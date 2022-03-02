global class BatchPropagateCTJPQuantityToATJP implements Database.Batchable<sObject>, Database.Stateful {
    
    global List<String> contractTreatmentJobProductIds = new List<String>();
    global List<Contract_Treatment_Job_Product__c> contractTreatmentJobProducts = new List<Contract_Treatment_Job_Product__c>();
    global Map<String,Decimal> contractProductQuantityMap = new Map<String,Decimal>();
    global List<Account_Treatment_Job_Product__c> updatedAccountTreatmentProduct = new List<Account_Treatment_Job_Product__c>();

    global Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('contractTreatmentJobProductIds: ' + contractTreatmentJobProductIds);
        for (Contract_Treatment_Job_Product__c ct : contractTreatmentJobProducts){
            contractProductQuantityMap.put(ct.Id, ct.Quantity__c);
        }

        String accTreatStatusValue = 'R';
        String treatJobStatusValue = 'New';
        String statusValue = 'Inactive';

        String query = 'SELECT Id, Quantity__c, Contract_Treatment_Job_Product__c FROM Account_Treatment_Job_Product__c '
            + ' WHERE Contract_Treatment_Job_Product__c IN :contractTreatmentJobProductIds AND Is_Quantity_Agreed_With_Patient__c = FALSE AND ' +
            ' Status__C != :statusValue AND Patient_Treatment_Job__r.Status__c != :treatJobStatusValue AND Patient_Treatment_Job__r.Patient_Treatment__r.Status__c != :accTreatStatusValue';

		return Database.getQueryLocator(query);
	}

	public void execute(Database.BatchableContext bc,List<Account_Treatment_Job_Product__c> scope) {
        List<Account_Treatment_Job_Product__c> updateList = new List<Account_Treatment_Job_Product__c>();
        for (Account_Treatment_Job_Product__c atj : scope){
            Boolean toBeUpdated = false;
            if (atj.Quantity__c != contractProductQuantityMap.get(atj.Contract_Treatment_Job_Product__c)){
                atj.Quantity__c = contractProductQuantityMap.get(atj.Contract_Treatment_Job_Product__c);
                toBeUpdated = true;
            } 
            if (toBeUpdated == true){
                updateList.add(atj);
                updatedAccountTreatmentProduct.add(atj);
            }
        }
        update updateList;
	}

	public void finish(Database.BatchableContext bc) {
        if (!updatedAccountTreatmentProduct.isEmpty()){
            BatchPropagateQuantityToWOLI batchUpdateWOLI = new BatchPropagateQuantityToWOLI();
            batchUpdateWOLI.accountTreatmentJobProducts = updatedAccountTreatmentProduct;
            Database.executeBatch(batchUpdateWOLI, 500);
        }
	}
}