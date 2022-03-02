public with sharing class PicklistChoiseSetFlowDAO {
    public static List<Picklist_Choise_Set_Flow__c> getFamilyPCSFsFromParentAndValue(List<String> queryFields, List<Id> parentIds, List<String> codes) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
        query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Picklist_Choise_Set_Flow__c WHERE Parent_Id__c IN: parentIds AND Code__c IN: codes AND Type__c = \'F\'';
        System.debug('getFamilyPCSFsFromParentAndValue QUERY: ' + query);
        
        return Database.query(query);
    }

    public static List<Picklist_Choise_Set_Flow__c> getProductPCSFsFromParentAndValue(List<String> queryFields, List<Id> parentIds, List<String> codes) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
        query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Picklist_Choise_Set_Flow__c WHERE Parent_Id__c IN: parentIds AND Code__c IN: codes AND Type__c = \'P\'';
        System.debug('getProductPCSFsFromParentAndValue QUERY: ' + query);
        
        return Database.query(query);
    }
}