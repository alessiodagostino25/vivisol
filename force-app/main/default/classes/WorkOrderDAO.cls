public with sharing class WorkOrderDAO {
    
    public static List<WorkOrder> getWorkOrdersFromAccountTreatment(List<String> queryFields, Id accountTreatmentId) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
            query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM WorkOrder WHERE Account_Treatment__c =: accountTreatmentId';
        System.debug('getWorkOrdersFromAccountTreatment QUERY: ' + query);
        
        return Database.query(query);
    }

    public static List<WorkOrder> getWorkOrdersFromAccountTreatmentIds(List<String> queryFields, List<Id> accountTreatmentIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
            query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM WorkOrder WHERE Account_Treatment__c IN: accountTreatmentIds';
        System.debug('getWorkOrdersFromAccountTreatmentIds QUERY: ' + query);
        
        return Database.query(query);
    }

    public static List<WorkOrder> getWOsFromCaseIds(List<String> queryFields, List<Id> caseIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
            query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM WorkOrder WHERE CaseId IN: caseIds';
        
        return Database.query(query);
    }

    public static List<WorkOrder> getAllWOsToAdjust(List<String> queryFields, List<Id> ATJIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
            query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM WorkOrder WHERE Account_Treatment_Job__c IN: ATJIds AND Autoscheduled__c = true AND (Status = \'New\' OR Status = \'Draft\') AND Due_Date__c != null AND Case.ExcludeFromAdjustment__c = false ORDER BY StartDate ASC';
        
        return Database.query(query);
    }

    public static List<WorkOrder> getCompletedWOs(List<String> queryFields, List<Id> relatedIds) {
        List<String> recordTypes = new List<String>{'AccountTreatment_Therapy', 'AccountTreatment_Sales', 'AccountTreatment_RentMaintenance', 'AccountTreatment_Maintenance'};
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
            query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM WorkOrder WHERE Status = \'Completed\' ' +  
        'AND Account_Treatment_Job__r.Patient_Treatment__r.RecordType.DeveloperName IN: recordTypes ' + 
        'AND Id IN: relatedIds';
        System.debug('getCompletedWOs QUERY: ' + query);
        
        return Database.query(query);
    }

    public static List<WorkOrder> getWorkOrdersFromIds(List<String> queryFields, List<Id> relatedIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
            query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM WorkOrder WHERE Id IN: relatedIds';
        System.debug('getWorkOrdersFromIds QUERY: ' + query);
        
        return Database.query(query);
    }

    public static List<WorkOrder> getWorkOrdersFromIds(List<String> queryFields, Set<Id> relatedIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
            query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM WorkOrder WHERE Id IN: relatedIds';
        System.debug('getWorkOrdersFromIds QUERY: ' + query);
        
        return Database.query(query);
    }

    public static List<WorkOrder> getWorkOrdersFromExternalIds(List<String> queryFields, List<String> relatedIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
            query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM WorkOrder WHERE OrderExternalId__c IN: relatedIds';
        System.debug('getWorkOrdersFromExternalIds QUERY: ' + query);
        
        return Database.query(query);
    }

    public static List<WorkOrder> getWorkOrdersFromATJIds(List<String> queryFields, List<Id> ATJIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
            query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM WorkOrder WHERE Account_Treatment_Job__c IN: ATJIds';
        System.debug('getWorkOrdersFromATJIds QUERY: ' + query);
        
        return Database.query(query);
    }

    public static List<WorkOrder> getBoReviewWordOrderIds(List<Id> WorkOrderIds) {
        String completed = 'Completed' ;
        String Cannotcomplete = 'Cannot Complete' ;
        String boreviewneeded = 'Bo review needed (general)' ;
        String  noshow = 'No show' ;
        String deliveryneed = 'Extra delivery needed' ;

        String query = 'SELECT Id , CaseId,Case.Status FROM WorkOrder WHERE (Status =: completed OR Status =: Cannotcomplete) AND Review__c = true AND Id IN :WorkOrderIds  ';
     
        System.debug(query);
        
        return Database.query(query);
    }
    public static List<WorkOrder> getnotRequiredBoReviewWorkOrders(List<Id> WorkOrderIds) {
        //String completed = 'Completed';
        String boreviewnotrequired = 'Bo review not needed' ;
        String caseType = 'Non compliance' ;
        String query = 'SELECT Id , CaseId,Case.Type FROM WorkOrder WHERE Review__c = false AND Id IN :WorkOrderIds';
     
        System.debug(query);
        
        return Database.query(query);
    }
    public static List<WorkOrder> getworkOrdersRelatedtoCaseIds(List<Id> caseIds) {
        String completed = 'Completed' ;
        String Cannotcomplete = 'Cannot Complete' ;
        String onhold = 'On Hold' ;
        String canceled = 'Canceled' ;
        String query = 'SELECT Id , CaseId,StartDate  FROM WorkOrder WHERE CaseId IN :caseIds AND ((Status !=: completed AND Status !=: Cannotcomplete AND Status !=:canceled) OR (Status =: completed AND Review__c = true AND Reviewed__c != true)) ORDER BY StartDate ASC NULLS LAST';
     
        System.debug(query);
        
        return Database.query(query);
    }
    public static List<WorkOrder> getworkOrdersRelatedtoCaseIdsfortask(List<Id> caseIds) {
        String completed = 'Completed';
        String Cannotcomplete = 'Cannot Complete';
        String onhold = 'On Hold';
        String canceled = 'Canceled';
        String Reason =  'Bo review not needed';
        String query = 'SELECT Id , CaseId ,StartDate FROM WorkOrder WHERE CaseId IN :caseIds AND ((Status !=: completed AND Status !=: Cannotcomplete AND Status !=:canceled) OR (Status =: Completed AND Review__c = true AND Reviewed__c != true)) ORDER BY StartDate ASC NULLS LAST';
     
        System.debug(query);
        
        return Database.query(query);
    }

    public static List<WorkOrder> getworkordersbylocationids(List<Id> locationIds) {
        String developerName = 'AccountTreatment_Maintenance';
        String recordTypeName = 'WorkOrder_Maintenance' ;
        String deliveryType = 'Welcome Model' ;
		List<String> statusValues = new List<String>();
		statusValues.add('In progress');
		statusValues.add('Completed');
		statusValues.add('Cannot Complete');
		statusValues.add('Canceled');
		String query = 'select Id,Account_Treatment__r.RecordType.DeveloperName,Status,LocationId,Street,PostalCode,StateCode,CountryCode,CaseId,EndDate,TaskCreated__c,RecordType.Name,Delivery_Type__c,City  From WorkOrder  Where Status NOT IN :statusvalues AND LocationId IN :locationIds AND Delivery_Type__c !=: deliveryType  ';
     
        System.debug(query);
        
        return Database.query(query);
    }

    public static List<WorkOrder> getFutureWOsFromATIds(List<String> queryFields, List<Id> accountTreatmentIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
        query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM WorkOrder WHERE Account_Treatment__c IN: accountTreatmentIds AND ' +
        'Status != \'In progress\' AND Status != \'On Hold \' AND Status != \'Completed\' AND Status != \'Cannot Complete \' AND Status != \'Canceled\'';
        System.debug('getFutureWOsFromATIds QUERY: ' + query);
        
        return Database.query(query);
    }

    public static List<WorkOrder> getAutoscheduledWOForCases(List<String> queryFields, List<Id> relatedCaseIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
        query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM WorkOrder WHERE CaseId IN: relatedCaseIds AND Autoscheduled__c = true';
        System.debug('getAutoscheduledWOForCases QUERY: ' + query);
        
        return Database.query(query);
    }
    public static List<WorkOrder> getWorkOrdersFromAccountIds(List<String> queryFields, List<Id> relatedAccountIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
        query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM WorkOrder WHERE AccountId  IN: relatedAccountIds ';
        System.debug('getWorkOrdersFromAccountIds QUERY: ' + query);
        
        return Database.query(query);
    }

    public static List<WorkOrder> getNewWorkOrdersFromATJIds(List<String> queryFields, List<Id> ATJIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
        query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM WorkOrder WHERE Account_Treatment_Job__c IN: ATJIds AND (Status = \'New\' OR Status = \'Draft\')';
        System.debug('getNewWorkOrdersFromATJIds QUERY: ' + query);
        
        return Database.query(query);
    }

    public static List<WorkOrder> getNewYOV0WorkOrdersFromATJIds(List<String> queryFields, List<Id> ATJIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
        query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM WorkOrder WHERE Account_Treatment_Job__c IN: ATJIds AND (Status = \'New\' OR Status = \'Draft\') AND Document_Type__c =\'YOV0\'';
        System.debug('getNewYOV0WorkOrdersFromATJIds QUERY: ' + query);
        
        return Database.query(query);
    }

    public static List<WorkOrder> getWorkOrdersFromResourceId(List<String> queryFields, List<Id> resourceIds) {
        String Assigned  = 'Assigned' ;  
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
            query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM WorkOrder WHERE Resource__c IN: resourceIds AND Status =:Assigned ';
        System.debug('getNewWorkOrdersFromResourceId QUERY: ' + query);
        
        return Database.query(query);
    }
    public static List<WorkOrder> getWorkOrdersFromparentid(List<String> queryFields,  List<Id> parentWorkOrderIds) {
         
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
        query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM WorkOrder WHERE ParentWorkOrderId IN: parentWorkOrderIds ';
        System.debug('getWorkOrdersFromparentid QUERY: ' + query);
        
        return Database.query(query);
    }

    public static List<WorkOrder> getWOsRelatedToATAPs(List<String> queryFields, List<Id> locationIds, List<Id> ATIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
            query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM WorkOrder WHERE Account_Treatment__c IN: ATIds AND LocationId IN: locationIds AND (Status = \'Draft\' OR Status = \'New\' OR Status = \'Assigned\' OR Status = \'On Hold\')';
        System.debug('getWOsRelatedToATAPs QUERY: ' + query);
        
        return Database.query(query);
    }

    public static List<WorkOrder> getWOFromATJPS(List<String> queryFields, List<Id> accountTreatmentJobIds,List<Id> atjpAssetIds) {
        List<String> woStatus = new List<String>();
        woStatus.add('In progress');
        woStatus.add('Completed');
        woStatus.add('Cannot Complete');
        woStatus.add('Canceled');
        woStatus.add('Assigned');
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
            query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM WorkOrder WHERE Account_Treatment_Job__c IN :accountTreatmentJobIds';
        query += ' AND WorkOrder.Status NOT IN :woStatus AND AssetId IN : atjpAssetIds';
      
        System.debug('getWOFromATJPS QUERY: ' + query);
        
        return Database.query(query);
    }
    public static List<WorkOrder> checkWOFromATJPS(List<String> queryFields, List<Id> accountTreatmentJobIds,List<Id> atjpAssetIds) {
        List<String> woStatus = new List<String>();
        woStatus.add('In progress');
        woStatus.add('Assigned');
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
            query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM WorkOrder WHERE Account_Treatment_Job__c IN :accountTreatmentJobIds';
        query += ' AND WorkOrder.Status IN :woStatus AND AssetId IN : atjpAssetIds';
        System.debug('checkWOFromATJPS QUERY: ' + query);
        
        return Database.query(query);
    }
    public static List<WorkOrder> getWOFromworktype(List<String> queryFields,List<Id> workTypeIds) {
        List<String> woStatus = new List<String>();
        woStatus.add('Draft');
        woStatus.add('New');
        woStatus.add('On Hold');
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
            query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM WorkOrder WHERE WorkTypeId  IN :workTypeIds';
        query += ' AND WorkOrder.Status IN :woStatus';
        System.debug('getWOFromworktype QUERY: ' + query);
        
        return Database.query(query);
    }

    public static List<WorkOrder> getOpenWOsFromCaseIds(List<String> queryFields, List<String> caseIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
        query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM WorkOrder WHERE CaseId IN: caseIds AND Status != \'Completed\' AND Status != \'Canceled\' AND Status != \'Cannot Complete\'';
        System.debug('getOpenWOsFromCaseIds QUERY: ' + query);
        
        return Database.query(query);
    }

    public static List<WorkOrder> getWOsFromParentsAndDifferentResource(List<String> queryFields, List<String> parentWOIds, List<String> resourcesToExclude) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
            query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM WorkOrder WHERE ParentWorkOrderId IN: parentWOIds AND Resource__c NOT IN: resourcesToExclude';
        System.debug('getWOsFromParentsAndDifferentResource QUERY: ' + query);
        
        return Database.query(query);
    }

    public static List<WorkOrder> getYP00WorkOrdersFromIds(List<String> queryFields, List<String> relatedIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
            query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM WorkOrder WHERE Id IN: relatedIds AND Document_Type__c = \'YP00\'';
        System.debug('getYP00WorkOrdersFromIds QUERY: ' + query);
        
        return Database.query(query);
    }

    public static List<WorkOrder> getNotClosedWOsFromCaseIds(List<String> queryFields, List<String> caseIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
            query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM WorkOrder WHERE IsClosed = false AND CaseId IN: caseIds';
        System.debug('getNotClosedWOsFromCaseIds QUERY: ' + query);
        
        return Database.query(query);
    }

    public static List<WorkOrder> getWOsFromCaseIdsByStartDateASC(List<String> queryFields, List<Id> caseIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
            query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM WorkOrder WHERE CaseId IN: caseIds ORDER BY StartDate ASC';
        System.debug('getWOsFromCaseIdsByStartDateASC QUERY: ' + query);
        
        return Database.query(query);
    }

    public static List<WorkOrder> getWOsFromCaseIdsExcluding(List<String> queryFields, List<String> caseIds, List<String> toExclude) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
            query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM WorkOrder WHERE CaseId IN: caseIds AND Id NOT IN: toExclude ORDER BY StartDate ASC';
        System.debug('getWOsFromCaseIdsExcluding QUERY: ' + query);
        
        return Database.query(query);
    }

    public static List<WorkOrder> getFutureWOsFromCaseIds(List<String> queryFields, List<String> caseIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
        query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM WorkOrder WHERE CaseId IN: caseIds AND ' +
        'Status != \'In progress\' AND Status != \'On Hold \' AND Status != \'Completed\' AND Status != \'Cannot Complete \' AND Status != \'Canceled\'';
        System.debug('getFutureWOsFromCaseIds QUERY: ' + query);
        
        return Database.query(query);
    }
}