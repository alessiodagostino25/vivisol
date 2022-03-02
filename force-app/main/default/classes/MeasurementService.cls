public class MeasurementService {

    public static ReturnDTO makeCallout(Measurement__c measurement) {
        //List<Status_Change_Event__e> changeEvents = new List<Status_Change_Event__e>();
        List<Id> createdMeasurementIds = new List<Id>();
        List<Callout_Logger__c> loggerList = new List<Callout_Logger__c>();
        List<Delete_Older_Logs__e> deleteOlderLogsEvents = new List<Delete_Older_Logs__e>();
        MeasurementRequestDTO dto = new MeasurementRequestDTO(measurement);
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:SAP_MEASUREMENT_CREATE');
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

            SAPResponseDTO responseDTO = (SAPResponseDTO) System.JSON.deserialize(response2, SAPResponseDTO.class);
            for(SAPResponseDTO.ResultList resList : responseDTO.resultList) {
                SAPResponseDTO.Log_event logEvent = resList.log_event;
                if(logEvent.errorList != null) {
                    for(SAPResponseDTO.ErrorList errorList : logEvent.errorList) {
                        Callout_Logger__c calloutLogger = CalloutLoggerService.initializeUpdateCalloutLog(String.valueOf(res.getStatusCode()) /*always 200, do i need
                        the single resList's one?*/, errorList.errorType, false, 
                        'Measurement__c', errorList.operation_Name, errorList.operationType, 'SFDC', 
                        resList.correlationID, // External ID?
                        'SFDC_SAP4HANA__MEASUREMENT_POINT_CREATE',
                        Datetime.now(), errorList.uuid_Flow, errorList.error_Description, req.getBody(), 'SAP4HANA', 'FAIL');
                        loggerList.add(calloutLogger);
                        System.debug('CALLOUT LOGGER: ' + calloutLogger);
                    }
                }
                if(logEvent.warningList != null) {
                    for(SAPResponseDTO.WarningList warningList : logEvent.warningList) {
                        Callout_Logger__c calloutLogger = CalloutLoggerService.initializeUpdateCalloutLog(String.valueOf(res.getStatusCode()), warningList.errorType, false, 
                        'Measurement__c', warningList.operation_Name, warningList.operationType, 'SFDC', 
                        resList.correlationID, 
                        'SFDC_SAP4HANA__MEASUREMENT_POINT_CREATE', 
                        Datetime.now(), warningList.uuid_Flow, warningList.error_Description, req.getBody(), 'SAP4HANA', 'WARN');
                        System.debug('CALLOUT_LOGGER: ' + calloutLogger);
                        loggerList.add(calloutLogger);
                        System.debug('CALLOUT LOGGER: ' + calloutLogger);
                    }
                }
            
                if(resList.success == true) {
                    createdMeasurementIds.add(measurement.Id);

                    // Deleting all Callout Loggers for this recordId if the call is a complete success (no error nor warning logs)

                    if(loggerList.isEmpty()) {
                        deleteOlderLogsEvents.add(
                            new Delete_Older_Logs__e(
                                Record_Id__c = resList.correlationID,
                                Service__c = 'SFDC_SAP4HANA__MEASUREMENT_POINT_CREATE'
                            )
                        );
                    }
                }
            }
            
        } catch (Exception e) {
            System.debug('EXCEPTION!!!! : ' + e.getMessage());
            System.debug('Exception: ' + e);
            System.debug('Exception line number: ' + e.getLineNumber());

            Callout_Logger__c calloutLogger = CalloutLoggerService.initializeUpdateCalloutLog(
                null, 
                null, 
                false, 
                'Measurement__c', 
                'CREATE', 
                'POST', 
                'SFDC', 
                measurement.Id, 
                'SFDC_SAP4HANA__MEASUREMENT_POINT_CREATE', 
                Datetime.now(), 
                null, 
                e.getMessage(), 
                req.getBody(), 
                'SAP4HANA', 
                'FAIL'
            );

            loggerList.add(calloutLogger);
        }

        /* Status_Change_Event__e changeEvent = new Status_Change_Event__e(RecordId__c = measurement.Id);

        changeEvents.add(changeEvent); */

        List<String> measuresFields = new String[]{'Id', 'Serialized_Item__c', 'Date_Measurement__c', 'Measure__c',
        'Parameter_1_Value__c', 'isCreatedSAP__c'};

        List<Measurement__c> createdMeasurements = MeasurementDAO.getMeasurementsFromIds(createdMeasurementIds, measuresFields);
        List<Measurement__c> toUpdate = new List<Measurement__c>();

        for(Measurement__c m : createdMeasurements) {
            m.isCreatedSAP__c = true;
        }

        for(Measurement__c m : createdMeasurements) {
            Measurement__c tempMeasurement = new Measurement__c();
            tempMeasurement.Id = m.Id;
            tempMeasurement.isCreatedSAP__c = true;

            toUpdate.add(tempMeasurement);
        }
        ReturnDTO toReturn = new ReturnDTO(loggerList, toUpdate, deleteOlderLogsEvents);
        
        return toReturn;
    }

    public static void makeCalloutWrapper(List<Measurement__c> measurements){
        List<Measurement__c> measurementsToUpdate = new List<Measurement__c>();
        List<Callout_Logger__c> calloutLogs = new List<Callout_Logger__c>();
        List<Delete_Older_Logs__e> deleteOlderLogsEvents = new List<Delete_Older_Logs__e>();

        for(Measurement__c m : measurements) {
            ReturnDTO returnDTO = makeCallout(m);
            for(Measurement__c measurementDTO : returnDTO.toUpdate) {
                measurementsToUpdate.add(measurementDTO);
            }
            for(Callout_Logger__c cl : returnDTO.loggerList) {
                calloutLogs.add(cl);
            }
            for(Delete_Older_Logs__e event : returnDTO.deleteOlderLogsEvents) {
                deleteOlderLogsEvents.add(event);
            }
        }

        if(!measurementsToUpdate.isEmpty()) {
            update measurementsToUpdate;
        }
        if(!calloutLogs.isEmpty()) {
            insert calloutLogs;
        }
        if(!deleteOlderLogsEvents.isEmpty()) {
            List<Database.SaveResult> results = EventBus.publish(deleteOlderLogsEvents);
            System.debug('EVENTS PUBLISHED size: ' + results.size());
        }
    }

    @AuraEnabled
    public static void makeCalloutWrapperWithIds(List<String> relatedIds){
        List<String> measurementQueryFields = new List<String>{'Serialized_Item__c', 'Serialized_Item__r.Equipment_Key__c', 'Date_Measurement__c', 'Measure__c', 
        'Parameter_1_Value__c', 'isCreatedSAP__c'};

        List<Measurement__c> measurementsToUpdate = new List<Measurement__c>();
        List<Callout_Logger__c> calloutLogs = new List<Callout_Logger__c>();
        List<Delete_Older_Logs__e> deleteOlderLogsEvents = new List<Delete_Older_Logs__e>();

        List<Measurement__c> measurements = MeasurementDAO.getMeasurementsFromIds(relatedIds, measurementQueryFields);

        for(Measurement__c m : measurements) {
            ReturnDTO returnDTO = makeCallout(m);
            for(Measurement__c measurementDTO : returnDTO.toUpdate) {
                measurementsToUpdate.add(measurementDTO);
            }
            for(Callout_Logger__c cl : returnDTO.loggerList) {
                calloutLogs.add(cl);
            }
            for(Delete_Older_Logs__e event : returnDTO.deleteOlderLogsEvents) {
                deleteOlderLogsEvents.add(event);
            }
        }

        if(!measurementsToUpdate.isEmpty()) {
            update measurementsToUpdate;
        }
        if(!calloutLogs.isEmpty()) {
            insert calloutLogs;
        }
        if(!deleteOlderLogsEvents.isEmpty()) {
            List<Database.SaveResult> results = EventBus.publish(deleteOlderLogsEvents);
            System.debug('EVENTS PUBLISHED size: ' + results.size());
        }
    }

    public class ReturnDTO {
        public List<Callout_Logger__c> loggerList;
        public List<Measurement__c> toUpdate;
        public List<Delete_Older_Logs__e> deleteOlderLogsEvents;
    
        public ReturnDTO(List<Callout_Logger__c> loggerList, List<Measurement__c> toUpdate, List<Delete_Older_Logs__e> deleteOlderLogsEvents) {
          this.loggerList = loggerList;
          this.toUpdate = toUpdate;
          this.deleteOlderLogsEvents = deleteOlderLogsEvents;
        }
    }
}