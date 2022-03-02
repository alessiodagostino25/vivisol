public with sharing class AccountTreatmentJobDAO {

	public static List<Account_Treatment_Job__c> getContractTreatmentJob(String selectedjobid) {

		return [select  Id, Contract_Treatment_Job__c from Account_Treatment_Job__c where Id = :selectedjobid];
	} 

	public static List<Account_Treatment_Job__c> getseletedjobsineditmodebyatid(String atid) {

		return [SELECT Id,Patient_Treatment__c,Contract_Treatment_Job__c FROM Account_Treatment_Job__c where Patient_Treatment__c = :atid ];
	}

	
	public static List<Account_Treatment_Job__c> getAccountTreatmentJobByACId(String accountTreatmentId) {

		return [select  Id, Contract_Treatment_Job__c from Account_Treatment_Job__c where Patient_Treatment__c =: accountTreatmentId];
	} 

	public static List<Account_Treatment_Job__c> getAccountTreatmentJobByACIdlist(List<String> accountTreatmentIds) {

		return [select  Id, Contract_Treatment_Job__c from Account_Treatment_Job__c where Patient_Treatment__c IN :accountTreatmentIds];
	} 
	
	public static List<Account_Treatment_Job__c> getselectJobs(String recordid2) {
		String query = 'select Id,Name,Patient_Treatment__c From Account_Treatment_Job__c';
		if(recordid2 != null && recordid2 != '') {
			query += ' WHERE Patient_Treatment__c = :recordid2 ';
		}
		system.debug(query);
		return Database.query(query);
	}

	public static List<Account_Treatment_Job__c> getaccounttreatmentjobbyatid(String accounttreatmentid) {
		String query = 'select Id,Name,Patient_Treatment__c,Contract_Treatment_Job__c From Account_Treatment_Job__c';
			query += ' WHERE Patient_Treatment__c = :accounttreatmentid ';
		system.debug(query);
		return Database.query(query);

	}
	public static List<Account_Treatment_Job__c> getaccounttreatmentjobbyatidslist(List<String> accounttreatmentids ) {
		String query = 'select Id,Name,Patient_Treatment__c,Contract_Treatment_Job__c From Account_Treatment_Job__c';
			query += ' WHERE Patient_Treatment__c = :accounttreatmentids  ';
		system.debug(query);
		return Database.query(query);

	}
	public static List<Account_Treatment_Job__c> getATJsFromAT(List<String> queryFields, Id accountTreatmentId) {
		String query = 'SELECT ';
		for(Integer i = 0; i < queryFields.size(); i++) {
		query += queryFields[i] + ', ';
		}
		query = query.substring(0, query.length() - 2);
		query += ' FROM Account_Treatment_Job__c WHERE Patient_Treatment__c =: accountTreatmentId';
		System.debug('getATJsFromAT QUERY: ' + query);
		
		return Database.query(query);
	}

	public static List<Account_Treatment_Job__c> getAccounttreatmentjobfield(List<Id> accounttreatmentids, List<Id> contreatmentjobParentids) {
		String query = 'SELECT  Id , Contract_Treatment_Job__c  , Account_Treatment_Job__c ,Patient_Treatment__c From Account_Treatment_Job__c where Patient_Treatment__c IN :accounttreatmentids AND Contract_Treatment_Job__c IN :contreatmentjobParentids';

		System.debug(query);
		return Database.query(query);
	}

	public static List<Account_Treatment_Job__c> getDependentATJsFromATJIds(List<String> queryFields, List<Id> ATJIds) {
		String query = 'SELECT ';
		for(Integer i = 0; i < queryFields.size(); i++) {
			query += queryFields[i] + ', ';
		}
		query = query.substring(0, query.length() - 2);
		query += ' FROM Account_Treatment_Job__c WHERE Account_Treatment_Job__c IN: ATJIds AND Scheduling_Rule__c = \'Dependent Job Execution\'';
		System.debug('getDependentATJsFromATJIds QUERY: ' + query);
		
		return Database.query(query);
	}

	public static List<Account_Treatment_Job__c> getATJSFROMIds(List<String> queryFields, List<Id> relatedIds) {
		String query = 'SELECT ';
		for(Integer i = 0; i < queryFields.size(); i++) {
			query += queryFields[i] + ', ';
		}
		query = query.substring(0, query.length() - 2);
		query += ' FROM Account_Treatment_Job__c WHERE Id IN: relatedIds';
		System.debug('getATJSFROMIds QUERY: ' + query);
		
		return Database.query(query);
	}

	public static List<Account_Treatment_Job__c> getATJsFromATIds(List<String> queryFields, List<Id> accountTreatmentIds) {
		String query = 'SELECT ';
		for(Integer i = 0; i < queryFields.size(); i++) {
			query += queryFields[i] + ', ';
		}
		query = query.substring(0, query.length() - 2);
		query += ' FROM Account_Treatment_Job__c WHERE Patient_Treatment__c IN: accountTreatmentIds';
		System.debug('getATJsFromATIds QUERY: ' + query);
		
		return Database.query(query);
	}

	public static List<Account_Treatment_Job__c> getATJsFromATsAndCTJs(List<String> queryFields, List<Id> ATIds, List<Id> CTJIds) {
		String query = 'SELECT ';
		for(Integer i = 0; i < queryFields.size(); i++) {
			query += queryFields[i] + ', ';
		}
		query = query.substring(0, query.length() - 2);
		query += ' FROM Account_Treatment_Job__c WHERE Patient_Treatment__c IN: ATIds AND Contract_Treatment_Job__c IN: CTJIds';
		System.debug('getATJsFromATsAndCTJs QUERY: ' + query);
		
		return Database.query(query);
	}

}