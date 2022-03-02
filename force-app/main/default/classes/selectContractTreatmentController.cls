public with sharing class selectContractTreatmentController {

    @AuraEnabled(cacheable = true)
    public static List<ContractTreatmentsDTO> getContracts(String searchKey, List<String> preselectedrowslist, String therapy, String recordType, String business) { 
        System.debug('therapy: '+ therapy);   
        System.debug('recordType: ' + recordType);   
        System.debug('business: ' +  business);   
        List<Contract_Treatment__c> contractTreatmentList = ContractTreatmentDAO.getContractTreatmentByFrameworkStatus(searchKey, preselectedrowslist, recordType, therapy, business);
        List<ContractTreatmentsDTO> contractTreatmenetDTOs = new List<ContractTreatmentsDTO>();
        for(Integer i=0; i<contractTreatmentList.size(); i++){
            ContractTreatmentsDTO tmp = new ContractTreatmentsDTO(contractTreatmentList[i]);
            contractTreatmenetDTOs.add(tmp);
        }
        return contractTreatmenetDTOs;
    } 


    @AuraEnabled(cacheable = true)
    public static List<Contract_Treatment__c> getselectedCTThreshold(String contractSelection) {
        return ContractTreatmentDAO.getselectedCTThresholdvalues(contractSelection);
    } 

    @AuraEnabled(cacheable = true)
    public static List<Prescription__c> getPrescriptions(String accountId) {
        return PrescriptionDAO.getPrescriptionsbyId(accountId);
    } 

    @AuraEnabled(cacheable = true)
    public static List<RecordType> getRecordTypeLabel(String SelectedRecordLabel) {
        return RecordTypeDAO.getRecordTypeLabelbyId(SelectedRecordLabel);
    }
    
    @AuraEnabled(cacheable=true)
    public static List<RecordType> getRecordType() {
        return  RecordTypeDAO.getRecordTypebysobject('Account_Treatment__c');             
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Account> getAccountName(String accountId) {
        return AccountDAO.getAccountNamebyId(accountId);             
    }
}