trigger AccountTreatmentHistoryTrigger on Account_Treatment_History__c (after insert) {

    if(Trigger.isAfter && Trigger.isInsert) {
        List<String> ATHQueryFields = new List<String>{'RecordType.DeveloperName', 'NotCompliant__c', 'Account_Treatment__c', 'ComplianceSource__c',
        'MadeBy__c', 'CreatedDate', 'Case__r.ParentId', 'PlannedComplianceRegistration__c', 'Case__c'};

        List<Id> ATHIds = new List<Id>();
        List<Id> plannedComplianceRegistrationIds = new List<Id>();
        List<Account_Treatment_History__c> compliantHistories = new List<Account_Treatment_History__c>();
        List<Id> relatedAccountTreatmentIds = new List<Id>();
        List<Account_Treatment_History__c> noComplianceHistories = new List<Account_Treatment_History__c>();

        for(Account_Treatment_History__c ath : Trigger.new) {
            ATHIds.add(ath.Id);
        }

        List<Account_Treatment_History__c> ATHs = AccountTreatmentHistoryDAO.getATHsFromIds(ATHQueryFields, ATHIds);

        for(Account_Treatment_History__c ath : ATHs) {
            if(ath.RecordType.DeveloperName == 'AccountTreatmentHistory_ComplianceRegistration') {
                if(ath.PlannedComplianceRegistration__c == false) {
                    plannedComplianceRegistrationIds.add(ath.Id);
                }
                
                if(ath.NotCompliant__c == false) {
                    compliantHistories.add(ath);
                }
                else if(ath.NotCompliant__c == true) {
                    noComplianceHistories.add(ath);
                    relatedAccountTreatmentIds.add(ath.Account_Treatment__c);
                }
            }
        }

        if(!compliantHistories.isEmpty()) {
            ATHTriggerService.closeNonComplianceCases(compliantHistories);
        }

        if(!plannedComplianceRegistrationIds.isEmpty()) {
            ComplianceReschedulingBatch reschedulingBatch = new ComplianceReschedulingBatch();
            reschedulingBatch.complianceHistoryIds = plannedComplianceRegistrationIds;

            Database.executeBatch(reschedulingBatch, 100);
        }

        if(!noComplianceHistories.isEmpty()) {
            ATHTriggerService.scheduleNoComplianceActivities(noComplianceHistories);
        }
    }
}