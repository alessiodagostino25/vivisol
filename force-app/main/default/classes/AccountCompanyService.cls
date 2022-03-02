public class AccountCompanyService {
    @AuraEnabled
    @future(callout=true)
    public static void futureCreateCallout(List<Id> relatedIds) {
        List<String> queryFieldsForAccountCompany = new List<String>{'Company_Code__c', 'Dunning_Procedure__c', 'Name', 'External_ID__c', 'Key_for_sorting_according_to_assignment__c',
        'Payment_Method__c', 'Payment_Terms__c', 'Reconciliation_Account__c', 'isCreatedSAP__c', 'isSyncSAP__c',
        'Account__r.Account_External_Id__c', 'Account__c', 'Dunning_Block__c', 'Head_Office__c',
        'Head_Office__r.Account_External_Id__c', 'UzoviCode__c'};
        List<Account_Company__c> accountCompanies = AccountCompanyDAO.getAccountcompanyFromIds(queryFieldsForAccountCompany, relatedIds);
        makeCreateCallout(accountCompanies);
    }

    @AuraEnabled
    @future(callout=true)
    public static void futureUpdateCallout(List<Id> relatedIds) {
        List<String> queryFieldsForAccountCompany = new List<String>{'Company_Code__c', 'Dunning_Procedure__c', 'Name', 'External_ID__c', 'Key_for_sorting_according_to_assignment__c',
        'Payment_Method__c', 'Payment_Terms__c', 'Reconciliation_Account__c', 'isCreatedSAP__c', 'isSyncSAP__c',
        'Account__r.Account_External_Id__c', 'Account__c', 'Dunning_Block__c', 'Head_Office__c',
        'Head_Office__r.Account_External_Id__c', 'UzoviCode__c'};
        List<Account_Company__c> accountCompanies = AccountCompanyDAO.getAccountcompanyFromIds(queryFieldsForAccountCompany, relatedIds);
        makeUpdateCallout(accountCompanies);
    }

    public static Boolean hasChanged(Account_Company__c company, Account_Company__c oldCompany) {
        if(company.Company_Code__c != oldCompany.Company_Code__c) {
            return true;
        }
        if(company.Dunning_Procedure__c != oldCompany.Dunning_Procedure__c) {
            return true;
        }
        if(company.Name != oldCompany.Name) {
            return true;
        }
        if(company.Key_for_sorting_according_to_assignment__c != oldCompany.Key_for_sorting_according_to_assignment__c) {
            return true;
        }
        if(company.Payment_Method__c != oldCompany.Payment_Method__c) {
            return true;
        }
        if(company.Payment_Terms__c != oldCompany.Payment_Terms__c) {
            return true;
        }
        if(company.Reconciliation_Account__c != oldCompany.Reconciliation_Account__c) {
            return true;
        }
        if(company.Account__c != oldCompany.Account__c) {
            return true;
        }
        if(company.Dunning_Block__c != oldCompany.Dunning_Block__c) {
            return true;
        }
        if(company.Head_Office__c != oldCompany.Head_Office__c) {
            return true;
        }
        
        return false;
    }

    public static void makeCreateCallout(List<Account_Company__c> accountCompanies) {
        Map<String, Id> correlationIdMap = new Map<String, Id>();

        for(Account_Company__c company : accountCompanies) {
            correlationIdMap.put(company.External_ID__c, company.Id);
        }
        
        //Calling DTO constructor from AccountCompany Trigger: asoList is null
        List<Id> createdCompanyIds = new List<Id>();
        List<Account_Company__c> createdCompanies = new List<Account_Company__c>();
        AccountSalesOrganizationDTO dto = new AccountSalesOrganizationDTO(null, accountCompanies);
        //List<Status_Change_Event__e> changeEvents = new List<Status_Change_Event__e>();
        System.debug('DTO: ' + dto);
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:SAP_SO_CREATE');
        req.setMethod('POST');
        req.setTimeout(60000); //If Timeout = 10000, Exception: Read timed out
    
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
            }
            System.debug('DtoMap: ' + dtoMap);*/
            //List<SAPResponseDTO.ErrorList> errors = new List<SAPResponseDTO.ErrorList>();
            //CALLOUT_LOGGER CREATION FOR errorList ELEMENTS
            for(SAPResponseDTO.ResultList resList : responseDTO.resultList) {
                Boolean isCompleteSuccess = true;
                SAPResponseDTO.Log_event logEvent = resList.log_event;
                System.debug('CorrelationID: ' + resList.correlationID);
                for(SAPResponseDTO.ErrorList errorList : logEvent.errorList) {
                    isCompleteSuccess = false;

                    Callout_Logger__c calloutLogger = CalloutLoggerService.initializeUpdateCalloutLog(String.valueOf(res.getStatusCode()), errorList.errorType, false, 
                    'Account_Company__c', errorList.operation_Name, errorList.operationType, 'SFDC', 
                    resList.correlationID,
                    errorList.service,
                    Datetime.now(), errorList.uuid_Flow, errorList.error_Description, req.getBody(), 'SAP4HANA', 'FAIL');
                    System.debug('CALLOUT_LOGGER: ' + calloutLogger);
                    loggerList.add(calloutLogger);
                }
                for(SAPResponseDTO.WarningList warningList : logEvent.warningList) {
                    isCompleteSuccess = false;

                    Callout_Logger__c calloutLogger = CalloutLoggerService.initializeUpdateCalloutLog(String.valueOf(res.getStatusCode()), warningList.errorType, false, 
                    'Account_Company__c', warningList.operation_Name, warningList.operationType, 'SFDC', resList.correlationID, warningList.service, 
                    Datetime.now(), warningList.uuid_Flow, warningList.error_Description, req.getBody(), 'SAP4HANA', 'WARN');
                    System.debug('CALLOUT_LOGGER: ' + calloutLogger);
                    loggerList.add(calloutLogger);
                }
                
                if(resList.success == true) {
                    createdCompanyIds.add(correlationIdMap.get(resList.correlationID));

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
            
            insert loggerList;  //EDIT!! Must not insert here, must return the Loggers to Insert outside

            if(!deleteOlderLogsEvents.isEmpty()) {
                List<Database.SaveResult> results = EventBus.publish(deleteOlderLogsEvents);
            }

        } 
        catch (Exception e) {
            System.debug('EXCEPTION!!!! : ' + e.getMessage());
            System.debug('Exception: ' + e);
            System.debug('Exception line number: ' + e.getLineNumber());

            List<Callout_Logger__c> calloutLoggers = new List<Callout_Logger__c>();

            for(Account_Company__c accountCompany : accountCompanies) {
                Callout_Logger__c calloutLogger = CalloutLoggerService.initializeUpdateCalloutLog(
                    null, 
                    null, 
                    false, 
                    'Account_Company__c', 
                    'CREATE', 
                    'POST', 
                    'SFDC', 
                    accountCompany.External_ID__c, 
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

        /* for(Account_Company__c ac : accountCompanies) {
            Status_Change_Event__e changeEvent = new Status_Change_Event__e(
                RecordId__c = ac.Id
            );

            changeEvents.add(changeEvent);
        } */

        /* if(!changeEvents.isEmpty()) {
            List<Database.SaveResult> results = EventBus.publish(changeEvents);
            System.debug('EVENTS PUBLISHED size: ' + results.size());
        } */ 

        System.debug('CreatedCompanyIds: ' + createdCompanyIds);
        List<String> queryFieldsForAccountCompany = new List<String>{'Company_Code__c', 'Dunning_Procedure__c', 'Name', 'External_ID__c', 'Key_for_sorting_according_to_assignment__c',
        'Payment_Method__c', 'Payment_Terms__c', 'Reconciliation_Account__c', 'isCreatedSAP__c', 'isSyncSAP__c',
        'Account__r.Account_External_Id__c', 'Account__c', 'Dunning_Block__c', 'Head_Office__c',
        'Head_Office__r.Account_External_Id__c', 'UzoviCode__c'};

        createdCompanies = AccountCompanyDAO.getAccountcompanyFromIds(queryFieldsForAccountCompany, createdCompanyIds);
        for(Account_Company__c company : createdCompanies) {
            company.IsCreatedSAP__c = true;
            company.IsSyncSAP__c = 'Sync';
        }
        update accountCompanies;
        update createdCompanies;
    }

    public static void makeUpdateCallout(List<Account_Company__c> companies) {
        Map<String, Id> correlationIdMap = new Map<String, Id>();

        for(Account_Company__c company : companies) {
            correlationIdMap.put(company.External_ID__c, company.Id);
        }

        List<Id> updatedCompanyIds = new List<Id>();
        List<Account_Company__c> updatedCompanies = new List<Account_Company__c>();
        AccountSalesOrganizationDTO dto = new AccountSalesOrganizationDTO(null, companies);
        //List<Status_Change_Event__e> changeEvents = new List<Status_Change_Event__e>();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:SAP_SO_UPDATE');
        req.setMethod('POST');
        req.setTimeout(60000);
    
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');
    
        // create body request
        String reqJSON = JSON.serialize(dto);
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
                for(SAPResponseDTO.ErrorList errorList : logEvent.errorList) {
                    isCompleteSuccess = false;

                    Callout_Logger__c calloutLogger = CalloutLoggerService.initializeUpdateCalloutLog(String.valueOf(res.getStatusCode()), errorList.errorType, false, 
                    'Account_Company__c', errorList.operation_Name, errorList.operationType, 'SFDC', 
                    resList.correlationID,
                    errorList.service,
                    Datetime.now(), errorList.uuid_Flow, errorList.error_Description, req.getBody(), 'SAP4HANA', 'FAIL');
                    System.debug('CALLOUT_LOGGER: ' + calloutLogger);
                    loggerList.add(calloutLogger);
                }
                for(SAPResponseDTO.WarningList warningList : logEvent.warningList) {
                    isCompleteSuccess = false;

                    Callout_Logger__c calloutLogger = CalloutLoggerService.initializeUpdateCalloutLog(String.valueOf(res.getStatusCode()), warningList.errorType, false, 
                    'Account_Company__c', warningList.operation_Name, warningList.operationType, 'SFDC', resList.correlationID, warningList.service, 
                    Datetime.now(), warningList.uuid_Flow, warningList.error_Description, req.getBody(), 'SAP4HANA', 'WARN');
                    System.debug('CALLOUT_LOGGER: ' + calloutLogger);
                    loggerList.add(calloutLogger);
                }
                
                if(resList.success == true) {
                    updatedCompanyIds.add(correlationIdMap.get(resList.CorrelationID));

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

            for(Account_Company__c accountCompany : companies) {
                Callout_Logger__c calloutLogger = CalloutLoggerService.initializeUpdateCalloutLog(
                    null, 
                    null, 
                    false, 
                    'Account_Company__c', 
                    'UPDATE', 
                    'POST', 
                    'SFDC', 
                    accountCompany.External_ID__c, 
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

        /* for(Account_Company__c ac : companies) {
            Status_Change_Event__e changeEvent = new Status_Change_Event__e(
                RecordId__c = ac.Id
            );

            changeEvents.add(changeEvent);
        } */

        /* if(!changeEvents.isEmpty()) {
            List<Database.SaveResult> results = EventBus.publish(changeEvents);
            System.debug('EVENTS PUBLISHED size: ' + results.size());
        } */ 

        System.debug('UpdatedASOIds: ' + updatedCompanyIds);
        
        List<String> queryFieldsForAccountCompany = new List<String>{'Company_Code__c', 'Dunning_Procedure__c', 'Name', 'External_ID__c', 
        'Key_for_sorting_according_to_assignment__c', 'Payment_Method__c', 'Payment_Terms__c', 'Reconciliation_Account__c', 'isCreatedSAP__c', 'isSyncSAP__c',
        'Account__r.Account_External_Id__c', 'Account__c', 'Dunning_Block__c', 'Head_Office__c',
        'Head_Office__r.Account_External_Id__c', 'UzoviCode__c'};
        
        updatedCompanies = AccountCompanyDAO.getAccountcompanyFromIds(queryFieldsForAccountCompany, updatedCompanyIds);
        for(Account_Company__c ac : updatedCompanies) {
            if(ac.IsSyncSAP__c == 'NotSync') {
                System.debug('IsSyncSAP__c era NOTSYNC --> CORRETTO!');
                ac.IsSyncSAP__c = 'Sync';
            }
            else if(ac.IsSyncSAP__c == 'Sync') {
                System.debug('IsSyncSAP__c era già SYNC --> ERRORE, avrebbe dovuto essere stato settato a NotSync prima di entrare nella chiamata per l update!');
            }
        }
        update updatedCompanies;
    }
}