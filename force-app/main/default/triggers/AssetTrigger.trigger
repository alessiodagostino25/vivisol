trigger AssetTrigger on Asset(before insert, before update, after update){
	if(Trigger.isInsert && Trigger.isBefore) {
		List<Asset> withAccountTreatment = new List<Asset>();

		for(Asset a : Trigger.new) {
			a.Is_Portal_Sync__c = '02';

			if(a.Account_Treatment__c != null) {
				withAccountTreatment.add(a);
			}
		}

		// Setting Account_Treatment_Number__c

		if(!withAccountTreatment.isEmpty()) {
			AssetTriggerService.setAccountTreatmentNumber(withAccountTreatment);
		}
	}

	if(Trigger.isUpdate && Trigger.isBefore) {
		List<Asset> updatedAccountTreatment = new List<Asset>();

		for(Asset a : Trigger.new) {
			Asset oldRecord = Trigger.oldMap.get(a.Id);

			if(oldRecord.Account_Treatment__c != a.Account_Treatment__c) {
				updatedAccountTreatment.add(a);
			}
		}

		AssetTriggerService.setIsPortalSync(Trigger.new, Trigger.oldMap, false);

		// Setting Account_Treatment_Number__c

		if(!updatedAccountTreatment.isEmpty()) {
			AssetTriggerService.setAccountTreatmentNumber(updatedAccountTreatment);
		}
	}

	if(Trigger.isUpdate && Trigger.isAfter) {
		List<String> changedAssetIds = new List<String>();

		for (Asset a : Trigger.new){
			if ((a.TemporaryLabel__c != trigger.oldMap.get(a.Id).TemporaryLabel__c) &&
			a.TemporaryLabel__c != null && a.StorageLocation__c != null && a.Plant__c != null){
				changedAssetIds.add(a.Id);
				/* a.Account_Treatment__c   = null ;
				a.AssetServicedById  = null ; */
			}
		}
		if(!changedAssetIds.isEmpty()){
			AssetTriggerService.assetTriggerServicemethod(changedAssetIds);
		}

		//AssetTriggerService.setIsPortalSync(Trigger.new, Trigger.oldMap);
	}
}