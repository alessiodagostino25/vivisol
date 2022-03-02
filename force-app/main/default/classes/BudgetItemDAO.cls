public with sharing class BudgetItemDAO {
    public static List<Budget_Item__c> getBudgetItemsFromYearMonthCompany(List<String> queryFields, List<String> years, List<String> months, List<String> companyIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
        query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Budget_Item__c WHERE Year__c IN: years AND Month__c IN: months AND Company__c IN: companyIds';

        System.debug('getBudgetItemsFromYearMonthCompany QUERY: ' + query);
        
        return Database.query(query);
    }
}