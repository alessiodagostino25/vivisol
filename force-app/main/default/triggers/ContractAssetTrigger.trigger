trigger ContractAssetTrigger on Contract_Asset__c (after insert, after update) {
    if(Trigger.isInsert && Trigger.isAfter) {
        SObjectServiceClass.updateExternalId('Contract_Asset__c', 'Name', 'External_Id__c', Trigger.new);
    }

    if(Trigger.isUpdate && Trigger.isAfter) {
        ContractAssetTriggerService.ContractAssetTriggerServicemethod(Trigger.new);
    }
}