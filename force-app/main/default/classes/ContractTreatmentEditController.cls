public class ContractTreatmentEditController {
    
    @AuraEnabled
    public static Contract_Treatment__c getContractTreatment(Id contractTreatmentId) {
        return ContractTreatmentEditService.getContractTreatment(contractTreatmentId);
    }

    @AuraEnabled
    public static void removePermSet() {
        ContractTreatmentController.removePermSet();
    }

    @AuraEnabled
    public static void assignPermSetNew(){
        ContractTreatmentController.assignPermSetNew();
    }
}