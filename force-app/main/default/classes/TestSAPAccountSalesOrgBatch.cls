@isTest
public class TestSAPAccountSalesOrgBatch {
    @isTest
    static void batchCreationSuccessTest() {
        Account account = TestDataFactory.createPersonAccount();
        insert account;

        Sales_Organization__c salesOrg = TestDataFactory.createSalesOrganization();
        salesOrg.Code__c = 'SalesOrgCode';
        insert salesOrg;

        Account_Sales_Organization__c ASO = TestDataFactory.getAso(account.Id);
        ASO.Sales_Organization__c = salesOrg.Id;
        insert ASO;

        Account_Sales_Organization__c queriedASO = [SELECT External_Id__c FROM Account_Sales_Organization__c WHERE Id =: ASO.Id];

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorBatchSuccess(202, false, queriedASO.External_Id__c));

        /* ASO.IsCreatedSAP__c = true;
        ASO.IsSyncSAP__c = 'NotSync';

        update ASO; */

        Test.startTest();

        Database.executeBatch(new SAPAccountSalesOrgBatch());

        Test.stopTest();

        Account_Sales_Organization__c queriedASO1 = [SELECT IsCreatedSAP__c, IsSyncSAP__c FROM Account_Sales_Organization__c WHERE Id =: ASO.Id];

