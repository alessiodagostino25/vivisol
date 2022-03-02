trigger AccountTreatmentJobTrigger on Account_Treatment_Job__c (before insert, after insert, after update) {

    if (Trigger.isInsert && Trigger.isBefore){
        for (Account_Treatment_Job__c acc : Trigger.new ) {
            acc.Last_Propagated_Delivery_Channel__c = acc.Delivery_Channel__c;
            acc.Last_Propagated_Frequency__c = acc.Frequency__c;
            acc.Last_Propagated_Frequency_UOM__c = acc.Frequency_Unit_of_measure__c;
            acc.Last_Propagated_Frequency_Type__c = acc.Frequency_Type__c;
        }
    }

    if(Trigger.isInsert && Trigger.isAfter) {
        AccountTreatmentJobService.setExternalId(Trigger.new);

        if(FeatureManagementService.getFeatureStatus('Update_AT_Is_Portal_Sync') || Test.isRunningTest()) {
            AccountTreatmentJobService.updateAccountTreatmentIsPortalSync(Trigger.new);
        }
    }

    if(Trigger.isUpdate && Trigger.isAfter) {
        if(FeatureManagementService.getFeatureStatus('Update_AT_Is_Portal_Sync') || Test.isRunningTest()) {
            AccountTreatmentJobService.updateAccountTreatmentIsPortalSync(Trigger.new);
        }

        List<Account_Treatment_Job__c> changedFrequency = new List<Account_Treatment_Job__c>();

        for(Account_Treatment_Job__c atj : Trigger.new) {
            Account_Treatment_Job__c oldRecord = Trigger.oldMap.get(atj.Id);

            if((atj.Frequency__c != oldRecord.Frequency__c) || (atj.Frequency_Unit_of_measure__c != oldRecord.Frequency_Unit_of_measure__c) ||
                atj.Frequency_Type__c != oldRecord.Frequency_Type__c) {
                changedFrequency.add(atj);
            }
        }

        if(!changedFrequency.isEmpty()) {
            AccountTreatmentJobService.updateServiceAppointmentHasFrequency(changedFrequency);
        }
    }
}