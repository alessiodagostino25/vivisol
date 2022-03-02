/* *
* @author Arturo Forneris
* @author Antonio Massaro
*/
public class ContractTreatmentController {
    @AuraEnabled
    public static List<ContractTreatmentListDTO> newGetContractTreatmentList(String contractFrameworkId) {
        return ContractTreatmentService.getContractTreatmentsWithLimit(contractFrameworkId);
    }

    @AuraEnabled
    public static String newGetContractTreatmentListNumber(String contractFrameworkId) {
        List<Contract_Treatment__c> queriedContractTreatments = ContractTreatmentDAO.getContractTreatmentsByFramworkId(contractFrameworkId);
        Integer size =  queriedContractTreatments.size();
        if (size < 4){
             return String.valueOf(size);
        } else {
             return '3+';
        }
    }

    @AuraEnabled
    public static string getNameFromId(String contractTreatmentRecordId){
        Contract_Treatment__c c= [SELECT Id, Name FROM Contract_Treatment__c WHERE Id =: contractTreatmentRecordId];
        String name = c.Name;
        return name;
    }

    /* *
    * Gets <code> getCorporateTreatment </code> This method return a Corporate Treatment Id by his Contract Treatment Id.
    *
    * @param contractTreatmentId String
    * @return corporateTreatmentId String
    */
    @AuraEnabled
    public static String getCorporateTreatment(String contractTreatmentRecordId){
        String corporateTreatmentId = ContractTreatmentService.getCorporateTreatmentIdByCTId(contractTreatmentRecordId);

        return corporateTreatmentId;
    }

    // When clicking New Contract Treatment, can only assign Create Permission Set
    @AuraEnabled
    public static void assignPermSetNew(){
        ContractTreatmentService.assignPermSetNew();
    }

    // When clicking Edit Contract Treatment, it depends on the Framework Status
    /* @AuraEnabled
    public static void assignPermSetEdit(String frameworkStatus){
        ContractTreatmentService.assignPermSetEdit(frameworkStatus);
    } */

    @AuraEnabled
    public static void removePermSet() {
        ContractTreatmentService.removePermSet();
    }

    @AuraEnabled
    public static string getFrameworkStatus(String contractFrameworkId){
        return ContractTreatmentService.getFrameworkStatus(contractFrameworkId);
    }

    @AuraEnabled
    public static void cloneContractTreatment(Id contractTreatmentId, Id contractFrameworkId, String name){
        cloneContractTreatmentAsync(contractTreatmentId, contractFrameworkId, name);
    }

    @AuraEnabled
    public static Boolean checkForSLAWarning(String contractTreatmentId) {
        List<String> scheduledCTJIds = new List<String>();
        Map<String, List<Contract_Treatment_Job_SLA__c>> CTJIdToSLAsMap = new Map<String, List<Contract_Treatment_Job_SLA__c>>();

        List<Contract_Treatment_Job__c> scheduledCTJs = [SELECT Id FROM Contract_Treatment_Job__c WHERE Contract_Treatment__c =: contractTreatmentId AND Scheduling_Rule__c != null];

        if(scheduledCTJs != null && !scheduledCTJs.isEmpty()) {
            for(Contract_Treatment_Job__c ctj : scheduledCTJs) {
                scheduledCTJIds.add(ctj.Id);
            }

            List<Contract_Treatment_Job_SLA__c> allRelatedSLAs = [SELECT Id, Contract_Treatment_Job__c FROM Contract_Treatment_Job_SLA__c WHERE Contract_Treatment_Job__c IN: scheduledCTJIds];

            if(allRelatedSLAs != null && !allRelatedSLAs.isEmpty()) {
                for(Contract_Treatment_Job_SLA__c sla : allRelatedSLAs) {
                    if(CTJIdToSLAsMap.get(sla.Contract_Treatment_Job__c) == null) {
                        CTJIdToSLAsMap.put(sla.Contract_Treatment_Job__c, new List<Contract_Treatment_Job_SLA__c>());
                    }
                    CTJIdToSLAsMap.get(sla.Contract_Treatment_Job__c).add(sla);
                }
            }

            if(!CTJIdToSLAsMap.isEmpty()) {
                for(Contract_Treatment_Job__c ctj : scheduledCTJs) {
                    List<Contract_Treatment_Job_SLA__c> relatedSLAs = CTJIdToSLAsMap.get(ctj.Id);

                    if(relatedSLAs == null || relatedSLAs.isEmpty()) {
                        return true;
                    }
                }
            }
            else {
                return true;
            }
        }

        return false;
    }

