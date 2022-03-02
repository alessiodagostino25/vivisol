public class DefaultBomConfigurationController {
    
    @AuraEnabled
    public static Boolean createDefaultBOM(List<Id> pricebookEntryIds, Id contractTreatmentJobId){
        System.debug('pricebookEntryIds size: ' + pricebookEntryIds.size());
        DefaultBomConfigurationService.createDefaultBOMService(pricebookEntryIds, contractTreatmentJobId);
        return true;
    }

    @AuraEnabled
    public static string getContractTreatmentJobName(Id contractTreatmentJobId){
        
        return DefaultBomConfigurationService.getContractTreatmentJobName(contractTreatmentJobId);
    }
}