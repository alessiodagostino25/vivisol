@isTest
public class TestMeritPolicyHeaderTrigger {

    @isTest
    public static void testMeritPolicyInsert(){
        Company__c testCompany = TestDataFactory.initCompany();
        insert testCompany;
        Merit_Policy_Header__c testHeader = TestDataFactory.initMeritPolicyHeader(testCompany);

        Annual_Budget__c testBudget = TestDataFactory.initAnnualBudget(testCompany);
        insert testBudget;

        Employee__c testEmployee = TestDataFactory.initEmployee(testCompany);
        insert testEmployee;
        
        Test.startTest();
        insert testHeader;
        Test.stopTest();

        Merit_Policy_Header__c queriedHeader = [SELECT id, Company_code__c, Annual_Budget__c from Merit_Policy_Header__c where id =:testHeader.Id];

        System.AssertEquals(testCompany.Company_code__c, queriedHeader.Company_code__c);
        System.AssertEquals(testBudget.Id, queriedHeader.Annual_Budget__c);
    }

}