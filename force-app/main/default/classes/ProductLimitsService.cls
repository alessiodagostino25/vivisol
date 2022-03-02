public class ProductLimitsService {
    
    //This method gets all Inactive Limits for the first page of the Product Limits configuration
    @AuraEnabled(cacheable=true)
    public static List<ProductLimitDTO> getInactiveLimits(String contractTreatmentId, String searchValue, List<String> allSelectedIds, String productType) {

        List<ProductLimitDTO> dtoList = new List<ProductLimitDTO>();
        List<Contract_Product_Limit__c> inactiveLimits = new List<Contract_Product_Limit__c>();
        String toSearch = '%' + searchValue + '%';

        List<Contract_Product_Limit__c> inactiveSelectedLimits = ProductLimitsDAO.getInactiveSelectedLimits(contractTreatmentId, allSelectedIds);

        //Different queries for different filter combinations
        if(searchValue == '' && productType == '') {
            inactiveLimits = ProductLimitsDAO.getInactiveLimitsWithoutFilters(contractTreatmentId);
        }
        else if(searchValue == '' && productType == 'products') {
            inactiveLimits = ProductLimitsDAO.getInactiveLimitsTypeProducts(contractTreatmentId);
        }
        else if(searchValue == '' && productType == 'services') {
            inactiveLimits = ProductLimitsDAO.getInactiveLimitsTypeServices(contractTreatmentId);
        }
        else if(searchValue != '' && productType == '') {
            inactiveLimits = ProductLimitsDAO.getInactiveLimitsWithSearchValue(contractTreatmentId, toSearch);
        }
        else if(searchValue != '' && productType == 'products') {
            inactiveLimits = ProductLimitsDAO.getInactiveLimitsProductsWithSearch(contractTreatmentId, toSearch);
        }
        else if(searchValue != '' && productType == 'services') {
            inactiveLimits = ProductLimitsDAO.getInactiveLimitsServicesWithSearch(contractTreatmentId, toSearch);
        }

        for(Contract_Product_Limit__c l : inactiveSelectedLimits) {
            if(!inactiveLimits.contains(l)) {
                inactiveLimits.add(l);
            }
        }
        //Return DTOs for Product Limits
        for(Contract_Product_Limit__c l : inactiveLimits) {
            ProductLimitDTO dto = new ProductLimitDTO((String) l.Id, l.Name, (String) l.Contract_Treatment__c, (Integer) l.Frequency__c, l.Frequency_Unit_of_measure__c, 
            (Integer) l.Max_Quantity__c, (Integer) l.Min_Quantity__c, (String) l.Product__c, l.Product__r.Name, (String) l.Product__r.Product_Code__c, l.Quantity_Unit_of_measure__c, l.Status__c, l.Configured_Checkbox__c);
            dtoList.add(dto);
        }
        return dtoList;
    }

    //This method gets all Active Limits for the Product Limits Configuration (second page)
    @AuraEnabled(cacheable=true)
    public static List<ProductLimitDTO> getLimits(String contractTreatmentId, String productType, String searchValue) {
       
        List<Contract_Product_Limit__c> limits = new List<Contract_Product_Limit__c>();
        List<ProductLimitDTO> dtoList = new List<ProductLimitDTO>();
        String toSearch = '%' + searchValue + '%';

        //Different queries for different filter combinations
        if(searchValue == '' && productType == '') {
            limits = ProductLimitsDAO.getLimitsWithoutFilters(contractTreatmentId);
        }
        else if(searchValue == '' && productType == 'products') {
            limits = ProductLimitsDAO.getLimitsTypeProducts(contractTreatmentId);
        }
        else if(searchValue == '' && productType == 'services') {
            limits = ProductLimitsDAO.getLimitsTypeServices(contractTreatmentId);
        }
        else if(searchValue != '' && productType == '') {
            limits = ProductLimitsDAO.getLimitsWithSearchValue(contractTreatmentId, toSearch);
        }
        else if(searchValue != '' && productType == 'products') {
            limits = ProductLimitsDAO.getLimitsProductsWithSearch(contractTreatmentId, toSearch);
        }
        else if(searchValue != '' && productType == 'services') {
            limits = ProductLimitsDAO.getLimitsServicesWithSearch(contractTreatmentId, toSearch);
        }
       
        //Return DTOs for Product Limits
        for(Contract_Product_Limit__c l : limits) {
            ProductLimitDTO dto = new ProductLimitDTO((String) l.Id, l.Name, (String) l.Contract_Treatment__c, (Integer) l.Frequency__c, l.Frequency_Unit_of_measure__c, 
            (Integer) l.Max_Quantity__c, (Integer) l.Min_Quantity__c, (String) l.Product__c, l.Product__r.Name, (String)l.Product__r.Product_Code__c, l.Quantity_Unit_of_measure__c, l.Status__c, l.Configured_Checkbox__c);
            dtoList.add(dto);
        }
        return dtoList;
    }

    //This method updates selected Limits to the Status of "Active", and these will be passed to the second page
    @AuraEnabled
    public static void updateLimitsToActive(List<String> productIds, String contractTreatmentId){
        List<Contract_Product_Limit__c> toUpdate = ProductLimitsDAO.getLimitsToUpdate(productIds, contractTreatmentId);
        for(Contract_product_Limit__c cpl : toUpdate) {
            if(cpl.Status__c != 'Active') {
                cpl.Status__c = 'Active';
            }
        }
        update toUpdate;
    }

    //This method does not delete a Limit. Instead, it updates its Status to "Inactive"
    @AuraEnabled
    public static void deleteLimit(String limitId){
        Contract_Product_Limit__c toDelete = ProductLimitsDAO.getLimitToDelete(limitId);
        if(toDelete.Status__c == 'Active') {
            toDelete.Status__c = 'Inactive';
            toDelete.Frequency__c = null;
            toDelete.Frequency_Unit_of_measure__c = null;
            toDelete.Max_Quantity__c = null;
            toDelete.Min_Quantity__c = null;
            toDelete.Quantity_Unit_of_measure__c = null;
            update toDelete;
        }
    }
}