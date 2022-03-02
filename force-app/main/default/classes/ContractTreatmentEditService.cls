public class ContractTreatmentEditService {
    
    public static Contract_Treatment__c getContractTreatment(Id contractTreatmentId) {
        Contract_Treatment__c contractTreatment = ContractTreatmentDAO.getContractTreatmentForEdit(contractTreatmentId);
        return contractTreatment;
    }
}