    @future
    public static void cloneContractTreatmentAsync(Id contractTreatmentId, Id contractFrameworkId, String name) {
        List<String> CTQueryFields = new List<String>{'Alternative_Description__c', 'Billable__c', 'Billing_Period__c', 'Billing_Rule__c', 'Billing_Unit__c',
        'Calculation_interval_Month_Rebate__c', 'Contract_Framework__c', 'Contract_Treatment_ID__c', 
        'Name', 'Corporate_Treatment__c', 'Customer_Purchase_Order_Date__c', 'Customer_Purchase_Order_Number__c', 'Customer_Request_Code__c',
        'Customer_Treatment_Alias__c', 'Description__c', 'Electricity_Rebates__c', 'End_day_Included_Excluded__c',
        'End_day_suspension_Included_Excluded__c','End_month_Included_Excluded__c', 'Invoice_Splitting_group__c', 'IS_UPFRONT__c', 
        'PriceListCode__c', 'Product__c', 'ROS__c', 'Rebate_Rule__c', 'Rounding__c', 'Rounding_perc__c','Scheduling_after_end_date__c', 
        'SplitEvaluation__c', 'Start_day_Included_Excluded__c', 'Start_day_suspension_Included_Excluded__c', 'Start_month_Included_Excluded__c',
        'Status__c','Threshold_AHI__c', 'Threshold_day__c', 'Threshold_hour__c', 'Time_rule_end_date__c', 'Time_rule_start_date__c', 'Business_Line__c', 
        'Treatment_Type__c', 'Model__c', 'Dental_surgent__c', 'RebateProduct__c', 'First_supply__c'};

        String exceptionMessage;
        Contract_Treatment__c contractTreatmentToClone = (ContractTreatmentDAO.getContractTreatmentsFromIds(CTQueryFields, new List<Id>{contractTreatmentId}))[0];

        // Cloning the Contract Treatment

        Contract_Treatment__c newCT = contractTreatmentToClone.clone(false, true, false, false);
        newCT.Contract_Framework__c = contractFrameworkId;
        newCT.Name = name;

        try {
            insert newCT;
            System.debug('newCT inserted: ' + newCT);

            // Cloning Contract Treatment Jobs: returns a map linking the Id of the job used to cloned and the new cloned job

            Map<Id, Contract_Treatment_Job__c> clonedCTJsMap = ContractTreatmentService.cloneRelatedCTJs(contractTreatmentId, newCT);

            if(!clonedCTJsMap.isEmpty()) {
                List<Contract_Treatment_Job__c> newCTJs = clonedCTJsMap.values();

                if(!newCTJs.isEmpty()) {
                    insert newCTJs;
                    System.debug('newCTJs inserted: ' + newCTJs.size());
                }
            }

            // Cloning Contract Treatment Job Products and Default BOMs (CTJPs are already inserted because DefaultBOMs depend on them. DefaultBOMs are already inserted too)
            
            List<Contract_Treatment_Job_Product__c> newCTJPs = ContractTreatmentService.cloneRelatedCTJPsAndDefaultBOMs(clonedCTJsMap);

            if(!newCTJPs.isEmpty()) {
                System.debug('newCTJPs inserted: ' + newCTJPs.size());
            }

            // Cloning Contract Treatment Job SLAs

            List<Contract_Treatment_Job_SLA__c> newSLAs = ContractTreatmentService.cloneRelatedSLAs(clonedCTJsMap);

            if(!newSLAs.isEmpty()) {
                insert newSLAs;
                System.debug('newSLAs inserted: ' + newSLAs.size());
            }

            // Cloning Contract Product Limits

            List<Contract_Product_Limit__c> newLimits = ContractTreatmentService.cloneRelatedLimits(contractTreatmentId, newCT);

            if(!newLimits.isEmpty()) {
                insert newLimits;
                System.debug('newLimits inserted: ' + newLimits.size());
            }
        }
        catch(DmlException e) {
            exceptionMessage = e.getDmlMessage(0);
        }

        //return newCT.Id;

        CustomNotificationType type = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'Autoscheduling_Finished'];
            
