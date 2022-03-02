public with sharing class RelatedAccountTreatmentJobBatch implements Database.Batchable<sObject>, Schedulable{
	public Database.QueryLocator start(Database.BatchableContext bc){
		//query to get the account treatment jobs
		Datetime d = datetime.now().addhours(-4);
		String query = 'select Id, Contract_Treatment_Job__c, Account_Treatment_Job__c, Patient_Treatment__c, LastModifiedDate From Account_Treatment_Job__c Where SystemModstamp >= 4';
		System.debug(query);
		return Database.getQueryLocator(query);
	}
	public void execute(Database.BatchableContext bc, List<Account_Treatment_Job__c> accounttreatmentjobs){
		List<Id> accounttreatmentids = new List<Id>();
		List<Id> contreatmentjobids = new List<Id>();
		List<Id> contreatmentjobParentids = new List<Id>();
        List<Account_Treatment_Job__c> finalupdateofatj = new List<Account_Treatment_Job__c>();
        // get the list of accounttreatments and contracttreatmentjobs ids related to the account treatment jobs. 
        // the conditon is the account treatment job should have the field 'Account_Treatment_Job__c'  = null
		for (Account_Treatment_Job__c atj : accounttreatmentjobs){
			if (atj.Account_Treatment_Job__c == null){
				accounttreatmentids.add(atj.Patient_Treatment__c);
				contreatmentjobids.add(atj.Contract_Treatment_Job__c);
			}
        }
        //query the Contract_Treatment_Job__c field from the list of the contracttreatmentjobids
        //map the field Contract_Treatment_Job__c(parent ctj id) and the contracttreatmentjobid (child ctj id)
		List<Contract_Treatment_Job__c> ctjobquery = new List<Contract_Treatment_Job__c>();
		ctjobquery = ContractTreatmentJobDAO.getContractTreatmentJobfield(contreatmentjobids);
		Map<String, String> ctjidandfield = new Map<String, String>();
		for (Contract_Treatment_Job__c ctj : ctjobquery){
			ctjidandfield.put(ctj.Id, ctj.Contract_Treatment_Job__c);
			contreatmentjobParentids.add(ctj.Contract_Treatment_Job__c);
        }
        //query the aAccountTreatmentJob using the condition where Patient_Treatment__c IN accounttreatmentids and Contract_Treatment_Job__c  IN contreatmentjobParentids
		List<Account_Treatment_Job__c> actjobquery = new List<Account_Treatment_Job__c>();
		Map<String, List<Id>> atidandatjid = new Map<String, List<Id>>();
		Map<String, String> atjidandctjid = new Map<String, String>();
		actjobquery = AccountTreatmentJobDAO.getAccounttreatmentjobfield(accounttreatmentids, contreatmentjobParentids);
		for (Account_Treatment_Job__c atj : actjobquery){
            // map the aAccountTreatmentJob(parent atj id) and contracttreatmentjob ( child ctj id)
			atjidandctjid.put(atj.Id, atj.Contract_Treatment_Job__c);

            //map the account treatment and the related account treatment job ids (parent atj ids ) 
			List<Id> temp = atidandatjid.get(atj.Patient_Treatment__c);
			if (temp == null){
				atidandatjid.put(atj.Patient_Treatment__c, new List<Id>{atj.Id});
			} else{
				temp.add(atj.Id);
			}
		}
		for (Account_Treatment_Job__c atj : accounttreatmentjobs){
            //getting the atj (parent ids ) related to the related account treatment
			List<Id> atjparentids = atidandatjid.get(atj.Patient_Treatment__c);
			if (atjparentids != null){
				for (Integer i = 0; i < atjparentids.size(); i++){
					//Checking the condition if parent id and child id are equal.
					if(atj.Id != atjparentids[i]){
						//from the comparing the contract treatment job related to the atj(child id)  and  contract treatment job related to the atj (parent id)
					if (ctjidandfield.get(atj.Contract_Treatment_Job__c) == atjidandctjid.get(atjparentids[i])){
						atj.Account_Treatment_Job__c = atjparentids[i];
						finalupdateofatj.add(atj);
					}
				}
			}
			}
		}
		update finalupdateofatj;
	} 

	public void finish(Database.BatchableContext bc){
		system.debug('DONE'); 
	
	}

	public static void Execute(SchedulableContext ctx){
		Database.executeBatch(new RelatedAccountTreatmentJobBatch()); //TODO
	}


}