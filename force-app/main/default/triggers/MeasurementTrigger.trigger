trigger MeasurementTrigger on Measurement__c (after insert) {
    if(Trigger.isInsert && Trigger.isAfter) {
        SObjectServiceClass.updateExternalId('Measurement__c', 'Measurement_Number__c', 'External_Id__c', Trigger.new);
    }
}