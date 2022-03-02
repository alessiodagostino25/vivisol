trigger MeritPolicyHeaderTrigger on Merit_Policy_Header__c (before insert, after insert) {

    if(Trigger.isInsert && Trigger.isAfter) {
        MeritPolicyHeaderTriggerHelper helper = new MeritPolicyHeaderTriggerHelper(Trigger.new);

        MeritPolicyHeaderTriggerQueueable updateJob = new MeritPolicyHeaderTriggerQueueable(helper);
        // enqueue the job for processing
        ID jobID = System.enqueueJob(updateJob);
    } else if (Trigger.isInsert && Trigger.isBefore){
        MeritPolicyHeaderTriggerHelper helperBefore = new MeritPolicyHeaderTriggerHelper(Trigger.new);
        for (Merit_Policy_Header__c mph : Trigger.new ) {
            mph = helperBefore.handleCompanyCode(mph);
            mph = helperBefore.handleAnnualBudget(mph);
        }
    }
    
}