global class AutoscheduleActivitiesTherapyBatch implements Database.Batchable<sObject>, Database.Stateful{
    // If startDatetimeWO and/or startDatetimeTask are set, it means I'm scheduling only one ATJ (also accountTreatmentJobId must be set)
    global List<Id> accountTreatmentIds;
    global Map<String, Datetime> startDateMap;
    global Map<Account_Treatment_Job__c, Contract_Treatment_Job_SLA__c> ATJToSLAMap = new Map<Account_Treatment_Job__c, Contract_Treatment_Job_SLA__c>();
    global List<WorkOrder> newWorkOrders = new List<WorkOrder>();

    // Single ATJ scheduling parameters

    global String accountTreatmentJobId;
    global Datetime startDatetimeWO;
    global Datetime startDatetimeTask;

    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id FROM Account_Treatment__c WHERE Id IN: accountTreatmentIds';
        System.debug(query);
        return Database.getQueryLocator(query);
    }

    // In the execute method, this batch will autoschedule the activities for the given AT

    public void execute(Database.BatchableContext bc, List<Account_Treatment__c> accountTreatments) {
        // Should have size = 1 if batch is launched with ( , 1) parameter
        List<Id> batchAccountTreatmentIds = new List<Id>();
        
        // Using this new Id list because accountTreatmentIds contains all the Ids, but if the batch is launched with 1 parameter, only one AT is handled at a time
        for(Account_Treatment__c at : accountTreatments) {
            batchAccountTreatmentIds.add(at.Id);
        }

        // Classic Therapy autoscheduling. Coming from a batch, it will avoid launching ATAAlignmentBatch and WOLICreationBatch
        for(Id accountTreatmentId : batchAccountTreatmentIds) {
            List<WorkOrder> tmpNewWorkOrders = autoscheduleActivities(accountTreatmentId);

            for(WorkOrder wo : tmpNewWorkOrders) {
                newWorkOrders.add(wo);
            }
        }
    }

    // In the finish method, the batches WOLICreationBatch and ATAAlignment batch that couldn't be launched before are launched

    public void finish(Database.BatchableContext bc) {
        List<String> queryFieldsForProducts = new List<String>{'Product__c', 'Quantity__c', 'Customer_Treatment_Alias__c', 'Patient_Treatment_Job__c',
        'Customer_Request_Code__c', 'Storage_Location__c', 'Plant__c', 'Purchase_order_number__c', 'Purchase_order_date__c', 
        'Contract_Treatment_Job_Product__r.Invoice_Splitting_group__c', 'Asset__c', 'Asset__r.SerialNumber'};
        List<String> queryFieldsForPBEntry = new List<String>{'Product2Id', 'Pricebook2Id'};

        Set<Account_Treatment_Job__c> ATJs = ATJToSLAMap.keySet();
        List<Account_Treatment_Job__c> workOrderATJs = new List<Account_Treatment_Job__c>();
        List<Id> workOrderATJsIds = new List<Id>();
        List<Id> pricebookIds = new List<Id>();

        Map<Id, Account_Treatment_Job__c> ATJMap = new Map<Id, Account_Treatment_Job__c>();
        Map<Id, List<Account_Treatment_Job_Product__c>> jobToProductsMap = new Map<Id, List<Account_Treatment_Job_Product__c>>();
        Map<Id, List<PricebookEntry>> pricebookIdToPEMap = new Map<Id, List<PricebookEntry>>();

        for(Account_Treatment_Job__c atj : ATJs) {
            if(atj.Work_Order__c == true) {
                workOrderATJs.add(atj);
            }
        }

        for(Account_Treatment_Job__c atj : workOrderATJs) {
            ATJMap.put(atj.Id, atj);
            workOrderATJsIds.add(atj.Id);
            pricebookIds.add(atj.Contract_Treatment_Job__r.Contract_Framework__r.Price_list_code__c);
        }

        List<Account_Treatment_Job_Product__c> allProducts = AccountTreatmentJobProductDAO.getActiveProductsFromATJs(queryFieldsForProducts, workOrderATJsIds);

        // jobToProductMap links an Account_Treatment_Job__c Id to its Account_Treatment_Job_Products

        if(!allProducts.isEmpty()) {
            for(Account_Treatment_Job_Product__c atjp : allProducts) {
                if(jobToProductsMap.get(atjp.Patient_Treatment_Job__c) == null) {
                    jobToProductsMap.put(atjp.Patient_Treatment_Job__c, new List<Account_Treatment_Job_Product__c>());
                }
                jobToProductsMap.get(atjp.Patient_Treatment_Job__c).add(atjp);
            }
        }

        // Getting all the pricebookEntries --> The pricebookEntry related to each Account_Treatment_Job__c

        List<PricebookEntry> allPricebookEntries = PricebookEntryDAO.getPEFromPricebookIds(queryFieldsForPBEntry, pricebookIds);

        if(!allPricebookEntries.isEmpty()) {
            for(PricebookEntry pe : allPricebookEntries) {
                if(pricebookIdToPEMap.get(pe.Pricebook2Id) == null) {
                    pricebookIdToPEMap.put(pe.Pricebook2Id, new List<PricebookEntry>());
                }
                pricebookIdToPEMap.get(pe.Pricebook2Id).add(pe);
            }
        }

        // Launching WOLICreationBatch

        WOLICreationBatch WOLICreation;

        if(!ATJMap.isEmpty() && !jobToProductsMap.isEmpty() && !pricebookIdToPEMap.isEmpty() && !newWorkOrders.isEmpty()) {
            WOLICreation = new WOLICreationBatch();

            WOLICreation.ATJMap = ATJMap;
            WOLICreation.jobToProductsMap = jobToProductsMap;
            WOLICreation.pricebookIdToPEMap = pricebookIdToPEMap;
            WOLICreation.workOrders = newWorkOrders;

            //Database.executeBatch(WOLICreation, 3);
        }

        // Launching ATAAlignmentBatch

        ATAAlignmentBatch ATABatch = new ATAAlignmentBatch();
        ATABatch.ATIds = accountTreatmentIds;

        if(WOLICreation != null) {
            ATABatch.WOLIBatch = WOLICreation;
        }

        // Launching ServiceTerritory Batch

        ServiceTerritoryUpdateBatch serviceTerritoryBatch = new ServiceTerritoryUpdateBatch();
        serviceTerritoryBatch.ATAAlignmentBatch = ATABatch;
        serviceTerritoryBatch.sendAutoschedulingEndNotification = true;
        serviceTerritoryBatch.targetId = accountTreatmentIds[0];

        Database.executeBatch(serviceTerritoryBatch, 50);

        //Database.executeBatch(ATABatch, 100);
    }

    // I need this method, a copy of ATMainComponentController.autoscheduleProcess, because I need to return the List<newWorkOrders> to launch the WOLICreationBatch on lately

    private List<WorkOrder> autoscheduleActivities(Id accountTreatmentId) {
        List<String> caseQueryFields = new List<String>{'AccountId', 'Account_Treatment__c', 'Account_Treatment_Job__c', 'Origin', 'Contract_Treatment__c', 
        'Patient__c', 'Status', 'Subject', 'Subtype__c', 'Type', 'Treatment__c', 'Autoscheduled__c', 'ContactId', 'OwnerId', 'Start_Date__c'};

        List<Id> ATIdList = new List<Id>();
        List<Id> newCaseIds = new List<Id>();
        Boolean considerOnlyAutoscheduledATJs = true;
        ATIdList.add(accountTreatmentId);

        BusinessHours bh = [SELECT Id, MondayStartTime, MondayEndTime, TuesdayStartTime, TuesdayEndTime, WednesdayStartTime, WednesdayEndTime,
                            ThursdayStartTime, ThursdayEndTime, FridayStartTime, FridayEndTime, SaturdayStartTime, SaturdayEndTime, SundayStartTime, SundayEndTime   
                            FROM BusinessHours WHERE Name = 'NL'];

        AssignmentRule assignmentRule = [SELECT Id FROM AssignmentRule WHERE SobjectType = 'Case' and Active = true LIMIT 1];

        // Creating the DMLOptions for "Assign using active assignment rules" checkbox
        Database.DMLOptions DMLOptions = new Database.DMLOptions();
        DMLOptions.assignmentRuleHeader.assignmentRuleId = assignmentRule.Id;

        if(accountTreatmentJobId != null) {
            considerOnlyAutoscheduledATJs = false;
        }
        
        // This first method checks for all the requirements to create Cases and WO/Tasks, and returns a map of the eligible ATJs and the related SLA

        Map<Account_Treatment_Job__c, Contract_Treatment_Job_SLA__c> tmpATJToSLAMap = ATMainComponentService.checkRequirements(
            accountTreatmentId, 
            considerOnlyAutoscheduledATJs
        );

        for(Account_Treatment_Job__c atj : tmpATJToSLAMap.keySet()) {
            // Selecting all the ATJs, this is an entire AT scheduling
            if(accountTreatmentJobId == null) {
                ATJToSLAMap.put(atj, tmpATJToSLAMap.get(atj));
            }

            // Selecting only the accountTreatmentJobId ATJ to schedule

            else {
                if(atj.Id == accountTreatmentJobId) {
                    ATJToSLAMap.put(atj, tmpATJToSLAMap.get(atj));
                    break;
                }
            }
        }

        // This second method creates a Case for each previously obtained ATJ and schedules the next ones
        List<Case> newCases = ATMainComponentService.createCases(ATJtoSLAMap, DMLOptions, true, null);
        List<Case> queriedNewCases = new List<Case>();

        // Inserting new Cases
        if(!newCases.isEmpty()) {
            insert newCases;

            for(Case c : newCases) {
                newCaseIds.add(c.Id);
            }

            queriedNewCases = CaseDAO.getCasesFromIds(caseQueryFields, newCaseIds);
        }

        List<WorkOrder> tmpNewWorkOrders;
        List<Task> newTasks;

        /**
         * General AT scheduling startDate (to be fixed with SLA's MaxTime to get WO/Task DueDate).
         * If startDateMap is not filled and startDatetimeWO/startDatetimeTask are,
         * I'm only scheduling one ATJ and these dates will be WO/Task DueDate, without applying SLA's MaxTime  
         * */

        Datetime startDate;

        if(startDateMap != null) {
            startDate = startDateMap.get(accountTreatmentId);
        }

        // Therapy

        if(startDate == null && accountTreatmentJobId == null && startDatetimeWO == null && startDatetimeTask == null) {
            // This third method creates a WO for the ATJs with Work_Order__c = true and schedules the next ones. Called with null on startDate = null for Therapy
            tmpNewWorkOrders = ATMainComponentService.createWorkOrders(ATJToSLAMap, queriedNewCases, null, false);

            // This fourth method creates a Task for the ATJs with Task__c = true and schedules the next ones. Calling this with usePrescription = true and closedWO = null
            newTasks = ATMainComponentService.createTasks(ATJToSLAMap, queriedNewCases, bh, true, null, null, null, false, null);
        }

        // Single ATJ scheduling (startDatetimeWO/startDatetimeTask are the first activities' DueDates)

        else if(startDate == null && accountTreatmentJobId != null && (startDatetimeWO != null || startDatetimeTask != null)) {
            // Called with "true" on startDateIsDueDate to let ATMainComponentService.calculateDates ignore SLA's MaxTime
            tmpNewWorkOrders = ATMainComponentService.createWorkOrders(ATJToSLAMap, queriedNewCases, startDatetimeWO, true);
            newTasks = ATMainComponentService.createTasks(ATJToSLAMap, queriedNewCases, bh, false, null, null, startDatetimeTask, true, null);
        }

        // Sales
        
        else {
            // Methods called with startDate if present (Sales AT case)
            tmpNewWorkOrders = ATMainComponentService.createWorkOrders(ATJToSLAMap, queriedNewCases, startDate, false);

            newTasks = ATMainComponentService.createTasks(ATJToSLAMap, queriedNewCases, bh, false, null, null, startDate, false, null);
        }

        if(!newTasks.isEmpty()) {
            insert newTasks;
            update queriedNewCases;
        }

        return tmpNewWorkOrders;
    }

}