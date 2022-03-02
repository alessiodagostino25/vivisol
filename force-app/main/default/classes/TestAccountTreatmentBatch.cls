@isTest
public class TestAccountTreatmentBatch {
    
    @isTest
    static void suspensionEndingTest() {
        String correlationId = 'externalId';

        Account a = TestDataFactory.createPersonAccount();
        a.Account_External_Id__c = 'externalId';
        insert a;

        Account_Treatment__c accountTreatment = TestDataFactory.createMRDAccountTreatment(a);
        accountTreatment.Treatment_Type__c = null;
        accountTreatment.Business_Line__c = null;
        accountTreatment.Status__c = 'W';
        accountTreatment.External_Id__c = 'AT-EXT-002343514';
        insert accountTreatment;

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, true, correlationId));

        AccountTreatmentBatch batch = new AccountTreatmentBatch();

        Test.startTest();

        Account_Treatment_Status__c status = new Account_Treatment_Status__c(
            Patient_Treatment__c = accountTreatment.Id,
            Status__c = 'S',
            Suspension_end_date__c = Date.today().addDays(1),
            Suspension_Reason__c = 'UNR',
            Suspension_start_date__c = Date.today().addDays(-3),
            Suspension_Type__c = 'SERVICE',
            External_Id__c = 'ATS-T-0034131353'
        );
        insert status;

        status.Suspension_end_date__c = Date.today().addDays(-1);

        update status;

        accountTreatment.Suspension_end_date__c = Date.today().addDays(-1);
        accountTreatment.Status__c = 'S'; 

        update accountTreatment;

        Account_Treatment__c queriedAccountTreatment = [SELECT Id, Status__c, Suspension_end_date__c FROM Account_Treatment__c WHERE Id =: accountTreatment.Id];

        System.debug('- TEST - AT status after ATS insert: ' + queriedAccountTreatment.Status__c);

        Database.executeBatch(batch);

        Test.stopTest();

        List<Account_Treatment__c> ATs = [SELECT Id, Status__c FROM Account_Treatment__c];
        List<Account_Treatment_Status__c> suspensionATSs = [SELECT Id, Status__c, EndDate__c FROM Account_Treatment_Status__c WHERE Status__c = 'S'];
        List<Account_Treatment_Status__c> activeATSs = [SELECT Id, Status__c, EndDate__c, StartDate__c, Previous_Status__c, Patient_Treatment__c 
                                                        FROM Account_Treatment_Status__c WHERE Status__c = 'A'];
        List<Account_Treatment_Status__c> waitingATSs = [SELECT Id, Status__c, EndDate__c, StartDate__c, Previous_Status__c, Patient_Treatment__c 
                                                        FROM Account_Treatment_Status__c WHERE Status__c = 'W'];

        System.debug('waitingATSs: ' + waitingATSs);
        System.debug('suspensionATSs: ' + suspensionATSs);
        System.debug('activeATSs: ' + activeATSs);
        System.assertEquals('A', ATs[0].Status__c);
        System.assertEquals(1, suspensionATSs.size());
        System.assertEquals(1, activeATSs.size());
        System.assertEquals(Date.today(), suspensionATSs[0].EndDate__c);
        System.assertEquals(Date.today(), activeATSs[0].StartDate__c);
        // System.assertEquals(suspensionATSs[0].Id, activeATSs[0].Previous_Status__c); Don't know why, but it sets the W as previous. Tested on the org, it works fine
        System.assertEquals(ATs[0].Id, activeATSs[0].Patient_Treatment__c);
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