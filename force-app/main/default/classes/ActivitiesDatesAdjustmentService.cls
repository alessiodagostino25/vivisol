public class ActivitiesDatesAdjustmentService {
    
    public static void adjustDatesTaskCases(List<Case> cases, Map<Id, Account_Treatment_History__c> ATIdToATHMap) {
        System.debug('----- adjustDatesTaskCases -----');

        BusinessHours bh = [SELECT Id, MondayStartTime, MondayEndTime, TuesdayStartTime, TuesdayEndTime, WednesdayStartTime, WednesdayEndTime,
                            ThursdayStartTime, ThursdayEndTime, FridayStartTime, FridayEndTime, SaturdayStartTime, SaturdayEndTime, SundayStartTime, SundayEndTime  
                            FROM BusinessHours WHERE Name = 'NL'];

        AssignmentRule assignmentRule = [SELECT Id FROM AssignmentRule WHERE SobjectType = 'Case' AND Active = true LIMIT 1];

        // Creating the DMLOptions for "Assign using active assignment rules" checkbox
        Database.DMLOptions DMLOptions = new Database.DMLOptions();
        DMLOptions.assignmentRuleHeader.assignmentRuleId = assignmentRule.Id;

        Id businessHoursId = bh.Id;

        List<String> queryFields = new List<String>{'Id', 'Due_Date__c', 'CompletedDateTime', 'Start_Date__c', 'End_Date__c', 'ActivityDate', 'Related_SLA__c', 
        'Account_Treatment_Job__c', 'WhatId', 'Account_Treatment_Job__r.Frequency_Unit_of_measure__c', 'Account_Treatment_Job__r.Frequency__c',
        'Account_Treatment_Job__r.Patient_Treatment__c'};

        List<String> queryFieldsForSLA = new List<String>{'IsDefault__c', 'Contract_Treatment_Job__c', 'Max_Time__c', 'Unite_of_measure_Max_Time__c', //Unit, not unite
        'Calculation_Mode__c', 'Offset_Start_Date__c', 'Offset_End_Date__c', 'Offset_unit_of_measure__c', 'Offset_calculation_mode__c', 'Task_MaxTime_Execution__c', 
        'Task_Unite_of_measure_Max_Time__c', 'Task_Calculation_Mode__c', 'Offset_calculation_mode_Task__c', 'Offset_unit_of_measure_Task__c',
        'Offset_End_Date_Task__c', 'Offset_Start_Date_Task__c'};

        List<String> queryFieldsForCase = new List<String>{'Start_Date__c', 'Account_Treatment_Job__c', 'Next_Activity_Date__c', 'OwnerId', 'Status', 'ExcludeFromAdjustment__c'};

        List<String> queryFieldsForTask = new List<String>{'ActivityDate', 'WhatId', 'Status', 'Subject', 'Type', 'TaskSubtype', 'Account__c',
        'Type__c', 'Account_Treatment_Job__c', 'Start_Date__c', 'End_Date__c', 'Due_Date__c', 'Autoscheduled__c', 'Related_SLA__c', 'CompletedDateTime'};

        List<String> queryFieldsForATJ = new List<String>{'Scheduling_Rule__c', 'Work_Order__c', 'Task__c', 'Contract_Treatment_Job__c', 'Patient_Treatment__r.Account__c',
        'Patient_Treatment__c', 'Patient_Treatment__r.Contract_Treatment__c', 'Name', 'Case_Subtype__c', 'Case_Type__c', 'Patient_Treatment__r.Treatment_Type__c',
        'Contract_Treatment_Job__r.Contract_Framework__r.Customer__c', 
        'Contract_Treatment_Job__r.Contract_Framework__r.Branch_of_belonging_sales_office__c', 'Contract_Treatment_Job__r.Contract_Framework__c', 
        'Contract_Treatment_Job__r.Contract_Treatment__c', 'Delivery_Channel__c', 
        'Contract_Treatment_Job__r.Contract_Framework__r.Price_list_code__c',
        'Patient_Treatment__r.Customer_Purchase_Date__c', 'Patient_Treatment__r.Customer_Purchase_Order_Number__c', 'Patient_Treatment__r.Account__r.FirstName',
        'Patient_Treatment__r.Account__r.LastName', 'Work_Type__c', 'Patient_Treatment__r.Account__r.IsPersonAccount', 
        'Patient_Treatment__r.Account__r.PersonContactId', 'Frequency__c', 'Frequency_Unit_of_measure__c', 'Patient_Treatment__r.Prescription__r.CreatedDate',
        'Patient_Treatment__r.Prescription__r.Received_Date__c', 'Frequency_Type__c', 'Scheduling_Time_Frame__c'};

        List<Id> caseIds = new List<Id>();
        List<Id> SLAIds = new List<Id>();
        List<Id> ATJIds = new List<Id>();
        List<Id> allATJIds = new List<Id>();

        List<Task> allChangedTasks = new List<Task>();
        List<Task> allTasksToAdjust = new List<Task>();

        Map<Id, Integer> jobToDatesDifferenceMap = new Map<Id, Integer>();
        Map<Id, Contract_Treatment_Job_SLA__c> SLAMap = new Map<Id, Contract_Treatment_Job_SLA__c>();
        Map<Id, Case> caseMap = new Map<Id, Case>();
        Map<Account_Treatment_Job__c,Contract_Treatment_Job_SLA__c> ATJToSLAMap = new Map<Account_Treatment_Job__c,Contract_Treatment_Job_SLA__c>();
        Map<String, Task> ATJIdToTriggeringTaskMap = new Map<String, Task>();
        Map<String, Integer> ATJToGapMap = new Map<String, Integer>();
        Map<String, List<Task>> ATJIdToTasksToAdjustMap = new Map<String, List<Task>>();

        for(Case c : cases) {
            caseIds.add(c.Id);
        }

        List<Task> allRelatedTasks = TaskDAO.getAutoscheduledTaskForCases(queryFields, caseIds);
        System.debug('AllRelatedTasks size: ' + allRelatedTasks.size());

        if(allRelatedTasks != null) {
            if(ATIdToATHMap == null) {
                for(Task t : allRelatedTasks) {
                    Datetime dueDate = t.Due_Date__c;
                    Datetime completedDateTime = t.CompletedDateTime;

                    // I only need to adjust the tasks related to the ones whose Date part in Due_Date__c is different from Date part in CompletedDateTime

                    if(dueDate != null && completedDateTime != null) {
                        allATJIds.add(t.Account_Treatment_Job__c);
                        ATJIdToTriggeringTaskMap.put(t.Account_Treatment_Job__c, t);

                        Date datePartDueDate = dueDate.date();
                        Date datePartCompletedDateTime = completedDateTime.date();

                        if(datePartDueDate != datePartCompletedDateTime) {
                            SLAIds.add(t.Related_SLA__c);
                            ATJIds.add(t.Account_Treatment_Job__c);

                            // This is the difference that will be reproduced in the following Tasks
                            Integer datesDifference = datePartDueDate.daysBetween(datePartCompletedDateTime);
                            System.debug('----- adjustDatesTaskCases ----- datesDifference: ' + datesDifference);

                            jobToDatesDifferenceMap.put(t.Account_Treatment_Job__c, datesDifference);
                        }
                    }
                }
            }

            // The map in input is not null if the method is called from ComplianceReschedulingBatch

            else {
                List<Id> accountTreatmentIds = new List<Id>();

                for(Task t : allRelatedTasks) {
                    allATJIds.add(t.Account_Treatment_Job__c);

                    if(!accountTreatmentIds.contains(t.Account_Treatment_Job__r.Patient_Treatment__c)) {
                        accountTreatmentIds.add(t.Account_Treatment_Job__r.Patient_Treatment__c);
                    }
                    if(!ATJIds.contains(t.Account_Treatment_Job__c)) {
                        ATJIds.add(t.Account_Treatment_Job__c);
                    }
                    if(!SLAIds.contains(t.Related_SLA__c)) {
                        SLAIds.add(t.Related_SLA__c);
                    }
                }

                Map<Id, Case> ATJIdToFirstCaseMap = CaseDAO.getATJToFirstCaseMap(queryFieldsForCase, ATJIds);
                System.debug('ATJIdToFirstCaseMap: ' + ATJIdToFirstCaseMap);

                // In this case, the datesDifference is based on (gap - days between next case and the History)

                if(ATJIdToFirstCaseMap != null) {
                    for(Task t : allRelatedTasks) { 
                        Account_Treatment_History__c relatedATH = ATIdToATHMap.get(t.Account_Treatment_Job__r.Patient_Treatment__c);
                        
                        if(t.Account_Treatment_Job__r.Frequency__c != null && relatedATH != null) {
                            Integer unitOfMeasureInYear;

                            if(t.Account_Treatment_Job__r.Frequency_Unit_of_measure__c == 'Day') {
                                unitOfMeasureInYear = 365;
                            }
                            else if(t.Account_Treatment_Job__r.Frequency_Unit_of_measure__c == 'Week') {
                                unitOfMeasureInYear = 52;
                            }
                            else if(t.Account_Treatment_Job__r.Frequency_Unit_of_measure__c == 'Month') {
                                unitOfMeasureInYear = 12;
                            }
                            else if(t.Account_Treatment_Job__r.Frequency_Unit_of_measure__c == 'Year') {
                                unitOfMeasureInYear = 1;
                            }

                            // This is the normal gap based on the ATJ's Frequency

                            Integer numberOfTasksToCreate = (Integer) (unitOfMeasureInYear * t.Account_Treatment_Job__r.Frequency__c);
                            Integer gap = (Integer) (365 / numberOfTasksToCreate);

                            Case nextCase = ATJIdToFirstCaseMap.get(t.Account_Treatment_Job__c);

                            if(nextCase != null) {
                                Date nextCaseStartDate = (nextCase.Start_Date__c).date();
                                Integer difference = nextCaseStartDate.daysBetween((relatedATH.CreatedDate).date());

                                if(relatedATH.CreatedDate > nextCaseStartDate) {
                                    difference = ((relatedATH.CreatedDate).date()).daysBetween(nextCaseStartDate);
                                }

                                System.debug('------ difference: ' + difference);

                                Integer datesDifference = gap - Math.abs(difference);

                                if(relatedATH.CreatedDate > nextCaseStartDate) {
                                    datesDifference = gap - difference;
                                }
                                
                                jobToDatesDifferenceMap.put(t.Account_Treatment_Job__c, datesDifference);
                                System.debug('t.ATJ: ' + t.Account_Treatment_Job__c);
                                System.debug('nextCaseStartDate: ' + nextCaseStartDate);
                                System.debug('gap: ' + gap);
                                System.debug('datesDifference: ' + datesDifference);
                            }
                        }
                    }
                }
            }

            // These are all the tasks to adjust related to all the tasks that have changed

            allTasksToAdjust = TaskDAO.getAllTasksToAdjust(queryFields, ATJIds);

            // These are the ATJs of the Tasks to adjust

            List<Account_Treatment_Job__c> ATJs = AccountTreatmentJobDAO.getATJSFROMIds(queryFieldsForATJ, ATJIds);

            // These are all the ATJs related to the Tasks, even the ones not to adjust. This because I need to schedule additional activities for these too

            List<Account_Treatment_Job__c> allATJs = AccountTreatmentJobDAO.getATJSFROMIds(queryFieldsForATJ, allATJIds);

            for(Task t : allTasksToAdjust) {
                caseIds.add(t.WhatId);

                if(ATJIdToTasksToAdjustMap.get(t.Account_Treatment_Job__c) == null) {
                    ATJIdToTasksToAdjustMap.put(t.Account_Treatment_Job__c, new List<Task>());
                }
                ATJIdToTasksToAdjustMap.get(t.Account_Treatment_Job__c).add(t);
            }

            for(Account_Treatment_Job__c atj : allATJs) {
                Integer schedulingTimeFrame = (Integer) ((atj.Scheduling_Time_Frame__c != null) ? atj.Scheduling_Time_Frame__c : 365);
                Integer unitOfMeasureInYear;
                Integer daysInUnitOfMeasure;
                List<Case> relatedAutoscheduledCases = new List<Case>();
                //List<Task> tasksThisATJ = ATJIdToTasksToAdjustMap.get(atj.Id);

                if(schedulingTimeFrame != null/*  && tasksThisATJ != null */) {
                    switch on atj.Frequency_Unit_of_measure__c {
                        when 'Day' {
                            unitOfMeasureInYear = 365;
                        }
                        when 'Week' {
                            unitOfMeasureInYear = 52;
                        }
                        when 'Month' {
                            unitOfMeasureInYear = 12;
                        }
                        when 'Year' {
                            unitOfMeasureInYear = 1;
                        }
                    }

                    switch on atj.Frequency_Unit_of_measure__c {
                        when 'Day' {
                            daysInUnitOfMeasure = 1;
                        }
                        when 'Week' {
                            daysInUnitOfMeasure = 7;
                        }
                        when 'Month' {
                            daysInUnitOfMeasure = 30;
                        }
                        when 'Year' {
                            daysInUnitOfMeasure = 365;
                        }
                    }

                    if(unitOfMeasureInYear != null && daysInUnitOfMeasure != null && atj.Frequency__c != null) {
                        Integer gap;

                        if(atj.Frequency_Type__c != 'IB') {
                            gap = (Integer) (365 / ((Integer) (unitOfMeasureInYear * atj.Frequency__c)));
                        }
                        else if(atj.Frequency_Type__c == 'IB') {
                            //gap = (Integer) (schedulingTimeFrame / tasksThisATJ.size());
                            gap = (Integer) (atj.Frequency__c * daysInUnitOfMeasure);
                        }

                        if(gap != null) {
                            ATJToGapMap.put(atj.Id, gap);
                        }
                    }
                }
            }

            List<Case> casesToAdjust = CaseDAO.getCasesFromIds(queryFieldsForCase, caseIds);
            
            for(Case c : casesToAdjust) {
                caseMap.put(c.Id, c);
            }

            // Not considering Tasks related to Cases to exclude from adjustment

            for(Task t : allTasksToAdjust) {
                Case relatedCase = caseMap.get(t.WhatId);

                if(relatedCase == null || relatedCase.ExcludeFromAdjustment__c == true) {
                    Integer index = allTasksToAdjust.indexOf(t);

                    if(index != -1) {
                        allTasksToAdjust.remove(index);
                    }
                }
            }

            List<Contract_Treatment_Job_SLA__c> allRelatedSLAs = ContractTreatmentJobSlaDAO.getSLAsFromIds(queryFieldsForSLA, SLAIds);

            for(Contract_Treatment_Job_SLA__c sla : allRelatedSLAs) {
                SLAMap.put(sla.Id, sla);
            }

            for(Task t : allTasksToAdjust) {
                if(t.Due_Date__c != null) {
                    System.debug('jobToDifferenceMap: ' + jobToDatesDifferenceMap);
                    Integer datesDifference = jobToDatesDifferenceMap.get(t.Account_Treatment_Job__c);
                    System.debug('datesDifference for task: ' + datesDifference);
                    Contract_Treatment_Job_SLA__c relatedSLA = SLAMap.get(t.Related_SLA__c);
                    Case relatedCase;
                    Integer gap = ATJToGapMap.get(t.Account_Treatment_Job__c);
                    Task relatedTriggeringTask = ATJIdToTriggeringTaskMap.get(t.Account_Treatment_Job__c);
                    List<Task> tasksThisATJ = ATJIdToTasksToAdjustMap.get(t.Account_Treatment_Job__c);
                    Integer index = tasksThisATJ.indexOf(t);

                    if(caseMap.get(t.WhatId) != null && datesDifference != null && relatedSLA != null && gap != null && index != -1) {
                        relatedCase = caseMap.get(t.WhatId);
                        //System.debug('WhatId: ' + t.WhatId);
                        //System.debug('RelatedCase: ' + relatedCase);
                        //System.debug('CaseMap: ' + caseMap);

                        Integer msInBusinessDay = 32400000;  // Milliseconds in 9 hours, a typical business day
                        Integer msInHour = 3600000;

                        // Adjusting scheduled Tasks with the new dates

                        //Datetime newDueDate = (t.Due_Date__c).addDays(datesDifference);
                        //t.Due_Date__c = newDueDate;

                        Datetime newDueDate;

                        if(ATIdToATHMap == null) {
                            if(index == 0) {
                                newDueDate = (relatedTriggeringTask).CompletedDateTime.addDays(gap);
                            }
                            else if(index > 0) {
                                Task previousTask = tasksThisATJ[index - 1];
                                newDueDate = (previousTask).Due_Date__c.addDays(gap);
                            }
                        }
                        else {
                            newDueDate = (t.Due_Date__c).addDays(datesDifference);
                        }

                        t.Due_Date__c = newDueDate;
                        
                        /* if(!BusinessHours.isWithin(businessHoursId, t.Due_Date__c)) {
                            t.Due_Date__c = BusinessHours.nextStartDate(businessHoursId, t.Due_Date__c);
                        } */

                        Date dueDateConverted = Date.newInstance((t.Due_Date__c).year(), (t.Due_Date__c).month(), (t.Due_Date__c).day());
                        Datetime consideredDate = t.Due_Date__c;
                        Time endTime;

                        while(endTime == null) {
                            String dayOfWeekConsideredDate = (consideredDate).format('EEEE');
                            Time dayOfWeekEndTime;
                            System.debug('Considering date: ' + consideredDate);
                            System.debug('Day of week: ' + dayOfWeekConsideredDate);

                            switch on dayOfWeekConsideredDate {
                                when 'Monday' {
                                    dayOfWeekEndTime = bh.MondayEndTime;
                                }
                                when 'Tuesday' {
                                    dayOfWeekEndTime = bh.TuesdayEndTime;
                                }
                                when 'Wednesday' {
                                    dayOfWeekEndTime = bh.WednesdayEndTime;
                                }
                                when 'Thursday' {
                                    dayOfWeekEndTime = bh.ThursdayEndTime;
                                }
                                when 'Friday' {
                                    dayOfWeekEndTime = bh.FridayEndTime;
                                }
                                when 'Saturday' {
                                    dayOfWeekEndTime = bh.SaturdayEndTime;
                                }
                                when 'Sunday' {
                                    dayOfWeekEndTime = bh.SundayEndTime;
                                }
                            }

                            if(dayOfWeekEndTime != null) {
                                endTime = dayOfWeekEndTime.addMinutes(-1);
                            }
                            else {
                                consideredDate = consideredDate.addDays(-1);
                            }
                        }

                        if(endTime != null) {
                            t.Due_Date__c = Datetime.newInstance(consideredDate.date(), endTime);
                        }

                        t.ActivityDate = (t.Due_Date__c).date();
                        
                        if(relatedSLA.Offset_calculation_mode_Task__c == 'Business') {
                            Integer toSubtract;
                            Integer toAdd;
                            
                            if(relatedSLA.Offset_unit_of_measure_Task__c == 'Hour') {
                                toSubtract = (Integer) relatedSLA.Offset_Start_Date_Task__c * msInHour;
                                toAdd = (Integer) relatedSLA.Offset_End_Date_Task__c * msInHour;
                            }
                            else if(relatedSLA.Offset_unit_of_measure_Task__c == 'Day') {
                                toSubtract = (Integer) relatedSLA.Offset_Start_Date_Task__c * msInBusinessDay;
                                toAdd = (Integer) relatedSLA.Offset_End_Date_Task__c * msInBusinessDay;
                            }
                            else if(relatedSLA.Offset_unit_of_measure_Task__c == 'Week') {
                                toSubtract = (Integer) relatedSLA.Offset_Start_Date_Task__c * msInBusinessDay * 5;
                                toAdd = (Integer) relatedSLA.Offset_End_Date_Task__c * msInBusinessDay * 5;
                            }
                            else if(relatedSLA.Offset_unit_of_measure_Task__c == 'Month') {
                                toSubtract = (Integer) relatedSLA.Offset_Start_Date_Task__c * msInBusinessDay * 20;
                                toAdd = (Integer) relatedSLA.Offset_End_Date_Task__c * msInBusinessDay * 20;
                            }

                            // Subtracting Offset from Due_Date (considering BH) to get Start_Date__c

                            t.Start_Date__c = BusinessHours.addGmt(businessHoursId, (t.Due_Date__c), -toSubtract);

                            // Adding Offset to Due_Date (considering BH) to get End_Date__c

                            t.End_Date__c = BusinessHours.addGmt(businessHoursId, (t.Due_Date__c), toAdd);
                        }
                        else if(relatedSLA.Offset_calculation_mode_Task__c == 'Calendar') {

                            // Subtracting Offset from Due_Date without considering BH to get Start_Date__c

                            Integer toSubtract = (Integer) relatedSLA.Offset_Start_Date_Task__c;
                            if(relatedSLA.Offset_unit_of_measure_Task__c == 'Hour') {
                                t.Start_Date__c = (t.Due_Date__c).addHours(-toSubtract);
                            }
                            else if(relatedSLA.Offset_unit_of_measure_Task__c == 'Day') {
                                t.Start_Date__c = (t.Due_Date__c).addDays(-toSubtract);
                            }
                            else if(relatedSLA.Offset_unit_of_measure_Task__c == 'Week') {
                                t.Start_Date__c = (t.Due_Date__c).addDays(-(toSubtract * 7));
                            }
                            else if(relatedSLA.Offset_unit_of_measure_Task__c == 'Month') {
                                t.Start_Date__c = (t.Due_Date__c).addMonths(-toSubtract);
                            }

                            // Adjusting Start_Date__c if it falls outside the BHs

                            if(!BusinessHours.isWithin(businessHoursId, t.Start_Date__c)) {
                                t.Start_Date__c = BusinessHours.nextStartDate(businessHoursId, t.Start_Date__c);
                            }

                            // Adding Offset to Due_Date without considering BH to get End_Date__c

                            Integer toAdd = (Integer) relatedSLA.Offset_End_Date_Task__c;
                            if(relatedSLA.Offset_unit_of_measure_Task__c == 'Hour') {
                                t.End_Date__c = (t.Due_Date__c).addHours(toAdd);
                            }
                            else if(relatedSLA.Offset_unit_of_measure_Task__c == 'Day') {
                                t.End_Date__c = (t.Due_Date__c).addDays(toAdd);
                            }
                            else if(relatedSLA.Offset_unit_of_measure_Task__c == 'Week') {
                                t.End_Date__c = (t.Due_Date__c).addDays(toAdd * 7);
                            }
                            else if(relatedSLA.Offset_unit_of_measure_Task__c == 'Month') {
                                t.End_Date__c = (t.Due_Date__c).addMonths(toAdd);
                            }

                            // Adjusting End_Date__c if it falls outside the BHs

                            if(!BusinessHours.isWithin(businessHoursId, t.End_Date__c)) {
                                t.End_Date__c = BusinessHours.nextStartDate(businessHoursId, t.End_Date__c);
                            }
                        }

                        // Approximating StartDate and EndDate to the Start/End of Business Day

                        if(relatedSLA.Offset_unit_of_measure_Task__c == 'Day' || relatedSLA.Offset_unit_of_measure_Task__c == 'Week' || relatedSLA.Offset_unit_of_measure_Task__c == 'Month') {
                            String dayOfWeekStartDate = t.Start_Date__c.format('EEEE');
                            //System.debug('dayOfWeekStartDate: ' + dayOfWeekStartDate);
                            String dayOfWeekEndDate = t.End_Date__c.format('EEEE');
                            //System.debug('dayOfWeekEndDate: ' + dayOfWeekEndDate);

                            Date startDateConverted = Date.newInstance((t.Start_Date__c).year(), (t.Start_Date__c).month(), (t.Start_Date__c).day());
                            Date endDateConverted = Date.newInstance((t.End_Date__c).year(), (t.End_Date__c).month(), (t.End_Date__c).day());

                            // Getting the day of the week, then getting the StartTime of that day and rebuilding startDate with the same Date but with the new startTime

                            if(dayOfWeekStartDate == 'Monday') {
                                Time mondayStartTime = bh.MondayStartTime;
                                
                                t.Start_Date__c = Datetime.newInstance(startDateConverted, mondayStartTime);
                            }
                            else if(dayOfWeekStartDate == 'Tuesday') {
                                Time tuesdayStartTime = bh.TuesdayStartTime;

                                t.Start_Date__c = Datetime.newInstance(startDateConverted, tuesdayStartTime);
                            }
                            else if(dayOfWeekStartDate == 'Wednesday') {
                                Time wednesdayStartTime = bh.WednesdayStartTime;

                                t.Start_Date__c = Datetime.newInstance(startDateConverted, wednesdayStartTime);
                            }
                            else if(dayOfWeekStartDate == 'Thursday') {
                                Time thursdayStartTime = bh.ThursdayStartTime;

                                t.Start_Date__c = Datetime.newInstance(startDateConverted, thursdayStartTime);
                            }
                            else if(dayOfWeekStartDate == 'Friday') {
                                Time fridayStartTime = bh.FridayStartTime;

                                t.Start_Date__c = Datetime.newInstance(startDateConverted, fridayStartTime);
                            }

                            // Getting the day of the week, then getting the EndTime of that day and rebuilding endDate with the same Date but with the new endTime

                            if(dayOfWeekEndDate == 'Monday') {
                                Time mondayEndTime = bh.MondayEndTime;
                                
                                t.End_Date__c = Datetime.newInstance(endDateConverted, mondayEndTime);
                            }
                            else if(dayOfWeekEndDate == 'Tuesday') {
                                Time tuesdayEndTime = bh.TuesdayEndTime;

                                t.End_Date__c = Datetime.newInstance(endDateConverted, tuesdayEndTime);
                            }
                            else if(dayOfWeekEndDate == 'Wednesday') {
                                Time wednesdayEndTime = bh.WednesdayEndTime;

                                t.End_Date__c = Datetime.newInstance(endDateConverted, wednesdayEndTime);
                            }
                            else if(dayOfWeekEndDate == 'Thursday') {
                                Time thursdayEndTime = bh.ThursdayEndTime;

                                t.End_Date__c = Datetime.newInstance(endDateConverted, thursdayEndTime);
                            }
                            else if(dayOfWeekEndDate == 'Friday') {
                                Time fridayEndTime = bh.FridayEndTime;

                                t.End_Date__c = Datetime.newInstance(endDateConverted, fridayEndTime);
                            }
                        }
                    }

                    if(relatedCase != null && relatedSLA != null) {
                        relatedCase.Start_Date__c =  Datetime.newInstance(t.ActivityDate, Time.newInstance(0,0,0,0));
                        relatedCase.Next_Activity_Date__c = relatedCase.Start_Date__c;
                    }
                }
            }

            if(!allTasksToAdjust.isEmpty()) {
                update allTasksToAdjust;
                update casesToAdjust;
            }

            // Autoscheduling additional activities if the covered period < 365 days

            if(allATJs != null) {
                System.debug('Autoscheduling additional activities for TASK ONLY...');
                System.debug('ATJs size: ' + allATJs.size());

                //Map<Id, Case> ATJToFirstOpenCaseMap = new Map<Id, Case>();
                Map<Id, Case> ATJToLastOpenCaseMap = new Map<Id, Case>();
                Map<Id, Case> ATJToLastCaseMap = new Map<Id, Case>();
                Map<Id, Integer> ATJIdToDaysToScheduleMap = new Map<Id, Integer>();
                Map<Id, Task> ATJToLastTaskMap = new Map<Id, Task>();
                Map<String, Task> ATJToTaskToStartFromMap = new Map<String, Task>();

                List<Account_Treatment_Job__c> ATJsForAdditionalScheduling = new List<Account_Treatment_Job__c>();
                List<Id> allLastCaseIds = new List<Id>();
                List<String> caseToStartFromIds = new List<String>();
                List<Id> newCaseIds = new List<Id>();

                // Mapping each ATJ to its first and last Open Case
                //ATJToFirstOpenCaseMap = CaseDAO.getATJToFirstCaseMap(queryFieldsForCase, allATJIds);
                ATJToLastOpenCaseMap = CaseDAO.getATJToLastCaseMap(queryFieldsForCase, allATJIds);

                // This instead contains the last cases, including the closed ones. I need it if I have no new activities open

                ATJToLastCaseMap = CaseDAO.getATJToAllLastCaseMap(queryFieldsForCase, allATJIds);

                for(Account_Treatment_Job__c atj : allATJs) {
                    //Case firstCase = ATJToFirstOpenCaseMap.get(atj.Id);
                    Case lastCase = ATJToLastOpenCaseMap.get(atj.Id);
                    Case lastClosedCase = ATJToLastCaseMap.get(atj.Id);
                    Date firstCaseStartDate;
                    Date lastCaseStartDate; 
                    Date triggeringDate;
                    Integer scheduledPeriodInDays;
                    Task relatedTriggeringTask = ATJIdToTriggeringTaskMap.get(atj.Id);

                    /* if(firstCase != null && firstCase.Start_Date__c != null) {
                        firstCaseStartDate = (firstCase.Start_Date__c).date();
                    } */
                    if(lastCase != null && lastCase.Start_Date__c != null) {
                        lastCaseStartDate = (lastCase.Start_Date__c).date();
                    }
                    else {
                        lastCase = lastClosedCase;
                    }

                    /* if(firstCaseStartDate != null && lastCaseStartDate != null) {
                        scheduledPeriodInDays = firstCaseStartDate.daysBetween(lastCaseStartDate);
                    }
                    else {
                        scheduledPeriodInDays = 0;
                    } */

                    if(ATIdToATHMap != null) {
                        Account_Treatment_History__c relatedATH = ATIdToATHMap.get(atj.Patient_Treatment__c);

                        if(relatedATH != null) {
                            triggeringDate = (relatedATH.CreatedDate).date();
                        }
                    }
                    else {
                        if(relatedTriggeringTask != null && relatedTriggeringTask.CompletedDateTime != null) {
                            triggeringDate = relatedTriggeringTask.CompletedDateTime.date();
                        }
                    }

                    if(lastCaseStartDate != null && triggeringDate != null) {
                        scheduledPeriodInDays = triggeringDate.daysBetween(lastCaseStartDate);
                    }
                    else {
                        scheduledPeriodInDays = 0;
                    }
                    
                    System.debug('Scheduled Period in Days TASK ONLY: ' + scheduledPeriodInDays);
                    System.debug('lastCase TASK ONLY: ' + lastCase);

                    Integer schedulingTimeFrame = (Integer) ((atj.Scheduling_Time_Frame__c != null) ? atj.Scheduling_Time_Frame__c : 365);

                    // Scheduling additional activities if it is less than atj.SchedulingTimeFrame days
                    if(scheduledPeriodInDays < schedulingTimeFrame) {
                        Integer daysToScheduleLeft;

                        if(/* firstCaseStartDate != null */triggeringDate != null && lastCaseStartDate != null) {
                            //Date schedulingPeriodEndDate = firstCaseStartDate.addYears(1);
                            Date schedulingPeriodEndDate = triggeringDate.addDays(schedulingTimeFrame);
                            System.debug('Scheduling Period End Date TASK ONLY: ' + schedulingPeriodEndDate);

                            daysToScheduleLeft = lastCaseStartDate.daysBetween(schedulingPeriodEndDate);
                        }
                        else {
                            daysToScheduleLeft = schedulingTimeFrame;
                        }
                        System.debug('daysToScheduleLeft TASK ONLY: ' + daysToScheduleLeft);

                        if(atj.Frequency__c != null) {
                            ATJsForAdditionalScheduling.add(atj);
                        }

                        //allLastCaseIds.add(lastCase.Id);
                        if(lastClosedCase != null && lastClosedCase.Id != null) {
                            allLastCaseIds.add(lastClosedCase.Id);
                        }
                        if(lastCase != null && lastCase.Id != null) {
                            caseToStartFromIds.add(lastCase.Id);
                        }

                        ATJIdToDaysToScheduleMap.put(atj.Id, daysToScheduleLeft);
                    }
                }

                if(!ATJsForAdditionalScheduling.isEmpty()) {
                    
                    // This method calls ATMainComponentService.createCases, but for a restricted period (DaysToSchedule)
                    List<Case> newCases = scheduleAdditionalCases(ATJsForAdditionalScheduling, ATJIdToDaysToScheduleMap, DMLOptions);
                    List<Case> queriedNewCases = new List<Case>();

                    if(!newCases.isEmpty()) {
                        insert newCases;

                        // Building a ATJ.Id --> List<RelatedCases> Map to run the autoscheduling only on the Cases related to each ATJ

                        Map<Id, List<Case>> ATJIdToCasesMap = new Map<Id, List<Case>>();

                        for(Case c: newCases) {
                            newCaseIds.add(c.Id);
                        }

                        queriedNewCases = CaseDAO.getCasesFromIds(queryFieldsForCase, newCaseIds);

                        for(Case c : queriedNewCases) {
                            if(ATJIdToCasesMap.get(c.Account_Treatment_Job__c) == null) {
                                ATJIdToCasesMap.put(c.Account_Treatment_Job__c, new List<Case>());
                            }
                            ATJIdToCasesMap.get(c.Account_Treatment_Job__c).add(c);
                        }

                        ATJToSLAMap = ATMainComponentService.getATJToSLAMap(ATJsForAdditionalScheduling);

                        // Getting the Tasks of each last Case marked with Autoscheduled__c = true (there is only one Task for each Case)

                        List<Task> allLastTasks = TaskDAO.getAutoscheduledTaskForCases(queryFieldsForTask, allLastCaseIds);
                        List<Task> tasksToStartFrom = TaskDAO.getAutoscheduledTaskForCases(queryFieldsForTask, caseToStartFromIds);

                        for(Task t : allLastTasks) {
                            ATJToLastTaskMap.put(t.Account_Treatment_Job__c, t);
                        }

                        if(tasksToStartFrom != null) {
                            for(Task t : tasksToStartFrom) {
                                ATJToTaskToStartFromMap.put(t.Account_Treatment_Job__c, t);
                            }
                        }

                        if(!ATJToSLAMap.isEmpty()) {
                            List<Task> tasksToInsert = new List<Task>();

                            for(Account_Treatment_Job__c atj : ATJsForAdditionalScheduling) {
                                System.debug('TASK --- atj.Id: ' + atj.Id);
                                // Getting the SLA related to the CTJ related to this ATJ
                                Contract_Treatment_Job_SLA__c relatedSLA = ATJToSLAMap.get(atj);
                                System.debug('relatedSLA TASK: ' + relatedSLA);

                                // Getting only the Cases related to this ATJ
                                List<Case> relatedCases = ATJIdToCasesMap.get(atj.Id);
                                System.debug('relatedCases: ' + relatedCases);

                                Task startingTask;
                                
                                if(ATJToTaskToStartFromMap.get(atj.Id) != null) {
                                    startingTask = ATJToTaskToStartFromMap.get(atj.Id);
                                }
                                else {
                                    startingTask = ATJToLastTaskMap.get(atj.Id);
                                }

                                // Getting the last Case for this ATJ (it's the closed one, the map is filled before newCases are inserted)
                                Case startingCase;
                                
                                if(ATJToLastOpenCaseMap.get(atj.Id) != null) {
                                    startingCase = ATJToLastOpenCaseMap.get(atj.Id);
                                }
                                else {
                                    startingCase = ATJToLastCaseMap.get(atj.Id);
                                }

                                /* Calling .autoscheduleTasks with "false" to tell the method that the first Task has not been scheduled yet
                                    (opposite of ATMainComponentService.createTasks)
                                */

                                if(startingTask != null && startingCase != null && relatedSLA != null) {
                                    System.debug('startingTask: ' + startingTask.Id);
                                    System.debug('startingCase: ' + startingCase.Id);

                                    // Day Autoscheduling

                                    if(atj.Frequency_Unit_of_measure__c == 'Day') {
                                        List<Task> newTasks = ATMainComponentService.autoscheduleTasks(atj, startingTask, startingCase, relatedSLA, 365, relatedCases, bh, false);

                                        for(Task t : newTasks) {
                                            tasksToInsert.add(t);
                                        }
                                    }

                                    // Week Autoscheduling 

                                    else if(atj.Frequency_Unit_of_measure__c == 'Week') {
                                        List<Task> newTasks = ATMainComponentService.autoscheduleTasks(atj, startingTask, startingCase, relatedSLA, 52, relatedCases, bh, false);

                                        for(Task t : newTasks) {
                                            tasksToInsert.add(t);
                                        }
                                    }

                                    // Month Autoscheduling

                                    else if(atj.Frequency_Unit_of_measure__c == 'Month') {
                                        List<Task> newTasks = ATMainComponentService.autoscheduleTasks(atj, startingTask, startingCase, relatedSLA, 12, relatedCases, bh, false);

                                        for(Task t : newTasks) {
                                            tasksToInsert.add(t);
                                        }
                                    }

                                    // Year Autoscheduling

                                    else if(atj.Frequency_Unit_of_measure__c == 'Year') {
                                        List<Task> newTasks = ATMainComponentService.autoscheduleTasks(atj, startingTask, startingCase, relatedSLA, 1, relatedCases, bh, false);

                                        for(Task t : newTasks) {
                                            tasksToInsert.add(t);
                                        }
                                    }
                                }
                            }

                            if(!tasksToInsert.isEmpty()) {
                                insert tasksToInsert;
                                update queriedNewCases;
                            }
                        }
                    }
                }
            }
        }
    }

    public static List<WorkOrder> adjustDatesWOCases(List<Case> cases, Map<Id, Account_Treatment_History__c> ATIdToATHMap) {
        BusinessHours bh = [SELECT Id, MondayStartTime, MondayEndTime, TuesdayStartTime, TuesdayEndTime, WednesdayStartTime, WednesdayEndTime,
                            ThursdayStartTime, ThursdayEndTime, FridayStartTime, FridayEndTime, SaturdayStartTime, SaturdayEndTime, SundayStartTime, SundayEndTime  
                            FROM BusinessHours WHERE Name = 'NL'];

        AssignmentRule assignmentRule = [SELECT Id FROM AssignmentRule WHERE SobjectType = 'Case' AND Active = true LIMIT 1];

        // Creating the DMLOptions for "Assign using active assignment rules" checkbox
        Database.DMLOptions DMLOptions = new Database.DMLOptions();
        DMLOptions.assignmentRuleHeader.assignmentRuleId = assignmentRule.Id;

        Id businessHoursId = bh.Id;

        List<String> queryFields = new List<String>{'Id', 'Due_Date__c', 'StartDate', 'EndDate', 'Related_SLA__c',
        'Scheduled_Start_Date__c', 'Scheduled_End_Date__c', 'Account_Treatment_Job__c', 'CaseId', 'Account_Treatment_Job__r.Frequency_Unit_of_measure__c', 
        'Account_Treatment_Job__r.Frequency__c', 'Account_Treatment_Job__r.Patient_Treatment__c'};

        List<String> queryFieldsForSLA = new List<String>{'IsDefault__c', 'Contract_Treatment_Job__c', 'Max_Time__c', 'Unite_of_measure_Max_Time__c', //Unit, not unite
        'Calculation_Mode__c', 'Offset_Start_Date__c', 'Offset_End_Date__c', 'Offset_unit_of_measure__c', 'Offset_calculation_mode__c', 'Task_MaxTime_Execution__c', 
        'Task_Unite_of_measure_Max_Time__c', 'Task_Calculation_Mode__c'};

        List<String> queryFieldsForCase = new List<String>{'Start_Date__c', 'Account_Treatment_Job__c', 'Next_Activity_Date__c', 'OwnerId'};

        List<String> queryFieldsForATJ = new List<String>{'Scheduling_Rule__c', 'Work_Order__c', 'Task__c', 'Contract_Treatment_Job__c', 'Patient_Treatment__r.Account__c',
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
        'Patient_Treatment__r.Contract_Treatment__r.Invoice_Splitting_Group__c', 'Frequency_Type__c', 'Scheduling_Time_Frame__c'};

        List<String> queryFieldsForWO = new List<String>{'AccountId', 'Account_Sold_To__c', 'Account_Sales_Organization__c', 'Account_Treatment__c', 'CaseId',
        'Contract_Framework__c', 'Contract_Treatment__c', 'Contract_Treatment_Job__c', 'Customer_Purchase_Order_Date__c', 'Customer_Purchase_Order_Number__c',
        'Delivery_Type__c', 'Document_Type__c', 'OwnerId', 'Pricebook2Id',
        'Status', 'Subject', 'WorkTypeId', 'Related_SLA__c', 'LocationId', 'City', 'Country', 'CountryCode', 'Latitude', 'Longitude', 'PostalCode', 'State',
        'StateCode', 'Street', 'Account_Treatment_Job__c', 'Autoscheduled__c', 'AssetId', 'Label__c', 'ContactId', 'StartDate', 'EndDate', 'Due_Date__c',
        'Scheduled_Start_Date__c', 'Scheduled_End_Date__c', 'Attachment_Addendum_Type__c', 'Billing_Via__c', 'Billing_Reference__c', 'Invoice_splitting_criterion__c',
        'InvoiceLayout__c', 'Job_InvoiceSplittingGroup__c', 'Treatment_Customer_Purchase_Order_Date__c', 'Treatment_Customer_Purchase_Order_Number__c',
        'Treatment_Customer_Request_Code__c', 'Treatment_InvoiceSplittingGroup__c', 'SalesOrganization__c', 'Division__c', 'Distribution_Channel__c',
        'Sales_Group__c', 'Sales_Office__c', 'Job_Product_Code__c', 'Case.Status'};

        List<String> queryFieldsForWOLI = new List<String>{'WorkOrderId', 'PricebookEntryId', 'Quantity', 'Customer_Product_Code__c', 'Customer_Request_Code__c',
        'Account_Treatment_Job_Product__c', 'Customer_Purchase_Order_Number__c', 'Customer_Purchase_Order_Date__c', 'StorageLocation__c', 'Plant__c',
        'InvoiceSplittingGroup__c', 'AssetId', 'Serial_Number__c'};

        List<Id> caseIds = new List<Id>();
        List<Id> SLAIds = new List<Id>();
        List<Id> ATJIds = new List<Id>();
        List<Id> allATJIds = new List<Id>();

        List<WorkOrder> allWOsToAdjust = new List<WorkOrder>();
        List<WorkOrder> workOrdersToInsert = new List<WorkOrder>();

        Map<Id, Integer> jobToDatesDifferenceMap = new Map<Id, Integer>();
        Map<Id, Contract_Treatment_Job_SLA__c> SLAMap = new Map<Id, Contract_Treatment_Job_SLA__c>();
        Map<Id, Case> caseMap = new Map<Id, Case>();
        Map<Account_Treatment_Job__c,Contract_Treatment_Job_SLA__c> ATJToSLAMap = new Map<Account_Treatment_Job__c,Contract_Treatment_Job_SLA__c>();
        Map<String, WorkOrder> ATJIdToTriggeringWOMap = new Map<String, WorkOrder>();
        Map<String, Integer> ATJToGapMap = new Map<String, Integer>();
        Map<String, List<WorkOrder>> ATJIdToWOsToAdjustMap = new Map<String, List<WorkOrder>>();

        for(Case c : cases) {
            caseIds.add(c.Id);
        }

        List<WorkOrder> allRelatedWOs = WorkOrderDAO.getAutoscheduledWOForCases(queryFields, caseIds);

        if(allRelatedWOs != null) {
            if(ATIdToATHMap == null) {
                for(WorkOrder wo : allRelatedWOs) {
                    Datetime dueDate = wo.Due_Date__c;
                    Datetime endDate = wo.EndDate;

                    // I only need to adjust the WOs related to the ones whose Date part in Due_Date__c is different from Date part in CompletedDateTime

                    if(dueDate != null && endDate != null) {
                        allATJIds.add(wo.Account_Treatment_Job__c);
                        ATJIdToTriggeringWOMap.put(wo.Account_Treatment_Job__c, wo);

                        Date datePartDueDate = dueDate.date();
                        Date datePartEndDate = endDate.date();

                        if(datePartDueDate != datePartEndDate) {
                            SLAIds.add(wo.Related_SLA__c);
                            ATJIds.add(wo.Account_Treatment_Job__c);

                            // This is the difference that will be reproduced in the following Tasks
                            Integer datesDifference = datePartDueDate.daysBetween(datePartEndDate);

                            jobToDatesDifferenceMap.put(wo.Account_Treatment_Job__c, datesDifference);
                        }
                    }
                }
            }

            // The map in input is not null if the method is called from ComplianceReschedulingBatch

            else {
                List<Id> accountTreatmentIds = new List<Id>();

                for(WorkOrder wo : allRelatedWOs) {
                    allATJIds.add(wo.Account_Treatment_Job__c);

                    if(!accountTreatmentIds.contains(wo.Account_Treatment_Job__r.Patient_Treatment__c)) {
                        accountTreatmentIds.add(wo.Account_Treatment_Job__r.Patient_Treatment__c);
                    }
                    if(!ATJIds.contains(wo.Account_Treatment_Job__c)) {
                        ATJIds.add(wo.Account_Treatment_Job__c);
                    }
                    if(!SLAIds.contains(wo.Related_SLA__c)) {
                        SLAIds.add(wo.Related_SLA__c);
                    }
                }

                Map<Id, Case> ATJIdToFirstCaseMap = CaseDAO.getATJToFirstCaseMap(queryFieldsForCase, ATJIds);

                // In this case, the datesDifference is based on (gap - days between next case and the History)

                if(ATJIdToFirstCaseMap != null) {
                    for(WorkOrder wo : allRelatedWOs) { 
                        Account_Treatment_History__c relatedATH = ATIdToATHMap.get(wo.Account_Treatment_Job__r.Patient_Treatment__c);
                        
                        if(wo.Account_Treatment_Job__r.Frequency__c != null && relatedATH != null) {
                            Integer unitOfMeasureInYear;

                            if(wo.Account_Treatment_Job__r.Frequency_Unit_of_measure__c == 'Day') {
                                unitOfMeasureInYear = 365;
                            }
                            else if(wo.Account_Treatment_Job__r.Frequency_Unit_of_measure__c == 'Week') {
                                unitOfMeasureInYear = 52;
                            }
                            else if(wo.Account_Treatment_Job__r.Frequency_Unit_of_measure__c == 'Month') {
                                unitOfMeasureInYear = 12;
                            }
                            else if(wo.Account_Treatment_Job__r.Frequency_Unit_of_measure__c == 'Year') {
                                unitOfMeasureInYear = 1;
                            }

                            // This is the normal gap based on the ATJ's Frequency

                            Integer numberOfTasksToCreate = (Integer) (unitOfMeasureInYear * wo.Account_Treatment_Job__r.Frequency__c);
                            Integer gap = (Integer) (365 / numberOfTasksToCreate);

                            Case nextCase = ATJIdToFirstCaseMap.get(wo.Account_Treatment_Job__c);

                            if(nextCase != null) {
                                Date nextCaseStartDate = (nextCase.Start_Date__c).date();
                                Integer difference = nextCaseStartDate.daysBetween((relatedATH.CreatedDate).date());

                                if(relatedATH.CreatedDate > nextCaseStartDate) {
                                    difference = ((relatedATH.CreatedDate).date()).daysBetween(nextCaseStartDate);
                                }

                                System.debug('------ difference: ' + difference);

                                Integer datesDifference = gap - Math.abs(difference);

                                if(relatedATH.CreatedDate > nextCaseStartDate) {
                                    datesDifference = gap - difference;
                                }

                                jobToDatesDifferenceMap.put(wo.Account_Treatment_Job__c, datesDifference);
                            }
                        }
                    }
                }
            }


            // These are all the WOs to adjust related to all the WOs that have changed (probably just one)

            allWOsToAdjust = WorkOrderDAO.getAllWOsToAdjust(queryFields, ATJIds);

            List<Account_Treatment_Job__c> ATJs = AccountTreatmentJobDAO.getATJSFROMIds(queryFieldsForATJ, ATJIds);

            // These are all the ATJs related to the WOs, even the ones not to adjust. This because I need to schedule additional activities for these too

            List<Account_Treatment_Job__c> allATJs = AccountTreatmentJobDAO.getATJSFROMIds(queryFieldsForATJ, allATJIds);

            if(allWOsToAdjust != null) {
                for(WorkOrder wo : allWOsToAdjust) {
                    caseIds.add(wo.CaseId);

                    if(ATJIdToWOsToAdjustMap.get(wo.Account_Treatment_Job__c) == null) {
                        ATJIdToWOsToAdjustMap.put(wo.Account_Treatment_Job__c, new List<WorkOrder>());
                    }
                    ATJIdToWOsToAdjustMap.get(wo.Account_Treatment_Job__c).add(wo);
                }
            }

            for(Account_Treatment_Job__c atj : allATJs) {
                Integer schedulingTimeFrame = (Integer) ((atj.Scheduling_Time_Frame__c != null) ? atj.Scheduling_Time_Frame__c : 365);
                Integer unitOfMeasureInYear;
                Integer daysInUnitOfMeasure;
                List<Case> relatedAutoscheduledCases = new List<Case>();
                //List<WorkOrder> workOrdersThisATJ = ATJIdToWOsToAdjustMap.get(atj.Id);

                if(schedulingTimeFrame != null /* && workOrdersThisATJ != null */) {
                    switch on atj.Frequency_Unit_of_measure__c {
                        when 'Day' {
                            unitOfMeasureInYear = 365;
                        }
                        when 'Week' {
                            unitOfMeasureInYear = 52;
                        }
                        when 'Month' {
                            unitOfMeasureInYear = 12;
                        }
                        when 'Year' {
                            unitOfMeasureInYear = 1;
                        }
                    }

                    switch on atj.Frequency_Unit_of_measure__c {
                        when 'Day' {
                            daysInUnitOfMeasure = 1;
                        }
                        when 'Week' {
                            daysInUnitOfMeasure = 7;
                        }
                        when 'Month' {
                            daysInUnitOfMeasure = 30;
                        }
                        when 'Year' {
                            daysInUnitOfMeasure = 365;
                        }
                    }

                    if(unitOfMeasureInYear != null && daysInUnitOfMeasure != null && atj.Frequency__c != null) {
                        Integer gap;

                        if(atj.Frequency_Type__c != 'IB') {
                            gap = (Integer) (365 / ((Integer) (unitOfMeasureInYear * atj.Frequency__c)));
                        }
                        else if(atj.Frequency_Type__c == 'IB') {
                            //gap = (Integer) (schedulingTimeFrame / workOrdersThisATJ.size());
                            gap = (Integer) (atj.Frequency__c * daysInUnitOfMeasure);
                        }

                        if(gap != null) {
                            ATJToGapMap.put(atj.Id, gap);
                        }
                    }
                }
            }

            List<Case> casesToAdjust = CaseDAO.getCasesFromIds(queryFieldsForCase, caseIds);
            
            for(Case c : casesToAdjust) {
                caseMap.put(c.Id, c);
            }

            List<Contract_Treatment_Job_SLA__c> allRelatedSLAs = ContractTreatmentJobSlaDAO.getSLAsFromIds(queryFieldsForSLA, SLAIds);

            for(Contract_Treatment_Job_SLA__c sla : allRelatedSLAs) {
                SLAMap.put(sla.Id, sla);
            }

            if(allWOsToAdjust != null) {
                for(WorkOrder wo : allWOsToAdjust) {
                    if(wo.Due_Date__c != null) {
                        Integer datesDifference = jobToDatesDifferenceMap.get(wo.Account_Treatment_Job__c);
                        Contract_Treatment_Job_SLA__c relatedSLA = SLAMap.get(wo.Related_SLA__c);
                        Case relatedCase;
                        Integer gap = ATJToGapMap.get(wo.Account_Treatment_Job__c);
                        WorkOrder relatedTriggeringWO = ATJIdToTriggeringWOMap.get(wo.Account_Treatment_Job__c);
                        List<WorkOrder> workOrdersThisATJ = ATJIdToWOsToAdjustMap.get(wo.Account_Treatment_Job__c);
                        Integer index = workOrdersThisATJ.indexOf(wo);

                        System.debug('wo: ' + wo.Id);
                        System.debug('index: ' + index);
                        System.debug('gap: ' + gap);

                        if(caseMap.get(wo.CaseId) != null && relatedSLA != null && datesDifference != null && gap != null && index != -1) {
                            relatedCase = caseMap.get(wo.CaseId);

                            Integer msInBusinessDay = 32400000;  // Milliseconds in 9 hours, a typical business day
                            Integer msInHour = 3600000;

                            // Adjusting scheduled WOs with the new dates

                            Datetime newDueDate;

                            /* if(allWOsToAdjust.indexOf(wo) == 0) {
                                newDueDate = (wo.EndDate).addDays(datesDifference);
                            } */
                            //else {
                               // newDueDate = (wo.Due_Date__c).addDays(datesDifference);
                            //}
                            
                            //wo.Due_Date__c = newDueDate;

                            if(ATIdToATHMap == null) {
                                if(index == 0) {
                                    newDueDate = (relatedTriggeringWO).EndDate.addDays(gap);
                                }
                                else if(index > 0) {
                                    WorkOrder previousWO = workOrdersThisATJ[index - 1];
                                    newDueDate = (previousWO).Due_Date__c.addDays(gap);
                                }
                            }
                            else {
                                newDueDate = (wo.Due_Date__c).addDays(datesDifference);
                            }

                            wo.Due_Date__c = newDueDate;
                            
                            /* if(!BusinessHours.isWithin(businessHoursId, wo.Due_Date__c)) {
                                if(wo.Due_Date__c.time() != Time.newInstance(18, 0, 0, 0) || !BusinessHours.isWithin(businessHoursId, wo.Due_Date__c.date())) {
                                    wo.Due_Date__c = BusinessHours.nextStartDate(businessHoursId, wo.Due_Date__c);
                                }
                            } */

                            Date dueDateConverted = Date.newInstance((wo.Due_Date__c).year(), (wo.Due_Date__c).month(), (wo.Due_Date__c).day());
                            Datetime consideredDate = wo.Due_Date__c;
                            Time endTime;

                            while(endTime == null) {
                                String dayOfWeekConsideredDate = (consideredDate).format('EEEE');
                                Time dayOfWeekEndTime;
                                System.debug('Considering date: ' + consideredDate);
                                System.debug('Day of week: ' + dayOfWeekConsideredDate);

                                switch on dayOfWeekConsideredDate {
                                    when 'Monday' {
                                        dayOfWeekEndTime = bh.MondayEndTime;
                                    }
                                    when 'Tuesday' {
                                        dayOfWeekEndTime = bh.TuesdayEndTime;
                                    }
                                    when 'Wednesday' {
                                        dayOfWeekEndTime = bh.WednesdayEndTime;
                                    }
                                    when 'Thursday' {
                                        dayOfWeekEndTime = bh.ThursdayEndTime;
                                    }
                                    when 'Friday' {
                                        dayOfWeekEndTime = bh.FridayEndTime;
                                    }
                                    when 'Saturday' {
                                        dayOfWeekEndTime = bh.SaturdayEndTime;
                                    }
                                    when 'Sunday' {
                                        dayOfWeekEndTime = bh.SundayEndTime;
                                    }
                                }

                                if(dayOfWeekEndTime != null) {
                                    endTime = dayOfWeekEndTime.addMinutes(-1);
                                }
                                else {
                                    consideredDate = consideredDate.addDays(-1);
                                }
                            }

                            if(endTime != null) {
                                wo.Due_Date__c = Datetime.newInstance(consideredDate.date(), endTime);
                            }

                            if(relatedSLA.Offset_calculation_mode__c == 'Business') {
                                Integer toSubtract;
                                Integer toAdd;
                                
                                if(relatedSLA.Offset_unit_of_measure__c == 'Hour') {
                                    toSubtract = (Integer) relatedSLA.Offset_Start_Date__c * msInHour;
                                    toAdd = (Integer) relatedSLA.Offset_End_Date__c * msInHour;
                                }
                                else if(relatedSLA.Offset_unit_of_measure__c == 'Day') {
                                    toSubtract = (Integer) relatedSLA.Offset_Start_Date__c * msInBusinessDay;
                                    toAdd = (Integer) relatedSLA.Offset_End_Date__c * msInBusinessDay;
                                }
                                else if(relatedSLA.Offset_unit_of_measure__c == 'Week') {
                                    toSubtract = (Integer) relatedSLA.Offset_Start_Date__c * msInBusinessDay * 5;
                                    toAdd = (Integer) relatedSLA.Offset_End_Date__c * msInBusinessDay * 5;
                                }
                                else if(relatedSLA.Offset_unit_of_measure__c == 'Month') {
                                    toSubtract = (Integer) relatedSLA.Offset_Start_Date__c * msInBusinessDay * 20;
                                    toAdd = (Integer) relatedSLA.Offset_End_Date__c * msInBusinessDay * 20;
                                }

                                // Subtracting Offset from Due_Date (considering BH) to get Start_Date__c

                                wo.StartDate = BusinessHours.addGmt(businessHoursId, (wo.Due_Date__c), -toSubtract);

                                // Adding Offset to Due_Date (considering BH) to get End_Date__c

                                wo.EndDate = BusinessHours.addGmt(businessHoursId, (wo.Due_Date__c), toAdd);
                            }
                            else if(relatedSLA.Offset_calculation_mode__c == 'Calendar') {

                                // Subtracting Offset from Due_Date without considering BH to get Start_Date__c

                                Integer toSubtract = (Integer) relatedSLA.Offset_Start_Date__c;
                                if(relatedSLA.Offset_unit_of_measure__c == 'Hour') {
                                    wo.StartDate = (wo.Due_Date__c).addHours(-toSubtract);
                                }
                                else if(relatedSLA.Offset_unit_of_measure__c == 'Day') {
                                    wo.StartDate = (wo.Due_Date__c).addDays(-toSubtract);
                                }
                                else if(relatedSLA.Offset_unit_of_measure__c == 'Week') {
                                    wo.StartDate = (wo.Due_Date__c).addDays(-(toSubtract * 7));
                                }
                                else if(relatedSLA.Offset_unit_of_measure__c == 'Month') {
                                    wo.StartDate = (wo.Due_Date__c).addMonths(-toSubtract);
                                }

                                // Adjusting Start_Date__c if it falls outside the BHs

                                if(!BusinessHours.isWithin(businessHoursId, wo.StartDate)) {
                                    wo.StartDate = BusinessHours.nextStartDate(businessHoursId, wo.StartDate);
                                }

                                // Adding Offset to Due_Date without considering BH to get End_Date__c

                                Integer toAdd = (Integer) relatedSLA.Offset_End_Date__c;
                                if(relatedSLA.Offset_unit_of_measure__c == 'Hour') {
                                    wo.EndDate = (wo.Due_Date__c).addHours(toAdd);
                                }
                                else if(relatedSLA.Offset_unit_of_measure__c == 'Day') {
                                    wo.EndDate = (wo.Due_Date__c).addDays(toAdd);
                                }
                                else if(relatedSLA.Offset_unit_of_measure__c == 'Week') {
                                    wo.EndDate = (wo.Due_Date__c).addDays(toAdd * 7);
                                }
                                else if(relatedSLA.Offset_unit_of_measure__c == 'Month') {
                                    wo.EndDate = (wo.Due_Date__c).addMonths(toAdd);
                                }

                                // Adjusting End_Date__c if it falls outside the BHs

                                if(!BusinessHours.isWithin(businessHoursId, wo.EndDate)) {
                                    wo.EndDate = BusinessHours.nextStartDate(businessHoursId, wo.EndDate);
                                }
                            }

                            // Approximating StartDate and EndDate to the Start/End of Business Day

                            if(relatedSLA.Offset_unit_of_measure__c == 'Day' || relatedSLA.Offset_unit_of_measure__c == 'Week' || relatedSLA.Offset_unit_of_measure__c == 'Month') {
                                String dayOfWeekStartDate = wo.StartDate.format('EEEE');
                                //System.debug('dayOfWeekStartDate: ' + dayOfWeekStartDate);
                                String dayOfWeekEndDate = wo.EndDate.format('EEEE');
                                //System.debug('dayOfWeekEndDate: ' + dayOfWeekEndDate);

                                Date startDateConverted = Date.newInstance((wo.StartDate).year(), (wo.StartDate).month(), (wo.StartDate).day());
                                Date endDateConverted = Date.newInstance((wo.EndDate).year(), (wo.EndDate).month(), (wo.EndDate).day());

                                // Getting the day of the week, then getting the StartTime of that day and rebuilding startDate with the same Date but with the new startTime

                                if(dayOfWeekStartDate == 'Monday') {
                                    Time mondayStartTime = bh.MondayStartTime;
                                    
                                    wo.StartDate = Datetime.newInstance(startDateConverted, mondayStartTime);
                                }
                                else if(dayOfWeekStartDate == 'Tuesday') {
                                    Time tuesdayStartTime = bh.TuesdayStartTime;

                                    wo.StartDate = Datetime.newInstance(startDateConverted, tuesdayStartTime);
                                }
                                else if(dayOfWeekStartDate == 'Wednesday') {
                                    Time wednesdayStartTime = bh.WednesdayStartTime;

                                    wo.StartDate = Datetime.newInstance(startDateConverted, wednesdayStartTime);
                                }
                                else if(dayOfWeekStartDate == 'Thursday') {
                                    Time thursdayStartTime = bh.ThursdayStartTime;

                                    wo.StartDate = Datetime.newInstance(startDateConverted, thursdayStartTime);
                                }
                                else if(dayOfWeekStartDate == 'Friday') {
                                    Time fridayStartTime = bh.FridayStartTime;

                                    wo.StartDate = Datetime.newInstance(startDateConverted, fridayStartTime);
                                }

                                // Getting the day of the week, then getting the EndTime of that day and rebuilding endDate with the same Date but with the new endTime

                                if(dayOfWeekEndDate == 'Monday') {
                                    Time mondayEndTime = bh.MondayEndTime;
                                    
                                    wo.EndDate = Datetime.newInstance(endDateConverted, mondayEndTime);
                                }
                                else if(dayOfWeekEndDate == 'Tuesday') {
                                    Time tuesdayEndTime = bh.TuesdayEndTime;

                                    wo.EndDate = Datetime.newInstance(endDateConverted, tuesdayEndTime);
                                }
                                else if(dayOfWeekEndDate == 'Wednesday') {
                                    Time wednesdayEndTime = bh.WednesdayEndTime;

                                    wo.EndDate = Datetime.newInstance(endDateConverted, wednesdayEndTime);
                                }
                                else if(dayOfWeekEndDate == 'Thursday') {
                                    Time thursdayEndTime = bh.ThursdayEndTime;

                                    wo.EndDate = Datetime.newInstance(endDateConverted, thursdayEndTime);
                                }
                                else if(dayOfWeekEndDate == 'Friday') {
                                    Time fridayEndTime = bh.FridayEndTime;

                                    wo.EndDate = Datetime.newInstance(endDateConverted, fridayEndTime);
                                }
                            }
                        }

                        if(relatedCase != null && relatedSLA != null) {
                            relatedCase.Start_Date__c = wo.StartDate;
                            relatedCase.Next_Activity_Date__c = relatedCase.Start_Date__c;
                        }

                        if(relatedSLA != null) {
                            wo.Scheduled_Start_Date__c = wo.StartDate;
                            wo.Scheduled_End_Date__c = wo.EndDate;
                        }
                    }
                }

                if(!allWOsToAdjust.isEmpty()) {
                    update allWOsToAdjust;
                    update casesToAdjust;
                }
            }

            // Autscheduling additional activities (same as above method)

            if(allATJs != null) {

                Map<Id, Case> ATJToFirstOpenCaseMap = new Map<Id, Case>();
                Map<Id, Case> ATJToLastOpenCaseMap = new Map<Id, Case>();
                Map<Id, Case> ATJToLastCaseMap = new Map<Id, Case>();
                Map<Id, Integer> ATJIdToDaysToScheduleMap = new Map<Id, Integer>();
                Map<Id, WorkOrder> ATJToLastWOMap = new Map<Id, WorkOrder>();
                Map<String, WorkOrder> ATJToWOToStartFromMap = new Map<String, WorkOrder>();

                List<Account_Treatment_Job__c> ATJsForAdditionalScheduling = new List<Account_Treatment_Job__c>();
                List<Id> allLastCaseIds = new List<Id>();
                List<String> caseToStartFromIds = new List<String>();
                List<Id> newCaseIds = new List<Id>();

                // These two contain the last open cases

                //ATJToFirstOpenCaseMap = CaseDAO.getATJToFirstCaseMap(queryFieldsForCase, allATJIds);
                ATJToLastOpenCaseMap = CaseDAO.getATJToLastCaseMap(queryFieldsForCase, allATJIds);

                // This instead contains the last cases, including the closed ones. I need it if I have no new activities open

                ATJToLastCaseMap = CaseDAO.getATJToAllLastCaseMap(queryFieldsForCase, allATJIds);

                for(Account_Treatment_Job__c atj : allATJs) {
                    //Case firstCase = ATJToFirstOpenCaseMap.get(atj.Id);
                    Case lastCase = ATJToLastOpenCaseMap.get(atj.Id);
                    Case lastClosedCase = ATJToLastCaseMap.get(atj.Id);
                    Date firstCaseStartDate;
                    Date lastCaseStartDate; 
                    Date triggeringDate;
                    Integer scheduledPeriodInDays;
                    WorkOrder relatedTriggeringWorkOrder = ATJIdToTriggeringWOMap.get(atj.Id);
                    //System.debug('FIRSTCASE:::::::::: ' + firstCase);
                    System.debug('LASTCASE::::::::::: ' + lastCase);

                    /* if(firstCase != null && firstCase.Start_Date__c != null) {
                        firstCaseStartDate = (firstCase.Start_Date__c).date();
                    } */
                    if(lastCase != null && lastCase.Start_Date__c != null) {
                        lastCaseStartDate = (lastCase.Start_Date__c).date();
                    }
                    else {
                        lastCase = lastClosedCase;
                    }

                    /* if(firstCaseStartDate != null && lastCaseStartDate != null) {
                        scheduledPeriodInDays = firstCaseStartDate.daysBetween(lastCaseStartDate);
                    }
                    else {
                        scheduledPeriodInDays = 0;
                    } */

                    if(ATIdToATHMap != null) {
                        Account_Treatment_History__c relatedATH = ATIdToATHMap.get(atj.Patient_Treatment__c);

                        if(relatedATH != null) {
                            triggeringDate = (relatedATH.CreatedDate).date();
                        }
                    }
                    else {
                        if(relatedTriggeringWorkOrder != null && relatedTriggeringWorkOrder.EndDate != null) {
                            triggeringDate = (relatedTriggeringWorkOrder.EndDate).date();
                        }
                    }

                    if(lastCaseStartDate != null && triggeringDate != null) {
                        scheduledPeriodInDays = triggeringDate.daysBetween(lastCaseStartDate);
                    }
                    else {
                        scheduledPeriodInDays = 0;
                    }

                    System.debug('Scheduled Period in Days: ' + scheduledPeriodInDays);

                    Integer schedulingTimeFrame = (Integer) ((atj.Scheduling_Time_Frame__c != null) ? atj.Scheduling_Time_Frame__c : 365);

                    if(scheduledPeriodInDays < schedulingTimeFrame) {
                        Integer daysToScheduleLeft;

                        if(/* firstCaseStartDate != null */triggeringDate != null && lastCaseStartDate != null) {
                            //Date schedulingPeriodEndDate = firstCaseStartDate.addYears(1);
                            Date schedulingPeriodEndDate = triggeringDate.addDays(schedulingTimeFrame);
                            System.debug('Scheduling Period End Date: ' + schedulingPeriodEndDate);

                            daysToScheduleLeft = lastCaseStartDate.daysBetween(schedulingPeriodEndDate);
                        }
                        else {
                            daysToScheduleLeft = schedulingTimeFrame;
                        }

                        if(atj.Frequency__c != null) {
                            ATJsForAdditionalScheduling.add(atj);
                        }

                        //allLastCaseIds.add(lastCase.Id);
                        if(lastClosedCase != null && lastClosedCase.Id != null) {
                            allLastCaseIds.add(lastClosedCase.Id);
                        }
                        if(lastCase != null && lastCase.Id != null) {
                            caseToStartFromIds.add(lastCase.Id);
                        }

                        ATJIdToDaysToScheduleMap.put(atj.Id, daysToScheduleLeft);
                    }
                }

                if(!ATJsForAdditionalScheduling.isEmpty()) {
                    
                    // Scheduling additional Cases

                    List<Case> newCases = scheduleAdditionalCases(ATJsForAdditionalScheduling, ATJIdToDaysToScheduleMap, DMLOptions);
                    List<Case> queriedNewCases = new List<Case>();
                    

                    if(!newCases.isEmpty()) {
                        insert newCases;

                        for(Case c : newCases) {
                            newCaseIds.add(c.Id);
                        }

                        queriedNewCases = CaseDAO.getCasesFromIds(queryFieldsForCase, newCaseIds);

                        // Building a ATJ.Id --> List<RelatedCases> Map to run the autoscheduling only on the Cases related to each ATJ

                        Map<Id, List<Case>> ATJIdToCasesMap = new Map<Id, List<Case>>();

                        for(Case c : queriedNewCases) {
                            if(ATJIdToCasesMap.get(c.Account_Treatment_Job__c) == null) {
                                ATJIdToCasesMap.put(c.Account_Treatment_Job__c, new List<Case>());
                            }
                            ATJIdToCasesMap.get(c.Account_Treatment_Job__c).add(c);
                        }

                        ATJToSLAMap = ATMainComponentService.getATJToSLAMap(ATJsForAdditionalScheduling);

                        List<Id> lastWOsIds = new List<Id>();
                        List<String> workOrderToStartFromIds = new List<String>();
                        List<WorkOrder> allLastWOs = WorkOrderDAO.getAutoscheduledWOForCases(queryFieldsForWO, allLastCaseIds);
                        List<WorkOrder> workOrdersToStartFrom = WorkOrderDAO.getAutoscheduledWOForCases(queryFieldsForWO, caseToStartFromIds);

                        for(WorkOrder wo : allLastWOs) {
                            lastWOsIds.add(wo.Id);
                        }

                        if(workOrdersToStartFrom != null) {
                            for(WorkOrder wo : workOrdersToStartFrom) {
                                workOrderToStartFromIds.add(wo.Id);
                            }
                        }

                        //Map<Id, List<WorkOrderLineItem>> WOToItemsMap = new Map<Id, List<WorkOrderLineItem>>();
                        //List<WorkOrderLineItem> allWOLIs = WorkOrderLineItemDAO.getWOLIsFromWOs(queryFieldsForWOLI, lastWOsIds);
                        //List<WorkOrderLineItem> WOLIsToStartFrom = WorkOrderLineItemDAO.getWOLIsFromWOs(queryFieldsForWOLI, workOrderToStartFromIds);

                        /* if(!allWOLIs.isEmpty()) {
                            for(WorkOrderLineItem woli : allWOLIs) {
                                if(WOToItemsMap.get(woli.WorkOrderId) == null) {
                                    WOToItemsMap.put(woli.WorkOrderId, new List<WorkOrderLineItem>());
                                }
                                WOToItemsMap.get(woli.WorkOrderId).add(woli);
                            }
                        } */

                        /* if(!WOLIsToStartFrom.isEmpty()) {
                            for(WorkOrderLineItem woli : WOLIsToStartFrom) {
                                if(WOToItemsMap.get(woli.WorkOrderId) == null) {
                                    WOToItemsMap.put(woli.WorkOrderId, new List<WorkOrderLineItem>());
                                }
                                if(!WOToItemsMap.get(woli.WorkOrderId).contains(woli)) {
                                    WOToItemsMap.get(woli.WorkOrderId).add(woli);
                                }
                            }
                        } */

                        for(WorkOrder wo : allLastWOs) {
                            ATJToLastWOMap.put(wo.Account_Treatment_Job__c, wo);
                        }

                        if(workOrdersToStartFrom != null) {
                            for(WorkOrder wo : workOrdersToStartFrom) {
                                ATJToWOToStartFromMap.put(wo.Account_Treatment_Job__c, wo);
                            }
                        }

                        // Scheduling additional WOs

                        if(!ATJToSLAMap.isEmpty()) {
                            //List<WorkOrder> workOrdersToInsert = new List<WorkOrder>();
                            List<WorkOrderLineItem> WOLIsToInsert = new List<WorkOrderLineItem>();

                            for(Account_Treatment_Job__c atj : ATJsForAdditionalScheduling) {
                                Contract_Treatment_Job_SLA__c relatedSLA = ATJToSLAMap.get(atj);
                                System.debug('relatedSLA when scheduling additional WOs: ' + relatedSLA);

                                // Getting the Cases related to this ATJ
                                List<Case> relatedCases = ATJIdToCasesMap.get(atj.Id);

                                // Starting from the last WO of the ATJ

                                //WorkOrder startingWorkOrder = ATJToLastWOMap.get(atj.Id);

                                WorkOrder startingWorkOrder;
                                
                                if(ATJToWOToStartFromMap.get(atj.Id) != null) {
                                    startingWorkOrder = ATJToWOToStartFromMap.get(atj.Id);
                                }
                                else {
                                    startingWorkOrder = ATJToLastWOMap.get(atj.Id);
                                }

                                System.debug('startingWorkOrder: ' + startingWorkOrder);

                                if(startingWorkOrder != null && relatedSLA != null) {
                                    // Day Autoscheduling

                                    // Using "false" because the first WO hasn't been scheduled yet

                                    if(atj.Frequency_Unit_of_measure__c == 'Day') {
                                        List<WorkOrder> newWorkOrders = ATMainComponentService.autoscheduleWorkOrders(atj, startingWorkOrder, relatedSLA, 365, relatedCases, bh, false);

                                        for(WorkOrder wo : newWorkOrders) {
                                            workOrdersToInsert.add(wo);
                                        }
                                    }

                                    // Week Autoscheduling

                                    else if(atj.Frequency_Unit_of_measure__c == 'Week') {
                                        List<WorkOrder> newWorkOrders = ATMainComponentService.autoscheduleWorkOrders(atj, startingWorkOrder, relatedSLA, 52, relatedCases, bh, false);

                                        for(WorkOrder wo : newWorkOrders) {
                                            workOrdersToInsert.add(wo);
                                        }
                                    }

                                    // Month Autoscheduling

                                    else if(atj.Frequency_Unit_of_measure__c == 'Month') {
                                        List<WorkOrder> newWorkOrders = ATMainComponentService.autoscheduleWorkOrders(atj, startingWorkOrder, relatedSLA, 12, relatedCases, bh, false);

                                        for(WorkOrder wo : newWorkOrders) {
                                            workOrdersToInsert.add(wo);
                                        }
                                    }

                                    // Year Autoscheduling

                                    else if(atj.Frequency_Unit_of_measure__c == 'Year') {
                                        List<WorkOrder> newWorkOrders = ATMainComponentService.autoscheduleWorkOrders(atj, startingWorkOrder, relatedSLA, 1, relatedCases, bh, false);

                                        for(WorkOrder wo : newWorkOrders) {
                                            workOrdersToInsert.add(wo);
                                        }
                                    }
                                }
                            }

                            if(!workOrdersToInsert.isEmpty()) {
                                insert workOrdersToInsert;
                                update queriedNewCases;
                            }

                            // Building a ATJ.Id --> List<RelatedCases> Map to run the autoscheduling only on the Cases related to each ATJ

                            /* Map<Id, List<WorkOrder>> ATJIdToWOsMap = new Map<Id, List<WorkOrder>>();

                            for(WorkOrder wo : workOrdersToInsert) {
                                if(ATJIdToWOsMap.get(wo.Account_Treatment_Job__c) == null) {
                                    ATJIdToWOsMap.put(wo.Account_Treatment_Job__c, new List<WorkOrder>());
                                }
                                ATJIdToWOsMap.get(wo.Account_Treatment_Job__c).add(wo);
                            } */

                            // WOLI creation (copied from the ones of the last WO)

                            /* for(Account_Treatment_Job__c atj : ATJsForAdditionalScheduling) {
                                WorkOrder startingWorkOrder = ATJToLastWOMap.get(atj.Id);
                                List<WorkOrderLineItem> relatedWOLIs;

                                if(startingWorkOrder != null) {
                                    relatedWOLIs = WOToItemsMap.get(startingWorkOrder.Id);
                                }

                                List<WorkOrder> relatedWorkOrders = ATJIdToWOsMap.get(atj.Id);

                                if(relatedWOLIs != null) {
                                    if(relatedWorkOrders != null) {
                                        for(WorkOrder wo : relatedWorkOrders) {
                                            for(WorkOrderLineItem woli : relatedWOLIs) {
                                                WorkOrderLineItem newWOLI = new WorkOrderLineItem(
                                                    WorkOrderId = wo.Id,
                                                    PricebookEntryId = woli.PricebookEntryId,
                                                    Quantity = woli.Quantity,
                                                    Customer_Product_Code__c = woli.Customer_Product_Code__c,
                                                    Customer_Request_Code__c = woli.Customer_Request_Code__c,
                                                    Customer_Purchase_Order_Number__c = woli.Customer_Purchase_Order_Number__c,
                                                    Customer_Purchase_Order_Date__c = woli.Customer_Purchase_Order_Date__c,
                                                    StorageLocation__c = woli.StorageLocation__c,
                                                    Plant__c = woli.Plant__c,
                                                    InvoiceSplittingGroup__c = woli.InvoiceSplittingGroup__c,
                                                    Account_Treatment_Job_Product__c = woli.Account_Treatment_Job_Product__c,
                                                    AssetId = woli.AssetId,
                                                    Serial_Number__c = woli.Serial_Number__c
                                                );

                                                WOLIsToInsert.add(newWOLI);
                                            }
                                        }
                                    }
                                }

                            }

                            if(!WOLIsToInsert.isEmpty()) {
                                insert WOLIsToInsert;
                            } */
                        }
                    }
                }
            }
        }

        return workOrdersToInsert;
    }

    public static List<WorkOrder> adjustDatesTaskAndWOCases(List<Case> cases, Map<Id, Account_Treatment_History__c> ATIdToATHMap) {
        BusinessHours bh = [SELECT Id, MondayStartTime, MondayEndTime, TuesdayStartTime, TuesdayEndTime, WednesdayStartTime, WednesdayEndTime,
                            ThursdayStartTime, ThursdayEndTime, FridayStartTime, FridayEndTime, SaturdayStartTime, SaturdayEndTime, SundayStartTime, SundayEndTime  
                            FROM BusinessHours WHERE Name = 'NL'];

        AssignmentRule assignmentRule = [SELECT Id FROM AssignmentRule WHERE SobjectType = 'Case' AND Active = true LIMIT 1];

        // Creating the DMLOptions for "Assign using active assignment rules" checkbox
        Database.DMLOptions DMLOptions = new Database.DMLOptions();
        DMLOptions.assignmentRuleHeader.assignmentRuleId = assignmentRule.Id;

        Id businessHoursId = bh.Id;

        List<String> queryFields = new List<String>{'Id', 'Due_Date__c', 'StartDate', 'EndDate', 'Related_SLA__c',
        'Scheduled_Start_Date__c', 'Scheduled_End_Date__c', 'Account_Treatment_Job__c', 'CaseId', 'Account_Treatment_Job__r.Frequency_Unit_of_measure__c', 
        'Account_Treatment_Job__r.Frequency__c', 'Account_Treatment_Job__r.Patient_Treatment__c'};

        List<String> queryFieldsForTasks = new List<String>{'Id', 'Due_Date__c', 'CompletedDateTime', 'Start_Date__c', 'End_Date__c', 'ActivityDate',
        'Related_SLA__c', 'Account_Treatment_Job__c', 'WhatId', 'Status', 'Subject', 'Type', 'TaskSubtype', 'Account__c', 'Type__c', 'Autoscheduled__c'};

        List<String> queryFieldsForSLA = new List<String>{'IsDefault__c', 'Contract_Treatment_Job__c', 'Max_Time__c', 'Unite_of_measure_Max_Time__c', //Unit, not unite
        'Calculation_Mode__c', 'Offset_Start_Date__c', 'Offset_End_Date__c', 'Offset_unit_of_measure__c', 'Offset_calculation_mode__c', 'Task_MaxTime_Execution__c', 
        'Task_Unite_of_measure_Max_Time__c', 'Task_Calculation_Mode__c', 'Offset_Start_Date_Task__c', 'Offset_End_Date_Task__c', 'Offset_unit_of_measure_Task__c', 
        'Offset_calculation_mode_Task__c'};

        List<String> queryFieldsForCase = new List<String>{'Start_Date__c', 'Account_Treatment_Job__c', 'Next_Activity_Date__c', 'OwnerId', 'Status', 'ExcludeFromAdjustment__c'};

        List<String> queryFieldsForATJ = new List<String>{'Scheduling_Rule__c', 'Work_Order__c', 'Task__c', 'Contract_Treatment_Job__c', 'Patient_Treatment__r.Account__c',
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
        'Patient_Treatment__r.Contract_Treatment__r.Invoice_Splitting_Group__c', 'Frequency_Type__c', 'Scheduling_Time_Frame__c'};

        List<String> queryFieldsForWO = new List<String>{'AccountId', 'Account_Sold_To__c', 'Account_Sales_Organization__c', 'Account_Treatment__c', 'CaseId',
        'Contract_Framework__c', 'Contract_Treatment__c', 'Contract_Treatment_Job__c', 'Customer_Purchase_Order_Date__c', 'Customer_Purchase_Order_Number__c',
        'Delivery_Type__c', 'Document_Type__c', 'OwnerId', 'Pricebook2Id',
        'Status', 'Subject', 'WorkTypeId', 'Related_SLA__c', 'LocationId', 'City', 'Country', 'CountryCode', 'Latitude', 'Longitude', 'PostalCode', 'State',
        'StateCode', 'Street', 'Account_Treatment_Job__c', 'Autoscheduled__c', 'AssetId', 'Label__c', 'ContactId', 'StartDate', 'EndDate', 'Due_Date__c',
        'Scheduled_Start_Date__c', 'Scheduled_End_Date__c', 'Attachment_Addendum_Type__c', 'Billing_Via__c', 'Billing_Reference__c', 'Invoice_splitting_criterion__c',
        'InvoiceLayout__c', 'Job_InvoiceSplittingGroup__c', 'Treatment_Customer_Purchase_Order_Date__c', 'Treatment_Customer_Purchase_Order_Number__c',
        'Treatment_Customer_Request_Code__c', 'Treatment_InvoiceSplittingGroup__c', 'SalesOrganization__c', 'Division__c', 'Distribution_Channel__c',
        'Sales_Group__c', 'Sales_Office__c', 'Job_Product_Code__c', 'Case.Status'};

        List<String> queryFieldsForWOLI = new List<String>{'WorkOrderId', 'PricebookEntryId', 'Quantity', 'Customer_Product_Code__c', 'Customer_Request_Code__c',
        'Account_Treatment_Job_Product__c', 'Customer_Purchase_Order_Number__c', 'Customer_Purchase_Order_Date__c', 'StorageLocation__c', 'Plant__c',
        'InvoiceSplittingGroup__c', 'AssetId', 'Serial_Number__c'};

        List<Id> caseIds = new List<Id>();
        List<Id> SLAIds = new List<Id>();
        List<Id> ATJIds = new List<Id>();
        List<Id> allATJIds = new List<Id>();

        List<WorkOrder> allWOsToAdjust = new List<WorkOrder>();
        List<WorkOrder> workOrdersToInsert = new List<WorkOrder>();

        List<Task> allTasksToAdjust = new List<Task>();

        List<Case> newCases = new List<Case>();
        List<Case> queriedNewCases = new List<Case>();
        List<Id> newCaseIds = new List<Id>();

        Map<Id, Integer> jobToDatesDifferenceMap = new Map<Id, Integer>();
        Map<Id, Contract_Treatment_Job_SLA__c> SLAMap = new Map<Id, Contract_Treatment_Job_SLA__c>();
        Map<Id, Case> caseMap = new Map<Id, Case>();
        Map<Account_Treatment_Job__c,Contract_Treatment_Job_SLA__c> ATJToSLAMap = new Map<Account_Treatment_Job__c,Contract_Treatment_Job_SLA__c>();

        Map<Id, Case> ATJToFirstOpenCaseMap = new Map<Id, Case>();
        Map<Id, Case> ATJToLastOpenCaseMap = new Map<Id, Case>();
        Map<Id, Case> ATJToLastCaseMap = new Map<Id, Case>();
        Map<Id, Integer> ATJIdToDaysToScheduleMap = new Map<Id, Integer>();
        Map<Id, Task> ATJToLastTaskMap = new Map<Id, Task>();
        Map<Id, WorkOrder> ATJToLastWOMap = new Map<Id, WorkOrder>();
        Map<Id, List<Case>> ATJIdToCasesMap = new Map<Id, List<Case>>();
        Map<String, Task> ATJToTaskToStartFromMap = new Map<String, Task>();
        Map<String, WorkOrder> ATJToWOToStartFromMap = new Map<String, WorkOrder>();
        Map<String, WorkOrder> ATJIdToTriggeringWOMap = new Map<String, WorkOrder>();
        Map<String, Integer> ATJToGapMap = new Map<String, Integer>();
        Map<String, List<Task>> ATJIdToTasksToAdjustMap = new Map<String, List<Task>>();
        Map<String, List<WorkOrder>> ATJIdToWOsToAdjustMap = new Map<String, List<WorkOrder>>();

        List<Account_Treatment_Job__c> ATJsForAdditionalScheduling = new List<Account_Treatment_Job__c>();
        List<Id> allLastCaseIds = new List<Id>();
        List<String> caseToStartFromIds = new List<String>();

        for(Case c : cases) {
            caseIds.add(c.Id);
        }

        List<WorkOrder> allRelatedWOs = WorkOrderDAO.getAutoscheduledWOForCases(queryFields, caseIds);
        System.debug('allRelatedWOs size: ' + allRelatedWOs.size());

        if(allRelatedWOs != null) {
            if(ATIdToATHMap == null) {
                for(WorkOrder wo : allRelatedWOs) {
                    Datetime dueDate = wo.Due_Date__c;
                    Datetime endDate = wo.EndDate;

                    // I only need to adjust the tasks and WOs related to the WOs whose Date part in Due_Date__c is different from Date part in CompletedDateTime

                    if(dueDate != null && endDate != null) {
                        allATJIds.add(wo.Account_Treatment_Job__c);
                        ATJIdToTriggeringWOMap.put(wo.Account_Treatment_Job__c, wo);

                        Date datePartDueDate = dueDate.date();
                        Date datePartEndDate = endDate.date();

                        if(datePartDueDate != datePartEndDate) {
                            SLAIds.add(wo.Related_SLA__c);
                            ATJIds.add(wo.Account_Treatment_Job__c);

                            // This is the difference that will be reproduced in the following Tasks and WOs
                            Integer datesDifference = datePartDueDate.daysBetween(datePartEndDate);

                            jobToDatesDifferenceMap.put(wo.Account_Treatment_Job__c, datesDifference);
                        }
                    }
                }
            }

            // The map in input is not null if the method is called from ComplianceReschedulingBatch

            else {
                List<Id> accountTreatmentIds = new List<Id>();

                for(WorkOrder wo : allRelatedWOs) {
                    allATJIds.add(wo.Account_Treatment_Job__c);
                    
                    if(!accountTreatmentIds.contains(wo.Account_Treatment_Job__r.Patient_Treatment__c)) {
                        accountTreatmentIds.add(wo.Account_Treatment_Job__r.Patient_Treatment__c);
                    }
                    if(!ATJIds.contains(wo.Account_Treatment_Job__c)) {
                        ATJIds.add(wo.Account_Treatment_Job__c);
                    }
                    if(!SLAIds.contains(wo.Related_SLA__c)) {
                        SLAIds.add(wo.Related_SLA__c);
                    }
                }
                System.debug('accountTreatmentIds: ' + accountTreatmentIds);

                Map<Id, Case> ATJIdToFirstCaseMap = CaseDAO.getATJToFirstCaseMap(queryFieldsForCase, ATJIds);

                // In this case, the datesDifference is based on (gap - days between next case and the History)

                if(ATJIdToFirstCaseMap != null) {
                    for(WorkOrder wo : allRelatedWOs) { 
                        Account_Treatment_History__c relatedATH = ATIdToATHMap.get(wo.Account_Treatment_Job__r.Patient_Treatment__c);
                        
                        if(wo.Account_Treatment_Job__r.Frequency__c != null && relatedATH != null) {
                            Integer unitOfMeasureInYear;

                            if(wo.Account_Treatment_Job__r.Frequency_Unit_of_measure__c == 'Day') {
                                unitOfMeasureInYear = 365;
                            }
                            else if(wo.Account_Treatment_Job__r.Frequency_Unit_of_measure__c == 'Week') {
                                unitOfMeasureInYear = 52;
                            }
                            else if(wo.Account_Treatment_Job__r.Frequency_Unit_of_measure__c == 'Month') {
                                unitOfMeasureInYear = 12;
                            }
                            else if(wo.Account_Treatment_Job__r.Frequency_Unit_of_measure__c == 'Year') {
                                unitOfMeasureInYear = 1;
                            }

                            // This is the normal gap based on the ATJ's Frequency

                            Integer numberOfTasksToCreate = (Integer) (unitOfMeasureInYear * wo.Account_Treatment_Job__r.Frequency__c);
                            Integer gap = (Integer) (365 / numberOfTasksToCreate);

                            Case nextCase = ATJIdToFirstCaseMap.get(wo.Account_Treatment_Job__c);

                            if(nextCase != null) {
                                Date nextCaseStartDate = (nextCase.Start_Date__c).date();
                                Integer difference = nextCaseStartDate.daysBetween((relatedATH.CreatedDate).date());

                                if(relatedATH.CreatedDate > nextCaseStartDate) {
                                    difference = ((relatedATH.CreatedDate).date()).daysBetween(nextCaseStartDate);
                                }

                                System.debug('------ difference: ' + difference);

                                Integer datesDifference = gap - Math.abs(difference);

                                if(relatedATH.CreatedDate > nextCaseStartDate) {
                                    datesDifference = gap - difference;
                                }

                                jobToDatesDifferenceMap.put(wo.Account_Treatment_Job__c, datesDifference);
                            }
                        }
                    }
                }
            }

            // These are all the WOs to adjust related to all the tasks that have changed

            allWOsToAdjust = WorkOrderDAO.getAllWOsToAdjust(queryFields, ATJIds);
            System.debug('AllWOsToAdjust size: ' + allWOsToAdjust.size());

            // These are all the Tasks to adjust related to all the tasks that have changed

            allTasksToAdjust = TaskDAO.getAllTasksToAdjust(queryFieldsForTasks, ATJIds);
            System.debug('AllTasksToAdjust size: ' + allTasksToAdjust.size());

            // These are the ATJs related to the Tasks that need to be adjusted only

            List<Account_Treatment_Job__c> ATJs = AccountTreatmentJobDAO.getATJSFROMIds(queryFieldsForATJ, ATJIds);

            // These are all the ATJs related to the Tasks, even the ones not to adjust. This because I need to schedule additional activities for these too

            List<Account_Treatment_Job__c> allATJs = AccountTreatmentJobDAO.getATJSFROMIds(queryFieldsForATJ, allATJIds);

            if(allWOsToAdjust != null) {
                for(WorkOrder wo : allWOsToAdjust) {
                    caseIds.add(wo.CaseId);

                    if(ATJIdToWOsToAdjustMap.get(wo.Account_Treatment_Job__c) == null) {
                        ATJIdToWOsToAdjustMap.put(wo.Account_Treatment_Job__c, new List<WorkOrder>());
                    }
                    ATJIdToWOsToAdjustMap.get(wo.Account_Treatment_Job__c).add(wo);
                }
            }

            if(allTasksToAdjust != null) {
                for(Task t : allTasksToAdjust) {
                    if(ATJIdToTasksToAdjustMap.get(t.Account_Treatment_Job__c) == null) {
                        ATJIdToTasksToAdjustMap.put(t.Account_Treatment_Job__c, new List<Task>());
                    }
                    ATJIdToTasksToAdjustMap.get(t.Account_Treatment_Job__c).add(t);
                }
            }

            for(Account_Treatment_Job__c atj : allATJs) {
                Integer schedulingTimeFrame = (Integer) ((atj.Scheduling_Time_Frame__c != null) ? atj.Scheduling_Time_Frame__c : 365);
                Integer unitOfMeasureInYear;
                Integer daysInUnitOfMeasure;
                List<Case> relatedAutoscheduledCases = new List<Case>();
                //List<WorkOrder> workOrdersThisATJ = ATJIdToWOsToAdjustMap.get(atj.Id);

                if(schedulingTimeFrame != null /* && workOrdersThisATJ != null */) {
                    switch on atj.Frequency_Unit_of_measure__c {
                        when 'Day' {
                            unitOfMeasureInYear = 365;
                        }
                        when 'Week' {
                            unitOfMeasureInYear = 52;
                        }
                        when 'Month' {
                            unitOfMeasureInYear = 12;
                        }
                        when 'Year' {
                            unitOfMeasureInYear = 1;
                        }
                    }

                    switch on atj.Frequency_Unit_of_measure__c {
                        when 'Day' {
                            daysInUnitOfMeasure = 1;
                        }
                        when 'Week' {
                            daysInUnitOfMeasure = 7;
                        }
                        when 'Month' {
                            daysInUnitOfMeasure = 30;
                        }
                        when 'Year' {
                            daysInUnitOfMeasure = 365;
                        }
                    }

                    if(unitOfMeasureInYear != null && daysInUnitOfMeasure != null && atj.Frequency__c != null) {
                        Integer gap;

                        if(atj.Frequency_Type__c != 'IB') {
                            gap = (Integer) (365 / ((Integer) (unitOfMeasureInYear * atj.Frequency__c)));
                        }
                        else if(atj.Frequency_Type__c == 'IB') {
                            //gap = (Integer) (schedulingTimeFrame / workOrdersThisATJ.size());
                            gap = (Integer) (atj.Frequency__c * daysInUnitOfMeasure);
                        }

                        if(gap != null) {
                            ATJToGapMap.put(atj.Id, gap);
                        }
                    }
                }
            }

            List<Case> casesToAdjust = CaseDAO.getCasesFromIds(queryFieldsForCase, caseIds);

            for(Case c : casesToAdjust) {
                if(c.ExcludeFromAdjustment__c == false) {
                    caseMap.put(c.Id, c);
                }
            }

            List<Contract_Treatment_Job_SLA__c> allRelatedSLAs = ContractTreatmentJobSlaDAO.getSLAsFromIds(queryFieldsForSLA, SLAIds);

            for(Contract_Treatment_Job_SLA__c sla : allRelatedSLAs) {
                SLAMap.put(sla.Id, sla);
            }

            // Tasks

            if(allTasksToAdjust != null) {
                for(Task t : allTasksToAdjust) {
                    if(t.Due_Date__c != null) {
                        Integer datesDifference = jobToDatesDifferenceMap.get(t.Account_Treatment_Job__c);
                        Contract_Treatment_Job_SLA__c relatedSLA = SLAMap.get(t.Related_SLA__c);
                        Case relatedCase;
                        Integer gap = ATJToGapMap.get(t.Account_Treatment_Job__c);
                        WorkOrder relatedTriggeringWO = ATJIdToTriggeringWOMap.get(t.Account_Treatment_Job__c);
                        List<Task> tasksThisATJ = ATJIdToTasksToAdjustMap.get(t.Account_Treatment_Job__c);
                        Integer index = tasksThisATJ.indexOf(t);

                        if(caseMap.get(t.WhatId) != null && relatedSLA != null && datesDifference != null && gap != null && index != -1) {
                            relatedCase = caseMap.get(t.WhatId);

                            if(relatedCase != null) {
                                System.debug('WhatId: ' + t.WhatId);
                                System.debug('RelatedCase: ' + relatedCase);
                                System.debug('CaseMap: ' + caseMap);

                                Integer msInBusinessDay = 32400000;  // Milliseconds in 9 hours, a typical business day
                                Integer msInHour = 3600000;

                                // Adjusting scheduled Tasks with the new dates

                                //Datetime newDueDate = (t.Due_Date__c).addDays(datesDifference);
                                //t.Due_Date__c = newDueDate;

                                Datetime newDueDate;

                                if(ATIdToATHMap == null) {
                                    if(index == 0) {
                                        newDueDate = (relatedTriggeringWO).EndDate.addDays(gap);
                                    }
                                    else if(index > 0) {
                                        Task previousTask = tasksThisATJ[index - 1];
                                        newDueDate = (previousTask).Due_Date__c.addDays(gap);
                                    }
                                }
                                else {
                                    newDueDate = (t.Due_Date__c).addDays(datesDifference);
                                }
    
                                t.Due_Date__c = newDueDate;
                                
                                /* if(!BusinessHours.isWithin(businessHoursId, t.Due_Date__c)) {
                                    t.Due_Date__c = BusinessHours.nextStartDate(businessHoursId, t.Due_Date__c);
                                } */

                                Date dueDateConverted = Date.newInstance((t.Due_Date__c).year(), (t.Due_Date__c).month(), (t.Due_Date__c).day());
                                Datetime consideredDate = t.Due_Date__c;
                                Time endTime;

                                while(endTime == null) {
                                    String dayOfWeekConsideredDate = (consideredDate).format('EEEE');
                                    Time dayOfWeekEndTime;
                                    System.debug('Considering date: ' + consideredDate);
                                    System.debug('Day of week: ' + dayOfWeekConsideredDate);

                                    switch on dayOfWeekConsideredDate {
                                        when 'Monday' {
                                            dayOfWeekEndTime = bh.MondayEndTime;
                                        }
                                        when 'Tuesday' {
                                            dayOfWeekEndTime = bh.TuesdayEndTime;
                                        }
                                        when 'Wednesday' {
                                            dayOfWeekEndTime = bh.WednesdayEndTime;
                                        }
                                        when 'Thursday' {
                                            dayOfWeekEndTime = bh.ThursdayEndTime;
                                        }
                                        when 'Friday' {
                                            dayOfWeekEndTime = bh.FridayEndTime;
                                        }
                                        when 'Saturday' {
                                            dayOfWeekEndTime = bh.SaturdayEndTime;
                                        }
                                        when 'Sunday' {
                                            dayOfWeekEndTime = bh.SundayEndTime;
                                        }
                                    }

                                    if(dayOfWeekEndTime != null) {
                                        endTime = dayOfWeekEndTime.addMinutes(-1);
                                    }
                                    else {
                                        consideredDate = consideredDate.addDays(-1);
                                    }
                                }

                                if(endTime != null) {
                                    t.Due_Date__c = Datetime.newInstance(consideredDate.date(), endTime);
                                }

                                //Date dueDateConverted = Date.newInstance((t.Due_Date__c).year(), (t.Due_Date__c).month(), (t.Due_Date__c).day());
                                t.ActivityDate = (t.Due_Date__c).date();
                                
                                if(relatedSLA.Offset_calculation_mode_Task__c == 'Business') {
                                    Integer toSubtract;
                                    Integer toAdd;
                                    
                                    if(relatedSLA.Offset_unit_of_measure_Task__c == 'Hour') {
                                        toSubtract = (Integer) relatedSLA.Offset_Start_Date_Task__c * msInHour;
                                        toAdd = (Integer) relatedSLA.Offset_End_Date_Task__c * msInHour;
                                    }
                                    else if(relatedSLA.Offset_unit_of_measure_Task__c == 'Day') {
                                        toSubtract = (Integer) relatedSLA.Offset_Start_Date_Task__c * msInBusinessDay;
                                        toAdd = (Integer) relatedSLA.Offset_End_Date_Task__c * msInBusinessDay;
                                    }
                                    else if(relatedSLA.Offset_unit_of_measure_Task__c == 'Week') {
                                        toSubtract = (Integer) relatedSLA.Offset_Start_Date_Task__c * msInBusinessDay * 5;
                                        toAdd = (Integer) relatedSLA.Offset_End_Date_Task__c * msInBusinessDay * 5;
                                    }
                                    else if(relatedSLA.Offset_unit_of_measure_Task__c == 'Month') {
                                        toSubtract = (Integer) relatedSLA.Offset_Start_Date_Task__c * msInBusinessDay * 20;
                                        toAdd = (Integer) relatedSLA.Offset_End_Date_Task__c * msInBusinessDay * 20;
                                    }

                                    // Subtracting Offset from Due_Date (considering BH) to get Start_Date__c

                                    t.Start_Date__c = BusinessHours.addGmt(businessHoursId, (t.Due_Date__c), -toSubtract);

                                    // Adding Offset to Due_Date (considering BH) to get End_Date__c

                                    t.End_Date__c = BusinessHours.addGmt(businessHoursId, (t.Due_Date__c), toAdd);
                                }
                                else if(relatedSLA.Offset_calculation_mode_Task__c == 'Calendar') {

                                    // Subtracting Offset from Due_Date without considering BH to get Start_Date__c

                                    Integer toSubtract = (Integer) relatedSLA.Offset_Start_Date_Task__c;
                                    if(relatedSLA.Offset_unit_of_measure_Task__c == 'Hour') {
                                        t.Start_Date__c = (t.Due_Date__c).addHours(-toSubtract);
                                    }
                                    else if(relatedSLA.Offset_unit_of_measure_Task__c == 'Day') {
                                        t.Start_Date__c = (t.Due_Date__c).addDays(-toSubtract);
                                    }
                                    else if(relatedSLA.Offset_unit_of_measure_Task__c == 'Week') {
                                        t.Start_Date__c = (t.Due_Date__c).addDays(-(toSubtract * 7));
                                    }
                                    else if(relatedSLA.Offset_unit_of_measure_Task__c == 'Month') {
                                        t.Start_Date__c = (t.Due_Date__c).addMonths(-toSubtract);
                                    }

                                    // Adjusting Start_Date__c if it falls outside the BHs

                                    if(!BusinessHours.isWithin(businessHoursId, t.Start_Date__c)) {
                                        t.Start_Date__c = BusinessHours.nextStartDate(businessHoursId, t.Start_Date__c);
                                    }

                                    // Adding Offset to Due_Date without considering BH to get End_Date__c

                                    Integer toAdd = (Integer) relatedSLA.Offset_End_Date_Task__c;
                                    if(relatedSLA.Offset_unit_of_measure_Task__c == 'Hour') {
                                        t.End_Date__c = (t.Due_Date__c).addHours(toAdd);
                                    }
                                    else if(relatedSLA.Offset_unit_of_measure_Task__c == 'Day') {
                                        t.End_Date__c = (t.Due_Date__c).addDays(toAdd);
                                    }
                                    else if(relatedSLA.Offset_unit_of_measure_Task__c == 'Week') {
                                        t.End_Date__c = (t.Due_Date__c).addDays(toAdd * 7);
                                    }
                                    else if(relatedSLA.Offset_unit_of_measure_Task__c == 'Month') {
                                        t.End_Date__c = (t.Due_Date__c).addMonths(toAdd);
                                    }

                                    // Adjusting End_Date__c if it falls outside the BHs

                                    if(!BusinessHours.isWithin(businessHoursId, t.End_Date__c)) {
                                        t.End_Date__c = BusinessHours.nextStartDate(businessHoursId, t.End_Date__c);
                                    }
                                }

                                // Approximating StartDate and EndDate to the Start/End of Business Day

                                if(relatedSLA.Offset_unit_of_measure_Task__c == 'Day' || relatedSLA.Offset_unit_of_measure_Task__c == 'Week' || relatedSLA.Offset_unit_of_measure_Task__c == 'Month') {
                                    String dayOfWeekStartDate = t.Start_Date__c.format('EEEE');
                                    //System.debug('dayOfWeekStartDate: ' + dayOfWeekStartDate);
                                    String dayOfWeekEndDate = t.End_Date__c.format('EEEE');
                                    //System.debug('dayOfWeekEndDate: ' + dayOfWeekEndDate);

                                    Date startDateConverted = Date.newInstance((t.Start_Date__c).year(), (t.Start_Date__c).month(), (t.Start_Date__c).day());
                                    Date endDateConverted = Date.newInstance((t.End_Date__c).year(), (t.End_Date__c).month(), (t.End_Date__c).day());

                                    // Getting the day of the week, then getting the StartTime of that day and rebuilding startDate with the same Date but with the new startTime

                                    if(dayOfWeekStartDate == 'Monday') {
                                        Time mondayStartTime = bh.MondayStartTime;
                                        
                                        t.Start_Date__c = Datetime.newInstance(startDateConverted, mondayStartTime);
                                    }
                                    else if(dayOfWeekStartDate == 'Tuesday') {
                                        Time tuesdayStartTime = bh.TuesdayStartTime;

                                        t.Start_Date__c = Datetime.newInstance(startDateConverted, tuesdayStartTime);
                                    }
                                    else if(dayOfWeekStartDate == 'Wednesday') {
                                        Time wednesdayStartTime = bh.WednesdayStartTime;

                                        t.Start_Date__c = Datetime.newInstance(startDateConverted, wednesdayStartTime);
                                    }
                                    else if(dayOfWeekStartDate == 'Thursday') {
                                        Time thursdayStartTime = bh.ThursdayStartTime;

                                        t.Start_Date__c = Datetime.newInstance(startDateConverted, thursdayStartTime);
                                    }
                                    else if(dayOfWeekStartDate == 'Friday') {
                                        Time fridayStartTime = bh.FridayStartTime;

                                        t.Start_Date__c = Datetime.newInstance(startDateConverted, fridayStartTime);
                                    }

                                    // Getting the day of the week, then getting the EndTime of that day and rebuilding endDate with the same Date but with the new endTime

                                    if(dayOfWeekEndDate == 'Monday') {
                                        Time mondayEndTime = bh.MondayEndTime;
                                        
                                        t.End_Date__c = Datetime.newInstance(endDateConverted, mondayEndTime);
                                    }
                                    else if(dayOfWeekEndDate == 'Tuesday') {
                                        Time tuesdayEndTime = bh.TuesdayEndTime;

                                        t.End_Date__c = Datetime.newInstance(endDateConverted, tuesdayEndTime);
                                    }
                                    else if(dayOfWeekEndDate == 'Wednesday') {
                                        Time wednesdayEndTime = bh.WednesdayEndTime;

                                        t.End_Date__c = Datetime.newInstance(endDateConverted, wednesdayEndTime);
                                    }
                                    else if(dayOfWeekEndDate == 'Thursday') {
                                        Time thursdayEndTime = bh.ThursdayEndTime;

                                        t.End_Date__c = Datetime.newInstance(endDateConverted, thursdayEndTime);
                                    }
                                    else if(dayOfWeekEndDate == 'Friday') {
                                        Time fridayEndTime = bh.FridayEndTime;

                                        t.End_Date__c = Datetime.newInstance(endDateConverted, fridayEndTime);
                                    }
                                }
                            }
                        }

                        if(relatedCase != null && relatedSLA != null) {
                            relatedCase.Start_Date__c =  Datetime.newInstance(t.ActivityDate, Time.newInstance(0,0,0,0));
                            relatedCase.Next_Activity_Date__c = relatedCase.Start_Date__c;
                        }
                    }
                }

                if(!allTasksToAdjust.isEmpty()) {
                    update allTasksToAdjust;
                    update casesToAdjust;
                }
            }

            // Scheduling additional Cases and Tasks

            if(allATJs != null) {

                // These two contain the last open cases

                //ATJToFirstOpenCaseMap = CaseDAO.getATJToFirstCaseMap(queryFieldsForCase, allATJIds);
                ATJToLastOpenCaseMap = CaseDAO.getATJToLastCaseMap(queryFieldsForCase, allATJIds);

                // This instead contains the last cases, including the closed ones. I need it if I have no new activities open

                ATJToLastCaseMap = CaseDAO.getATJToAllLastCaseMap(queryFieldsForCase, allATJIds);

                for(Account_Treatment_Job__c atj : allATJs) {
                    //Case firstCase = ATJToFirstOpenCaseMap.get(atj.Id);
                    Case lastCase = ATJToLastOpenCaseMap.get(atj.Id);
                    Case lastClosedCase = ATJToLastCaseMap.get(atj.Id);
                    Date firstCaseStartDate;
                    Date lastCaseStartDate;
                    Date triggeringDate; 
                    Integer scheduledPeriodInDays;
                    WorkOrder relatedTriggeringWorkOrder = ATJIdToTriggeringWOMap.get(atj.Id);

                    /* if(firstCase != null && firstCase.Start_Date__c != null) {
                        firstCaseStartDate = (firstCase.Start_Date__c).date();
                    } */
                    if(lastCase != null && lastCase.Start_Date__c != null) {
                        lastCaseStartDate = (lastCase.Start_Date__c).date();
                    }
                    else {
                        lastCase = lastClosedCase;
                    }

                    /* if(firstCaseStartDate != null && lastCaseStartDate != null) {
                        scheduledPeriodInDays = firstCaseStartDate.daysBetween(lastCaseStartDate);
                    }
                    else {
                        scheduledPeriodInDays = 0;
                    } */

                    if(ATIdToATHMap != null) {
                        Account_Treatment_History__c relatedATH = ATIdToATHMap.get(atj.Patient_Treatment__c);

                        if(relatedATH != null) {
                            triggeringDate = (relatedATH.CreatedDate).date();
                        }
                    }
                    else {
                        if(relatedTriggeringWorkOrder != null && relatedTriggeringWorkOrder.EndDate != null) {
                            triggeringDate = (relatedTriggeringWorkOrder.EndDate).date();
                        }
                    }

                    if(lastCaseStartDate != null && triggeringDate != null) {
                        scheduledPeriodInDays = triggeringDate.daysBetween(lastCaseStartDate);
                    }
                    else {
                        scheduledPeriodInDays = 0;
                    }

                    System.debug('Scheduled Period in Days: ' + scheduledPeriodInDays);

                    Integer schedulingTimeFrame = (Integer) ((atj.Scheduling_Time_Frame__c != null) ? atj.Scheduling_Time_Frame__c : 365);

                    if(scheduledPeriodInDays < schedulingTimeFrame) {
                        Integer daysToScheduleLeft;

                        if(/* firstCaseStartDate != null */triggeringDate != null && lastCaseStartDate != null) {
                            //Date schedulingPeriodEndDate = firstCaseStartDate.addYears(1);
                            Date schedulingPeriodEndDate = triggeringDate.addDays(schedulingTimeFrame);
                            System.debug('Scheduling Period End Date: ' + schedulingPeriodEndDate);

                            daysToScheduleLeft = lastCaseStartDate.daysBetween(schedulingPeriodEndDate);
                        }
                        else {
                            daysToScheduleLeft = schedulingTimeFrame;
                        }

                        if(atj.Frequency__c != null) {
                            ATJsForAdditionalScheduling.add(atj);
                        }

                        if(lastClosedCase != null && lastClosedCase.Id != null) {
                            allLastCaseIds.add(lastClosedCase.Id);
                        }
                        if(lastCase != null && lastCase.Id != null) {
                            caseToStartFromIds.add(lastCase.Id);
                        }

                        ATJIdToDaysToScheduleMap.put(atj.Id, daysToScheduleLeft);
                    }
                }

                if(!ATJsForAdditionalScheduling.isEmpty()) {
                
                    newCases = scheduleAdditionalCases(ATJsForAdditionalScheduling, ATJIdToDaysToScheduleMap, DMLOptions);

                    if(!newCases.isEmpty()) {
                        insert newCases;

                        for(Case c : newCases) {
                            newCaseIds.add(c.Id);
                        }

                        queriedNewCases = CaseDAO.getCasesFromIds(queryFieldsForCase, newCaseIds);

                        for(Case c : queriedNewCases) {
                            if(ATJIdToCasesMap.get(c.Account_Treatment_Job__c) == null) {
                                ATJIdToCasesMap.put(c.Account_Treatment_Job__c, new List<Case>());
                            }
                            ATJIdToCasesMap.get(c.Account_Treatment_Job__c).add(c);
                        }

                        ATJToSLAMap = ATMainComponentService.getATJToSLAMap(ATJsForAdditionalScheduling);

                        List<Task> allLastTasks = TaskDAO.getAutoscheduledTaskForCases(queryFieldsForTasks, allLastCaseIds);
                        List<Task> tasksToStartFrom = TaskDAO.getAutoscheduledTaskForCases(queryFieldsForTasks, caseToStartFromIds);

                        for(Task t : allLastTasks) {
                            ATJToLastTaskMap.put(t.Account_Treatment_Job__c, t);
                        }

                        if(tasksToStartFrom != null) {
                            for(Task t : tasksToStartFrom) {
                                ATJToTaskToStartFromMap.put(t.Account_Treatment_Job__c, t);
                            }
                        }

                        if(!ATJToSLAMap.isEmpty()) {
                            List<Task> tasksToInsert = new List<Task>();

                            for(Account_Treatment_Job__c atj : ATJsForAdditionalScheduling) {
                                Contract_Treatment_Job_SLA__c relatedSLA = ATJToSLAMap.get(atj);

                                List<Case> relatedCases = ATJIdToCasesMap.get(atj.Id);

                                Task startingTask;
                                
                                if(ATJToTaskToStartFromMap.get(atj.Id) != null) {
                                    startingTask = ATJToTaskToStartFromMap.get(atj.Id);
                                }
                                else {
                                    startingTask = ATJToLastTaskMap.get(atj.Id);
                                }

                                // Getting the last Case for this ATJ (it's the closed one, the map is filled before newCases are inserted)
                                Case startingCase;
                                
                                if(ATJToLastOpenCaseMap.get(atj.Id) != null) {
                                    startingCase = ATJToLastOpenCaseMap.get(atj.Id);
                                }
                                else {
                                    startingCase = ATJToLastCaseMap.get(atj.Id);
                                }

                                if(startingTask != null && relatedSLA != null) {
                                    // Day Autoscheduling

                                    if(atj.Frequency_Unit_of_measure__c == 'Day') {
                                        List<Task> newTasks = ATMainComponentService.autoscheduleTasks(atj, startingTask, startingCase, relatedSLA, 365, relatedCases, bh, false);

                                        for(Task t : newTasks) {
                                            tasksToInsert.add(t);
                                        }
                                    }

                                    // Week Autoscheduling 

                                    else if(atj.Frequency_Unit_of_measure__c == 'Week') {
                                        List<Task> newTasks = ATMainComponentService.autoscheduleTasks(atj, startingTask, startingCase, relatedSLA, 52, relatedCases, bh, false);

                                        for(Task t : newTasks) {
                                            tasksToInsert.add(t);
                                        }
                                    }

                                    // Month Autoscheduling

                                    else if(atj.Frequency_Unit_of_measure__c == 'Month') {
                                        List<Task> newTasks = ATMainComponentService.autoscheduleTasks(atj, startingTask, startingCase, relatedSLA, 12, relatedCases, bh, false);

                                        for(Task t : newTasks) {
                                            tasksToInsert.add(t);
                                        }
                                    }

                                    // Year Autoscheduling

                                    else if(atj.Frequency_Unit_of_measure__c == 'Year') {
                                        List<Task> newTasks = ATMainComponentService.autoscheduleTasks(atj, startingTask, startingCase, relatedSLA, 1, relatedCases, bh, false);

                                        for(Task t : newTasks) {
                                            tasksToInsert.add(t);
                                        }
                                    }
                                }
                            }

                            if(!tasksToInsert.isEmpty()) {
                                insert tasksToInsert;
                                update queriedNewCases;
                            }
                        }
                    }
                }
            }

            // WOs

            if(allWOsToAdjust != null) {
                for(WorkOrder wo : allWOsToAdjust) {
                    if(wo.Due_Date__c != null) {
                        Integer datesDifference = jobToDatesDifferenceMap.get(wo.Account_Treatment_Job__c);
                        Contract_Treatment_Job_SLA__c relatedSLA = SLAMap.get(wo.Related_SLA__c);
                        Case relatedCase;
                        Integer gap = ATJToGapMap.get(wo.Account_Treatment_Job__c);
                        WorkOrder relatedTriggeringWO = ATJIdToTriggeringWOMap.get(wo.Account_Treatment_Job__c);
                        List<WorkOrder> workOrdersThisATJ = ATJIdToWOsToAdjustMap.get(wo.Account_Treatment_Job__c);
                        Integer index = workOrdersThisATJ.indexOf(wo);

                        System.debug('wo: ' + wo.Id);
                        System.debug('index: ' + index);
                        System.debug('gap: ' + gap);

                        if(caseMap.get(wo.CaseId) != null && relatedSLA != null && datesDifference != null && gap != null && index != -1) {
                            relatedCase = caseMap.get(wo.CaseId);

                            Integer msInBusinessDay = 32400000;  // Milliseconds in 9 hours, a typical business day
                            Integer msInHour = 3600000;

                            // Adjusting scheduled WOs with the new dates

                            Datetime newDueDate;

                            /* if(allWOsToAdjust.indexOf(wo) == 0) {
                                newDueDate = (wo.EndDate).addDays(datesDifference);
                            } */
                            //else {
                                //newDueDate = (wo.Due_Date__c).addDays(datesDifference);
                            //}

                            //wo.Due_Date__c = newDueDate;

                            if(ATIdToATHMap == null) {
                                if(index == 0) {
                                    newDueDate = (relatedTriggeringWO).EndDate.addDays(gap);
                                }
                                else if(index > 0) {
                                    WorkOrder previousWO = workOrdersThisATJ[index - 1];
                                    newDueDate = (previousWO).Due_Date__c.addDays(gap);
                                }
                            }
                            else {
                                newDueDate = (wo.Due_Date__c).addDays(datesDifference);
                            }

                            wo.Due_Date__c = newDueDate;

                            System.debug('newDueDate before BusinessHours fix: ' + wo.Due_Date__c);
                            
                            /* if(!BusinessHours.isWithin(businessHoursId, wo.Due_Date__c)) {
                                if(wo.Due_Date__c.time() != Time.newInstance(18, 0, 0, 0) || !BusinessHours.isWithin(businessHoursId, wo.Due_Date__c.date())) {
                                    wo.Due_Date__c = BusinessHours.nextStartDate(businessHoursId, wo.Due_Date__c);
                                }
                            } */

                            Date dueDateConverted = Date.newInstance((wo.Due_Date__c).year(), (wo.Due_Date__c).month(), (wo.Due_Date__c).day());
                            Datetime consideredDate = wo.Due_Date__c;
                            Time endTime;

                            while(endTime == null) {
                                String dayOfWeekConsideredDate = (consideredDate).format('EEEE');
                                Time dayOfWeekEndTime;
                                System.debug('Considering date: ' + consideredDate);
                                System.debug('Day of week: ' + dayOfWeekConsideredDate);

                                switch on dayOfWeekConsideredDate {
                                    when 'Monday' {
                                        dayOfWeekEndTime = bh.MondayEndTime;
                                    }
                                    when 'Tuesday' {
                                        dayOfWeekEndTime = bh.TuesdayEndTime;
                                    }
                                    when 'Wednesday' {
                                        dayOfWeekEndTime = bh.WednesdayEndTime;
                                    }
                                    when 'Thursday' {
                                        dayOfWeekEndTime = bh.ThursdayEndTime;
                                    }
                                    when 'Friday' {
                                        dayOfWeekEndTime = bh.FridayEndTime;
                                    }
                                    when 'Saturday' {
                                        dayOfWeekEndTime = bh.SaturdayEndTime;
                                    }
                                    when 'Sunday' {
                                        dayOfWeekEndTime = bh.SundayEndTime;
                                    }
                                }

                                if(dayOfWeekEndTime != null) {
                                    endTime = dayOfWeekEndTime.addMinutes(-1);
                                }
                                else {
                                    consideredDate = consideredDate.addDays(-1);
                                }
                            }

                            if(endTime != null) {
                                wo.Due_Date__c = Datetime.newInstance(consideredDate.date(), endTime);
                            }

                            System.debug('newDueDate after BusinessHours fix: ' + wo.Due_Date__c);

                            if(relatedSLA.Offset_calculation_mode__c == 'Business') {
                                Integer toSubtract;
                                Integer toAdd;
                                
                                if(relatedSLA.Offset_unit_of_measure__c == 'Hour') {
                                    toSubtract = (Integer) relatedSLA.Offset_Start_Date__c * msInHour;
                                    toAdd = (Integer) relatedSLA.Offset_End_Date__c * msInHour;
                                }
                                else if(relatedSLA.Offset_unit_of_measure__c == 'Day') {
                                    toSubtract = (Integer) relatedSLA.Offset_Start_Date__c * msInBusinessDay;
                                    toAdd = (Integer) relatedSLA.Offset_End_Date__c * msInBusinessDay;
                                }
                                else if(relatedSLA.Offset_unit_of_measure__c == 'Week') {
                                    toSubtract = (Integer) relatedSLA.Offset_Start_Date__c * msInBusinessDay * 5;
                                    toAdd = (Integer) relatedSLA.Offset_End_Date__c * msInBusinessDay * 5;
                                }
                                else if(relatedSLA.Offset_unit_of_measure__c == 'Month') {
                                    toSubtract = (Integer) relatedSLA.Offset_Start_Date__c * msInBusinessDay * 20;
                                    toAdd = (Integer) relatedSLA.Offset_End_Date__c * msInBusinessDay * 20;
                                }

                                // Subtracting Offset from Due_Date (considering BH) to get Start_Date__c

                                wo.StartDate = BusinessHours.addGmt(businessHoursId, (wo.Due_Date__c), -toSubtract);

                                // Adding Offset to Due_Date (considering BH) to get End_Date__c

                                wo.EndDate = BusinessHours.addGmt(businessHoursId, (wo.Due_Date__c), toAdd);
                            }
                            else if(relatedSLA.Offset_calculation_mode__c == 'Calendar') {

                                // Subtracting Offset from Due_Date without considering BH to get Start_Date__c

                                Integer toSubtract = (Integer) relatedSLA.Offset_Start_Date__c;
                                if(relatedSLA.Offset_unit_of_measure__c == 'Hour') {
                                    wo.StartDate = (wo.Due_Date__c).addHours(-toSubtract);
                                }
                                else if(relatedSLA.Offset_unit_of_measure__c == 'Day') {
                                    wo.StartDate = (wo.Due_Date__c).addDays(-toSubtract);
                                }
                                else if(relatedSLA.Offset_unit_of_measure__c == 'Week') {
                                    wo.StartDate = (wo.Due_Date__c).addDays(-(toSubtract * 7));
                                }
                                else if(relatedSLA.Offset_unit_of_measure__c == 'Month') {
                                    wo.StartDate = (wo.Due_Date__c).addMonths(-toSubtract);
                                }

                                // Adjusting Start_Date__c if it falls outside the BHs

                                if(!BusinessHours.isWithin(businessHoursId, wo.StartDate)) {
                                    wo.StartDate = BusinessHours.nextStartDate(businessHoursId, wo.StartDate);
                                }

                                // Adding Offset to Due_Date without considering BH to get End_Date__c

                                Integer toAdd = (Integer) relatedSLA.Offset_End_Date__c;
                                if(relatedSLA.Offset_unit_of_measure__c == 'Hour') {
                                    wo.EndDate = (wo.Due_Date__c).addHours(toAdd);
                                }
                                else if(relatedSLA.Offset_unit_of_measure__c == 'Day') {
                                    wo.EndDate = (wo.Due_Date__c).addDays(toAdd);
                                }
                                else if(relatedSLA.Offset_unit_of_measure__c == 'Week') {
                                    wo.EndDate = (wo.Due_Date__c).addDays(toAdd * 7);
                                }
                                else if(relatedSLA.Offset_unit_of_measure__c == 'Month') {
                                    wo.EndDate = (wo.Due_Date__c).addMonths(toAdd);
                                }

                                // Adjusting End_Date__c if it falls outside the BHs

                                if(!BusinessHours.isWithin(businessHoursId, wo.EndDate)) {
                                    wo.EndDate = BusinessHours.nextStartDate(businessHoursId, wo.EndDate);
                                }
                            }

                            // Approximating StartDate and EndDate to the Start/End of Business Day

                            if(relatedSLA.Offset_unit_of_measure__c == 'Day' || relatedSLA.Offset_unit_of_measure__c == 'Week' || relatedSLA.Offset_unit_of_measure__c == 'Month') {
                                String dayOfWeekStartDate = wo.StartDate.format('EEEE');
                                //System.debug('dayOfWeekStartDate: ' + dayOfWeekStartDate);
                                String dayOfWeekEndDate = wo.EndDate.format('EEEE');
                                //System.debug('dayOfWeekEndDate: ' + dayOfWeekEndDate);

                                Date startDateConverted = Date.newInstance((wo.StartDate).year(), (wo.StartDate).month(), (wo.StartDate).day());
                                Date endDateConverted = Date.newInstance((wo.EndDate).year(), (wo.EndDate).month(), (wo.EndDate).day());

                                // Getting the day of the week, then getting the StartTime of that day and rebuilding startDate with the same Date but with the new startTime

                                if(dayOfWeekStartDate == 'Monday') {
                                    Time mondayStartTime = bh.MondayStartTime;
                                    
                                    wo.StartDate = Datetime.newInstance(startDateConverted, mondayStartTime);
                                }
                                else if(dayOfWeekStartDate == 'Tuesday') {
                                    Time tuesdayStartTime = bh.TuesdayStartTime;

                                    wo.StartDate = Datetime.newInstance(startDateConverted, tuesdayStartTime);
                                }
                                else if(dayOfWeekStartDate == 'Wednesday') {
                                    Time wednesdayStartTime = bh.WednesdayStartTime;

                                    wo.StartDate = Datetime.newInstance(startDateConverted, wednesdayStartTime);
                                }
                                else if(dayOfWeekStartDate == 'Thursday') {
                                    Time thursdayStartTime = bh.ThursdayStartTime;

                                    wo.StartDate = Datetime.newInstance(startDateConverted, thursdayStartTime);
                                }
                                else if(dayOfWeekStartDate == 'Friday') {
                                    Time fridayStartTime = bh.FridayStartTime;

                                    wo.StartDate = Datetime.newInstance(startDateConverted, fridayStartTime);
                                }

                                // Getting the day of the week, then getting the EndTime of that day and rebuilding endDate with the same Date but with the new endTime

                                if(dayOfWeekEndDate == 'Monday') {
                                    Time mondayEndTime = bh.MondayEndTime;
                                    
                                    wo.EndDate = Datetime.newInstance(endDateConverted, mondayEndTime);
                                }
                                else if(dayOfWeekEndDate == 'Tuesday') {
                                    Time tuesdayEndTime = bh.TuesdayEndTime;

                                    wo.EndDate = Datetime.newInstance(endDateConverted, tuesdayEndTime);
                                }
                                else if(dayOfWeekEndDate == 'Wednesday') {
                                    Time wednesdayEndTime = bh.WednesdayEndTime;

                                    wo.EndDate = Datetime.newInstance(endDateConverted, wednesdayEndTime);
                                }
                                else if(dayOfWeekEndDate == 'Thursday') {
                                    Time thursdayEndTime = bh.ThursdayEndTime;

                                    wo.EndDate = Datetime.newInstance(endDateConverted, thursdayEndTime);
                                }
                                else if(dayOfWeekEndDate == 'Friday') {
                                    Time fridayEndTime = bh.FridayEndTime;

                                    wo.EndDate = Datetime.newInstance(endDateConverted, fridayEndTime);
                                }
                            }
                        }

                        if(relatedCase != null && relatedCase.Start_Date__c == null && relatedSLA != null) {
                            relatedCase.Start_Date__c = wo.StartDate;
                            relatedCase.Next_Activity_Date__c = relatedCase.Start_Date__c;
                        }

                        if(relatedSLA != null) {
                            wo.Scheduled_Start_Date__c = wo.StartDate;
                            wo.Scheduled_End_Date__c = wo.EndDate;
                        }
                    }
                }

                if(!allWOsToAdjust.isEmpty()) {
                    update allWOsToAdjust;
                    update casesToAdjust;
                }
            }

            // Scheduling additional WOs and WOLIs

            if(allATJs != null) {

                if(!ATJsForAdditionalScheduling.isEmpty()) {

                    if(!newCases.isEmpty()) {
                        //List<Id> lastWOsIds = new List<Id>();
                        //List<String> workOrderToStartFromIds = new List<String>();
                        List<WorkOrder> allLastWOs = WorkOrderDAO.getAutoscheduledWOForCases(queryFieldsForWO, allLastCaseIds);
                        List<WorkOrder> workOrdersToStartFrom = WorkOrderDAO.getAutoscheduledWOForCases(queryFieldsForWO, caseToStartFromIds);

                        /* for(WorkOrder wo : allLastWOs) {
                            lastWOsIds.add(wo.Id);
                        } */

                        /* if(workOrdersToStartFrom != null) {
                            for(WorkOrder wo : workOrdersToStartFrom) {
                                workOrderToStartFromIds.add(wo.Id);
                            }
                        } */

                        //Map<Id, List<WorkOrderLineItem>> WOToItemsMap = new Map<Id, List<WorkOrderLineItem>>();
                        //List<WorkOrderLineItem> allWOLIs = WorkOrderLineItemDAO.getWOLIsFromWOs(queryFieldsForWOLI, lastWOsIds);
                        //List<WorkOrderLineItem> WOLIsToStartFrom = WorkOrderLineItemDAO.getWOLIsFromWOs(queryFieldsForWOLI, workOrderToStartFromIds);

                        /* if(!allWOLIs.isEmpty()) {
                            for(WorkOrderLineItem woli : allWOLIs) {
                                if(WOToItemsMap.get(woli.WorkOrderId) == null) {
                                    WOToItemsMap.put(woli.WorkOrderId, new List<WorkOrderLineItem>());
                                }
                                WOToItemsMap.get(woli.WorkOrderId).add(woli);
                            }
                        } */

                        /* if(!WOLIsToStartFrom.isEmpty()) {
                            for(WorkOrderLineItem woli : WOLIsToStartFrom) {
                                if(WOToItemsMap.get(woli.WorkOrderId) == null) {
                                    WOToItemsMap.put(woli.WorkOrderId, new List<WorkOrderLineItem>());
                                }
                                if(!WOToItemsMap.get(woli.WorkOrderId).contains(woli)) {
                                    WOToItemsMap.get(woli.WorkOrderId).add(woli);
                                }
                            }
                        } */

                        for(WorkOrder wo : allLastWOs) {
                            ATJToLastWOMap.put(wo.Account_Treatment_Job__c, wo);
                        }

                        if(workOrdersToStartFrom != null) {
                            for(WorkOrder wo : workOrdersToStartFrom) {
                                ATJToWOToStartFromMap.put(wo.Account_Treatment_Job__c, wo);
                            }
                        }

                        if(!ATJToSLAMap.isEmpty()) {
                            //List<WorkOrder> workOrdersToInsert = new List<WorkOrder>();
                            List<WorkOrderLineItem> WOLIsToInsert = new List<WorkOrderLineItem>();

                            for(Account_Treatment_Job__c atj : ATJsForAdditionalScheduling) {
                                Contract_Treatment_Job_SLA__c relatedSLA = ATJToSLAMap.get(atj);

                                List<Case> relatedCases = ATJIdToCasesMap.get(atj.Id);

                                WorkOrder startingWorkOrder;
                                
                                if(ATJToWOToStartFromMap.get(atj.Id) != null) {
                                    startingWorkOrder = ATJToWOToStartFromMap.get(atj.Id);
                                }
                                else {
                                    startingWorkOrder = ATJToLastWOMap.get(atj.Id);
                                }

                                if(startingWorkOrder != null && relatedSLA != null) {
                                    // Day Autoscheduling

                                    if(atj.Frequency_Unit_of_measure__c == 'Day') {
                                        List<WorkOrder> newWorkOrders = ATMainComponentService.autoscheduleWorkOrders(atj, startingWorkOrder, relatedSLA, 365, relatedCases, bh, false);

                                        for(WorkOrder wo : newWorkOrders) {
                                            workOrdersToInsert.add(wo);
                                        }
                                    }

                                    // Week Autoscheduling

                                    else if(atj.Frequency_Unit_of_measure__c == 'Week') {
                                        List<WorkOrder> newWorkOrders = ATMainComponentService.autoscheduleWorkOrders(atj, startingWorkOrder, relatedSLA, 52, relatedCases, bh, false);

                                        for(WorkOrder wo : newWorkOrders) {
                                            workOrdersToInsert.add(wo);
                                        }
                                    }

                                    // Month Autoscheduling

                                    else if(atj.Frequency_Unit_of_measure__c == 'Month') {
                                        List<WorkOrder> newWorkOrders = ATMainComponentService.autoscheduleWorkOrders(atj, startingWorkOrder, relatedSLA, 12, relatedCases, bh, false);

                                        for(WorkOrder wo : newWorkOrders) {
                                            workOrdersToInsert.add(wo);
                                        }
                                    }

                                    // Year Autoscheduling

                                    else if(atj.Frequency_Unit_of_measure__c == 'Year') {
                                        List<WorkOrder> newWorkOrders = ATMainComponentService.autoscheduleWorkOrders(atj, startingWorkOrder, relatedSLA, 1, relatedCases, bh, false);

                                        for(WorkOrder wo : newWorkOrders) {
                                            workOrdersToInsert.add(wo);
                                        }
                                    }
                                }
                            }

                            if(!workOrdersToInsert.isEmpty()) {
                                insert workOrdersToInsert;
                                update queriedNewCases;
                            }

                            // Building a ATJ.Id --> List<RelatedCases> Map to run the autoscheduling only on the Cases related to each ATJ

                            /* Map<Id, List<WorkOrder>> ATJIdToWOsMap = new Map<Id, List<WorkOrder>>();

                            for(WorkOrder wo : workOrdersToInsert) {
                                if(ATJIdToWOsMap.get(wo.Account_Treatment_Job__c) == null) {
                                    ATJIdToWOsMap.put(wo.Account_Treatment_Job__c, new List<WorkOrder>());
                                }
                                ATJIdToWOsMap.get(wo.Account_Treatment_Job__c).add(wo);
                            } */

                            // WOLI creation (copied from the ones of the last WO)

                            /* for(Account_Treatment_Job__c atj : ATJsForAdditionalScheduling) {
                                WorkOrder startingWorkOrder = ATJToLastWOMap.get(atj.Id);
                                if(startingWorkOrder != null) {
                                    List<WorkOrderLineItem> relatedWOLIs = WOToItemsMap.get(startingWorkOrder.Id);
                                    List<WorkOrder> relatedWorkOrders = ATJIdToWOsMap.get(atj.Id);

                                    if(relatedWOLIs != null) {
                                        for(WorkOrder wo : relatedWorkOrders) {
                                            for(WorkOrderLineItem woli : relatedWOLIs) {
                                                WorkOrderLineItem newWOLI = new WorkOrderLineItem(
                                                    WorkOrderId = wo.Id,
                                                    PricebookEntryId = woli.PricebookEntryId,
                                                    Quantity = woli.Quantity,
                                                    Customer_Product_Code__c = woli.Customer_Product_Code__c,
                                                    Customer_Request_Code__c = woli.Customer_Request_Code__c,
                                                    Customer_Purchase_Order_Number__c = woli.Customer_Purchase_Order_Number__c,
                                                    Customer_Purchase_Order_Date__c = woli.Customer_Purchase_Order_Date__c,
                                                    StorageLocation__c = woli.StorageLocation__c,
                                                    Plant__c = woli.Plant__c,
                                                    InvoiceSplittingGroup__c = woli.InvoiceSplittingGroup__c,
                                                    Account_Treatment_Job_Product__c = woli.Account_Treatment_Job_Product__c,
                                                    AssetId = woli.AssetId,
                                                    Serial_Number__c = woli.Serial_Number__c
                                                );

                                                WOLIsToInsert.add(newWOLI);
                                            }
                                        }
                                    }
                                }
                            }

                            if(!WOLIsToInsert.isEmpty()) {
                                insert WOLIsToInsert;
                            } */
                        }
                    }
                }
            }
        }

        return workOrdersToInsert;
    }

    // This method calls ATMainComponentService.createCases to autoschedule not for a year, but for "DaysToSchedule" days

    public static List<Case> scheduleAdditionalCases(List<Account_Treatment_Job__c> ATJsForAdditionalScheduling, Map<Id, Integer> ATJIdToDaysToScheduleMap,
    Database.DMLOptions DMLOptions) {
        List<Case> casesToInsert = new List<Case>();

        if(!ATJIdToDaysToScheduleMap.isEmpty()) {
            // Getting ATJToSLAMap
            Map<Account_Treatment_Job__c, Contract_Treatment_Job_SLA__c> ATJToSLAMap = ATMainComponentService.getATJtoSLAMap(ATJsForAdditionalScheduling);
            System.debug('Calling createCases, ATJToSLAMap: ' + ATJToSLAMap);

            for(Account_Treatment_Job__c atj : ATJsForAdditionalScheduling) {
                Map<Account_Treatment_Job__c, Contract_Treatment_Job_SLA__c> thisSLAMap = new Map<Account_Treatment_Job__c, Contract_Treatment_Job_SLA__c>();
                
                if(ATJToSLAMap.get(atj) != null) {
                    thisSLAMap.put(atj, ATJToSLAMap.get(atj));
                }

                if(!thisSLAMap.isEmpty()) {
                    System.debug('Days to schedule for: ' + ATJIdToDaysToScheduleMap.get(atj.Id));
                    List<Case> newCases = ATMainComponentService.createCases(thisSLAMap, DMLOptions, false, ATJIdToDaysToScheduleMap.get(atj.Id));

                    if(newCases != null) {
                        for(Case c : newCases) {
                            casesToInsert.add(c);
                        }
                    }
                }
            }
        }
        System.debug('CasesToInsert: ' + casesToInsert);

        return casesToInsert;

    }
}