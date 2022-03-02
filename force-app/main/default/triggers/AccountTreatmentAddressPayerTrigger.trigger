trigger AccountTreatmentAddressPayerTrigger on Account_Treatment_Address_Payer__c (before insert, after insert, before update, after update) {
    if(Trigger.isInsert && Trigger.isBefore) {
        ATAPTriggerService.checkForDuplicates(Trigger.new);
    }

    if(Trigger.isInsert && Trigger.isAfter) {
        SObjectServiceClass.updateExternalId('Account_Treatment_Address_Payer__c', 'Name', 'External_Id__c', Trigger.new);
    }

    if(Trigger.isUpdate && Trigger.isBefore) {
        List<Account_Treatment_Address_Payer__c> ATAPsToCheck = new List<Account_Treatment_Address_Payer__c>();

        for(Account_Treatment_Address_Payer__c atap : Trigger.new) {
            Account_Treatment_Address_Payer__c oldRecord = Trigger.oldMap.get(atap.Id);

            if(oldRecord.Account_Treatment_Address__c != atap.Account_Treatment_Address__c || oldRecord.Payer__c != atap.Payer__c) {
                ATAPsToCheck.add(atap);
            }
        }

        if(!ATAPsToCheck.isEmpty()) {
            ATAPTriggerService.checkForDuplicates(ATAPsToCheck);
        }
    }

    if(Trigger.isUpdate && Trigger.isAfter) {
        List<Id> ATAPIdsToUpdateWOs = new List<Id>();

        // Updating Payer fields on the related WOs if the Payer has changed

        for(Account_Treatment_Address_Payer__c atap : Trigger.new) {
            if(Trigger.oldMap.get(atap.Id).Payer__c != atap.Payer__c) {
                ATAPIdsToUpdateWOs.add(atap.Id);
            }
        }

        System.debug('ATAPIdsToUpdateWOs: ' + ATAPIdsToUpdateWOs);

        if(!ATAPIdsToUpdateWOs.isEmpty()) {
            List<WorkOrder> workOrdersToUpdate = ATAPTriggerService.updateRelatedWOsPayerFields(ATAPIdsToUpdateWOs);

            System.debug('workOrdersToUpdate size: ' + workOrdersToUpdate.size());

            if(!workOrdersToUpdate.isEmpty()) {
                update workOrdersToUpdate;
            }
        }
    }
}