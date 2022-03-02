global without sharing class NoComplianceActivitiesSchedulingBatch implements Database.Batchable<sObject>, Schedulable, Database.Stateful {
    global List<Account_Treatment_History__c> noComplianceHistories;
    global List<Id> relatedAccountTreatmentIds;
    global List<Id> relatedATIds = new List<Id>();
    global List<Id> ATIdsForScheduling = new List<Id>();
    global WOLICreationBatch WOLICreationBatch;
    Boolean executeATABatch = false;

    public Database.QueryLocator start(Database.BatchableContext bc) {
        List<String> queryFields = new List<String>{'Scheduling_Rule__c', 'Work_Order__c', 'Task__c', 'Contract_Treatment_Job__c', 'Patient_Treatment__r.Account__c',
        'Patient_Treatment__c', 'Patient_Treatment__r.Contract_Treatment__c', 'Name', 'Case_Subtype__c', 'Case_Type__c', 'Patient_Treatment__r.Treatment_Type__c',
        'Contract_Treatment_Job__r.Contract_Framework__r.Customer__c', 
        'Contract_Treatment_Job__r.Contract_Framework__r.Branch_of_belonging_sales_office__c', 'Contract_Treatment_Job__r.Contract_Framework__c', 
        'Contract_Treatment_Job__r.Contract_Treatment__c', 'Delivery_Channel__c', 
        'Contract_Treatment_Job__r.Contract_Framework__r.Price_list_code__c',
        'Patient_Treatment__r.Customer_Purchase_Date__c', 'Patient_Treatment__r.Customer_Purchase_Order_Number__c', 'Patient_Treatment__r.Account__r.FirstName',
        'Patient_Treatment__r.Account__r.LastName', 'Work_Type__c', 'Patient_Treatment__r.Account__r.IsPersonAccount', 
        'Patient_Treatment__r.Account__r.PersonContactId', 'Frequency__c', 'Frequency_Unit_of_measure__c', 'Patient_Treatment__r.Prescription__r.CreatedDate',
        'Patient_Treatment__r.Prescription__r.Received_Date__c', 'Contract_Treatment_Job__r.Contract_Framework__r.Attachment_Addendum_Type__c',
        'Contract_Treatment_Job__r.Contract_Framework__r.Billing_Via__c', 'Contract_Treatment_Job__r.Contract_Framework__r.Customer__r.Customer_Purchase_Order_Date__c',
        'Contract_Treatment_Job__r.Contract_Framework__r.Customer_Purchase_Order_Date__c', 
        'Contract_Treatment_Job__r.Contract_Framework__r.Customer__r.Customer_Purchase_Order_Number__c',
        'Contract_Treatment_Job__r.Contract_Framework__r.Customer_Purchase_Order_Number__c', 
        'Contract_Treatment_Job__r.Contract_Framework__r.Customer__r.Billing_Reference__c', 'Contract_Treatment_Job__r.Contract_Framework__r.Customer_Request_Code__c', 
        'Contract_Treatment_Job__r.Contract_Framework__r.Invoice_splitting_criterion__c', 'Contract_Treatment_Job__r.Contract_Framework__r.Invoice_Layout__c',
        'Contract_Treatment_Job__r.Invoice_Splitting_Group__c', 'Patient_Treatment__r.Customer_Request_Code__c', 
        'Patient_Treatment__r.Contract_Treatment__r.Invoice_Splitting_Group__c', 'ComplianceSource__c'};

        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
            query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Account_Treatment_Job__c WHERE Patient_Treatment__c =: relatedAccountTreatmentIds';
        System.debug(query);
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Account_Treatment_Job__c> noComplianceATJs) {
       /*  Map<Id, List<Account_Treatment_Job__c>> ATIdToATJsMap = new Map<Id, List<Account_Treatment_Job__c>>();
        Map<Id, Account_Treatment_History__c> ATJIdToATHMap = new Map<Id, Account_Treatment_History__c>();

        List<Account_Treatment_Job__c> ATJsForScheduling = new List<Account_Treatment_Job__c>();

        if(noComplianceATJs != null) {
            for(Account_Treatment_Job__c atj : noComplianceATJs) {
                if(ATIdToATJsMap.get(atj.Patient_Treatment__c) == null) {
                    ATIdToATJsMap.put(atj.Patient_Treatment__c, new List<Account_Treatment_Job__c>());
                }
                ATIdToATJsMap.get(atj.Patient_Treatment__c).add(atj);
            }
        }

        System.debug('NonComplianceATJs size: ' + noComplianceATJs.size());
        for(Account_Treatment_History__c ath : noComplianceHistories) {
            List<Account_Treatment_Job__c> relatedATJs = ATIdToATJsMap.get(ath.Account_Treatment__c);

            for(Account_Treatment_Job__c atj : relatedATJs) {
                System.debug('atj.ComplianceSource__c: ' + atj.ComplianceSource__c);
                System.debug('ATH.ComplianceSource__c: ' + ath.ComplianceSource__c);
                if(atj.ComplianceSource__c != null && 
                ath.ComplianceSource__c != null &&
                (atj.ComplianceSource__c).contains(ath.ComplianceSource__c) &&
                atj.Scheduling_Rule__c == 'Compliance Registration' &&
                atj.Case_Subtype__c == ath.MadeBy__c) {
                    ATJsForScheduling.add(atj);
                    ATJIdToATHMap.put(atj.Id, ath);
                    ATIdsForScheduling.add(atj.Patient_Treatment__c);
                }
            }
        }

        System.debug('ATJsForScheduling size: ' + ATJsForScheduling.size());
        if(!ATJsForScheduling.isEmpty()) {
            BusinessHours bh = [SELECT Id, MondayStartTime, MondayEndTime, TuesdayStartTime, TuesdayEndTime, WednesdayStartTime, WednesdayEndTime,
                            ThursdayStartTime, ThursdayEndTime, FridayStartTime, FridayEndTime  
                            FROM BusinessHours WHERE Name = 'NL'];

            AssignmentRule assignmentRule = [SELECT Id FROM AssignmentRule WHERE SobjectType = 'Case' and Active = true LIMIT 1];

            List<String> queryFieldsForATA = new List<String>{'Account_Treatment__c', 'Start_Date__c', 'End_Date__c', 'Location__c', 
            'Location__r.VisitorAddress.Street', 'Location__r.VisitorAddress.PostalCode', 'Location__r.VisitorAddress.StateCode',
            'Location__r.VisitorAddress.CountryCode', 'Location__r.VisitorAddress.City', 'Location__r.VisitorAddress.Country',
            'Location__r.VisitorAddress.Latitude', 'Location__r.VisitorAddress.Longitude', 'Location__r.VisitorAddress.State'};

            Map<Id, Account_Treatment_Address__c> ATIdToDefaultATAMap = new Map<Id, Account_Treatment_Address__c>();

            // Retrieving all the Default ATAs for all the ATs, then building a map

            List<Account_Treatment_Address__c> defaultAddressList = AccountTreatmentAddressDAO.getDefaultATAFromATs(queryFieldsForATA, ATIdsForScheduling);
            
            for(Account_Treatment_Address__c ata : defaultAddressList) {
                ATIdToDefaultATAMap.put(ata.Account_Treatment__c, ata);
            }

            // Creating the DMLOptions for "Assign using active assignment rules" checkbox

            Database.DMLOptions DMLOptions = new Database.DMLOptions();
            DMLOptions.assignmentRuleHeader.assignmentRuleId = assignmentRule.Id;

            // This first method gets a map linking each ATJ to its default (or chosen) SLA

            Map<Account_Treatment_Job__c, Contract_Treatment_Job_SLA__c> ATJToSLAMap = ATMainComponentService.getATJtoSLAMap(ATJsForScheduling);

            if(ATJToSLAMap != null && DMLOptions != null) {
                // This second method creates a Case for each previously obtained ATJ and schedules the next ones
                List<Case> newCases = NoComplianceActivitiesSchedulingService.createCases(ATJtoSLAMap, DMLOptions, 365, ATJIdToATHMap);

                // Inserting new Cases
                if(newCases != null) {
                    insert newCases;
                }

                // This third method creates a WO for the ATJs with Work_Order__c = true and schedules the next ones: this is the batch to be scheduled to create WOLIs
                WOLICreationBatch = NoComplianceActivitiesSchedulingService.createWorkOrders(ATJToSLAMap, newCases, ATIdToDefaultATAMap);

                // This fourth method creates a Task for the ATJs with Task__c = true and schedules the next ones. Calling this with usePrescription = true and closedWO = null
                List<Task> newTasks = ATMainComponentService.createTasks(ATJToSLAMap, newCases, bh, false, null);

                if(newTasks != null) {
                    insert newTasks;
                    update newCases;
                }
            }
        } */
    }

    public void finish(Database.BatchableContext bc) {

        /* if(WOLICreationBatch != null) {
            Database.executeBatch(WOLICreationBatch, 3);
        }

        // Calling the ATAAlignmentBatch to align Addresses if Cases with WOs have been acjusted

        if(!ATIdsForScheduling.isEmpty()) {
            List<String> ATQueryFields = new List<String>{'RecordType.DeveloperName'};

            List<Account_Treatment__c> accountTreatments = AccountTreatmentDAO.getAccountTreatmentsFromIds(ATQueryFields, ATIdsForScheduling);
            List<Id> ATIdsForATABatch = new List<Id>();

            for(Account_Treatment__c at : accountTreatments) {
                if(at.RecordType.DeveloperName != 'AccountTreatment_Maintenance') {
                    ATIdsForATABatch.add(at.Id);
                }
            }
            if(ATIdsForATABatch != null && executeATABatch == true) {
                ATAAlignmentBatch ATABatch = new ATAAlignmentBatch();
                ATABatch.ATIds = ATIdsForATABatch;

                Database.executeBatch(ATABatch, 100);
            }

            system.debug('DONE'); //TODO
        } */
    }

    public static void Execute(SchedulableContext ctx) {
        Database.executeBatch(new NoComplianceActivitiesSchedulingBatch(), 100);
    }

}