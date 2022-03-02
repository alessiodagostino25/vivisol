@isTest
public class TestSAPAccountBatch {
    @isTest
    static void batchCreationFailTest() {
        Account account = TestDataFactory.createPersonAccount();
        insert account;

        account.IsCreatedSAP__c = false;
        account.IsSyncSAP__c = 'NotSync';
        update account;

        Account queriedAccount = [SELECT AutoNumber__c FROM Account WHERE Id =: account.Id];

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(202, false, queriedAccount.AutoNumber__c));

        Database.executeBatch(new SAPAccountBatch());

        Test.stopTest();

        Account queriedAccount1 = [SELECT IsCreatedSAP__c, IsSyncSAP__c FROM Account WHERE Id =: account.Id];

        System.assertEquals(false, queriedAccount1.IsCreatedSAP__c);
        System.assertEquals('NotSync', queriedAccount1.IsSyncSAP__c);
    }

    @isTest
    static void batchUpdateFailTest() {
        Account account = TestDataFactory.createPersonAccount();
        insert account;

        account.IsCreatedSAP__c = true;
        account.IsSyncSAP__c = 'NotSync';
        update account;

        Account queriedAccount = [SELECT AutoNumber__c FROM Account WHERE Id =: account.Id];

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(202, false, queriedAccount.AutoNumber__c));

        Database.executeBatch(new SAPAccountBatch());

        Test.stopTest();

        Account queriedAccount1 = [SELECT IsCreatedSAP__c, IsSyncSAP__c FROM Account WHERE Id =: account.Id];

        System.assertEquals(true, queriedAccount1.IsCreatedSAP__c);
        System.assertEquals('NotSync', queriedAccount1.IsSyncSAP__c);
    }

    public class MockHttpResponseGenerator implements HttpCalloutMock {
        Integer responseStatusCode;
        Boolean success;
        String correlationId;

        public MockHttpResponseGenerator(Integer status, Boolean success, String correlationId){
            responseStatusCode = status;
            this.success = success;
            this.correlationId = correlationId;
        }
     
        public HTTPResponse respond(HTTPRequest req) {
            Integer statusCode = 200;
            if(req.getEndpoint() != 'callout:MC_Login') {
                statusCode = responseStatusCode;
            } 
            // Create a response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');

            if(success == false) {
                res.setBody('{"resultList": [{"success": false,"correlationID": "' + correlationId + '","log_event": {"warningList": [{"uuid_Flow": "afbb1641-abb0-4994-a4d3-8f0a89be14a6","recordId": "abc1234","errorType": "Error","error_Description": "Counter reading smaller than in previous document 66","operationType": "BAPI","operation_Name": "ZFM_IF018_MEASUREMENT_CREATE","originSystem": "Salesforce","objectName": null,"service": "equipment-measurement-sfdc-sap-test","status": "fail","targetSystem": "SAP"}],"errorList": [{"uuid_Flow": "afbb1641-abb0-4994-a4d3-8f0a89be14a6","recordId": "abc1234","errorType": "Error","error_Description": "Counter reading smaller than in previous document 66","operationType": "BAPI","operation_Name": "ZFM_IF018_MEASUREMENT_CREATE","originSystem": "Salesforce","objectName": null,"service": "equipment-measurement-sfdc-sap-test","status": "fail","targetSystem": "SAP"}]}}]}');
            }
            else {
                res.setBody('{"resultList": [{"success": true,"correlationID": "' + correlationId + '","log_event": {"warningList": [],"errorList": []}}]}');
            }
            res.setStatusCode(statusCode);
            res.setStatus('Complete');
            return res;
        }
    }
}