global without sharing class ComplianceReschedulingBatch implements Database.Batchable<sObject>, Schedulable, Database.Stateful {
    global List<Id> complianceHistoryIds;
    global List<Id> relatedATIds = new List<Id>();
    global List<WorkOrder> newWorkOrders = new List<WorkOrder>();
    Boolean executeATABatch = false;

    public Database.QueryLocator start(Database.BatchableContext bc) {
        List<String> queryFields = new List<String>{'RecordType.DeveloperName', 'NotCompliant__c', 'Account_Treatment__c', 'ComplianceSource__c',
        'MadeBy__c', 'CreatedDate', 'Case__r.ParentId', 'PlannedComplianceRegistration__c', 'Case__c'};


        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
            query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Account_Treatment_History__c WHERE Id IN: complianceHistoryIds';
        System.debug(query);
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Account_Treatment_History__c> complianceHistories) {
        List<String> workOrderQueryFields = new List<String>{'Id', 'Account_Treatment_Job__c', 'Account_Treatment__c'};
        List<String> ATJQueryFields = new List<String>{'Patient_Treatment__c', 'Contract_Treatment_Job__r.ComplianceFollowUp__c', 'ComplianceSource__c'};
        List<String> caseQueryFields = new List<String>{'Status', 'ClosedDate', 'Autoscheduled__c', 'Account_Treatment_Job__c', 'Account_Treatment_Job__r.Task__c',
        'Account_Treatment_Job__r.Work_Order__c', 'Start_Date__c', 'Account_Treatment_Job__r.Patient_Treatment__c'};

        List<Id> ATJIdsToReschedule = new List<Id>();
        List<Id> relatedAccountTreatmentIds = new List<Id>();
        List<Id> caseIds = new List<Id>();

        Map<Id, List<Account_Treatment_Job__c>> ATIdToRelatedATJsMap = new Map<Id, List<Account_Treatment_Job__c>>();
        Map<Id, Account_Treatment_History__c> ATIdToATHMap = new Map<Id, Account_Treatment_History__c>();
        Map<Id, Case> caseMap = new Map<Id, Case>();

        System.debug('complianceHistories: ' + complianceHistories);

        for(Account_Treatment_History__c ath : complianceHistories) {
            relatedAccountTreatmentIds.add(ath.Account_Treatment__c);
            ATIdToATHMap.put(ath.Account_Treatment__c, ath);
            caseIds.add(ath.Case__c);
        }

        List<Account_Treatment_Job__c> allRelatedATJs = AccountTreatmentJobDAO.getATJsFromATIds(ATJQueryFields, relatedAccountTreatmentIds);
        System.debug('allRelatedATJs: ' + allRelatedATJs);

        // Building AT Id --> List<Related ATJs> Map

        if(allRelatedATJs != null) {
            for(Account_Treatment_Job__c atj : allRelatedATJs) {
                if(ATIdToRelatedATJsMap.get(atj.Patient_Treatment__c) == null) {
                    ATIdToRelatedATJsMap.put(atj.Patient_Treatment__c, new List<Account_Treatment_Job__c>());
                }
                ATIdToRelatedATJsMap.get(atj.Patient_Treatment__c).add(atj);
            }
        }

        for(Account_Treatment_History__c ath : complianceHistories) {
            List<Account_Treatment_Job__c> relatedATJs = ATIdToRelatedATJsMap.get(ath.Account_Treatment__c);
            System.debug('RelatedATJs: ' + relatedATJs);

            // If there are ATJs with ComplianceFollowUp and same ComplianceSource, and they have WOs associated, then they have to be adjusted through the batch

            if(relatedATJs != null) {
                System.debug('RelatedATJs size: ' + relatedATJs.size());
                for(Account_Treatment_Job__c atj : relatedATJs) {
                    if(atj.ComplianceSource__c != null) {
                        List<String> complianceSourceValues = atj.ComplianceSource__c.split(';');
                        System.debug('complianceSourceValues: ' + complianceSourceValues);
                        System.debug('ATH.ComplianceSource: ' + ath.ComplianceSource__c);

                        if(atj.Contract_Treatment_Job__r.ComplianceFollowUp__c == true && complianceSourceValues.contains(ath.ComplianceSource__c)) {
                            ATJIdsToReschedule.add(atj.Id);
                        }
                    }
                }
            }
        }
        System.debug('ATJIdsToReschedule size: ' + ATJIdsToReschedule.size());

        // Calling the same adjustment methods used in ActivitiesDatesAdjustmentBatch, but with the Cases related to the ATJs above instead of the ones closed today

        if(!ATJIdsToReschedule.isEmpty()) {
            List<Case> casesToAdjust = CaseDAO.getCasesFromATJIds(caseQueryFields, ATJIdsToReschedule);
            System.debug('CasesToAdjust size: ' + casesToAdjust.size());

            for(Case c : casesToAdjust) {
                caseMap.put(c.Id, c);
            }

            // Removing the Cases related to the ATHs from the casesToAdjust

            for(Id caseIdRelatedToATH : caseIds) {
                Case caseRelatedToATH = caseMap.get(caseIdRelatedToATH);

                if(caseRelatedToATH != null) {
                    Integer index = casesToAdjust.indexOf(caseRelatedToATH);

                    if(index != null && index != -1) {
                        casesToAdjust.remove(index);
                    }
                }
            }

            List<Case> taskCases = new List<Case>();
            List<Case> WOCases = new List<Case>();
            List<Case> taskAndWOCases = new List<Case>();

            if(casesToAdjust != null) {
                for(Case c : casesToAdjust) {
                    relatedATIds.add(c.Account_Treatment_Job__r.Patient_Treatment__c);
                    if(c.Account_Treatment_Job__r.Task__c == true && c.Account_Treatment_Job__r.Work_Order__c == false) {
                        taskCases.add(c);
                    }
                    else if(c.Account_Treatment_Job__r.Task__c == false && c.Account_Treatment_Job__r.Work_Order__c == true) {
                        WOCases.add(c);
                    }
                    else if(c.Account_Treatment_Job__r.Task__c == true && c.Account_Treatment_Job__r.Work_Order__c == true) {
                        taskAndWOCases.add(c);
                    }
                }
            }

            System.debug('--------------------------------- STARTING ADJUSTMENT -------------------------------');
            if(!taskCases.isEmpty()) {
                System.debug('TaskCases size: ' + taskCases.size());
                ComplianceReschedulingBatchService.adjustDatesTaskCasesCompliance(taskCases, ATIdToATHMap);
            }
    
            if(!WOCases.isEmpty()) {
                System.debug('WOCases size: ' + WOCases.size());
                List<WorkOrder> tmpNewWorkOrders = ComplianceReschedulingBatchService.adjustDatesWOCasesCompliance(WOCases, ATIdToATHMap);

                if(tmpNewWorkOrders != null) {
                    for(WorkOrder wo : tmpNewWorkOrders) {
                        newWorkOrders.add(wo);
                    }
                }
            }
    
            if(!taskAndWOCases.isEmpty()) {
                System.debug('TaskAndWOCases size: ' + taskAndWOCases.size());
                List<WorkOrder> tmpNewWorkOrders = ComplianceReschedulingBatchService.adjustDatesTaskAndWOCasesCompliance(taskAndWOCases, ATIdToATHMap);

                if(tmpNewWorkOrders != null) {
                    for(WorkOrder wo : tmpNewWorkOrders) {
                        newWorkOrders.add(wo);
                    }
                }
            }
    
            if(!WOCases.isEmpty() || !taskAndWOCases.isEmpty()) {
                executeATABatch = true;
            }
        }
    }

    public void finish(Database.BatchableContext bc) {
        WOLICreationBatch woliBatch;

        // Calling the ATAAlignmentBatch to align Addresses if Cases with WOs have been acjusted

        if(!relatedATIds.isEmpty()) {
            List<String> ATQueryFields = new List<String>{'RecordType.DeveloperName'};

            List<Account_Treatment__c> accountTreatments = AccountTreatmentDAO.getAccountTreatmentsFromIds(ATQueryFields, relatedATIds);
            List<Id> ATIdsForATABatch = new List<Id>();

            for(Account_Treatment__c at : accountTreatments) {
                if(at.RecordType.DeveloperName != 'AccountTreatment_Maintenance') {
                    ATIdsForATABatch.add(at.Id);
                }
            }

            if(!newWorkOrders.isEmpty()) {
                woliBatch = new WOLICreationBatch();
                woliBatch.workOrders = newWorkOrders;
            }

            if(ATIdsForATABatch != null && executeATABatch == true) {
                ATAAlignmentBatch ATABatch = new ATAAlignmentBatch();
                ATABatch.ATIds = ATIdsForATABatch;

                if(woliBatch != null && woliBatch.workOrders != null) {
                    if(!Test.isRunningTest()) {
                        ATABatch.WOLIBatch = woliBatch;
                    }
                }

                Database.executeBatch(ATABatch, 100);
            }

            system.debug('DONE'); //TODO
        }

        // Launching WOLICreationBatch for new WOs

        /* if(!newWorkOrders.isEmpty()) {
            WOLICreationBatch woliBatch = new WOLICreationBatch();
            woliBatch.workOrders = newWorkOrders;

            if(!Test.isRunningTest()) {
                Database.executeBatch(woliBatch, 3);
            }
        } */
    }

    public static void Execute(SchedulableContext ctx) {
        Database.executeBatch(new ComplianceReschedulingBatch(), 100);
    }

}