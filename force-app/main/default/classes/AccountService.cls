public class AccountService {

    //Updates field Account_External_Id__c with the value of AutoNumber__c, because AccountInsertTrigger can't
    public static void updateAccountExtId(List<Id> relatedIds, List<Id> locationIds) {
        List<Account> relatedAccounts = AccountDAO.getAccountFromIds(relatedIds);
        List<Account> accountToUpdate = new List<Account>();
        List<Account> createdAccounts = new List<Account>();
        List<Id> accountIds = new List<Id>();
        Map<Id, Schema.Location> locationToAccountMap = new Map<Id, Schema.Location>();

        //Also need Locations to update related Account's Location__c field
        List<Schema.Location> locations = [SELECT Id, Account__c, Location_Id__c FROM Location WHERE Id IN: locationIds];
    
        for(Schema.Location l : locations) {
            locationToAccountMap.put(l.Account__c, l);
        }

        for (Account a : relatedAccounts) {
            accountIds.add(a.Id);
            Account tmpAccount = new Account();
            tmpAccount.Id = a.Id;
            if(a.Account_External_Id__c == null) {
                tmpAccount.Account_External_Id__c = a.AutoNumber__c;
            }
            tmpAccount.Location__c = (locationToAccountMap.get(a.Id)).Id;
            tmpAccount.Address_ID__c = (locationToAccountMap.get(a.Id)).Location_Id__c;
            accountToUpdate.add(tmpAccount);
        }

        update accountToUpdate; 
    }

    public static void updateAccountWorkOrders(List<Account> accountForWorkOrders){
        Map<Id,Id> accountIdandOpertinghourId = new Map<Id,Id>();
        List<Id>  accountIds = new List<Id>();
        for(Account a : accountForWorkOrders){
            accountIdandOpertinghourId.put(a.Id,a.OperatingHoursId) ;
            accountIds.add(a.Id) ;
        }
        List<WorkOrder> workOders = new List<WorkOrder>();
        List<WorkOrder> workOrdersUpdate = new List<WorkOrder>();
        List<String> querfields = new List<String>{'Id','FSL__VisitingHours__c ','Status','AccountId'} ;
        workOders = WorkOrderDAO.getWorkOrdersFromAccountIds(querfields,accountIds);
        for (WorkOrder wo : workOders) {
            if ((wo.FSL__VisitingHours__c == null || wo.FSL__VisitingHours__c != accountIdandOpertinghourId.get(wo.AccountId)) && (wo.Status == 'New' || wo.Status == 'None' || wo.Status == 'DeliveryBlocked' )) {
                wo.FSL__VisitingHours__c = accountIdandOpertinghourId.get(wo.AccountId) ;
                workOrdersUpdate.add(wo) ;
            } 
        }
        if (!workOrdersUpdate.isEmpty()) {
            update workOrdersUpdate ;
        }
    }

    public static Boolean hasChanged(Account a, Account oldAccount) {
        if (a.Entity_Type__c != oldAccount.Entity_Type__c){
            return true;
        }
        if(a.Name != oldAccount.Name) {
            return true;
        }
        if(a.Name_2__c != oldAccount.Name_2__c) {
            return true;
        }
        if(a.Name_3__c != oldAccount.Name_3__c) {
            return true;
        }
        if(a.Name_4__c != oldAccount.Name_4__c) {
            return true;
        }
        if(a.Salutation != oldAccount.Salutation) {
            return true;
        }
        if(a.MiddleName != oldAccount.MiddleName) {
            return true;
        }
        if(a.FirstName != oldAccount.FirstName) {
            return true;
        }
        if(a.LastName != oldAccount.LastName) {
            return true;
        }
        if(a.PersonBirthdate != oldAccount.PersonBirthdate) {
            return true;
        }
        if(a.HealthCloudGA__DeceasedDate__pc != oldAccount.HealthCloudGA__DeceasedDate__pc) {
            return true;
        }
        if(a.HealthCloudGA__Gender__pc != oldAccount.HealthCloudGA__Gender__pc) {
            return true;
        }
        if(a.Birth_city__pc != oldAccount.Birth_city__pc) {
            return true;
        }
        if(a.Birth_country__pc != oldAccount.Birth_country__pc) {
            return true;
        }
        if(a.Fiscal_Code__c != oldAccount.Fiscal_Code__c) {
            return true;
        }
        if(a.VAT_Number__c != oldAccount.VAT_Number__c) {
            return true;
        }
        if(a.Social_Security_Number__pc != oldAccount.Social_Security_Number__pc) {
            return true;
        }
        if(a.PersonHomePhone != oldAccount.PersonHomePhone) {
            return true;
        }
        if(a.Work_Phone__c != oldAccount.Work_Phone__c) {
            return true;
        }
        if(a.Phone != oldAccount.Phone) {
            return true;
        }
        if(a.PersonMobilePhone != oldAccount.PersonMobilePhone) {
            return true;
        }
        if(a.PersonEmail != oldAccount.PersonEmail) {
            return true;
        }
        if(a.Email_B2B__c != oldAccount.Email_B2B__c) {
            return true;
        }
        if(a.Fax != oldAccount.Fax) {
            return true;
        }
        if(a.Patients_insurance_number__pc != oldAccount.Patients_insurance_number__pc) {
            return true;
        }
        if(a.Iban__c != oldAccount.Iban__c) {
            return true;
        }
        if(a.Billing_Reference__c != oldAccount.Billing_Reference__c) {
            return true;
        }
        if(a.Customer_Purchase_Order_Number__c != oldAccount.Customer_Purchase_Order_Number__c) {
            return true;
        }
        if(a.Customer_Purchase_Order_Date__c != oldAccount.Customer_Purchase_Order_Date__c) {
            return true;
        }
        if(a.Chamber_of_commerce_number__c != oldAccount.Chamber_of_commerce_number__c) {
            return true;
        }
        if(a.Language__c != oldAccount.Language__c) {
            return true;
        }
        if(a.Description != oldAccount.Description) {
            return true;
        }
        if(a.TransportationZone__c != oldAccount.TransportationZone__c) {
            return true;
        }
        if(a.Bank_Account_Owner__c != oldAccount.Bank_Account_Owner__c) {
            return true;
        }
        if(a.Dunning_Email__c != oldAccount.Dunning_Email__c) {
            return true;
        }
        if(a.Billing_Email__c != oldAccount.Billing_Email__c) {
            return true;
        }
        if(a.Regional_Grouping__c != oldAccount.Regional_Grouping__c) {
            return true;
        }

        return false;
    }

    @AuraEnabled
    @future(callout=true)
    public static void futureCreateCallout(List<Id> accountIds) {
        List<Account> personAccountToAlign = new List<Account>();
        List<Account> businessAccountToAlign = new List<Account>();
        List<Callout_Logger__c> logsToInsert = new List<Callout_Logger__c>();
        List<Delete_Older_Logs__e> deleteOlderLogsEvents = new List<Delete_Older_Logs__e>();

        List<Account> relatedAccounts = AccountDAO.getAccountFromIds(accountIds);
        List<String> queryFields = new List<String>{'Account__c', 'Location_Id__c'};
        Map<Id, Schema.Location> locationMap = new Map<Id, Schema.Location>();
        List<Schema.Location> relatedLocations = LocationDAO.getLocationsFromAccountIds(queryFields, accountIds);

        for(Schema.Location l : relatedLocations) {
            locationMap.put(l.Account__c, l);
        }

        for (Account acc : relatedAccounts) {
            Schema.Location relatedLocation = locationMap.get(acc.Id);
            ReturnDTO returnDTO = doAccountCreateCallout(acc, relatedLocation);

            System.debug('ReturnDTO loggerList: ' + returnDTO.loggerList);
            System.debug('ReturnDTO personAccounts: ' + returnDTO.personAccounts);
            System.debug('ReturnDTO businessAccounts: ' + returnDTO.businessAccounts);
            System.debug('ReturnDTO deleteOlderLogsEvents: ' + returnDTO.deleteOlderLogsEvents);

            for(Callout_Logger__c cl : returnDTO.loggerList) {
                logsToInsert.add(cl);
            }

            for(Account a : returnDTO.personAccounts) {
                personAccountToAlign.add(a);
            }

            for(Account a : returnDTO.businessAccounts) {
                businessAccountToAlign.add(a);
            }

            for(Delete_Older_Logs__e e : returnDTO.deleteOlderLogsEvents) {
                deleteOlderLogsEvents.add(e);
            }
        }

        if(!personAccountToAlign.isEmpty()) {
            System.debug('PersonAccountToAlign NOT NULL: ' + personAccountToAlign);
            update personAccountToAlign;
        }

        if(!businessAccountToAlign.isEmpty()) {
            update businessAccountToAlign;
        }

        if(!logsToInsert.isEmpty()) {
            insert logsToInsert;
        }

        if(!deleteOlderLogsEvents.isEmpty()) {
            List<Database.SaveResult> results = EventBus.publish(deleteOlderLogsEvents);
            System.debug('EVENTS PUBLISHED size: ' + results.size());
        }
    }

    @AuraEnabled
    @future(callout=true)
    public static void futureUpdateCallout(List<Id> accountIds) {
        List<Account> personAccountToAlign = new List<Account>();
        List<Account> businessAccountToAlign = new List<Account>();
        List<Callout_Logger__c> logsToInsert = new List<Callout_Logger__c>();
        List<Delete_Older_Logs__e> deleteOlderLogsEvents = new List<Delete_Older_Logs__e>();

        List<Account> relatedAccounts = AccountDAO.getAccountFromIds(accountIds);

        for (Account acc : relatedAccounts) {
            ReturnDTO returnDTO = doAccountUpdateCallout(acc);

            System.debug('ReturnDTO loggerList: ' + returnDTO.loggerList);
            System.debug('ReturnDTO personAccounts: ' + returnDTO.personAccounts);
            System.debug('ReturnDTO businessAccounts: ' + returnDTO.businessAccounts);
            System.debug('ReturnDTO deleteOlderLogsEvents: ' + returnDTO.deleteOlderLogsEvents);

            for(Callout_Logger__c cl : returnDTO.loggerList) {
                logsToInsert.add(cl);
            }

            for(Account a : returnDTO.personAccounts) {
                personAccountToAlign.add(a);
            }

            for(Account a : returnDTO.businessAccounts) {
                businessAccountToAlign.add(a);
            }

            for(Delete_Older_Logs__e event : returnDTO.deleteOlderLogsEvents) {
                deleteOlderLogsEvents.add(event);
            }
        }

        if(!personAccountToAlign.isEmpty()) {
            System.debug('PersonAccountToAlign NOT NULL: ' + personAccountToAlign);
            update personAccountToAlign;
        }

        if(!businessAccountToAlign.isEmpty()) {
            update businessAccountToAlign;
        }

        if(!logsToInsert.isEmpty()) {
            insert logsToInsert;
        }

        if(!deleteOlderLogsEvents.isEmpty()) {
            List<Database.SaveResult> results = EventBus.publish(deleteOlderLogsEvents);
            System.debug('EVENTS PUBLISHED size: ' + results.size());
        }
    }
    
    public static ReturnDTO doAccountCreateCallout(Account acc) {
        return doAccountCreateCallout(acc, null);
    }

    public static ReturnDTO doAccountCreateCallout(Account acc, Schema.Location relatedLocation) {
        //List<Status_Change_Event__e> changeEvents = new List<Status_Change_Event__e>();
        List<Callout_Logger__c> loggerList = new List<Callout_Logger__c>();
        List<Delete_Older_Logs__e> deleteOlderLogsEvents = new List<Delete_Older_Logs__e>();
        //List<Id> createdAccountIds = new List<Id>();
        Boolean isSuccess = false;
        AccountCreateDTO dto = new AccountCreateDTO(acc, relatedLocation);
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:SAP_CUSTOMER_CREATE');
        req.setMethod('POST');
        req.setTimeout(60000);

        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');

        // create body request
        String reqJSON = JSON.serialize(dto);
        System.debug('DTO:::: ' + dto);
        System.debug(reqJSON);
        req.setBody(reqJSON);

        Http http = new Http();
        HTTPResponse res = new HttpResponse();

        // initialize timers
        Long startTime = Datetime.now().getTime();
        Long finishTime;
        Long totalTime;

        try {
            res = http.send(req);
            System.debug(res);
            System.debug(res.getBody());
            finishTime = Datetime.now().getTime();
            totalTime = (finishTime - startTime);
            String responseUnparsed = res.getBody();
            String response1 = responseUnparsed.replaceAll('Object__c', 'ObjectName');
            String response2 = response1.replaceAll('__c', '');
            String recordId;

            if(acc.Account_External_Id__c != null) {
            recordId = acc.Account_External_Id__c;
            }
            else {
            recordId = acc.AutoNumber__c;
            }

            SAPResponseDTO responseDTO = (SAPResponseDTO) System.JSON.deserialize(response2, SAPResponseDTO.class);
            for(SAPResponseDTO.ResultList resList : responseDTO.resultList) {
                SAPResponseDTO.Log_event logEvent = resList.log_event;
                System.debug('Account Id: ' + acc.Id); //NULL
                if(logEvent.errorList != null) {
                    for(SAPResponseDTO.ErrorList errorList : logEvent.errorList) {
                        Callout_Logger__c calloutLogger = CalloutLoggerService.initializeUpdateCalloutLog(String.valueOf(res.getStatusCode()) /*always 200, do i need
                        the single resList's one?*/, errorList.errorType, false, 
                        'Account', errorList.operation_Name, errorList.operationType, 'SFDC', 
                        recordId, // External ID?
                        'SFDC_SAP4HANA__PATIENT_CREATE',
                        Datetime.now(), errorList.uuid_Flow, errorList.error_Description, req.getBody(), 'SAP4HANA', 'FAIL');
                        loggerList.add(calloutLogger);
                        System.debug('CALLOUT LOGGER: ' + calloutLogger);
                    }
                }
                if(logEvent.warningList != null) {
                    for(SAPResponseDTO.WarningList warningList : logEvent.warningList) {
                        Callout_Logger__c calloutLogger = CalloutLoggerService.initializeUpdateCalloutLog(String.valueOf(res.getStatusCode()), warningList.errorType, false, 
                        'Account', warningList.operation_Name, warningList.operationType, 'SFDC', recordId, 'SFDC_SAP4HANA__PATIENT_CREATE', 
                        Datetime.now(), warningList.uuid_Flow, warningList.error_Description, req.getBody(), 'SAP4HANA', 'WARN');
                        System.debug('CALLOUT_LOGGER: ' + calloutLogger);
                        loggerList.add(calloutLogger);
                        System.debug('CALLOUT LOGGER: ' + calloutLogger);
                    }
                }
            
                if(resList.success == true) {
                    //createdAccountIds.add(acc.Id);
                    isSuccess = true;

                    // Deleting all Callout Loggers for this recordId if the call is a complete success (no error nor warning logs)

                    if(loggerList.isEmpty()) {
                        deleteOlderLogsEvents.add(
                            new Delete_Older_Logs__e(
                                Record_Id__c = recordId,
                                Service__c = 'SFDC_SAP4HANA__PATIENT_CREATE'
                            )
                        );
                    }
                }
            }
        } catch (Exception e) {
            System.debug('EXCEPTION!!!! : ' + e.getMessage());
            System.debug('Exception: ' + e);
            System.debug('Exception line number: ' + e.getLineNumber());

            String recordId;

            if(acc.Account_External_Id__c != null) {
            recordId = acc.Account_External_Id__c;
            }
            else {
            recordId = acc.AutoNumber__c;
            }

            Callout_Logger__c calloutLogger = CalloutLoggerService.initializeUpdateCalloutLog(
                null, 
                null, 
                false, 
                'Account', 
                'CREATE', 
                'POST', 
                'SFDC', 
                recordId, 
                'SFDC_SAP4HANA__PATIENT_CREATE', 
                Datetime.now(), 
                null, 
                e.getMessage(), 
                req.getBody(), 
                'SAP4HANA', 
                'FAIL'
            );

            loggerList.add(calloutLogger);
        }

        List<Account> personAccounts = new List<Account>();
        List<Account> businessAccounts = new List<Account>();

        Account tempAccount = new Account();
        tempAccount.Id = acc.Id;

        if(isSuccess) {
            tempAccount.IsCreatedSAP__c = true;
            tempAccount.IsSyncSAP__c = 'Sync';
        }
        else {
            // TO SET IsCreatedSAP__c = false; ?
        }

        if(acc.RecordType.DeveloperName == 'Account_Patient' || acc.RecordType.DeveloperName == 'Account_B2C' || acc.RecordType.DeveloperName == 'Account_Caregiver' ||
        acc.RecordType.DeveloperName == 'Account_PrescriberPhysician') {
            personAccounts.add(tempAccount);
        }
        else if(acc.RecordType.DeveloperName == 'Account_B2B' || acc.RecordType.DeveloperName == 'Account_Vivisol') {
            businessAccounts.add(tempAccount);
        }

        ReturnDTO toReturn = new ReturnDTO(loggerList, personAccounts, businessAccounts, deleteOlderLogsEvents);
        
        return toReturn;
    }

    public static ReturnDTO doAccountUpdateCallout(Account acc) {
        //List<Status_Change_Event__e> changeEvents = new List<Status_Change_Event__e>();
        List<Callout_Logger__c> loggerList = new List<Callout_Logger__c>();
        List<Delete_Older_Logs__e> deleteOlderLogsEvents = new List<Delete_Older_Logs__e>();
        //List<Id> updatedAccountIds = new List<Id>();
        Boolean isSuccess = false;
        AccountUpdateDTO dto = new AccountUpdateDTO(acc, null);
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:SAP_CUSTOMER_UPDATE');
        req.setMethod('POST');
        req.setTimeout(60000);

        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');

        // create body request
        String reqJSON = JSON.serialize(dto);
        System.debug('DTO:::: ' + dto);
        System.debug(reqJSON);
        req.setBody(reqJSON);

        Http http = new Http();
        HTTPResponse res = new HttpResponse();

        // initialize timers
        Long startTime = Datetime.now().getTime();
        Long finishTime;
        Long totalTime;

        try {
            res = http.send(req);
            System.debug(res);
            System.debug(res.getBody());
            finishTime = Datetime.now().getTime();
            totalTime = (finishTime - startTime);
            String responseUnparsed = res.getBody();
            String response1 = responseUnparsed.replaceAll('Object__c', 'ObjectName');
            String response2 = response1.replaceAll('__c', '');
            String recordId;

            if(acc.Account_External_Id__c != null) {
                recordId = acc.Account_External_Id__c;
            }
            else {
                recordId = acc.AutoNumber__c;
            }

            SAPResponseDTO responseDTO = (SAPResponseDTO) System.JSON.deserialize(response2, SAPResponseDTO.class);
            for(SAPResponseDTO.ResultList resList : responseDTO.resultList) {
                SAPResponseDTO.Log_event logEvent = resList.log_event;
                System.debug('Account Id: ' + acc.Id); //NULL
                if(logEvent.errorList != null) {
                    for(SAPResponseDTO.ErrorList errorList : logEvent.errorList) {
                        Callout_Logger__c calloutLogger = CalloutLoggerService.initializeUpdateCalloutLog(String.valueOf(res.getStatusCode()) /*always 200, do i need
                        the single resList's one?*/, errorList.errorType, false, 
                        'Account', errorList.operation_Name, errorList.operationType, 'SFDC', 
                        recordId, //THIS IS NULL
                        'SFDC_SAP4HANA__PATIENT_UPDATE',
                        Datetime.now(), errorList.uuid_Flow, errorList.error_Description, req.getBody(), 'SAP4HANA', 'FAIL');
                        loggerList.add(calloutLogger);
                        System.debug('CALLOUT LOGGER: ' + calloutLogger);
                    }
                }
                if(logEvent.warningList != null) {
                    for(SAPResponseDTO.WarningList warningList : logEvent.warningList) {
                        Callout_Logger__c calloutLogger = CalloutLoggerService.initializeUpdateCalloutLog(String.valueOf(res.getStatusCode()), warningList.errorType, false, 
                        'Account', warningList.operation_Name, warningList.operationType, 'SFDC', recordId, 'SFDC_SAP4HANA__PATIENT_UPDATE', 
                        Datetime.now(), warningList.uuid_Flow, warningList.error_Description, req.getBody(), 'SAP4HANA', 'WARN');
                        System.debug('CALLOUT_LOGGER: ' + calloutLogger);
                        loggerList.add(calloutLogger);
                        System.debug('CALLOUT LOGGER: ' + calloutLogger);
                    }
                }
            
                if(resList.success == true) {
                    isSuccess = true;

                    // Deleting all Callout Loggers for this recordId if the call is a complete success (no error nor warning logs)

                    if(loggerList.isEmpty()) {
                        deleteOlderLogsEvents.add(
                            new Delete_Older_Logs__e(
                                Record_Id__c = recordId,
                                Service__c = 'SFDC_SAP4HANA__PATIENT_UPDATE'
                            )
                        );
                    }
                }
            }
            
        } catch (Exception e) {
            System.debug('EXCEPTION!!!! : ' + e.getMessage());
            System.debug('Exception: ' + e);
            System.debug('Exception line number: ' + e.getLineNumber());

            String recordId;

            if(acc.Account_External_Id__c != null) {
            recordId = acc.Account_External_Id__c;
            }
            else {
            recordId = acc.AutoNumber__c;
            }

            Callout_Logger__c calloutLogger = CalloutLoggerService.initializeUpdateCalloutLog(
                null, 
                null, 
                false, 
                'Account', 
                'UPDATE', 
                'POST', 
                'SFDC', 
                recordId, 
                'SFDC_SAP4HANA__PATIENT_UPDATE', 
                Datetime.now(), 
                null, 
                e.getMessage(), 
                req.getBody(), 
                'SAP4HANA', 
                'FAIL'
            );

            loggerList.add(calloutLogger);
        }

        List<Account> personAccounts = new List<Account>();
        List<Account> businessAccounts = new List<Account>();

        Account tempAccount = new Account();
        tempAccount.Id = acc.Id;

        if(isSuccess) {
            tempAccount.IsCreatedSAP__c = true;
            tempAccount.IsSyncSAP__c = 'Sync';
        }
        else {
            if(acc.IsSyncSAP__c == 'Sync') {
                tempAccount.IsSyncSAP__c = 'NotSync';
            }
        }

        if(acc.RecordType.DeveloperName == 'Account_Patient' || acc.RecordType.DeveloperName == 'Account_B2C' || acc.RecordType.DeveloperName == 'Account_Caregiver' ||
        acc.RecordType.DeveloperName == 'Account_PrescriberPhysician') {
            System.debug('THIS IS A PERSON ACCOUNT');
            personAccounts.add(tempAccount);
        }
        else if(acc.RecordType.DeveloperName == 'Account_B2B' || acc.RecordType.DeveloperName == 'Account_Vivisol') {
            businessAccounts.add(tempAccount);
        }

        ReturnDTO toReturn = new ReturnDTO(loggerList, personAccounts, businessAccounts, deleteOlderLogsEvents);
        
        return toReturn;
    }

    public static void updateMainAddress(List<Account> newAccounts, Map<Id, Account> oldAccountMap) {
        List<Schema.Address> addressesToUpdate = new List<Schema.Address>();
        Map<Id,Account> locationAccountMap = new Map<Id,Account>(); 
        List<Id> relatedLocationIds = new List<Id>();
        for(Account acc : newAccounts) {
            if (acc.Location__c != null){
                relatedLocationIds.add(acc.Location__c);
                locationAccountMap.put(acc.Location__c, acc);
            }
        }
        if (!relatedLocationIds.isEmpty()){
            List<Schema.Address> allAddresses = AddressDAO.getAddressesFromLocation(relatedLocationIds);
            for(Schema.Address address : allAddresses) {
                if(address.AddressType == 'XXDEFAULT') {
                    Account tmpAcc = locationAccountMap.get(address.ParentId);
                    Account oldAccount = oldAccountMap.get(tmpAcc.Id);
                    if(tmpAcc.ShippingStreet != oldAccount.ShippingStreet) {
                        address.Street = tmpAcc.ShippingStreet;
                    }
                    if(tmpAcc.ShippingCity != oldAccount.ShippingCity) {
                        address.City = tmpAcc.ShippingCity;
                    }
                    if(tmpAcc.ShippingPostalCode != oldAccount.ShippingPostalCode) {
                        address.PostalCode = tmpAcc.ShippingPostalCode;
                    }
                    if(tmpAcc.ShippingStateCode != oldAccount.ShippingStateCode) {
                        address.StateCode = tmpAcc.ShippingStateCode;
                    }
                    if(tmpAcc.ShippingCountryCode != oldAccount.ShippingCountryCode) {
                        address.CountryCode = tmpAcc.ShippingCountryCode;
                    }
                    if(tmpAcc.Regional_Grouping__c != oldAccount.Regional_Grouping__c) {
                        address.Regional_Grouping__c = tmpAcc.Regional_Grouping__c;
                    }                    
                    addressesToUpdate.add(address);
                }
            }
            if (!addressesToUpdate.isEmpty()){
                update addressesToUpdate; //bulk approach even if the record with "XXDEFAULT" will always be only one
            }
        }
    }

    // DTO inner-class to return both loggerList and person/business accounts from the above method
    public class ReturnDTO {
        public List<Callout_Logger__c> loggerList;
        public List<Account> personAccounts;
        public List<Account> businessAccounts;
        public List<Delete_Older_Logs__e> deleteOlderLogsEvents;

        public ReturnDTO(List<Callout_Logger__c> loggerList, List<Account> personAccounts, List<Account> businessAccounts, List<Delete_Older_Logs__e> deleteOlderLogsEvents) {
            this.loggerList = loggerList;
            this.personAccounts = personAccounts;
            this.businessAccounts = businessAccounts;
            this.deleteOlderLogsEvents = deleteOlderLogsEvents;
        }
    }

    public static void createAddressAndLocation (Map<Id,Account> newAccountMap, List<Account> accountList){
        List<Schema.Location> locationsToAdd = new List<Schema.Location>();
        List<Id> locationIds = new List<Id>();
        List<Id> accountIds = new List<Id>();
        Map<Id, Schema.Location> locationMap = new Map<Id, Schema.Location>();
        List<Schema.Address> addressesToAdd = new List<Schema.Address>();


        for (Account acc : accountList){
            accountIds.add(acc.Id);
            String name = '';
			if (acc.IsPersonAccount == false){
				name = acc.Name;
			} else if (acc.IsPersonAccount == true){
				name = '';
				if (acc.FirstName != null){
					name = name + acc.FirstName + ' ';
				} 
				if (acc.MiddleName != null){
                    name = name + acc.MiddleName + ' ';
                }
                name = name + acc.LastName + ' ';
            }
            Schema.Location newLocation = new Schema.Location();
            newLocation.Account__c = acc.Id;
            newLocation.IsInventoryLocation = true;
            newLocation.Name = name + ' - Standard Address';
            newLocation.LocationType = 'Site';
            newLocation.Sales_Org_Code__c = acc.Regional_Grouping__c;

			locationsToAdd.add(newLocation);
        }
                
        //System.debug('future per:' + autoNumList);
		insert locationsToAdd;
		//Call future method on Service Class to update Account_External_Id__c with the value of AutoNumber__c and Location__c field
		for (Schema.Location l : locationsToAdd){
			locationIds.add(l.Id);
		}

		//Have to query to iterate on a list of Locations with LocationNumber__c generated
		List<Schema.Location> insertedLocations = [SELECT Id, Account__c, LocationNumber__c, Location_Id__c
		                                           FROM Location
		                                           WHERE Account__c IN :accountIds];
		List<Id> addressIds = new List<Id>();
		for (Schema.Location l : insertedLocations){
			locationMap.put(l.Id, l);
            Schema.Address newAddress =new Schema.Address();
            newAddress.AddressType = newAccountMap.get(l.Account__c).Shipping_Address_Type__c;
            newAddress.LocationType = 'Site';
            newAddress.ParentId = l.Id;
            newAddress.City = newAccountMap.get(l.Account__c).ShippingCity;
            newAddress.Street = newAccountMap.get(l.Account__c).ShippingStreet;
            newAddress.StateCode = newAccountMap.get(l.Account__c).ShippingStateCode;
            newAddress.CountryCode = newAccountMap.get(l.Account__c).ShippingCountryCode;
            newAddress.PostalCode = newAccountMap.get(l.Account__c).ShippingPostalCode;
            newAddress.Is_Default__c = true;
            newAddress.Regional_Grouping__c = newAccountMap.get(l.Account__c).Regional_Grouping__c;
			addressesToAdd.add(newAddress);
		}
		insert addressesToAdd;
		for (Schema.Address a : addressesToAdd){
			addressIds.add(a.Id);
		}
		//Querying again the inserted Addresses to get the Autonumber  "Name"
		List<Schema.Address> insertedAddresses = [SELECT Id, Name, ParentId
		                                          FROM Address
		                                          WHERE Id IN :addressIds];
		//Updating new Locations with fields from the new Address
		for (Schema.Location l : insertedLocations){
			for (Schema.Address add : insertedAddresses){
				locationMap.get(add.ParentId).VisitorAddressId = add.Id;
				System.debug('Id Address: ' + add.Id);
				locationMap.get(add.ParentId).Location_Id__c = add.Name;
				System.debug('Address Name: ' + add.Name);
			}
		}
		update insertedLocations;
		//This method also updates the Location_Id__c of a location with the Name of the Address, beacuse this one is an Autonumber (not usable in a Trigger)
		AccountService.updateAccountExtId(accountIds, locationIds);
    }

    public static Boolean hasAddressOnAccountChanged(Account a, Account oldAccount) {
        if (a.ShippingStreet != oldAccount.ShippingStreet){
            return true;
        }
        if (a.ShippingCity != oldAccount.ShippingCity){
            return true;
        }
        if (a.ShippingPostalCode != oldAccount.ShippingPostalCode){
            return true;
        }
        if (a.ShippingStateCode != oldAccount.ShippingStateCode){
            return true;
        }
        if (a.ShippingCountryCode != oldAccount.ShippingCountryCode){
            return true;
        }
        if(a.Regional_Grouping__c != oldAccount.Regional_Grouping__c) {
            return true;
        }

        return false;
    }

    public static void setIsPortalSync(List<Account> accounts, Map<Id, Account> oldMap, Boolean checkProfile, Boolean performDML) {
        SObjectServiceClass.setIsPortalSync(accounts, oldMap, 'Account', true, performDML);
    }

    public static void setUpperCaseIBAN(List<Account> accounts) {
        for (Account a:accounts){
            if (a.iban__c!=null){
                a.iban__c = a.iban__c.toUpperCase();
            }
        }
    }

    public static void createCompanyData(List<Account> accounts) {
        System.debug('----- createCompanyData -----');
        List<String> companyCodes = new List<String>();
        List<String> recordTypes = new List<String>();
        List<String> entityTypes = new List<String>();
        List<String> newEntityTypesList = new List<String>();
        List<Account_Company__c> allRelatedAccountCompanies = new List<Account_Company__c>();
        List<Account_Company__c> toInsert = new List<Account_Company__c>();

        Map<String, List<Account_Company__c>> accountCompanyMap = new Map<String, List<Account_Company__c>>();

        for(Account a : accounts) {
            companyCodes.add(a.AutoCreateCompanyData__c);
            recordTypes.add(a.RecordType.DeveloperName);
            entityTypes.add(a.Entity_type__c);
        }
        System.debug('entityTypes: ' + entityTypes);

        for(String s : entityTypes) {
            String newValue = '\'' + s + '\'';
            newEntityTypesList.add(newValue);
        }

        String entityTypesString = String.join(newEntityTypesList, ',');
        System.debug('entityTypes after transformation: ' + newEntityTypesList);
        System.debug('entityTypesString ' + entityTypesString);

        String query = 'SELECT Company_Code__c, Dunning_Block__c, Dunning_Procedure__c, Head_Office__c, Key_for_sorting_according_to_assignment__c, ' +
        'Payment_Terms__c, Payment_Method__c, Reconciliation_Account__c, UzoviCode__c, OwnerId, AccountRecordType__c, EntityType__c ' + 
        'FROM Account_Company__c WHERE Company_Code__c IN: companyCodes AND Account__c = null AND AccountRecordType__c IN: recordTypes AND ' +
        'EntityType__c INCLUDES (' + entityTypesString + ')';

        System.debug('query: ' + query);
        allRelatedAccountCompanies = Database.query(query);

        if(!allRelatedAccountCompanies.isEmpty()) {
            /* for(Account_Company__c accountCompany : allRelatedAccountCompanies) {
                accountCompanyMap.put(
                    String.valueOf(accountCompany.Company_Code__c) + '_' + String.valueOf(accountCompany.AccountRecordType__c) + '_' + 
                    String.valueOf(accountCompany.EntityType__c), 
                    accountCompany
                );
            } */
            for(Account_Company__c accountCompany : allRelatedAccountCompanies) {
                String key = String.valueOf(accountCompany.Company_Code__c) + '_' + String.valueOf(accountCompany.AccountRecordType__c);

                if(accountCompanyMap.get(key) == null) {
                    accountCompanyMap.put(key, new List<Account_Company__c>());
                }
                accountCompanyMap.get(key).add(accountCompany);
            }

            for(Account a : accounts) {
                Account_Company__c relatedAccountCompany;
                List<Account_Company__c> relatedAccountCompaniesTmp = accountCompanyMap.get(String.valueOf(a.AutoCreateCompanyData__c) + '_' + 
                String.valueOf(a.RecordType.DeveloperName));
                System.debug('relatedAccountCompaniesTmp: ' + relatedAccountCompaniesTmp);

                if(relatedAccountCompaniesTmp != null && !relatedAccountCompaniesTmp.isEmpty()) {
                    for(Account_Company__c ac : relatedAccountCompaniesTmp) {
                        if(String.valueOf(ac.EntityType__c).contains(a.Entity_type__c)) {
                            relatedAccountCompany = ac;
                            System.debug('relatedAccountCompany: ' + relatedAccountCompany);
                            break;
                        }
                    }
                    if(relatedAccountCompany != null) {
                        Account_Company__c accountCompanyClone = relatedAccountCompany.clone(false, true, false, false);
                        accountCompanyClone.Account__c = a.Id;
                        toInsert.add(accountCompanyClone);
                    }
                }
            }
        }

        if(!toInsert.isEmpty()) {
            List<Database.SaveResult> results = Database.insert(toInsert, false);
        }
    }

    public static void createSalesData(List<Account> accounts) {
        System.debug('----- createSalesData -----');
        List<String> salesOrgCodes = new List<String>();
        List<String> recordTypes = new List<String>();
        List<String> entityTypes = new List<String>();
        List<String> newEntityTypesList = new List<String>();
        List<String> allRelatedASOIds = new List<String>();
        List<Account_Sales_Organization__c> allRelatedASOs = new List<Account_Sales_Organization__c>();
        List<Account_Sales_Organization__c> ASOsToInsert = new List<Account_Sales_Organization__c>();
        List<Account_Tax_Classification__c> allRelatedATCs = new List<Account_Tax_Classification__c>();
        List<Account_Tax_Classification__c> ATCsToInsert = new List<Account_Tax_Classification__c>();

        Map<String, List<Account_Sales_Organization__c>> ASOMap = new Map<String, List<Account_Sales_Organization__c>>();
        Map<String, Account_Sales_Organization__c> ASOMapWithEntityType = new Map<String, Account_Sales_Organization__c>();
        Map<Account_Sales_Organization__c, Account_Sales_Organization__c> cloneToOriginalMap = new Map<Account_Sales_Organization__c, Account_Sales_Organization__c>();
        Map<String, List<Account_Tax_Classification__c>> ASOIdToATCsMap = new Map<String, List<Account_Tax_Classification__c>>();

        for(Account a : accounts) {
            salesOrgCodes.add(a.AutoCreateSalesData__c);
            recordTypes.add(a.RecordType.DeveloperName);
            entityTypes.add(a.Entity_type__c);
        }
        System.debug('entityTypes: ' + entityTypes);

        for(String s : entityTypes) {
            String newValue = '\'' + s + '\'';
            newEntityTypesList.add(newValue);
        }
        
        String entityTypesString = String.join(newEntityTypesList, ',');
        System.debug('entityTypes after transformation: ' + newEntityTypesList);
        System.debug('entityTypesString ' + entityTypesString);

        String query = 'SELECT Account_Assignment_Group__c, Account_Bill_To__c, Authorization_group__c, Billing_Method__c, Credit_Limit__c, Currency__c, ' + 
        'Customer_Group__c, Customer_Statistics_Group__c, Distribution_Channel__c, Division__c, Dunning_Via__c, Invoicing_Dates__c, Invoice_grouping_Y_N__c, ' +
        'Main_Health_Insurance__c, Payment_Terms__c, POD_Relevant__c, Price_Group__c, Price_Procedure_Dterm__c, Pricelist__c, ' +
        'Responsabile_Vivisol_Account_Manager__c, Sales_district__c, Sales_Group__c, Sales_Office__c, Sales_Organization__c, Shipping_Conditions__c, ' +
        'Sales_Organization__r.Code__c, OwnerId, AccountRecordType__c, EntityType__c ' +
        'FROM Account_Sales_Organization__c WHERE Sales_Organization__r.Code__c IN: salesOrgCodes AND Account__c = null ' +
        'AND AccountRecordType__c IN: recordTypes AND EntityType__c INCLUDES (' + entityTypesString + ')';

        System.debug('query: ' + query);
        allRelatedASOs = Database.query(query);

        if(!allRelatedASOs.isEmpty()) {
            for(Account_Sales_Organization__c aso : allRelatedASOs) {
                String key = String.valueOf(aso.Sales_Organization__r.Code__c) + '_' + String.valueOf(aso.AccountRecordType__c);
                allRelatedASOIds.add(aso.Id);

                ASOMapWithEntityType.put(
                    String.valueOf(aso.Sales_Organization__r.Code__c) + '_' + String.valueOf(aso.AccountRecordType__c) + '_' + String.valueOf(aso.EntityType__c), 
                    aso
                );

                if(ASOMap.get(key) == null) {
                    ASOMap.put(key, new List<Account_Sales_Organization__c>());
                }
                ASOMap.get(key).add(aso);
            }

            for(Account a : accounts) {
                Account_Sales_Organization__c relatedASO;
                List<Account_Sales_Organization__c> relatedASOsTmp = ASOMap.get(String.valueOf(a.AutoCreateSalesData__c) + '_' + String.valueOf(a.RecordType.DeveloperName));

                if(relatedASOsTmp != null && !relatedASOsTmp.isEmpty()) {
                    for(Account_Sales_Organization__c aso : relatedASOsTmp) {
                        if(String.valueOf(aso.EntityType__c).contains(a.Entity_type__c)) {
                            relatedASO = aso;
                            break;
                        }
                    }

                    if(relatedASO != null) {
                        Account_Sales_Organization__c ASOClone = relatedASO.clone(false, true, false, false);
                        ASOClone.Account__c = a.Id;
                        ASOsToInsert.add(ASOClone);
                        cloneToOriginalMap.put(ASOClone, relatedASO);
                    }
                }
            }
        }

        if(!ASOsToInsert.isEmpty()) {
            List<Database.SaveResult> ASOResults = Database.insert(ASOsToInsert, false);

            allRelatedATCs = [SELECT Tax_Category__c, Tax_Classification__c, Tax_Id__c, Account_Sales_Organization__c
                              FROM Account_Tax_Classification__c WHERE Account_Sales_Organization__c IN: allRelatedASOIds];

            if(!allRelatedATCs.isEmpty()) {
                for(Account_Tax_Classification__c atc : allRelatedATCs) {
                    if(ASOIdToATCsMap.get(atc.Account_Sales_Organization__c) == null) {
                        ASOIdToATCsMap.put(atc.Account_Sales_Organization__c, new List<Account_Tax_Classification__c>());
                    }
                    ASOIdToATCsMap.get(atc.Account_Sales_Organization__c).add(atc);
                }

                for(Account_Sales_Organization__c cloneASO : ASOsToInsert) {
                    String key = String.valueOf(cloneASO.Sales_Organization__r.Code__c) + '_' + String.valueOf(cloneASO.AccountRecordType__c) + '_' + 
                    String.valueOf(cloneASO.EntityType__c);
                    Account_Sales_Organization__c originalASO = ASOMapWithEntityType.get(key);

                    if(originalASO != null) {
                        List<Account_Tax_Classification__c> ATCsRelatedToOriginalASO = ASOIdToATCsMap.get(originalASO.Id);

                        if(ATCsRelatedToOriginalASO != null && !ATCsRelatedToOriginalASO.isEmpty()) {
                            for(Account_Tax_Classification__c atc : ATCsRelatedToOriginalASO) {
                                Account_Tax_Classification__c clonedATC = atc.clone(false, true, false, false);
                                clonedATC.Account_Sales_Organization__c = cloneASO.Id;
                                ATCsToInsert.add(clonedATC);
                            }
                        }
                    }
                }
            }

            if(!ATCsToInsert.isEmpty()) {
                List<Database.SaveResult> ATCResults = Database.insert(ATCsToInsert, false);
            }
        }
    }
}