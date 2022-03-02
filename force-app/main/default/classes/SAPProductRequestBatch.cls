public without sharing class SAPProductRequestBatch implements Database.Batchable<sObject>, Schedulable, Database.AllowsCallouts{

    // OTTENGO COMUNQUE ECCEZIONE "YOU HAVE UNCOMMITED WORK PENDING"

    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Outbound_Delivery_Number__c, DestinationLocationId, DestinationLocation.Location_Id__c, ' +
        'SAP_Storage_Location__c, SAP_Plant__c, OwnerId, NeedByDate, Status, isSyncSAP__c, SAP_Storage_Location__r.Location_Id__c, ' +
        'SAP_Plant__r.Location_Id__c, BPResource__c, SourceLocation.Location_Id__c, Loading_Plant__r.Location_Id__c, ProductRequestNumber, RecordType.Name ' +
        'FROM ProductRequest WHERE isSyncSAP__c = \'NotSync\' AND Status = \'2\'';
        System.debug(query);
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<ProductRequest> productRequests) {
        if(FeatureManagementService.getFeatureStatus('SAP_Product_Request_Update_Batch') || Test.isRunningTest()) {
            List<ProductRequest> pickingLoadingCallout = new List<ProductRequest>();
            //List<ProductRequest> extraLoadingCallout = new List<ProductRequest>();
            List<Id> productRequestIds = new List<Id>();

            List<String> queryFields = new List<String>{'Id', 'Outbound_Delivery_Number__c', 'DestinationLocationId', 'DestinationLocation.Location_Id__c',
                'SAP_Storage_Location__c', 'SAP_Plant__c', 'OwnerId', 'NeedByDate', 'Status', 'isSyncSAP__c',
                'SAP_Storage_Location__r.Location_Id__c', 'SAP_Plant__r.Location_Id__c', 'BPResource__c', 'Loading_Plant__r.Location_Id__c', 'ProductRequestNumber'};

            List<String> queryFieldsForItem = new List<String>{'Status', 'ParentId', 'Product2.Product_Code__c', 'Batch_Number__c',
            'Serial_Number__c', 'Loaded_Quantity__c'};

            for(ProductRequest pr : productRequests) {
                productRequestIds.add(pr.Id);
            }
            
            List<ProductRequestLineItem> allPRLIs = ProductRequestLineItemDAO.getPRLIFromParentIds(queryFieldsForItem, productRequestIds);
            Map<Id, List<ProductRequestLineItem>> PRLIMap = new Map<Id, List<ProductRequestLineItem>>();
            List<Callout_Logger__c> loggersToInsert = new List<Callout_Logger__c>();
            List<ProductRequest> requestsToUpdate = new List<ProductRequest>();
            List<ProductRequestLineItem> PRLIsToUpdate = new List<ProductRequestLineItem>();
            
            if(!allPRLIs.isEmpty()) {
                for(ProductRequestLineItem prli : allPRLIs) {
                    if(PRLIMap.get(prli.ParentId) == null) {
                        PRLIMap.put(prli.ParentId, new List<ProductRequestLineItem>());
                    }
                    PRLIMap.get(prli.ParentId).add(prli);
                }
            }

            // TODO --> Call only the methods which do the callouts, then perform dml operations here
            for(ProductRequest pr : productRequests) {
                if(pr.Outbound_Delivery_Number__c != null) {
                    pickingLoadingCallout.add(pr);
                }
                /* else if(pr.Outbound_Delivery_Number__c == null && pr.RecordType.Name == 'ProductRequest_ExtraLoading') {
                    extraLoadingCallout.add(pr);
                } */
            }

            // Picking Loading

            if(!pickingLoadingCallout.isEmpty()) {
                List<Id> requestIdsToUpdate = new List<Id>();

                for(ProductRequest pr : pickingLoadingCallout) {
                    ProductRequestService.ReturnDTO dto = ProductRequestService.doUpdateCallout(pr);

                    for(Callout_Logger__c logger : dto.loggerList) {
                        loggersToInsert.add(logger);
                    }
                    for(Id requestId : dto.updatedIds) {
                        requestIdsToUpdate.add(requestId);
                    }

                }

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
            }

            // Extra Loading

            /* if(!extraLoadingCallout.isEmpty()) {
                List<Id> requestIdsToUpdate = new List<Id>();

                for(ProductRequest pr : extraLoadingCallout) {

                    List<ProductRequestLineItem> relatedPRLIs = PRLIMap.get(pr.Id);
                    System.debug('RelatedPRLIs size: ' + relatedPRLIs.size());

                    ProductRequestService.ReturnDTO dto = ProductRequestService.doUpdateCalloutExtraLoading(pr, relatedPRLIs);
                    
                    for(Callout_Logger__c logger : dto.loggerList) {
                        loggersToInsert.add(logger);
                    }
                    for(Id requestId : dto.updatedIds) {
                        requestIdsToUpdate.add(requestId);
                    }

                }

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
            } */
            
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
        }
    }

    public void finish(Database.BatchableContext bc) {
        system.debug('DONE'); //TODO
    }

    public static void Execute(SchedulableContext ctx) {
        Database.executeBatch(new SAPProductRequestBatch(), 5);
    }

}