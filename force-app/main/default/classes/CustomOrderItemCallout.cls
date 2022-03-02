public class CustomOrderItemCallout {
    
    public static String CustomOrderItemCalloutmethod(String orderitemid) {
        OrderItem oi = OrderItemDAO.getOrderItemforsapFromId(orderitemid) ;

        CallOutForProductPriceDTO dto = new CallOutForProductPriceDTO(oi);
        System.debug('DTO: ' + dto);
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:SFDC_SAP4HANA_PRODUCT_PRICE');
        req.setMethod('POST');
        req.setTimeout(10000); 
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');
    
        // create body request
        String reqJSON = JSON.serialize(dto);
        req.setBody(reqJSON);
    
        Http http = new Http();
        HTTPResponse res = new HttpResponse();
        System.debug('requst'+req.getEndpoint());
        System.debug('request body'+req.getBody());

        try {
            res = http.send(req);
            System.debug('RESPONSE: ' + res);
            System.debug('response status code'+res.getStatusCode());
            System.debug('RESPONSE BODY: ' + res.getBody());
            String response = res.getBody();
            SAPResponseDTO responseDTO = (SAPResponseDTO) System.JSON.deserialize(response, SAPResponseDTO.class);
            System.debug('responsedto'+responseDTO);
            List<Callout_Logger__c> loggerList = new List<Callout_Logger__c>();
            List<Delete_Older_Logs__e> deleteOlderLogsEvents = new List<Delete_Older_Logs__e>();
        
            //CALLOUT_LOGGER CREATION FOR errorList ELEMENTS

            if(responseDTO != null && responseDTO.resultList != null && !responseDTO.resultList.isEmpty()) {
                for(SAPResponseDTO.ResultList resList : responseDTO.resultList) {
                    SAPResponseDTO.Log_event logEvent = resList.log_event;

                    if(logEvent != null) {
                        if(logEvent.errorList != null) {
                            for(SAPResponseDTO.ErrorList errorList : logEvent.errorList) {
                                Callout_Logger__c calloutLogger = CalloutLoggerService.initializeUpdateCalloutLog(
                                    String.valueOf(res.getStatusCode()), 
                                    errorList.errorType, 
                                    false, 
                                    'OrderItem', 
                                    errorList.operation_Name, 
                                    errorList.operationType, 
                                    'SFDC', 
                                    orderitemid,
                                    errorList.service,
                                    Datetime.now(), 
                                    errorList.uuid_Flow, 
                                    errorList.error_Description, 
                                    req.getBody(), 
                                    'SAP4HANA', 
                                    'FAIL'
                                );
                                System.debug('CALLOUT_LOGGER: ' + calloutLogger);

                                loggerList.add(calloutLogger);
                            }
                        }
                        if(logEvent.warningList != null) {
                            for(SAPResponseDTO.WarningList warningList : logEvent.warningList) {
                                Callout_Logger__c calloutLogger = CalloutLoggerService.initializeUpdateCalloutLog(
                                    String.valueOf(res.getStatusCode()), 
                                    warningList.errorType, 
                                    false, 
                                    'OrderItem', 
                                    warningList.operation_Name, 
                                    warningList.operationType, 
                                    'SFDC', 
                                    orderitemid, 
                                    warningList.service, 
                                    Datetime.now(), 
                                    warningList.uuid_Flow, 
                                    warningList.error_Description, 
                                    req.getBody(), 
                                    'SAP4HANA', 
                                    'WARN'
                                );
                                System.debug('CALLOUT_LOGGER: ' + calloutLogger);

                                loggerList.add(calloutLogger);
                            }
                        }
                    }
                }
            }

            if(!loggerList.isEmpty()) {
                insert loggerList;
            }
            else {
                deleteOlderLogsEvents.add(
                    new Delete_Older_Logs__e(
                        Record_Id__c = orderitemid
                    )
                );

                List<Database.SaveResult> results = EventBus.publish(deleteOlderLogsEvents);
            }

            return response;        
        }
        catch (Exception e) {
            System.debug('EXCEPTION!!!! : ' + e.getMessage());
            System.debug('Exception: ' + e);
            System.debug('Exception line number: ' + e.getLineNumber());

            Callout_Logger__c calloutLogger = CalloutLoggerService.initializeUpdateCalloutLog(
                null, 
                null, 
                false, 
                'OrderItem', 
                'POST', 
                'POST', 
                'SFDC', 
                orderitemid, 
                'SFDC_SAP4HANA__PRODUCT_PRICE', 
                Datetime.now(), 
                null, 
                e.getMessage(), 
                req.getBody(), 
                'SAP4HANA', 
                'FAIL'
            );

            insert calloutLogger;

            return null;
        }
    }
}