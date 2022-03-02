public with sharing class accountTreatmentJobSelectionController {

	//This method returns a List of CTJs given a Contract Treatment, search key and a list of preselected Jobs
	@AuraEnabled(cacheable = true)
	public static List<Contract_Treatment_Job__c> getJobssampath(String searchKey2, String selectedcontract,List<String> preselectedrowslistjobs ) {

		return ContractTreatmentJobDAO.getJobsbyselectedcontractwithpreselected(searchKey2, selectedcontract,preselectedrowslistjobs);
	}


	@AuraEnabled(cacheable = true)
	public static List<Contract_Treatment_Job__c> getJobs(String searchKey2, String selectedcontract, String accountTreatmentId) {
		
		return accountTreatmentJobSelectionService.getJobs(searchKey2, selectedcontract, accountTreatmentId);
	}

	//This method creates Account Treatment Jobs for the selected Jobs
	@AuraEnabled
	public static void createAccountTreatmentJobs(String accounttreatmentid, List<String> selectedjobs) {

		accountTreatmentJobSelectionService.createAccountTreatmentJobsselected(accounttreatmentid, selectedjobs);
	}

	@AuraEnabled(cacheable = true)
	public static List<Account_Treatment_Job__c> getseletedjobsineditmode(String atid ) {

		return AccountTreatmentJobDAO.getseletedjobsineditmodebyatid(atid);
	}

	

	@AuraEnabled(cacheable = true)
	public static List<Account_Treatment__c> getAccountTreatmentName(String atid ) {

		return AccountTreatmentDAO.getAccountTreatmentNamebyId(atid);
	}

}