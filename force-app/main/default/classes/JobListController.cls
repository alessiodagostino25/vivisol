public class JobListController {
    
    @AuraEnabled(cacheable=true)
    public static List<Account_Treatment_Job__c> getselectJobs(String recordid2) {
        return AccountTreatmentJobDAO.getselectJobs(recordid2);
    }

    @AuraEnabled(cacheable=true)
    public static List<Account_Treatment__c> getaccounttreatmentstatus(String atid) {
        return AccountTreatmentDAO.getaccounttreatmentstatus(atid);
    }
}