        System.assertEquals(true, queriedASO1.IsCreatedSAP__c);
        System.assertEquals('Sync', queriedASO1.IsSyncSAP__c);
    }

    @isTest
    static void batchCreationFailTest() {
        Account account = TestDataFactory.createPersonAccount();
        insert account;

        Sales_Organization__c salesOrg = TestDataFactory.createSalesOrganization();
        salesOrg.Code__c = 'SalesOrgCode';
        insert salesOrg;

        Account_Sales_Organization__c ASO = TestDataFactory.getAso(account.Id);
        ASO.Sales_Organization__c = salesOrg.Id;
        insert ASO;

        Account_Sales_Organization__c queriedASO = [SELECT External_Id__c FROM Account_Sales_Organization__c WHERE Id =: ASO.Id];

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(202, false, queriedASO.External_Id__c));

        /* ASO.IsCreatedSAP__c = true;
        ASO.IsSyncSAP__c = 'NotSync';

        update ASO; */

        Test.startTest();

        Database.executeBatch(new SAPAccountSalesOrgBatch());

        Test.stopTest();

        Account_Sales_Organization__c queriedASO1 = [SELECT IsCreatedSAP__c, IsSyncSAP__c FROM Account_Sales_Organization__c WHERE Id =: ASO.Id];

        System.assertEquals(false, queriedASO1.IsCreatedSAP__c);
        System.assertEquals(null, queriedASO1.IsSyncSAP__c);
    }

    @isTest
    static void batchUpdateSuccessTest() {
        Account account = TestDataFactory.createPersonAccount();
        insert account;

        Account queriedAccount = [SELECT AutoNumber__c FROM Account WHERE Id =: account.Id];

        Sales_Organization__c salesOrg = TestDataFactory.createSalesOrganization();
        salesOrg.Code__c = 'SalesOrgCode';
        insert salesOrg;

        Account_Sales_Organization__c ASO = TestDataFactory.getAso(account.Id);
        ASO.Sales_Organization__c = salesOrg.Id;
        ASO.External_Id__c = String.valueOf(queriedAccount.AutoNumber__c) + 'SalesOrgCode';
        insert ASO;

        ASO.Payment_Terms__c = 'NL00';
        ASO.IsCreatedSAP__c = true;
        ASO.IsSyncSAP__c = 'NotSync';
        update ASO;

        Test.startTest();

        Account_Sales_Organization__c queriedASO = [SELECT External_Id__c, IsCreatedSAP__c, IsSyncSAP__c FROM Account_Sales_Organization__c WHERE Id =: ASO.Id];

        System.debug('TEST queriedASO.ExternalId: ' + queriedASO.External_Id__c);
        System.debug('TEST queriedASO.Id: ' + queriedASO.Id);
        System.debug('TEST queriedASO.IsCreatedSAP: ' + queriedASO.IsCreatedSAP__c);
        System.debug('TEST queriedASO.IsSyncSAP: ' + queriedASO.IsSyncSAP__c);

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorBatchSuccess(202, false, String.valueOf(queriedAccount.AutoNumber__c) + 'SalesOrgCode'));

        Database.executeBatch(new SAPAccountSalesOrgBatch());

        Test.stopTest();

        Account_Sales_Organization__c queriedASO1 = [SELECT IsCreatedSAP__c, IsSyncSAP__c FROM Account_Sales_Organization__c WHERE Id =: ASO.Id];

        System.assertEquals(true, queriedASO1.IsCreatedSAP__c);
        System.assertEquals('Sync', queriedASO1.IsSyncSAP__c);
    }

    @isTest
    static void batchUpdateFailTest() {
        Account account = TestDataFactory.createPersonAccount();
        insert account;

        Account queriedAccount = [SELECT AutoNumber__c FROM Account WHERE Id =: account.Id];

        Sales_Organization__c salesOrg = TestDataFactory.createSalesOrganization();
        salesOrg.Code__c = 'SalesOrgCode';
        insert salesOrg;

        Account_Sales_Organization__c ASO = TestDataFactory.getAso(account.Id);
        ASO.Sales_Organization__c = salesOrg.Id;
        ASO.External_Id__c = String.valueOf(queriedAccount.AutoNumber__c) + 'SalesOrgCode';
        insert ASO;

        ASO.Payment_Terms__c = 'NL00';
        ASO.IsCreatedSAP__c = true;
        ASO.IsSyncSAP__c = 'NotSync';
        update ASO;

        Test.startTest();

        Account_Sales_Organization__c queriedASO = [SELECT External_Id__c, IsCreatedSAP__c, IsSyncSAP__c FROM Account_Sales_Organization__c WHERE Id =: ASO.Id];

        System.debug('TEST queriedASO.ExternalId: ' + queriedASO.External_Id__c);
        System.debug('TEST queriedASO.Id: ' + queriedASO.Id);
        System.debug('TEST queriedASO.IsCreatedSAP: ' + queriedASO.IsCreatedSAP__c);
        System.debug('TEST queriedASO.IsSyncSAP: ' + queriedASO.IsSyncSAP__c);

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorBatchFail(202, false, String.valueOf(queriedAccount.AutoNumber__c) + 'SalesOrgCode'));

        Database.executeBatch(new SAPAccountSalesOrgBatch());

        Test.stopTest();

        Account_Sales_Organization__c queriedASO1 = [SELECT IsCreatedSAP__c, IsSyncSAP__c FROM Account_Sales_Organization__c WHERE Id =: ASO.Id];

        System.assertEquals(true, queriedASO1.IsCreatedSAP__c);
        System.assertEquals('NotSync', queriedASO1.IsSyncSAP__c);
    }

    public class MockHttpResponseGeneratorBatchSuccess implements HttpCalloutMock {
       
        Integer responseStatusCode;
        Boolean success;
        String correlationId;

        public MockHttpResponseGeneratorBatchSuccess(Integer status, Boolean success, String correlationId){
            responseStatusCode = status;
            this.success = success;
            this.correlationId = correlationId;
        }
     
        public HTTPResponse respond(HTTPRequest req) {
            Integer statusCode = 200;
            if(req.getEndpoint() != 'callout:MC_Login') {
                statusCode = responseStatusCode;
            } 
            if(System.isBatch()) {
                success = true;
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

    public class MockHttpResponseGeneratorBatchFail implements HttpCalloutMock {
       
        Integer responseStatusCode;
        Boolean success;
        String correlationId;

        public MockHttpResponseGeneratorBatchFail(Integer status, Boolean success, String correlationId){
            responseStatusCode = status;
            this.success = success;
            this.correlationId = correlationId;
        }
     
        public HTTPResponse respond(HTTPRequest req) {
            Integer statusCode = 200;
            if(req.getEndpoint() != 'callout:MC_Login') {
                statusCode = responseStatusCode;
            } 
            if(System.isBatch()) {
                success = false;
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

    public class MockHttpResponseGeneratorUpdateFail implements HttpCalloutMock {
       
        Integer responseStatusCode;
        Boolean success;
        String correlationId;

        public MockHttpResponseGeneratorUpdateFail(Integer status, Boolean success, String correlationId){
            responseStatusCode = status;
            this.success = success;
            this.correlationId = correlationId;
        }
     
        public HTTPResponse respond(HTTPRequest req) {
            Integer statusCode = 200;
            if(req.getEndpoint() == 'callout:SAP_SO_UPDATE') {
                success = false;
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