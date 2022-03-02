public class WorkOrderService{
	// This method schedules activities (Cases, Tasks, WOs) for the ATJs dependent from the ATJ of the closed Therapy WOs (given in input)
	public static void scheduleActivities(List<WorkOrder> workOrders){
		/* System.debug('WorkOrderService, workOrders size: ' + workOrders.size());
		List<String> queryFieldsForATJ = new List<String>{'Scheduling_Rule__c', 'Work_Order__c', 'Task__c', 'Contract_Treatment_Job__c', 'Patient_Treatment__r.Account__c',
		'Patient_Treatment__c', 'Patient_Treatment__r.Contract_Treatment__c', 'Name', 'Case_Subtype__c', 'Case_Type__c', 'Patient_Treatment__r.Treatment_Type__c', 
		'Contract_Treatment_Job__r.Contract_Framework__r.Customer__c', 'Contract_Treatment_Job__r.Contract_Framework__r.Branch_of_belonging_sales_office__c', 
		'Contract_Treatment_Job__r.Contract_Framework__c', 'Contract_Treatment_Job__r.Contract_Treatment__c', 'Delivery_Channel__c', 
		'Contract_Treatment_Job__r.Contract_Framework__r.Price_list_code__c', 'Patient_Treatment__r.Customer_Purchase_Date__c', 
		'Patient_Treatment__r.Customer_Purchase_Order_Number__c', 'Patient_Treatment__r.Account__r.FirstName', 'Patient_Treatment__r.Account__r.LastName', 
		'Work_Type__c', 'Patient_Treatment__r.Account__r.IsPersonAccount', 'Patient_Treatment__r.Account__r.PersonContactId', 'Frequency__c', 
		'Frequency_Unit_of_measure__c', 'Patient_Treatment__r.Prescription__r.CreatedDate', 'Patient_Treatment__r.Prescription__r.Received_Date__c', 
		'Contract_Treatment_Job__r.Contract_Framework__r.Attachment_Addendum_Type__c', 'Contract_Treatment_Job__r.Contract_Framework__r.Billing_Via__c', 
		'Contract_Treatment_Job__r.Contract_Framework__r.Customer__r.Customer_Purchase_Order_Date__c', 
		'Contract_Treatment_Job__r.Contract_Framework__r.Customer__r.Customer_Purchase_Order_Number__c', 
		'Contract_Treatment_Job__r.Contract_Framework__r.Customer__r.Billing_Reference__c', 'Contract_Treatment_Job__r.Contract_Framework__r.Invoice_splitting_criterion__c', 
		'Contract_Treatment_Job__r.Contract_Framework__r.Invoice_Layout__c', 'Contract_Treatment_Job__r.Invoice_Splitting_Group__c', 
		'Patient_Treatment__r.Customer_Request_Code__c', 'Patient_Treatment__r.Contract_Treatment__r.Invoice_Splitting_Group__c', 'Account_Treatment_Job__c', 
		'Customer_Product_Code__c'};

		List<String> queryFieldsForSLA = new List<String>{'IsDefault__c', 'Contract_Treatment_Job__c', 'Max_Time__c', 'Unite_of_measure_Max_Time__c',      //Unit, not unite
		'Calculation_Mode__c', 'Offset_Start_Date__c', 'Offset_End_Date__c', 'Offset_unit_of_measure__c', 'Offset_calculation_mode__c', 'Task_MaxTime_Execution__c', 
		'Task_Unite_of_measure_Max_Time__c', 'Task_Calculation_Mode__c'};

		List<String> queryFieldsForProducts = new List<String>{'Product__c', 'Quantity__c', 'Customer_Treatment_Alias__c', 'Patient_Treatment_Job__c', 'Customer_Request_Code__c', 
		'Storage_Location__c', 'Plant__c', 'Purchase_order_number__c', 'Purchase_order_date__c', 'Contract_Treatment_Job_Product__r.Invoice_Splitting_group__c', 'Asset__c'};

		List<String> queryFieldsForPBEntry = new List<String>{'Product2Id', 'Pricebook2Id'};

		List<String> queryFieldsForASO = new List<String>{'Sales_Organization__r.Code__c', 'Division__c', 'Distribution_Channel__c', 'Sales_Group__c', 'Sales_Office__c'};

		List<String> caseQueryFields = new List<String>{'AccountId', 'Account_Treatment__c', 'Account_Treatment_Job__c', 'Origin', 'Contract_Treatment__c', 
        'Patient__c', 'Status', 'Subject', 'Subtype__c', 'Type', 'Treatment__c', 'Autoscheduled__c', 'ContactId', 'OwnerId', 'Start_Date__c', 'Next_Activity_Date__c'};

		BusinessHours bh = [SELECT Id, MondayStartTime, MondayEndTime, TuesdayStartTime, TuesdayEndTime, WednesdayStartTime, WednesdayEndTime, ThursdayStartTime, ThursdayEndTime, FridayStartTime, FridayEndTime
		                    FROM BusinessHours
							WHERE Name = 'NL'];
							
		AssignmentRule assignmentRule = [SELECT Id
		                                 FROM AssignmentRule
		                                 WHERE SobjectType = 'Case' and Active = true
										 LIMIT 1];
										 
		DocumentType__mdt therapyDocumentType = [SELECT Code__c
		                                         FROM DocumentType__mdt
												 WHERE DeveloperName = 'Therapy'];
												 
		//Creating the DMLOptions for "Assign using active assignment rules" checkbox

		Database.DMLOptions DMLOptions = new Database.DMLOptions();
		DMLOptions.assignmentRuleHeader.assignmentRuleId = assignmentRule.Id;

		// This map links each CTJ Id to the related SLAs

		Map<Id, List<Contract_Treatment_Job_SLA__c>> SLAMap = new Map<Id, List<Contract_Treatment_Job_SLA__c>>();
		Map<Id, List<Account_Treatment_Job__c>> dependentATJMap = new Map<Id, List<Account_Treatment_Job__c>>();
		Map<Id, List<Account_Treatment_Job_Product__c>> jobToProductsMap = new Map<Id, List<Account_Treatment_Job_Product__c>>();
		Map<Id, Account_Treatment_Job__c> ATJMap = new Map<Id, Account_Treatment_Job__c>();
		Map<Id, List<PricebookEntry>> pricebookIdToPEMap = new Map<Id, List<PricebookEntry>>();
		Map<Id, Account_Sales_Organization__c> ASOMap = new Map<Id, Account_Sales_Organization__c>();
		Map<String, List<Case>> newCasesMap = new Map<String, List<Case>>();
		Map<String, Case> queriedNewCasesMap = new Map<String, Case>();

		List<Id> ATJids = new List<Id>();
		List<Id> dependentJobsIds = new List<Id>();
		List<Id> pricebookIds = new List<Id>();
		List<Id> newCaseIds = new List<Id>();
		List<Case> newCases = new List<Case>();
		List<Case> queriedNewCases = new List<Case>();
		List<WorkOrder> newWorkOrders = new List<WorkOrder>();
		List<Task> newTasks = new List<Task>();
		List<Id> relatedASOIds = new List<Id>();

		for (WorkOrder wo : workOrders){
			ATJids.add(wo.Account_Treatment_Job__c);
		}

		// This is the list of all the dependent ATJs related to all the workOrders in input

		List<Account_Treatment_Job__c> allDependentJobs = AccountTreatmentJobDAO.getDependentATJsFromATJIds(queryFieldsForATJ, ATJids);

		// Filling the dependentATJMap with key = ATJ Id which the Job depends on and value = list of the job depending on that ATJ Id

		if (allDependentJobs != null){
			for (Account_Treatment_Job__c atj : allDependentJobs){
				ATJMap.put(atj.Id, atj);
				dependentJobsIds.add(atj.Id);
				pricebookIds.add(atj.Contract_Treatment_Job__r.Contract_Framework__r.Price_list_code__c);
				relatedASOIds.add(atj.Contract_Treatment_Job__r.Contract_Framework__r.Branch_of_belonging_sales_office__c);
				if (dependentATJMap.get(atj.Account_Treatment_Job__c) == null){
					dependentATJMap.put(atj.Account_Treatment_Job__c, new List<Account_Treatment_Job__c>());
				}
				dependentATJMap.get(atj.Account_Treatment_Job__c).add(atj);
			}
		}

		System.debug('DependentATJMap: ' + dependentATJMap);
		List<Account_Treatment_Job_Product__c> allProducts = AccountTreatmentJobProductDAO.getActiveProductsFromATJs(queryFieldsForProducts, dependentJobsIds);

		if (!allProducts.isEmpty()){
			System.debug('allproducts size: ' + allProducts.size());
			for (Account_Treatment_Job_Product__c atjp : allProducts){
				if (jobToProductsMap.get(atjp.Patient_Treatment_Job__c) == null){
					jobToProductsMap.put(atjp.Patient_Treatment_Job__c, new List<Account_Treatment_Job_Product__c>());
				}
				jobToProductsMap.get(atjp.Patient_Treatment_Job__c).add(atjp);
			}
		}

		// Getting all the pricebookEntries --> The pricebookEntry related to each Account_Treatment_Job__c

		List<PricebookEntry> allPricebookEntries = PricebookEntryDAO.getPEFromPricebookIds(queryFieldsForPBEntry, pricebookIds);
		if (!allPricebookEntries.isEmpty()){
			for (PricebookEntry pe : allPricebookEntries){
				if (pricebookIdToPEMap.get(pe.Pricebook2Id) == null){
					pricebookIdToPEMap.put(pe.Pricebook2Id, new List<PricebookEntry>());
				}
				pricebookIdToPEMap.get(pe.Pricebook2Id).add(pe);
			}
		}

		// Getting all the ASOs related to the ATJs

		List<Account_Sales_Organization__c> relatedASOs = AccountSalesOrganizationDAO.getASOsFromIds(queryFieldsForASO, relatedASOIds);
		if (relatedASOs != null){
			for (Account_Sales_Organization__c aso : relatedASOs){
				ASOMap.put(aso.Id, aso);
			}
		}

		// Creating Cases --> I need to insert them before creating WO and Tasks

		for (WorkOrder wo : workOrders){
			List<Account_Treatment_Job__c> dependentATJs = dependentATJMap.get(wo.Account_Treatment_Job__c);
			//System.debug('dependentATJs: ' + dependentATJs.size());
			if (dependentATJs != null){
				System.debug('dependentATJs: ' + dependentATJs);
				// All dependent ATJs and the related chosen SLA
				Map<Account_Treatment_Job__c, Contract_Treatment_Job_SLA__c> ATJtoSLAMap = ATMainComponentService.getATJtoSLAMap(dependentATJs);
				List<Case> createdNewCases = ATMainComponentService.createCases(ATJtoSLAMap, DMLOptions, 365);
				System.debug('createdNewCases size: ' + createdNewCases.size());

				if(createdNewCases != null) {
					newCasesMap.put(wo.Id, createdNewCases);

					for(Case c : createdNewCases) {
						newCases.add(c);
					}
				}
			}
		}

		// Inserting new Cases

		if (!newCases.isEmpty()){
			insert newCases;

			for(Case c : newCases) {
                newCaseIds.add(c.Id);
			}
			
			// I need to query the new Cases, but then I need to swap the queried new Cases with the old ones in the newCases Map, to have the queried new Cases for each WO

			queriedNewCases = CaseDAO.getCasesFromIds(caseQueryFields, newCaseIds);
			
			for(Case c : queriedNewCases) {
				queriedNewCasesMap.put(c.Id, c);
			}

			for(WorkOrder wo : workOrders) {
				List<Case> relatedNewCases = newCasesMap.get(wo.Id);
				List<Case> newRelatedNewCases = new List<Case>();

				if(relatedNewCases != null && !relatedNewCases.isEmpty()) {
					for(Case c : relatedNewCases) {
						Case relatedQueriedCase = queriedNewCasesMap.get(c.Id);

						if(relatedQueriedCase != null) {
							newRelatedNewCases.add(relatedQueriedCase);
						}
					}

					if(newRelatedNewCases != null) {
						newCasesMap.put(wo.Id, newRelatedNewCases);
					}
				}
			}
		}

		for (WorkOrder wo : workOrders){
			List<Account_Treatment_Job__c> dependentATJs = dependentATJMap.get(wo.Account_Treatment_Job__c);
			if (dependentATJs != null){
				List<Case> relatedNewCases = newCasesMap.get(wo.Id);

				if(relatedNewCases != null && !relatedNewCases.isEmpty()) {
					// All dependent ATJs and the related chosen SLA
					Map<Account_Treatment_Job__c, Contract_Treatment_Job_SLA__c> ATJtoSLAMap = ATMainComponentService.getATJtoSLAMap(dependentATJs);
					// Using the modified version of createWorkOrders to create WOs for each dependent Job of each closed WO
					List<WorkOrder> createdWorkOrders = createWorkOrders(ATJToSLAMap, relatedNewCases, wo, null, bh, ASOMap, therapyDocumentType);
					if (createdWorkOrders != null){
						for (WorkOrder createdWO : createdWorkOrders){
							newWorkOrders.add(createdWO);
						}
					}
					// Using the same method used in ATMainComponentService to create Tasks for each dependent Job of each closed WO
					List<Task> createdTasks = ATMainComponentService.createTasks(ATJtoSLAMap, relatedNewCases, bh, false, wo, null, null, null);
					if (createdTasks != null){
						for (Task createdTask : createdTasks){
							newTasks.add(createdTask);
						}
					}
				}
			}
		}

		// Inserting new WorkOrders and executing batches to insert WOLI for each new WorkOrder + updating Cases for the Start Date

		if (!newWorkOrders.isEmpty()){
			insert newWorkOrders;
			update queriedNewCases;

			WOLICreationBatch WOLICreation = new WOLICreationBatch();
			WOLICreation.ATJMap = ATJMap;
			WOLICreation.jobToProductsMap = jobToProductsMap;
			WOLICreation.pricebookIdToPEMap = pricebookIdToPEMap;
			WOLICreation.workOrders = newWorkOrders;
			Database.executeBatch(WOLICreation, 3);
		}
		// Inserting new Tasks and updating Cases for the Start Date
		if (!newTasks.isEmpty()){
			insert newTasks;
			update queriedNewCases;
		} */

		List<String> workOrderIds = new List<String>();

		for(WorkOrder wo : workOrders) {
			workOrderIds.add(wo.Id);
		}

		DependentActivitiesScheduling_WO dependentActivitiesBatch = new DependentActivitiesScheduling_WO();
		dependentActivitiesBatch.workOrderIds = workOrderIds;

		Database.executeBatch(dependentActivitiesBatch);

		SingletonClass.setFlag();
	}

	// This is a modified version of the method ATMainComponentService.createWorkOrders, made to be used with a closedWO or a closedTask and not to do DML operations/queries

	public static List<WorkOrder> createWorkOrders(Map<Account_Treatment_Job__c, Contract_Treatment_Job_SLA__c> ATJToSLAMap, List<Case> newCases, WorkOrder closedWO, 
	Task closedTask, BusinessHours bh, Map<Id, Account_Sales_Organization__c> ASOMap, DocumentType__mdt therapyDocumentType){
		Set<Account_Treatment_Job__c> ATJs = ATJToSLAMap.keySet();
		List<Account_Treatment_Job__c> workOrderATJs = new List<Account_Treatment_Job__c>();
		List<Id> workOrderATJsIds = new List<Id>();
		Map<Id, List<Case>> ATJToCasesMap = new Map<Id, List<Case>>();
		List<WorkOrder> toInsert = new List<WorkOrder>();
		Id businessHoursId = bh.Id;

		if (!newCases.isEmpty()){
			for (Case c : newCases){
				if (ATJToCasesMap.get(c.Account_Treatment_Job__c) == null){
					ATJToCasesMap.put(c.Account_Treatment_Job__c, new List<Case>());
				}
				ATJToCasesMap.get(c.Account_Treatment_Job__c).add(c);
			}
		}

		for (Account_Treatment_Job__c atj : ATJs){
			if (atj.Work_Order__c == true){
				workOrderATJs.add(atj);
			}
		}

		for (Account_Treatment_Job__c atj : workOrderATJs){
			workOrderATJsIds.add(atj.Id);
		}

		for (Account_Treatment_Job__c atj : workOrderATJs){
			// Getting the related ASO
			Account_Sales_Organization__c relatedASO = ASOMap.get(atj.Contract_Treatment_Job__r.Contract_Framework__r.Branch_of_belonging_sales_office__c);

			// These are the Cases previously created related to this ATJ
			List<Case> relatedCases = ATJToCasesMap.get(atj.Id);

			// The first WO created will be assigned to thefirst  Case
			Case firstCase = relatedCases[0];

			// These are the Cases that will be assigned to the WOs that will be autoscheduled later
			List<Case> remainingCases = relatedCases;
			remainingCases.remove(0);
			Contract_Treatment_Job_SLA__c relatedSLA = ATJToSLAMap.get(atj);

			DatesResponseDTO relatedDates;

			// Getting startDate, endDate and dueDate
			if(closedWO != null && closedTask == null) {
				relatedDates = ATMainComponentService.calculateDates(
					closedWO.EndDate, 
					relatedSLA.Max_Time__c, 
					relatedSLA.Unite_of_measure_Max_Time__c,       // To fix, unit not unite
					relatedSLA.Calculation_Mode__c, 
					relatedSLA.Offset_Start_Date__c, 
					relatedSLA.Offset_End_Date__c, 
					relatedSLA.Offset_unit_of_measure__c, 
					relatedSLA.Offset_calculation_mode__c, 
					bh,
					false
				);
			}
			else if(closedWO == null && closedTask != null) {
				relatedDates = ATMainComponentService.calculateDates(
					closedTask.CompletedDateTime, 
					relatedSLA.Max_Time__c, 
					relatedSLA.Unite_of_measure_Max_Time__c,       // To fix, unit not unite
					relatedSLA.Calculation_Mode__c, 
					relatedSLA.Offset_Start_Date__c, 
					relatedSLA.Offset_End_Date__c, 
					relatedSLA.Offset_unit_of_measure__c, 
					relatedSLA.Offset_calculation_mode__c, 
					bh,
					false
				);
			}

			// Creating new WO for each ATJ with Work_Order__c = true related to the previously created Case (CaseId)
			WorkOrder newWorkOrder = new WorkOrder(

				// Fields from the ATJ

				AccountId = atj.Patient_Treatment__r.Account__c, 
				Account_Sold_To__c = atj.Contract_Treatment_Job__r.Contract_Framework__r.Customer__c, 
				Account_Sales_Organization__c = atj.Contract_Treatment_Job__r.Contract_Framework__r.Branch_of_belonging_sales_office__c, 
				Account_Treatment__c = atj.Patient_Treatment__c, 
				CaseId = firstCase.Id, 
				Contract_Framework__c = atj.Contract_Treatment_Job__r.Contract_Framework__c, 
				Contract_Treatment__c = atj.Contract_Treatment_Job__r.Contract_Treatment__c, 
				Contract_Treatment_Job__c = atj.Contract_Treatment_Job__c, 
				//Customer_Purchase_Order_Date__c = atj.Contract_Treatment_Job__r.Contract_Framework__r.Customer__r.Customer_Purchase_Order_Date__c, 
				//Customer_Purchase_Order_Number__c = atj.Contract_Treatment_Job__r.Contract_Framework__r.Customer__r.Customer_Purchase_Order_Number__c, 
				Delivery_Type__c = atj.Delivery_Channel__c, 
				Document_Type__c = therapyDocumentType.Code__c, 
				OwnerId = UserInfo.getUserId(), 
				Pricebook2Id = atj.Contract_Treatment_Job__r.Contract_Framework__r.Price_list_code__c, 
				Status = 'New', 
				Subject = atj.Patient_Treatment__r.Account__r.FirstName + ' ' + atj.Patient_Treatment__r.Account__r.LastName + ' - ' + atj.Name, 
				WorkTypeId = atj.Work_Type__c, 
				Account_Treatment_Job__c = atj.Id, 
				Attachment_Addendum_Type__c = atj.Contract_Treatment_Job__r.Contract_Framework__r.Attachment_Addendum_Type__c, 
				Billing_Via__c = atj.Contract_Treatment_Job__r.Contract_Framework__r.Billing_Via__c, 
				//Billing_Reference__c = atj.Contract_Treatment_Job__r.Contract_Framework__r.Customer__r.Billing_Reference__c, 
				Invoice_splitting_criterion__c = atj.Contract_Treatment_Job__r.Contract_Framework__r.Invoice_splitting_criterion__c, 
				InvoiceLayout__c = atj.Contract_Treatment_Job__r.Contract_Framework__r.Invoice_Layout__c, 
				Job_InvoiceSplittingGroup__c = atj.Contract_Treatment_Job__r.Invoice_Splitting_Group__c, 
				Treatment_Customer_Purchase_Order_Date__c = atj.Patient_Treatment__r.Customer_Purchase_Date__c, 
				Treatment_Customer_Purchase_Order_Number__c = atj.Patient_Treatment__r.Customer_Purchase_Order_Number__c, 
				Treatment_Customer_Request_Code__c = atj.Patient_Treatment__r.Customer_Request_Code__c, 
				Treatment_InvoiceSplittingGroup__c = atj.Patient_Treatment__r.Contract_Treatment__r.Invoice_Splitting_Group__c, 

				// Fields from the calculateDates method

				Related_SLA__c = relatedSLA.Id, 
				Scheduled_Start_Date__c = relatedDates.startDate, 
				Scheduled_End_Date__c = relatedDates.endDate, 
				StartDate = relatedDates.startDate, 
				EndDate = relatedDates.endDate, 
				Due_Date__c = relatedDates.dueDate, 
				Autoscheduled__c = true, 
				Job_Product_Code__c = atj.Customer_Product_Code__c
			);

			if (atj.Patient_Treatment__r.Account__r.IsPersonAccount == true){
				newWorkOrder.ContactId = atj.Patient_Treatment__r.Account__r.PersonContactId;
			}

			if(atj.Contract_Treatment_Job__r.Contract_Framework__r.Customer_Request_Code__c != null) {
                newWorkOrder.Billing_Reference__c = atj.Contract_Treatment_Job__r.Contract_Framework__r.Customer_Request_Code__c;
            }
            else {
                newWorkOrder.Billing_Reference__c = atj.Contract_Treatment_Job__r.Contract_Framework__r.Customer__r.Billing_Reference__c;
            }

			if(atj.Contract_Treatment_Job__r.Contract_Framework__r.Customer_Purchase_Order_Number__c != null) {
				newWorkOrder.Customer_Purchase_Order_Number__c = atj.Contract_Treatment_Job__r.Contract_Framework__r.Customer_Purchase_Order_Number__c;
			}
			else {
				newWorkOrder.Customer_Purchase_Order_Number__c = atj.Contract_Treatment_Job__r.Contract_Framework__r.Customer__r.Customer_Purchase_Order_Number__c;
			}

			if(atj.Contract_Treatment_Job__r.Contract_Framework__r.Customer_Purchase_Order_Date__c != null) {
				newWorkOrder.Customer_Purchase_Order_Date__c = atj.Contract_Treatment_Job__r.Contract_Framework__r.Customer_Purchase_Order_Date__c;
			}
			else {
				newWorkOrder.Customer_Purchase_Order_Date__c = atj.Contract_Treatment_Job__r.Contract_Framework__r.Customer__r.Customer_Purchase_Order_Date__c;
			}

			// Fields from the closed WorkOrder

			if(closedWO != null && closedTask == null) {
				newWorkOrder.LocationId = closedWO.LocationId; 
				newWorkOrder.City = closedWO.City; 
				newWorkOrder.Country = closedWO.Country; 
				newWorkOrder.CountryCode = closedWO.CountryCode; 
				newWorkOrder.Latitude = closedWO.Latitude; 
				newWorkOrder.Longitude = closedWO.Longitude; 
				newWorkOrder.PostalCode = closedWO.PostalCode; 
				newWorkOrder.State = closedWO.State; 
				newWorkOrder.StateCode = closedWO.StateCode; 
				newWorkOrder.Street = closedWO.Street;
			}

			// Fields from relatedASO

			if (relatedASO != null){
				newWorkOrder.SalesOrganization__c = relatedASO.Sales_Organization__r.Code__c;
				newWorkOrder.Division__c = relatedASO.Division__c;
				newWorkOrder.Distribution_Channel__c = relatedASO.Distribution_Channel__c;
				newWorkOrder.Sales_Group__c = relatedASO.Sales_Group__c;
				newWorkOrder.Sales_Office__c = relatedASO.Sales_Office__c;
			}

			toInsert.add(newWorkOrder);

			if (firstCase.Start_Date__c == null/* || firstCase.Start_Date__c > newWorkOrder.StartDate*/){
				firstCase.Start_Date__c = newWorkOrder.StartDate;
				firstCase.Next_Activity_Date__c = firstCase.Start_Date__c;
			}

			// Autoscheduling

			if (atj.Frequency__c != null){
				WorkOrder startingWorkOrder = newWorkOrder;
				
				// Day Autoscheduling
				if (atj.Frequency_Unit_of_measure__c == 'Day'){
					List<WorkOrder> newWorkOrders = ATMainComponentService.autoscheduleWorkOrders(atj, startingWorkOrder, relatedSLA, 365, remainingCases, bh, true);
					for (WorkOrder wo : newWorkOrders){
						toInsert.add(wo);
					}
				}
				// Week Autoscheduling
				else if (atj.Frequency_Unit_of_measure__c == 'Week'){
					List<WorkOrder> newWorkOrders = ATMainComponentService.autoscheduleWorkOrders(atj, startingWorkOrder, relatedSLA, 52, remainingCases, bh, true);
					for (WorkOrder wo : newWorkOrders){
						toInsert.add(wo);
					}
				}
				// Month Autoscheduling
				else if (atj.Frequency_Unit_of_measure__c == 'Month'){
					List<WorkOrder> newWorkOrders = ATMainComponentService.autoscheduleWorkOrders(atj, startingWorkOrder, relatedSLA, 12, remainingCases, bh, true);
					for (WorkOrder wo : newWorkOrders){
						toInsert.add(wo);
					}
				}
				// Year Autoscheduling
				else if (atj.Frequency_Unit_of_measure__c == 'Year'){
					List<WorkOrder> newWorkOrders = ATMainComponentService.autoscheduleWorkOrders(atj, startingWorkOrder, relatedSLA, 1, remainingCases, bh, true);
					for (WorkOrder wo : newWorkOrders){
						toInsert.add(wo);
					}
				}
			}
		}
		return toInsert;
	}

	public static void updateEntitlementId(List<WorkOrder> workOrders){
		System.debug('Updating EntitlementId...');

		List<String> accountTreatmentQueryFields = new List<String>{'RecordType.DeveloperName', 'Business_Line__c', 
		'Treatment_Type__c'};
		List<String> entitlementQueryFields = new List<String>{'Id', 'Treatment_Type__c'};

		List<Id> accountTreatmentIds = new List<Id>();
		List<Account_Treatment__c> accountTreatments = new List<Account_Treatment__c>();
		List<WorkOrder> therapyWorkOrders = new List<WorkOrder>();
		List<WorkOrder> otherWorkOrders = new List<WorkOrder>();
		List<Entitlement> entitlementsForBusinessLines = new List<Entitlement>();
		List<Entitlement> entitlementsForNonTherapyWOs = new List<Entitlement>();
		List<String> therapyBusinessLines = new List<String>();
		List<String> therapyTreatmentTypes = new List<String>();

		Map<Id, Account_Treatment__c> accountTreatmentMap = new Map<Id, Account_Treatment__c>();

		for(WorkOrder wo : workOrders) {
			accountTreatmentIds.add(wo.Account_Treatment__c);
		}

		if(!accountTreatmentIds.isEmpty()) {
			accountTreatments = AccountTreatmentDAO.getAccountTreatmentsFromIds(accountTreatmentQueryFields, accountTreatmentIds);

			for(Account_Treatment__c at : accountTreatments) {
				accountTreatmentMap.put(at.Id, at);
			}

			for(WorkOrder wo : workOrders) {
				Account_Treatment__c relatedAccountTreatment = accountTreatmentMap.get(wo.Account_Treatment__c);

				if(relatedAccountTreatment != null) {
					if(relatedAccountTreatment.RecordType.DeveloperName == 'AccountTreatment_Therapy') {
						therapyWorkOrders.add(wo);
					}
					else {
						otherWorkOrders.add(wo);
					}
				}
				else {
					otherWorkOrders.add(wo);
				}
			}
		}

		// Therapy WorkOrders

		if(!therapyWorkOrders.isEmpty()) {
			for(WorkOrder wo : therapyWorkOrders) {
				Account_Treatment__c relatedAccountTreatment = accountTreatmentMap.get(wo.Account_Treatment__c);

				if(relatedAccountTreatment != null && relatedAccountTreatment.Business_Line__c != null && relatedAccountTreatment.Treatment_Type__c != null) {
					therapyBusinessLines.add(relatedAccountTreatment.Business_Line__c);
					therapyTreatmentTypes.add(relatedAccountTreatment.Treatment_Type__c);
				}
			}

			if(!therapyBusinessLines.isEmpty()) {
				entitlementsForBusinessLines = EntitlementDAO.getEntitlementsFromBusinessLines(entitlementQueryFields, therapyBusinessLines);

				if(!entitlementsForBusinessLines.isEmpty()) {
					for(WorkOrder wo : therapyWorkOrders) {
						Account_Treatment__c relatedAccountTreatment = accountTreatmentMap.get(wo.Account_Treatment__c);
						Entitlement relatedEntitlement;

						if(relatedAccountTreatment != null) {
							for(Entitlement e : entitlementsForBusinessLines) {
								if((e.Treatment_Type__c).contains(relatedAccountTreatment.Treatment_Type__c)) {
									relatedEntitlement = e;
									break;
								}
							}

							if(relatedEntitlement != null) {
								wo.EntitlementId = relatedEntitlement.Id;
							}
						}
					}
				}
			}
		}

		// Other WorkOrders (same Entitlement for each one)

		if(!otherWorkOrders.isEmpty()) {
			entitlementsForNonTherapyWOs = EntitlementDAO.getEntitlementForNonTherapyWOs(entitlementQueryFields);

			if(!entitlementsForNonTherapyWOs.isEmpty()) {
				Entitlement relatedEntitlement = entitlementsForNonTherapyWOs[0];

				for(WorkOrder wo : otherWorkOrders) {
					wo.EntitlementId = relatedEntitlement.Id;
				}
			}
		}
	}

	public static void updateEntitlementIdWelcomeModelRemoteCall(List<WorkOrder> workOrders, String deliveryType) {
		System.debug('Updating EntitlementId Welcome Model...');

		List<String> serviceTerritoryQueryFields = new List<String>{'OperatingHoursId'};
		List<String> entitlementQueryFields = new List<String>{'Id', 'SvcApptBookingWindowsId'};
		List<Id> serviceTerritoryIds = new List<Id>();
		List<Id> operatingHoursIds = new List<Id>();

		Map<Id, Entitlement> operatingHoursIdToEntitlementMap = new Map<Id, Entitlement>();
		Map<Id, ServiceTerritory> serviceTerritoryMap = new Map<Id, ServiceTerritory>();

		if(!workOrders.isEmpty()) {
			for(WorkOrder wo : workOrders) {
				if(wo.ServiceTerritoryId != null) {
					System.debug('wo.ServiceTerritoryId: ' + wo.ServiceTerritoryId);

					serviceTerritoryIds.add(wo.ServiceTerritoryId);
				} else{
					wo.EntitlementId = null;
				}
			}

			if(!serviceTerritoryIds.isEmpty()) {
				List<ServiceTerritory> allServiceTerritories = ServiceTerritoryDAO.getServiceTerritoriesFromIds(serviceTerritoryQueryFields, serviceTerritoryIds);
				System.debug('AllServiceTerritories: ' + allServiceTerritories);

				if(allServiceTerritories != null) {
					for (ServiceTerritory st : allServiceTerritories){
						System.debug('OperatingHours: ' + st.OperatingHoursId);

						operatingHoursIds.add(st.OperatingHoursId);
						serviceTerritoryMap.put(st.Id, st);
					}

					if(!operatingHoursIds.isEmpty()) {
						List<Entitlement> allRelatedEntitlements = EntitlementDAO.getEntitlementsFromSvcApptBookingWindowsId(
							entitlementQueryFields, 
							operatingHoursIds, 
							deliveryType
						);
						System.debug('AllRelatedEntitlements: ' + allRelatedEntitlements);

						if(allRelatedEntitlements != null) {
							for(Entitlement e : allRelatedEntitlements) {
								System.debug('SvcApptBookingWindowsId: ' + e.SvcApptBookingWindowsId);

								operatingHoursIdToEntitlementMap.put(e.SvcApptBookingWindowsId, e);
							}

							// For each WO, getting the related ST and the Entitlement related to the ST; then updating EntitlementId

							if (!operatingHoursIdToEntitlementMap.isEmpty()){
								for (WorkOrder wo : workOrders){
									ServiceTerritory relatedServiceTerritory = serviceTerritoryMap.get(wo.ServiceTerritoryId);
									if (relatedServiceTerritory != null && relatedServiceTerritory.OperatingHoursId != null){
										Entitlement relatedEntitlement = operatingHoursIdToEntitlementMap.get(relatedServiceTerritory.OperatingHoursId);
										System.debug('RelatedServiceTerritory: ' + relatedServiceTerritory);
										System.debug('RelatedEntitlement: ' + relatedEntitlement);
										if (relatedEntitlement != null){
											wo.EntitlementId = relatedEntitlement.Id;
										}
									}
								}
							}
						}
					}
				}
			}
		}
	}

	public static void updateAddressFromST(List<WorkOrder> workOrders) {
		List<String> serviceTerritoryQueryFields = new List<String>{'Street', 'City', 'PostalCode', 'CountryCode', 'StateCode'};

		List<String> serviceTerritoryIds = new List<String>();

		Map<String, ServiceTerritory> serviceTerritoryMap = new Map<String, ServiceTerritory>();

		for(WorkOrder wo : workOrders) {
			serviceTerritoryIds.add(wo.ServiceTerritoryId);
		}

		if(!serviceTerritoryIds.isEmpty()) {
			List<ServiceTerritory> serviceTerritories = ServiceTerritoryDAO.getServiceTerritoriesFromIds(serviceTerritoryQueryFields, serviceTerritoryIds);

			if(serviceTerritories != null && !serviceTerritories.isEmpty()) {
				for(ServiceTerritory st : serviceTerritories) {
					serviceTerritoryMap.put(st.Id, st);
				}

				for(WorkOrder wo : workOrders) {
					ServiceTerritory relatedServiceTerritory = serviceTerritoryMap.get(wo.ServiceTerritoryId);

					if(relatedServiceTerritory != null) {
						wo.Street = relatedServiceTerritory.Street;
						wo.City = relatedServiceTerritory.City;
						wo.PostalCode = relatedServiceTerritory.PostalCode;
						wo.StateCode = relatedServiceTerritory.StateCode;
						wo.CountryCode = relatedServiceTerritory.CountryCode;

						wo.Check_Service_Territory__c = true;
					}
				}
			}
		}
	}

	public static void updateOrderExternalId(List<WorkOrder> workOrders){
		List<WorkOrder> toUpdate = new List<WorkOrder>();
		for (WorkOrder wo : workOrders){
			if (wo.OrderExternalId__c == null){
				WorkOrder tmp = new WorkOrder();
				tmp.Id = wo.Id;
				tmp.OrderExternalId__c = wo.WorkOrderNumber;
				toUpdate.add(tmp);
			}
		}
		if (!toUpdate.isEmpty()){
			update toUpdate;
		}
	}

	public static void updateOrderHK(List<String> workOrderIds, Map<Id, WorkOrder> oldMap, Boolean isDelete, Boolean checkDifferences){
		System.debug('----- updateOrderHK -----');

		List<String> workOrderQueryFields = new List<String>{'RecordTypeId'};
		List<String> orderHKQueryFields = new List<String>(OrderHK__c.SObjectType.getDescribe().fields.getMap().keySet());
		//List<String> workOrderIds = new List<String>();
		List<OrderHK__c> orderHKs = new List<OrderHK__c>();
		List<OrderHK__c> toUpsert = new List<OrderHK__c>();
		List<WorkOrder> workOrders = new List<WorkOrder>();
		RecordType CPAPSchool;

		Map<String, OrderHK__c> orderHKMap = new Map<String, OrderHK__c>();

		List<ObjectMapping__mdt> fieldMappings = [SELECT Source_Field__c, Target_Field__c, isCheckBox__c, Source_Object__c, Target_Object__c
		                                          FROM ObjectMapping__mdt
												  WHERE Source_Object__r.DeveloperName = 'WorkOrder' AND Target_Object__r.DeveloperName = 'OrderHK'];

		System.debug('----- fieldMappings: ' + fieldMappings);
		
		List<RecordType> CPAPSchoolList = RecordTypeDAO.getRecordTypesFromDeveloperNames(new List<String>{'Id'}, new List<String>{'WorkOrder_CPAPSchool'});

		if(!CPAPSchoolList.isEmpty()) {
			CPAPSchool = CPAPSchoolList[0];
		}

		if(fieldMappings != null) {
			for(ObjectMapping__mdt mapping : fieldMappings) {
				workOrderQueryFields.add(mapping.Source_Field__c);
			}
		}

		orderHKs = OrderHKDAO.getOrderHKbyworkorderId(orderHKQueryFields, workOrderIds);
		workOrders = WorkOrderDAO.getWorkOrdersFromIds(workOrderQueryFields, workOrderIds);

		if(orderHKs != null) {
			if(!orderHKs.isEmpty()) {
				for(OrderHK__c orderHK : orderHKs) {
					orderHKMap.put(orderHK.WorkOrder__c, orderHK);
				}
			}

			for(WorkOrder wo : workOrders) {
				OrderHK__c relatedOrderHK = orderHKMap.get(wo.Id);

				if(relatedOrderHK != null) {
					Boolean upsertThisRecord = false;

					for(ObjectMapping__mdt fieldMapping : fieldMappings) {
						if(checkDifferences && oldMap != null) {
							if(wo.get(fieldMapping.Source_Field__c) != oldMap.get(wo.Id).get(fieldMapping.Source_Field__c)) {
								System.debug('Updating an OrderHK field...');
								relatedOrderHK.put(fieldMapping.Target_Field__c, wo.get(fieldMapping.Source_Field__c));

								if(upsertThisRecord == false) {
									upsertThisRecord = true;
								}
							}
						}
						else {
							System.debug('Updating an OrderHK field...');
							relatedOrderHK.put(fieldMapping.Target_Field__c, wo.get(fieldMapping.Source_Field__c));

							if(upsertThisRecord == false) {
								upsertThisRecord = true;
							}
						}
					}

					if(isDelete) {
						relatedOrderHK.To_Be_Deleted__c = true;
					}

					if(upsertThisRecord) {
						if(relatedOrderHK.OrderExternalId__c != null) {
							toUpsert.add(relatedOrderHK);
							System.debug('UPDATING OrderHK ' + relatedOrderHK.Id);
						}
					}
				}
				else {
					if(wo.RecordTypeId != CPAPSchool.Id) {
						OrderHK__c newOrderHK = new OrderHK__c();

						for(ObjectMapping__mdt fieldMapping : fieldMappings) {
							newOrderHK.put(fieldMapping.Target_Field__c, wo.get(fieldMapping.Source_Field__c));

							System.debug('--- targetField: ' + fieldMapping.Target_Field__c);
							System.debug('--- sourceField: ' + wo.get(fieldMapping.Source_Field__c));
						}

						if(newOrderHK.OrderExternalId__c != null) {
							toUpsert.add(newOrderHK);
						}

						System.debug('CREATING new OrderHK');
						System.debug(newOrderHK);
					}
				}
			}
		}

		if(!toUpsert.isEmpty()) {
			List<Database.UpsertResult> results = Database.upsert(toUpsert, OrderHK__c.Fields.OrderExternalId__c, false);

			if(results != null) {
				List<Error_Log_Event__e> errorLogEvents = new List<Error_Log_Event__e>();

				for(Database.UpsertResult result : results) {
					System.debug('OrderHK creation success: ' + result.isSuccess());

					if(!result.isSuccess()) {
						Database.Error[] errors = result.getErrors();

						if(errors != null) {
							for(Database.Error error : errors) {
								Error_Log_Event__e event = ErrorLogEventHandler.createEvent(
									'WorkOrderService', 
									'updateOrderHK', 
									'ERROR', 
									error.getMessage(), 
									'OrderHK upsert error'
								);
								errorLogEvents.add(event);
							}
						}
					}
				}

				if(!errorLogEvents.isEmpty()) {
					List<Database.SaveResult> publishResults = EventBus.publish(errorLogEvents);
				}
			}
		}
	}

	public static void setPaymentFields(List<WorkOrder> workOrders){
		List<String> contractFrameworkQueryFields = new List<String>{'PaymentMethod__c', 'Payment_Condition__c'};

		List<Id> contractFrameworkIds = new List<Id>();
		List<Contract_Framework__c> contractFrameworks = new List<Contract_Framework__c>();

		Map<Id, Contract_Framework__c> contractFrameworkMap = new Map<Id, Contract_Framework__c>();

		for (WorkOrder wo : workOrders){
			contractFrameworkIds.add(wo.Contract_Framework__c);
		}

		contractFrameworks = ContractFrameworkDAO.getCFsFromIds(contractFrameworkQueryFields, contractFrameworkIds);

		for (Contract_Framework__c cf : contractFrameworks){
			contractFrameworkMap.put(cf.Id, cf);
		}

		for (WorkOrder wo : workOrders){
			Contract_Framework__c relatedCF = contractFrameworkMap.get(wo.Contract_Framework__c);

			if (wo.PaymentMethod__c == null){
				wo.PaymentMethod__c = relatedCF.PaymentMethod__c;
			}
			if (wo.PaymentCondition__c == null){
				wo.PaymentCondition__c = relatedCF.Payment_Condition__c;
			}
		}
	}

	public static List<WorkOrder> setPayerFields(List<WorkOrder> workOrders, String operationType) {
        System.debug('----- setPayerFields -----');

        List<String> contractFrameworkQueryFields = new List<String>{'Customer__c'};
        List<String> ATAPQueryFields = new List<String>{'Payer__c', 'Account_Treatment_Address__r.Location__c', 'Account_Treatment__c'};
        List<String> ASOQueryFields = new List<String>{'Account__c', 'Account_Bill_To__c', 'Sales_Organization__c'};

		List<WorkOrder> toSetPayerFields = new List<WorkOrder>();
        List<WorkOrder> withAccountTreatment = new List<WorkOrder>();
        List<WorkOrder> withoutAccountTreatment = new List<WorkOrder>();
		List<WorkOrder> toUpdate = new List<WorkOrder>();
        List<Contract_Framework__c> relatedContractFrameworks = new List<Contract_Framework__c>();
        List<Account_Treatment_Address_Payer__c> allRelatedATAPs = new List<Account_Treatment_Address_Payer__c>();
        List<Account_Sales_Organization__c> relatedASOs = new List<Account_Sales_Organization__c>();
        List<Account_Sales_Organization__c> ASOsRelatedToSalesOrgs = new List<Account_Sales_Organization__c>();
        List<String> relatedASOIds = new List<String>();
        List<String> relatedContractFrameworkIds = new List<String>();
        List<String> relatedAccountTreatmentIds = new List<String>();
        List<String> relatedLocationIds = new List<String>();
        List<String> salesOrganizationIds = new List<String>();
		List<String> payerIds = new List<String>();

        Map<String, Contract_Framework__c> contractFrameworkMap = new Map<String, Contract_Framework__c>();
        Map<String, Account_Treatment_Address_Payer__c> ATAPMap = new Map<String, Account_Treatment_Address_Payer__c>();
        Map<String, List<Account_Partner_Function__c>> ASOToAPFsMap = new Map<String, List<Account_Partner_Function__c>>();
        Map<String, Account_Sales_Organization__c> ASOMap = new Map<String, Account_Sales_Organization__c>();

		for(WorkOrder wo : workOrders) {
			if(operationType == 'BEFORE_INSERT') {
				if(wo.IsEmergency__c == false && (wo.Account_Sold_To__c == null || wo.Account_BillTo__c == null || wo.Payer__c == null)) {
					toSetPayerFields.add(wo);
				}
			}
			else {
				if(wo.IsEmergency__c == false) {
					toSetPayerFields.add(wo);
				}
			}
		}

		if(!toSetPayerFields.isEmpty()) {
			for(WorkOrder wo : workOrders) {
                if(wo.Account_Sales_Organization__c != null) {
                    relatedASOIds.add(wo.Account_Sales_Organization__c);
                }

				if(wo.Payer__c != null) {
					payerIds.add(wo.Payer__c);
				}

                if(wo.Account_Treatment__c != null && wo.Contract_Framework__c != null) {
                    withAccountTreatment.add(wo);

					if(operationType == 'BEFORE_INSERT') {
						if(wo.Payer__c == null) {
							relatedAccountTreatmentIds.add(wo.Account_Treatment__c);

							if(wo.LocationId != null) {
								relatedLocationIds.add(wo.LocationId);
							}
						}
					}
					else {
						relatedAccountTreatmentIds.add(wo.Account_Treatment__c);

						if(wo.LocationId != null) {
							relatedLocationIds.add(wo.LocationId);
						}
					}

					if(operationType == 'BEFORE_INSERT') {
						if(wo.Account_Sold_To__c == null) {
							relatedContractFrameworkIds.add(wo.Contract_Framework__c);
						}
					}
					else {
						relatedContractFrameworkIds.add(wo.Contract_Framework__c);
					}
                }
                else if(wo.Account_Treatment__c == null && wo.Contract_Framework__c == null) {
                    withoutAccountTreatment.add(wo);
                }
            }
		}

        if(!relatedASOIds.isEmpty()) {
            relatedASOs = [SELECT Sales_Organization__c, (SELECT Account__c, Partner_Function__c FROM Account_Partner_Functions__r) 
                           FROM Account_Sales_Organization__c WHERE Id IN: relatedASOIds];
            
            if(!relatedASOs.isEmpty()) {
                for(Account_Sales_Organization__c aso : relatedASOs) {
                    ASOMap.put(aso.Id, aso);

					if(aso.Sales_Organization__c != null) {
                    	salesOrganizationIds.add(aso.Sales_Organization__c);
					}

                    if(aso.Account_Partner_Functions__r != null && !aso.Account_Partner_Functions__r.isEmpty()) {
                        ASOToAPFsMap.put(aso.Id, aso.Account_Partner_Functions__r);
                    }

					if(!salesOrganizationIds.isEmpty() && !payerIds.isEmpty()) {
                    	ASOsRelatedToSalesOrgs = AccountSalesOrganizationDAO.getASOsFromSOsAndAccounts(ASOQueryFields, salesOrganizationIds, payerIds);
					}

                    if(!ASOsRelatedToSalesOrgs.isEmpty()) {
                        for(Account_Sales_Organization__c salesOrgASO : ASOsRelatedToSalesOrgs) {
                            ASOMap.put(String.valueOf(salesOrgASO.Account__c) + String.valueOf(salesOrgASO.Sales_Organization__c), salesOrgASO);
                        }
                    }
                }
            }
        }

        // With Account Treatment

        if(!withAccountTreatment.isEmpty()) {
            if(!relatedContractFrameworkIds.isEmpty()) {
                relatedContractFrameworks = ContractFrameworkDAO.getCFsFromIds(contractFrameworkQueryFields, relatedContractFrameworkIds);

                if(!relatedContractFrameworks.isEmpty()) {
                    for(Contract_Framework__c cf : relatedContractFrameworks) {
                        contractFrameworkMap.put(cf.Id, cf);
                    }
                }
            }

            if(!relatedAccountTreatmentIds.isEmpty() && !relatedLocationIds.isEmpty()) {
                allRelatedATAPs = AccountTreatmentAddressPayerDAO.getATAPsFromLocationAndAT(ATAPQueryFields, relatedAccountTreatmentIds, relatedLocationIds);

                if(!allRelatedATAPs.isEmpty()) {
                    for (Account_Treatment_Address_Payer__c atap : allRelatedATAPs){
                        ATAPMap.put(String.valueOf(atap.Account_Treatment__c) + String.valueOf(atap.Account_Treatment_Address__r.Location__c), atap);
                    }
                }
            }

            for(WorkOrder workOrder : withAccountTreatment) {
				if(operationType == 'BEFORE_INSERT') {
					if(workOrder.Account_Sold_To__c == null) {
						Contract_Framework__c relatedContractFramework = contractFrameworkMap.get(workOrder.Contract_Framework__c);

						if(relatedContractFramework != null && relatedContractFramework.Customer__c != null) {
							workOrder.Account_Sold_To__c = relatedContractFramework.Customer__c;
						}
					}
				}
				else {
					Contract_Framework__c relatedContractFramework = contractFrameworkMap.get(workOrder.Contract_Framework__c);

					if(relatedContractFramework != null && relatedContractFramework.Customer__c != null) {
						workOrder.Account_Sold_To__c = relatedContractFramework.Customer__c;
					}
				}

				if(operationType == 'BEFORE_INSERT') {
					if(workOrder.Payer__c == null) {
						Account_Treatment_Address_Payer__c relatedATAP = ATAPMap.get(String.valueOf(workOrder.Account_Treatment__c) + String.valueOf(workOrder.LocationId));

						if(relatedATAP != null && relatedATAP.Payer__c != null) {
							workOrder.Payer__c = relatedATAP.Payer__c;
						}
						else {
							List<Account_Partner_Function__c> relatedAPFs = ASOToAPFsMap.get(workOrder.Account_Sales_Organization__c);

							if(relatedAPFs != null && !relatedAPFs.isEmpty()) {
								for(Account_Partner_Function__c apf : relatedAPFs) {
									if(apf.Partner_Function__c == 'RG' && apf.Account__c != null) {
										workOrder.Payer__c = apf.Account__c;
										break;
									}
								}
							}
						}
					}
				}
				else {
					Account_Treatment_Address_Payer__c relatedATAP = ATAPMap.get(String.valueOf(workOrder.Account_Treatment__c) + String.valueOf(workOrder.LocationId));

					if(relatedATAP != null && relatedATAP.Payer__c != null) {
						workOrder.Payer__c = relatedATAP.Payer__c;
					}
					else {
						List<Account_Partner_Function__c> relatedAPFs = ASOToAPFsMap.get(workOrder.Account_Sales_Organization__c);

						if(relatedAPFs != null && !relatedAPFs.isEmpty()) {
							for(Account_Partner_Function__c apf : relatedAPFs) {
								if(apf.Partner_Function__c == 'RG' && apf.Account__c != null) {
									workOrder.Payer__c = apf.Account__c;
									break;
								}
							}
						}
					}
				}

				if(operationType == 'BEFORE_INSERT') {
					if(workOrder.Account_BillTo__c == null) {
						Account_Sales_Organization__c relatedASO = ASOMap.get(workOrder.Account_Sales_Organization__c);

						if(relatedASO != null) {
							Account_Sales_Organization__c payerASO = ASOMap.get(String.valueOf(workOrder.Payer__c) + String.valueOf(relatedASO.Sales_Organization__c));

							if(payerASO != null && payerASO.Account_Bill_To__c != null) {
								workOrder.Account_BillTo__c = payerASO.Account_Bill_To__c;
							}
							else {
								workOrder.Account_BillTo__c = workOrder.Payer__c;
							}
						}
					}
				}
				else {
					Account_Sales_Organization__c relatedASO = ASOMap.get(workOrder.Account_Sales_Organization__c);

					if(relatedASO != null) {
						Account_Sales_Organization__c payerASO = ASOMap.get(String.valueOf(workOrder.Payer__c) + String.valueOf(relatedASO.Sales_Organization__c));

						if(payerASO != null && payerASO.Account_Bill_To__c != null) {
							workOrder.Account_BillTo__c = payerASO.Account_Bill_To__c;
						}
						else {
							workOrder.Account_BillTo__c = workOrder.Payer__c;
						}
					}
				}

				toUpdate.add(workOrder);
            }
        }

        // Without Account Treatment

        if(!withoutAccountTreatment.isEmpty()) {
            for(WorkOrder workOrder : withoutAccountTreatment) {
                List<Account_Partner_Function__c> relatedAPFs = ASOToAPFsMap.get(workOrder.Account_Sales_Organization__c);

                if(relatedAPFs != null && !relatedAPFs.isEmpty()) {
                    if(workOrder.Account_Sold_To__c == null || workOrder.Payer__c == null) {
                        for(Account_Partner_Function__c apf : relatedAPFs) {
                            if(workOrder.Account_Sold_To__c == null) {
                                if(apf.Partner_Function__c == 'WE' && apf.Account__c != null) {
                                    workOrder.Account_Sold_To__c = apf.Account__c;
                                }
                            }
                            if(workOrder.Payer__c == null) {
                                if(apf.Partner_Function__c == 'RG' && apf.Account__c != null) {
                                    workOrder.Payer__c = apf.Account__c;
                                }
                            }
                        }
                    }
                }

                if(workOrder.Account_BillTo__c == null) {
                    Account_Sales_Organization__c relatedASO = ASOMap.get(workOrder.Account_Sales_Organization__c);

                    if(relatedASO != null) {
                        Account_Sales_Organization__c payerASO = ASOMap.get(String.valueOf(workOrder.Payer__c) + String.valueOf(relatedASO.Sales_Organization__c));

                        if(payerASO != null && payerASO.Account_Bill_To__c != null) {
                            workOrder.Account_BillTo__c = payerASO.Account_Bill_To__c;
                        }
                        else {
                            workOrder.Account_BillTo__c = workOrder.Payer__c;
                        }
                    }
                }

				toUpdate.add(workOrder);
            }
        }

		return toUpdate;
	}

	/* public static List<WorkOrder> checkForSetPayerFields(List<String> workOrderIds){
		System.debug('----- checkForSetPayerFields -----');
		System.debug('workOrderIds: ' + workOrderIds);

		List<String> workOrderQueryFields = new List<String>{'Account_Treatment__c', 'LocationId', 'Payer__c', 
		'Account_Sales_Organization__r.Sales_Organization__c', 'Account_Sold_To__c'};
		List<String> ATAPQueryFields = new List<String>{'Payer__c', 'Account_Treatment_Address__r.Location__c', 'Account_Treatment__c'};

		List<Id> locationIds = new List<Id>();
		List<Id> accountTreatmentIds = new List<Id>();
		List<WorkOrder> workOrdersToCheck = new List<WorkOrder>();
		List<Account_Treatment_Address_Payer__c> allATAPs = new List<Account_Treatment_Address_Payer__c>();

		Map<String, Account_Treatment_Address_Payer__c> ATAPMap = new Map<String, Account_Treatment_Address_Payer__c>();

		List<WorkOrder> workOrders = WorkOrderDAO.getWorkOrdersFromIds(workOrderQueryFields, workOrderIds);

		for (WorkOrder wo : workOrders){
			if (wo.Account_Treatment__c != null){
				accountTreatmentIds.add(wo.Account_Treatment__c);
			}
			if (wo.LocationId != null){
				locationIds.add(wo.LocationId);
			}
		}

		allATAPs = AccountTreatmentAddressPayerDAO.getATAPsFromLocationAndAT(ATAPQueryFields, accountTreatmentIds, locationIds);

		System.debug('allATAPs: ' + allATAPs);

		for (Account_Treatment_Address_Payer__c atap : allATAPs){
			ATAPMap.put(String.valueOf(atap.Account_Treatment__c)+String.valueOf(atap.Account_Treatment_Address__r.Location__c), atap);
		}

		System.debug('ATAPMap: ' + ATAPMap);

		for (WorkOrder wo : workOrders){

			Account_Treatment_Address_Payer__c relatedATAP = ATAPMap.get(String.valueOf(wo.Account_Treatment__c)+String.valueOf(wo.LocationId));

			System.debug('relatedATAP: ' + relatedATAP);

			if (relatedATAP != null){

				if (relatedATAP.Payer__c != wo.Payer__c){
					workOrdersToCheck.add(wo);

					System.debug('workOrder to check');
				}
			}
		}

		System.debug('workOrdersToCheck size: ' + workOrdersToCheck.size());

		return workOrdersToCheck;
	} */

	public static List<WorkOrder> updateServiceTerritoryWelcomeModel(List<WorkOrder> welcomeModels){
		System.debug('WelcomeModels: ' + welcomeModels.size());

		List<String> ATQueryFields = new List<String>{'RecordType.DeveloperName', 'Hospital__r.DefaultTrainingServiceTerritory__c'};
		List<String> serviceTerritoryQueryFields = new List<String>{'OperatingHoursId', 'Street', 'City', 'PostalCode', 'StateCode', 'CountryCode'};

		List<Id> welcomeModelATIds = new List<Id>();
		List<Id> accountTreatmentIds = new List<Id>();
		List<Id> serviceTerritoryIds = new List<Id>();
		List<ServiceTerritory> serviceTerritories = new List<ServiceTerritory>();
		List<WorkOrder> workOrdersToUpdate = new List<WorkOrder>();

		Map<Id, Account_Treatment__c> accountTreatmentMap = new Map<Id, Account_Treatment__c>();
		Map<Id, ServiceTerritory> serviceTerritoryMap = new Map<Id, ServiceTerritory>();

		for (WorkOrder wo : welcomeModels){
			if(wo.Account_Treatment__c != null) {
				welcomeModelATIds.add(wo.Account_Treatment__c);
			}
		}

		if(!welcomeModelATIds.isEmpty()) {
			List<Account_Treatment__c> relatedAccountTreatments = AccountTreatmentDAO.getAccountTreatmentsFromIds(ATQueryFields, welcomeModelATIds);

			if(relatedAccountTreatments != null) {
				for (Account_Treatment__c at : relatedAccountTreatments){
					accountTreatmentIds.add(at.Id);
					accountTreatmentMap.put(at.Id, at);

					// Filling the list of the Service Territories to query

					if (at.Hospital__r.DefaultTrainingServiceTerritory__c != null){
						System.debug('Hospital DefaultTrainingST: ' + at.Hospital__r.DefaultTrainingServiceTerritory__c);
						serviceTerritoryIds.add(at.Hospital__r.DefaultTrainingServiceTerritory__c);
					}
				}
			}

			// Getting all the ServiceTerritories and building a map

			if (!serviceTerritoryIds.isEmpty()){
				serviceTerritories = ServiceTerritoryDAO.getServiceTerritoriesFromIds(serviceTerritoryQueryFields, serviceTerritoryIds);
				if (!serviceTerritories.isEmpty()){
					for (ServiceTerritory st : serviceTerritories){
						serviceTerritoryMap.put(st.Id, st);
					}
				}
			}

			// For each Therapy Welcome Model WO, getting the related AT and ST, updating the fields from the ST and calling the method to update EntitlementId

			if (!welcomeModels.isEmpty() && serviceTerritoryMap != null && accountTreatmentMap != null){
				for (WorkOrder wo : welcomeModels){
					Account_Treatment__c relatedAccountTreatment = accountTreatmentMap.get(wo.Account_Treatment__c);

					if(relatedAccountTreatment != null) {
						ServiceTerritory relatedServiceTerritory = serviceTerritoryMap.get(relatedAccountTreatment.Hospital__r.DefaultTrainingServiceTerritory__c);
						if (relatedServiceTerritory != null){
							wo.ServiceTerritoryId = relatedServiceTerritory.Id;
							wo.Street = relatedServiceTerritory.Street;
							wo.City = relatedServiceTerritory.City;
							wo.PostalCode = relatedServiceTerritory.PostalCode;
							wo.StateCode = relatedServiceTerritory.StateCode;
							wo.CountryCode = relatedServiceTerritory.CountryCode;

							wo.Check_Service_Territory__c = true;

							workOrdersToUpdate.add(wo);
						}
					}
				}

				if(!workOrdersToUpdate.isEmpty()) {
					updateEntitlementIdWelcomeModelRemoteCall(workOrdersToUpdate, 'Welcome Model');
				}
			}
		}

		return workOrdersToUpdate;
	}

	public static void updateServiceTerritoryRemoteCall(List<WorkOrder> workOrders) {
		List<String> serviceTerritoryQueryFields = new List<String>{'Service_Territory_Code__c', 'Street', 'City', 'PostalCode', 'CountryCode', 'StateCode'};

		List<String> salesOrgs = new List<String>();
		List<String> serviceTerritoryCodes = new List<String>();
		List<WorkOrder> updatedWorkOrders = new List<WorkOrder>();

		Map<String, RemoteCall_ServiceTerritory__mdt> codeMappingMap = new Map<String, RemoteCall_ServiceTerritory__mdt>();
		Map<String, ServiceTerritory> serviceTerritoryMap = new Map<String, ServiceTerritory>();

		for(WorkOrder wo : workOrders) {
			salesOrgs.add(wo.SalesOrganization__c);
		}

		if(!salesOrgs.isEmpty()) {
			List<RemoteCall_ServiceTerritory__mdt> codeMappings = [SELECT Sales_Org__c, Code__c FROM RemoteCall_ServiceTerritory__mdt WHERE Sales_Org__c IN: salesOrgs];

			if(codeMappings != null && !codeMappings.isEmpty()) {
				for(RemoteCall_ServiceTerritory__mdt mapping : codeMappings) {
					codeMappingMap.put(mapping.Sales_Org__c, mapping);
				}

				for(WorkOrder wo : workOrders) {
					RemoteCall_ServiceTerritory__mdt relatedMapping = codeMappingMap.get(wo.SalesOrganization__c);

					if(relatedMapping != null) {
						serviceTerritoryCodes.add(relatedMapping.Code__c);
					}
				}

				if(!serviceTerritoryCodes.isEmpty()) {
					List<ServiceTerritory> serviceTerritories = ServiceTerritoryDAO.getServiceTerritoriesFromCodes(serviceTerritoryQueryFields, serviceTerritoryCodes);

					if(serviceTerritories != null && !serviceTerritories.isEmpty()) {
						for(ServiceTerritory st : serviceTerritories) {
							serviceTerritoryMap.put(st.Service_Territory_Code__c, st);
						}

						for(WorkOrder wo : workOrders) {
							RemoteCall_ServiceTerritory__mdt relatedMapping = codeMappingMap.get(wo.SalesOrganization__c);
							
							if(relatedMapping != null) {
								ServiceTerritory relatedServiceTerritory = serviceTerritoryMap.get(relatedMapping.Code__c);

								if(relatedServiceTerritory != null) {
									wo.ServiceTerritoryId = relatedServiceTerritory.Id;
									wo.Street = relatedServiceTerritory.Street;
									wo.City = relatedServiceTerritory.City;
									wo.PostalCode = relatedServiceTerritory.PostalCode;
									wo.StateCode = relatedServiceTerritory.StateCode;
									wo.CountryCode = relatedServiceTerritory.CountryCode;

									updatedWorkOrders.add(wo);
								}
							}
						}
					}
				}
			}
		}

		if(!updatedWorkOrders.isEmpty()) {
			updateEntitlementIdWelcomeModelRemoteCall(updatedWorkOrders, 'Remote Call');
		}
	}

	public static void updateNewNotWMAddress(List<WorkOrder> workOrders){
		System.debug('----- updateNewNotWMAddress -----');

		List<String> workOrderQueryFields = new List<String>{'Location.VisitorAddress.Street', 'Location.VisitorAddress.City', 'Location.VisitorAddress.PostalCode', 
		'Location.VisitorAddress.StateCode', 'Location.VisitorAddress.CountryCode', 'Street', 'City', 'PostalCode', 'StateCode', 'CountryCode', 'Check_Service_Territory__c'};

		List<String> workOrderIds = new List<String>();

		Map<String, WorkOrder> workOrderMap = new Map<String, WorkOrder>();

		for(WorkOrder wo : workOrders) {
			workOrderIds.add(wo.Id);
		}

		List<WorkOrder> queriedWorkOrders = WorkOrderDAO.getWorkOrdersFromIds(workOrderQueryFields, workOrderIds);

		for (WorkOrder wo : queriedWorkOrders){
			workOrderMap.put(wo.Id, wo);
		}

		for(WorkOrder wo : workOrders) {
			WorkOrder relatedQueriedWorkOrder = workOrderMap.get(wo.Id);

			if(relatedQueriedWorkOrder != null) {
				wo.Street = relatedQueriedWorkOrder.Location.VisitorAddress.Street;
				wo.City = relatedQueriedWorkOrder.Location.VisitorAddress.City;
				wo.PostalCode = relatedQueriedWorkOrder.Location.VisitorAddress.PostalCode;
				wo.StateCode = relatedQueriedWorkOrder.Location.VisitorAddress.StateCode;
				wo.CountryCode = relatedQueriedWorkOrder.Location.VisitorAddress.CountryCode;

				wo.Check_Service_Territory__c = true;
			}
		}

		if(!System.isBatch()) {
			Database.executeBatch(new ServiceTerritoryUpdateBatch(), 100);
		}
	}

	@AuraEnabled
	public static void retrySAPSync(List<Id> workOrderIds){
		List<String> workOrderQueryFields = new List<String>{'IsSyncSAP__c'};
		List<String> WOLIQueryFields = new List<String>();

		SObjectType WOLIType = Schema.getGlobalDescribe().get('WorkOrderLineItem');
		Map<String,Schema.SObjectField> WOLIFieldsMap = WOLIType.getDescribe().fields.getMap();

		for(String key : WOLIFieldsMap.keySet()) {
			WOLIQueryFields.add(String.valueOf(WOLIFieldsMap.get(key)));
		}

		List<WorkOrder> workOrders = WorkOrderDAO.getWorkOrdersFromIds(workOrderQueryFields, workOrderIds);
		List<WorkOrderLineItem> relatedWOLIs = WorkOrderLineItemDAO.getWOLIsFromWOs(WOLIQueryFields, workOrderIds);

		// Fake updates to force Heroku Sync

		/* List<Database.SaveResult> WOResults = Database.update(workOrders);
		List<Database.SaveResult> WOLIResults = Database.update(relatedWOLIs);
 */
		// Then real update to set WOs to Pending

		for (WorkOrder wo : workOrders){
			wo.IsSyncSAP__c = 'Pending';
		}

		List<Database.SaveResult> realWOResults = Database.update(workOrders);

		/** 
		 * updateOrderHK would be called from the Trigger too, but I need to call it from here with oldMap = null to force it to fake update the record anyway, 
		 * even if no field has changed. Otherwise, it would see (via oldMap) that no field has changed and it would not perform the upsert (that filter is 
		 * necessary to prevent unnecessary fake updates anyway).
		 */ 

		updateOrderHK(workOrderIds, null, false, false);

		if(relatedWOLIs != null && !relatedWOLIs.isEmpty()) {
			WOLITriggerService.updateOrderLineItemHK(relatedWOLIs, false, false);
		}
	}

	public static List<SkillRequirement> getSkillRequirementsFromRelatedRecords(List<Id> relatedRecordIds) {
		System.debug('----- getSkillRequirementsFromRelatedRecords -----');
		List<String> skillRequirementQueryFields = new List<String>{'RelatedRecordId', 'SkillId', 'SkillLevel'};

		List<SkillRequirement> relatedSkillRequirements = SkillRequirementDAO.getSkillRequirementsFromRelatedRecordIds(skillRequirementQueryFields, relatedRecordIds);

		return relatedSkillRequirements;
	}

	public static List<WorkOrder> updateWOsFromWorkTypes(List<WorkOrder> workOrders) {
		System.debug('----- updateWOsFromWorkTypes -----');

		List<String> workTypeQueryFields = new List<String>{'EstimatedDuration', 'DurationType', 'ServiceReportTemplateId'};

		List<Id> workTypeIds = new List<Id>();
		List<WorkType> workTypes = new List<WorkType>();
		List<WorkOrder> toUpdate = new List<WorkOrder>();

		Map<Id, WorkType> workTypeMap = new Map<Id, WorkType>();

		for(WorkOrder wo : workOrders) {
			workTypeIds.add(wo.WorkTypeId);
		}

		workTypes = WorkTypeDAO.getWorkTypesFromIds(workTypeQueryFields, workTypeIds);

		if(!workTypes.isEmpty()) {
			for(WorkType wt : workTypes) {
				workTypeMap.put(wt.Id, wt);
			}

			for(WorkOrder wo : workOrders) {
				WorkType relatedWorkType = workTypeMap.get(wo.WorkTypeId);

				if(relatedWorkType != null) {
					WorkOrder tmp = new WorkOrder();

					tmp.Id = wo.Id;
					tmp.Duration = relatedWorkType.EstimatedDuration;
					tmp.DurationType = relatedWorkType.DurationType;
					tmp.ServiceReportTemplateId = relatedWorkType.ServiceReportTemplateId;

					toUpdate.add(tmp);
				}
			}
		}

		return toUpdate;
	}

	public static List<SkillRequirement> cloneWorkTypeSkillRequirementsOnWOs(List<WorkOrder> workOrders, Map<Id, List<SkillRequirement>> skillRequirementMap) {
		System.debug('----- cloneWorkTypeSkillRequirementsOnWOs -----');
		List<SkillRequirement> newSkillRequirements = new List<SkillRequirement>();

		for(WorkOrder wo : workOrders) {
			List<SkillRequirement> skillRequirementsRelatedToWorkType = skillRequirementMap.get(wo.WorkTypeId);

			if(skillRequirementsRelatedToWorkType != null && !skillRequirementsRelatedToWorkType.isEmpty()) {
				for(SkillRequirement sr : skillRequirementsRelatedToWorkType) {
					SkillRequirement newSkillRequirement = new SkillRequirement(
						RelatedRecordId = wo.Id,
						SkillId = sr.SkillId,
						SkillLevel = sr.SkillLevel
					);

					newSkillRequirements.add(newSkillRequirement);
				}
			}
		}

		return newSkillRequirements;
	}

	public static List<ServiceAppointment> updateServiceAppointments(List<Id> workOrderIds) {
		System.debug('----- updateServiceAppointments -----');
		List<String> workOrderQueryFields = new List<String>{'WorkType.EstimatedDuration', 'WorkType.DurationType'};
		List<String> serviceAppointmentQueryFields = new List<String>{'Duration', 'DurationType', 'ParentRecordId'};

		List<ServiceAppointment> toUpdate = new List<ServiceAppointment>();
		Map<Id, List<ServiceAppointment>> serviceAppointmentMap = new Map<Id, List<ServiceAppointment>>();

		List<WorkOrder> workOrders = WorkOrderDAO.getWorkOrdersFromIds(workOrderQueryFields, workOrderIds);
		List<ServiceAppointment> allRelatedServiceAppointments = ServiceAppointmentDAO.getNoneAndNewSAsFromParentIds(serviceAppointmentQueryFields, workOrderIds);

		if(!allRelatedServiceAppointments.isEmpty()) {
			for(ServiceAppointment sa : allRelatedServiceAppointments) {
				if(serviceAppointmentMap.get(sa.ParentRecordId) == null) {
					serviceAppointmentMap.put(sa.ParentRecordId, new List<ServiceAppointment>());
				}

				serviceAppointmentMap.get(sa.ParentRecordId).add(sa);
			}

			for(WorkOrder wo : workOrders) {
				List<ServiceAppointment> relatedServiceAppointments = serviceAppointmentMap.get(wo.Id);

				if(relatedServiceAppointments != null && !relatedServiceAppointments.isEmpty()) {
					for(ServiceAppointment sa : relatedServiceAppointments) {
						sa.Duration = wo.WorkType.EstimatedDuration;
						sa.DurationType = wo.WorkType.DurationType;

						toUpdate.add(sa);
					}
				}
			}
		}

		return toUpdate;
	}

	public static List<ServiceAppointment> cancelRelatedServiceAppointments(List<Id> workOrderIds) {
		List<String> serviceAppointmentQueryFields = new List<String>{'Status'};

		List<ServiceAppointment> relatedServiceAppointments = new List<ServiceAppointment>();
		List<ServiceAppointment> toUpdate = new List<ServiceAppointment>();

		relatedServiceAppointments = ServiceAppointmentDAO.getNoneAndNewSAsFromParentIds(serviceAppointmentQueryFields, workOrderIds);

		if(!relatedServiceAppointments.isEmpty()) {
			for(ServiceAppointment sa : relatedServiceAppointments) {
				sa.Status = 'Canceled';

				toUpdate.add(sa);
			}
		}

		return toUpdate;
	}

	public static void updateMaintenanceSRTemplateId(List<WorkOrder> workOrders) {
		List<String> skillRequirementQueryFields = new List<String>{'Id', 'SkillLevel', 'SkillId', 'SkillNumber'};

		List<WorkOrder> workOrdersToUpdate = new List<WorkOrder>();
		List<SkillRequirement> newSkillRequirements = new List<SkillRequirement>();
		List<WorkType> workTypeList = [SELECT ServiceReportTemplateId FROM WorkType WHERE Code__c = 'MAINT'];

		if(workTypeList != null && !workTypeList.isEmpty()) {
			WorkType maintenanceWorkType = workTypeList[0];

			if(workOrders != null && !workOrders.isEmpty()) {
				if(maintenanceWorkType != null) {
					List<SkillRequirement> relatedSkillRequirementList = SkillRequirementDAO.getSkillRequirementsFromRelatedRecordIds(
						skillRequirementQueryFields, 
						new List<String>{maintenanceWorkType.Id}
					);

					for(WorkOrder wo : workOrders) {
						if(wo.RecordType.DeveloperName == 'WorkOrder_Maintenance') {
							wo.ServiceReportTemplateId = maintenanceWorkType.ServiceReportTemplateId;

							workOrdersToUpdate.add(wo);

							if(relatedSkillRequirementList != null && !relatedSkillRequirementList.isEmpty()) {
								for(SkillRequirement sr : relatedSkillRequirementList) {
									SkillRequirement newSkillRequirement = sr.clone(false, true, false, false);
									newSkillRequirement.RelatedRecordId = wo.Id;

									newSkillRequirements.add(newSkillRequirement);
								}
							}
						}
					}
				}
			}
		}

		if(!workOrdersToUpdate.isEmpty()) {
			List<Database.SaveResult> results = Database.update(workOrdersToUpdate);
		}

		if(!newSkillRequirements.isEmpty()) {
			List<Database.SaveResult> results = Database.insert(newSkillRequirements);
		}
	}

	public static List<ServiceAppointment> updateRelatedSAsDates(List<WorkOrder> workOrders) {
		List<String> SAQueryFields = new List<String>{'EarliestStartTime', 'DueDate', 'ParentRecordId'};

		List<String> workOrderIds = new List<String>();
		List<ServiceAppointment> toUpdate = new List<ServiceAppointment>();

		Map<String, List<ServiceAppointment>> workOrderToSAsMap = new Map<String, List<ServiceAppointment>>();

		for(WorkOrder wo : workOrders) {
			workOrderIds.add(wo.Id);
		}

		List<ServiceAppointment> allRelatedSAs = ServiceAppointmentDAO.getNoneAndNewSAsFromParentIds(SAQueryFields, workOrderIds);

		if(allRelatedSAs != null && !allRelatedSAs.isEmpty()) {
			for(ServiceAppointment sa : allRelatedSAs) {
				if(workOrderToSAsMap.get(sa.ParentRecordId) == null) {
					workOrderToSAsMap.put(sa.ParentRecordId, new List<ServiceAppointment>());
				}

				workOrderToSAsMap.get(sa.ParentRecordId).add(sa);
			}
		}

		if(workOrderToSAsMap != null) {
			for(WorkOrder wo : workOrders) {
				List<ServiceAppointment> relatedServiceAppointments = workOrderToSAsMap.get(wo.Id);

				if(relatedServiceAppointments != null && !relatedServiceAppointments.isEmpty()) {
					for(ServiceAppointment sa : relatedServiceAppointments) {
						sa.EarliestStartTime = wo.StartDate;
						sa.DueDate = wo.EndDate;

						toUpdate.add(sa);
					}
				}
			}
		}

		return toUpdate;
	}

	public static List<WorkOrder> updateSchedulingPolicy(List<WorkOrder> workOrders) {
		List<String> serviceTerritoryQueryFields = new List<String>{'Scheduling_Policy__c'};

		List<String> serviceTerritoryIds = new List<String>();
		List<WorkOrder> toUpdate = new List<WorkOrder>();

		Map<String, ServiceTerritory> serviceTerritoryMap = new Map<String, ServiceTerritory>();

		for(WorkOrder wo : workOrders) {
			serviceTerritoryIds.add(wo.ServiceTerritoryId);
		}

		if(!serviceTerritoryIds.isEmpty()) {
			List<ServiceTerritory> serviceTerritories = ServiceTerritoryDAO.getServiceTerritoriesFromIds(serviceTerritoryQueryFields, serviceTerritoryIds);

			if(serviceTerritories != null && !serviceTerritories.isEmpty()) {
				for(ServiceTerritory st : serviceTerritories) {
					serviceTerritoryMap.put(st.Id, st);
				}

				for(WorkOrder wo : workOrders) {
					ServiceTerritory relatedServiceTerritory = serviceTerritoryMap.get(wo.ServiceTerritoryId);

					if(relatedServiceTerritory != null && relatedServiceTerritory.Scheduling_Policy__c != null) {
						WorkOrder tmp = new WorkOrder();

						tmp.Id = wo.Id;
						tmp.Scheduling_Policy__c = relatedServiceTerritory.Scheduling_Policy__c;

						toUpdate.add(tmp);
					}
				}
			}
		}

		return toUpdate;
	}

	public static List<WorkOrderLineItem> updateRelatedWOLIs(List<WorkOrder> workOrders) {
		List<String> workOrderQueryFields = new List<String>{'Delivery_Type__c', 'ServiceTerritory.Stock__c'};

		List<String> workOrderIds = new List<String>();
		List<String> stockWelcomeModelWOIds = new List<String>();
		List<WorkOrder> queriedWorkOrders = new List<WorkOrder>();
		List<WorkOrder> stockWelcomeModelWOs = new List<WorkOrder>();
		List<WorkOrderLineItem> relatedWOLIs = new List<WorkOrderLineItem>();
		List<WorkOrderLineItem> toUpdate = new List<WorkOrderLineItem>();

		for(WorkOrder wo : workOrders) {
			workOrderIds.add(wo.Id);
		}

		queriedWorkOrders = WorkOrderDAO.getWorkOrdersFromIds(workOrderQueryFields, workOrderIds);

		if(!queriedWorkOrders.isEmpty()) {
			for(WorkOrder wo : queriedWorkOrders) {
				if(wo.Delivery_Type__c == 'Welcome Model' && wo.ServiceTerritory.Stock__c == true) {
					stockWelcomeModelWOs.add(wo);
					stockWelcomeModelWOIds.add(wo.Id);
				}
			}
		}

		if(!stockWelcomeModelWOs.isEmpty()) {
			relatedWOLIs = [SELECT Plant__c, StorageLocation__c FROM WorkOrderLineItem 
						    WHERE WorkOrderId IN: stockWelcomeModelWOIds
							AND (Plant__c != null OR StorageLocation__c != null)];

			if(!relatedWOLIs.isEmpty()) {
				for(WorkOrderLineItem woli : relatedWOLIs) {
					woli.Plant__c = null;
					woli.StorageLocation__c = null;

					toUpdate.add(woli);
				}
			}
		}

		return toUpdate;
	}

	public static void updateTreatmentType(List<WorkOrder> workOrders) {
		//List<String> locationQueryFields = new List<String>{'VisitorAddress.CountryCode'};
		List<String> caseQueryFields = new List<String>{'Treatment__c'};

		//List<String> locationIds = new List<String>();
		List<String> caseIds = new List<String>();
		//List<Schema.Location> relatedLocations = new List<Schema.Location>();
		List<Case> relatedCases = new List<Case>();

		//Map<String, Schema.Location> locationMap = new Map<String, Schema.Location>();
		Map<String, Case> caseMap = new Map<String, Case>();

		for(WorkOrder wo : workOrders) {
			/* if(wo.LocationId != null) {
				locationIds.add(wo.LocationId);
			} */
			if(wo.CaseId != null) {
				caseIds.add(wo.CaseId);
			}
		}

		/* if(!locationIds.isEmpty()) {
			relatedLocations = LocationDAO.getLocationsFromIds(locationQueryFields, locationIds);

			if(!relatedLocations.isEmpty()) {
				for(Schema.Location l : relatedLocations) {
					locationmap.put(l.Id, l);
				}
			}
		} */

		if(!caseIds.isEmpty()) {
			relatedCases = CaseDAO.getCasesFromIds(caseQueryFields, caseIds);

			if(!relatedCases.isEmpty()) {
				for(Case c : relatedCases) {
					caseMap.put(c.Id, c);
				}
			}
		}

		for(WorkOrder wo : workOrders) {
			//Schema.Location relatedLocation;
			Case relatedCase;

			/* if(wo.LocationId != null) {
				relatedLocation = locationMap.get(wo.LocationId);
			} */

			if(wo.CaseId != null) {
				relatedCase = caseMap.get(wo.CaseId);
			}

			/* if(relatedLocation != null) {
				wo.CountryCode__c = relatedLocation.VisitorAddress.CountryCode;
			} */

			if(relatedCase != null) {
				wo.Treatment_Type__c = relatedCase.Treatment__c;
			}
		}
	}

	public static List<ServiceAppointment> updateRelatedSATreatmentTypeAndSO(List<WorkOrder> workOrders) {
		List<String> SAQueryFields = new List<String>{'ParentRecordId', 'TreatmentType__c', 'SalesOrganization__c'};

		List<String> workOrderIds = new List<String>();
		List<ServiceAppointment> allRelatedServiceAppointments = new List<ServiceAppointment>();

		Map<String, WorkOrder> workOrderMap = new Map<String, WorkOrder>();

		for(WorkOrder wo : workOrders) {
			workOrderIds.add(wo.Id);
			workOrderMap.put(wo.Id, wo);
		}

		allRelatedServiceAppointments = ServiceAppointmentDAO.getNoneAndNewSAsFromParentIds(SAQueryFields, workOrderIds);

		if(!allRelatedServiceAppointments.isEmpty()) {
			for(ServiceAppointment sa : allRelatedServiceAppointments) {
				WorkOrder relatedWorkOrder = workOrderMap.get(sa.ParentRecordId);

				if(relatedWorkOrder != null) {
					sa.TreatmentType__c = relatedWorkOrder.Treatment_Type__c;
					sa.SalesOrganization__c = relatedWorkOrder.SalesOrganization__c;
				}
			}
		}

		return allRelatedServiceAppointments;
	}

	public static void updateContactId(List<WorkOrder> workOrders) {
		List<String> accountQueryFields = new List<String>{'IsPersonAccount', 'PersonContactId'};

		List<String> accountIds = new List<String>();
		List<Account> relatedAccounts = new List<Account>();

		Map<String, Account> accountMap = new Map<String, Account>();

		for(WorkOrder wo : workOrders) {
			accountIds.add(wo.AccountId);
		}

		relatedAccounts = AccountDAO.getAccountIsSapSyncFromRecordIds(accountQueryFields, accountIds);

		if(!relatedAccounts.isEmpty()) {
			for(Account account : relatedAccounts) {
				accountMap.put(account.Id, account);
			}

			for(WorkOrder wo : workOrders) {
				Account relatedAccount = accountMap.get(wo.AccountId);

				if(relatedAccount != null && relatedAccount.IsPersonAccount == true) {
					wo.ContactId = relatedAccount.PersonContactId;
				}
			}
		}
	}
	
	public static void updateRelatedSADescription(Map<Id, WorkOrder> woUpdated) {
		List<String> SAQueryFields = new List<String>{'ParentRecordId', 'Description'};

		Set<Id> workOrderSetIds = new Set<Id>();
		List<Id> workOrderIds = new List<Id>();
		workOrderSetIds = woUpdated.keySet();
		workOrderIds.addAll(workOrderSetIds);
		List<ServiceAppointment> serviceAppointmentsToUpdate = new List<ServiceAppointment>();

		serviceAppointmentsToUpdate = ServiceAppointmentDAO.getAllSAsFromParentIds(SAQueryFields, workOrderIds);

		if(!serviceAppointmentsToUpdate.isEmpty()) {
			for(ServiceAppointment sa : serviceAppointmentsToUpdate) {
				WorkOrder relatedWorkOrder = woUpdated.get(sa.ParentRecordId);

				if(relatedWorkOrder != null) {
					sa.Description = relatedWorkOrder.Description;
				}
			}
		}

		List<Database.SaveResult> serviceAppointmentResults = Database.update(serviceAppointmentsToUpdate);
	}

	public static void moveMaterials(List<String> workOrderIds) {
		System.debug('----- moveMaterials -----');

		CanceledWorkOrdersMovement.moveMaterials(workOrderIds, null);
	}

	public static void updateRelatedCases(List<WorkOrder> workOrders) {
		List<String> caseQueryFields = new List<String>{'Status', 'OwnerId', 'Next_Activity_Date__c'};

		List<String> relatedCaseIds = new List<String>();
		List<Case> relatedCases = new List<Case>();

		AssignmentRule assignmentRule = [SELECT Id FROM AssignmentRule WHERE SobjectType = 'Case' and Active = true LIMIT 1];

		if(assignmentRule != null) {
			// Creating the DMLOptions for "Assign using active assignment rules" checkbox
			
			Database.DMLOptions DMLOptions = new Database.DMLOptions();
			DMLOptions.assignmentRuleHeader.assignmentRuleId = assignmentRule.Id;

			for(WorkOrder wo : workOrders) {
				relatedCaseIds.add(wo.CaseId);
			}

			relatedCases = CaseDAO.getCasesFromIds(caseQueryFields, relatedCaseIds);

			if(!relatedCases.isEmpty()) {
				for(Case c : relatedCases) {
					c.Status = 'Review';
					c.Next_Activity_Date__c = Date.today();

					c.setOptions(DMLOptions);
				}
			}
		}

		if(!relatedCases.isEmpty()) {
			List<Database.SaveResult> results = Database.update(relatedCases);
		}
	}

	public static void updateServiceAppointmentAddress(List<String> workOrderIds) {
		List<String> serviceAppointmentQueryFields = new List<String>{'ParentRecordId', 'Street', 'PostalCode', 'StateCode', 'CountryCode', 'City'};

		List<ServiceAppointment> relatedNoneServiceAppointments = ServiceAppointmentDAO.getNoneAndNewSAsFromParentIds(serviceAppointmentQueryFields, workOrderIds);

		if(relatedNoneServiceAppointments != null && !relatedNoneServiceAppointments.isEmpty()) {
			List<ServiceAppointment> toUpdate = ServiceAppointmentTriggerService.updateAddressFromWorkOrder(relatedNoneServiceAppointments);

			if(!toUpdate.isEmpty()) {
				List<Database.SaveResult> results = Database.update(toUpdate);
			}
		}
	}

	public static void updateAddressFromLocation(List<WorkOrder> workOrders) {
		List<String> locationQueryFields = new List<String>{'VisitorAddress.Street', 'VisitorAddress.City', 'VisitorAddress.PostalCode', 'VisitorAddress.StateCode', 
		'VisitorAddress.CountryCode'};

		List<WorkOrder> toUpdate = new List<WorkOrder>();
		List<String> locationIds = new List<String>();
		List<Schema.Location> locations = new List<Schema.Location>();

		Map<String, Schema.Location> locationMap = new Map<String, Schema.Location>();

		for(WorkOrder wo : workOrders) {
			locationIds.add(wo.LocationId);
		}

		if(!locationIds.isEmpty()) {
			locations = LocationDAO.getLocationsFromIds(locationQueryFields, locationIds);

			if(!locations.isEmpty()) {
				for(Schema.Location location : locations) {
					locationMap.put(location.Id, location);
				}
			}

			for(WorkOrder wo : workOrders) {
				Schema.Location relatedLocation = locationMap.get(wo.LocationId);

				if(relatedLocation != null) {
					WorkOrder tmp = new WorkOrder();

					tmp.Id = wo.Id;
					tmp.Street = relatedLocation.VisitorAddress.Street;
					tmp.City = relatedLocation.VisitorAddress.City;
					tmp.PostalCode = relatedLocation.VisitorAddress.PostalCode;
					tmp.StateCode = relatedLocation.VisitorAddress.StateCode;
					tmp.CountryCode = relatedLocation.VisitorAddress.CountryCode;

					toUpdate.add(tmp);
				}
			}
		}

		if(!toUpdate.isEmpty()) {
			List<Database.SaveResult> results = Database.update(toUpdate);
		}
	}

	public static void baseUnitBatchCodeCheck(List<String> workOrderIds) {
		List<String> WOLIQueryFields = new List<String>{'AssetId', 'Batch_Number__c', 'Asset.Product2Id', 'WorkOrderId'};

		List<String> refillAssetIds = new List<String>();
		List<String> refillAssetProductIds = new List<String>();
		List<WorkOrderLineItem> relatedBaseUnits = new List<WorkOrderLineItem>();
		List<WorkOrderLineItem> toUpdate = new List<WorkOrderLineItem>();

		Map<String, WorkOrderLineItem> WOLIMap = new Map<String, WorkOrderLineItem>();

		List<WorkOrderLineItem> relatedRefillWOLIs = WorkOrderLineItemDAO.getCompletedRefillWOLIsFromWOs(WOLIQueryFields, workOrderIds);

		if(relatedRefillWOLIs != null && !relatedRefillWOLIs.isEmpty()) {
			for(WorkOrderLineItem woli : relatedRefillWOLIs) {
				if(woli.AssetId != null) {
					refillAssetIds.add(woli.AssetId);
					WOLIMap.put(String.valueOf(woli.WorkOrderId) + String.valueOf(woli.AssetId), woli);
				}
				if(woli.Asset.Product2Id != null) {
					refillAssetProductIds.add(woli.Asset.Product2Id);
				}
			}

			if(!refillAssetIds.isEmpty() && !refillAssetProductIds.isEmpty()) {
				relatedBaseUnits = WorkOrderLineItemDAO.getCompletedBaseUnitWOLIsFromAssets(WOLIQueryFields, workOrderIds, refillAssetIds, refillAssetProductIds);

				// Updating the Completed Base Units that don't have Batch Number yet

				if(!relatedBaseUnits.isEmpty()) {
					for(WorkOrderLineItem woli : relatedBaseUnits) {
						WorkOrderLineItem relatedRefillWOLI = WOLIMap.get(String.valueOf(woli.WorkOrderId) + String.valueOf(woli.AssetId));

						if(relatedRefillWOLI != null) {
							woli.Batch_Number__c = relatedRefillWOLI.Batch_Number__c;

							toUpdate.add(woli);
						}
					}
				}
			}
		}

		if(!toUpdate.isEmpty()) {
			List<Database.SaveResult> results = Database.update(toUpdate);
		}
	}

	public static void closeRelatedServiceWOLI(List<Id> workOrderIds) {
		List<String> WOLIQueryFields = new List<String>{'Status', 'Product_Type__c','QuantityDelivered__c'};

		List<WorkOrderLineItem> toUpdate = new List<WorkOrderLineItem>();

		List<WorkOrderLineItem> relatedWOLI = WorkOrderLineItemDAO.getWOLIsFromWOs(WOLIQueryFields, workOrderIds);

		if(relatedWOLI != null && !relatedWOLI.isEmpty()) {
			for(WorkOrderLineItem woli : relatedWOLI) {
				if(woli.Status == 'New' && woli.Product_Type__c == 'ZSER') {
					woli.Status = 'Completed';
					woli.QuantityDelivered__c = 1;
					toUpdate.add(woli);
				}
			}
		}

		if(!toUpdate.isEmpty()) {
			List<Database.SaveResult> results = Database.update(toUpdate);
		}
	}

	public static void updateCaseStartDate(List<WorkOrder> updatedStartDateWOs) {
        List<String> taskQueryFields = new List<String>{'WhatId', 'ActivityDate', 'IsClosed'};
        List<String> workOrderQueryFields = new List<String>{'CaseId', 'StartDate', 'IsClosed'};

        List<String> updatedStartDateWOIds = new List<String>();
        List<String> caseIds = new List<String>();
        List<Task> allTasks = new List<Task>();
        List<WorkOrder> allOtherWOs = new List<WorkOrder>();
        List<Case> toUpdate = new List<Case>();

        Map<String, List<Task>> caseToRelatedTasksMap = new Map<String, List<Task>>();
        Map<String, List<WorkOrder>> caseToRelatedWOsMap = new Map<String, List<WorkOrder>>();

        for(WorkOrder wo : updatedStartDateWOs) {
            updatedStartDateWOIds.add(wo.Id);

            if(wo.CaseId != null) {
                caseIds.add(wo.CaseId);
            }
        }

        if(!updatedStartDateWOIds.isEmpty() && !caseIds.isEmpty()) {
            allTasks = TaskDAO.getTasksFromWhatIds(taskQueryFields, caseIds);
            allOtherWOs = WorkOrderDAO.getWOsFromCaseIdsExcluding(workOrderQueryFields, caseIds, updatedStartDateWOIds);

            if(!allTasks.isEmpty()) {
                for(Task t : allTasks) {
                    if(caseToRelatedTasksMap.get(t.WhatId) == null) {
                        caseToRelatedTasksMap.put(t.WhatId, new List<Task>());
                    }
                    caseToRelatedTasksMap.get(t.WhatId).add(t);
                }
            }
            if(!allOtherWOs.isEmpty()) {
                for(WorkOrder wo : allOtherWOs) {
                    if(caseToRelatedWOsMap.get(wo.CaseId) == null) {
                        caseToRelatedWOsMap.put(wo.CaseId, new List<WorkOrder>());
                    }
                    caseToRelatedWOsMap.get(wo.CaseId).add(wo);
                }
            }

            for(WorkOrder wo : updatedStartDateWOs) {
                Boolean hasClosedActivities = false;
                Datetime firstOtherActivityDate;
                List<Task> relatedTasks = caseToRelatedTasksMap.get(wo.CaseId);
                List<WorkOrder> relatedOtherWorkOrders = caseToRelatedWOsMap.get(wo.CaseId);

                // Checking if the related Case has closed activities. If so, I won't update its StartDate

                if(relatedTasks != null && !relatedTasks.isEmpty()) {
                    for(Task t : relatedTasks) {
                        if(t.IsClosed) {
                            hasClosedActivities = true;
                            break;
                        }
                    }
                }
                if(relatedOtherWorkOrders != null && !relatedOtherWorkOrders.isEmpty() && !hasClosedActivities) {
                    for(WorkOrder otherWO : relatedOtherWorkOrders) {
                        if(otherWO.IsClosed) {
                            hasClosedActivities = true;
                            break;
                        }
                    }
                }

                // Further checks only if the related Case has no closed activities

                if(!hasClosedActivities) {
                    Case relatedCase = new Case(
                        Id = wo.CaseId,
                        Start_Date__c = wo.StartDate
                    );
                        
                    if(relatedTasks != null && !relatedTasks.isEmpty()) {
                        firstOtherActivityDate = Datetime.newInstance(relatedTasks[0].ActivityDate, Time.newInstance(0, 0, 0, 0));
                    }
                    if(relatedOtherWorkOrders != null && !relatedOtherWorkOrders.isEmpty()) {
                        if(firstOtherActivityDate != null) {
                            if(relatedOtherWorkOrders[0].StartDate < firstOtherActivityDate) {
                                firstOtherActivityDate = relatedOtherWorkOrders[0].StartDate;
                            }
                        }
                        else {
                            firstOtherActivityDate = relatedOtherWorkOrders[0].StartDate;
                        }
                    }

                    // Setting the new StartDate if this Task will be the first activity

                    if(firstOtherActivityDate != null) {
                        if(wo.StartDate < firstOtherActivityDate) {
                            toUpdate.add(relatedCase);
                        }
                    }
                    else {
                        toUpdate.add(relatedCase);
                    }
                }
            }
        }

        if(!toUpdate.isEmpty()) {
            List<Database.SaveResult> results = Database.update(toUpdate, false);
        }
    }

	public static void setReviewFromATJ(List<WorkOrder> workOrders) {
		List<String> ATJQueryFields = new List<String>{'Back_Office_Review__c'};

		List<Id> ATJIds = new List<Id>();
		List<Account_Treatment_Job__c> relatedATJs = new List<Account_Treatment_Job__c>();

		Map<String, Account_Treatment_Job__c> ATJMap = new Map<String, Account_Treatment_Job__c>();

		for(WorkOrder wo : workOrders) {
			if(wo.Account_Treatment_Job__c != null) {
				ATJIds.add(wo.Account_Treatment_Job__c);
			}
		}

		if(!ATJIds.isEmpty()) {
			relatedATJs = AccountTreatmentJobDAO.getATJSFROMIds(ATJQueryFields, ATJIds);

			if(!relatedATJs.isEmpty()) {
				for(Account_Treatment_Job__c atj : relatedATJs) {
					ATJMap.put(atj.Id, atj);
				}

				for(WorkOrder wo : workOrders) {
					Account_Treatment_Job__c relatedATJ = ATJMap.get(wo.Account_Treatment_Job__c);

					if(relatedATJ != null && relatedATJ.Back_Office_Review__c == true) {
						wo.Review__c = true;
					} 
				}
			}
		}
	}
}