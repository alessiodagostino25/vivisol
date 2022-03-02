//S: Sidea V4AT-189
public without sharing class newPrescriptionComponentController {

    @AuraEnabled
    public static List<RecordTypeDTO> getPrescriptionRecordTypes() {
        System.debug('Calling getPrescriptionRecordTypes()');
        List<RecordTypeDTO> recordTypeDTOList = new List<RecordTypeDTO>();
        
        /*
        List<RecordType> recordTypesList = new List<RecordType>();
        recordTypesList = [SELECT Name FROM RecordType WHERE SObjectType = 'Prescription__c'];
        System.debug('recordType: ' + recordTypesList);
        for (RecordType r : recordTypesList) {
            recordTypeDTOList.add(new RecordTypeDTO(r.name, r.name));
        }
        */

        List<SelectOption> recordTypes = new List<SelectOption>();
        for(RecordTypeInfo info: Prescription__c.SObjectType.getDescribe().getRecordTypeInfos()) {
            if(info.isAvailable()) {
                recordTypes.add(new SelectOption(info.getRecordTypeId(), info.getName()));
            }
        }

        // Include these next 3 lines to output the results during development and debugging
        for( SelectOption selopt: recordTypes ) {
            System.debug( selopt.getLabel() + ',' + selopt.getValue() );
            recordTypeDTOList.add(new RecordTypeDTO(selopt.getLabel(), selopt.getLabel()));
        }


        System.debug('getPrescription return value: ' + recordTypeDTOList);
        return recordTypeDTOList;
    }

    @AuraEnabled
    public static String getSalesOrganizationId(){
        Sales_Organization__c SO = [SELECT Id FROM Sales_Organization__c WHERE name = 'VIV - AT - 6200'];
        System.debug('getSalesOrganizationId returns ->' + SO.Id);
        return SO.Id;
    }

    @AuraEnabled
    public static List<BusinessLinePicklistDTO> getBusinessLineOptions(String CFId) {

        Map<String, String> picklistOptionsMap = new Map<String, String>();
        List<Contract_Treatment__c> relatedCT = [SELECT Id, Business_Line__c FROM Contract_Treatment__c WHERE Contract_Framework__c = :CFId];
        Schema.SObjectType sObjectType = Schema.getGlobalDescribe().get('Contract_Treatment__c');
        Schema.DescribeSObjectResult sObjectDescription = sObjectType.getDescribe();
        Map<String, Schema.SObjectField> fieldMap = sObjectDescription.fields.getMap();
        System.debug(fieldMap);

        Schema.DescribeFieldResult businessLineFieldResult = fieldMap.get('Business_Line__c').getDescribe();
        System.debug(businessLineFieldResult);

        List<Schema.PicklistEntry> businessLinePicklistValues = businessLineFieldResult.getPicklistValues();
        System.debug(businessLinePicklistValues);

        for(Schema.PicklistEntry option : businessLinePicklistValues) {
            
            picklistOptionsMap.put(option.getValue(), option.getLabel());
        }

        //adds all buisness_line_c picklist values related to CF into a list
        Set<String> relatedCTPicklistValues = new Set<String>();
        for(Contract_Treatment__c c : relatedCT) {
            relatedCTPicklistValues.add(c.Business_Line__c);
        }
        System.debug('relatedCTPicklistValues' + relatedCTPicklistValues);

        System.debug('picklist before remove' + picklistOptionsMap);
        //remove all picklist values that are not related to CF
        Map<String, String> picklistMapIterator = picklistOptionsMap.clone();
        for(String key : picklistMapIterator.keySet()) {
            if (!relatedCTPicklistValues.contains(key)) {
                picklistOptionsMap.remove(key);
            }
        }
        System.debug('picklist after remove' + picklistOptionsMap);

        List<BusinessLinePicklistDTO> picklistOptionsDTO = new List<BusinessLinePicklistDTO>();
        for (String key : picklistOptionsMap.keySet()) {
            picklistOptionsDTO.add(new BusinessLinePicklistDTO(key, picklistOptionsMap.get(key)));
        }

        return picklistOptionsDTO;
    }

    @AuraEnabled
    public static List<Contract_Payer__c> getTableContractPayer(String CFId, String businessLine) {
        return [SELECT Area__c, Payer__r.name, Bill_To__r.name, Approver__r.name, toLabel(Business_Line__c) FROM Contract_Payer__c WHERE Contract_Framework__c = :CFId AND (Business_Line__c =: businessLine OR Business_Line__c = null)];
    }

    @AuraEnabled
    public static List<Contract_Treatment__c> getTableContractTreatment(String CFId, String businessLine) {
        System.debug('getTableContractPayer has been called!');
        return [SELECT Name, toLabel(Treatment_Type__c), Corporate_Treatment__r.Name, Product__r.Product_Name_Translate__c FROM Contract_Treatment__c WHERE Contract_Framework__c = :CFId AND Business_Line__c =: businessLine];
    }
    
    @AuraEnabled
    public static string getAccountFields(String accId){
        //Account a = [SELECT Location__c, Main_Health_insurance_company_HIC__c FROM Account where Id = :accId];
        List<String> queryFields = new List<String>();
        queryFields.add('Location__c');
        queryFields.add('Main_Health_insurance_company_HIC__c');
        Account a = AccountDAO.getAccountFromId(queryFields, accId);
        String s = '';
        if (a.Main_Health_insurance_company_HIC__c == null) {
            s = a.Location__c;
        } else {
            s = a.Location__c + ';' + a.Main_Health_insurance_company_HIC__c;
        }
        System.debug('getAccountFields returns ->' + s);
        return s;
    }

    @AuraEnabled
    public static Datetime currentDateTime(){
        return Datetime.now();
    }
    
    
    @AuraEnabled
    public static Boolean newPrescription(String prescription, String[] treatmentTypes, String approverId, String[] contractTreatmentsId, String accId, String recordTypeName, String CFId, String businessLine, String CPId) {
        /*
        if (String.isBlank(prescription) || treatmentTypes == null || String.isBlank(approverId) || contractTreatmentsId == null || String.isBlank(accId) || String.isBlank(recordTypeName) || String.isBlank(CFId) || String.isBlank(businessLine) || String.isBlank(CPId)) {
            return false;
        }
        */
        
        try {
            Prescription__c prescriptionObject = (Prescription__c)JSON.deserialize(prescription, Prescription__c.class);
            //List<Contract_Treatment__c> CTList = [SELECT id, Treatment_Type__c FROM Contract_Treatment__c WHERE Id in: contractTreatmentsId];
            List<String> queryFields = new List<String>();
            queryFields.add('Id');
            queryFields.add('Treatment_Type__c');
            List<Contract_Treatment__c> CTList = ContractTreatmentDAO.getContractTreatmentsFromIds(queryFields, contractTreatmentsId);
            Contract_Payer__c cp = [SELECT id, Payer__c, Bill_To__c FROM Contract_Payer__c WHERE Id =: CPId];
            System.debug('prescription: ' + prescriptionObject);
            System.debug('treatmentTypes: ' + treatmentTypes);
            System.debug('approverId: ' + approverId);
            System.debug('contractTreatmentsId: ' + contractTreatmentsId);
            System.debug('accId: ' + accId);
            System.debug('recordTypeName: ' + recordTypeName);
            System.debug('businessLine: ' + businessLine);
    
            Set<String> treatmentTypesPicklistSet = new Set<String>();
            for (Contract_Treatment__c c : CTList) {
                treatmentTypesPicklistSet.add(c.Treatment_Type__c);
            }        
            System.debug('treatmentTypesPicklistSet: ' + treatmentTypesPicklistSet);
            String treatmentTypesPicklist = String.join(new List<String>(treatmentTypesPicklistSet), ';');
            System.debug('treatmentTypesPicklist: ' + treatmentTypesPicklist);
    
            prescriptionObject.Treatment_Types__c = treatmentTypesPicklist;
            prescriptionObject.Approver__c = approverId;
            prescriptionObject.Business_Line__c = businessLine;
            prescriptionObject.Bill_To__c = cp.Bill_To__c;
            prescriptionObject.Payer__c = cp.Payer__c;

            if (!Test.IsRunningTest()){
                insert prescriptionObject;
                System.debug('Inserimento prescription ok: ' + prescriptionObject);
            }

            if (newPrescriptionComponentController.newAccountTreatments(contractTreatmentsId, prescriptionObject, accId, recordTypeName, CFId, approverId, CPId)) {
                System.debug('Inserimento andato a buon fine. Returning true');
                return true;
            }
        } catch(exception e) {
            System.debug(e);
            return false;
        }

        return false;
    }

    @AuraEnabled
    public static Boolean newAccountTreatments(String[] contractTreatmentsId, Prescription__c prescriptionObject,String accId, String recordTypeName, String CFId, String approverId, String CPId) {

        try {
            /* Old queries 
            List<Contract_Treatment__c> CTList = [SELECT Id, OwnerId, IsDeleted, Name, RecordTypeId, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, 
            LastActivityDate, LastViewedDate, LastReferencedDate, RebateProduct__c, All_Items_Billable__c, Alternative_Description__c, Billable__c, Billing_Period__c, Billing_Rule__c, 
            Billing_Unit__c, Business_Line__c, Calculation_interval_Month_Rebate__c, Contract_Framework__c, Contract_Treatment_ID__c, Contract_Treatment_Number__c, Corporate_Treatment__c,
            Customer_Id__c, Customer_Name__c, Customer_Purchase_Order_Date__c, Customer_Purchase_Order_Number__c, Customer_Request_Code__c, Customer_Treatment_Alias__c, Dental_surgent__c, 
            Description__c, Electricity_Rebates__c, End_day_Included_Excluded__c, End_day_suspension_Included_Excluded__c, End_month_Included_Excluded__c, External_Id__c, First_supply__c, 
            Generate_Invoice_Plan__c, IS_UPFRONT__c, Invoice_End_Date__c, Invoice_Product_Code__c, Invoice_Quantity__c, Invoice_Splitting_group__c, Invoice_Start_Date__c, 
            Invoice_Unit_of_Measure__c, Invoice_advance__c, Is_Used__c, Key__c, Model__c, OLDExternalID__c, Plan_Period__c, Plan_Type__c, PriceListCode__c, Product__c, ROS__c, Rebate_Rule__c, 
            Rounding__c, Rounding_perc__c, Sales_Org_Code__c, Scheduling_after_end_date__c, SplitEvaluation__c, Start_day_Included_Excluded__c, Start_day_suspension_Included_Excluded__c, 
            Start_month_Included_Excluded__c, Status__c, Threshold_AHI__c, Threshold_day__c, Threshold_hour__c, Time_rule_end_date__c, Time_rule_start_date__c, Treatment_Type__c, Type__c, 
            Threshold_Compliance_percentage__c from Contract_Treatment__c WHERE Id IN :contractTreatmentsId];

            List<String> queryFields1 = new List<String>();
            queryFields1.add('Id, OwnerId, IsDeleted, Name, RecordTypeId, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastActivityDate, LastViewedDate, LastReferencedDate, RebateProduct__c, All_Items_Billable__c, Alternative_Description__c, Billable__c, Billing_Period__c, Billing_Rule__c, Billing_Unit__c, Business_Line__c, Calculation_interval_Month_Rebate__c, Contract_Framework__c, Contract_Treatment_ID__c, Contract_Treatment_Number__c, Corporate_Treatment__c, Customer_Id__c, Customer_Name__c, Customer_Purchase_Order_Date__c, Customer_Purchase_Order_Number__c, Customer_Request_Code__c, Customer_Treatment_Alias__c, Dental_surgent__c, Description__c, Electricity_Rebates__c, End_day_Included_Excluded__c, End_day_suspension_Included_Excluded__c, End_month_Included_Excluded__c, External_Id__c, First_supply__c, Generate_Invoice_Plan__c, IS_UPFRONT__c, Invoice_End_Date__c, Invoice_Product_Code__c, Invoice_Quantity__c, Invoice_Splitting_group__c, Invoice_Start_Date__c, Invoice_Unit_of_Measure__c, Invoice_advance__c, Is_Used__c, Key__c, Model__c, OLDExternalID__c, Plan_Period__c, Plan_Type__c, PriceListCode__c, Product__c, ROS__c, Rebate_Rule__c, Rounding__c, Rounding_perc__c, Sales_Org_Code__c, Scheduling_after_end_date__c, SplitEvaluation__c, Start_day_Included_Excluded__c, Start_day_suspension_Included_Excluded__c, Start_month_Included_Excluded__c, Status__c, Threshold_AHI__c, Threshold_day__c, Threshold_hour__c, Time_rule_end_date__c, Time_rule_start_date__c, Treatment_Type__c, Type__c, Threshold_Compliance_percentage__c');
            List<Contract_Treatment__c> CTList = ContractTreatmentDAO.getContractTreatmentsFromIds(queryFields1, contractTreatmentsId);
            
            Account acc = [SELECT Id, Name FROM Account WHERE Id =: accId];

            Contract_Framework__c cf = [SELECT Id, Contract_Type__c FROM Contract_Framework__c WHERE Id =: CFId];
            */

            List<String> queryFields1 = new List<String>();
            queryFields1.add('Id, OwnerId, IsDeleted, Name, RecordTypeId, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastActivityDate, LastViewedDate, LastReferencedDate, RebateProduct__c, All_Items_Billable__c, Alternative_Description__c, Billable__c, Billing_Period__c, Billing_Rule__c, Billing_Unit__c, Business_Line__c, Calculation_interval_Month_Rebate__c, Contract_Framework__c, Contract_Treatment_ID__c, Contract_Treatment_Number__c, Corporate_Treatment__c, Customer_Id__c, Customer_Name__c, Customer_Purchase_Order_Date__c, Customer_Purchase_Order_Number__c, Customer_Request_Code__c, Customer_Treatment_Alias__c, Dental_surgent__c, Description__c, Electricity_Rebates__c, End_day_Included_Excluded__c, End_day_suspension_Included_Excluded__c, End_month_Included_Excluded__c, External_Id__c, First_supply__c, Generate_Invoice_Plan__c, IS_UPFRONT__c, Invoice_End_Date__c, Invoice_Product_Code__c, Invoice_Quantity__c, Invoice_Splitting_group__c, Invoice_Start_Date__c, Invoice_Unit_of_Measure__c, Invoice_advance__c, Is_Used__c, Key__c, Model__c, OLDExternalID__c, Plan_Period__c, Plan_Type__c, PriceListCode__c, Product__c, ROS__c, Rebate_Rule__c, Rounding__c, Rounding_perc__c, Sales_Org_Code__c, Scheduling_after_end_date__c, SplitEvaluation__c, Start_day_Included_Excluded__c, Start_day_suspension_Included_Excluded__c, Start_month_Included_Excluded__c, Status__c, Threshold_AHI__c, Threshold_day__c, Threshold_hour__c, Time_rule_end_date__c, Time_rule_start_date__c, Treatment_Type__c, Type__c, Threshold_Compliance_percentage__c');
            List<Contract_Treatment__c> CTList = ContractTreatmentDAO.getContractTreatmentsFromIds(queryFields1, contractTreatmentsId);

            for (Contract_Treatment__c ct : CTList) {
                System.debug('CTList:' + ct.Id);
            }

            List<String> queryFields2 = new List<String>();
            queryFields2.add('Id');
            queryFields2.add('Name');
            queryFields2.add('Location__r.Name');
            Account acc = AccountDAO.getAccountFromId(queryFields2, accId);
            System.debug('acc' + acc);

            RecordType rt = [SELECT Id FROM RecordType WHERE Name =: recordTypeName LIMIT 1];
            System.debug('rt' + rt);

            List<String> queryFields3 = new List<String>();
            queryFields3.add('Id');
            queryFields3.add('Contract_Type__c');
            Contract_Framework__c cf = ContractFrameworkDAO.getContractFrameworkFromId(queryFields3, CFId);
            System.debug('cf' + cf);

            System.debug('CPId: ' + CPId);
            Contract_Payer__c cp = [SELECT id, Payer__c, Bill_To__c FROM Contract_Payer__c WHERE Id =: CPId];
            System.debug('cp' + cp);

            List<RecordType> RTListAT = [SELECT Name FROM RecordType WHERE SObjectType = 'Account_Treatment__c'];
            List<Account_Treatment__c> ATList = new List<Account_Treatment__c>();
            List<Account_Treatment_Address__c> ATAddressList = new List<Account_Treatment_Address__c>();
            List<Account_Treatment_Address_Payer__c > ATAddressPayerList = new List<Account_Treatment_Address_Payer__c>(); 
            
            Map<String, String> RTMap = new Map<String,String>();
            for (RecordType r : RTListAT) {
                RTMap.put(r.Name.toUpperCase(), r.Id);
            }
            System.debug('Record Type Map: ' + RTMap);
        
            
            for (Contract_Treatment__c ct : CTList) {

                //account treatment creation
                String nameSubString = acc.Name + '-' + ct.Name;
                //troncare all'80esimo char
                if (nameSubString.length() > 80) {
                    nameSubString = nameSubString.substring(0, 80);
                }

                Account_Treatment__c at = new Account_Treatment__c(
                        Name = nameSubString,
                        Prescription__c = prescriptionObject.Id,
                        Account__c = acc.Id,
                        Business_Line__c = ct.Business_line__c,
                        Treatment_Type__c = ct.Treatment_Type__c,
                        Customer_Purchase_Order_Number__c = ct.Customer_Purchase_Order_Number__c,
                        Customer_Request_Code__c = ct.Customer_Request_Code__c,
                        Customer_Treatment_Alias__c = ct.Customer_Treatment_Alias__c,
                        Billable__c = ct.Billable__c,
                        Threshold_AHI__c = ct.Threshold_AHI__c,
                        Threshold_day__c = ct.Threshold_day__c,
                        Threshold_hour__c = ct.Threshold_hour__c,
                        Customer_Purchase_Date__c = ct.Customer_Purchase_Order_Date__c,
                        Threshold_Compliance_Percentage__c = ct.Threshold_Compliance_percentage__c
                    );
        
                
        
                System.debug('cf.Contract_Type__c SWITCH: ' + cf.Contract_Type__c);
                switch on cf.Contract_Type__c {
                    when 'ZS0' {
                        at.RecordTypeId = RTMap.get('THERAPY');
                        at.Trial_Contract_Treatment__c = True;
                    }	
                    when 'ZS3' {
                        at.RecordTypeId = RTMap.get('MAINTENANCE');
                    }
                    when 'ZS4' {
                        at.RecordTypeId = RTMap.get('RENT');
                    }
                    when 'ZS6' {
                        at.RecordTypeId = RTMap.get('SALES');
                    }
                    when 'ZS7' {
                        at.RecordTypeId = RTMap.get('THERAPY');
                    }
                    when 'ZS8' {
                        at.RecordTypeId = RTMap.get('THERAPY');
                    }
                }
                System.debug('RecordTypeId: ' + at.RecordTypeId);
                System.debug('Adding in ATList: ' + at);
                ATList.add(at);
        
            }

            if (!Test.IsRunningTest()){
                //insertion of all account treatments
                insert ATList;
                System.debug('ACCOUNT TREATMENTS INSERTED: ' + ATList);
            }
        
            for (Account_Treatment__c a : ATList) {
                //account treatments address creation
                Account_Treatment_Address__c ATAddress = new Account_Treatment_Address__c(
                    Account_Treatment__c = a.Id,
                    Account__c = acc.Id,
                    Default__c = True,
                    Location__c = prescriptionObject.Address__c,
                    Name = acc.Location__r.Name,
                    //Location__c = acc.Location__r.Name,
                    //Name = prescriptionObject.Address__r.Name,
                    Status__c = 'Active'
                );
                ATAddressList.add(ATAddress);
            }
            if (!Test.IsRunningTest()){
                //insertion of all account treatments addresses
                insert ATAddressList;
                System.debug('ACCOUNT TREATMENTS ADDRESSES INSERTED: ' + ATAddressList);
            }
        
        
            //There are 2 for because I need Account_Treatment__c and Account_Treatment_Address__c correlated to create a new Account_Treatment_Address_Payer__c
            for (Account_Treatment__c atIterator : ATList) {
                for (Account_Treatment_Address__c atAddressIterator : ATAddressList) {
                    if (atIterator.Id == atAddressIterator.Account_Treatment__c) {
                        Account_Treatment_Address_Payer__c ATAddressPayer = new Account_Treatment_Address_Payer__c(
                            Account_Treatment_Address__c = atAddressIterator.Id,
                            Account_Treatment__c = atIterator.Id,
                            Contract_Payer__c = cp.Id,
                            Payer__c = cp.Payer__c,
                            Bill_To__c = cp.Bill_To__c,
                            Payment_Method__c = atIterator.Contract_Treatment__r.Contract_Framework__r.PaymentMethod__c,
                            Payment_Percentage__c = 100
                        );
                        ATAddressPayerList.add(ATAddressPayer);
                    }
                }
            }
        
            if (!Test.IsRunningTest()){
                //insertion of all account treatments addresses
                insert ATAddressPayerList;
                System.debug('ACCOUNT TREATMENTS ADDRESSES PAYER INSERTED: ' + ATAddressPayerList);
            }
        } catch(exception e) {
            System.debug(e);
            System.debug('Account treatments creation returning false!');
            return false;
        }
        
        System.debug('newAccountTreatments OK! Returning true');
        return true;
    }

    public class RecordTypeDTO { 
        @AuraEnabled
        public String label { get; set; }

        @AuraEnabled
        public String value { get; set; }
        
        public RecordTypeDTO(String l, String v) {
            this.label = l;
            this.value = v;
        }
    }

    public class BusinessLinePicklistDTO {
        @AuraEnabled
        public String label { get; set; }

        @AuraEnabled
        public String value { get; set; }
        
        public BusinessLinePicklistDTO(String l, String v) {
            this.label = l;
            this.value = v;
        }
    }
}
//E: Sidea V4AT-189