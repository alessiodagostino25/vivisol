trigger AdditionalItemConfigurationTrigger on Additional_Item_Configuration__c (after insert) {
    if(Trigger.isInsert && Trigger.isAfter) {
        SObjectServiceClass.updateExternalId('Additional_Item_Configuration__c', 'Name', 'External_Id__c', Trigger.new);
    }
}