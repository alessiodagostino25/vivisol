public class ProductRequestService {
    @future(callout=true)
    @AuraEnabled
    public static void futureUpdateCallout(List<Id> productRequestIds) {
        List<String> queryFields = new List<String>{'Id', 'Outbound_Delivery_Number__c', 'DestinationLocationId', 'DestinationLocation.Location_Id__c',
            'SAP_Storage_Location__c', 'SAP_Plant__c', 'OwnerId', 'NeedByDate', 'Status', 'isSyncSAP__c', 'Account.Account_External_Id__c',
            'SAP_Storage_Location__r.Location_Id__c', 'SAP_Plant__r.Location_Id__c', 'BPResource__c', 'Partner_Function__c'};

        List<String> queryFieldsForItem = new List<String>{'Status', 'ParentId', 'Product2.Product_Code__c', 'Batch_Number__c',
        'Serial_Number__c', 'Loaded_Quantity__c'};

        List<Callout_Logger__c> loggersToInsert = new List<Callout_Logger__c>();
        List<Delete_Older_Logs__e> deleteOlderLogsEvents = new List<Delete_Older_Logs__e>();
        List<Id> requestIdsToUpdate = new List<Id>();
        List<ProductRequest> requestsToUpdate = new List<ProductRequest>();
        List<ProductRequestLineItem> PRLIsToUpdate = new List<ProductRequestLineItem>();
        Map<Id, List<ProductRequestLineItem>> PRLIMap = new Map<Id, List<ProductRequestLineItem>>();
        
        List<ProductRequest> prList = ProductRequestDAO.getProductRequestsFromIds(queryFields, productRequestIds);
        List<ProductRequestLineItem> allPRLIs = ProductRequestLineItemDAO.getPRLIFromParentIds(queryFieldsForItem, productRequestIds);

        System.debug('AllPRLIs size: ' + allPRLIs.size());

        if(!allPRLIs.isEmpty()) {
            for(ProductRequestLineItem prli : allPRLIs) {
                if(PRLIMap.get(prli.ParentId) == null) {
                    PRLIMap.put(prli.ParentId, new List<ProductRequestLineItem>());
                }
                PRLIMap.get(prli.ParentId).add(prli);
            }
        }
        

        for(ProductRequest productRequest : prList) {
            ReturnDTO dto = doUpdateCallout(productRequest);
            
            for(Callout_Logger__c logger : dto.loggerList) {
                loggersToInsert.add(logger);
            }
            for(Id requestId : dto.updatedIds) {
                requestIdsToUpdate.add(requestId);
            }
            for(Delete_Older_Logs__e event : dto.deleteOlderLogsEvents) {
                deleteOlderLogsEvents.add(event);
            }
        }
        // If this part (moving this DAO call here) is working, apply to AccountService too. There is a SOQL query in a for cycle there too
        List<ProductRequest> updatedProductRequests = ProductRequestDAO.getProductRequestsFromIds(queryFields, requestIdsToUpdate);
        
        // Updating records as "Sync" if callout was successful
        for(ProductRequest pr : updatedProductRequests) {
            ProductRequest tempRequest = new ProductRequest();
            tempRequest.Id = pr.Id;
            tempRequest.isSyncSAP__c = 'Sync';
            
            requestsToUpdate.add(tempRequest);

            List<ProductRequestLineItem> relatedPRLIs = PRLIMap.get(pr.Id);

            if(relatedPRLIs != null) {
                for(ProductRequestLineItem prli : relatedPRLIs) {
                    prli.Status = '2';
                    PRLIsToUpdate.add(prli);
                }
            }
        }

        if(!loggersToInsert.isEmpty()) {
            insert loggersToInsert;
        }
        if(!requestsToUpdate.isEmpty()) {
            System.debug('Should update once isSyncSAP__c is created, but then add hasChanged method to avoid loop');
            update requestsToUpdate;
        }
        if(!PRLIsToUpdate.isEmpty()) {
            update PRLIsToUpdate;
        }
        if(!deleteOlderLogsEvents.isEmpty()) {
            List<Database.SaveResult> results = EventBus.publish(deleteOlderLogsEvents);
            System.debug('EVENTS PUBLISHED size: ' + results.size());
        }
    }

    // We will only perform a callout to Mulesoft if the Status changes
    public static Boolean hasChanged(ProductRequest request, ProductRequest oldRequest) {
        if(request.Status != oldRequest.Status) {
            return true;
        }
        if(request.Outbound_Delivery_Number__c != oldRequest.Outbound_Delivery_Number__c) {
            return true;
        }
    
        return false;
      }

    // Update callout to Mulesoft
    public static ReturnDTO doUpdateCallout(ProductRequest productRequest) {
        ProductRequestDTO dto = new ProductRequestDTO(productRequest);
        List<Id> updatedIds = new List<Id>();
        List<Callout_Logger__c> loggerList = new List<Callout_Logger__c>();
        List<Delete_Older_Logs__e> deleteOlderLogsEvents = new List<Delete_Older_Logs__e>();

        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:SAP_PRODUCT_REQUEST_UPDATE');
        req.setMethod('POST');
        req.setTimeout(70000);

        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');

        // create body request
        String reqJSON = JSON.serialize(dto);
        System.debug('DTO:::: ' + dto);
        System.debug(reqJSON);
        req.setBody(reqJSON);

        Http http = new Http();
        HTTPResponse res = new HttpResponse();

        // initialize timers
        Long startTime = Datetime.now().getTime();
        Long finishTime;
        Long totalTime;

        try {
            // Sending callout
            res = http.send(req);
            System.debug(res);
            System.debug(res.getBody());
            finishTime = Datetime.now().getTime();
            totalTime = (finishTime - startTime);
            String responseUnparsed = res.getBody();
            SAPResponseDTO responseDTO = (SAPResponseDTO) System.JSON.deserialize(responseUnparsed, SAPResponseDTO.class);

            // Creating Callout_Logger__c for each result with error or warning
            for(SAPResponseDTO.ResultList resList : responseDTO.resultList) {
                SAPResponseDTO.Log_event logEvent = resList.log_event;
                System.debug('CorrelationID: ' + resList.correlationID);
                if(logEvent.errorList != null) {
                    for(SAPResponseDTO.ErrorList errorList : logEvent.errorList) {
                        
                        Callout_Logger__c calloutLogger = CalloutLoggerService.initializeUpdateCalloutLog(String.valueOf(res.getStatusCode()), errorList.errorType, false, 
                        'ProductRequest', errorList.operation_Name, errorList.operationType, 'SFDC', 
                        productRequest.Id,
                        'SFDC_SAP4HANA__PICKING_LOADING_UPDATE',
                        Datetime.now(), errorList.uuid_Flow, errorList.error_Description, req.getBody(), 'SAP4HANA', 'FAIL');
                        System.debug('CALLOUT_LOGGER: ' + calloutLogger);
                        loggerList.add(calloutLogger);

                    }
                }
                if(logEvent.warningList != null) {
                    for(SAPResponseDTO.WarningList warningList : logEvent.warningList) {
                        
                        Callout_Logger__c calloutLogger = CalloutLoggerService.initializeUpdateCalloutLog(String.valueOf(res.getStatusCode()), warningList.errorType, false, 
                        'ProductRequest', warningList.operation_Name, warningList.operationType, 'SFDC', 
                        productRequest.Id, 
                        'SFDC_SAP4HANA__PICKING_LOADING_UPDATE', 
                        Datetime.now(), warningList.uuid_Flow, warningList.error_Description, req.getBody(), 'SAP4HANA', 'WARN');
                        System.debug('CALLOUT_LOGGER: ' + calloutLogger);
                        loggerList.add(calloutLogger);

                    }
                }
                
                if(resList.success == true) {
                    // Logic to update isSyncSAP__c ?
                    updatedIds.add(productRequest.Id);
                    System.debug('SUCCESS!!!');

                    // Deleting all Callout Loggers for this recordId if the call is a complete success (no error nor warning logs)

                    if(loggerList.isEmpty()) {
                        deleteOlderLogsEvents.add(
                            new Delete_Older_Logs__e(
                                Record_Id__c = productRequest.Id,
                                Service__c = 'SFDC_SAP4HANA__PICKING_LOADING_UPDATE'
                            )
                        );
                    }
                }
            }
        } 
        catch (Exception e) {
            System.debug('EXCEPTION!!!! : ' + e.getMessage());
            System.debug('Exception: ' + e);
            System.debug('Exception line number: ' + e.getLineNumber());

            Callout_Logger__c calloutLogger = CalloutLoggerService.initializeUpdateCalloutLog(
                null, 
                null, 
                false, 
                'ProductRequest', 
                'UPDATE', 
                'POST', 
                'SFDC', 
                productRequest.Id, 
                'SFDC_SAP4HANA__PICKING_LOADING_UPDATE', 
                Datetime.now(), 
                null, 
                e.getMessage(), 
                req.getBody(), 
                'SAP4HANA', 
                'FAIL'
            );

            loggerList.add(calloutLogger);
        }

        // Cannot insert records here (in for cycle). Need to return loggerlist to insert and ids to update as "Sync"
        ReturnDTO toReturn = new ReturnDTO(loggerList, updatedIds, deleteOlderLogsEvents);
          
        return toReturn;
    }

    // Class to return

    public class ReturnDTO {
        public List<Callout_Logger__c> loggerList;
        public List<Id> updatedIds;
        public List<Delete_Older_Logs__e> deleteOlderLogsEvents;
    
        public ReturnDTO(List<Callout_Logger__c> loggerList, List<Id> updatedIds, List<Delete_Older_Logs__e> deleteOlderLogsEvents) {
          this.loggerList = loggerList;
          this.updatedIds = updatedIds;
          this.deleteOlderLogsEvents = deleteOlderLogsEvents;
        }
    }

    // Launching VANUnloadingSAPFlow only on ProductRequests with Status = 1 and RecordType VanUnLoadfromSAP
    /**
     * TODO: TO BE REMOVED
     * */
    public static void launchVANUnloadingSAPFlow(List<Id> productRequestIds) {
        List<String> productRequestQueryFields = new List<String>{'RecordType.DeveloperName'};

        List<ProductRequest> allProductRequests = new List<ProductRequest>();
        List<Id> VANUnloadingProductRequestIds = new List<Id>();

        allProductRequests = ProductRequestDAO.getProductRequestsFromIds(productRequestQueryFields, productRequestIds);

        if(!allProductRequests.isEmpty()) {
            for(ProductRequest pr : allProductRequests) {
                if(pr.RecordType.DeveloperName == 'ProductRequest_VanUnLoadfromSAP') {
                    VANUnloadingProductRequestIds.add(pr.Id);
                }
            }

            if(!VANUnloadingProductRequestIds.isEmpty()) {
                for(Id productRequestId : VANUnloadingProductRequestIds) {
                    VanUnloadingSAPFlowController.productRequestId = productRequestId;
                    VanUnloadingSAPFlowController.start();
                }
            }
        }
    }

    /**
     * @description: this method UNLOADS the van
     */
    public static void launchVANUnloadingSAP(List<Id> productRequestIds) {
        List<String> productRequestQueryFields = new List<String>{'RecordType.DeveloperName'};
        List<String> VANUnloadingProductRequestIds = new List<String>();

        List<ProductRequest> allProductRequests = new List<ProductRequest>();
        allProductRequests = ProductRequestDAO.getProductRequestsFromIds(productRequestQueryFields, productRequestIds);
        if(!allProductRequests.isEmpty()) {
            for(ProductRequest pr : allProductRequests) {
                if(pr.RecordType.DeveloperName == 'ProductRequest_VanUnLoadfromSAP') {
                    VANUnloadingProductRequestIds.add(pr.Id);
                }
            }
        }

        if(!VANUnloadingProductRequestIds.isEmpty()){
            List<VanUnloadingInvocable.Request> requests = new  List<VanUnloadingInvocable.Request>();
            for(Id pr : VANUnloadingProductRequestIds) {
                VanUnloadingInvocable.Request tmp = new VanUnloadingInvocable.Request();
                tmp.productRequestId = pr;
                requests.add(tmp);
            }
            VanUnloadingInvocable.unloadVAN(requests);
        }
    }


    /**
     * @description: this method LOADS the van
     */
    public static void launchVANLoadingInventory(List<Id> productRequestIds) {
        List<String> productRequestQueryFields = new List<String>{'RecordType.DeveloperName', 'SourceLocationId'};
        List<String> productRequestInventoryIds = new List<String>();

        List<ProductRequest> allProductRequests = new List<ProductRequest>();
        allProductRequests = ProductRequestDAO.getProductRequestsFromIds(productRequestQueryFields, productRequestIds);
        if(!allProductRequests.isEmpty()) {
            for(ProductRequest pr : allProductRequests) {
                if(pr.RecordType.DeveloperName == 'ProductRequest_Inventory') {
                    productRequestInventoryIds.add(pr.Id);
                }
            }
        }

        if(!productRequestInventoryIds.isEmpty()){
            List<VanLoadingInvocable.Request> requests = new  List<VanLoadingInvocable.Request>();
            for(Id pr : productRequestIds) {
                VanLoadingInvocable.Request tmp = new VanLoadingInvocable.Request();
                tmp.productRequestId = pr;
                requests.add(tmp);
            }
            VanLoadingInvocable.loadVAN(requests);
        }
    }

    /**
     * @description: this method unloads the van
     */
    public static void launchVANUnloadingInventory(List<Id> productRequestIds) {
        List<String> productRequestQueryFields = new List<String>{'RecordType.DeveloperName', 'SourceLocationId'};
        List<String> productItemQueryFields = new List<String>{'Serialized_Item__c', 'BatchNumber__c', 'HU__c', 'Barcode_Label__c', 'Product2Id',
        'QuantityUnitOfMeasure', 'LocationId'};
        List<String> locationQueryFields = new List<String>{'Id'};

        List<ProductRequest> allProductRequests = new List<ProductRequest>();
        List<Id> inventoryProductRequestIds = new List<Id>();
        List<String> sourceLocationIdIds = new List<String>();
        List<ProductItem> allProductItems = new List<ProductItem>();
        List<ProductItem> productItemsToUpdate = new List<ProductItem>();
        List<ProductItem> productItemsToDelete = new List<ProductItem>();
        List<ProductTransfer> createdPTs = new List<ProductTransfer>();
        List<Schema.Location> defaultLocations = new List<Schema.Location>(); 


        allProductRequests = ProductRequestDAO.getProductRequestsFromIds(productRequestQueryFields, productRequestIds);

        if(!allProductRequests.isEmpty()) {
            for(ProductRequest pr : allProductRequests) {
                if(pr.RecordType.DeveloperName == 'ProductRequest_Inventory') {
                    inventoryProductRequestIds.add(pr.Id);
                    sourceLocationIdIds.add(pr.SourceLocationId);
                }
            }
        }

        if (!sourceLocationIdIds.isEmpty()){
            allProductItems = ProductItemDAO.getProductItemsFromLocationIds(productItemQueryFields, sourceLocationIdIds);
            defaultLocations = LocationDAO.getLocationsFromExternalId(locationQueryFields, '6300');
        }
        for (ProductItem pi : allProductItems){
            if (pi.Serialized_Item__c != null && pi.BatchNumber__c == null && pi.HU__c == null){
                createdPTs.add(createPT(pi, defaultLocations[0]));
            } else if (pi.Serialized_Item__c != null && pi.BatchNumber__c == null && pi.HU__c != null) {
                createdPTs.add(createPT(pi, defaultLocations[0]));
                pi.HU__c = null;
                productItemsToUpdate.add(pi);
            } else if (pi.Serialized_Item__c != null && pi.BatchNumber__c != null && pi.HU__c == null) {
                createdPTs.add(createPT(pi, defaultLocations[0]));
                pi.BatchNumber__c = null;
                productItemsToUpdate.add(pi);
            } else if (pi.Serialized_Item__c != null && pi.BatchNumber__c != null && pi.HU__c != null) {
                createdPTs.add(createPT(pi, defaultLocations[0]));
                pi.BatchNumber__c = null;
                pi.HU__c = null;
                productItemsToUpdate.add(pi);
            } else if (pi.Serialized_Item__c == null){
                productItemsToDelete.add(pi);
            }
        }

        if (!createdPTs.isEmpty()){
            insert createdPTs;
        }
        if (!productItemsToDelete.isEmpty()){
            delete productItemsToDelete;
        }   
        if (!productItemsToUpdate.isEmpty()){
            update productItemsToUpdate;
        }        
    }

    private static ProductTransfer createPT (ProductItem pi, Schema.Location destinationLocation){
        ProductTransfer tmpTransfer = new ProductTransfer();
        tmpTransfer.Date__c = Date.today();
        tmpTransfer.Label__c = pi.Barcode_Label__c;
        tmpTransfer.Product2Id = pi.Product2Id;
        tmpTransfer.QuantityReceived = 1;
        tmpTransfer.QuantitySent = 1;
        tmpTransfer.QuantityUnitOfMeasure = pi.QuantityUnitOfMeasure;
        tmpTransfer.IsReceived = true;
        tmpTransfer.Serialized_Item__c = pi.Serialized_Item__c;
        tmpTransfer.SourceLocationId = pi.LocationId;
        tmpTransfer.SourceProductItemId = pi.Id;
        tmpTransfer.Status = 'Completato';
        tmpTransfer.ExpectedPickupDate = Datetime.now();
        tmpTransfer.DestinationLocationId = destinationLocation.Id;


        return tmpTransfer;
    }

    @AuraEnabled
    public static ProductRequest getProductRequestFromId(String relatedId){
        List<String> queryFields = new List<String>{'IsSyncSAP__c'};

        List<ProductRequest> productRequests = ProductRequestDAO.getProductRequestsFromIds(queryFields, new List<String>{relatedId});

        return productRequests[0];
    }

    @AuraEnabled
    public static void setProductRequestSyncStatus(String relatedId, String syncStatus){
        List<String> queryFields = new List<String>{'IsSyncSAP__c'};

        List<ProductRequest> productRequests = ProductRequestDAO.getProductRequestsFromIds(queryFields, new List<String>{relatedId});
        ProductRequest productRequest = productRequests[0];

        productRequest.isSyncSAP__c = syncStatus;

        update productRequest;
    }

    public static void updateSalesOrgCode(List<ProductRequest> productRequests) {
        List<String> locationQueryFields = new List<String>{'Location_Id__c'};

        List<String> plantIds = new List<String>();
        List<Schema.Location> plants = new List<Schema.Location>();

        Map<String, Schema.Location> plantMap = new Map<String, Schema.Location>();

        for(ProductRequest pr : productRequests) {
            if(pr.Loading_Plant__c != null) {
                plantIds.add(pr.Loading_Plant__c);
            }
        }

        if(!plantIds.isEmpty()) {
            plants = LocationDAO.getLocationsFromIds(locationQueryFields, plantIds);

            if(!plants.isEmpty()) {
                for(Schema.Location plant : plants) {
                    plantMap.put(plant.Id, plant);
                }
            }

            for(ProductRequest pr : productRequests) {
                Schema.Location relatedPlant = plantMap.get(pr.Loading_Plant__c);

                if(relatedPlant != null) {
                    pr.Sales_Org_Code__c = relatedPlant.Location_Id__c;
                }
            }
        }
    }

    public static void setSourceLocationUnderInventory(List<ProductRequest> productRequests, Boolean value) {
        List<String> locationQueryFields = new List<String>{'Under_Inventory__c'};

        List<String> sourceLocationIds = new List<String>();
        List<Schema.Location> relatedSourceLocations = new List<Schema.Location>();

        RecordType inventoryRT = [SELECT Id FROM RecordType WHERE DeveloperName = 'ProductRequest_Inventory'];

        for(ProductRequest pr : productRequests) {
            if(pr.RecordTypeId == inventoryRT.Id) {
                sourceLocationIds.add(pr.SourceLocationId);
            }
        }

        if(!sourceLocationIds.isEmpty()) {
            relatedSourceLocations = LocationDAO.getLocationsFromIds(locationQueryFields, sourceLocationIds);

            if(!relatedSourceLocations.isEmpty()) {
                for(Schema.Location location : relatedSourceLocations) {
                    location.Under_Inventory__c = value;
                }

                List<Database.SaveResult> results = Database.update(relatedSourceLocations);
            }
        }
    }

    // This method is used from SAP LWC to decide which type of update to try (productRequestIds contains only one Id)

    @AuraEnabled
    public static void handleProductRequestUpdate(List<String> productRequestIds) {
        ProductRequest productRequest = [SELECT RecordType.DeveloperName, IsSyncSAP__c FROM ProductRequest WHERE Id =: productRequestIds[0]];

        if(productRequest != null) {
            // Performing callout

            if(productRequest.RecordType.DeveloperName == 'ProductRequest_PickingList') {
                System.debug('Performing callout...');

                futureUpdateCallout(productRequestIds);
            }

            // Updating to Sync and sending event (the record will be updated back to NotSync in case errors are raised)

            else if(productRequest.RecordType.DeveloperName == 'Van_Unloading') {
                System.debug('Publishing event...');

                productRequest.isSyncSAP__c = 'Sync';

                update productRequest;

                Van_Unloading_Event__e event = new Van_Unloading_Event__e(
                    Id_Item__c = productRequestIds[0],
                    Is_Total__c = true
                );

                Database.SaveResult result = EventBus.publish(event);
            }
            else {
                System.debug('ProductRequest was not PickingList or VanUnloading and was ignored by the component');
            }
        }
    }

    public static void shareProductRequestRecords(List<String> recordIds, String groupDeveloperName, String groupType, String accessLevel) {
        List<ProductRequestShare> toInsert = new List<ProductRequestShare>();

        Group groupToShareWith = [SELECT Id FROM Group WHERE DeveloperName =: groupDeveloperName AND Type =: groupType];

        if(groupToShareWith != null) {
            for(String recordId : recordIds) {
                ProductRequestShare shareObject = new ProductRequestShare(
                    ParentId = recordId,
                    UserOrGroupId = groupToShareWith.Id,
                    AccessLevel = accessLevel
                );

                toInsert.add(shareObject);

                System.debug('shareObject: ' + shareObject);
                System.debug('Inserting ProductRequestShare...');
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