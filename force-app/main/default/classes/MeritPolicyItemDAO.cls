public without sharing class MeritPolicyItemDAO {

    public static List<Merit_Policy_Item__c> getMeritPolicyItemByEmpoleeAndYear(List<String> queryFields, List<String> employeeIds, String year) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
            query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Merit_Policy_Item__c WHERE Employee__c  IN :employeeIds AND Merit_Policy_Header__r.Year__c = :year';

        return Database.query(query);
    }
}