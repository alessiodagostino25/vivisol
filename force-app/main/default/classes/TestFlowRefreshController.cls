@isTest
public class TestFlowRefreshController {
    @isTest
    static void gestSObjectTest() {
        ProductRequest pr = TestDataFactory.createProductRequest();
        insert pr;

        ProductRequestLineItem prli = TestDataFactory.createPRLI();
        prli.ParentId = pr.Id;
        prli.Availability__c = 'Available';
        insert prli;

        Test.startTest();

        List<SObject> queriedSObjects = FlowRefreshController.getSObject(prli.Id);

        Test.stopTest();

        System.assert(queriedSObjects != null);
    }

    @isTest
    static void exceptionTest() {
        Boolean exceptionRisen = false;
        
        Test.startTest();

        try {
            List<SObject> queriedSObjects = FlowRefreshController.getSObject('InvalidId');
        }
        catch(Exception e) {
            exceptionRisen = true;
        }

        Test.stopTest();

        System.assertEquals(true, exceptionRisen);
    }
}