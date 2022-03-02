// By Antonio

public class ATMainComponentService {
    
    public static Boolean checkForAddressSelectionPage(Id accountTreatmentId) {
        
        List<String> queryFieldsForAT = new List<String>{'RecordType.DeveloperName', 'Prescription__r.Received_date__c', 
        '(SELECT Id FROM Account_Treatment_Jobs__r)'};
        List<String> queryFields = new List<String>{'Id'};

        List<WorkOrder> relatedWorkOrders = new List<WorkOrder>();
        List<Task> relatedTasks = new List<Task>();
        List<String> ATJIds = new List<String>();

        Account_Treatment__c accountTreatment = AccountTreatmentDAO.getAccountTreatmentFromId(queryFieldsForAT, accountTreatmentId);

        if(accountTreatment.Account_Treatment_Jobs__r != null) {
            for(Account_Treatment_Job__c atj : accountTreatment.Account_Treatment_Jobs__r) {
                ATJIds.add(atj.Id);
            }
        }

        String recordType = accountTreatment.RecordType.DeveloperName;
        System.debug('RecordType: ' + recordType);
        Datetime prescriptionReceivedDate = accountTreatment.Prescription__r.Received_date__c;
        System.debug('PrescriptionReceivedDate: ' + prescriptionReceivedDate);

        try {
            relatedWorkOrders = WorkOrderDAO.getWorkOrdersFromAccountTreatment(queryFields, accountTreatmentId);
            System.debug('RelatedWorkOrders size: ' + relatedWorkOrders.size());
        }
        catch(Exception e) {
            System.debug('Exception, no records found');
        }

        try {
            relatedTasks = TaskDAO.getTasksFromATJIds(queryFields, ATJIds);
            System.debug('RelatedTasks size: ' + relatedTasks.size());
        }
        catch(Exception e) {
            System.debug('Exception, no records found');
        }

        // Condition to show the AccountTreatmentAddressSelection page
        if(relatedWorkOrders.size() == 0 && 
        relatedTasks.size() == 0) {
            return true;
        }

        return false;
    }

    public static Map<Account_Treatment_Job__c, Contract_Treatment_Job_SLA__c> checkRequirements(Id accountTreatmentId, Boolean onlyAutoscheduled) {
        List<String> queryFields = new List<String>{'Scheduling_Rule__c', 'Work_Order__c', 'Task__c', 'Contract_Treatment_Job__c', 'Patient_Treatment__r.Account__c',
        'Patient_Treatment__c', 'Patient_Treatment__r.Contract_Treatment__c', 'Name', 'Case_Subtype__c', 'Case_Type__c', 'Patient_Treatment__r.Treatment_Type__c',
        'Contract_Treatment_Job__r.Contract_Framework__r.Customer__c', 
        'Contract_Treatment_Job__r.Contract_Framework__r.Branch_of_belonging_sales_office__c', 'Contract_Treatment_Job__r.Contract_Framework__c', 
        'Contract_Treatment_Job__r.Contract_Treatment__c', 'Delivery_Channel__c', 
        'Contract_Treatment_Job__r.Contract_Framework__r.Price_list_code__c',
        'Patient_Treatment__r.Customer_Purchase_Date__c', 'Patient_Treatment__r.Customer_Purchase_Order_Number__c', 'Patient_Treatment__r.Account__r.FirstName',
        'Patient_Treatment__r.Account__r.LastName', 'Work_Type__c', 'Patient_Treatment__r.Account__r.IsPersonAccount', 'Patient_Treatment__r.Account__r.Name',
        'Patient_Treatment__r.Account__r.PersonContactId', 'Frequency__c', 'Frequency_Unit_of_measure__c', 'Patient_Treatment__r.Prescription__r.CreatedDate',
        'Patient_Treatment__r.Prescription__r.Received_Date__c', 'Contract_Treatment_Job__r.Contract_Framework__r.Attachment_Addendum_Type__c',
        'Contract_Treatment_Job__r.Contract_Framework__r.Billing_Via__c', 'Contract_Treatment_Job__r.Contract_Framework__r.Customer__r.Customer_Purchase_Order_Date__c',
        'Contract_Treatment_Job__r.Contract_Framework__r.Customer_Purchase_Order_Date__c', 
        'Contract_Treatment_Job__r.Contract_Framework__r.Customer__r.Customer_Purchase_Order_Number__c',
        'Contract_Treatment_Job__r.Contract_Framework__r.Customer_Purchase_Order_Number__c', 
        'Contract_Treatment_Job__r.Contract_Framework__r.Customer__r.Billing_Reference__c', 'Contract_Treatment_Job__r.Contract_Framework__r.Customer_Request_Code__c',
        'Contract_Treatment_Job__r.Contract_Framework__r.Invoice_splitting_criterion__c', 'Contract_Treatment_Job__r.Contract_Framework__r.Invoice_Layout__c',
        'Contract_Treatment_Job__r.Invoice_Splitting_Group__c', 'Patient_Treatment__r.Customer_Request_Code__c', 
        'Patient_Treatment__r.Contract_Treatment__r.Invoice_Splitting_Group__c', 'Customer_Product_Code__c', 'Scheduling_Time_Frame__c', 'Frequency_Type__c'};

        List<Account_Treatment_Job__c> eligibleATJs = new List<Account_Treatment_Job__c>();

        List<Account_Treatment_Job__c> relatedATJs = AccountTreatmentJobDAO.getATJsFromAT(queryFields, accountTreatmentId);

        for(Account_Treatment_Job__c atj : relatedATJs) {
            if(atj.Work_Order__c == true | atj.Task__c == true) {
                if(onlyAutoscheduled) {
                    if(atj.Scheduling_Rule__c == 'Autoscheduled') {
                        eligibleATJs.add(atj);
                    }
                }
                else {
                    eligibleATJs.add(atj);
                }
            }
        }
        
        return getATJtoSLAMap(eligibleATJs);
    }

