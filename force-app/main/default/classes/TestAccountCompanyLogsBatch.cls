@isTest
public class TestAccountCompanyLogsBatch {
    
    @isTest
    static void batchTest() {

        Account_Company__c accountCompany = TestDataFactory.createAccountCompany();

        Account relatedAccount = [SELECT Id, Account_External_Id__c, AutoNumber__c FROM Account];

        relatedAccount.Account_External_Id__c = relatedAccount.AutoNumber__c;
        update relatedAccount;

        String correlationId = relatedAccount.AutoNumber__c + '6300';

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(202, false, correlationId));

        accountCompany.External_Id__c = correlationId;
        insert accountCompany;
        
        //accountCompany.External_ID__c = accountCompany.Account__r.Account_External_Id__c + accountCompany.Company_Code__c;

        /* System.debug('accountCompany ExtId: ' + accountCompany.External_ID__c);
        Callout_Logger__c logger = new Callout_Logger__c(
            Service__c = 'SFDC_SAP4HANA__SO_CREATE',
            isSolved__c = false,
            Object__c = 'Account_Company__c',
            RecordId__c = accountCompany.External_ID__c
        );

        insert logger; */

        Test.startTest();

        AccountCompanyLogsBatch batch = new AccountCompanyLogsBatch();
        Database.executeBatch(batch);

        Test.stopTest();

        List<Callout_Logger__c> loggers = [SELECT Id, Related_Account_Company__c, Object__c, Service__c FROM Callout_Logger__c WHERE Related_Account_Company__c != null];
        
        System.assertEquals(4, loggers.size());
        System.assertEquals(accountCompany.Id, loggers[0].Related_Account_Company__c);
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
                res.setBody('{"resultList": [{"success": false,"correlationID": "' + correlationId + '","log_event": {"warningList": [{"uuid_Flow": "afbb1641-abb0-4994-a4d3-8f0a89be14a6","recordId": "abc1234","errorType": "Error","error_Description": "Counter reading smaller than in previous document 66","operationType": "BAPI","operation_Name": "SFDC_SAP4HANA__SO_CREATE","originSystem": "Salesforce","objectName": null,"service": "SFDC_SAP4HANA__SO_CREATE","status": "fail","targetSystem": "SAP"}],"errorList": [{"uuid_Flow": "afbb1641-abb0-4994-a4d3-8f0a89be14a6","recordId": "abc1234","errorType": "Error","error_Description": "Counter reading smaller than in previous document 66","operationType": "BAPI","operation_Name": "SFDC_SAP4HANA__SO_CREATE","originSystem": "Salesforce","objectName": null,"service": "SFDC_SAP4HANA__SO_CREATE","status": "fail","targetSystem": "SAP"}]}}]}');
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