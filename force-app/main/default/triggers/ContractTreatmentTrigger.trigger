trigger ContractTreatmentTrigger on Contract_Treatment__c (before insert, after insert, before update) {
    if (Trigger.isInsert && Trigger.isBefore){
        List<Id> ctframeworksids = new List<Id>();
         //copy the contractframework ids into a list
        for (Contract_Treatment__c CT : Trigger.new){
            ctframeworksids.add(CT.Contract_Framework__c);
        }
         //query the pricelistcodes of the frameworkids
        List<Contract_Framework__c> contractframeworks = ContractFrameworkDAO.getContractFrameworkpricelistcode(ctframeworksids);
        Map<String, String> cfidsandpricelistcodes = new Map<String, String>();
          //map the framework id and the related pricelistcode
        for(Integer i=0;i < contractframeworks.size() ;i++ ){
            cfidsandpricelistcodes.put(contractframeworks[i].Id ,contractframeworks[i].PriceListCode__c) ;
        }
           //assign the pricelistcode to the contract treatment .using the contractframework map
        for (Contract_Treatment__c CT : Trigger.new){
            CT.PriceListCode__c  = cfidsandpricelistcodes.get(CT.Contract_Framework__c);
        }       
    }

    if(Trigger.isInsert && Trigger.isAfter) {
        // Filling External_Id__c

        ContractTreatmentService.setExternalId(Trigger.new);
    }

    if(Trigger.isUpdate && Trigger.isBefore) {
        List<Contract_Treatment__c> toUpdateCTJAndCTJPsBillable = new List<Contract_Treatment__c>();

        for(Contract_Treatment__c ct : Trigger.new) {
            Contract_Treatment__c oldRecord = Trigger.oldMap.get(ct.Id);

            if(oldRecord.All_Items_Billable__c == false && ct.All_Items_Billable__c == true) {
                toUpdateCTJAndCTJPsBillable.add(ct);
            }
        }

        // Handling All_Items_Billable being set to true, updating Billable__c on all related CTJ and CTJPs

        if(FeatureManagementService.getFeatureStatus('CT_CTJ_CTJP_Billable_Handling') || Test.isRunningTest()) {
            if(!toUpdateCTJAndCTJPsBillable.isEmpty()) {
                ContractTreatmentService.updateCTJandCTJPsBillable(toUpdateCTJAndCTJPsBillable);
            }
        }
    }
}