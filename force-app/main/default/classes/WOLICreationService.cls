public class WOLICreationService {
    
    public static void createWOLIs(Id pricebookEntryId, Id workOrderId, Decimal quantity, String assetId, String plantId, String storageLocationId, String movementType, Boolean billable) {
        System.debug('PricebookEntryId: ' + pricebookEntryId);
        System.debug('workOrderId: ' + workOrderId);
        System.debug('quantity: ' + quantity);

        List<String> CTJPQueryFields = new List<String>{'Customer_Treatment_Alias__c', 'Customer_Request_Code__c', 'Purchase_order_number__c', 
        'Purchase_order_date__c', 'Invoice_Splitting_Group__c', 'Questionnaire__c', 'Questionnaire__r.ServiceReportTemplateId__c', 'Billable__c'};
        List<String> pricebookEntryQueryFields = new List<String>{'Product2Id'};
        List<String> workOrderQueryFields = new List<String>{'Contract_Treatment_Job__c'};
        List<String> productQueryFields = new List<String>{'Product_Family__c'};
        List<String> assetQueryFields = new List<String>{'SerialNumber'};

        List<Id> productIds = new List<Id>();
        List<WorkOrderLineItem> newWOLIs = new List<WorkOrderLineItem>();
        Id contractTreatmentJobId;
        Asset selectedAsset;

        // Setting the Asset if selected

        if(assetId != null && assetId != '') {
            List<Asset> assetList = AssetDAO.getAssetsFromIds(assetQueryFields, new List<String>{assetId});

            if(!assetList.isEmpty()) {
                selectedAsset = assetList[0];
            }
        }

        List<WorkOrder> workOrders = WorkOrderDAO.getWorkOrdersFromIds(workOrderQueryFields, new List<Id>{workOrderId});

        WorkOrder workOrder = workOrders[0];
        contractTreatmentJobId = workOrder.Contract_Treatment_Job__c;

        List<PricebookEntry> pricebookEntries = PricebookEntryDAO.getPricebookEntriesFromId(pricebookEntryQueryFields, new List<Id>{pricebookEntryId});

        System.debug('pricebookEntries: ' + pricebookEntries);

        for(PricebookEntry pe : pricebookEntries) {
            productIds.add(pe.Product2Id);
        }

        System.debug('productIds: ' + productIds);
        System.debug('CTJId: ' + contractTreatmentJobId);

        List<Product2> relatedProducts = Product2DAO.getProduct2sFromIds(productQueryFields, productIds);

        for(Product2 p : relatedProducts) {
            if(p.Product_Family__c != null) {
                productIds.add(p.Product_Family__c);
            }
        }

        if(!productIds.isEmpty() && contractTreatmentJobId != null) {
            List<Contract_Treatment_Job_Product__c> relatedCTJPs = ContractTreatmentJobProductDAO.getCTJPsFromJobAndProductsFamilyAndSingle(CTJPQueryFields, productIds, contractTreatmentJobId);
            System.debug('relatedCTJPs: ' + relatedCTJPs);

            for(Contract_Treatment_Job_Product__c ctjp : relatedCTJPs) {
                WorkOrderLineItem newWOLI = new WorkOrderLineItem(
                    WorkOrderId = workOrderId,
                    Quantity = quantity,
                    PricebookEntryId = pricebookEntryId,
                    Customer_Product_Code__c = ctjp.Customer_Treatment_Alias__c,
                    Customer_Request_Code__c = ctjp.Customer_Request_Code__c,
                    Customer_Purchase_Order_Number__c = ctjp.Purchase_order_number__c,
                    Customer_Purchase_Order_Date__c = ctjp.Purchase_order_date__c,
                    InvoiceSplittingGroup__c = ctjp.Invoice_Splitting_group__c,
                    Questionnaire__c = ctjp.Questionnaire__c,
                    ServiceReportTemplateId = ctjp.Questionnaire__r.ServiceReportTemplateId__c,
                    Movement_Type__c = movementType,
                    Billable__c = billable
                );

                if(selectedAsset != null) {
                    newWOLI.AssetId = selectedAsset.Id;
                    newWOLI.Serial_Number__c = selectedAsset.SerialNumber;
                }

                if(plantId != null && plantId != '') {
                    newWOLI.Plant__c = plantId;
                }

                if(storageLocationId != null && storageLocationId != '') {
                    newWOLI.StorageLocation__c = storageLocationId;
                }

                newWOLIs.add(newWOLI);
                
                System.debug('newWOLI: ' + newWOLI);
            }

            if(!newWOLIs.isEmpty()) {
                insert newWOLIs;
            }

            System.debug('NewWOLIs inserted: ' + newWOLIs.size());
        }
    }

    public static Contract_Treatment_Job_Product__c getRelatedCTJP(String pricebookEntryId, String workOrderId) {
        System.debug('PricebookEntryId: ' + pricebookEntryId);
        System.debug('workOrderId: ' + workOrderId);

        List<String> CTJPQueryFields = new List<String>{'Customer_Treatment_Alias__c', 'Customer_Request_Code__c', 'Purchase_order_number__c', 
        'Purchase_order_date__c', 'Invoice_Splitting_Group__c', 'Questionnaire__c', 'Questionnaire__r.ServiceReportTemplateId__c', 'Billable__c',
        'Plant__c', 'Storage_Location__c'};
        List<String> pricebookEntryQueryFields = new List<String>{'Product2Id'};
        List<String> workOrderQueryFields = new List<String>{'Contract_Treatment_Job__c'};
        List<String> productQueryFields = new List<String>{'Product_Family__c'};

        List<Id> productIds = new List<Id>();
        Id contractTreatmentJobId;
        Contract_Treatment_Job_Product__c relatedCTJP;

        List<WorkOrder> workOrders = WorkOrderDAO.getWorkOrdersFromIds(workOrderQueryFields, new List<Id>{workOrderId});

        WorkOrder workOrder = workOrders[0];
        contractTreatmentJobId = workOrder.Contract_Treatment_Job__c;

        List<PricebookEntry> pricebookEntries = PricebookEntryDAO.getPricebookEntriesFromId(pricebookEntryQueryFields, new List<Id>{pricebookEntryId});

        System.debug('pricebookEntries: ' + pricebookEntries);

        for(PricebookEntry pe : pricebookEntries) {
            productIds.add(pe.Product2Id);
        }

        System.debug('productIds: ' + productIds);
        System.debug('CTJId: ' + contractTreatmentJobId);

        List<Product2> relatedProducts = Product2DAO.getProduct2sFromIds(productQueryFields, productIds);

        for(Product2 p : relatedProducts) {
            if(p.Product_Family__c != null) {
                productIds.add(p.Product_Family__c);
            }
        }

        if(!productIds.isEmpty() && contractTreatmentJobId != null) {
            List<Contract_Treatment_Job_Product__c> relatedCTJPs = ContractTreatmentJobProductDAO.getCTJPsFromJobAndProductsFamilyAndSingle(CTJPQueryFields, productIds, contractTreatmentJobId);
            System.debug('relatedCTJPs: ' + relatedCTJPs);

            if(relatedCTJPs != null) {
                relatedCTJP = relatedCTJPs[0];
            }
        }

        return relatedCTJP;
    }
}