public class ProductTransferTriggerService {
    
    public static void updateRelatedProductItems(List<ProductTransfer> productTransfers) {
        List<String> productItemQueryFields = new List<String>{'Id', 'Status__c', 'Serialized_Item__c', 'Serialized_Item__r.Product2Id', 'LocationId',
        'Serialized_Item__r.SerialNumber', 'BatchNumber__c'};
        List<String> PAPHQueryFields = new List<String>{'Account_Treatment__c', 'Serialized_Item__c', 'Date__c', 'Type__c', 'Account_Treatment__r.Account__c'};
        List<String> assetQueryFields = new List<String>{'Account_Treatment__c', 'LocationId', 'AssetServicedById'};
        List<String> ATQueryFields = new List<String>{'Account__c'};
        List<String> locationQueryFields = new List<String>{'Account__c'};

        List<Id> productItemIds = new List<Id>();
        List<Id> relatedAssetIds = new List<Id>();
        List<Id> relatedATIds = new List<Id>();
        List<Id> destinationLocationIds = new List<Id>();

        List<Product_Asset_Patient_History__c> PAPHsToInsert = new List<Product_Asset_Patient_History__c>();
        List<Asset> assetsToUpdate = new List<Asset>();

        Map<Id, ProductItem> productItemMap = new Map<Id, ProductItem>();
        Map<Id, List<Product_Asset_Patient_History__c>> assetIdTOPAPHsMap = new Map<Id, List<Product_Asset_Patient_History__c>>();
        Map<Id, Asset> assetMap = new Map<Id, Asset>();
        Map<Id, Account_Treatment__c> accountTreatmentMap = new Map<Id, Account_Treatment__c>();
        Map<Id, Schema.Location> destinationLocationMap = new Map<Id, Schema.Location>();

        for(ProductTransfer pt : productTransfers) {
            destinationLocationIds.add(pt.DestinationLocationId);
            if(pt.SourceProductItemId != null) {
                productItemIds.add(pt.SourceProductItemId);
            }
        }   

        // Getting all the ProductItems related to the Product Transfers
        List<ProductItem> relatedProductItems = ProductItemDAO.getProductItemsFromIds(productItemQueryFields, productItemIds);
        System.debug('productItemIds size: ' + productItemIds.size());
        System.debug('productItemIds: ' + productItemIds);
        System.debug('relatedProductItems size: ' + relatedProductItems.size());
        System.debug('CPU consumed ---  STEP 3: ' + Limits.getCpuTime());

        if(relatedProductItems != null) {
            for(ProductItem pi : relatedProductItems) {
                productItemMap.put(pi.Id, pi);
                relatedAssetIds.add(pi.Serialized_Item__c);
            }
        }

        // Getting all the Assets related to the Product Items
        List<Asset> relatedAssets = AssetDAO.getAssetsFromIds(assetQueryFields, relatedAssetIds);
        System.debug('relatedAssets size: ' + relatedAssets);
        System.debug('CPU consumed ---  STEP 4: ' + Limits.getCpuTime());

        if(relatedAssets != null) {
            for(Asset a : relatedAssets) {
                assetMap.put(a.Id, a);
            }
        }

        // Getting all the PAPH related to the Assets
        List<Product_Asset_Patient_History__c> allPAPHs = ProductAssetPatientHistoryDAO.getPAPHFromAssetIds(PAPHQueryFields, relatedAssetIds);

        // Building a Asset.Id --> List<related PAPHs> Map
        if(!allPAPHs.isEmpty()) {
            for(Product_Asset_Patient_History__c paph : allPAPHs) {
                relatedATIds.add(paph.Account_Treatment__c);
                if(assetIdTOPAPHsMap.get(paph.Serialized_Item__c) == null) {
                    assetIdTOPAPHsMap.put(paph.Serialized_Item__c, new List<Product_Asset_Patient_History__c>());
                }
                assetIdTOPAPHsMap.get(paph.Serialized_Item__c).add(paph);
            }
        }

        System.debug('CPU consumed ---  STEP 5: ' + Limits.getCpuTime());
        // Getting all the Destination Locations related to the Product Transfers
        List<Schema.Location> destinationLocations = LocationDAO.getLocationsFromIds(locationQueryFields, destinationLocationIds);

        System.debug('CPU consumed ---  STEP 6: ' + Limits.getCpuTime());
        if(destinationLocations != null) {
            for(Schema.Location l : destinationLocations) {
                destinationLocationMap.put(l.Id, l);
            }
        }

        List<Account_Treatment__c> allRelatedATs = AccountTreatmentDAO.getAccountTreatmentsFromIds(ATQueryFields, relatedATIds);

        if(allRelatedATs != null) {
            for(Account_Treatment__c at : allRelatedATs) {
                accountTreatmentMap.put(at.Id, at);
            }
        }

        System.debug('CPU consumed ---  STEP 7: ' + Limits.getCpuTime());

        for(ProductTransfer pt : productTransfers) {
            ProductItem relatedProductItem = productItemMap.get(pt.SourceProductItemId);
            System.debug('relatedProductItem: ' + relatedProductItem);

            if(relatedProductItem != null) {
                Asset assetRelatedToProductItem = assetMap.get(relatedProductItem.Serialized_Item__c);
                Schema.Location relatedDestinationLocation = destinationLocationMap.get(pt.DestinationLocationId);

                List<Product_Asset_Patient_History__c> relatedPAPHs = assetIdTOPAPHsMap.get(relatedProductItem.Serialized_Item__c);
                Map<Id, List<Product_Asset_Patient_History__c>> ATIdTOPAPHsMap = new Map<Id, List<Product_Asset_Patient_History__c>>();

                if(relatedPAPHs != null) {
                    for(Product_Asset_Patient_History__c paph : relatedPAPHs) {
                        if(ATIdTOPAPHsMap.get(paph.Account_Treatment__c) == null) {
                            ATIdTOPAPHsMap.put(paph.Account_Treatment__c, new List<Product_Asset_Patient_History__c>());
                        }
                        ATIdTOPAPHsMap.get(paph.Account_Treatment__c).add(paph);
                    }
                }

                // Updating the Status of the related Product Item

                if(pt.Return__c == true) {
                    if(relatedProductItem.Status__c != 'NotValid') {
                        relatedProductItem.Status__c = 'NotValid';

                        if(relatedProductItem.BatchNumber__c != null) {
                            relatedProductItem.BatchNumber__c = null;
                        }
                    }
                }
                else if(pt.Return__c == false) {
                    if(relatedProductItem.Status__c == 'NotValid') {
                        relatedProductItem.Status__c = 'Valid';
                    }
                }
                if(pt.IsReceived == false) {
                    if(relatedPAPHs != null && !ATIdTOPAPHsMap.isEmpty()) {

                        PAPHsToInsert = createNewPAPHs(ATIdTOPAPHsMap, accountTreatmentMap, assetMap, pt, relatedProductItem);

                    }
                }
                else if(pt.isReceived == true) {
                    if(assetRelatedToProductItem != null) {

                        // Updating relatedAsset's LocationId

                        assetRelatedToProductItem.LocationId = pt.DestinationLocationId;

                        if(relatedDestinationLocation != null) {
                            if(relatedDestinationLocation.Account__c != null) {

                                // Updating the Account Id on Asset with the one on the Destination Location

                                assetRelatedToProductItem.AssetServicedById = relatedDestinationLocation.Account__c;
                            }
                            else if(relatedDestinationLocation.Account__c == null && assetRelatedToProductItem.AssetServicedById != null) {

                                // Blanking the Account Id on the Asset if it is empty on the Destination Location...

                                assetRelatedToProductItem.AssetServicedById = null;

                                if(assetRelatedToProductItem.Account_Treatment__c != null) {

                                    // ... And same for the Account Treatment

                                    assetRelatedToProductItem.Account_Treatment__c = null;

                                    if(relatedPAPHs != null && !ATIdTOPAPHsMap.isEmpty()) {
                                        
                                        PAPHsToInsert = createNewPAPHs(ATIdTOPAPHsMap, accountTreatmentMap, assetMap, pt, relatedProductItem);

                                    }
                                }
                            }
                        }

                        assetsToUpdate.add(assetRelatedToProductItem);
                    }
                }
            }
            System.debug('CPU consumed ---  STEP 8: ' + Limits.getCpuTime());
        }
        System.debug('CPU consumed ---  STEP 9: ' + Limits.getCpuTime());
        if(relatedProductItems != null) {
            update relatedProductItems;
        }
        System.debug('CPU consumed ---  STEP 10: ' + Limits.getCpuTime());

        if(!PAPHsToInsert.isEmpty()) {
            insert PAPHsToInsert;
        }
        System.debug('CPU consumed ---  STEP 11: ' + Limits.getCpuTime());
        if(!assetsToUpdate.isEmpty()) {
            update assetsToUpdate;
        }
    }

