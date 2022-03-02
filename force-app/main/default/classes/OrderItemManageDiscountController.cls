public without sharing class OrderItemManageDiscountController {
    public class MissingFieldException extends Exception {}

    @AuraEnabled
    public static void handleManualPriceDiscount(String orderItemId, String discountType, Decimal totalPriceExVAT) {
        System.debug('----- handleManualPriceDiscount -----');
        System.debug('totalPriceExVAT: ' + totalPriceExVAT);

        List<String> orderItemQueryFields = new List<String>{'TotalPrice_excluding_VAT__c', 'VAT__c', 'Discount__c', 'DiscountType__c', 'Total_VAT__c'};

        List<OrderItem> orderItemList = OrderItemDAO.getOrderItemsFromIds(orderItemQueryFields, new List<String>{orderItemId});

        if(orderItemList != null && !orderItemList.isEmpty()) {
            OrderItem orderItem = orderItemList[0];

            if(orderItem != null) {
                if(discountType == 'MAN_PRICE') {
                    orderItem.TotalPrice_excluding_VAT__c = totalPriceExVAT;

                    if(orderItem.VAT__c != null) {
                        orderItem.TotalPrice_Including_VAT__c = totalPriceExVAT * (1 + (orderItem.VAT__c / 100));
                        orderItem.Total_VAT__c = totalPriceExVAT * (orderItem.VAT__c / 100);
                    }
                    else {
                        throw new MissingFieldException(Label.ManageDiscount_Exception_MissingField);
                    }

                    orderItem.Discount__c = null;
                    orderItem.DiscountType__c = 'MAN_PRICE';

                    Database.SaveResult result = Database.update(orderItem);
                }
            }
        }
    }

    @AuraEnabled
    public static void handlePercentageDiscount(String orderItemId, String discountType, Decimal discountPercentage) {
        System.debug('----- handlePercentageDiscount -----');
        System.debug('discountPercentage: ' + discountPercentage);

        List<String> orderItemQueryFields = new List<String>{'TotalPrice_excluding_VAT__c', 'VAT__c', 'Discount__c', 'DiscountType__c', 'Total_VAT__c', 
        'Total_Amount_from_SAP_excluding_VAT__c', 'Total_Amount_from_SAP_including_VAT__c', 'Total_VAT_from_SAP__c'};

        List<OrderItem> orderItemList = OrderItemDAO.getOrderItemsFromIds(orderItemQueryFields, new List<String>{orderItemId});

        if(orderItemList != null && !orderItemList.isEmpty()) {
            OrderItem orderItem = orderItemList[0];

            if(orderItem != null) {
                if(discountType == 'PERC') {
                    if(orderItem.Total_Amount_from_SAP_excluding_VAT__c != null) {
                        orderItem.TotalPrice_excluding_VAT__c = (1 - (discountPercentage / 100)) * orderItem.Total_Amount_from_SAP_excluding_VAT__c;
                    }
                    else {
                        throw new MissingFieldException(Label.ManageDiscount_Exception_MissingField);
                    }
                    if(orderItem.Total_Amount_from_SAP_including_VAT__c != null) {
                        orderItem.TotalPrice_Including_VAT__c = (1 - (discountPercentage / 100)) * orderItem.Total_Amount_from_SAP_including_VAT__c;
                    }
                    else {
                        throw new MissingFieldException(Label.ManageDiscount_Exception_MissingField);
                    }
                    if(orderItem.Total_VAT_from_SAP__c != null) {
                        orderItem.Total_VAT__c = (1 - (discountPercentage / 100)) * orderItem.Total_VAT_from_SAP__c;
                    }
                    else {
                        throw new MissingFieldException(Label.ManageDiscount_Exception_MissingField);
                    }
                    
                    orderItem.Discount__c = discountPercentage;
                    orderItem.DiscountType__c = 'PERC';

                    Database.SaveResult result = Database.update(orderItem);
                }
            }
        }
    }

    @AuraEnabled
    public static void clearDiscount(String orderItemId) {
        System.debug('----- clearDiscount -----');

        List<String> orderItemQueryFields = new List<String>{'TotalPrice_excluding_VAT__c', 'VAT__c', 'Discount__c', 'DiscountType__c', 'Total_VAT__c', 
        'Total_Amount_from_SAP_excluding_VAT__c', 'Total_Amount_from_SAP_including_VAT__c', 'Total_VAT_from_SAP__c'};

        List<OrderItem> orderItemList = OrderItemDAO.getOrderItemsFromIds(orderItemQueryFields, new List<String>{orderItemId});

        if(orderItemList != null && !orderItemList.isEmpty()) {
            OrderItem orderItem = orderItemList[0];

            if(orderItem != null) {
                orderItem.DiscountType__c = null;
                orderItem.Discount__c = null;
                orderItem.TotalPrice_excluding_VAT__c = orderItem.Total_Amount_from_SAP_excluding_VAT__c;
                orderItem.TotalPrice_Including_VAT__c = orderItem.Total_Amount_from_SAP_including_VAT__c;
                orderItem.Total_VAT__c = orderItem.Total_VAT_from_SAP__c;

                Database.SaveResult result = Database.update(orderItem);
            }
        }
    }
}