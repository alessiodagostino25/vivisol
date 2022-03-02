global class BatchPropagateDeliveryChannel implements Database.Batchable<sObject>, Database.Stateful {

    global List<String> contractTreatmentJobIds = new List<String>();
    global List<Contract_Treatment_Job__c> contractTreatmentJobs = new List<Contract_Treatment_Job__c>();
    global Map<String,String> contractDeliveryChannelMap = new Map<String,String>();
    global List<Account_Treatment_Job__c> updatedAccountTreatment = new List<Account_Treatment_Job__c>();

    global Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('contractTreatmentJobIds: ' + contractTreatmentJobIds);
        String statusValue = 'R';
        for (Contract_Treatment_Job__c ct : contractTreatmentJobs){
            contractDeliveryChannelMap.put(ct.Id, ct.Delivery_Channel__c);
        }
		return Database.getQueryLocator(
            'SELECT Id, Delivery_Channel__c, Last_Propagated_Delivery_Channel__c, Contract_Treatment_Job__c FROM Account_Treatment_Job__c WHERE Is_Delivery_Channel_different_from_Contr__c = false AND Patient_Treatment__r.Status__c != :statusValue' +
            ' AND Contract_Treatment_Job__c IN :contractTreatmentJobIds'
		);
	}

	public void execute(Database.BatchableContext bc,List<Account_Treatment_Job__c> scope) {
        List<Account_Treatment_Job__c> updateList = new List<Account_Treatment_Job__c>();
        for (Account_Treatment_Job__c atj : scope){
            if (atj.Delivery_Channel__c != contractDeliveryChannelMap.get(atj.Contract_Treatment_Job__c)){
                atj.Delivery_Channel__c = contractDeliveryChannelMap.get(atj.Contract_Treatment_Job__c);
                atj.Last_Propagated_Delivery_Channel__c = contractDeliveryChannelMap.get(atj.Contract_Treatment_Job__c);
                updateList.add(atj);
                updatedAccountTreatment.add(atj);
            }  
        }
        update updateList;
	}

	public void finish(Database.BatchableContext bc) {
        if (!updatedAccountTreatment.isEmpty()){
            BatchPropagateDeliveryChannel_WO batchDeliveryChannel = new BatchPropagateDeliveryChannel_WO();
            batchDeliveryChannel.accountTreatmentJobs = updatedAccountTreatment;
            Database.executeBatch(batchDeliveryChannel, 500);
        }
        System.debug('Account Treatment List: ' + updatedAccountTreatment);
	}

}