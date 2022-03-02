public with sharing class ContractTreatmentJobProductDAO {
    public static List<Contract_Treatment_Job_Product__c> getContractTreatmentJobProduct(List<id> queryResults){


        String Inactive = 'Inactive' ;
        String query = 'SELECT Product__c, Id ,Status__c FROM Contract_Treatment_Job_Product__c WHERE Contract_Treatment_Job__c IN :queryResults AND Status__c !=: Inactive ';
        system.debug(query);
		return Database.query(query);
     
    }

    public static List<Contract_Treatment_Job_Product__c> getContractTreatmentJobProductListByCTJId(String contractTreatmentJobId) {

        String query = 'SELECT Id, Name, Product__c, Family__c, Frequency__c, Status__c FROM Contract_Treatment_Job_Product__c';
        query += ' WHERE Contract_Treatment_Job__c =:contractTreatmentJobId' ;
	
		system.debug(query);
		return Database.query(query);
    }

    public static List<Contract_Treatment_Job_Product__c> getCTJPsFromJob(List<String> queryFields, Id contractTreatmentJobId) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
        query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Contract_Treatment_Job_Product__c WHERE Contract_Treatment_Job__c =: contractTreatmentJobId';
        System.debug('getCTJPsFromJob QUERY: ' + query);
        
        return Database.query(query);
    }

    public static List<Contract_Treatment_Job_Product__c> getActiveCTJPsFromCTJs(List<String> queryFields, List<String> CTJIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
        query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Contract_Treatment_Job_Product__c WHERE Contract_Treatment_Job__c IN: CTJIds AND Status__c = \'Active\'';
        System.debug('getActiveCTJPsFromCTJs QUERY: ' + query);
        
        return Database.query(query);
    }

    public static List<Contract_Treatment_Job_Product__c> getCTJPsFromIds(List<String> queryFields, List<Id> relatedIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
        query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Contract_Treatment_Job_Product__c WHERE Id IN: relatedIds';
        System.debug('getCTJPsFromIds QUERY: ' + query);
        
        return Database.query(query);
    }

    public static List<Contract_Treatment_Job_Product__c> getCTJPsFromJobAndProducts(List<String> queryFields, List<Id> productIds, Id contractTreatmentJobId) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
        query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Contract_Treatment_Job_Product__c WHERE Product__c IN: productIds AND Contract_Treatment_Job__c =: contractTreatmentJobId';
        System.debug('getCTJPsFromJobAndProducts QUERY: ' + query);
        
        return Database.query(query);
    }

    public static List<Contract_Treatment_Job_Product__c> getCTJPsFromCTJIds(List<String> queryFields, Set<Id> CTJIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
        query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Contract_Treatment_Job_Product__c WHERE Contract_Treatment_Job__c IN: CTJIds';
        System.debug('getCTJPsFromCTJIds QUERY: ' + query);
        
        return Database.query(query);
    }

    public static List<Contract_Treatment_Job_Product__c> getCTJPsFromJobAndProductsFamilyAndSingle(List<String> queryFields, List<Id> productIds, Id contractTreatmentJobId) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
        query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Contract_Treatment_Job_Product__c WHERE Product__c IN: productIds AND Contract_Treatment_Job__c =: contractTreatmentJobId AND Status__c = \'Active\'';
        System.debug('getCTJPsFromJobAndProductsFamilyAndSingle QUERY: ' + query);
        
        return Database.query(query);
    }

    public static List<Contract_Treatment_Job_Product__c> getCTJPsFromCTIds(List<String> queryFields, List<String> CTIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
        query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Contract_Treatment_Job_Product__c WHERE Contract_Treatment_Job__r.Contract_Treatment__c IN: CTIds';
        System.debug('getCTJPsFromCTIds QUERY: ' + query);
        
        return Database.query(query);
    }
   
}