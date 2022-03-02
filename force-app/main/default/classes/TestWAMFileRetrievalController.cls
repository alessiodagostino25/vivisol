@isTest
public class TestWAMFileRetrievalController {
    @isTest
    static void getDocumentIdToShowFailTest() {
        Stored_Document__c storedDocument = new Stored_Document__c();
        storedDocument.Document_Name__c = 'Test Document';
        insert storedDocument;

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(202, false, storedDocument.Id));

        Test.startTest();

        String documentId = WAMFileRetrievalController.getDocumentIdToShow(storedDocument.Id);

        Test.stopTest();

        List<Callout_Logger__c> calloutLoggers = [SELECT Id FROM Callout_Logger__c];

        System.assertEquals(null, documentId);
        System.assert(calloutLoggers.size() > 0);
    }

    @isTest
    static void getDocumentIdToShowSuccessTest() {
        Stored_Document__c storedDocument = new Stored_Document__c();
        storedDocument.Document_Name__c = 'Test Document';
        insert storedDocument;

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, true, storedDocument.Id));

        Test.startTest();

        String documentId = WAMFileRetrievalController.getDocumentIdToShow(storedDocument.Id);

        Test.stopTest();

        List<Callout_Logger__c> calloutLoggers = [SELECT Id FROM Callout_Logger__c];

        System.assert(documentId != null);
        System.assertEquals(0, calloutLoggers.size());
    }

    public class MockHttpResponseGenerator implements HttpCalloutMock {
        Integer responseStatusCode;
        Boolean success;
        String storedDocumentId;

        public  MockHttpResponseGenerator(Integer status, Boolean success, String storedDocumentId){
            responseStatusCode = status;
            this.success = success;
            this.storedDocumentId = storedDocumentId;
        }
     
        public HTTPResponse respond(HTTPRequest req) {
            ContentVersion contentVersion = new ContentVersion(
                VersionData = Blob.valueOf('Test'),
                Title = 'Test Document',
                To_Be_Deleted__c = true,
                PathOnClient = 'TestDocument.pdf'
            );

            insert contentVersion;

            ContentVersion queriedContentVersion = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: contentVersion.Id];

            ContentDocumentLink CDL = new ContentDocumentLink(
                ContentDocumentId = queriedContentVersion.ContentDocumentId,
                LinkedEntityId = storedDocumentId
            );

            insert CDL;

            Integer statusCode = 200;
            if(req.getEndpoint() != 'callout:MC_Login') {
                statusCode = responseStatusCode;
            } 
            // Create a response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');

            if(success == false) {
                res.setBody('{"resultList": [{"success": false,"log_event": {"warningList": [{"uuid_Flow": "afbb1641-abb0-4994-a4d3-8f0a89be14a6","recordId": "abc1234","errorType": "Error","error_Description": "Counter reading smaller than in previous document 66","operationType": "BAPI","operation_Name": "ZFM_IF018_MEASUREMENT_CREATE","originSystem": "Salesforce","objectName": null,"service": "equipment-measurement-sfdc-sap-test","status": "fail","targetSystem": "SAP"}],"errorList": [{"uuid_Flow": "afbb1641-abb0-4994-a4d3-8f0a89be14a6","recordId": "abc1234","errorType": "Error","error_Description": "Counter reading smaller than in previous document 66","operationType": "BAPI","operation_Name": "ZFM_IF018_MEASUREMENT_CREATE","originSystem": "Salesforce","objectName": null,"service": "equipment-measurement-sfdc-sap-test","status": "fail","targetSystem": "SAP"}]}}]}');
            }
            else {
                Blob fileBase64 = Blob.valueOf('Test File');
                res.setBody('{"resultList": [{"success": true,"log_event": {"warningList": [],"errorList": []}}], "documentLinkId": "' + CDL.Id + '"}');
            }
            res.setStatusCode(statusCode);
            res.setStatus('Complete');
            return res;
        }

    }
}