    /* Each Product Transfer has a Product Item with an Asset linked. Having retrieved all the PAPHs related to the Asset Id, and having built
    an AccountTreatmentId --> List<relatedPAPHs> Map, this method creates a new PAPH for each Account Treatment if certain conditions are met. */

    public static List<Product_Asset_Patient_History__c> createNewPAPHs(Map<Id, List<Product_Asset_Patient_History__c>> ATIdTOPAPHsMap, 
    Map<Id, Account_Treatment__c> accountTreatmentMap, Map<Id, Asset> assetMap, ProductTransfer pt, ProductItem relatedProductItem) {
        List<Product_Asset_Patient_History__c> PAPHsToInsert = new List<Product_Asset_Patient_History__c>();

        for(Id accountTreatmentId : ATIdTOPAPHsMap.keySet()) {
            Account_Treatment__c relatedAccountTreatment = accountTreatmentMap.get(accountTreatmentId);
            List<Product_Asset_Patient_History__c> PAPHsRelatedToAT = ATIdTOPAPHsMap.get(accountTreatmentId);

            if(PAPHsRelatedToAT != null) {
                List<Product_Asset_Patient_History__c> unmatchedRemovals = new List<Product_Asset_Patient_History__c>();
                List<Product_Asset_Patient_History__c> unmatchedDeliveries = new List<Product_Asset_Patient_History__c>();

                // For each AT, checking if each Removal PAPH is matched with a Delivery one...

                for(Product_Asset_Patient_History__c paph : PAPHsRelatedToAT) {
                    System.debug('-------------------------- Date: ' + paph.Date__c);
                    System.debug('-------------------------- Type: ' + paph.Type__c);

                    if(paph.Date__c != null && paph.Type__c == 'Removal') {
                        if(unmatchedDeliveries.size() > 0) {
                            unmatchedDeliveries.remove(unmatchedDeliveries.size() - 1);
                        }
                        else {
                            unmatchedRemovals.add(paph);
                        }
                    }
                    else if(paph.Date__c != null && paph.Type__c == 'Delivery') {
                        if(unmatchedRemovals.size() > 0) {
                            unmatchedRemovals.remove(unmatchedRemovals.size() - 1);
                        }
                        else {
                            unmatchedDeliveries.add(paph);
                        }
                    }

                }

                // ... If some PAPHs aren't matched, check for them if the relatedAsset.Account_Treatment == accountTreatmentId...

                if(unmatchedRemovals.size() > 0 || unmatchedDeliveries.size() > 0) {
                    Boolean createNewPAPH = false;
                    List<Product_Asset_Patient_History__c> unmatchedHistories = new List<Product_Asset_Patient_History__c>();

                    if(unmatchedRemovals.size() > 0) {
                        unmatchedHistories = unmatchedRemovals;
                    }
                    else if(unmatchedDeliveries.size() > 0) {
                        unmatchedHistories = unmatchedDeliveries;
                    }

                    if(!unmatchedHistories.isEmpty()) {
                        for(Product_Asset_Patient_History__c paph : unmatchedHistories) {
                            Asset relatedAsset = assetMap.get(paph.Serialized_Item__c);

                            if(relatedAsset != null) {
                                if(relatedAsset.Account_Treatment__c != accountTreatmentId) {
                                    createNewPAPH = true;
                                    break;
                                }
                            }
                        }
                    }

                    // ... If one still doesn't meet the requirements, create a new PAPH
                    
                    if(createNewPAPH == true) {
                        Product_Asset_Patient_History__c newPAPH = new Product_Asset_Patient_History__c(
                            Date__c = pt.Date__c,
                            Serialized_Item__c = relatedProductItem.Serialized_Item__c,
                            Product__c = relatedProductItem.Serialized_Item__r.Product2Id,
                            Quantity__c = 1,
                            Account_Treatment__c = accountTreatmentId,
                            Account__c = relatedAccountTreatment.Account__c,
                            SerialNumber__c = relatedProductItem.Serialized_Item__r.SerialNumber,
                            Type__c = 'Removal'
                        );

                        PAPHsToInsert.add(newPAPH);
                    }
                }
            }
        }

        return PAPHsToInsert;
    }

