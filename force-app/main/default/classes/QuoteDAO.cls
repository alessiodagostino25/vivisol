public with sharing class QuoteDAO {
    
    public static List<Quote__c> getQuotesFromIds(List<String> queryFields, List<Id> relatedIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
        query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Quote__c WHERE Id IN: relatedIds';
        System.debug('getQuotesFromIds QUERY: ' + query);
        
        return Database.query(query);
    }

    public static List<Quote__c> getQuotesFromCases(List<String> queryFields, List<Id> caseIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
        query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Quote__c WHERE Case__c IN: caseIds';
        System.debug('getQuotesFromCases QUERY: ' + query);
        
        return Database.query(query);
    }
    
    public static Quote__c getQuoteForOrderCreation(String quoteId){
        return [SELECT Id, Account_Name__c, Contract_Treatment__r.Contract_Framework__r.Customer__c,
                Case__c,Description__c,Contract_Treatment__c,Name,Delivery_Terms__c,Payment_Terms__c,Account_Name__r.Location__c,
                Street__c,PostalCode__c,City__c,StateCode__c,CountryCode__c,Contract_Treatment__r.Contract_Framework__r.Customer__r.Location__c,
                Contract_Treatment__r.Contract_Framework__r.Customer__r.LocationStreet__c,
                Contract_Treatment__r.Contract_Framework__r.Customer__r.LocationPostalCode__c,
                Contract_Treatment__r.Contract_Framework__r.Customer__r.LocationCity__c,
                Contract_Treatment__r.Contract_Framework__r.Customer__r.LocationStateCode__c,
                Contract_Treatment__r.Contract_Framework__r.Customer__r.LocationCountryCode__c,
				Contact__c,Price_Book__c,AccountManager__c,Contract_Treatment__r.Contract_framework__r.Customer_Request_Code__c,
                Contract_Treatment__r.Contract_framework__r.Customer_Purchase_Order_Number__c,
                Contract_Treatment__r.Contract_framework__r.Customer_Purchase_Order_Date__c,
                Location__c,Account_Sales_Organization__c, Discount__c, PaymentMethod__c, Account_Sold_To__c, Account_Bill_To__c, Payer__c 
                FROM Quote__c WHERE Id =: quoteId];
    }
    
    public static List<Quote_Line_Item__c> getQuoteLineItemByQuoteId(String quoteId){
        return [SELECT Description__c,Product__c,Max_discount__c,Asset__c,Box__c,Discount_Description__c,
                Pricebook__c,Total_VAT__c,Total_VAT_from_SAP__c,TotalPrice_excluding_VAT__c,TotalPrice_Including_VAT__c,
                VAT__c,Total_Amount_from_SAP_excluding_VAT__c,Total_Amount_from_SAP_including_VAT__c,Quantity__c, Discount__c, DiscountType__c
                FROM Quote_Line_Item__c WHERE Quote_Name__c =: quoteId];
    }

}