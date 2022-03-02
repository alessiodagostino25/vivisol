public class PrescriptionService {
    public static void setExternalId(List<Prescription__c> prescriptions) {
        SObjectServiceClass.updateExternalId('Prescription__c', 'Name', 'External_Id__c', prescriptions);
    }

    public static void setIsPortalSync(List<Prescription__c> prescriptions, Map<Id, Prescription__c> oldMap, Boolean checkProfile, Boolean performDML) {
        SObjectServiceClass.setIsPortalSync(prescriptions, oldMap, 'Prescription__c', true, performDML);
    }
}