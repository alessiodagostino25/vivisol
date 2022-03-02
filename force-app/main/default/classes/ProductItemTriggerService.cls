public class ProductItemTriggerService {
    
    public class PIException extends Exception {}

    public static List<Picklist_Choise_Set_Flow__c> checkAndCreatePCSF(List<ProductItem> productItems) { 
        List<String> PCSFQueryFields = new List<String>{'Parent_Id__c', 'Value__c', 'Code__c'};

        List<Id> locationIds = new List<Id>();
        List<String> productCodes = new List<String>();
        List<String> families = new List<String>();
        List<Picklist_Choise_Set_Flow__c> toInsert = new List<Picklist_Choise_Set_Flow__c>();

        for(ProductItem pi : productItems) {
            if(pi.LocationId != null) {
                locationIds.add(pi.LocationId);
            }

            if(pi.Family__c != null) {
                families.add(pi.Family__c);
            }

            if(pi.Product_Code__c != null) {
                productCodes.add(pi.Product_Code__c);
            }
        }

        if(!locationIds.isEmpty() && !families.isEmpty() && !productCodes.isEmpty()) {

            // Getting all the PCSFs with Parent_Id IN locationIds and Value IN families

            List<Picklist_Choise_Set_Flow__c> familyPCSFs = PicklistChoiseSetFlowDAO.getFamilyPCSFsFromParentAndValue(PCSFQueryFields, locationIds, families);
            List<Picklist_Choise_Set_Flow__c> productPCSFs = PicklistChoiseSetFlowDAO.getProductPCSFsFromParentAndValue(PCSFQueryFields, locationIds, productCodes);

            System.debug('familyPCSFs size: ' + familyPCSFs.size());
            System.debug('productPCSFs size: ' + productPCSFs.size());

            // Checking the Family PCSFs and eventually creating a new one...

            if(familyPCSFs.size() != 0) {
                for(ProductItem pi : productItems) {
                    Picklist_Choise_Set_Flow__c relatedPCSF;

                    // Searching for the PCSF related to this PI...

                    for(Picklist_Choise_Set_Flow__c pcsf : familyPCSFs) {
                        System.debug('pcsf.Parent_Id__c: ' + pcsf.Parent_Id__c);
                        System.debug('pi.LocationId: ' + pi.LocationId);
                        if(pcsf.Parent_Id__c == pi.LocationId && pcsf.Code__c == pi.Family__c) {
                            relatedPCSF = pcsf;
                            break;
                        }
                    }

                    // ... If not found, create a new one

                    if(relatedPCSF == null) {
                        Picklist_Choise_Set_Flow__c newPCSF = new Picklist_Choise_Set_Flow__c(
                            Parent_Id__c = pi.LocationId,
                            Value__c = pi.Family_Name__c,
                            Code__c = pi.Family__c,
                            Type__c = 'F',
                            Location__c = pi.LocationId
                        );

                        toInsert.add(newPCSF);
                    }
                }
            }

            // If no PCSFs were found at all, then create a new one for each PI

            else {
                for(ProductItem pi : productItems) {
                    Picklist_Choise_Set_Flow__c newPCSF = new Picklist_Choise_Set_Flow__c(
                        Parent_Id__c = pi.LocationId,
                        Value__c = pi.Family_Name__c,
                        Code__c = pi.Family__c,
                        Type__c = 'F',
                        Location__c = pi.LocationId
                    );

                    toInsert.add(newPCSF);
                }
            }

            // Checking the Product PCSFs and eventually creating a new one...

            if(productPCSFs.size() != 0) {
                for(ProductItem pi : productItems) {
                    Picklist_Choise_Set_Flow__c relatedPCSF;

                    // Searching for the PCSF related to this PI...

                    for(Picklist_Choise_Set_Flow__c pcsf : productPCSFs) {
                        System.debug('pcsf.Parent_Id__c: ' + pcsf.Parent_Id__c);
                        System.debug('pi.LocationId: ' + pi.LocationId);
                        if(pcsf.Parent_Id__c == pi.LocationId && pcsf.Code__c == pi.Product_Code__c) {
                            relatedPCSF = pcsf;
                            break;
                        }
                    }

                    // ... If not found, create a new one

                    if(relatedPCSF == null) {
                        Picklist_Choise_Set_Flow__c newPCSF = new Picklist_Choise_Set_Flow__c(
                            Parent_Id__c = pi.LocationId,
                            Value__c = pi.Product_Name_Transalate__c,
                            Code__c = pi.Product_Code__c,
                            Type__c = 'P',
                            Location__c = pi.LocationId
                        );

                        toInsert.add(newPCSF);
                    }
                }
            }

            // If no PCSFs were found at all, then create a new one for each PI

            else {
                for(ProductItem pi : productItems) {
                    Picklist_Choise_Set_Flow__c newPCSF = new Picklist_Choise_Set_Flow__c(
                        Parent_Id__c = pi.LocationId,
                        Value__c = pi.Product_Name_Transalate__c,
                        Code__c = pi.Product_Code__c,
                        Type__c = 'P',
                        Location__c = pi.LocationId
                    );

                    toInsert.add(newPCSF);
                }
            }
        }

        System.debug('ProductItemTriggerService, toInsert size: ' + toInsert.size());
        return toInsert;
    }

    public static List<Picklist_Choise_Set_Flow__c> checkAndGetPCSFToDelete(List<ProductItem> productItems) {
        System.debug('In checkAndGetPCSFToDelete...');
        List<String> productItemQueryFields = new List<String>{'LocationId', 'Family_Name__c', 'Family__c', 'Product_Code__c'};
        List<String> PCSFQueryFields = new List<String>{'Parent_Id__c', 'Value__c'};

        List<Id> productItemIds = new List<Id>();
        List<Id> locationIds = new List<Id>();
        List<String> productCodes = new List<String>();
        List<String> families = new List<String>();
        List<Picklist_Choise_Set_Flow__c> toDelete = new List<Picklist_Choise_Set_Flow__c>();

        for(ProductItem pi : productItems) {
            productItemIds.add(pi.Id);

            if(pi.LocationId != null) {
                System.debug('pi.LocationId: ' + pi.LocationId);
                locationIds.add(pi.LocationId);
            }

            if(pi.Family__c != null) {
                families.add(pi.Family__c);
            }
            
            if(pi.Product_Code__c != null) {
                productCodes.add(pi.Product_Code__c);
            }
         }

        // I can only delete a PCSF if there is no other PI with same LocationId and FamilyName as the deleted one

        if(!productItemIds.isEmpty() && !locationIds.isEmpty() && !families.isEmpty() && !productCodes.isEmpty()) {

            // Getting all the other ProductItems with same LocationId and FamilyName/Product2Id (and SerializedItem = null)

            List<ProductItem> otherFamilyProductItems = ProductItemDAO.getOtherFamilyProductItems(productItemQueryFields, productItemIds, locationIds, families);
            List<ProductItem> otherSingleProductItems = ProductItemDAO.getOtherSingleProductItems(productItemQueryFields, productItemIds, locationIds, productCodes);

            System.debug('otherFamilyProductItems size: ' + otherFamilyProductItems.size());
            System.debug('otherSingleProductItems size: ' + otherSingleProductItems.size());

            // OtherFamilyProductItems

            // If there are other PIs, when I find the PI that has same Location and FamilyName of the deleted one, I remove its values from the ones of the PCSFs to remove

            if(otherFamilyProductItems.size() != 0) {
                List<Id> tmpLocationIds = locationIds.clone();
                List<String> tmpFamilies = families;

                for(ProductItem oldProductItem : productItems) {
                    for(ProductItem pi : otherFamilyProductItems) {

                        // Looking for the PI with same LocationId and FamilyName...

                        if(pi.LocationId == oldProductItem.LocationId && pi.Family__c == oldProductItem.Family__c) {

                            // ... When found, remove its LocationId and FamilyName from the ones which I will use to get the PCSFs to delete

                            Integer toRemoveLocation = tmpLocationIds.indexOf(oldProductItem.LocationId);
                            Integer toRemoveFamily = tmpFamilies.indexOf(oldProductItem.Family__c);

                            tmpLocationIds.remove(toRemoveLocation);
                            tmpFamilies.remove(toRemoveFamily);

                            break;
                        }
                    }
                }

                List<Picklist_Choise_Set_Flow__c> toDeleteTmp = PicklistChoiseSetFlowDAO.getFamilyPCSFsFromParentAndValue(PCSFQueryFields, tmpLocationIds, tmpFamilies);

                for(Picklist_Choise_Set_Flow__c pcsf : toDeleteTmp) {
                    toDelete.add(pcsf);
                }
            }

            // If there are no other PIs at all, then delete all the PCSF linked to the deleted PIs

            else {
                // Getting all the PCSFs with Parent_Id IN locationIds and Value IN familyNames
                List<Picklist_Choise_Set_Flow__c> toDeleteTmp = PicklistChoiseSetFlowDAO.getFamilyPCSFsFromParentAndValue(PCSFQueryFields, locationIds, families);

                for(Picklist_Choise_Set_Flow__c pcsf : toDeleteTmp) {
                    toDelete.add(pcsf);
                }
            }

            // OtherSingleProductItems

            // If there are other PIs, when I find the PI that has same Location and Product2Id of the deleted one, I remove its values from the ones of the PCSFs to remove

            if(otherSingleProductItems.size() != 0) {
                List<Id> tmpLocationIds = locationIds.clone();
                List<String> tmpProductCodes = productCodes;

                for(ProductItem oldProductItem : productItems) {
                    for(ProductItem pi : otherSingleProductItems) {

                        // Looking for the PI with same LocationId and Product2Id...

                        if(pi.LocationId == oldProductItem.LocationId && pi.Product_Code__c == oldProductItem.Product_Code__c) {

                            // ... When found, remove its LocationId and Product2Id from the ones which I will use to get the PCSFs to delete

                            Integer toRemoveLocation = tmpLocationIds.indexOf(oldProductItem.LocationId);
                            Integer toRemoveProduct = tmpProductCodes.indexOf(oldProductItem.Product_Code__c);

                            tmpLocationIds.remove(toRemoveLocation);
                            tmpProductCodes.remove(toRemoveProduct);

                            break;
                        }
                    }
                }

                List<Picklist_Choise_Set_Flow__c> toDeleteTmp = PicklistChoiseSetFlowDAO.getProductPCSFsFromParentAndValue(PCSFQueryFields, tmpLocationIds, tmpProductCodes);

                for(Picklist_Choise_Set_Flow__c pcsf : toDeleteTmp) {
                    toDelete.add(pcsf);
                }
            }

            // If there are no other PIs at all, then delete all the PCSF linked to the deleted PIs

            else {
                // Getting all the PCSFs with Parent_Id IN locationIds and Value IN productIds
                System.debug('productCodes: ' + productCodes);
                System.debug('locationIds: ' + locationIds);

                List<Picklist_Choise_Set_Flow__c> toDeleteTmp = PicklistChoiseSetFlowDAO.getProductPCSFsFromParentAndValue(PCSFQueryFields, locationIds, productCodes);
                System.debug('toDeleteTmp: ' + toDeleteTmp);

                for(Picklist_Choise_Set_Flow__c pcsf : toDeleteTmp) {
                    toDelete.add(pcsf);
                }
            }
        }

        System.debug('ProductItemTriggerService, toDelete size: ' + toDelete.size());
        return toDelete;
    }

    public static List<ProductItem> updateRelatedContainerField(List<ProductItem> productItems) {
        List<String> productItemQueryFields = new List<String>{'RelatedProductItem__r.Serialized_Item__c'};

        List<String> productItemIds = new List<String>();
        List<ProductItem> queriedProductItems = new List<ProductItem>();
        List<ProductItem> toUpdate = new List<ProductItem>();

        for(ProductItem pi : productItems) {
            productItemIds.add(pi.Id);
        }

        queriedProductItems = ProductItemDAO.getProductItemsFromIds(productItemQueryFields, productItemIds);

        if(!queriedProductItems.isEmpty()) {
            for(ProductItem pi : queriedProductItems) {
                ProductItem tmp = new ProductItem();

                tmp.Id = pi.Id;
                tmp.RelatedContainer__c = pi.RelatedProductItem__r.Serialized_Item__c;

                toUpdate.add(tmp);
            }
        }

        return toUpdate;
    }

    public static List<ProductItem> updateRelatedItem(List<ProductItem> productItems) {
        List<String> productItemQueryFields = new List<String>{'BatchNumber__c', 'RelatedProductItem__c'};

        List<String> relatedItemIds = new List<String>();
        List<String> productItemIds = new List<String>();
        List<ProductItem> relatedItems = new List<ProductItem>();
        List<ProductItem> toUpdate = new List<ProductItem>();
        List<ProductItem> PIsWithSameRelatedItem = new List<ProductItem>();

        Map<String, ProductItem> relatedItemMap = new Map<String, ProductItem>();

        for(ProductItem pi : productItems) {
            relatedItemIds.add(pi.RelatedProductItem__c);
            productItemIds.add(pi.Id);
        }

        relatedItems = ProductItemDAO.getProductItemsFromIds(productItemQueryFields, relatedItemIds);
        PIsWithSameRelatedItem = ProductItemDAO.getProductItemsWithSameRelatedItem(productItemQueryFields, relatedItemIds, productItemIds);

        if(!relatedItems.isEmpty()) {
            for(ProductItem pi : relatedItems) {
                relatedItemMap.put(pi.Id, pi);
            }

            for(ProductItem pi : productItems) {
                ProductItem relatedItem = relatedItemMap.get(pi.RelatedProductItem__c);

                if(relatedItem != null) {
                    relatedItem.BatchNumber__c = pi.BatchNumber__c;

                    toUpdate.add(relatedItem);
                }
            }

            if(!PIsWithSameRelatedItem.isEmpty()) {
                for(ProductItem pi : PIsWithSameRelatedItem) {
                    pi.RelatedProductItem__c = null;

                    toUpdate.add(pi);
                }
            }
        }

        return toUpdate;
    }

    public static void updateSalesOrgCode(List<ProductItem> productItems) {
        List<String> locationQueryFields = new List<String>{'Sales_Org_Code__c'};

        List<Group> netherlandsGroupList = [SELECT Id FROM Group WHERE DeveloperName = 'Netherlands_6300'];
        Group netherlandsGroup;
        List<String> locationIds = new List<String>();
        List<Schema.Location> relatedLocations = new List<Schema.Location>();

        Map<String, Schema.Location> locationMap = new Map<String, Schema.Location>();

        if(netherlandsGroupList != null && !netherlandsGroupList.isEmpty()) {
            netherlandsGroup = netherlandsGroupList[0];
        }

        for(ProductItem pi : productItems) {
            if(pi.LocationId != null) {
                locationIds.add(pi.LocationId);
            }
        }

        if(!locationIds.isEmpty()) {
            relatedLocations = LocationDAO.getLocationsFromIds(locationQueryFields, locationIds);

            if(!relatedLocations.isEmpty()) {
                for(Schema.Location location : relatedLocations) {
                    locationMap.put(location.Id, location);
                }
            }

            for(ProductItem pi : productItems) {
                Schema.Location relatedLocation = locationMap.get(pi.LocationId);

                if(relatedLocation != null) {
                    pi.Sales_Org_Code__c = relatedLocation.Sales_Org_Code__c;

                    if(relatedLocation.Sales_Org_Code__c == '6300' && netherlandsGroup != null) {
                        pi.OwnerId = netherlandsGroup.Id;
                    }
                }
            }
        }
    }
    
    public static void throwSerializedItemCustomException() {
        String exceptionlabel =  System.Label.ProductItemSerializedItem_Exception;
        throw new PIException(exceptionlabel);
    }

    public static void setOldExternalId(List<ProductItem> productItems) {
        for(ProductItem productItem : productItems) {
            productItem.OLDExternalID__c = productItem.SerialNumber;
        }
    }
}