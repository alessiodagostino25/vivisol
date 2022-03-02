public class WAMFileRetrievalController {

    @AuraEnabled
    public static String getDocumentIdToShow(String storedDocumentId){
        String contentDocumentId = WAMFileRetrievalService.getDocumentIdToShow(storedDocumentId);

        return contentDocumentId;
    }
}