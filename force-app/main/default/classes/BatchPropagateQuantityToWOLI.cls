global class BatchPropagateQuantityToWOLI implements Database.Batchable<sObject>, Database.Stateful {

    global List<String> accountTreatmentJobProductsIds = new List<String>();
    global List<Account_Treatment_Job_Product__c> accountTreatmentJobProducts = new List<Account_Treatment_Job_Product__c>();
    global Map<String,Decimal> accountProductQuantityMap = new Map<String,Decimal>();

    global Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('accountTreatmentJobProductsIds: ' + accountTreatmentJobProductsIds);
        String woliStatusValue = 'New';

        //In progress, Completed, Cannot Complete, Canceled, Assigned

        List<String> woStatus = new List<String>();
        woStatus.add('In progress');
        woStatus.add('Completed');
        woStatus.add('Cannot Complete');
        woStatus.add('Canceled');
        woStatus.add('Assigned');
        for (Account_Treatment_Job_Product__c ct : accountTreatmentJobProducts){
            accountProductQuantityMap.put(ct.Id, ct.Quantity__c);
            accountTreatmentJobProductsIds.add(ct.Id);
        }
        String query = 'SELECT Id, Quantity, Account_Treatment_Job_Product__c FROM WorkOrderLineItem '
            + ' WHERE Account_Treatment_Job_Product__c IN :accountTreatmentJobProductsIds and Status = :woliStatusValue AND WorkOrder.Status NOT IN :woStatus';

		return Database.getQueryLocator(query);
	}

	public void execute(Database.BatchableContext bc,List<WorkOrderLineItem> scope) {
        List<WorkOrderLineItem> updateList = new List<WorkOrderLineItem>();
        for (WorkOrderLineItem woli : scope){
            if (woli.Quantity != accountProductQuantityMap.get(woli.Account_Treatment_Job_Product__c)){
                woli.Quantity = accountProductQuantityMap.get(woli.Account_Treatment_Job_Product__c);
                updateList.add(woli);
            } 
        }
        update updateList;
	}

	public void finish(Database.BatchableContext bc) {

	}
}