public class DefaultBomProductConfigurationService {
    
    public static List<ContractTreatmentDefaultBomDTO> getDefaultBOMs(Id contractTreatmentJobId, String searchValue) {
        List<ContractTreatmentDefaultBomDTO> toReturn = new List<ContractTreatmentDefaultBomDTO>();
        List<Contract_Treatment_Default_BOM__c> defaultBOMs = new List<Contract_Treatment_Default_BOM__c>();

        List<String> queryFields = new List<String>{
            'Product__c',
            'Product__r.Product_Name_Translate__c',
            'Product__r.Product_Code__c',
            'Product__r.Product_Family__r.Product_Name_Translate__c',
            'Product__r.Manufacturer_part_number__c'};

        if(searchValue == '') {

            defaultBOMs = ContractTreatmentDefaultBomDAO.getDefaultBOMsFromJob(queryFields, contractTreatmentJobId);
        }
        else {
            defaultBOMs = ContractTreatmentDefaultBomDAO.getDefaultBOMsWithSearch(queryFields, contractTreatmentJobId, searchValue);
        }

        for(Contract_Treatment_Default_BOM__c defaultBOM : defaultBOMs) {
            ContractTreatmentDefaultBomDTO dto = new ContractTreatmentDefaultBomDTO(
                defaultBOM.Id, 
                defaultBOM.Product__c, 
                defaultBOM.Product__r.Product_Name_Translate__c,
                defaultBOM.Product__r.Product_Code__c,
                defaultBOM.Product__r.Product_Family__r.Product_Name_Translate__c,
                defaultBOM.Product__r.Manufacturer_part_number__c
            );

            toReturn.add(dto);
        }

        return toReturn;
    }

    public static void deleteDefaultBOM(Id defaultBOMId) {
        List<String> queryFields = new List<String>{'Id'};

        Contract_Treatment_Default_BOM__c toDelete = ContractTreatmentDefaultBomDAO.getDefaultBOMFromId(queryFields, defaultBOMId);

        delete toDelete;

    }
}