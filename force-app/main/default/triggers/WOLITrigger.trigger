trigger WOLITrigger on WorkOrderLineItem (before insert, after insert, before update, after update, before delete) {

    if(Trigger.isBefore && Trigger.isInsert) {
        List<String> pricebookEntryQueryFields = new List<String>{'Product2Id', 'Product2.Type__c'};

        List<String> metadataCodes = new List<String>();
        List<WorkOrderLineItem> WOLIsToClone = new List<WorkOrderLineItem>();

        List<Product_Type__mdt> metadataRecords = [SELECT Code__c FROM Product_Type__mdt];

        for(Product_Type__mdt mdt : metadataRecords) {
            metadataCodes.add(mdt.Code__c);
        }
        System.debug('MetadataCodes: ' + metadataCodes);

        if(!metadataCodes.isEmpty()) {
            List<Id> pricebookEntryIds = new List<Id>();
            Map<Id, PricebookEntry> pricebookEntryMap = new Map<Id, PricebookEntry>();

            for(WorkOrderLineItem woli : Trigger.new) {
                System.debug('woli.PricebookEntryId: ' + woli.PricebookEntryId);
                pricebookEntryIds.add(woli.PricebookEntryId);
            }

            // Querying PricebookEntries because WOLI.Product_Type__c isn't populated in before insert (neither Product2Id), so I need to query for Product2.Type__c from Pricebook

            List<PricebookEntry> relatedPricebookEntries = PricebookEntryDAO.getPricebookEntriesFromId(pricebookEntryQueryFields, pricebookEntryIds);
            System.debug('relatedPricebookEntries: ' + relatedPricebookEntries);

            for(PricebookEntry pricebookEntry : relatedPricebookEntries) {
                pricebookEntryMap.put(pricebookEntry.Id, pricebookEntry);
            }

            for(WorkOrderLineItem woli : Trigger.new) {
                if(!pricebookEntryMap.isEmpty()) {
                    PricebookEntry relatedPricebookEntry = pricebookEntryMap.get(woli.PricebookEntryId);
                    
                    if(relatedPricebookEntry != null) {
                        System.debug('relatedPricebookEntry: ' + relatedPricebookEntry);

                        if(metadataCodes.contains(relatedPricebookEntry.Product2.Type__c)) {
                            WOLIsToClone.add(woli);
                        }
                    }
                }
            }
        }

        // Cloning and setting Quantity = 1 for WOLIs with Product2.Type__c in the list of codes of the metadata

        if(!WOLIsToClone.isEmpty()) {
            List<WorkOrderLineItem> newWOLIs = WOLITriggerService.cloneAndChangeQuantity(WOLIsToClone);

            if(newWOLIs != null) {
                insert newWOLIs;
            }
        }

        // Handling Billable__c for Pimcore WOLIs

        WOLITriggerService.handleBillablePimcore(Trigger.new);
    }

    if(Trigger.isAfter && Trigger.isInsert) {
        WOLITriggerService.createOrderLineItemHK(Trigger.new);
        List<WorkOrderLineItem> WOLIsToUpdate = WOLITriggerService.updateExternalId(Trigger.new);

        if(WOLIsToUpdate != null) {
            update WOLIsToUpdate;
        }

        // Update Service Report

        List<WorkOrderLineItem> toUpdate = WOLITriggerService.updateServiceReport(Trigger.new);

        if(toUpdate != null) {
            update toUpdate;
        }

        // Setting IsPortalSync on related WOs

        List<String> workOrderIds = new List<String>();

        for(WorkOrderLineItem woli : Trigger.new) {
            workOrderIds.add(woli.WorkOrderId);
        }

        if(!workOrderIds.isEmpty()) {
            WOLITriggerService.updateIsPortalSyncRelatedWOs(workOrderIds);
        }
    }

    if(Trigger.isBefore && Trigger.isUpdate) {
        List<WorkOrderLineItem> completedWOLIs = new List<WorkOrderLineItem>();
        List<String> canceledWOLIIds = new List<String>();

        for(WorkOrderLineItem woli : Trigger.new) {
            WorkOrderLineItem oldRecord = Trigger.oldMap.get(woli.Id);

            if(woli.Status == 'Completed') {
                completedWOLIs.add(woli);
            }
            if(woli.Status == 'Canceled' && oldRecord.Status == 'Completed' && woli.QuantityDelivered__c != 0 && woli.QuantityDelivered__c != null) {
                canceledWOLIIds.add(woli.Id);
            }
        }

        if(!completedWOLIs.isEmpty()) {
            WOLITriggerService.updateWOLIStorageLocation(completedWOLIs);
        }

        // Canceled WOLIs movement

        if(!canceledWOLIIds.isEmpty()) {
            WOLITriggerService.moveMaterials(canceledWOLIIds/* , null */);
        }
    }

    if(Trigger.isAfter && Trigger.isUpdate) {
        // Updating OrderItemHK

        WOLITriggerService.updateOrderLineItemHK(Trigger.new, false, true);

        // Checking if any Pimcore-related field has changed; if so, setting IsPortalSync to 02 on the related WO

        WOLITriggerService.pimcoreFieldsChangeCheck(Trigger.new, Trigger.oldMap);
    }

	// Updating linked the OrderItemHKs to be removed
	
	if(Trigger.isBefore && Trigger.isDelete) {
		WOLITriggerService.checkForWOLIDelete(Trigger.old);
		WOLITriggerService.updateOrderLineItemHK(Trigger.old, true, true);
    }
}