trigger StoredDocumentTrigger on Stored_Document__c (after insert, after update) {
    if(Trigger.isInsert && Trigger.isAfter) {
        List<Stored_Document__c> toUpdateRelatedPrescriptions = new List<Stored_Document__c>();

        for(Stored_Document__c sd : Trigger.new) {
            if(sd.Related_Prescription__c != null) {
                toUpdateRelatedPrescriptions.add(sd);
            }
        }

        if(!toUpdateRelatedPrescriptions.isEmpty()) {
            StoredDocumentTriggerService.updateRelatedPrescriptions(toUpdateRelatedPrescriptions);
        }
        StoredDocumentTriggerService.updateRelatedContentVersion(Trigger.new);
    }

    if(Trigger.isUpdate && Trigger.isAfter) {
        List<Stored_Document__c> toUpdateRelatedPrescriptions = new List<Stored_Document__c>();

        for(Stored_Document__c sd : Trigger.new) {
            if(sd.Related_Prescription__c != null) {
                toUpdateRelatedPrescriptions.add(sd);
            }
        }

        if(!toUpdateRelatedPrescriptions.isEmpty()) {
            StoredDocumentTriggerService.updateRelatedPrescriptions(toUpdateRelatedPrescriptions);
        }
    }
}