global class BatchPropagateFrequency_WO implements Database.Batchable<sObject>, Database.Stateful {

    global List<String> accTreatmentJobIds = new List<String>();
    global List<Account_Treatment_Job__c> accTreatmentJobs = new List<Account_Treatment_Job__c>();
    global List<String> WOStatusListToExclude = new List<String>{'In Progress', 'Completed', 'Cannot Complete', 'Canceled', 'Assigned'};
    global List<String> taskStatusListToExclude = new List<String>{'Completed', 'Canceled'};
    global List<WorkOrder> workOrdersToCreate = new List<WorkOrder>();
    global List<Id> pricebookIds = new List<Id>();

    // Parameters for WOLICreationBatch
    global Map<Id, List<Account_Treatment_Job_Product__c>> jobToProductsMap = new Map<Id, List<Account_Treatment_Job_Product__c>>();
    global Map<Id, Account_Treatment_Job__c> ATJMap = new Map<Id, Account_Treatment_Job__c>();
    global Map<Id, List<PricebookEntry>> pricebookIdToPEMap = new Map<Id, List<PricebookEntry>>();

    global Database.QueryLocator start(Database.BatchableContext bc) {

        for (Account_Treatment_Job__c atj : accTreatmentJobs){
            accTreatmentJobIds.add(atj.Id);
        }
        System.debug('accTreatmentJobIds: ' + accTreatmentJobIds);
        String statusValue = 'R';

        String query = 'SELECT Id, Patient_Treatment__r.RecordType.DeveloperName, Frequency_Unit_of_measure__c, Frequency__c, Work_Order__c, Task__c,'
            + ' Contract_Treatment_Job__r.Contract_Framework__r.Price_list_code__c, Patient_Treatment__r.Account__c, Patient_Treatment__r.Contract_Treatment__c, '
            + ' Name, Case_Subtype__c, Case_Type__c, Patient_Treatment__r.Treatment_Type__c, Patient_Treatment__r.Account__r.PersonContactId, '
            + ' Patient_Treatment__r.Account__r.IsPersonAccount, Frequency_Type__c, Scheduling_Time_Frame__c '
            + ' FROM Account_Treatment_Job__c '
            + ' WHERE Id IN :accTreatmentJobIds';
		return Database.getQueryLocator(query);
	}

	public void execute(Database.BatchableContext bc,List<Account_Treatment_Job__c> accountTreatmentJobs) {
        System.debug('----- EXECUTING BatchPropagateFrequency_WO -----');

        List<Id> ATJIds = new List<Id>();

        for (Account_Treatment_Job__c atj : accountTreatmentJobs){
            ATJIds.add(atj.Id);
        }

        List<String> queryFieldsForCase = new List<String>{'Start_Date__c', 'Account_Treatment_Job__c'};

        List<String> queryFieldsForProducts = new List<String>{'Product__c', 'Quantity__c', 'Customer_Treatment_Alias__c', 'Patient_Treatment_Job__c',
        'Customer_Request_Code__c', 'Storage_Location__c', 'Plant__c', 'Purchase_order_number__c', 'Purchase_order_date__c', 
        'Contract_Treatment_Job_Product__r.Invoice_Splitting_group__c', 'Asset__c', 'Asset__r.SerialNumber'};

        List<String> queryFieldsForPBEntry = new List<String>{'Product2Id', 'Pricebook2Id'};


        // Getting the Map linking each ATJ to its first Case (this will be the only one to keep)

        Map<Id, Case> firstCaseMap = new Map<Id, Case>();
        firstCaseMap = CaseDAO.getATJToFirstCaseMap(queryFieldsForCase, ATJIds);

        List<Case> caseList = new List<Case>();
        Set<Id> atjList = new Set<Id>();
        Set<Id> caseIdList = new Set<Id>();

        caseList = firstCaseMap.values();
        atjList = firstCaseMap.keySet();

        for (Case tmp : caseList){
            caseIdList.add(tmp.Id);
        }

        List<WorkOrder> woToRemove = new List<WorkOrder>();
        List<Task> taskToRemove = new List<Task>();
        List<Case> caseToRemove = new List<Case>();
        List<WorkOrder> firstWorkOrders = new List<WorkOrder>();
        List<Task> firstTasks = new List<Task>();

        Map<Id, List<Task>> caseIdToTasksMap = new Map<Id, List<Task>>();
        Map<Id, List<WorkOrder>> caseIdToWOsMap = new Map<Id, List<WorkOrder>>();
        Map<Id, List<Case>> ATJIdToCasesMap = new map<Id, List<Case>>();

        // Getting all the WOs and Tasks related to the first Cases (these will be the only ones to keep)

        firstWorkOrders = [SELECT Id, StartDate, EndDate, Due_Date__c, CaseId, AccountId, Account_Sold_To__c, Account_Sales_Organization__c, Account_Treatment__c, 
                           Contract_Framework__c, Contract_Treatment__c, Contract_Treatment_Job__c, Customer_Purchase_Order_Date__c, Customer_Purchase_Order_Number__c,
                           Delivery_Type__c, Document_Type__c, OwnerId, Pricebook2Id, Status, Subject, WorkTypeId, Related_SLA__c, LocationId, City, Country, 
                           CountryCode, Latitude, Longitude, PostalCode, State, StateCode, Street, Account_Treatment_Job__c, Attachment_Addendum_Type__c,
                           Billing_Via__c, Billing_Reference__c, Invoice_splitting_criterion__c, InvoiceLayout__c, Job_InvoiceSplittingGroup__c, 
                           Treatment_Customer_Purchase_Order_Date__c, Treatment_Customer_Purchase_Order_Number__c, Treatment_Customer_Request_Code__c, 
                           Treatment_InvoiceSplittingGroup__c, AssetId, Label__c, ContactId, SalesOrganization__c, Division__c, Distribution_Channel__c, 
                           Sales_Group__c, Sales_Office__c, Job_Product_Code__c, Case.Status 
                           FROM WorkOrder WHERE CaseId IN: caseIdList AND Autoscheduled__c = true];

        firstTasks = [SELECT Id, Start_Date__c, WhatId, Type, Due_Date__c, ActivityDate  
                      FROM Task WHERE WhatId IN: caseIdList AND Autoscheduled__c = true];

        System.debug('firstWorkOrders: ' + firstWorkOrders);
        System.debug('firstTasks: ' + firstTasks);

        for(WorkOrder wo : firstWorkOrders) {
            if(caseIdToWOsMap.get(wo.CaseId) == null) {
                caseIdToWOsMap.put(wo.CaseId, new List<WorkOrder>());
            }
            caseIdToWOsMap.get(wo.CaseId).add(wo);
        }

        for(Task t : firstTasks) {
            if(caseIdToTasksMap.get(t.WhatId) == null) {
                caseIdToTasksMap.put(t.WhatId, new List<Task>());
            }
            caseIdToTasksMap.get(t.WhatId).add(t);
        } 


        // Getting all the WOs, Tasks and Cases to remove: all except the first ones (*)

        woToRemove = [SELECT id, StartDate, Account_Treatment_Job__c, Status, To_Be_Removed__c, Reason__c, CaseId
                      FROM WorkOrder WHERE Account_Treatment_Job__c IN :atjList AND To_Be_Removed__c = false
                      AND Status NOT IN :WOStatusListToExclude AND CaseId NOT IN : caseIdList AND Autoscheduled__c = true];
        System.debug('WOsToRemove size: ' + woToRemove.size());

        List<Id> WOToRemoveCases = new List<Id>();

        if(woToRemove != null) {
            for(WorkOrder wo : woToRemove) {
                WOToRemoveCases.add(wo.CaseId);
            }
        }

        // If a Case related to a WO to remove has an open/assigned etc. Task, it has to be removed from the list of Cases to remove

        List<Task> tasksNotToRemove = [SELECT Id, WhatId FROM Task WHERE WhatId IN: WOToRemoveCases AND Status IN: taskStatusListToExclude];

        if(tasksNotToRemove != null) {
            if(!tasksNotToRemove.isEmpty()) {
                for(Task t : tasksNotToRemove) {
                    Integer index = WOToRemoveCases.indexOf(t.WhatId);

                    if(index != null && index != -1) {
                        WOToRemoveCases.remove(index);
                    }
                }
            }
        }
                      
        taskToRemove = [SELECT id, Status, WhatId, To_Be_Removed__c FROM Task WHERE Account_Treatment_Job__c IN: atjList 
                        AND WhatId NOT IN : caseIdList AND Status NOT IN: taskStatusListToExclude
                        AND Autoscheduled__c = true];
        System.debug('tasksToRemove size: ' + taskToRemove.size());

        List<Id> taskToRemoveCases = new List<Id>();

        if(taskToRemove != null) {
            for(Task t : taskToRemove) {
                taskToRemoveCases.add(t.WhatId);
            }
        }

        // If a Case related to a Task to remove has an open/assigned etc. WO, it has to be removed from the list of Cases to remove
        
        List<WorkOrder> WOsNotToRemove = [SELECT Id, CaseId FROM WorkOrder WHERE CaseId IN: taskToRemoveCases AND Status IN: WOStatusListToExclude];

        if(WOsNotToRemove != null) {
            if(!WOsNotToRemove.isEmpty()) {
                for(WorkOrder wo : WOsNotToRemove) {
                    Integer index = taskToRemoveCases.indexOf(wo.CaseId);

                    if(index != null && index != -1) {
                        taskToRemoveCases.remove(index);
                    }
                }
            }
        }

        // Getting all the Cases to remove

        List<Id> casesToRemoveIds = new List<Id>();

        for(Id caseId : WOToRemoveCases) {
            if(!casesToRemoveIds.contains(caseId)) {
                casesToRemoveIds.add(caseId);
            }
        }

        for(Id caseId : taskToRemoveCases) {
            if(!casesToRemoveIds.contains(caseId)) {
                casesToRemoveIds.add(caseId);
            }
        }

        if(!casesToRemoveIds.isEmpty()) {
            caseToRemove = [SELECT id, Status, To_Be_Removed__c FROM Case WHERE Account_Treatment_Job__c IN :atjList AND Id IN : casesToRemoveIds AND Autoscheduled__c = true];
            System.debug('casesToRemove size: ' + caseToRemove.size());
        }

        // Removing Cases

        for (Case tmp : caseToRemove){
            tmp.Status = 'Canceled';
            tmp.To_Be_Removed__c = true;
        }

        // Removing Tasks

        for(Task toRemove : taskToRemove) {
            toRemove.Status = 'Canceled';
            toRemove.To_Be_Removed__c = true;
        }

        // Removing WOs

        List<String> removedWOIds = new List<String>();

        for(WorkOrder toRemove : woToRemove) {
            toRemove.Status = 'Canceled';
            toRemove.To_Be_Removed__c = true;
            toRemove.Reason__c = 'Rescheduled';
            removedWOIds.add(toRemove.Id);
        }

        if(!taskToRemove.isEmpty()) {
            update taskToRemove;

            System.debug('Removed Tasks size: ' + taskToRemove.size());
        }

        if(!woToRemove.isEmpty()) {
            update woToRemove;

            System.debug('Removed WOs size: ' + woToRemove.size());
        }

        List<WorkOrderLineItem> woliToRemove = [SELECT Id, Status, To_Be_Removed__c FROM WorkOrderLineItem WHERE WorkOrderId IN: removedWOIds];

        // Removing WOLIs

        for (WorkOrderLineItem woli : woliToRemove){
            woli.Status = 'Canceled';
            woli.To_Be_Removed__c = true;
        }

        if (!woliToRemove.isEmpty()){
            update woliToRemove;
        }

        if(!caseToRemove.isEmpty()) {
            update caseToRemove;

            System.debug('Removed Cases size: ' + caseToRemove.size());
        }

        AssignmentRule assignmentRule = [SELECT Id FROM AssignmentRule WHERE SobjectType = 'Case' and Active = true LIMIT 1];

        Map<Account_Treatment_Job__c, Contract_Treatment_Job_SLA__c> accTreatmentSLAMap = ATMainComponentService.getATJtoSLAMap(accountTreatmentJobs);

        // Creating the DMLOptions for "Assign using active assignment rules" checkbox

        Database.DMLOptions DMLOptions = new Database.DMLOptions();
        DMLOptions.assignmentRuleHeader.assignmentRuleId = assignmentRule.Id;

        // Creating Cases

        List<Case> newCases = ATMainComponentService.createCases(accTreatmentSLAMap, DMLOptions, true, null);

        System.debug('newCases: ' + newCases);

        // Removing the first created Case for each ATJ, because in this scenario it has already been created (it's the one that is not deleted) (*)

        if(newCases != null) {
            System.debug('newCases size: ' + newCases.size());
            
            for(Case c : newCases) {
                if(ATJIdToCasesMap.get(c.Account_Treatment_Job__c) == null) {
                    ATJIdToCasesMap.put(c.Account_Treatment_Job__c, new List<Case>());
                }
                ATJIdToCasesMap.get(c.Account_Treatment_Job__c).add(c);
            }

            for(Id ATJId : ATJIdToCasesMap.keySet()) {
                List<Case> relatedCases = ATJIdToCasesMap.get(ATJId);

                Integer index = newCases.indexOf(relatedCases[0]);

                if(index != -1) {
                    newCases.remove(index);
                    ATJIdToCasesMap.get(ATJId).remove(0);
                }
            }

            System.debug('newCases size after removing the first one: ' + newCases.size());
            insert newCases;
        }

        // Creating WorkOrders and Tasks

        List<Task> tasksToCreate = new List<Task>();
        List<WorkOrder> workOrdersToCreateTmp = new List<WorkOrder>();
        List<Id> workOrderATJIds = new List<Id>();
        List<Id> tmpPricebookIds = new List<Id>();

        BusinessHours bh = [SELECT Id, MondayStartTime, MondayEndTime, TuesdayStartTime, TuesdayEndTime, WednesdayStartTime, WednesdayEndTime,
        ThursdayStartTime, ThursdayEndTime, FridayStartTime, FridayEndTime, SaturdayStartTime, SaturdayEndTime, SundayStartTime, SundayEndTime  
        FROM BusinessHours WHERE Name = 'NL'];

        for(Account_Treatment_Job__c atj : accountTreatmentJobs){
            System.debug('Scheduling activities for ATJ: ' + atj.Id);

            if(atj.Frequency__c != null) {
                Case relatedFirstCase = firstCaseMap.get(atj.Id);
                List<Case> relatedCases = ATJIdToCasesMap.get(atj.Id);

                System.debug('ATJ s frequency not null');
                System.debug('relatedFirstCase: ' + relatedFirstCase);
                System.debug('relatedCases size: ' + relatedCases.size());

                if(relatedFirstCase != null && relatedCases != null) {

                    // WorkOrder Autoscheduling

                    if(atj.Work_Order__c == true) {
            
                        // Parameters required for WOLICreationBatch

                        Id relatedPricebookId = atj.Contract_Treatment_Job__r.Contract_Framework__r.Price_list_code__c;

                        if(relatedPricebookId != null && !pricebookIds.contains(relatedPricebookId)) {
                            pricebookIds.add(relatedPricebookId);
                            tmpPricebookIds.add(relatedPricebookId);
                        }

                        ATJMap.put(atj.Id, atj);
                        workOrderATJIds.add(atj.Id);

                        List<WorkOrder> WOsRelatedToFirstCase= caseIdToWOsMap.get(relatedFirstCase.Id);
                        System.debug('WOsRelatedToFirstCase: ' + WOsRelatedToFirstCase);

                        if(WOsRelatedToFirstCase != null) {
                            // There is only one WorkOrder related to a Case marked as Autoscheduled

                            WorkOrder startingWorkOrder = WOsRelatedToFirstCase[0];
                            System.debug('startingWorkOrder: ' + startingWorkOrder);

                            Contract_Treatment_Job_SLA__c relatedSLA = accTreatmentSLAMap.get(atj);
                            System.debug('relatedSLA: ' + relatedSLA);
                    
                            if(relatedSLA != null && startingWorkOrder != null) {

                                // Day Autoscheduling

                                if(atj.Frequency_Unit_of_measure__c == 'Day') {
                                    List<WorkOrder> newWorkOrders = ATMainComponentService.autoscheduleWorkOrders(atj, startingWorkOrder, relatedSLA, 365, relatedCases, bh, false);
                                    for(WorkOrder wo : newWorkOrders) {
                                        wo.Status = 'New';
                                        workOrdersToCreateTmp.add(wo);
                                    }
                                }
                                // Week Autoscheduling

                                else if(atj.Frequency_Unit_of_measure__c == 'Week') {
                                    List<WorkOrder> newWorkOrders = ATMainComponentService.autoscheduleWorkOrders(atj, startingWorkOrder, relatedSLA, 52, relatedCases, bh, false);
                                    for(WorkOrder wo : newWorkOrders) {
                                        wo.Status = 'New';
                                        workOrdersToCreateTmp.add(wo);
                                    }
                                }
                                // Month Autoscheduling

                                else if(atj.Frequency_Unit_of_measure__c == 'Month') {
                                    List<WorkOrder> newWorkOrders = ATMainComponentService.autoscheduleWorkOrders(atj, startingWorkOrder, relatedSLA, 12, relatedCases, bh, false);
                                    for(WorkOrder wo : newWorkOrders) {
                                        wo.Status = 'New';
                                        workOrdersToCreateTmp.add(wo);
                                    }
                                }
                                // Year Autoscheduling

                                else if(atj.Frequency_Unit_of_measure__c == 'Year') {
                                    List<WorkOrder> newWorkOrders = ATMainComponentService.autoscheduleWorkOrders(atj, startingWorkOrder, relatedSLA, 1, relatedCases, bh, false);
                                    for(WorkOrder wo : newWorkOrders) {
                                        wo.Status = 'New';
                                        workOrdersToCreateTmp.add(wo);
                                    }
                                }
                            }
                        }
                    }

                    // Task Autoscheduling

                    if(atj.Task__c == true) {
                        List<Task> tasksRelatedToFirstCase = caseIdToTasksMap.get(relatedFirstCase.Id);
                        System.debug('tasksRelatedToFirstCase: ' + tasksRelatedToFirstCase);

                        if(tasksRelatedToFirstCase != null) {
                            // There is only one WorkOrder related to a Case marked as Autoscheduled

                            Task startingTask = tasksRelatedToFirstCase[0];
                            System.debug('startingTask: ' + startingTask);

                            Contract_Treatment_Job_SLA__c relatedSLA = accTreatmentSLAMap.get(atj);
                            System.debug('relatedSLA: ' + relatedSLA);

                            if(relatedSLA != null && startingTask != null) {

                                // Day Autoscheduling

                                if(atj.Frequency_Unit_of_measure__c == 'Day') {
                                    List<Task> newTasks = ATMainComponentService.autoscheduleTasks(atj, startingTask, null, relatedSLA, 365, relatedCases, bh, false);

                                    for(Task t : newTasks) {
                                        tasksToCreate.add(t);
                                    }
                                }

                                // Week Autoscheduling 

                                else if(atj.Frequency_Unit_of_measure__c == 'Week') {
                                    List<Task> newTasks = ATMainComponentService.autoscheduleTasks(atj, startingTask, null, relatedSLA, 52, relatedCases, bh, false);

                                    for(Task t : newTasks) {
                                        tasksToCreate.add(t);
                                    }
                                }

                                // Month Autoscheduling

                                else if(atj.Frequency_Unit_of_measure__c == 'Month') {
                                    List<Task> newTasks = ATMainComponentService.autoscheduleTasks(atj, startingTask, null, relatedSLA, 12, relatedCases, bh, false);

                                    for(Task t : newTasks) {
                                        tasksToCreate.add(t);
                                    }
                                }

                                // Year Autoscheduling

                                else if(atj.Frequency_Unit_of_measure__c == 'Year') {
                                    List<Task> newTasks = ATMainComponentService.autoscheduleTasks(atj, startingTask, null, relatedSLA, 1, relatedCases, bh, false);

                                    for(Task t : newTasks) {
                                        tasksToCreate.add(t);
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        if(!tmpPricebookIds.isEmpty()) {
            // Getting all the pricebookEntries --> The pricebookEntry related to each Account_Treatment_Job__c

            List<PricebookEntry> allPricebookEntries = PricebookEntryDAO.getPEFromPricebookIds(queryFieldsForPBEntry, tmpPricebookIds);

            if(!allPricebookEntries.isEmpty()) {
                for(PricebookEntry pe : allPricebookEntries) {
                    if(pricebookIdToPEMap.get(pe.Pricebook2Id) == null) {
                        pricebookIdToPEMap.put(pe.Pricebook2Id, new List<PricebookEntry>());
                    }
                    pricebookIdToPEMap.get(pe.Pricebook2Id).add(pe);
                }
            }
        }

        List<Account_Treatment_Job_Product__c> allProducts = AccountTreatmentJobProductDAO.getActiveProductsFromATJs(queryFieldsForProducts, workOrderATJIds);

        // jobToProductMap links an Account_Treatment_Job__c Id to its Account_Treatment_Job_Products

        if(!allProducts.isEmpty()) {
            for(Account_Treatment_Job_Product__c atjp : allProducts) {
                if(jobToProductsMap.get(atjp.Patient_Treatment_Job__c) == null) {
                    jobToProductsMap.put(atjp.Patient_Treatment_Job__c, new List<Account_Treatment_Job_Product__c>());
                }
                jobToProductsMap.get(atjp.Patient_Treatment_Job__c).add(atjp);
            }
        }

        System.debug('workOrdersToCreateTmp size: ' + workOrdersToCreateTmp.size());
        System.debug('tasksToCreate size: ' + tasksToCreate.size());

        if(!workOrdersToCreateTmp.isEmpty()) {
            insert workOrdersToCreateTmp;
            update newCases;

            for(WorkOrder wo : workOrdersToCreateTmp) {
                workOrdersToCreate.add(wo);
            }
        }

        if(!tasksToCreate.isEmpty()) {
            insert tasksToCreate;
            update newCases;
        }
    }

	public void finish(Database.BatchableContext bc) {
        // Launching WOLICreationBatch

        if(!ATJMap.isEmpty() && !jobToProductsMap.isEmpty() && !pricebookIdToPEMap.isEmpty() && !workOrdersToCreate.isEmpty()) {
            WOLICreationBatch WOLICreation = new WOLICreationBatch();

            WOLICreation.ATJMap = ATJMap;
            WOLICreation.jobToProductsMap = jobToProductsMap;
            WOLICreation.pricebookIdToPEMap = pricebookIdToPEMap;
            WOLICreation.workOrders = workOrdersToCreate;

            Database.executeBatch(WOLICreation, 3);
        }
    }

}