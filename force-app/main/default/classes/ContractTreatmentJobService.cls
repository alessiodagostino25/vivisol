/* *
* @author Arturo Forneris
*/
public class ContractTreatmentJobService {

    public static String getCorporateTreatmentJobByCTJId(String contractTreatmentJobId) {
        Contract_Treatment_Job__c cTJ = [SELECT Id, Corporate_Treatment_Job__c FROM Contract_Treatment_Job__c WHERE Id =: contractTreatmentJobId];
        String corporateTreatmentJobId = (String) cTJ.Corporate_Treatment_Job__c;

        return corporateTreatmentJobId;
    }

    public static String getCorporateTreatmentByCTJId(String contractTreatmentJobId) {
        Contract_Treatment_Job__c cTJ = [SELECT Id, Contract_Treatment__c FROM Contract_Treatment_Job__c WHERE Id =: contractTreatmentJobId];
        String contractTreatmentId = cTJ.Contract_Treatment__c;
        Contract_Treatment__c cT = [SELECT Id, Corporate_Treatment__c FROM Contract_Treatment__c WHERE Id =: contractTreatmentId];

        return cT.Corporate_Treatment__c;
    }

    public static String copyContractTreatmentJobAndRlated(String contractTreatmentJobIdToCopy, String corporateTreatmentJob, String contractTreatmentJobCode, 
    String contractTreatmentRecordId, String contractFrameworkId) {

        List<String> defaultBOMQueryFields = new List<String>{'Contract_Treatment_Job_Product__c', 'Product__c'};

        Contract_Treatment_Job__c contractToCopy = ContractTreatmentJobDAO.getContractTreatmentJobByCTJId(contractTreatmentJobIdToCopy);
        List <Contract_Treatment_Job_Sla__c> slaListToCopy = ContractTreatmentJobSlaDAO.getContractTreatmentJobSlaListByCTJId(contractToCopy.Id);
        List <Contract_Treatment_Job_Product__c> prodListToCopy = ContractTreatmentJobProductDAO.getContractTreatmentJobProductListByCTJId(contractToCopy.Id);
        List<Contract_Treatment_Job_Sla__c> newSLAs = new List<Contract_Treatment_Job_SLA__c>();
        List<Contract_Treatment_Job_Product__c> newCTJPs = new List<Contract_Treatment_Job_Product__c>();
        List<Contract_Treatment_Default_BOM__c> defaultBOMsToClone = new List<Contract_Treatment_Default_BOM__c>();
        Map<Id, List<Contract_Treatment_Default_BOM__c>> defaultBOMMap = new Map<Id, List<Contract_Treatment_Default_BOM__c>>();
        Map<Id, Contract_Treatment_Job_Product__c> CTJPCloningMap = new Map<Id, Contract_Treatment_Job_Product__c>();
        List<Id> CTJPIdsToCopy = new List<Id>();
        List<Contract_Treatment_Default_BOM__c> newDefaultBOMs = new List<Contract_Treatment_Default_BOM__c>();

        for(Contract_Treatment_Job_Product__c ctjp : prodListToCopy) {
            CTJPIdsToCopy.add(ctjp.Id);
        }

        // Getting all the Default BOMs related to the CTJPs to copy

        if(!CTJPIdsToCopy.isEmpty()) {
            defaultBOMsToClone = ContractTreatmentDefaultBomDAO.getDefaultBOMsFromCTJPIds(defaultBOMQueryFields, CTJPIdsToCopy);

            // In the Family case, there can be two DefaultBOM with same CTJP but different Product__c
            for(Contract_Treatment_Default_BOM__c defaultBOM : defaultBOMsToClone) {
                if(defaultBOMMap.get(defaultBOM.Contract_Treatment_Job_Product__c) == null) {
                    defaultBOMMap.put(defaultBOM.Contract_Treatment_Job_Product__c, new List<Contract_Treatment_Default_BOM__c>());
                }

                defaultBOMMap.get(defaultBOM.Contract_Treatment_Job_Product__c).add(defaultBOM);
            }
        }

        System.debug('Job Ids to copy: ' + contractToCopy.Id);

        // Copying Job
        Contract_Treatment_Job__c newCTJ = contractToCopy.clone(false, true, false, false);
        newCTJ.Contract_Framework__c = contractFrameworkId;
        newCTJ.Contract_Treatment__c = contractTreatmentRecordId;
        newCTJ.Corporate_Treatment_Job__c = corporateTreatmentJob;
        newCTJ.Contract_Treatment_Job_Code__c = contractTreatmentJobCode;

        insert newCTJ;

        System.debug('Job Ids copied: ' + newCTJ.Id);

        //Coping Sla list related to the Job I want to copy
        for(Contract_Treatment_Job_Sla__c sla : slaListToCopy) {

            Contract_Treatment_Job_Sla__c newSla = sla.clone(false, true, false, false);
            newSla.Contract_Treatment_Job__c = newCTJ.Id; 
                

            newSLAs.add(newSla);

            System.debug('Sla Ids inserted: ' + newSla.Id);
            System.debug('Copied SLA Name: ' + sla.Name);
        }
        
        if(!newSLAs.isEmpty()) {
            insert newSLAs;
        }

        //Coping Product list related to the Job I want to copy
        for(Contract_Treatment_Job_Product__c prod : prodListToCopy){
            List<Contract_Treatment_Default_BOM__c> relatedDefaultBOMs = defaultBOMMap.get(prod.Id);

            System.debug('RelatedDefaultBOMs: ' + relatedDefaultBOMs);

            Contract_Treatment_Job_Product__c newProd = prod.clone(false, true, false, false);
            newProd.Contract_Treatment_Job__c = newCTJ.Id;

            newCTJPs.add(newProd);

            // This map links each CTJP Id I'm cloning to the new CTJP.
            CTJPCloningMap.put(prod.Id, newProd);
        }

        if(!newCTJPs.isEmpty()) {
            insert newCTJPs;

            //When CTJPs are created, limits are also created for them, with a Status__c of "Inactive"

            List<Contract_Product_Limit__c> limitsToInsert = new List<Contract_Product_Limit__c>();
            List<Id> presentLimitsIds = new List<Id>();
            List<Contract_Product_Limit__c> presentLimits = CorporateTreatmentJobProductDAO.getPresentLimits(contractTreatmentRecordId);

            for(Contract_Product_Limit__C p : presentLimits) {
                presentLimitsIds.add(p.Product__c);
            }

            for(Contract_Treatment_Job_Product__c ctjp : newCTJPs) {
                if(!presentLimitsIds.contains(ctjp.Product__c)) {
                    Contract_Product_Limit__c lim = new Contract_Product_Limit__c(
                        Product__c = ctjp.Product__c, 
                        Contract_Treatment__c = contractTreatmentRecordId, 
                        Status__c = 'Inactive'
                    );

                    limitsToInsert.add(lim);
                }
            }

            if(!limitsToInsert.isEmpty()) {
                insert limitsToInsert;
            }
        }

        // Cloning DefaultBOMs
        for(Contract_Treatment_Job_Product__c ctjp : prodListToCopy) {

            // Getting the DefaultBOMs related to the CTJP I cloned the new one from...
            List<Contract_Treatment_Default_BOM__c> relatedDefaultBOMs = defaultBOMMap.get(ctjp.Id);
            System.debug('RelatedDefaultBOMs while cloning: ' + relatedDefaultBOMs);

            // ... Then getting the new CTJP cloned from ctjp...
            Contract_Treatment_Job_Product__c clonedCTJP = CTJPCloningMap.get(ctjp.Id);
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

        return newCTJ.Id;
    }

    public static List<Contract_Treatment_Job__c> getCTJClonableList(String corporateTreatmentJob, String corporateTreatmentId, String contractTreatmentRecordId,
    String searchTerm) {
        List<Contract_Treatment_Job__c> cTJClonableList = new List<Contract_Treatment_Job__c>();

        if(searchTerm != null && searchTerm.length() > 2) {
            String toSearch = '%' + searchTerm + '%';

            cTJClonableList = [SELECT Id, Name, Billable__c, Frequency__c, Frequency_Unit_of_measure__c, Work_Order__c, Task__c, 
                                                            Scheduling_Rule__c, Work_Type__c, Work_Type__r.Name, Case_Type__c, Contract_Treatment__r.Name 
                                                            FROM Contract_Treatment_Job__c 
                                                            WHERE Corporate_Treatment_Job__c =: corporateTreatmentJob 
                                                            AND Contract_Treatment__r.Corporate_Treatment__c =: corporateTreatmentId
                                                            //AND Contract_Treatment__c !=: contractTreatmentRecordId
                                                            AND (Name LIKE: toSearch OR Contract_Treatment__r.Name LIKE: toSearch)
                                                            LIMIT 30];
        }
        else {
            cTJClonableList = [SELECT Id, Name, Billable__c, Frequency__c, Frequency_Unit_of_measure__c, Work_Order__c, Task__c, 
                                                            Scheduling_Rule__c, Work_Type__c, Work_Type__r.Name, Case_Type__c, Contract_Treatment__r.Name 
                                                            FROM Contract_Treatment_Job__c 
                                                            WHERE Corporate_Treatment_Job__c =: corporateTreatmentJob 
                                                            AND Contract_Treatment__r.Corporate_Treatment__c =: corporateTreatmentId
                                                            //AND Contract_Treatment__c !=: contractTreatmentRecordId
                                                            LIMIT 30];
        }

        return cTJClonableList;
    }

    public static Boolean getCTJbyCorTJandCTJCode(String corporateTreatmentJob, String contractTreatmentJobCode, String contractTreatmentRecordId) {
        Boolean check;
        Integer i = 0;
        List<Contract_Treatment_Job__c> cTJClonableList = [SELECT Id, Name FROM Contract_Treatment_Job__c WHERE Corporate_Treatment_Job__c =: corporateTreatmentJob AND Contract_Treatment_Job_Code__c =: contractTreatmentJobCode AND Contract_Treatment__c =: contractTreatmentRecordId];

        if (cTJClonableList.size() == i) {
            check = false;
        } else check = true;

        return check;
    }

}