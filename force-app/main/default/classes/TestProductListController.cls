@isTest
public class TestProductListController {
    
    
    static testMethod void getSelectedProducts(){
        Product2 p = TestDataFactory.initProduct();
        Account a = TestDataFactory.createPersonAccount();
        insert a;

        Account_Treatment__c at = TestDataFactory.createMRDAccountTreatment(a);
        at.Business_Line__c = null;
        at.Treatment_Type__c = null;
        at.Account__c = a.Id;
        insert at;

        Account_Treatment_Job__c atj = TestDataFactory.initAccountTreatmentJob2(p, at);
        Account_Treatment_Job_Product__c atjp = TestDataFactory.initAccountTreatmentJobProduct2(atj, p);
        test.startTest();
        List<Account_Treatment_Job_Product__c> result = ProductListController.getSelectedProducts(atj.Id);
        test.stopTest();
        system.assertEquals(1, result.size());
    }

}