    public static List<Case> createCases(Map<Account_Treatment_Job__c, Contract_Treatment_Job_SLA__c> ATJtoSLAMap, Database.DMLOptions DMLOptions,
    Boolean isFullScheduling, Integer autoschedulingPeriodInDays) {
        System.debug('----- createCases -----');

        Set<Account_Treatment_Job__c> ATJs = ATJtoSLAMap.keySet();
        List<Case> toInsert = new List<Case>();

        // The first Case is only created if the schedulation period is full (no starting Case already present). Otherless, every Case will be scheduled below

        for(Account_Treatment_Job__c atj : ATJs) {
            Integer schedulingTimeFrame = (Integer) ((atj.Scheduling_Time_Frame__c != null) ? atj.Scheduling_Time_Frame__c : 365);
            Case newCase;

            if(isFullScheduling || autoschedulingPeriodInDays == schedulingTimeFrame) {
                newCase = new Case(
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

                toInsert.add(newCase);
            }

            // Creating the autoscheduled Cases: WO and Tasks will later be assigned to each of these Cases

            if(atj.Frequency__c != null/*  && atj.Scheduling_Time_Frame__c != null && atj.Frequency_Type__c != null */) {
                Decimal numberOfDays = (Decimal) ((autoschedulingPeriodInDays != null) ? autoschedulingPeriodInDays : schedulingTimeFrame);
                Integer numberOfCasesToCreate;

                if(/* atj.Frequency_Type__c == 'NPU' */ atj.Frequency_Type__c != 'IB') {
                    // The numberOfCasesToCreate is rounded basing on numberOfDays / (number of days in the period) (Week, Month, Year)

                    if(atj.Frequency_Unit_of_measure__c == 'Day') {
                        numberOfCasesToCreate = (Integer) (numberOfDays * atj.Frequency__c);
                    }
                    else if(atj.Frequency_Unit_of_measure__c == 'Week') {
                        numberOfCasesToCreate = (Integer) ((numberOfDays / 7) * atj.Frequency__c).round(System.RoundingMode.HALF_UP);
                    }
                    else if(atj.Frequency_Unit_of_measure__c == 'Month') {
                        numberOfCasesToCreate = (Integer) ((numberOfDays / 30) * atj.Frequency__c).round(System.RoundingMode.HALF_UP);
                    }
                    else if(atj.Frequency_Unit_of_measure__c == 'Year') {
                        numberOfCasesToCreate = (Integer) ((numberOfDays / 365) * atj.Frequency__c).round(System.RoundingMode.HALF_UP);
                    }
                }
                else/*  if(atj.Frequency_Type__c == 'IB') */ {
                    numberOfCasesToCreate = (Integer) (numberOfDays / atj.Frequency__c).round(System.RoundingMode.HALF_UP);

                    if(atj.Frequency_Unit_of_measure__c == 'Day') {
                        numberOfCasesToCreate = (Integer) (numberOfDays / atj.Frequency__c).round(System.RoundingMode.HALF_UP);
                    }
                    else if(atj.Frequency_Unit_of_measure__c == 'Week') {
                        numberOfCasesToCreate = (Integer) (numberOfDays / (atj.Frequency__c * 7)).round(System.RoundingMode.HALF_UP);
                    }
                    else if(atj.Frequency_Unit_of_measure__c == 'Month') {
                        numberOfCasesToCreate = (Integer) (numberOfDays / (atj.Frequency__c * 30)).round(System.RoundingMode.HALF_UP);
                    }
                    else if(atj.Frequency_Unit_of_measure__c == 'Year') {
                        numberOfCasesToCreate = (Integer) (numberOfDays / (atj.Frequency__c * 365)).round(System.RoundingMode.HALF_UP);
                    }
                }

                // If the first Case hasn't been created yet, I have to create it too
                    
                if(newCase != null) {
                    numberOfCasesToCreate = numberOfCasesToCreate - 1;
                }

                System.debug('numberOfCasesToCreate: ' + numberOfCasesToCreate);

                if(numberOfCasesToCreate != null) {
                    for(Integer i = 0; i < numberOfCasesToCreate; i++) {
                        Case scheduledCase = new Case(
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
                            scheduledCase.ContactId = atj.Patient_Treatment__r.Account__r.PersonContactId;
                        }

                        scheduledCase.setOptions(DMLOptions);

                        toInsert.add(scheduledCase);
                    }
                }
            }
        }

        System.debug('CREATECASES, toInsert: ' + toInsert);
        return toInsert;
    }

    public static List<WorkOrder> createWorkOrders(Map<Account_Treatment_Job__c,Contract_Treatment_Job_SLA__c> ATJToSLAMap, List<Case> newCases,
    Datetime startDateForSales, Boolean startDateIsDueDate) {
        System.debug('----- createWorkOrders -----');

        List<String> queryFields = new List<String>{'Location__c', 'Location__r.VisitorAddress.City', 
        'Location__r.VisitorAddress.Country', 'Location__r.VisitorAddress.CountryCode', 'Location__r.VisitorAddress.Latitude', 
        'Location__r.VisitorAddress.Longitude', 'Location__r.VisitorAddress.PostalCode', 'Location__r.VisitorAddress.State', 
        'Location__r.VisitorAddress.StateCode', 'Location__r.VisitorAddress.Street', 'Account_Treatment__c'};

        List<String> queryFieldsForProducts = new List<String>{'Product__c', 'Quantity__c', 'Customer_Treatment_Alias__c', 'Patient_Treatment_Job__c',
        'Customer_Request_Code__c', 'Storage_Location__c', 'Plant__c', 'Purchase_order_number__c', 'Purchase_order_date__c', 
        'Contract_Treatment_Job_Product__r.Invoice_Splitting_group__c', 'Asset__c', 'Asset__r.SerialNumber'};

        List<String> queryFieldsForPBEntry = new List<String>{'Product2Id', 'Pricebook2Id'};

        List<String> queryFieldsForASO = new List<String>{'Sales_Organization__r.Code__c', 'Division__c', 'Distribution_Channel__c', 'Sales_Group__c',
        'Sales_Office__c'};

        Set<Account_Treatment_Job__c> ATJs = ATJToSLAMap.keySet();
        List<Account_Treatment_Job__c> workOrderATJs = new List<Account_Treatment_Job__c>();
        List<Id> workOrderATJsIds = new List<Id>();
        List<Id> pricebookIds = new List<Id>();
        List<WorkOrder> toInsert = new List<WorkOrder>();
        List<Id> relatedASOIds = new List<Id>();
        List<Id> relatedATIds = new List<Id>();

        Map<Id, List<Case>> ATJToCasesMap = new Map<Id, List<Case>>();
        Map<Id, List<Account_Treatment_Job_Product__c>> jobToProductsMap = new Map<Id, List<Account_Treatment_Job_Product__c>>();
        Map<Id, List<PricebookEntry>> pricebookIdToPEMap = new Map<Id, List<PricebookEntry>>();
        Map<Id, Account_Treatment_Job__c> ATJMap = new Map<Id, Account_Treatment_Job__c>();
        Map<Id, Account_Sales_Organization__c> ASOMap = new Map<Id, Account_Sales_Organization__c>();
        Map<Id, Account_Treatment_Address__c> ATIdToDefaultATAMap = new Map<Id, Account_Treatment_Address__c>();

        BusinessHours bh = [SELECT Id, MondayStartTime, MondayEndTime, TuesdayStartTime, TuesdayEndTime, WednesdayStartTime, WednesdayEndTime,
                            ThursdayStartTime, ThursdayEndTime, FridayStartTime, FridayEndTime, SaturdayStartTime, SaturdayEndTime, SundayStartTime, SundayEndTime  
                            FROM BusinessHours WHERE Name = 'NL'];
        Id businessHoursId = bh.Id;

        DocumentType__mdt therapyDocumentType = [SELECT Code__c FROM DocumentType__mdt WHERE DeveloperName = 'Therapy'];

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
            ATJMap.put(atj.Id, atj);
            workOrderATJsIds.add(atj.Id);
            relatedATIds.add(atj.Patient_Treatment__c);
        }

        List<Account_Treatment_Address__c> allDefaultAddresses = AccountTreatmentAddressDAO.getDefaultATAFromATs(queryFields, relatedATIds);

        for(Account_Treatment_Address__c ata : allDefaultAddresses) {
            ATIdToDefaultATAMap.put(ata.Account_Treatment__c, ata);
        }

        List<Account_Treatment_Job_Product__c> allProducts = AccountTreatmentJobProductDAO.getActiveProductsFromATJs(queryFieldsForProducts, workOrderATJsIds);

        for(Account_Treatment_Job__c atj : workOrderATJs) {
            pricebookIds.add(atj.Contract_Treatment_Job__r.Contract_Framework__r.Price_list_code__c);
        }
        
        // Getting all the pricebookEntries --> The pricebookEntry related to each Account_Treatment_Job__c

        List<PricebookEntry> allPricebookEntries = PricebookEntryDAO.getPEFromPricebookIds(queryFieldsForPBEntry, pricebookIds);

        if(!allPricebookEntries.isEmpty()) {
            for(PricebookEntry pe : allPricebookEntries) {
                if(pricebookIdToPEMap.get(pe.Pricebook2Id) == null) {
                    pricebookIdToPEMap.put(pe.Pricebook2Id, new List<PricebookEntry>());
                }
                pricebookIdToPEMap.get(pe.Pricebook2Id).add(pe);
            }
        }

        // jobToProductMap links an Account_Treatment_Job__c Id to its Account_Treatment_Job_Products

        if(!allProducts.isEmpty()) {
            for(Account_Treatment_Job_Product__c atjp : allProducts) {
                if(jobToProductsMap.get(atjp.Patient_Treatment_Job__c) == null) {
                    jobToProductsMap.put(atjp.Patient_Treatment_Job__c, new List<Account_Treatment_Job_Product__c>());
                }
                jobToProductsMap.get(atjp.Patient_Treatment_Job__c).add(atjp);
            }
        }

        for(Account_Treatment_Job__c atj : workOrderATJs) {
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

            // Getting Default ATA related to related AT
            Account_Treatment_Address__c defaultAddress = ATIdToDefaultATAMap.get(atj.Patient_Treatment__c);

            // Getting the related ASO
            Account_Sales_Organization__c relatedASO = ASOMap.get(atj.Contract_Treatment_Job__r.Contract_Framework__r.Branch_of_belonging_sales_office__c);

            // These are the Cases previously created related to this ATJ
            List<Case> relatedCases = ATJToCasesMap.get(atj.Id);

            // The first WO created will be assigned to the first Case
            Case firstCase = relatedCases[0];

            // These are the Cases that will be assigned to the WOs that will be autoscheduled later
            List<Case> remainingCases = relatedCases;
            remainingCases.remove(0);

            Contract_Treatment_Job_SLA__c relatedSLA = ATJToSLAMap.get(atj);
            
            // Getting startDate, endDate and dueDate: if the process starts from a Sales AT, I'm using startDateForSales instead of Prescription's received Date

            DatesResponseDTO relatedDates;

            if(startDateForSales == null) {
                relatedDates = calculateDates(
                    atj.Patient_Treatment__r.Prescription__r.Received_Date__c, 
                    relatedSLA.Max_Time__c, 
                    relatedSLA.Unite_of_measure_Max_Time__c, // To fix, unit not unite
                    relatedSLA.Calculation_Mode__c, 
                    relatedSLA.Offset_Start_Date__c, 
                    relatedSLA.Offset_End_Date__c, 
                    relatedSLA.Offset_unit_of_measure__c, 
                    relatedSLA.Offset_calculation_mode__c,
                    bh,
                    startDateIsDueDate
                );
            }
            else {
                relatedDates = calculateDates(
                    startDateForSales, 
                    relatedSLA.Max_Time__c, 
                    relatedSLA.Unite_of_measure_Max_Time__c, // To fix, unit not unite
                    relatedSLA.Calculation_Mode__c, 
                    relatedSLA.Offset_Start_Date__c, 
                    relatedSLA.Offset_End_Date__c, 
                    relatedSLA.Offset_unit_of_measure__c, 
                    relatedSLA.Offset_calculation_mode__c,
                    bh,
                    startDateIsDueDate
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
                Job_Product_Code__c = atj.Customer_Product_Code__c,

                // Fields from the selected ATA

                LocationId = defaultAddress.Location__c,
                City = defaultAddress.Location__r.VisitorAddress.City,
                Country = defaultAddress.Location__r.VisitorAddress.Country,
                CountryCode = defaultAddress.Location__r.VisitorAddress.CountryCode,
                Latitude = defaultAddress.Location__r.VisitorAddress.Latitude,
                Longitude = defaultAddress.Location__r.VisitorAddress.Longitude,
                PostalCode = defaultAddress.Location__r.VisitorAddress.PostalCode,
                State = defaultAddress.Location__r.VisitorAddress.State,
                StateCode = defaultAddress.Location__r.VisitorAddress.StateCode,
                Street = defaultAddress.Location__r.VisitorAddress.Street,

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

            // Fields from relatedASO

            if(relatedASO != null) {
                newWorkOrder.SalesOrganization__c = relatedASO.Sales_Organization__r.Code__c;
                newWorkOrder.Division__c = relatedASO.Division__c;
                newWorkOrder.Distribution_Channel__c = relatedASO.Distribution_Channel__c;
                newWorkOrder.Sales_Group__c = relatedASO.Sales_Group__c;
                newWorkOrder.Sales_Office__c = relatedASO.Sales_Office__c;
            }

            toInsert.add(newWorkOrder);

            if(firstCase.Start_Date__c == null/* || firstCase.Start_Date__c > newWorkOrder.StartDate*/) {
                firstCase.Start_Date__c = newWorkOrder.StartDate;
                firstCase.Next_Activity_Date__c = firstCase.Start_Date__c;
            }

            // Autoscheduling - 31/05/21: the unitOfMeasureInYear parameter is not indicative anymore: the method will schedule until there are Cases to schedule for

            if(atj.Frequency__c != null/*  && atj.Scheduling_Time_Frame__c != null && atj.Frequency_Type__c != null */) {
                WorkOrder startingWorkOrder = newWorkOrder;

                // Day Autoscheduling

                if(atj.Frequency_Unit_of_measure__c == 'Day') {
                    List<WorkOrder> newWorkOrders = autoscheduleWorkOrders(atj, startingWorkOrder, relatedSLA, 365, remainingCases, bh, true);

                    for(WorkOrder wo : newWorkOrders) {
                        toInsert.add(wo);
                    }
                }

                // Week Autoscheduling

                else if(atj.Frequency_Unit_of_measure__c == 'Week') {
                    List<WorkOrder> newWorkOrders = autoscheduleWorkOrders(atj, startingWorkOrder, relatedSLA, 52, remainingCases, bh, true);

                    for(WorkOrder wo : newWorkOrders) {
                        toInsert.add(wo);
                    }
                }

                // Month Autoscheduling

                else if(atj.Frequency_Unit_of_measure__c == 'Month') {
                    List<WorkOrder> newWorkOrders = autoscheduleWorkOrders(atj, startingWorkOrder, relatedSLA, 12, remainingCases, bh, true);

                    for(WorkOrder wo : newWorkOrders) {
                        toInsert.add(wo);
                    }
                }

                // Year Autoscheduling

                else if(atj.Frequency_Unit_of_measure__c == 'Year') {
                    List<WorkOrder> newWorkOrders = autoscheduleWorkOrders(atj, startingWorkOrder, relatedSLA, 1, remainingCases, bh, true);

                    for(WorkOrder wo : newWorkOrders) {
                        toInsert.add(wo);
                    }
                }
            }
        }

        if(!toInsert.isEmpty()) {
            insert toInsert;
        }

        // Updating the Cases, because the Start_Date__c of each Case has become the StartDate of each WO

        if(!newCases.isEmpty()) {
            update newCases;
        }

        if (!System.isBatch()){
            if(!ATJMap.isEmpty() && !jobToProductsMap.isEmpty() && !pricebookIdToPEMap.isEmpty() && !toInsert.isEmpty()) {
                WOLICreationBatch WOLICreation = new WOLICreationBatch();

                WOLICreation.ATJMap = ATJMap;
                WOLICreation.jobToProductsMap = jobToProductsMap;
                WOLICreation.pricebookIdToPEMap = pricebookIdToPEMap;
                WOLICreation.workOrders = toInsert;

                Database.executeBatch(WOLICreation, 3);
            }
        }

        return toInsert;
    }

    public static List<Task> createTasks(Map<Account_Treatment_Job__c,Contract_Treatment_Job_SLA__c> ATJToSLAMap, List<Case> newCases, BusinessHours bh,
    Boolean usePrescription, WorkOrder closedWorkOrder, Task closedTask, Datetime startDateForSales, Boolean startDateIsDueDate, Map<Id, Task> ATJIdToStartingTaskMap) {

        System.debug('----- ATMainComponentService.createTasks -----');
        System.debug('newCases: ' + newCases);
        System.debug('closedWorkOrder: ' + closedWorkOrder);
        Set<Account_Treatment_Job__c> ATJs = ATJToSLAMap.keySet();
        List<Account_Treatment_Job__c> taskATJs = new List<Account_Treatment_Job__c>();
        Map<Id, List<Case>> ATJToCasesMap = new Map<Id, List<Case>>();
        List<Task> toInsert = new List<Task>();

        Id businessHoursId = bh.Id;

        if(!newCases.isEmpty()) {
            for(Case c : newCases) {
                if(ATJToCasesMap.get(c.Account_Treatment_Job__c) == null) {
                    ATJToCasesMap.put(c.Account_Treatment_Job__c, new List<Case>());
                }
                ATJToCasesMap.get(c.Account_Treatment_Job__c).add(c);
            }
        }

        for(Account_Treatment_Job__c atj : ATJs) {
            if(atj.Task__c == true) {
                taskATJs.add(atj);
            }
        }

        for(Account_Treatment_Job__c atj : taskATJs) {
            Task newTask;
            Contract_Treatment_Job_SLA__c relatedSLA = ATJToSLAMap.get(atj);

            // Checking whether a startingTask is already present (i.e. frequency update case)

            if(ATJIdToStartingTaskMap != null) {
                newTask = ATJIdToStartingTaskMap.get(atj.Id);
            }

            // Previously created Cases related to this ATJ

            List<Case> relatedCases = ATJToCasesMap.get(atj.Id);

            // First Task is assigned to first Case
            
            Case firstCase = relatedCases[0];

            // These Cases will be the ones to which the future scheduled Tasks will be assigned to

            List<Case> remainingCases = relatedCases;

            if(newTask == null) {
                remainingCases.remove(0);

                // Getting startDate, endDate and dueDate

                DatesResponseDTO relatedDates;
                
                if(usePrescription == true && closedWorkOrder == null && closedTask == null) {
                    relatedDates = calculateDates(
                        atj.Patient_Treatment__r.Prescription__r.Received_Date__c, 
                        (Integer) relatedSLA.Task_MaxTime_Execution__c, 
                        relatedSLA.Task_Unite_of_measure_Max_Time__c, // To fix, unit not unite
                        relatedSLA.Task_Calculation_Mode__c, 
                        (Integer) relatedSLA.Offset_Start_Date_Task__c, 
                        (Integer) relatedSLA.Offset_End_Date_Task__c, 
                        relatedSLA.Offset_unit_of_measure_Task__c, 
                        relatedSLA.Offset_calculation_mode_Task__c,
                        bh,
                        startDateIsDueDate
                    );
                }
                /* If this is being called from WorkOrderService.scheduleActivities, the EndDate of the closed WorkOrder will be used
                instead of the Prescription's received Date. If the Prescription is being used, the closedWorkOrder/Task parameter will be null.
                If the process starts from a Sales AT, then there will be no Prescription and no closed WorkOrderTask; there will be a 
                startDateForSales chosen from the User in the modal instead.
                */
                else if(usePrescription == false && closedWorkOrder != null && closedTask == null && startDateForSales == null) {
                    relatedDates = calculateDates(
                        closedWorkOrder.EndDate, 
                        (Integer) relatedSLA.Task_MaxTime_Execution__c, 
                        relatedSLA.Task_Unite_of_measure_Max_Time__c, // To fix, unit not unite
                        relatedSLA.Task_Calculation_Mode__c, 
                        (Integer) relatedSLA.Offset_Start_Date_Task__c, 
                        (Integer) relatedSLA.Offset_End_Date_Task__c, 
                        relatedSLA.Offset_unit_of_measure_Task__c, 
                        relatedSLA.Offset_calculation_mode_Task__c,
                        bh,
                        startDateIsDueDate
                    );
                }
                /* If this is being called from TaskService.scheduleActivities, the CompletedDateTime of the closed Task will be used
                instead of the Prescription's received Date. If the Prescription is being used, the closedWorkOrder and closedTask parameters will be null.
                If the process starts from a Sales AT, then there will be no Prescription and no closed WorkOrder/Task; there will be a 
                startDateForSales chosen from the User in the modal instead.
                */
                else if(usePrescription == false && closedWorkOrder == null && closedTask != null && startDateForSales == null) {
                    relatedDates = calculateDates(
                        closedTask.CompletedDateTime, 
                        (Integer) relatedSLA.Task_MaxTime_Execution__c, 
                        relatedSLA.Task_Unite_of_measure_Max_Time__c, // To fix, unit not unite
                        relatedSLA.Task_Calculation_Mode__c, 
                        (Integer) relatedSLA.Offset_Start_Date_Task__c, 
                        (Integer) relatedSLA.Offset_End_Date_Task__c, 
                        relatedSLA.Offset_unit_of_measure_Task__c, 
                        relatedSLA.Offset_calculation_mode_Task__c,
                        bh,
                        startDateIsDueDate
                    );
                }
                // If there's no Prescription to use and no Closed WorkOrder and no startDateForSales, we are in Maintenance Case: we need to use the current Datetime
                else if(usePrescription == false && closedWorkOrder == null && closedTask == null && startDateForSales == null) {
                    relatedDates = calculateDates(
                        Datetime.now(), 
                        (Integer) relatedSLA.Task_MaxTime_Execution__c, 
                        relatedSLA.Task_Unite_of_measure_Max_Time__c, // To fix, unit not unite
                        relatedSLA.Task_Calculation_Mode__c, 
                        (Integer) relatedSLA.Offset_Start_Date_Task__c, 
                        (Integer) relatedSLA.Offset_End_Date_Task__c, 
                        relatedSLA.Offset_unit_of_measure_Task__c, 
                        relatedSLA.Offset_calculation_mode_Task__c,
                        bh,
                        startDateIsDueDate
                    );
                }
                // If there's no Prescription to use, no closed WorkOrder and a startDateForSales, we are in Sales Case: we need to use the Date chosen by the User in the modal
                else if(usePrescription == false && closedWorkOrder == null && closedTask == null && startDateForSales != null) {
                    relatedDates = calculateDates(
                        startDateForSales, 
                        (Integer) relatedSLA.Task_MaxTime_Execution__c, 
                        relatedSLA.Task_Unite_of_measure_Max_Time__c, // To fix, unit not unite
                        relatedSLA.Task_Calculation_Mode__c, 
                        (Integer) relatedSLA.Offset_Start_Date_Task__c, 
                        (Integer) relatedSLA.Offset_End_Date_Task__c, 
                        relatedSLA.Offset_unit_of_measure_Task__c, 
                        relatedSLA.Offset_calculation_mode_Task__c,
                        bh,
                        startDateIsDueDate
                    );
                }

                Date dateConvertedDueDate = Date.newInstance((relatedDates.dueDate).year(), (relatedDates.dueDate).month(), (relatedDates.dueDate).day());
                newTask = new Task(
                    ActivityDate = dateConvertedDueDate,
                    WhatId = firstCase.Id,
                    Status = 'Open',
                    Subject = atj.Name,
                    Type = 'Follow Up',
                    TaskSubtype = 'Task',
                    Account__c = atj.Patient_Treatment__r.Account__c,
                    Type__c = 'Task',
                    Account_Treatment_Job__c = atj.Id,
                    Start_Date__c = relatedDates.startDate,
                    End_Date__c = relatedDates.endDate,
                    Due_Date__c = relatedDates.dueDate,
                    Autoscheduled__c = true,
                    Related_SLA__c = relatedSLA.Id
                );

                if(firstCase.OwnerId != null) {
                    newTask.OwnerId = firstCase.OwnerId;
                }

                if(atj.Patient_Treatment__r.Account__r.IsPersonAccount == true) {
                    newTask.WhoId = atj.Patient_Treatment__r.Account__r.PersonContactId;
                }

                if(usePrescription == false && closedWorkOrder == null && closedTask == null) {
                    newTask.Type = 'Call';
                }

                toInsert.add(newTask);
                System.debug('newTask: ' + newTask);

                //if(firstCase.Start_Date__c == null || firstCase.Start_Date__c > newTask.Start_Date__c) {
                    firstCase.Start_Date__c = Datetime.newInstance(newTask.ActivityDate, Time.newInstance(0,0,0,0));
                    firstCase.Next_Activity_Date__c = firstCase.Start_Date__c;
                //}
            }

            // Autoscheduling - 31/05/21: the unitOfMeasureInYear parameter is not indicative anymore: the method will schedule until there are Cases to schedule for

            if(atj.Frequency__c != null/*  && atj.Scheduling_Time_Frame__c != null && atj.Frequency_Type__c != null */) {
                Task startingTask = newTask;

                // Day Autoscheduling

                if(atj.Frequency_Unit_of_measure__c == 'Day') {
                    List<Task> newTasks = autoscheduleTasks(atj, startingTask, null, relatedSLA, 365, remainingCases, bh, true);

                    for(Task t : newTasks) {
                        toInsert.add(t);
                    }
                }

                // Week Autoscheduling 

                else if(atj.Frequency_Unit_of_measure__c == 'Week') {
                    List<Task> newTasks = autoscheduleTasks(atj, startingTask, null, relatedSLA, 52, remainingCases, bh, true);

                    for(Task t : newTasks) {
                        toInsert.add(t);
                    }
                }

                // Month Autoscheduling

                else if(atj.Frequency_Unit_of_measure__c == 'Month') {
                    List<Task> newTasks = autoscheduleTasks(atj, startingTask, null, relatedSLA, 12, remainingCases, bh, true);

                    for(Task t : newTasks) {
                        toInsert.add(t);
                    }
                }

                // Year Autoscheduling

                else if(atj.Frequency_Unit_of_measure__c == 'Year') {
                    List<Task> newTasks = autoscheduleTasks(atj, startingTask, null, relatedSLA, 1, remainingCases, bh, true);

                    for(Task t : newTasks) {
                        toInsert.add(t);
                    }
                }
            }
        }

        System.debug('toInsert TASK: ' + toInsert);
        return toInsert;

    }

    // startingCase is null if not needed (only needed from ActivitiesDatesAdjustmentService, because Task.WhatId is polymorphic and I need the check the Case Status)

    public static List<Task> autoscheduleTasks(Account_Treatment_Job__c atj, Task startingTask, Case startingCase, Contract_Treatment_Job_SLA__c relatedSLA, 
    Integer unitOfMeasureInYear, List<Case> remainingCases, BusinessHours businessHoursRecord, Boolean isFirstCreated) {
        List<Task> toInsert = new List<Task>();
        
        if(remainingCases != null && !remainingCases.isEmpty() && startingTask != null && atj != null && startingTask.Start_Date__c != null && 
        atj.Frequency_Unit_of_measure__c != null) {
            System.debug('----- autoscheduleTasks -----');
            System.debug('startingTask: ' + startingTask.Id);
            System.debug('startingTask.Start_Date__c: ' + startingTask.Start_Date__c);

            Id businessHoursId = businessHoursRecord.Id;
            Task previousTask = startingTask;
            Integer numberOfTasksToCreate;
            Integer gap;
            Integer schedulingTimeFrame = (Integer) ((atj.Scheduling_Time_Frame__c != null) ? atj.Scheduling_Time_Frame__c : 365);
            Integer daysInUnitOfMeasure;

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

            numberOfTasksToCreate = remainingCases.size();

            if(atj.Frequency_Type__c != 'IB') {
                Date dateConvertedStartDate = Date.newInstance((startingTask.Start_Date__c).year(), (startingTask.Start_Date__c).month(), (startingTask.Start_Date__c).day());
                Integer oneYearDifference = (dateConvertedStartDate).daysBetween(dateConvertedStartDate.addYears(1));

                /* if(schedulingTimeFrame <= 365) {
                    numberOfTasksToCreate = (Integer) (unitOfMeasureInYear * atj.Frequency__c);
                }
                else {
                    numberOfTasksToCreate = (Integer) ((schedulingTimeFrame / 365) * atj.Frequency__c); 
                } */
                //numberOfTasksToCreate = remainingCases.size();
                gap = (Integer) (oneYearDifference / ((Integer) (unitOfMeasureInYear * atj.Frequency__c)));
            }
            else if(atj.Frequency_Type__c == 'IB') {
                //numberOfTasksToCreate = remainingCases.size();
                //gap = (Integer) (atj.Scheduling_Time_Frame__c / numberOfTasksToCreate);

                /* if(isFirstCreated) {
                    gap = (Integer) (schedulingTimeFrame / (numberOfTasksToCreate + 1));
                }
                else {
                    gap = (Integer) (schedulingTimeFrame / numberOfTasksToCreate);
                } */

                gap = (Integer) (atj.Frequency__c * daysInUnitOfMeasure);
            }

            /* if(isFirstCreated == true) {
                numberOfTasksToCreate = numberOfTasksToCreate - 1;
            } */
            System.debug('NumberOfTasksToCreate::: ' + numberOfTasksToCreate);
            
            if(numberOfTasksToCreate != null) {
                for(Integer i = 0; i < numberOfTasksToCreate; i++) { // One has already been created 
                    try {
                        System.debug('Creating first Task...');
                        // Initially, each Case for each ATJ is identical. So I will simply go "1 to 1" with Cases and Tasks
                        Case relatedCase = remainingCases[i];
                        System.debug('relatedCase: ' + relatedCase);

                        Task dependentTask = new Task(
                            WhatId = relatedCase.Id,
                            Status = 'Open',
                            Subject = atj.Name,
                            Type = previousTask.Type,
                            TaskSubtype = 'Task',   
                            Account__c = atj.Patient_Treatment__r.Account__c,
                            Type__c = 'Task',
                            Account_Treatment_Job__c = atj.Id,
                            Autoscheduled__c = true,
                            Related_SLA__c = relatedSLA.Id
                        );

                        if(relatedCase.OwnerId != null) {
                            dependentTask.OwnerId = relatedCase.OwnerId;
                        }

                        if(atj.Patient_Treatment__r.Account__r.IsPersonAccount == true) {
                            dependentTask.WhoId = atj.Patient_Treatment__r.Account__r.PersonContactId;
                        }

                        Integer msInBusinessDay = 32400000;  // Milliseconds in 9 hours, a typical business day
                        Integer msInHour = 3600000;
                        Datetime toApplyGap = previousTask.Due_Date__c;

                        if(!isFirstCreated && i == 0 && startingCase != null && startingCase.Status == 'Closed') {
                            toApplyGap = previousTask.CompletedDateTime;
                        }

                        //dependentTask.Due_Date__c = (previousTask.ActivityDate).addDays(gap);

                        if(/* atj.Frequency_Type__c == 'NPU' */ atj.Frequency_Type__c != 'IB') {
                            dependentTask.Due_Date__c = (toApplyGap).addDays(gap);
                        }
                        else/*  if(atj.Frequency_Type__c == 'IB') */ {
                            if(atj.Frequency_Unit_of_measure__c == 'Day') {
                                dependentTask.Due_Date__c = (toApplyGap).addDays((Integer) atj.Frequency__c);
                            }
                            else if(atj.Frequency_Unit_of_measure__c == 'Week') {
                                dependentTask.Due_Date__c = (toApplyGap).addDays(7 * (Integer) atj.Frequency__c);
                            }
                            else if(atj.Frequency_Unit_of_measure__c == 'Month') {
                                dependentTask.Due_Date__c = (toApplyGap).addMonths((Integer) atj.Frequency__c);
                            }
                            else if(atj.Frequency_Unit_of_measure__c == 'Year') {
                                dependentTask.Due_Date__c = (toApplyGap).addYears((Integer) atj.Frequency__c);
                            }
                        }

                        System.debug('New Task DueDate: ' + dependentTask.Due_Date__c);

                        /* if(!BusinessHours.isWithin(businessHoursId, dependentTask.Due_Date__c)) {
                            dependentTask.Due_Date__c = BusinessHours.nextStartDate(businessHoursId, dependentTask.Due_Date__c);
                        } */

                        // If DueDate is within BusinessHours, I approximate it to the end of the business day. If not, I go back till the first business day

                        Date dueDateConverted = (dependentTask.Due_Date__c).date();
                        Datetime consideredDate = dependentTask.Due_Date__c;
                        Time endTime;

                        /* if(!BusinessHours.isWithin(businessHoursId, dependentWO.Due_Date__c)) {
                            dependentWO.Due_Date__c = BusinessHours.nextStartDate(businessHoursId, dependentWO.Due_Date__c);
                        } */

                        while(endTime == null) {
                            String dayOfWeekConsideredDate = (consideredDate).format('EEEE');
                            Time dayOfWeekEndTime;
                            System.debug('Considering date: ' + consideredDate);
                            System.debug('Day of week: ' + dayOfWeekConsideredDate);

                            switch on dayOfWeekConsideredDate {
                                when 'Monday' {
                                    dayOfWeekEndTime = businessHoursRecord.MondayEndTime;
                                }
                                when 'Tuesday' {
                                    dayOfWeekEndTime = businessHoursRecord.TuesdayEndTime;
                                }
                                when 'Wednesday' {
                                    dayOfWeekEndTime = businessHoursRecord.WednesdayEndTime;
                                }
                                when 'Thursday' {
                                    dayOfWeekEndTime = businessHoursRecord.ThursdayEndTime;
                                }
                                when 'Friday' {
                                    dayOfWeekEndTime = businessHoursRecord.FridayEndTime;
                                }
                                when 'Saturday' {
                                    dayOfWeekEndTime = businessHoursRecord.SaturdayEndTime;
                                }
                                when 'Sunday' {
                                    dayOfWeekEndTime = businessHoursRecord.SundayEndTime;
                                }
                            }

                            if(dayOfWeekEndTime != null) {
                                /* if(BusinessHours.isWithin(businessHoursId, Datetime.newInstance(consideredDate.date(), dayOfWeekEndTime))) {
                                    System.debug(Datetime.newInstance(consideredDate.date(), dayOfWeekEndTime) + ' is a Business Hour!');
                                    endTime = dayOfWeekEndTime;
                                }
                                else {
                                    System.debug(Datetime.newInstance(consideredDate.date(), dayOfWeekEndTime) + ' is NOT a Business Hour! Going 1 day back...');
                                    consideredDate = consideredDate.addDays(-1);
                                } */
                                endTime = dayOfWeekEndTime.addMinutes(-1);
                            }
                            else {
                                consideredDate = consideredDate.addDays(-1);
                            }
                        }

                        if(endTime != null) {
                            dependentTask.Due_Date__c = Datetime.newInstance(consideredDate.date(), endTime);
                        }

                        /* Date dueDateConverted = Date.newInstance((dependentTask.Due_Date__c).year(), (dependentTask.Due_Date__c).month(), (dependentTask.Due_Date__c).day());
                        dependentTask.ActivityDate = dueDateConverted; */
                        dependentTask.ActivityDate = (dependentTask.Due_Date__c).date();
                        
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

                            dependentTask.Start_Date__c = BusinessHours.addGmt(businessHoursId, (dependentTask.Due_Date__c), -toSubtract);

                            // Adding Offset to Due_Date (considering BH) to get End_Date__c

                            dependentTask.End_Date__c = BusinessHours.addGmt(businessHoursId, (dependentTask.Due_Date__c), toAdd);
                        }
                        else if(relatedSLA.Offset_calculation_mode_Task__c == 'Calendar') {

                            // Subtracting Offset from Due_Date without considering BH to get Start_Date__c

                            Integer toSubtract = (Integer) relatedSLA.Offset_Start_Date_Task__c;
                            if(relatedSLA.Offset_unit_of_measure_Task__c == 'Hour') {
                                dependentTask.Start_Date__c = (dependentTask.Due_Date__c).addHours(-toSubtract);
                            }
                            else if(relatedSLA.Offset_unit_of_measure_Task__c == 'Day') {
                                dependentTask.Start_Date__c = (dependentTask.Due_Date__c).addDays(-toSubtract);
                            }
                            else if(relatedSLA.Offset_unit_of_measure_Task__c == 'Week') {
                                dependentTask.Start_Date__c = (dependentTask.Due_Date__c).addDays(-(toSubtract * 7));
                            }
                            else if(relatedSLA.Offset_unit_of_measure_Task__c == 'Month') {
                                dependentTask.Start_Date__c = (dependentTask.Due_Date__c).addMonths(-toSubtract);
                            }

                            // Adjusting Start_Date__c if it falls outside the BHs

                            if(!BusinessHours.isWithin(businessHoursId, dependentTask.Start_Date__c)) {
                                dependentTask.Start_Date__c = BusinessHours.nextStartDate(businessHoursId, dependentTask.Start_Date__c);
                            }

                            // Adding Offset to Due_Date without considering BH to get End_Date__c

                            Integer toAdd = (Integer) relatedSLA.Offset_End_Date_Task__c;
                            if(relatedSLA.Offset_unit_of_measure_Task__c == 'Hour') {
                                dependentTask.End_Date__c = (dependentTask.Due_Date__c).addHours(toAdd);
                            }
                            else if(relatedSLA.Offset_unit_of_measure_Task__c == 'Day') {
                                dependentTask.End_Date__c = (dependentTask.Due_Date__c).addDays(toAdd);
                            }
                            else if(relatedSLA.Offset_unit_of_measure_Task__c == 'Week') {
                                dependentTask.End_Date__c = (dependentTask.Due_Date__c).addDays(toAdd * 7);
                            }
                            else if(relatedSLA.Offset_unit_of_measure_Task__c == 'Month') {
                                dependentTask.End_Date__c = (dependentTask.Due_Date__c).addMonths(toAdd);
                            }

                            // Adjusting End_Date__c if it falls outside the BHs

                            if(!BusinessHours.isWithin(businessHoursId, dependentTask.End_Date__c)) {
                                dependentTask.End_Date__c = BusinessHours.nextStartDate(businessHoursId, dependentTask.End_Date__c);
                            }
                        }

                        // Approximating StartDate and EndDate to the Start/End of Business Day

                        if(relatedSLA.Offset_unit_of_measure_Task__c == 'Day' || relatedSLA.Offset_unit_of_measure_Task__c == 'Week' || relatedSLA.Offset_unit_of_measure_Task__c == 'Month') {
                            String dayOfWeekStartDate = dependentTask.Start_Date__c.format('EEEE');
                            System.debug('dayOfWeekStartDate: ' + dayOfWeekStartDate);
                            String dayOfWeekEndDate = dependentTask.End_Date__c.format('EEEE');
                            System.debug('dayOfWeekEndDate: ' + dayOfWeekEndDate);

                            Date startDateConverted = Date.newInstance((dependentTask.Start_Date__c).year(), (dependentTask.Start_Date__c).month(), (dependentTask.Start_Date__c).day());
                            Date endDateConverted = Date.newInstance((dependentTask.End_Date__c).year(), (dependentTask.End_Date__c).month(), (dependentTask.End_Date__c).day());

                            // Getting the day of the week, then getting the StartTime of that day and rebuilding startDate with the same Date but with the new startTime

                            if(dayOfWeekStartDate == 'Monday') {
                                Time mondayStartTime = businessHoursRecord.MondayStartTime;
                                
                                dependentTask.Start_Date__c = Datetime.newInstance(startDateConverted, mondayStartTime);
                            }
                            else if(dayOfWeekStartDate == 'Tuesday') {
                                Time tuesdayStartTime = businessHoursRecord.TuesdayStartTime;

                                dependentTask.Start_Date__c = Datetime.newInstance(startDateConverted, tuesdayStartTime);
                            }
                            else if(dayOfWeekStartDate == 'Wednesday') {
                                Time wednesdayStartTime = businessHoursRecord.WednesdayStartTime;

                                dependentTask.Start_Date__c = Datetime.newInstance(startDateConverted, wednesdayStartTime);
                            }
                            else if(dayOfWeekStartDate == 'Thursday') {
                                Time thursdayStartTime = businessHoursRecord.ThursdayStartTime;

                                dependentTask.Start_Date__c = Datetime.newInstance(startDateConverted, thursdayStartTime);
                            }
                            else if(dayOfWeekStartDate == 'Friday') {
                                Time fridayStartTime = businessHoursRecord.FridayStartTime;

                                dependentTask.Start_Date__c = Datetime.newInstance(startDateConverted, fridayStartTime);
                            }

                            // Getting the day of the week, then getting the EndTime of that day and rebuilding endDate with the same Date but with the new endTime

                            if(dayOfWeekEndDate == 'Monday') {
                                Time mondayEndTime = businessHoursRecord.MondayEndTime;
                                
                                dependentTask.End_Date__c = Datetime.newInstance(endDateConverted, mondayEndTime);
                            }
                            else if(dayOfWeekEndDate == 'Tuesday') {
                                Time tuesdayEndTime = businessHoursRecord.TuesdayEndTime;

                                dependentTask.End_Date__c = Datetime.newInstance(endDateConverted, tuesdayEndTime);
                            }
                            else if(dayOfWeekEndDate == 'Wednesday') {
                                Time wednesdayEndTime = businessHoursRecord.WednesdayEndTime;

                                dependentTask.End_Date__c = Datetime.newInstance(endDateConverted, wednesdayEndTime);
                            }
                            else if(dayOfWeekEndDate == 'Thursday') {
                                Time thursdayEndTime = businessHoursRecord.ThursdayEndTime;

                                dependentTask.End_Date__c = Datetime.newInstance(endDateConverted, thursdayEndTime);
                            }
                            else if(dayOfWeekEndDate == 'Friday') {
                                Time fridayEndTime = businessHoursRecord.FridayEndTime;

                                dependentTask.End_Date__c = Datetime.newInstance(endDateConverted, fridayEndTime);
                            }
                        }

                        toInsert.add(dependentTask);
                        System.debug('dependentTask: ' + dependentTask);

                        // If the Start_Date__c is null (No WO has still be assigned to this Case) or > dependentTask.Start_Date__c, set it to this one

                        System.debug('RelatedCase: ' + relatedCase);
                        System.debug('RelatedCase Start Date: ' + relatedCase.Start_Date__c);
                        System.debug('dependentTask.StartDate: ' + dependentTask.Start_Date__c);
                        //if(relatedCase.Start_Date__c == null || (relatedCase.Start_Date__c > dependentTask.Start_Date__c)) {
                            relatedCase.Start_Date__c =  Datetime.newInstance(dependentTask.ActivityDate, Time.newInstance(0,0,0,0));
                            relatedCase.Next_Activity_Date__c = relatedCase.Start_Date__c;
                        //}
                        previousTask = dependentTask;
                    }
                    // List index out of bounds --> No more Cases to create Tasks for
                    catch(ListException e) {
                        System.debug('ListException: ' + e.getMessage());
                        break;
                    }
                    catch(Exception e) {
                        System.debug('Exception: ' + e.getMessage());
                        break;
                    }
                }
            }
        }

        return toInsert;
    }

    public static List<WorkOrder> autoscheduleWorkOrders(Account_Treatment_Job__c atj, WorkOrder startingWorkOrder, Contract_Treatment_Job_SLA__c relatedSLA, Integer unitOfMeasureInYear,
    List<Case> remainingCases, BusinessHours businessHoursRecord, Boolean isFirstCreated) {
        List<WorkOrder> toInsert = new List<WorkOrder>();

        if(remainingCases != null && !remainingCases.isEmpty() && atj != null && atj.Frequency_Unit_of_measure__c != null) {
            System.debug('startingWorkOrder: ' + startingWorkOrder);
            System.debug('startingWorkOrder.StartDate: ' + startingWorkOrder.StartDate);

            Integer numberOfWOToCreate;
            Integer gap;
            Id businessHoursId = businessHoursRecord.Id;
            WorkOrder previousWO = startingWorkOrder;
            Integer schedulingTimeFrame = (Integer) ((atj.Scheduling_Time_Frame__c != null) ? atj.Scheduling_Time_Frame__c : 365);
            Integer daysInUnitOfMeasure;

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

            numberOfWOToCreate = remainingCases.size();

            if(atj.Frequency_Type__c != 'IB') {
                Date dateConvertedStartDate = Date.newInstance((startingWorkOrder.StartDate).year(), (startingWorkOrder.StartDate).month(), (startingWorkOrder.StartDate).day());
                Integer oneYearDifference = (dateConvertedStartDate).daysBetween(dateConvertedStartDate.addYears(1));

                /* if(schedulingTimeFrame <= 365) {
                    numberOfWOToCreate = (Integer) (unitOfMeasureInYear * atj.Frequency__c);  // Not using daysInYear: if the year is leap, it will be 365 / 366 = 0 -> no gap
                }
                else {
                    numberOfWOToCreate = (Integer) ((schedulingTimeFrame / 365) * atj.Frequency__c);
                } */
                //numberOfWOToCreate = remainingCases.size();
                gap = (Integer) (oneYearDifference / ((Integer) (unitOfMeasureInYear * atj.Frequency__c))); // This is not going to work if Frequency in Day > 1 --> gap = 0
                System.debug('WorkOrder Gap: ' + gap);
            }
            else if(atj.Frequency_Type__c == 'IB') {
                //numberOfWOToCreate = remainingCases.size();
                //gap = (Integer) (atj.Scheduling_Time_Frame__c / numberOfWOToCreate);

                /* if(isFirstCreated) {
                    gap = (Integer) (schedulingTimeFrame / (numberOfWOToCreate + 1));
                }
                else {
                    gap = (Integer) (schedulingTimeFrame / numberOfWOToCreate);
                } */

                gap = (Integer) (atj.Frequency__c * daysInUnitOfMeasure);
            }

            /* if(isFirstCreated == true) {
                numberOfWOToCreate = numberOfWOToCreate - 1;
            } */
            
            System.debug('numberOfWOToCreate: ' + numberOfWOToCreate);

            if(numberOfWOToCreate != null) {
                for(Integer i = 0; i < numberOfWOToCreate; i++) { // One has already been created
                    try {
                        System.debug('Creating WorkOrders...');
                        // Number of Cases to be assigned = Number of new WorkOrders to schedule, so (as all Cases are identical) I link them "1 to 1"
                        Case relatedCase = remainingCases[i];
                        
                        WorkOrder dependentWO = new WorkOrder(
                            AccountId = previousWO.AccountId,
                            Account_Sold_To__c = previousWO.Account_Sold_To__c,
                            Account_Sales_Organization__c = previousWO.Account_Sales_Organization__c,
                            Account_Treatment__c = previousWO.Account_Treatment__c,
                            CaseId = relatedCase.Id,
                            Contract_Framework__c = previousWO.Contract_Framework__c,
                            Contract_Treatment__c = previousWO.Contract_Treatment__c,
                            Contract_Treatment_Job__c = previousWO.Contract_Treatment_Job__c,
                            Customer_Purchase_Order_Date__c = previousWO.Customer_Purchase_Order_Date__c,
                            Customer_Purchase_Order_Number__c = previousWO.Customer_Purchase_Order_Number__c,
                            Delivery_Type__c = previousWO.Delivery_Type__c,
                            Document_Type__c = previousWO.Document_Type__c,
                            OwnerId = previousWO.OwnerId,
                            Pricebook2Id = previousWO.Pricebook2Id,
                            Status = 'New',
                            Subject = previousWO.Subject,
                            WorkTypeId = previousWO.WorkTypeId,
                            Related_SLA__c = previousWO.Related_SLA__c,
                            LocationId = previousWO.LocationId,
                            City = previousWO.City,
                            Country = previousWO.Country,
                            CountryCode = previousWO.CountryCode,
                            Latitude = previousWO.Latitude,
                            Longitude = previousWO.Longitude,
                            PostalCode = previousWO.PostalCode,
                            State = previousWO.State,
                            StateCode = previousWO.StateCode,
                            Street = previousWO.Street,
                            Account_Treatment_Job__c = previousWO.Account_Treatment_Job__c,
                            Attachment_Addendum_Type__c = previousWO.Attachment_Addendum_Type__c,
                            Billing_Via__c = previousWO.Billing_Via__c,
                            Billing_Reference__c = previousWO.Billing_Reference__c,
                            Invoice_splitting_criterion__c = previousWO.Invoice_splitting_criterion__c,
                            InvoiceLayout__c = previousWO.InvoiceLayout__c,
                            Job_InvoiceSplittingGroup__c = previousWO.Job_InvoiceSplittingGroup__c,
                            Treatment_Customer_Purchase_Order_Date__c = previousWO.Treatment_Customer_Purchase_Order_Date__c,
                            Treatment_Customer_Purchase_Order_Number__c = previousWO.Treatment_Customer_Purchase_Order_Number__c,
                            Treatment_Customer_Request_Code__c = previousWO.Treatment_Customer_Request_Code__c,
                            Treatment_InvoiceSplittingGroup__c = previousWO.Treatment_InvoiceSplittingGroup__c,
                            Autoscheduled__c = true,
                            AssetId = previousWO.AssetId,
                            Label__c = previousWO.Label__c,
                            ContactId = previousWO.ContactId,
                            SalesOrganization__c = previousWO.SalesOrganization__c,
                            Division__c = previousWO.Division__c,
                            Distribution_Channel__c = previousWO.Distribution_Channel__c,
                            Sales_Group__c = previousWO.Sales_Group__c,
                            Sales_Office__c = previousWO.Sales_Office__c,
                            Job_Product_Code__c = previousWO.Job_Product_Code__c
                        );

                        Integer msInBusinessDay = 32400000;  // Milliseconds in 9 hours, a typical business day
                        Integer msInHour = 3600000;
                        Datetime toApplyGap = previousWO.Due_Date__c;

                        if(!isFirstCreated && i == 0 && previousWO.Case.Status == 'Closed') {
                            toApplyGap = previousWO.EndDate;
                        }

                        if(/* atj.Frequency_Type__c == 'NPU' */atj.Frequency_Type__c != 'IB' && gap != null) {
                            dependentWO.Due_Date__c = (toApplyGap).addDays(gap);
                        }
                        else if(atj.Frequency_Type__c == 'IB') {
                            if(atj.Frequency_Unit_of_measure__c == 'Day') {
                                dependentWO.Due_Date__c = (toApplyGap).addDays((Integer) atj.Frequency__c);
                            }
                            else if(atj.Frequency_Unit_of_measure__c == 'Week') {
                                dependentWO.Due_Date__c = (toApplyGap).addDays(7 * (Integer) atj.Frequency__c);
                            }
                            else if(atj.Frequency_Unit_of_measure__c == 'Month') {
                                dependentWO.Due_Date__c = (toApplyGap).addMonths((Integer) atj.Frequency__c);
                            }
                            else if(atj.Frequency_Unit_of_measure__c == 'Year') {
                                dependentWO.Due_Date__c = (toApplyGap).addYears((Integer) atj.Frequency__c);
                            }
                        }

                        // If DueDate is within BusinessHours, I approximate it to the end of the business day. If not, I go back till the first business day

                        Date dueDateConverted = (dependentWO.Due_Date__c).date();
                        Datetime consideredDate = dependentWO.Due_Date__c;
                        Time endTime;

                        /* if(!BusinessHours.isWithin(businessHoursId, dependentWO.Due_Date__c)) {
                            dependentWO.Due_Date__c = BusinessHours.nextStartDate(businessHoursId, dependentWO.Due_Date__c);
                        } */

                        while(endTime == null) {
                            String dayOfWeekConsideredDate = (consideredDate).format('EEEE');
                            Time dayOfWeekEndTime;
                            System.debug('Considering date: ' + consideredDate);
                            System.debug('Day of week: ' + dayOfWeekConsideredDate);

                            switch on dayOfWeekConsideredDate {
                                when 'Monday' {
                                    dayOfWeekEndTime = businessHoursRecord.MondayEndTime;
                                }
                                when 'Tuesday' {
                                    dayOfWeekEndTime = businessHoursRecord.TuesdayEndTime;
                                }
                                when 'Wednesday' {
                                    dayOfWeekEndTime = businessHoursRecord.WednesdayEndTime;
                                }
                                when 'Thursday' {
                                    dayOfWeekEndTime = businessHoursRecord.ThursdayEndTime;
                                }
                                when 'Friday' {
                                    dayOfWeekEndTime = businessHoursRecord.FridayEndTime;
                                }
                                when 'Saturday' {
                                    dayOfWeekEndTime = businessHoursRecord.SaturdayEndTime;
                                }
                                when 'Sunday' {
                                    dayOfWeekEndTime = businessHoursRecord.SundayEndTime;
                                }
                            }

                            if(dayOfWeekEndTime != null) {
                                /* if(BusinessHours.isWithin(businessHoursId, (Datetime.newInstance(consideredDate.date(), dayOfWeekEndTime)).addSeconds(-1))) {
                                    System.debug(Datetime.newInstance(consideredDate.date(), dayOfWeekEndTime) + ' is a Business Hour!');
                                    endTime = dayOfWeekEndTime;
                                }
                                else {
                                    System.debug(Datetime.newInstance(consideredDate.date(), dayOfWeekEndTime) + ' is NOT a Business Hour! Going 1 day back...');
                                    consideredDate = consideredDate.addDays(-1);
                                } */
                                System.debug('This is a working day!');
                                endTime = dayOfWeekEndTime.addMinutes(-1);
                            }
                            else {
                                System.debug('This is not a working day! Going 1 day back...');
                                consideredDate = consideredDate.addDays(-1);
                            }
                        }

                        if(endTime != null) {
                            dependentWO.Due_Date__c = Datetime.newInstance(consideredDate.date(), endTime);
                        }

                        System.debug('dependentWO.DueDate: ' + dependentWO.Due_Date__c);

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

                            dependentWO.StartDate = BusinessHours.addGmt(businessHoursId, (dependentWO.Due_Date__c), -toSubtract);
                            dependentWO.Scheduled_Start_Date__c = dependentWO.StartDate;

                            // Adding Offset to Due_Date (considering BH) to get End_Date__c

                            dependentWO.EndDate = BusinessHours.addGmt(businessHoursId, (dependentWO.Due_Date__c), toAdd);
                            dependentWO.Scheduled_End_Date__c = dependentWO.EndDate;
                        }
                        else if(relatedSLA.Offset_calculation_mode__c == 'Calendar') {

                            // Subtracting Offset from Due_Date without considering BH to get Start_Date__c

                            Integer toSubtract = (Integer) relatedSLA.Offset_Start_Date__c;
                            if(relatedSLA.Offset_unit_of_measure__c == 'Hour') {
                                dependentWO.StartDate = (dependentWO.Due_Date__c).addHours(-toSubtract);
                            }
                            else if(relatedSLA.Offset_unit_of_measure__c == 'Day') {
                                dependentWO.StartDate = (dependentWO.Due_Date__c).addDays(-toSubtract);
                            }
                            else if(relatedSLA.Offset_unit_of_measure__c == 'Week') {
                                dependentWO.StartDate = (dependentWO.Due_Date__c).addDays(-(toSubtract * 7));
                            }
                            else if(relatedSLA.Offset_unit_of_measure__c == 'Month') {
                                dependentWO.StartDate = (dependentWO.Due_Date__c).addMonths(-toSubtract);
                            }

                            System.debug('StartDate before BH check: ' + dependentWO.StartDate);

                            // Adjusting Start_Date__c if it falls outside the BHs

                            if(!BusinessHours.isWithin(businessHoursId, dependentWO.StartDate)) {
                                dependentWO.StartDate = BusinessHours.nextStartDate(businessHoursId, dependentWO.StartDate);
                            }

                            System.debug('StartDate after BH check: ' + dependentWO.StartDate);

                            dependentWO.Scheduled_Start_Date__c = dependentWO.StartDate;

                            // Adding Offset to Due_Date without considering BH to get End_Date__c

                            Integer toAdd = (Integer) relatedSLA.Offset_End_Date__c;
                            if(relatedSLA.Offset_unit_of_measure__c == 'Hour') {
                                dependentWO.EndDate = (dependentWO.Due_Date__c).addHours(toAdd);
                            }
                            else if(relatedSLA.Offset_unit_of_measure__c == 'Day') {
                                dependentWO.EndDate = (dependentWO.Due_Date__c).addDays(toAdd);
                            }
                            else if(relatedSLA.Offset_unit_of_measure__c == 'Week') {
                                dependentWO.EndDate = (dependentWO.Due_Date__c).addDays(toAdd * 7);
                            }
                            else if(relatedSLA.Offset_unit_of_measure__c == 'Month') {
                                dependentWO.EndDate = (dependentWO.Due_Date__c).addMonths(toAdd);
                            }

                            // Adjusting End_Date__c if it falls outside the BHs

                            if(!BusinessHours.isWithin(businessHoursId, dependentWO.EndDate)) {
                                dependentWO.EndDate = BusinessHours.nextStartDate(businessHoursId, dependentWO.EndDate);
                            }

                            dependentWO.Scheduled_End_Date__c = dependentWO.EndDate;
                        }

                        // Approximating StartDate and EndDate to the Start/End of Business Day

                        if(relatedSLA.Offset_unit_of_measure__c == 'Day' || relatedSLA.Offset_unit_of_measure__c == 'Week' || relatedSLA.Offset_unit_of_measure__c == 'Month') {
                            String dayOfWeekStartDate = dependentWO.StartDate.format('EEEE');
                            System.debug('dayOfWeekStartDate: ' + dayOfWeekStartDate);
                            String dayOfWeekEndDate = dependentWO.EndDate.format('EEEE');
                            System.debug('dayOfWeekEndDate: ' + dayOfWeekEndDate);

                            Date startDateConverted = Date.newInstance((dependentWO.StartDate).year(), (dependentWO.StartDate).month(), (dependentWO.StartDate).day());
                            Date endDateConverted = Date.newInstance((dependentWO.EndDate).year(), (dependentWO.EndDate).month(), (dependentWO.EndDate).day());

                            // Getting the day of the week, then getting the StartTime of that day and rebuilding startDate with the same Date but with the new startTime

                            if(dayOfWeekStartDate == 'Monday') {
                                Time mondayStartTime = businessHoursRecord.MondayStartTime;
                                
                                dependentWO.StartDate = Datetime.newInstance(startDateConverted, mondayStartTime);
                            }
                            else if(dayOfWeekStartDate == 'Tuesday') {
                                Time tuesdayStartTime = businessHoursRecord.TuesdayStartTime;

                                dependentWO.StartDate = Datetime.newInstance(startDateConverted, tuesdayStartTime);
                            }
                            else if(dayOfWeekStartDate == 'Wednesday') {
                                Time wednesdayStartTime = businessHoursRecord.WednesdayStartTime;

                                dependentWO.StartDate = Datetime.newInstance(startDateConverted, wednesdayStartTime);
                            }
                            else if(dayOfWeekStartDate == 'Thursday') {
                                Time thursdayStartTime = businessHoursRecord.ThursdayStartTime;

                                dependentWO.StartDate = Datetime.newInstance(startDateConverted, thursdayStartTime);
                            }
                            else if(dayOfWeekStartDate == 'Friday') {
                                Time fridayStartTime = businessHoursRecord.FridayStartTime;

                                dependentWO.StartDate = Datetime.newInstance(startDateConverted, fridayStartTime);
                            }

                            // Getting the day of the week, then getting the EndTime of that day and rebuilding endDate with the same Date but with the new endTime

                            if(dayOfWeekEndDate == 'Monday') {
                                Time mondayEndTime = businessHoursRecord.MondayEndTime;
                                
                                dependentWO.EndDate = Datetime.newInstance(endDateConverted, mondayEndTime);
                            }
                            else if(dayOfWeekEndDate == 'Tuesday') {
                                Time tuesdayEndTime = businessHoursRecord.TuesdayEndTime;

                                dependentWO.EndDate = Datetime.newInstance(endDateConverted, tuesdayEndTime);
                            }
                            else if(dayOfWeekEndDate == 'Wednesday') {
                                Time wednesdayEndTime = businessHoursRecord.WednesdayEndTime;

                                dependentWO.EndDate = Datetime.newInstance(endDateConverted, wednesdayEndTime);
                            }
                            else if(dayOfWeekEndDate == 'Thursday') {
                                Time thursdayEndTime = businessHoursRecord.ThursdayEndTime;

                                dependentWO.EndDate = Datetime.newInstance(endDateConverted, thursdayEndTime);
                            }
                            else if(dayOfWeekEndDate == 'Friday') {
                                Time fridayEndTime = businessHoursRecord.FridayEndTime;

                                dependentWO.EndDate = Datetime.newInstance(endDateConverted, fridayEndTime);
                            }

                            dependentWO.Scheduled_Start_Date__c = dependentWO.StartDate;
                            dependentWO.Scheduled_End_Date__c = dependentWO.EndDate;
                        }

                        toInsert.add(dependentWO);
                        System.debug('DependentWO: ' + dependentWO);

                        // Same as above, if Start_Date__c on the Case is still null or falls later in time, set it to dependentWO.StartDate

                        if(relatedCase.Start_Date__c == null/* || (relatedCase.Start_Date__c > dependentWO.StartDate)*/) {
                            relatedCase.Start_Date__c = dependentWO.StartDate;
                            relatedCase.Next_Activity_Date__c = relatedCase.Start_Date__c;
                        }
                        previousWO = dependentWO;
                    }
                    // List index out of bounds: no more Cases to create WOs for
                    catch(ListException e) {
                        System.debug('ListException: ' + e);
                        break;
                    }
                    catch(Exception e) {
                        System.debug('Exception: ' + e.getMessage());
                        break;
                    }
                }
            }
        }

        return toInsert;
    }

