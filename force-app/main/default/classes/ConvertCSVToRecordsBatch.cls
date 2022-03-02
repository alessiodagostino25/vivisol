global class ConvertCSVToRecordsBatch implements Database.Batchable<sObject>, Database.Stateful{
    global String contentDocumentId;
    global Integer month;
    global String year;
    global String companyId;
    global List<Error_Log_Event__e> errorLogEvents;
    global Boolean exceptionRaised = false;

	global Database.QueryLocator start(Database.BatchableContext bc){
		//query to get all the Addresses based on conditions
		String query = 'SELECT Id FROM ContentDocument WHERE Id =: contentDocumentId';
		System.debug(query);
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext bc, List<ContentDocument> contentDocuments){
		if(contentDocumentId != null && month != null && year != null && companyId != null) {
            try {
                errorLogEvents = ConvertCSVToRecords.convert(contentDocumentId, month, year, companyId);
            }
            catch(ConvertCSVToRecords.CSVParsingException parsingException) {
                exceptionRaised = true;
            }
        }
	}

	global void finish(Database.BatchableContext bc){
		system.debug('DONE');

        CustomNotificationType type = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'CSV_Conversion_Finished'];
        List<Report> errorReportList = [SELECT Id FROM Report WHERE Name = 'Errors Log Report'];
        List<Report> successReportList = [SELECT Id FROM Report WHERE Name = 'Payroll Process'];
        Report errorReport;
        Report successReport;
        //List<Error_Log__c> relatedErrorLogs = [SELECT Id FROM Error_Log__c WHERE Content_Document__c =: contentDocumentId];
            
        if(type != null) {
            Messaging.CustomNotification notification = new Messaging.CustomNotification();
            notification.setNotificationTypeId(type.Id);

            if(!exceptionRaised) {
                if(errorReportList != null && !errorReportList.isEmpty()) {
                    errorReport = errorReportList[0];
                }

                if(successReportList != null && !successReportList.isEmpty()) {
                    successReport = successReportList[0];
                }

                String errorReportURL;
                String successReportURL;
                String errorPageRef;
                String successPageRef;

                if(errorReport != null) {
                    errorReportURL = (String) URL.getSalesforceBaseUrl().toExternalForm() + '/lightning/r/Report/' + errorReport.Id + '/view?&fv0=' + contentDocumentId;
                }

                if(successReport != null) {
                    successReportURL = (String) URL.getSalesforceBaseUrl().toExternalForm() + '/lightning/r/Report/' + successReport.Id + 
                                       '/view?&fv0=' + companyId + '&fv1=' + year + '&fv2=' + month;
                }

                if(errorReportURL != null) {
                    errorPageRef = '{"type": "standard__webPage","attributes": {"url": "' + errorReportURL +'"}}';
                }

                if(successReportURL != null) {
                    successPageRef = '{"type": "standard__webPage","attributes": {"url": "' + successReportURL +'"}}';
                }

                if(errorLogEvents != null && !errorLogEvents.isEmpty()) {
                    if(errorPageRef != null) {
                        notification.setTargetPageRef(errorPageRef);
                    }
                }
                else {
                    if(successPageRef != null) {
                        notification.setTargetPageRef(successPageRef);
                    }
                }

                notification.setBody(Label.Notification_CSVConversionFinished_Body);
                notification.setTitle(Label.Notification_CSVConversionFinished_Title);
            }
            else {
                notification.setTargetId(contentDocumentId);
                notification.setBody(Label.Notification_CSVConversionFinished_Error_Body);
                notification.setTitle(Label.Notification_CSVConversionFinished_Error_Title);
            }

            try {
                notification.send(new Set<String>{Userinfo.getUserId()});
            }
            catch(Exception e) {
                System.debug('Problem sending notification: ' + e.getMessage());
            }
        }

        // Updating ContentVersion to be deleted by the scheduled batch

        List<ContentVersion> contentVersionList = [SELECT To_Be_Deleted__c FROM ContentVersion WHERE ContentDocumentId =: contentDocumentId];

        if(contentVersionList != null && !contentVersionList.isEmpty()) {
            for(ContentVersion cv : contentVersionList) {
                System.debug('Updating ContentVersion ' + cv.Id + ' To Be Deleted...');
                cv.To_Be_Deleted__c = true;
            }

            update contentVersionList;
        }
	}

    global ConvertCSVToRecordsBatch(String contentDocumentId, Integer month, String year, String companyId) {
        this.contentDocumentId = contentDocumentId;
        this.month = month;
        this.year = year;
        this.companyId = companyId;
    }

    global ConvertCSVToRecordsBatch() {

    }
}