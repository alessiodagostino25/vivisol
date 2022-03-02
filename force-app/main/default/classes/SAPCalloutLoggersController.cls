public class SAPCalloutLoggersController {
    
    @AuraEnabled
    public static List<CalloutLoggerDTO> getCalloutLoggers(String recordId, String objectApiName, String errorType){
        List<String> calloutLoggerQueryFields = new List<String>{'CreatedDate', 'Error_Description__c', 'ErrorType__c'};

        List<CalloutLoggerDTO> DTOsToReturn = new List<CalloutLoggerDTO>();

        DTOsToReturn = getCalloutLoggerDTOs(calloutLoggerQueryFields, objectApiName, new List<String>{recordId}, errorType, 10);

        return DTOsToReturn;
    }

    public static List<CalloutLoggerDTO> getCalloutLoggerDTOs(List<String> queryFields, String objectApiName, List<String> recordIds, String errorType, Integer queryLimit) {
        List<Callout_Logger__c> relatedCalloutLoggers = new List<Callout_Logger__c>();
        List<CalloutLoggerDTO> DTOsToReturn = new List<CalloutLoggerDTO>();

        if(objectApiName == 'Account') {
            relatedCalloutLoggers = CalloutLoggerDAO.getCalloutLoggersFromRelatedAccounts(queryFields, recordIds, errorType, queryLimit);
        }

        else if(objectApiName == 'Account_Company__c') {
            relatedCalloutLoggers = CalloutLoggerDAO.getCalloutLoggersFromRelatedAccountCompanies(queryFields, recordIds, errorType, queryLimit);
        }

        else if(objectApiName == 'Account_Sales_Organization__c') {
            relatedCalloutLoggers = CalloutLoggerDAO.getCalloutLoggersFromRelatedASOs(queryFields, recordIds, errorType, queryLimit);
        }

        else if(objectApiName == 'Address') {
            relatedCalloutLoggers = CalloutLoggerDAO.getCalloutLoggersFromRelatedAddresses(queryFields, recordIds, errorType, queryLimit);
        }

        else if(objectApiName == 'Contract_Framework__c') {
            relatedCalloutLoggers = CalloutLoggerDAO.getCalloutLoggersFromRelatedFrameworks(queryFields, recordIds, errorType, queryLimit);
        }

        else if(objectApiName == 'WorkOrder') {
            relatedCalloutLoggers = CalloutLoggerDAO.getCalloutLoggersFromRelatedWorkOrders(queryFields, recordIds, errorType, queryLimit);
        }

        else if(objectApiName == 'ProductRequest') {
            relatedCalloutLoggers = CalloutLoggerDAO.getCalloutLoggersFromRelatedProductRequests(queryFields, recordIds, errorType, queryLimit);
        }

        else if(objectApiName == 'Measurement__c') {
            relatedCalloutLoggers = CalloutLoggerDAO.getCalloutLoggersFromRelatedMeasurements(queryFields, recordIds, errorType, queryLimit);
        }
        
        else if(objectApiName == 'Rebate__c') {
            relatedCalloutLoggers = CalloutLoggerDAO.getCalloutLoggersFromRelatedRebates(queryFields, recordIds, errorType, queryLimit);
        }

        else if(objectApiName == 'EndOfMonthHeader__c') {
            relatedCalloutLoggers = CalloutLoggerDAO.getCalloutLoggersFromRelatedEOMs(queryFields, recordIds, errorType, queryLimit);
        }

        else if(objectApiName == 'Asset') {
            relatedCalloutLoggers = CalloutLoggerDAO.getCalloutLoggersFromRelatedAssets(queryFields, recordIds, errorType, queryLimit);
        }

        else if(objectApiName == 'Product_Asset_Patient_History__c') {
            relatedCalloutLoggers = CalloutLoggerDAO.getCalloutLoggersFromRelatedPAPHs(queryFields, recordIds, errorType, queryLimit);
        }

        else if(objectApiName == 'Account_Treatment__c') {
            relatedCalloutLoggers = CalloutLoggerDAO.getCalloutLoggersFromRelatedATs(queryFields, recordIds, queryLimit);
        }

        for(Callout_Logger__c cl : relatedCalloutLoggers) {
            CalloutLoggerDTO dto = new CalloutLoggerDTO(cl.Id, cl.CreatedDate, cl.Error_Description__c, cl.ErrorType__c);

            DTOsToReturn.add(dto);
        }

        return DTOsToReturn;
    }
}