    public static void updateSalesOrgCode(List<ProductTransfer> productTransfers) {
        List<String> locationQueryFields = new List<String>{'Sales_Org_Code__c'};

        List<String> sourceLocationIds = new List<String>();
        List<Schema.Location> sourceLocations = new List<Schema.Location>();

        Map<String, Schema.Location> sourceLocationMap = new Map<String, Schema.Location>();

        for(ProductTransfer pt : productTransfers) {
            if(pt.SourceLocationId != null) {
                sourceLocationIds.add(pt.SourceLocationId);
            }
        }

        if(!sourceLocationIds.isEmpty()) {
            sourceLocations = LocationDAO.getLocationsFromIds(locationQueryFields, sourceLocationIds);

            if(!sourceLocations.isEmpty()) {
                for(Schema.Location location : sourceLocations) {
                    sourceLocationMap.put(location.Id, location);
                }
            }

            for(ProductTransfer pt : productTransfers) {
                Schema.Location relatedSourceLocation = sourceLocationMap.get(pt.SourceLocationId);

                if(relatedSourceLocation != null) {
                    pt.Sales_Org_Code__c = relatedSourceLocation.Sales_Org_Code__c;
                }
            }
        }
    }

    public static void shareProductTransferRecords(List<String> recordIds, String groupDeveloperName, String groupType, String accessLevel) {
        List<ProductTransferShare> toInsert = new List<ProductTransferShare>();

        Group groupToShareWith = [SELECT Id FROM Group WHERE DeveloperName =: groupDeveloperName AND Type =: groupType];

        if(groupToShareWith != null) {
            for(String recordId : recordIds) {
                ProductTransferShare shareObject = new ProductTransferShare(
                    ParentId = recordId,
                    UserOrGroupId = groupToShareWith.Id,
                    AccessLevel = accessLevel
                );

                toInsert.add(shareObject);

                System.debug('shareObject: ' + shareObject);
                System.debug('Inserting ProductTransferShare...');
            }
        }

        if(!toInsert.isEmpty()) {
            try {
                List<Database.SaveResult> results = Database.insert(toInsert);
            }
            catch(DmlException e) {
                if(e.getMessage().contains('AccessLevel')) {
                    System.debug('Exception ignored: trying to grant lower access level than object\'s default');
                }
            }
        }
    }
}