public class UpdateCaseStatusForTask {

    public static void  UpdateCaseStatus(List<Id> caseIds) {
        List<Case> caseUpdate = new List<Case>();
        Datetime taskActivityDatetime ;
        Datetime workorderStartDatetime;
        //Date workorderStartDate ;
        Integer taskRelatedtoCaseIdNumber = 0 ;
        Integer workOrdersRelatedtoCaseidNumber = 0 ;
        List<task> taskRelatedtoCaseIds = new List<task>();
        List<String> queryFieldsForCase = new List<String>{'Id','Status'};
        //get the workorders related to the case ids 
        List<WorkOrder> workOrdersRelatedtoCaseIds = WorkOrderDAO.getworkOrdersRelatedtoCaseIdsfortask(caseIds);
        if (workOrdersRelatedtoCaseIds.size()>0) {
            workorderStartDatetime = workOrdersRelatedtoCaseIds[0].StartDate;
            System.debug('workorderstartdate'+workorderStartDatetime);
            /* if (workorderStartDatetime != null) {
                workorderStartDate = date.newInstance(workorderStartDatetime.year(), workorderStartDatetime.month(), workorderStartDatetime.day());
            } */
        }
        
        //map the caseId and with list of related WorkOrders 
        Map<Id, List<String>> caseIdandworkorderIds = new Map<Id, List<String>>();
        Map<String, List<WorkOrder>> caseToRelatedWOsMap = new Map<String, List<WorkOrder>>();

        for (WorkOrder wo : workOrdersRelatedtoCaseIds){
            List<String> temp = caseIdandworkorderIds.get(wo.CaseId);
            if (temp == null){
                caseIdandworkorderIds.put(wo.CaseId, new List<String>{wo.Id});
            } else{
                temp.add(wo.Id);
            }

            if (caseToRelatedWOsMap.get(wo.CaseId) == null){
                caseToRelatedWOsMap.put(wo.CaseId, new List<WorkOrder>());
            }
            caseToRelatedWOsMap.get(wo.CaseId).add(wo);
        }
        //get the tasks related to the case ids 
        taskRelatedtoCaseIds = TaskDAO.gettaskRelatedtoCaseIds(caseIds) ;
        if (taskRelatedtoCaseIds.size()>0) {
            taskActivityDatetime = Datetime.newInstance(taskRelatedtoCaseIds[0].ActivityDate , Time.newInstance(0, 0, 0, 0));
        } 
        
        //map the caseId and with the list of related tasks
        Map<Id, List<String>> caseIdandtaskIds = new Map<Id, List<String>>();
        Map<String, List<Task>> caseToRelatedTasksMap = new Map<String, List<Task>>();

        for(Task tk : taskRelatedtoCaseIds){
            List<String> temp = caseIdandtaskIds.get(tk.WhatId);
            if (temp == null){
                caseIdandtaskIds.put(tk.WhatId, new List<String>{tk.Id});
            } else{
                temp.add(tk.Id);
            }

            if (caseToRelatedTasksMap.get(tk.WhatId) == null){
                caseToRelatedTasksMap.put(tk.WhatId, new List<Task>());
            }
            caseToRelatedTasksMap.get(tk.WhatId).add(tk);
        }

        List<Case>  casestobeupdated = CaseDAO.getCasesFromIds(queryFieldsForCase,caseIds);
        for(Case c : casestobeupdated){
            WorkOrder relatedFirstWO;
			Task relatedFirstTask;
            List<WorkOrder> relatedWOs = caseToRelatedWOsMap.get(c.Id);
			List<Task> relatedTasks = caseToRelatedTasksMap.get(c.Id);

            if(relatedWOs != null && !relatedWOs.isEmpty()) {
				relatedFirstWO = relatedWOs[0];
			}

			if(relatedTasks != null && !relatedTasks.isEmpty()) {
				relatedFirstTask = relatedTasks[0];
			}

            if(caseIdandworkorderIds.containsKey(c.Id)){
                List<String> workOrdersRelatedtoCaseid = caseIdandworkorderIds.get(c.Id) ;
                //getting the total no of workorders related to the caseId 
                workOrdersRelatedtoCaseidNumber = workOrdersRelatedtoCaseid.size() ;
            }
            if(caseIdandtaskIds.containsKey(c.Id)){
                List<String> taskRelatedtoCaseId  = caseIdandtaskIds.get(c.Id) ;
                //getting the total no of tasks related to the case case Id
                taskRelatedtoCaseIdNumber = taskRelatedtoCaseId.size() ;
            }   
            if(taskRelatedtoCaseIdNumber == 0 && workOrdersRelatedtoCaseidNumber == 0){
                //update the case id
                c.Status = 'Closed' ;
                caseUpdate.add(c) ;
                System.debug('case utaskRelatedtoCaseIddpated');
            }
            /* else if (taskRelatedtoCaseIdNumber != 0 && workOrdersRelatedtoCaseidNumber != 0) {

            if (workorderStartDate <  taskActivityDate) {
                c.Next_Activity_Date__c = workorderStartDate ;
                caseUpdate.add(c) ;
                
            }else {
                c.Next_Activity_Date__c = taskActivityDate ;
                caseUpdate.add(c) ;
            }
                
            }
            else if (taskRelatedtoCaseIdNumber != 0) {
            c.Next_Activity_Date__c = taskActivityDate ;
            caseUpdate.add(c) ;
            }
            else {
            c.Next_Activity_Date__c = workorderStartDate ;
            caseUpdate.add(c) ;

            } */
            
            else if(taskRelatedtoCaseIdNumber != 0) {
                //c.Next_Activity_Date__c = taskActivityDatetime;
                if(relatedFirstTask != null && relatedFirstTask.ActivityDate != null) {
					c.Next_Activity_Date__c = Datetime.newInstance(relatedFirstTask.ActivityDate, Time.newInstance(0,0,0,0));
                    if(!caseUpdate.contains(c)) {
					    caseUpdate.add(c);
                    }
				}

                if(!caseUpdate.contains(c)) {
                    caseUpdate.add(c);
                }
            }
            else if (taskRelatedtoCaseIdNumber == 0 && workOrdersRelatedtoCaseidNumber != 0) {
                //c.Next_Activity_Date__c = workorderStartDatetime;
                if(relatedFirstWO != null) {
					c.Next_Activity_Date__c = relatedFirstWO.StartDate;
                    if(!caseUpdate.contains(c)) {
					    caseUpdate.add(c);
                    }
				}

                if(!caseUpdate.contains(c)) {
                    caseUpdate.add(c);
                }
            }    
        }
        update caseUpdate; 
        }

    }