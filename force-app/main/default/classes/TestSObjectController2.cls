@isTest
public with sharing class TestSObjectController2 {

    static testMethod void test() {
		Account a1 = TestDataFactory.createPersonAccount();
        insert a1;
		Account a2 = TestDataFactory.createPersonAccount();
        insert a2;

        Account[] accts = [Select Id, Name, OwnerId from Account];
        String fieldnames = 'Name,Id,OwnerId,AccountNumber,Website,Type,Description,IsDeleted,CreatedDate,AnnualRevenue,Fax,LastActivityDate';
        String testResponse = SObjectController2.getReturnResults(accts, fieldnames);
        System.assert(testResponse.contains('"noEditFieldList":['));
        System.assert(testResponse.contains('"lookupFieldList":["OwnerId"]'));
        
        Account[] empty = [Select Id, Name, OwnerId from Account Where Name='NotInAccounts'];
        String testEmpty = SObjectController2.getReturnResults(empty, fieldnames);
        System.assert(testEmpty.contains('"objectName":"EmptyCollection"'));
    }

}