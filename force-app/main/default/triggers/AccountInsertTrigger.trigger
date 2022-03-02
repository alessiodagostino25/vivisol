trigger AccountInsertTrigger on Account(after insert, before update, before insert, after update){
	Map<Id, Account> oldMap = new Map<Id, Account>();
	List<Id> accountIdsToCreate = new List<Id>();
	List<Id> accountIdsToUpdate = new List<Id>();
	List<Account> addressChangedAccs = new List<Account>();
	List<Account> accountForWorkOrders = new List<Account>();
	if (Trigger.isInsert){
		System.debug('IN INSERT');
	} else if (Trigger.isUpdate){
		System.debug('IN UPDATE!!!!');
		for (Account a : Trigger.old){
			oldMap.put(a.Id, a);
		}
	}
	if (Trigger.isInsert && Trigger.isAfter){
		List<Account> toCreateLocationAndAddress = new List<Account>();
		List<Account> toCreateCompanyOrSalesData = new List<Account>();

		for (Account a : Trigger.new){
			if(a.OperatingHoursId != null ){
				accountForWorkOrders.add(a) ;
			}
			if(a.ShippingStreet != null && a.ShippingPostalCode != null && a.ShippingCountry != null && a.ShippingCity != null) {
				toCreateLocationAndAddress.add(a);
			}
			if(a.AutoCreateCompanyData__c != null || a.AutoCreateSalesData__c != null) {
				toCreateCompanyOrSalesData.add(a);
			}
		}

		if(!accountForWorkOrders.isEmpty()){
			AccountService.updateAccountWorkOrders(accountForWorkOrders) ;
		}

		if(!toCreateLocationAndAddress.isEmpty()) {
			// Creating standard Address and Location
			
			AccountService.createAddressAndLocation(Trigger.newMap, toCreateLocationAndAddress);
		}

		// Publishing CompanyAndSalesDataEvent to auto create Account Company/ASO + ATC

		if(!toCreateCompanyOrSalesData.isEmpty()) {
			List<CompanyAndSalesDataEvent__e> eventsToPublish = new List<CompanyAndSalesDataEvent__e>();

			for(Account a : toCreateCompanyOrSalesData) {
				CompanyAndSalesDataEvent__e dataCreationEvent = new CompanyAndSalesDataEvent__e(
					Account_Id__c = a.Id
				);
				eventsToPublish.add(dataCreationEvent);
			}

			if(!eventsToPublish.isEmpty()) {
				List<Database.SaveResult> results = EventBus.publish(eventsToPublish);
			}
		}
	}

	//If any Address field has changed, update the related MAIN Address record
	if (Trigger.isUpdate && Trigger.isBefore){
		for (Account a : Trigger.new){
			Account oldAccount = oldMap.get(a.Id);
			if (AccountService.hasAddressOnAccountChanged(a, oldAccount) == true){
				addressChangedAccs.add(a);
			}
			if(a.OperatingHoursId != trigger.oldMap.get(a.Id).OperatingHoursId){
				accountForWorkOrders.add(a) ;
			}
		}
		if(!accountForWorkOrders.isEmpty()){
			AccountService.updateAccountWorkOrders(accountForWorkOrders) ;
		}
		
		if (!addressChangedAccs.isEmpty()){
			AccountService.updateMainAddress(addressChangedAccs, oldMap);
		}

		AccountService.setIsPortalSync(Trigger.new, Trigger.oldMap, true, false);
	}

	/* if(Trigger.isUpdate && Trigger.isAfter) {
		AccountService.setIsPortalSync(Trigger.new, Trigger.oldMap, true);
	} */

	if (Trigger.isInsert && Trigger.isAfter){
		if(!System.isFuture()) {
			for (Account a : Trigger.new){
				accountIdsToCreate.add(a.Id);
			}

			if(FeatureManagementService.getFeatureStatus('SAP_Customer_Create') || Test.isRunningTest()) {
				// Publishing events to tell the component that a callout is starting

				/* List<Starting_Callout_Event__e> startingCalloutEvents = new List<Starting_Callout_Event__e>();

				for(Id accountId : accountIdsToCreate) {
					Starting_Callout_Event__e startingCalloutEvent = new Starting_Callout_Event__e(
						RecordId__c = accountId
					);

					startingCalloutEvents.add(startingCalloutEvent);
				} */
				
				/* if(!startingCalloutEvents.isEmpty()) {
					List<Database.SaveResult> results = EventBus.publish(startingCalloutEvents);
					System.debug('EVENTS STARTING CALLOUT PUBLISHED size: ' + results.size());
				} */
				
				AccountService.futureCreateCallout(accountIdsToCreate);
			}
		}	
	}
	
	else if(Trigger.isUpdate && Trigger.isBefore) {
		if(!System.isFuture()) {
			for (Account a : Trigger.new){
				Account oldAccount = oldMap.get(a.Id);
				if (AccountService.hasChanged(a, oldAccount) == true){
					System.debug('CHANGED!!!!!! ');
					if (a.IsCreatedSAP__c == false){
						accountIdsToCreate.add(a.Id);
					} else if (a.isCreatedSAP__c == true){
						accountIdsToUpdate.add(a.Id);
						a.IsSyncSAP__c = 'NotSync';
					}
				} else{
					System.debug('ACCOUNT HAS NOT CHANGED');
				}
			}
			if (!accountIdsToCreate.isEmpty()){
				if(FeatureManagementService.getFeatureStatus('SAP_Customer_Create') || Test.isRunningTest()) {
					/* When creating an Account, Location__c and Account_ID__c get immediately updated. Thus, there is a new creation attempt
					(creation because the insert trigger hasn't still even created the Account on SAP). Therefore, a DmlException is thrown, because
					it is trying to call a future method (futureCreateCallout) from another future (updateAccountExtId). Since it is ok for me that
					the second creation attempt fails, I simply handle the Exception doing nothing.*/
					System.debug('Calling futureCreateCallout');
					try{
						// Publishing events to tell the component that a callout is starting

						/* List<Starting_Callout_Event__e> startingCalloutEvents = new List<Starting_Callout_Event__e>();

						for(Id accountId : accountIdsToCreate) {
							Starting_Callout_Event__e startingCalloutEvent = new Starting_Callout_Event__e(
								RecordId__c = accountId
							);

							startingCalloutEvents.add(startingCalloutEvent);
						} */

						/* if(!startingCalloutEvents.isEmpty()) {
							List<Database.SaveResult> results = EventBus.publish(startingCalloutEvents);
							System.debug('EVENTS STARTING CALLOUT PUBLISHED size: ' + results.size());
						} */

						AccountService.futureCreateCallout(accountIdsToCreate);
					
					} catch (Exception e){
						System.debug('Creation callout not executed: ' + e.getMessage());
					}
				}
			}
			if (!accountIdsToUpdate.isEmpty()){
				if(FeatureManagementService.getFeatureStatus('SAP_Customer_Update') || Test.isRunningTest()) {
					System.debug('Calling futureUpdateCallout');
					try{
						// Publishing events to tell the component that a callout is starting
						
						/* List<Starting_Callout_Event__e> startingCalloutEvents = new List<Starting_Callout_Event__e>();

						for(Id accountId : accountIdsToUpdate) {
							Starting_Callout_Event__e startingCalloutEvent = new Starting_Callout_Event__e(
								RecordId__c = accountId
							);

							startingCalloutEvents.add(startingCalloutEvent);
						} */

						/* if(!startingCalloutEvents.isEmpty()) {
							List<Database.SaveResult> results = EventBus.publish(startingCalloutEvents);
							System.debug('EVENTS STARTING CALLOUT PUBLISHED size: ' + results.size());
						} */

						AccountService.futureUpdateCallout(accountIdsToUpdate);
					} catch (Exception e){
						System.debug('Update callout not executed: ' + e.getMessage());
					}
				}
			}
		}
	}
	if (Trigger.isBefore){
		//update the BirthDateSearch__c field with the PersonBirthdate field
		AccountService.setUpperCaseIBAN(Trigger.new);
		for (Account a : Trigger.new){
			Date personbirthdaydate = a.PersonBirthdate;
			if (personbirthdaydate != null){
				String BirthDateSearch = personbirthdaydate.day() + '/' + personbirthdaydate.month() + '/' + personbirthdaydate.year();
				a.BirthDateSearch__c = BirthDateSearch;
			} else{
				a.BirthDateSearch__c = null;
			}
		}
	}
}