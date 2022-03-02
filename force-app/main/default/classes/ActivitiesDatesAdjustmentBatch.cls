global without sharing class ActivitiesDatesAdjustmentBatch implements Database.Batchable<sObject>, Schedulable, Database.Stateful {
    global List<Id> relatedATIds = new List<Id>();
    global List<WorkOrder> newWorkOrders = new List<WorkOrder>();
    global List<String> caseIds;
    Boolean executeATABatch = false;

    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id, Status, ClosedDate, Autoscheduled__c, Account_Treatment_Job__c, Account_Treatment_Job__r.Task__c, ' +
        'Account_Treatment_Job__r.Work_Order__c, Start_Date__c, Account_Treatment_Job__r.Patient_Treatment__c '+
        'FROM Case WHERE Status = \'Closed\' AND (ClosedDate >= TODAY AND ClosedDate <= TOMORROW) ' + 
        'AND Autoscheduled__c = true AND ExcludeFromAdjustment__c = false AND Account_Treatment__r.Status__c != \'D\' AND Account_Treatment__r.Status__c != \'R\''; 

        if(caseIds != null && !caseIds.isEmpty()) {
            query = 'SELECT Id, Status, ClosedDate, Autoscheduled__c, Account_Treatment_Job__c, Account_Treatment_Job__r.Task__c, ' +
            'Account_Treatment_Job__r.Work_Order__c, Start_Date__c, Account_Treatment_Job__r.Patient_Treatment__c '+
            'FROM Case WHERE Status = \'Closed\' AND Id IN: caseIds'; 
        }

        System.debug(query);
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Case> cases) {
        System.debug('Autoscheduled Cases closed today: ' + cases.size());
        
        List<Case> taskCases = new List<Case>();
        List<Case> WOCases = new List<Case>();
        List<Case> taskAndWOCases = new List<Case>();

        for(Case c : cases) {
            relatedATIds.add(c.Account_Treatment_Job__r.Patient_Treatment__c);
            if(c.Account_Treatment_Job__r.Task__c == true && c.Account_Treatment_Job__r.Work_Order__c == false) {
                taskCases.add(c);
            }
            else if(c.Account_Treatment_Job__r.Task__c == false && c.Account_Treatment_Job__r.Work_Order__c == true) {
                WOCases.add(c);
            }
            else if(c.Account_Treatment_Job__r.Task__c == true && c.Account_Treatment_Job__r.Work_Order__c == true) {
                taskAndWOCases.add(c);
            }
        }

        if(!taskCases.isEmpty()) {
            System.debug('TaskCases size: ' + taskCases.size());
            ActivitiesDatesAdjustmentService.adjustDatesTaskCases(taskCases, null);
        }

        if(!WOCases.isEmpty()) {
            System.debug('WOCases size: ' + WOCases.size());
            List<WorkOrder> tmpNewWorkOrders = ActivitiesDatesAdjustmentService.adjustDatesWOCases(WOCases, null);

            if(tmpNewWorkOrders != null) {
                for(WorkOrder wo : tmpNewWorkOrders) {
                    newWorkOrders.add(wo);
                }
            }
        }

        if(!taskAndWOCases.isEmpty()) {
            System.debug('TaskAndWOCases size: ' + taskAndWOCases.size());
            List<WorkOrder> tmpNewWorkOrders = ActivitiesDatesAdjustmentService.adjustDatesTaskAndWOCases(taskAndWOCases, null);

            if(tmpNewWorkOrders != null) {
                for(WorkOrder wo : tmpNewWorkOrders) {
                    newWorkOrders.add(wo);
                }
            }
        }

        if(!WOCases.isEmpty() || !taskAndWOCases.isEmpty()) {
            executeATABatch = true;
        }

        for(Case c : cases) {
            c.ExcludeFromAdjustment__c = true;
        }

        List<Database.SaveResult> results = Database.update(cases, false);
    }

    public void finish(Database.BatchableContext bc) {
        List<String> ATQueryFields = new List<String>{'RecordType.DeveloperName'};

        List<Account_Treatment__c> accountTreatments = AccountTreatmentDAO.getAccountTreatmentsFromIds(ATQueryFields, relatedATIds);
        List<Id> ATIdsForATABatch = new List<Id>();

        for(Account_Treatment__c at : accountTreatments) {
            //if(at.RecordType.DeveloperName != 'AccountTreatment_Maintenance') {
                ATIdsForATABatch.add(at.Id);
            //}
        }

        /** Executing ATAAlignmentBatch with executeServiceTerritoryBatchAnyway = true because here it's possible that no WO's address gets updated. 
         * In this case, the ServiceTerritoryUpdateBatch needs to run anyway, because it has to assign the ST to the newly created WOs.
         * */ 

        ATAAlignmentBatch ATABatch;
        
        if(ATIdsForATABatch != null && executeATABatch == true) {
            ATABatch = new ATAAlignmentBatch();
            ATABatch.ATIds = ATIdsForATABatch;
            //ATABatch.executeServiceTerritoryBatchAnyway = true;

            //Database.executeBatch(ATABatch, 100);
        }

        // Launching ServiceTerritory Batch

        ServiceTerritoryUpdateBatch serviceTerritoryBatch = new ServiceTerritoryUpdateBatch();
        serviceTerritoryBatch.ATAAlignmentBatch = ATABatch;
        
        if(!newWorkOrders.isEmpty()) {
            WOLICreationBatch woliBatch = new WOLICreationBatch();
            woliBatch.workOrders = newWorkOrders;

            if(!Test.isRunningTest()) {
                serviceTerritoryBatch.WOLIBatch = woliBatch;
            }
        }

        Database.executeBatch(serviceTerritoryBatch, 50);

        // Launching WOLICreationBatch for new WOs

        /* if(!newWorkOrders.isEmpty()) {
            WOLICreationBatch woliBatch = new WOLICreationBatch();
            woliBatch.workOrders = newWorkOrders;

            if(!Test.isRunningTest()) {
                Database.executeBatch(woliBatch, 3);
            }
        } */
        
        system.debug('DONE'); //TODO
    }

    public static void Execute(SchedulableContext ctx) {
        Database.executeBatch(new ActivitiesDatesAdjustmentBatch(), 100);
    }

    public static void scheduleDatesAdjustment(String jobName) {
        /*
        String sch0 = '0 00 * * * ?';
        String sch1 = '0 30 * * * ?';
        System.schedule(jobName + ' hh:00', sch0, new ActivitiesDatesAdjustmentBatch());
        System.schedule(jobName + ' hh:30', sch1, new ActivitiesDatesAdjustmentBatch());
        */
    }

}