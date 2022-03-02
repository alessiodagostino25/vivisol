trigger WorkOrderTrigger on WorkOrder(before insert, after insert, before update, after update, before delete){
	List<Id> completedWOIds = new List<Id>();
	List<Id> WOIdsForGoodsMovement = new List<Id>();
	List<Id> WorkOrderIds = new List<Id>();
	List<Id> caseIds = new List<Id>();
	List<WorkOrder> WorkOrderupdate = new List<WorkOrder>();
	List<String> queryFields = new List<String>{'Id', 'Due_Date__c', 'StartDate', 'EndDate', 'Related_SLA__c', 'Scheduled_Start_Date__c', 'Scheduled_End_Date__c', 
	'Account_Treatment_Job__c', 'CaseId', 'Status', 'Account_Treatment_Job__r.Account_Treatment_Job__c', 
	'Account_Treatment_Job__r.Patient_Treatment__r.RecordType.DeveloperName', 'LocationId', 'City', 'Country', 'CountryCode', 'Latitude', 'Longitude', 'PostalCode', 
	'State', 'StateCode', 'Street'};

	RecordType CPAPSchool = [SELECT Id FROM RecordType WHERE DeveloperName = 'WorkOrder_CPAPSchool'];
	
	if (Trigger.isBefore && Trigger.isInsert){
		System.debug('----- WorkOrderTrigger BEFORE INSERT -----');

		List<WorkOrder> welcomeModels = new List<WorkOrder>();
		List<WorkOrder> notWelcomeModels = new List<WorkOrder>();
		List<WorkOrder> toSetPaymentFields = new List<WorkOrder>();
		List<WorkOrder> remoteCalls = new List<WorkOrder>();
		List<WorkOrder> curriers = new List<WorkOrder>();

		// Getting ServiceTerritory

		for (WorkOrder wo : Trigger.new){
			Id serviceTerritoryId;

			if(wo.ServiceTerritoryId == null && wo.Latitude != null && wo.Longitude != null && wo.Delivery_Type__c != 'Welcome Model' && 
			wo.Delivery_Type__c != 'Remote Call' && wo.RecordTypeId != CPAPSchool.Id) {
				Double relatedLatitude = wo.Latitude;
				Double relatedLongitude = wo.Longitude;

				System.debug('----- WO -----');
				System.debug('relatedLatitude: ' + relatedLatitude);
				System.debug('relatedLongitude: ' + relatedLongitude);
				System.debug('relatedCity: ' + wo.City);

				if(Trigger.new.size() == 1) {
					System.debug('Querying for ServiceTerritory...');
					serviceTerritoryId = FSL.PolygonUtils.getTerritoryIdByPolygons(relatedLongitude, relatedLatitude);
				}
				else {
					wo.Check_Service_Territory__c = true;
				}

				if(serviceTerritoryId != null) {
					wo.ServiceTerritoryId = serviceTerritoryId;
				}
			}

			// Welcome Model WorkOrders

			if(wo.Delivery_Type__c == 'Welcome Model') {
				welcomeModels.add(wo);
			}
			else if(wo.Delivery_Type__c == 'Remote Call') {
				remoteCalls.Add(wo);
			}
			else {
				notWelcomeModels.add(wo);
			}

			if(wo.Contract_Framework__c != null && (wo.PaymentMethod__c == null || wo.PaymentCondition__c == null)) {
				toSetPaymentFields.add(wo);
			}

			if(wo.Delivery_Type__c == 'Currier') {
				curriers.add(wo);
			}
		}

		// Filling Service Territory for Remote Call WorkOrders

		if(!remoteCalls.isEmpty()) {
			WorkOrderService.updateServiceTerritoryRemoteCall(remoteCalls);
		}

		// Filling PaymentMethod__c and PaymentCondition__c if null (if Contract_Framework__c != null)

		if(!toSetPaymentFields.isEmpty()) {
			WorkOrderService.setPaymentFields(toSetPaymentFields);
		}

		// Updating Entitlement for every non-WelcomeModel WorkOrder

		if(!notWelcomeModels.isEmpty()) {
			WorkOrderService.updateEntitlementId(notWelcomeModels);
		}

		// Updating Welcome Model WOs

		if (!welcomeModels.isEmpty()){
			List<WorkOrder> updatedWOs = WorkOrderService.updateServiceTerritoryWelcomeModel(welcomeModels);
		}

		// Setting Review = true if ATJ.BO_Review == true on Currier WOs

		if(!curriers.isEmpty()) {
			WorkOrderService.setReviewFromATJ(curriers);
		}

		// Updating CountryCode__c and Treatment_Type__c

		WorkOrderService.updateTreatmentType(Trigger.new);

		// Updating ContactId

		WorkOrderService.updateContactId(Trigger.new);

		// Updating Payer Fields

		WorkOrderService.setPayerFields(Trigger.new, 'BEFORE_INSERT');
	}

	if (Trigger.isAfter && Trigger.isInsert){
		List<String> workOrderQueryFields = new List<String>{'RecordType.DeveloperName', 'ServiceReportTemplateId', 'Account_Treatment__c', 'LocationId', 
		'Account_Sales_Organization__r.Sales_Organization__c', 'Account_Sold_To__c', 'IsEmergency__c', 'Account_BillTo__c', 'Payer__c'};

		List<WorkOrder> queriedWorkOrders = WorkOrderDAO.getWorkOrdersFromIds(workOrderQueryFields, Trigger.newMap.keySet());
		List<String> notCPAPSchoolWorkOrderIds = new List<String>();
		List<WorkOrder> toUpdateSchedulingPolicy = new List<WorkOrder>();
		List<String> notAutoscheduledWOIds = new List<String>();

		// Updating the WorkType for Maintenance WorkOrders

		WorkOrderService.updateMaintenanceSRTemplateId(queriedWorkOrders);

		for (WorkOrder wo : Trigger.new){
			if(wo.RecordTypeId != CPAPSchool.Id) {
				notCPAPSchoolWorkOrderIds.add(wo.Id);
			}

			if(wo.ServiceTerritoryId != null) {
				toUpdateSchedulingPolicy.add(wo);
			}

			if(wo.Autoscheduled__c != true) {
				notAutoscheduledWOIds.add(wo.Id);
			}
		}

		// Updating Case NextActivityDate if necessary

		UpdateCaseStatusHelper.UpdateCaseStatus(notAutoscheduledWOIds);

		// Updating ExternalId if null

		WorkOrderService.updateOrderExternalId(Trigger.new);

		if(!notCPAPSchoolWorkOrderIds.isEmpty()) {
			WorkOrderService.updateOrderHK(notCPAPSchoolWorkOrderIds, null, false, false);
		}

		// Updating Scheduling Policy from Service Territory

		if(!toUpdateSchedulingPolicy.isEmpty()) {
			List<WorkOrder> toUpdate = WorkOrderService.updateSchedulingPolicy(toUpdateSchedulingPolicy);

			if(!toUpdate.isEmpty()) {
				List<Database.SaveResult> results = Database.update(toUpdate);
			}
		}

		// Setting WO.Payer__c and WO.Account_BillTo__c
		
		/* List<WorkOrder> toUpdate = WorkOrderService.setPayerFields(queriedWorkOrders);

		if(!toUpdate.isEmpty()) {
			update toUpdate;
		} */
	}

	if (Trigger.isBefore && Trigger.isUpdate){
		List<WorkOrder> welcomeModelsToUpdateEntitlement = new List<WorkOrder>();
		List<WorkOrder> newWelcomeModels = new List<WorkOrder>();
		List<WorkOrder> newNotWelcomeModels = new List<WorkOrder>();
		List<WorkOrder> newRemoteCalls = new List<WorkOrder>();
		List<WorkOrder> newCurriers = new List<WorkOrder>();
		List<WorkOrder> toUpdateRelatedSADates = new List<WorkOrder>();
		List<WorkOrder> toUpdateRelatedSATreatmentTypeAndSO = new List<WorkOrder>();
		List<WorkOrder> toUpdatePayerFields = new List<WorkOrder>();
		Boolean executeSTBatch = false;

		for (WorkOrder wo : Trigger.new){
			WorkOrder oldWorkOrder = Trigger.oldMap.get(wo.Id);

			// Mark the WorkOrder for the ServiceTerritory update

			if (oldWorkOrder.Latitude != wo.Latitude || oldWorkOrder.Longitude != wo.Longitude || oldWorkOrder.City != wo.City || oldWorkOrder.Street != wo.Street ||
			oldWorkOrder.CountryCode != wo.CountryCode || oldWorkOrder.PostalCode != wo.PostalCode || oldWorkOrder.StateCode != wo.StateCode){
				if(wo.Check_Service_Territory__c == false) {
					wo.Check_Service_Territory__c = true;
				}

				if(executeSTBatch == false) {
					executeSTBatch = true;
				}
			}

			if(oldWorkOrder.StartDate != wo.StartDate || oldWorkOrder.EndDate != wo.EndDate) {
				toUpdateRelatedSADates.add(wo);
			}

			// Update of Entitlement if ServiceTerritory is updated

			if (oldWorkOrder.ServiceTerritoryId != wo.ServiceTerritoryId && wo.Delivery_Type__c == 'Welcome Model'){
				welcomeModelsToUpdateEntitlement.add(wo);
			}

			if (oldWorkOrder.Delivery_Type__c != 'Welcome Model' && wo.Delivery_Type__c == 'Welcome Model'){
				newWelcomeModels.add(wo);
			}

			if((oldWorkOrder.Delivery_Type__c == 'Welcome Model' || oldWorkOrder.Delivery_Type__c == 'Remote Call') 
			&& wo.Delivery_Type__c != 'Welcome Model' && wo.Delivery_Type__c != 'Remote Call') {
				newNotWelcomeModels.add(wo);
			}

			if(oldWOrkOrder.Delivery_Type__c != 'Remote Call' && wo.Delivery_Type__c == 'Remote Call') {
				newRemoteCalls.add(wo);
			}

			if(oldWorkOrder.Delivery_Type__c != 'Currier' && wo.Delivery_Type__c == 'Currier') {
				newCurriers.add(wo);
			}

			if(oldWorkOrder.Treatment_Type__c != wo.Treatment_Type__c || oldWorkOrder.SalesOrganization__c != wo.SalesOrganization__c) {
				toUpdateRelatedSATreatmentTypeAndSO.add(wo);
			}

			if(oldWorkOrder.LocationId != wo.LocationId && wo.LocationId != null && wo.Account_Treatment__c != null) {
				toUpdatePayerFields.add(wo);
			}
		}

		// If the ServiceTerritory has been changend, update the address and the Entitlement on Welcome Model WorkOrders

		if(!welcomeModelsToUpdateEntitlement.isEmpty()) {

			// Updating the address on the WO from the new ServiceTerritory

			WorkOrderService.updateAddressFromST(welcomeModelsToUpdateEntitlement);

			// Updating the Entitlement

			WorkOrderService.updateEntitlementIdWelcomeModelRemoteCall(welcomeModelsToUpdateEntitlement, 'Welcome Model');
		}

		if(!newWelcomeModels.isEmpty()) {
			List<WorkOrder> updatedWOs = WorkOrderService.updateServiceTerritoryWelcomeModel(newWelcomeModels);
		}

		if(!newNotWelcomeModels.isEmpty()) {

			// This also updates Check_Service_Territory__c to let the batch update the ServiceTerritory for the new Address

			WorkOrderService.updateNewNotWMAddress(newNotWelcomeModels);

			// Updating Entitlement for new NOT Welcome Models

			WorkOrderService.updateEntitlementId(newNotWelcomeModels);
		}

		if(!newRemoteCalls.isEmpty()) {
			WorkOrderService.updateServiceTerritoryRemoteCall(newRemoteCalls);

			for(WorkOrder wo : newRemoteCalls) {
				if(wo.Check_Service_Territory__c == false) {
					wo.Check_Service_Territory__c = true;
				}
			}

			// Executing batch to align the ST on the related ServiceAppointment

			if(executeSTBatch == false) {
				executeSTBatch = true;
			}
		}

		// If StartDate/EndDate have changed, I need to update the related ServiceAppointments too

		if(!toUpdateRelatedSADates.isEmpty()) {
			List<ServiceAppointment> SAsToUpdate = WorkOrderService.updateRelatedSAsDates(toUpdateRelatedSADates);

			if(!SAsToUpdate.isEmpty()) {
				List<Database.SaveResult> results = Database.update(SAsToUpdate);
			}
		}

		// Updating TreatmentType and SalesOrganization on realted Service Appointments

		if(!toUpdateRelatedSATreatmentTypeAndSO.isEmpty()) {
			List<ServiceAppointment> toUpdate = WorkOrderService.updateRelatedSATreatmentTypeAndSO(toUpdateRelatedSATreatmentTypeAndSO);

			if(!toUpdate.isEmpty()) {
				List<Database.SaveResult> results = Database.update(toUpdate);
			}
		}

		// Executing ST Batch if the Address on any WO has been updated

		if(executeSTBatch == true && !System.isBatch()) {
			Database.executeBatch(new ServiceTerritoryUpdateBatch(), 100);
		}

		// Setting IsPortalSync

		SObjectServiceClass.setIsPortalSync(Trigger.new, Trigger.oldMap, 'WorkOrder', false, false);

		// Updating Payer fields

		if(!toUpdatePayerFields.isEmpty()) {
			WorkOrderService.setPayerFields(toUpdatePayerFields, 'BEFORE_UPDATE');
		}

		// Setting Review = true if ATJ.BO_Review == true on Currier WOs

		if(!newCurriers.isEmpty()) {
			WorkOrderService.setReviewFromATJ(newCurriers);
		}
	}

	if (Trigger.isAfter && Trigger.isUpdate){
		System.debug('WORKORDERTRIGGER AFTER UPDATE');

		//List<String> differentATAworkOrderIds = new List<String>();
		List<Id> newHomeVisitIds = new List<Id>();
		List<Id> canceledWorkOrderIds = new List<Id>();
		//List<Status_Change_Event__e> changeEvents = new List<Status_Change_Event__e>();
		List<WorkOrder> toUpdateSchedulingPolicy = new List<WorkOrder>();
		List<WorkOrder> newAssignedWOs = new List<WorkOrder>();
		List<WorkOrder> toUpdateCase = new List<WorkOrder>();
		List<String> toUpdateNextActivityDate = new List<String>();
		List<String> toUpdateRelatedSAAddressIds = new List<String>();
		List<WorkOrder> toUpdateAddress = new List<WorkOrder>();
		List<String> closedWorkOrderIds = new List<String>();
		List<String> closedNotReviewWOIds = new List<String>();
		List<String> workOrderIds = new List<String>();
		List<WorkOrder> toUpdateCaseStartDate = new List<WorkOrder>();

		for (WorkOrder wo : Trigger.new) {	
			workOrderIds.add(wo.Id);

			if(!System.isBatch()){
				System.debug('oldStatus: ' +(Trigger.oldMap.get(wo.Id).Status));
				System.debug('newStatus: ' + wo.Status);
				System.debug('oldIsClosed: ' + (Trigger.oldMap.get(wo.Id).IsClosed));
				System.debug('newIsClosed: ' + wo.IsClosed);
				if ((Trigger.oldMap.get(wo.Id).IsClosed == false && wo.IsClosed == true)) {
					closedWorkOrderIds.add(wo.Id);

					if(wo.Review__c == false && wo.CaseId != null) {
						closedNotReviewWOIds.add(wo.Id);
					}
					else if(wo.Review__c == true && wo.CaseId != null) {
						toUpdateCase.add(wo);
					}
				}

				if(Trigger.oldMap.get(wo.Id).StartDate != wo.StartDate && wo.CaseId != null) {
					toUpdateNextActivityDate.add(wo.CaseId);

					if(wo.Status == 'New' || wo.Status == 'Draft') {
						toUpdateCaseStartDate.add(wo);
					}
				}
			}

			/* This is an initial check before the query, just to make sure that the Trigger doesn't fire (due to rollup fields)
			 * when the autoscheduled creation batches execute
			 */

			if (((Trigger.oldMap.get(wo.Id)).Status != 'Completed') && wo.Status == 'Completed'){
				completedWOIds.add(wo.Id);
				System.debug('Completed WO Id: ' + wo.Id);
				// Goods Movement
				if (wo.Delivery_Type__c == 'Currier'){
					WOIdsForGoodsMovement.add(wo.Id);
				}
			}

			// Checking if the ATA has changed: if so, need to check for the Payer__c

			if(Trigger.oldMap.get(wo.Id).LocationId != wo.LocationId) {
				//differentATAworkOrderIds.add(wo.Id);

				if(wo.Delivery_Type__c == 'Home Visit' || wo.Delivery_Type__c == 'Currier') {
					toUpdateAddress.add(wo);
				}
			}

			if(Trigger.oldMap.get(wo.Id).Status != 'Canceled' && wo.Status == 'Canceled') {
				canceledWorkOrderIds.add(wo.Id);
			}

			if(Trigger.oldMap.get(wo.Id).ServiceTerritoryId != wo.ServiceTerritoryId && wo.ServiceTerritoryId != null) {
				toUpdateSchedulingPolicy.add(wo);
			}

			if(Trigger.oldMap.get(wo.Id).Status != 'Assigned' && wo.Status == 'Assigned') {
				newAssignedWOs.add(wo);
			}

			/* if(Trigger.oldMap.get(wo.Id).Review__c != true && wo.Review__c == true) {
				toUpdateCase.add(wo);
			} */

			if (Trigger.oldMap.get(wo.Id).Latitude != wo.Latitude || Trigger.oldMap.get(wo.Id).Longitude != wo.Longitude || Trigger.oldMap.get(wo.Id).City != wo.City || 
			Trigger.oldMap.get(wo.Id).Street != wo.Street ||
			Trigger.oldMap.get(wo.Id).CountryCode != wo.CountryCode || Trigger.oldMap.get(wo.Id).PostalCode != wo.PostalCode || 
			Trigger.oldMap.get(wo.Id).StateCode != wo.StateCode) {
				toUpdateRelatedSAAddressIds.add(wo.Id);
			}
		}

		if(!closedWorkOrderIds.isEmpty()) {
			WorkOrderService.baseUnitBatchCodeCheck(closedWorkOrderIds);
		}

		if(!toUpdateSchedulingPolicy.isEmpty()) {
			List<WorkOrder> toUpdate = WorkOrderService.updateSchedulingPolicy(toUpdateSchedulingPolicy);

			if(!toUpdate.isEmpty()) {
				List<Database.SaveResult> results = Database.update(toUpdate);
			}
		}

		if (!completedWOIds.isEmpty()){
			List<WorkOrder> completedTherapyWOs = WorkOrderDAO.getCompletedWOs(queryFields, completedWOIds);
			if (!completedTherapyWOs.isEmpty()){
				if(!SingletonClass.checkNotToFire()) {
					WorkOrderService.scheduleActivities(completedTherapyWOs);
				}
			}
		}

		if (!WOIdsForGoodsMovement.isEmpty()){
			GoodsMovement.processGoodsMovement(WOIdsForGoodsMovement);
			//CLOSE RELATED SERVICE WOLI FOR END_DELIVERY
			WorkOrderService.closeRelatedServiceWOLI(WOIdsForGoodsMovement);
		}

		if (!closedNotReviewWOIds.isEmpty()){
			UpdateCaseStatusHelper.UpdateCaseStatus(closedNotReviewWOIds);
		}

		// Canceling related ServiceAppointments if a WorkOrder is canceled and moving materials back to VAN if necessary

		if(!canceledWorkOrderIds.isEmpty()) {
			// Canceling SAs

			List<ServiceAppointment> canceledRelatedSAs = WorkOrderService.cancelRelatedServiceAppointments(canceledWorkOrderIds);

			if(!canceledRelatedSAs.isEmpty()) {
				List<Database.SaveResult> results = Database.update(canceledRelatedSAs);
			}

			// Moving materials to VAN

			WorkOrderService.moveMaterials(canceledWorkOrderIds);
		}

		// Updating WOLIs related to new Assigned WOs with Plant and StorageLocation = null

		if(!newAssignedWOs.isEmpty()) {
			List<WorkOrderLineItem> WOLIsToUpdate = WorkOrderService.updateRelatedWOLIs(newAssignedWOs);

			if(!WOLIsToUpdate.isEmpty()) {
				List<Database.SaveResult> results = Database.update(WOLIsToUpdate);
			}
		}

		// Updating the Next Activity Date on the related Case if the StartDate has changed

		if(!toUpdateNextActivityDate.isEmpty()) {
			UpdateCaseStatusForTask.UpdateCaseStatus(toUpdateNextActivityDate);
		}

		// Updating the StartDate on the related Case if the StartDate has changed

		if(!toUpdateCaseStartDate.isEmpty()) {
			WorkOrderService.updateCaseStartDate(toUpdateCaseStartDate);
		}

		WorkOrderService.updateOrderHK(workOrderIds, Trigger.oldMap, false, true);
		
		// Checking if the Payer on the related ATAP has changed: if so, change the Payer and BillTo fields on the WorkOrder

		/* if(!differentATAworkOrderIds.isEmpty()) {
			List<WorkOrder> workOrdersToCheck = WorkOrderService.checkForSetPayerFields(differentATAworkOrderIds);

			if(!workOrdersToCheck.isEmpty()) {
				List<WorkOrder> toUpdate = WorkOrderService.setPayerFields(workOrdersToCheck);

				if(!toUpdate.isEmpty()) {
					update toUpdate;
				}
			}
		} */

		// Updating Case for Review WOs

		if(!toUpdateCase.isEmpty()) {
			WorkOrderService.updateRelatedCases(toUpdateCase);
		}

		// Updating SA's Address if the WorkOrder's one changes

		if(!toUpdateRelatedSAAddressIds.isEmpty()) {
			WorkOrderService.updateServiceAppointmentAddress(toUpdateRelatedSAAddressIds);
		}

		// Updating Address from new Location

		if(!toUpdateAddress.isEmpty()) {
			WorkOrderService.updateAddressFromLocation(toUpdateAddress);
		}

		// Update event for the SAP component
		
		/* for(WorkOrder wo : Trigger.new) {
			WorkOrder oldRecord = Trigger.oldMap.get(wo.Id);

			if(oldRecord.IsSyncSAP__c == 'Pending' && wo.IsSyncSAP__c != 'Pending') {
				Status_Change_Event__e changeEvent = new Status_Change_Event__e(
					RecordId__c = wo.Id
				);

				changeEvents.add(changeEvent);
			}
		} */

		/* if(!changeEvents.isEmpty()) {
			List<Database.SaveResult> results = Eventbus.publish(changeEvents);
			System.debug('STATUS CHANGE EVENTS WORKORDER PUBLISHED size: ' + results.size());
		} */

		if(!System.isBatch()) {
			List<WorkOrder> newWorkTypeWOs = new List<WorkOrder>();
			List<Id> newWorkTypeWOIds = new List<Id>();
			List<Id> workTypeIds = new List<Id>();
			Map<Id, WorkOrder> changedDescriptionWO = new Map<Id, WorkOrder>();

			Map<Id, List<SkillRequirement>> skillRequirementMap = new Map<Id, List<SkillRequirement>>();

			for(WorkOrder wo : Trigger.new) {
				if((Trigger.oldMap.get(wo.Id).WorkTypeId != wo.WorkTypeId) && !wo.IsClosed) {
					newWorkTypeWOs.add(wo);
					newWorkTypeWOIds.add(wo.Id);
					workTypeIds.add(wo.WorkTypeId);
				}
				if(Trigger.oldMap.get(wo.Id).Description != Trigger.newMap.get(wo.Id).Description){
					changedDescriptionWO.put(wo.Id, Trigger.oldMap.get(wo.Id));
				}
			}

			if (!changedDescriptionWO.isEmpty()){
				WorkOrderService.updateRelatedSADescription(Trigger.newMap);
			}

			if(!newWorkTypeWOs.isEmpty() && !workTypeIds.isEmpty()) {
				
				// Deleting related SkillRequirements

				List<SkillRequirement> skillRequirementsToDelete = WorkOrderService.getSkillRequirementsFromRelatedRecords(newWorkTypeWOIds);

				if(!skillRequirementsToDelete.isEmpty()) {
					List<Database.DeleteResult> deleteResults = Database.delete(skillRequirementsToDelete);
				}

				// Updating WO with new WorkType fields

				List<WorkOrder> workOrdersToUpdate = WorkOrderService.updateWOsFromWorkTypes(newWorkTypeWOs);

				if(!workOrdersToUpdate.isEmpty()) {
					List<Database.SaveResult> updateWOsResults = Database.update(workOrdersToUpdate);
				}

				// Getting SkillRequirements linked to new WorkType, mapping them, then creating them for the WO too

				List<SkillRequirement> workTypeSkillRequirements = WorkOrderService.getSkillRequirementsFromRelatedRecords(workTypeIds);

				if(!workTypeSkillRequirements.isEmpty()) {
					for (SkillRequirement sr : workTypeSkillRequirements){
						if (skillRequirementMap.get(sr.RelatedRecordId) == null){
							skillRequirementMap.put(sr.RelatedRecordId, new List<SkillRequirement>());
						}
						skillRequirementMap.get(sr.RelatedRecordId).add(sr);
					}

					List<SkillRequirement> newSkillRequirements = WorkOrderService.cloneWorkTypeSkillRequirementsOnWOs(newWorkTypeWOs, skillRequirementMap);

					if(!newSkillRequirements.isEmpty()) {
						List<Database.SaveResult> skillRequirementResults = Database.insert(newSkillRequirements);
					}
				}

				// Updating Duration Info for each ServiceAppointment related to each WorkOrder with new WorkType

				List<ServiceAppointment> serviceAppointmentsToUpdate = WorkOrderService.updateServiceAppointments(newWorkTypeWOIds);

				if(!serviceAppointmentsToUpdate.isEmpty()) {
					List<Database.SaveResult> serviceAppointmentResults = Database.update(serviceAppointmentsToUpdate);
				}
			}
		}

		// Setting IsPortalSync

		//SObjectServiceClass.setIsPortalSync(Trigger.new, Trigger.oldMap, 'WorkOrder', false);
	}

	// Updating linked the OrderHKs to be removed
	
	if(Trigger.isDelete && Trigger.isBefore) {
		List<String> workOrdersToDeleteIds = new List<String>();

		for(WorkOrder wo : Trigger.old) {
			workOrdersToDeleteIds.add(wo.Id);
		}
		WorkOrderService.updateOrderHK(workOrdersToDeleteIds, null, true, false);
	}
}