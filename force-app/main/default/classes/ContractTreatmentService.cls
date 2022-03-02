/* *
* @author Arturo Forneris
* @author Antonio Massaro
*/
public class ContractTreatmentService {

    public static List<ContractTreatmentListDTO> getContractTreatmentsWithLimit(String contractFrameworkId){
        List<Contract_Treatment__c> queriedContractTreatments = ContractTreatmentDAO.getContractTreatmentsByFramworkIdWithLimit(contractFrameworkId) ;
        List<ContractTreatmentListDTO> contractTreatmentDTOs = new List<ContractTreatmentListDTO>();
        if (!queriedContractTreatments.isEmpty()) {
            for (Contract_Treatment__c treatment : queriedContractTreatments) {
                contractTreatmentDTOs.add(new ContractTreatmentListDTO(treatment));
            }        
        }
        return contractTreatmentDTOs;
    }

    /* *
    * Gets <code> getCorporateTreatmentIdByCTId </code> This method return a Corporate Treatment Id by his Contract Treatment Id.
    *
    * @param contractTreatmentId String
    * @return corporateTreatmentId String
    */
    public static String getCorporateTreatmentIdByCTId(String contractTreatmentRecordId) {
        Contract_Treatment__c contractTreatment = [SELECT Id, Corporate_Treatment__c FROM Contract_Treatment__c WHERE Id =: contractTreatmentRecordId];
        Id corporateTreatmentId = contractTreatment.Corporate_Treatment__c;

        return corporateTreatmentId;
    }

    public static void assignPermSetNew() { 
        if(!Test.isRunningTest()) {
            Map<String, String> sessionManagement = Auth.SessionManagement.getCurrentSession();
            final String sessionId;
            if(sessionManagement.get('ParentId') != null) {
                sessionId = sessionManagement.get('ParentId');
            }
            else {
                sessionId = sessionManagement.get('SessionId');
            }

            List<PermissionSet> psList = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Contract_Creation'];
            if(psList != null && !psList.isEmpty()) {
                PermissionSet ps = psList[0];
                SessionPermSetActivation activation = new SessionPermSetActivation();
                activation.AuthSessionId = sessionId;
                System.debug('AuthSessionId: ' + activation.AuthSessionId);
                activation.PermissionSetId = ps.Id;
                activation.Description = 'created by SessionPermSetActivationController';
                insert activation;
                System.debug('Activation Id: ' + activation.Id);
            }
        }
    }

    // Not used anymore
    /* public static void assignPermSetEdit(String frameworkStatus) {
        if(frameworkStatus == 'Draft') {
            /*PermissionSetAssignment psa = new PermissionSetAssignment();
            psa.PermissionSetId = '0PS9E0000009iDWWAY';
            psa.AssigneeId = UserInfo.getUserId();
            insert psa;
            Map<String, String> sessionManagement = Auth.SessionManagement.getCurrentSession();
            final String sessionId;
            if(sessionManagement.get('ParentId') != null) {
                sessionId = sessionManagement.get('ParentId');
            }
            else {
                sessionId = sessionManagement.get('SessionId');
            }
            SessionPermSetActivation activation = new SessionPermSetActivation();
            activation.AuthSessionId = sessionId;
            activation.PermissionSetId = '0PS9E0000009iDWWAY';
            activation.Description = 'created by SessionPermSetActivationController';
            insert activation;
            System.debug('Activation Id: ' + activation.Id);
        }
        else if(frameworkStatus == 'Active') {
            /*PermissionSetAssignment psa = new PermissionSetAssignment();
            psa.PermissionSetId = '0PS9E0000009iVbWAI';
            psa.AssigneeId = UserInfo.getUserId();
            insert psa;
            Map<String, String> sessionManagement = Auth.SessionManagement.getCurrentSession();
            final String sessionId;
            if(sessionManagement.get('ParentId') != null) {
                sessionId = sessionManagement.get('ParentId');
            }
            else {
                sessionId = sessionManagement.get('SessionId');
            }
            SessionPermSetActivation activation = new SessionPermSetActivation();
            activation.AuthSessionId = sessionId;
            activation.PermissionSetId = '0PS9E0000009iVbWAI';
            activation.Description = 'created by SessionPermSetActivationController';
            insert activation;
            System.debug('Activation Id: ' + activation.Id);
        }
        else {
            System.debug('Framework is Inactive. No Permission Set assigned.');
        }
    } */

