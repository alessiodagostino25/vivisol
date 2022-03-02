@isTest
public class TestSAPMeasurementBatch {

    static testMethod void sapMeasurementBatch(){
        TestDataFactory.initMeasurement();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(202, [SELECT Id FROM Measurement__c LIMIT 1].Id));        
        Test.startTest();
        SAPMeasurementBatch sapM = new SAPMeasurementBatch();
        String jobId = system.schedule('Test Sched', '0 0 23 * * ?', sapM);
        SchedulerClass.scheduleSAPMeasurement(jobId);
        Test.stopTest();
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals('0 0 23 * * ?',ct.CronExpression);
    }
    
    public class MockHttpResponseGenerator implements HttpCalloutMock {
       
       Integer responseStatusCode;
       String correlationId;
       public  MockHttpResponseGenerator(Integer status, String correlationId){
           responseStatusCode = status;
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
          res.setBody('{"resultList": [{"success": true,"correlationID": "' + correlationId + '","log_event": {"warningList": [{"uuid_Flow": "afbb1641-abb0-4994-a4d3-8f0a89be14a6","recordId": "abc1234","errorType": "Error","error_Description": "Counter reading smaller than in previous document 66","operationType": "BAPI","operation_Name": "ZFM_IF018_MEASUREMENT_CREATE","originSystem": "Salesforce","objectName": null,"service": "equipment-measurement-sfdc-sap-test","status": "fail","targetSystem": "SAP"}],"errorList": [{"uuid_Flow": "afbb1641-abb0-4994-a4d3-8f0a89be14a6","recordId": "abc1234","errorType": "Error","error_Description": "Counter reading smaller than in previous document 66","operationType": "BAPI","operation_Name": "ZFM_IF018_MEASUREMENT_CREATE","originSystem": "Salesforce","objectName": null,"service": "equipment-measurement-sfdc-sap-test","status": "fail","targetSystem": "SAP"}]}}]}');
          res.setStatusCode(statusCode);
          res.setStatus('Complete');
          return res;
       }
   	}
}