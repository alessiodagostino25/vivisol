public without sharing class WorkOrderCreationBatch implements Database.Batchable<sObject>, Database.Stateful {
    public List<String> ATJQueryFields = new List<String>{'Scheduling_Rule__c', 'Work_Order__c', 'Task__c', 'Contract_Treatment_Job__c', 'Patient_Treatment__r.Account__c',
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
    public List<String> ATAQueryFields = new List<String>{'Location__c', 'Location__r.VisitorAddress.City', 
    'Location__r.VisitorAddress.Country', 'Location__r.VisitorAddress.CountryCode', 'Location__r.VisitorAddress.Latitude', 
    'Location__r.VisitorAddress.Longitude', 'Location__r.VisitorAddress.PostalCode', 'Location__r.VisitorAddress.State', 
    'Location__r.VisitorAddress.StateCode', 'Location__r.VisitorAddress.Street', 'Account_Treatment__c'};
    List<String> ASOQueryFields = new List<String>{'Sales_Organization__r.Code__c', 'Division__c', 'Distribution_Channel__c', 'Sales_Group__c',
    'Sales_Office__c'};

    public List<String> relatedATIds = new List<String>();
    public List<String> newWorkOrderIds = new List<String>();
    public BusinessHours bh;
    public DocumentType__mdt therapyDocumentType;

    public Database.QueryLocator start(Database.BatchableContext bc) {
        bh = [SELECT Id, MondayStartTime, MondayEndTime, TuesdayStartTime, TuesdayEndTime, WednesdayStartTime, WednesdayEndTime,
                            ThursdayStartTime, ThursdayEndTime, FridayStartTime, FridayEndTime, SaturdayStartTime, SaturdayEndTime, SundayStartTime, SundayEndTime  
                            FROM BusinessHours WHERE Name = 'NL'];
        therapyDocumentType = [SELECT Code__c FROM DocumentType__mdt WHERE DeveloperName = 'Therapy'];

        String query = 'SELECT Status, ClosedDate, Autoscheduled__c, Account_Treatment_Job__c, Account_Treatment_Job__r.Task__c, ' +
        'Account_Treatment_Job__r.Work_Order__c, Start_Date__c, Account_Treatment_Job__r.Patient_Treatment__c, Next_Activity_Date__c '+
        'FROM Case WHERE WorkOrderToBeCreated__c = true'; 

        System.debug(query);
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Case> cases) {
        List<String> relatedATJIds = new List<String>();
        List<String> relatedATIdsTmp = new List<String>();
        List<Account_Treatment_Job__c> relatedATJs = new List<Account_Treatment_Job__c>();
        List<WorkOrder> toInsert = new List<WorkOrder>();
        List<String> relatedASOIds = new List<String>();

        Map<String, Account_Treatment_Job__c> ATJMap = new Map<String, Account_Treatment_Job__c>();
        Map<Account_Treatment_Job__c, Contract_Treatment_Job_SLA__c> ATJtoSLAMap = new Map<Account_Treatment_Job__c, Contract_Treatment_Job_SLA__c>();
        Map<String, Account_Treatment_Address__c> ATIdToDefaultATAMap = new Map<String, Account_Treatment_Address__c>();
        Map<String, Account_Sales_Organization__c> ASOMap = new Map<String, Account_Sales_Organization__c>();

        if(bh != null) {
            for(Case c : cases) {
                if(c.Account_Treatment_Job__c != null && c.Account_Treatment_Job__r.Patient_Treatment__c != null) {
                    if(!relatedATJIds.contains(c.Account_Treatment_Job__c)) {
                        relatedATJIds.add(c.Account_Treatment_Job__c);
                    }
                    if(!relatedATIdsTmp.contains(c.Account_Treatment_Job__r.Patient_Treatment__c)) {
                        relatedATIdsTmp.add(c.Account_Treatment_Job__r.Patient_Treatment__c);
                    }
                }
            }

            if(!relatedATJIds.isEmpty()) {
                relatedATJs = AccountTreatmentJobDAO.getATJSFROMIds(ATJQueryFields, relatedATJIds);
                ATJtoSLAMap = ATMainComponentService.getATJtoSLAMap(relatedATJs);

                for(Account_Treatment_Job__c atj : relatedATJs) {
                    ATJMap.put(atj.Id, atj);
                }

                List<Account_Treatment_Address__c> allDefaultAddresses = AccountTreatmentAddressDAO.getDefaultATAFromATs(ATAQueryFields, relatedATIdsTmp);

                if(allDefaultAddresses != null) {
                    for(Account_Treatment_Address__c ata : allDefaultAddresses) {
                        ATIdToDefaultATAMap.put(ata.Account_Treatment__c, ata);
                    }
                }

                for(Account_Treatment_Job__c atj : relatedATJs) {
                    relatedASOIds.add(atj.Contract_Treatment_Job__r.Contract_Framework__r.Branch_of_belonging_sales_office__c);
                }

                // Getting all the ASOs related to the ATJs

                List<Account_Sales_Organization__c> relatedASOs = AccountSalesOrganizationDAO.getASOsFromIds(ASOQueryFields, relatedASOIds);

                if(relatedASOs != null) {
                    for(Account_Sales_Organization__c aso : relatedASOs) {
                        ASOMap.put(aso.Id, aso);
                    }
                }

                for(Case c : cases) {
                    Account_Treatment_Job__c relatedATJ = ATJMap.get(c.Account_Treatment_Job__c);
                    Datetime dueDate;
                    WorkOrder newWorkOrder;

                    if(relatedATJ != null) {
                        Contract_Treatment_Job_SLA__c relatedSLA = ATJtoSLAMap.get(relatedATJ);
                        Account_Treatment_Address__c defaultAddress = ATIdToDefaultATAMap.get(relatedATJ.Patient_Treatment__c);
                        Account_Sales_Organization__c relatedASO = ASOMap.get(relatedATJ.Contract_Treatment_Job__r.Contract_Framework__r.Branch_of_belonging_sales_office__c);

                        if(defaultAddress != null) {
                            if(c.Next_Activity_Date__c != null/*  && c.Next_Activity_Date__c > Datetime.now() */) {
                                dueDate = c.Next_Activity_Date__c;
                            }
                            /* else {
                                dueDate = Datetime.now();
                            } */

                            if(dueDate != null) {
                                try {
                                    newWorkOrder = createWorkOrder(relatedATJ, dueDate, defaultAddress, relatedSLA, relatedASO, bh);
                                }
                                catch(Exception e) {
                                    System.debug('EXCEPTION');
                                    System.debug(e.getMessage());
                                }

                                if(newWorkOrder != null) {
                                    newWorkOrder.CaseId = c.Id;

                                    toInsert.add(newWorkOrder);

                                    if(!relatedATIds.contains(c.Account_Treatment_Job__r.Patient_Treatment__c)) {
                                        relatedATIds.add(c.Account_Treatment_Job__r.Patient_Treatment__c);
                                    }
                                }
                            }
                        }
                    }
                }
            }

            if(!toInsert.isEmpty()) {
                List<Database.SaveResult> results = Database.insert(toInsert, false);

                for(WorkOrder wo : toInsert) {
                    if(wo.Id != null) {
                        newWorkOrderIds.add(wo.Id);
                    }
                }
            }

            for(Case c : cases) {
                c.WorkOrderToBeCreated__c = false;
            }

            List<Database.SaveResult> results = Database.update(cases, false);
        }
    }

    public void finish(Database.BatchableContext bc) {
        ATAAlignmentBatch ATABatch = new ATAAlignmentBatch();
        ATABatch.ATIds = relatedATIds;

        // Launching ServiceTerritory Batch

        ServiceTerritoryUpdateBatch serviceTerritoryBatch = new ServiceTerritoryUpdateBatch();
        serviceTerritoryBatch.ATAAlignmentBatch = ATABatch;
        serviceTerritoryBatch.ATABatchSize = 100;
        serviceTerritoryBatch.WOLIBatchSize = 10;
        
        if(!newWorkOrderIds.isEmpty()) {
            WOLICreationBatch woliBatch = new WOLICreationBatch();
            woliBatch.globalWorkOrderIds = newWorkOrderIds;

            if(!Test.isRunningTest()) {
                serviceTerritoryBatch.WOLIBatch = woliBatch;
            }
        }

        Database.executeBatch(serviceTerritoryBatch, 50);
        
        System.debug('DONE'); //TODO
    }

    private WorkOrder createWorkOrder(Account_Treatment_Job__c atj, Datetime dueDate, Account_Treatment_Address__c defaultAddress, 
    Contract_Treatment_Job_SLA__c relatedSLA, Account_Sales_Organization__c relatedASO, BusinessHours bh) {
        WorkOrder newWorkOrder;
        DatesResponseDTO relatedDates;

        if(relatedSLA != null) {
            relatedDates = ATMainComponentService.calculateDates(
                dueDate, 
                relatedSLA.Max_Time__c, 
                relatedSLA.Unite_of_measure_Max_Time__c, // To fix, unit not unite
                relatedSLA.Calculation_Mode__c, 
                relatedSLA.Offset_Start_Date__c, 
                relatedSLA.Offset_End_Date__c, 
                relatedSLA.Offset_unit_of_measure__c, 
                relatedSLA.Offset_calculation_mode__c,
                bh,
                true
            );
        }

        if(defaultAddress != null) {
            newWorkOrder = new WorkOrder(

                // Fields from the ATJ

                AccountId = atj.Patient_Treatment__r.Account__c,
                Account_Sold_To__c = atj.Contract_Treatment_Job__r.Contract_Framework__r.Customer__c,
                Account_Sales_Organization__c = atj.Contract_Treatment_Job__r.Contract_Framework__r.Branch_of_belonging_sales_office__c,
                Account_Treatment__c = atj.Patient_Treatment__c,
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

            if(relatedSLA != null) {
                newWorkOrder.Related_SLA__c = relatedSLA.Id;
                
                if(relatedDates != null) {
                    newWorkOrder.Scheduled_Start_Date__c = relatedDates.startDate;
                    newWorkOrder.Scheduled_End_Date__c = relatedDates.endDate;
                    newWorkOrder.StartDate = relatedDates.startDate;
                    newWorkOrder.EndDate = relatedDates.endDate;
                    newWorkOrder.Due_Date__c = relatedDates.dueDate;
                }
            }
            else {
                newWorkOrder.Scheduled_Start_Date__c = dueDate;
                newWorkOrder.Scheduled_End_Date__c = dueDate;
                newWorkOrder.StartDate = dueDate;
                newWorkOrder.EndDate = dueDate;
                newWorkOrder.Due_Date__c = dueDate;
            }
        }

        return newWorkOrder;
    }
}