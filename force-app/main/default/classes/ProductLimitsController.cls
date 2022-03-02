public class ProductLimitsController {

    //This method gets all Inactive Limits for the first page of the Product Limits configuration
    @AuraEnabled(cacheable=true)
    public static List<ProductLimitDTO> getInactiveLimits(String contractTreatmentId, String searchValue, List<String> allSelectedIds, String productType) {

        return ProductLimitsService.getInactiveLimits(contractTreatmentId, searchValue, allSelectedIds, productType);
    }

    //This method gets all Active Limits for the Product Limits Configuration (second page)
    @AuraEnabled(cacheable=true)
    public static List<ProductLimitDTO> getLimits(List<String> productIds/*unuseful*/, String contractTreatmentId, String productType, String searchValue) {
       
        return ProductLimitsService.getLimits(contractTreatmentId, productType, searchValue);
    }

    //This method updates selected Limits to the Status of "Active", and these will be passed to the second page
    @AuraEnabled
    public static void updateLimitsToActive(List<String> productIds, String contractTreatmentId){
        
        ProductLimitsService.updateLimitsToActive(productIds, contractTreatmentId);
    }

    //This method does not delete a Limit. Instead, it updates its Status to "Inactive"
    @AuraEnabled
    public static void deleteLimit(String limitId){
        
        ProductLimitsService.deleteLimit(limitId);
    }
}