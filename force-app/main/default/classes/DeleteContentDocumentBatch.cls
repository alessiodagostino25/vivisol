global class DeleteContentDocumentBatch implements Database.Batchable<sObject>, Schedulable{

    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id, (SELECT To_Be_Deleted__c FROM ContentVersions) FROM ContentDocument';

        System.debug('QUERY: ' + query);
		return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<ContentDocument> contentDocuments) {
        List<ContentDocument> contentDocumentsToDelete = new List<ContentDocument>();
        List<ServiceReport> allRelatedServiceReports = new List<ServiceReport>();
        List<ServiceReport> serviceReportsToDelete = new List<ServiceReport>();
        List<String> contentDocumentIds = new List<String>();
        List<String> contentVersionIds = new List<String>();

        Map<String, List<ServiceReport>> contentDocumentToServiceReportsMap = new Map<String, List<ServiceReport>>();

        for(ContentDocument cd : contentDocuments) {
            contentDocumentIds.add(cd.Id);
            List<ContentVersion> relatedContentVersions = cd.ContentVersions;

            if(relatedContentVersions != null) {
                for(ContentVersion cv : relatedContentVersions) {
                    contentVersionIds.add(cv.Id);
                }
            }
        }

        if(!contentVersionIds.isEmpty()) {
            allRelatedServiceReports = [SELECT Id, ContentVersionDocumentId, ContentVersionDocument.ContentDocumentId 
                                        FROM ServiceReport WHERE ContentVersionDocumentId IN: contentVersionIds];

            if(!allRelatedServiceReports.isEmpty()) {
                for(ServiceReport sr : allRelatedServiceReports) {
                    if(contentDocumentToServiceReportsMap.get(sr.ContentVersionDocument.ContentDocumentId) == null) {
                        contentDocumentToServiceReportsMap.put(sr.ContentVersionDocument.ContentDocumentId, new List<ServiceReport>());
                    }
                    contentDocumentToServiceReportsMap.get(sr.ContentVersionDocument.ContentDocumentId).add(sr);
                }
            } 
        }

        for(ContentDocument contentDocument : contentDocuments) {
            Boolean toDelete = true;

            List<ContentVersion> relatedContentVersions = contentDocument.ContentVersions;
            List<ServiceReport> relatedServiceReports = contentDocumentToServiceReportsMap.get(contentDocument.Id);

            if(relatedContentVersions != null) {
                for(ContentVersion version : relatedContentVersions) {
                    if(version.To_Be_Deleted__c == false) {
                        toDelete = false;
                        break;
                    }
                }
            }

            if(toDelete == true) {
                contentDocumentsToDelete.add(contentDocument);

                if(relatedServiceReports != null) {
                    for(ServiceReport sr : relatedServiceReports) {
                        serviceReportsToDelete.add(sr);
                    }
                }
            }
        }

        if(!contentDocumentsToDelete.isEmpty()) {
            System.debug('Deleting: ');
            System.debug(contentDocumentsToDelete); 

            if(!serviceReportsToDelete.isEmpty()) {
                System.debug('Deleting: ');
                System.debug(serviceReportsToDelete); 

                List<Database.DeleteResult> results = Database.delete(serviceReportsToDelete);
            }

            List<Database.DeleteResult> results = Database.delete(contentDocumentsToDelete);
        }
    }

    global void finish(Database.BatchableContext bc) {
        system.debug('DONE'); //TODO
    }

    global void execute(SchedulableContext scon) {
        Database.executeBatch(new DeleteContentDocumentBatch());
    }
}