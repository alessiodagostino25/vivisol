@isTest
public class TestLayoutService {

    @isTest
    static void getLayoutTest() {

        Account a = TestDataFactory.createPersonAccount();
        insert a;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, true));
        
        Test.startTest();

        LayoutDTO dto = LayoutService.getLayout(a.Id);

        Test.stopTest();

        //System.assert(dto != null);
    }

    private class MockHttpResponseGenerator implements HttpCalloutMock {
       
        Integer responseStatusCode;
        Boolean success;

        public  MockHttpResponseGenerator(Integer status, Boolean success){
            responseStatusCode = status;
            this.success = success;
        }
     
        public HTTPResponse respond(HTTPRequest req) {
            Integer statusCode = 200;
            statusCode = responseStatusCode;
            // Create a response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');

            res.setBody(' "Name":"test-layout"');

            res.setStatusCode(statusCode);
            res.setStatus('Complete');
            return res;
        }

    }
}