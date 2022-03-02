public with sharing class accountTreatmentJobSelectionService{
	public static void createAccountTreatmentJobsselected(String accounttreatmentid, List<String> selectedjobs){
		List<String> nonMatchedjobs = new List<String>();
		List<String> jobsIds = getAlljobsbyAccountId(accounttreatmentid);
		if (selectedjobs.size() > 0 && jobsIds.size() > 0){
			for (Integer i = 0; i < selectedjobs.size(); i++){
				//If the selected job is not already present in the list of jobs related to the accounttreatment
				if (!jobsIds.contains(selectedjobs[i])){
					//Add it to this list
					nonMatchedjobs.add(selectedjobs[i]);
				}
			}
		}
		System.debug('before' + nonMatchedjobs);
		//If the account has no Jobs associated, then add every selected job to the list
		if (jobsIds.size() < 1){
			for (Integer i = 0; i < selectedjobs.size(); i++){
				nonMatchedjobs.add(selectedjobs[i]);
			}
		}
		system.debug('after' + nonMatchedjobs);
		List<Contract_Treatment_Job__c> jobQuery = ContractTreatmentJobDAO.getContractTreatmentJobByLISTCTId(nonMatchedjobs);
		List<Contract_Treatment_Job__c> contractTreatmentJobsParentList = new List<Contract_Treatment_Job__c>();
        List<Contract_Treatment_Job__c> ContracttreatmentjobsChildList = new List<Contract_Treatment_Job__c>();
		List<Account_Treatment_Job__c> atjupdateParentlist = new List<Account_Treatment_Job__c>();
		List<Account_Treatment_Job__c> atjupdateChildlist = new List<Account_Treatment_Job__c>();
		for (Integer i = 0; i < jobQuery.size(); i++){
			//sorting the parent and child jobs in jobQuery
			if (String.isnotblank(jobQuery[i].Contract_Treatment_Job__c)){
				ContracttreatmentjobsChildList.add(jobQuery[i]);
			} else{
				contractTreatmentJobsParentList.add(jobQuery[i]);
			}
		}
		//For each job in jobQuery, create a new Account Treatment Job

		for (Integer i = 0; i < contractTreatmentJobsParentList.size(); i++){
			Account_Treatment_Job__c atj = new Account_Treatment_Job__c();
			atj.Contract_Treatment_Job__c = contractTreatmentJobsParentList[i].Id;
			atj.Delivery_Channel__c = contractTreatmentJobsParentList[i].Delivery_Channel__c;
			atj.Frequency__c = contractTreatmentJobsParentList[i].Frequency__c;
			atj.Frequency_Unit_of_measure__c = contractTreatmentJobsParentList[i].Frequency_Unit_of_measure__c;
			atj.Patient_Treatment__c = accounttreatmentid;
			atj.Name = contractTreatmentJobsParentList[i].Name;
			atj.Task__c = contractTreatmentJobsParentList[i].Task__c;
			atj.Work_Order__c = contractTreatmentJobsParentList[i].Work_Order__c;
			atj.Scheduling_Rule__c = contractTreatmentJobsParentList[i].Scheduling_Rule__c;
			atj.Case_Type__c = contractTreatmentJobsParentList[i].Case_Type__c;
			atj.Case_Subtype__c = contractTreatmentJobsParentList[i].Case_Subtype__c;
			atj.Task_Type__c = contractTreatmentJobsParentList[i].Task_Type__c;
			atj.Work_Type__c = contractTreatmentJobsParentList[i].Work_Type__c;
			atj.ComplianceSource__c = contractTreatmentJobsParentList[i].ComplianceSource__c;
			atj.Customer_Product_Code__c = contractTreatmentJobsParentList[i].Customer_Product_Code__c;
			atj.Billable__c = contractTreatmentJobsParentList[i].Billable__c;
			atj.Back_Office_Review__c = contractTreatmentJobsParentList[i].Back_Office_Review__c;
			atj.Scheduling_Time_Frame__c = contractTreatmentJobsParentList[i].Scheduling_Time_Frame__c;
			atj.Frequency_Type__c = contractTreatmentJobsParentList[i].Frequency_Type__c;
			atjupdateParentlist.add(atj);
		}
		System.debug('acoounttreatment id' + accounttreatmentid);
		System.debug('selectedjobs' + selectedjobs);
		insert atjupdateParentlist;
		System.debug(atjupdateParentlist);
		List<Account_Treatment_Job__c> accounttreatmentfield = AccountTreatmentJobDAO.getaccounttreatmentjobbyatid(accounttreatmentid);
		Map<string, string> accounttreatmentfieldmap = new map<string, string>();
		for (Integer i = 0; i < accounttreatmentfield.size(); i++){
			accounttreatmentfieldmap.put(accounttreatmentfield[i].Contract_Treatment_Job__c, accounttreatmentfield[i].Id);
		}
		for (Integer i = 0; i < ContracttreatmentjobsChildList.size(); i++){
			Account_Treatment_Job__c atj = new Account_Treatment_Job__c();
			if (String.isnotblank(ContracttreatmentjobsChildList[i].Contract_Treatment_Job__c)){
				atj.Account_Treatment_Job__c = accounttreatmentfieldmap.get(ContracttreatmentjobsChildList[i].Contract_Treatment_Job__c);
			}
			atj.Contract_Treatment_Job__c = ContracttreatmentjobsChildList[i].Id;
			atj.Delivery_Channel__c = ContracttreatmentjobsChildList[i].Delivery_Channel__c;
			atj.Frequency__c = ContracttreatmentjobsChildList[i].Frequency__c;
			atj.Frequency_Unit_of_measure__c = ContracttreatmentjobsChildList[i].Frequency_Unit_of_measure__c;
			atj.Patient_Treatment__c = accounttreatmentid;
			atj.Name = ContracttreatmentjobsChildList[i].Name;
			atj.Task__c = ContracttreatmentjobsChildList[i].Task__c;
			atj.Work_Order__c = ContracttreatmentjobsChildList[i].Work_Order__c;
			atj.Scheduling_Rule__c = ContracttreatmentjobsChildList[i].Scheduling_Rule__c;
			atj.Case_Type__c = ContracttreatmentjobsChildList[i].Case_Type__c;
			atj.Case_Subtype__c = ContracttreatmentjobsChildList[i].Case_Subtype__c;
			atj.Task_Type__c = ContracttreatmentjobsChildList[i].Task_Type__c;
			atj.Work_Type__c = ContracttreatmentjobsChildList[i].Work_Type__c;
			atj.ComplianceSource__c = ContracttreatmentjobsChildList[i].ComplianceSource__c;
			atj.Customer_Product_Code__c = ContracttreatmentjobsChildList[i].Customer_Product_Code__c;
			atj.Billable__c = ContracttreatmentjobsChildList[i].Billable__c;
			atj.Back_Office_Review__c = ContracttreatmentjobsChildList[i].Back_Office_Review__c;
			atj.Scheduling_Time_Frame__c = ContracttreatmentjobsChildList[i].Scheduling_Time_Frame__c;
			atj.Frequency_Type__c = ContracttreatmentjobsChildList[i].Frequency_Type__c;
			atjupdateChildlist.add(atj);
		}
		insert atjupdateChildlist;
		System.debug(atjupdateChildlist);
	}

	public static List<String> getAlljobsbyAccountId(String accounttreatmentid){
		List<String> jobsids2 = new List<String>();
		List<Account_Treatment_Job__c> jobsids1 = [SELECT Contract_Treatment_Job__c
		                                           FROM Account_Treatment_Job__c
		                                           WHERE Patient_Treatment__c = :accounttreatmentid];
		for (Integer i = 0; i < jobsids1.size(); i++){
			jobsids2.add(jobsids1[i].Contract_Treatment_Job__c);
		}
		return jobsids2;
	}

	@AuraEnabled(cacheable = true)
	public static List<Contract_Treatment_Job__c> getJobs(String searchKey2, String selectedcontract, String accountTreatmentId){
		System.debug('accountTreatmentId: ' + accountTreatmentId);
		//Getting ATJs from Account Treatment's Id
		List<Account_Treatment_Job__c> currentATjobs = AccountTreatmentJobDAO.getAccountTreatmentJobByACId(accountTreatmentId);
		System.debug('currentATjobs: ' + currentATjobs);
		List<String> contractTreatmentjobIds = new List<String>();
		List<Contract_Treatment_Job__c> queriedContractTreatmentjobs = new List<Contract_Treatment_Job__c>();
		List<Contract_Treatment_Job__c> cleanedContractTreatmentJobs = new List<Contract_Treatment_Job__c>();
		for (Account_Treatment_Job__c aTJ : currentATjobs){
			contractTreatmentjobIds.add(aTJ.Contract_Treatment_Job__c);
		}
		System.debug('contractTreatmentjobIds: ' + contractTreatmentjobIds);
		queriedContractTreatmentjobs = ContractTreatmentJobDAO.getJobsbyselectedcontract(searchKey2, selectedcontract);
		System.debug('queriedContractTreatmentjobs: ' + queriedContractTreatmentjobs);
		if (contractTreatmentjobIds.isEmpty()){
			return queriedContractTreatmentjobs;
		}
		for (Contract_Treatment_Job__c cTJ : queriedContractTreatmentjobs){
			Boolean tmp = true;
			for (Integer i = 0; i < contractTreatmentjobIds.size(); i++){
				if (cTJ.Id == contractTreatmentjobIds[i]){
					tmp = false;
				}
			}
			if (tmp == true){
				cleanedContractTreatmentJobs.add(cTJ);
			}
		}
		return cleanedContractTreatmentJobs;
	}
}