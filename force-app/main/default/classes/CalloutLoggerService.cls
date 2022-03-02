public class CalloutLoggerService {
    
    public static Callout_Logger__c initializeUpdateCalloutLog(String errorHTTPCode, String errorType, Boolean isSolved, String obj, String operationName,
    String operationType, String originSystem, String recordId, String service, Datetime timeStamp, String UUIDflow, String description, String requestBody,
    String targetSystem, String status) {

        Callout_Logger__c logger = new Callout_Logger__c(
            errorHTTPCode__c = errorHTTPCode, 
            ErrorType__c = errorType, 
            isSolved__c = isSolved,
            Object__c = obj, 
            Operation_Name__c = operationName, 
            OperationType__c = operationType, 
            OriginSystem__c = originSystem, 
            RecordId__c = recordId, 
            Service__c = service, 
            Timestamp__c = timeStamp, 
            UUID_Flow__c = UUIDflow, 
            Error_Description__c = description, 
            Request_Body__c = requestBody,
            TargetSystem__c = targetSystem,
            Status__c = status
            );

        system.debug ('Aggiunta di test');
        //System.debug('CalloutLogger: ' + logger);
        //insert logger; //bulkify?

        return logger;
    }
    
}