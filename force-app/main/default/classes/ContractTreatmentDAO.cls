public with sharing class ContractTreatmentDAO {
    
    public static List<Contract_Treatment__c> getContractTreatmentByName(String searchKey ,List<String> preselectedrowslist){
    	String query = 'select Id,Name,Customer_Purchase_Order_Number__c,Customer_Name__c,Customer_Treatment_Alias__c,Customer_Request_Code__c,Customer_Purchase_Order_Date__c,Contract_Framework__r.Customer__r.Uzovi_code__c,Threshold_hour__c,Threshold_day__c,Contract_End_Date__c From Contract_Treatment__c ';
		if(searchKey != null && searchKey != '') {
			String key = '%' + searchKey + '%';
			if(preselectedrowslist != null && preselectedrowslist.size() > 0) {
				query += ' WHERE (Name LIKE :key OR Customer_Name__c LIKE :KEY OR Contract_Framework__r.Customer__r.Uzovi_code__c LIke :KEY OR Id In :preselectedrowslist )';
			} else {
				query += ' WHERE (Name LIKE :key OR Customer_Name__c LIKE :KEY OR Contract_Framework__r.Customer__r.Uzovi_code__c LIke :KEY)';
			}
			query += 'AND Contract_Framework__r.Contract_End_Date__c > TODAY AND Contract_Framework__r.Contract_End_Date__c != null ';
		} else {
			query += 'WHERE Contract_Framework__r.Contract_End_Date__c > TODAY AND Contract_Framework__r.Contract_End_Date__c != null';
		}
		
		system.debug(query);
		return Database.query(query);
	}

	public static List<Contract_Treatment__c> getContractTreatmentByFrameworkStatus(String searchKey ,List<String> preselectedrowslist, String recordType, String therapy, String business){
		String Active = 'Active' ;
		String query = 'select Id,Name,Customer_Purchase_Order_Number__c,Customer_Name__c,Customer_Treatment_Alias__c,Customer_Request_Code__c,Customer_Purchase_Order_Date__c,Contract_Framework__r.Customer__r.Uzovi_code__c,Threshold_hour__c,Threshold_day__c,Contract_Framework__r.Status__c From Contract_Treatment__c ';
		if(searchKey != null && searchKey != '') {
			String key = '%' + searchKey + '%';
			if(preselectedrowslist != null && preselectedrowslist.size() > 0) {
				query += ' WHERE (Name LIKE :key OR Customer_Name__c LIKE :KEY OR Contract_Framework__r.Customer__r.Uzovi_code__c LIke :KEY OR Id In :preselectedrowslist )';
			} else {
				query += ' WHERE (Name LIKE :key OR Customer_Name__c LIKE :KEY OR Contract_Framework__r.Customer__r.Uzovi_code__c LIke :KEY)';
			}
			if(recordType == 'AccountTreatment_Therapy'){
				query += ' AND (Contract_Framework__r.Contract_Type__c = \'ZS7\' OR Contract_Framework__r.Contract_Type__c = \'ZS8\' OR Contract_Framework__r.Contract_Type__c = \'ZS0\') ';
				query += ' AND Treatment_Type__c =: therapy AND Business_Line__c =: business ';
			}
			else if(recordType == 'AccountTreatment_RentMaintenance') {
				query += ' AND Contract_Framework__r.Contract_Type__c = \'ZS4\'';
			}
			else if(recordType == 'AccountTreatment_Maintenance') {
				query += ' AND Contract_Framework__r.Contract_Type__c = \'ZS3\'';
			}
			else if(recordType == 'AccountTreatment_Sales') {
				query += ' AND Contract_Framework__r.Contract_Type__c = \'ZS6\'';
			}
			query += ' AND Contract_Framework__r.Status__c =: Active LIMIT 100 ';
		}else {
			if(recordType == 'AccountTreatment_Therapy'){
				query += ' WHERE (Contract_Framework__r.Contract_Type__c = \'ZS7\' OR Contract_Framework__r.Contract_Type__c = \'ZS8\' OR Contract_Framework__r.Contract_Type__c = \'ZS0\') ';
				query += ' AND Treatment_Type__c =: therapy AND Business_Line__c =: business ';
				query += ' AND Contract_Framework__r.Status__c =: Active LIMIT 100 ';
			}
			else if(recordType == 'AccountTreatment_RentMaintenance') {
				query += ' WHERE Contract_Framework__r.Contract_Type__c = \'ZS4\'';
				query += ' AND Contract_Framework__r.Status__c =: Active LIMIT 100 ';
			}
			else if(recordType == 'AccountTreatment_Maintenance') {
				query += ' WHERE Contract_Framework__r.Contract_Type__c = \'ZS3\'';
				query += ' AND Contract_Framework__r.Status__c =: Active LIMIT 100 ';
			}
			else if(recordType == 'AccountTreatment_Sales') {
				query += ' WHERE Contract_Framework__r.Contract_Type__c = \'ZS6\'';
				query += ' AND Contract_Framework__r.Status__c =: Active LIMIT 100 ';
			}
			else {
				query += 'WHERE Contract_Framework__r.Status__c =: Active LIMIT 100';
			}
		}   
 		system.debug(query);
 		return Database.query(query);
	}
	
	public static List<Contract_Treatment__c> getselectedCTThresholdvalues(String contractSelection){
        String query = 'select Id,Threshold_hour__c,Threshold_day__c,Threshold_AHI__c,Billable__c  From Contract_Treatment__c Where Id = :contractSelection';
		system.debug(query);
		return Database.query(query);
    }

	public static List<Contract_Treatment__c> getContractTreatmentsByFramworkId(String contractFrameworkId){
        String query = 'select Name, Contract_Treatment_ID__c, Corporate_Treatment__c, Billable__c, '+
			'  Contract_Framework__c, Corporate_Treatment__r.Name From Contract_Treatment__c'+
			 ' where Contract_Framework__c = :contractFrameworkId';
        system.debug(query) ;
        return Database.query( query );
	}
	
	public static List<Contract_Treatment__c> getContractTreatmentsByFramworkIdWithLimit(String contractFrameworkId){
        String query = 'select Name, Contract_Treatment_ID__c, Corporate_Treatment__c, Billable__c, '+
			' Contract_Framework__c, Corporate_Treatment__r.Name From Contract_Treatment__c'+
			 ' where Contract_Framework__c = :contractFrameworkId LIMIT 3';
        system.debug(query) ;
        return Database.query( query );
	}
	
	public static Contract_Treatment__c getContractTreatmentForEdit(Id contractTreatmentId) {
		Contract_Treatment__c contractTreatment = [SELECT Id, Contract_Framework__c, Corporate_Treatment__c, Contract_Framework__r.Status__c
												   FROM Contract_Treatment__c WHERE Id =: contractTreatmentId];
		
		return contractTreatment;
	}

	public static List<Contract_Treatment__c> getContractTreatmentsFromIds(List<String> queryFields, List<Id> relatedIds) {
		String query = 'SELECT ';
		for(Integer i = 0; i < queryFields.size(); i++) {
		query += queryFields[i] + ', ';
		}
		query = query.substring(0, query.length() - 2);
		query += ' FROM Contract_Treatment__c WHERE Id IN: relatedIds';
		System.debug('getContractTreatmentsFromIds QUERY: ' + query);
		
		return Database.query(query);
  	}
}