global class BatchPropagateDeliveryChannel_WO  implements Database.Batchable<sObject>, Database.Stateful {

    global List<String> accountTreatmentsJobIds = new List<String>();
    global Map<String,String> accTreatmentDeliveryChannelMap = new Map<String,String>();
    global List<Account_Treatment_Job__c> accountTreatmentJobs = new List<Account_Treatment_Job__c>();

    global Database.QueryLocator start(Database.BatchableContext bc) {
        List <String> statusValues = new List <String>{ 'In progress', 'Assigned', 'Completed', 'Cannot Complete', 'Canceled'};
    
        for (Account_Treatment_Job__c at : accountTreatmentJobs){
            accTreatmentDeliveryChannelMap.put(at.Id, at.Delivery_Channel__c);
            accountTreatmentsJobIds.add(at.Id);
        }

		return Database.getQueryLocator(
            'SELECT Id, Delivery_Type__c, Account_Treatment_Job__c, Contract_Treatment_Job__c FROM WorkOrder WHERE Status NOT IN :statusValues ' +
            ' AND Account_Treatment_Job__c IN :accountTreatmentsJobIds'
		);
	}

	public void execute(Database.BatchableContext bc,List<WorkOrder> scope) {
        List <WorkOrder> workOrdersToUpdate = new List <WorkOrder> ();
        for (WorkOrder wo : scope){
            wo.Delivery_Type__c = accTreatmentDeliveryChannelMap.get(wo.Account_Treatment_Job__c);
            workOrdersToUpdate.add(wo);
        }
        update workOrdersToUpdate;
	}

	public void finish(Database.BatchableContext bc) {
	}
}