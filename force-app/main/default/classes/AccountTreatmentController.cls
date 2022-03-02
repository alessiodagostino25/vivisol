public class AccountTreatmentController {
    @AuraEnabled
    public static void assignPermSetNew(){
        AccountTreatmentService.assignPermSetNew();
    }

    @AuraEnabled
    public static void removePermSet() {
        AccountTreatmentService.removePermSet();
    }

    @AuraEnabled
    public static String getAccountId(Id accountTreatmentId) {
        Account_Treatment__c accountTreatment = [SELECT Id, Account__c FROM Account_Treatment__c WHERE Id =: accountTreatmentId];
        System.debug('AccountId: ' + accountTreatment.Account__c);

        return accountTreatment.Account__c;
    }
}