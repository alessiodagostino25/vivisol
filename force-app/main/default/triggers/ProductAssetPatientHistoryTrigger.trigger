trigger ProductAssetPatientHistoryTrigger on Product_Asset_Patient_History__c (before insert, after insert, before update, after update) {
    if(Trigger.isInsert && Trigger.isBefore) {
        for(Product_Asset_Patient_History__c paph : Trigger.new) {
            paph.Is_Portal_Sync__c = '02';
        }
    }

    if(Trigger.isInsert && Trigger.isAfter) {
        ProductAssetPatientHistoryService.setExternalId(Trigger.new);
    }

    if(Trigger.isUpdate && Trigger.isBefore) {
        ProductAssetPatientHistoryService.setIsPortalSync(Trigger.new, Trigger.oldMap, false);
    }

    /* if(Trigger.isUpdate && Trigger.isAfter) {
        ProductAssetPatientHistoryService.setIsPortalSync(Trigger.new, Trigger.oldMap);
    } */
}