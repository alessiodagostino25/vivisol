public without sharing class ATPrescriptionMappingmdtDAO {
    
    public static List<AccountTreatmentPrescriptionMapping__mdt> ATPrescriptionMappingmdtfields() {
        return [SELECT Id,Prescription_Field__c,Account_Treatment_Field__c FROM AccountTreatmentPrescriptionMapping__mdt];
    }
}