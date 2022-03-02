trigger ContractTreatmentJobProductTrigger on Contract_Treatment_Job_Product__c (before insert, after insert, before update, after update) {

    if (Trigger.isInsert && trigger.isBefore){
        List<String> productIds = new List<String>();
        for (Integer i = 0; i<Trigger.new.size(); i++){
            productIds.add(Trigger.new[i].Product__c);
        }

        Map<Id, Product2> productMap = new Map<Id, Product2>([SELECT id, Name, Product_Code__c FROM Product2 WHERE id IN :productIds]);

        for (Contract_Treatment_Job_Product__c c : Trigger.new ) {
            c.Last_Propagated_Quantity__c = c.Quantity__c;
            if (c.Product__c != null){
                c.Product_Name_Text__c = productMap.get(c.Product__c).Name;     
                c.Product_Code_Text__c = productMap.get(c.Product__c).Product_Code__c;    
            }
        }

        // Checking for CTJ.CT.AllItemsBillable to eventually set Billable

        if(FeatureManagementService.getFeatureStatus('CT_CTJ_CTJP_Billable_Handling') || Test.isRunningTest()) {
            ContractTreatmentJobProductService.checkForBillable(Trigger.new);
        }
    }

    if(Trigger.isInsert && Trigger.isAfter) {
        // Filling Contract_Treatment_Job_Product_Id__c

        ContractTreatmentJobProductService.setCTJPIdField(Trigger.new);
    }
    
    //Copy the Quantity__c to Last_Propagated_Quantity__c with the framework in DRAFT
    if (Trigger.isUpdate && Trigger.isBefore){
        List<String> contractTreatmentJobIdList = new List<String>();
        List<Contract_Treatment_Job__c> contractTreatmentJobList = new List<Contract_Treatment_Job__c>();
        for (Contract_Treatment_Job_Product__c c : Trigger.new ){
            contractTreatmentJobIdList.add(c.Contract_Treatment_Job__c);
        }
        contractTreatmentJobList = [SELECT id, Contract_Framework__r.Status__c FROM Contract_Treatment_Job__c WHERE Id IN :contractTreatmentJobIdList];
        Map<String,String> statusMap = new Map<String,String>();
        for (Contract_Treatment_Job__c ctj : contractTreatmentJobList ){
            statusMap.put(ctj.Id, ctj.Contract_Framework__r.Status__c);
        }
        for (Contract_Treatment_Job_Product__c ctjp : Trigger.new ){
            if (statusMap.get(ctjp.Contract_Treatment_Job__c) == 'Draft'){
                ctjp.Last_Propagated_Quantity__c = ctjp.Quantity__c;
            }
        }

        // Setting IsPortalSync

		SObjectServiceClass.setIsPortalSync(Trigger.new, Trigger.oldMap, 'Contract_Treatment_Job_Product__c', true, false);
    }

    if(Trigger.isUpdate && Trigger.isAfter) {
        // Setting IsPortalSync

		//SObjectServiceClass.setIsPortalSync(Trigger.new, Trigger.oldMap, 'Contract_Treatment_Job_Product__c', true);
    }
}