global class ATAAlignmentBatch implements Database.Batchable<sObject>, Database.Stateful{
    global List<Id> ATIds;
    global Boolean executeServiceTerritoryBatch = false;
    //global Boolean executeServiceTerritoryBatchAnyway;
    global WOLICreationBatch WOLIBatch;

    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id FROM Account_Treatment__c WHERE Id IN: ATIds';
        System.debug(query);
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Account_Treatment__c> accountTreatments) {
        System.debug('accountTreatments: ' + accountTreatments);
        List<String> queryFieldsForWO = new List<String>{'Account_Treatment__c', 'Status', 'Due_Date__c', 'LocationId', 'Street', 'PostalCode', 
        'StateCode', 'CountryCode', 'City', 'Delivery_Type__c', 'TaskCreated__c', 'CaseId', 'StartDate', 'EndDate', 'Check_Service_Territory__c'};
        List<String> queryFieldsForATA = new List<String>{'Account_Treatment__c', 'Start_Date__c', 'End_Date__c', 'Location__c', 
        'Location__r.VisitorAddress.Street', 'Location__r.VisitorAddress.PostalCode', 'Location__r.VisitorAddress.StateCode',
        'Location__r.VisitorAddress.CountryCode', 'Location__r.VisitorAddress.City'};

        Map<Id, List<WorkOrder>> ATIdToWorkOrdersMap = new Map<Id, List<WorkOrder>>();
        Map<Id, Account_Treatment_Address__c> ATIdToDefaultATAMap = new Map<Id, Account_Treatment_Address__c>();
        Map<Id, List<Account_Treatment_Address__c>> ATIdToTemporaryATAsMap = new Map<Id, List<Account_Treatment_Address__c>>();

        List<WorkOrder> workOrdersToUpdate = new List<WorkOrder>();
        List<Task> tasksToInsert = new List<Task>();
        List<Id> accountTreatmentIds = new List<Id>();

        for(Account_Treatment__c at : accountTreatments) {
            accountTreatmentIds.add(at.Id);
        }

        // Retrieving WOs related to the Account Treatments
        List<WorkOrder> workOrdersRelatedToATs = WorkOrderDAO.getWorkOrdersFromAccountTreatmentIds(queryFieldsForWO, accountTreatmentIds);
        System.debug('ATAAlignmentBatch workOrdersRelatedToATs: ' + workOrdersRelatedToATs);

        Group prePlannerNL = [SELECT Id FROM Group WHERE Name = 'Preplanner_NL' AND Type = 'Queue'];

        // Building a AT.Id --> List<related WO> Map
        if(workOrdersRelatedToATs != null) {
            for(WorkOrder wo : workOrdersRelatedToATs) {
                if(ATIdToWorkOrdersMap.get(wo.Account_Treatment__c) == null) {
                    ATIdToWorkOrdersMap.put(wo.Account_Treatment__c, new List<WorkOrder>());
                }
                ATIdToWorkOrdersMap.get(wo.Account_Treatment__c).add(wo);
            }
        }

        // Retrieving the Default ATA for each AT
        List<Account_Treatment_Address__c> defaultATAs = AccountTreatmentAddressDAO.getDefaultATAFromATs(queryFieldsForATA, accountTreatmentIds);

        // Building a AT.Id --> Default ATA Map
        for(Account_Treatment_Address__c ata : defaultATAs) {
            ATIdToDefaultATAMap.put(ata.Account_Treatment__c, ata);
        }

        // Retrieving the temporary ATAs for each AT
        List<Account_Treatment_Address__c> temporaryATAs = AccountTreatmentAddressDAO.getTemporaryATAsFromATs(queryFieldsForATA, accountTreatmentIds);

        // Building a AT.Id --> List<related Temporary ATAs> Map
        if(temporaryATAs != null) {
            for(Account_Treatment_Address__c ata : temporaryATAs) {
                if(ATIdToTemporaryATAsMap.get(ata.Account_Treatment__c) == null) {
                    ATIdToTemporaryATAsMap.put(ata.Account_Treatment__c, new List<Account_Treatment_Address__c>());
                }
                ATIdToTemporaryATAsMap.get(ata.Account_Treatment__c).add(ata);
            }
        }

        if(!ATIdToWorkOrdersMap.isEmpty()) {
            for(Account_Treatment__c at : accountTreatments) {
                List<WorkOrder> relatedWorkOrders = ATIdToWorkOrdersMap.get(at.Id);
                
                if(ATIdToTemporaryATAsMap.get(at.Id) != null) {
                    List<Account_Treatment_Address__c> relatedTemporaryAddresses = ATIdToTemporaryATAsMap.get(at.Id);
                    System.debug('Related Temporary Addresses: ' + relatedTemporaryAddresses);

                    if(relatedTemporaryAddresses != null) {
                        for(Account_Treatment_Address__c temporaryAddress : relatedTemporaryAddresses) {

                            if(relatedWorkOrders != null) {
                                System.debug('relatedWorkOrders.size: ' + relatedWorkOrders.size());
                                for(WorkOrder wo : relatedWorkOrders) {
                                    System.debug('Related WO: ' + wo);
                                    System.debug('DeliveryType: ' + wo.Delivery_Type__c);
                                    if(wo.Delivery_Type__c != 'Welcome Model' && wo.Delivery_Type__c != 'Remote Call' &&
                                    (wo.Status != 'In progress' && wo.Status != 'Completed' && wo.Status != 'Cannot Complete' && wo.Status != 'Canceled') && 
                                    ((wo.Due_Date__c).date() >= temporaryAddress.Start_Date__c && (wo.Due_Date__c).date() <= temporaryAddress.End_Date__c) &&
                                    (wo.LocationId != temporaryAddress.Location__c || 
                                    (wo.Street != temporaryAddress.Location__r.VisitorAddress.Street ||
                                    wo.PostalCode != temporaryAddress.Location__r.VisitorAddress.PostalCode ||
                                    wo.StateCode != temporaryAddress.Location__r.VisitorAddress.StateCode || 
                                    wo.CountryCode != temporaryAddress.Location__r.VisitorAddress.CountryCode || 
                                    wo.City != temporaryAddress.Location__r.VisitorAddress.City))) {
                                        System.debug('In if != welcome model');
                                        if(wo.Status != 'Assigned') {
                                            System.debug('TEMPORARY ADDRESS');
                                            System.debug('----- ATAAlignmentBatch, editing Address from Street ' + wo.Street + ' to Street ' + temporaryAddress.Location__r.VisitorAddress.Street + ' -----');

                                            wo.LocationId = temporaryAddress.Location__c;
                                            wo.Street = temporaryAddress.Location__r.VisitorAddress.Street;
                                            wo.PostalCode = temporaryAddress.Location__r.VisitorAddress.PostalCode;
                                            wo.StateCode = temporaryAddress.Location__r.VisitorAddress.StateCode;
                                            wo.CountryCode = temporaryAddress.Location__r.VisitorAddress.CountryCode;
                                            wo.City = temporaryAddress.Location__r.VisitorAddress.City;

                                            wo.Check_Service_Territory__c = true;

                                            if(!workOrdersToUpdate.contains(wo)) {
                                                workOrdersToUpdate.add(wo);
                                            }
                                        }
                                        else if(wo.Status == 'Assigned' && wo.TaskCreated__c == false) {
                                            Task newTask = new Task(
                                                Subject = 'Check the Address / Location',
                                                Description = 'Check the Address / Location',
                                                WhatId = wo.CaseId,
                                                ActivityDate = Date.newInstance((wo.EndDate).year(), (wo.EndDate).month(), (wo.EndDate).day()),
                                                OwnerId = prePlannerNL.Id
                                            );

                                            tasksToInsert.add(newTask);
                                            wo.TaskCreated__c = true;

                                            if(!workOrdersToUpdate.contains(wo)) {
                                                workOrdersToUpdate.add(wo);
                                            }
                                        }
                                    }
                                    else if((wo.Delivery_Type__c == 'Welcome Model' || wo.Delivery_Type__c == 'Remote Call') &&
                                    (wo.Status != 'In progress' && wo.Status != 'Completed' && wo.Status != 'Cannot Complete' && wo.Status != 'Canceled') &&
                                    ((wo.Due_Date__c).date() >= temporaryAddress.Start_Date__c && (wo.Due_Date__c).date() <= temporaryAddress.End_Date__c) &&
                                    wo.LocationId != temporaryAddress.Location__c) {
                                        System.debug('In if == welcome model');
                                        if(wo.Status != 'Assigned') {
                                            wo.LocationId = temporaryAddress.Location__c;

                                            if(!workOrdersToUpdate.contains(wo)) {
                                                workOrdersToUpdate.add(wo);
                                            }
                                        }
                                        else if(wo.Status == 'Assigned' && wo.TaskCreated__c == false) {
                                            Task newTask = new Task(
                                                Subject = 'Check the Location',
                                                Description = 'Check the Location',
                                                WhatId = wo.CaseId,
                                                ActivityDate = Date.newInstance((wo.EndDate).year(), (wo.EndDate).month(), (wo.EndDate).day()),
                                                OwnerId = prePlannerNL.Id
                                            );

                                            tasksToInsert.add(newTask);
                                            wo.TaskCreated__c = true;

                                            if(!workOrdersToUpdate.contains(wo)) {
                                                workOrdersToUpdate.add(wo);
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                if(ATIdToDefaultATAMap != null) {
                    Account_Treatment_Address__c relatedDefaultAddress = ATIdToDefaultATAMap.get(at.Id);
                    List<Account_Treatment_Address__c> relatedTemporaryAddresses = ATIdToTemporaryATAsMap.get(at.Id);
                    List<WorkOrder> WOsInDefaultAddress = new List<WorkOrder>();

                    if(relatedWorkOrders != null) {
                        for(WorkOrder wo : relatedWorkOrders) {
                            Boolean isInDefaultAddress = true;
                            if(relatedTemporaryAddresses != null) {
                                for(Account_Treatment_Address__c temporaryATA : relatedTemporaryAddresses) {
                                    if((wo.Due_Date__c).date() >= temporaryATA.Start_Date__c && (wo.Due_Date__c).date() <= temporaryATA.End_Date__c) {
                                        isInDefaultAddress = false;
                                        break;
                                    }
                                }
                            }

                            if(isInDefaultAddress == true) {
                                WOsInDefaultAddress.add(wo);
                            }
                        }
                    }

                    if(relatedDefaultAddress != null) {
                        for(WorkOrder wo : WOsInDefaultAddress) {
                            if(wo.Delivery_Type__c != 'Welcome Model' && wo.Delivery_Type__c != 'Remote Call' && 
                            (wo.Status != 'In progress' && wo.Status != 'Completed' && wo.Status != 'Cannot Complete' && wo.Status != 'Canceled') &&
                            (wo.LocationId != relatedDefaultAddress.Location__c ||
                            (wo.Street != relatedDefaultAddress.Location__r.VisitorAddress.Street ||
                            wo.PostalCode != relatedDefaultAddress.Location__r.VisitorAddress.PostalCode || 
                            wo.StateCode != relatedDefaultAddress.Location__r.VisitorAddress.StateCode || 
                            wo.CountryCode != relatedDefaultAddress.Location__r.VisitorAddress.CountryCode ||
                            wo.City != relatedDefaultAddress.Location__r.VisitorAddress.City))) {
                                if(wo.Status != 'Assigned') {
                                    System.debug('DEFAULT ADDRESS');
                                    System.debug('----- ATAAlignmentBatch, editing Address from Street ' + wo.Street + ' to Street ' + relatedDefaultAddress.Location__r.VisitorAddress.Street + ' -----');
                                    wo.LocationId = relatedDefaultAddress.Location__c;
                                    wo.Street = relatedDefaultAddress.Location__r.VisitorAddress.Street;
                                    wo.PostalCode = relatedDefaultAddress.Location__r.VisitorAddress.PostalCode;
                                    wo.StateCode = relatedDefaultAddress.Location__r.VisitorAddress.StateCode;
                                    wo.CountryCode = relatedDefaultAddress.Location__r.VisitorAddress.CountryCode;
                                    wo.City = relatedDefaultAddress.Location__r.VisitorAddress.City;

                                    wo.Check_Service_Territory__c = true;

                                    if(!workOrdersToUpdate.contains(wo)) {
                                        workOrdersToUpdate.add(wo);
                                    }
                                }
                                else if(wo.Status == 'Assigned' && wo.TaskCreated__c == false) {
                                    Task newTask = new Task(
                                        Subject = 'Check the Address / Location',
                                        Description = 'Check the Address / Location',
                                        WhatId = wo.CaseId,
                                        ActivityDate = Date.newInstance((wo.EndDate).year(), (wo.EndDate).month(), (wo.EndDate).day()),
                                        OwnerId = prePlannerNL.Id
                                    );

                                    tasksToInsert.add(newTask);
                                    wo.TaskCreated__c = true;

                                    if(!workOrdersToUpdate.contains(wo)) {
                                        workOrdersToUpdate.add(wo);
                                    }
                                }
                            }
                            else if((wo.Delivery_Type__c == 'Welcome Model' || wo.Delivery_Type__c == 'Remote Call') &&
                            (wo.Status != 'In progress' && wo.Status != 'Completed' && wo.Status != 'Cannot Complete' && wo.Status != 'Canceled') &&
                            wo.LocationId != relatedDefaultAddress.Location__c) {
                                if(wo.Status != 'Assigned') {
                                    wo.LocationId = relatedDefaultAddress.Location__c;

                                    if(!workOrdersToUpdate.contains(wo)) {
                                        workOrdersToUpdate.add(wo);
                                    }
                                }
                                else if(wo.Status == 'Assigned' && wo.TaskCreated__c == false) {
                                    Task newTask = new Task(
                                        Subject = 'Check the Location',
                                        Description = 'Check the Location',
                                        WhatId = wo.CaseId,
                                        ActivityDate = Date.newInstance((wo.EndDate).year(), (wo.EndDate).month(), (wo.EndDate).day()),
                                        OwnerId = prePlannerNL.Id
                                    );

                                    tasksToInsert.add(newTask);
                                    wo.TaskCreated__c = true;

                                    if(!workOrdersToUpdate.contains(wo)) {
                                        workOrdersToUpdate.add(wo);
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        if(!tasksToInsert.isEmpty()) {
            insert tasksToInsert;
        }

        if(!workOrdersToUpdate.isEmpty()) {
            executeServiceTerritoryBatch = true;

            update workOrdersToUpdate;
        }
        System.debug('TasksToInsert: ' + tasksToInsert);
        System.debug('WorkOrdersToUpdate: ' + workOrdersToUpdate);

    }

    public void finish(Database.BatchableContext bc) {
        system.debug('DONE'); //TODO

        // Execute the ServiceTerritoryUpdateBatch if any WO has been updated with a new Address, or the global variable coming from the outside (ex. from Adjustment) is true
        
        if(executeServiceTerritoryBatch == true/*  || executeServiceTerritoryBatchAnyway == true */) {
            ServiceTerritoryUpdateBatch serviceTerritoryBatch = new ServiceTerritoryUpdateBatch();
            if(WOLIBatch != null) {
                serviceTerritoryBatch.WOLIBatch = WOLIBatch;
            }

            //Database.executeBatch(serviceTerritoryBatch, 100);
        }
        else {
            if(WOLIBatch != null) {
                Database.executeBatch(WOLIBatch, 3);
            }
        }
    }

}