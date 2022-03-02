global class BatchPropagateSubstitute_WOLI implements Database.Batchable<sObject>, Database.Stateful  {


    global List<String> oldAccTreatJobProductsIds = new List<String>();
    global List<Account_Treatment_Job_Product__c> oldAccountTreatmentJobProducts = new List<Account_Treatment_Job_Product__c>();
    global List<Account_Treatment_Job_Product__c> newAccountTreatmentJobProducts = new List<Account_Treatment_Job_Product__c>();


    global Database.QueryLocator start(Database.BatchableContext bc) {
        String statusValue = 'New';

        //In progress, Completed, Cannot Complete, Canceled, Assigned

        List<String> woStatus = new List<String>();
        woStatus.add('In progress');
        woStatus.add('Completed');
        woStatus.add('Cannot Complete');
        woStatus.add('Canceled');
        woStatus.add('Assigned');

        for (Account_Treatment_Job_Product__c ct : oldAccountTreatmentJobProducts){
            oldAccTreatJobProductsIds.add(ct.Id);
        }
        String query = 'SELECT Id, Account_Treatment_Job_Product__c, Quantity FROM WorkOrderLineItem '
            + ' WHERE Account_Treatment_Job_Product__c IN :oldAccTreatJobProductsIds and Status = :statusValue AND WorkOrder.Status NOT IN :woStatus';

		return Database.getQueryLocator(query);
	}

	public void execute(Database.BatchableContext bc,List<Account_Treatment_Job_Product__c> scope) {
        /*
        List<Account_Treatment_Job_Product__c> oldList = new List<Account_Treatment_Job_Product__c>();
        List<Account_Treatment_Job_Product__c> newList = new List<Account_Treatment_Job_Product__c>();

        List<String> relatedAccountTreatmentJobIds = new List<String>();
        for (Integer i = 0; i<scope.size(); i++){
            relatedAccountTreatmentJobIds.add(scope[i].Patient_Treatment_Job__c);
        }

        List<Account_Treatment_Job_Product__c> alreadyExistingATJP = new List<Account_Treatment_Job_Product__c>();

        alreadyExistingATJP = [SELECT id, Patient_Treatment_Job__c, Contract_Treatment_Job_Product__c from Account_Treatment_Job_Product__c WHERE Patient_Treatment_Job__c IN:relatedAccountTreatmentJobIds 
            AND Contract_Treatment_Job_Product__c = :newContractTreatmentJobProductId];
        
        List<String> existingContractAndAccountTJP = new List<String>();

        Map <Id,List<String>> strMap = new Map <Id,List<String>>();
        for (Integer i = 0; i< alreadyExistingATJP.size(); i++){
            strMap.put(alreadyExistingATJP[i].Patient_Treatment_Job__c, new List<String>());
        }
        for (Integer i = 0; i< alreadyExistingATJP.size(); i++){
            List<String> tmpList = new List<String>();
            tmpList = strMap.get(alreadyExistingATJP[i].Patient_Treatment_Job__c);
            tmpList.add(alreadyExistingATJP[i].Contract_Treatment_Job_Product__c);
            strMap.put(alreadyExistingATJP[i].Patient_Treatment_Job__c,tmpList);
        }

        System.Debug(strMap);

        for (Account_Treatment_Job_Product__c oldATJP : scope){
            List<String> tmpList = new List<String>();
            tmpList = strMap.get(oldATJP.Patient_Treatment_Job__c);
            if(tmpList == null || !tmpList.contains(newContractTreatmentJobProductId)){
                System.debug('inserisco il prodotto nuovo!!!');
                oldATJP.Status__c = 'Inactive';
                oldList.add(oldATJP);
                Account_Treatment_Job_Product__c tmpATJP = new Account_Treatment_Job_Product__c();
                tmpATJP.Asset__c = oldATJP.Asset__c;
    
                tmpATJP.Billable__c = newCTJP.Billable__c;
                tmpATJP.Contract_Treatment_Job_Product__c = newContractTreatmentJobProductId;
                tmpATJP.Customer_Request_Code__c = newCTJP.Customer_Request_Code__c;
                tmpATJP.Customer_Treatment_Alias__c = newCTJP.Customer_Treatment_Alias__c;
                tmpATJP.Frequency__c = newCTJP.Frequency__c;
                tmpATJP.Frequency_Unit_of_measure__c = newCTJP.Frequency_Unit_of_measure__c;
                tmpATJP.Invoice_Splitting_group__c = newCTJP.Invoice_Splitting_group__c;
                tmpATJP.Is_Quantity_Agreed_With_Patient__c = false;
                tmpATJP.Max_Quantity__c = newCTJP.Max_Quantity__c;
                tmpATJP.Min_Quantity__c = newCTJP.Min_Quantity__c;
                tmpATJP.Patient_Treatment_Job__c = oldATJP.Patient_Treatment_Job__c;
                tmpATJP.Product__c = newCTJP.Product__c;
                tmpATJP.Purchase_order_date__c = newCTJP.Purchase_order_date__c;
                tmpATJP.Purchase_order_number__c = newCTJP.Purchase_order_number__c;
                tmpATJP.Quantity__c = newCTJP.Quantity__c;
                tmpATJP.Quantity_Unit_of_measure__c = newCTJP.Quantity_Unit_of_measure__c;
                tmpATJP.Status__c = 'Active';
                newList.add(tmpATJP);
            }
        }
        insert newList;
        update oldList;
        */
	}

	public void finish(Database.BatchableContext bc) {

	}
}