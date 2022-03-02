@isTest
public class TestAccountTaxClassificationTrigger {

    @TestSetup
    static void makeData(){
        Account a = TestDataFactory.createPersonAccount();
        insert a;
    }


    @isTest
    static void insertTest() {
        Account a = [SELECT id from Account LIMIT 1];

        Account_Sales_Organization__c aso = TestDataFactory.getAso(a.Id);
        insert aso;

        Account_Tax_Classification__c atc = TestDataFactory.createAccountTaxClassification(aso);

        Test.startTest();
        
        Database.SaveResult result = Database.insert(atc);

        Test.stopTest();

        System.assert(result.isSuccess());
    }

    @isTest
    static void updateForCreationTest() {
        Account a = [SELECT id from Account LIMIT 1];

        Account_Sales_Organization__c aso = TestDataFactory.getAso(a.Id);
        insert aso;

        Account_Tax_Classification__c atc = TestDataFactory.createAccountTaxClassification(aso);
        insert atc;

        atc.Tax_Category__c = 'TTX1';

        Test.startTest();
        
        Database.SaveResult result = Database.update(atc);

        Test.stopTest();

        System.assert(result.isSuccess());
    }

    @isTest
    static void updateTest() {
        Account a = [SELECT id from Account LIMIT 1];

        Account_Sales_Organization__c aso = TestDataFactory.getAso(a.Id);
        aso.IsCreatedSAP__c = true;
        insert aso;

        Account_Tax_Classification__c atc = TestDataFactory.createAccountTaxClassification(aso);
        insert atc;

        atc.Tax_Category__c = 'TTX1';

        Test.startTest();
        
        Database.SaveResult result = Database.update(atc);

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