@isTest
private class ASOTriggerTest {
    @isTest static void ASOInsertTest() {
        Account acc = TestDataFactory.createPersonAccount();
        insert acc;
        Sales_Organization__c so = new Sales_Organization__c(Code__c = '0000');
        insert so;
        Account_Sales_Organization__c aso = new Account_Sales_Organization__c(
            Account__c = acc.Id,
            Sales_Organization__c = so.Id,
            Payment_Terms__c = 'NL00'
        );
        Test.startTest();
        insert aso;
        Test.stopTest();
        List<Account_Sales_Organization__c> asoList = [SELECT Id, Account__c, Sales_Organization__c, Code__c, Sales_Organization__r.Code__c FROM Account_Sales_Organization__c];
        List<Account> accounts = [SELECT Id, Account_Sales_Organizations__c FROM Account];
        System.debug('ASO.Sales_Organization__c: ' + asoList[0].Sales_Organization__c);
        System.debug('ASO.Code__c: ' + asoList[0].Code__c);
        System.assert(!asoList.isEmpty());
        System.assert(!accounts.isEmpty());
        System.assertEquals((asoList[0].Sales_Organization__r.Code__c), accounts[0].Account_Sales_Organizations__c);
    }

    @isTest static void ASOInsertFilledTest() {
        Account acc2 = TestDataFactory.createPersonAccount();
        acc2.Account_Sales_Organizations__c = 'PREVIOUS-ASO';
        insert acc2;
        Sales_Organization__c so2 = new Sales_Organization__c(Code__c = '0000');
        insert so2;
        Account_Sales_Organization__c aso2 = new Account_Sales_Organization__c(
            Account__c = acc2.Id,
            Sales_Organization__c = so2.Id,
            Payment_Terms__c = 'NL00'
        );
        Test.startTest();
        insert aso2;
        Test.stopTest();
        List<Account_Sales_Organization__c> asoList2 = [SELECT Id, Account__c, Sales_Organization__c, Sales_Organization__r.Code__c, Code__c FROM Account_Sales_Organization__c];
        List<Account> accounts2 = [SELECT Id, Account_Sales_Organizations__c FROM Account];
        System.assertEquals(('PREVIOUS-ASO' + '; ' + asoList2[0].Sales_Organization__r.Code__c), accounts2[0].Account_Sales_Organizations__c);
    }
}