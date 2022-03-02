public without sharing class QLIManageDiscountController {
    public class MissingFieldException extends Exception {}

    @AuraEnabled
    public static void handleManualPriceDiscount(String quoteLineItemId, String discountType, Decimal totalPriceExVAT) {
        System.debug('----- handleManualPriceDiscount -----');
        System.debug('totalPriceExVAT: ' + totalPriceExVAT);

        List<String> quoteLineItemQueryFields = new List<String>{'TotalPrice_excluding_VAT__c', 'VAT__c', 'Discount__c', 'DiscountType__c', 'Total_VAT__c'};

        List<Quote_Line_Item__c> quoteLineItemList = QuoteLineItemDAO.getQLIsFromIds(quoteLineItemQueryFields, new List<String>{quoteLineItemId});

        if(quoteLineItemList != null && !quoteLineItemList.isEmpty()) {
            Quote_Line_Item__c quoteLineItem = quoteLineItemList[0];

            if(quoteLineItem != null) {
                if(discountType == 'MAN_PRICE') {
                    quoteLineItem.TotalPrice_excluding_VAT__c = totalPriceExVAT;

                    if(quoteLineItem.VAT__c != null) {
                        quoteLineItem.TotalPrice_Including_VAT__c = totalPriceExVAT * (1 + (quoteLineItem.VAT__c / 100));
                        quoteLineItem.Total_VAT__c = totalPriceExVAT * (quoteLineItem.VAT__c / 100);
                    }
                    else {
                        throw new MissingFieldException(Label.ManageDiscount_Exception_MissingField);
                    }

                    quoteLineItem.Discount__c = null;
                    quoteLineItem.DiscountType__c = 'MAN_PRICE';

                    Database.SaveResult result = Database.update(quoteLineItem);
                }
            }
        }
    }

    @AuraEnabled
    public static void handlePercentageDiscount(String quoteLineItemId, String discountType, Decimal discountPercentage) {
        System.debug('----- handlePercentageDiscount -----');
        System.debug('discountPercentage: ' + discountPercentage);

        List<String> quoteLineItemQueryFields = new List<String>{'TotalPrice_excluding_VAT__c', 'VAT__c', 'Discount__c', 'DiscountType__c', 'Total_VAT__c', 
        'Total_Amount_from_SAP_excluding_VAT__c', 'Total_Amount_from_SAP_including_VAT__c', 'Total_VAT_from_SAP__c'};

        List<Quote_Line_Item__c> quoteLineItemList = QuoteLineItemDAO.getQLIsFromIds(quoteLineItemQueryFields, new List<String>{quoteLineItemId});

        if(quoteLineItemList != null && !quoteLineItemList.isEmpty()) {
            Quote_Line_Item__c quoteLineItem = quoteLineItemList[0];

            if(quoteLineItem != null) {
                if(discountType == 'PERC') {
                    if(quoteLineItem.Total_Amount_from_SAP_excluding_VAT__c != null) {
                        quoteLineItem.TotalPrice_excluding_VAT__c = (1 - (discountPercentage / 100)) * quoteLineItem.Total_Amount_from_SAP_excluding_VAT__c;
                    }
                    else {
                        throw new MissingFieldException(Label.ManageDiscount_Exception_MissingField);
                    }
                    if(quoteLineItem.Total_Amount_from_SAP_including_VAT__c != null) {
                        quoteLineItem.TotalPrice_Including_VAT__c = (1 - (discountPercentage / 100)) * quoteLineItem.Total_Amount_from_SAP_including_VAT__c;
                    }
                    else {
                        throw new MissingFieldException(Label.ManageDiscount_Exception_MissingField);
                    }
                    if(quoteLineItem.Total_VAT_from_SAP__c != null) {
                        quoteLineItem.Total_VAT__c = (1 - (discountPercentage / 100)) * quoteLineItem.Total_VAT_from_SAP__c;
                    }
                    else {
                        throw new MissingFieldException(Label.ManageDiscount_Exception_MissingField);
                    }
                    
                    quoteLineItem.Discount__c = discountPercentage;
                    quoteLineItem.DiscountType__c = 'PERC';

                    Database.SaveResult result = Database.update(quoteLineItem);
                }
            }
        }
    }

    @AuraEnabled
    public static void clearDiscount(String quoteLineItemId) {
        System.debug('----- clearDiscount -----');

        List<String> quoteLineItemQueryFields = new List<String>{'TotalPrice_excluding_VAT__c', 'VAT__c', 'Discount__c', 'DiscountType__c', 'Total_VAT__c', 
        'Total_Amount_from_SAP_excluding_VAT__c', 'Total_Amount_from_SAP_including_VAT__c', 'Total_VAT_from_SAP__c'};

        List<Quote_Line_Item__c> quoteLineItemList = QuoteLineItemDAO.getQLIsFromIds(quoteLineItemQueryFields, new List<String>{quoteLineItemId});

        if(quoteLineItemList != null && !quoteLineItemList.isEmpty()) {
            Quote_Line_Item__c quoteLineItem = quoteLineItemList[0];

            if(quoteLineItem != null) {
                quoteLineItem.DiscountType__c = null;
                quoteLineItem.Discount__c = null;
                quoteLineItem.TotalPrice_excluding_VAT__c = quoteLineItem.Total_Amount_from_SAP_excluding_VAT__c;
                quoteLineItem.TotalPrice_Including_VAT__c = quoteLineItem.Total_Amount_from_SAP_including_VAT__c;
                quoteLineItem.Total_VAT__c = quoteLineItem.Total_VAT_from_SAP__c;

                Database.SaveResult result = Database.update(quoteLineItem);
            }
        }
    }
}