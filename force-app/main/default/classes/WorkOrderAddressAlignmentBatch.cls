global class WorkOrderAddressAlignmentBatch implements Database.Batchable<sObject>, Schedulable{	
	private final String PreplannerId;

	global WorkOrderAddressAlignmentBatch() {
		Group Preplanner_NL = [Select Id
			from Group
			WHERE Name = 'Preplanner_NL' and  Type = 'Queue'];
	  	this.PreplannerId = Preplanner_NL.Id;
	}
	
	public Database.QueryLocator start(Database.BatchableContext bc){
		//query to get all the Addresses based on conditions
		String query = 'SELECT Id, ParentId FROM Address WHERE LastModifiedDate = LAST_N_DAYS:2 AND LastModifiedDate != TODAY';
		System.debug(query);
		return Database.getQueryLocator(query);
	}

	public void execute(Database.BatchableContext bc, List<Schema.Address> addressList){
		List<Id> locationIds = new List<Id>();
		List<Task> createTasks = new List<Task>();
		List<WorkOrder> workOrderUpdate = new List<WorkOrder>();
	
		for (Integer i = 0; i < addressList.size(); i++){
			locationIds.add(addressList[i].ParentId);
		}
		List<WorkOrder> workOrders = WorkOrderDAO.getworkordersbylocationids(locationIds);
		List<Schema.Location> locations = LocationDAO.getvisitoraddressFromlocationid(locationIds);
		Map<Id, Schema.Location> locationIdandlocation = new Map<Id, Schema.Location>();
		for (Integer i = 0; i < locations.size(); i++){
			locationIdandlocation.put(locations[i].Id, locations[i]);
		}
		for (Integer i = 0; i < workOrders.size(); i++){
			Schema.Location addressLocation = locationIdandlocation.get(workOrders[i].LocationId);
			System.debug('workOrders[i].Street: ' + workOrders[i].Street);
			System.debug('addressLocation.Address.Street: ' + addressLocation.VisitorAddress.Street);
			if (workOrders[i].Delivery_Type__c != 'Remote Call'){
				if (workOrders[i].Street != addressLocation.VisitorAddress.Street || workOrders[i].PostalCode != addressLocation.VisitorAddress.PostalCode || workOrders[i].CountryCode != addressLocation.VisitorAddress.CountryCode || workOrders[i].StateCode != addressLocation.VisitorAddress.StateCode || workOrders[i].City != addressLocation.VisitorAddress.City){
					if (workOrders[i].Status != 'Assigned'){
						workOrders[i].Street = addressLocation.VisitorAddress.Street;
						workOrders[i].PostalCode = addressLocation.VisitorAddress.PostalCode;
						workOrders[i].CountryCode = addressLocation.VisitorAddress.CountryCode;
						workOrders[i].StateCode = addressLocation.VisitorAddress.StateCode;
						workOrders[i].City = addressLocation.VisitorAddress.City ;
						workOrderUpdate.add(workOrders[i]);
					}
		
					if (workOrders[i].Status == 'Assigned' && workOrders[i].TaskCreated__c == false){			
						Task task = new Task();
						task.Subject = Label.WorkOrderNewTaskSubject;
						task.Description = Label.WorkOrderNewTaskDescription;
						task.WhatId = workOrders[i].CaseId;
						if (workOrders[i].EndDate != null){
							task.ActivityDate = workOrders[i].EndDate.date();
						}
						task.OwnerId = this.PreplannerId;
						workOrders[i].TaskCreated__c = true;
						createTasks.add(task);
						System.debug(createTasks);			
					}
				}
			}
		}

		update workOrderUpdate;
		insert createTasks;
	}

	public void finish(Database.BatchableContext bc){
		system.debug('DONE');
	}

	public static void Execute(SchedulableContext ctx){
		Database.executeBatch(new WorkOrderAddressAlignmentBatch());
	}


}