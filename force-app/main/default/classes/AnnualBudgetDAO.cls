public without sharing class AnnualBudgetDAO {

    public static List<Annual_Budget__c> getAnnualBudgetsByCompany(List<String> queryFields, List<String> companyId) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
            query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Annual_Budget__c WHERE Company__c IN :companyId';

        return Database.query(query);
    }

}