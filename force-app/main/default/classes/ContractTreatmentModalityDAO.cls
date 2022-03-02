public with sharing class ContractTreatmentModalityDAO {
    public static List<Contract_Treatment_Modality__c> getCTModalitiesFromCTsAndRTs(List<String> queryFields, List<String> CTIds, List<String> recordTypeNames) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
            query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Contract_Treatment_Modality__c WHERE Contract_Treatment__c IN: CTIds AND RecordType.DeveloperName IN: recordTypeNames';
        System.debug('getCTModalitiesFromCTsAndRTs QUERY: ' + query);
        
        return Database.query(query);
    }

    /* public static List<Contract_Treatment_Modality__c> getCTModalitiesFromIds(List<String> queryFields, List<String> relatedIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
            query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Contract_Treatment_Modality__c WHERE Id IN: relatedIds';
        System.debug('getCTModalitiesFromIds QUERY: ' + query);
        
        return Database.query(query);
    } */

    public static List<Contract_Treatment_Modality__c> getActiveCTMsFromCTs(List<String> queryFields, List<String> CTIds, List<String> toExclude) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
            query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Contract_Treatment_Modality__c WHERE Contract_Treatment__c IN: CTIds AND Status__c = \'Active\'';

        if(toExclude != null && !toExclude.isEmpty()) {
            query += ' AND Id NOT IN: toExclude';
        }
        System.debug('getActiveCTMsFromCTs QUERY: ' + query);
        
        return Database.query(query);
    }

    public static List<Contract_Treatment_Modality__c> getCTModalitiesForATTreatmentModality(List<String> queryFields, List<String> CTIds, List<String> subTreatments, 
    List<String> installationTypes) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
            query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Contract_Treatment_Modality__c WHERE Contract_Treatment__c IN: CTIds AND RecordType.DeveloperName = \'CTM_Treatment\' AND ' +
        '(Sub_Treatment__c IN: subTreatments OR Installation_Type__c IN: installationTypes)';
        System.debug('getCTModalitiesForATTreatmentModality QUERY: ' + query);
        
        return Database.query(query);
    }
}