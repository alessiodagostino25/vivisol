public with sharing class PayrollHeaderDAO {
    public static List<Payroll_Header__c> getPayrollHeadersFromIds(List<String> queryFields, List<String> relatedIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
        	query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Payroll_Header__c WHERE Id IN: relatedIds';
        System.debug('getPayrollHeadersFromIds QUERY: ' + query);
        
        return Database.query(query);
    }
}