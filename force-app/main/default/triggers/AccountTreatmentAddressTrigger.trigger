trigger AccountTreatmentAddressTrigger on Account_Treatment_Address__c (after insert, after update, before insert, before update, after delete) {
    if(Trigger.isAfter && Trigger.isInsert) {
        SObjectServiceClass.updateExternalId('Account_Treatment_Address__c', 'Account_Treatment_Address_Number__c', 'External_Id__c', Trigger.new);

        Id profileId = UserInfo.getProfileId();
        List<Id> relatedContractFrameworkIds = new List<Id>();
        List<Id> ataIds = new List<Id>();
        List<Id> cfIds = new List<Id>();
        List<Account_Treatment_Address_Payer__c> atapsToInsert = new List<Account_Treatment_Address_Payer__c>();
        String profileName = [SELECT Name FROM Profile WHERE Id =: profileId].Name;
        Map<Id, Account_Treatment_Address__c> ataMap = new Map<Id, Account_Treatment_Address__c>();
        if(profileName != null && profileName.contains('_NL')) {
            for(Account_Treatment_Address__c ata : Trigger.new) {
                ataIds.add(ata.Id);
            }
            List<Account_Treatment_Address__c> ataList = [SELECT Account_Treatment__r.Contract_Treatment__r.Contract_Framework__c FROM Account_Treatment_Address__c WHERE Id IN: ataIds];
            for(Account_Treatment_Address__c ata : ataList) {
                cfIds.add(ata.Account_Treatment__r.Contract_Treatment__r.Contract_Framework__c);
                ataMap.put(ata.Account_Treatment__r.Contract_Treatment__r.Contract_Framework__c, ata);
            }
            List<Contract_Payer__c> contractPayers = [SELECT Account__c, Id, Contract_Framework__c FROM Contract_Payer__c WHERE Contract_Framework__c IN: cfIds LIMIT 1];
            for(Contract_Payer__c cp : contractPayers) {
                Account_Treatment_Address_Payer__c atap = new Account_Treatment_Address_Payer__c(
                    Payer__c = cp.Account__c,
                    Account_Treatment_Address__c = ataMap.get(cp.Contract_Framework__c).Id,
                    //Payment_Method__c = ?,
                    Payment_Percentage__c = 100,
                    Contract_Payer__c = cp.Id,
                    Account_Treatment__c = ataMap.get(cp.Contract_Framework__c).Account_Treatment__c
                );
                atapsToInsert.add(atap);
            }
            insert atapsToInsert;
        }
    }

    // Handling an ATA being set to Default

    if(Trigger.isBefore) {
        if(Trigger.isInsert) {
            ATATriggerService.updateDefault(Trigger.new, false);
        }
        else if(Trigger.isUpdate) {
            ATATriggerService.updateDefault(Trigger.new, true);
        }
    }

    // Executing the batch to assign every autoscheduled WorkOrder to the correct ATA
    
    if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate || Trigger.isDelete)) {
        List<Id> relatedATIds = new List<Id>();
        
        if(Trigger.isInsert || Trigger.isUpdate) {
            for(Account_Treatment_Address__c ata : Trigger.new) {
                relatedATIds.add(ata.Account_Treatment__c);
            }
        }
        else if(Trigger.isDelete) {
            for(Account_Treatment_Address__c ata : Trigger.old) {
                relatedATIds.add(ata.Account_Treatment__c);
            }
        }

        if(FeatureManagementService.getFeatureStatus('Run_ATA_Batch_From_ATA_Trigger') || Test.isRunningTest()) {
            ATAAlignmentBatch ATABatch = new ATAAlignmentBatch();
            ATABatch.ATIds = relatedATIds;

            Database.executeBatch(ATABatch, 100);
        }
    }

}