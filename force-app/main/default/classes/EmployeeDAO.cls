public without sharing class EmployeeDAO {

    public static List<Employee__c> getAStatusEmployeeByCompany(List<String> queryFields, List<String> companyId) {
        //String statusValue = 'A';
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
            query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        //query += ' FROM Employee__c WHERE Company__c IN :companyId AND Status__c = :statusValue';
        query += ' FROM Employee__c WHERE Company__c IN :companyId AND (Exit_Date__c = null OR Exit_Date__c > TODAY)';

        return Database.query(query);
    }

}