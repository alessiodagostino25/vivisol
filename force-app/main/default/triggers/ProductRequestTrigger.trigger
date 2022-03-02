trigger ProductRequestTrigger on ProductRequest (before insert, after insert, before update, after update) {

    if(Trigger.isBefore && Trigger.isInsert) {
        ProductRequestService.updateSalesOrgCode(Trigger.new);
    }
    
    // Adding to the list of ProductRequest records to send to SAP
    if(Trigger.isBefore && Trigger.isUpdate) {
        //List<String> toShareNetherlandsIds = new List<String>();

        if(FeatureManagementService.getFeatureStatus('SAP_Product_Request_Update') || Test.isRunningTest()) {
            List<Id> calloutIds = new List<Id>();
            List<ProductRequestLineItem> relatedPRLI = new List<ProductRequestLineItem>();
            RecordType pickingListRT = [SELECT Id FROM RecordType WHERE DeveloperName = 'ProductRequest_PickingList'];

            for(ProductRequest pr : Trigger.New) {
                if(ProductRequestService.hasChanged(pr, Trigger.oldMap.get(pr.Id)) && pr.Status == '2' && pr.Outbound_Delivery_Number__c != null && 
                pr.RecordTypeId == pickingListRT.Id) {
                    System.debug('Request valida per callout');
                    pr.isSyncSAP__c = 'NotSync';
                    // Integrate logic for isSyncSAP__c? With hasChanged method in case
                    calloutIds.add(pr.Id);
                }
                else {
                    System.debug('Request non valida per callout');
                    System.debug('hasChanged = ' + ProductRequestService.hasChanged(pr, Trigger.oldMap.get(pr.Id)));
                    System.debug('Status: ' + pr.Status);
                    System.debug('Outbound_Delivery_Number__c: ' + pr.Outbound_Delivery_Number__c);
                }
            }

            // Calling Service class method to perform Mulesoft callout
            if(!calloutIds.isEmpty()) {
                // This also updates Status of related ProductRequestLineItems
                ProductRequestService.futureUpdateCallout(calloutIds);
            }
        }

        /* for(ProductRequest pr : Trigger.new) {
            ProductRequest oldRecord = Trigger.oldMap.get(pr.Id);

            if(pr.Sales_Org_Code__c == '6300' && (oldRecord.OwnerId != pr.OwnerId)) {
                toShareNetherlandsIds.add(pr.Id);
            }
        }

        // When OwnerId changes, all the sharing records get reset, so I need to share the record again

        if(!toShareNetherlandsIds.isEmpty()) {
            ProductRequestService.shareProductRequestRecords(toShareNetherlandsIds, 'NL_6300', 'RoleAndSubordinates', 'Edit');
        } */
    }

    if(Trigger.isAfter && Trigger.isInsert) {
        //List<Id> forVANUnloadingInventoryFlow = new List<Id>();
        List<ProductRequest> toSetLocationUnderInventory = new List<ProductRequest>();
        List<ProductRequest> toUnsetLocationUnderInventory = new List<ProductRequest>();
        List<Id> forVANUnloadingInventoryFlow = new List<Id>();
        List<Id> forVANLoadingInventoryFlow = new List<Id>();
        List<String> toShareNetherlandsIds = new List<String>();

        for(ProductRequest pr : Trigger.new) {
            if(pr.Status == '0') {
                //forVANUnloadingInventoryFlow.add(pr.Id);
                toSetLocationUnderInventory.add(pr);
            }
            else if(pr.Status == '1') {
                forVANUnloadingInventoryFlow.add(pr.Id);
                forVANLoadingInventoryFlow.add(pr.Id);
                toUnsetLocationUnderInventory.add(pr);
            }
            else if(pr.Status == '3') {
                toUnsetLocationUnderInventory.add(pr);
            }

            if(pr.Sales_Org_Code__c == '6300') {
                toShareNetherlandsIds.add(pr.Id);
            }
        }

        if(!toSetLocationUnderInventory.isEmpty()) {
            ProductRequestService.setSourceLocationUnderInventory(toSetLocationUnderInventory, true);
        }

        if(!forVANUnloadingInventoryFlow.isEmpty()) {
            ProductRequestService.launchVANUnloadingInventory(forVANUnloadingInventoryFlow);
        }

        if(!forVANLoadingInventoryFlow.isEmpty()) {
            ProductRequestService.launchVANLoadingInventory(forVANLoadingInventoryFlow);
        }

        if(!toUnsetLocationUnderInventory.isEmpty()) {
            ProductRequestService.setSourceLocationUnderInventory(toUnsetLocationUnderInventory, false);
        }

        if(!toShareNetherlandsIds.isEmpty()) {
            ProductRequestService.shareProductRequestRecords(toShareNetherlandsIds, 'NL_6300', 'RoleAndSubordinates', 'Edit');
        }
    }

    if(Trigger.isAfter && Trigger.isUpdate) {
        //List<Id> calloutIds = new List<Id>();
        List<ProductRequestLineItem> relatedPRLI = new List<ProductRequestLineItem>();
        List<String> queryFields = new List<String>{'Status', 'Outbound_Delivery_Number__c', 'RecordType.Name'};
        List<Id> relatedIds = new List<Id>();
        List<Id> relatedPRLIIds = new List<Id>();
        List<Id> forVANUnloadingSAPFlow = new List<Id>();
        List<Id> forVANUnloadingInventoryFlow = new List<Id>();
        List<Id> forVANLoadingInventoryFlow = new List<Id>();
        List<ProductRequest> toSetLocationUnderInventory = new List<ProductRequest>();
        List<ProductRequest> toUnsetLocationUnderInventory = new List<ProductRequest>();
        List<String> toShareNetherlandsIds = new List<String>();

        for(ProductRequest pr : Trigger.new) {
            relatedIds.add(pr.Id);

            if(Trigger.oldMap.get(pr.Id).Status != '1' && pr.Status == '1') {
                forVANUnloadingSAPFlow.add(pr.Id);
                forVANUnloadingInventoryFlow.add(pr.Id);
                forVANLoadingInventoryFlow.add(pr.Id);
                toUnsetLocationUnderInventory.add(pr);
            }
            else if(Trigger.oldMap.get(pr.Id).Status != '0' && pr.Status == '0') {
                //forVANUnloadingInventoryFlow.add(pr.Id);
                toSetLocationUnderInventory.add(pr);
            }
            else if(Trigger.oldMap.get(pr.Id).Status != '3' && pr.Status == '3') {
                toUnsetLocationUnderInventory.add(pr);
            }

            if(pr.Sales_Org_Code__c == '6300' && (Trigger.oldMap.get(pr.Id).OwnerId != pr.OwnerId)) {
                toShareNetherlandsIds.add(pr.Id);
            }
        }

        // This method will launch the flow only on PR with Status = 1 and RecordType = VANUnLoadfromSAP

        if(!forVANUnloadingSAPFlow.isEmpty()) {
            //ProductRequestService.launchVANUnloadingSAPFlow(forVANUnloadingSAPFlow);
            ProductRequestService.launchVANUnloadingSAP(forVANUnloadingSAPFlow);
        }

        // This method will launch the flow only on PR with Status = 1 and RecordType = ProductRequest_Inventory

        if(!forVANUnloadingInventoryFlow.isEmpty()) {
            //ProductRequestService.launchVANUnloadingInventoryFlow(forVANUnloadingInventoryFlow);
            ProductRequestService.launchVANUnloadingInventory(forVANUnloadingInventoryFlow);
        }

        // This method will launch the flow only on PR with Status = 1 and RecordType = ProductRequest_Inventory

        if(!forVANLoadingInventoryFlow.isEmpty()) {
            ProductRequestService.launchVANLoadingInventory(forVANLoadingInventoryFlow);
        }

        if(!toSetLocationUnderInventory.isEmpty()) {
            ProductRequestService.setSourceLocationUnderInventory(toSetLocationUnderInventory, true);
        }

        if(!toUnsetLocationUnderInventory.isEmpty()) {
            ProductRequestService.setSourceLocationUnderInventory(toUnsetLocationUnderInventory, false);
        }

        List<ProductRequest> productRequests = ProductRequestDAO.getProductRequestsFromIds(queryFields, relatedIds);
        for(ProductRequest pr : productRequests) {
            if(ProductRequestService.hasChanged(pr, Trigger.oldMap.get(pr.Id)) && pr.Status == '2' && pr.Outbound_Delivery_Number__c == null 
               && pr.RecordType.Name == 'ProductRequest_ExtraLoading') {
                System.debug('Request valida per callout');
                pr.isSyncSAP__c = 'NotSync';
                //calloutIds.add(pr.Id);
            }
        }

        // When OwnerId changes, all the sharing records get reset, so I need to share the record again

        if(!toShareNetherlandsIds.isEmpty()) {
            ProductRequestService.shareProductRequestRecords(toShareNetherlandsIds, 'NL_6300', 'RoleAndSubordinates', 'Edit');
        }
    }
}