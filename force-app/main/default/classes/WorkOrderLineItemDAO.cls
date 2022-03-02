public with sharing class WorkOrderLineItemDAO {
    
    public static List<WorkOrderLineItem> getWOLIsFromWOs(List<String> queryFields, List<Id> workOrderIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
            query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM WorkOrderLineItem WHERE WorkOrderId IN: workOrderIds';
        System.debug('getWOLIsFromWOs QUERY: ' + query);
        
        return Database.query(query);
    }

    public static List<WorkOrderLineItem> getNotCompletedWOLIsFromWOs(List<String> queryFields, List<Id> workOrderIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
            query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM WorkOrderLineItem WHERE WorkOrderId IN: workOrderIds AND Status != \'Completed\' AND Status != \'Canceled\' AND QuantityDelivered__c != null'; // TO CHANGE: Completed
        System.debug('getCompletedWOLIsFromWOs QUERY: ' + query);
        
        return Database.query(query);
    }

    public static List<WorkOrderLineItem> getWOLIsFromIds(List<String> queryFields, List<Id> relatedIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
            query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM WorkOrderLineItem WHERE Id IN: relatedIds';
        System.debug('getWOLIsFromIds QUERY: ' + query);
        
        return Database.query(query);
    }

    public static List<WorkOrderLineItem> getWOLIsFromLabels(List<String> queryFields, List<String> temporaryLabels) {
        String Completed = 'Completed';
        String CannotComplete = 'Cannot Complete';
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
            query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM WorkOrderLineItem WHERE Serial_Number__c IN: temporaryLabels AND AssetId = null AND ( WorkOrder.Status =:Completed  OR WorkOrder.Status =:CannotComplete ) AND Status = \'Completed\'';
        System.debug('getWOLIsFromIds QUERY: ' + query);
        
        return Database.query(query);
    }

    
    public static List<WorkOrderLineItem> getWOLIsFromATJP(List<String> queryFields, String accountTreatmentJobProductId) {
        List<String> woStatus = new List<String>();
        String woliStatusValue = 'New';
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
        query += ' FROM WorkOrderLineItem WHERE Account_Treatment_Job_Product__c = :accountTreatmentJobProductId';
        query += ' AND Status = :woliStatusValue';
        query += ' AND WorkOrder.Status NOT IN :woStatus';
        System.debug('getWOLIsFromIds QUERY: ' + query);
        
        return Database.query(query);
    }
    public static List<WorkOrderLineItem> getWOLIsFromATJPS(List<String> queryFields, List<Id> accountTreatmentJobProductIds) {
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
        query += ' FROM WorkOrderLineItem WHERE Account_Treatment_Job_Product__c IN :accountTreatmentJobProductIds';
        query += ' AND WorkOrder.Status NOT IN :woStatus';
        System.debug('getWOLIsFromIds QUERY: ' + query);
        
        return Database.query(query);
    }

    public static List<WorkOrderLineItem> getWOLIsToMoveFromWOs(List<String> queryFields, List<Id> workOrderIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
            query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM WorkOrderLineItem WHERE WorkOrderId IN: workOrderIds AND (Status = \'Completed\' OR (QuantityDelivered__c != null AND QuantityDelivered__c != 0)) AND Product_Type__c != \'ZSER\'';
        System.debug('getWOLIsToMoveFromWOs QUERY: ' + query);
        
        return Database.query(query);
    }

    public static List<WorkOrderLineItem> getCompletedRefillWOLIsFromWOs(List<String> queryFields, List<String> workOrderIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
            query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM WorkOrderLineItem WHERE WorkOrderId IN: workOrderIds AND Product_Family__c = \'SLOXT\' AND QuantityDelivered__c > 0 AND Status = \'Completed\' AND AssetId != null AND Batch_Number__c != null';
        System.debug('getCompletedRefillWOLIsFromWOs QUERY: ' + query);
        
        return Database.query(query);
    }

    public static List<WorkOrderLineItem> getCompletedBaseUnitWOLIsFromAssets(List<String> queryFields, List<String> workOrderIds, List<String> assetIds, List<String> assetProductIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
            query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM WorkOrderLineItem WHERE WorkOrderId IN: workOrderIds AND QuantityDelivered__c = 1 AND Status = \'Completed\' AND AssetId IN: assetIds AND Product2Id IN: assetProductIds AND Batch_Number__c = null';
        System.debug('getCompletedBaseUnitWOLIsFromAssets QUERY: ' + query);
        
        return Database.query(query);
    }

    public static List<WorkOrderLineItem> getCylinderContentWOLIs(List<String> queryFields, List<String> batchNumbers, List<String> equipmentKeys) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
            query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM WorkOrderLineItem WHERE Batch_Number__c IN: batchNumbers AND Status = \'Completed\' AND QuantityDelivered__c > 0 AND ' +
        'Related_Equipment_Key__c IN: equipmentKeys AND Equipment_Key_Tank__c = null';
        System.debug('getCompletedWOLIsFromWOs QUERY: ' + query);
        
        return Database.query(query);
    }

    public static List<WorkOrderLineItem> getContainersFromAssetIds(List<String> queryFields, List<String> assetIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
            query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM WorkOrderLineItem WHERE Batch_Number__c != null AND AssetId IN: assetIds AND Status = \'Completed\' AND QuantityDelivered__c > 0';
        System.debug('getContainersFromAssetIds QUERY: ' + query);
        
        return Database.query(query);
    }

    public static List<WorkOrderLineItem> getRefillWOLIsFromAssetAndWO(List<String> queryFields, List<String> assetIds, List<String> workOrderIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
            query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM WorkOrderLineItem WHERE AssetId IN: assetIds AND WorkOrderId IN: workOrderIds AND Batch_Number__c != null AND Related_Equipment_Key__c != null AND ' +
        'Equipment_Key_Tank__c != null AND Status = \'Completed\' AND QuantityDelivered__c > 0';
        System.debug('getWOLIsFromAssetAndWO QUERY: ' + query);
        
        return Database.query(query);
    }

    public static List<WorkOrderLineItem> getRefillContainers(List<String> queryFields, List<String> batchNumbers, List<String> assetProductIds, List<String> equipmentKeys, 
    List<String> workOrderIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
            query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM WorkOrderLineItem WHERE Batch_Number__c IN: batchNumbers AND AssetId != null AND PricebookEntry.Product2Id IN: assetProductIds AND ' +
        'Asset.Equipment_Key__c IN: equipmentKeys AND WorkOrderId IN: workOrderIds AND Status = \'Completed\' AND QuantityDelivered__c > 0';
        System.debug('getRefillContainers QUERY: ' + query);
        
        return Database.query(query);
    }

    public static List<WorkOrderLineItem> getWOLIsFromHUAndWOId(List<String> queryFields, List<String> HUs, List<String> workOrderIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
            query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM WorkOrderLineItem WHERE WorkOrderId IN: workOrderIds AND HU__c IN: HUs AND Status = \'Completed\' AND QuantityDelivered__c > 0';
        System.debug('getWOLIsFromHUAndWOId QUERY: ' + query);
        
        return Database.query(query);
    }
}