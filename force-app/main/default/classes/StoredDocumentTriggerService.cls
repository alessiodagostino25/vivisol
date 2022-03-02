public class StoredDocumentTriggerService {
    public static void updateRelatedPrescriptions(List<Stored_Document__c> storedDocuments) {
        List<String> prescriptionQueryFields = new List<String>{'Is_Portal_Sync__c'};

        List<Prescription__c> prescriptions = new List<Prescription__c>();
        List<String> prescriptionIds = new List<String>();

        for(Stored_Document__c sd : storedDocuments) {
            prescriptionIds.add(sd.Related_Prescription__c);
        }

        prescriptions = PrescriptionDAO.getPrescriptionsFromIds(prescriptionQueryFields, prescriptionIds);

        if(!prescriptions.isEmpty()) {
            SObjectServiceClass.updateGenericField('Prescription__c', '03', 'Is_Portal_Sync__c', prescriptions);
        }
    }

    public static void updateRelatedContentVersion(List<Stored_Document__c> storedDocuments) {
        List<String> contentVersionExternalId = new List<String>();
        List<String> contentVersionQueryFields = new List<String>{'To_Be_Deleted__c'};

        for(Stored_Document__c sd : storedDocuments) {
            contentVersionExternalId.add(sd.Document_External_Id__c);
        }

        List<ContentVersion> versions = new List<ContentVersion>(); 

        versions = ContentVersionDAO.getVersionsFromExternalId(contentVersionQueryFields, contentVersionExternalId);
        List<ContentVersion> versionsToBeUpdated = new List<ContentVersion>(); 
        if(!versions.isEmpty()) {
            for (ContentVersion cv : versions){
                if (cv.To_Be_Deleted__c == false){
                    cv.To_Be_Deleted__c = true;
                    versionsToBeUpdated.add(cv);
                }
            }
        }
        if (!versionsToBeUpdated.isEmpty()){
            update versionsToBeUpdated;
        }
    }
}