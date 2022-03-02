public class ATHTriggerService {
    
    public static void scheduleNoComplianceActivities(List<Account_Treatment_History__c> noComplianceHistories) {
        System.debug('----- scheduleNoComplianceActivities -----');
        
        List<String> ATJQueryFields = new List<String>{'Scheduling_Rule__c', 'Work_Order__c', 'Task__c', 'Contract_Treatment_Job__c', 'Patient_Treatment__r.Account__c',
        'Patient_Treatment__c', 'Patient_Treatment__r.Contract_Treatment__c', 'Name', 'Case_Subtype__c', 'Case_Type__c', 'Patient_Treatment__r.Treatment_Type__c',
        'Contract_Treatment_Job__r.Contract_Framework__r.Customer__c', 
        'Contract_Treatment_Job__r.Contract_Framework__r.Branch_of_belonging_sales_office__c', 'Contract_Treatment_Job__r.Contract_Framework__c', 
        'Contract_Treatment_Job__r.Contract_Treatment__c', 'Delivery_Channel__c', 
        'Contract_Treatment_Job__r.Contract_Framework__r.Price_list_code__c',
        'Patient_Treatment__r.Customer_Purchase_Date__c', 'Patient_Treatment__r.Customer_Purchase_Order_Number__c', 'Patient_Treatment__r.Account__r.FirstName',
        'Patient_Treatment__r.Account__r.LastName', 'Work_Type__c', 'Patient_Treatment__r.Account__r.IsPersonAccount', 'Patient_Treatment__r.Account__r.Name',
        'Patient_Treatment__r.Account__r.PersonContactId', 'Frequency__c', 'Frequency_Unit_of_measure__c', 'Patient_Treatment__r.Prescription__r.CreatedDate',
        'Patient_Treatment__r.Prescription__r.Received_Date__c', 'Contract_Treatment_Job__r.Contract_Framework__r.Attachment_Addendum_Type__c',
        'Contract_Treatment_Job__r.Contract_Framework__r.Billing_Via__c', 'Contract_Treatment_Job__r.Contract_Framework__r.Customer__r.Customer_Purchase_Order_Date__c',
        'Contract_Treatment_Job__r.Contract_Framework__r.Customer_Purchase_Order_Date__c', 
        'Contract_Treatment_Job__r.Contract_Framework__r.Customer__r.Customer_Purchase_Order_Number__c',
        'Contract_Treatment_Job__r.Contract_Framework__r.Customer_Purchase_Order_Number__c', 
        'Contract_Treatment_Job__r.Contract_Framework__r.Customer__r.Billing_Reference__c', 'Contract_Treatment_Job__r.Contract_Framework__r.Customer_Request_Code__c',
        'Contract_Treatment_Job__r.Contract_Framework__r.Invoice_splitting_criterion__c', 'Contract_Treatment_Job__r.Contract_Framework__r.Invoice_Layout__c',
        'Contract_Treatment_Job__r.Invoice_Splitting_Group__c', 'Patient_Treatment__r.Customer_Request_Code__c', 
        'Patient_Treatment__r.Contract_Treatment__r.Invoice_Splitting_Group__c', 'ComplianceSource__c', 'Customer_Product_Code__c', 'Scheduling_Time_Frame__c',
        'Frequency_Type__c'};
        List<String> queryFieldsForATA = new List<String>{'Account_Treatment__c', 'Start_Date__c', 'End_Date__c', 'Location__c', 
        'Location__r.VisitorAddress.Street', 'Location__r.VisitorAddress.PostalCode', 'Location__r.VisitorAddress.StateCode',
        'Location__r.VisitorAddress.CountryCode', 'Location__r.VisitorAddress.City', 'Location__r.VisitorAddress.Country',
        'Location__r.VisitorAddress.Latitude', 'Location__r.VisitorAddress.Longitude', 'Location__r.VisitorAddress.State'};
        List<String> caseQueryFields = new List<String>{'Id'};

        List<Id> accountTreatmentIds = new List<Id>();
        List<Account_Treatment_Job__c> ATJsForScheduling = new List<Account_Treatment_Job__c>();
        List<Id> ATIdsForScheduling = new List<Id>();

        Map<Id, List<Account_Treatment_Job__c>> ATIdToATJsMap = new Map<Id, List<Account_Treatment_Job__c>>();
        Map<Id, Account_Treatment_History__c> ATJIdToATHMap = new Map<Id, Account_Treatment_History__c>();
        
        for(Account_Treatment_History__c ath : noComplianceHistories) {
            accountTreatmentIds.add(ath.Account_Treatment__c);
        }

        List<Account_Treatment_Job__c> allRelatedATJs = AccountTreatmentJobDAO.getATJsFromATIds(ATJQueryFields, accountTreatmentIds);

        if(allRelatedATJs != null) {
            System.debug('AllRelatedATJs size: ' + allRelatedATJs.size());

            for(Account_Treatment_Job__c atj : allRelatedATJs) {
                if(ATIdToATJsMap.get(atj.Patient_Treatment__c) == null) {
                    ATIdToATJsMap.put(atj.Patient_Treatment__c, new List<Account_Treatment_Job__c>());
                }
                ATIdToATJsMap.get(atj.Patient_Treatment__c).add(atj);
            }
        }

        for(Account_Treatment_History__c ath : noComplianceHistories) {
            List<Account_Treatment_Job__c> relatedATJs = ATIdToATJsMap.get(ath.Account_Treatment__c);
            List<Case> noComplianceCasesForAT = CaseDAO.getOpenNoComplianceCasesFromATs(caseQueryFields, new List<String>{ath.Account_Treatment__c});

            if(relatedATJs != null) {
                for(Account_Treatment_Job__c atj : relatedATJs) {
                    System.debug('atj.ComplianceSource__c: ' + atj.ComplianceSource__c);
                    System.debug('ATH.ComplianceSource__c: ' + ath.ComplianceSource__c);

                    if(atj.ComplianceSource__c != null) {
                        List<String> complianceSourceValues = atj.ComplianceSource__c.split(';');

                        if(atj.ComplianceSource__c != null && 
                        ath.ComplianceSource__c != null &&
                        complianceSourceValues.contains(ath.ComplianceSource__c) &&
                        atj.Scheduling_Rule__c == 'Compliance Registration' && 
                        (noComplianceCasesForAT.isEmpty()) || noComplianceCasesForAT == null) {
                            ATJsForScheduling.add(atj);
                            ATJIdToATHMap.put(atj.Id, ath);
                            ATIdsForScheduling.add(atj.Patient_Treatment__c);
                        }
                    }
                }
            }
        }

        if(!ATJsForScheduling.isEmpty()) {
            BusinessHours bh = [SELECT Id, MondayStartTime, MondayEndTime, TuesdayStartTime, TuesdayEndTime, WednesdayStartTime, WednesdayEndTime,
                            ThursdayStartTime, ThursdayEndTime, FridayStartTime, FridayEndTime, SaturdayStartTime, SaturdayEndTime, SundayStartTime, SundayEndTime  
                            FROM BusinessHours WHERE Name = 'NL'];

            AssignmentRule assignmentRule = [SELECT Id FROM AssignmentRule WHERE SobjectType = 'Case' and Active = true LIMIT 1];

            DocumentType__mdt therapyDocumentType = [SELECT Code__c FROM DocumentType__mdt WHERE DeveloperName = 'Therapy'];

            List<Case> casesToInsert = new List<Case>();
            List<Task> tasksToInsert = new List<Task>();
            List<WorkOrder> newWorkOrders = new List<WorkOrder>();

            Map<Id, Account_Treatment_Address__c> ATIdToDefaultATAMap = new Map<Id, Account_Treatment_Address__c>();
            Map<Account_Treatment_Job__c,Contract_Treatment_Job_SLA__c> ATJToSLAMap = ATMainComponentService.getATJtoSLAMap(ATJsForScheduling);

            // Retrieving all the Default ATAs for all the ATs, then building a map

            List<Account_Treatment_Address__c> defaultAddressList = AccountTreatmentAddressDAO.getDefaultATAFromATs(queryFieldsForATA, ATIdsForScheduling);
            
            for(Account_Treatment_Address__c ata : defaultAddressList) {
                ATIdToDefaultATAMap.put(ata.Account_Treatment__c, ata);
            }

            // Creating the DMLOptions for "Assign using active assignment rules" checkbox

            Database.DMLOptions DMLOptions = new Database.DMLOptions();
            DMLOptions.assignmentRuleHeader.assignmentRuleId = assignmentRule.Id;

            // Creating Cases

            casesToInsert = NoComplianceActivitiesSchedulingService.createCases(ATJtoSLAMap, DMLOptions, 365, ATJIdToATHMap);

            if(!casesToInsert.isEmpty()) {
                insert casesToInsert;

                // Creating WorkOrders: these newWorkOrders are already inserted by the method, because it also has to do an update of the related Cases

                newWorkOrders = NoComplianceActivitiesSchedulingService.createWorkOrders(ATJToSLAMap, 
                casesToInsert, ATIdToDefaultATAMap);

                // Creating Tasks  

                tasksToInsert = ATMainComponentService.createTasks(ATJToSLAMap, casesToInsert, bh, false, null, null, null, false, null);

                if(!tasksToInsert.isEmpty()) {
                    insert tasksToInsert;

                    // Updating Cases to update StartDate and NextActivityDate. For WOs, this update is already done inside the method itself

                    update casesToInsert;
                }

                // Executing Batch to align workOrders for different created addresses (Temporary and Default)

                ATAAlignmentBatch ATABatch = new ATAAlignmentBatch();
                ATABatch.ATIds = ATIdsForScheduling;

                Database.executeBatch(ATABatch, 100);
            }
        }
    }

    public static void closeNonComplianceCases(List<Account_Treatment_History__c> ATHs) {
        List<String> caseQueryFields = new List<String>{'Status', 'Account_Treatment__c', 'Account_Treatment_Job__r.ComplianceSource__c'};
        List<String> workOrderQueryFields = new List<String>{'Status', 'Reason__c', 'CaseId'};
        List<String> WOLIQueryFields = new List<String>{'Status', 'WorkOrderId', 'WorkOrder.CaseId', 'WorkOrder.Status'};
        List<String> taskQueryFields = new List<String>{'Status', 'WhatId'};

        List<String> relatedATIds = new List<String>();
        List<String> openNonComplianceCaseIds = new List<String>();
        List<String> allRelatedWorkOrderIds = new List<String>();

        List<Case> openNonComplianceCases = new List<Case>();
        List<WorkOrder> allRelatedWorkOrders = new List<WorkOrder>();
        List<WorkOrderLineItem> allRelatedWOLIs = new List<WorkOrderLineItem>();
        List<Task> allRelatedTasks = new List<Task>();

        List<Case> casesToUpdate = new List<Case>();
        List<WorkOrder> workOrdersToUpdate = new List<WorkOrder>();
        List<WorkOrderLineItem> WOLIsToUpdate = new List<WorkOrderLineItem>();
        List<Task> tasksToUpdate = new List<Task>();

        Map<String, List<Case>> ATIdToNonComplianceCasesMap = new Map<String, List<Case>>();
        Map<String, List<WorkOrder>> caseToWorkOrdersMap = new Map<String, List<WorkOrder>>();
        Map<String, List<WorkOrderLineItem>> caseToWOLIsMap = new Map<String, List<WorkOrderLineItem>>();
        Map<String, List<Task>> caseToTasksMap = new Map<String, List<Task>>();

        AssignmentRule assignmentRule = [SELECT Id FROM AssignmentRule WHERE SobjectType = 'Case' and Active = true LIMIT 1];

        // Creating the DMLOptions for "Assign using active assignment rules" checkbox
        Database.DMLOptions DMLOptions = new Database.DMLOptions();
        DMLOptions.assignmentRuleHeader.assignmentRuleId = assignmentRule.Id;

        for(Account_Treatment_History__c ath : ATHs) {
            relatedATIds.add(ath.Account_Treatment__c);
        }

        // Getting all the open Non Compliance Cases related to the ATs of the ATHs and building a map to link them to the related AT

        openNonComplianceCases = CaseDAO.getOpenNoComplianceCasesFromATs(caseQueryFields, relatedATIds);

        for(Case c : openNonComplianceCases) {
            openNonComplianceCaseIds.add(c.Id);

            if(ATIdToNonComplianceCasesMap.get(c.Account_Treatment__c) == null) {
                ATIdToNonComplianceCasesMap.put(c.Account_Treatment__c, new List<Case>());
            }
            ATIdToNonComplianceCasesMap.get(c.Account_Treatment__c).add(c);
        }

        // If open Non Compliance Cases are found, then getting the open activities related to these Cases and building a Case.Id --> List<Related activities> Map

        if(!openNonComplianceCaseIds.isEmpty()) {
            allRelatedWorkOrders = WorkOrderDAO.getOpenWOsFromCaseIds(workOrderQueryFields, openNonComplianceCaseIds);

            for(WorkOrder wo : allRelatedWorkOrders) {
                allRelatedWorkOrderIds.add(wo.Id);

                if(caseToWorkOrdersMap.get(wo.CaseId) == null) {
                    caseToWorkOrdersMap.put(wo.CaseId, new List<WorkOrder>());
                }
                caseToWorkOrdersMap.get(wo.CaseId).add(wo);
            }

            // Getting all the WOLIs related to the WOs (related to the open Non Compliance Cases) and building a RelatedWO.CaseId --> List<Related WOLIs> Map

            if(!allRelatedWorkOrderIds.isEmpty()) {
                allRelatedWOLIs = WorkOrderLineItemDAO.getWOLIsFromWOs(WOLIQueryFields, allRelatedWorkOrderIds);

                for(WorkOrderLineItem woli : allRelatedWOLIs) {
                    if(caseToWOLIsMap.get(woli.WorkOrder.CaseId) == null) {
                        caseToWOLIsMap.put(woli.WorkOrder.CaseId, new List<WorkOrderLineItem>());
                    }
                    caseToWOLIsMap.get(woli.WorkOrder.CaseId).add(woli);
                }
            }

            // Getting all the Tasks related to the Non Compliance Cases found, then building a Case.Id --> List<Related Open Tasks> Map

            allRelatedTasks = TaskDAO.getOpenTasksFromWhatIds(taskQueryFields, openNonComplianceCaseIds);

            for(Task t : allRelatedTasks) {
                if(caseToTasksMap.get(t.WhatId) == null) {
                    caseToTasksMap.put(t.WhatId, new List<Task>());
                }
                caseToTasksMap.get(t.WhatId).add(t);
            }
        }

        for(Account_Treatment_History__c ath : ATHs) {
            List<Case> nonComplianceCasesRelatedToAT = ATIdToNonComplianceCasesMap.get(ath.Account_Treatment__c);

            if(nonComplianceCasesRelatedToAT != null && !nonComplianceCasesRelatedToAT.isEmpty()) {
                Case nonComplianceCase = nonComplianceCasesRelatedToAT[0];

                if(nonComplianceCase != null) {
                    // Getting all the open activities related to this Non Compliance Case

                    List<WorkOrder> relatedWorkOrders = caseToWorkOrdersMap.get(nonComplianceCase.Id);
                    List<WorkOrderLineItem> relatedWOLIs = caseToWOLIsMap.get(nonComplianceCase.Id);
                    List<Task> relatedTasks = caseToTasksMap.get(nonComplianceCase.Id);

                    // If The Non Compliance Case for this AT is not the one related to the ATH...

                    if(nonComplianceCase.Id != ath.Case__c) {
                        if(nonComplianceCase.Account_Treatment_Job__r.ComplianceSource__c != null) {
                            List<String> complianceSourceValues = (nonComplianceCase.Account_Treatment_Job__r.ComplianceSource__c).split(';');

                            if(complianceSourceValues.contains(ath.ComplianceSource__c)) {
                                List<WorkOrder> relatedOpenWorkOrders = new List<WorkOrder>();
                                Boolean noAssignedWOsFound = true;

                                // One more filter for WOs in this case

                                if(relatedWorkOrders != null) {
                                    for(WorkOrder wo : relatedWorkOrders) {
                                        if(wo.Status != 'In Progress') {
                                            relatedOpenWorkOrders.add(wo);
                                        }
                                    }
                                }

                                // Closing related WorkOrders and WOLIs

                                if(relatedOpenWorkOrders != null && !relatedOpenWorkOrders.isEmpty()) {
                                    for(WorkOrder wo : relatedOpenWorkOrders) {
                                        if(wo.Status == 'Assigned') {
                                            noAssignedWOsFound = false;

                                            nonComplianceCase.Status = 'Review';
                                            nonComplianceCase.setOptions(DMLOptions);

                                            casesToUpdate.add(nonComplianceCase);
                                        }
                                    }

                                    if(noAssignedWOsFound) {
                                        for(WorkOrder wo : relatedOpenWorkOrders) {
                                            if(wo.Status == 'New' || wo.Status == 'Draft') {
                                                wo.Status = 'Canceled';
                                                wo.Reason__c = 'By Vivisol';

                                                workOrdersToUpdate.add(wo);
                                            }
                                        }

                                        if(relatedWOLIs != null && !relatedWOLIs.isEmpty()) {
                                            for(WorkOrderLineItem woli : relatedWOLIs) {
                                                if(woli.WorkOrder.Status == 'New' || woli.WorkOrder.Status == 'Draft') {
                                                    woli.Status = 'Canceled';

                                                    WOLIsToUpdate.add(woli);
                                                }
                                            }
                                        }
                                    }
                                }

                                if(noAssignedWOsFound) {
                                    // Closing related Tasks

                                    if(relatedTasks != null && !relatedTasks.isEmpty()) {
                                        for(Task t : relatedTasks) {
                                            t.Status = 'Canceled';

                                            tasksToUpdate.add(t);
                                        }
                                    }

                                    // Closing the Case

                                    nonComplianceCase.Status = 'Canceled';

                                    casesToUpdate.add(nonComplianceCase);
                                }
                            }
                        }
                    }

                    // ... Else If The Non Compliance Case for this AT is the one related to the ATH

                    else if(nonComplianceCase.Id == ath.Case__c) {
                        // Only closing the Case and the Tasks if there are no open WorkOrders for the Non Compliance Case

                        if(relatedWorkOrders == null || relatedWorkOrders.isEmpty()) {
                            if(relatedTasks != null && !relatedTasks.isEmpty()) {
                                // Closing related Tasks

                                for(Task t : relatedTasks) {
                                    t.Status = 'Completed';

                                    tasksToUpdate.add(t);
                                }

                                // Closing the Case

                                nonComplianceCase.Status = 'Closed';

                                casesToUpdate.add(nonComplianceCase);
                            }
                        }
                    }
                }
            }
        }

        // Executing the update of the records if needed

        if(!WOLIsToUpdate.isEmpty()) {
            List<Database.SaveResult> results = Database.update(WOLIsToUpdate);
        }

        if(!workOrdersToUpdate.isEmpty()) {
            List<Database.SaveResult> results = Database.update(workOrdersToUpdate);
        }

        if(!tasksToUpdate.isEmpty()) {
            List<Database.SaveResult> results = Database.update(tasksToUpdate);
        }

        if(!casesToUpdate.isEmpty()) {
            List<Database.SaveResult> results = Database.update(casesToUpdate);
        }
    }
}