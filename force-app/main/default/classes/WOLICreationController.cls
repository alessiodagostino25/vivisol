public class WOLICreationController {

    @AuraEnabled
    public static List<PricebookEntryDTO> getPricebookEntries(Id contractTreatmentJobId, String searchValue) {

        // Calling the same method used in DefaultBOM, but I don't have selectedIds to keep in search or Ids not to show, so I just pass empty lists

        return DefaultBomProductSelectionService.getPricebookEntries(contractTreatmentJobId, searchValue, new List<String>(), new List<Id>(), 20);
    }

    @AuraEnabled
    public static string getContractTreatmentJobId(Id workOrderId){
        WorkOrder wo = [SELECT Id, Contract_Treatment_Job__c FROM WorkOrder WHERE Id =: workOrderId];

        return wo.Contract_Treatment_Job__c;
    }

    @AuraEnabled
    public static void createWOLIs(Id pricebookEntryId, Id workOrderId, Decimal quantity, String assetId, String plantId, String storageLocationId, String movementType, Boolean billable){
        WOLICreationService.createWOLIs(pricebookEntryId, workOrderId, quantity, assetId, plantId, storageLocationId, movementType, billable);
    }

    @AuraEnabled
    public static Boolean checkForAssetDisabling(Id pricebookEntryId){
        PricebookEntry pe = [SELECT Product2.Type__c FROM PricebookEntry WHERE Id =: pricebookEntryId];
        System.debug('Product2.Type__c: ' + pe.Product2.Type__c);

        if(pe.Product2.Type__c == 'ZS01' || pe.Product2.Type__c == 'ZD01' || pe.Product2.Type__c == 'ZSER') {
            return false;
        }

        return true;
    }

    @AuraEnabled
    public static Boolean checkForLocationFieldsShowing(Id pricebookEntryId){
        PricebookEntry pe = [SELECT Product2.Type__c FROM PricebookEntry WHERE Id =: pricebookEntryId];
        System.debug('Product2.Type__c: ' + pe.Product2.Type__c);

        if(pe.Product2.Type__c == 'ZSER') {
            return false;
        }

        return true;
    }

    @AuraEnabled
    public static Contract_Treatment_Job_Product__c getRelatedCTJP(String pricebookEntryId, String workOrderId) {
        return WOLICreationService.getRelatedCTJP(pricebookEntryId, workOrderId);
    }

    @AuraEnabled
    public static String getWorkOrderDocumentType(String workOrderId) {
        List<String> workOrderQueryFields = new List<String>{'Document_Type__c'};

        List<WorkOrder> workOrderList = WorkOrderDAO.getWorkOrdersFromIds(workOrderQueryFields, new List<String>{workOrderId});

        if(workOrderList != null && !workOrderList.isEmpty()) {
            WorkOrder workOrder = workOrderList[0];

            if(workOrder != null) {
                return workOrder.Document_Type__c;
            }
        }

        return null;
    }

    @AuraEnabled
    public static String getSelectedProductType(String pricebookEntryId) {
        List<String> pricebookEntryQueryFields = new List<String>{'Product2Id'};
        List<String> productQueryFields = new List<String>{'Type__c'};

        List<String> productIds = new List<String>();

        List<PricebookEntry> pricebookEntryList = PricebookEntryDAO.getPricebookEntriesFromId(pricebookEntryQueryFields, new List<String>{pricebookEntryId});

        if(pricebookEntryList != null && !pricebookEntryList.isEmpty()) {
            PricebookEntry pricebookEntry = pricebookEntryList[0];

            productIds.add(pricebookEntry.Product2Id);
            List<Product2> productList = Product2DAO.getProduct2sFromIds(productQueryFields, productIds);

            if(productList != null && !productList.isEmpty()) {
                Product2 relatedProduct = productList[0];

                return relatedProduct.Type__c;
            }
        }

        return null;
    }
}