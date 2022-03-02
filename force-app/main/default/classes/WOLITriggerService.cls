public class WOLITriggerService{

	public class WOLIException extends Exception {}

	public static List<WorkOrderLineItem> updateExternalId(List<WorkOrderLineItem> WOLIs){
		List<String> workOrderQueryFields = new List<String>{'WorkOrderNumber'};

		List<WorkOrderLineItem> WOLIsToUpdate = new List<WorkOrderLineItem>();
		List<WorkOrder> relatedWorkOrders = new List<WorkOrder>();
		List<Id> workOrderIds = new List<Id>();

		Map<Id, WorkOrder> workOrderMap = new Map<Id, WorkOrder>();

		for (WorkOrderLineItem woli : WOLIs){
			workOrderIds.add(woli.WorkOrderId);
		}

		if (!workOrderIds.isEmpty()){
			relatedWorkOrders = WorkOrderDAO.getWorkOrdersFromIds(workOrderQueryFields, workOrderIds);

			if (!relatedWorkOrders.isEmpty()){
				for (WorkOrder wo : relatedWorkOrders){
					workOrderMap.put(wo.Id, wo);
				}
			}
		}

		for (WorkOrderLineItem woli : WOLIs){
			WorkOrder relatedWorkOrder = workOrderMap.get(woli.WorkOrderId);
			System.debug('RelatedWorkOrder: ' + relatedWorkOrder);
			System.debug('WorkOrderNumber: ' + relatedWorkOrder.WorkOrderNumber);
			System.debug('LineItemNumber: ' + woli.LineItemNumber);

			if (relatedWorkOrder != null){
				if (woli.OrderLineItemExternalId__c == null){
					WorkOrderLineItem tmp = new WorkOrderLineItem();
					tmp.Id = woli.Id;
					tmp.OrderLineItemExternalId__c = relatedWorkOrder.WorkOrderNumber + '_' + woli.LineItemNumber;

					WOLIsToUpdate.add(tmp);
				}
			}
		}

		return WOLIsToUpdate;
	}

	public static List<WorkOrderLineItem> updateServiceReport(List<WorkOrderLineItem> WOLIs){
		List<String> WOLIQueryFields = new List<String>{'Account_Treatment_Job_Product__c', 'Account_Treatment_Job_Product__r.Contract_Treatment_Job_Product__r.Questionnaire__c', 
		'Account_Treatment_Job_Product__r.Contract_Treatment_Job_Product__r.Questionnaire__r.ServiceReportTemplateId__c'};

		List<WorkOrderLineItem> toUpdate = new List<WorkOrderLineItem>();
		List<Id> WOLIIds = new List<Id>();

		for (WorkOrderLineItem woli : WOLIs){
			WOLIIds.add(woli.Id);
		}

		List<WorkOrderLineItem> queriedWOLIs = WorkOrderLineItemDAO.getWOLIsFromIds(WOLIQueryFields, WOLIIds);

		for (WorkOrderLineItem woli : queriedWOLIs){
			if (woli.Account_Treatment_Job_Product__c != null && woli.Account_Treatment_Job_Product__r.Contract_Treatment_Job_Product__r.Questionnaire__c != null){
				WorkOrderLineItem tmp = new WorkOrderLineItem();
				tmp.Id = woli.Id;
				tmp.ServiceReportTemplateId = woli.Account_Treatment_Job_Product__r.Contract_Treatment_Job_Product__r.Questionnaire__r.ServiceReportTemplateId__c;
				tmp.Questionnaire__c = woli.Account_Treatment_Job_Product__r.Contract_Treatment_Job_Product__r.Questionnaire__c;

				toUpdate.add(tmp);
			}
		}

		return toUpdate;
	}

	public static List<WorkOrderLineItem> cloneAndChangeQuantity(List<WorkOrderLineItem> WOLIs){
		List<WorkOrderLineItem> newWOLIs = new List<WorkOrderLineItem>();

		for (WorkOrderLineItem woli : WOLIs){
			if (woli.Quantity != null){
				Decimal originalQuantity = woli.Quantity;

				if (originalQuantity > 1){
					woli.Quantity = 1;

					// Deep cloning the record (is it correct to deep clone it? Otherwise I'd keep a reference)

					for (Integer i = 0; i < (originalQuantity - 1); i++){
						WorkOrderLineItem newWOLI = woli.clone(false, true, false, false);

						newWOLIs.add(newWOLI);
					}
				}
			}
		}

		return newWOLIs;
	}

	public static void createOrderLineItemHK(List<WorkOrderLineItem> WOLIs){
		System.debug('----- createOrderLineItemHK -----');
		List<ObjectMapping__mdt> mappingfields = [SELECT Source_Field__c, Target_Field__c, isCheckBox__c, Source_Object__c, Target_Object__c
		                                          FROM ObjectMapping__mdt
		                                          WHERE Source_Object__r.DeveloperName = 'WorkOrderLineItem' AND Target_Object__r.DeveloperName = 'OrderItemHK'];

		System.debug('mappingFields: ' + mappingfields);
		List<OrderItemHK__c> toUpdate = new List<OrderItemHK__c>();
		List<OrderItemHK__c> toInsert = new List<OrderItemHK__c>();
		List<Id> workOrderIds = new List<Id>();
		for (WorkOrderLineItem woli : WOLIs){
			workOrderIds.add(woli.WorkOrderId);
		}
		List<String> queryfields = new List<String>{'Id', 'WorkOrder__c'};
		List<OrderHK__c> orderHKs = OrderHKDAO.getOrderHKbyworkorderId(queryfields, workOrderIds);
		System.debug('orderHKs size: ' + orderHKs.size());
		Map<Id, Id> orderhkIdandworkorderId = new Map<Id, Id>();
		for (OrderHK__c ohk : orderHKs){
			orderhkIdandworkorderId.put(ohk.WorkOrder__c, ohk.Id);
		}
		if (!orderHKs.isEmpty()){

			for (WorkOrderLineItem woli : WOLIs){
				OrderItemHK__c oikh = new OrderItemHK__c();
				for (ObjectMapping__mdt mapping : mappingfields){
					if (mapping.isCheckBox__c){
						oikh.put(mapping.Target_Field__c, woli.get(mapping.Source_Field__c));
					} else{
						oikh.put(mapping.Target_Field__c, woli.get(mapping.Source_Field__c));
					}
				}
				oikh.ParentOrderHK__c = orderhkIdandworkorderId.get(woli.WorkOrderId);

				if(oikh.OrderLineItemExternalId__c != null) {
					toUpdate.add(oikh);
				}
			}
		}

		if (!toUpdate.isEmpty()){
			Schema.SObjectField orderitemexternalId = OrderItemHK__c.Fields.OrderLineItemExternalId__c;
			if (orderitemexternalId == null){
				insert toUpdate;
			} else{
				Database.UpsertResult[] srList = Database.upsert(toUpdate, orderitemexternalId, false);
				
				if(srList != null) {
					List<Error_Log_Event__e> errorLogEvents = new List<Error_Log_Event__e>();
	
					for(Database.UpsertResult result : srList) {
						System.debug('OrderItemHK creation success: ' + result.isSuccess());
	
						if(!result.isSuccess()) {
							Database.Error[] errors = result.getErrors();
	
							if(errors != null) {
								for(Database.Error error : errors) {
									Error_Log_Event__e event = ErrorLogEventHandler.createEvent(
										'WOLITriggerService', 
										'createOrderLineItemHK', 
										'ERROR', 
										error.getMessage(), 
										'OrderItemHK creation error'
									);
									errorLogEvents.add(event);
								}
							}
						}
					}
	
					if(!errorLogEvents.isEmpty()) {
						List<Database.SaveResult> publishResults = EventBus.publish(errorLogEvents);
					}
				}
			}
		}
	}

	public static void updateOrderLineItemHK(List<WorkOrderLineItem> WOLIs, Boolean isDelete, Boolean checkDifferences){
		System.debug('----- updateOrderLineItemHK -----');
		
		List<ObjectMapping__mdt> mappingfields = [SELECT Source_Field__c, Target_Field__c, isCheckBox__c, Source_Object__c, Target_Object__c
		                                          FROM ObjectMapping__mdt
		                                          WHERE Source_Object__r.DeveloperName = 'WorkOrderLineItem' AND Target_Object__r.DeveloperName = 'OrderItemHK'];

		System.debug('mappingFields: ' + mappingfields);
		List<OrderItemHK__c> toUpdate = new List<OrderItemHK__c>();
		List<OrderItemHK__c> toUpdateupsert = new List<OrderItemHK__c>();
		List<Id> woliIds = new List<Id>();
		for (WorkOrderLineItem woli : WOLIs){
			woliIds.add(woli.Id);
		}
		List<String> queryfields = new List<String>(OrderItemHK__c.SObjectType.getDescribe().fields.getMap().keySet());
		List<WorkOrderLineItem> createorderlineitemHKwolis = new List<WorkOrderLineItem>();
		List<OrderItemHK__c> orderitemHKs = OrderItemHKDAO.getOrderItemHKbyworkorderId(queryfields, woliIds);
		Map<Id, OrderItemHK__c> idAndOrderItemHK = new Map<Id, OrderItemHK__c>();
		for (OrderItemHK__c oihk : orderitemHKs){
			idAndOrderItemHK.put(oihk.WorkOrderLineItem__c, oihk);
		}
		for (WorkOrderLineItem woli : WOLIs){
			if (idAndOrderItemHK.containsKey(woli.Id)){
				OrderItemHK__c oihk = idAndOrderItemHK.get(woli.Id);
				for (ObjectMapping__mdt mapping : mappingfields){
					if (mapping.isCheckBox__c){
						oihk.put(mapping.Target_Field__c, woli.get(mapping.Source_Field__c));
					} else{
						if(checkDifferences) {
							if (woli.get(mapping.Source_Field__c) != oihk.get(mapping.Target_Field__c)){
								oihk.put(mapping.Target_Field__c, woli.get(mapping.Source_Field__c));
							}
						}
						else {
							oihk.put(mapping.Target_Field__c, woli.get(mapping.Source_Field__c));
						}
					}
				}

				if(isDelete) {
					//oihk.To_Be_Deleted__c = true;
					oihk.Rejection_Reason__c = 'Z1';					
				}

				if(oihk.OrderLineItemExternalId__c != null) {
					toUpdate.add(oihk);
				}
			}
			else {
				createorderlineitemHKwolis.add(woli);
			}
		}
		if (!createorderlineitemHKwolis.isEmpty()) {

			WOLITriggerService.createOrderLineItemHK(createorderlineitemHKwolis);
		}

		if (!toUpdate.isEmpty()){
			Schema.SObjectField orderitemexternalId = OrderItemHK__c.Fields.OrderLineItemExternalId__c;
			if (orderitemexternalId == null){
				update toUpdate;
			} else{
				Database.UpsertResult[] srList = Database.upsert(toUpdate, orderitemexternalId, false);
				
				if(srList != null) {
					List<Error_Log_Event__e> errorLogEvents = new List<Error_Log_Event__e>();
	
					for(Database.UpsertResult result : srList) {
						System.debug('OrderItemHK upsert success: ' + result.isSuccess());
	
						if(!result.isSuccess()) {
							Database.Error[] errors = result.getErrors();
	
							if(errors != null) {
								for(Database.Error error : errors) {
									Error_Log_Event__e event = ErrorLogEventHandler.createEvent(
										'WOLITriggerService', 
										'updateOrderLineItemHK', 
										'ERROR', 
										error.getMessage(), 
										'OrderItemHK upsert error'
									);
									errorLogEvents.add(event);
								}
							}
						}
					}
	
					if(!errorLogEvents.isEmpty()) {
						List<Database.SaveResult> publishResults = EventBus.publish(errorLogEvents);
					}
				}
			}
		}
	}
	
	public static void updateWOLIStorageLocation(List<WorkOrderLineItem> newWOLIs){
		List<String> relatedWOIds = new List<String>();
		List<String> workOrderQueryFields = new List<String>{ 'SAP_Plant__c', 'SAP_Storage_Location__c'};
		for(WorkOrderLineItem newWOLI: newWOLIs){
			relatedWOIds.add(newWOLI.WorkOrderId);
		}

		List<WorkOrder> woList = WorkOrderDAO.getWorkOrdersFromIds(workOrderQueryFields,relatedWOIds);
		Map<String,WorkOrder> woMap = new Map<String,WorkOrder>();
		for (WorkOrder wo: woList){
			woMap.put(wo.Id, wo);
		}
		for(WorkOrderLineItem newWOLI:newWOLIs){
			String tmpPlant = woMap.get(newWOLI.WorkOrderId).SAP_Plant__c;
			String tmpStorageLocation = woMap.get(newWOLI.WorkOrderId).SAP_Storage_Location__c;
			if (tmpPlant != null){
				newWOLI.Plant__c = tmpPlant;
			}
			if (tmpStorageLocation != null){
				newWOLI.StorageLocation__c = tmpStorageLocation;
			}
		}
	}

	public static void updateIsPortalSyncRelatedWOs(List<String> workOrderIds) {
		List<String> workOrderQueryFields = new List<String>{'Is_Portal_Sync__c'};

		List<WorkOrder> workOrders = WorkOrderDAO.getWorkOrdersFromIds(workOrderQueryFields, workOrderIds);

		if(workOrders != null && !workOrders.isEmpty()) {
			SObjectServiceClass.updateGenericField('WorkOrder', '03', 'Is_Portal_Sync__c', workOrders);
		}
	}

	public static void pimcoreFieldsChangeCheck(List<WorkOrderLineItem> WOLIs, Map<Id, WorkOrderLineItem> oldMap) {
		List<String> toUpdate = new List<String>();

		// Checking if any Pimcore-related WOLI field has changed...

		List<Pimcore_Field_Mapping__mdt> fieldMappings = [SELECT Object__c, Field__c FROM Pimcore_Field_Mapping__mdt WHERE Object__c = 'WorkOrderLineItem'];

		if(fieldMappings != null && !fieldMappings.isEmpty()) {
			for(WorkOrderLineItem record : WOLIs) {
				WorkOrderLineItem oldRecord = oldMap.get((String)record.get('Id'));

				if(oldRecord != null) {
					for(Pimcore_Field_Mapping__mdt fieldMapping : fieldMappings) {
						if(oldRecord.get(fieldMapping.Field__c) != record.get(fieldMapping.Field__c)) {
							toUpdate.add(record.WorkOrderId);
							break;
						}
					}
				}
			}
			
			// ... In case, updating IsPortalSync on its related WO

			if(!toUpdate.isEmpty()) {
				updateIsPortalSyncRelatedWOs(toUpdate);
			}
		}
	}

	public static void handleBillablePimcore(List<WorkOrderLineItem> WOLIs) {
		List<String> workOrderQueryFields = new List<String>{'Document_Type__c', 'Account_Treatment__c', 'Account_Treatment_Job__c', 
		'Account_Treatment_Job__r.Contract_Treatment_Job__c'};
		List<String> pricebookEntryQueryFields = new List<String>{'Product2Id'};
		List<String> productQueryFields = new List<String>{'Product_Family__c'};
		List<String> ATJPQueryFields = new List<String>{'Billable__c', 'Patient_Treatment_Job__c', 'Product__c'};
		List<String> CTJPQueryFields = new List<String>{'Billable__c', 'Contract_Treatment_Job__c', 'Product__c'};

		List<String> relatedWorkOrderIds = new List<String>();
		List<String> relatedWorkOrderATJIds = new List<String>();
		List<String> relatedWorkOrderCTJIds = new List<String>();
		List<String> relatedProductIds = new List<String>();
		List<String> relatedPricebookEntryIds = new List<String>();
		List<PricebookEntry> relatedPricebookEntries = new List<PricebookEntry>();
		List<Product2> relatedProducts = new List<Product2>();
		List<WorkOrder> relatedPimcoreWorkOrders = new List<WorkOrder>();
		List<Account_Treatment_Job_Product__c> relatedATJPs = new List<Account_Treatment_Job_Product__c>();
		List<Contract_Treatment_Job_Product__c> relatedCTJPs = new List<Contract_Treatment_Job_Product__c>();

		Map<String, WorkOrder> pimcoreWorkOrderMap = new Map<String, WorkOrder>();
		Map<String, Account_Treatment_Job_Product__c> ATJPMap = new Map<String, Account_Treatment_Job_Product__c>();
		Map<String, Contract_Treatment_Job_Product__c> CTJPMap = new Map<String, Contract_Treatment_Job_Product__c>();
		Map<String, Product2> productMap = new Map<String, Product2>();
		Map<String, PricebookEntry> pricebookEntryMap = new Map<String, PricebookEntry>();

		for(WorkOrderLineItem woli : WOLIs) {
			relatedWorkOrderIds.add(woli.WorkOrderId);
			relatedPricebookEntryIds.add(woli.PricebookEntryId);
		}

		if(!relatedWorkOrderIds.isEmpty()) {		
			relatedPimcoreWorkOrders = WorkOrderDAO.getYP00WorkOrdersFromIds(workOrderQueryFields, relatedWorkOrderIds);

			if(!relatedPimcoreWorkOrders.isEmpty()) {
				relatedPricebookEntries = PricebookEntryDAO.getPricebookEntriesFromId(pricebookEntryQueryFields, relatedPricebookEntryIds);

				if(!relatedPricebookEntries.isEmpty()) {
					for(PricebookEntry pe : relatedPricebookEntries) {
						pricebookEntryMap.put(pe.Id, pe);
						relatedProductIds.add(pe.Product2Id);
					}
				}

				relatedProducts = Product2DAO.getProduct2sFromIds(productQueryFields, relatedProductIds);

				if(!relatedProducts.isEmpty()) {
					for(Product2 product : relatedProducts) {
						productMap.put(product.Id, product);
					}
				}

				for(WorkOrder wo : relatedPimcoreWorkOrders) {
					pimcoreWorkOrderMap.put(wo.Id, wo);

					if(wo.Account_Treatment__c != null && wo.Account_Treatment_Job__c != null) {
						relatedWorkOrderATJIds.add(wo.Account_Treatment_Job__c);

						if(wo.Account_Treatment_Job__r.Contract_Treatment_Job__c != null) {
							relatedWorkOrderCTJIds.add(wo.Account_Treatment_Job__r.Contract_Treatment_Job__c);
						}
					}
				}

				if(!relatedWorkOrderATJIds.isEmpty()) {
					relatedATJPs = AccountTreatmentJobProductDAO.getActiveProductsFromATJs(ATJPQueryFields, relatedWorkOrderATJIds);

					if(!relatedATJPs.isEmpty()) {
						for(Account_Treatment_Job_Product__c atjp : relatedATJPs) {
							ATJPMap.put(String.valueOf(atjp.Patient_Treatment_Job__c) + String.valueOf(atjp.Product__c), atjp);
						}
					}
				}

				if(!relatedWorkOrderCTJIds.isEmpty()) {
					relatedCTJPs = ContractTreatmentJobProductDAO.getActiveCTJPsFromCTJs(CTJPQueryFields, relatedWorkOrderCTJIds);

					if(!relatedCTJPs.isEmpty()) {
						for(Contract_Treatment_Job_Product__c ctjp : relatedCTJPs) {
							CTJPMap.put(String.valueOf(ctjp.Contract_Treatment_Job__c) + String.valueOf(ctjp.Product__c), ctjp);
						}
					}
				}

				for(WorkOrderLineItem woli : WOLIs) {
					WorkOrder relatedWorkOrder = pimcoreWorkOrderMap.get(woli.WorkOrderId);
					PricebookEntry relatedPricebookEntry = pricebookEntryMap.get(woli.PricebookEntryId);
					Product2 relatedProduct;

					System.debug('ATJPMap: ' + ATJPMap);
					System.debug('relatedWorkOrder: ' + relatedWorkOrder);

					if(relatedPricebookEntry != null) {
						relatedProduct = productMap.get(relatedPricebookEntry.Product2Id);
					}

					if(relatedWorkOrder != null) {
						if(relatedWorkOrder.Account_Treatment__c == null) {
							woli.Billable__c = true;
						}
						else {
							if(relatedProduct != null) {
								Account_Treatment_Job_Product__c relatedATJP = ATJPMap.get(
									String.valueOf(relatedWorkOrder.Account_Treatment_Job__c) + String.valueOf(relatedProduct.Id)
								);
								System.debug('relatedATJP: ' + relatedATJP);
								System.debug('cosa cerco: ' + String.valueOf(relatedWorkOrder.Account_Treatment_Job__c) + String.valueOf(relatedProduct.Id));

								if(relatedATJP != null) {
									woli.Billable__c = relatedATJP.Billable__c;
								}
								else {
									Contract_Treatment_Job_Product__c relatedCTJP = CTJPMap.get(
										String.valueOf(relatedWorkOrder.Account_Treatment_Job__r.Contract_Treatment_Job__c) + String.valueOf(relatedProduct.Id)
									);

									if(relatedCTJP != null) {
										woli.Billable__c = relatedCTJP.Billable__c;
									}
									else {
										Contract_Treatment_Job_Product__c relatedCTJPFamily = CTJPMap.get(
											String.valueOf(relatedWorkOrder.Account_Treatment_Job__r.Contract_Treatment_Job__c) + 
											String.valueOf(relatedProduct.Product_Family__c)
										);

										if(relatedCTJPFamily != null) {
											woli.Billable__c = relatedCTJPFamily.Billable__c;
										}
										else {
											woli.Billable__c = true;
										}
									}
								}
							}
						}
					}
				}
			}
		}
	}

	//https://111222.atlassian.net/browse/VI-1786
	public static void checkForWOLIDelete (List<WorkOrderLineItem> newWOLIs){
		String currentUserProfileId = UserInfo.getProfileId();
		List<String> queriedProfileIds = new List<String>();
        List<String> profileQueryFields = new List<String>{'Name'};
        List<String> profileNames = new List<String>{'System Administrator', 'System_Admin_Mulesoft', 'SystemAdministrator_NL', 'SystemAdministrator_Corporate'};

		List<Profile> queriedProfiles = ProfileDAO.getProfilesFromNames(profileQueryFields, profileNames);
		for (Profile tmpProfile : queriedProfiles){
			queriedProfileIds.add(tmpProfile.Id);
		}
		if (!queriedProfileIds.contains(currentUserProfileId)){
			for (WorkOrderLineItem tmpWOLI : newWOLIs){		
				if (tmpWOLI.WOStatus__c == 'In Progress' || tmpWOLI.WOStatus__c == 'Completed' || tmpWOLI.WOStatus__c == 'Cannot Complete' 
				|| tmpWOLI.WOStatus__c == 'Canceled'){
					System.debug('WORK ORDER STATUS: ' + tmpWOLI.WOStatus__c);
					throw new WOLIException();
				}
			}
		}
	}

	public static void moveMaterials(List<String> WOLIIds/* , List<WorkOrderLineItem> relatedWOLIs */) {
		System.debug('----- WOLITriggerService.moveMaterials (SINGLE ROWS) -----');

		CanceledWOLIsMovementBatch canceledWOLIsMovementBatch = new CanceledWOLIsMovementBatch();
		canceledWOLIsMovementBatch.WOLIIds = WOLIIds;

		Database.executeBatch(canceledWOLIsMovementBatch);

		/* List<String> WOLIQueryFields = new List<String>{'WorkOrderId', 'AssetId', 'Serial_Number__c', 'HU__c', 'Movement_Type__c', 'Status', 'WorkOrder.LocationId',
		'StorageLocation__c', 'WorkOrder.Delivery_Type__c', 'WorkOrder.Source_Location__c', 'WorkOrder.Account_Treatment__c', 'WorkOrder.EndDate', 
		'WorkOrder.SAP_Storage_Location__c', 'WorkOrder.AccountId', 'Related_Equipment_Key__c', 'Batch_Number__c', 'QuantityDelivered__c', 'ExpiryDate__c', 
		'Product_Code__c', 'Product2Id', 'Product2.Unit_of_measure__c', 'Equipment_Key_Tank__c', 'Asset.Product2Id', 'Offset__c', 'PricebookEntry.Product2Id', 
		'Asset.Equipment_Key__c'};
		List<String> assetQueryFields = new List<String>{'Equipment_Key__c'};

		List<WorkOrderLineItem> WOLIs = new List<WorkOrderLineItem>();
		List<WorkOrderLineItem> relatedWOLIsToCancel = new List<WorkOrderLineItem>();
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

		if(relatedWOLIs == null) {
			WOLIs = WorkOrderLineItemDAO.getWOLIsFromIds(WOLIQueryFields, WOLIIds);
		}
		else {
			WOLIs = relatedWOLIs;
		}

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

		if(!cylinderContainers.isEmpty()) {
			List<WorkOrderLineItem> contentWOLIs = WorkOrderLineItemDAO.getCylinderContentWOLIs(WOLIQueryFields, cylinderContainerBatchNumbers, cylinderContainerEquipmentKeys);

			if(contentWOLIs != null) {
				relatedWOLIsToCancel.addAll(contentWOLIs);
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
					relatedWOLIsToCancel.addAll(containerWOLIs);
				}
			}
		}

		if(!emptyRefills.isEmpty()) {
			List<WorkOrderLineItem> otherRefillWOLIs = WorkOrderLineItemDAO.getRefillWOLIsFromAssetAndWO(WOLIQueryFields, emptyRefillAssetIds, emptyRefillWOIds);

			if(otherRefillWOLIs != null) {
				relatedWOLIsToCancel.addAll(otherRefillWOLIs);
			}
		}

		if(!refillOxygenItems.isEmpty()) {
			List<WorkOrderLineItem> containerWOLIs = WorkOrderLineItemDAO.getRefillContainers(WOLIQueryFields, refillOxygenItemBatchNumbers, refillOxygenItemAssetProductIds, 
			refillOxygenItemEquipmentKeys, refillOxygenItemWOIds);

			if(containerWOLIs != null) {
				relatedWOLIsToCancel.addAll(containerWOLIs);
			}
		}

		if(!HUItems.isEmpty()) {
			List<WorkOrderLineItem> sameHuWOLIs = WorkOrderLineItemDAO.getWOLIsFromHUAndWOId(WOLIQueryFields, HUItemHUs, HUItemWOIds);

			if(sameHuWOLIs != null) {
				relatedWOLIsToCancel.addAll(sameHuWOLIs);
			}
		}

		// Recalling this method for related WOLIs to cancel

		if(!relatedWOLIsToCancel.isEmpty()) {
			moveMaterials(null, relatedWOLIsToCancel);
		} */
	}
}