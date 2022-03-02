public with sharing class AccountTreatmentDAO {


    public static List<Account_Treatment__c> getAccountTreatmentListbyId() {
        String query = 'select Id,Name From Account_Treatment__c';
        system.debug(query) ;
        return Database.query( query );
    }
    
    public static List<Account_Treatment__c> getAccountTreatmentListbyAccountId( String accountId) {
        String query = 'select Name, Status__c, Activation_Date__c, Treatment_Type__c, Treatment__c, Contract_Treatment__c From Account_Treatment__c where Account__c = :accountId';
        system.debug(query) ;
        return Database.query( query );
    }

    public static List<Account_Treatment__c> getAccountTreatmentListbyAccountIdWithLimit( String accountId) {
        String query = 'select Name, toLabel(Status__c), Activation_Date__c, Treatment_Type__c, Treatment__c, Contract_Treatment__c '+ 
        ' From Account_Treatment__c where Account__c = :accountId LIMIT 3';
        system.debug(query) ;
        return Database.query( query );
    }

    public static List<Account_Treatment__c> getAccountTreatmentNamebyId(String atid) {
        String query = 'select Id,Name From Account_Treatment__c Where Id = :atid';
        system.debug(query) ;
        return Database.query( query );
    }
    public static List<Account_Treatment__c> getrecordnameandtreatment(String accounttreatmentrecordid) {
        String query = 'SELECT RecordType.developername,Treatment_Type__c,Contract_Treatment__c  FROM Account_Treatment__c where id = :accounttreatmentrecordid';
        system.debug(query) ;
        return Database.query( query );
    }
    public static List<Account_Treatment__c> getaccounttreatmentstatus(String accounttreatmentrecordid) {
        String query = 'SELECT Status__c FROM Account_Treatment__c where id = :accounttreatmentrecordid';
        system.debug(query) ;
        return Database.query( query );
    }

    public static Account_Treatment__c getAccountTreatmentFromId(List<String> queryFields, Id accountTreatmentId) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
        query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Account_Treatment__c WHERE Id =: accountTreatmentId';
        System.debug('getAccountTreatmentFromId QUERY: ' + query);
        
        return Database.query(query);
    }

    public static List<Account_Treatment__c> getAccountTreatmentsFromIds(List<String> queryFields, List<Id> relatedIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
        query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Account_Treatment__c WHERE Id IN: relatedIds';
        System.debug('getAccountTreatmentsFromIds QUERY: ' + query);
        
        return Database.query(query);
    }

    public static List<Account_Treatment__c> getaccounttreatmentfieldvaluesforatids(List<String> AccountTreatmentfields,List<String> accounttreatmentids)  {
        String query1 = 'SELECT Prescription__c,';
    for (Integer i = 0; i < AccountTreatmentfields.size(); i++){
        query1 += AccountTreatmentfields[i] + ' ,';
    }
    if (AccountTreatmentfields.size() != 0){
        query1 = query1.substring(0, query1.length() - 1);
    }
        query1 += 'FROM Account_Treatment__c Where id IN :accounttreatmentids';
        system.debug(query1) ;
        return Database.query( query1 );
    }

    public static List<Account_Treatment__c> getActiveMaintenanceATsFromIds(List<String> queryFields, List<Id> relatedIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
        query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Account_Treatment__c WHERE Id IN: relatedIds AND Status__c = \'A\' AND RecordType.DeveloperName = \'AccountTreatment_Maintenance\'';
        System.debug('getActiveMaintenanceATsFromIds QUERY: ' + query);
        
        return Database.query(query);
    }

    public static List<Account_Treatment__c> getTherapyATsFromIds(List<String> queryFields, List<Id> relatedIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
        query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Account_Treatment__c WHERE Id IN: relatedIds AND RecordType.DeveloperName = \'AccountTreatment_Therapy\'';
        System.debug('getTherapyATsFromIds QUERY: ' + query);
        
        return Database.query(query);
    }

    public static List<Account_Treatment__c> getActiveATsFromCFIds(List<String> queryFields, List<String> CFIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
        query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Account_Treatment__c WHERE Contract_Treatment__r.Contract_Framework__c IN: CFIds AND Status__c != \'R\' AND Status__c != \'D\' ' +
        'AND Contract_Treatment__r.Scheduling_after_end_date__c = false';
        System.debug('getActiveATsFromCFIds QUERY: ' + query);
        
        return Database.query(query);
    }

    public static List<Account_Treatment__c> getOtherATsFromAccounts(List<String> queryFields, List<String> accountIds, List<String> toAvoid) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
        query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Account_Treatment__c WHERE Id NOT IN: toAvoid AND Account__c IN: accountIds';
        System.debug('getOtherATsFromAccounts QUERY: ' + query);
        
        return Database.query(query);
    }

    public static List<Account_Treatment__c> getATsFromExternalIds(List<String> queryFields, List<String> externalIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
        query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Account_Treatment__c WHERE External_Id__c IN: externalIds';
        System.debug('getATsFromExternalIds QUERY: ' + query);
        
        return Database.query(query);
    }
}