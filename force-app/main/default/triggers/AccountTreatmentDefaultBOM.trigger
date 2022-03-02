trigger AccountTreatmentDefaultBOM on Account_Treatment__c(before insert, after insert, before update, after update){
	
	List<String> accounttreatmentids = new List<String>();
	List<String> atcontracttreatmentids = new List<String>();
	List<Account_Treatment__c> accountTreatments = new List<Account_Treatment__c>();

	if(Trigger.isInsert && Trigger.isBefore) {
		List<Account_Treatment__c> toSetTreatmentModality = new List<Account_Treatment__c>();

		for(Account_Treatment__c at : Trigger.new) {
			if(at.Treatment_Modality__c == null && (at.Installation_Type__c != null || at.Treatment__c != null)) {
				toSetTreatmentModality.add(at);
			}
		}

		AccountTreatmentDefaultBOMHelper.updateElectricityCostsDesired(Trigger.new);

		// Setting Treatment_Modality__c

		if(!toSetTreatmentModality.isEmpty()) {
			AccountTreatmentDefaultBOMHelper.setTreatmentModality(toSetTreatmentModality);
		}
	}

	if (Trigger.isInsert && Trigger.isAfter){
		List<Account_Treatment__c> waitingATs = new List<Account_Treatment__c>();
		List<String> prescriptionIds = new List<String>();
		List<String> prescriptionATIds = new List<String>();
		
		for (Account_Treatment__c at : Trigger.new){
			accounttreatmentids.add(at.Id);
			atcontracttreatmentids.add(at.Contract_Treatment__c);
			accountTreatments.add(at);

			if(at.Status__c == 'W') {
				waitingATs.add(at);
			}

			if (at.Prescription__c != null){
				prescriptionIds.add(at.Prescription__c);
				prescriptionATIds.add(at.Id);
			}
		}

		// Creating Waiting Account Treatment Status

		if(FeatureManagementService.getFeatureStatus('Create_Waiting_Status_On_AT_Creation') || Test.isRunningTest()) {
			if(!waitingATs.isEmpty()) {
				AccountTreatmentDefaultBOMHelper.createWaitingATS(waitingATs);
			}
		}

		// Filling External_Id__c

		if(FeatureManagementService.getFeatureStatus('Set_AT_External_Id') || Test.isRunningTest()) {
			AccountTreatmentDefaultBOMHelper.setExternalId(Trigger.new);
		}
		
		if(accounttreatmentids.size()>0){
			if(FeatureManagementService.getFeatureStatus('AT_Default_BOM_From_Trigger') || Test.isRunningTest()) {
				//AccountTreatmentDefaultBOMHelper.AccountTreatmentDefaultBOMHelperwithid(accounttreatmentids, atcontracttreatmentids);
				AccountTreatmentDefaultBOMHelper.AccountTreatmentDefaultBOMHelperwithid(accounttreatmentids, accountTreatments, atcontracttreatmentids);
			}
		}

		// Handling Prescription

		if(!prescriptionIds.isEmpty() && !prescriptionATIds.isEmpty()) {
			AccountTreatmentDefaultBOMHelper.handlePrescription(prescriptionATIds, prescriptionIds);
		}
	}
	else if(Trigger.isUpdate && Trigger.isBefore) {
		List<Account_Treatment__c> toSetTreatmentModality = new List<Account_Treatment__c>();

		for(Account_Treatment__c at : Trigger.new) {
			Account_Treatment__c oldRecord = Trigger.oldMap.get(at.Id);

			if((oldRecord.Installation_Type__c != at.Installation_Type__c) || (oldRecord.Treatment__c != at.Treatment__c)) {
				toSetTreatmentModality.add(at);
			}
		}

		if(FeatureManagementService.getFeatureStatus('Update_AT_Is_Portal_Sync') || Test.isRunningTest()) {
			SObjectServiceClass.setIsPortalSync(Trigger.new, Trigger.oldMap, 'Account_Treatment__c', true, false);
		}

		// Setting Treatment_Modality__c

		if(!toSetTreatmentModality.isEmpty()) {
			AccountTreatmentDefaultBOMHelper.setTreatmentModality(toSetTreatmentModality);
		}
	}
	else if (Trigger.isUpdate && Trigger.isAfter){
		List<String> prescriptionIds = new List<String>();
		List<String> prescriptionATIds = new List<String>();

		AccountTreatmentTriggerHelper helper = new AccountTreatmentTriggerHelper(Trigger.new, Trigger.old, Trigger.oldMap, Trigger.newMap);
		helper.initListHistory();
		system.debug('UPDATE TRIGGER');
		List<Account_Treatment_History__c> histories = new List<Account_Treatment_History__c>();
		histories = helper.getHistories();
		system.debug('Accountr treatment history: ' + histories);

		if (!histories.isEmpty()){
			insert histories;
		}

		// Setting IsPortalSync

		/* if(FeatureManagementService.getFeatureStatus('Update_AT_Is_Portal_Sync')) {
			SObjectServiceClass.setIsPortalSync(Trigger.new, Trigger.oldMap, 'Account_Treatment__c', true);
		} */

		for(Account_Treatment__c at : Trigger.new) {
			if(at.Prescription__c != null && Trigger.oldMap.get(at.Id).Prescription__c != at.Prescription__c) {
				prescriptionIds.add(at.Prescription__c);
				prescriptionATIds.add(at.Id);
			}
		}

		// Handling Prescription

		if(!prescriptionIds.isEmpty() && !prescriptionATIds.isEmpty()) {
			AccountTreatmentDefaultBOMHelper.handlePrescription(prescriptionATIds, prescriptionIds);
		}
		
		/*List<String> queryFields = new List<String>{'RecordType.DeveloperName'};

		List<String> queryFieldsForATJ = new List<String>{'Scheduling_Rule__c', 'Work_Order__c', 'Task__c', 'Contract_Treatment_Job__c', 'Patient_Treatment__r.Account__c',
        'Patient_Treatment__c', 'Patient_Treatment__r.Contract_Treatment__c', 'Name', 'Case_Subtype__c', 'Case_Type__c', 'Patient_Treatment__r.Treatment_Type__c',
        'Contract_Treatment_Job__r.Contract_Framework__r.Customer__c', 
        'Contract_Treatment_Job__r.Contract_Framework__r.Branch_of_belonging_sales_office__c', 'Contract_Treatment_Job__r.Contract_Framework__c', 
        'Contract_Treatment_Job__r.Contract_Treatment__c', 'Delivery_Channel__c', 
        'Contract_Treatment_Job__r.Contract_Framework__r.Price_list_code__c','Patient_Treatment__r.Account__r.Name',
        'Patient_Treatment__r.Customer_Purchase_Date__c', 'Patient_Treatment__r.Customer_Purchase_Order_Number__c', 'Patient_Treatment__r.Account__r.FirstName',
        'Patient_Treatment__r.Account__r.LastName', 'Work_Type__c', 'Patient_Treatment__r.Account__r.IsPersonAccount', 
        'Patient_Treatment__r.Account__r.PersonContactId', 'Frequency__c', 'Frequency_Unit_of_measure__c', 'Patient_Treatment__r.Prescription__r.CreatedDate',
        'Patient_Treatment__r.Prescription__r.Received_Date__c', 'Contract_Treatment_Job__r.Contract_Framework__r.Attachment_Addendum_Type__c',
        'Contract_Treatment_Job__r.Contract_Framework__r.Billing_Via__c', 'Contract_Treatment_Job__r.Contract_Framework__r.Customer__r.Customer_Purchase_Order_Date__c',
        'Contract_Treatment_Job__r.Contract_Framework__r.Customer__r.Customer_Purchase_Order_Number__c',
        'Contract_Treatment_Job__r.Contract_Framework__r.Customer__r.Billing_Reference__c', 
        'Contract_Treatment_Job__r.Contract_Framework__r.Invoice_splitting_criterion__c', 'Contract_Treatment_Job__r.Contract_Framework__r.Invoice_Layout__c',
        'Contract_Treatment_Job__r.Invoice_Splitting_Group__c', 'Patient_Treatment__r.Customer_Request_Code__c', 
        'Patient_Treatment__r.Contract_Treatment__r.Invoice_Splitting_Group__c', 'Customer_Product_Code__c'};

		List<String> queryFieldsForATJP = new List<String>{'Asset__c', 'Patient_Treatment_Job__r.Patient_Treatment__c', 'Product__c', 'Quantity__c', 
		'Customer_Treatment_Alias__c', 'Patient_Treatment_Job__c', 'Customer_Request_Code__c', 'Storage_Location__c', 'Plant__c', 'Purchase_order_number__c',
		'Purchase_order_date__c', 'Contract_Treatment_Job_Product__r.Invoice_Splitting_group__c'};
		
		List<String> queryFieldsForAssets = new List<String>{'Id', 'LocationId', 'Location.VisitorAddress.City', 'Location.VisitorAddress.Country', 
		'Location.VisitorAddress.CountryCode', 'Location.VisitorAddress.Latitude', 'Location.VisitorAddress.Longitude', 'Location.VisitorAddress.PostalCode', 
		'Location.VisitorAddress.State', 'Location.VisitorAddress.StateCode', 'Location.VisitorAddress.Street', 'SerialNumber'}; 

		List<Account_Treatment__c> newActiveMaintenanceATs = new List<Account_Treatment__c>();
		List<Id> newActiveATIds = new List<Id>();
		List<Id> newActiveMaintenanceATIds = new List<Id>();

		Map<Id, Account_Treatment__c> accountTreatmentMap = new Map<Id, Account_Treatment__c>();
		Map<Id, List<Account_Treatment_Job_Product__c>> jobToAssetProductsMap = new Map<Id, List<Account_Treatment_Job_Product__c>>();
		Map<Id, List<Account_Treatment_Job_Product__c>> jobToNotAssetProductsMap = new Map<Id, List<Account_Treatment_Job_Product__c>>();

		for(Account_Treatment__c accountTreatment : Trigger.new) {
            if((Trigger.oldMap.get(accountTreatment.Id)).Status__c != 'A' && accountTreatment.Status__c == 'A') {
                newActiveATIds.add(accountTreatment.Id);
            }
		}
		
		newActiveMaintenanceATs = AccountTreatmentDAO.getActiveMaintenanceATsFromIds(queryFields, newActiveATIds);
		System.debug('newActiveMaintenanceATs size: ' + newActiveMaintenanceATs.size());

		for(Account_Treatment__c at : newActiveMaintenanceATs) {
			newActiveMaintenanceATIds.add(at.Id);
			accountTreatmentMap.put(at.Id, at);
		}

		if(!newActiveMaintenanceATIds.isEmpty()) {
			List<Id> relatedATJIds = new List<Id>();
			List<Id> jobsWithAssetProductsIds = new List<Id>();
			List<Id> assetIds = new List<Id>();

			List<Asset> assets = new List<Asset>();
			List<Account_Treatment_Job__c> jobsWithAssetProducts = new List<Account_Treatment_Job__c>();
			
			Map<Id, Asset> assetMap = new Map<Id, Asset>();
			Map<Id, List<Account_Treatment_Job_Product__c>> ATToProductsMap = new Map<Id, List<Account_Treatment_Job_Product__c>>();
			// When the RecordType is Maintenance, the Account Treatment has only one Account Treatment Job
			List<Account_Treatment_Job__c> relatedATJs = AccountTreatmentJobDAO.getATJsFromATIds(queryFieldsForATJ, newActiveMaintenanceATIds);

			for(Account_Treatment_Job__c atj : relatedATJs) {
				relatedATJIds.add(atj.Id);
			}
			List<Account_Treatment_Job_Product__c> assetATJPs = AccountTreatmentJobProductDAO.getAssetActiveProductsFromATJs(queryFieldsForATJP, relatedATJIds);
			List<Account_Treatment_Job_Product__c> notAssetATJPs = AccountTreatmentJobProductDAO.getNotAssetActiveProductsFromATJs(queryFieldsForATJP, relatedATJIds);

			if(assetATJPs != null) {

				// This links a job to the list of its Products linked to an Asset
				for(Account_Treatment_Job_Product__c atjp : assetATJPs) {
					jobsWithAssetProductsIds.add(atjp.Patient_Treatment_Job__c);
					if(jobToAssetProductsMap.get(atjp.Patient_Treatment_Job__c) == null) {
						jobToAssetProductsMap.put(atjp.Patient_Treatment_Job__c, new List<Account_Treatment_Job_Product__c>());
					}
					jobToAssetProductsMap.get(atjp.Patient_Treatment_Job__c).add(atjp);
				}

				// This links a job to the list of its Products not linked to an Asset
				for(Account_Treatment_Job_Product__c atjp : notAssetATJPs) {
					if(jobToNotAssetProductsMap.get(atjp.Patient_Treatment_Job__c) == null) {
						jobToNotAssetProductsMap.put(atjp.Patient_Treatment_Job__c, new List<Account_Treatment_Job_Product__c>());
					}
					jobToNotAssetProductsMap.get(atjp.Patient_Treatment_Job__c).add(atjp);
				}
			}

			for(Account_Treatment_Job_Product__c atjp : assetATJPs) {
				assetIds.add(atjp.Asset__c);
			}
	
			if(!assetIds.isEmpty()) {
				assets = AssetDAO.getAssetsFromIds(queryFieldsForAssets, assetIds);
			}
	
			for(Asset a : assets) {
				assetMap.put(a.Id, a);
			}

			jobsWithAssetProducts = AccountTreatmentJobDAO.getATJSFROMIds(queryFieldsForATJ, jobsWithAssetProductsIds);

			// This batch will autoschedule Cases, Tasks and WOs for each product linked to an Asset

			AutoscheduleActivitiesMaintenanceBatch autoscheduleBatch = new AutoscheduleActivitiesMaintenanceBatch();
			autoscheduleBatch.jobsWithAssetProducts = jobsWithAssetProducts;
			autoscheduleBatch.assetProducts = assetATJPs;
			autoscheduleBatch.notAssetATJPs = notAssetATJPs;
			autoscheduleBatch.jobToNotAssetProductsMap = jobToNotAssetProductsMap;
			autoscheduleBatch.assetMap = assetMap;
			autoscheduleBatch.isRescheduling = false;

			Database.executeBatch(autoscheduleBatch); 
		}*/
	}
}