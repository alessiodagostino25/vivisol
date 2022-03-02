public class DefaultBomConfigurationService {
    
    public static void createDefaultBOMService(List<Id> pricebookEntryIds, Id contractTreatmentJobId) {
        List<String> queryFields = new List<String>{'Product2Id', 'Product2.Product_Family__c'};
        List<String> queryFieldsForCTJP = new List<String>{'Product__c', 'Family__c'};
        List<Contract_Treatment_Default_BOM__c> toInsert = new List<Contract_Treatment_Default_BOM__c>();
        List<Id> productIds = new List<Id>();
        List<Id> product2OfJob = new List<Id>();
        Map<Id, Contract_Treatment_Job_Product__c> CTJPMap = new Map<Id, Contract_Treatment_Job_Product__c>();

        // Getting all the CTJP for the Job
        List<Contract_Treatment_Job_Product__c> relatedToJob = ContractTreatmentJobProductDAO.getCTJPsFromJob(queryFieldsForCTJP, contractTreatmentJobId);

        // List of all the Product2 associated to the CTJPs of the Job
        for(Contract_Treatment_Job_Product__c ctjp : relatedToJob) {
            product2OfJob.add(ctjp.Product__c);
            CTJPMap.put(ctjp.Product__c, ctjp);
        }

        // Getting all the PricebookEntries from the Ids
        List<PricebookEntry> pricebookEntries = PricebookEntryDAO.getPricebookEntriesFromId(queryFields, pricebookEntryIds);

        // List of all the Product2 associated to the selected PricebookEntries
        for(PricebookEntry pe : pricebookEntries) {
            productIds.add(pe.Product2Id);
        }
        
        // Check whether the Product2 associated to the PricebookEntries is present in the list of Product2 associated to the CTJPs of the Job. If not, refer to the Family
        for(PricebookEntry pe : pricebookEntries) {
            Id pricebookEntryProductId = pe.Product2Id;
            if(product2OfJob.contains(pricebookEntryProductId)) {
                System.debug('Contains Product');
                Contract_Treatment_Job_Product__c relatedCTJP = CTJPMap.get(pricebookEntryProductId);
                Contract_Treatment_Default_BOM__c newDefaultBOM = new Contract_Treatment_Default_BOM__c(
                    Contract_Treatment_Job_Product__c = relatedCTJP.Id,
                    Product__c = pricebookEntryProductId
                );
                toInsert.add(newDefaultBOM);
            }
            // This is when the selected PricebookEntries are from a Product related to a Family (and only the family is present in the CTJPs list)
            else {
                Id productFamilyId = pe.Product2.Product_Family__c;
                if(product2OfJob.contains(productFamilyId)) {
                    System.debug('Does not contain Product, but contains family');
                    Contract_Treatment_Job_Product__c relatedCTJP = CTJPMap.get(productFamilyId);
                    Contract_Treatment_Default_BOM__c newDefaultBOM = new Contract_Treatment_Default_BOM__c(
                        Contract_Treatment_Job_Product__c = relatedCTJP.Id,
                        Product__c = pricebookEntryProductId
                    );
                    toInsert.add(newDefaultBOM);
                }
            }
        }

        if(!toInsert.isEmpty()) {
            insert toInsert;
        }
        System.debug('Created DefaultBOMs: ' + toInsert.size());
    }

    public static String getContractTreatmentJobName(Id contractTreatmentJobId){
        Contract_Treatment_Job__c ctj = ContractTreatmentJobDAO.getContractTreatmentJobByCTJId(contractTreatmentJobId);

        return ctj.Name;
    }
}