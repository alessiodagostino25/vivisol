@isTest
public class TestCustomOrderPPCController {
    @isTest
    static void customordercalloutDTOTest() {
        Test.startTest();

        List<customordercalloutDTO> DTOs = customOrderProductPagecardController.customordercalloutDTO();

        Test.stopTest();

        System.assert(DTOs != null);
    }

    @isTest
    static void SAPCalloutTest() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Account acc = TestDataFactory.createPersonAccount();
        insert acc;

        Pricebook2 pb = TestDataFactory.initPricebookStandard();
        Product2 pr = TestDataFactory.initProduct();
        PricebookEntry pe =  TestDataFactory.initPricebookEntry(pb, pr);
        Order o = TestDataFactory.initOrder(acc, pb);
		OrderItem oi = TestDataFactory.initOrderItem(o, pb, pr, pe);

        Test.startTest();

        String response = customOrderProductPagecardController.customorderitemsapcallout(oi.Id);

        Test.stopTest();
    }

    public class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody('{"resultList": [{"success": false,"log_event": {"warningList": [{"uuid_Flow": "afbb1641-abb0-4994-a4d3-8f0a89be14a6","recordId": "abc1234","errorType": "Error","error_Description": "Counter reading smaller than in previous document 66","operationType": "BAPI","operation_Name": "ZFM_IF018_MEASUREMENT_CREATE","originSystem": "Salesforce","objectName": null,"service": "equipment-measurement-sfdc-sap-test","status": "fail","targetSystem": "SAP"}],"errorList": [{"uuid_Flow": "afbb1641-abb0-4994-a4d3-8f0a89be14a6","recordId": "abc1234","errorType": "Error","error_Description": "Counter reading smaller than in previous document 66","operationType": "BAPI","operation_Name": "ZFM_IF018_MEASUREMENT_CREATE","originSystem": "Salesforce","objectName": null,"service": "equipment-measurement-sfdc-sap-test","status": "fail","targetSystem": "SAP"}]}}]}');
            res.setStatus('Complete');
            return res;
        }
    }
}