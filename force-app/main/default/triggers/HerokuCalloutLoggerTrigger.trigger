trigger HerokuCalloutLoggerTrigger on Heroku_Callout_Logger__c (before insert, before delete) {

    if(FeatureManagementService.getFeatureStatus('Trigger_Heroku_Callout_Logger') || Test.isRunningTest()) {
        if(Trigger.isInsert && Trigger.isBefore) {
            List<Heroku_Callout_Logger__c> workOrderUpsertHCLs = new List<Heroku_Callout_Logger__c>();

            // Generating a Callout Logger record for each new Heroku Callout Logger (already inserted in the method because I need to update lookup field too)
            List<Callout_Logger__c> newCalloutLoggers = HerokuCalloutLoggerTriggerService.createCalloutLoggers(Trigger.new);

            for(Heroku_Callout_Logger__c hcl : Trigger.new) {
                if(hcl.Service__c == 'HEROKU_SAP4HANA__WORKORDER_UPSERT' && hcl.Type__c != 'W') {
                    workOrderUpsertHCLs.add(hcl);
                }
            }

            if(!workOrderUpsertHCLs.isEmpty()) {
                List<WorkOrder> toUpdate = HerokuCalloutLoggerTriggerService.updateRelatedWOs(workOrderUpsertHCLs);

                if(!toUpdate.isEmpty()) {
                    List<Database.SaveResult> results = Database.update(toUpdate);
                }
            }
        }

        if(Trigger.isDelete && Trigger.isBefore) {
            // Deleting related Callout Logger records
            HerokuCalloutLoggerTriggerService.deleteRelatedCalloutLoggers(Trigger.old);
        }
    }
}