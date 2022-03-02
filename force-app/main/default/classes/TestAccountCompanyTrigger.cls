@isTest
public class TestAccountCompanyTrigger {

    @isTest
    static void insertFailTest() {
        Account_Company__c accountCompany = TestDataFactory.createAccountCompany();

        Account relatedAccount = [SELECT Id, Account_External_Id__c, AutoNumber__c FROM Account];

        String correlationId = relatedAccount.Account_External_Id__c + '6300';

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(202, false, correlationId));

        Test.startTest();

        Database.SaveResult result = Database.insert(accountCompany);

        Test.stopTest();

        List<Callout_Logger__c> loggers = [SELECT Id FROM Callout_Logger__c];
        Account_Company__c queriedAC = [SELECT IsCreatedSAP__c, IsSyncSAP__c FROM Account_Company__c WHERE Id =: accountCompany.Id];

        System.assert(result.isSuccess());
        System.assert(loggers.size() > 0);
        System.assertEquals(false, queriedAC.IsCreatedSAP__c);
        System.assertEquals(null, queriedAC.IsSyncSAP__c);
    }

    @isTest
    static void insertSuccessTest() {
        Account_Company__c accountCompany = TestDataFactory.createAccountCompany();

        Account relatedAccount = [SELECT Id, Account_External_Id__c, AutoNumber__c FROM Account];

        String correlationId = relatedAccount.Account_External_Id__c + '6300';

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, true, correlationId));

        Test.startTest();

        Database.SaveResult result = Database.insert(accountCompany);

        Account_Company__c queriedAccountCompany = [SELECT Payment_Terms__c, IsSyncSAP__c, IsCreatedSAP__c FROM Account_Company__c WHERE Id =: accountCompany.Id];
        /* System.assertEquals(true, queriedAccountCompany.IsCreatedSAP__c);
        System.assertEquals('Sync', queriedAccountCompany.IsSyncSAP__c); */
        queriedAccountCompany.Payment_Terms__c = 'NL01';

        //Database.SaveResult updateResult = Database.update(queriedAccountCompany);

        Test.stopTest();

        Account_Company__c queriedAccountCompany2 = [SELECT Payment_Terms__c, IsSyncSAP__c, IsCreatedSAP__c FROM Account_Company__c WHERE Id =: accountCompany.Id];

        System.assert(result.isSuccess());
        //System.assert(updateResult.isSuccess());
        System.assertEquals(true, queriedAccountCompany2.IsCreatedSAP__c);
        System.assertEquals('Sync', queriedAccountCompany2.IsSyncSAP__c);
    }

    @isTest
    static void updateSuccessTest() {
        Account_Company__c accountCompany = TestDataFactory.createAccountCompany();

        Account relatedAccount = [SELECT Id, Account_External_Id__c, AutoNumber__c FROM Account];

        String correlationId = relatedAccount.Account_External_Id__c + '6300';

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, true, correlationId));
        Database.SaveResult result = Database.insert(accountCompany);
        
        Account_Company__c queriedAccountCompany = [SELECT Payment_Terms__c,isCreatedSAP__c, isSyncSAP__c FROM Account_Company__c WHERE Id =: accountCompany.Id];
        queriedAccountCompany.Payment_Terms__c = 'NL01';
        queriedAccountCompany.isCreatedSAP__c = true;
        queriedAccountCompany.isSyncSAP__c = 'Sync';
        System.debug('isCreatedSAP before update: ' + queriedAccountCompany.isCreatedSAP__c);

        Test.startTest();

        Database.SaveResult updateResult = Database.update(queriedAccountCompany);

        Test.stopTest();

        System.assert(updateResult.isSuccess());
    }

    @isTest
    static void updateFailTest() {
        Account_Company__c accountCompany = TestDataFactory.createAccountCompany();

        Account relatedAccount = [SELECT Id, Account_External_Id__c, AutoNumber__c FROM Account];

        String correlationId = relatedAccount.Account_External_Id__c + '6300';

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(202, false, correlationId));
        Database.SaveResult result = Database.insert(accountCompany);
        
        Account_Company__c queriedAccountCompany = [SELECT Payment_Terms__c,isCreatedSAP__c, isSyncSAP__c FROM Account_Company__c WHERE Id =: accountCompany.Id];
        queriedAccountCompany.Payment_Terms__c = 'NL01';
        queriedAccountCompany.isCreatedSAP__c = true;
        queriedAccountCompany.isSyncSAP__c = 'Sync';
        System.debug('isCreatedSAP before update: ' + queriedAccountCompany.isCreatedSAP__c);

        Test.startTest();

        Database.SaveResult updateResult = Database.update(queriedAccountCompany);

        Test.stopTest();

        System.assert(updateResult.isSuccess());
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