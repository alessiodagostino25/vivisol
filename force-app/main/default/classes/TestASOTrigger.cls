@isTest
public class TestASOTrigger {
    
    @TestSetup
    static void makeData(){
        Account account = TestDataFactory.createPersonAccount();
        insert account;

        Sales_Organization__c salesOrg = TestDataFactory.createSalesOrganization();
        salesOrg.Code__c = 'SalesOrgCode';
        insert salesOrg;
    }

    @isTest
    static void insertFailTest() {
        Account account = [SELECT Id, Account_External_Id__c FROM Account];
        Sales_Organization__c salesOrg = [SELECT Id, Code__c FROM Sales_Organization__c];

        String correlationId = account.Account_External_Id__c + salesOrg.Code__c;

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(202, false, correlationId));

        Account_Sales_Organization__c ASO = TestDataFactory.getAso(account.Id);
        ASO.Sales_Organization__c = salesOrg.Id;

        Test.startTest();

        Database.SaveResult result = Database.insert(ASO);

        Test.stopTest();

        System.assert(result.isSuccess());
    }

    @isTest
    static void insertSuccessTest() {
        Account account = [SELECT Id, Account_External_Id__c FROM Account];
        Sales_Organization__c salesOrg = [SELECT Id, Code__c FROM Sales_Organization__c];

        String correlationId = account.Account_External_Id__c + salesOrg.Code__c;

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, true, correlationId));

        Account_Sales_Organization__c ASO = TestDataFactory.getAso(account.Id);
        ASO.Sales_Organization__c = salesOrg.Id;

        Test.startTest();

        Database.SaveResult result = Database.insert(ASO);

        Test.stopTest();

        System.assert(result.isSuccess());
    }

    @isTest
    static void updateFailTest() {
        Account account = [SELECT Id, Account_External_Id__c FROM Account];
        Sales_Organization__c salesOrg = [SELECT Id, Code__c FROM Sales_Organization__c];

        String correlationId = account.Account_External_Id__c + salesOrg.Code__c;

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(202, false, correlationId));

        Account_Sales_Organization__c ASO = TestDataFactory.getAso(account.Id);
        ASO.Sales_Organization__c = salesOrg.Id;

        insert ASO;

        ASO.IsCreatedSAP__c = true;
        ASO.IsSyncSAP__c = 'NotSync';

        Test.startTest();

        Database.SaveResult result = Database.update(ASO);

        Test.stopTest();

        System.assert(result.isSuccess());
    }

    @isTest
    static void updateSuccessTest() {
        Account account = [SELECT Id, Account_External_Id__c FROM Account];
        Sales_Organization__c salesOrg = [SELECT Id, Code__c FROM Sales_Organization__c];

        String correlationId = account.Account_External_Id__c + salesOrg.Code__c;

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, true, correlationId));

        Account_Sales_Organization__c ASO = TestDataFactory.getAso(account.Id);
        ASO.Sales_Organization__c = salesOrg.Id;

        insert ASO;

        ASO.IsCreatedSAP__c = true;
        ASO.IsSyncSAP__c = 'NotSync';

        Test.startTest();

        Database.SaveResult result = Database.update(ASO);

        Test.stopTest();

        System.assert(result.isSuccess());
    }

    public class MockHttpResponseGenerator implements HttpCalloutMock {
       
        Integer responseStatusCode;
        Boolean success;
        String correlationId;

        public  MockHttpResponseGenerator(Integer status, Boolean success, String correlationId){
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