    public static DatesResponseDTO calculateDates(Datetime startDateTime, Decimal maxTime, String maxTimeUnitOfMeasure, String maxTimeCalculationMode,
    Decimal offsetStartDateTime, Decimal offsetEndDateTime, String offsetUnitOfMeasure, String offsetCalculationMode, BusinessHours businessHoursRecord, 
    Boolean startDatetimeIsDueDate) {

        Datetime startDate = startDateTime;
        Datetime endDate = startDateTime;
        Datetime dueDate = startDateTime;
        Id businessHoursId = businessHoursRecord.Id;

        // Conversion

        Integer integerMaxTime = (Integer) maxTime;
        Integer integerOffsetStartDateTime = (Integer) offsetStartDateTime;
        Integer integerOffsetEndDateTime = (Integer) offsetEndDateTime;

        // Adding MaxTime

        if(maxTimeCalculationMode == 'Calendar') {
            if(maxTimeUnitOfMeasure == 'Hour') {
                startDate = startDate.addHours(integerMaxTime);
                endDate = startDate;
                if(!startDatetimeIsDueDate) {
                    dueDate = startDate;
                }
            }
            else if(maxTimeUnitOfMeasure == 'Day') {
                startDate = startDate.addDays(integerMaxTime);
                endDate = startDate;
                if(!startDatetimeIsDueDate) {
                    dueDate = startDate;
                }
            }
            else if(maxTimeUnitOfMeasure == 'Week') {
                startDate = startDate.addDays(integerMaxTime * 7);
                Boolean isBusinessDay = BusinessHours.isWithin(businessHoursId, startDate);
                if(!isBusinessDay) {
                    startDate = BusinessHours.nextStartDate(businessHoursId, startDate);
                }
                endDate = startDate;
                if(!startDatetimeIsDueDate) {
                    dueDate = startDate;
                }
            }
            else if(maxTimeUnitOfMeasure == 'Month') {
                startDate = startDate.addMonths(integerMaxTime);
                Boolean isBusinessDay = BusinessHours.isWithin(businessHoursId, startDate);
                if(!isBusinessDay) {
                    startDate = BusinessHours.nextStartDate(businessHoursId, startDate);
                }
                endDate = startDate;
                if(!startDatetimeIsDueDate) {
                    dueDate = startDate;
                }
            }
        }
        else if(maxTimeCalculationMode == 'Business') {
            if(maxTimeUnitOfMeasure == 'Hour') {
                Boolean isBusinessDay = BusinessHours.isWithin(businessHoursId, startDate);
                if(!isBusinessDay) {
                    startDate = BusinessHours.nextStartDate(businessHoursId, startDate);
                }
                Integer msInHour = 3600000;
                Integer toAdd = integerMaxTime * msInHour;

                startDate = BusinessHours.addGmt(businessHoursId, startDate, toAdd);
                endDate = startDate;
                if(!startDatetimeIsDueDate) {
                    dueDate = startDate;
                }
                System.debug('New start Date after BusinessHours.add (Hour): ' + startDate);
            }
            else if(maxTimeUnitOfMeasure == 'Day') {
                System.debug('MaxTimeUnitOfMeasure = Day');
                System.debug('StartDate: '+ startDate);
                Boolean isBusinessDay = BusinessHours.isWithin(businessHoursId, startDate);
                if(!isBusinessDay) {
                    System.debug('StartDate !isBusinessDay');
                    startDate = BusinessHours.nextStartDate(businessHoursId, startDate);
                }
                Integer msInDay = 32400000;  // In 9 hours business day
                Integer toAdd = integerMaxTime * msInDay;

                startDate = BusinessHours.addGmt(businessHoursId, startDate, toAdd);
                endDate = startDate;
                if(!startDatetimeIsDueDate) {
                    dueDate = startDate;
                }
                System.debug('New start Date after BusinessHours.add (Day): ' + startDate);
            }
            else if(maxTimeUnitOfMeasure == 'Week') {
                System.debug('MaxTimeUnitOfMeasure = Week');
                System.debug('StartDate: ' + startDate);
                Boolean isBusinessDay = BusinessHours.isWithin(businessHoursId, startDate);
                if(!isBusinessDay) {
                    System.debug('StartDate !isBusinessDay');
                    startDate = BusinessHours.nextStartDate(businessHoursId, startDate);
                }
                Integer msInWeek = 32400000 * 5;  // In 9 hours business days * 5 business days
                Integer toAdd = integerMaxTime * msInWeek;

                startDate = BusinessHours.addGmt(businessHoursId, startDate, toAdd);
                endDate = startDate;
                if(!startDatetimeIsDueDate) {
                    dueDate = startDate;
                }
                System.debug('New start Date after BusinessHours.add (Day): ' + startDate);
            }
            else if(maxTimeUnitOfMeasure == 'Month') {
                System.debug('MaxTimeUnitOfMeasure = Month');
                System.debug('StartDate: ' + startDate);
                Boolean isBusinessDay = BusinessHours.isWithin(businessHoursId, startDate);
                if(!isBusinessDay) {
                    System.debug('StartDate !isBusinessDay');
                    startDate = BusinessHours.nextStartDate(businessHoursId, startDate);
                }
                Integer msInWeek = 32400000 * 20;  // In 9 hours business days * 20 business days
                Integer toAdd = integerMaxTime * msInWeek;

                startDate = BusinessHours.addGmt(businessHoursId, startDate, toAdd);
                endDate = startDate;
                if(!startDatetimeIsDueDate) {
                    dueDate = startDate;
                }
                System.debug('New start Date after BusinessHours.add (Day): ' + startDate);
            }
        }

        // Subtracting OffsetStartDateTIme and adding OffsetEndDateTime

        if(offsetCalculationMode == 'Calendar') {
            if(offsetUnitOfMeasure == 'Hour') {
                startDate = dueDate.addHours(-integerOffsetStartDateTime);
                endDate = dueDate.addHours(integerOffsetEndDateTime);
            }
            else if(offsetUnitOfMeasure == 'Day') {
                startDate = dueDate.addDays(-integerOffsetStartDateTime);
                endDate = dueDate.addDays(integerOffsetEndDateTime);
            }
            else if(offsetUnitOfMeasure == 'Week') {
                startDate = dueDate.addDays((-integerOffsetStartDateTime) * 7);
                endDate = dueDate.addDays((integerOffsetEndDateTime) * 7);
                Boolean isBusinessDay = BusinessHours.isWithin(businessHoursId, startDate);
                Boolean isEndDateBusinessDay = BusinessHours.isWithin(businessHoursId, endDate);
                if(!isBusinessDay) {
                    startDate = BusinessHours.nextStartDate(businessHoursId, startDate);
                }
                if(!isEndDateBusinessDay) {
                    endDate = BusinessHours.nextStartDate(businessHoursId, endDate);
                }
            }
            else if(offsetUnitOfMeasure == 'Month') {
                startDate = dueDate.addMonths(-integerOffsetStartDateTime);
                endDate = dueDate.addMonths(integerOffsetEndDateTime);
                Boolean isBusinessDay = BusinessHours.isWithin(businessHoursId, startDate);
                Boolean isEndDateBusinessDay = BusinessHours.isWithin(businessHoursId, endDate);
                if(!isBusinessDay) {
                    startDate = BusinessHours.nextStartDate(businessHoursId, startDate);
                }
                if(!isEndDateBusinessDay) {
                    endDate = BusinessHours.nextStartDate(businessHoursId, endDate);
                }
            }
        }
        else if(offsetCalculationMode == 'Business') {
            if(offsetUnitOfMeasure == 'Hour') {
                Boolean isBusinessDay = BusinessHours.isWithin(businessHoursId, startDate);
                Boolean isEndDateBusinessDay = BusinessHours.isWithin(businessHoursId, endDate);
                if(!isBusinessDay) {
                    startDate = BusinessHours.nextStartDate(businessHoursId, startDate);
                }
                if(!isEndDateBusinessDay) {
                    endDate = BusinessHours.nextStartDate(businessHoursId, endDate);
                }
                Integer msInHour = 3600000;
                Integer toAddStartDate = integerOffsetStartDateTime * msInHour;
                Integer toAddEndDate = integerOffsetEndDateTime * msInHour;

                endDate = BusinessHours.addGmt(businessHoursId, dueDate, toAddEndDate);
                startDate = BusinessHours.addGmt(businessHoursId, dueDate, -toAddStartDate);
                System.debug('New start Date after BusinessHours.add (offset): ' + startDate);
                System.debug('New end Date after BusinessHours.add (offset): ' + endDate);
            }
            else if(offsetUnitOfMeasure == 'Day') {
                Boolean isBusinessDay = BusinessHours.isWithin(businessHoursId, startDate);
                Boolean isEndDateBusinessDay = BusinessHours.isWithin(businessHoursId, endDate);
                if(!isBusinessDay) {
                    startDate = BusinessHours.nextStartDate(businessHoursId, startDate);
                }
                if(!isEndDateBusinessDay) {
                    endDate = BusinessHours.nextStartDate(businessHoursId, endDate);
                }
                Integer msInDay = 32400000;  // In 9 hours business day
                Integer toAddStartDate = integerOffsetStartDateTime * msInDay;
                Integer toAddEndDate = integerOffsetEndDateTime * msInDay;

                endDate = BusinessHours.addGmt(businessHoursId, dueDate, toAddEndDate);
                startDate = BusinessHours.addGmt(businessHoursId, dueDate, -toAddStartDate);
                System.debug('New start Date after BusinessHours.add (offset): ' + startDate);
                System.debug('New end Date after BusinessHours.add (offset): ' + endDate);
            }
            else if(offsetUnitOfMeasure == 'Week') {
                Boolean isBusinessDay = BusinessHours.isWithin(businessHoursId, startDate);
                Boolean isEndDateBusinessDay = BusinessHours.isWithin(businessHoursId, endDate);
                if(!isBusinessDay) {
                    startDate = BusinessHours.nextStartDate(businessHoursId, startDate);
                }
                if(!isEndDateBusinessDay) {
                    endDate = BusinessHours.nextStartDate(businessHoursId, endDate);
                }
                Integer msInWeek = 32400000 * 5;  // In 9 hours business day * 5 business days
                Integer toAddStartDate = integerOffsetStartDateTime * msInWeek;
                Integer toAddEndDate = integerOffsetEndDateTime * msInWeek;

                endDate = BusinessHours.addGmt(businessHoursId, dueDate, toAddEndDate);
                startDate = BusinessHours.addGmt(businessHoursId, dueDate, -toAddStartDate);
                System.debug('New start Date after BusinessHours.add (offset): ' + startDate);
                System.debug('New end Date after BusinessHours.add (offset): ' + endDate);
            }
            else if(offsetUnitOfMeasure == 'Month') {
                Boolean isBusinessDay = BusinessHours.isWithin(businessHoursId, startDate);
                Boolean isEndDateBusinessDay = BusinessHours.isWithin(businessHoursId, endDate);
                if(!isBusinessDay) {
                    startDate = BusinessHours.nextStartDate(businessHoursId, startDate);
                }
                if(!isEndDateBusinessDay) {
                    endDate = BusinessHours.nextStartDate(businessHoursId, endDate);
                }
                Integer msInMonth = 32400000 * 20;  // In 9 hours business day * 20 business days
                Integer toAddStartDate = integerOffsetStartDateTime * msInMonth;
                Integer toAddEndDate = integerOffsetEndDateTime * msInMonth;

                endDate = BusinessHours.addGmt(businessHoursId, dueDate, toAddEndDate);
                startDate = BusinessHours.addGmt(businessHoursId, dueDate, -toAddStartDate);
                System.debug('New start Date after BusinessHours.add (offset): ' + startDate);
                System.debug('New end Date after BusinessHours.add (offset): ' + endDate);
            }
        }

        // Approximating StartDate and EndDate to the Start/End of Business Day for Business

        if(offsetCalculationMode == 'Business' && (offsetUnitOfMeasure == 'Day' || offsetUnitOfMeasure == 'Week' || offsetUnitOfMeasure == 'Month')) {
            String dayOfWeekStartDate = startDate.format('EEEE');
            System.debug('dayOfWeekStartDate: ' + dayOfWeekStartDate);
            String dayOfWeekEndDate = endDate.format('EEEE');
            System.debug('dayOfWeekEndDate: ' + dayOfWeekEndDate);

            Date startDateConverted = Date.newInstance(startDate.year(), startDate.month(), startDate.day());
            Date endDateConverted = Date.newInstance(endDate.year(), endDate.month(), endDate.day());

            // Getting the day of the week, then getting the StartTime of that day and rebuilding startDate with the same Date but with the new startTime

            if(dayOfWeekStartDate == 'Monday') {
                Time mondayStartTime = businessHoursRecord.MondayStartTime;
                
                startDate = Datetime.newInstance(startDateConverted, mondayStartTime);
            }
            else if(dayOfWeekStartDate == 'Tuesday') {
                Time tuesdayStartTime = businessHoursRecord.TuesdayStartTime;

                startDate = Datetime.newInstance(startDateConverted, tuesdayStartTime);
            }
            else if(dayOfWeekStartDate == 'Wednesday') {
                Time wednesdayStartTime = businessHoursRecord.WednesdayStartTime;

                startDate = Datetime.newInstance(startDateConverted, wednesdayStartTime);
            }
            else if(dayOfWeekStartDate == 'Thursday') {
                Time thursdayStartTime = businessHoursRecord.ThursdayStartTime;

                startDate = Datetime.newInstance(startDateConverted, thursdayStartTime);
            }
            else if(dayOfWeekStartDate == 'Friday') {
                Time fridayStartTime = businessHoursRecord.FridayStartTime;

                startDate = Datetime.newInstance(startDateConverted, fridayStartTime);
            }

            // Getting the day of the week, then getting the EndTime of that day and rebuilding endDate with the same Date but with the new endTime

            if(dayOfWeekEndDate == 'Monday') {
                Time mondayEndTime = businessHoursRecord.MondayEndTime;
                
                endDate = Datetime.newInstance(endDateConverted, mondayEndTime);
            }
            else if(dayOfWeekEndDate == 'Tuesday') {
                Time tuesdayEndTime = businessHoursRecord.TuesdayEndTime;

                endDate = Datetime.newInstance(endDateConverted, tuesdayEndTime);
            }
            else if(dayOfWeekEndDate == 'Wednesday') {
                Time wednesdayEndTime = businessHoursRecord.WednesdayEndTime;

                endDate = Datetime.newInstance(endDateConverted, wednesdayEndTime);
            }
            else if(dayOfWeekEndDate == 'Thursday') {
                Time thursdayEndTime = businessHoursRecord.ThursdayEndTime;

                endDate = Datetime.newInstance(endDateConverted, thursdayEndTime);
            }
            else if(dayOfWeekEndDate == 'Friday') {
                Time fridayEndTime = businessHoursRecord.FridayEndTime;

                endDate = Datetime.newInstance(endDateConverted, fridayEndTime);
            }
        }
        else if(offsetCalculationMode == 'Calendar' && 
        (offsetUnitOfMeasure == 'Day' || offsetUnitOfMeasure == 'Week' || offsetUnitOfMeasure == 'Month')) {
            Date startDateConverted = Date.newInstance((startDate).year(), (startDate).month(), (startDate).day());
            Date endDateConverted = Date.newInstance(endDate.year(), endDate.month(), endDate.day());

            Time startOfDay = Time.newInstance(0, 0, 0, 0);
            Time endOfDay = Time.newInstance(23, 59, 0, 0);

            startDate = Datetime.newInstance(startDateConverted, startOfDay);
            endDate = Datetime.newInstance(endDateConverted, endOfDay);
        }

        System.debug('startDate: ' + startDate);
        System.debug('endDate: ' + endDate);
        System.debug('dueDate: ' + dueDate);
        DatesResponseDTO dto = new DatesResponseDTO(startDate, endDate, dueDate);

        return dto;
    }

