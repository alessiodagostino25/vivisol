public with sharing class AccountTreatmentDefaultBOMHelper {

    public static void AccountTreatmentDefaultBOMHelperwithid(List<String> accounttreatmentids, List<Account_Treatment__c> accountTreatments,List<String> atcontracttreatmentids){
        //Map<String, String> atidsandctids = new Map<String, String>();
        //List<Account_Treatment__c> Accounttreatmentupdate = new List<Account_Treatment__c>();
        //List<Account_Treatment__c> AccounttreatmentupdateList = new List<Account_Treatment__c>();
        //List<String> ATQueryFields = new List<String>{'Id','electricity_costs_desired__c','Contract_Treatment__c'};
        //List<String> CTQueryFields = new List<String>{'Id','Electricity_Rebates__c '};
        //Accounttreatmentupdate = AccountTreatmentDAO.getAccountTreatmentsFromIds(ATQueryFields,accounttreatmentids);
        /* List<Contract_Treatment__c> ContractTreatments = new List<Contract_Treatment__c>();
        ContractTreatments = ContractTreatmentDAO.getContractTreatmentsFromIds(CTQueryFields,atcontracttreatmentids) ;
        Map<Id, String> ctidsandelectricity = new Map<Id, String>(); */

        Map<String, List<Account_Treatment__c>> CTIdToRelatedATsMap = new Map<String, List<Account_Treatment__c>>();

        for(Account_Treatment__c at : accountTreatments) {
            if(CTIdToRelatedATsMap.get(at.Contract_Treatment__c) == null) {
                CTIdToRelatedATsMap.put(at.Contract_Treatment__c, new List<Account_Treatment__c>());
            }
            CTIdToRelatedATsMap.get(at.Contract_Treatment__c).add(at);
        }

        /* for(Integer i=0 ; i<ContractTreatments.size() ; i++ ){
			ctidsandelectricity.put(ContractTreatments[i].Id ,String.valueOf(ContractTreatments[i].Electricity_Rebates__c)) ;
		}

        for (Account_Treatment__c at : Accounttreatmentupdate){
            at.electricity_costs_desired__c = ctidsandelectricity.get(at.Contract_Treatment__c) ;
            AccounttreatmentupdateList.add(at) ;

        }
        //update account Treatment 
        if(!AccounttreatmentupdateList.isEmpty()){
            update AccounttreatmentupdateList ;
        }  */
        /* for(Integer i=0 ; i<accounttreatmentids.size() ; i++ ){
			atidsandctids.put(atcontracttreatmentids[i] ,accounttreatmentids[i]) ;
		} */
        List<Contract_Treatment_Job__c> ContracttreatmentjobsList = new List<Contract_Treatment_Job__c>();
        List<Contract_Treatment_Job__c> contractTreatmentJobsParentList = new List<Contract_Treatment_Job__c>();
        List<Contract_Treatment_Job__c> ContracttreatmentjobsChildList = new List<Contract_Treatment_Job__c>();

        //get the contracttreatmentjobs from  dom using the contract treatment id .
        ContracttreatmentjobsList = ContractTreatmentJobDAO.getContractTreatmentJobsForDOM(atcontracttreatmentids);
        List<string> Contracttreatmentjobsidsfromlist = new List<string>();
        for(Integer i=0 ; i< ContracttreatmentjobsList.size() ; i++ ){
            Contracttreatmentjobsidsfromlist.add(ContracttreatmentjobsList[i].Id) ;
        }
      
        List<Account_Treatment_Job__c> atjupdateParentlist = new List<Account_Treatment_Job__c>();
        List<Account_Treatment_Job__c> atjupdateChildlist = new List<Account_Treatment_Job__c>();
       
        for(Integer i= 0 ; i < ContracttreatmentjobsList.size() ; i++ ){
         //sorting the parent and child jobs in ContracttreatmentjobsList
            if(String.isnotblank(ContracttreatmentjobsList[i].Contract_Treatment_Job__c) ){
                ContracttreatmentjobsChildList.add(ContracttreatmentjobsList[i]) ;
            }else {
                contractTreatmentJobsParentList.add(ContracttreatmentjobsList[i]) ;
            }
        }
         //creating of account treatment job for each contract treatment job .
        for(Integer i= 0 ; i < contractTreatmentJobsParentList.size() ; i++ ){
            List<Account_Treatment__c> relatedAccountTreatments = CTIdToRelatedATsMap.get(contractTreatmentJobsParentList[i].Contract_Treatment__c);
            System.debug('relatedAccountTreatments: ' + relatedAccountTreatments);

            if(relatedAccountTreatments != null) {
                for(Account_Treatment__c at : relatedAccountTreatments) {
                    Account_Treatment_Job__c atj = new Account_Treatment_Job__c();
           
                    atj.Contract_Treatment_Job__c = contractTreatmentJobsParentList[i].Id; 
                    atj.Delivery_Channel__c = contractTreatmentJobsParentList[i].Delivery_Channel__c ;
                    atj.Frequency__c = contractTreatmentJobsParentList[i].Frequency__c ;
                    atj.Frequency_Unit_of_measure__c = contractTreatmentJobsParentList[i].Frequency_Unit_of_measure__c ; 
                    atj.Patient_Treatment__c = at.Id; 
                    atj.Billable__c = contractTreatmentJobsParentList[i].Billable__c ;
                    atj.Name = contractTreatmentJobsParentList[i].Name ;
                    atj.Task__c = contractTreatmentJobsParentList[i].Task__c ;
                    atj.Work_Order__c = contractTreatmentJobsParentList[i].Work_Order__c ;
                    atj.Scheduling_Rule__c = contractTreatmentJobsParentList[i].Scheduling_Rule__c ; 
                    atj.Case_Type__c = contractTreatmentJobsParentList[i].Case_Type__c ;
                    atj.Case_Subtype__c = contractTreatmentJobsParentList[i].Case_Subtype__c ;
                    atj.Task_Type__c = contractTreatmentJobsParentList[i].Task_Type__c ;
                    atj.Work_Type__c = contractTreatmentJobsParentList[i].Work_Type__c ;
                    atj.ComplianceSource__c = contractTreatmentJobsParentList[i].ComplianceSource__c ;
                    atj.Customer_Product_Code__c  = contractTreatmentJobsParentList[i].Customer_Product_Code__c ;
                    atj.Back_Office_Review__c = contractTreatmentJobsParentList[i].Back_Office_Review__c;
                    atj.Scheduling_Time_Frame__c = contractTreatmentJobsParentList[i].Scheduling_Time_Frame__c;
                    atj.Frequency_Type__c = contractTreatmentJobsParentList[i].Frequency_Type__c;
                
                    atjupdateParentlist.add(atj);
                }
            }
        }

        //insert the account treatment jobs

        if (!atjupdateParentlist.isEmpty()){
            insert atjupdateParentlist;
        }

        //get the accounttreatmentjob using the accounttreatmentid and contracttreatmentjob 
        List<Account_Treatment_Job__c> accounttreatmentfield = AccountTreatmentJobDAO.getaccounttreatmentjobbyatidslist(accounttreatmentids) ;
        System.debug('accounttreatmentfield: ' + accounttreatmentfield);
        Map<string,string>  accounttreatmentfieldmap = new map<string,string>();

        for(Integer i=0 ; i<accounttreatmentfield.size() ; i++ ){
            //mapping the contracttreatment job and the account treatment job
            accounttreatmentfieldmap.put(accounttreatmentfield[i].Contract_Treatment_Job__c ,accounttreatmentfield[i].Id) ;
        }
        System.debug('accounttreatmentfieldmap: ' + accounttreatmentfieldmap);

        for(Integer i= 0 ; i < ContracttreatmentjobsChildList.size() ; i++ ){ 
            List<Account_Treatment__c> relatedAccountTreatments = CTIdToRelatedATsMap.get(ContracttreatmentjobsChildList[i].Contract_Treatment__c);

            if(relatedAccountTreatments != null) {
                for(Account_Treatment__c at : relatedAccountTreatments) {
                    Account_Treatment_Job__c atj = new Account_Treatment_Job__c();
                    atj.Contract_Treatment_Job__c = ContracttreatmentjobsChildList[i].Id; 
                    atj.Delivery_Channel__c = ContracttreatmentjobsChildList[i].Delivery_Channel__c ;
                    atj.Frequency__c = ContracttreatmentjobsChildList[i].Frequency__c ;
                    atj.Frequency_Unit_of_measure__c = ContracttreatmentjobsChildList[i].Frequency_Unit_of_measure__c ; 
                    atj.Patient_Treatment__c = at.Id; 
                    atj.Billable__c = ContracttreatmentjobsChildList[i].Billable__c ;
                    atj.Name = ContracttreatmentjobsChildList[i].Name ;
                    atj.Task__c = ContracttreatmentjobsChildList[i].Task__c ;
                    atj.Work_Order__c = ContracttreatmentjobsChildList[i].Work_Order__c ;
                    atj.Scheduling_Rule__c = ContracttreatmentjobsChildList[i].Scheduling_Rule__c ; 
                    atj.Case_Type__c = ContracttreatmentjobsChildList[i].Case_Type__c ;
                    atj.Case_Subtype__c = ContracttreatmentjobsChildList[i].Case_Subtype__c ;
                    atj.Task_Type__c = ContracttreatmentjobsChildList[i].Task_Type__c ;
                    atj.Work_Type__c = ContracttreatmentjobsChildList[i].Work_Type__c ;
                    atj.ComplianceSource__c = ContracttreatmentjobsChildList[i].ComplianceSource__c ;
                    atj.Customer_Product_Code__c = ContracttreatmentjobsChildList[i].Customer_Product_Code__c ;
                    atj.Back_Office_Review__c = ContracttreatmentjobsChildList[i].Back_Office_Review__c;
                    atj.Scheduling_Time_Frame__c = ContracttreatmentjobsChildList[i].Scheduling_Time_Frame__c;
                    atj.Frequency_Type__c = ContracttreatmentjobsChildList[i].Frequency_Type__c;
                    
                    atjupdateChildlist.add(atj) ;
                }
            }
        }

        //insert the account treatment jobs

        if (!atjupdateChildlist.isEmpty()){
            insert atjupdateChildlist;

            updateRelatedATJ(atjupdateChildlist);
        }
   
        List<Contract_Treatment_Default_BOM__c> ContracttreatmentjobsProductList = new List<Contract_Treatment_Default_BOM__c>();
        List<String> ContracttreatmentjobIds = new List<String>();
        for(Integer i= 0 ; i < ContracttreatmentjobsList.size() ; i++ ){
            ContracttreatmentjobIds.add(ContracttreatmentjobsList[i].Id);
        }
        List<String> accounttreatmentjobids = new List<String>();
        List<String> contracttreatmentjobsids = new List<String>();
        Map<String, List<Account_Treatment_Job__c>> CTJIdToATJsMap = new Map<String, List<Account_Treatment_Job__c>>();
        //getting the account treament jobs using the account treatment ids 
        List<Account_Treatment_Job__c> accounttreatmentjob = AccountTreatmentJobDAO.getAccountTreatmentJobByACIdlist(accounttreatmentids) ;
        System.debug('accounttreatmentids: ' + accounttreatmentids);
        System.debug('accounttreatmentjob size: ' + accounttreatmentjob.size());
        for(Integer i= 0 ; i < accounttreatmentjob.size() ; i++){
            accounttreatmentjobids.add(accounttreatmentjob[i].Id) ;
            contracttreatmentjobsids.add(accounttreatmentjob[i].Contract_Treatment_Job__c) ;
        }

        for(Account_Treatment_Job__c atj : accounttreatmentjob) {
            if(CTJIdToATJsMap.get(atj.Contract_Treatment_Job__c) == null) {
                CTJIdToATJsMap.put(atj.Contract_Treatment_Job__c, new List<Account_Treatment_Job__c>());
            }
            CTJIdToATJsMap.get(atj.Contract_Treatment_Job__c).add(atj);
        }

        System.debug('accounttreatmentjobids size: ' + accounttreatmentjobids.size());
        System.debug('contracttreatmentjobsids size: ' + contracttreatmentjobsids.size());
        Map<String, String> atjidandctjid = new Map<String, String>();
        for (Integer i = 0; i < accounttreatmentjobids.size(); i++) {
            //mapping the contracttreamentjobs ids with accounttreatmentjobs ids 
            atjidandctjid.put(contracttreatmentjobsids[i],accounttreatmentjobids[i]);
        }
        System.debug('atjidandctjid: ' + atjidandctjid);
        //getting the ContracttreatmentjobsProductList using the contracttreatmentjobs ids
        ContracttreatmentjobsProductList = ContractTreatmentDefaultBomDAO.getDefaultBOMFromcontracttreatmentid(ContracttreatmentjobIds);
        System.debug('ContracttreatmentjobsProductList size: ' + ContracttreatmentjobsProductList.size());
        List<Account_Treatment_Job_Product__c> atjpupdatelist = new List<Account_Treatment_Job_Product__c>();
        //creating a new account treatment job product for every ContracttreatmentjobsProductList .
        for(Integer i = 0; i < ContracttreatmentjobsProductList.size(); i ++) {
            List<Account_Treatment_Job__c> relatedATJs = CTJIdToATJsMap.get(ContracttreatmentjobsProductList[i].Contract_Treatment_Job_Product__r.Contract_Treatment_Job__c);

            if(relatedATJs != null && !relatedATJs.isEmpty()) {
                for(Account_Treatment_Job__c atj : relatedATJs) {
                    Account_Treatment_Job_Product__c atjp = new Account_Treatment_Job_Product__c();
                    atjp.Product__c = ContracttreatmentjobsProductList[i].Product__c ;
                    atjp.Patient_Treatment_Job__c =  atj.Id;
                    atjp.Contract_Treatment_Job_Product__c = ContracttreatmentjobsProductList[i].Contract_Treatment_Job_Product__c ;
                    atjp.Max_Quantity__c = ContracttreatmentjobsProductList[i].Contract_Treatment_Job_Product__r.Max_Quantity__c;
                    atjp.Min_Quantity__c = ContracttreatmentjobsProductList[i].Contract_Treatment_Job_Product__r.Min_Quantity__c;
                    atjp.Quantity_Unit_of_measure__c = ContracttreatmentjobsProductList[i].Contract_Treatment_Job_Product__r.Quantity_Unit_of_measure__c;
                    atjp.Frequency__c = ContracttreatmentjobsProductList[i].Contract_Treatment_Job_Product__r.Frequency__c;
                    atjp.Frequency_Unit_of_measure__c = ContracttreatmentjobsProductList[i].Contract_Treatment_Job_Product__r.Frequency_Unit_of_measure__c;
                    atjp.Billable__c = ContracttreatmentjobsProductList[i].Contract_Treatment_Job_Product__r.Billable__c;
                    atjp.Invoice_Splitting_group__c = ContracttreatmentjobsProductList[i].Contract_Treatment_Job_Product__r.Invoice_Splitting_group__c;
                    atjp.Purchase_order_number__c = ContracttreatmentjobsProductList[i].Contract_Treatment_Job_Product__r.Purchase_order_number__c;
                    atjp.Purchase_order_date__c = ContracttreatmentjobsProductList[i].Contract_Treatment_Job_Product__r.Purchase_order_date__c;
                    atjp.Customer_Treatment_Alias__c = ContracttreatmentjobsProductList[i].Contract_Treatment_Job_Product__r.Customer_Treatment_Alias__c;
                    atjp.Customer_Request_Code__c = ContracttreatmentjobsProductList[i].Contract_Treatment_Job_Product__r.Contract_Treatment_Job__r.Contract_Treatment__r.Customer_Request_Code__c ;
                    atjp.Quantity__c = ContracttreatmentjobsProductList[i].Contract_Treatment_Job_Product__r.Quantity__c ;
                    atjp.Plant__c = ContracttreatmentjobsProductList[i].Contract_Treatment_Job_Product__r.Plant__c;
                    atjp.Storage_Location__c = ContracttreatmentjobsProductList[i].Contract_Treatment_Job_Product__r.Storage_Location__c;
                    atjpupdatelist.add(atjp);
                }
            }
        }
        if (!atjpupdatelist.isEmpty()){
            insert atjpupdatelist;
        }
    }

    /* public static List<WorkOrder> autoscheduleActivitiesMaintenance(List<Account_Treatment_Job__c> accountTreatmentJobs, 
    Map<Id, List<Account_Treatment_Job_Product__c>> jobToAssetProductsMap, Map<Id, Asset> assetMap, Boolean isRescheduling,
    Map<Id, WorkOrder> assetProductToFirstWOMap, Map<Id, Task> assetProductToFirstTaskMap) {

        List<String> caseQueryFields = new List<String>{'AccountId', 'Account_Treatment__c', 'Account_Treatment_Job__c', 'Origin', 'Contract_Treatment__c', 
        'Patient__c', 'Status', 'Subject', 'Subtype__c', 'Type', 'Treatment__c', 'Autoscheduled__c', 'ContactId', 'OwnerId', 'Start_Date__c', 'Next_Activity_Date__c'};
        
        List<Case> newCases = new List<Case>();
        List<Case> queriedNewCases = new List<Case>();
        List<WorkOrder> newWorkOrders = new List<WorkOrder>();
        List<Task> newTasks = new List<Task>();
        List<Id> newCaseIds = new List<Id>();

        Map<Account_Treatment_Job__c, Contract_Treatment_Job_SLA__c> ATJtoSLAMap = ATMainComponentService.getATJtoSLAMap(accountTreatmentJobs);

        BusinessHours bh = [SELECT Id, MondayStartTime, MondayEndTime, TuesdayStartTime, TuesdayEndTime, WednesdayStartTime, WednesdayEndTime,
                            ThursdayStartTime, ThursdayEndTime, FridayStartTime, FridayEndTime  
                            FROM BusinessHours WHERE Name = 'NL'];

        AssignmentRule assignmentRule = [SELECT Id FROM AssignmentRule WHERE SobjectType = 'Case' and Active = true LIMIT 1];

        //Creating the DMLOptions for "Assign using active assignment rules" checkbox
        Database.DMLOptions DMLOptions = new Database.DMLOptions();
        DMLOptions.assignmentRuleHeader.assignmentRuleId= assignmentRule.Id;

        // Creating Cases for each Product linked to an Asset (for each ATJ, but should always be one)

        System.debug('jobToAssetProductsMap: ' + jobToAssetProductsMap);
        newCases = createCasesAssetProducts(ATJtoSLAMap, DMLOptions, jobToAssetProductsMap, isRescheduling);

        // Inserting new Cases, then using standart ATMainComponentService's method to create Tasks and modified method to create WorkOrders

        if(!newCases.isEmpty()) {
            insert newCases;

            for(Case c : newCases) {
                newCaseIds.add(c.Id);
            }

            queriedNewCases = CaseDAO.getCasesFromIds(caseQueryFields, newCaseIds);

            System.debug('newCases size: ' + newCases.size());
            newTasks = createTasksAssetProducts(ATJToSLAMap, queriedNewCases, bh, jobToAssetProductsMap, assetProductToFirstTaskMap);
            System.debug('newTasks size: ' + newTasks.size());
            newWorkOrders = createWorkOrdersAssetProducts(ATJtoSLAMap, queriedNewCases, bh, jobToAssetProductsMap, assetMap, assetProductToFirstWOMap);
            System.debug('newWorkOrders size: ' + newWorkOrders.size());
        }
        
        if(!newTasks.isEmpty()) {
            insert newTasks;
            update queriedNewCases;
        }

        if(!newWorkOrders.isEmpty()) {
            insert newWorkOrders;
            update queriedNewCases;

            
        }

        return newWorkOrders;

    } */

    // Modified version of the method in ATMainComponentService made to work with Assets

    /* public static List<Case> createCasesAssetProducts(Map<Account_Treatment_Job__c, Contract_Treatment_Job_SLA__c> ATJtoSLAMap, Database.DMLOptions DMLOptions,
    Map<Id, List<Account_Treatment_Job_Product__c>> jobToAssetProductsMap, Boolean isRescheduling) {

        Set<Account_Treatment_Job__c> ATJs = ATJtoSLAMap.keySet();
        List<Case> toInsert = new List<Case>();
        System.debug('ATJs: ' + ATJs);
        System.debug('jobToAssetProductsMap: ' + jobToAssetProductsMap);

        for(Account_Treatment_Job__c atj : ATJs) {
            List<Account_Treatment_Job_Product__c> relatedAssetProducts = jobToAssetProductsMap.get(atj.Id);
            if(relatedAssetProducts != null) {
                System.debug('relatedAssetProducts: ' + relatedAssetProducts);
                for(Account_Treatment_Job_Product__c atjp : relatedAssetProducts) {
                    if(!isRescheduling) {
                        Case newCase = new Case(
                            AccountId = atj.Patient_Treatment__r.Account__c,
                            Account_Treatment__c = atj.Patient_Treatment__c,
                            Account_Treatment_Job__c = atj.Id,
                            Origin = 'System',
                            Contract_Treatment__c = atj.Patient_Treatment__r.Contract_Treatment__c,
                            Patient__c = atj.Patient_Treatment__r.Account__c,
                            Status = 'New',
                            Subject = atj.Name,
                            Subtype__c = atj.Case_Subtype__c,
                            Type = atj.Case_Type__c,
                            Treatment__c = atj.Patient_Treatment__r.Treatment_Type__c,
                            Autoscheduled__c = true
                        );

                        if(atj.Patient_Treatment__r.Account__r.IsPersonAccount == true) {
                            newCase.ContactId = atj.Patient_Treatment__r.Account__r.PersonContactId;
                        }

                        newCase.setOptions(DMLOptions);

                        System.debug('firstCase: ' + newCase);
                        toInsert.add(newCase);
                    }

                    // Creating the autoscheduled Cases: WO and Tasks will later be assigned to each of these Cases

                    if(atj.Frequency__c != null) {
                        Integer numberOfCasesToCreate;

                        if(atj.Frequency_Unit_of_measure__c == 'Day') {
                            numberOfCasesToCreate = (Integer) (365 * atj.Frequency__c);
                        }
                        else if(atj.Frequency_Unit_of_measure__c == 'Week') {
                            numberOfCasesToCreate = (Integer) (52 * atj.Frequency__c);
                        }
                        else if(atj.Frequency_Unit_of_measure__c == 'Month') {
                            numberOfCasesToCreate = (Integer) (12 * atj.Frequency__c);
                        }
                        else if(atj.Frequency_Unit_of_measure__c == 'Year') {
                            numberOfCasesToCreate = (Integer) atj.Frequency__c;
                        }

                        System.debug('numberOfCasesToCreate: ' + numberOfCasesToCreate);

                        for(Integer i = 0; i < (numberOfCasesToCreate - 1); i++) {
                            Case scheduledCase = new Case(
                                AccountId = atj.Patient_Treatment__r.Account__c,
                                Account_Treatment__c = atj.Patient_Treatment__c,
                                Account_Treatment_Job__c = atj.Id,
                                Origin = 'System',
                                Contract_Treatment__c = atj.Patient_Treatment__r.Contract_Treatment__c,
                                //Patient__c = atj.Patient_Treatment__r.Account__c,
                                Status = 'New',
                                Subject = atj.Name,
                                Subtype__c = atj.Case_Subtype__c,
                                Type = atj.Case_Type__c,
                                Treatment__c = atj.Patient_Treatment__r.Treatment_Type__c,
                                Autoscheduled__c = true
                            );

                            if(atj.Patient_Treatment__r.Account__r.IsPersonAccount == true) {
                                scheduledCase.ContactId = atj.Patient_Treatment__r.Account__r.PersonContactId;
                            }

                            scheduledCase.setOptions(DMLOptions);

                            toInsert.add(scheduledCase);
                        }
                    }
                }
            }
        }

        System.debug('casesToInsert size: ' + toInsert.size());
        return toInsert;
    } */

    // This is a modified version of the method ATMainComponentService.createWorkOrders, made to be used with Asset products

    /* public static List<WorkOrder> createWorkOrdersAssetProducts(Map<Account_Treatment_Job__c,Contract_Treatment_Job_SLA__c> ATJToSLAMap, List<Case> newCases, 
    BusinessHours bh, Map<Id, List<Account_Treatment_Job_Product__c>> jobToAssetProductsMap, Map<Id, Asset> assetMap,
    Map<Id, WorkOrder> assetProductToFirstWOMap) {

        System.debug('------ Creating WorkOrders');

        List<String> queryFieldsForASO = new List<String>{'Sales_Organization__r.Code__c', 'Division__c', 'Distribution_Channel__c', 'Sales_Group__c',
        'Sales_Office__c'};

        Set<Account_Treatment_Job__c> ATJs = ATJToSLAMap.keySet();
        List<Account_Treatment_Job__c> workOrderATJs = new List<Account_Treatment_Job__c>();
        List<Id> workOrderATJsIds = new List<Id>();
        List<WorkOrder> toInsert = new List<WorkOrder>();
        List<Id> relatedASOIds = new List<Id>();

        Map<Id, List<Case>> ATJToCasesMap = new Map<Id, List<Case>>();
        Map<Id, Account_Sales_Organization__c> ASOMap = new Map<Id, Account_Sales_Organization__c>();

        Id businessHoursId = bh.Id;

        DocumentType__mdt maintenanceDocumentType = [SELECT Code__c FROM DocumentType__mdt WHERE DeveloperName = 'Maintenance'];

        if(!newCases.isEmpty()) {
            for(Case c : newCases) {
                if(ATJToCasesMap.get(c.Account_Treatment_Job__c) == null) {
                    ATJToCasesMap.put(c.Account_Treatment_Job__c, new List<Case>());
                }
                ATJToCasesMap.get(c.Account_Treatment_Job__c).add(c);
            }
        }

        for(Account_Treatment_Job__c atj : ATJs) {
            if(atj.Work_Order__c == true) {
                workOrderATJs.add(atj);
            }
        }

        for(Account_Treatment_Job__c atj : workOrderATJs) {
            workOrderATJsIds.add(atj.Id);
            relatedASOIds.add(atj.Contract_Treatment_Job__r.Contract_Framework__r.Branch_of_belonging_sales_office__c);
        }

        // Getting all the ASOs related to the ATJs

        List<Account_Sales_Organization__c> relatedASOs = AccountSalesOrganizationDAO.getASOsFromIds(queryFieldsForASO, relatedASOIds);

        if(relatedASOs != null) {
            for(Account_Sales_Organization__c aso : relatedASOs) {
                ASOMap.put(aso.Id, aso);
            }
        }

        for(Account_Treatment_Job__c atj : workOrderATJs) {
            Map<Id, List<Case>> ATJPIdToRelatedCasesMap = new Map<Id, List<Case>>();

            // Getting the related ASO
            Account_Sales_Organization__c relatedASO = ASOMap.get(atj.Contract_Treatment_Job__r.Contract_Framework__r.Branch_of_belonging_sales_office__c);

            List<Account_Treatment_Job_Product__c> relatedAssetProducts = jobToAssetProductsMap.get(atj.Id);

            if(relatedAssetProducts != null) {
                // These are the Cases previously created related to this ATJ
                List<Case> allRelatedCases = ATJToCasesMap.get(atj.Id);
                System.debug('ATJToCasesMap: ' + ATJToCasesMap);
                System.debug('allRelatedCases size: ' + allRelatedCases.size());

                // Assigning Cases to different ATJPs (example: first 5 to the first ATJP, from sixth to tenth to the second ATJP...)
                
                Integer casesForEachATJP = (Integer) (allRelatedCases.size() / relatedAssetProducts.size());
                System.debug('CasesForEachATJP for WorkOrders: ' + casesForEachATJP);

                Integer min = 0;
                Integer max = casesForEachATJP;

                for(Integer j = 0; j < relatedAssetProducts.size(); j++) {
                    for(Integer i = min; i < max; i++) {
                        if(ATJPIdToRelatedCasesMap.get(relatedAssetProducts[j].Id) == null) {
                            ATJPIdToRelatedCasesMap.put(relatedAssetProducts[j].Id, new List<Case>());
                        }
                        ATJPIdToRelatedCasesMap.get(relatedAssetProducts[j].Id).add(allRelatedCases[i]);
                    }

                    min = min + casesForEachATJP;
                    max = max + casesForEachATJP;
                }
            
                if(allRelatedCases != null) {
                    for(Account_Treatment_Job_Product__c atjp : relatedAssetProducts) {

                        WorkOrder newWorkOrder;

                        // Checking if there is already a First WO for this Asset (that means we are in a Frequency propagation case)

                        if(assetProductToFirstWOMap != null) {
                            newWorkOrder = assetProductToFirstWOMap.get(atjp.Id);
                        }

                        // Getting the Asset related to the ATJP
                        Asset relatedAsset = assetMap.get(atjp.Asset__c);

                        //Getting the SLA related to this ATJ
                        Contract_Treatment_Job_SLA__c relatedSLA = ATJToSLAMap.get(atj);

                        // Using only the cases related to this AssetProduct (all the Cases are the same here, so it's just in equal parts)
                        
                        List<Case> relatedCases = ATJPIdToRelatedCasesMap.get(atjp.Id);
                        System.debug('relatedCases for this ATJP for WorkOrders: ' + relatedCases.size());

                        // The first WO created will be assigned to the first Case
                        Case firstCase = relatedCases[0];

                        // These are the Cases that will be assigned to the WOs that will be autoscheduled later
                        List<Case> remainingCases = relatedCases;

                        // Creating the first WO only if we are not in a Frequency Propagation case

                        if(newWorkOrder == null) {
                            remainingCases.remove(0);
                            
                            // Getting startDate, endDate and dueDate

                            DatesResponseDTO relatedDates = ATMainComponentService.calculateDates(
                                Datetime.now(), 
                                relatedSLA.Max_Time__c, 
                                relatedSLA.Unite_of_measure_Max_Time__c, // To fix, unit not unite
                                relatedSLA.Calculation_Mode__c, 
                                relatedSLA.Offset_Start_Date__c, 
                                relatedSLA.Offset_End_Date__c, 
                                relatedSLA.Offset_unit_of_measure__c, 
                                relatedSLA.Offset_calculation_mode__c,
                                bh
                            );

                            // Creating new WO for each ATJ with Work_Order__c = true related to the previously created Case (CaseId)

                            newWorkOrder = new WorkOrder(

                                // Fields from the ATJ

                                AccountId = atj.Patient_Treatment__r.Account__c,
                                Account_Sold_To__c = atj.Contract_Treatment_Job__r.Contract_Framework__r.Customer__c,
                                Account_Sales_Organization__c = atj.Contract_Treatment_Job__r.Contract_Framework__r.Branch_of_belonging_sales_office__c,
                                Account_Treatment__c = atj.Patient_Treatment__c,
                                CaseId = firstCase.Id,
                                Contract_Framework__c = atj.Contract_Treatment_Job__r.Contract_Framework__c,
                                Contract_Treatment__c = atj.Contract_Treatment_Job__r.Contract_Treatment__c,
                                Contract_Treatment_Job__c = atj.Contract_Treatment_Job__c,
                                Customer_Purchase_Order_Date__c = atj.Contract_Treatment_Job__r.Contract_Framework__r.Customer__r.Customer_Purchase_Order_Date__c,
                                Customer_Purchase_Order_Number__c = atj.Contract_Treatment_Job__r.Contract_Framework__r.Customer__r.Customer_Purchase_Order_Number__c,
                                Delivery_Type__c = atj.Delivery_Channel__c,
                                Document_Type__c = maintenanceDocumentType.Code__c,
                                OwnerId = UserInfo.getUserId(),
                                Pricebook2Id = atj.Contract_Treatment_Job__r.Contract_Framework__r.Price_list_code__c,
                                Status = 'New',
                                Subject = atj.Patient_Treatment__r.Account__r.FirstName + ' ' + atj.Patient_Treatment__r.Account__r.LastName + ' - ' + atj.Name,
                                WorkTypeId = atj.Work_Type__c,
                                Account_Treatment_Job__c = atj.Id,
                                Attachment_Addendum_Type__c = atj.Contract_Treatment_Job__r.Contract_Framework__r.Attachment_Addendum_Type__c,
                                Billing_Via__c = atj.Contract_Treatment_Job__r.Contract_Framework__r.Billing_Via__c,
                                Billing_Reference__c = atj.Contract_Treatment_Job__r.Contract_Framework__r.Customer__r.Billing_Reference__c,
                                Invoice_splitting_criterion__c = atj.Contract_Treatment_Job__r.Contract_Framework__r.Invoice_splitting_criterion__c,
                                InvoiceLayout__c = atj.Contract_Treatment_Job__r.Contract_Framework__r.Invoice_Layout__c,
                                Job_InvoiceSplittingGroup__c = atj.Contract_Treatment_Job__r.Invoice_Splitting_Group__c,
                                Treatment_Customer_Purchase_Order_Date__c = atj.Patient_Treatment__r.Customer_Purchase_Date__c,
                                Treatment_Customer_Purchase_Order_Number__c = atj.Patient_Treatment__r.Customer_Purchase_Order_Number__c,
                                Treatment_Customer_Request_Code__c = atj.Patient_Treatment__r.Customer_Request_Code__c,
                                Treatment_InvoiceSplittingGroup__c = atj.Patient_Treatment__r.Contract_Treatment__r.Invoice_Splitting_Group__c,
                                Job_Product_Code__c = atj.Customer_Product_Code__c,

                                // Fields from the Asset

                                AssetId = relatedAsset.Id,
                                LocationId = relatedAsset.LocationId,
                                City = relatedAsset.Location.VisitorAddress.City,
                                Country = relatedAsset.Location.VisitorAddress.Country,
                                CountryCode = relatedAsset.Location.VisitorAddress.CountryCode,
                                Latitude = relatedAsset.Location.VisitorAddress.Latitude,
                                Longitude = relatedAsset.Location.VisitorAddress.Longitude,
                                PostalCode = relatedAsset.Location.VisitorAddress.PostalCode,
                                State = relatedAsset.Location.VisitorAddress.State,
                                StateCode = relatedAsset.Location.VisitorAddress.StateCode,
                                Street = relatedAsset.Location.VisitorAddress.Street,
                                Label__c = relatedAsset.SerialNumber,

                                // Fields from the calculateDates method

                                Related_SLA__c = relatedSLA.Id,
                                Scheduled_Start_Date__c = relatedDates.startDate,
                                Scheduled_End_Date__c = relatedDates.endDate,
                                StartDate = relatedDates.startDate,
                                EndDate = relatedDates.endDate,
                                Due_Date__c = relatedDates.dueDate,
                                Autoscheduled__c = true
                            );

                            if(atj.Patient_Treatment__r.Account__r.IsPersonAccount == true) {
                                newWorkOrder.ContactId = atj.Patient_Treatment__r.Account__r.PersonContactId;
                            }

                            else {
                                newWorkOrder.Subject = atj.Patient_Treatment__r.Account__r.Name + ' - ' + atj.Name;
                            }

                            // Fields from relatedASO

                            if(relatedASO != null) {
                                newWorkOrder.SalesOrganization__c = relatedASO.Sales_Organization__r.Code__c;
                                newWorkOrder.Division__c = relatedASO.Division__c;
                                newWorkOrder.Distribution_Channel__c = relatedASO.Distribution_Channel__c;
                                newWorkOrder.Sales_Group__c = relatedASO.Sales_Group__c;
                                newWorkOrder.Sales_Office__c = relatedASO.Sales_Office__c;
                            }

                            toInsert.add(newWorkOrder);

                            if(firstCase.Start_Date__c == null || firstCase.Start_Date__c > newWorkOrder.StartDate) {
                                firstCase.Start_Date__c = newWorkOrder.StartDate;
                                firstCase.Next_Activity_Date__c = firstCase.Start_Date__c;
                            }
                        }

                        if(newWorkOrder != null) {
                            // Autoscheduling

                            if(atj.Frequency__c != null) {
                                WorkOrder startingWorkOrder = newWorkOrder;
                                Integer daysInYear;

                                // This is currently not used

                                if(Date.isLeapYear((startingWorkOrder.StartDate).year())) {
                                    daysInYear = 366;
                                }
                                else {
                                    daysInYear = 365;
                                }

                                // Day Autoscheduling

                                if(atj.Frequency_Unit_of_measure__c == 'Day') {
                                    List<WorkOrder> newWorkOrders = ATMainComponentService.autoscheduleWorkOrders(atj, startingWorkOrder, relatedSLA, 365, remainingCases, bh, true);

                                    for(WorkOrder wo : newWorkOrders) {
                                        toInsert.add(wo);
                                    }
                                }

                                // Week Autoscheduling

                                else if(atj.Frequency_Unit_of_measure__c == 'Week') {
                                    List<WorkOrder> newWorkOrders = ATMainComponentService.autoscheduleWorkOrders(atj, startingWorkOrder, relatedSLA, 52, remainingCases, bh, true);

                                    for(WorkOrder wo : newWorkOrders) {
                                        toInsert.add(wo);
                                    }
                                }

                                // Month Autoscheduling

                                else if(atj.Frequency_Unit_of_measure__c == 'Month') {
                                    List<WorkOrder> newWorkOrders = ATMainComponentService.autoscheduleWorkOrders(atj, startingWorkOrder, relatedSLA, 12, remainingCases, bh, true);

                                    for(WorkOrder wo : newWorkOrders) {
                                        toInsert.add(wo);
                                    }
                                }

                                // Year Autoscheduling

                                else if(atj.Frequency_Unit_of_measure__c == 'Year') {
                                    List<WorkOrder> newWorkOrders = ATMainComponentService.autoscheduleWorkOrders(atj, startingWorkOrder, relatedSLA, 1, remainingCases, bh, true);

                                    for(WorkOrder wo : newWorkOrders) {
                                        toInsert.add(wo);
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        return toInsert;
    } */

    /* public static List<Task> createTasksAssetProducts(Map<Account_Treatment_Job__c,Contract_Treatment_Job_SLA__c> ATJToSLAMap, List<Case> newCases, 
    BusinessHours bh, Map<Id, List<Account_Treatment_Job_Product__c>> jobToAssetProductsMap, Map<Id, Task> assetProductToFirstTaskMap) {
        List<Task> toInsert = new List<Task>();
        Set<Account_Treatment_Job__c> ATJs = ATJToSLAMap.keySet();
        Map<Id, List<Case>> ATJIdToCasesMap = new Map<Id, List<Case>>();

        for(Case c : newCases) {
            if(ATJIdToCasesMap.get(c.Account_Treatment_Job__c) == null) {
                ATJIdToCasesMap.put(c.Account_Treatment_Job__c, new List<Case>());
            }
            ATJIdToCasesMap.get(c.Account_Treatment_Job__c).add(c);
        }

        for(Account_Treatment_Job__c atj : ATJs) {
            if(atj.Task__c == true) {
                List<Case> relatedCases = ATJIdToCasesMap.get(atj.Id);
                Map<Account_Treatment_Job__c, Contract_Treatment_Job_SLA__c> thisATJToSLAMap = new Map<Account_Treatment_Job__c, Contract_Treatment_Job_SLA__c>();
                List<Account_Treatment_Job_Product__c> relatedAssetProducts = jobToAssetProductsMap.get(atj.Id);
                Map<Id, List<Case>> ATJPIdToRelatedCasesMap = new Map<Id, List<Case>>();

                if(relatedAssetProducts != null) {

                    // Assigning Cases to different ATJPs (example: first 5 to the first ATJP, from sixth to tenth to the second ATJP...)

                    Integer casesForEachATJP = (Integer) (relatedCases.size() / relatedAssetProducts.size());

                    Integer min = 0;
                    Integer max = casesForEachATJP;
                    for(Integer j = 0; j < relatedAssetProducts.size(); j++) {
                        for(Integer i = min; i < max; i++) {
                            if(ATJPIdToRelatedCasesMap.get(relatedAssetProducts[j].Id) == null) {
                                ATJPIdToRelatedCasesMap.put(relatedAssetProducts[j].Id, new List<Case>());
                            }
                            ATJPIdToRelatedCasesMap.get(relatedAssetProducts[j].Id).add(relatedCases[i]);
                        }

                        min = min + casesForEachATJP;
                        max = max + casesForEachATJP;
                    }

                    thisATJToSLAMap.put(atj, ATJToSLAMap.get(atj));

                }

                if(relatedCases != null) {

                    for(Account_Treatment_Job_Product__c atjp : relatedAssetProducts) {
                        List<Case> casesRelatedToATJP = ATJPIdToRelatedCasesMap.get(atjp.Id);
                        Task relatedFirstTask;

                        if(assetProductToFirstTaskMap != null) {
                            relatedFirstTask = assetProductToFirstTaskMap.get(atjp.Id);
                        }

                        if(relatedFirstTask != null) {
                            Map<Id, Task> ATJIdToFirstTaskMap = new Map<Id, Task>{atj.Id => relatedFirstTask};

                            // Calling createTasks for each single ATJP, with the list containing only its Cases and the Map containing the First starting Task

                            if(casesRelatedToATJP != null) {
                                System.debug('cases for this ATJP: ' + casesRelatedToATJP.size());
                                List<Task> relatedNewTasks = ATMainComponentService.createTasks(
                                    thisATJToSLAMap, 
                                    casesRelatedToATJP, 
                                    bh, 
                                    false, 
                                    null,
                                    null, 
                                    null, 
                                    ATJIdToFirstTaskMap
                                );

                                if(relatedNewTasks != null) {
                                    for(Task t : relatedNewTasks) {
                                        toInsert.add(t);
                                    }
                                }
                            }
                        }
                        else {
                            if(casesRelatedToATJP != null) {
                                System.debug('cases for this ATJP: ' + casesRelatedToATJP.size());
                                List<Task> relatedNewTasks = ATMainComponentService.createTasks(
                                    thisATJToSLAMap, 
                                    casesRelatedToATJP, 
                                    bh, 
                                    false, 
                                    null,
                                    null, 
                                    null, 
                                    null
                                );

                                if(relatedNewTasks != null) {
                                    for(Task t : relatedNewTasks) {
                                        toInsert.add(t);
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        return toInsert;
    } */

    public static void setExternalId(List<Account_Treatment__c> accountTreatments) {
        SObjectServiceClass.updateExternalId('Account_Treatment__c', 'Account_Treatment_Number__c', 'External_Id__c', accountTreatments);
    }

    public static void createWaitingATS(List<Account_Treatment__c> accountTreatments) {
        List<Account_Treatment_Status__c> toInsert = new List<Account_Treatment_Status__c>();

        for(Account_Treatment__c accountTreatment : accountTreatments) {
            Account_Treatment_Status__c ats = new Account_Treatment_Status__c(
                Patient_Treatment__c = accountTreatment.Id,
                StartDate__c = Date.today(),
                Status__c = 'W'
            );

            toInsert.add(ats);
        }

        if(!toInsert.isEmpty()) {
            List<Database.SaveResult> results = Database.insert(toInsert);
        }
    }

    public static void updateRelatedATJ(List<Account_Treatment_Job__c> ATJs) {
        List<String> CTJQueryFields = new List<String>{'Contract_Treatment_Job__c'};
        List<String> ATJQueryFields = new List<String>{'Patient_Treatment__c', 'Contract_Treatment_Job__c'};

        List<Account_Treatment_Job__c> toUpdate = new List<Account_Treatment_Job__c>();
        List<Account_Treatment_Job__c> ATJsRelatedToParentCTJs = new List<Account_Treatment_Job__c>();
        List<Contract_Treatment_Job__c> relatedCTJs = new List<Contract_Treatment_Job__c>();
        List<String> accountTreatmentIds = new List<String>();
        List<String> parentCTJIds = new List<String>();
        List<String> CTJIds = new List<String>();

        Map<String, Contract_Treatment_Job__c> CTJMap = new Map<String, Contract_Treatment_Job__c>();
        Map<String, Account_Treatment_Job__c> parentATJMap = new Map<String, Account_Treatment_Job__c>();

        for(Account_Treatment_Job__c atj : ATJs) {
            accountTreatmentIds.add(atj.Patient_Treatment__c);

            if(atj.Contract_Treatment_Job__c != null) {
                CTJIds.add(atj.Contract_Treatment_Job__c);
            }
        }

        if(!CTJIds.isEmpty()) {
            relatedCTJs = ContractTreatmentJobDAO.getCTJsFromIds(CTJQueryFields, CTJIds);

            if(!relatedCTJs.isEmpty()) {
                for(Contract_Treatment_Job__c ctj : relatedCTJs) {
                    CTJMap.put(ctj.Id, ctj);

                    if(ctj.Contract_Treatment_Job__c != null) {
                        parentCTJIds.add(ctj.Contract_Treatment_Job__c);
                    }
                }

                ATJsRelatedToParentCTJs = AccountTreatmentJobDAO.getATJsFromATsAndCTJs(ATJQueryFields, accountTreatmentIds, parentCTJIds);

                if(!ATJsRelatedToParentCTJs.isEmpty()) {
                    for(Account_Treatment_Job__c atj : ATJsRelatedToParentCTJs) {
                        parentATJMap.put(String.valueOf(atj.Patient_Treatment__c) + String.valueOf(atj.Contract_Treatment_Job__c), atj);
                    }
                }

                for(Account_Treatment_Job__c atj : ATJs) {
                    Contract_Treatment_Job__c relatedCTJ = CTJMap.get(atj.Contract_Treatment_Job__c);

                    if(relatedCTJ != null) {
                        Account_Treatment_Job__c parentATJ = parentATJMap.get(String.valueOf(atj.Patient_Treatment__c) + 
                        String.valueOf(relatedCTJ.Contract_Treatment_Job__c));

                        if(parentATJ != null) {
                            atj.Account_Treatment_Job__c = parentATJ.Id;

                            toUpdate.add(atj);
                        }
                    }
                }
            }
        }

        if(!toUpdate.isEmpty()) {
            List<Database.SaveResult> results = Database.update(toUpdate);
        }
    }

    public static void handlePrescription(List<String> accountTreatmentIds, List<String> prescriptionIds) {
        List<String> prescriptionFields = new List<String>();
	    List<String> accountTreatmentFields = new List<String>();
        List<Account_Treatment__c> toUpdate = new List<Account_Treatment__c>();

        List<AccountTreatmentPrescriptionMapping__mdt> fieldsfrommetadata = ATPrescriptionMappingmdtDAO.ATPrescriptionMappingmdtfields();

        if(fieldsfrommetadata != null && !fieldsfrommetadata.isEmpty()) {
            //list the prescription fields from metadata
            for (Integer i = 0; i < fieldsfrommetadata.size(); i++){
                prescriptionFields.add(fieldsfrommetadata[i].Prescription_Field__c);
            }
            //list the account treatments fields from the metadata
            for (Integer i = 0; i < fieldsfrommetadata.size(); i++){
                accountTreatmentFields.add(fieldsfrommetadata[i].Account_Treatment_Field__c);
            }
        }

        List<Account_Treatment__c> queriedAccountTreatments = AccountTreatmentDAO.getaccounttreatmentfieldvaluesforatids(accountTreatmentFields, accountTreatmentIds);
        List<Prescription__c> queriedPrescriptions = PrescriptionDAO.getPrescriptionsvaluesbyprescriptionfields(prescriptionFields, prescriptionIds);

        if(queriedAccountTreatments != null && queriedPrescriptions != null) {
            for (Integer i = 0; queriedAccountTreatments.size() > i; i++){
                for (Integer j = 0; queriedPrescriptions.size() > j; j++){
                    if (queriedAccountTreatments[i].Prescription__c == queriedPrescriptions[j].Id){
                        Account_Treatment__c accounttreatmentstoupdate = ATPrescriptionMappingTriggerHelper.ATPrescriptionMappingTriggerHelperwithId(
                            queriedPrescriptions[j], 
                            queriedAccountTreatments[i], 
                            prescriptionFields, 
                            accountTreatmentFields
                        );
                        toUpdate.add(accounttreatmentstoupdate);
                    }
                }
            }
        }

		upsert toUpdate;
    }

    public static void updateElectricityCostsDesired(List<Account_Treatment__c> accountTreatments) {
        List<String> CTQueryFields = new List<String>{'Id','Electricity_Rebates__c '};

        List<String> atcontracttreatmentids = new List<String>();
        List<Contract_Treatment__c> ContractTreatments = new List<Contract_Treatment__c>();

        Map<Id, String> ctidsandelectricity = new Map<Id, String>();

        for(Account_Treatment__c at : accountTreatments) {
            if(at.Contract_Treatment__c != null) {
                atcontracttreatmentids.add(at.Contract_Treatment__c);
            }
        }

        if(!atcontracttreatmentids.isEmpty()) {
            ContractTreatments = ContractTreatmentDAO.getContractTreatmentsFromIds(CTQueryFields,atcontracttreatmentids);

            if(!ContractTreatments.isEmpty()) {
                for(Integer i=0 ; i<ContractTreatments.size() ; i++ ) {
                    ctidsandelectricity.put(ContractTreatments[i].Id ,String.valueOf(ContractTreatments[i].Electricity_Rebates__c)) ;
                }

                for(Account_Treatment__c at : accountTreatments) {
                    at.electricity_costs_desired__c = ctidsandelectricity.get(at.Contract_Treatment__c);
                }
            }
        }
    }

    public static void setTreatmentModality(List<Account_Treatment__c> accountTreatments) {
        List<String> CTModalityQueryFields = new List<String>{'Sub_Treatment__c', 'Installation_Type__c', 'Contract_Treatment__c'};

        List<String> contractTreatmentIds = new List<String>();
        List<String> treatments = new List<String>();
        List<String> installationTypes = new List<String>();
        List<Contract_Treatment_Modality__c> allCTMs = new List<Contract_Treatment_Modality__c>();

        Map<String, List<Contract_Treatment_Modality__c>> treatmentCTMMap = new Map<String, List<Contract_Treatment_Modality__c>>();
        Map<String, List<Contract_Treatment_Modality__c>> instTypeCTMMap = new Map<String, List<Contract_Treatment_Modality__c>>();
        Map<String, List<Contract_Treatment_Modality__c>> treatmentInstTypeCTMMap = new Map<String, List<Contract_Treatment_Modality__c>>();

        for(Account_Treatment__c at : accountTreatments) {
            if(at.Contract_Treatment__c != null) {
                contractTreatmentIds.add(at.Contract_Treatment__c);
            }
            if(at.Treatment__c != null) {
                treatments.add(at.Treatment__c);
            }
            if(at.Installation_Type__c != null) {
                installationTypes.add(at.Installation_Type__c);
            }
        }

        if(!contractTreatmentIds.isEmpty() && (!treatments.isEmpty() || !installationTypes.isEmpty())) {
            allCTMs = ContractTreatmentModalityDAO.getCTModalitiesForATTreatmentModality(CTModalityQueryFields, contractTreatmentIds, treatments, installationTypes);

            if(!allCTMs.isEmpty()) {
                for(Contract_Treatment_Modality__c ctm : allCTMs) {
                    if(ctm.Sub_Treatment__c != null && ctm.Installation_Type__c != null) {
                        if(treatmentInstTypeCTMMap.get(String.valueOf(ctm.Contract_Treatment__c) + '_' + String.valueOf(ctm.Sub_Treatment__c) + '_' + 
                        String.valueOf(ctm.Installation_Type__c)) == null) {
                            treatmentInstTypeCTMMap.put(String.valueOf(ctm.Contract_Treatment__c) + '_' + String.valueOf(ctm.Sub_Treatment__c) + '_' + 
                            String.valueOf(ctm.Installation_Type__c), new List<Contract_Treatment_Modality__c>());
                        }
                        treatmentInstTypeCTMMap.get(String.valueOf(ctm.Contract_Treatment__c) + '_' + String.valueOf(ctm.Sub_Treatment__c) + '_' + 
                        String.valueOf(ctm.Installation_Type__c)).add(ctm);
                    }
                    if(ctm.Sub_Treatment__c != null) {
                        if(treatmentCTMMap.get(String.valueOf(ctm.Contract_Treatment__c) + '_' + String.valueOf(ctm.Sub_Treatment__c)) == null) {
                            treatmentCTMMap.put(String.valueOf(ctm.Contract_Treatment__c) + '_' + String.valueOf(ctm.Sub_Treatment__c), 
                            new List<Contract_Treatment_Modality__c>());
                        }
                        treatmentCTMMap.get(String.valueOf(ctm.Contract_Treatment__c) + '_' + String.valueOf(ctm.Sub_Treatment__c)).add(ctm);
                    }
                    if(ctm.Installation_Type__c != null) {
                        if(instTypeCTMMap.get(String.valueOf(ctm.Contract_Treatment__c) + '_' + String.valueOf(ctm.Installation_Type__c)) == null) {
                            instTypeCTMMap.put(String.valueOf(ctm.Contract_Treatment__c) + '_' + String.valueOf(ctm.Installation_Type__c), 
                            new List<Contract_Treatment_Modality__c>());
                        }
                        instTypeCTMMap.get(String.valueOf(ctm.Contract_Treatment__c) + '_' + String.valueOf(ctm.Installation_Type__c)).add(ctm);
                    }
                }

                for(Account_Treatment__c accountTreatment : accountTreatments) {
                    List<Contract_Treatment_Modality__c> relatedCTMList;

                    if(accountTreatment.Treatment__c != null && accountTreatment.Installation_Type__c != null) {
                        relatedCTMList = treatmentInstTypeCTMMap.get(
                            String.valueOf(accountTreatment.Contract_Treatment__c) + '_' + 
                            String.valueOf(accountTreatment.Treatment__c) + '_' + 
                            String.valueOf(accountTreatment.Installation_Type__c)
                        );

                        if(relatedCTMList == null) {
                            relatedCTMList = treatmentCTMMap.get(
                                String.valueOf(accountTreatment.Contract_Treatment__c) + '_' + 
                                String.valueOf(accountTreatment.Treatment__c)
                            );

                            if(relatedCTMList == null) {
                                relatedCTMList = instTypeCTMMap.get(
                                    String.valueOf(accountTreatment.Contract_Treatment__c) + '_' + 
                                    String.valueOf(accountTreatment.Installation_Type__c)
                                );
                            }
                        }
                    }
                    else if(accountTreatment.Treatment__c != null && accountTreatment.Installation_Type__c == null) {
                        relatedCTMList = treatmentCTMMap.get(
                            String.valueOf(accountTreatment.Contract_Treatment__c) + '_' + 
                            String.valueOf(accountTreatment.Treatment__c)
                        );
                    }
                    else if(accountTreatment.Treatment__c == null && accountTreatment.Installation_Type__c != null) {
                        relatedCTMList = instTypeCTMMap.get(
                            String.valueOf(accountTreatment.Contract_Treatment__c) + '_' + 
                            String.valueOf(accountTreatment.Installation_Type__c)
                        );
                    }

                    if(relatedCTMList != null && !relatedCTMList.isEmpty()) {
                        accountTreatment.Treatment_Modality__c = relatedCTMList[0].Id;
                    }
                }
            }
        }
    }
}