    public static void removePermSet() {
        Id userId = UserInfo.getUserId();
        List<PermissionSet> psList = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Contract_Creation'];

        if(psList != null && !psList.isEmpty()) {
            PermissionSet ps = psList[0];
            List<Id> permissionSetIds = new List<Id>();
            permissionSetIds.add(ps.Id);
            //permissionSetIds.add('0PS9E0000009iVbWAI');
            /*String userId = UserInfo.getUserId();

            List<PermissionSetAssignment> psa = [SELECT Id FROM PermissionSetAssignment WHERE PermissionSetId IN: permissionSetIds AND AssigneeId =: userId];

            delete psa;*/
            /* Map<String, String> sessionManagement = Auth.SessionManagement.getCurrentSession();
            final String sessionId;
            if(sessionManagement.get('ParentId') != null) {
                sessionId = sessionManagement.get('ParentId');
            }
            else {
                sessionId = sessionManagement.get('SessionId');
            } */
            List<SessionPermSetActivation> activations = [SELECT Id FROM SessionPermSetActivation WHERE UserId =: userId AND PermissionSetId IN: permissionSetIds];
            System.debug('Activations to remove: ' + activations.size());

            delete activations;
        }
    }

    public static String getFrameworkStatus(String contractFrameworkId) {
        System.debug('contractFrameworkId in getFrameworkStatus: ' + contractFrameworkId);
        List<String> queryFields = new List<String>{'Status__c'};
        Contract_Framework__c cf = ContractFrameworkDAO.getContractFrameworkFromId(queryFields, contractFrameworkId);
        return cf.Status__c;
    }

    // CLONING METHODS

    public static Map<Id, Contract_Treatment_Job__c> cloneRelatedCTJs(Id contractTreatmentId, Contract_Treatment__c newCT) {
        List<String> CTJQueryFields = new List<String>{'Billable__c', 'Case_Subtype__c', 'Case_Type__c', 'ComplianceFollowUp__c', 'ComplianceSource__c', 
        'Contract_Framework__c', 'Contract_Treatment__c', 'Contract_Treatment_Job_Code__c', 'Name', 'Corporate_Treatment_Job__c',
        'Customer_Product_Code__c', 'Default_BOM__c', 'Delivery_Channel__c', 'Frequency__c', 'Frequency_Unit_of_measure__c', 'Invoice_Splitting_group__c',
        'Job_Name__c', 'Last_Propagated_Delivery_Channel__c', 'Last_Propagated_Frequency__c', 'Last_Propagated_Frequency_UOM__c',
        'PriceListCode__c', 'Scheduling_Rule__c', 'Status__c', 'Task__c',
        'Task_Type__c', 'Work_Order__c', 'Work_Type__c', 'Back_Office_Review__c', 'Frequency_Type__c', 'Scheduling_Time_Frame__c'};

        Map<Id, Contract_Treatment_Job__c> cloningMap = new Map<Id, Contract_Treatment_Job__c>();
        List<Contract_Treatment_Job__c> CTJsToClone = ContractTreatmentJobDAO.getCTJsFromCTIds(CTJQueryFields, new List<Id>{contractTreatmentId});

        for(Contract_Treatment_Job__c toClone : CTJsToClone) {
            Contract_Treatment_Job__c newCTJ = toClone.clone(false, true, false, false);
            newCTJ.Contract_Treatment__c = newCT.Id;
            newCTJ.Contract_Framework__c = newCT.Contract_Framework__c;

            cloningMap.put(toClone.Id, newCTJ);
        }

        return cloningMap;
    }

    // This methods clones CTJPs and inserts them to be able to clone and insert DefaultBOMs too