        if(type != null) {
            Messaging.CustomNotification notification = new Messaging.CustomNotification();

            notification.setNotificationTypeId(type.Id);

            if(exceptionMessage == null && newCT != null && newCT.Id != null) {
                notification.setTargetId(newCT.Id);
                notification.setBody(Label.ContractTreatmentCloning_Notification_Body);
                notification.setTitle(Label.ContractTreatmentCloning_Notification_Title);
            }
            else {
                notification.setTargetId(contractTreatmentId);
                notification.setBody(exceptionMessage);
                notification.setTitle(Label.ContractTreatmentCloning_Notification_Title_Error);
            }

            try {
                System.debug('notification: ' + notification);
                notification.send(new Set<String>{Userinfo.getUserId()});
            }
            catch(Exception e) {
                System.debug('Problem sending notification: ' + e.getMessage());
            }
        }
    }

    @AuraEnabled
    public static List<ProductTypeDTO> getBusinessLineOptionsBySO(String salesOrgCode) {
        List<ProductTypeDTO> picklistOptions = new List<ProductTypeDTO>();
        Map<String, String> picklistOptionsMap = new Map<String, String>();
        Map<String, ProductTypeDTO> dtoMap = new Map<String, ProductTypeDTO>();

        List<Business_Line_Treatment_Mapping__mdt> optionsMappings = [SELECT Business_Line__c FROM Business_Line_Treatment_Mapping__mdt WHERE Sales_Org_Code__c =: salesOrgCode];

        Schema.SObjectType sObjectType = Schema.getGlobalDescribe().get('Contract_Treatment__c');
        Schema.DescribeSObjectResult sObjectDescription = sObjectType.getDescribe();
        Map<String, Schema.SObjectField> fieldMap = sObjectDescription.fields.getMap();

        Schema.DescribeFieldResult businessLineFieldResult = fieldMap.get('Business_Line__c').getDescribe();
        // Schema.DescribeFieldResult treatmentTypeFieldResult = fieldMap.get('Treatment_Type__c').getDescribe();

        List<Schema.PicklistEntry> businessLinePicklistValues = businessLineFieldResult.getPicklistValues();
        // List<Schema.PicklistEntry> treatmentTypePicklistValues = treatmentTypeFieldResult.getPicklistValues();

        for(Schema.PicklistEntry option : businessLinePicklistValues) {
            System.debug('option.label: ' + option.getLabel());
            System.debug('option.value: ' + option.getValue());
            
            picklistOptionsMap.put(option.getValue(), option.getLabel());
        }

        // Need to add to a map and filter to create only one DTO per BusinessLine.. I can't use GROUP BY on custom metadata records (yet)

        for(Business_Line_Treatment_Mapping__mdt mapping : optionsMappings) {
            if(!dtoMap.containsKey(String.valueOf(mapping.get('Business_Line__c')))) {
                ProductTypeDTO optionDTO = new ProductTypeDTO(
                    picklistOptionsMap.get(String.valueOf(mapping.get('Business_Line__c'))),
                    String.valueOf(mapping.get('Business_Line__c'))
                );

                picklistOptions.add(optionDTO);
                dtoMap.put(optionDTO.value, optionDTO);
            }
        }

        return picklistOptions;
    }

    @AuraEnabled
    public static List<ProductTypeDTO> getTreatmentTypeOptionsBySOAndBL(String salesOrgCode, String businessLine) {
        List<ProductTypeDTO> picklistOptions = new List<ProductTypeDTO>();
        Map<String, String> picklistOptionsMap = new Map<String, String>();
        Map<String, ProductTypeDTO> dtoMap = new Map<String, ProductTypeDTO>();

        List<Business_Line_Treatment_Mapping__mdt> optionsMappings = [SELECT Treatment_Type__c FROM Business_Line_Treatment_Mapping__mdt 
                                                                      WHERE Sales_Org_Code__c =: salesOrgCode AND Business_Line__c =: businessLine];

        Schema.SObjectType sObjectType = Schema.getGlobalDescribe().get('Contract_Treatment__c');
        Schema.DescribeSObjectResult sObjectDescription = sObjectType.getDescribe();
        Map<String, Schema.SObjectField> fieldMap = sObjectDescription.fields.getMap();

        Schema.DescribeFieldResult businessLineFieldResult = fieldMap.get('Treatment_Type__c').getDescribe();
        // Schema.DescribeFieldResult treatmentTypeFieldResult = fieldMap.get('Treatment_Type__c').getDescribe();

        List<Schema.PicklistEntry> businessLinePicklistValues = businessLineFieldResult.getPicklistValues();
        // List<Schema.PicklistEntry> treatmentTypePicklistValues = treatmentTypeFieldResult.getPicklistValues();

        for(Schema.PicklistEntry option : businessLinePicklistValues) {
            System.debug('option.label: ' + option.getLabel());
            System.debug('option.value: ' + option.getValue());
            
            picklistOptionsMap.put(option.getValue(), option.getLabel());
        }

        // Need to add to a map and filter to create only one DTO per BusinessLine.. I can't use GROUP BY on custom metadata records (yet)

        for(Business_Line_Treatment_Mapping__mdt mapping : optionsMappings) {
            if(!dtoMap.containsKey(String.valueOf(mapping.get('Treatment_Type__c')))) {
                ProductTypeDTO optionDTO = new ProductTypeDTO(
                    picklistOptionsMap.get(String.valueOf(mapping.get('Treatment_Type__c'))),
                    String.valueOf(mapping.get('Treatment_Type__c'))
                );

                picklistOptions.add(optionDTO);
                dtoMap.put(optionDTO.value, optionDTO);
            }
        }

        return picklistOptions;
    }
}