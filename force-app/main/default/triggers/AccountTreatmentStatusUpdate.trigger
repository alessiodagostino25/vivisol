trigger AccountTreatmentStatusUpdate on Account_Treatment_Status__c(before insert, after insert) {
    
    //try {
    if(Trigger.isInsert && Trigger.isBefore) {
        for(Account_Treatment_Status__c ats : Trigger.new) {
            if(ats.Status__c == 'S') {
                ats.StartDate__c = ats.Suspension_start_date__c;
            }
        }
    }

    if(Trigger.isInsert && Trigger.isAfter) {
        SObjectServiceClass.updateExternalId('Account_Treatment_Status__c', 'Name', 'External_Id__c', Trigger.new);

        AccTreatmentStatusTriggerHelper.onInsert(Trigger.new);
        AccTreatmentStatusTriggerHelper.updateWorkOrders(Trigger.new);
    }
    /* } catch (Exception e) {
        system.debug('trigger AccountTreatmentStatusUpdate Exception Line number: ' +e.getLineNumber() +', Exception message:' +e.getMessage());
    } */
}