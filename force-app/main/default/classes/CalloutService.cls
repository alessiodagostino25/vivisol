public class CalloutService {
    /**
     * @description Performs a callout for a list of records
     * @param records The list of records to perform the callout for
     * @param endpoint The endpoint (or Named Credendial name) to send the callout to
     * @param httpMethod The http method of the callout (POST, GET...)
     * @param method The method of the callout (CREATE or UPDATE)
     * @return An object containing the callout response and, eventually, the callout logger related to the raised exception
     */
    public static ReturnDTO makeCallout(List<SObject> records, String endpoint, String httpMethod, String method, String service) {
        System.debug('----- CalloutService.makeCallout -----');

        ReturnDTO returnDTO;
        Object dtoClass;
        Schema.SObjectField recordIdCalloutLogger;
        List<Callout_Logger__c> exceptionCalloutLoggers = new List<Callout_Logger__c>();

        // Getting sObject info

        Id firstRecordId = records[0].Id;
        Schema.SObjectType objectType = firstRecordId.getSObjectType();
        String objectName = objectType.getDescribe().getName();

        // Getting the correct request DTO

        switch on objectName {
            when 'Account_Sales_Organization__c' {
                recordIdCalloutLogger = Account_Sales_Organization__c.External_Id__c;
                dtoClass = new AccountSalesOrganizationDTO(records, null);
            }
            when 'Account_Company__c' {
                recordIdCalloutLogger = Account_Company__c.External_ID__c;
                dtoClass = new AccountSalesOrganizationDTO(null, records);
            }
            when else {
                // TODO
            }
        }

        // Setting up the request

        HttpRequest req = new HttpRequest();

        req.setEndpoint(endpoint);
        req.setMethod(httpMethod);
        req.setTimeout(60000);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');

        // TO ADAPT TO OTHER OBJECTS two lines below
    
        String reqJSON = JSON.serialize(dtoClass);
        String correctJSON = reqJSON.replace('"replacedCurrency":', '"currency":');

        System.debug(correctJSON);
        req.setBody(correctJSON);
    
        Http http = new Http();
        HTTPResponse res = new HttpResponse();
    
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

            returnDTO = new ReturnDTO(responseDTO, null, req, res);
        }
        catch(Exception e) {
            System.debug('EXCEPTION!!!! : ' + e.getMessage());
            System.debug('Exception: ' + e);
            System.debug('Exception line number: ' + e.getLineNumber());

            for(SObject record : records) {
                Callout_Logger__c calloutLogger = CalloutLoggerService.initializeUpdateCalloutLog(
                    null, 
                    null, 
                    false, 
                    objectName, 
                    method, 
                    httpMethod, 
                    'SFDC', 
                    (String)record.get(recordIdCalloutLogger), 
                    service, 
                    Datetime.now(), 
                    null, 
                    e.getMessage(), 
                    req.getBody(), 
                    'SAP4HANA', 
                    'FAIL'
                );

                exceptionCalloutLoggers.add(calloutLogger);
            }

            return new ReturnDTO(null, exceptionCalloutLoggers, req, res);
        }

        return returnDTO;
    }

    public static List<Callout_Logger__c> createCalloutLoggers(SAPResponseDTO responseDTO, HttpRequest req, HTTPResponse res, String objectName, String service) {
        System.debug('----- CalloutService.createCalloutLoggers -----');

        List<Callout_Logger__c> toReturn = new List<Callout_Logger__c>();
        List<Delete_Older_Logs__e> deleteOlderLogsEvents = new List<Delete_Older_Logs__e>();
        String requestBody;

        if(req.getBody().length() < 131072) {
            requestBody = req.getBody();
        }

        if(responseDTO.resultList != null) {
            for(SAPResponseDTO.ResultList resList : responseDTO.resultList) {
                Boolean isCompleteSuccess = true;
                SAPResponseDTO.Log_event logEvent = resList.log_event;
                System.debug('CorrelationID: ' + resList.correlationID);

                if(logEvent != null) {
                    if(logEvent.errorList != null) {
                        for(SAPResponseDTO.ErrorList errorList : logEvent.errorList) {
                            isCompleteSuccess = false;

                            Callout_Logger__c calloutLogger = CalloutLoggerService.initializeUpdateCalloutLog(
                                String.valueOf(res.getStatusCode()), 
                                errorList.errorType, 
                                false, 
                                objectName, 
                                errorList.operation_Name, 
                                errorList.operationType, 
                                'SFDC', 
                                resList.correlationID,
                                service,
                                Datetime.now(), 
                                errorList.uuid_Flow, 
                                errorList.error_Description, 
                                requestBody, 
                                'SAP4HANA', 
                                'FAIL'
                            );

                            System.debug('CALLOUT_LOGGER: ' + calloutLogger);
                            toReturn.add(calloutLogger);
                        }
                    }
                    if(logEvent.warningList != null) {
                        for(SAPResponseDTO.WarningList warningList : logEvent.warningList) {
                            isCompleteSuccess = false;

                            Callout_Logger__c calloutLogger = CalloutLoggerService.initializeUpdateCalloutLog(
                                String.valueOf(res.getStatusCode()), 
                                warningList.errorType, 
                                false, 
                                objectName, 
                                warningList.operation_Name, 
                                warningList.operationType, 
                                'SFDC', 
                                resList.correlationID,
                                service, 
                                Datetime.now(), 
                                warningList.uuid_Flow, 
                                warningList.error_Description, 
                                requestBody, 
                                'SAP4HANA', 
                                'WARN'
                            );

                            System.debug('CALLOUT_LOGGER: ' + calloutLogger);
                            toReturn.add(calloutLogger);
                        }
                    }
                }

                // Deleting all Callout Loggers for this recordId if the call is a complete success (no error nor warning logs)

                if(isCompleteSuccess) {
                    deleteOlderLogsEvents.add(
                        new Delete_Older_Logs__e(
                            Record_Id__c = resList.correlationID,
                            Service__c = service
                        )
                    );
                }
            }
        }

        if(!deleteOlderLogsEvents.isEmpty()) {
            List<Database.SaveResult> results = EventBus.publish(deleteOlderLogsEvents);
        }

        return toReturn;
    }

    public static List<SObject> handleRecordsFields(List<SObject> records, SAPResponseDTO responseDTO, String method) {
        System.debug('----- CalloutService.handleRecordsFields -----');

        List<SObject> toUpdate = new List<SObject>();
        List<String> toUpdateIds = new List<String>();

        Map<String, SObject> correlationIdMap = new Map<String, SObject>();

        Id firstRecordId = records[0].Id;
        Schema.SObjectType objectType = firstRecordId.getSObjectType();
        String objectName = objectType.getDescribe().getName();

        for(SObject record : records) {
            switch on objectName {
                when 'Account_Sales_Organization__c' {
                    correlationIdMap.put((String)record.get('External_Id__c'), record);
                }
                when 'Account_Company__c' {
                    correlationIdMap.put((String)record.get('External_ID__c'), record);
                }
                when else {
                    // TODO
                }
            }
        }

        if(responseDTO != null) {
            for(SAPResponseDTO.ResultList resList : responseDTO.resultList) {
                if(resList.success == true) {
                    if(correlationIdMap.get(resList.correlationID) != null) {
                        toUpdate.add(correlationIdMap.get(resList.correlationID));
                    }
                }
            }

            if(!toUpdate.isEmpty()) {
                if(method == 'CREATE') {
                    for(SObject record : toUpdate) {
                        record.put('IsCreatedSAP__c', true);
                        record.put('IsSyncSAP__c', 'Sync');
                    }
                }
                else if(method == 'UPDATE') {
                    for(SObject record : toUpdate) {
                        if((String)record.get('IsSyncSAP__c') != 'Sync') {
                            record.put('IsSyncSAP__c', 'Sync');
                        }
                    }
                }
            }
        }

        return toUpdate;
    }

    public class ReturnDTO {
        public SAPResponseDTO responseDTO;
        public List<Callout_Logger__c> calloutLoggers;
        public HttpRequest request;
        public HttpResponse response;

        public ReturnDTO(SAPResponseDTO responseDTO, List<Callout_Logger__c> calloutLoggers, HttpRequest request, HttpResponse response) {
            this.responseDTO = responseDTO;
            this.calloutLoggers = calloutLoggers;
            this.request = request;
            this.response = response;
        }
    }
}