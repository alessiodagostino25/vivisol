public class DefaultBomProductConfigurationController {
    
    @AuraEnabled//(cacheable=true)
    public static List<ContractTreatmentDefaultBomDTO> getDefaultBOMs(Id contractTreatmentJobId, String searchValue) {
        return DefaultBomProductConfigurationService.getDefaultBOMs(contractTreatmentJobId, searchValue);
    }

    @AuraEnabled 
    public static void deleteDefaultBOM(Id defaultBOMId) {
        DefaultBomProductConfigurationService.deleteDefaultBOM(defaultBOMId);
    }
}