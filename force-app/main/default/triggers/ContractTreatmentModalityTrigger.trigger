trigger ContractTreatmentModalityTrigger on Contract_Treatment_Modality__c (before insert, before update) {
    if(Trigger.isInsert && Trigger.isBefore) {
        CTModalityTriggerService.checkSubTreatment(Trigger.new);
    }

    if(Trigger.isUpdate && Trigger.isBefore) {
        List<Contract_Treatment_Modality__c> newActiveCTMs = new List<Contract_Treatment_Modality__c>();

        for(Contract_Treatment_Modality__c ctm : Trigger.new) {
            Contract_Treatment_Modality__c oldRecord = Trigger.oldMap.get(ctm.Id);

            if(oldRecord.Status__c != 'Active' && ctm.Status__c == 'Active') {
                newActiveCTMs.add(ctm);
            }
        }

        if(!newActiveCTMs.isEmpty()) {
            CTModalityTriggerService.checkSubTreatment(newActiveCTMs);
        }
    }
}