public without sharing class CanceledWOLIsMovementBatch implements Database.Batchable<sObject>, Database.Stateful {
    public final List<String> WOLIQueryFields = new List<String>{'WorkOrderId', 'AssetId', 'Serial_Number__c', 'HU__c', 'Movement_Type__c', 'Status', 'WorkOrder.LocationId',
    'StorageLocation__c', 'WorkOrder.Delivery_Type__c', 'WorkOrder.Source_Location__c', 'WorkOrder.Account_Treatment__c', 'WorkOrder.EndDate', 
    'WorkOrder.SAP_Storage_Location__c', 'WorkOrder.AccountId', 'Related_Equipment_Key__c', 'Batch_Number__c', 'QuantityDelivered__c', 'ExpiryDate__c', 
    'Product_Code__c', 'Product2Id', 'Product2.Unit_of_measure__c', 'Equipment_Key_Tank__c', 'Asset.Product2Id', 'Offset__c', 'PricebookEntry.Product2Id', 
    'Asset.Equipment_Key__c'};
    public final List<String> assetQueryFields = new List<String>{'Equipment_Key__c'};

    public List<String> WOLIIds;
    public List<String> relatedWOLIIds = new List<String>();

    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT ';

        for(Integer i = 0; i < WOLIQueryFields.size(); i++) {
        query += WOLIQueryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM WorkOrderLineItem WHERE Id IN: WOLIIds';

        System.debug('CanceledWOLIsMovementBatch QUERY: ' + query);
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<WorkOrderLineItem> WOLIs) {
        List<WorkOrderLineItem> cylinderContainers = new List<WorkOrderLineItem>();
		List<WorkOrderLineItem> cylinderOxygenItems = new List<WorkOrderLineItem>();
		List<WorkOrderLineItem> emptyRefills = new List<WorkOrderLineItem>();
		List<WorkOrderLineItem> refillOxygenItems = new List<WorkOrderLineItem>();
		List<WorkOrderLineItem> HUItems = new List<WorkOrderLineItem>();
		List<String> cylinderContainerBatchNumbers = new List<String>();
		List<String> cylinderContainerEquipmentKeys = new List<String>();
		List<String> cylinderOxygenItemEquipmentKeys = new List<String>();
		List<String> cylinderOxygenItemAssetIds = new List<String>();
		List<String> emptyRefillAssetIds = new List<String>();
		List<String> emptyRefillWOIds = new List<String>();
		List<String> refillOxygenItemBatchNumbers = new List<String>();
		List<String> refillOxygenItemAssetProductIds = new List<String>();
		List<String> refillOxygenItemEquipmentKeys = new List<String>();
		List<String> refillOxygenItemWOIds = new List<String>();
		List<String> HUItemHUs = new List<String>();
		List<String> HUItemWOIds = new List<String>();

        // WOLIs movement

        CanceledWorkOrdersMovement.moveMaterials(null, WOLIs);

		// Setting QuantityDelivered and checking if there are related WOLIs to cancel

		for(WorkOrderLineItem woli : WOLIs) {
			woli.QuantityDelivered__c = 1;

			// Full cylinder - canceled container

			if(woli.Batch_Number__c != null && woli.AssetId != null && (woli.PricebookEntry.Product2Id == woli.Asset.Product2Id) && woli.HU__c == null) {
				cylinderContainers.add(woli);
				cylinderContainerBatchNumbers.add(woli.Batch_Number__c);
				cylinderContainerEquipmentKeys.add(woli.Asset.Equipment_Key__c);
			}

			// Full cylinder - canceled oxygen item

			if(woli.Batch_Number__c != null && woli.AssetId == null && woli.Related_Equipment_Key__c != null && woli.Equipment_Key_Tank__c == null && woli.HU__c == null) {
				cylinderOxygenItems.add(woli);
				cylinderOxygenItemEquipmentKeys.add(woli.Related_Equipment_Key__c);
			}

			// Refill - empty canceling

			if(woli.AssetId != null && (woli.PricebookEntry.Product2Id == woli.Asset.Product2Id) && woli.HU__c == null) {
				emptyRefills.add(woli);
				emptyRefillAssetIds.add(woli.AssetId);
				emptyRefillWOIds.add(woli.WorkOrderId);
			}

			// Refill - canceled oxygen

			if(woli.Batch_Number__c != null && woli.AssetId != null && woli.Related_Equipment_Key__c != null && woli.Equipment_Key_Tank__c != null && woli.HU__c == null) {
				refillOxygenItems.add(woli);
				refillOxygenItemBatchNumbers.add(woli.Batch_Number__c);
				refillOxygenItemAssetProductIds.add(woli.Asset.Product2Id);
				refillOxygenItemEquipmentKeys.add(woli.Related_Equipment_Key__c);
				refillOxygenItemWOIds.add(woli.WorkOrderId);
			}

			// HU Items

			if(woli.HU__c != null) {
				HUItems.add(woli);
				HUItemHUs.add(woli.HU__c);
				HUItemWOIds.add(woli.WorkOrderId);
			}
		}

        List<Database.SaveResult> results = Database.update(WOLIs);

		if(!cylinderContainers.isEmpty()) {
			List<WorkOrderLineItem> contentWOLIs = WorkOrderLineItemDAO.getCylinderContentWOLIs(WOLIQueryFields, cylinderContainerBatchNumbers, cylinderContainerEquipmentKeys);

			if(contentWOLIs != null) {
                for(WorkOrderLineItem woli : contentWOLIs) {
                    relatedWOLIIds.add(woli.Id);
                }
			}
		}

		if(!cylinderOxygenItems.isEmpty()) {
			List<Asset> relatedAssets = AssetDAO.getAssetsFromEquipmentKey(assetQueryFields, cylinderOxygenItemEquipmentKeys);

			if(relatedAssets != null && !relatedAssets.isEmpty()) {
				for(Asset a : relatedAssets) {
					cylinderOxygenItemAssetIds.add(a.Id);
				}

				List<WorkOrderLineItem> containerWOLIs = WorkOrderLineItemDAO.getContainersFromAssetIds(WOLIQueryFields, cylinderOxygenItemAssetIds);

				if(containerWOLIs != null) {
					for(WorkOrderLineItem woli : containerWOLIs) {
                        relatedWOLIIds.add(woli.Id);
                    }
				}
			}
		}

		if(!emptyRefills.isEmpty()) {
			List<WorkOrderLineItem> otherRefillWOLIs = WorkOrderLineItemDAO.getRefillWOLIsFromAssetAndWO(WOLIQueryFields, emptyRefillAssetIds, emptyRefillWOIds);

			if(otherRefillWOLIs != null) {
				for(WorkOrderLineItem woli : otherRefillWOLIs) {
                    relatedWOLIIds.add(woli.Id);
                }
			}
		}

		if(!refillOxygenItems.isEmpty()) {
			List<WorkOrderLineItem> containerWOLIs = WorkOrderLineItemDAO.getRefillContainers(WOLIQueryFields, refillOxygenItemBatchNumbers, refillOxygenItemAssetProductIds, 
			refillOxygenItemEquipmentKeys, refillOxygenItemWOIds);

			if(containerWOLIs != null) {
				for(WorkOrderLineItem woli : containerWOLIs) {
                    relatedWOLIIds.add(woli.Id);
                }
			}
		}

		if(!HUItems.isEmpty()) {
			List<WorkOrderLineItem> sameHuWOLIs = WorkOrderLineItemDAO.getWOLIsFromHUAndWOId(WOLIQueryFields, HUItemHUs, HUItemWOIds);

			if(sameHuWOLIs != null) {
				for(WorkOrderLineItem woli : sameHuWOLIs) {
                    relatedWOLIIds.add(woli.Id);
                }
			}
		}
    }

    public void finish(Database.BatchableContext bc) {
        system.debug('DONE'); //TODO
        List<WorkOrderLineItem> relatedWOLIsToCancel = new List<WorkOrderLineItem>();

        if(!relatedWOLIIds.isEmpty()) {
            for(String WOLIId : relatedWOLIIds) {
                WorkOrderLineItem WOLI = new WorkOrderLineItem(
                    Id = WOLIId,
                    Status = 'Canceled'
                );

                relatedWOLIsToCancel.add(WOLI);
            }   

            if(!relatedWOLIsToCancel.isEmpty()) {
                List<Database.SaveResult> results = Database.update(relatedWOLIsToCancel, false);
            }
        }
    }
}