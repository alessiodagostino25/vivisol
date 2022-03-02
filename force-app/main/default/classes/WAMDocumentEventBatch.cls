global class WAMDocumentEventBatch implements Database.Batchable<sObject>, Schedulable {
    public List<String> contentDocumentIds;

    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id FROM ContentDocument ';
        
        if(contentDocumentIds != null && !contentDocumentIds.isEmpty()) {
            query += 'WHERE Id IN: contentDocumentIds';
        }

        System.debug(query);
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<ContentDocument> contentDocuments) {
        System.debug('Executing WAMDocumentEventBatch...');
        System.debug('contentDocuments: ' + contentDocuments);

        List<String> CDLQueryFields = new List<String>{'LinkedEntityId', 'ContentDocumentId', 'ContentDocument.Title'};
        List<String> contentVersionQueryFields = new List<String>{'External_Id__c', 'ContentDocumentId', 'Origin'};

        List<Id> contentDocumentIds = new List<Id>();
        List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>();
        List<ContentVersion> relatedLatestContentVersions = new List<ContentVersion>();
        List<Stored_Document__c> storedDocuments = new List<Stored_Document__c>();
        List<String> contentVersionExternalIds = new List<String>();

        Map<String, Stored_Document__c> storedDocumentMap = new Map<String, Stored_Document__c>();

        for(ContentDocument cd : contentDocuments) {
            contentDocumentIds.add(cd.Id);
        }

        relatedLatestContentVersions = ContentVersionDAO.getLatestContentVersionsFromContentDocuments(contentVersionQueryFields, contentDocumentIds);

        for(ContentVersion contentVersion : relatedLatestContentVersions) {
            if(contentVersion.External_Id__c != null) {
                contentVersionExternalIds.add(contentVersion.External_Id__c);
            }
        }

        storedDocuments = [SELECT Document_External_Id__c FROM Stored_Document__c WHERE Document_External_Id__c IN: contentVersionExternalIds];

        for(Stored_Document__c storedDocument : storedDocuments) {
            storedDocumentMap.put(storedDocument.Document_External_Id__c, storedDocument);
        }

        // Not sending the ContentDocuments for which there is already a Stored Document for the latest ContentVersion + excluding chatter files (Origin = H)

        for(ContentVersion contentVersion : relatedLatestContentVersions) {
            if(storedDocumentMap.get(contentVersion.External_Id__c) != null || contentVersion.Origin == 'H') {
                Integer index = contentDocumentIds.indexOf(contentVersion.ContentDocumentId);

                if(index != -1) {
                    System.debug('Removing ContentDocument ' + contentDocumentIds.get(index) + ' because of a Stored Document already present with Document_External_Id__c ' + 
                    contentVersion.External_Id__c + ', OR it is a Chatter File');
                    contentDocumentIds.remove(index);
                }
            }
        }

        // Not sending the ContentDocuments which have the latest ContentVersion marked as "To Be Deleted"

        List<ContentVersion> latestToDeleteVersions = [SELECT Id, ContentDocumentId FROM ContentVersion 
                                                       WHERE ContentDocumentId IN: contentDocumentIds AND IsLatest = true AND To_Be_Deleted__c = true];
        System.debug(latestToDeleteVersions);
        if(latestToDeleteVersions != null && !latestToDeleteVersions.isEmpty()) {
            for(ContentVersion cv : latestToDeleteVersions) {
                Integer index = contentDocumentIds.indexOf(cv.ContentDocumentId);

                if(index != null && index != -1) {
                    System.debug('Removing ContentDocument ' + contentDocumentIds.get(index) + ' because its latest ContentVersion has To_Be_Deleted__c = true');
                    contentDocumentIds.remove(index);
                }
            }
        }

        if(!contentDocumentIds.isEmpty()) {
            contentDocumentLinks = ContentDocumentLinkDAO.getCDLsFromCDIds(CDLQueryFields, contentDocumentIds);

            System.debug('contentDocumentLinks size: ' + contentDocumentLinks.size());
            System.debug('contentDocumentLinks: ' + contentDocumentLinks);
        }

        if(!contentDocumentLinks.isEmpty()) {
            List<WAM_Document__e> WAMDocumentEvents = WAMDocumentEventBatchService.createWAMDocumentEvents(contentDocumentLinks);
            System.debug('WAMDocumentEvents size: ' + WAMDocumentEvents.size());
            System.debug('WAMDocumentEvents: ' + WAMDocumentEvents);

            if(!WAMDocumentEvents.isEmpty()) {
                List<Database.SaveResult> results = EventBus.publish(WAMDocumentEvents);

                for(Database.SaveResult result : results) {
                    System.debug('Publishing success? ' + result.isSuccess());
                }
            }
        }
    }

    public void finish(Database.BatchableContext bc) {
        
    }

    public static void Execute(SchedulableContext ctx) {
        Database.executeBatch(new WAMDocumentEventBatch(), 3);
    }

    public WAMDocumentEventBatch() {

    }

    public WAMDocumentEventBatch(List<String> contentDocumentIds) {
        this.contentDocumentIds = contentDocumentIds;
    }
}