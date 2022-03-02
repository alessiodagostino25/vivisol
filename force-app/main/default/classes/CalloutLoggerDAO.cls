public with sharing class CalloutLoggerDAO {
    
    public static List<Callout_Logger__c> getCalloutLoggersFromRecordIdsExcludingUUIDs(List<String> queryFields, List<String> recordIds, List<String> UUIDsToExclude, 
    List<String> services, Integer queryLimit) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
        query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Callout_Logger__c WHERE RecordId__c IN: recordIds AND UUID_Flow__c NOT IN: UUIDsToExclude AND Service__c IN: services ORDER BY CreatedDate DESC';

        if(queryLimit != null) {
            query += ' LIMIT ' + queryLimit;
        }
        System.debug('getCalloutLoggersFromRecordIdsExcludingUUIDs QUERY: ' + query);
        
        return Database.query(query);
    }

    public static List<Callout_Logger__c> getCalloutLoggersFromIds(List<String> queryFields, List<String> relatedIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
        query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Callout_Logger__c WHERE Id IN: relatedIds';

        System.debug('getCalloutLoggersFromIds QUERY: ' + query);
        
        return Database.query(query);
    }

    public static List<Callout_Logger__c> getCalloutLoggersFromRelatedAccounts(List<String> queryFields, List<String> accountIds, String errorType, Integer queryLimit) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
        query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Callout_Logger__c WHERE Related_Account__c IN: accountIds AND isSolved__c = false';

        if(errorType != 'EW' && errorType != null) {
            query += ' AND ErrorType__c =: errorType';
        }

        query += ' ORDER BY CreatedDate DESC';

        if(queryLimit != null) {
            query += ' LIMIT ' + queryLimit;
        }

        System.debug('getCalloutLoggersFromRelatedAccounts QUERY: ' + query);
        
        return Database.query(query);
    }

    public static List<Callout_Logger__c> getCalloutLoggersFromRelatedAccountCompanies(List<String> queryFields, List<String> ACIds, String errorType, Integer queryLimit) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
        query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Callout_Logger__c WHERE Related_Account_Company__c IN: ACIds AND isSolved__c = false';

        if(errorType != 'EW' && errorType != null) {
            query += ' AND ErrorType__c =: errorType';
        }

        query += ' ORDER BY CreatedDate DESC';

        if(queryLimit != null) {
            query += ' LIMIT ' + queryLimit;
        }

        System.debug('getCalloutLoggersFromRelatedAccountCompanies QUERY: ' + query);
        
        return Database.query(query);
    }

    public static List<Callout_Logger__c> getCalloutLoggersFromRelatedASOs(List<String> queryFields, List<String> ASOIds, String errorType, Integer queryLimit) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
        query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Callout_Logger__c WHERE Related_Account_Sales_Organization__c IN: ASOIds AND isSolved__c = false';

        if(errorType != 'EW' && errorType != null) {
            query += ' AND ErrorType__c =: errorType';
        }

        query += ' ORDER BY CreatedDate DESC';

        if(queryLimit != null) {
            query += ' LIMIT ' + queryLimit;
        }

        System.debug('getCalloutLoggersFromRelatedASOs QUERY: ' + query);
        
        return Database.query(query);
    }

    public static List<Callout_Logger__c> getCalloutLoggersFromRelatedAddresses(List<String> queryFields, List<String> addressIds, String errorType, Integer queryLimit) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
        query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Callout_Logger__c WHERE Related_Address__c IN: addressIds AND isSolved__c = false';

        if(errorType != 'EW' && errorType != null) {
            query += ' AND ErrorType__c =: errorType';
        }

        query += ' ORDER BY CreatedDate DESC';

        if(queryLimit != null) {
            query += ' LIMIT ' + queryLimit;
        }

        System.debug('getCalloutLoggersFromRelatedAddresses QUERY: ' + query);
        
        return Database.query(query);
    }

    public static List<Callout_Logger__c> getCalloutLoggersFromRelatedFrameworks(List<String> queryFields, List<String> CFIds, String errorType, Integer queryLimit) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
        query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Callout_Logger__c WHERE Related_Contract_Framework__c IN: CFIds AND isSolved__c = false';

        if(errorType != 'EW' && errorType != null) {
            query += ' AND ErrorType__c =: errorType';
        }

        query += ' ORDER BY CreatedDate DESC';

        if(queryLimit != null) {
            query += ' LIMIT ' + queryLimit;
        }

        System.debug('getCalloutLoggersFromRelatedFrameworks QUERY: ' + query);
        
        return Database.query(query);
    }

    public static List<Callout_Logger__c> getCalloutLoggersFromRelatedWorkOrders(List<String> queryFields, List<String> WOIds, String errorType, Integer queryLimit) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
        query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Callout_Logger__c WHERE Related_Work_Order__c IN: WOIds AND isSolved__c = false';

        if(errorType != 'EW' && errorType != null) {
            query += ' AND ErrorType__c =: errorType';
        }

        query += ' ORDER BY CreatedDate DESC';

        if(queryLimit != null) {
            query += ' LIMIT ' + queryLimit;
        }

        System.debug('getCalloutLoggersFromRelatedWorkOrders QUERY: ' + query);
        
        return Database.query(query);
    }

    public static List<Callout_Logger__c> getCalloutLoggersFromRelatedProductRequests(List<String> queryFields, List<String> PRIds, String errorType, Integer queryLimit) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
        query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Callout_Logger__c WHERE Related_Product_Request__c IN: PRIds AND isSolved__c = false';

        if(errorType != 'EW' && errorType != null) {
            query += ' AND ErrorType__c =: errorType';
        }

        query += ' ORDER BY CreatedDate DESC';

        if(queryLimit != null) {
            query += ' LIMIT ' + queryLimit;
        }

        System.debug('getCalloutLoggersFromRelatedProductRequests QUERY: ' + query);
        
        return Database.query(query);
    }

    public static List<Callout_Logger__c> getCalloutLoggersFromRelatedMeasurements(List<String> queryFields, List<String> measurementIds, String errorType, Integer queryLimit) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
        query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Callout_Logger__c WHERE Related_Measurement__c IN: measurementIds AND isSolved__c = false';

        if(errorType != 'EW' && errorType != null) {
            query += ' AND ErrorType__c =: errorType';
        }

        query += ' ORDER BY CreatedDate DESC';

        if(queryLimit != null) {
            query += ' LIMIT ' + queryLimit;
        }

        System.debug('getCalloutLoggersFromRelatedMeasurements QUERY: ' + query);
        
        return Database.query(query);
    }

    public static List<Callout_Logger__c> getCalloutLoggersFromRelatedRebates(List<String> queryFields, List<String> rebateIds, String errorType, Integer queryLimit) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
        query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Callout_Logger__c WHERE Related_Rebate__c IN: rebateIds AND isSolved__c = false';

        if(errorType != 'EW' && errorType != null) {
            query += ' AND ErrorType__c =: errorType';
        }

        query += ' ORDER BY CreatedDate DESC';

        if(queryLimit != null) {
            query += ' LIMIT ' + queryLimit;
        }

        System.debug('getCalloutLoggersFromRelatedRebates QUERY: ' + query);
        
        return Database.query(query);
    }

    public static List<Callout_Logger__c> getCalloutLoggersFromRelatedEOMs(List<String> queryFields, List<String> EOMIds, String errorType, Integer queryLimit) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
        query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Callout_Logger__c WHERE Related_EOM__c IN: EOMIds AND isSolved__c = false';

        if(errorType != 'EW' && errorType != null) {
            query += ' AND ErrorType__c =: errorType';
        }

        query += ' ORDER BY CreatedDate DESC';

        if(queryLimit != null) {
            query += ' LIMIT ' + queryLimit;
        }

        System.debug('getCalloutLoggersFromRelatedEOMs QUERY: ' + query);
        
        return Database.query(query);
    }

    public static List<Callout_Logger__c> getCalloutLoggersFromRelatedAssets(List<String> queryFields, List<String> assetIds, String errorType, Integer queryLimit) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
        query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Callout_Logger__c WHERE Related_Asset__c IN: assetIds AND isSolved__c = false';

        if(errorType != 'EW' && errorType != null) {
            query += ' AND ErrorType__c =: errorType';
        }

        query += ' ORDER BY CreatedDate DESC';

        if(queryLimit != null) {
            query += ' LIMIT ' + queryLimit;
        }

        System.debug('getCalloutLoggersFromRelatedAssets QUERY: ' + query);
        
        return Database.query(query);
    }

    public static List<Callout_Logger__c> getCalloutLoggersFromRelatedPAPHs(List<String> queryFields, List<String> PAPHIds, String errorType, Integer queryLimit) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
        query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Callout_Logger__c WHERE Related_PAPH__c IN: PAPHIds AND isSolved__c = false';

        if(errorType != 'EW' && errorType != null) {
            query += ' AND ErrorType__c =: errorType';
        }

        query += ' ORDER BY CreatedDate DESC';

        if(queryLimit != null) {
            query += ' LIMIT ' + queryLimit;
        }

        System.debug('getCalloutLoggersFromRelatedPAPHs QUERY: ' + query);
        
        return Database.query(query);
    }

    public static List<Callout_Logger__c> getCalloutLoggersFromRelatedATs(List<String> queryFields, List<String> ATIds, Integer queryLimit) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
        query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Callout_Logger__c WHERE Related_Account_Treatment__c IN: ATIds AND isSolved__c = false ORDER BY CreatedDate DESC';

        if(queryLimit != null) {
            query += ' LIMIT ' + queryLimit;
        }

        System.debug('getCalloutLoggersFromRelatedATs QUERY: ' + query);
        
        return Database.query(query);
    }
}