public class WorkOrderSapAlignmentBatch implements Database.Batchable<sObject>,Schedulable {

    public  Database.QueryLocator start(Database.BatchableContext bc){
        String status = 'Error';
        String query = 'SELECT IsSyncSAP__c FROM WorkOrder WHERE IsSyncSAP__c =: status';
		System.debug(query);
		return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<WorkOrder> workorders){
        /* List<Id> workorderids = new List<Id>();
        List<Id> woliIds = new List<Id>();
        for (WorkOrder wo : workorders) {
            workorderids.add(wo.Id);
        }
        List<String> queryfields = new List<String>{'Id','WorkOrderId'};
        List<WorkOrderLineItem> wolis = WorkOrderLineItemDAO.getWOLIsFromWOs(queryfields,workorderids);
     
        if (!workorders.isEmpty()) {
            List<Database.SaveResult> updateResultsofwo = Database.update(workorders);
        }
        
        if (!wolis.isEmpty()) {
            List<Database.SaveResult> updateResultsofwoli = Database.update(wolis);
        } */
        List<String> WOLIQueryFields = new List<String>();
        List<String> workOrderIds = new List<String>();
        List<WorkOrderLineItem> relatedWOLIs = new List<WorkOrderLineItem>();

        SObjectType WOLIType = Schema.getGlobalDescribe().get('WorkOrderLineItem');
		Map<String,Schema.SObjectField> WOLIFieldsMap = WOLIType.getDescribe().fields.getMap();

		for(String key : WOLIFieldsMap.keySet()) {
            if(WOLIFieldsMap.get(key).getDescribe().isAccessible()) {
			    WOLIQueryFields.add(String.valueOf(WOLIFieldsMap.get(key)));
            }
		}

        for(WorkOrder wo : workorders) {
            workOrderIds.add(wo.Id);
            wo.IsSyncSAP__c = 'Pending';
        }

        List<Database.SaveResult> results = Database.update(workOrders, false);

        relatedWOLIs = WorkOrderLineItemDAO.getWOLIsFromWOs(WOLIQueryFields, workOrderIds);

        WorkOrderService.updateOrderHK(workOrderIds, null, false, false);

        if(!relatedWOLIs.isEmpty()) {
            WOLITriggerService.updateOrderLineItemHK(relatedWOLIs, false, false);
        }
    }

    public void finish(Database.BatchableContext bc){   
        system.debug('DONE'); 
    }

    public static void Execute(SchedulableContext ctx){
        Database.executeBatch(new WorkOrderSapAlignmentBatch());
    }
}