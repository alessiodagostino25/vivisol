trigger AccountTreatmentJobProductTrigger on Account_Treatment_Job_Product__c (after insert, before insert,after update) {

    if (Trigger.isInsert && Trigger.isBefore){
        for (Account_Treatment_Job_Product__c c : Trigger.new ) {
            c.Last_Propagated_Quantity__c = c.Quantity__c;
        }
    }

    if (Trigger.isAfter && Trigger.isUpdate) {
        List<Id> atjpsIds = new List<Id>();
        List<Id> atjsIds = new List<Id>();
        List<Id> atjpAssetIds = new List<Id>();

        for (Account_Treatment_Job_Product__c atjp : Trigger.new ) {
            if (atjp.Status__c == 'Inactive' && atjp.Asset__c !=  null ) {
                atjpsIds.add(atjp.Id);
                atjsIds.add(atjp.Patient_Treatment_Job__c);
                atjpAssetIds.add(atjp.Asset__c);
            }
        }

        if(!atjpsIds.isEmpty() && !atjsIds.isEmpty() && !atjpAssetIds.isEmpty()) {
            ATJProductTriggerService.deactivationOfWoandWoli(atjpsIds,atjsIds,atjpAssetIds);
        }

        // Handling the update of Asset__c, Plant__c and Storage_Location__c

        List<WorkOrderLineItem> WOLIsToUpdate = ATJProductTriggerService.updateRelatedWOLIs(Trigger.new, Trigger.oldMap);

        if(!WOLIsToUpdate.isEmpty()) {
            List<Database.SaveResult> results = Database.update(WOLIsToUpdate);
        }
    }
    
    if(Trigger.isAfter && Trigger.isInsert) {
        List<Id> ATJPIds = new List<Id>();

        for(Account_Treatment_Job_Product__c atjp : Trigger.new) {
            ATJPIds.add(atjp.Id);
        }

        List<WorkOrderLineItem> newWOLIs = ATJProductTriggerService.createWOLIs(ATJPIds);

        if(!newWOLIs.isEmpty()) {
            List<Database.SaveResult> results = Database.insert(newWOLIs);
        }
    }
}