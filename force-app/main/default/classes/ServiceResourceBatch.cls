public class ServiceResourceBatch implements Database.Batchable<sObject>, Schedulable{
	public Database.QueryLocator start(Database.BatchableContext bc){
		String query = 'select Id,New_Van_Assignement_Date__c,NextLocation__c,LocationId From ServiceResource WHERE New_Van_Assignement_Date__c != null AND NextLocation__c != null AND New_Van_Assignement_Date__c > TODAY  ';
		System.debug(query);
		return Database.getQueryLocator(query);
	}

	public void execute(Database.BatchableContext bc, List<ServiceResource> ServiceResources){
		List<ServiceResource> finalServiceResources = new List<ServiceResource>();
		List<ServiceResource> srGreaterthanTomorow = new List<ServiceResource>();
		List<ServiceResource> srEqualTomorow = new List<ServiceResource>();
		for (ServiceResource sr : ServiceResources){
			if (sr.NextLocation__c != sr.LocationId){
				finalServiceResources.add(sr);
			}
		}
		List<Id> resourceids = new List<Id>();
		List<Id> locationIds = new List<Id>();
		List<Id> nextlocationIds = new List<Id>();


		for (ServiceResource fsr : finalServiceResources){
			resourceids.add(fsr.Id);
			locationIds.add(fsr.NextLocation__c);
			if (fsr.New_Van_Assignement_Date__c > date.today().addDays(1)){
				srGreaterthanTomorow.add(fsr);
			}
			if (fsr.New_Van_Assignement_Date__c == date.today().addDays(1)){
                srEqualTomorow.add(fsr);
            }
		}
		for (ServiceResource fsr : srEqualTomorow){
			nextlocationIds.add(fsr.NextLocation__c);
		}
		List<String> queryfieldsforsr = new List<String>{'Id', 'LocationId '};
		List<ServiceResource> serviceResourceRecords = ServiceResourceDAO.getServiceResourcesFromlocationIds(queryfieldsforsr, nextlocationIds);
		Map<Id, ServiceResource> nextLocationAndsrRecord = new Map<Id, ServiceResource>();
		for (ServiceResource sr : serviceResourceRecords){
			nextLocationAndsrRecord.put(sr.LocationId, sr);
		}
		List<String> queryfieldsforlocation = new List<String>{'Id', 'ParentLocationId', 'Plant__c'};
		List<Schema.Location> locations = LocationDAO.getLocationsFromIds(queryfieldsforlocation, locationIds);
		Map<Id, Schema.Location> Locationmap = new Map<Id, Schema.Location>();
		for (Schema.Location l : locations){
			Locationmap.put(l.Id, l);
		}
		List<String> queryfields = new List<String>{'Id', 'SAScheduledStart__c ', 'Status ', 'Resource__c', 'Source_Location__c ', 'SAP_Plant__c ', 'SAP_Storage_Location__c'};
		List<WorkOrder> workOrders = WorkOrderDAO.getWorkOrdersFromResourceId(queryfields, resourceids);
		Map<Id, List<WorkOrder>> resourceidAndWorkOrder = new Map<Id, List<WorkOrder>>();
		for (WorkOrder wo : workOrders){
			if (resourceidAndWorkOrder.get(wo.Resource__c) == null){
				resourceidAndWorkOrder.put(wo.Resource__c, new List<WorkOrder>());
			}
			resourceidAndWorkOrder.get(wo.Resource__c).add(wo);
		}

		List<WorkOrder> updateWorkOrders = new List<WorkOrder>();
		List<ServiceResource> updateServiceResource = new List<ServiceResource>();
		List<ServiceResource> updateServiceResource1 = new List<ServiceResource>();

		for (ServiceResource fsr : srEqualTomorow){
			Schema.Location nextlocation = Locationmap.get(fsr.NextLocation__c);

			if (nextLocationAndsrRecord.containskey(fsr.NextLocation__c)){
				ServiceResource sr = nextLocationAndsrRecord.get(fsr.NextLocation__c);
				sr.LocationId = null;
				updateServiceResource1.add(sr);
			}

			if (resourceidAndWorkOrder.containskey(fsr.Id)){
				List<WorkOrder> workordersfrommap = resourceidAndWorkOrder.get(fsr.Id);
	
				for (WorkOrder wom : workordersfrommap){
					if (wom.SAScheduledStart__c >= fsr.New_Van_Assignement_Date__c){
						if (wom.Source_Location__c != fsr.NextLocation__c){

							wom.Source_Location__c = nextlocation.Id;
							wom.SAP_Plant__c = nextlocation.Plant__c;
							wom.SAP_Storage_Location__c = nextlocation.ParentLocationId;
							updateWorkOrders.add(wom);
						}
					}
				}
			}

			fsr.LocationId = fsr.NextLocation__c;
			fsr.New_Van_Assignement_Date__c = null;
			fsr.NextLocation__c = null;
			updateServiceResource.add(fsr);

		}
		for (ServiceResource fsr : srGreaterthanTomorow){
			Schema.Location nextlocation = Locationmap.get(fsr.NextLocation__c);
			if (resourceidAndWorkOrder.containskey(fsr.Id)){
				List<WorkOrder> workordersfrommap = resourceidAndWorkOrder.get(fsr.Id);
				for (WorkOrder wom : workordersfrommap){
					if (wom.SAScheduledStart__c >= fsr.New_Van_Assignement_Date__c){
						if (wom.Source_Location__c != fsr.NextLocation__c){

							wom.Source_Location__c = nextlocation.Id;
							wom.SAP_Plant__c = nextlocation.Plant__c;
							wom.SAP_Storage_Location__c = nextlocation.ParentLocationId;
							updateWorkOrders.add(wom);

						}
					}
				}
			}

		}


		if (!updateWorkOrders.isEmpty()){
			update updateWorkOrders;
		}

		if (!updateServiceResource1.isEmpty()){
			update updateServiceResource1;
		}

		if (!updateServiceResource.isEmpty()){
			update updateServiceResource;
		}
	}

	public void finish(Database.BatchableContext bc){
		system.debug('DONE');
	}

	public static void Execute(SchedulableContext ctx){
		Database.executeBatch(new ServiceResourceBatch()); //TODO
	}

}