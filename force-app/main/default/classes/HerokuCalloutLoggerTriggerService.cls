public class HerokuCalloutLoggerTriggerService {
    
    public static List<Callout_Logger__c> createCalloutLoggers(List<Heroku_Callout_Logger__c> herokuCLs) {
        List<Callout_Logger__c> newCalloutLoggers = new List<Callout_Logger__c>();

        Map<String, Callout_Logger__c> calloutLoggerMap = new Map<String, Callout_Logger__c>();

        for(Heroku_Callout_Logger__c hcl : herokuCLs) {
            Callout_Logger__c newCalloutLogger = new Callout_Logger__c();

            newCalloutLogger.Heroku_Session_Id__c = hcl.Session_Id__c;
            newCalloutLogger.Error_Description__c = hcl.Message__c;
            newCalloutLogger.Service__c = hcl.Service__c;
            newCalloutLogger.OriginSystem__c = 'HEROKU';
            newCalloutLogger.TargetSystem__c = 'SAP4HANA';
            newCalloutLogger.Timestamp__c = Datetime.now();
            
            if(hcl.Service__c == 'HEROKU_SAP4HANA__REBATE_DATA') {
                newCalloutLogger.RecordId__c = hcl.rebate_external_id__c;
                newCalloutLogger.Object__c = 'Rebate__c';
            }
            else if(hcl.Service__c == 'HEROKU_SAP4HANA__BILLING_DATA') {
                newCalloutLogger.RecordId__c = hcl.orderexternalid__c;
                newCalloutLogger.Object__c = 'EndOfMonthHeader__c';
            }
            else {
                newCalloutLogger.RecordId__c = hcl.orderexternalid__c;
                newCalloutLogger.Object__c = 'WorkOrder';
            }

            if(hcl.Type__c == 'E' || hcl.Type__c == 'A') {
                newCalloutLogger.ErrorType__c = hcl.Type__c;
                newCalloutLogger.Status__c = 'FAIL';
            }
            else if(hcl.Type__c == 'W' || hcl.Type__c == 'I') {
                newCalloutLogger.ErrorType__c = hcl.Type__c;
                newCalloutLogger.Status__c = 'WARN';
            }
            else if(hcl.Type__c == 'S') {
                newCalloutLogger.ErrorType__c = hcl.Type__c;
                newCalloutLogger.Status__c = 'SUCCESS';
            }

            newCalloutLoggers.add(newCalloutLogger);
            calloutLoggerMap.put(hcl.Log_External_Id__c, newCalloutLogger);
        }

        if(!newCalloutLoggers.isEmpty()) {
            List<Database.SaveResult> results = Database.insert(newCalloutLoggers);

            if(!calloutLoggerMap.isEmpty()) {
                for(Heroku_Callout_Logger__c hcl : herokuCLs) {
                    Callout_Logger__c relatedCalloutLogger = calloutLoggerMap.get(hcl.Log_External_Id__c);

                    if(relatedCalloutLogger != null) {
                        hcl.Callout_Logger__c = relatedCalloutLogger.Id;
                    }
                }
            }
        }

        return newCalloutLoggers;
    }

    public static void deleteRelatedCalloutLoggers(List<Heroku_Callout_Logger__c> herokuCLs) {
        List<String> calloutLoggerQueryFields = new List<String>{'Id'};

        List<Id> relatedCalloutLoggersIds = new List<Id>();
        List<Callout_Logger__c> relatedCalloutLoggers = new List<Callout_Logger__c>();

        for(Heroku_Callout_Logger__c hcl : herokuCLs) {
            relatedCalloutLoggersIds.add(hcl.Callout_Logger__c);
        }

        if(!relatedCalloutLoggersIds.isEmpty()) {
            relatedCalloutLoggers = CalloutLoggerDAO.getCalloutLoggersFromIds(calloutLoggerQueryFields, relatedCalloutLoggersIds);

            if(!relatedCalloutLoggers.isEmpty()) {
                List<Database.DeleteResult> results = Database.delete(relatedCalloutLoggers);
            }
        }
    }

    public static List<WorkOrder> updateRelatedWOs(List<Heroku_Callout_Logger__c> herokuCLs) {
        List<String> workOrderQueryFields = new List<String>{'OrderExternalId__c', 'IsSyncSAP__c'};

        List<String> relatedWorkOrderExtIds = new List<String>();
        List<WorkOrder> relatedWorkOrders = new List<WorkOrder>();
        List<WorkOrder> workOrdersToUpdate = new List<WorkOrder>();

        Map<String, Heroku_Callout_Logger__c> WOExtIdToHCLMap = new Map<String, Heroku_Callout_Logger__c>();

        for(Heroku_Callout_Logger__c hcl : herokuCLs) {

            if(hcl.orderexternalid__c != null && hcl.rebate_external_id__c == null) {
                relatedWorkOrderExtIds.add(hcl.orderexternalid__c);
                WOExtIdToHCLMap.put(hcl.orderexternalid__c, hcl);
            }

            else if(hcl.orderexternalid__c == null && hcl.rebate_external_id__c != null) {
                relatedWorkOrderExtIds.add(hcl.rebate_external_id__c);
                WOExtIdToHCLMap.put(hcl.rebate_external_id__c, hcl);
            }
            
        }

        if(!relatedWorkOrderExtIds.isEmpty() && !WOExtIdToHCLMap.isEmpty()) {
            relatedWorkOrders = WorkOrderDAO.getWorkOrdersFromExternalIds(workOrderQueryFields, relatedWorkOrderExtIds);

            for(WorkOrder wo : relatedWorkOrders) {
                Heroku_Callout_Logger__c relatedHCL = WOExtIdToHCLMap.get(wo.OrderExternalId__c);

                if(relatedHCL != null) {
                    if(relatedHCL.Type__c == 'S' && wo.IsSyncSAP__c != 'Success') {
                        wo.IsSyncSAP__c = 'Success';

                        workOrdersToUpdate.add(wo);
                    }
                    else if(relatedHCL.Type__c == 'P' && wo.IsSyncSAP__c != 'Pending') {
                        wo.IsSyncSAP__c = 'Pending';

                        workOrdersToUpdate.add(wo);
                    }
                    else if((relatedHCL.Type__c == 'E' || relatedHCL.Type__c == 'A') && wo.IsSyncSAP__c != 'Error') {
                        wo.IsSyncSAP__c = 'Error';

                        workOrdersToUpdate.add(wo);
                    }
                }
            }
        }

        return workOrdersToUpdate;
    }
}