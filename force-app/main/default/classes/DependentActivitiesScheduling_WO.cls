global class DependentActivitiesScheduling_WO implements Database.Batchable<sObject>, Database.Stateful{
    global List<String> workOrderIds;

    // These variables will be overwritten every batch chunk, but it's ok since this batch will run only on one closed WO at a time (workOrderIds will have size 1)

    global Map<Id, Account_Treatment_Job__c> ATJMap = new Map<Id, Account_Treatment_Job__c>();
    global Map<Id, List<Account_Treatment_Job_Product__c>> jobToProductsMap = new Map<Id, List<Account_Treatment_Job_Product__c>>();
    global Map<Id, List<PricebookEntry>> pricebookIdToPEMap = new Map<Id, List<PricebookEntry>>();
	global List<WorkOrder> newWorkOrders = new List<WorkOrder>();
	global List<String> accountTreatmentIds = new List<String>();

    public Database.QueryLocator start(Database.BatchableContext bc) {
        List<String> queryFields = new List<String>{'EndDate', 'Account_Treatment_Job__c', 'LocationId', 'City', 'Country', 'CountryCode', 'Latitude', 'Longitude', 
        'PostalCode', 'State', 'StateCode', 'Street', 'Account_Treatment__c'};

        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
            query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM WorkOrder WHERE Id IN: workOrderIds';

        System.debug(query);
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<WorkOrder> workOrders) {
        System.debug('WorkOrderService, workOrders size: ' + workOrders.size());
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
		'Contract_Treatment_Job__r.Contract_Framework__r.Customer_Purchase_Order_Date__c', 
		'Contract_Treatment_Job__r.Contract_Framework__r.Customer__r.Customer_Purchase_Order_Number__c',
		'Contract_Treatment_Job__r.Contract_Framework__r.Customer_Purchase_Order_Number__c',  
		'Contract_Treatment_Job__r.Contract_Framework__r.Customer__r.Billing_Reference__c', 'Contract_Treatment_Job__r.Contract_Framework__r.Customer_Request_Code__c', 
		'Contract_Treatment_Job__r.Contract_Framework__r.Invoice_splitting_criterion__c', 
		'Contract_Treatment_Job__r.Contract_Framework__r.Invoice_Layout__c', 'Contract_Treatment_Job__r.Invoice_Splitting_Group__c', 
		'Patient_Treatment__r.Customer_Request_Code__c', 'Patient_Treatment__r.Contract_Treatment__r.Invoice_Splitting_Group__c', 'Account_Treatment_Job__c', 
		'Customer_Product_Code__c', 'Scheduling_Time_Frame__c', 'Frequency_Type__c'};

		List<String> queryFieldsForSLA = new List<String>{'IsDefault__c', 'Contract_Treatment_Job__c', 'Max_Time__c', 'Unite_of_measure_Max_Time__c',      //Unit, not unite
		'Calculation_Mode__c', 'Offset_Start_Date__c', 'Offset_End_Date__c', 'Offset_unit_of_measure__c', 'Offset_calculation_mode__c', 'Task_MaxTime_Execution__c', 
		'Task_Unite_of_measure_Max_Time__c', 'Task_Calculation_Mode__c'};

		List<String> queryFieldsForProducts = new List<String>{'Product__c', 'Quantity__c', 'Customer_Treatment_Alias__c', 'Patient_Treatment_Job__c', 'Customer_Request_Code__c', 
		'Storage_Location__c', 'Plant__c', 'Purchase_order_number__c', 'Purchase_order_date__c', 'Contract_Treatment_Job_Product__r.Invoice_Splitting_group__c', 'Asset__c', 
		'Asset__r.SerialNumber'};

		List<String> queryFieldsForPBEntry = new List<String>{'Product2Id', 'Pricebook2Id'};

		List<String> queryFieldsForASO = new List<String>{'Sales_Organization__r.Code__c', 'Division__c', 'Distribution_Channel__c', 'Sales_Group__c', 'Sales_Office__c'};

		List<String> caseQueryFields = new List<String>{'AccountId', 'Account_Treatment__c', 'Account_Treatment_Job__c', 'Origin', 'Contract_Treatment__c', 
        'Patient__c', 'Status', 'Subject', 'Subtype__c', 'Type', 'Treatment__c', 'Autoscheduled__c', 'ContactId', 'OwnerId', 'Start_Date__c', 'Next_Activity_Date__c'};

		BusinessHours bh = [SELECT Id, MondayStartTime, MondayEndTime, TuesdayStartTime, TuesdayEndTime, WednesdayStartTime, WednesdayEndTime, 
							ThursdayStartTime, ThursdayEndTime, FridayStartTime, FridayEndTime, SaturdayStartTime, SaturdayEndTime, SundayStartTime, SundayEndTime
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
		Map<Id, Account_Sales_Organization__c> ASOMap = new Map<Id, Account_Sales_Organization__c>();
		Map<String, List<Case>> newCasesMap = new Map<String, List<Case>>();
		Map<String, Case> queriedNewCasesMap = new Map<String, Case>();

		List<Id> ATJids = new List<Id>();
		List<Id> dependentJobsIds = new List<Id>();
		List<Id> pricebookIds = new List<Id>();
		List<Id> newCaseIds = new List<Id>();
		List<Case> newCases = new List<Case>();
		List<Case> queriedNewCases = new List<Case>();
		List<Task> newTasks = new List<Task>();
		List<Id> relatedASOIds = new List<Id>();
		List<Account_Treatment_Job__c> allDependentJobs = new List<Account_Treatment_Job__c>();

		for (WorkOrder wo : workOrders){
			if(wo.Account_Treatment_Job__c != null) {
				ATJids.add(wo.Account_Treatment_Job__c);
			}
			accountTreatmentIds.add(wo.Account_Treatment__c);
		}

		// This is the list of all the dependent ATJs related to all the workOrders in input

		if(!ATJids.isEmpty()) {
			allDependentJobs = AccountTreatmentJobDAO.getDependentATJsFromATJIds(queryFieldsForATJ, ATJids);
		}

		// Filling the dependentATJMap with key = ATJ Id which the Job depends on and value = list of the job depending on that ATJ Id

		if (allDependentJobs != null && !allDependentJobs.isEmpty()){
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
		}

		// Creating Cases --> I need to insert them before creating WO and Tasks

		if(dependentATJMap != null && !dependentATJMap.isEmpty()) {
			for (WorkOrder wo : workOrders){
				List<Account_Treatment_Job__c> dependentATJs = dependentATJMap.get(wo.Account_Treatment_Job__c);
				//System.debug('dependentATJs: ' + dependentATJs.size());
				if (dependentATJs != null){
					System.debug('dependentATJs: ' + dependentATJs);
					// All dependent ATJs and the related chosen SLA
					Map<Account_Treatment_Job__c, Contract_Treatment_Job_SLA__c> ATJtoSLAMap = ATMainComponentService.getATJtoSLAMap(dependentATJs);
					List<Case> createdNewCases = ATMainComponentService.createCases(ATJtoSLAMap, DMLOptions, true, null);
					System.debug('createdNewCases size: ' + createdNewCases.size());

					if(createdNewCases != null) {
						newCasesMap.put(wo.Id, createdNewCases);

						for(Case c : createdNewCases) {
							newCases.add(c);
						}
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

		if(dependentATJMap != null && !dependentATJMap.isEmpty()) {
			for (WorkOrder wo : workOrders){
				List<Account_Treatment_Job__c> dependentATJs = dependentATJMap.get(wo.Account_Treatment_Job__c);
				if (dependentATJs != null){
					List<Case> relatedNewCases = newCasesMap.get(wo.Id);

					if(relatedNewCases != null && !relatedNewCases.isEmpty()) {
						// All dependent ATJs and the related chosen SLA
						Map<Account_Treatment_Job__c, Contract_Treatment_Job_SLA__c> ATJtoSLAMap = ATMainComponentService.getATJtoSLAMap(dependentATJs);
						// Using the modified version of createWorkOrders to create WOs for each dependent Job of each closed WO
						List<WorkOrder> createdWorkOrders = WorkOrderService.createWorkOrders(ATJToSLAMap, relatedNewCases, wo, null, bh, ASOMap, therapyDocumentType);
						if (createdWorkOrders != null){
							for (WorkOrder createdWO : createdWorkOrders){
								newWorkOrders.add(createdWO);
							}
						}
						// Using the same method used in ATMainComponentService to create Tasks for each dependent Job of each closed WO
						List<Task> createdTasks = ATMainComponentService.createTasks(ATJtoSLAMap, relatedNewCases, bh, false, wo, null, null, false, null);
						if (createdTasks != null){
							for (Task createdTask : createdTasks){
								newTasks.add(createdTask);
							}
						}
					}
				}
			}
		}

		// Inserting new WorkOrders + updating Cases for the Start Date

		if (!newWorkOrders.isEmpty()){
			insert newWorkOrders;
			update queriedNewCases;
        }
        
        // Inserting new Tasks and updating Cases for the Start Date
        
		if (!newTasks.isEmpty()){
			insert newTasks;
			update queriedNewCases;
		}
    }

    public void finish(Database.BatchableContext bc) {

        // Executing WOLI Batch

        WOLICreationBatch WOLICreation;

        if(!ATJMap.isEmpty() && !jobToProductsMap.isEmpty() && !pricebookIdToPEMap.isEmpty() && !newWorkOrders.isEmpty()) {
            WOLICreation = new WOLICreationBatch();
			WOLICreation.ATJMap = ATJMap;
			WOLICreation.jobToProductsMap = jobToProductsMap;
			WOLICreation.pricebookIdToPEMap = pricebookIdToPEMap;
            WOLICreation.workOrders = newWorkOrders;
            
			//Database.executeBatch(WOLICreation, 3);
        }    

        // Executing Batch to align workOrders for different created addresses (Temporary and Default)

        if(!accountTreatmentIds.isEmpty()) {
            ATAAlignmentBatch ATABatch = new ATAAlignmentBatch();
            ATABatch.ATIds = accountTreatmentIds;

            if(WOLICreation != null) {
                ATABatch.WOLIBatch = WOLICreation;
            }

            // Launching ServiceTerritory Batch

            ServiceTerritoryUpdateBatch serviceTerritoryBatch = new ServiceTerritoryUpdateBatch();
            serviceTerritoryBatch.ATAAlignmentBatch = ATABatch;

            Database.executeBatch(serviceTerritoryBatch, 50);

            //Database.executeBatch(ATABatch, 100);
        }
        
    }
}