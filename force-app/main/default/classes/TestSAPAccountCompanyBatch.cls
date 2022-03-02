@isTest
public class TestSAPAccountCompanyBatch {
    @isTest
    static void batchCreationFailTest() {
        Account account = TestDataFactory.createPersonAccount();
        insert account;

        Account queriedAccount = [SELECT AutoNumber__c FROM Account WHERE Id =: account.Id];

        Account_Company__c accountCompany = new Account_Company__c(
            Payment_Terms__c = 'NL00',
            Account__c = queriedAccount.Id,
            Company_Code__c = '6300'
        );
        insert accountCompany;

        accountCompany.IsCreatedSAP__c = false;
        accountCompany.IsSyncSAP__c = 'NotSync';
        accountCompany.External_ID__c = queriedAccount.AutoNumber__c + '6300';
        update accountCompany;

        Test.startTest();

        Account_Company__c queriedAccountCompany = [SELECT External_ID__c, IsCreatedSAP__c, IsSyncSAP__c FROM Account_Company__c WHERE Id =: accountCompany.Id];

        System.debug('TEST queriedAC.ExtId: ' + queriedAccountCompany.External_ID__c);
        System.debug('TEST queriedAC.IsCreatedSAP: ' + queriedAccountCompany.IsCreatedSAP__c);
        System.debug('TEST queriedAC.IsSyncSAP: ' + queriedAccountCompany.IsSyncSAP__c);

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(202, false, queriedAccount.AutoNumber__c + '6300'));

        Database.executeBatch(new SAPAccountCompanyBatch());

        Test.stopTest();

        Account_Company__c queriedAC1 = [SELECT IsCreatedSAP__c, IsSyncSAP__c FROM Account_Company__c WHERE Id =: accountCompany.Id];

        System.assertEquals(false, queriedAC1.IsCreatedSAP__c);
    }

    @isTest
    static void batchUpdateFailTest() {
        Account account = TestDataFactory.createPersonAccount();
        insert account;

        Account queriedAccount = [SELECT AutoNumber__c FROM Account WHERE Id =: account.Id];

        Account_Company__c accountCompany = new Account_Company__c(
            Payment_Terms__c = 'NL00',
            Account__c = queriedAccount.Id,
            Company_Code__c = '6300'
        );
        insert accountCompany;

        accountCompany.IsCreatedSAP__c = true;
        accountCompany.IsSyncSAP__c = 'NotSync';
        accountCompany.External_ID__c = queriedAccount.AutoNumber__c + '6300';
        update accountCompany;

        Test.startTest();

        Account_Company__c queriedAccountCompany = [SELECT External_ID__c, IsCreatedSAP__c, IsSyncSAP__c FROM Account_Company__c WHERE Id =: accountCompany.Id];

        System.debug('TEST queriedAC.ExtId: ' + queriedAccountCompany.External_ID__c);
        System.debug('TEST queriedAC.IsCreatedSAP: ' + queriedAccountCompany.IsCreatedSAP__c);
        System.debug('TEST queriedAC.IsSyncSAP: ' + queriedAccountCompany.IsSyncSAP__c);

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(202, false, queriedAccount.AutoNumber__c + '6300'));

        Database.executeBatch(new SAPAccountCompanyBatch());

        Test.stopTest();

        Account_Company__c queriedAC1 = [SELECT IsCreatedSAP__c, IsSyncSAP__c FROM Account_Company__c WHERE Id =: accountCompany.Id];

        System.assertEquals(true, queriedAC1.IsCreatedSAP__c);
        System.assertEquals('NotSync', queriedAC1.IsSyncSAP__c);
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