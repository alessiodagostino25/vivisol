public class MaintenanceWorkOrderBatch implements Database.Batchable<sObject>, Schedulable{
	
	public Database.QueryLocator start(Database.BatchableContext bc){
		//query to get all the work orders based on conditions 
		String DeveloperName = 'AccountTreatment_Maintenance';
		List<String> statusValues = new List<String>();
		statusValues.add('In progress');
		statusValues.add('On Hold');
		statusValues.add('Completed');
		statusValues.add('Cannot Complete');
		statusValues.add('Canceled');
		String query = 'select Id,Account_Treatment__r.RecordType.Name,Status,AssetId,LocationId,Street,PostalCode,StateCode,CountryCode,CaseId,EndDate,TaskCreated__c,City From WorkOrder  Where Account_Treatment__r.RecordType.DeveloperName =:DeveloperName AND Status NOT IN :statusvalues AND AssetId != null ';
		System.debug(query);
		return Database.getQueryLocator(query);
	}

	public void execute(Database.BatchableContext bc, List<WorkOrder> workOrders){
		/* List<Id> assetIds = new List<Id>();
		List<Id> locationIds = new List<Id>();
		List<Task> createTasks = new List<Task>();
		List<WorkOrder> workOrderUpdate = new List<WorkOrder>();
		Map<Id, Id> workOrderIdandassetId = new Map<Id, Id>();
		Group Preplanner_NL = [Select Id
		                       from Group
		                       WHERE Name = 'Preplanner_NL' and  Type = 'Queue'];
		for (Integer i = 0; i < workOrders.size(); i++){
			assetIds.add(workOrders[i].AssetId);
			workOrderIdandassetId.put(workOrders[i].Id, workOrders[i].AssetId);
		}
		List<Asset> assets = AssetDAO.getAssetbyId(assetIds);
		Map<Id, Id> assetIdandlocationId = new Map<Id, Id>();
		for (Integer i = 0; i < assets.size(); i++){
			locationIds.add(assets[i].LocationId);
			assetIdandlocationId.put(assets[i].Id, assets[i].LocationId);
		}
		List<Schema.Location> locations = LocationDAO.getvisitoraddressFromlocationid(locationIds);
		Map<Id, Schema.Location> locationIdandlocation = new Map<Id, Schema.Location>();
		for (Integer i = 0; i < locations.size(); i++){
			locationIdandlocation.put(locations[i].Id, locations[i]);
		}
		for (Integer i = 0; i < workOrders.size(); i++){
			Schema.Location assetLocation = locationIdandlocation.get(assetIdandlocationId.get(workOrderIdandassetId.get(workOrders[i].Id)));
			if (workOrders[i].LocationId != assetIdandlocationId.get(workOrderIdandassetId.get(workOrders[i].Id)) || workOrders[i].Street != assetLocation.VisitorAddress.Street || workOrders[i].PostalCode != assetLocation.VisitorAddress.PostalCode || workOrders[i].StateCode != assetLocation.VisitorAddress.StateCode || workOrders[i].CountryCode != assetLocation.VisitorAddress.CountryCode){
				Boolean checkassign = workOrders[i].Status != 'Assigned' && assetLocation.LocationType != 'Van' ;
				if (checkassign){ 
					workOrders[i].LocationId = assetIdandlocationId.get(workOrderIdandassetId.get(workOrders[i].Id));
					workOrders[i].Street = assetLocation.VisitorAddress.Street;
					workOrders[i].PostalCode = assetLocation.VisitorAddress.PostalCode;
					workOrders[i].StateCode = assetLocation.VisitorAddress.StateCode;
					workOrders[i].CountryCode = assetLocation.VisitorAddress.CountryCode;
					workOrders[i].City = assetLocation.VisitorAddress.City;

					workOrderUpdate.add(workOrders[i]);
				}
				Boolean checkassign1 = workOrders[i].Status == 'Assigned' && assetLocation.LocationType != 'Van' && workOrders[i].TaskCreated__c == false ;
				if (checkassign1){
				
						Task task = new Task();
						task.Subject = Label.WorkOrderNewTaskSubject;
						task.Description = Label.WorkOrderNewTaskDescription;
						task.WhatId = workOrders[i].CaseId;
						if(workOrders[i].EndDate != null){
						task.ActivityDate = workOrders[i].EndDate.date();
						}
						task.OwnerId = Preplanner_NL.Id;
						workOrders[i].TaskCreated__c = true;
						workOrderUpdate.add(workOrders[i]);
						createTasks.add(task);
						System.debug(createTasks) ;
					}
				
			}


		}
		update workOrderUpdate;
		insert createTasks; */
	}

	public void finish(Database.BatchableContext bc){
		system.debug('DONE');
	}

	public static void Execute(SchedulableContext ctx){
		Database.executeBatch(new MaintenanceWorkOrderBatch());
	}

}