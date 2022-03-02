public with sharing class AccountTreatmentJobProductDAO {
	public static List<Account_Treatment_Job_Product__c> getSelectedProducts(String selectedjobid2) {
		String query = 'select Id,Name,Patient_Treatment_Job__c,ProductName__c,Product__c From Account_Treatment_Job_Product__c';
		if(selectedjobid2 != null && selectedjobid2 != '') {
			query += ' WHERE Patient_Treatment_Job__c = :selectedjobid2 ';
		}
		system.debug(query);
		return Database.query(query);
	}

	public static List<Account_Treatment_Job_Product__c> getActiveProductsFromATJs(List<String> queryFields, List<Id> accountTreatmentJobIds) {
		String query = 'SELECT ';
		for(Integer i = 0; i < queryFields.size(); i++) {
		query += queryFields[i] + ', ';
		}
		query = query.substring(0, query.length() - 2);
		query += ' FROM Account_Treatment_Job_Product__c WHERE Patient_Treatment_Job__c IN: accountTreatmentJobIds AND Status__c = \'Active\'';
		System.debug('getActiveProductsFromATJ QUERY: ' + query);
		
		return Database.query(query);
	}

	public static List<Account_Treatment_Job_Product__c> getAssetActiveProductsFromATJs(List<String> queryFields, List<Id> accountTreatmentJobIds) {
		String query = 'SELECT ';
		for(Integer i = 0; i < queryFields.size(); i++) {
		query += queryFields[i] + ', ';
		}
		query = query.substring(0, query.length() - 2);
		query += ' FROM Account_Treatment_Job_Product__c WHERE Patient_Treatment_Job__c IN: accountTreatmentJobIds AND Asset__c != null AND Status__c = \'Active\'';
		System.debug('getAssetActiveProductsFromATJs QUERY: ' + query);
		
		return Database.query(query);
	}

	public static List<Account_Treatment_Job_Product__c> getNotAssetActiveProductsFromATJs(List<String> queryFields, List<Id> accountTreatmentJobIds) {
		String query = 'SELECT ';
		for(Integer i = 0; i < queryFields.size(); i++) {
		query += queryFields[i] + ', ';
		}
		query = query.substring(0, query.length() - 2);
		query += ' FROM Account_Treatment_Job_Product__c WHERE Patient_Treatment_Job__c IN: accountTreatmentJobIds AND Asset__c = null AND Status__c = \'Active\'';
		System.debug('getNotAssetActiveProductsFromATJs QUERY: ' + query);
		
		return Database.query(query);
	}

	public static List<Account_Treatment_Job_Product__c> getAssetActiveProductsFromIds(List<String> queryFields, List<Id> relatedIds) {
		String query = 'SELECT ';
		for(Integer i = 0; i < queryFields.size(); i++) {
		query += queryFields[i] + ', ';
		}
		query = query.substring(0, query.length() - 2);
		query += ' FROM Account_Treatment_Job_Product__c WHERE Id IN: relatedIds AND Asset__c != null AND Status__c = \'Active\' ' +
		'AND Patient_Treatment_Job__r.Patient_Treatment__r.Status__c = \'A\' ' + 
		'AND Patient_Treatment_Job__r.Patient_Treatment__r.RecordType.DeveloperName = \'AccountTreatment_Maintenance\'';
		System.debug('getAssetActiveProductsFromIds QUERY: ' + query);
		
		return Database.query(query);
	}

	public static List<Account_Treatment_Job_Product__c> getATJPsFromIds(List<String> queryFields, List<Id> relatedIds) {
		String query = 'SELECT ';
		for(Integer i = 0; i < queryFields.size(); i++) {
		query += queryFields[i] + ', ';
		}
		query = query.substring(0, query.length() - 2);
		query += ' FROM Account_Treatment_Job_Product__c WHERE Id IN: relatedIds ';
		System.debug('getATJPsFromIds QUERY: ' + query);
		
		return Database.query(query);
	}

	public static List<Account_Treatment_Job_Product__c> getProductsFromATJs(List<String> queryFields, String accountTreatmentJobId) {
		String query = 'SELECT ';
		for(Integer i = 0; i < queryFields.size(); i++) {
		query += queryFields[i] + ', ';
		}
		query = query.substring(0, query.length() - 2);
		query += ' FROM Account_Treatment_Job_Product__c WHERE Patient_Treatment_Job__c =: accountTreatmentJobId ';
		System.debug('getProductsFromATJs QUERY: ' + query);
		
		return Database.query(query);
	}

	public static List<Account_Treatment_Job_Product__c> getcontractassetrelatedATJs(List<String> queryFields, List<Id> caCTIds,List<Id> caAssetIds) {
		String query = 'SELECT ';
		for(Integer i = 0; i < queryFields.size(); i++) {
		query += queryFields[i] + ', ';
		}
		query = query.substring(0, query.length() - 2);
		query += ' FROM Account_Treatment_Job_Product__c WHERE Patient_Treatment_Job__r.Patient_Treatment__r.Contract_Treatment__c IN:caCTIds AND Asset__c IN:caAssetIds ';
		System.debug('getcontractassetrelatedATJs QUERY: ' + query);
		
		return Database.query(query);
	}


}