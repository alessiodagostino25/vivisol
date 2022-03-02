public without sharing class AccountTreatmentBatch implements Database.Batchable<sObject>, Schedulable, Database.AllowsCallouts{

    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id, Status__c, Suspension_end_date__c, Suspension_Reason__c, Suspension_start_date__c, Suspension_Type__c ' + 
                       'FROM Account_Treatment__c WHERE Status__c = \'S\' AND Suspension_end_date__c = YESTERDAY';
        System.debug(query);
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Account_Treatment__c> treatments) {
        //Updating Account Treatments

        List<Account_Treatment__c> toUpdate = new List<Account_Treatment__c>();
        Map<Id, Account_Treatment__c> treatmentMap = new Map<Id, Account_Treatment__c>();
        List<Id> treatmentIds = new List<Id>();
        List<Id> suspensionATSIds = new List<Id>();

        //Updating related Account_Treatment_Status__c records
        Map<Id, Account_Treatment_Status__c> oldStatusMap = new Map<Id, Account_Treatment_Status__c>();
        Map<String, List<Account_Treatment_Status__c>> ATIdToSuspendedATSMap = new Map<String, List<Account_Treatment_Status__c>>();

        for(Account_Treatment__c at : treatments) {
            treatmentIds.add(at.Id);
        }
        
        List<Account_Treatment_Status__c> statusList = [SELECT Id, Status__c, EndDate__c, Patient_Treatment__c, Is_Current_Status__c FROM Account_Treatment_Status__c 
                                                        WHERE Status__c = 'S' AND EndDate__c = NULL AND Patient_Treatment__c IN: treatmentIds];
        System.debug('statusList: ' + statusList);

        if(statusList != null) {
            for(Account_Treatment_Status__c ats : statusList) {
                suspensionATSIds.add(ats.Id);
                oldStatusMap.put(ats.Patient_Treatment__c, ats);
                ats.EndDate__c = Date.today();
                ats.Is_Current_Status__c = false;
            }

            update statusList;
        }

        // Eventually getting other Suspended ATS for these ATs to update the Suspesion_Dates on the AT record

        List<Account_Treatment_Status__c> otherSuspensionATSList = [SELECT StartDate__c, Patient_Treatment__c, Suspension_end_date__c, Suspension_Reason__c,
                                                                    Suspension_start_date__c, Suspension_Type__c 
                                                                    FROM Account_Treatment_Status__c
                                                                    WHERE Status__c = 'S' AND EndDate__c = null AND Patient_Treatment__c IN: treatmentIds
                                                                    AND Id NOT IN: suspensionATSIds ORDER BY StartDate__c ASC];

        if(otherSuspensionATSList != null) {
            for(Account_Treatment_Status__c ats : otherSuspensionATSList) {
                if(ATIdToSuspendedATSMap.get(ats.Patient_Treatment__c) == null) {
                    ATIdToSuspendedATSMap.put(ats.Patient_Treatment__c, new List<Account_Treatment_Status__c>());
                }
                ATIdToSuspendedATSMap.get(ats.Patient_Treatment__c).add(ats);
            }
        }

        for(Account_Treatment__c at : treatments) {
            List<Account_Treatment_Status__c> otherSuspendedStatusList = ATIdToSuspendedATSMap.get(at.Id);

            // Checking if there are other Suspended ATS for this Treatment: in case, update the AT's dates with the ATS' ones

            if(otherSuspendedStatusList != null && !otherSuspendedStatusList.isEmpty()) {
                Account_Treatment_Status__c firstSuspendedStatus = otherSuspendedStatusList[0];

                at.Suspension_end_date__c = firstSuspendedStatus.Suspension_end_date__c;
                at.Suspension_Reason__c = firstSuspendedStatus.Suspension_Reason__c;
                at.Suspension_start_date__c = firstSuspendedStatus.Suspension_start_date__c;
                at.Suspension_Type__c = firstSuspendedStatus.Suspension_Type__c;
            }
            else {
                at.Suspension_end_date__c = null;
                at.Suspension_Reason__c = null;
                at.Suspension_start_date__c = null;
                at.Suspension_Type__c = null;
            }

            at.Status__c = 'A';

            toUpdate.add(at);
            treatmentMap.put(at.Id, at);
        }

        update toUpdate;

        //Creating a new Account_Treatment_Status__c for each Account_Treatment__c
        List<Account_Treatment_Status__c> toInsert = new List<Account_Treatment_Status__c>();
        for(Id treatmentId : treatmentIds) {
            Account_Treatment_Status__c newATS = new Account_Treatment_Status__c(
                Patient_Treatment__c = treatmentId,
                Status__c = 'A',
                StartDate__c = Date.today(),
                Previous_Status__c = oldStatusMap.get(treatmentId).Id,
                Is_Current_Status__c = true
            );
            toInsert.add(newATS);
            System.debug('newATS: ' + newATS);
        }
        insert toInsert;
    }

    public void finish(Database.BatchableContext bc) {
        system.debug('DONE'); //TODO


    }

    public static void Execute(SchedulableContext ctx) {
        Database.executeBatch(new AccountTreatmentBatch()); //TODO
    }

}