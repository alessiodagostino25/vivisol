public with sharing class TaskDAO {
    
    public static List<Task> getTasksFromIds(List<String> queryFields, List<Id> relatedIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
            query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Task WHERE Id IN: relatedIds';
        System.debug('getTasksFromIds QUERY: ' + query);
        
        return Database.query(query);
    }

    public static List<Task> getTasksFromWhatId(List<String> queryFields, Id whatId) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
        query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Task WHERE WhatId =: whatId';
        System.debug('getTasksFromWhatId QUERY: ' + query);
        
        return Database.query(query);
    }

    public static List<Task> getTasksFromWhatIds(List<String> queryFields, List<Id> whatIds) {

        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
            query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Task WHERE WhatId IN: whatIds';
        System.debug('getTasksFromWhatIds QUERY: ' + query);
        
        return Database.query(query);
    }

    public static List<Task> getAllTasksToAdjust(List<String> queryFields, List<Id> ATJIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
            query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Task WHERE Account_Treatment_Job__c IN: ATJIds AND Autoscheduled__c = true AND CompletedDateTime = null AND Due_Date__c != null';
        System.debug('getAllTasksToAdjust QUERY: ' + query);
        
        return Database.query(query);
    }

    public static List<Task> gettaskRelatedtoCaseIds(List<Id> caseIds) {
        String open = 'Open';
        
        String query = 'SELECT Id , WhatId, ActivityDate FROM Task WHERE WhatId IN :caseIds AND Status =: open ORDER BY ActivityDate ASC NULLS LAST ';
     
        System.debug(query);
        return Database.query(query);
    }

    public static List<Task> getAutoscheduledTaskForCases(List<String> queryFields, List<Id> relatedCaseIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
            query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Task WHERE WhatId IN: relatedCaseIds AND Autoscheduled__c = true';
        System.debug('getAutoscheduledTaskForCases QUERY: ' + query);
        
        return Database.query(query);
    }

    public static List<Task> getOpenTasksFromWhatIds(List<String> queryFields, List<Id> whatIds) {

        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
        query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Task WHERE WhatId IN: whatIds AND Status = \'Open\'';
        System.debug('getOpenTasksFromWhatIds QUERY: ' + query);
        
        return Database.query(query);
    }

    public static List<Task> getNotClosedTasksFromCaseIds(List<String> queryFields, List<String> caseIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
            query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Task WHERE IsClosed = false AND WhatId IN: caseIds';
        System.debug('getNotClosedTasksFromCaseIds QUERY: ' + query);
        
        return Database.query(query);
    }

    public static List<Task> getTasksFromATJIds(List<String> queryFields, List<String> ATJIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
            query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Task WHERE Account_Treatment_Job__c IN: ATJIds';
        System.debug('getTasksFromATJIds QUERY: ' + query);
        
        return Database.query(query);
    }

    public static List<Task> getTasksFromCasesExcluding(List<String> queryFields, List<String> caseIds, List<String> toExclude) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
            query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Task WHERE WhatId IN: caseIds AND IsClosed = false AND Id NOT IN: toExclude ORDER BY ActivityDate ASC';
        System.debug('getTasksFromCasesExcluding QUERY: ' + query);
        
        return Database.query(query);
    }
}