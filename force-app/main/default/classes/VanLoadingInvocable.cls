global without sharing class VanLoadingInvocable {

    @InvocableMethod
    public static void loadVAN(List<Request> inputList) {
        List<String> PRLIQueryFields = new List<String>{'EquipmentKey__c', 'Serial_Number__c', 'HU__c', 'Batch_Number__c', 'Loaded_Quantity__c', 
        'Product2.Unit_of_measure__c', 'Expired_Date__c', 'ProductCode__c', 'Offset__c', 'RelatedItem__c'};
        List<String> productRequestQueryFields = new List<String>{'DestinationLocationId', 'SourceLocationId'};

        ProductRequest productRequest = new ProductRequest();
        List<ProductRequest> productRequestList = new List<ProductRequest>();

        List<ProductRequestLineItem> allRelatedPRLIs = new List<ProductRequestLineItem>();
        List<ProductRequestLineItem> serializedItems = new List<ProductRequestLineItem>();
        List<ProductRequestLineItem> batchItemsNoHUNoCylinder = new List<ProductRequestLineItem>();
        List<ProductRequestLineItem> batchItemsHUNoCylinder = new List<ProductRequestLineItem>();
        List<ProductRequestLineItem> batchItemsCylinder = new List<ProductRequestLineItem>();
        List<ProductRequestLineItem> consumableItemsNoHU = new List<ProductRequestLineItem>();
        List<ProductRequestLineItem> consumableItemsHU = new List<ProductRequestLineItem>();

        List<ProductItem> productItemsToUpdate = new List<ProductItem>();
        List<ProductItem> productItemsToInsert = new List<ProductItem>();
        List<ProductItem> productItemsToDelete = new List<ProductItem>();
        List<ProductTransfer> productTransfersToInsert = new List<ProductTransfer>();
        
        Request request = inputList[0];
        String productRequestId = request.productRequestId;

        productRequestList = ProductRequestDAO.getProductRequestsFromIds(productRequestQueryFields, new List<String>{productRequestId});
        allRelatedPRLIs = ProductRequestLineItemDAO.getAvailablePRLIFromParentIdsStatus1(PRLIQueryFields, new List<String>{productRequestId});

        if(!productRequestList.isEmpty()) {
            productRequest = productRequestList[0];
        }

        // Splitting out the ProductRequestLineItems to be handled in different ways

        if(!allRelatedPRLIs.isEmpty()) {
            for(ProductRequestLineItem prli : allRelatedPRLIs) {

                // Serialized

                if(prli.Serial_Number__c != null || prli.EquipmentKey__c != null) {
                    serializedItems.add(prli);
                }

                // Batch...

                else if(prli.Serial_Number__c == null && prli.EquipmentKey__c == null && prli.Batch_Number__c != null) {

                    // ... Without Cylinder...

                    if(prli.RelatedItem__c == null) {

                        // ... And without Handling Unit

                        if(prli.HU__c == null) {
                            batchItemsNoHUNoCylinder.add(prli);
                        }

                        // ... And with Handling Unit

                        else {
                            batchItemsHUNoCylinder.add(prli);
                        }
                    }

                    // ... With Cylinder

                    else {
                        batchItemsCylinder.add(prli);
                    }
                }

                // Consumable...

                else if(prli.Serial_Number__c == null && prli.EquipmentKey__c == null && prli.Batch_Number__c == null) {

                    // ... Without Handling Unit

                    if(prli.HU__c == null) {
                        consumableItemsNoHU.add(prli);
                    }

                    // ... With Handling Unit

                    else {
                        consumableItemsHU.add(prli);
                    }
                }
            }
        }

        // Handling Serialized Items with/without Handling Unit

        if(!serializedItems.isEmpty()) {
            VanLoadingInvocableService.VanLoadingReturn result = VanLoadingInvocableService.handleSerializedItemsLoading(serializedItems, productRequest);

            if(result != null) {
                if(result.productItemsToDelete != null) {
                    productItemsToDelete.addAll(result.productItemsToDelete);
                }
                if(result.productItemsToInsert != null) {
                    productItemsToInsert.addAll(result.productItemsToInsert);
                }
                if(result.productItemsToUpdate != null) {
                    productItemsToUpdate.addAll(result.productItemsToUpdate);
                }
                if(result.productTransfersToInsert != null) {
                    productTransfersToInsert.addAll(result.productTransfersToInsert);
                }
            }
        }

        // Handling Batch Items without Handling Unit and without Cylinder

        if(!batchItemsNoHUNoCylinder.isEmpty()) {
            VanLoadingInvocableService.VanLoadingReturn result = VanLoadingInvocableService.handleBatchItemsNoHUNoCylinder(batchItemsNoHUNoCylinder, productRequest, false);

            if(result != null) {
                if(result.productItemsToDelete != null) {
                    productItemsToDelete.addAll(result.productItemsToDelete);
                }
                if(result.productItemsToInsert != null) {
                    productItemsToInsert.addAll(result.productItemsToInsert);
                }
                if(result.productItemsToUpdate != null) {
                    productItemsToUpdate.addAll(result.productItemsToUpdate);
                }
                if(result.productTransfersToInsert != null) {
                    productTransfersToInsert.addAll(result.productTransfersToInsert);
                }
            }
        }

        // Handling Batch Items with Handling Unit but without Cylinder

        if(!batchItemsHUNoCylinder.isEmpty()) {
            VanLoadingInvocableService.VanLoadingReturn result = VanLoadingInvocableService.handleBatchItemsHUNoCylinder(batchItemsHUNoCylinder, productRequest, false);

            if(result != null) {
                if(result.productItemsToDelete != null) {
                    productItemsToDelete.addAll(result.productItemsToDelete);
                }
                if(result.productItemsToInsert != null) {
                    productItemsToInsert.addAll(result.productItemsToInsert);
                }
                if(result.productItemsToUpdate != null) {
                    productItemsToUpdate.addAll(result.productItemsToUpdate);
                }
                if(result.productTransfersToInsert != null) {
                    productTransfersToInsert.addAll(result.productTransfersToInsert);
                }
            }
        }

        // Handling Batch Items with Cylinder

        if(!batchItemsCylinder.isEmpty()) {
            VanLoadingInvocableService.VanLoadingReturn result = VanLoadingInvocableService.handleBatchItemsCylinder(batchItemsCylinder, productRequest, false);

            if(result != null) {
                if(result.productItemsToDelete != null) {
                    productItemsToDelete.addAll(result.productItemsToDelete);
                }
                if(result.productItemsToInsert != null) {
                    productItemsToInsert.addAll(result.productItemsToInsert);
                }
                if(result.productItemsToUpdate != null) {
                    productItemsToUpdate.addAll(result.productItemsToUpdate);
                }
                if(result.productTransfersToInsert != null) {
                    productTransfersToInsert.addAll(result.productTransfersToInsert);
                }
            }
        }

        // Handling Consumable Items without Handling Unit

        if(!consumableItemsNoHU.isEmpty()) {
            VanLoadingInvocableService.VanLoadingReturn result = VanLoadingInvocableService.handleConsumableItemsNoHU(consumableItemsNoHU, productRequest, false);

            if(result != null) {
                if(result.productItemsToDelete != null) {
                    productItemsToDelete.addAll(result.productItemsToDelete);
                }
                if(result.productItemsToInsert != null) {
                    productItemsToInsert.addAll(result.productItemsToInsert);
                }
                if(result.productItemsToUpdate != null) {
                    productItemsToUpdate.addAll(result.productItemsToUpdate);
                }
                if(result.productTransfersToInsert != null) {
                    productTransfersToInsert.addAll(result.productTransfersToInsert);
                }
            }
        }

        // Handling Consumable Items with Handling Unit

        if(!consumableItemsHU.isEmpty()) {
            VanLoadingInvocableService.VanLoadingReturn result = VanLoadingInvocableService.handleConsumableItemsHU(consumableItemsHU, productRequest, false);

            if(result != null) {
                if(result.productItemsToDelete != null) {
                    productItemsToDelete.addAll(result.productItemsToDelete);
                }
                if(result.productItemsToInsert != null) {
                    productItemsToInsert.addAll(result.productItemsToInsert);
                }
                if(result.productItemsToUpdate != null) {
                    productItemsToUpdate.addAll(result.productItemsToUpdate);
                }
                if(result.productTransfersToInsert != null) {
                    productTransfersToInsert.addAll(result.productTransfersToInsert);
                }
            }
        }

        if(!productItemsToUpdate.isEmpty()) {
            List<Database.SaveResult> results = Database.update(productItemsToUpdate);
        }

        if(!productTransfersToInsert.isEmpty()) {
            List<Database.SaveResult> results = Database.insert(productTransfersToInsert);
        }

        if(!productItemsToInsert.isEmpty()) {
            List<Database.SaveResult> results = Database.insert(productItemsToInsert);
        }

        if(!productItemsToDelete.isEmpty()) {
            List<Database.DeleteResult> results = Database.delete(productItemsToDelete);
        }
    }

    global class Request {
        @InvocableVariable
        global String productRequestId;

        public Request(String productRequestId) {
            this.productRequestId = productRequestId;
        }

        public Request() {

        }
    }
}