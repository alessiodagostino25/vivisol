trigger ContractFrameworkTrigger on Contract_Framework__c(before insert, before update, after insert, after update ){
	//List<Pricebook2> pricebook = new List<Pricebook2>();
	List<Id> cfInsertIds = new List<Id>();
	List<Id> cfUpdateIds = new List<Id>();
	/* pricebook = PricebookDAO.getPricebookExternalIds();
	Map<String, String> pricebookIdAndExternalId = new Map<String, String>();
	for (Integer i = 0; i < pricebook.size(); i++){
		pricebookIdAndExternalId.put(pricebook[i].Id, pricebook[i].External_ID__c);
	} */
	if (Trigger.isInsert && Trigger.isBefore){
		// Setting Pricebook if CF.BranchOfBelonging != null
			
		ContractFrameworkTriggerService.checkPricebook(Trigger.new);

		/* for (Contract_Framework__c CF : Trigger.new){
			CF.PriceListCode__c = pricebookIdAndExternalId.get(CF.Price_list_code__c);
		} */
	}
	if (Trigger.isUpdate && Trigger.isBefore){
		/* for (Contract_Framework__c CF : Trigger.new){
			CF.PriceListCode__c = pricebookIdAndExternalId.get(CF.Price_list_code__c);
		} */

		// Setting IsPortalSync

		SObjectServiceClass.setIsPortalSync(Trigger.new, Trigger.oldMap, 'Contract_Framework__c', true, false);
	}
	if (Trigger.isUpdate && Trigger.isAfter){
		//List<Status_Change_Event__e> changeEvents = new List<Status_Change_Event__e>();
		List<Contract_Framework__c> toDeactivateRelatedATs = new List<Contract_Framework__c>();

		if(FeatureManagementService.getFeatureStatus('SAP_Contract_Framework') || Test.isRunningTest()) {
			for (Id cf : Trigger.newMap.keySet()){
				if (Trigger.newMap.get(cf).Status__c == 'Active' && ContractFrameworkEventHelper.isContractUpdated(Trigger.newMap.get(cf), Trigger.oldMap.get(cf))){
					cfUpdateIds.add(cf);
					System.debug('UPDATED CONTRACT FRAMEWORK');
				}
				System.debug('NOT UPDATED CONTRACT FRAMEWORK');
			}
			if(!cfUpdateIds.isEmpty()){
				ContractFrameworkEventHelper.createEvent(cfUpdateIds) ;
			}
		}

		for(Contract_Framework__c cf : Trigger.new) {
			Contract_Framework__c oldRecord = Trigger.oldMap.get(cf.Id);

			/* if((oldRecord.IsCreatedSAP__c == true && cf.IsCreatedSAP__c == false) ||
			(oldRecord.IsSyncSAP__c == 'Sync' && cf.IsSyncSAP__c == 'NotSync')) {
				Status_Change_Event__e changeEvent = new Status_Change_Event__e(
					RecordId__c = cf.Id
				);

				changeEvents.add(changeEvent);
			} */

			if(oldRecord.Status__c != 'Inactive' && cf.Status__c == 'Inactive') {
				toDeactivateRelatedATs.add(cf);
			}
		}

		/* if(!changeEvents.isEmpty()) {
			List<Database.SaveResult> results = Eventbus.publish(changeEvents);
			System.debug('STATUS CHANGE EVENTS CONTRACT FRAMEWORK PUBLISHED size: ' + results.size());
		} */

		// Deactivating related Account Treatments for CF set to Inactive

		if(!toDeactivateRelatedATs.isEmpty()) {
			ContractFrameworkTriggerService.deactivateRelatedATs(toDeactivateRelatedATs);
		}

		// Setting IsPortalSync

		//SObjectServiceClass.setIsPortalSync(Trigger.new, Trigger.oldMap, 'Contract_Framework__c', true);
	}

	if (Trigger.isInsert && Trigger.isAfter){
		SObjectServiceClass.updateExternalId('Contract_Framework__c', 'Contract_Number__c', 'External_Id__c', Trigger.new);

		if(FeatureManagementService.getFeatureStatus('SAP_Contract_Framework') || Test.isRunningTest()) {
			for (Contract_Framework__c cf : Trigger.new){
				if (cf.Status__c ==  'Active'){
					cfInsertIds.add(cf.Id) ;
				}	
			}
			if(!cfInsertIds.isEmpty()){
				ContractFrameworkEventHelper.createEvent(cfInsertIds) ;
			}
		}
		ContractFrameworkTriggerService.createContractPayer(trigger.new);
	}
}