global class DependentActivitiesScheduling_Task implements Database.Batchable<sObject>, Database.Stateful{
    global List<String> completedTaskIds;

    // These variables will be overwritten every batch chunk, but it's ok since this batch will run only on one closed Task at a time (completedTaskIds will have size 1)

    global Map<Id, Account_Treatment_Job__c> ATJMap = new Map<Id, Account_Treatment_Job__c>();
    global Map<Id, List<Account_Treatment_Job_Product__c>> jobToProductsMap = new Map<Id, List<Account_Treatment_Job_Product__c>>();
    global Map<Id, List<PricebookEntry>> pricebookIdToPEMap = new Map<Id, List<PricebookEntry>>();
    global List<WorkOrder> newWorkOrders = new List<WorkOrder>();
    global List<String> accountTreatmentIds = new List<String>();

    public Database.QueryLocator start(Database.BatchableContext bc) {
        List<String> queryFields = new List<String>{'WhatId', 'Account_Treatment_Job__c', 'CompletedDateTime', 'Account_Treatment_Job__r.Patient_Treatment__c'};

        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
            query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Task WHERE Id IN: completedTaskIds';

        System.debug(query);
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Task> completedTasks) {
        List<String> taskQueryFields = new List<String>{'WhatId', 'Account_Treatment_Job__c', 'CompletedDateTime', 'Account_Treatment_Job__r.Patient_Treatment__c'};

        List<String> workOrderQueryFields = new List<String>{'CaseId'};

        List<String> ATJQueryFields = new List<String>{'Scheduling_Rule__c', 'Work_Order__c', 'Task__c', 'Contract_Treatment_Job__c', 'Patient_Treatment__r.Account__c',
		'Patient_Treatment__c', 'Patient_Treatment__r.Contract_Treatment__c', 'Name', 'Case_Subtype__c', 'Case_Type__c', 'Patient_Treatment__r.Treatment_Type__c', 
		'Contract_Treatment_Job__r.Contract_Framework__r.Customer__c', 'Contract_Treatment_Job__r.Contract_Framework__r.Branch_of_belonging_sales_office__c', 
		'Contract_Treatment_Job__r.Contract_Framework__c', 'Contract_Treatment_Job__r.Contract_Treatment__c', 'Delivery_Channel__c', 
		'Contract_Treatment_Job__r.Contract_Framework__r.Price_list_code__c', 'Patient_Treatment__r.Customer_Purchase_Date__c', 
		'Patient_Treatment__r.Customer_Purchase_Order_Number__c', 'Patient_Treatment__r.Account__r.FirstName', 'Patient_Treatment__r.Account__r.LastName', 
		'Work_Type__c', 'Patient_Treatment__r.Account__r.IsPersonAccount', 'Patient_Treatment__r.Account__r.PersonContactId', 'Frequency__c', 
		'Frequency_Unit_of_measure__c', 'Patient_Treatment__r.Prescription__r.CreatedDate', 'Patient_Treatment__r.Prescription__r.Received_Date__c', 
		'Contract_Treatment_Job__r.Contract_Framework__r.Attachment_Addendum_Type__c', 'Contract_Treatment_Job__r.Contract_Framework__r.Billing_Via__c', 
		'Contract_Treatment_Job__r.Contract_Framework__r.Customer__r.Customer_Purchase_Order_Date__c',
        'Contract_Treatment_Job__r.Contract_Framework__r.Customer_Purchase_Order_Date__c',  
		'Contract_Treatment_Job__r.Contract_Framework__r.Customer__r.Customer_Purchase_Order_Number__c', 
        'Contract_Treatment_Job__r.Contract_Framework__r.Customer_Purchase_Order_Number__c', 
		'Contract_Treatment_Job__r.Contract_Framework__r.Customer__r.Billing_Reference__c', 'Contract_Treatment_Job__r.Contract_Framework__r.Customer_Request_Code__c', 
        'Contract_Treatment_Job__r.Contract_Framework__r.Invoice_splitting_criterion__c', 
		'Contract_Treatment_Job__r.Contract_Framework__r.Invoice_Layout__c', 'Contract_Treatment_Job__r.Invoice_Splitting_Group__c', 
		'Patient_Treatment__r.Customer_Request_Code__c', 'Patient_Treatment__r.Contract_Treatment__r.Invoice_Splitting_Group__c', 'Account_Treatment_Job__c', 
        'Customer_Product_Code__c', 'Scheduling_Time_Frame__c', 'Frequency_Type__c'};
        
        List<String> caseQueryFields = new List<String>{'AccountId', 'Account_Treatment__c', 'Account_Treatment_Job__c', 'Origin', 'Contract_Treatment__c', 
        'Patient__c', 'Status', 'Subject', 'Subtype__c', 'Type', 'Treatment__c', 'Autoscheduled__c', 'ContactId', 'OwnerId', 'Start_Date__c', 'Next_Activity_Date__c'};

        List<String> ASOQueryFields = new List<String>{'Sales_Organization__r.Code__c', 'Division__c', 'Distribution_Channel__c', 'Sales_Group__c', 'Sales_Office__c'};

        List<String> ATJPQueryFields = new List<String>{'Product__c', 'Quantity__c', 'Customer_Treatment_Alias__c', 'Patient_Treatment_Job__c', 'Customer_Request_Code__c', 
        'Storage_Location__c', 'Plant__c', 'Purchase_order_number__c', 'Purchase_order_date__c', 'Contract_Treatment_Job_Product__r.Invoice_Splitting_group__c', 'Asset__c', 
        'Asset__r.SerialNumber'};
        
        List<String> PBEntryQueryFields = new List<String>{'Product2Id', 'Pricebook2Id'};

        List<Task> completedTasksWithoutWOs = new List<Task>();
        List<WorkOrder> WOsRelatedToCompletedTaskCases = new List<WorkOrder>();
        List<Account_Treatment_Job__c> allDependentATJs = new List<Account_Treatment_Job__c>();
        List<Case> newCases = new List<Case>();
        List<Task> newTasks = new List<Task>();
        List<Case> queriedNewCases = new List<Case>();
        List<String> completedTaskWhatIds = new List<String>();
        List<String> completedTaskATJIds = new List<String>();
        List<String> newCaseIds = new List<String>();
        List<String> relatedASOIds = new List<String>();
        List<String> allDependentATJIds = new List<String>();
        List<String> pricebookIds = new List<String>();

        Map<String, List<WorkOrder>> caseToOpenWOsMap = new Map<String, List<WorkOrder>>();
        Map<String, List<Account_Treatment_Job__c>> dependentATJMap = new Map<String, List<Account_Treatment_Job__c>>();
        Map<String, List<Case>> newCasesMap = new Map<String, List<Case>>();
        Map<String, Case> queriedNewCasesMap = new Map<String, Case>();
        Map<Id, Account_Sales_Organization__c> ASOMap = new Map<Id, Account_Sales_Organization__c>();

        AssignmentRule assignmentRule = [SELECT Id FROM AssignmentRule WHERE SobjectType = 'Case' and Active = true LIMIT 1];

        BusinessHours bh = [SELECT Id, MondayStartTime, MondayEndTime, TuesdayStartTime, TuesdayEndTime, WednesdayStartTime, WednesdayEndTime, 
                            ThursdayStartTime, ThursdayEndTime, FridayStartTime, FridayEndTime, SaturdayStartTime, SaturdayEndTime, SundayStartTime, SundayEndTime
		                    FROM BusinessHours
                            WHERE Name = 'NL'];
                            
        DocumentType__mdt therapyDocumentType = [SELECT Code__c
                                                 FROM DocumentType__mdt
                                                 WHERE DeveloperName = 'Therapy'];

        //Creating the DMLOptions for "Assign using active assignment rules" checkbox

		Database.DMLOptions DMLOptions = new Database.DMLOptions();
		DMLOptions.assignmentRuleHeader.assignmentRuleId = assignmentRule.Id;

        if(completedTasks != null) {
            for(Task t : completedTasks) {
                if(t.WhatId != null) {
                    completedTaskWhatIds.add(t.WhatId);
                }

                if(t.Account_Treatment_Job__r.Patient_Treatment__c != null) {
                    accountTreatmentIds.add(t.Account_Treatment_Job__r.Patient_Treatment__c);
                }
            }

            // Getting all the open WOs related to the Cases of the completed Tasks. I can only schedule dependent activities if there is no open WO for that Case

            if(!completedTaskWhatIds.isEmpty()) {
                WOsRelatedToCompletedTaskCases = WorkOrderDAO.getOpenWOsFromCaseIds(workOrderQueryFields, completedTaskWhatIds);
            }

            if(WOsRelatedToCompletedTaskCases != null) {
                for(WorkOrder wo : WOsRelatedToCompletedTaskCases) {
                    if(caseToOpenWOsMap.get(wo.CaseId) == null) {
                        caseToOpenWOsMap.put(wo.CaseId, new List<WorkOrder>());
                    }
                    caseToOpenWOsMap.get(wo.CaseId).add(wo);
                }
            }

            // Putting in completedTasksWithoutWOs only the completed Tasks whose Case has no open WOs

            for(Task t : completedTasks) {
                List<WorkOrder> relatedOpenWorkOrders = caseToOpenWOsMap.get(t.WhatId);

                if(relatedOpenWorkOrders == null || relatedOpenWorkOrders.isEmpty()) {
                    completedTasksWithoutWOs.add(t);

                    if(t.Account_Treatment_Job__c != null) {
                        completedTaskATJIds.add(t.Account_Treatment_Job__c);
                    }
                }
            }

            if(!completedTaskATJIds.isEmpty()) {
                // Getting all the ATJs which depend on the ATJs of the completed Tasks, then building a FatherATJ.Id --> List<Dependent ATJs> Map

                allDependentATJs = AccountTreatmentJobDAO.getDependentATJsFromATJIds(ATJQueryFields, completedTaskATJIds);

                if(allDependentATJs != null && !allDependentATJs.isEmpty()) {
                    for(Account_Treatment_Job__c atj : allDependentATJs) {
                        allDependentATJIds.add(atj.Id);

                        if(atj.Contract_Treatment_Job__r.Contract_Framework__r.Branch_of_belonging_sales_office__c != null) {
                            relatedASOIds.add(atj.Contract_Treatment_Job__r.Contract_Framework__r.Branch_of_belonging_sales_office__c);
                        }

                        if(atj.Contract_Treatment_Job__r.Contract_Framework__r.Price_list_code__c != null) {
                            pricebookIds.add(atj.Contract_Treatment_Job__r.Contract_Framework__r.Price_list_code__c);
                        }
                        
                        ATJMap.put(atj.Id, atj);

                        if(dependentATJMap.get(atj.Account_Treatment_Job__c) == null) {
                            dependentATJMap.put(atj.Account_Treatment_Job__c, new List<Account_Treatment_Job__c>());
                        }
                        dependentATJMap.get(atj.Account_Treatment_Job__c).add(atj);
                    }
                }
            }

            // Getting all the ATJPs for the WOLICreationBatch

            List<Account_Treatment_Job_Product__c> allProducts = AccountTreatmentJobProductDAO.getActiveProductsFromATJs(ATJPQueryFields, allDependentATJIds);

            if (!allProducts.isEmpty()){
                System.debug('allproducts size: ' + allProducts.size());
                for (Account_Treatment_Job_Product__c atjp : allProducts){
                    if (jobToProductsMap.get(atjp.Patient_Treatment_Job__c) == null){
                        jobToProductsMap.put(atjp.Patient_Treatment_Job__c, new List<Account_Treatment_Job_Product__c>());
                    }
                    jobToProductsMap.get(atjp.Patient_Treatment_Job__c).add(atjp);
                }
            }

            // Getting all the pricebookEntries --> The pricebookEntry related to each Account_Treatment_Job__c

            List<PricebookEntry> allPricebookEntries = PricebookEntryDAO.getPEFromPricebookIds(PBEntryQueryFields, pricebookIds);
            if (!allPricebookEntries.isEmpty()){
                for (PricebookEntry pe : allPricebookEntries){
                    if (pricebookIdToPEMap.get(pe.Pricebook2Id) == null){
                        pricebookIdToPEMap.put(pe.Pricebook2Id, new List<PricebookEntry>());
                    }
                    pricebookIdToPEMap.get(pe.Pricebook2Id).add(pe);
                }
            }

            // Getting all the ASOs related to the ATJs

            List<Account_Sales_Organization__c> relatedASOs = AccountSalesOrganizationDAO.getASOsFromIds(ASOQueryFields, relatedASOIds);
            if (relatedASOs != null){
                for (Account_Sales_Organization__c aso : relatedASOs){
                    ASOMap.put(aso.Id, aso);
                }
            }

            // Creating new Cases (need to insert them before creating WOs, WOLIs and Tasks)

            for(Task t : completedTasksWithoutWOs) {
                List<Account_Treatment_Job__c> dependentATJs = dependentATJMap.get(t.Account_Treatment_Job__c);
                Map<Account_Treatment_Job__c, Contract_Treatment_Job_SLA__c> ATJToSLAMap = new Map<Account_Treatment_Job__c, Contract_Treatment_Job_SLA__c>();

                if (dependentATJs != null){
                    System.debug('dependentATJs: ' + dependentATJs.size());

                    // All dependent ATJs and the related chosen SLA

                    ATJToSLAMap = ATMainComponentService.getATJtoSLAMap(dependentATJs);
                    List<Case> tmpNewCases = ATMainComponentService.createCases(ATJtoSLAMap, DMLOptions, true, null);

                    System.debug('tmpNewCases size: ' + tmpNewCases.size());

                    if(tmpNewCases != null) {
                        newCasesMap.put(t.Id, tmpNewCases);

                        for(Case c : tmpNewCases) {
                            newCases.add(c);
                        }
                    }
                }
            }

            // Inserting new Cases

            if (!newCases.isEmpty()){
                List<Database.SaveResult> results = Database.insert(newCases);

                for(Case c : newCases) {
                    newCaseIds.add(c.Id);
                }

                // I need to query the new Cases, but then I need to swap the queried new Cases with the old ones in the newCases Map, to have the queried new Cases for each Task

                queriedNewCases = CaseDAO.getCasesFromIds(caseQueryFields, newCaseIds);
                
                for(Case c : queriedNewCases) {
                    queriedNewCasesMap.put(c.Id, c);
                }

                for(Task t : completedTasksWithoutWOs) {
                    List<Case> relatedNewCases = newCasesMap.get(t.Id);
                    List<Case> newRelatedNewCases = new List<Case>();

                    if(relatedNewCases != null && !relatedNewCases.isEmpty()) {
                        for(Case c : relatedNewCases) {
                            Case relatedQueriedCase = queriedNewCasesMap.get(c.Id);

                            if(relatedQueriedCase != null) {
                                newRelatedNewCases.add(relatedQueriedCase);
                            }
                        }

                        if(newRelatedNewCases != null) {
                            System.debug('Swapping Cases...');
                            newCasesMap.put(t.Id, newRelatedNewCases);
                        }
                    }
                }
            }

            // Creating new WorkOrders and Tasks

            for(Task t : completedTasksWithoutWOs) {
                List<Account_Treatment_Job__c> dependentATJs = dependentATJMap.get(t.Account_Treatment_Job__c);
                Map<Account_Treatment_Job__c, Contract_Treatment_Job_SLA__c> ATJToSLAMap = new Map<Account_Treatment_Job__c, Contract_Treatment_Job_SLA__c>();

                if(dependentATJs != null) {
                    List<Case> relatedNewCases = newCasesMap.get(t.Id);

                    if(relatedNewCases != null && !relatedNewCases.isEmpty()) {
                        System.debug('relatedNewCases size: ' + relatedNewCases.size());
                        // All dependent ATJs and the related chosen SLA

                        ATJtoSLAMap = ATMainComponentService.getATJtoSLAMap(dependentATJs);

                        // Using the same method used in WorkOrderTrigger to create dependent activities from closed WO

                        List<WorkOrder> createdWorkOrders = WorkOrderService.createWorkOrders(ATJToSLAMap, relatedNewCases, null, t, bh, ASOMap, therapyDocumentType);
                        if (createdWorkOrders != null){
                            for (WorkOrder createdWO : createdWorkOrders){
                                newWorkOrders.add(createdWO);
                            }
                        }

                        // Using the same method used in ATMainComponentService to create Tasks for each dependent Job of each closed WO

                        List<Task> createdTasks = ATMainComponentService.createTasks(ATJtoSLAMap, relatedNewCases, bh, false, null, t, null, false, null);
                        if (createdTasks != null){
                            for (Task createdTask : createdTasks){
                                newTasks.add(createdTask);
                            }
                        }
                    }
                }
            }

            // Inserting new WorkOrders + updating Cases for the Start Date

            if (!newWorkOrders.isEmpty()){
                List<Database.SaveResult> WOResults = Database.insert(newWorkOrders);
                List<Database.SaveResult> firstCasesResults = Database.update(queriedNewCases);
            }

            // Inserting new Tasks and updating Cases for the Start Date

            if (!newTasks.isEmpty()){
                List<Database.SaveResult> taskResults = Database.insert(newTasks);
                List<Database.SaveResult> secondCasesResults = Database.update(queriedNewCases);
            }
        }
    }

    public void finish(Database.BatchableContext bc) {

        // Executing WOLI Batch

        WOLICreationBatch WOLICreation;

        if(!ATJMap.isEmpty() && !jobToProductsMap.isEmpty() && !pricebookIdToPEMap.isEmpty() && !newWorkOrders.isEmpty()) {
            WOLICreation = new WOLICreationBatch();
			WOLICreation.ATJMap = ATJMap;
			WOLICreation.jobToProductsMap = jobToProductsMap;
			WOLICreation.pricebookIdToPEMap = pricebookIdToPEMap;
            WOLICreation.workOrders = newWorkOrders;
            
			Database.executeBatch(WOLICreation, 3);
        }    

        // Executing Batch to align workOrders for different created addresses (Temporary and Default)

        if(!accountTreatmentIds.isEmpty()) {
            ATAAlignmentBatch ATABatch = new ATAAlignmentBatch();
            ATABatch.ATIds = accountTreatmentIds;

            /* if(WOLICreation != null) {
                ATABatch.WOLIBatch = WOLICreation;
            } */

            Database.executeBatch(ATABatch, 100);
        }
    }
}