    public static List<Contract_Treatment_Job_Product__c> cloneRelatedCTJPsAndDefaultBOMs(Map<Id, Contract_Treatment_Job__c> clonedCTJsMap) {
        List<String> CTJPQueryFields = new List<String>{'Billable__c', 'Configured_Checkbox__c', 'Contract_Treatment_Job__c',
        'Name', 'ContractTreatmentId__c', 'Customer_Product_Code__c', 'Customer_Request_Code__c',
        'Customer_Treatment_Alias__c', 'Default__c', 'Family__c', 'Family_sType__c', 'Frequency__c', 'Frequency_Unit_of_measure__c', 
        'Invoice_Splitting_criterion__c', 'Invoice_Splitting_group__c', 'Last_Propagated_Quantity__c', 'Line_Number__c', 'Max_Quantity__c', 'Min_Quantity__c',
        'Object_Type__c', 'Product__c', 'Product_Code__c', 'Product_Type__c', 'Product_Code_Text__c', 'Product_Name_Text__c', 'ProductName__c',
        'Purchase_order_date__c', 'Purchase_order_number__c', 'Quantity__c', 'Quantity_Unit_of_measure__c', 'Questionnaire__c', 'Status__c'};
        List<String> defaultBOMQueryFields = new List<String>{'Name', 'Contract_Treatment_Job_Product__c', 'Product__c'};

        Set<Id> oldCTJIds = clonedCTJsMap.keySet();

        List<Contract_Treatment_Job_Product__c> newCTJPs = new List<Contract_Treatment_Job_Product__c>();
        List<Contract_Treatment_Default_BOM__c> newDefaultBOMs = new List<Contract_Treatment_Default_BOM__c>();
        List<Id> CTJPToCloneIds = new List<Id>();
        List<Contract_Treatment_Default_BOM__c> defaultBOMsToClone = new List<Contract_Treatment_Default_BOM__c>();

        Map<Id, List<Contract_Treatment_Default_BOM__c>> defaultBOMMap = new Map<Id, List<Contract_Treatment_Default_BOM__c>>();
        Map<Id, Contract_Treatment_Job_Product__c> CTJPCloningMap = new Map<Id, Contract_Treatment_Job_Product__c>();

        List<Contract_Treatment_Job_Product__c> CTJPsToClone = ContractTreatmentJobProductDAO.getCTJPsFromCTJIds(CTJPQueryFields, oldCTJIds);

        for(Contract_Treatment_Job_Product__c toClone : CTJPsToClone) {
            CTJPToCloneIds.add(toClone.Id);
        }

        // Getting all the DefaultBOMs to clone and putting them in a CTJP.Id --> List<BOM> map

        if(!CTJPToCloneIds.isEmpty()) {
            defaultBOMsToClone = ContractTreatmentDefaultBomDAO.getDefaultBOMsFromCTJPIds(defaultBOMQueryFields, CTJPToCloneIds);

            // In the Family case, there can be two DefaultBOM with same CTJP but different Product__c

            for(Contract_Treatment_Default_BOM__c defaultBOM : defaultBOMsToClone) {
                if(defaultBOMMap.get(defaultBOM.Contract_Treatment_Job_Product__c) == null) {
                    defaultBOMMap.put(defaultBOM.Contract_Treatment_Job_Product__c, new List<Contract_Treatment_Default_BOM__c>());
                }

                defaultBOMMap.get(defaultBOM.Contract_Treatment_Job_Product__c).add(defaultBOM);
            }
        }

        // Cloning CTJPs

        for(Contract_Treatment_Job_Product__c toClone : CTJPsToClone) {
            Contract_Treatment_Job__c relatedNewCTJ = clonedCTJsMap.get(toClone.Contract_Treatment_Job__c);

            if(relatedNewCTJ != null) {
                Contract_Treatment_Job_Product__c newCTJP = toClone.clone(false, true, false, false);
                newCTJP.Contract_Treatment_Job__c = relatedNewCTJ.Id;

                newCTJPs.add(newCTJP);

                // This map links each CTJP Id I'm cloning to the new CTJP.
                CTJPCloningMap.put(toClone.Id, newCTJP);
            }
        }

        if(!newCTJPs.isEmpty()) {
            insert newCTJPs;

            // Cloning DefaultBOMs

            for(Contract_Treatment_Job_Product__c toClone : CTJPsToClone) {

                // Getting the DefaultBOMs related to the CTJP I cloned the new one from...
                List<Contract_Treatment_Default_BOM__c> relatedDefaultBOMs = defaultBOMMap.get(toClone.Id);
                System.debug('RelatedDefaultBOMs while cloning: ' + relatedDefaultBOMs);

                // ... Then getting the new CTJP cloned from toClone...
                Contract_Treatment_Job_Product__c clonedCTJP = CTJPCloningMap.get(toClone.Id);
                System.debug('ClonedCTJP: ' + clonedCTJP);

                if(clonedCTJP != null && relatedDefaultBOMs != null) {

                    // ... Finally cloning each DefaultBOM related to the old CTJP on the new one (can only do this after having inserted the new ones)
                    for(Contract_Treatment_Default_BOM__c defaultBOM : relatedDefaultBOMs) {
                        Contract_Treatment_Default_BOM__c clonedDefaultBOM = defaultBOM.clone(false, true, false, false);
                        clonedDefaultBOM.Contract_Treatment_Job_Product__c = clonedCTJP.Id;

                        newDefaultBOMs.add(clonedDefaultBOM);
                    }
                }
            }

            if(!newDefaultBOMs.isEmpty()) {
                insert newDefaultBOMs;
            }
        }

        return newCTJPs;
    }

