public with sharing class AccountSalesOrganizationDAO {
    public static List<Account_Sales_Organization__c> getASOs(List<Id> relatedIds) {
        List<Account_Sales_Organization__c> asoList = [SELECT Id, Name, Account__c, Account__r.Account_External_Id__c, Account_Assignment_Group__c, 
                                                       Account__r.IsPersonAccount, Account__r.Name, Account__r.FirstName, Account__r.MiddleName, 
                                                       Account__r.LastName, Authorization_group__c, Billing_Method__c,
                                                       Code__c, CreatedById, Credit_Limit__c, Currency__c,
                                                       Customer_Group__c, Customer_Statistics_Group__c, Distribution_Channel__c, 
                                                       Division__c, Invoice_grouping_Y_N__c, Invoicing_Dates__c, 
                                                       LastModifiedById, Payment_Terms__c, POD_Relevant__c, Price_Group__c, 
                                                       Price_Procedure_Dterm__c, Pricelist__c, Responsabile_Vivisol_Account_Manager__c, 
                                                       Responsabile_Vivisol_Account_Manager__r.Account_External_Id__c,
                                                       Sales_district__c, Sales_Group__c, Sales_Office__c, Sales_Organization__c, Sales_Organization__r.Code__c,
                                                       Sales_Organization__r.Name, Shipping_Conditions__c,
                                                       isCreatedSAP__c, isSyncSAP__c, External_Id__c, Dunning_Via__c 
                                                       FROM Account_Sales_Organization__c WHERE Id IN: relatedIds];
        return asoList;
    }

    public static List<Account> getRelatedAccounts(List<Id> relatedAccountIds) {
        List<Account> relatedAccounts = [SELECT Id, Account_Sales_Organizations__c, IsPersonAccount, Account_External_Id__c FROM Account WHERE Id IN: relatedAccountIds];
        return relatedAccounts;
    }

    public static Account_Sales_Organization__c getASO(Id relatedId) {
        Account_Sales_Organization__c aso = [SELECT Id, Name, Account__c, Account__r.Account_External_Id__c, Account_Assignment_Group__c, 
                                                       Account__r.IsPersonAccount, Account__r.Name, Account__r.FirstName, Account__r.MiddleName, 
                                                       Account__r.LastName, Authorization_group__c, Billing_Method__c,
                                                       Code__c, CreatedById, Credit_Limit__c, Currency__c,
                                                       Customer_Group__c, Customer_Statistics_Group__c, Distribution_Channel__c, 
                                                       Division__c, Invoice_grouping_Y_N__c, Invoicing_Dates__c, 
                                                       LastModifiedById, Payment_Terms__c, POD_Relevant__c, Price_Group__c, 
                                                       Price_Procedure_Dterm__c, Pricelist__c, Responsabile_Vivisol_Account_Manager__c, 
                                                       Responsabile_Vivisol_Account_Manager__r.Account_External_Id__c,
                                                       Sales_district__c, Sales_Group__c, Sales_Office__c, Sales_Organization__c, Sales_Organization__r.Code__c,
                                                       Sales_Organization__r.Name, Shipping_Conditions__c,
                                                       isCreatedSAP__c, isSyncSAP__c 
                                                       FROM Account_Sales_Organization__c WHERE Id =: relatedId];
        return aso;
    }

    public static List<Account_Sales_Organization__c> getASOsFromIds(List<String> queryFields, List<Id> relatedIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
        query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Account_Sales_Organization__c WHERE Id IN: relatedIds';
        System.debug('getASOsFromIds QUERY: ' + query);
        
        return Database.query(query);
    }

    public static List<Account_Sales_Organization__c> getASOsFromRecordIds(List<String> queryFields, List<String> recordIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
          query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Account_Sales_Organization__c WHERE External_Id__c IN: recordIds';
        System.debug('getASOsFromRecordIds QUERY: ' + query);
        
        return Database.query(query);
    }

    public static List<Account_Sales_Organization__c> getASOsFromSOIds(List<String> queryFields, List<Id> SOIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
        query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Account_Sales_Organization__c WHERE Sales_Organization__c IN: SOIds';
        System.debug('getASOsFromSOIds QUERY: ' + query);
        
        return Database.query(query);
    }

    public static List<Account_Sales_Organization__c> getASOsFromSOsAndAccounts(List<String> queryFields, List<String> SOIds, List<String> accountIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
        query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Account_Sales_Organization__c WHERE Sales_Organization__c IN: SOIds AND Account__c IN: accountIds';
        System.debug('getASOsFromSOsAndAccounts QUERY: ' + query);
        
        return Database.query(query);
    }
}