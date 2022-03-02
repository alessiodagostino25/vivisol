public class ATJProductTriggerService {
    
    /* public static void autoscheduleActivities(List<Id> assetProductIds, Boolean isRescheduling, Map<Id, WorkOrder> assetProductToFirstWOMap, 
    Map<Id, Task> assetProductToFirstTaskMap) {
        List<String> queryFieldsForATJP = new List<String>{'Asset__c', 'Patient_Treatment_Job__r.Patient_Treatment__c', 'Product__c', 'Quantity__c', 
        'Customer_Treatment_Alias__c', 'Patient_Treatment_Job__c', 'Customer_Request_Code__c', 'Patient_Treatment_Job__r.Patient_Treatment__r.Status__c',
        'Patient_Treatment_Job__r.Patient_Treatment__r.RecordType.DeveloperName', 'Purchase_order_number__c', 'Purchase_order_date__c',
        'Storage_Location__c', 'Plant__c', 'Contract_Treatment_Job_Product__r.Invoice_Splitting_group__c', 'Asset__c'};
        List<String> queryFieldsForAssets = new List<String>{'Id', 'LocationId', 'Location.VisitorAddress.City', 'Location.VisitorAddress.Country', 
		'Location.VisitorAddress.CountryCode', 'Location.VisitorAddress.Latitude', 'Location.VisitorAddress.Longitude', 'Location.VisitorAddress.PostalCode', 
        'Location.VisitorAddress.State', 'Location.VisitorAddress.StateCode', 'Location.VisitorAddress.Street', 'SerialNumber'}; 
        List<String> queryFieldsForATJ = new List<String>{'Scheduling_Rule__c', 'Work_Order__c', 'Task__c', 'Contract_Treatment_Job__c', 'Patient_Treatment__r.Account__c',
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
        'Contract_Treatment_Job__r.Contract_Framework__r.Customer__r.Customer_Purchase_Order_Number__c',
        'Contract_Treatment_Job__r.Contract_Framework__r.Customer__r.Billing_Reference__c', 
        'Contract_Treatment_Job__r.Contract_Framework__r.Invoice_splitting_criterion__c', 'Contract_Treatment_Job__r.Contract_Framework__r.Invoice_Layout__c',
        'Contract_Treatment_Job__r.Invoice_Splitting_Group__c', 'Patient_Treatment__r.Customer_Request_Code__c', 
        'Patient_Treatment__r.Contract_Treatment__r.Invoice_Splitting_Group__c', 'Customer_Product_Code__c'};

        List<Account_Treatment_Job__c> jobsWithAssetProducts = new List<Account_Treatment_Job__c>();
        List<Id> ATJIds = new List<Id>();
        List<Id> assetIds = new List<Id>();
        List<Asset> assets = new List<Asset>();

        Map<Id, List<Account_Treatment_Job_Product__c>> jobToNotAssetProductsMap = new Map<Id, List<Account_Treatment_Job_Product__c>>();
        Map<Id, Asset> assetMap = new Map<Id, Asset>();

        List<Account_Treatment_Job_Product__c> assetProducts = AccountTreatmentJobProductDAO.getAssetActiveProductsFromIds(queryFieldsForATJP, assetProductIds);

        System.debug('Products linked to an Asset inserted into an active Maintenance Treatment: ' + assetProducts);

        if(assetProducts != null) {

            for(Account_Treatment_Job_Product__c atjp : assetProducts) {
                ATJIds.add(atjp.Patient_Treatment_Job__c);
                assetIds.add(atjp.Asset__c);
            }

            List<Account_Treatment_Job_Product__c> notAssetATJPs = AccountTreatmentJobProductDAO.getNotAssetActiveProductsFromATJs(queryFieldsForATJP, ATJIds);
            jobsWithAssetProducts = AccountTreatmentJobDAO.getATJSFROMIds(queryFieldsForATJ, ATJIds);

            if(notAssetATJPs != null) {
                // This links a job to the list of its Products not linked to an Asset
                for(Account_Treatment_Job_Product__c atjp : notAssetATJPs) {
                    if(jobToNotAssetProductsMap.get(atjp.Patient_Treatment_Job__c) == null) {
                        jobToNotAssetProductsMap.put(atjp.Patient_Treatment_Job__c, new List<Account_Treatment_Job_Product__c>());
                    }
                    jobToNotAssetProductsMap.get(atjp.Patient_Treatment_Job__c).add(atjp);
                }
            }

            if(!assetIds.isEmpty()) {
                assets = AssetDAO.getAssetsFromIds(queryFieldsForAssets, assetIds);
            }

            for(Asset a : assets) {
                assetMap.put(a.Id, a);
            }

            // This batch will autoschedule Cases, Tasks and WOs for each Product linked to an asset in assetProducts (only one)

            AutoscheduleActivitiesMaintenanceBatch autoscheduleBatch = new AutoscheduleActivitiesMaintenanceBatch();
            autoscheduleBatch.jobsWithAssetProducts = jobsWithAssetProducts;
            autoscheduleBatch.assetProducts = assetProducts;
            autoscheduleBatch.notAssetATJPs = notAssetATJPs;
            autoscheduleBatch.jobToNotAssetProductsMap = jobToNotAssetProductsMap;
            autoscheduleBatch.assetMap = assetMap;
            autoscheduleBatch.isRescheduling = isRescheduling;
            autoscheduleBatch.assetProductToFirstWOMap = assetProductToFirstWOMap;
            autoscheduleBatch.assetProductToFirstTaskMap = assetProductToFirstTaskMap;

            Database.executeBatch(autoscheduleBatch, 1);
        }
    } */

    public static List<WorkOrderLineItem> createWOLIs(List<Id> ATJPIds) {
        List<String> ATJPQueryFields = new List<String>{'Quantity__c', 'Customer_Treatment_Alias__c', 'Customer_Request_Code__c', 'Purchase_order_number__c',
        'Purchase_order_date__c', 'Storage_Location__c', 'Plant__c', 'Contract_Treatment_Job_Product__r.Invoice_Splitting_group__c', 'Patient_Treatment_Job__c',
        'Product__c', 'Asset__c'};
        List<String> workOrderQueryFields = new List<String>{'Id', 'Pricebook2Id', 'Account_Treatment_Job__c'};
        List<String> pricebookEntryQueryFields = new List<String>{'Pricebook2Id', 'Product2Id'};

        List<Id> relatedATJIds = new List<Id>();
        List<Id> relatedProductIds = new List<Id>();
        List<WorkOrderLineItem> newWOLIs = new List<WorkOrderLineItem>();

        Map<Id, List<WorkOrder>> ATJIdToWOsMap = new Map<Id, List<WorkOrder>>();
        Map<Id, List<PricebookEntry>> productIdToPEsMap = new Map<Id, List<PricebookEntry>>();

        List<Account_Treatment_Job_Product__c> ATJPs = AccountTreatmentJobProductDAO.getATJPsFromIds(ATJPQueryFields, ATJPIds);

        for(Account_Treatment_Job_Product__c atjp : ATJPs) {
            relatedATJIds.add(atjp.Patient_Treatment_Job__c);
            relatedProductIds.add(atjp.Product__c);
        }

        // Getting all the new WorkOrders related to the ATJs related to the newly created not-Asset ATJPs

        List<WorkOrder> relatedNewWorkOrders = WorkOrderDAO.getNewYOV0WorkOrdersFromATJIds(workOrderQueryFields, relatedATJIds);

        // Building a ATJ.Id --> List<Related WO> Map

        if(relatedNewWorkOrders != null) {
            for(WorkOrder wo : relatedNewWorkOrders) {
                if(ATJIdToWOsMap.get(wo.Account_Treatment_Job__c) == null) {
                    ATJIdToWOsMap.put(wo.Account_Treatment_Job__c, new List<WorkOrder>());
                }
                ATJIdToWOsMap.get(wo.Account_Treatment_Job__c).add(wo);
            }
        }

        // Getting all the PricebookEntries related to the Product2s (via ATJP.Product__c) of the newly created not-Asset ATJPs

        List<PricebookEntry> allRelatedPricebookEntries = PricebookEntryDAO.getPEFromProductIds(pricebookEntryQueryFields, relatedProductIds);

        if(allRelatedPricebookEntries != null) {
            for(PricebookEntry pe : allRelatedPricebookEntries) {
                if(productIdToPEsMap.get(pe.Product2Id) == null) {
                    productIdToPEsMap.put(pe.Product2Id, new List<PricebookEntry>());
                }
                productIdToPEsMap.get(pe.Product2Id).add(pe);
            }
        }

        // For each new ATJP, getting the WOs related to its ATJ and the PricebookEntries related to its Product__c

        if(!ATJIdToWOsMap.isEmpty() && !productIdToPEsMap.isEmpty()) {
            for(Account_Treatment_Job_Product__c atjp : ATJPs) {
                List<WorkOrder> relatedWorkOrders = ATJIdToWOsMap.get(atjp.Patient_Treatment_Job__c);
                List<PricebookEntry> relatedPricebookEntries = productIdToPEsMap.get(atjp.Product__c);

                Map<Id, PricebookEntry> pricebookIdToPEMap = new Map<Id, PricebookEntry>();

                // Using a double map to get the right PricebookEntry (matching Product2Id from ATJP and Pricebook2Id from WO)

                for(PricebookEntry pe : relatedPricebookEntries) {
                    pricebookIdToPEMap.put(pe.Pricebook2Id, pe);
                }

                if(relatedWorkOrders != null && relatedPricebookEntries != null) {
                    System.debug('relatedWorkOrders size: ' + relatedWorkOrders.size());

                    // For each WO related to the ATJ related to the ATJP, getting the exact PricebookEntry matching its Pricebook2Id and the Product2Id of the ATJP

                    for(WorkOrder wo : relatedWorkOrders) {
                        PricebookEntry relatedPricebookEntry = pricebookIdToPEMap.get(wo.Pricebook2Id);

                        // Creating new WOLI

                        if(relatedPricebookEntry != null) {
                            WorkOrderLineItem newWOLI = new WorkOrderLineItem(
                                WorkOrderId = wo.Id,
                                PricebookEntryId = relatedPricebookEntry.Id,
                                Quantity = atjp.Quantity__c,
                                Customer_Product_Code__c = atjp.Customer_Treatment_Alias__c,
                                Customer_Request_Code__c = atjp.Customer_Request_Code__c,
                                Customer_Purchase_Order_Number__c = atjp.Purchase_order_number__c,
                                Customer_Purchase_Order_Date__c = atjp.Purchase_order_date__c,
                                Account_Treatment_Job_Product__c = atjp.Id,
                                StorageLocation__c = atjp.Storage_Location__c,
                                Plant__c = atjp.Plant__c,
                                InvoiceSplittingGroup__c = atjp.Contract_Treatment_Job_Product__r.Invoice_Splitting_Group__c,
                                AssetId = atjp.Asset__c
                            );

                            newWOLIs.add(newWOLI);
                        }
                    }
                }
            }
        }

        System.debug('createWOLIs, newWOLIs: ' + newWOLIs.size());
        return newWOLIs;

    }
    public static void deactivationOfWoandWoli(List<Id> atjpIds, List<Id> atjsIds,List<Id> atjpAssetIds) {

        //scenario 1
        //deactivation of wo
        List<WO_Delete_Configuration__mdt> configswo = new List<WO_Delete_Configuration__mdt>();
        configswo = WODeleteConfigurationDAO.getAllWODeleteConfigs();
        List<String> woFields = new List<String>();
        Map<String,String> woFieldValueMap = new Map<String,String>();
        for (WO_Delete_Configuration__mdt configwo : configswo){
            woFields.add(configwo.Field_API_Name__c);
            woFieldValueMap.put(configwo.Field_API_Name__c, configwo.Field_Value__c);
        }
        woFields.add('CaseId');
        woFields.add('EndDate');
     
        List<WorkOrder> queriedWO = WorkOrderDAO.getWOFromATJPS(woFields, atjsIds,atjpAssetIds);

        for (WorkOrder  wo : queriedWO) {

            
        }
        List<Id> caseIds = new List<Id>();
        if (!queriedWO.isEmpty()){
            for(WorkOrder wo : queriedWO){
                caseIds.add(wo.CaseId);
                for (WO_Delete_Configuration__mdt configwo : configswo){
                    wo.put(configwo.Field_API_Name__c, woFieldValueMap.get(configwo.Field_API_Name__c));
                }
            }
            update queriedWO;
        }


        //deactivation of woli 
        List<WOLI_Delete_Configuration__mdt> configs = new List<WOLI_Delete_Configuration__mdt>();
        configs = WOLIDeleteConfigurationDAO.getAllWOLIDeleteConfigs();
        List<String> woliFields = new List<String>();
        Map<String,String> woliFieldValueMap = new Map<String,String>();
        for (WOLI_Delete_Configuration__mdt config : configs){
            woliFields.add(config.Field_API_Name__c);
            woliFieldValueMap.put(config.Field_API_Name__c, config.Field_Value__c);
        }
        
        List<WorkOrderLineItem> queriedWOLIs = WorkOrderLineItemDAO.getWOLIsFromATJPS(woliFields, atjpIds);
            if (!queriedWOLIs.isEmpty()){
                for(WorkOrderLineItem woli : queriedWOLIs){
                    for (WOLI_Delete_Configuration__mdt config : configs){
                        woli.put(config.Field_API_Name__c, woliFieldValueMap.get(config.Field_API_Name__c));
                    }
                }
                update queriedWOLIs;
            }

         //cancellation of case ids
         List<String> queryFields = new List<String>{'Status','Id'};
         List<Case> queriedCases = CaseDAO.getCasesFromIds(queryFields, caseIds);
         List<Case> updateCases = new List<Case>();
         for (Case c : queriedCases) {
             c.Status = 'Canceled'; 
             updateCases.add(c); 
         }
         if (!updateCases.isEmpty()) {
                update updateCases ;
         }

         //cancellation of tasks 
         List<String> queryFieldsfortasks = new List<String>{'Status','Id'};
         List<Task> queriedTasks = TaskDAO.getTasksFromWhatIds(queryFieldsfortasks,caseIds);
         List<Task> updateTasks = new List<Task>();
         for (Task t : queriedTasks) {
             t.Status ='Canceled'; 
             updateTasks.add(t); 
         }
         if (!updateTasks.isEmpty()) {
             update updateTasks;
         }

        //scenario 2
        Group preplanner = [SELECT Id FROM Group WHERE Name = 'Preplanner_NL' AND Type = 'Queue'];
   
    
        List<WorkOrder> queriedWO2 = WorkOrderDAO.checkWOFromATJPS(woFields, atjsIds ,atjpAssetIds);
        String Subject  =   System.Label.AccountTreatmentJobProduct_PropagateWOSubject;
        string Description = System.Label.AccountTreatmentJobProduct_PropagateWODescription;
        List<Task> insertTasks = new List<Task>();
        if (!queriedWO2.isEmpty()) {
            for (WorkOrder wo : queriedWO2) {
                Task t = new Task();
                t.WhatId = wo.CaseId ;
                t.Subject = Subject ;
                t.Description  = Description ;
                DateTime dT =  wo.EndDate;
                t.ActivityDate = date.newinstance(dT.year(), dT.month(), dT.day());
                t.OwnerId = preplanner.Id;
                insertTasks.add(t);
            }
        }
        insert insertTasks;

    }

    public static List<WorkOrderLineItem> updateRelatedWOLIs(List<Account_Treatment_Job_Product__c> ATJPs, Map<Id, Account_Treatment_Job_Product__c> oldMap) {
        List<String> WOLIQueryFields = new List<String>{'Plant__c', 'StorageLocation__c', 'AssetId', 'Account_Treatment_Job_Product__c'};

        List<Account_Treatment_Job_Product__c> changedATJPs = new List<Account_Treatment_Job_Product__c>();
        List<String> changedATJPIds = new List<String>();
        List<WorkOrderLineItem> allRelatedWOLIs = new List<WorkOrderLineItem>();
        List<WorkOrderLineItem> WOLIsToUpdate = new List<WorkOrderLineItem>();

        Map<String, List<WorkOrderLineItem>> ATJPToWOLIsMap = new Map<String, List<WorkOrderLineItem>>();

        for(Account_Treatment_Job_Product__c atjp : ATJPs) {
            Account_Treatment_Job_Product__c oldATJP = oldMap.get(atjp.Id);

            // Keeping all the ATJPs in which whether Asset__c, Plant__c or Storage_Location__c has changed

            if(oldATJP != null) {
                if(oldATJP.Asset__c != atjp.Asset__c || oldATJP.Plant__c != atjp.Plant__c || oldATJP.Storage_Location__c != atjp.Storage_Location__c) {
                    changedATJPs.add(atjp);
                    changedATJPIds.add(atjp.Id);
                }
            }
        }

        if(!changedATJPIds.isEmpty()) {
            allRelatedWOLIs = WorkOrderLineItemDAO.getWOLIsFromATJPS(WOLIQueryFields, changedATJPIds);

            // Building a ATJP.Id --> List<Linked WOLIs> map

            if(!allRelatedWOLIs.isEmpty()) {
                for(WorkOrderLineItem woli : allRelatedWOLIs) {
                    if(ATJPToWOLIsMap.get(woli.Account_Treatment_Job_Product__c) == null) {
                        ATJPToWOLIsMap.put(woli.Account_Treatment_Job_Product__c, new List<WorkOrderLineItem>());
                    }
                    ATJPToWOLIsMap.get(woli.Account_Treatment_Job_Product__c).add(woli);
                }

                for(Account_Treatment_Job_Product__c atjp : changedATJPs) {
                    List<WorkOrderLineItem> relatedWOLIs = ATJPToWOLIsMap.get(atjp.Id);
                    Account_Treatment_Job_Product__c oldATJP = oldMap.get(atjp.Id);

                    // For each ATJP, seeing which field has changed and updating the related one on the related WOLIs

                    if(relatedWOLIs != null && !relatedWOLIs.isEmpty() && oldATJP != null) {
                        for(WorkOrderLineItem woli : relatedWOLIs) {
                            if(oldATJP.Asset__c != atjp.Asset__c) {
                                woli.AssetId = atjp.Asset__c;
                            }

                            if(oldATJP.Plant__c != atjp.Plant__c) {
                                woli.Plant__c = atjp.Plant__c;
                            }

                            if(oldATJP.Storage_Location__c != atjp.Storage_Location__c) {
                                woli.StorageLocation__c = atjp.Storage_Location__c;
                            }

                            WOLIsToUpdate.add(woli);
                        }
                    }
                }
            }
        }

        return WOLIsToUpdate;
    }
}