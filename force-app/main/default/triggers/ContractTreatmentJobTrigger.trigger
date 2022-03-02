trigger ContractTreatmentJobTrigger on Contract_Treatment_Job__c (before insert, after insert, before update) {
    
	System.debug('Entry in Contract Treatment Job Trigger');

    if(Trigger.isInsert && Trigger.isBefore){
        List <String> contractTreatmentIds = new List <String>();
        List <String> corporateTreatmentJobIds = new List <String>();
        List<Id> ctframeworksids = new List<Id>();
        List<Contract_Treatment_Job__c> toSetSchedulingTimeFrame = new List<Contract_Treatment_Job__c>();

        // Checking for CT.AllItemsBillable to eventually set Billable

        if(FeatureManagementService.getFeatureStatus('CT_CTJ_CTJP_Billable_Handling') || Test.isRunningTest()) {
            ContractTreatmentJobTriggerService.checkForBillable(Trigger.new);
        }
    
        for(Contract_Treatment_Job__c cTJ : Trigger.New) {
            System.debug('Entry in for loop on Contract Treatment Job');
            contractTreatmentIds.add(cTj.Contract_Treatment__c);
            corporateTreatmentJobIds.add(cTJ.Corporate_Treatment_Job__c);
            ctframeworksids.add(CTJ.Contract_Framework__c);
        }
            //query the pricelistcodes of the frameworkids
        List<Contract_Framework__c> contractframeworks = ContractFrameworkDAO.getContractFrameworkpricelistcode(ctframeworksids);
           //map the framework id and the related pricelistcode
        Map<String, String> cfidsandpricelistcodes = new Map<String, String>();
        for(Integer i=0;i < contractframeworks.size() ;i++ ){
            cfidsandpricelistcodes.put(contractframeworks[i].Id ,contractframeworks[i].PriceListCode__c) ;
        }
    
        List <Contract_Treatment__c> cTList = [SELECT Id, Name FROM Contract_Treatment__c WHERE Id IN :contractTreatmentIds];
        System.debug('Populate Contract Treatment List: ' + cTList);
            
        List <Corporate_Treatment_Job__c> corTJList = [SELECT Id, Name FROM Corporate_Treatment_Job__c WHERE Id IN :corporateTreatmentJobIds];
        System.debug('Populate Corporate Treatment Job List: ' + corTJList);

        for(Contract_Treatment_Job__c cTJ : Trigger.new) {
            //assign the pricelistcode to the contract treatment job .using the contractframework map
            cTJ.Last_Propagated_Delivery_Channel__c = cTJ.Delivery_Channel__c;
            cTJ.Last_Propagated_Frequency__c = cTJ.Frequency__c;
            cTJ.Last_Propagated_Frequency_UOM__c = cTJ.Frequency_Unit_of_measure__c;
            cTJ.Last_Propagated_Frequency_Type__c = cTJ.Frequency_Type__c;

            cTJ.PriceListCode__c  = cfidsandpricelistcodes.get(cTJ.Contract_Framework__c);

            if(cTJ.Name == null) {
                System.debug('Entry in for loop on Contract Treatment Job');
                for(Contract_Treatment__c cT : cTList) {
                    System.debug('Entry in for loop on Contract Treatment');
                    if(cTJ.Contract_Treatment__c == cT.Id){
                        cTJ.Name = cT.Name;
                    }
                    for(Corporate_Treatment_Job__c corTJ : corTJList){
                        System.debug('Entry in for loop on Corporate Treatment Job');
                        if(cTJ.Corporate_Treatment_Job__c == corTJ.Id){
                            // Cutting off the Treatment Job name if it is longer than 80 characters
                            if((cTJ.Name  + ' - ' + corTJ.Name).length() > 80) {
                                String toCutName = cTJ.Name  + ' - ' + corTJ.Name;
                                cTJ.Name = toCutName.substring(0, 79) + '.';
                            }
                            else {
                                cTJ.Name += (' - ' + corTJ.Name);
                            }
                        }
                    }
                }
            }
            
            System.debug('Contract Treatment Job Name is: ' + cTJ.Name);

            if(cTJ.Scheduling_Time_Frame__c == null && cTJ.Contract_Treatment__c != null) {
                toSetSchedulingTimeFrame.add(cTJ);
            }
        }

        // Setting Scheduling_Time_Frame__c from Contract_Treatment__r.Corporate_Treatment__c

        if(!toSetSchedulingTimeFrame.isEmpty()) {
            ContractTreatmentJobTriggerService.setSTFFromCorporateTreatment(toSetSchedulingTimeFrame);
        }
    }

    if(Trigger.isInsert && Trigger.isAfter) {
        // Filling External_Id__c

        ContractTreatmentJobTriggerService.setExternalId(Trigger.new);
    }

    if(Trigger.isUpdate && Trigger.isBefore){
        List<Id> ctjobids = new List<Id>();
        for (Contract_Treatment_Job__c cTJ : Trigger.new) {
            ctjobids.add(cTJ.Id);
        }
        List<String> queryfields = new List<String>{'Id','Contract_Treatment_Job__c'};
        List<Contract_Treatment_Job__c> ctjs = ContractTreatmentJobDAO.getContractTreatmentJobfieldbyids(queryfields,ctjobids);
        Map<Id, Id> ctjandfatherctj = new Map<Id, Id>();
        for (Contract_Treatment_Job__c ctj : ctjs) {
            ctjandfatherctj.put(ctj.Contract_Treatment_Job__c,ctj.Id) ;
        }
        List<Id> ctjids = new List<Id>();
        String exceptionlabel =  System.Label.ContractTreatmentJob_Expection;
        for (Contract_Treatment_Job__c cTJ : Trigger.new) {
            Contract_Treatment_Job__c oldRecord = Trigger.oldMap.get(cTJ.Id);

            if (cTJ.Frequency__c != oldRecord.Frequency__c || cTJ.Frequency_Unit_of_measure__c != oldRecord.Frequency_Unit_of_measure__c/*  ||
                cTJ.Frequency_Type__c != oldRecord.Frequency_Type__c */) {
                //ctjids.add(cTJ.Id);
                if (ctjandfatherctj.containsKey(cTJ.Id)) {
                    cTJ.addError(exceptionlabel ) ;
                    
                }
            }
        }
        ContractTreatmentJobTriggerService.updateFrequencyAndDelivery(Trigger.newMap, trigger.new);
    }
}