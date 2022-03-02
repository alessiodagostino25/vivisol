trigger ProductItemTrigger on ProductItem (before insert, after insert, before update, after update, after delete) {

    if(Trigger.isBefore && Trigger.isInsert) {
        List<ProductItem> withSerializedItem = new List<ProductItem>();
        System.debug('CPU consumed ---  STEP 12: ' + Limits.getCpuTime());
        ProductItemTriggerService.updateSalesOrgCode(Trigger.new);
        System.debug('CPU consumed ---  STEP 13: ' + Limits.getCpuTime());

        for(ProductItem productItem : Trigger.new) {
            if(productItem.Serialized_Item__c != null) {
                withSerializedItem.add(productItem);
            }
        }

        

        if(!withSerializedItem.isEmpty()) {
            if(FeatureManagementService.getFeatureStatus('ProductItem_OLDExternalId', false) || Test.isRunningTest()) {
                ProductItemTriggerService.setOldExternalId(withSerializedItem);
            }
        }
    }

    if(Trigger.isAfter && Trigger.isInsert) {
        System.debug('CPU consumed ---  STEP 14: ' + Limits.getCpuTime());
        List<ProductItem> productItemsToCheck = new List<ProductItem>();
        List<ProductItem> withRelatedItem = new List<ProductItem>();

        for(ProductItem pi : Trigger.new) {
            if(pi.Serialized_Item__c == null) {
                productItemsToCheck.add(pi);
            }

            if(pi.RelatedProductItem__c != null) {
                withRelatedItem.add(pi);
            }
        }

        if(!productItemsToCheck.isEmpty()) {
            System.debug('CPU consumed ---  STEP 15: ' + Limits.getCpuTime());
            List<Picklist_Choise_Set_Flow__c> PCSFsToInsert = ProductItemTriggerService.checkAndCreatePCSF(productItemsToCheck);
            System.debug('CPU consumed ---  STEP 16: ' + Limits.getCpuTime());

            if(PCSFsToInsert != null) {
                insert PCSFsToInsert;
            }
        }

        if(!withRelatedItem.isEmpty()) {

            // Updating RelatedContainer__c

            System.debug('CPU consumed ---  STEP 17: ' + Limits.getCpuTime());
            List<ProductItem> toUpdateRelatedContainerField = ProductItemTriggerService.updateRelatedContainerField(withRelatedItem);
            System.debug('CPU consumed ---  STEP 18: ' + Limits.getCpuTime());

            if(!toUpdateRelatedContainerField.isEmpty()) {
                List<Database.SaveResult> results = Database.update(toUpdateRelatedContainerField);
            }

            // Updating RelatedItem's BatchNumber + blanking RelatedProductItem__c on PIs related to the same Item

            System.debug('CPU consumed ---  STEP 19: ' + Limits.getCpuTime());
            List<ProductItem> toUpdate = ProductItemTriggerService.updateRelatedItem(withRelatedItem);
            System.debug('CPU consumed ---  STEP 20: ' + Limits.getCpuTime());

            if(!toUpdate.isEmpty()) {
                List<Database.SaveResult> results = Database.update(toUpdate);
            }

        }
    }

    if(Trigger.isBefore && Trigger.isUpdate) {
        System.debug('----- ProductItemTrigger BEFORE UPDATE -----');
        System.debug('CPU consumed ---  STEP 21: ' + Limits.getCpuTime());
        List<ProductItem> changedLocation = new List<ProductItem>();

        for(ProductItem pi : Trigger.new) {
            ProductItem oldProductItem = Trigger.oldMap.get(pi.Id);

            if(oldProductItem.LocationId != pi.LocationId && pi.LocationId != null) {
                changedLocation.add(pi);
            }
        }

        if(!changedLocation.isEmpty()) {
            System.debug('CPU consumed ---  STEP 22: ' + Limits.getCpuTime());
            ProductItemTriggerService.updateSalesOrgCode(changedLocation);
            System.debug('CPU consumed ---  STEP 23: ' + Limits.getCpuTime());
        }
    }

    if(Trigger.isAfter && Trigger.isUpdate) {
        System.debug('----- ProductItemTrigger AFTER UPDATE -----');
        List<ProductItem> withUpdatedRelatedItem = new List<ProductItem>();

        for(ProductItem pi : Trigger.new) {
            if(Trigger.oldMap.get(pi.Id).RelatedProductItem__c != pi.RelatedProductItem__c && pi.RelatedProductItem__c != null) {
                withUpdatedRelatedItem.add(pi);
            }
        }

        if(!withUpdatedRelatedItem.isEmpty()) {
            // Updating RelatedItem's BatchNumber + blanking RelatedProductItem__c on PIs related to the same Item

            System.debug('CPU consumed ---  STEP 24: ' + Limits.getCpuTime());
            List<ProductItem> toUpdate = ProductItemTriggerService.updateRelatedItem(withUpdatedRelatedItem);
            System.debug('CPU consumed ---  STEP 25: ' + Limits.getCpuTime());

            if(!toUpdate.isEmpty()) {
                List<Database.SaveResult> results = Database.update(toUpdate);
            }
        }
    }

    if(Trigger.isAfter && Trigger.isDelete) {
        List<ProductItem> productItemsToCheck = new List<ProductItem>();

        for(ProductItem pi : Trigger.old) {
            if(pi.Serialized_Item__c == null) {
                productItemsToCheck.add(pi);
            } else {
                if(FeatureManagementService.getFeatureStatus('PI_SN_DELETE_CHECK', false) || Test.isRunningTest()) {
                    ProductItemTriggerService.throwSerializedItemCustomException();
                }
            }
        }

        if(!productItemsToCheck.isEmpty()) {
            List<Picklist_Choise_Set_Flow__c> PCSFsToDelete = ProductItemTriggerService.checkAndGetPCSFToDelete(productItemsToCheck);

            if(PCSFsToDelete != null) {
                delete PCSFsToDelete;
            }
        }
    }
}