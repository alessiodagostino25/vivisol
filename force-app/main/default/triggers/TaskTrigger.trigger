trigger TaskTrigger on Task(before insert, after insert, before update, after update ){
	if(Trigger.isAfter) {
		List<Id> caseids = new List<Id>();
		List<Id> queryCaseIds = new List<Id>();
		for (Task tk : Trigger.new){
			String s1 = String.valueof(tk.WhatId);
			if (s1!= null && s1.startsWith('500') == true){
				queryCaseIds.add(tk.WhatId);
			}
		}
		List<String> queryFieldsForCases = new List<String>{'Id', 'Type'};
		List<Case> cases = CaseDAO.getCasesFromIds(queryFieldsForCases, queryCaseIds);
		Map<Id, String> CaseIdandTypeMap = new Map<Id, String>();
		for (Case c : cases){
			CaseIdandTypeMap.put(c.Id, c.Type);
		}

		if (Trigger.isInsert){
			for (Task tk : Trigger.new){
				if (tk.Status == 'Open' && tk.Autoscheduled__c == false && tk.TaskSubtype != 'Email'){
					String s1 = String.valueof(tk.WhatId);
					if (s1.startsWith('500') == true){
						if (CaseIdandTypeMap.get(tk.WhatId) != 'Non compliance'){
							caseids.add(tk.WhatId);
						}
					}
				}
			}
		}

		if(Trigger.isUpdate && Trigger.isAfter) {
			List<Id> completedTaskIds = new List<Id>();
			List<Task> completedTasks = new List<Task>();
			List<Task> updatedActivityDateTasks = new List<Task>();

			for(Task t : Trigger.new) {
				String whatId = String.valueOf(t.WhatId);

				if (!System.isBatch()){
					if ((t.Status == 'Completed' || Trigger.oldMap.get(t.Id).ActivityDate != Trigger.newMap.get(t.Id).ActivityDate) && (t.TaskSubtype != 'Email')){
						if (whatId.startsWith('500') == true){
							if (CaseIdandTypeMap.get(t.WhatId) != 'Non compliance'){
								caseids.add(t.WhatId);
							}
						}
					}
				}

				if(whatId.startsWith('500') && Trigger.oldMap.get(t.Id).Status != 'Completed' && t.Status == 'Completed') {
					completedTaskIds.add(t.Id);
					completedTasks.add(t);
				}

				if((Trigger.oldMap.get(t.Id).ActivityDate != t.ActivityDate) && !t.IsClosed) {
					updatedActivityDateTasks.add(t);
				}
			}

			// Dependent activities scheduling

			if(!completedTaskIds.isEmpty()) {
				TaskService.scheduleDependentActivities(completedTaskIds, completedTasks);
			}

			// Checking if Case.StartDate has to be updated and eventually updating it

			if(!updatedActivityDateTasks.isEmpty()) {
				TaskService.updateCaseStartDate(updatedActivityDateTasks);
			}
		}

		if (!caseids.isEmpty()){
			UpdateCaseStatusForTask.UpdateCaseStatus(caseids);
		}
	}

	if(Trigger.isInsert && Trigger.isBefore) {
		Profile mulesoftProfile = TaskService.getMulesoftProfile();

		if(mulesoftProfile != null && mulesoftProfile.Id != null) {
			if(UserInfo.getProfileId() == mulesoftProfile.Id) {
				TaskService.setOwner(Trigger.new);
			}
		}

		for(Task t : Trigger.new) {
			if(t.Due_Date__c == null && t.ActivityDate != null) {
				t.Due_Date__c = Datetime.newInstance(t.ActivityDate, Time.newInstance(0, 0, 0, 0));
			} 
		}
	}

	if(Trigger.isUpdate && Trigger.isBefore) {
		List<Task> toCheckCaseStatus = new List<Task>();

		for(Task t : Trigger.new) {
			Task oldRecord = Trigger.oldMap.get(t.Id);

			if(oldRecord.Status == 'Completed' && t.Status == 'Open') {
				toCheckCaseStatus.add(t);
			}
		}

		if(FeatureManagementService.getFeatureStatus('Task_Open_Case_Closed_Exception') || Test.isRunningTest()) {
			if(!toCheckCaseStatus.isEmpty()) {
				TaskService.checkCaseStatus(toCheckCaseStatus);
			}
		}
	}
}