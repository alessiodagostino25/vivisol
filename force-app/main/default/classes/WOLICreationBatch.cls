global class WOLICreationBatch implements Database.Batchable<sObject>, Database.Stateful{
    global List<WorkOrder> workOrders;
    global List<String> globalWorkOrderIds;
    global Map<Id, Account_Treatment_Job__c> ATJMap;
    global Map<Id, List<PricebookEntry>> pricebookIdToPEMap;
    global Map<Id, List<Account_Treatment_Job_Product__c>> jobToProductsMap;
    global List<WorkOrderLineItem> toRetry = new List<WorkOrderLineItem>();

    public Database.QueryLocator start(Database.BatchableContext bc) {
        List<Id> workOrderIds = new List<Id>();
        System.debug('workOrders: ' + workOrders);
        System.debug('globalWorkOrderIds: ' + globalWorkOrderIds);
        System.debug('ATJMap: ' + ATJMap);
        System.debug('pricebookIdToPEMap: ' + pricebookIdToPEMap);
        System.debug('jobToProductsMap: ' + jobToProductsMap);

        if(globalWorkOrderIds == null && workOrders != null) {
            for(WorkOrder wo : workOrders) {
                //wo.WOLI_Creation_Processing__c = true;
                workOrderIds.add(wo.Id);
            }
        }
        else {
            workOrderIds = globalWorkOrderIds;
        }

        System.debug('workOrderIds: ' + workOrderIds);

        //List<Database.SaveResult> results = Database.update(workOrders);

        String query = 'SELECT Id, Pricebook2Id, Account_Treatment_Job__c FROM WorkOrder WHERE Id IN: workOrderIds';
        System.debug(query);
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<WorkOrder> workOrdersToProcess) {
        Map<Id, List<Account_Treatment_Job_Product__c>> thisJobToProductsMap;
        Map<Id, List<PricebookEntry>> thisPricebookIdToPEMap;
        Map<Id, Account_Treatment_Job__c> thisATJMap;

        List<WorkOrderLineItem> toInsertWOLI = new List<WorkOrderLineItem>();

        if(ATJMap != null && pricebookIdToPEMap != null && jobToProductsMap != null) {
            thisATJMap = ATJMap;
            thisPricebookIdToPEMap = pricebookIdToPEMap;
            thisJobToProductsMap = jobToProductsMap;
        }
        else {
            thisJobToProductsMap = new Map<Id, List<Account_Treatment_Job_Product__c>>();
            thisPricebookIdToPEMap = new Map<Id, List<PricebookEntry>>();
            thisATJMap = new Map<Id, Account_Treatment_Job__c>();

            List<String> ATJQueryFields = new List<String>{'Scheduling_Rule__c', 'Work_Order__c', 'Task__c', 'Contract_Treatment_Job__c', 'Patient_Treatment__r.Account__c',
            'Patient_Treatment__c', 'Patient_Treatment__r.Contract_Treatment__c', 'Name', 'Case_Subtype__c', 'Case_Type__c', 'Patient_Treatment__r.Treatment_Type__c',
            'Contract_Treatment_Job__r.Contract_Framework__r.Customer__c', 
            'Contract_Treatment_Job__r.Contract_Framework__r.Branch_of_belonging_sales_office__c', 'Contract_Treatment_Job__r.Contract_Framework__c', 
            'Contract_Treatment_Job__r.Contract_Treatment__c', 'Delivery_Channel__c', 
            'Contract_Treatment_Job__r.Contract_Framework__r.Price_list_code__c',
            'Patient_Treatment__r.Customer_Purchase_Date__c', 'Patient_Treatment__r.Customer_Purchase_Order_Number__c', 'Patient_Treatment__r.Account__r.FirstName',
            'Patient_Treatment__r.Account__r.LastName', 'Work_Type__c', 'Patient_Treatment__r.Account__r.IsPersonAccount', 
            'Patient_Treatment__r.Account__r.PersonContactId', 'Frequency__c', 'Frequency_Unit_of_measure__c', 'Patient_Treatment__r.Prescription__r.CreatedDate',
            'Patient_Treatment__r.Prescription__r.Received_Date__c', 'Contract_Treatment_Job__r.Contract_Framework__r.Attachment_Addendum_Type__c',
            'Contract_Treatment_Job__r.Contract_Framework__r.Billing_Via__c', 'Contract_Treatment_Job__r.Contract_Framework__r.Customer__r.Customer_Purchase_Order_Date__c',
            'Contract_Treatment_Job__r.Contract_Framework__r.Customer_Purchase_Order_Date__c', 
            'Contract_Treatment_Job__r.Contract_Framework__r.Customer__r.Customer_Purchase_Order_Number__c',
            'Contract_Treatment_Job__r.Contract_Framework__r.Customer_Purchase_Order_Number__c', 
            'Contract_Treatment_Job__r.Contract_Framework__r.Customer__r.Billing_Reference__c', 'Contract_Treatment_Job__r.Contract_Framework__r.Customer_Request_Code__c',
            'Contract_Treatment_Job__r.Contract_Framework__r.Invoice_splitting_criterion__c', 'Contract_Treatment_Job__r.Contract_Framework__r.Invoice_Layout__c',
            'Contract_Treatment_Job__r.Invoice_Splitting_Group__c', 'Patient_Treatment__r.Customer_Request_Code__c', 
            'Patient_Treatment__r.Contract_Treatment__r.Invoice_Splitting_Group__c', 'Frequency_Type__c', 'Scheduling_Time_Frame__c'};
            List<String> productQueryFields = new List<String>{'Product__c', 'Quantity__c', 'Customer_Treatment_Alias__c', 'Patient_Treatment_Job__c',
            'Customer_Request_Code__c', 'Storage_Location__c', 'Plant__c', 'Purchase_order_number__c', 'Purchase_order_date__c', 
            'Contract_Treatment_Job_Product__r.Invoice_Splitting_group__c', 'Asset__c', 'Asset__r.SerialNumber'};
            List<String> PBEntryQueryFields = new List<String>{'Product2Id', 'Pricebook2Id'};

            List<String> ATJIds = new List<String>();
            List<String> pricebookIds = new List<String>();
            List<Account_Treatment_Job__c> relatedATJs = new List<Account_Treatment_Job__c>();

            for(WorkOrder wo : workOrdersToProcess) {
                if(wo.Account_Treatment_Job__c != null) {
                    ATJIds.add(wo.Account_Treatment_Job__c);
                }
            }

            if(!ATJIds.isEmpty()) {
                relatedATJs = AccountTreatmentJobDAO.getATJSFROMIds(ATJQueryFields, ATJIds);

                if(!relatedATJs.isEmpty()) {
                    for(Account_Treatment_Job__c atj : relatedATJs) {
                        thisATJMap.put(atj.Id, atj);
                    }
                }

                List<Account_Treatment_Job_Product__c> allProducts = AccountTreatmentJobProductDAO.getActiveProductsFromATJs(productQueryFields, ATJIds);

                for(Account_Treatment_Job__c atj : relatedATJs) {
                    pricebookIds.add(atj.Contract_Treatment_Job__r.Contract_Framework__r.Price_list_code__c);
                }

                // Getting all the pricebookEntries --> The pricebookEntry related to each Account_Treatment_Job__c

                List<PricebookEntry> allPricebookEntries = PricebookEntryDAO.getPEFromPricebookIds(PBEntryQueryFields, pricebookIds);

                if(!allPricebookEntries.isEmpty()) {
                    for(PricebookEntry pe : allPricebookEntries) {
                        if(thisPricebookIdToPEMap.get(pe.Pricebook2Id) == null) {
                            thisPricebookIdToPEMap.put(pe.Pricebook2Id, new List<PricebookEntry>());
                        }
                        thisPricebookIdToPEMap.get(pe.Pricebook2Id).add(pe);
                    }
                }

                // jobToProductMap links an Account_Treatment_Job__c Id to its Account_Treatment_Job_Products

                if(!allProducts.isEmpty()) {
                    for(Account_Treatment_Job_Product__c atjp : allProducts) {
                        if(thisJobToProductsMap.get(atjp.Patient_Treatment_Job__c) == null) {
                            thisJobToProductsMap.put(atjp.Patient_Treatment_Job__c, new List<Account_Treatment_Job_Product__c>());
                        }
                        thisJobToProductsMap.get(atjp.Patient_Treatment_Job__c).add(atjp);
                    }
                }
            }
        }

        for(WorkOrder wo : workOrdersToProcess) {
        
            List<Account_Treatment_Job_Product__c> productsRelatedToATJ = new List<Account_Treatment_Job_Product__c>();
            Account_Treatment_Job__c relatedATJ = thisATJMap.get(wo.Account_Treatment_Job__c);

            if(thisJobToProductsMap != null) {
                if(thisJobToProductsMap.get(relatedATJ.Id) != null) {
                    productsRelatedToATJ = thisJobToProductsMap.get(relatedATJ.Id);
                }

                if(!productsRelatedToATJ.isEmpty()) {
                    for(Account_Treatment_Job_Product__c atjp : productsRelatedToATJ) {

                        // Getting all the PricebookEntries related to the Pricebook2Id of the WorkOrder
                        List<PricebookEntry> PErelatedToPricebookId = thisPricebookIdToPEMap.get(wo.Pricebook2Id);
                        PricebookEntry relatedPE;

                        for(PricebookEntry pe : PErelatedToPricebookId) {
                            // Searching for the PricebookEntry that matches the Pricebook2Id of the WO and the current ATJP's Product__c
                            if(pe.Product2Id == atjp.Product__c) {
                                relatedPE = pe;
                                break;
                            }
                        }

                        // Creating the WOLI

                        WorkOrderLineItem newWOLI = new WorkOrderLineItem(
                            WorkOrderId = wo.Id,
                            PricebookEntryId = relatedPE.Id,
                            Quantity = atjp.Quantity__c,
                            Customer_Product_Code__c = atjp.Customer_Treatment_Alias__c,
                            Customer_Request_Code__c = atjp.Customer_Request_Code__c,
                            Customer_Purchase_Order_Number__c = atjp.Purchase_order_number__c,
                            Customer_Purchase_Order_Date__c = atjp.Purchase_order_date__c,
                            StorageLocation__c = atjp.Storage_Location__c,
                            Plant__c = atjp.Plant__c,
                            InvoiceSplittingGroup__c = atjp.Contract_Treatment_Job_Product__r.Invoice_Splitting_group__c,
                            Account_Treatment_Job_Product__c = atjp.Id,
                            AssetId = atjp.Asset__c,
                            Serial_Number__c = atjp.Asset__r.SerialNumber
                        );

                        toInsertWOLI.add(newWOLI);
                    }
                }
            }
        }

        if(!toInsertWOLI.isEmpty()) {
            System.debug('toInsertWOLI size: ' + toInsertWOLI.size());

            try {
                insert toInsertWOLI;
            }
            catch(DmlException e) {
                System.debug('Exception caught!');
                System.debug(e.getMessage());
                System.debug('--- Adding to toRetry... ---');
                toRetry.addAll(toInsertWOLI);
            }
        }
    }

    public void finish(Database.BatchableContext bc) {
        system.debug('DONE'); //TODO

        if(!toRetry.isEmpty()) {
            System.debug('--- Retrying failed records... ---');
            List<Database.SaveResult> results = Database.insert(toRetry, false);
        }
        /* for(WorkOrder wo : workOrders) {
            wo.WOLI_Creation_Processing__c = false;
        }

        List<Database.SaveResult> results = Database.update(workOrders); */
    }

}