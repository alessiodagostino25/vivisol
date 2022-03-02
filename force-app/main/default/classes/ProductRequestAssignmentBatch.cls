global class ProductRequestAssignmentBatch implements Database.Batchable<sObject>, Schedulable {

    public Database.QueryLocator start(Database.BatchableContext bc){
        String statusPR = '1';
        String productRequestRT = 'ProductRequest_PickingList';
		String query = 'select DestinationLocationId, OwnerId From ProductRequest WHERE status = :statusPR AND RecordType.DeveloperName = :productRequestRT';
		System.debug(query);
		return Database.getQueryLocator(query);
	}

	public void execute(Database.BatchableContext bc, List<ProductRequest> queriedRequests){
		List<Id> productRequestLocations = new List<Id>();
        for (ProductRequest pr : queriedRequests){
            productRequestLocations.add(pr.DestinationLocationId);
        }
        List<ServiceResource> resources = new List<ServiceResource>();
        List<String> queryfieldsforsr = new List<String>{'LocationId', 'RelatedRecordId'};
        resources = ServiceResourceDAO.getServiceResourcesFromlocationIds(queryfieldsforsr, productRequestLocations);
        Map<String,ServiceResource> resourceLocationMap = new  Map<String,ServiceResource>();
        for (ServiceResource res : resources){
            resourceLocationMap.put(res.LocationId, res);
        }
        List<ProductRequest> updatePR = new List<ProductRequest>();
        for (ProductRequest pr : queriedRequests){
            ServiceResource tmp = resourceLocationMap.get(pr.DestinationLocationId);
            if (tmp != null){
                if (tmp.RelatedRecordId != pr.OwnerId){
                    pr.OwnerId = tmp.RelatedRecordId;
                    updatePR.add(pr);
                }
            }
        }
        if (!updatePR.isEmpty()){
            update updatePR;
        }
	}

	public void finish(Database.BatchableContext bc){
		system.debug('DONE');
	}

	public static void Execute(SchedulableContext ctx){
		Database.executeBatch(new ProductRequestAssignmentBatch()); //TODO
	}
}