    public static List<Contract_Treatment_Job_SLA__c> cloneRelatedSLAs(Map<Id, Contract_Treatment_Job__c> clonedCTJsMap) {
        List<String> SLAQueryFields = new List<String>{'Contract_Treatment_Job__c', 'IsDefault__c', 'Offset_calculation_mode__c', 'Offset_End_Date__c',
        'Offset_Start_Date__c', 'Offset_unit_of_measure__c', 'Status__c', 'Task_Calculation_Mode__c', 'Task_MaxTime_Execution__c', 'Task_Unite_of_measure_Max_Time__c',
        'Unite_of_measure_Max_Time__c', 'Urgency_Level__c', 'Name', 'Calculation_Mode__c', 'Max_Time__c', 'Offset_calculation_mode_Task__c', 
        'Offset_unit_of_measure_Task__c', 'Offset_Start_Date_Task__c', 'Offset_End_Date_Task__c'};

        Set<Id> oldCTJIds = clonedCTJsMap.keySet();
        List<Contract_Treatment_Job_SLA__c> newSLAs = new List<Contract_Treatment_Job_SLA__c>();
        List<Contract_Treatment_Job_SLA__c> SLAsToClone = ContractTreatmentJobSlaDAO.getSLAsFromCTJs(SLAQueryFields, oldCTJIds);

        for(Contract_Treatment_Job_SLA__c toClone : SLAsToClone) {
            Contract_Treatment_Job__c relatedNewCTJ = clonedCTJsMap.get(toClone.Contract_Treatment_Job__c);

            if(relatedNewCTJ != null) {
                Contract_Treatment_Job_SLA__c newSLA = toClone.clone(false, true, false, false);
                newSLA.Contract_Treatment_Job__c = relatedNewCTJ.Id;

                newSLAs.add(newSLA);
            }
        }

        return newSLAs;
    }

    public static List<Contract_Product_Limit__c> cloneRelatedLimits(Id contractTreatmentId, Contract_Treatment__c newCT) {
        List<String> productLimitQueryFields = new List<String>{'Name', 'Contract_Treatment__c', 'Frequency__c', 'Frequency_Unit_of_measure__c',
        'Max_Quantity__c', 'Min_Quantity__c', 'Product__c', 'Quantity_Unit_of_measure__c', 'Status__c'};

        List<Contract_Product_Limit__c> newLimits = new List<Contract_Product_Limit__c>();
        List<Contract_Product_Limit__c> limitsToClone = ContractProductLimitDAO.getLimitsFromCTIds(productLimitQueryFields, new List<Id>{contractTreatmentId});

        for(Contract_Product_Limit__c toClone : limitsToClone) {
            Contract_Product_Limit__c newLimit = toClone.clone(false, true, false, false);
            newLimit.Contract_Treatment__c = newCT.Id;

            newLimits.add(newLimit);
        }

        return newLimits;
    }

    public static void setExternalId(List<Contract_Treatment__c> contractTreatments) {
        SObjectServiceClass.updateExternalId('Contract_Treatment__c', 'Contract_Treatment_Number__c', 'External_Id__c', contractTreatments);
    }

    public static void updateCTJandCTJPsBillable(List<Contract_Treatment__c> contractTreatments) {
        System.debug('----- updateCTJandCTJPsBillable -----');
        
        List<String> CTJQueryFields = new List<String>{'Contract_Treatment__c', 'Billable__c'};
        List<String> CTJPQueryFields = new List<String>{'Contract_Treatment_Job__c', 'Contract_Treatment_Job__r.Contract_Treatment__c', 'Billable__c'};

        List<String> contractTreatmentIds = new List<String>();
        List<Contract_Treatment_Job__c> allRelatedCTJs = new List<Contract_Treatment_Job__c>();
        List<Contract_Treatment_Job_Product__c> allRelatedCTJPs = new List<Contract_Treatment_Job_Product__c>();

        for(Contract_Treatment__c contractTreatment : contractTreatments) {
            contractTreatmentIds.add(contractTreatment.Id);
        }

        allRelatedCTJs = ContractTreatmentJobDAO.getCTJsFromCTIds(CTJQueryFields, contractTreatmentIds);
        allRelatedCTJPs = ContractTreatmentJobProductDAO.getCTJPsFromCTIds(CTJPQueryFields, contractTreatmentIds);

        if(!allRelatedCTJs.isEmpty()) {
            for(Contract_Treatment_Job__c ctj : allRelatedCTJs) {
                ctj.Billable__c = true;
            }

            List<Database.SaveResult> results = Database.update(allRelatedCTJs);
        }

        if(!allRelatedCTJPs.isEmpty()) {
            for(Contract_Treatment_Job_Product__c ctjp : allRelatedCTJPs) {
                ctjp.Billable__c = true;
            }

            List<Database.SaveResult> results = Database.update(allRelatedCTJPs);
        }
    }
    
}