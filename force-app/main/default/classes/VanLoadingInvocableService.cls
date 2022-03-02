public without sharing class VanLoadingInvocableService {
    // Custom exception
    public class NoProductItemException extends Exception {}
    
    // Serialized Items LOADING

    public static VanLoadingReturn handleSerializedItemsLoading(List<ProductRequestLineItem> PRLIs, ProductRequest relatedProductRequest) {
        System.debug('----- handleSerializedItemsLoading -----');

        List<String> productItemQueryFields = new List<String>{'Barcode_Label__c', 'Product2Id', 'QuantityUnitOfMeasure', 'Serialized_Item__c', 'SerialNumber'};

        VanLoadingReturn toReturn = new VanLoadingReturn();
        List<String> productItemSerialNumbers = new List<String>();
        List<ProductItem> allRelatedProductItems = new List<ProductItem>();
        List<ProductTransfer> newProductTransfers = new List<ProductTransfer>();
        List<ProductItem> productItemsToUpdate = new List<ProductItem>();

        Map<String, ProductItem> productItemMap = new Map<String, ProductItem>();

        for(ProductRequestLineItem prli : PRLIs) {
            productItemSerialNumbers.add(prli.EquipmentKey__c);
        }

        allRelatedProductItems = ProductItemDAO.getProductItemsFromSerialNumbers(productItemQueryFields, productItemSerialNumbers);

        if(!allRelatedProductItems.isEmpty()) {
            for(ProductItem productItem : allRelatedProductItems) {
                productItemMap.put(productItem.SerialNumber, productItem);
            }

            for(ProductRequestLineItem prli : PRLIs) {
                ProductItem relatedProductItem = productItemMap.get(prli.EquipmentKey__c);

                // Creating the new ProductTransfer for both serialized items with HU = null or != null

                if(relatedProductItem != null) {
                    // If the serialized item has a Handling Unit != null, update the related Product Item

                    if(prli.HU__c != null) {
                        relatedProductItem.HU__c = prli.HU__c;

                        productItemsToUpdate.add(relatedProductItem);
                    }

                    ProductTransfer newProductTransfer = new ProductTransfer(
                        Date__c = Date.today(),
                        DestinationLocationId = relatedProductRequest.DestinationLocationId,
                        Label__c = relatedProductItem.Barcode_Label__c,
                        Product2Id = relatedProductItem.Product2Id,
                        ProductRequestLineItemId = prli.Id,
                        QuantityReceived = 1,
                        QuantitySent = 1,
                        QuantityUnitOfMeasure = relatedProductItem.QuantityUnitOfMeasure,
                        IsReceived = true,
                        Serialized_Item__c = relatedProductItem.Serialized_Item__c,
                        SourceLocationId = relatedProductRequest.SourceLocationId,
                        SourceProductItemId = relatedProductItem.Id,
                        Status = 'Completato',
                        ExpectedPickupDate = Date.today()
                    );

                    newProductTransfers.add(newProductTransfer);
                }
                else {
                    throw new NoProductItemException(Label.NoProductItem_Exception + '_EquipmentKey: ' + prli.EquipmentKey__c);
                }
            }
        }
        else {
            throw new NoProductItemException(Label.NoProductItem_Exception + '_EquipmentKey: ' + productItemSerialNumbers);
        }

        if(!productItemsToUpdate.isEmpty()) {
            //List<Database.SaveResult> results = Database.update(productItemsToUpdate);
            toReturn.productItemsToUpdate = productItemsToUpdate;
        }

        if(!newProductTransfers.isEmpty()) {
            //List<Database.SaveResult> results = Database.insert(newProductTransfers);
            toReturn.productTransfersToInsert = newProductTransfers;
        }

        return toReturn;
    }

    // Serialized Items UNLOADING

    public static VanLoadingReturn handleSerializedItemsUnloading(List<ProductRequestLineItem> PRLIs, ProductRequest relatedProductRequest) {
        System.debug('----- handleSerializedItemsUnloading -----');

        List<String> productItemQueryFields = new List<String>{'Barcode_Label__c', 'Product2Id', 'QuantityUnitOfMeasure', 'Serialized_Item__c', 'SerialNumber'};

        VanLoadingReturn toReturn = new VanLoadingReturn();
        List<String> productItemSerialNumbers = new List<String>();
        List<ProductItem> allRelatedProductItems = new List<ProductItem>();
        List<ProductTransfer> newProductTransfers = new List<ProductTransfer>();
        List<ProductItem> productItemsToUpdate = new List<ProductItem>();
        List<ProductItem> productItemsToDelete = new List<ProductItem>();

        Map<String, ProductItem> productItemMap = new Map<String, ProductItem>();

        for(ProductRequestLineItem prli : PRLIs) {
            productItemSerialNumbers.add(prli.EquipmentKey__c);
        }

        allRelatedProductItems = ProductItemDAO.getProductItemsFromSerialNumbers(productItemQueryFields, productItemSerialNumbers);

        if(!allRelatedProductItems.isEmpty()) {
            for(ProductItem productItem : allRelatedProductItems) {
                productItemMap.put(productItem.SerialNumber, productItem);
            }

            for(ProductRequestLineItem prli : PRLIs) {
                ProductItem relatedProductItem = productItemMap.get(prli.EquipmentKey__c);

                if(relatedProductItem != null) {
                    if(!prli.Serial_Number__c.startsWith('NL') && !prli.Serial_Number__c.startsWith('SK')) {
                        if(prli.HU__c != null || prli.Batch_Number__c != null) {
                            // If the serialized item has a Handling Unit != null, update the related Product Item

                            if(prli.HU__c != null) {
                                relatedProductItem.HU__c = null;
                            }

                            // If the serialized item has a Batch Number != null, update the related Product Item

                            if(prli.Batch_Number__c != null) {
                                relatedProductItem.BatchNumber__c = null;
                            }

                            productItemsToUpdate.add(relatedProductItem);
                        }

                        // Creating the new ProductTransfer for both serialized items with HU = null or != null

                        ProductTransfer newProductTransfer = new ProductTransfer(
                            Date__c = Date.today(),
                            DestinationLocationId = relatedProductRequest.DestinationLocationId,
                            Label__c = relatedProductItem.Barcode_Label__c,
                            Product2Id = relatedProductItem.Product2Id,
                            ProductRequestLineItemId = prli.Id,
                            QuantityReceived = 1,
                            QuantitySent = 1,
                            QuantityUnitOfMeasure = relatedProductItem.QuantityUnitOfMeasure,
                            IsReceived = true,
                            Serialized_Item__c = relatedProductItem.Serialized_Item__c,
                            SourceLocationId = relatedProductRequest.SourceLocationId,
                            SourceProductItemId = relatedProductItem.Id,
                            Status = 'Completato',
                            ExpectedPickupDate = Date.today()
                        );

                        newProductTransfers.add(newProductTransfer);
                    }
                }
                else {
                    throw new NoProductItemException(Label.NoProductItem_Exception + '_EquipmentKey: ' + prli.EquipmentKey__c);
                }
            }
        }
        else {
            throw new NoProductItemException(Label.NoProductItem_Exception + '_EquipmentKey: ' + productItemSerialNumbers);
        }

        if(!productItemsToUpdate.isEmpty()) {
            //List<Database.SaveResult> results = Database.update(productItemsToUpdate);
            toReturn.productItemsToUpdate = productItemsToUpdate;
        }

        if(!newProductTransfers.isEmpty()) {
            //List<Database.SaveResult> results = Database.insert(newProductTransfers);
            toReturn.productTransfersToInsert = newProductTransfers;
        }

        if(!productItemsToDelete.isEmpty()) {
            //List<Database.DeleteResult> results = Database.delete(productItemsToDelete);
            toReturn.productItemsToDelete = productItemsToDelete;
        }

        return toReturn;
    }

    // Serialized Items Sack or NL UNLOADING

    public static VanLoadingReturn handleSerializedUnloadingSackOrNL(List<ProductRequestLineItem> PRLIs, ProductRequest relatedProductRequest) {
        System.debug('----- handleSerializedUnloadingSackOrNL -----');

        List<String> productItemQueryFields = new List<String>{'Barcode_Label__c', 'Product2Id', 'QuantityUnitOfMeasure', 'Serialized_Item__c', 'SerialNumber'};

        VanLoadingReturn toReturn = new VanLoadingReturn();
        List<String> productItemSerialNumbers = new List<String>();
        List<ProductItem> allRelatedProductItems = new List<ProductItem>();
        List<ProductItem> productItemsToDelete = new List<ProductItem>();

        Map<String, ProductItem> productItemMap = new Map<String, ProductItem>();

        for(ProductRequestLineItem prli : PRLIs) {
            productItemSerialNumbers.add(prli.Serial_Number__c);
        }

        allRelatedProductItems = ProductItemDAO.getProductItemsFromSerialNumbers(productItemQueryFields, productItemSerialNumbers);

        if(!allRelatedProductItems.isEmpty()) {
            for(ProductItem productItem : allRelatedProductItems) {
                productItemMap.put(productItem.SerialNumber, productItem);
            }

            for(ProductRequestLineItem prli : PRLIs) {
                ProductItem relatedProductItem = productItemMap.get(prli.Serial_Number__c);

                if(relatedProductItem != null) {
                    productItemsToDelete.add(relatedProductItem);
                }
                else {
                    throw new NoProductItemException(Label.NoProductItem_Exception + '_SerialNumber: ' + prli.Serial_Number__c);
                }
            }
        }
        else {
            throw new NoProductItemException(Label.NoProductItem_Exception + '_SerialNumber: ' + productItemSerialNumbers);
        }

        if(!productItemsToDelete.isEmpty()) {
            //List<Database.DeleteResult> results = Database.delete(productItemsToDelete);
            toReturn.productItemsToDelete = productItemsToDelete;
        }

        return toReturn;
    }

    // Batch Items without Handling Unit and without Cylinder

    public static VanLoadingReturn handleBatchItemsNoHUNoCylinder(List<ProductRequestLineItem> PRLIs, ProductRequest relatedProductRequest, Boolean isUnloading) {
        System.debug('----- handleBatchItemsNoHUNoCylinder -----');

        VanLoadingReturn toReturn = new VanLoadingReturn();
        List<String> batchNumbers = new List<String>();
        List<String> productIds = new List<String>();
        List<ProductItem> allRelatedProductItems = new List<ProductItem>();

        Map<String, ProductItem> PRLIToProductItemMap = new Map<String, ProductItem>();

        String locationIdToMatch;

        if(isUnloading) {
            locationIdToMatch = relatedProductRequest.SourceLocationId;
        }
        else {
            locationIdToMatch = relatedProductRequest.DestinationLocationId;
        }

        for(ProductRequestLineItem prli : PRLIs) {
            batchNumbers.add(prli.Batch_Number__c);
            productIds.add(prli.Product2Id);
        }

        allRelatedProductItems = [SELECT QuantityOnHand, BatchNumber__c, Product2Id FROM ProductItem 
                                  WHERE BatchNumber__c IN: batchNumbers 
                                  AND Product2Id IN: productIds 
                                  AND LocationId =: locationIdToMatch
                                  AND HU__c = null
                                  AND RelatedProductItem__c = null
                                 ];

        // Building a PRLI.Id --> related PI from query map
        
        for(ProductRequestLineItem prli : PRLIs) {
            for(ProductItem pi : allRelatedProductItems) {
                if(pi.BatchNumber__c == prli.Batch_Number__c && pi.Product2Id == prli.Product2Id) {
                    PRLIToProductItemMap.put(prli.Id, pi);
                    break;
                }
            }
        }

        toReturn = handleProductItems(PRLIs, relatedProductRequest, PRLIToProductItemMap, null, isUnloading, true);

        return toReturn;
    }

    // Batch Items with Handling Unit but without Cylinder

    public static VanLoadingReturn handleBatchItemsHUNoCylinder(List<ProductRequestLineItem> PRLIs, ProductRequest relatedProductRequest, Boolean isUnloading) {
        System.debug('----- handleBatchItemsHUNoCylinder -----');

        VanLoadingReturn toReturn = new VanLoadingReturn();
        List<String> batchNumbers = new List<String>();
        List<String> productIds = new List<String>();
        List<String> handlingUnits = new List<String>();
        List<ProductItem> allRelatedProductItems = new List<ProductItem>();

        Map<String, ProductItem> PRLIToProductItemMap = new Map<String, ProductItem>();

        String locationIdToMatch;

        if(isUnloading) {
            locationIdToMatch = relatedProductRequest.SourceLocationId;
        }
        else {
            locationIdToMatch = relatedProductRequest.DestinationLocationId;
        }

        for(ProductRequestLineItem prli : PRLIs) {
            batchNumbers.add(prli.Batch_Number__c);
            productIds.add(prli.Product2Id);
            handlingUnits.add(prli.HU__c);
        }

        allRelatedProductItems = [SELECT QuantityOnHand, BatchNumber__c, Product2Id, HU__c FROM ProductItem 
                                  WHERE BatchNumber__c IN: batchNumbers 
                                  AND Product2Id IN: productIds 
                                  AND LocationId =: locationIdToMatch
                                  AND HU__c IN: handlingUnits
                                  AND RelatedProductItem__c = null
                                 ];

        // Building a PRLI.Id --> related PI from query map
        
        for(ProductRequestLineItem prli : PRLIs) {
            for(ProductItem pi : allRelatedProductItems) {
                if(pi.BatchNumber__c == prli.Batch_Number__c && pi.Product2Id == prli.Product2Id && pi.HU__c == prli.HU__c) {
                    PRLIToProductItemMap.put(prli.Id, pi);
                    break;
                }
            }
        }

        toReturn = handleProductItems(PRLIs, relatedProductRequest, PRLIToProductItemMap, null, isUnloading, false);

        return toReturn;
    }

    // Batch Items with Cylinder

    public static VanLoadingReturn handleBatchItemsCylinder(List<ProductRequestLineItem> PRLIs, ProductRequest relatedProductRequest, Boolean isUnloading) {
        System.debug('----- handleBatchItemsCylinder -----');

        VanLoadingReturn toReturn = new VanLoadingReturn();
        List<String> batchNumbers = new List<String>();
        List<String> productIds = new List<String>();
        List<String> handlingUnits = new List<String>();
        List<String> relatedItemSerialNumbers = new List<String>();
        List<ProductItem> allRelatedProductItems = new List<ProductItem>();
        List<ProductItem> allRelatedItems = new List<ProductItem>();

        Map<String, ProductItem> PRLIToProductItemMap = new Map<String, ProductItem>();
        Map<String, ProductItem> relatedItemMap = new Map<String, ProductItem>();

        String locationIdToMatch;

        if(isUnloading) {
            locationIdToMatch = relatedProductRequest.SourceLocationId;
        }
        else {
            locationIdToMatch = relatedProductRequest.DestinationLocationId;
        }

        for(ProductRequestLineItem prli : PRLIs) {
            batchNumbers.add(prli.Batch_Number__c);
            productIds.add(prli.Product2Id);
            handlingUnits.add(prli.HU__c);
            relatedItemSerialNumbers.add(prli.RelatedItem__c);
        }

        allRelatedProductItems = [SELECT QuantityOnHand, BatchNumber__c, Product2Id, HU__c, RelatedEquipmentKey__c FROM ProductItem 
                                  WHERE BatchNumber__c IN: batchNumbers 
                                  AND Product2Id IN: productIds 
                                  AND LocationId =: locationIdToMatch
                                  AND HU__c IN: handlingUnits
                                  AND RelatedEquipmentKey__c IN: relatedItemSerialNumbers
                                 ];

        allRelatedItems = [SELECT SerialNumber FROM ProductItem WHERE SerialNumber IN: relatedItemSerialNumbers];

        for(ProductItem relatedItem : allRelatedItems) {
            relatedItemMap.put(relatedItem.SerialNumber, relatedItem);
        }

        // Building a PRLI.Id --> related PI from query map
        
        for(ProductRequestLineItem prli : PRLIs) {
            for(ProductItem pi : allRelatedProductItems) {
                if(pi.BatchNumber__c == prli.Batch_Number__c && pi.Product2Id == prli.Product2Id && pi.HU__c == prli.HU__c && pi.RelatedEquipmentKey__c == prli.RelatedItem__c) {
                    PRLIToProductItemMap.put(prli.Id, pi);
                    break;
                }
            }
        }

        toReturn = handleProductItems(PRLIs, relatedProductRequest, PRLIToProductItemMap, relatedItemMap, isUnloading, false);

        return toReturn;
    }

    // Consumable Items without Handling Unit

    public static VanLoadingReturn handleConsumableItemsNoHU(List<ProductRequestLineItem> PRLIs, ProductRequest relatedProductRequest, Boolean isUnloading) {
        System.debug('----- handleConsumableItemsNoHU -----');

        VanLoadingReturn toReturn = new VanLoadingReturn();
        List<String> productIds = new List<String>();
        List<ProductItem> allRelatedProductItems = new List<ProductItem>();

        Map<String, ProductItem> PRLIToProductItemMap = new Map<String, ProductItem>();

        String locationIdToMatch;

        if(isUnloading) {
            locationIdToMatch = relatedProductRequest.SourceLocationId;
        }
        else {
            locationIdToMatch = relatedProductRequest.DestinationLocationId;
        }

        for(ProductRequestLineItem prli : PRLIs) {
            productIds.add(prli.Product2Id);
        }

        allRelatedProductItems = [SELECT QuantityOnHand, Product2Id FROM ProductItem 
                                  WHERE BatchNumber__c = null 
                                  AND Product2Id IN: productIds 
                                  AND LocationId =: locationIdToMatch
                                 ];

        // Building a PRLI.Id --> related PI from query map
        
        for(ProductRequestLineItem prli : PRLIs) {
            for(ProductItem pi : allRelatedProductItems) {
                if(pi.Product2Id == prli.Product2Id) {
                    PRLIToProductItemMap.put(prli.Id, pi);
                    break;
                }
            }
        }

        toReturn = handleProductItems(PRLIs, relatedProductRequest, PRLIToProductItemMap, null, isUnloading, true);

        return toReturn;
    }

    // Consumable Items with Handling Unit

    public static VanLoadingReturn handleConsumableItemsHU(List<ProductRequestLineItem> PRLIs, ProductRequest relatedProductRequest, Boolean isUnloading) {
        System.debug('----- handleConsumableItemsHU -----');

        VanLoadingReturn toReturn = new VanLoadingReturn();
        List<String> productIds = new List<String>();
        List<String> handlingUnits = new List<String>();
        List<ProductItem> allRelatedProductItems = new List<ProductItem>();

        Map<String, ProductItem> PRLIToProductItemMap = new Map<String, ProductItem>();

        String locationIdToMatch;

        if(isUnloading) {
            locationIdToMatch = relatedProductRequest.SourceLocationId;
        }
        else {
            locationIdToMatch = relatedProductRequest.DestinationLocationId;
        }

        for(ProductRequestLineItem prli : PRLIs) {
            productIds.add(prli.Product2Id);
            handlingUnits.add(prli.HU__c);
        }

        allRelatedProductItems = [SELECT QuantityOnHand, Product2Id, HU__c FROM ProductItem 
                                  WHERE BatchNumber__c = null 
                                  AND Product2Id IN: productIds 
                                  AND LocationId =: locationIdToMatch
                                  AND HU__c IN: handlingUnits
                                 ];

        // Building a PRLI.Id --> related PI from query map
        
        for(ProductRequestLineItem prli : PRLIs) {
            for(ProductItem pi : allRelatedProductItems) {
                if(pi.Product2Id == prli.Product2Id && pi.HU__c == prli.HU__c) {
                    PRLIToProductItemMap.put(prli.Id, pi);
                    break;
                }
            }
        }

        toReturn = handleProductItems(PRLIs, relatedProductRequest, PRLIToProductItemMap, null, isUnloading, false);

        return toReturn;
    }

    // Generic code to create/update Product Item for Batch/Consumable Items

    public static VanLoadingReturn handleProductItems(List<ProductRequestLineItem> PRLIs, ProductRequest relatedProductRequest, Map<String, ProductItem> productItemMap, 
    Map<String, ProductItem> relatedItemMap, Boolean isUnloading, Boolean partialRemoval) {
        System.debug('----- handleProductItems -----');

        VanLoadingReturn toReturn = new VanLoadingReturn();
        List<ProductItem> productItemsToUpdate = new List<ProductItem>();
        List<ProductItem> productItemsToInsert = new List<ProductItem>();
        List<ProductItem> productItemsToDelete = new List<ProductItem>();
        List<String> productItemsToUpdateIds = new List<String>();

        Map<String, ProductItem> newProductItemMap = new Map<String, ProductItem>();
        
        for(ProductRequestLineItem prli : PRLIs) {
            ProductItem relatedProductItem;

            // Getting the Product Item if already present...

            if(!productItemMap.isEmpty()) {
                relatedProductItem = productItemMap.get(prli.Id);
            }

            System.debug('----- PRLI: ' + prli.Id);
            System.debug('productItemMap: ' + productItemMap);
            System.debug('relatedProductItem: ' + relatedProductItem);
            if(relatedProductItem != null) {
                System.debug('relatedProductItem.Id: ' + relatedProductItem.Id);
                System.debug('PRODUCT ITEM ALREADY UPDATED? ' + productItemsToUpdateIds.contains(relatedProductItem.Id));
            }
            System.debug('prli.Batch_Number: ' + prli.Batch_Number__c);
            System.debug('prli.HU: ' + prli.HU__c);
            System.debug('prli.RelatedItem: ' + prli.RelatedItem__c);
            System.debug('prli.Loaded_Quantity: ' + prli.Loaded_Quantity__c);

            // ... Then updating its quantity if called from VanLoading. If called from VanUnloading, subtract the loaded quantity or delete the ProductItem found instead

            if(relatedProductItem != null) {
                if(!isUnloading) {
                    if(!productItemsToUpdateIds.contains(relatedProductItem.Id)) {
                        relatedProductItem.QuantityOnHand = relatedProductItem.QuantityOnHand + prli.Loaded_Quantity__c;

                        productItemsToUpdate.add(relatedProductItem);
                        productItemsToUpdateIds.add(relatedProductItem.Id);
                    }

                    // If a PRLI was related to the same PI and this has already been updated, I need to update its quantity without adding it to the list again

                    else {
                        System.debug('VAN LOADING - relatedProductItem era già contenuto nella lista da aggiornare');

                        Integer index = productItemsToUpdateIds.indexOf(relatedProductItem.Id);

                        if(index != null && index != -1) {
                            if(productItemsToUpdate[index] != null) {
                                System.debug('Adding quantity to already updated PI...');
                                System.debug('Old quantity: ' + productItemsToUpdate[index].QuantityOnHand);
                                System.debug('Adding: ' + prli.Loaded_Quantity__c);

                                productItemsToUpdate[index].QuantityOnHand = productItemsToUpdate[index].QuantityOnHand + prli.Loaded_Quantity__c;

                                System.debug('New Quantity for ProductItem ' + productItemsToUpdate[index].Id + ': ' + productItemsToUpdate[index].QuantityOnHand);
                            }
                        }
                    }
                }
                else {
                    if(partialRemoval && relatedProductItem.QuantityOnHand - prli.Loaded_Quantity__c > 0) {
                        System.debug('UNLOADING - Partial removal');

                        if(!productItemsToUpdateIds.contains(relatedProductItem.Id)) {
                            relatedProductItem.QuantityOnHand = relatedProductItem.QuantityOnHand - prli.Loaded_Quantity__c;

                            productItemsToUpdate.add(relatedProductItem);
                            productItemsToUpdateIds.add(relatedProductItem.Id);
                        }
                        else {
                            System.debug('VAN UNLOADING - relatedProductItem era già contenuto nella lista da aggiornare');
    
                            Integer index = productItemsToUpdateIds.indexOf(relatedProductItem.Id);
    
                            if(index != null && index != -1) {
                                if(productItemsToUpdate[index] != null) {
                                    System.debug('Subtracting quantity to already updated PI...');
                                    System.debug('Old quantity: ' + productItemsToUpdate[index].QuantityOnHand);
                                    System.debug('Subtracting: ' + prli.Loaded_Quantity__c);
    
                                    productItemsToUpdate[index].QuantityOnHand = productItemsToUpdate[index].QuantityOnHand - prli.Loaded_Quantity__c;
    
                                    System.debug('New Quantity for ProductItem ' + productItemsToUpdate[index].Id + ': ' + productItemsToUpdate[index].QuantityOnHand);

                                    if(productItemsToUpdate[index].QuantityOnHand <= 0) {
                                        System.debug('The resulting quantity was 0 or less: removing the ProductItem...');

                                        productItemsToDelete.add(productItemsToUpdate[index]);
                                    }
                                }
                            }
                        }
                    }
                    else {
                        if(!productItemsToDelete.contains(relatedProductItem)) {
                            System.debug('DELETING Product Item');

                            productItemsToDelete.add(relatedProductItem);
                        }
                    }
                }
            }

            // If there's no Product Item yet, I'll create it

            else {
                if(!isUnloading) {
                    ProductItem newProductItem = new ProductItem(
                        Expired_Date__c = prli.Expired_Date__c,
                        LocationId = relatedProductRequest.DestinationLocationId,
                        Offset__c = prli.Offset__c,
                        Product2Id = prli.Product2Id,
                        QuantityOnHand = prli.Loaded_Quantity__c,
                        QuantityUnitOfMeasure = prli.Product2.Unit_of_measure__c
                    );

                    // Particular attributes for Batch Items

                    if(prli.Batch_Number__c != null) {
                        newProductItem.BatchNumber__c = prli.Batch_Number__c;
                        newProductItem.SerialNumber = prli.Batch_Number__c + '_' + prli.ProductCode__c;
                    }

                    // Particular attributes for HU != null and no cylinder

                    if(prli.HU__c != null) {
                        if(newProductItem.SerialNumber == null) {
                            newProductItem.SerialNumber = prli.ProductCode__c;
                        }

                        if(prli.RelatedItem__c == null) {
                            newProductItem.SerialNumber = newProductItem.SerialNumber + '_' + prli.HU__c;
                        }
                            
                        newProductItem.HU__c = prli.HU__c;
                    }

                    // Particular attributes for cylinder != null

                    if(prli.RelatedItem__c != null && relatedItemMap != null) {
                        ProductItem relatedItem = relatedItemMap.get(prli.RelatedItem__c);

                        System.debug('relatedItem: ' + relatedItem);

                        newProductItem.SerialNumber = newProductItem.SerialNumber + '_' + prli.RelatedItem__c;

                        if(relatedItem != null) {
                            newProductItem.RelatedProductItem__c = relatedItem.Id;
                        }
                    }

                    String toMatch;

                    if(newProductItem.SerialNumber != null) {
                        toMatch = newProductItem.SerialNumber;
                    }
                    else {
                        toMatch = newProductItem.Product2Id;
                    }

                    if(!newProductItemMap.containsKey(toMatch)) {
                        System.debug('SerialNumber NOT ALREADY created');

                        productItemsToInsert.add(newProductItem);
                        newProductItemMap.put(toMatch, newProductItem);
                    }
                    else {
                        System.debug('SerialNumber ALREADY created! ' + toMatch);

                        ProductItem toUpdateQuantity = newProductItemMap.get(toMatch);

                        System.debug('ProductItem with same SerialNumber: ' + toUpdateQuantity);

                        if(toUpdateQuantity != null) {
                            Integer index = productItemsToInsert.indexOf(toUpdateQuantity);

                            if(index != null && index != -1) {
                                if(productItemsToInsert[index] != null) {
                                    System.debug('SerialNumber already present to be inserted! Updating its quantity');
                                    System.debug('Old quantity: ' + productItemsToInsert[index].QuantityOnHand);
                                    
                                    productItemsToInsert[index].QuantityOnHand = productItemsToInsert[index].QuantityOnHand + prli.Loaded_Quantity__c;

                                    System.debug('New quantity: ' + productItemsToInsert[index].QuantityOnHand);
                                }
                            }
                        }
                    }

                    System.debug('newProductItem.SerialNumber: ' + newProductItem.SerialNumber);
                }
                else {
                    throw new NoProductItemException(Label.NoProductItem_Exception + '_HU: ' + prli.HU__c + '_BatchNumber: ' + prli.Batch_Number__c + '_RelatedItem: ' + 
                    prli.RelatedItem__c);
                }
            }
        }

        if(!productItemsToUpdate.isEmpty()) {
            //List<Database.SaveResult> results = Database.update(productItemsToUpdate);
            toReturn.productItemsToUpdate = productItemsToUpdate;
        }

        if(!productItemsToInsert.isEmpty()) {
            //List<Database.SaveResult> results = Database.insert(productItemsToInsert);
            toReturn.productItemsToInsert = productItemsToInsert;
        }

        if(!productItemsToDelete.isEmpty()) {
            //List<Database.DeleteResult> results = Database.delete(productItemsToDelete);
            toReturn.productItemsToDelete = productItemsToDelete;
        }

        return toReturn;
    }

    public class VanLoadingReturn {
        public List<ProductItem> productItemsToUpdate;
        public List<ProductItem> productItemsToInsert;
        public List<ProductItem> productItemsToDelete;
        public List<ProductTransfer> productTransfersToInsert;
    }
}