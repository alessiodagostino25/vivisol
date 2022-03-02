public with sharing class ProductRequestRelatedListController {
    @AuraEnabled
    public static List<ProductRequestCardDTO> getProductRequests(Integer queryLimit) {
        System.debug('----- getProductRequests -----');

        List<ProductRequestCardDTO> toReturn = new List<ProductRequestCardDTO>();
        List<String> destinationLocationIds = new List<String>();

        Map<Id, List<ServiceTerritoryMember>> productRequestToSTMListMap = new Map<Id, List<ServiceTerritoryMember>>();

        Id currentUserId = UserInfo.getUserId();

        // Retrieving ProductRequests with RecordType = PicklingList

        List<ProductRequest> allPickingLists = [SELECT ProductRequestNumber, SourceLocationId, DestinationLocationId, NeedByDate, Outbound_Delivery_Number__c, OwnerId,
                                               SourceLocation.Name, DestinationLocation.Name 
                                               FROM ProductRequest 
                                               WHERE RecordType.DeveloperName = 'ProductRequest_PickingList' 
                                               AND Status = '1'
                                               LIMIT: queryLimit];
        
        if(!allPickingLists.isEmpty()) {
            for(ProductRequest pr : allPickingLists) {
                destinationLocationIds.add(pr.DestinationLocationId);
            }

            // Retrieving all the ServiceTerritoryMembers linked to the current User and the retrieved DestLocationIds

            List<ServiceTerritoryMember> STMs = [SELECT Id, ServiceTerritory.Warehouse__c FROM ServiceTerritoryMember 
                                                WHERE ServiceResource.RelatedRecordId =: currentUserId
                                                AND EffectiveStartDate <= TODAY
                                                AND EffectiveEndDate >= TODAY
                                                AND ServiceTerritory.Warehouse__c IN: destinationLocationIds];

            for(ServiceTerritoryMember stm : STMs) {
                if(productRequestToSTMListMap.get(stm.ServiceTerritory.Warehouse__c) == null) {
                    productRequestToSTMListMap.put(stm.ServiceTerritory.Warehouse__c, new List<ServiceTerritoryMember>());
                }
                productRequestToSTMListMap.get(stm.ServiceTerritory.Warehouse__c).add(stm);
            }

            for(ProductRequest pr : allPickingLists) {
                System.debug('currentUserId: ' + currentUserId);
                System.debug('pr.OwnerId: ' + pr.OwnerId);

                List<ServiceTerritoryMember> relatedSTMs = new List<ServiceTerritoryMember>();

                if(!productRequestToSTMListMap.isEmpty()) {
                    relatedSTMs = productRequestToSTMListMap.get(pr.DestinationLocationId);
                }

                // I will return this PR only if it is related to the currentUser OR to a technical User but with a Destination Location linked to a Service Territory the user belongs to
                
                if((pr.OwnerId == currentUserId) || (!relatedSTMs.isEmpty())) {
                    ProductRequestCardDTO dto = new ProductRequestCardDTO(
                        pr.Id,
                        pr.ProductRequestNumber,
                        pr.SourceLocationId,
                        pr.SourceLocation.Name,
                        pr.DestinationLocationId,
                        pr.DestinationLocation.Name,
                        pr.NeedByDate,
                        pr.Outbound_Delivery_Number__c,
                        pr.OwnerId
                    );

                    toReturn.add(dto);
                }
            }
        }

        System.debug('productRequestDTOs toReturn: ' + toReturn.size());
        return toReturn;
    }
}