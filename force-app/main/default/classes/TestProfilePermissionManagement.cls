@isTest
public class TestProfilePermissionManagement {
    @isTest
    static void assignEmailTemplateManagementTest() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Test.startTest();

        ProfilePermissionManagement.assignEmailTemplateManagement();

        Test.stopTest();
    }

    public class MockHttpResponseGenerator implements HttpCalloutMock {

        public MockHttpResponseGenerator(){
            
        }
     
        public HTTPResponse respond(HTTPRequest req) {
            Integer statusCode = 200;
            
            // Create a response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(statusCode);
            res.setStatus('Complete');
            return res;
        }
    }
}