public without sharing class ATJScheduleActivitiesController {
    @AuraEnabled
    public static Account_Treatment_Job__c getATJ(String accountTreatmentJobId) {
        List<String> ATJQueryFields = new List<String>{'Task__c', 'Work_Order__c'};

        List<Account_Treatment_Job__c> ATJList = AccountTreatmentJobDAO.getATJSFROMIds(ATJQueryFields, new List<String>{accountTreatmentJobId});
        return ATJList[0];
    }

    @AuraEnabled
    public static void scheduleActivities(String accountTreatmentJobId, Datetime startDatetimeWO, Datetime startDatetimeTask) {
        AccountTreatmentJobService.scheduleActivities(accountTreatmentJobId, startDatetimeWO, startDatetimeTask);
    }
}