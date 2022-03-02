trigger ProductTransferTrigger on ProductTransfer (before insert, after insert, after update) {
    
    if(Trigger.isInsert && Trigger.isBefore) {
        System.debug('CPU consumed ---  STEP 1: ' + Limits.getCpuTime());
        ProductTransferTriggerService.updateSalesOrgCode(Trigger.new);
        System.debug('CPU consumed ---  STEP 2: ' + Limits.getCpuTime());

        if(!SingletonClass.checkNotToFire()) {
            ProductTransferTriggerService.updateRelatedProductItems(Trigger.new);
        }
    }

    if(Trigger.isInsert && Trigger.isAfter) {
        //SObjectServiceClass.updateExternalId('ProductTransfer', 'ProductTransferNumber', 'External_Id__c', Trigger.new);

        List<String> toShareNetherlandsIds = new List<String>();
        List<String> productTransferIds = new List<String>();

        for(ProductTransfer productTransfer : Trigger.new) {
            productTransferIds.add(productTransfer.Id);

            if(productTransfer.Sales_Org_Code__c == '6300') {
                toShareNetherlandsIds.add(productTransfer.Id);
            }
        }

        if(!System.isBatch()) {
            SObjectServiceClass.updateExternalIdFuture('ProductTransfer', 'ProductTransferNumber', 'External_Id__c', productTransferIds);
        }
        else {
            SObjectServiceClass.updateExternalId('ProductTransfer', 'ProductTransferNumber', 'External_Id__c', Trigger.new);
        }

        if(!toShareNetherlandsIds.isEmpty()) {
            ProductTransferTriggerService.shareProductTransferRecords(toShareNetherlandsIds, 'NL_6300', 'RoleAndSubordinates', 'Edit');
        }
    }

    if(Trigger.isUpdate && Trigger.isAfter) {
        List<String> toShareNetherlandsIds = new List<String>();

        for(ProductTransfer productTransfer : Trigger.new) {
            ProductTransfer oldRecord = Trigger.oldMap.get(productTransfer.Id);

            if(productTransfer.Sales_Org_Code__c == '6300' && (oldRecord.OwnerId != productTransfer.OwnerId)) {
                toShareNetherlandsIds.add(productTransfer.Id);
            }
        }

        if(!toShareNetherlandsIds.isEmpty()) {
            ProductTransferTriggerService.shareProductTransferRecords(toShareNetherlandsIds, 'NL_6300', 'RoleAndSubordinates', 'Edit');
        }
    }
}