@isTest
public class TestEmailMessageTrigger {
    @TestSetup
    static void makeData(){
        Order o = TestDataFactory.createOrder();
        insert o;

        Case c = TestDataFactory.createCase();
        insert c;

        Quote__c quote = TestDataFactory.createQuote();
        quote.Case__c = c.Id;
        insert quote;
    }

    @isTest
    static void insertSentTest() {
        Order o = [SELECT Id FROM Order];

        EmailMessage em = TestDataFactory.createSentEmailMessage(o.Id);

        Test.startTest();

        Database.SaveResult result = Database.insert(em);

        Test.stopTest();

        System.assert(result.isSuccess());
    }

    @isTest
    static void insertIncomingNoRefTest() {
        Order o = [SELECT Id FROM Order];
        Case c = [SELECT Id FROM Case];

        EmailMessage em = TestDataFactory.createIncomingEmailMessage(o.Id);
        em.TextBody = 'Test Body';
        em.MessageDate = Datetime.now();
        em.ToAddress = 'antonio.massaro@pwc.com';
        em.ParentId = c.Id;

        Test.startTest();

        Database.SaveResult result = Database.insert(em);

        Test.stopTest();

        System.assert(result.isSuccess());
    }

    @isTest
    static void insertIncomingWithRefTest() {
        Order o = [SELECT Id FROM Order];
        Case c = [SELECT Id FROM Case];
        Quote__c quote = [SELECT Id FROM Quote__c];

        EmailMessage em = TestDataFactory.createIncomingEmailMessage(o.Id);
        em.TextBody = 'Test Body - ref_id::' + quote.Id;
        em.MessageDate = Datetime.now();
        em.ToAddress = 'antonio.massaro@pwc.com';
        em.ParentId = c.Id;

        Test.startTest();

        Database.SaveResult result = Database.insert(em);

        Test.stopTest();

        System.assert(result.isSuccess());
    }
}