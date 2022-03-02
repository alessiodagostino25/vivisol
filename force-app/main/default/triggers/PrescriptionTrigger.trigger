trigger PrescriptionTrigger on Prescription__c (after insert, before update) {
    if(Trigger.isInsert && Trigger.isAfter) {
        // Filling External_Id__c

        PrescriptionService.setExternalId(Trigger.new);
    }

    /* if(Trigger.isUpdate && Trigger.isAfter) {
        PrescriptionService.setIsPortalSync(Trigger.new, Trigger.oldMap, true);
    } */

    if(Trigger.isUpdate && Trigger.isBefore) {
        PrescriptionService.setIsPortalSync(Trigger.new, Trigger.oldMap, true, false);
    }
}