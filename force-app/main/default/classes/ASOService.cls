public class ASOService {
    @AuraEnabled
    @future(callout=true)
    public static void futureCreateCallout(List<Id> relatedIds) {
        List<Account_Sales_Organization__c> asoListForCallout = new List<Account_Sales_Organization__c>();
        //List<Status_Change_Event__e> changeEvents = new List<Status_Change_Event__e>();

        Map<String, Account_Sales_Organization__c> asoMap = new Map<String, Account_Sales_Organization__c>();
        Map<String, List<Account_Partner_Function__c>> asoToApfMap = new Map<String, List<Account_Partner_Function__c>>();

        List<Account_Sales_Organization__c> asoList = AccountSalesOrganizationDAO.getASOs(relatedIds);

        for(Account_Sales_Organization__c aso : asoList) {
            asoMap.put(aso.Id, aso);
        }

        List<Account_Partner_Function__c> allRelatedAPFs = [SELECT Id, Account_Sales_Organization__c FROM Account_Partner_Function__c 
                                                            WHERE Account_Sales_Organization__c IN: relatedIds];

        if(allRelatedAPFs != null) {
            for(Account_Partner_Function__c apf : allRelatedAPFs) {
                if(asoToApfMap.get(apf.Account_Sales_Organization__c) == null) {
                    asoToApfMap.put(apf.Account_Sales_Organization__c, new List<Account_Partner_Function__c>());
                }
                asoToApfMap.get(apf.Account_Sales_Organization__c).add(apf);
            }

            for(Account_Sales_Organization__c aso : asoList) {
                List<Account_Partner_Function__c> relatedAPFs = asoToApfMap.get(aso.Id);

                if(relatedAPFs != null && !relatedAPFs.isEmpty()) {
                    asoListForCallout.add(aso);
                }
                /* else {
                    Status_Change_Event__e changeEvent = new Status_Change_Event__e(
                        RecordId__c = aso.Id
                    );
        
                    changeEvents.add(changeEvent);
                } */
            }
        }

        System.debug('allRelatedAPFs: ' + allRelatedAPFs);
        System.debug('asoListForCallout: ' + asoListForCallout);

        /* if(!changeEvents.isEmpty()) {
            List<Database.SaveResult> results = EventBus.publish(changeEvents);
            System.debug('EVENTS PUBLISHED size: ' + results.size());
        } */

        if(!asoListForCallout.isEmpty()) {
            makeCreateCallout(asoListForCallout);
        }
    }

    @AuraEnabled
    @future(callout=true)
    public static void futureUpdateCallout(List<Id> relatedIds) {
        List<Account_Sales_Organization__c> asoList = AccountSalesOrganizationDAO.getASOs(relatedIds);
        makeUpdateCallout(asoList);
    }

    public static void updateRelatedAccounts(List<Account> relatedAccounts, Map<Id, Account_Sales_Organization__c> asoMap) {
        for(Account a : relatedAccounts) {
            if(a.Account_Sales_Organizations__c == null) {
                System.debug('account sales org: ' + asoMap.get(a.Id));
                a.Account_Sales_Organizations__c = (asoMap.get(a.Id)).Sales_Organization__r.Code__c; //+ asoMap.get(a.Id).Code__c + ';';
                System.debug('asoMap SalesOrgR.Code__c: ' + (asoMap.get(a.Id)).Sales_Organization__r.Code__c);
            }
            else {
                a.Account_Sales_Organizations__c = a.Account_Sales_Organizations__c + '; ' +  (asoMap.get(a.Id)).Sales_Organization__r.Code__c; //+ asoMap.get(a.Id).Code__c + ';';
            }
        }
        update relatedAccounts;
    }

    public static void updateASOName(List<Id> newASOIds) {
        //Need to query again because I need related fields of the Account
        List<Account_Sales_Organization__c> newASOs = AccountSalesOrganizationDAO.getASOs(newASOIds);

        for(Account_Sales_Organization__c aso : newASOs) {
            if(aso.Account__r.IsPersonAccount == false) {
                aso.Name = aso.Account__r.Name + ' - ' + aso.Sales_Organization__r.Name;
            }
            else if(aso.Account__r.IsPersonAccount == true) {
                //Variables for Person Account name
                String firstName;
                String middleName;
                String lastName;

                if(aso.Account__r.FirstName != null) {
                    firstName = aso.Account__r.FirstName;
                }
                else {
                    firstName = '';
                }
                if(aso.Account__r.MiddleName != null) {
                    middleName = aso.Account__r.MiddleName;
                }
                else {
                    middleName = '';
                }
                lastName = aso.Account__r.LastName;  //mandatory field

                aso.Name = firstName + ' ' + middleName + ' ' + lastName + ' - ' + aso.Sales_Organization__r.Name;
            }
        }

        update newASOs;
    }

    //Method to check if an ASO really needs to trigger the update Trigger, or only isSyncSAP has changed
    public static Boolean hasChanged(Account_Sales_Organization__c aso, Account_Sales_Organization__c oldASO) {
        if(aso.Name != oldASO.Name) {
            return true;
        }
        if(aso.Account_Assignment_Group__c != oldASO.Account_Assignment_Group__c) {
            return true;
        }
        if(aso.Authorization_group__c != oldASO.Authorization_group__c) {
            return true;
        }
        if(aso.Code__c != oldASO.Code__c) {
            return true;
        }
        if(aso.Credit_Limit__c != oldASO.Credit_Limit__c) {
            return true;
        }
        if(aso.Currency__c != oldASO.Currency__c) {
            return true;
        }
        if(aso.Customer_Group__c != oldASO.Customer_Group__c) {
            return true;
        }
        if(aso.Customer_Statistics_Group__c != oldASO.Customer_Statistics_Group__c) {
            return true;
        }
        if(aso.Distribution_Channel__c != oldASO.Distribution_Channel__c) {
            return true;
        }
        if(aso.Division__c != oldASO.Division__c) {
            return true;
        }
        if(aso.Invoice_grouping_Y_N__c != oldASO.Invoice_grouping_Y_N__c) {
            return true;
        }
        if(aso.Invoicing_Dates__c != oldASO.Invoicing_Dates__c) {
            return true;
        }
        if(aso.Payment_Terms__c != oldASO.Payment_Terms__c) {
            return true;
        }
        if(aso.POD_Relevant__c != oldASO.POD_Relevant__c) {
            return true;
        }
        if(aso.Price_Group__c != oldASO.Price_Group__c) {
            return true;
        }
        if(aso.Price_Procedure_Dterm__c != oldASO.Price_Procedure_Dterm__c) {
            return true;
        }
        if(aso.Pricelist__c != oldASO.Pricelist__c) {
            return true;
        }
        if(aso.Responsabile_Vivisol_Account_Manager__c != oldASO.Responsabile_Vivisol_Account_Manager__c) {
            return true;
        }
        if(aso.Sales_district__c != oldASO.Sales_district__c) {
            return true;
        }
        if(aso.Sales_Group__c != oldASO.Sales_Group__c) {
            return true;
        }
        if(aso.Sales_Office__c != oldASO.Sales_Office__c) {
            return true;
        }
        if(aso.Sales_Organization__c != oldASO.Sales_Organization__c) {
            return true;
        }
        if(aso.Sales_Organization__r.Code__c != oldASO.Sales_Organization__r.Code__c) {
            return true;
        }
        if(aso.Shipping_Conditions__c != oldASO.Shipping_Conditions__c) {
            return true;
        }
        if(aso.Billing_Method__c != oldASO.Billing_Method__c) {
            return true;
        }
        if(aso.Dunning_Via__c != oldASO.Dunning_Via__c) {
            return true;
        }
        
        return false;
    }

    public static void makeCreateCallout(List<Account_Sales_Organization__c> asoList) {
        Map<String, Id> correlationIdMap = new Map<String, Id>();

        for(Account_Sales_Organization__c aso : asoList) {
            correlationIdMap.put(aso.External_Id__c, aso.Id);
        }

        System.debug('IN makeCREATEcallout');
        List<Id> createdASOIds = new List<Id>();
        List<Account_Sales_Organization__c> createdASOs = new List<Account_Sales_Organization__c>();  //List of ASOs with "true" on isCreated; these will be updated
        //Calling DTO constructor from ASO Trigger: Account Company List is null
        AccountSalesOrganizationDTO dto = new AccountSalesOrganizationDTO(asoList, null);
        //List<Status_Change_Event__e> changeEvents = new List<Status_Change_Event__e>();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:SAP_SO_CREATE');
        req.setMethod('POST');
        req.setTimeout(60000);
    
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');
    
        // create body request
        String reqJSON = JSON.serialize(dto);
        String correctJSON = reqJSON.replace('"replacedCurrency":', '"currency":');
        System.debug(correctJSON);
        req.setBody(correctJSON);
    
        Http http = new Http();
        HTTPResponse res = new HttpResponse();
    
        // initialize timers
        Long startTime = Datetime.now().getTime();
        Long finishTime;
        Long totalTime;

        try {
            res = http.send(req);
            System.debug('RESPONSE: ' + res);
            System.debug('RESPONSE BODY: ' + res.getBody());
            finishTime = Datetime.now().getTime();
            totalTime = (finishTime - startTime);
            String responseUnparsed = res.getBody();
            SAPResponseDTO responseDTO = (SAPResponseDTO) System.JSON.deserialize(responseUnparsed, SAPResponseDTO.class);
            Map<Id, AccountSalesOrganizationDTO.AccountSO> dtoMap = new Map<Id, AccountSalesOrganizationDTO.AccountSO>();
            Map<Id, AccountSalesOrganizationDTO.SalesOrganization> salesOrgMap = new Map<Id, AccountSalesOrganizationDTO.SalesOrganization>();
            List<Callout_Logger__c> loggerList = new List<Callout_Logger__c>();
            List<Delete_Older_Logs__e> deleteOlderLogsEvents = new List<Delete_Older_Logs__e>();
            //Map each SalesOrganization's CorrelationID with its aSO to get it from the resLists
            /*for(AccountSalesOrganizationDTO.SalesOrganization so : dto.salesOrganizationList) {
                dtoMap.put(so.correlationID, so.accountSO); //This is unuseful, could use the one below with .AccountSO --> TODO: EDIT AND REMOVE
                salesOrgMap.put(so.correlationID, so);
            }*/
            //System.debug('DtoMap: ' + dtoMap);
            //List<SAPResponseDTO.ErrorList> errors = new List<SAPResponseDTO.ErrorList>();
            //CALLOUT_LOGGER CREATION FOR errorList ELEMENTS
            for(SAPResponseDTO.ResultList resList : responseDTO.resultList) {
                Boolean isCompleteSuccess = true;
                SAPResponseDTO.Log_event logEvent = resList.log_event;
                System.debug('CorrelationID: ' + resList.correlationID);
                System.debug('RecordId from Map: ' + correlationIdMap.get(resList.correlationID));
                if(logEvent.errorList != null) {
                    for(SAPResponseDTO.ErrorList errorList : logEvent.errorList) {
                        isCompleteSuccess = false;

                        Callout_Logger__c calloutLogger = CalloutLoggerService.initializeUpdateCalloutLog(String.valueOf(res.getStatusCode()), errorList.errorType, false, 
                        'Account_Sales_Organization__c', errorList.operation_Name, errorList.operationType, 'SFDC', 
                        /*recordId,*/resList.correlationID,
                        'SFDC_SAP4HANA__SO_CREATE',
                        Datetime.now(), errorList.uuid_Flow, errorList.error_Description, req.getBody(), 'SAP4HANA', 'FAIL');
                        System.debug('CALLOUT_LOGGER: ' + calloutLogger);
                        loggerList.add(calloutLogger);
                    }
                }
                if(logEvent.warningList != null) {
                    for(SAPResponseDTO.WarningList warningList : logEvent.warningList) {
                        isCompleteSuccess = false;

                        Callout_Logger__c calloutLogger = CalloutLoggerService.initializeUpdateCalloutLog(String.valueOf(res.getStatusCode()), warningList.errorType, false, 
                        'Account_Sales_Organization__c', warningList.operation_Name, warningList.operationType, 'SFDC', /*recordId2*/resList.correlationID,
                        'SFDC_SAP4HANA__SO_CREATE', 
                        Datetime.now(), warningList.uuid_Flow, warningList.error_Description, req.getBody(), 'SAP4HANA', 'WARN');
                        System.debug('CALLOUT_LOGGER: ' + calloutLogger);
                        loggerList.add(calloutLogger);
                    }
                }
                
                if(resList.success == true) {
                    createdASOIds.add(correlationIdMap.get(resList.correlationID));

                    // Deleting all Callout Loggers for this recordId if the call is a complete success (no error nor warning logs)

                    if(isCompleteSuccess) {
                        deleteOlderLogsEvents.add(
                            new Delete_Older_Logs__e(
                                Record_Id__c = resList.correlationID
                            )
                        );
                    }
                }
            }

            insert loggerList;

            if(!deleteOlderLogsEvents.isEmpty()) {
                List<Database.SaveResult> results = EventBus.publish(deleteOlderLogsEvents);
            }
        } 
        catch (Exception e) {
            System.debug('EXCEPTION!!!! : ' + e.getMessage());
            System.debug('Exception: ' + e);
            System.debug('Exception line number: ' + e.getLineNumber());

            List<Callout_Logger__c> calloutLoggers = new List<Callout_Logger__c>();

            for(Account_Sales_Organization__c aso : asoList) {
                Callout_Logger__c calloutLogger = CalloutLoggerService.initializeUpdateCalloutLog(
                    null, 
                    null, 
                    false, 
                    'Account_Sales_Organization__c', 
                    'CREATE', 
                    'POST', 
                    'SFDC', 
                    aso.External_Id__c, 
                    'SFDC_SAP4HANA__SO_CREATE', 
                    Datetime.now(), 
                    null, 
                    e.getMessage(), 
                    req.getBody(), 
                    'SAP4HANA', 
                    'FAIL'
                );

                calloutLoggers.add(calloutLogger);
            }

            insert calloutLoggers;
        }

        /* for(Account_Sales_Organization__c aso : asoList) {
            Status_Change_Event__e changeEvent = new Status_Change_Event__e(
                RecordId__c = aso.Id
            );

            changeEvents.add(changeEvent);
        } */

        /* if(!changeEvents.isEmpty()) {
            List<Database.SaveResult> results = EventBus.publish(changeEvents);
            System.debug('EVENTS PUBLISHED size: ' + results.size());
        } */

        System.debug('CreatedASOIds: ' + createdASOIds);
        createdASOs = AccountSalesOrganizationDAO.getASOs(createdASOIds);
        for(Account_Sales_Organization__c aso : createdASOs) {
            aso.IsCreatedSAP__c = true;
            aso.IsSyncSAP__c = 'Sync';
        }
        update asoList;
        update createdASOs;
    }

    public static void makeUpdateCallout(List<Account_Sales_Organization__c> asoList) {
        Map<String, Id> correlationIdMap = new Map<String, Id>();

        for(Account_Sales_Organization__c aso : asoList) {
            correlationIdMap.put(aso.External_Id__c, aso.Id);
        }

        System.debug('IN makeUPDATEcallout');
        List<Id> updatedASOIds = new List<Id>();
        List<Account_Sales_Organization__c> updatedASOs = new List<Account_Sales_Organization__c>();
        AccountSalesOrganizationDTO dto = new AccountSalesOrganizationDTO(asoList, null);
        //List<Status_Change_Event__e> changeEvents = new List<Status_Change_Event__e>();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:SAP_SO_UPDATE');
        req.setMethod('POST');
        req.setTimeout(60000);
    
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');
    
        // create body request
        String reqJSON = JSON.serialize(dto);
        String correctJSON = reqJSON.replace('"replacedCurrency":', '"currency":');
        System.debug(correctJSON);
        req.setBody(correctJSON);
    
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
            SAPResponseDTO responseDTO = (SAPResponseDTO) System.JSON.deserialize(responseUnparsed, SAPResponseDTO.class);
            Map<Id, AccountSalesOrganizationDTO.AccountSO> dtoMap = new Map<Id, AccountSalesOrganizationDTO.AccountSO>();
            Map<Id, AccountSalesOrganizationDTO.SalesOrganization> salesOrgMap = new Map<Id, AccountSalesOrganizationDTO.SalesOrganization>();
            List<Callout_Logger__c> loggerList = new List<Callout_Logger__c>();
            List<Delete_Older_Logs__e> deleteOlderLogsEvents = new List<Delete_Older_Logs__e>();
            //Map each SalesOrganization's CorrelationID with its aSO to get it from the resLists
            /*for(AccountSalesOrganizationDTO.SalesOrganization so : dto.salesOrganizationList) {
                dtoMap.put(so.correlationID, so.accountSO); //This is unuseful, could use the one below with .AccountSO --> TODO: EDIT AND REMOVE
                salesOrgMap.put(so.correlationID, so);
            }
            System.debug('DtoMap: ' + dtoMap);*/
            //List<SAPResponseDTO.ErrorList> errors = new List<SAPResponseDTO.ErrorList>();
            //CALLOUT_LOGGER CREATION FOR errorList ELEMENTS
            for(SAPResponseDTO.ResultList resList : responseDTO.resultList) {
                Boolean isCompleteSuccess = true;
                SAPResponseDTO.Log_event logEvent = resList.log_event;
                System.debug('CorrelationID: ' + resList.correlationID);
                if(logEvent.errorList != null) {
                    for(SAPResponseDTO.ErrorList errorList : logEvent.errorList) {
                        isCompleteSuccess = false;

                        Callout_Logger__c calloutLogger = CalloutLoggerService.initializeUpdateCalloutLog(String.valueOf(res.getStatusCode()), errorList.errorType, false, 
                        'Account_Sales_Organization__c', errorList.operation_Name, errorList.operationType, 'SFDC', 
                        /*recordId*/resList.correlationID,
                        'SFDC_SAP4HANA__SO_UPDATE',
                        Datetime.now(), errorList.uuid_Flow, errorList.error_Description, req.getBody(), 'SAP4HANA', 'FAIL');
                        System.debug('CALLOUT_LOGGER: ' + calloutLogger);
                        loggerList.add(calloutLogger);
                    }
                }
                if(logEvent.warningList != null) {
                    for(SAPResponseDTO.WarningList warningList : logEvent.warningList) {
                        isCompleteSuccess = false;

                        Callout_Logger__c calloutLogger = CalloutLoggerService.initializeUpdateCalloutLog(String.valueOf(res.getStatusCode()), warningList.errorType, false, 
                        'Account_Sales_Organization__c', warningList.operation_Name, warningList.operationType, 'SFDC', /*recordId2*/resList.correlationID, 
                        'SFDC_SAP4HANA__SO_UPDATE', 
                        Datetime.now(), warningList.uuid_Flow, warningList.error_Description, req.getBody(), 'SAP4HANA', 'WARN');
                        System.debug('CALLOUT_LOGGER: ' + calloutLogger);
                        loggerList.add(calloutLogger);
                    }
                }
                
                if(resList.success == true) {
                    updatedASOIds.add(correlationIdMap.get(resList.correlationID));

                    // Deleting all Callout Loggers for this recordId if the call is a complete success (no error nor warning logs)

                    if(isCompleteSuccess) {
                        deleteOlderLogsEvents.add(
                            new Delete_Older_Logs__e(
                                Record_Id__c = resList.correlationID
                            )
                        );
                    }
                }
            }

            insert loggerList;
            
            if(!deleteOlderLogsEvents.isEmpty()) {
                List<Database.SaveResult> results = EventBus.publish(deleteOlderLogsEvents);
            }
        } 
        catch (Exception e) {
            System.debug('EXCEPTION!!!! : ' + e.getMessage());
            System.debug('Exception: ' + e);
            System.debug('Exception line number: ' + e.getLineNumber());

            List<Callout_Logger__c> calloutLoggers = new List<Callout_Logger__c>();

            for(Account_Sales_Organization__c aso : asoList) {
                Callout_Logger__c calloutLogger = CalloutLoggerService.initializeUpdateCalloutLog(
                    null, 
                    null, 
                    false, 
                    'Account_Sales_Organization__c', 
                    'UPDATE', 
                    'POST', 
                    'SFDC', 
                    aso.External_Id__c, 
                    'SFDC_SAP4HANA__SO_UPDATE', 
                    Datetime.now(), 
                    null, 
                    e.getMessage(), 
                    req.getBody(), 
                    'SAP4HANA', 
                    'FAIL'
                );

                calloutLoggers.add(calloutLogger);
            }

            insert calloutLoggers;
        }

        /* for(Account_Sales_Organization__c aso : asoList) {
            Status_Change_Event__e changeEvent = new Status_Change_Event__e(
                RecordId__c = aso.Id
            );

            changeEvents.add(changeEvent);
        } */

        /* if(!changeEvents.isEmpty()) {
            List<Database.SaveResult> results = EventBus.publish(changeEvents);
            System.debug('EVENTS PUBLISHED size: ' + results.size());
        } */

        System.debug('UpdatedASOIds: ' + updatedASOIds);
        updatedASOs = AccountSalesOrganizationDAO.getASOs(updatedASOIds);
        for(Account_Sales_Organization__c aso : updatedASOs) {
            if(aso.IsSyncSAP__c == 'NotSync') {
                System.debug('IsSyncSAP__c era NOTSYNC --> CORRETTO!');
                aso.IsSyncSAP__c = 'Sync';
            }
            else if(aso.IsSyncSAP__c == 'Sync') {
                System.debug('IsSyncSAP__c era già SYNC --> ERRORE, avrebbe dovuto essere stato settato a NotSync prima di entrare nella chiamata per l update!');
            }
        }
        update updatedASOs;
    }

    /**
     * NOT USED ANYMORE
     */

    public static List<Schema.Location> updateRelatedLocations(List<String> ASOIds) {
        List<String> locationQueryFields = new List<String>{'Sales_Org_Code__c', 'Account__c'};
        List<String> ASOQueryFields = new List<String>{'Account__c', 'Account__r.Account_Sales_Organizations__c'};

        List<Account_Sales_Organization__c> ASOs = new List<Account_Sales_Organization__c>();
        List<String> relatedAccountIds = new List<String>();
        List<Schema.Location> allRelatedLocations = new List<Schema.Location>();
        List<Schema.Location> toUpdate = new List<Schema.Location>();

        Map<String, List<Schema.Location>> locationMap = new Map<String, List<Schema.Location>>();

        ASOs = AccountSalesOrganizationDAO.getASOsFromIds(ASOQueryFields, ASOIds);

        if(!ASOs.isEmpty()) {
            for(Account_Sales_Organization__c aso : ASOs) {
                relatedAccountIds.add(aso.Account__c);
            }

            if(!relatedAccountIds.isEmpty()) {
                allRelatedLocations = LocationDAO.getLocationsFromAccountIds(locationQueryFields, relatedAccountIds);

                if(!allRelatedLocations.isEmpty()) {
                    for(Schema.Location location : allRelatedLocations) {
                        if(locationMap.get(location.Account__c) == null) {
                            locationMap.put(location.Account__c, new List<Schema.Location>());
                        }
                        locationMap.get(location.Account__c).add(location);
                    }

                    for(Account_Sales_Organization__c aso : ASOs) {
                        List<Schema.Location> relatedLocations = locationMap.get(aso.Account__c);

                        if(relatedLocations != null) {
                            for(Schema.Location location : relatedLocations) {
                                location.Sales_Org_Code__c = aso.Account__r.Account_Sales_Organizations__c;

                                toUpdate.add(location);
                            }
                        }
                    }
                }
            }
        }

        return toUpdate;
    }

    public static void updateAccountIsPortalSync(List<Account_Sales_Organization__c> ASOs) {
        List<String> accountQueryFields = new List<String>{'Is_Portal_Sync__c'};

        List<Account> accounts = new List<Account>();
        List<String> accountIds = new List<String>();

        for(Account_Sales_Organization__c aso : ASOs) {
            accountIds.add(aso.Account__c);
        }

        accounts = AccountDAO.getAccountIsSapSyncFromRecordIds(accountQueryFields, accountIds);

        if(!accounts.isEmpty()) {
            SObjectServiceClass.updateGenericField('Account', '03', 'Is_Portal_Sync__c', accounts);
        }
    }
}