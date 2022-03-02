public class GoodsMovement {

    public static void processGoodsMovement(List<Id> workOrderIds) {
        System.debug('----- STARTING GOODS MOVEMENT -----');
        Map<Id, List<WorkOrderLineItem>> WOToWOLIsMap = retrieveNotCompletedWOLIs(workOrderIds);

        if(WOToWOLIsMap != null) {
            moveGoods(WOToWOLIsMap);
        }
    }

    public static Map<Id, List<WorkOrderLineItem>> retrieveNotCompletedWOLIs(List<Id> workOrderIds) {
        List<String> WOLIQueryFields = new List<String>{'Batch_Number__c', 'AssetId', 'Serial_Number__c', 'PricebookEntryId',
        'QuantityDelivered__c', 'Product2Id', 'Product2.Product_Code__c', 'ExpiryDate__c', 'WorkOrderId', 'LocationId', 'Movement_Type__c', 'Status',
        'StorageLocation__c', 'Offset__c'};

        Map<Id, List<WorkOrderLineItem>> WOToWOLIsMap = new Map<Id, List<WorkOrderLineItem>>();

        List<WorkOrderLineItem> relatedWOLIs = WorkOrderLineItemDAO.getNotCompletedWOLIsFromWOs(WOLIQueryFields, workOrderIds);
        System.debug('RelatedWOLIs: ' + relatedWOLIs.size());

        if(relatedWOLIs != null) {
            for(WorkOrderLineItem woli : relatedWOLIs) {
                if(WOToWOLIsMap.get(woli.WorkOrderId) == null) {
                    WOToWOLIsMap.put(woli.WorkOrderId, new List<WorkOrderLineItem>());
                }
                WOToWOLIsMap.get(woli.WorkOrderId).add(woli);
            }
        }

        System.debug('WOToWOLIsMAP: ' + WOToWOLIsMap);
        return WOToWOLIsMap;
    }

    public static void moveGoods(Map<Id, List<WorkOrderLineItem>> WOToWOLIsMap) {
        List<String> workOrderQueryFields = new List<String>{'Document_Type__c', 'LocationId', 'Account_Treatment__c', 'AccountId', 'EndDate', 'SAP_Storage_Location__c'};
        List<String> productItemQueryFields = new List<String>{'LocationId', 'QuantityOnHand', 'BatchNumber__c', 'Product2Id', 'SerialNumber', 'Serialized_Item__c'};
        List<String> assetQueryFields = new List<String>{'AssetServicedById', 'Account_Treatment__c', 'LocationId'};

        List<WorkOrder> workOrders = WorkOrderDAO.getWorkOrdersFromIds(workOrderQueryFields, WOToWOLIsMap.keySet());
        List<WorkOrderLineItem> allWOLIs = new List<WorkOrderLineItem>();
        List<Id> allRelatedAssetIds = new List<Id>();
        List<Asset> allRelatedAssets = new List<Asset>();
        List<ProductItem> allRelatedProductItems = new List<ProductItem>();
        List<ProductItem> allRelatedProductItemsPatients = new List<ProductItem>();

        List<ProductTransfer> productTransfersToInsert = new List<ProductTransfer>();
        List<Product_Asset_Patient_History__c> PAPHsToInsert = new List<Product_Asset_Patient_History__c>();
        List<ProductItem> productItemsToUpdate = new List<ProductItem>();
        List<ProductItem> productItemsToInsert = new List<ProductItem>();
        List<ProductItem> productItemsToDelete = new List<ProductItem>();
        List<Asset> assetsToUpdate = new List<Asset>();
        List<WorkOrderLineItem> WOLIsToUpdate = new List<WorkOrderLineItem>();

        List<String> allBatchNumbers = new List<String>();
        List<Id> allProductIds = new List<Id>();
        List<Id> allLocationIds = new List<Id>();

        Map<Id, ProductItem> productItemMap = new Map<Id, ProductItem>();
        Map<Id, Asset> assetMap = new Map<Id, Asset>();

        for(WorkOrder wo : workOrders) {
            List<WorkOrderLineItem> relatedWOLIs = WOToWOLIsMap.get(wo.Id);
            allLocationIds.add(wo.LocationId);
            System.debug('wo.LocationId: ' + wo.LocationId);

            for(WorkOrderLineItem woli : relatedWOLIs) {
                allWOLIs.add(woli);
            }
        }

        // Building a Map to get related ProductItem for each WOLI and same for Assets

        if(!allWOLIs.isEmpty()) {
            for(WorkOrderLineItem woli : allWOLIs) {
                if(woli.AssetId != null) {
                    allRelatedAssetIds.add(woli.AssetId);
                    System.debug('woli.AssetId: ' + woli.AssetId);
                }
                if(woli.Batch_Number__c != null) {
                    allBatchNumbers.add(woli.Batch_Number__c);
                    System.debug('woli.Batch_Number__c: ' + woli.Batch_Number__c);
                }
                if(woli.Product2Id != null) {
                    allProductIds.add(woli.Product2Id);
                    System.debug('woli.Product2Id: ' + woli.Product2Id);
                }
            }

            if(!allRelatedAssetIds.isEmpty()) {
                allRelatedProductItems = ProductItemDAO.getProductItemsFromSerializedItem(productItemQueryFields, allRelatedAssetIds);
                allRelatedAssets = AssetDAO.getAssetsFromIds(assetQueryFields, allRelatedAssetIds);

                if(!allRelatedProductItems.isEmpty()) {
                    for(ProductItem pi : allRelatedProductItems) {
                        productItemMap.put(pi.Serialized_Item__c, pi);
                    }
                }
                if(!allRelatedAssets.isEmpty()) {
                    for(Asset a : allRelatedAssets) {
                        assetMap.put(a.Id, a);
                    }
                }
            }
            
            System.debug('allBatchNumbers size: ' + allBatchNumbers.size());
            System.debug('allProductIds size: ' + allProductIds.size());
            System.debug('allLocationIds size: ' + allLocationIds.size());
            if(!allProductIds.isEmpty() && !allLocationIds.isEmpty()) {
                allRelatedProductItemsPatients = ProductItemDAO.getProductItemPatients(productItemQueryFields, allProductIds, allBatchNumbers, allLocationIds);
            }
        }
        System.debug('GOODS MOVEMENT ----- workOrders size: ' + workOrders.size());

        // Goods Movement

        for(WorkOrder wo : workOrders) {
            List<WorkOrderLineItem> relatedWOLIs = WOToWOLIsMap.get(wo.Id);
            System.debug('RelatedWOLIs size: ' + relatedWOLIs.size());

            // Delivery

            if(wo.Document_Type__c != 'ZRET' && wo.Document_Type__c != 'ZRNC') {
                for(WorkOrderLineItem woli : relatedWOLIs) {
                    ProductItem relatedProductItem = productItemMap.get(woli.AssetId);
                    Asset relatedAsset = assetMap.get(woli.AssetId);

                    // Serialized Item Delivery

                    if(woli.Serial_Number__c != null && woli.AssetId != null && woli.Movement_Type__c != 'Removal (-)') {

                        // Product Transfer creation

                        if(relatedProductItem != null) {
                            ProductTransfer newProductTransfer = new ProductTransfer(
                                SourceProductItemId = relatedProductItem.Id,
                                SourceLocationId = relatedProductItem.LocationId,
                                DestinationLocationId = wo.LocationId,
                                Date__c = (wo.EndDate).date(),
                                isReceived = true,
                                QuantityReceived = 1,
                                QuantitySent = 1,
                                Serialized_Item__c = woli.AssetId
                            );

                            productTransfersToInsert.add(newProductTransfer);
                        }

                        // Product/Asset Patient History creation

                        if(wo.Account_Treatment__c != null) {
                            Product_Asset_Patient_History__c newPAPH = new Product_Asset_Patient_History__c(
                                Account__c = wo.AccountId,
                                Account_Treatment__c = wo.Account_Treatment__c,
                                BatchNumber__c = woli.Batch_Number__c,
                                Date__c = (wo.EndDate).date(),
                                Product__c = woli.Product2Id,
                                Quantity__c = woli.QuantityDelivered__c,
                                Serialized_Item__c = woli.AssetId,
                                SerialNumber__c = woli.Serial_Number__c,
                                Type__c = 'Delivery',
                                Location__c = wo.LocationId
                            );

                            PAPHsToInsert.add(newPAPH);

                            // Updating related Asset

                            if(relatedAsset != null) {
                                relatedAsset.AssetServicedById = wo.AccountId;
                                relatedAsset.Account_Treatment__c = wo.Account_Treatment__c;
                                relatedAsset.LocationId = wo.LocationId;

                                assetsToUpdate.add(relatedAsset);
                            }
                        }
                        else {

                            // Updating related Asset

                            if(relatedAsset != null) {
                                relatedAsset.AssetServicedById = wo.AccountId;
                                relatedAsset.LocationId = wo.LocationId;

                                assetsToUpdate.add(relatedAsset);
                            }
                        }
                    }

                    // Batch and Consumable Delivery

                    else if(woli.Serial_Number__c == null && woli.AssetId == null) {
                        ProductItem relatedProductItemPatient;
                        
                        // Searching for the related Product Item Patient...

                        System.debug('allRelatedProductItemsPatients size: ' + allRelatedProductItemsPatients.size());
                        if(!allRelatedProductItemsPatients.isEmpty()) {
                            for(ProductItem pi : allRelatedProductItemsPatients) {
                                System.debug('pi.Product2Id: ' + pi.Product2Id);
                                System.debug('woli.product2Id: ' + woli.Product2Id);
                                System.debug('pi.BatchNumber__c: ' + pi.BatchNumber__c);
                                System.debug('woli.Batch_Number__c: ' + woli.Batch_Number__c);
                                System.debug('pi.LocationId: ' + pi.LocationId);
                                System.debug('wo.LocationId: ' + wo.LocationId);
                                System.debug('pi.SerialNumber: ' + pi.SerialNumber);

                                // Retrieving Product Item Patient for Batch Delivery

                                if(woli.Batch_Number__c != null) {
                                    if(pi.Product2Id == woli.Product2Id && pi.BatchNumber__c == woli.Batch_Number__c && pi.LocationId == wo.LocationId) {
                                        relatedProductItemPatient = pi;
                                        break;
                                    }
                                }

                                // Retrieving Product Item Patient for Consumable Delivery

                                else {
                                    if(pi.Product2Id == woli.Product2Id && pi.BatchNumber__c == null && pi.LocationId == wo.LocationId && pi.SerialNumber == null) {
                                        relatedProductItemPatient = pi;
                                        break;
                                    }
                                }

                            }
                        }
                        System.debug('relatedProductItemPatient: ' + relatedProductItemPatient);

                        // ... If found, updating it with the new QuantityOnHand...

                        if(relatedProductItemPatient != null) {
                            Boolean alreadyExistingItem = false;
                            for (ProductItem tempItem : productItemsToUpdate){
                                if (tempItem.Product2Id == woli.Product2Id && tempItem.BatchNumber__c == woli.Batch_Number__c) {
                                    tempItem.QuantityOnHand = tempItem.QuantityOnHand + woli.QuantityDelivered__c;
                                    alreadyExistingItem = true;
                                }
                            }
                            if (!alreadyExistingItem){
                                relatedProductItemPatient.QuantityOnHand = relatedProductItemPatient.QuantityOnHand + woli.QuantityDelivered__c;
                                productItemsToUpdate.add(relatedProductItemPatient);
                            }
                        } 

                        // ... If not, creating a new one

                        else {
                            Boolean alreadyExistingItem = false;
                            for (ProductItem tempItem : productItemsToInsert){
                                if (tempItem.Product2Id == woli.Product2Id && tempItem.BatchNumber__c == woli.Batch_Number__c) {
                                    tempItem.QuantityOnHand = tempItem.QuantityOnHand + woli.QuantityDelivered__c;
                                    alreadyExistingItem = true;
                                }
                            }
                            if (!alreadyExistingItem){
                                ProductItem newProductItem = new ProductItem(
                                    LocationId = wo.LocationId,
                                    Product2Id = woli.Product2Id,
                                    BatchNumber__c = woli.Batch_Number__c,
                                    Expired_Date__c = woli.ExpiryDate__c,
                                    QuantityOnHand = woli.QuantityDelivered__c
                                );
    
                                if(woli.Batch_Number__c != null) {
                                    newProductItem.SerialNumber = woli.Batch_Number__c + '_' + woli.Product2.Product_Code__c;
                                    newProductItem.Offset__c = woli.Offset__c;
                                }
    
                                productItemsToInsert.add(newProductItem);
                            }
                        }

                        // Product/Asset Patient History creation

                        if(wo.Account_Treatment__c != null) {
                            Product_Asset_Patient_History__c newPAPH = new Product_Asset_Patient_History__c(
                                Account__c = wo.AccountId,
                                Account_Treatment__c = wo.Account_Treatment__c,
                                BatchNumber__c = woli.Batch_Number__c,
                                Date__c = (wo.EndDate).date(),
                                Product__c = woli.Product2Id,
                                Quantity__c = woli.QuantityDelivered__c,
                                Serialized_Item__c = woli.AssetId,
                                SerialNumber__c = woli.Serial_Number__c,
                                Type__c = 'Delivery',
                                ExpiryDate__c = woli.ExpiryDate__c,
                                Location__c = wo.LocationId
                            );

                            PAPHsToInsert.add(newPAPH);
                        }
                    }

                    woli.Status = 'Completed';
                    WOLIsToUpdate.add(woli);
                }
            }

            // Removal

            else if(wo.Document_Type__c == 'ZRET' || wo.Document_Type__c == 'ZRNC') {
                for(WorkOrderLineItem woli : relatedWOLIs) {
                    ProductItem relatedProductItem = productItemMap.get(woli.AssetId);
                    Asset relatedAsset = assetMap.get(woli.AssetId);

                    // Serialized Item Removal

                    if(woli.Serial_Number__c != null && woli.AssetId != null && woli.Movement_Type__c == 'Removal (-)') {

                        // Product Transfer creation

                        if(relatedProductItem != null) {
                            ProductTransfer newProductTransfer = new ProductTransfer(
                                SourceProductItemId = relatedProductItem.Id,
                                SourceLocationId = relatedProductItem.LocationId,
                                DestinationLocationId = woli.StorageLocation__c,
                                Date__c = (wo.EndDate).date(),
                                isReceived = true,
                                QuantityReceived = 1,
                                QuantitySent = 1,
                                Serialized_Item__c = woli.AssetId
                            );

                            productTransfersToInsert.add(newProductTransfer);
                        }

                        // Product/Asset Patient History creation

                        if(wo.Account_Treatment__c != null) {
                            Product_Asset_Patient_History__c newPAPH = new Product_Asset_Patient_History__c(
                                Account__c = wo.AccountId,
                                Account_Treatment__c = wo.Account_Treatment__c,
                                BatchNumber__c = woli.Batch_Number__c,
                                Date__c = (wo.EndDate).date(),
                                Product__c = woli.Product2Id,
                                Quantity__c = woli.QuantityDelivered__c,
                                Serialized_Item__c = woli.AssetId,
                                SerialNumber__c = woli.Serial_Number__c,
                                Type__c = 'Removal',
                                Location__c = wo.LocationId
                            );

                            PAPHsToInsert.add(newPAPH);

                            // Updating related Asset

                            if(relatedAsset != null) {
                                relatedAsset.AssetServicedById = null;
                                relatedAsset.Account_Treatment__c = null;
                                relatedAsset.LocationId = woli.StorageLocation__c;

                                assetsToUpdate.add(relatedAsset);
                            }
                        }
                        else {
                            
                            // Updating related Asset

                            if(relatedAsset != null) {
                                relatedAsset.AssetServicedById = null;
                                relatedAsset.LocationId = woli.StorageLocation__c;

                                assetsToUpdate.add(relatedAsset);
                            }
                        }
                    }

                    // Batch and Consumable Removal

                    else if(woli.Serial_Number__c == null && woli.AssetId == null) {
                        ProductItem relatedProductItemPatient;
                        
                        System.debug('allRelatedProductItemsPatients size: ' + allRelatedProductItemsPatients.size());

                        // Searching for the related Product Item Patient...
                        if(!allRelatedProductItemsPatients.isEmpty()) {
                            for(ProductItem pi : allRelatedProductItemsPatients) {
                                System.debug('pi.Product2Id: ' + pi.Product2Id);
                                System.debug('woli.product2Id: ' + woli.Product2Id);
                                System.debug('pi.BatchNumber__c: ' + pi.BatchNumber__c);
                                System.debug('woli.Batch_Number__c: ' + woli.Batch_Number__c);
                                System.debug('pi.LocationId: ' + pi.LocationId);
                                System.debug('wo.LocationId: ' + wo.LocationId);
                                System.debug('pi.SerialNumber: ' + pi.SerialNumber);

                                // Retrieving Product Item Patient for Batch Removal

                                if(woli.Batch_Number__c != null) {
                                    if(pi.Product2Id == woli.Product2Id && pi.BatchNumber__c == woli.Batch_Number__c && pi.LocationId == wo.LocationId) {
                                        relatedProductItemPatient = pi;
                                        break;
                                    }
                                }

                                // Retrieving Product Item Patient for Consumable Removal

                                else {
                                    if(pi.Product2Id == woli.Product2Id && pi.BatchNumber__c == null && pi.LocationId == wo.LocationId && pi.SerialNumber == null) {
                                        relatedProductItemPatient = pi;
                                        break;
                                    }
                                }

                            }
                        }
                        System.debug('relatedProductItemPatient: ' + relatedProductItemPatient);

                        // ... If found, updating or deleting it

                        if(relatedProductItemPatient != null) {
                            Boolean alreadyDeletingItem = false;
                            for (ProductItem tempItem : productItemsToDelete){
                                if (tempItem.Product2Id == woli.Product2Id && tempItem.BatchNumber__c == woli.Batch_Number__c) {
                                    alreadyDeletingItem = true;
                                }
                            }
                            if (!alreadyDeletingItem) {
                                Boolean alreadyExistingItem = false;
                                for (Integer i = 0; i<productItemsToUpdate.size(); i++){
                                    if (productItemsToUpdate[i].Product2Id == woli.Product2Id && productItemsToUpdate[i].BatchNumber__c == woli.Batch_Number__c) {
                                        productItemsToUpdate[i].QuantityOnHand = productItemsToUpdate[i].QuantityOnHand - woli.QuantityDelivered__c;
                                        if (productItemsToUpdate[i].QuantityOnHand > 0){
                                            alreadyExistingItem = true;
                                        } else {
                                            alreadyExistingItem = true;
                                            productItemsToDelete.add(productItemsToUpdate[i]);
                                            productItemsToUpdate.remove(i);
                                        }
                                    }
                                }
                                if (!alreadyExistingItem){
                                    if((relatedProductItemPatient.QuantityOnHand - woli.QuantityDelivered__c) > 0) {
                                        relatedProductItemPatient.QuantityOnHand = (relatedProductItemPatient.QuantityOnHand - woli.QuantityDelivered__c);
                                        productItemsToUpdate.add(relatedProductItemPatient);
                                    }
                                    else /*if((relatedProductItemPatient.QuantityOnHand - woli.QuantityDelivered__c) == 0)*/ {
                                        productItemsToDelete.add(relatedProductItemPatient);
                                    }
                                }
                            }
                        }

                        // Product/Asset Patient History creation

                        if(wo.Account_Treatment__c != null) {
                            Product_Asset_Patient_History__c newPAPH = new Product_Asset_Patient_History__c(
                                Account__c = wo.AccountId,
                                Account_Treatment__c = wo.Account_Treatment__c,
                                BatchNumber__c = woli.Batch_Number__c,
                                Date__c = (wo.EndDate).date(),
                                Product__c = woli.Product2Id,
                                Quantity__c = woli.QuantityDelivered__c,
                                Serialized_Item__c = woli.AssetId,
                                SerialNumber__c = woli.Serial_Number__c,
                                Type__c = 'Removal',
                                ExpiryDate__c = woli.ExpiryDate__c,
                                Location__c = wo.LocationId
                            );
                            PAPHsToInsert.add(newPAPH);
                        }
                    }
                    woli.Status = 'Completed';
                    WOLIsToUpdate.add(woli);
                }
            }
        }
        System.debug('WOLIsToUpdate size: ' + WOLIsToUpdate.size());
        System.debug('productTransfersToInsert size: ' + productItemsToInsert.size());
        System.debug('PAPHsToInsert size: ' + PAPHsToInsert.size());
        System.debug('productItemsToInsert size: ' + productItemsToInsert.size());
        System.debug('productItemsToUpdate size: ' + productItemsToUpdate.size());
        System.debug('productItemsToDelete size: ' + productItemsToDelete.size());
        System.debug('assetsToUpdate size: ' + assetsToUpdate.size());

        if(!WOLIsToUpdate.isEmpty()) {
            update WOLIsToUpdate;
        }

        if(!productTransfersToInsert.isEmpty()) {
            insert productTransfersToInsert;
        }

        if(!PAPHsToInsert.isEmpty()) {
            insert PAPHsToInsert;
        }

        if(!productItemsToInsert.isEmpty()) {
            insert productItemsToInsert;
        }

        if(!productItemsToUpdate.isEmpty()) {
            update productItemsToUpdate;
        }

        if(!productItemsToDelete.isEmpty()) {
            delete productItemsToDelete;
        }

        if(!assetsToUpdate.isEmpty()) {
            update assetsToUpdate;
        }
    }
}