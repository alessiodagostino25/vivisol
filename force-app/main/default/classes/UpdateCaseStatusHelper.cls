public class UpdateCaseStatusHelper{
	public static void UpdateCaseStatus(List<Id> WorkOrderIds){
		System.debug('----- updateCaseStatus -----');

		List<Id> caseIds = new List<Id>();
		List<Id> CaseIdsForBoRequired = new List<Id>();
		List<Case> caseUpdate = new List<Case>();
		List<Case> caseUpdateBOrequired = new List<Case>();
		Integer taskRelatedtoCaseIdNumber = 0;
		Integer workOrdersRelatedtoCaseidNumber = 0;
		Integer result;
		Integer taskRelatedtoCaseIdNumberBOrequired = 0;
		Datetime workorderStartDatetime;
		Date workorderStartDate;
		Datetime workorderStartDatetimeNOBO;
		//Date workorderStartDateNOBO;
		Date taskActivityDate;
		Datetime taskActivityDateNOBO;
		Integer workOrdersRelatedtoCaseidNumberBorequired = 0;
		List<String> queryFieldsForCase = new List<String>{'Id', 'Status'};
		List<WorkOrder> WorkOrderupdate = new List<WorkOrder>();
		//query the workorders(with conditions) for the back office to review
		/* List<WorkOrder> boReviewWorkOrders = WorkOrderDAO.getBoReviewWordOrderIds(WorkOrderIds);
		for (WorkOrder wo : boReviewWorkOrders){
			//update the case status
			CaseIdsForBoRequired.add(wo.CaseId);
		}
		List<Case> CasesRelatedToWorkOrderBoRequired = CaseDAO.getCasesFromIds(queryFieldsForCase, CaseIdsForBoRequired);
		List<WorkOrder> workOrdersRelatedtoCaseIdsBOrequired = WorkOrderDAO.getworkOrdersRelatedtoCaseIds(CaseIdsForBoRequired);
		if (workOrdersRelatedtoCaseIdsBOrequired.size() > 0){
			workorderStartDatetime = workOrdersRelatedtoCaseIdsBOrequired[0].StartDate;
			if (workorderStartDatetime != null){
				workorderStartDate = date.newinstance(workorderStartDatetime.year(), workorderStartDatetime.month(), workorderStartDatetime.day());
			}
		}

		//map the caseId and with list of related WorkOrders
		Map<Id, List<String>> caseIdandworkorderIdsBOrequired = new Map<Id, List<String>>();
		for (WorkOrder wo : workOrdersRelatedtoCaseIdsBOrequired){
			List<String> temp = caseIdandworkorderIdsBOrequired.get(wo.CaseId);
			if (temp == null){
				caseIdandworkorderIdsBOrequired.put(wo.CaseId, new List<String>{wo.Id});
			} else{
				temp.add(wo.Id);
			}
		}
		//get the tasks related to the case ids
		List<Task> taskRelatedtoCaseIdsBOrequired = TaskDAO.gettaskRelatedtoCaseIds(CaseIdsForBoRequired);
		if (taskRelatedtoCaseIdsBOrequired.size() > 0){
			taskActivityDate = taskRelatedtoCaseIdsBOrequired[0].ActivityDate;
		}

		//map the caseId and with the list of related tasks
		Map<Id, List<String>> caseIdandtaskIdsBOrequired = new Map<Id, List<String>>();
		for (Task tk : taskRelatedtoCaseIdsBOrequired){
			List<String> temp = caseIdandtaskIdsBOrequired.get(tk.WhatId);
			if (temp == null){
				caseIdandtaskIdsBOrequired.put(tk.WhatId, new List<String>{tk.Id});
			} else{
				temp.add(tk.Id);
			}
		}

		for (Case c : CasesRelatedToWorkOrderBoRequired){

			List<String> workOrdersRelatedtoCaseidBOrequired = caseIdandworkorderIdsBOrequired.get(c.Id);
			//getting the total no of workorders related to the caseId
			if (workOrdersRelatedtoCaseidBOrequired != null){
				workOrdersRelatedtoCaseidNumberBorequired = workOrdersRelatedtoCaseidBOrequired.size();
			}
			if (caseIdandtaskIdsBOrequired.containsKey(c.Id)){
				List<String> taskRelatedtoCaseIdBOrequired = caseIdandtaskIdsBOrequired.get(c.Id);
				//getting the total no of tasks related to the case case Id
				taskRelatedtoCaseIdNumberBOrequired = taskRelatedtoCaseIdBOrequired.size();
			}
			result = taskRelatedtoCaseIdNumberBOrequired + workOrdersRelatedtoCaseidNumberBorequired;
			//if (result == 0){
				//update the case id
				c.Status = 'Review';
				c.Next_Activity_Date__c = Date.today();
				caseUpdateBOrequired.add(c);

			/*} else if (taskRelatedtoCaseIdNumberBOrequired != 0 && workOrdersRelatedtoCaseidNumberBorequired != 0){
				if (workorderStartDate < taskActivityDate){
					c.Next_Activity_Date__c = workorderStartDate;
					c.Status = 'Review';
					caseUpdateBOrequired.add(c);

				} else{
					c.Next_Activity_Date__c = taskActivityDate;
					c.Status = 'Review';
					caseUpdateBOrequired.add(c);
				}

			} else if (taskRelatedtoCaseIdNumberBOrequired != 0 && workOrdersRelatedtoCaseidNumberBorequired == 0){

				c.Next_Activity_Date__c = taskActivityDate;
				c.Status = 'Review';
				caseUpdateBOrequired.add(c);


			} else{
				c.Next_Activity_Date__c = workorderStartDate;
				c.Status = 'Review';
				caseUpdateBOrequired.add(c);
			}
		}
		update caseUpdateBOrequired; */


		//query the workorders(with conditions) that are not required to review by back office
		List<WorkOrder> notRequiredBoReviewWorkOrders = WorkOrderDAO.getnotRequiredBoReviewWorkOrders(WorkOrderIds);
		//get the case ids from the workorders
		for (WorkOrder wo : notRequiredBoReviewWorkOrders){
			if(wo.CaseId != null) {
				caseIds.add(wo.CaseId);
			}
		}
		//get the workorders related to the case ids
		List<WorkOrder> workOrdersRelatedtoCaseIds = new List<WorkOrder>();
		Map<String, List<WorkOrder>> caseToRelatedWOsMap = new Map<String, List<WorkOrder>>();

		if(!caseIds.isEmpty()) {
			workOrdersRelatedtoCaseIds = WorkOrderDAO.getworkOrdersRelatedtoCaseIds(caseIds);

			for(WorkOrder wo : workOrdersRelatedtoCaseIds) {
				if (caseToRelatedWOsMap.get(wo.CaseId) == null){
					caseToRelatedWOsMap.put(wo.CaseId, new List<WorkOrder>());
				}
				caseToRelatedWOsMap.get(wo.CaseId).add(wo);
			}
		}

		if (workOrdersRelatedtoCaseIds.size() > 0){
			workorderStartDatetimeNOBO = workOrdersRelatedtoCaseIds[0].StartDate;
			/* if (workorderStartDatetimeNOBO != null){
				workorderStartDateNOBO = date.newinstance(workorderStartDatetimeNOBO.year(), workorderStartDatetimeNOBO.month(), workorderStartDatetimeNOBO.day());
			} */

		}

		//map the caseId and with list of related WorkOrders
		Map<Id, List<String>> caseIdandworkorderIds = new Map<Id, List<String>>();
		for (WorkOrder wo : workOrdersRelatedtoCaseIds){
			List<String> temp = caseIdandworkorderIds.get(wo.CaseId);
			if (temp == null){
				caseIdandworkorderIds.put(wo.CaseId, new List<String>{wo.Id});
			} else{
				temp.add(wo.Id);
			}
		}
		//get the tasks related to the case ids
		List<Task> taskRelatedtoCaseIds = new List<Task>();
		Map<String, List<Task>> caseToRelatedTasksMap = new Map<String, List<Task>>();

		if(!caseIds.isEmpty()) {
			taskRelatedtoCaseIds = TaskDAO.gettaskRelatedtoCaseIds(caseIds);

			for(Task t : taskRelatedtoCaseIds) {
				if (caseToRelatedTasksMap.get(t.WhatId) == null){
					caseToRelatedTasksMap.put(t.WhatId, new List<Task>());
				}
				caseToRelatedTasksMap.get(t.WhatId).add(t);
			}
		}
		if (taskRelatedtoCaseIds.size() > 0){
			taskActivityDateNOBO = Datetime.newInstance(taskRelatedtoCaseIds[0].ActivityDate, Time.newInstance(0,0,0,0));
		}

		//map the caseId and with the list of related tasks
		Map<Id, List<String>> caseIdandtaskIds = new Map<Id, List<String>>();
		for (Task tk : taskRelatedtoCaseIds){
			List<String> temp = caseIdandtaskIds.get(tk.WhatId);
			if (temp == null){
				caseIdandtaskIds.put(tk.WhatId, new List<String>{tk.Id});
			} else{
				temp.add(tk.Id);
			}
		}
		List<Case> CasesRelatedToWorkOrderBoNotRequired = CaseDAO.getCasesFromIds(queryFieldsForCase, caseIds);
		for (Case c : CasesRelatedToWorkOrderBoNotRequired){
			List<WorkOrder> relatedWOs = caseToRelatedWOsMap.get(c.Id);
			List<Task> relatedTasks = caseToRelatedTasksMap.get(c.Id);
			WorkOrder relatedFirstWO;
			Task relatedFirstTask;

			if(relatedWOs != null && !relatedWOs.isEmpty()) {
				relatedFirstWO = relatedWOs[0];
			}

			if(relatedTasks != null && !relatedTasks.isEmpty()) {
				relatedFirstTask = relatedTasks[0];
			}
			
			List<String> workOrdersRelatedtoCaseid = caseIdandworkorderIds.get(c.Id);
			//getting the total no of workorders related to the caseId
			if (workOrdersRelatedtoCaseid != null){
				workOrdersRelatedtoCaseidNumber = workOrdersRelatedtoCaseid.size();
			}
			if (caseIdandtaskIds.containsKey(c.Id)){
				List<String> taskRelatedtoCaseId = caseIdandtaskIds.get(c.Id);
				//getting the total no of tasks related to the case case Id
				taskRelatedtoCaseIdNumber = taskRelatedtoCaseId.size();
			}

			System.debug('Case: ' + c.Id);
			System.debug('Related WOs: ' + workOrdersRelatedtoCaseidNumber);
			System.debug('Related Tasks: ' + taskRelatedtoCaseIdNumber);

			if (taskRelatedtoCaseIdNumber == 0 && workOrdersRelatedtoCaseidNumber == 0){
				//update the case id
				c.Status = 'Closed';
				//c.Next_Activity_Date__c = null;
				caseUpdate.add(c);

			} /*else if (taskRelatedtoCaseIdNumber != 0 && workOrdersRelatedtoCaseidNumber != 0){
				if (workorderStartDateNOBO < taskActivityDateNOBO){
					c.Next_Activity_Date__c = workorderStartDateNOBO;
					caseUpdate.add(c);

				} else{
					c.Next_Activity_Date__c = taskActivityDateNOBO;
					caseUpdate.add(c);
				}

			} else if (taskRelatedtoCaseIdNumber != 0 && workOrdersRelatedtoCaseidNumberBorequired == 0){

				c.Next_Activity_Date__c = taskActivityDateNOBO;
				caseUpdate.add(c);

			} else{
				c.Next_Activity_Date__c = workorderStartDateNOBO;
				caseUpdate.add(c);
			} */

			else if(taskRelatedtoCaseIdNumber != 0) {
				//c.Next_Activity_Date__c = taskActivityDateNOBO;
				if(relatedFirstTask != null && relatedFirstTask.ActivityDate != null) {
					c.Next_Activity_Date__c = Datetime.newInstance(relatedFirstTask.ActivityDate, Time.newInstance(0,0,0,0));
					caseUpdate.add(c);
				}
			}
			else if (taskRelatedtoCaseIdNumber == 0 && workOrdersRelatedtoCaseidNumber != 0) {
				//c.Next_Activity_Date__c = workorderStartDatetimeNOBO;
				if(relatedFirstWO != null) {
					c.Next_Activity_Date__c = relatedFirstWO.StartDate;
					caseUpdate.add(c);
				}
			}
		}


        update caseUpdate;
        








        ////////////////7777




		/* List<String> queryFieldsForwo = new List<String>{'Id', 'CaseId'};
		List<Case> caseUpdate2 = new List<Case>();
		Datetime StartDatetimewo;
		Date StartDatewo;
        Date taskActivityDate2;
        Integer taskRelatedtoCaseIdNumber2 = 0;
        Integer workOrdersRelatedtoCaseidNumber2 = 0;
		List<Id> caseIds2 = new List<Id>();
		//query the workorders(with conditions) that are not required to review by back office
		List<WorkOrder> WorkOrders = WorkOrderDAO.getWorkOrdersFromIds(queryFieldsForwo,WorkOrderIds);
		//get the case ids from the workorders
		for (WorkOrder wo : WorkOrders){
			caseIds2.add(wo.CaseId);
		}
		//get the workorders related to the case ids
		List<WorkOrder> newworkOrdersRelatedtoCaseIds2 = WorkOrderDAO.getworkOrdersRelatedtoCaseIds(caseIds2);
		if (newworkOrdersRelatedtoCaseIds2.size() > 0){
			StartDatetimewo = newworkOrdersRelatedtoCaseIds2[0].StartDate;
			if (StartDatetimewo != null){
				StartDatewo = date.newinstance(StartDatetimewo.year(), StartDatetimewo.month(), StartDatetimewo.day());
			}

		}

		//map the caseId and with list of related WorkOrders
		Map<Id, List<String>> caseIdandworkorderIds2 = new Map<Id, List<String>>();
		for (WorkOrder wo : newworkOrdersRelatedtoCaseIds2){
			List<String> temp = caseIdandworkorderIds2.get(wo.CaseId);
			if (temp == null){
				caseIdandworkorderIds2.put(wo.CaseId, new List<String>{wo.Id});
			} else{
				temp.add(wo.Id);
			}
		}
		//get the tasks related to the case ids
		List<Task> taskRelatedtoCaseIds2 = TaskDAO.gettaskRelatedtoCaseIds(caseIds2);
		if (taskRelatedtoCaseIds2.size() > 0){
			taskActivityDate2 = taskRelatedtoCaseIds2[0].ActivityDate;
		}

		//map the caseId and with the list of related tasks
		Map<Id, List<String>> caseIdandtaskIds2 = new Map<Id, List<String>>();
		for (Task tk : taskRelatedtoCaseIds2){
			List<String> temp = caseIdandtaskIds2.get(tk.WhatId);
			if (temp == null){
				caseIdandtaskIds2.put(tk.WhatId, new List<String>{tk.Id});
			} else{
				temp.add(tk.Id);
			}
		}
		List<Case> CasesRelatedToWorkOrder2 = CaseDAO.getCasesFromIds(queryFieldsForCase, caseIds2);
		for (Case c : CasesRelatedToWorkOrder2){

			List<String> workOrdersRelatedtoCaseid2 = caseIdandworkorderIds2.get(c.Id);
			//getting the total no of workorders related to the caseId
			if (workOrdersRelatedtoCaseid2 != null) {
				workOrdersRelatedtoCaseidNumber2 = workOrdersRelatedtoCaseid2.size();
			}
	
			if (caseIdandtaskIds2.containsKey(c.Id)){
				List<String> taskRelatedtoCaseId2 = caseIdandtaskIds2.get(c.Id);
				//getting the total no of tasks related to the case case Id
				taskRelatedtoCaseIdNumber2 = taskRelatedtoCaseId2.size();
			}

			if (taskRelatedtoCaseIdNumber2 == 0 && workOrdersRelatedtoCaseidNumber2 == 0){
				//update the case id


			} else if (taskRelatedtoCaseIdNumber2 != 0 && workOrdersRelatedtoCaseidNumber2 != 0){
				if (StartDatewo < taskActivityDate2){
					c.Next_Activity_Date__c = StartDatewo;
					caseUpdate2.add(c);

				} else{
					c.Next_Activity_Date__c = taskActivityDate2;
					caseUpdate2.add(c);
				}

			} else if (taskRelatedtoCaseIdNumber2 != 0 && workOrdersRelatedtoCaseidNumber2 == 0){

				c.Next_Activity_Date__c = taskActivityDate2;
				caseUpdate2.add(c);

			} else{
				c.Next_Activity_Date__c = StartDatewo;
				caseUpdate2.add(c);
			}
		}


		update caseUpdate2;*/
	} 
}