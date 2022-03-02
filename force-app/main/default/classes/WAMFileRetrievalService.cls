public class WAMFileRetrievalService {

    public static String getDocumentIdToShow(String storedDocumentId){
        List<String> storedDocumentQueryFields = new List<String>{'WAM_Id__c', 'File_Extension__c', 'Document_Name__c'};
        List<String> CDLQueryFields = new List<String>{'ContentDocumentId'};

        ContentDocumentLink CDL;
        List<Stored_Document__c> storedDocumentList = StoredDocumentDAO.getStoredDocumentsFromIds(storedDocumentQueryFields, new List<String>{storedDocumentId});
        Stored_Document__c storedDocument;

        if(!storedDocumentList.isEmpty()) {
            storedDocument = storedDocumentList[0];
        }

        // Checking if a ContentDocumentLink is already present for this Stored Document

        CDL = checkForCDL(storedDocumentId);

        // I only need to perform a call to WAM if there are no ContentDocumentLink records for this StoredDocument

        if(CDL == null) {
            WAMDocumentResponseDTO responseDTO = performWAMGetDocumentCall(storedDocument);

            if(responseDTO != null /*&& responseDTO.FileBase64 != null*/ && responseDTO.documentLinkId != null) {

                // Creating Content Version

                /* ContentVersion contentVersion = new ContentVersion(
                    VersionData = responseDTO.FileBase64,
                    Title = responseDTO.FileName,
                    To_Be_Deleted__c = true,
                    PathOnClient = responseDTO.FileName + '.' + storedDocument.File_Extension__c
                );

                insert contentVersion;

                ContentVersion queriedContentVersion = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: contentVersion.Id];

                // Creating ContentDocumentLink

                CDL = new ContentDocumentLink(
                    ContentDocumentId = queriedContentVersion.ContentDocumentId,
                    LinkedEntityId = storedDocumentId
                );

                insert CDL; */

                List<ContentDocumentLink> CDLList = ContentDocumentLinkDAO.getCDLsFromIds(CDLQueryFields, new List<String>{responseDTO.documentLinkId});
                
                if(CDLList != null && !CDLList.isEmpty()) {
                    CDL = CDLList[0];
                }
            }
        }

        if(CDL != null && CDL.ContentDocumentId != null) {
            System.debug('CDL.ContentDocumentId: ' + CDL.ContentDocumentId);
            return CDL.ContentDocumentId;
        }

        return null;
    }

    public static ContentDocumentLink checkForCDL(String storedDocumentId) {
        List<String> CDLQueryFields = new List<String>{'ContentDocumentId'};

        ContentDocumentLink relatedCDL;
        List<ContentDocumentLink> relatedCDLList = ContentDocumentLinkDAO.getCDLsFromEntityIds(CDLQueryFields, new List<String>{storedDocumentId});

        if(!relatedCDLList.isEmpty()) {
            System.debug('relatedCDLList: ' + relatedCDLList);
            relatedCDL = relatedCDLList[0];
        }

        return relatedCDL;
    }

    public static WAMDocumentResponseDTO performWAMGetDocumentCall(Stored_Document__c storedDocument) {
        WAMDocumentRequestDTO dto = new WAMDocumentRequestDTO(storedDocument);
        WAMDocumentResponseDTO responseDTO;
        List<Callout_Logger__c> loggerList = new List<Callout_Logger__c>();
        String documentName = storedDocument.Document_Name__c;

        if(storedDocument.File_Extension__c != null) {
            if(documentName.endsWith(storedDocument.File_Extension__c)) {
                documentName = documentName.substringBeforeLast('.');
            }
        }

        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:WAM_DOCUMENT_DOWNLOAD' + '?ID=' + storedDocument.WAM_Id__c + '&storedDocumentId=' + 
        storedDocument.Id + '&fileName=' + EncodingUtil.urlEncode(documentName, 'UTF-8') + '&fileExtension=' + storedDocument.File_Extension__c);
        req.setMethod('GET');
        req.setTimeout(60000);

        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');

        // create body request
        String reqJSON = JSON.serialize(dto);
        System.debug('DTO:::: ' + dto);
        System.debug(reqJSON);
        System.debug('ENDPOINT: ' + req.getEndpoint());
        //req.setBody(reqJSON);

        Http http = new Http();
        HTTPResponse res = new HttpResponse();

        // initialize timers
        Long startTime = Datetime.now().getTime();
        Long finishTime;
        Long totalTime;

        try {
            res = http.send(req);
            System.debug(res);
            System.debug(res.getBody());
            System.debug('Endpoint: ' + req.getEndpoint());
            finishTime = Datetime.now().getTime();
            totalTime = (finishTime - startTime);
            String responseUnparsed = res.getBody();

            responseDTO = (WAMDocumentResponseDTO) System.JSON.deserialize(responseUnparsed, WAMDocumentResponseDTO.class);

            if(responseDTO.resultList != null) {
                // Callout Loggers

                for(WAMDocumentResponseDTO.ResultList resList : responseDTO.resultList) {
                    WAMDocumentResponseDTO.Log_event logEvent = resList.log_event;

                    if(logEvent != null) {
                        // Error Callout Loggers

                        if(logEvent.errorList != null) {
                            for(WAMDocumentResponseDTO.ErrorList errorList : logEvent.errorList) {
                                Callout_Logger__c calloutLogger = CalloutLoggerService.initializeUpdateCalloutLog(
                                    String.valueOf(res.getStatusCode()), 
                                    errorList.errorType, 
                                    false, 
                                    'Stored_Document__c', 
                                    errorList.operation_Name, 
                                    errorList.operationType, 
                                    'SFDC', 
                                    errorList.recordId,
                                    'SFDC_WAM_GET_DOCUMENT',
                                    Datetime.now(), 
                                    errorList.uuid_Flow, 
                                    errorList.error_Description, 
                                    req.getBody(), 
                                    'WAM', 
                                    'FAIL'
                                );

                                loggerList.add(calloutLogger);
                                System.debug('CALLOUT LOGGER: ' + calloutLogger);
                            }
                        }

                        // Warning Callout Loggers

                        if(logEvent.warningList != null) {
                            for(WAMDocumentResponseDTO.WarningList warningList : logEvent.warningList) {
                                Callout_Logger__c calloutLogger = CalloutLoggerService.initializeUpdateCalloutLog(
                                    String.valueOf(res.getStatusCode()), 
                                    warningList.errorType, 
                                    false, 
                                    'Stored_Document__c', 
                                    warningList.operation_Name, 
                                    warningList.operationType, 
                                    'SFDC', 
                                    warningList.recordId, 
                                    'SFDC_WAM_GET_DOCUMENT', 
                                    Datetime.now(), 
                                    warningList.uuid_Flow, 
                                    warningList.error_Description, 
                                    req.getBody(), 
                                    'WAM', 
                                    'WARN'
                                );

                                loggerList.add(calloutLogger);
                                System.debug('CALLOUT LOGGER: ' + calloutLogger);
                            }
                        }
                    }
                }
            }

            if(!loggerList.isEmpty()) {
                List<Database.SaveResult> results = Database.insert(loggerList);
            }

            // Returning che responseDTO with the Document only if FileName and FileBase64 are filled, that means no errors have been found

            /* if(responseDTO.FileName != null && responseDTO.FileBase64 != null) {
                System.debug('responseDTO.FileName: ' + responseDTO.FileName);
                System.debug('responseDTO.FileBase64: ' + responseDTO.FileBase64);

                return responseDTO;
            } */

            if(responseDTO.documentLinkId != null) {
                System.debug('responseDTO.documentLinkId: ' + responseDTO.documentLinkId);

                return responseDTO;
            }
        }
        catch(Exception e) {
            System.debug('EXCEPTION!!!! : ' + e.getMessage());
            System.debug('Exception: ' + e);
            System.debug('Exception line number: ' + e.getLineNumber());

            Callout_Logger__c calloutLogger = CalloutLoggerService.initializeUpdateCalloutLog(
                null, 
                null, 
                false, 
                'Stored_Document__c', 
                'GET', 
                'GET', 
                'SFDC', 
                storedDocument.Id, 
                'SFDC_WAM_GET_DOCUMENT', 
                Datetime.now(), 
                null, 
                e.getMessage(), 
                req.getBody(), 
                'WAM', 
                'FAIL'
            );

            insert calloutLogger;
        }

        return null;
    }

}