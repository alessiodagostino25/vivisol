global class BatchPropagateSubstitute_CTJP implements Database.Batchable<sObject>, Database.Stateful {

    global String oldContractTreatmentJobProductId;
    global Contract_Treatment_Job_Product__c oldCTJP;
    global Contract_Treatment_Job_Product__c newCTJP;
    global String newContractTreatmentJobProductId;

    global Database.QueryLocator start(Database.BatchableContext bc) {
        String accTreatStatusValue = 'R';
        String treatJobStatusValue = 'Inactive';
        String statusValue = 'Inactive';

        newCTJP = [SELECT Id, Billable__c, Customer_Treatment_Alias__c, Customer_Request_Code__c, Frequency__c, Frequency_Unit_of_measure__c, Invoice_Splitting_group__c, 
        Max_Quantity__c, Min_Quantity__c , Product__c, Purchase_order_date__c, Purchase_order_number__c, Quantity__c,
        Quantity_Unit_of_measure__c, Plant__c, Storage_Location__c FROM Contract_Treatment_Job_Product__c WHERE id = :newContractTreatmentJobProductId];

        oldCTJP = [SELECT Id, Billable__c, Customer_Treatment_Alias__c, Customer_Request_Code__c, Frequency__c, Frequency_Unit_of_measure__c, Invoice_Splitting_group__c, 
        Max_Quantity__c, Min_Quantity__c , Product__c, Purchase_order_date__c, Purchase_order_number__c, Quantity__c,
        Quantity_Unit_of_measure__c, Plant__c, Storage_Location__c FROM Contract_Treatment_Job_Product__c WHERE id = :oldContractTreatmentJobProductId];

        String query = 'SELECT Id, Status__c, Patient_Treatment_Job__c, Asset__c FROM Account_Treatment_Job_Product__c '
            + ' WHERE Contract_Treatment_Job_Product__c = :oldContractTreatmentJobProductId and Status__C != :statusValue AND ' +  
            ' Patient_Treatment_Job__r.Status__c != :treatJobStatusValue AND Patient_Treatment_Job__r.Patient_Treatment__r.Status__c != :accTreatStatusValue';

		return Database.getQueryLocator(query);
	}

	public void execute(Database.BatchableContext bc,List<Account_Treatment_Job_Product__c> scope) {
        List<Account_Treatment_Job_Product__c> oldList = new List<Account_Treatment_Job_Product__c>();
        List<String> oldListIds = new List<String>();
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
                oldListIds.add(oldATJP.Id);
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
                tmpATJP.Plant__c = newCTJP.Plant__c;
                tmpATJP.Storage_Location__c = newCTJP.Storage_Location__c;
                newList.add(tmpATJP);
            }
        }
        insert newList;
        update oldList;

        List<WorkOrderLineItem> woliToRemove = [SELECT Id, Status FROM WorkOrderLineItem WHERE Account_Treatment_Job_Product__c IN: oldList];
        for (WorkOrderLineItem woli : woliToRemove){
            woli.Status = 'Canceled';
        }
        update woliToRemove;

	}

	public void finish(Database.BatchableContext bc) {

	}
}