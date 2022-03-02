public class CorporateTreatmentJobProductController {

    //This method handles the data in the datatables for family/product selection
    @AuraEnabled(cacheable=true)
    public static List<CorporateTreatmentJobProductDTO> getCorporateTreatmentJobProduct(String corporateTreatment, String corporateTreatmentJob, 
    String contractFramework, String contractTreatmentJobId, String picklistValue, String searchValue, 
    List<String> selectedFamilyStrings, List<String> allSelectedIds) {

        return CorporateTreatmentJobProductService.getCorporateTreatmentJobProduct(corporateTreatment, corporateTreatmentJob, contractFramework, 
        contractTreatmentJobId, picklistValue, searchValue, selectedFamilyStrings, allSelectedIds);
    }

    //This method return the Product Types to show in the picklist for datatable's filter 
    @AuraEnabled(cacheable=true)
    public static List<ProductTypeDTO> getProductTypes(){
        return CorporateTreatmentJobProductService.getProductTypes();
    }

    //This method creates a new Contract Treatment Job Product
    @AuraEnabled
    public static void createCTJP(List<String> productsToCreate, String contractTreatmentJob) {
        CorporateTreatmentJobProductService.createCTJP(productsToCreate, contractTreatmentJob);
    }
    
    //This method gets the Contract Treatment Job Products to show in the configuration page
    @AuraEnabled(cacheable=true)
    public static List<CorporateTreatmentJobProductDTO> getCTJP(String contractTreatmentJob, String searchValue) {
        return CorporateTreatmentJobProductService.getCTJP(contractTreatmentJob, searchValue);
    }

    //This method gets Ids of Family products
    @AuraEnabled(cacheable=true)
    public static List<String> getFamilyIds(String contractTreatmentJob){
        return CorporateTreatmentJobProductService.getFamilyIds(contractTreatmentJob);
    }

    //This method gets Ids of Not-Family products
    @AuraEnabled(cacheable=true)
    public static List<String> getProductIds(String contractTreatmentJob){
        
        return CorporateTreatmentJobProductService.getProductIds(contractTreatmentJob);
    }

    //This method deletes a Contract Treatment Job Product
    @AuraEnabled
    public static void deleteProduct(String productId){
        CorporateTreatmentJobProductService.deleteProduct(productId);
    }

    @AuraEnabled
    public static List<TableAction> getCTJPTableActions(String contractTreatmentJobProductId){
        Contract_Treatment_Job_Product__c ctjp = [SELECT id, Contract_Treatment_Job__r.Contract_Framework__r.Status__c, Quantity__c, Last_Propagated_Quantity__c  from Contract_Treatment_Job_Product__c WHERE Id = :contractTreatmentJobProductId];
        String frameworkStatus = ctjp.Contract_Treatment_Job__r.Contract_Framework__r.Status__c;
        List<TableAction> actions = new List<TableAction>();
        if (frameworkStatus!='Inactive'){
            //Action: Configure
            TableAction configure = new TableAction();
            configure.label = 'Configure';
            configure.name = 'configure';
            actions.add(configure);
            
            if (frameworkStatus == 'Active'){
                TableAction manStatus = new TableAction();
                manStatus.label = 'Manage Status';
                manStatus.name = 'managestatus';
                actions.add(manStatus);
            }

            if (frameworkStatus == 'Draft'){
                TableAction deleteAction = new TableAction();
                deleteAction.label = 'Delete';
                deleteAction.name = 'delete';
                actions.add(deleteAction);
            }

            if ( ctjp.Last_Propagated_Quantity__c != ctjp.Quantity__c && frameworkStatus == 'Active'){
                //Action: Configure
                TableAction progateQuantity = new TableAction();
                progateQuantity.label = 'Propagate Quantity';
                progateQuantity.name = 'progateQuantity';
                actions.add(progateQuantity);
            }
        }
        return actions;
    }

    @AuraEnabled
    public static void propagateCTJPQuantity(String contractTreatmentJobProductId){
        system.debug('propagate Quantity');
        List<Contract_Treatment_Job_Product__c> contractProducts = [SELECT id, Contract_Treatment_Job__r.Contract_Framework__r.Status__c, Quantity__c, Last_Propagated_Quantity__c  from Contract_Treatment_Job_Product__c WHERE Id = :contractTreatmentJobProductId];
        for (Contract_Treatment_Job_Product__c ctjp : contractProducts){
            ctjp.Last_Propagated_Quantity__c = ctjp.Quantity__c;
        }

        List<String> jobs = new List<String>();
        jobs.add(contractTreatmentJobProductId); 

        BatchPropagateCTJPQuantityToATJP batchQuantity = new BatchPropagateCTJPQuantityToATJP();

        batchQuantity.contractTreatmentJobProductIds = jobs;
        batchQuantity.contractTreatmentJobProducts = contractProducts;

        Database.executeBatch(batchQuantity, 1000);
        update contractProducts;
    }

    @AuraEnabled
    public static void substituteCTJP(String oldContractTreatmentJobProduct, String newContractTreatmentJobProduct){
        Contract_Treatment_Job_Product__c oldContractProduct = [SELECT id, Status__c from Contract_Treatment_Job_Product__c where id = :oldContractTreatmentJobProduct];

        
        BatchPropagateSubstitute_CTJP batchPropagate = new BatchPropagateSubstitute_CTJP();

        batchPropagate.oldContractTreatmentJobProductId = oldContractTreatmentJobProduct;
        batchPropagate.newContractTreatmentJobProductId = newContractTreatmentJobProduct;

        Database.executeBatch(batchPropagate, 1000);

        oldContractProduct.Status__c = 'Inactive';
        update oldContractProduct;
    }

    @AuraEnabled
    public static Boolean checkIsFamilyCTJP(String contractTreatmentJobProduct){
        Contract_Treatment_Job_Product__c contractProduct = [SELECT id, Product__r.Product_Family__c from Contract_Treatment_Job_Product__c where id = :contractTreatmentJobProduct];
        if (contractProduct.Product__r.Product_Family__c == null){
            return true;
        } else{
            return false;
        }
    }

    @AuraEnabled
    public static Boolean checkForCTJPActivation(String CTJPId){
        return CorporateTreatmentJobProductService.checkForCTJPActivation(CTJPId);
    }

    @AuraEnabled
    public static String getCTJPFamily(String CTJPId){
        return CorporateTreatmentJobProductService.getCTJPFamily(CTJPId);
    }
}