public with sharing class ContractTreatmentJobDAO {
	public static List<Contract_Treatment_Job__c> getJobsbyselectedcontractwithpreselected(String searchKey2, String selectedcontract,List<String> preselectedrowslistjobs) {
		String query = 'select Id,Name,Delivery_Channel__c,Frequency__c,Frequency_Unit_of_measure__c,Status__c From Contract_Treatment_Job__c';
		String Inactive = 'Inactive' ;
		if(selectedcontract != null && selectedcontract != '') {
			query += ' WHERE Contract_Treatment__c = :selectedContract ';
		}
		if(searchKey2 != null && searchKey2 != '') {
			String key = '%' + searchKey2 + '%';
			if(preselectedrowslistjobs != null && preselectedrowslistjobs.size() > 0) {

			query += ' AND (Name LIKE :key OR Id in :preselectedrowslistjobs) AND Status__c !=: Inactive';
		}else {
				query += ' AND Name LIKE :key  AND Status__c !=: Inactive ';
			}
		}
		system.debug(query);
		return Database.query(query);
	}

	public static List<Contract_Treatment_Job__c> getJobsbyselectedcontract(String searchKey2, String selectedcontract) {
		String Inactive = 'Inactive' ;
		String query = 'select Id,Name,Delivery_Channel__c,Frequency__c,Frequency_Unit_of_measure__c,Status__c From Contract_Treatment_Job__c';
		if(selectedcontract != null && selectedcontract != '') {
			query += ' WHERE Contract_Treatment__c = :selectedContract AND Status__c !=: Inactive ';
		}
		if(searchKey2 != null && searchKey2 != '') {
			String key = '%' + searchKey2 + '%';
			query += ' AND Name LIKE :key ';
			
		}
		system.debug(query);
		return Database.query(query);
	}

	public static List<Contract_Treatment_Job__c> getContractTreatmentJobByCTId(String contractTreatmentId) {
		String query = 'SELECT Id, Name, Job_Name__c, Contract_Framework__c, Contract_Treatment__c, Contract_Treatment__r.Name, '+
		'Corporate_Treatment_Job__c, Corporate_Treatment_Job__r.Name, Contract_Treatment_Job_Code__c, Frequency__c, Work_Type__c,'+
		' Frequency_Unit_of_measure__c, Delivery_Channel__c, Billable__c, Work_Order__c, Task__c, Case_Type__c, '+
		' Scheduling_Rule__c, Customer_Product_Code__c, Invoice_Splitting_group__c, Key__c FROM Contract_Treatment_Job__c';

        query += ' WHERE Contract_Treatment__C = :contractTreatmentId';
	
		system.debug(query);
		return Database.query(query);
	}

	public static Contract_Treatment_Job__c getContractTreatmentJobByCTJId(String contractTreatmentJobId) {
		String query = 'SELECT Id, Name, Contract_Framework__c, Contract_Treatment__c, Contract_Treatment__r.Name, '+
		'Corporate_Treatment_Job__c, Corporate_Treatment_Job__r.Name, Contract_Treatment_Job_Code__c, Frequency__c, Work_Type__c,'+
		' Frequency_Unit_of_measure__c, Delivery_Channel__c, Billable__c, Work_Order__c, Task__c, Case_Type__c, '+
		' Scheduling_Rule__c, Customer_Product_Code__c, Invoice_Splitting_group__c, Default_BOM__c, ' +
		'ComplianceFollowUp__c, ComplianceSource__c, Task_Type__c, Case_Subtype__c, Back_Office_Review__c, Frequency_Type__c, Scheduling_Time_Frame__c ' +
		'FROM Contract_Treatment_Job__c';

        query += ' WHERE Id = :contractTreatmentJobId';
	
		system.debug(query);
		return Database.query(query);
	}

	public static List<Contract_Treatment_Job__c> getContractTreatmentJobsForDOM(List<String> ContractTreatmentIds) {
		String Active = 'Active' ;
		String query = 'select Id,Name,Delivery_Channel__c,Frequency__c,Frequency_Unit_of_measure__c,Status__c,Billable__c,Default_BOM__c,Task__c,Work_Order__c,Scheduling_Rule__c,Case_Type__c,Case_Subtype__c,Task_Type__c,Work_Type__c,Contract_Treatment_Job__c ,Contract_Treatment__c,ComplianceSource__c,Customer_Product_Code__c, Back_Office_Review__c, Scheduling_Time_Frame__c, Frequency_Type__c FROM Contract_Treatment_Job__c';

		query += ' WHERE Contract_Treatment__c IN :ContractTreatmentIds AND Status__c =: Active AND Default_BOM__c = TRUE';
		system.debug(query);
		return Database.query(query);
	}

	public static List<Contract_Treatment_Job__c> getContractTreatmentJobByLISTCTId(List<String> contractTreatmentjobIds) {
		String query = 'SELECT Id,Name,Delivery_Channel__c,Frequency__c,Frequency_Unit_of_measure__c ,Task__c,Work_Order__c,Scheduling_Rule__c,Case_Type__c,Case_Subtype__c,Task_Type__c,Work_Type__c,Contract_Treatment_Job__c,ComplianceSource__c,Contract_Treatment__c,Customer_Product_Code__c, Billable__c, Back_Office_Review__c, Scheduling_Time_Frame__c, Frequency_Type__c FROM Contract_Treatment_Job__c WHERE Id IN :contractTreatmentjobIds';
	
		system.debug(query);
		return Database.query(query);
	}

	public static List<Contract_Treatment_Job__c> getContractTreatmentJobfield(List<Id> contractTreatmentjobIds) {
		String query = 'SELECT Id,Contract_Treatment_Job__c from Contract_Treatment_Job__c WHERE Id IN :contractTreatmentjobIds';
	
		system.debug(query);
		return Database.query(query);
	}

	public static List<Contract_Treatment_Job__c> getContractTreatmentJobfieldbyids(List<String> queryFields,  List<Id> ctjids) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
        	query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Contract_Treatment_Job__c WHERE Contract_Treatment_Job__c IN: ctjids ';
        System.debug('getContractTreatmentJobfieldbyids QUERY: ' + query);
        
        return Database.query(query);
    }

	public static List<Contract_Treatment_Job__c> getCTJsFromCTIds(List<String> queryFields, List<Id> CTIds) {
		String query = 'SELECT ';
		for(Integer i = 0; i < queryFields.size(); i++) {
			query += queryFields[i] + ', ';
		}
		query = query.substring(0, query.length() - 2);
		query += ' FROM Contract_Treatment_Job__c WHERE Contract_Treatment__c IN: CTIds';
		System.debug('getCTJsFromCTIds QUERY: ' + query);
		
		return Database.query(query);
  	}

	public static List<Contract_Treatment_Job__c> getCTJsbyIds(List<String> queryFields, Set<Id> CTIds) {
		String query = 'SELECT ';
		for(Integer i = 0; i < queryFields.size(); i++) {
			query += queryFields[i] + ', ';
		}
		query = query.substring(0, query.length() - 2);
		query += ' FROM Contract_Treatment_Job__c WHERE Id IN: CTIds';
		System.debug('getCTJsFromCTIds QUERY: ' + query);
		
		return Database.query(query);
	  }
	  
	  public static List<Contract_Treatment_Job__c> getCTJsFromIds(List<String> queryFields, List<String> relatedIds) {
		String query = 'SELECT ';
		for(Integer i = 0; i < queryFields.size(); i++) {
			query += queryFields[i] + ', ';
		}
		query = query.substring(0, query.length() - 2);
		query += ' FROM Contract_Treatment_Job__c WHERE Id IN: relatedIds';
		System.debug('getCTJsFromIds QUERY: ' + query);
		
		return Database.query(query);
  	}
}