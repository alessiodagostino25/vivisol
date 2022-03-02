public class CTModalitiesModalController {
    public class DuplicateException extends Exception {}

    @AuraEnabled
    public static List<ContractTreatmentModalityDTO> getContractTreatmentModalities(String contractTreatmentId, String recordTypeName){
        List<String> CTModalityQueryFields = new List<String>{'Treatment_Type__c', 'Treatment__c', 'Installation_Type__c', 'Contract_Treatment__c', 'Status__c',
        'Sub_Treatment__c', 'Rebate__c'};

        List<ContractTreatmentModalityDTO> toReturn = new List<ContractTreatmentModalityDTO>();

        List<Contract_Treatment_Modality__c> CTModalities = ContractTreatmentModalityDAO.getCTModalitiesFromCTsAndRTs(
            CTModalityQueryFields, 
            new List<String>{contractTreatmentId}, 
            new List<String>{recordTypeName}
        );

        if(CTModalities != null) {
            for(Contract_Treatment_Modality__c ctm : CTModalities) {
                ContractTreatmentModalityDTO dto = new ContractTreatmentModalityDTO(ctm);
                toReturn.add(dto);
            }
        }

        return toReturn;
    }

    @AuraEnabled
    public static void deleteCTModality(String CTModalityId) {
        Database.DeleteResult result = Database.delete(CTModalityId);
    }

    @AuraEnabled
    public static String getModalitytRTIdFromName(String developerName) {
        List<RecordType> recordTypeList = [SELECT Id FROM RecordType WHERE DeveloperName =: developerName];

        if(recordTypeList != null && !recordTypeList.isEmpty()) {
            return recordTypeList[0].Id;
        }

        return null;
    }
}