    public static Map<Account_Treatment_Job__c, Contract_Treatment_Job_SLA__c> getATJtoSLAMap(List<Account_Treatment_Job__c> accountTreatmentJobs) {
        List<String> queryFieldsForSLA = new List<String>{'IsDefault__c', 'Contract_Treatment_Job__c', 'Max_Time__c', 'Unite_of_measure_Max_Time__c', //Unit, not unite
        'Calculation_Mode__c', 'Offset_Start_Date__c', 'Offset_End_Date__c', 'Offset_unit_of_measure__c', 'Offset_calculation_mode__c', 'Task_MaxTime_Execution__c', 
        'Task_Unite_of_measure_Max_Time__c', 'Task_Calculation_Mode__c', 'Offset_calculation_mode_Task__c', 'Offset_unit_of_measure_Task__c', 
        'Offset_Start_Date_Task__c', 'Offset_End_Date_Task__c'};

        // This is what I will return: a map with all eligible ATJ Ids and the related chosen SLA
        Map<Account_Treatment_Job__c, Contract_Treatment_Job_SLA__c> ATJToSLAMap = new Map<Account_Treatment_Job__c, Contract_Treatment_Job_SLA__c>();

        // This map links each CTJ Id to the related SLAs
        Map<Id, List<Contract_Treatment_Job_SLA__c>> SLAMap = new Map<Id, List<Contract_Treatment_Job_SLA__c>>();
        List<Id> CTJIds = new List<Id>();

        // Getting all the CTJs related to the ATJs
        for(Account_Treatment_Job__c atj : accountTreatmentJobs) {
            CTJIds.add(atj.Contract_Treatment_Job__c);
        }

        // Getting all the SLAs related to each CTJ related to each ATJ
        List<Contract_Treatment_Job_SLA__c> allRelatedSLAs = ContractTreatmentJobSlaDAO.getSLAsFromCTJs(queryFieldsForSLA, CTJIds);

        // Filling CTJ.Id --> List<SLA> Map
        if(!allRelatedSLAs.isEmpty()) {
            for(Contract_Treatment_Job_SLA__c sla : allRelatedSLAs) {
                if(SLAMap.get(sla.Contract_Treatment_Job__c) == null) {
                    SLAMap.put(sla.Contract_Treatment_Job__c, new List<Contract_Treatment_Job_SLA__c>());
                }
                SLAMap.get(sla.Contract_Treatment_Job__c).add(sla);
            }
        }


        for(Account_Treatment_Job__c atj : accountTreatmentJobs) {
            if(SLAMap.get(atj.Contract_Treatment_Job__c) != null) {

                Contract_Treatment_Job_SLA__c relatedSLA;

                // Looking for a Default SLA...
                for(Contract_Treatment_Job_SLA__c sla : SLAMap.get(atj.Contract_Treatment_Job__c)) {
                    if(relatedSLA == null) {
                        if(sla.IsDefault__c == true) {
                            System.debug('Default SLA found!');
                            relatedSLA = sla;
                            break;
                        }
                    }
                }

                // If no Default SLA is found, pick the first one
                if(relatedSLA == null) {
                    System.debug('No Default SLA found');
                    for(Contract_Treatment_Job_SLA__c sla : SLAMap.get(atj.Contract_Treatment_Job__c)) {
                        if(relatedSLA == null) {
                            relatedSLA = sla;
                            break;
                        }
                    }
                }

                if(relatedSLA != null) {
                    ATJToSLAMap.put(atj, relatedSLA);
                }

                System.debug('Related SLA Id: ' + relatedSLA.Id);
            }
        }

        return ATJToSLAMap;
    }
}