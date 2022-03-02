public class NoComplianceActivitiesSchedulingService {

    /* Modified version of ATMainComponentService.createCases made to work with ATHs. It takes in input the Map to retrieve the Subject
       to be given to the Cases */

    public static List<Case> createCases(Map<Account_Treatment_Job__c, Contract_Treatment_Job_SLA__c> ATJtoSLAMap, Database.DMLOptions DMLOptions,
    Integer autoschedulingPeriodInDays, Map<Id, Account_Treatment_History__c> ATJIdToATHMap) {
        System.debug('IN CREATECASES');

        Set<Account_Treatment_Job__c> ATJs = ATJtoSLAMap.keySet();
        List<Case> toInsert = new List<Case>();

        // The first Case is only created if the schedulation period is 365 days (a year). Otherless, every Case will be scheduled below

        for(Account_Treatment_Job__c atj : ATJs) {
            Account_Treatment_History__c relatedATH = ATJIdToATHMap.get(atj.Id);
            if(autoschedulingPeriodInDays == 365) {
                Case newCase = new Case(
                    AccountId = atj.Patient_Treatment__r.Account__c,
                    Account_Treatment__c = atj.Patient_Treatment__c,
                    Account_Treatment_Job__c = atj.Id,
                    Origin = 'System',
                    Contract_Treatment__c = atj.Patient_Treatment__r.Contract_Treatment__c,
                    Patient__c = atj.Patient_Treatment__r.Account__c,
                    Status = 'New',
                    Subtype__c = atj.Case_Subtype__c,
                    Type = atj.Case_Type__c,
                    Treatment__c = atj.Patient_Treatment__r.Treatment_Type__c,
                    Autoscheduled__c = true,
                    ParentId = relatedATH.Case__c
                );

                if(atj.Patient_Treatment__r.Account__r.IsPersonAccount == true) {
                    newCase.ContactId = atj.Patient_Treatment__r.Account__r.PersonContactId;
                }
            
                if(relatedATH != null) {
                    newCase.Subject = 'No Compliance - ' + (relatedATH.CreatedDate).date();
                }

                newCase.setOptions(DMLOptions);

                toInsert.add(newCase);
            }

            // Creating the autoscheduled Cases: WO and Tasks will later be assigned to each of these Cases

            if(atj.Frequency__c != null) {
                Decimal numberOfDays;
                Integer numberOfWeeks;
                Integer numberOfMonths;
                Integer numberOfYears;

                if(autoschedulingPeriodInDays == 365) {
                    numberOfDays = 365;
                    numberOfWeeks = 52;
                    numberOfMonths = 12;
                    numberOfYears = 1;

                }
                else {
                    numberOfDays = autoschedulingPeriodInDays;
                    Decimal weeksToRound = numberOfDays / 7;
                    Decimal monthsToRound = numberOfDays / 30;
                    Decimal yearsToRound = numberOfDays / 365;

                    /* numberOfWeeks = (Integer) (weeksToRound).round(System.RoundingMode.CEILING);
                    numberOfMonths = (Integer) (monthsToRound).round(System.RoundingMode.CEILING);
                    numberOfYears = (Integer) (yearsToRound).round(System.RoundingMode.CEILING); */
                }

                System.debug('numberOfDays: ' + numberOfDays);
                System.debug('numberOfWeeks: ' + numberOfWeeks);
                System.debug('numberOfMonths: ' + numberOfMonths);
                System.debug('numberOfYears: ' + numberOfYears);

                Integer numberOfCasesToCreate;

                // If the schedulingPeriod != 365, then the numberOfCasesToCreate is rounded basing on numberOfDays / numberOfDays in the period (Week, Month, Year)

                if(atj.Frequency_Unit_of_measure__c == 'Day') {
                    numberOfCasesToCreate = (Integer) (numberOfDays * atj.Frequency__c);
                }
                else if(atj.Frequency_Unit_of_measure__c == 'Week') {
                    if(autoschedulingPeriodInDays == 365) {
                        numberOfCasesToCreate = (Integer) (52 * atj.Frequency__c);
                    }
                    else {
                        numberOfCasesToCreate = (Integer) ((numberOfDays / 7) * atj.Frequency__c).round(System.RoundingMode.HALF_UP);
                    }
                }
                else if(atj.Frequency_Unit_of_measure__c == 'Month') {
                    if(autoschedulingPeriodInDays == 365) {
                        numberOfCasesToCreate = (Integer) (12 * atj.Frequency__c);
                    }
                    else {
                        numberOfCasesToCreate = (Integer) ((numberOfDays / 30) * atj.Frequency__c).round(System.RoundingMode.HALF_UP);
                    }
                }
                else if(atj.Frequency_Unit_of_measure__c == 'Year') {
                    if(autoschedulingPeriodInDays == 365) {
                        numberOfCasesToCreate = (Integer) atj.Frequency__c;
                    }
                    else {
                        numberOfCasesToCreate = (Integer) ((numberOfDays / 365) * atj.Frequency__c).round(System.RoundingMode.HALF_UP);
                    }
                }

                // If the first Case hasn't been created yet (autoschedulingPeriod != 365), I have to create it too
                
                if(autoschedulingPeriodInDays == 365) {
                    numberOfCasesToCreate = numberOfCasesToCreate - 1;
                }

                System.debug('numberOfCasesToCreate: ' + numberOfCasesToCreate);

                for(Integer i = 0; i < numberOfCasesToCreate; i++) {
                    Case scheduledCase = new Case(
                        AccountId = atj.Patient_Treatment__r.Account__c,
                        Account_Treatment__c = atj.Patient_Treatment__c,
                        Account_Treatment_Job__c = atj.Id,
                        Origin = 'System',
                        Contract_Treatment__c = atj.Patient_Treatment__r.Contract_Treatment__c,
                        Patient__c = atj.Patient_Treatment__r.Account__c,
                        Status = 'New',
                        Subtype__c = atj.Case_Subtype__c,
                        Type = atj.Case_Type__c,
                        Treatment__c = atj.Patient_Treatment__r.Treatment_Type__c,
                        Autoscheduled__c = true
                    );

                    if(atj.Patient_Treatment__r.Account__r.IsPersonAccount == true) {
                        scheduledCase.ContactId = atj.Patient_Treatment__r.Account__r.PersonContactId;
                    }

                    if(relatedATH != null) {
                        scheduledCase.Subject = 'No Compliance - ' + (relatedATH.CreatedDate).date();
                    }

                    scheduledCase.setOptions(DMLOptions);

                    toInsert.add(scheduledCase);
                }
            }
        }

        System.debug('CREATECASES, toInsert: ' + toInsert);
        return toInsert;
    }

    /* Modified version of ATMainComponentService.createWorkOrders made to work with several ATs. It takes in input a map linking
       each AT to its default ATA, and not a single defaultAddressId as in the other class. So I can retrieve the default ATA
       for each ATJ which I'm scheduling for */

    public static List<WorkOrder> createWorkOrders(Map<Account_Treatment_Job__c,Contract_Treatment_Job_SLA__c> ATJToSLAMap, List<Case> newCases,
    Map<Id, Account_Treatment_Address__c> ATIdToDefaultATAMap) {

        System.debug('------ Creating WorkOrders');
        List<String> queryFields = new List<String>{'Location__c', 'Location__r.VisitorAddress.City', 
        'Location__r.VisitorAddress.Country', 'Location__r.VisitorAddress.CountryCode', 'Location__r.VisitorAddress.Latitude', 
        'Location__r.VisitorAddress.Longitude', 'Location__r.VisitorAddress.PostalCode', 'Location__r.VisitorAddress.State', 
        'Location__r.VisitorAddress.StateCode', 'Location__r.VisitorAddress.Street'};

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

        Map<Id, List<Case>> ATJToCasesMap = new Map<Id, List<Case>>();
        Map<Id, List<Account_Treatment_Job_Product__c>> jobToProductsMap = new Map<Id, List<Account_Treatment_Job_Product__c>>();
        Map<Id, List<PricebookEntry>> pricebookIdToPEMap = new Map<Id, List<PricebookEntry>>();
        Map<Id, Account_Treatment_Job__c> ATJMap = new Map<Id, Account_Treatment_Job__c>();
        Map<Id, Account_Sales_Organization__c> ASOMap = new Map<Id, Account_Sales_Organization__c>();

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
        }

        for(Account_Treatment_Job__c atj : workOrderATJs) {
            workOrderATJsIds.add(atj.Id);
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

        System.debug('ATIdToDefaultATAMap: ' + ATIdToDefaultATAMap);
        for(Account_Treatment_Job__c atj : workOrderATJs) {

            Account_Treatment_Address__c defaultAddress = ATIdToDefaultATAMap.get(atj.Patient_Treatment__c);
            System.debug('Default Address: ' + defaultAddress);

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
                bh,
                false
            );

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
                firstCase.Next_Activity_Date__c = newWorkOrder.StartDate;
            }

            // Autoscheduling

            if(atj.Frequency__c != null) {
                WorkOrder startingWorkOrder = newWorkOrder;

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

        if(!toInsert.isEmpty()) {
            insert toInsert;
        }

        // Updating the Cases, because the Start_Date__c of each Case has become the StartDate of each WO

        if(!newCases.isEmpty()) {
            update newCases;
        }

        if(!ATJMap.isEmpty() && !jobToProductsMap.isEmpty() && !pricebookIdToPEMap.isEmpty() && !toInsert.isEmpty()) {
            WOLICreationBatch WOLICreation = new WOLICreationBatch();

            WOLICreation.ATJMap = ATJMap;
            WOLICreation.jobToProductsMap = jobToProductsMap;
            WOLICreation.pricebookIdToPEMap = pricebookIdToPEMap;
            WOLICreation.workOrders = toInsert;

            Database.executeBatch(WOLICreation, 3);
        }

        return toInsert;
    }
}