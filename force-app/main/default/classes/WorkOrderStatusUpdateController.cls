public class WorkOrderStatusUpdateController {
    
    @AuraEnabled
    public static String getStatus(Id workOrderId) {
        WorkOrder wo = [SELECT Status FROM WorkOrder WHERE Id =: workOrderId];
        return wo.Status;
    }

    @AuraEnabled
    public static String getReason(Id workOrderId) {
        WorkOrder wo = [SELECT Reason__c FROM WorkOrder WHERE Id =: workOrderId];

        return wo.Reason__c;
    }

    @AuraEnabled
    public static void processGoodsMovement(Id workOrderId){
        List<Id> workOrderIds = new List<Id>{workOrderId};
        System.debug('workOrderIds: ' + workOrderIds);

        GoodsMovement.processGoodsMovement(workOrderIds);
    }
}