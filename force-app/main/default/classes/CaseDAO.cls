public without sharing class CaseDAO {

    public static Case getCaseForOrder(String caseId) {
        return [SELECT Id, AccountId, ContactId, Contract_Treatment__r.Contract_Framework__r.Customer__c, 
        Contract_Treatment__c, Account.Location__c, Contract_Treatment__r.Contract_Framework__r.Customer__r.Location__c,
        Contract_Treatment__r.Contract_Framework__r.Customer__r.Billing_reference__c, 
        Contract_Treatment__r.Contract_Framework__r.Customer__r.Customer_Purchase_Order_Number__c, 
        Contract_Treatment__r.Contract_Framework__r.Customer__r.Customer_Purchase_Order_Date__c, 
        Contract_Treatment__r.Contract_Framework__r.Payment_Condition__c, 
        Account.ShippingStreet, Account.ShippingPostalCode, Account.ShippingCity, Account.ShippingStateCode, 
        Account.ShippingCountryCode, Contract_Treatment__r.Contract_Framework__r.Customer__r.ShippingStreet,
        Account.Location__r.VisitorAddress.Street, Account.Location__r.VisitorAddress.PostalCode,
        Account.Location__r.VisitorAddress.City, Account.Location__r.VisitorAddress.StateCode,
        Account.Location__r.VisitorAddress.CountryCode, Account.PersonContactId,
        Contract_Treatment__r.Contract_Framework__r.Customer__r.ShippingPostalCode, 
        Contract_Treatment__r.Contract_Framework__r.Customer__r.ShippingCity, 
        Contract_Treatment__r.Contract_Framework__r.Customer__r.ShippingStateCode, 
        Contract_Treatment__r.Contract_Framework__r.Customer__r.ShippingCountryCode, Account.IsPersonAccount, 
        Contract_Treatment__r.Contract_Framework__r.Customer__r.LocationCity__c, 
        Contract_Treatment__r.Contract_Framework__r.Customer__r.LocationCountryCode__c,
        Contract_Treatment__r.Contract_Framework__r.Customer__r.LocationPostalCode__c,
        Contract_Treatment__r.Contract_Framework__r.Customer__r.LocationStateCode__c,
        Contract_Treatment__r.Contract_Framework__r.Customer__r.LocationStreet__c FROM Case WHERE Id =: caseId];
    }

    public static Case getCaseForQuote(String caseId) {
        return [SELECT Id, AccountId, ContactId, Contract_Treatment__c, Account.Location__c, 
        Contract_Treatment__r.Contract_Framework__r.Payment_Condition__c, Account.Location__r.VisitorAddress.Street,
        Account.Location__r.VisitorAddress.PostalCode, Account.Location__r.VisitorAddress.City, 
        Account.Location__r.VisitorAddress.StateCode, Account.Location__r.VisitorAddress.CountryCode, Contract_Treatment__r.Contract_Framework__c, 
        Contract_treatment__r.Contract_Framework__r.Customer__c, Account.PersonContactId, Account.IsPersonAccount
        FROM Case WHERE Id =: caseId];
    }

    public static List<Case> getCasesFromIds(List<String> queryFields, List<Id> relatedIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
        query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Case WHERE Id IN: relatedIds';
        System.debug('getCasesFromIds QUERY: ' + query);
        
        return Database.query(query);
    }

    public static Map<Id, Case> getATJToFirstCaseMap(List<String> queryFields, List<Id> ATJIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
            query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Case WHERE Account_Treatment_Job__c IN: ATJIds AND Autoscheduled__c = true AND Status != \'Closed\' ORDER BY Start_Date__c ASC';
        System.debug('getATJToFirstCaseMap QUERY: ' + query);
        
        List<Case> allCases = Database.query(query);
        System.debug('----- QUERY -----');
        System.debug('ATJIds size: ' + ATJIds.size());

        Map<Id, List<Case>> ATJToCasesMap = new Map<Id, List<Case>>();
        Map<Id, Case> ATJToFirstCaseMap = new Map<Id, Case>();

        if(!allCases.isEmpty()) {
            for(Case c : allCases) {
                if(ATJToCasesMap.get(c.Account_Treatment_Job__c) == null) {
                    ATJToCasesMap.put(c.Account_Treatment_Job__c, new List<Case>());
                }
                ATJToCasesMap.get(c.Account_Treatment_Job__c).add(c);
            }

            System.debug('allCases size: ' + allCases.size());

            for(Id atjId : ATJIds) {
                List<Case> relatedCases = ATJToCasesMap.get(atjId);
                System.debug('relatedCases: ' + relatedCases);
                if(relatedCases != null) {
                    Case firstCase = relatedCases[0];
                    ATJToFirstCaseMap.put(atjId, firstCase);
                }
            }
        }

        return ATJToFirstCaseMap;
    }

    public static Map<Id, Case> getATJToLastCaseMap(List<String> queryFields, List<Id> ATJIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
        query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Case WHERE Account_Treatment_Job__c IN: ATJIds AND Autoscheduled__c = true AND Status != \'Closed\' AND Status != \'Canceled\' AND Status != \'Cannot Complete\' AND ExcludeFromAdjustment__c = false ORDER BY Start_Date__c DESC';
        System.debug('getATJToLastCaseMap QUERY: ' + query);
        
        List<Case> allCases = Database.query(query);

        Map<Id, List<Case>> ATJToCasesMap = new Map<Id, List<Case>>();
        Map<Id, Case> ATJToLastCaseMap = new Map<Id, Case>();

        if(!allCases.isEmpty()) {
            for(Case c : allCases) {
                if(ATJToCasesMap.get(c.Account_Treatment_Job__c) == null) {
                    ATJToCasesMap.put(c.Account_Treatment_Job__c, new List<Case>());
                }
                ATJToCasesMap.get(c.Account_Treatment_Job__c).add(c);
            }
        }

        for(Id atjId : ATJIds) {
            List<Case> relatedCases = ATJToCasesMap.get(atjId);
            if(relatedCases != null && !relatedCases.isEmpty()) {
                Case firstCase = relatedCases[0];
                ATJToLastCaseMap.put(atjId, firstCase);
            }
        }

        return ATJToLastCaseMap;
    }

    public static Map<Id, Case> getATJToAllLastCaseMap(List<String> queryFields, List<Id> ATJIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
        query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        //query += ' FROM Case WHERE Account_Treatment_Job__c IN: ATJIds AND Autoscheduled__c = true ORDER BY Start_Date__c DESC';
        query += ' FROM Case WHERE Account_Treatment_Job__c IN: ATJIds AND Autoscheduled__c = true AND Status = \'Closed\' ORDER BY Start_Date__c DESC';
        System.debug('getATJToLastCaseMap QUERY: ' + query);
        
        List<Case> allCases = Database.query(query);

        Map<Id, List<Case>> ATJToCasesMap = new Map<Id, List<Case>>();
        Map<Id, Case> ATJToLastCaseMap = new Map<Id, Case>();

        if(!allCases.isEmpty()) {
            for(Case c : allCases) {
                if(ATJToCasesMap.get(c.Account_Treatment_Job__c) == null) {
                    ATJToCasesMap.put(c.Account_Treatment_Job__c, new List<Case>());
                }
                ATJToCasesMap.get(c.Account_Treatment_Job__c).add(c);
            }
        }

        for(Id atjId : ATJIds) {
            List<Case> relatedCases = ATJToCasesMap.get(atjId);
            if(relatedCases != null && !relatedCases.isEmpty()) {
                Case firstCase = relatedCases[0];
                ATJToLastCaseMap.put(atjId, firstCase);
            }
        }

        return ATJToLastCaseMap;
    }

    public static List<Case> getCasesFromATJIds(List<String> queryFields, List<Id> ATJIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
        query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Case WHERE Account_Treatment_Job__c IN: ATJIds';
        System.debug('getCasesFromATJIds QUERY: ' + query);
        
        return Database.query(query);
    }

    public static List<Case> getOpenNoComplianceCasesFromATs(List<String> queryFields, List<String> ATIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
        query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Case WHERE Account_Treatment__c IN: ATIds AND Type = \'Non Compliance\' AND Status != \'Closed\' AND Status != \'Canceled\'';
        System.debug('getOpenNoComplianceCasesFromATs QUERY: ' + query);
        
        return Database.query(query);
    }

    public static List<Case> getOpenCasesFromATs(List<String> queryFields, List<String> ATIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
        query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Case WHERE Account_Treatment__c IN: ATIds AND Status != \'Closed\' AND Status != \'Canceled\'';
        System.debug('getOpenCasesFromATs QUERY: ' + query);
        
        return Database.query(query);
    }
}