public with sharing class AccountPartnerFunctionDAO {
    public static List<Account_Partner_Function__c> getAPFsFromPFAndASO(List<String> queryFields, List<String> partnerFunctions, List<String> ASOIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
            query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Account_Partner_Function__c WHERE Partner_Functionc__c IN: partnerFunctions AND Account_Sales_Organization__c IN: ASOIds';
        System.debug('getAPFsFromPFAndASO QUERY: ' + query);
        
        return Database.query(query);
    }
}