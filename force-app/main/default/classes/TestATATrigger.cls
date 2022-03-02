@isTest
private class TestATATrigger {

    @isTest static void testATAInsert() {
        Profile p = TestDataFactory.getVivisolAdminProfile();
        User u = TestDataFactory.initUser(p);

        System.runAs(u){
            Schema.Location location = TestDataFactory.createLocation();
            insert location;

            Account testAccount = TestDataFactory.createPersonAccount();
            insert testAccount;

            System.debug('----- TEST testAccount.Id: ' + testAccount.Id);

            Contract_Framework__c cf = new Contract_Framework__c();
            insert cf;
            Contract_Treatment__c ct = new Contract_Treatment__c(
                Contract_Framework__c = cf.Id
            );
            insert ct;
            Account_Treatment__c at = new Account_Treatment__c(
                Contract_Treatment__c = ct.Id,
                Account__c = testAccount.Id
            );
            insert at;
            
            Contract_Payer__c cp = [SELECT Id, Account__c, Contract_Framework__c FROM Contract_Payer__c LIMIT 1];
            cp.Account__c = testAccount.Id;
            update cp;

            System.debug('----- TEST cp: ' + cp);
            Account_Treatment_Address__c ata = new Account_Treatment_Address__c(
                Account_Treatment__c = at.Id,
                Location__c = location.Id,
                Default__c = true
            );
      
        
            Test.startTest();
            insert ata;
            Test.stopTest();

            List<Account_Treatment_Address__c> ataList = [SELECT Id, Account_Treatment__c FROM Account_Treatment_Address__c];
            List<Account_Treatment_Address_Payer__c> atapList = [SELECT Id, Payer__c, Account_Treatment_Address__c, Payment_Percentage__c, Contract_Payer__c, Account_Treatment__c 
                                                                FROM Account_Treatment_Address_Payer__c];
            System.assert(!ataList.isEmpty());
            System.assert(!atapList.isEmpty());
            System.assertEquals(cp.Account__c, atapList[0].Payer__c);
            System.assertEquals(ataList[0].Id, atapList[0].Account_Treatment_Address__c);
            System.assertEquals(100, atapList[0].Payment_Percentage__c);
            System.assertEquals(cp.Id, atapList[0].Contract_Payer__c);
            System.assertEquals(ataList[0].Account_Treatment__c, atapList[0].Account_Treatment__c);
        }
    }
}