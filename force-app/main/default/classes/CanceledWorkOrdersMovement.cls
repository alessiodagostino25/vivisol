public class CanceledWorkOrdersMovement {
    public static void moveMaterials(List<String> workOrderIds, List<WorkOrderLineItem> WOLIs) {
		System.debug('----- moveMaterials -----');

		List<String> WOLIQueryFields = new List<String>{'WorkOrderId', 'AssetId', 'Serial_Number__c', 'HU__c', 'Movement_Type__c', 'Status', 'WorkOrder.LocationId',
		'StorageLocation__c', 'WorkOrder.Delivery_Type__c', 'WorkOrder.Source_Location__c', 'WorkOrder.Account_Treatment__c', 'WorkOrder.EndDate', 
		'WorkOrder.SAP_Storage_Location__c', 'WorkOrder.AccountId', 'Related_Equipment_Key__c', 'Batch_Number__c', 'QuantityDelivered__c', 'ExpiryDate__c', 
		'Product_Code__c', 'Product2Id', 'Product2.Unit_of_measure__c', 'Equipment_Key_Tank__c', 'Asset.Product2Id', 'Offset__c'};

		List<WorkOrderLineItem> allRelatedWOLIs = new List<WorkOrderLineItem>();

		List<WorkOrderLineItem> serializedItems = new List<WorkOrderLineItem>();

		List<WorkOrderLineItem> batchVANItemsNoHUNoCylinderDelivery = new List<WorkOrderLineItem>();
		List<WorkOrderLineItem> batchVANItemsHUNoCylinderDelivery = new List<WorkOrderLineItem>();
		List<WorkOrderLineItem> batchVANItemsCylinderDelivery = new List<WorkOrderLineItem>();
        List<WorkOrderLineItem> batchVANItemsRefillDelivery = new List<WorkOrderLineItem>();
        List<WorkOrderLineItem> batchVANItemsRemoval = new List<WorkOrderLineItem>();
        List<WorkOrderLineItem> batchHospitalItemsNoHUNoCylinderDelivery = new List<WorkOrderLineItem>();
        List<WorkOrderLineItem> batchHospitalItemsHUNoCylinderDelivery = new List<WorkOrderLineItem>();
        List<WorkOrderLineItem> batchHospitalItemsRemoval = new List<WorkOrderLineItem>();
        List<WorkOrderLineItem> batchCurrierItemsNoHUNoCylinderDelivery = new List<WorkOrderLineItem>();
		List<WorkOrderLineItem> batchCurrierItemsRemoval = new List<WorkOrderLineItem>();

		List<WorkOrderLineItem> consumableVANItemsNoHUDelivery = new List<WorkOrderLineItem>();
		List<WorkOrderLineItem> consumableHospitalItemsNoHUDelivery = new List<WorkOrderLineItem>();
		List<WorkOrderLineItem> consumableCurrierItemsNoHUDelivery = new List<WorkOrderLineItem>();
		List<WorkOrderLineItem> consumableVANItemsHUDelivery = new List<WorkOrderLineItem>();
		List<WorkOrderLineItem> consumableHospitalItemsHUDelivery = new List<WorkOrderLineItem>();
		List<WorkOrderLineItem> consumableVANItemsNoHURemoval = new List<WorkOrderLineItem>();
		List<WorkOrderLineItem> consumableHospitalItemsNoHURemoval = new List<WorkOrderLineItem>();
		List<WorkOrderLineItem> consumableCurrierItemsNoHURemoval = new List<WorkOrderLineItem>();

		List<WorkOrderLineItem> yellowBagItems = new List<WorkOrderLineItem>();

		// WOLIs is a new parameter added to handle the movimentation of single items

		if(workOrderIds != null && WOLIs == null) {
			allRelatedWOLIs = WorkOrderLineItemDAO.getWOLIsToMoveFromWOs(WOLIQueryFields, workOrderIds);
		}
		else if(workOrderIds == null && WOLIs != null) {
			allRelatedWOLIs = WOLIs;
		}

		if(!allRelatedWOLIs.isEmpty()) {
			for(WorkOrderLineItem woli : allRelatedWOLIs) {

				// SERIALIZED

				if(woli.AssetId != null && woli.Serial_Number__c != null && woli.Asset.Product2Id == woli.Product2Id) {
					serializedItems.add(woli);
				}

				// BATCH REFILL DELIVERY

				if(woli.Related_Equipment_Key__c != null && woli.Equipment_Key_Tank__c != null && woli.AssetId != null && woli.Batch_Number__c != null &&
				(woli.WorkOrder.Delivery_Type__c == 'Home Visit' || (woli.WorkOrder.Delivery_Type__c == 'Welcome Model' && woli.WorkOrder.Source_Location__c != null))) {
					batchVANItemsRefillDelivery.add(woli);
				}

				// BATCH...

				else if(woli.Batch_Number__c != null && woli.Serial_Number__c == null) {

					// ... VAN... 

					if(woli.WorkOrder.Delivery_Type__c == 'Home Visit' || (woli.WorkOrder.Delivery_Type__c == 'Welcome Model' && woli.WorkOrder.Source_Location__c != null)) {

						// ... No Asset...

						if(woli.AssetId == null) {

							// ... Delivery...

							if(woli.Movement_Type__c == 'Delivery (+)') {

								// ... No Cylinder...

								if(woli.Related_Equipment_Key__c == null) {

									// ... No HU

									if(woli.HU__c == null) {
										batchVANItemsNoHUNoCylinderDelivery.add(woli);
									}

									// ... HU

									else {
										batchVANItemsHUNoCylinderDelivery.add(woli);
									}
								}

								// ... Cylinder 

								else {
									batchVANItemsCylinderDelivery.add(woli);
								}
							}
							
							// ... Removal

							else if(woli.Movement_Type__c == 'Removal (-)') {
                                if(woli.HU__c == null && woli.Related_Equipment_Key__c == null) {
                                    batchVANItemsRemoval.add(woli);
                                }
							}
						}

						// Batch Refill Delivery

						/* else {
							if(woli.Related_Equipment_Key__c != null && woli.Equipment_Key_Tank__c != null) {
								batchVANItemsRefillDelivery.add(woli);
							}
						} */
                    }
                    
                    // ... Hospital Stock...

                    else if(woli.WorkOrder.Delivery_Type__c == 'Consignment Stock' || (woli.WorkOrder.Delivery_Type__c == 'Welcome Model' && woli.WorkOrder.Source_Location__c == null)) {
                        if(woli.AssetId == null && woli.Related_Equipment_Key__c == null) {
                            if(woli.Movement_Type__c == 'Delivery (+)') {
                                if(woli.HU__c == null) {
                                    batchHospitalItemsNoHUNoCylinderDelivery.add(woli);
                                }
                                else {
                                    batchHospitalItemsHUNoCylinderDelivery.add(woli);
                                }
                            }
                            else if(woli.Movement_Type__c == 'Removal (-)' && woli.HU__c == null) {
                                batchHospitalItemsRemoval.add(woli);
                            }
                        }
                    }

                    // ... Currier

                    else if(woli.WorkOrder.Delivery_Type__c == 'Currier') {
                        if(woli.AssetId == null && woli.Related_Equipment_Key__c == null && woli.HU__c == null) {
                            if(woli.Movement_Type__c == 'Delivery (+)') {
                                batchCurrierItemsNoHUNoCylinderDelivery.add(woli);
                            }
                            else if(woli.Movement_Type__c == 'Removal (-)') {
                                batchCurrierItemsRemoval.add(woli);
                            }
                        }
                    }
				}

				// CONSUMABLE...

				else if(woli.Serial_Number__c == null && woli.Batch_Number__c == null) {

					// ... VAN... 

					if(woli.WorkOrder.Delivery_Type__c == 'Home Visit' || (woli.WorkOrder.Delivery_Type__c == 'Welcome Model' && woli.WorkOrder.Source_Location__c != null)) {

						// ... Delivery...

						if(woli.Movement_Type__c == 'Delivery (+)') {

							if(woli.Related_Equipment_Key__c == null) {
								if(woli.HU__c == null) {
									consumableVANItemsNoHUDelivery.add(woli);
								}
								else {
									consumableVANItemsHUDelivery.add(woli);
								}
							}
						}

						// ... Removal...

						else if(woli.Movement_Type__c == 'Removal (-)') {
							if(woli.Related_Equipment_Key__c == null && woli.HU__c == null) {
								consumableVANItemsNoHURemoval.add(woli);
							}
						}
					}

					// ... Hospital Stock...

					else if(woli.WorkOrder.Delivery_Type__c == 'Consignment Stock' || (woli.WorkOrder.Delivery_Type__c == 'Welcome Model' && woli.WorkOrder.Source_Location__c == null)) {

						// ... Delivery...

						if(woli.Movement_Type__c == 'Delivery (+)') {

							if(woli.Related_Equipment_Key__c == null) {
								if(woli.HU__c == null) {
									consumableHospitalItemsNoHUDelivery.add(woli);
								}
								else {
									consumableHospitalItemsHUDelivery.add(woli);
								}
							}
						}

						// ... Removal...

						else if(woli.Movement_Type__c == 'Removal (-)') {
							if(woli.Related_Equipment_Key__c == null && woli.HU__c == null) {
								consumableHospitalItemsNoHURemoval.add(woli);
							}
						}
					}

					// ... Currier...

					else if(woli.WorkOrder.Delivery_Type__c == 'Currier') {

						// Delivery...

						if(woli.Movement_Type__c == 'Delivery (+)') {

							if(woli.Related_Equipment_Key__c == null && woli.HU__c == null) {
								consumableCurrierItemsNoHUDelivery.add(woli);
							}
						}

						// ... Removal...

						else if(woli.Movement_Type__c == 'Removal (-)') {
							if(woli.Related_Equipment_Key__c == null && woli.HU__c == null) {
								consumableCurrierItemsNoHURemoval.add(woli);
							}
						}
					}
				}

				// YELLOW BAG...

				else if(woli.AssetId == null && woli.Serial_Number__c != null) {
					if(woli.Movement_Type__c == 'Removal (-)') {
						if(woli.Product_Code__c == 'YELLOW_BAG' || woli.Product_Code__c == 'NOT_LABELED') {
							yellowBagItems.add(woli);
						}
					}
				}


			}

			if(!serializedItems.isEmpty()) {
				handleSerializedItems(serializedItems);
			}

			if(!batchVANItemsNoHUNoCylinderDelivery.isEmpty()) {
				handleBatchItemsNoHUNoCylinderDelivery(batchVANItemsNoHUNoCylinderDelivery, 'Home Visit');
			}

			if(!batchVANItemsHUNoCylinderDelivery.isEmpty()) {
				handleBatchItemsHUNoCylinderDelivery(batchVANItemsHUNoCylinderDelivery, 'Home Visit');
			}

			if(!batchVANItemsCylinderDelivery.isEmpty()) {
				handleBatchVANItemsCylinderDelivery(batchVANItemsCylinderDelivery);
			}

			if(!batchVANItemsRefillDelivery.isEmpty()) {
                handleBatchVANItemsRefillDelivery(batchVANItemsRefillDelivery);
            }
            
            if(!batchVANItemsRemoval.isEmpty()) {
                handleBatchItemsRemoval(batchVANItemsRemoval, 'Home Visit');
            }

            if(!batchHospitalItemsNoHUNoCylinderDelivery.isEmpty()) {
                handleBatchItemsNoHUNoCylinderDelivery(batchHospitalItemsNoHUNoCylinderDelivery, 'Consignment Stock');
            }

            if(!batchHospitalItemsHUNoCylinderDelivery.isEmpty()) {
                handleBatchItemsHUNoCylinderDelivery(batchHospitalItemsHUNoCylinderDelivery, 'Consignment Stock');
            }

            if(!batchHospitalItemsRemoval.isEmpty()) {
                handleBatchItemsRemoval(batchHospitalItemsRemoval, 'Consignment Stock');
            }

            if(!batchCurrierItemsNoHUNoCylinderDelivery.isEmpty()) {
                handleBatchItemsNoHUNoCylinderDelivery(batchCurrierItemsNoHUNoCylinderDelivery, 'Currier');
            }

            if(!batchCurrierItemsRemoval.isEmpty()) {
                handleBatchItemsRemoval(batchCurrierItemsRemoval, 'Currier');
			}
			
			if(!consumableVANItemsNoHUDelivery.isEmpty()) {
				handleConsumableItemsNoHUDelivery(consumableVANItemsNoHUDelivery, 'Home Visit');
			}

			if(!consumableHospitalItemsNoHUDelivery.isEmpty()) {
				handleConsumableItemsNoHUDelivery(consumableHospitalItemsNoHUDelivery, 'Consignment Stock');
			}

			if(!consumableCurrierItemsNoHUDelivery.isEmpty()) {
				handleConsumableItemsNoHUDelivery(consumableCurrierItemsNoHUDelivery, 'Currier');
			}

			if(!consumableVANItemsHUDelivery.isEmpty()) {
				handleConsumableItemsHUDelivery(consumableVANItemsHUDelivery, 'Home Visit');
			}

			if(!consumableHospitalItemsHUDelivery.isEmpty()) {
				handleConsumableItemsHUDelivery(consumableVANItemsHUDelivery, 'Consignment Stock');
			}

			if(!consumableVANItemsNoHURemoval.isEmpty()) {
				handleConsumableItemsRemoval(consumableVANItemsNoHURemoval, 'Home Visit');
			}

			if(!consumableHospitalItemsNoHURemoval.isEmpty()) {
				handleConsumableItemsRemoval(consumableHospitalItemsNoHURemoval, 'Consignment Stock');
			}

			if(!consumableCurrierItemsNoHURemoval.isEmpty()) {
				handleConsumableItemsRemoval(consumableCurrierItemsNoHURemoval, 'Currier');
			}

			if(!yellowBagItems.isEmpty()) {
				handleYellowBagItems(yellowBagItems);
			}
		}
	}

	// Serialized Items

	public static void handleSerializedItems(List<WorkOrderLineItem> WOLIs) {
		System.debug('----- handleSerializedItems -----');

		List<String> productItemQueryFields = new List<String>{'Barcode_Label__c', 'Product2Id', 'QuantityUnitOfMeasure', 'Serialized_Item__c', 'SerialNumber', 
		'LocationId', 'HU__c'};
		List<String> assetQueryFields = new List<String>{'Account_Treatment__c', 'AssetServicedById'};

		List<ProductItem> allRelatedProductItems = new List<ProductItem>();
		List<ProductItem> productItemsToUpdate = new List<ProductItem>();
		List<Asset> allRelatedAssets = new List<Asset>();
		List<Asset> assetsToUpdate = new List<Asset>();
		List<ProductTransfer> productTransfersToInsert = new List<ProductTransfer>();
		List<String> serializedItemIds = new List<String>();
		List<String> serializedItemsToDeletePAPHsDelivery = new List<String>();
		List<String> ATIdsToDeletePAPHsDelivery = new List<String>();
		List<Date> datesToDeletePAPHsDelivery = new List<Date>();
		List<String> serializedItemsToDeletePAPHsRemoval = new List<String>();
		List<String> ATIdsToDeletePAPHsRemoval = new List<String>();
		List<Date> datesToDeletePAPHsRemoval = new List<Date>();
		List<Product_Asset_Patient_History__c> PAPHsToDelete = new List<Product_Asset_Patient_History__c>();

		Map<String, ProductItem> productItemMap = new Map<String, ProductItem>();
		Map<String, Asset> assetMap = new Map<String, Asset>();

		for(WorkOrderLineItem woli : WOLIs) {
			serializedItemIds.add(woli.AssetId);
		}

		// Getting all ProductItems and all Assets related to the serialized WOLIs

		allRelatedProductItems = ProductItemDAO.getProductItemsFromSerializedItem(productItemQueryFields, serializedItemIds);
		allRelatedAssets = AssetDAO.getAssetsFromIds(assetQueryFields, serializedItemIds);

		if(!allRelatedAssets.isEmpty()) {
			for(Asset a : allRelatedAssets) {
				assetMap.put(a.Id, a);
			}
		}

		if(!allRelatedProductItems.isEmpty()) {
			for(ProductItem productItem : allRelatedProductItems) {
				productItemMap.put(String.valueOf(productItem.Serialized_Item__c), productItem);
			}

			for(WorkOrderLineItem woli : WOLIs) {
				ProductItem relatedProductItem = productItemMap.get(String.valueOf(woli.AssetId));
				Asset relatedAsset = assetMap.get(woli.AssetId);

				System.debug('----- WOLI: ' + woli.Id);
				System.debug('Movement type: ' + woli.Movement_Type__c);
				System.debug('HU: ' + woli.HU__c);
				System.debug('relatedProductItem: ' + relatedProductItem);
				System.debug('relatedAsset: ' + relatedAsset);

				if(relatedProductItem != null) {
					ProductTransfer newProductTransfer = new ProductTransfer(
						Date__c = Date.today(),
						Label__c = relatedProductItem.Barcode_Label__c,
						Product2Id = relatedProductItem.Product2Id,
						QuantityReceived = 1,
						QuantitySent = 1,
						QuantityUnitOfMeasure = relatedProductItem.QuantityUnitOfMeasure,
						IsReceived = true,
						Serialized_Item__c = relatedProductItem.Serialized_Item__c,
						SourceProductItemId = relatedProductItem.Id,
						Status = 'Completato',
						ExpectedPickupDate = Date.today()
					);

					// Setting DestinationLocationId and SourceLocationId

					if(woli.Movement_Type__c == 'Delivery (+)') {
						newProductTransfer.SourceLocationId = woli.WorkOrder.LocationId;

						if(woli.WorkOrder.Delivery_Type__c == 'Home Visit' || 
						(woli.WorkOrder.Delivery_Type__c == 'Welcome Model' && woli.WorkOrder.Source_Location__c != null)) {
							newProductTransfer.DestinationLocationId = woli.WorkOrder.Source_Location__c;
						}
						else if(woli.WorkOrder.Delivery_Type__c == 'Consignment Stock' || 
						(woli.WorkOrder.Delivery_Type__c == 'Welcome Model' && woli.WorkOrder.Source_Location__c == null)) {
							newProductTransfer.DestinationLocationId = woli.WorkOrder.SAP_Storage_Location__c;
						}
						else if(woli.WorkOrder.Delivery_Type__c == 'Currier') {
							newProductTransfer.DestinationLocationId = woli.StorageLocation__c;
						}
					}
					else if(woli.Movement_Type__c == 'Removal (-)') {
						newProductTransfer.DestinationLocationId = woli.WorkOrder.LocationId;
						newProductTransfer.SourceLocationId = relatedProductItem.LocationId;
					}

					// If WO.AT != null, saving the parameters to get the related PAPH to delete and updating the related Asset

					if(woli.WorkOrder.Account_Treatment__c != null) {
						if(woli.Movement_Type__c == 'Delivery (+)') {
							ATIdsToDeletePAPHsDelivery.add(woli.WorkOrder.Account_Treatment__c);
							serializedItemsToDeletePAPHsDelivery.add(woli.AssetId);
							datesToDeletePAPHsDelivery.add(woli.WorkOrder.EndDate.date());

							// DELIVERY: blanking Asset fields

							if(relatedAsset != null) {
								relatedAsset.Account_Treatment__c = null;
								relatedAsset.AssetServicedById = null;

								assetsToUpdate.add(relatedAsset);
							}
						}
						else if(woli.Movement_Type__c == 'Removal (-)') {
							ATIdsToDeletePAPHsRemoval.add(woli.WorkOrder.Account_Treatment__c);
							serializedItemsToDeletePAPHsRemoval.add(woli.AssetId);
							datesToDeletePAPHsRemoval.add(woli.WorkOrder.EndDate.date());

							// REMOVAL: setting Asset fields

							if(relatedAsset != null) {
								relatedAsset.Account_Treatment__c = woli.WorkOrder.Account_Treatment__c;
								relatedAsset.AssetServicedById = woli.WorkOrder.AccountId;

								assetsToUpdate.add(relatedAsset);
							}
						}
					}

					// Serialized HU: updating the ProductItem

					if(woli.Movement_Type__c == 'Delivery (+)' && woli.HU__c != null) {
						relatedProductItem.HU__c = woli.HU__c;

						productItemsToUpdate.add(relatedProductItem);
					}

					productTransfersToInsert.add(newProductTransfer);
				}
			}

			if(!assetsToUpdate.isEmpty()) {
				System.debug('----- Updating ' + assetsToUpdate.size() + ' Assets...');

				List<Database.SaveResult> results = Database.update(assetsToUpdate);
			}

			if(!productTransfersToInsert.isEmpty()) {
				System.debug('----- Inserting ' + productTransfersToInsert.size() + ' Product Transfers...');

				List<Database.SaveResult> results = Database.insert(productTransfersToInsert);
			}

			if(!productItemsToUpdate.isEmpty()) {
				System.debug('----- Updating ' + productItemsToUpdate.size() + ' Product Items...');

				List<Database.SaveResult> results = Database.update(productItemsToUpdate);
			}

			// Deleting DELIVERY PAPH

			if(!ATIdsToDeletePAPHsDelivery.isEmpty() && !serializedItemsToDeletePAPHsDelivery.isEmpty() && !datesToDeletePAPHsDelivery.isEmpty()) {
				List<Product_Asset_Patient_History__c> deliveryPAPHsToDelete = [SELECT Id FROM Product_Asset_Patient_History__c
																		WHERE Account_Treatment__c IN: ATIdsToDeletePAPHsDelivery
																		AND Serialized_Item__c IN: serializedItemsToDeletePAPHsDelivery
																		AND Date__c IN: datesToDeletePAPHsDelivery
																		AND Type__c = 'Delivery'];

				if(deliveryPAPHsToDelete != null) {
					for(Product_Asset_Patient_History__c paph : deliveryPAPHsToDelete) {
						PAPHsToDelete.add(paph);
					}
				}
			}

			// Deleting REMOVAL PAPH

			if(!ATIdsToDeletePAPHsRemoval.isEmpty() && !serializedItemsToDeletePAPHsRemoval.isEmpty() && !datesToDeletePAPHsRemoval.isEmpty()) {
				List<Product_Asset_Patient_History__c> removalPAPHsToDelete = [SELECT Id FROM Product_Asset_Patient_History__c
																		WHERE Account_Treatment__c IN: ATIdsToDeletePAPHsRemoval
																		AND Serialized_Item__c IN: serializedItemsToDeletePAPHsRemoval
																		AND Date__c IN: datesToDeletePAPHsRemoval
																		AND Type__c = 'Removal'];

				if(PAPHsToDelete != null) {
					for(Product_Asset_Patient_History__c paph : removalPAPHsToDelete) {
						PAPHsToDelete.add(paph);
					}
				}
			}

			if(!PAPHsToDelete.isEmpty()) {
				System.debug('----- Deleting ' + PAPHsToDelete.size() + ' PAPHs...');

				List<Database.DeleteResult> results = Database.delete(PAPHsToDelete);
			}
		}
	}

	// Batch NO HU NO Cylinder DELIVERY

	public static void handleBatchItemsNoHUNoCylinderDelivery(List<WorkOrderLineItem> WOLIs, String deliveryType) {
		System.debug('----- handleBatchItemsNoHUNoCylinderDelivery -----');

		List<String> batchNumbers = new List<String>();
		List<String> productIds = new List<String>();
		List<String> locationIds = new List<String>();
        List<String> sourceLocationIds = new List<String>();
        List<String> sapStorageLocationIds = new List<String>();
		List<ProductItem> patientProductItems = new List<ProductItem>();
        List<ProductItem> vanProductItems = new List<ProductItem>();
        List<ProductItem> hospitalStockProductItems = new List<ProductItem>();

		Map<String, ProductItem> WOLIToProductItemMap = new Map<String, ProductItem>();

		for(WorkOrderLineItem woli : WOLIs) {
			batchNumbers.add(woli.Batch_Number__c);
			productIds.add(woli.Product2Id);
			locationIds.add(woli.WorkOrder.LocationId);
            sourceLocationIds.add(woli.WorkOrder.Source_Location__c);
            sapStorageLocationIds.add(woli.WorkOrder.SAP_Storage_Location__c);
        }
        
        // Getting Patient Product Items

        patientProductItems = [SELECT QuantityOnHand, BatchNumber__c, Product2Id, LocationId, HU__c, RelatedProductItem__c, Offset__c FROM ProductItem 
                            WHERE BatchNumber__c IN: batchNumbers
                            AND Product2Id IN: productIds
                            AND LocationId IN: locationIds
                            AND HU__c = null
                            AND RelatedProductItem__c = null];

        if(deliveryType == 'Home Visit') {

            // Getting VAN Product Items

            vanProductItems = [SELECT QuantityOnHand, BatchNumber__c, Product2Id, LocationId, HU__c, RelatedProductItem__c, Offset__c FROM ProductItem 
                            WHERE BatchNumber__c IN: batchNumbers
                            AND Product2Id IN: productIds
                            AND LocationId IN: sourceLocationIds
                            AND HU__c = null
                            AND RelatedProductItem__c = null];
        }
        else if(deliveryType == 'Consignment Stock') {

            // Getting Hospital Stock Product Items

            hospitalStockProductItems = [SELECT QuantityOnHand, BatchNumber__c, Product2Id, LocationId, HU__c, RelatedProductItem__c, Offset__c FROM ProductItem 
                            WHERE BatchNumber__c IN: batchNumbers
                            AND Product2Id IN: productIds
                            AND LocationId IN: sapStorageLocationIds
                            AND HU__c = null
                            AND RelatedProductItem__c = null];
        }

        // Building ProductItem maps

        if(!patientProductItems.isEmpty()) {

            // Building a (WOLI.BatchNumber + WOLI.Product2Id + WOLI.WO.LocationId) --> ProductItem Map

            for(ProductItem pi : patientProductItems) {
                WOLIToProductItemMap.put(String.valueOf(pi.BatchNumber__c) + String.valueOf(pi.Product2Id) + String.valueOf(pi.LocationId), pi);
            }
        }

        if(!vanProductItems.isEmpty()) {

            // Building a (WOLI.BatchNumber + WOLI.Product2Id + WOLI.WO.SourceLocationId) --> ProductItem Map

            for(ProductItem pi : vanProductItems) {
                WOLIToProductItemMap.put(String.valueOf(pi.BatchNumber__c) + String.valueOf(pi.Product2Id) + String.valueOf(pi.LocationId), pi);
            }
        }

        if(!hospitalStockProductItems.isEmpty()) {

            // Building a (WOLI.BatchNumber + WOLI.Product2Id + WOLI.WO.SourceLocationId) --> ProductItem Map

            for(ProductItem pi : hospitalStockProductItems) {
                WOLIToProductItemMap.put(String.valueOf(pi.BatchNumber__c) + String.valueOf(pi.Product2Id) + String.valueOf(pi.LocationId), pi);
            }
		}
		
		String sourceMethod;

		if(deliveryType == 'Home Visit') {
			sourceMethod = 'handleBatchItemsNoHUNoCylinderDelivery_HomeVisit';
		}
		else if(deliveryType == 'Consignment Stock') {
			sourceMethod = 'handleBatchItemsNoHUNoCylinderDelivery_ConsignmentStock';
		}
		else if(deliveryType == 'Currier') {
			sourceMethod = 'handleBatchItemsNoHUNoCylinderDelivery_Currier';
		}

		handleBatchConsumableItems(WOLIs, WOLIToProductItemMap, sourceMethod, null);
	}

	// Batch HU NO Cylinder DELIVERY

	public static void handleBatchItemsHUNoCylinderDelivery(List<WorkOrderLineItem> WOLIs, String deliveryType) {
		System.debug('----- handleBatchItemsHUNoCylinderDelivery -----');

		List<String> batchNumbers = new List<String>();
		List<String> productIds = new List<String>();
		List<String> locationIds = new List<String>();
        List<String> sourceLocationIds = new List<String>();
        List<String> sapStorageLocationIds = new List<String>();
		List<String> HUs = new List<String>();
		List<ProductItem> patientProductItems = new List<ProductItem>();
        List<ProductItem> vanProductItems = new List<ProductItem>();
        List<ProductItem> hospitalStockProductItems = new List<ProductItem>();

		Map<String, ProductItem> WOLIToProductItemMap = new Map<String, ProductItem>();

		for(WorkOrderLineItem woli : WOLIs) {
			batchNumbers.add(woli.Batch_Number__c);
			productIds.add(woli.Product2Id);
			HUs.add(woli.HU__c);
			locationIds.add(woli.WorkOrder.LocationId);
            sourceLocationIds.add(woli.WorkOrder.Source_Location__c);
            sapStorageLocationIds.add(woli.WorkOrder.SAP_Storage_Location__c);
        }
        
        // Getting Patient Product Items

        patientProductItems = [SELECT QuantityOnHand, BatchNumber__c, Product2Id, LocationId, HU__c, RelatedProductItem__c, Offset__c FROM ProductItem 
                            WHERE BatchNumber__c IN: batchNumbers
                            AND Product2Id IN: productIds
                            AND LocationId IN: locationIds
                            AND HU__c = null
                            AND RelatedProductItem__c = null];

        if(deliveryType == 'Home Visit') {

            // Getting VAN Product Items

            vanProductItems = [SELECT QuantityOnHand, BatchNumber__c, Product2Id, LocationId, HU__c, RelatedProductItem__c, Offset__c FROM ProductItem 
                            WHERE BatchNumber__c IN: batchNumbers
                            AND Product2Id IN: productIds
                            AND LocationId IN: sourceLocationIds
                            AND HU__c IN: HUs
                            AND RelatedProductItem__c = null];
        }
        else if(deliveryType == 'Consignment Stock') {

            // Getting Hospital Stock Product Items

            hospitalStockProductItems = [SELECT QuantityOnHand, BatchNumber__c, Product2Id, LocationId, HU__c, RelatedProductItem__c, Offset__c FROM ProductItem 
                            WHERE BatchNumber__c IN: batchNumbers
                            AND Product2Id IN: productIds
                            AND LocationId IN: sapStorageLocationIds
                            AND HU__c IN: HUs
                            AND RelatedProductItem__c = null];
        }

        // Building Product Item maps
		
		if(!patientProductItems.isEmpty()) {

			// Building a (WOLI.BatchNumber + WOLI.Product2Id + WOLI.WO.LocationId + WOLI.HU) --> ProductItem Map

			for(ProductItem pi : patientProductItems) {
				WOLIToProductItemMap.put(String.valueOf(pi.BatchNumber__c) + String.valueOf(pi.Product2Id) + String.valueOf(pi.LocationId), pi);
			}
		}

		if(!vanProductItems.isEmpty()) {

			// Building a (WOLI.BatchNumber + WOLI.Product2Id + WOLI.WO.SourceLocationId + WOLI.HU) --> ProductItem Map

			for(ProductItem pi : vanProductItems) {
				WOLIToProductItemMap.put(String.valueOf(pi.BatchNumber__c) + String.valueOf(pi.Product2Id) + String.valueOf(pi.LocationId) + String.valueOf(pi.HU__c), pi);
			}
        }
        
        if(!hospitalStockProductItems.isEmpty()) {

            // Building a (WOLI.BatchNumber + WOLI.Product2Id + WOLI.WO.SourceLocationId + WOLI.HU) --> ProductItem Map

			for(ProductItem pi : vanProductItems) {
				WOLIToProductItemMap.put(String.valueOf(pi.BatchNumber__c) + String.valueOf(pi.Product2Id) + String.valueOf(pi.LocationId) + String.valueOf(pi.HU__c), pi);
			}
        }

		String sourceMethod;

		if(deliveryType == 'Home Visit') {
			sourceMethod = 'handleBatchItemsHUNoCylinderDelivery_HomeVisit';
		}
		else if(deliveryType == 'Consignment Stock') {
			sourceMethod = 'handleBatchItemsHUNoCylinderDelivery_ConsignmentStock';
		}

		handleBatchConsumableItems(WOLIs, WOLIToProductItemMap, sourceMethod, null);
	}

	// Batch VAN Cylinder Delivery

	public static void handleBatchVANItemsCylinderDelivery(List<WorkOrderLineItem> WOLIs) {
		System.debug('----- handleBatchVANItemsCylinderDelivery -----');

		List<String> batchNumbers = new List<String>();
		List<String> productIds = new List<String>();
		List<String> HUs = new List<String>();
		List<String> relatedEquipmentKeys = new List<String>();
		List<String> locationIds = new List<String>();
		List<String> sourceLocationIds = new List<String>();
		List<ProductItem> patientProductItems = new List<ProductItem>();
		List<ProductItem> vanProductItems = new List<ProductItem>();
		List<ProductItem> relatedProductItems = new List<ProductItem>();

		Map<String, ProductItem> WOLIToProductItemMap = new Map<String, ProductItem>();
		Map<String, ProductItem> serialNumberToProductItemMap = new Map<String, ProductItem>();

		for(WorkOrderLineItem woli : WOLIs) {
			batchNumbers.add(woli.Batch_Number__c);
			productIds.add(woli.Product2Id);
			HUs.add(woli.HU__c);
			relatedEquipmentKeys.add(woli.Related_Equipment_Key__c);
			locationIds.add(woli.WorkOrder.LocationId);
			sourceLocationIds.add(woli.WorkOrder.Source_Location__c);
		}

		// Getting Patient and VAN Product Items and related Product Items (via Equipment Key)

		patientProductItems = [SELECT QuantityOnHand, BatchNumber__c, Product2Id, LocationId, HU__c, RelatedProductItem__c, Offset__c, RelatedEquipmentKey__c FROM ProductItem 
							   WHERE BatchNumber__c IN: batchNumbers
							   AND Product2Id IN: productIds
							   AND LocationId IN: locationIds
							   AND RelatedEquipmentKey__c IN: relatedEquipmentKeys];

		vanProductItems = [SELECT QuantityOnHand, BatchNumber__c, Product2Id, LocationId, HU__c, RelatedProductItem__c, Offset__c, RelatedEquipmentKey__c FROM ProductItem 
						   WHERE BatchNumber__c IN: batchNumbers
						   AND Product2Id IN: productIds
						   AND LocationId IN: sourceLocationIds
						   AND HU__c IN: HUs
						   AND RelatedEquipmentKey__c IN: relatedEquipmentKeys];

		relatedProductItems = [SELECT Id, SerialNumber FROM ProductItem WHERE SerialNumber IN: relatedEquipmentKeys];
		
		if(!patientProductItems.isEmpty()) {

			// Building a (WOLI.BatchNumber + WOLI.Product2Id + WOLI.WO.LocationId + WOLI.RelatedEquipmentKey__c) --> ProductItem Map

			for(ProductItem pi : patientProductItems) {
				WOLIToProductItemMap.put(
					String.valueOf(pi.BatchNumber__c) + String.valueOf(pi.Product2Id) + String.valueOf(pi.LocationId) + String.valueOf(pi.RelatedEquipmentKey__c), pi
					);
			}
		}

		if(!vanProductItems.isEmpty()) {

			// Building a (WOLI.BatchNumber + WOLI.Product2Id + WOLI.WO.SourceLocationId + WOLI.RelatedEquipmentKey__c + WOLI.HU) --> ProductItem Map

			for(ProductItem pi : vanProductItems) {
				WOLIToProductItemMap.put(
					String.valueOf(pi.BatchNumber__c) + String.valueOf(pi.Product2Id) + String.valueOf(pi.LocationId) + 
					String.valueOf(pi.RelatedEquipmentKey__c) + String.valueOf(pi.HU__c), pi
					);
			}
		}

		if(!relatedProductItems.isEmpty()) {

			// Building a WOLI.Related_Equipment_Key --> Related ProductItem Map

			for(ProductItem pi : relatedProductItems) {
				serialNumberToProductItemMap.put(pi.SerialNumber, pi);
			}
		}

		handleBatchConsumableItems(WOLIs, WOLIToProductItemMap, 'handleBatchVANItemsCylinderDelivery', serialNumberToProductItemMap);
	}

	// Batch VAN Refill Delivery

	public static void handleBatchVANItemsRefillDelivery(List<WorkOrderLineItem> WOLIs) {
		System.debug('----- handleBatchVANItemsRefillDelivery -----');

		List<String> batchNumbers = new List<String>();
		List<String> productIds = new List<String>();
		List<String> HUs = new List<String>();
		List<String> relatedEquipmentKeys = new List<String>();
		List<String> relatedEquipmentKeyTanks = new List<String>();
		List<String> locationIds = new List<String>();
		List<String> sourceLocationIds = new List<String>();
		List<ProductItem> patientProductItems = new List<ProductItem>();
		List<ProductItem> vanProductItems = new List<ProductItem>();
		List<ProductItem> relatedProductItems = new List<ProductItem>();

		Map<String, ProductItem> WOLIToProductItemMap = new Map<String, ProductItem>();
		Map<String, ProductItem> serialNumberToProductItemMap = new Map<String, ProductItem>();

		for(WorkOrderLineItem woli : WOLIs) {
			batchNumbers.add(woli.Batch_Number__c);
			productIds.add(woli.Product2Id);
			HUs.add(woli.HU__c);
			relatedEquipmentKeys.add(woli.Related_Equipment_Key__c);
			relatedEquipmentKeyTanks.add(woli.Equipment_Key_Tank__c);
			locationIds.add(woli.WorkOrder.LocationId);
			sourceLocationIds.add(woli.WorkOrder.Source_Location__c);
		}

		// Getting Patient and VAN Product Items and related Product Items (via Equipment Key)

		patientProductItems = [SELECT QuantityOnHand, BatchNumber__c, Product2Id, LocationId, HU__c, RelatedProductItem__c, Offset__c, RelatedEquipmentKey__c FROM ProductItem 
							   WHERE BatchNumber__c IN: batchNumbers
							   AND Product2Id IN: productIds
							   AND LocationId IN: locationIds
							   AND RelatedEquipmentKey__c IN: relatedEquipmentKeys];

		vanProductItems = [SELECT QuantityOnHand, BatchNumber__c, Product2Id, LocationId, HU__c, RelatedProductItem__c, Offset__c, RelatedEquipmentKey__c FROM ProductItem 
						   WHERE BatchNumber__c IN: batchNumbers
						   AND Product2Id IN: productIds
						   AND LocationId IN: sourceLocationIds
						   AND HU__c IN: HUs
						   AND RelatedEquipmentKey__c IN: relatedEquipmentKeyTanks];

		relatedProductItems = [SELECT Id, SerialNumber FROM ProductItem WHERE SerialNumber IN: relatedEquipmentKeyTanks];
		
		if(!patientProductItems.isEmpty()) {

			// Building a (WOLI.BatchNumber + WOLI.Product2Id + WOLI.WO.LocationId + WOLI.RelatedEquipmentKey__c) --> ProductItem Map

			for(ProductItem pi : patientProductItems) {
				WOLIToProductItemMap.put(
					String.valueOf(pi.BatchNumber__c) + String.valueOf(pi.Product2Id) + String.valueOf(pi.LocationId) + String.valueOf(pi.RelatedEquipmentKey__c), pi
					);
			}
		}

		if(!vanProductItems.isEmpty()) {

			// Building a (WOLI.BatchNumber + WOLI.Product2Id + WOLI.WO.SourceLocationId + WOLI.RelatedEquipmentKey__c + WOLI.HU) --> ProductItem Map

			for(ProductItem pi : vanProductItems) {
				WOLIToProductItemMap.put(
					String.valueOf(pi.BatchNumber__c) + String.valueOf(pi.Product2Id) + String.valueOf(pi.LocationId) + 
					String.valueOf(pi.RelatedEquipmentKey__c) + String.valueOf(pi.HU__c), pi
					);
			}
		}

		if(!relatedProductItems.isEmpty()) {

			// Building a WOLI.Related_Equipment_Key --> Related ProductItem Map

			for(ProductItem pi : relatedProductItems) {
				serialNumberToProductItemMap.put(pi.SerialNumber, pi);
			}
		}

		handleBatchConsumableItems(WOLIs, WOLIToProductItemMap, 'handleBatchVANItemsRefillDelivery', serialNumberToProductItemMap);
	}
    
    // Batch Removal

    public static void handleBatchItemsRemoval(List<WorkOrderLineItem> WOLIs, String deliveryType) {
        System.debug('----- handleBatchItemsRemoval -----');

		List<String> batchNumbers = new List<String>();
		List<String> productIds = new List<String>();
		List<String> locationIds = new List<String>();
        List<String> sourceLocationIds = new List<String>();
        List<String> sapStorageLocationIds = new List<String>();
		List<ProductItem> patientProductItems = new List<ProductItem>();
        List<ProductItem> vanProductItems = new List<ProductItem>();
        List<ProductItem> hospitalStockProductItems = new List<ProductItem>();

		Map<String, ProductItem> WOLIToProductItemMap = new Map<String, ProductItem>();

		for(WorkOrderLineItem woli : WOLIs) {
			batchNumbers.add(woli.Batch_Number__c);
			productIds.add(woli.Product2Id);
			locationIds.add(woli.WorkOrder.LocationId);
            sourceLocationIds.add(woli.WorkOrder.Source_Location__c);
            sapStorageLocationIds.add(woli.WorkOrder.SAP_Storage_Location__c);
		}

		// Getting Patient Product Items

		patientProductItems = [SELECT QuantityOnHand, BatchNumber__c, Product2Id, LocationId, HU__c, RelatedProductItem__c, Offset__c FROM ProductItem 
							   WHERE BatchNumber__c IN: batchNumbers
							   AND Product2Id IN: productIds
							   AND LocationId IN: locationIds
							   AND HU__c = null
                               AND RelatedProductItem__c = null];
                               
        if(deliveryType == 'Home Visit') {

            // Getting VAN Product Items

            vanProductItems = [SELECT QuantityOnHand, BatchNumber__c, Product2Id, LocationId, HU__c, RelatedProductItem__c, Offset__c FROM ProductItem 
                            WHERE BatchNumber__c IN: batchNumbers
                            AND Product2Id IN: productIds
                            AND LocationId IN: sourceLocationIds
                            AND HU__c = null
                            AND RelatedProductItem__c = null];
        }
        else if(deliveryType == 'Consignment Stock') {

            // Getting VAN Product Items

            hospitalStockProductItems = [SELECT QuantityOnHand, BatchNumber__c, Product2Id, LocationId, HU__c, RelatedProductItem__c, Offset__c FROM ProductItem 
                            WHERE BatchNumber__c IN: batchNumbers
                            AND Product2Id IN: productIds
                            AND LocationId IN: sapStorageLocationIds
                            AND HU__c = null
                            AND RelatedProductItem__c = null];
        }
		
		if(!patientProductItems.isEmpty()) {

			// Building a (WOLI.BatchNumber + WOLI.Product2Id + WOLI.WO.LocationId + WOLI.HU) --> ProductItem Map

			for(ProductItem pi : patientProductItems) {
				WOLIToProductItemMap.put(String.valueOf(pi.BatchNumber__c) + String.valueOf(pi.Product2Id) + String.valueOf(pi.LocationId), pi);
			}
		}

		if(!vanProductItems.isEmpty()) {

			// Building a (WOLI.BatchNumber + WOLI.Product2Id + WOLI.WO.SourceLocationId + WOLI.HU) --> ProductItem Map

			for(ProductItem pi : vanProductItems) {
				WOLIToProductItemMap.put(String.valueOf(pi.BatchNumber__c) + String.valueOf(pi.Product2Id) + String.valueOf(pi.LocationId), pi);
			}
        }
        
        if(!hospitalStockProductItems.isEmpty()) {

			// Building a (WOLI.BatchNumber + WOLI.Product2Id + WOLI.WO.SourceLocationId + WOLI.HU) --> ProductItem Map

			for(ProductItem pi : hospitalStockProductItems) {
				WOLIToProductItemMap.put(String.valueOf(pi.BatchNumber__c) + String.valueOf(pi.Product2Id) + String.valueOf(pi.LocationId), pi);
			}
		}

		String sourceMethod;

		if(deliveryType == 'Home Visit') {
			sourceMethod = 'handleBatchItemsRemoval_HomeVisit';
		}
		else if(deliveryType == 'Consignment Stock') {
			sourceMethod = 'handleBatchItemsRemoval_ConsignmentStock';
		}
		else if(deliveryType == 'Currier') {
			sourceMethod = 'handleBatchItemsRemoval_Currier';
		}

		handleBatchConsumableItems(WOLIs, WOLIToProductItemMap, sourceMethod, null);
	}
	
	// Consumable No HU DELIVERY

	public static void handleConsumableItemsNoHUDelivery(List<WorkOrderLineItem> WOLIs, String deliveryType) {
		System.debug('----- handleConsumableItemsNoHUDelivery -----');

		List<String> productIds = new List<String>();
		List<String> locationIds = new List<String>();
        List<String> sourceLocationIds = new List<String>();
        List<String> sapStorageLocationIds = new List<String>();
		List<ProductItem> patientProductItems = new List<ProductItem>();
        List<ProductItem> vanProductItems = new List<ProductItem>();
        List<ProductItem> hospitalStockProductItems = new List<ProductItem>();

		Map<String, ProductItem> WOLIToProductItemMap = new Map<String, ProductItem>();

		for(WorkOrderLineItem woli : WOLIs) {
			productIds.add(woli.Product2Id);
			locationIds.add(woli.WorkOrder.LocationId);
            sourceLocationIds.add(woli.WorkOrder.Source_Location__c);
            sapStorageLocationIds.add(woli.WorkOrder.SAP_Storage_Location__c);
        }
        
        // Getting Patient Product Items

        patientProductItems = [SELECT QuantityOnHand, BatchNumber__c, Product2Id, LocationId, HU__c, RelatedProductItem__c, Offset__c FROM ProductItem 
                            WHERE BatchNumber__c = null
                            AND Product2Id IN: productIds
                            AND LocationId IN: locationIds
                            AND HU__c = null];

        if(deliveryType == 'Home Visit') {

            // Getting VAN Product Items

            vanProductItems = [SELECT QuantityOnHand, BatchNumber__c, Product2Id, LocationId, HU__c, RelatedProductItem__c, Offset__c FROM ProductItem 
                            WHERE BatchNumber__c = null
                            AND Product2Id IN: productIds
                            AND LocationId IN: sourceLocationIds
                            AND HU__c = null];
        }
        else if(deliveryType == 'Consignment Stock') {

            // Getting Hospital Stock Product Items

            hospitalStockProductItems = [SELECT QuantityOnHand, BatchNumber__c, Product2Id, LocationId, HU__c, RelatedProductItem__c, Offset__c FROM ProductItem 
                            WHERE BatchNumber__c = null
                            AND Product2Id IN: productIds
                            AND LocationId IN: sapStorageLocationIds
                            AND HU__c = null];
        }

        // Building ProductItem maps

        if(!patientProductItems.isEmpty()) {

            // Building a (WOLI.BatchNumber + WOLI.Product2Id + WOLI.WO.LocationId) --> ProductItem Map

            for(ProductItem pi : patientProductItems) {
                WOLIToProductItemMap.put(String.valueOf(pi.Product2Id) + String.valueOf(pi.LocationId), pi);
            }
        }

        if(!vanProductItems.isEmpty()) {

            // Building a (WOLI.BatchNumber + WOLI.Product2Id + WOLI.WO.SourceLocationId) --> ProductItem Map

            for(ProductItem pi : vanProductItems) {
                WOLIToProductItemMap.put(String.valueOf(pi.Product2Id) + String.valueOf(pi.LocationId), pi);
            }
        }

        if(!hospitalStockProductItems.isEmpty()) {

            // Building a (WOLI.BatchNumber + WOLI.Product2Id + WOLI.WO.SourceLocationId) --> ProductItem Map

            for(ProductItem pi : hospitalStockProductItems) {
                WOLIToProductItemMap.put(String.valueOf(pi.Product2Id) + String.valueOf(pi.LocationId), pi);
            }
        }

		String sourceMethod;

		if(deliveryType == 'Home Visit') {
			sourceMethod = 'handleConsumableItemsNoHUDelivery_HomeVisit';
		}
		else if(deliveryType == 'Consignment Stock') {
			sourceMethod = 'handleConsumableItemsNoHUDelivery_ConsignmentStock';
		}
		else if(deliveryType == 'Currier') {
			sourceMethod = 'handleConsumableItemsNoHUDelivery_Currier';
		}

		handleBatchConsumableItems(WOLIs, WOLIToProductItemMap, sourceMethod, null);
	}

	// Consumable HU DELIVERY

	public static void handleConsumableItemsHUDelivery(List<WorkOrderLineItem> WOLIs, String deliveryType) {
		System.debug('----- handleConsumableItemsHUDelivery -----');

		List<String> productIds = new List<String>();
		List<String> locationIds = new List<String>();
        List<String> sourceLocationIds = new List<String>();
		List<String> sapStorageLocationIds = new List<String>();
		List<String> HUs = new List<String>();
		List<ProductItem> patientProductItems = new List<ProductItem>();
        List<ProductItem> vanProductItems = new List<ProductItem>();
        List<ProductItem> hospitalStockProductItems = new List<ProductItem>();

		Map<String, ProductItem> WOLIToProductItemMap = new Map<String, ProductItem>();

		for(WorkOrderLineItem woli : WOLIs) {
			productIds.add(woli.Product2Id);
			locationIds.add(woli.WorkOrder.LocationId);
			HUs.add(woli.HU__c);
            sourceLocationIds.add(woli.WorkOrder.Source_Location__c);
            sapStorageLocationIds.add(woli.WorkOrder.SAP_Storage_Location__c);
        }
        
        // Getting Patient Product Items

        patientProductItems = [SELECT QuantityOnHand, BatchNumber__c, Product2Id, LocationId, HU__c, RelatedProductItem__c, Offset__c FROM ProductItem 
                            WHERE BatchNumber__c = null
                            AND Product2Id IN: productIds
                            AND LocationId IN: locationIds
                            AND HU__c = null];

        if(deliveryType == 'Home Visit') {

            // Getting VAN Product Items

            vanProductItems = [SELECT QuantityOnHand, BatchNumber__c, Product2Id, LocationId, HU__c, RelatedProductItem__c, Offset__c FROM ProductItem 
                            WHERE BatchNumber__c = null
                            AND Product2Id IN: productIds
                            AND LocationId IN: sourceLocationIds
                            AND HU__c IN: HUs];
        }
        else if(deliveryType == 'Consignment Stock') {

            // Getting Hospital Stock Product Items

            hospitalStockProductItems = [SELECT QuantityOnHand, BatchNumber__c, Product2Id, LocationId, HU__c, RelatedProductItem__c, Offset__c FROM ProductItem 
                            WHERE BatchNumber__c = null
                            AND Product2Id IN: productIds
                            AND LocationId IN: sapStorageLocationIds
                            AND HU__c IN: HUs];
        }

        // Building ProductItem maps

        if(!patientProductItems.isEmpty()) {

            // Building a (WOLI.BatchNumber + WOLI.Product2Id + WOLI.WO.LocationId) --> ProductItem Map

            for(ProductItem pi : patientProductItems) {
                WOLIToProductItemMap.put(String.valueOf(pi.Product2Id) + String.valueOf(pi.LocationId), pi);
            }
        }

        if(!vanProductItems.isEmpty()) {

            // Building a (WOLI.BatchNumber + WOLI.Product2Id + WOLI.WO.SourceLocationId + WOLI.HU) --> ProductItem Map

            for(ProductItem pi : vanProductItems) {
                WOLIToProductItemMap.put(String.valueOf(pi.Product2Id) + String.valueOf(pi.LocationId) + String.valueOf(pi.HU__c), pi);
            }
        }

        if(!hospitalStockProductItems.isEmpty()) {

            // Building a (WOLI.BatchNumber + WOLI.Product2Id + WOLI.WO.SAPStorageLocation + WOLI.HU) --> ProductItem Map

            for(ProductItem pi : hospitalStockProductItems) {
                WOLIToProductItemMap.put(String.valueOf(pi.Product2Id) + String.valueOf(pi.LocationId) + String.valueOf(pi.HU__c), pi);
            }
        }

		String sourceMethod;

		if(deliveryType == 'Home Visit') {
			sourceMethod = 'handleConsumableItemsHUDelivery_HomeVisit';
		}
		else if(deliveryType == 'Consignment Stock') {
			sourceMethod = 'handleConsumableItemsHUDelivery_ConsignmentStock';
		}

		handleBatchConsumableItems(WOLIs, WOLIToProductItemMap, sourceMethod, null);
	}

	// Consumable Removal

    public static void handleConsumableItemsRemoval(List<WorkOrderLineItem> WOLIs, String deliveryType) {
        System.debug('----- handleConsumableItemsRemoval -----');

		List<String> productIds = new List<String>();
		List<String> locationIds = new List<String>();
        List<String> sourceLocationIds = new List<String>();
        List<String> sapStorageLocationIds = new List<String>();
		List<ProductItem> patientProductItems = new List<ProductItem>();
        List<ProductItem> vanProductItems = new List<ProductItem>();
        List<ProductItem> hospitalStockProductItems = new List<ProductItem>();

		Map<String, ProductItem> WOLIToProductItemMap = new Map<String, ProductItem>();

		for(WorkOrderLineItem woli : WOLIs) {
			productIds.add(woli.Product2Id);
			locationIds.add(woli.WorkOrder.LocationId);
            sourceLocationIds.add(woli.WorkOrder.Source_Location__c);
            sapStorageLocationIds.add(woli.WorkOrder.SAP_Storage_Location__c);
		}

		// Getting Patient Product Items

		patientProductItems = [SELECT QuantityOnHand, BatchNumber__c, Product2Id, LocationId, HU__c, RelatedProductItem__c, Offset__c FROM ProductItem 
							   WHERE BatchNumber__c = null
							   AND Product2Id IN: productIds
							   AND LocationId IN: locationIds
							   AND HU__c = null];
                               
        if(deliveryType == 'Home Visit') {

            // Getting VAN Product Items

            vanProductItems = [SELECT QuantityOnHand, BatchNumber__c, Product2Id, LocationId, HU__c, RelatedProductItem__c, Offset__c FROM ProductItem 
                            WHERE BatchNumber__c = null
                            AND Product2Id IN: productIds
                            AND LocationId IN: sourceLocationIds
                            AND HU__c = null];
        }
        else if(deliveryType == 'Consignment Stock') {

            // Getting VAN Product Items

            hospitalStockProductItems = [SELECT QuantityOnHand, BatchNumber__c, Product2Id, LocationId, HU__c, RelatedProductItem__c, Offset__c FROM ProductItem 
                            WHERE BatchNumber__c = null	
                            AND Product2Id IN: productIds
                            AND LocationId IN: sapStorageLocationIds
                            AND HU__c = null];
        }
		
		if(!patientProductItems.isEmpty()) {

			// Building a (WOLI.BatchNumber + WOLI.Product2Id + WOLI.WO.LocationId + WOLI.HU) --> ProductItem Map

			for(ProductItem pi : patientProductItems) {
				WOLIToProductItemMap.put(String.valueOf(pi.Product2Id) + String.valueOf(pi.LocationId), pi);
			}
		}

		if(!vanProductItems.isEmpty()) {

			// Building a (WOLI.BatchNumber + WOLI.Product2Id + WOLI.WO.SourceLocationId + WOLI.HU) --> ProductItem Map

			for(ProductItem pi : vanProductItems) {
				WOLIToProductItemMap.put(String.valueOf(pi.Product2Id) + String.valueOf(pi.LocationId), pi);
			}
        }
        
        if(!hospitalStockProductItems.isEmpty()) {

			// Building a (WOLI.BatchNumber + WOLI.Product2Id + WOLI.WO.SourceLocationId + WOLI.HU) --> ProductItem Map

			for(ProductItem pi : hospitalStockProductItems) {
				WOLIToProductItemMap.put(String.valueOf(pi.Product2Id) + String.valueOf(pi.LocationId), pi);
			}
		}

		String sourceMethod;

		if(deliveryType == 'Home Visit') {
			sourceMethod = 'handleConsumableItemsRemoval_HomeVisit';
		}
		else if(deliveryType == 'Consignment Stock') {
			sourceMethod = 'handleConsumableItemsRemoval_ConsignmentStock';
		}
		else if(deliveryType == 'Currier') {
			sourceMethod = 'handleConsumableItemsRemoval_Currier';
		}

		handleBatchConsumableItems(WOLIs, WOLIToProductItemMap, sourceMethod, null);
	}

	// Common behavior for batch Items (for REMOVAL the name of the variables are swapped to simplify the method)

	public static void handleBatchConsumableItems(List<WorkOrderLineItem> WOLIs, Map<String, ProductItem> WOLIToProductItemMap, String sourceMethod, 
	Map<String, ProductItem> relatedProductItemMap) {
		System.debug('----- handleBatchConsumableItems -----');

		List<String> productIdsToDeletePAPHsDelivery = new List<String>();
		List<String> batchNumbersToDeletePAPHsDelivery = new List<String>();
		List<String> ATIdsToDeletePAPHsDelivery = new List<String>();
        List<Date> datesToDeletePAPHsDelivery = new List<Date>();
        List<String> productIdsToDeletePAPHsRemoval = new List<String>();
		List<String> batchNumbersToDeletePAPHsRemoval = new List<String>();
		List<String> ATIdsToDeletePAPHsRemoval = new List<String>();
		List<Date> datesToDeletePAPHsRemoval = new List<Date>();
		List<String> productIdsToDeletePAPHsDeliveryConsumable = new List<String>();
		List<String> ATIdsToDeletePAPHsDeliveryConsumable = new List<String>();
		List<Date> datesToDeletePAPHsDeliveryConsumable = new List<Date>();
		List<String> productIdsToDeletePAPHsRemovalConsumable = new List<String>();
		List<String> ATIdsToDeletePAPHsRemovalConsumable = new List<String>();
		List<Date> datesToDeletePAPHsRemovalConsumable = new List<Date>();
		List<ProductItem> productItemsToDelete = new List<ProductItem>();
		List<ProductItem> productItemsToUpdate = new List<ProductItem>();
		List<ProductItem> productItemsToInsert = new List<ProductItem>();
		List<String> productItemsToUpdateIds = new List<String>();
		List<Product_Asset_Patient_History__c> PAPHsToDelete = new List<Product_Asset_Patient_History__c>();

		Map<String, ProductItem> newProductItemMap = new Map<String, ProductItem>();

		for(WorkOrderLineItem woli : WOLIs) {
			ProductItem relatedPatientProductItem;
			ProductItem relatedVanProductItem;

            if(sourceMethod == 'handleBatchItemsNoHUNoCylinderDelivery_HomeVisit' || sourceMethod == 'handleBatchItemsNoHUNoCylinderDelivery_ConsignmentStock' ||
            sourceMethod == 'handleBatchItemsNoHUNoCylinderDelivery_Currier') {
				relatedPatientProductItem = WOLIToProductItemMap.get(
					String.valueOf(woli.Batch_Number__c) + String.valueOf(woli.Product2Id) + String.valueOf(woli.WorkOrder.LocationId)
				);

                if(sourceMethod == 'handleBatchItemsNoHUNoCylinderDelivery_HomeVisit') {
                    relatedVanProductItem = WOLIToProductItemMap.get(
                        String.valueOf(woli.Batch_Number__c) + String.valueOf(woli.Product2Id) + String.valueOf(woli.WorkOrder.Source_Location__c)
                    );
				}
				else if(sourceMethod == 'handleBatchItemsNoHUNoCylinderDelivery_ConsignmentStock') {
                    relatedVanProductItem = WOLIToProductItemMap.get(
                        String.valueOf(woli.Batch_Number__c) + String.valueOf(woli.Product2Id) + String.valueOf(woli.WorkOrder.SAP_Storage_Location__c)
                    );
                }
			}
			else if(sourceMethod == 'handleBatchItemsHUNoCylinderDelivery_HomeVisit' || sourceMethod == 'handleBatchItemsHUNoCylinderDelivery_ConsignmentStock') {
				relatedPatientProductItem = WOLIToProductItemMap.get(
					String.valueOf(woli.Batch_Number__c) + String.valueOf(woli.Product2Id) + String.valueOf(woli.WorkOrder.LocationId)
				);

				if(sourceMethod == 'handleBatchItemsHUNoCylinderDelivery_HomeVisit') {
					relatedVanProductItem = WOLIToProductItemMap.get(
						String.valueOf(woli.Batch_Number__c) + String.valueOf(woli.Product2Id) + String.valueOf(woli.WorkOrder.Source_Location__c) + 
						String.valueOf(woli.HU__c)
					);
				}
				else if(sourceMethod == 'handleBatchItemsHUNoCylinderDelivery_ConsignmentStock') {
					relatedVanProductItem = WOLIToProductItemMap.get(
						String.valueOf(woli.Batch_Number__c) + String.valueOf(woli.Product2Id) + String.valueOf(woli.WorkOrder.SAP_Storage_Location__c) + 
						String.valueOf(woli.HU__c)
					);
				}
			}
			else if(sourceMethod == 'handleBatchVANItemsCylinderDelivery') {
				relatedPatientProductItem = WOLIToProductItemMap.get(
					String.valueOf(woli.Batch_Number__c) + String.valueOf(woli.Product2Id) + String.valueOf(woli.WorkOrder.LocationId) + 
					String.valueOf(woli.Related_Equipment_Key__c)
				);

				relatedVanProductItem = WOLIToProductItemMap.get(
					String.valueOf(woli.Batch_Number__c) + String.valueOf(woli.Product2Id) + String.valueOf(woli.WorkOrder.Source_Location__c) + 
					String.valueOf(woli.Related_Equipment_Key__c) + String.valueOf(woli.HU__c)
				);
			}
			else if(sourceMethod == 'handleBatchVANItemsRefillDelivery') {
				relatedPatientProductItem = WOLIToProductItemMap.get(
					String.valueOf(woli.Batch_Number__c) + String.valueOf(woli.Product2Id) + String.valueOf(woli.WorkOrder.LocationId) + 
					String.valueOf(woli.Related_Equipment_Key__c)
				);

				relatedVanProductItem = WOLIToProductItemMap.get(
					String.valueOf(woli.Batch_Number__c) + String.valueOf(woli.Product2Id) + String.valueOf(woli.WorkOrder.Source_Location__c) + 
					String.valueOf(woli.Equipment_Key_Tank__c) + String.valueOf(woli.HU__c)
				);
            }
            else if(sourceMethod == 'handleBatchItemsRemoval_HomeVisit' || sourceMethod == 'handleBatchItemsRemoval_ConsignmentStock' ||
            sourceMethod == 'handleBatchItemsRemoval_Currier') {
                // This is the PatientPI anyway (swapped variables to quickly swap behavior)
                relatedVanProductItem = WOLIToProductItemMap.get(
					String.valueOf(woli.Batch_Number__c) + String.valueOf(woli.Product2Id) + String.valueOf(woli.WorkOrder.LocationId)
				);

                if(sourceMethod == 'handleBatchItemsRemoval_HomeVisit') {
                    // this is the VAN anyway
                    relatedPatientProductItem = WOLIToProductItemMap.get(
                        String.valueOf(woli.Batch_Number__c) + String.valueOf(woli.Product2Id) + String.valueOf(woli.WorkOrder.Source_Location__c)
                    );
                }
                else if(sourceMethod == 'handleBatchItemsRemoval_ConsignmentStock') {
                    // this is the VAN anyway
                    relatedPatientProductItem = WOLIToProductItemMap.get(
                        String.valueOf(woli.Batch_Number__c) + String.valueOf(woli.Product2Id) + String.valueOf(woli.WorkOrder.SAP_Storage_Location__c)
                    );
                }
			}
			else if(sourceMethod == 'handleConsumableItemsNoHUDelivery_HomeVisit' || sourceMethod == 'handleConsumableItemsNoHUDelivery_ConsignmentStock' ||
			sourceMethod == 'handleConsumableItemsNoHUDelivery_Currier') {
				relatedPatientProductItem = WOLIToProductItemMap.get(
					String.valueOf(woli.Product2Id) + String.valueOf(woli.WorkOrder.LocationId)
				);

				if(sourceMethod == 'handleConsumableItemsNoHUDelivery_HomeVisit') {
					relatedVanProductItem = WOLIToProductItemMap.get(
						String.valueOf(woli.Product2Id) + String.valueOf(woli.WorkOrder.Source_Location__c)
					);
				}
				else if(sourceMethod == 'handleConsumableItemsNoHUDelivery_ConsignmentStock') {
					relatedVanProductItem = WOLIToProductItemMap.get(
						String.valueOf(woli.Product2Id) + String.valueOf(woli.WorkOrder.SAP_Storage_Location__c)
					);
				}
			}
			else if(sourceMethod == 'handleConsumableItemsHUDelivery_HomeVisit' || sourceMethod == 'handleConsumableItemsHUDelivery_ConsignmentStock') {
				relatedPatientProductItem = WOLIToProductItemMap.get(
					String.valueOf(woli.Product2Id) + String.valueOf(woli.WorkOrder.LocationId)
				);

				if(sourceMethod == 'handleConsumableItemsHUDelivery_HomeVisit') {
					relatedVanProductItem = WOLIToProductItemMap.get(
						String.valueOf(woli.Product2Id) + String.valueOf(woli.WorkOrder.Source_Location__c) + String.valueOf(woli.HU__c)
					);
				}
				else if(sourceMethod == 'handleConsumableItemsHUDelivery_ConsignmentStock') {
					relatedVanProductItem = WOLIToProductItemMap.get(
						String.valueOf(woli.Product2Id) + String.valueOf(woli.WorkOrder.SAP_Storage_Location__c) + String.valueOf(woli.HU__c)
					);
				}
			}
			else if(sourceMethod == 'handleConsumableItemsRemoval_HomeVisit' || sourceMethod == 'handleConsumableItemsRemoval_ConsignmentStock' || 
				sourceMethod == 'handleConsumableItemsRemoval_Currier') {
                // This is the PatientPI anyway (swapped variables to quickly swap behavior)
                relatedVanProductItem = WOLIToProductItemMap.get(
					String.valueOf(woli.Product2Id) + String.valueOf(woli.WorkOrder.LocationId)
				);

                if(sourceMethod == 'handleConsumableItemsRemoval_HomeVisit') {
                    // this is the VAN anyway
                    relatedPatientProductItem = WOLIToProductItemMap.get(
                        String.valueOf(woli.Product2Id) + String.valueOf(woli.WorkOrder.Source_Location__c)
                    );
                }
                else if(sourceMethod == 'handleBatchConsumableRemoval_ConsignmentStock') {
                    // this is the VAN anyway
                    relatedPatientProductItem = WOLIToProductItemMap.get(
                        String.valueOf(woli.Product2Id) + String.valueOf(woli.WorkOrder.SAP_Storage_Location__c)
                    );
                }
			}

            System.debug('sourceMethod: ' + sourceMethod);
			System.debug('----- WOLI: ' + woli.Id);
			System.debug('HU: ' + woli.HU__c);
			System.debug('Related_Equipment_Key: ' + woli.Related_Equipment_Key__c);
			System.debug('relatedPatientProductItem: ' + relatedPatientProductItem);
			System.debug('relatedVanProductItem: ' + relatedVanProductItem);
			System.debug('relatedProductItemMap: ' + relatedProductItemMap);

			// Deleting / Updating quantity of the related Product Item

			if(relatedPatientProductItem != null) {
				if(relatedPatientProductItem.QuantityOnHand - woli.QuantityDelivered__c <= 0) {
					System.debug('Quantity <= 0: deleting the Patient PI');

					if(!productItemsToDelete.contains(relatedPatientProductItem)) {
						productItemsToDelete.add(relatedPatientProductItem);
					}
				}
				else {
					if(!productItemsToUpdateIds.contains(relatedPatientProductItem.Id)) {
						System.debug('Updating relatedPatientProductItem Quantity to ' + (relatedPatientProductItem.QuantityOnHand - woli.QuantityDelivered__c) + '...');

						relatedPatientProductItem.QuantityOnHand = relatedPatientProductItem.QuantityOnHand - woli.QuantityDelivered__c;

						productItemsToUpdate.add(relatedPatientProductItem);
						productItemsToUpdateIds.add(relatedPatientProductItem.Id);
					}
					else {
						System.debug('relatedPatientProductItem.Id had already been updated! Updating its quantity...');

						Integer index = productItemsToUpdateIds.indexOf(relatedPatientProductItem.Id);

						if(index != null && index != -1) {
							if(productItemsToUpdate[index] != null && productItemsToUpdate[index].Id == productItemsToUpdateIds[index]) {
								System.debug('Subtracting quantity to already updated Patient PI...');
								System.debug('Old quantity: ' + productItemsToUpdate[index].QuantityOnHand);
								System.debug('Subtracting: ' + woli.QuantityDelivered__c);
									
								productItemsToUpdate[index].QuantityOnHand = productItemsToUpdate[index].QuantityOnHand - woli.QuantityDelivered__c;

								System.debug('New Quantity for Patient ProductItem ' + productItemsToUpdate[index].Id + ': ' + productItemsToUpdate[index].QuantityOnHand);

								if(productItemsToUpdate[index].QuantityOnHand <= 0) {
									if(!productItemsToDelete.contains(productItemsToUpdate[index])) {
										productItemsToDelete.add(productItemsToUpdate[index]);
									}
								}
							}
						}
					}
				}
			}

			// Updating quantity of the related VAN Product Item OR creating a new one if it's not present yet

			if(relatedVanProductItem != null) {
				if(!productItemsToUpdateIds.contains(relatedVanProductItem.Id)) {
					System.debug('relatedVanProductItem found, updating its quantity to ' + (relatedVanProductItem.QuantityOnHand + woli.QuantityDelivered__c) + '...');

					relatedVanProductItem.QuantityOnHand = relatedVanProductItem.QuantityOnHand + woli.QuantityDelivered__c;

					productItemsToUpdate.add(relatedVanProductItem);
					productItemsToUpdateIds.add(relatedVanProductItem.Id);
				}
				else {
					System.debug('relatedVanProductItem.Id had already been updated! Updating its quantity...');

					Integer index = productItemsToUpdateIds.indexOf(relatedVanProductItem.Id);

					if(index != null && index != -1) {
						if(productItemsToUpdate[index] != null && productItemsToUpdate[index].Id == productItemsToUpdateIds[index]) {
							System.debug('Adding quantity to already updated VAN PI...');
							System.debug('Old quantity: ' + productItemsToUpdate[index].QuantityOnHand);
							System.debug('Adding: ' + woli.QuantityDelivered__c);
								
							productItemsToUpdate[index].QuantityOnHand = productItemsToUpdate[index].QuantityOnHand + woli.QuantityDelivered__c;

							System.debug('New Quantity for VAN ProductItem ' + productItemsToUpdate[index].Id + ': ' + productItemsToUpdate[index].QuantityOnHand);
						}
					}
				}
			}
			else {
				if(sourceMethod != 'handleBatchItemsNoHUNoCylinderDelivery_Currier' && sourceMethod != 'handleConsumableItemsNoHUDelivery_Currier') {
					System.debug('relatedVanProductItem NOT found, creating a new one...');

					ProductItem newVanProductItem = new ProductItem(
						BatchNumber__c = woli.Batch_Number__c,
						Expired_Date__c = woli.ExpiryDate__c,
						SerialNumber = woli.Batch_Number__c + '_' + woli.Product_Code__c,
						LocationId = woli.WorkOrder.Source_Location__c,
						Product2Id = woli.Product2Id,
						QuantityOnHand = woli.QuantityDelivered__c,
						QuantityUnitOfMeasure = woli.Product2.Unit_of_measure__c
					);

					if(relatedPatientProductItem != null) {
						newVanProductItem.Offset__c = relatedPatientProductItem.Offset__c;
					}

					if(sourceMethod == 'handleBatchItemsNoHUNoCylinderDelivery_HomeVisit' || sourceMethod == 'handleBatchItemsHUNoCylinderDelivery_HomeVisit' ||
					sourceMethod == 'handleBatchVANItemsCylinderDelivery' || sourceMethod == 'handleBatchVANItemsRefillDelivery' ||
					sourceMethod == 'handleBatchItemsRemoval_HomeVisit' || sourceMethod == 'handleBatchItemsNoHUNoCylinderDelivery_ConsignmentStock' ||
					sourceMethod == 'handleBatchItemsHUNoCylinderDelivery_ConsignmentStock' || sourceMethod == 'handleBatchItemsRemoval_ConsignmentStock' ||
					sourceMethod == 'handleBatchItemsRemoval_Currier') {
						newVanProductItem.Offset__c = woli.Offset__c;
					}
					
					// No BatchNumber or SerialNumber if the WOLI is coming from a Consumable

					if(sourceMethod == 'handleConsumableItemsNoHUDelivery_HomeVisit' || sourceMethod == 'handleConsumableItemsNoHUDelivery_ConsignmentStock' || 
					sourceMethod == 'handleConsumableItemsHUDelivery_HomeVisit' || sourceMethod == 'handleConsumableItemsHUDelivery_ConsignmentStock' || 
					sourceMethod == 'handleConsumableItemsRemoval_HomeVisit' || sourceMethod == 'handleConsumableItemsRemoval_ConsignmentStock') {
						newVanProductItem.BatchNumber__c = null;

						if(sourceMethod != 'handleConsumableItemsHUDelivery_HomeVisit' && sourceMethod != 'handleConsumableItemsHUDelivery_ConsignmentStock') {
							newVanProductItem.SerialNumber = null;
						}
						else {
							newVanProductItem.SerialNumber = woli.Product_Code__c + '_' + woli.HU__c;
							newVanProductItem.HU__c = woli.HU__c;
						}
					}

					// Use SAP_Storage_Location if coming from a Consignment Stock method
					
					if(sourceMethod == 'handleBatchItemsNoHUNoCylinderDelivery_ConsignmentStock' ||
					sourceMethod == 'handleBatchItemsHUNoCylinderDelivery_ConsignmentStock' ||
					sourceMethod == 'handleConsumableItemsNoHUDelivery_ConsignmentStock' ||
					sourceMethod == 'handleConsumableItemsHUDelivery_ConsignmentStock') {
						newVanProductItem.LocationId = woli.WorkOrder.SAP_Storage_Location__c;
					}

					if(sourceMethod == 'handleBatchItemsRemoval_HomeVisit' || 
					sourceMethod == 'handleBatchItemsRemoval_ConsignmentStock' || sourceMethod == 'handleBatchItemsRemoval_Currier' ||
					sourceMethod == 'handleConsumableItemsRemoval_HomeVisit' || sourceMethod == 'handleConsumableItemsRemoval_ConsignmentStock' || 
					sourceMethod == 'handleConsumableItemsRemoval_Currier') {
						newVanProductItem.LocationId = woli.WorkOrder.LocationId;
					}

					// If HU is present, then append it to the SerialNumber and set the field. If there's a Cylinder, same thing + set RelatedProductItem

					if(sourceMethod == 'handleBatchItemsHUNoCylinderDelivery_HomeVisit' || sourceMethod == 'handleBatchItemsHUNoCylinderDelivery_ConsignmentStock') {
						newVanProductItem.SerialNumber = newVanProductItem.SerialNumber + '_' + woli.HU__c;
						newVanProductItem.HU__c = woli.HU__c;
					}
					else if(sourceMethod == 'handleBatchVANItemsCylinderDelivery') {
						newVanProductItem.SerialNumber = newVanProductItem.SerialNumber + '_' + woli.Related_Equipment_Key__c;
						newVanProductItem.HU__c = woli.HU__c;

						if(relatedProductItemMap != null) {
							ProductItem relatedEquipment = relatedProductItemMap.get(woli.Related_Equipment_Key__c);

							System.debug('relatedEquipment: ' + relatedEquipment);

							if(relatedEquipment != null) {
								newVanProductItem.RelatedProductItem__c = relatedEquipment.Id;
							}
						}
					}
					else if(sourceMethod == 'handleBatchVANItemsRefillDelivery') {
						newVanProductItem.SerialNumber = newVanProductItem.SerialNumber + '_' + woli.Equipment_Key_Tank__c;
						newVanProductItem.HU__c = woli.HU__c;

						if(relatedProductItemMap != null) {
							ProductItem relatedEquipment = relatedProductItemMap.get(woli.Equipment_Key_Tank__c);

							System.debug('relatedEquipment: ' + relatedEquipment);

							if(relatedEquipment != null) {
								newVanProductItem.RelatedProductItem__c = relatedEquipment.Id;
							}
						}
					}

					System.debug('newVanProductItem: ' + newVanProductItem);
					System.debug('newVanProductItem.SerialNumber: ' + newVanProductItem.SerialNumber);
					System.debug('newVanProductItem.Product2Id: ' + newVanProductItem.Product2Id);

					String stringToCheck;

					if(newVanProductItem.SerialNumber == null) {
						System.debug('SerialNumber null, checking with Product2Id...');

						stringToCheck = newVanProductItem.Product2Id;
					}
					else {
						System.debug('SerialNumber NOT null, checking with SerialNumber...');

						stringToCheck = newVanProductItem.SerialNumber;
					}

					if(!newProductItemMap.containsKey(stringToCheck)) {
						System.debug('SerialNumber / Product2Id NOT already created! Putting it into the list');

						productItemsToInsert.add(newVanProductItem);

						if(newVanProductItem.SerialNumber == null) {
							newProductItemMap.put(newVanProductItem.Product2Id, newVanProductItem);
						}
						else {
							newProductItemMap.put(newVanProductItem.SerialNumber, newVanProductItem);
						}
					}
					else {
						System.debug('SerialNumber/Product2Id NOT already created!');

						ProductItem toUpdateQuantity = newProductItemMap.get(stringToCheck);

						if(toUpdateQuantity != null) {
							Integer index = productItemsToInsert.indexOf(toUpdateQuantity);

							if(index != null && index != -1) {
								if(productItemsToInsert[index] != null) {
									System.debug('SerialNumber/Product2Id already present to be inserted! Updating its quantity');
									System.debug('Old quantity: ' + productItemsToInsert[index].QuantityOnHand);
									
									productItemsToInsert[index].QuantityOnHand = productItemsToInsert[index].QuantityOnHand + woli.QuantityDelivered__c;

									System.debug('New quantity: ' + productItemsToInsert[index].QuantityOnHand);
								}
							}
						}
					}	
				}
			}

			// If WO.AT != null, saving the parameters to get the related PAPH to delete and updating the related Asset

			if(woli.WorkOrder.Account_Treatment__c != null) {
				if(woli.Movement_Type__c == 'Delivery (+)') {
					if(sourceMethod == 'handleConsumableItemsNoHUDelivery_HomeVisit' || sourceMethod == 'handleConsumableItemsNoHUDelivery_ConsignmentStock' ||
					sourceMethod == 'handleConsumableItemsNoHUDelivery_Currier') {
						ATIdsToDeletePAPHsDeliveryConsumable.add(woli.WorkOrder.Account_Treatment__c);
						datesToDeletePAPHsDeliveryConsumable.add(woli.WorkOrder.EndDate.date());
						productIdsToDeletePAPHsDeliveryConsumable.add(woli.Product2Id);
					}
					else {
						ATIdsToDeletePAPHsDelivery.add(woli.WorkOrder.Account_Treatment__c);
						batchNumbersToDeletePAPHsDelivery.add(woli.Batch_Number__c);
						datesToDeletePAPHsDelivery.add(woli.WorkOrder.EndDate.date());
						productIdsToDeletePAPHsDelivery.add(woli.Product2Id);
					}
				}
				else if(woli.Movement_Type__c == 'Removal (-)') {
					if(sourceMethod == 'handleConsumableItemsNoHUDelivery_HomeVisit' || sourceMethod == 'handleConsumableItemsNoHUDelivery_ConsignmentStock' ||
					sourceMethod == 'handleConsumableItemsNoHUDelivery_Currier') {
						ATIdsToDeletePAPHsRemovalConsumable.add(woli.WorkOrder.Account_Treatment__c);
						datesToDeletePAPHsRemovalConsumable.add(woli.WorkOrder.EndDate.date());
						productIdsToDeletePAPHsRemovalConsumable.add(woli.Product2Id);
					}
					else {
						ATIdsToDeletePAPHsRemoval.add(woli.WorkOrder.Account_Treatment__c);
						batchNumbersToDeletePAPHsRemoval.add(woli.Batch_Number__c);
						datesToDeletePAPHsRemoval.add(woli.WorkOrder.EndDate.date());
						productIdsToDeletePAPHsRemoval.add(woli.Product2Id);
					}
				}
			} 
		}

		if(!productItemsToUpdate.isEmpty()) {
			System.debug('----- Updating ' + productItemsToUpdate.size() + ' ProductItems...');

			List<Database.SaveResult> results = Database.update(productItemsToUpdate);
		}
		
		if(!productItemsToDelete.isEmpty()) {
			System.debug('----- Deleting ' + productItemsToDelete.size() + ' ProductItems...');

			List<Database.DeleteResult> results = Database.delete(productItemsToDelete, false);
		}


		if(!productItemsToInsert.isEmpty()) {
			System.debug('----- Inserting ' + productItemsToInsert.size() + ' ProductItems...');

			List<Database.SaveResult> results = Database.insert(productItemsToInsert);
		}

		// Deleting BATCH DELIVERY PAPH

		if(!ATIdsToDeletePAPHsDelivery.isEmpty() && !batchNumbersToDeletePAPHsDelivery.isEmpty() && !datesToDeletePAPHsDelivery.isEmpty() && !productIdsToDeletePAPHsDelivery.isEmpty()) {
			List<Product_Asset_Patient_History__c> deliveryPAPHsToDelete = [SELECT Id FROM Product_Asset_Patient_History__c
																			WHERE Account_Treatment__c IN: ATIdsToDeletePAPHsDelivery
																			AND BatchNumber__c IN: batchNumbersToDeletePAPHsDelivery
																			AND Product__c IN: productIdsToDeletePAPHsDelivery
																			AND Date__c IN: datesToDeletePAPHsDelivery
																			AND Type__c = 'Delivery'];

			if(deliveryPAPHsToDelete != null) {
				for(Product_Asset_Patient_History__c paph : deliveryPAPHsToDelete) {
					PAPHsToDelete.add(paph);
				}
			}
        }
        
        // Deleting BATCH REMOVAL PAPH

        if(!ATIdsToDeletePAPHsRemoval.isEmpty() && !batchNumbersToDeletePAPHsRemoval.isEmpty() && !datesToDeletePAPHsRemoval.isEmpty() && !productIdsToDeletePAPHsRemoval.isEmpty()) {
			List<Product_Asset_Patient_History__c> removalPAPHsToDelete = [SELECT Id FROM Product_Asset_Patient_History__c
																			WHERE Account_Treatment__c IN: ATIdsToDeletePAPHsRemoval
																			AND BatchNumber__c IN: batchNumbersToDeletePAPHsRemoval
																			AND Product__c IN: productIdsToDeletePAPHsRemoval
																			AND Date__c IN: datesToDeletePAPHsRemoval
																			AND Type__c = 'Removal'];

			if(removalPAPHsToDelete != null) {
				for(Product_Asset_Patient_History__c paph : removalPAPHsToDelete) {
					PAPHsToDelete.add(paph);
				}
			}
		}
		
		// Deleting CONSUMABLE DELIVERY PAPH

		if(!ATIdsToDeletePAPHsDeliveryConsumable.isEmpty() && !datesToDeletePAPHsDeliveryConsumable.isEmpty() && !productIdsToDeletePAPHsDeliveryConsumable.isEmpty()) {
			List<Product_Asset_Patient_History__c> deliveryPAPHsToDelete = [SELECT Id FROM Product_Asset_Patient_History__c
																			WHERE Account_Treatment__c IN: ATIdsToDeletePAPHsDeliveryConsumable
																			AND Product__c IN: productIdsToDeletePAPHsDeliveryConsumable
																			AND Date__c IN: datesToDeletePAPHsDeliveryConsumable
																			AND Type__c = 'Delivery'];

			if(deliveryPAPHsToDelete != null) {
				for(Product_Asset_Patient_History__c paph : deliveryPAPHsToDelete) {
					PAPHsToDelete.add(paph);
				}
			}
		}
		
		// Deleting CONSUMABLE REMOVAL PAPH

        if(!ATIdsToDeletePAPHsRemovalConsumable.isEmpty() && !datesToDeletePAPHsRemovalConsumable.isEmpty() && !productIdsToDeletePAPHsRemovalConsumable.isEmpty()) {
			List<Product_Asset_Patient_History__c> removalPAPHsToDelete = [SELECT Id FROM Product_Asset_Patient_History__c
																			WHERE Account_Treatment__c IN: ATIdsToDeletePAPHsRemoval
																			AND Product__c IN: productIdsToDeletePAPHsRemoval
																			AND Date__c IN: datesToDeletePAPHsRemoval
																			AND Type__c = 'Removal'];

			if(removalPAPHsToDelete != null) {
				for(Product_Asset_Patient_History__c paph : removalPAPHsToDelete) {
					PAPHsToDelete.add(paph);
				}
			}
		}

		if(!PAPHsToDelete.isEmpty()) {
			System.debug('----- Deleting ' + PAPHsToDelete.size() + ' PAPHs...');

			List<Database.DeleteResult> results = Database.delete(PAPHsToDelete, false);
		}
	}

	// Yellow Bag Items

	public static void handleYellowBagItems(List<WorkOrderLineItem> WOLIs) {
		List<ProductItem> vanProductItems = new List<ProductItem>();
		List<String> serialNumbers = new List<String>();
		List<String> productIds = new List<String>();
		List<String> sourceLocationIds = new List<String>();

		for(WorkOrderLineItem woli : WOLIs) {
			serialNumbers.add(woli.Serial_Number__c);
			productIds.add(woli.Product2Id);
			sourceLocationIds.add(woli.WorkOrder.Source_Location__c);
		}

		vanProductItems = [SELECT Id FROM ProductItem WHERE SerialNumber IN: serialNumbers AND Product2Id IN: productIds AND LocationId IN: sourceLocationIds];

		if(!vanProductItems.isEmpty()) {
			List<Database.DeleteResult> results = Database.delete(vanProductItems);
		}
	}
}