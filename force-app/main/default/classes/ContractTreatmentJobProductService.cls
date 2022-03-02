public class ContractTreatmentJobProductService {
    public static void setCTJPIdField(List<Contract_Treatment_Job_Product__c> CTJPs) {
        SObjectServiceClass.updateExternalId('Contract_Treatment_Job_Product__c', 'Name', 'Contract_Treatment_Job_Product_Id__c', CTJPs);
    }

    public static void checkForBillable(List<Contract_Treatment_Job_Product__c> CTJPs) {
        System.debug('----- checkForBillable -----');
        
        List<String> CTJQueryFields = new List<String>{'Contract_Treatment__r.All_Items_Billable__c'};

        List<String> relatedCTJIds = new List<String>();
        List<Contract_Treatment_Job__c> relatedCTJs = new List<Contract_Treatment_Job__c>();

        Map<String, Contract_Treatment_Job__c> CTJMap = new Map<String, Contract_Treatment_Job__c>();

        for(Contract_Treatment_Job_Product__c ctjp : CTJPs) {
            relatedCTJIds.add(ctjp.Contract_Treatment_Job__c);
        }

        relatedCTJs = ContractTreatmentJobDAO.getCTJsFromIds(CTJQueryFields, relatedCTJIds);

        if(!relatedCTJs.isEmpty()) {
            for(Contract_Treatment_Job__c ctj : relatedCTJs) {
                CTJMap.put(ctj.Id, ctj);
            }

            for(Contract_Treatment_Job_Product__c ctjp : CTJPs) {
                Contract_Treatment_Job__c relatedCTJ = CTJMap.get(ctjp.Contract_Treatment_Job__c);

                if(relatedCTJ != null) {
                    if(relatedCTJ.Contract_Treatment__r.All_Items_Billable__c == true) {
                        ctjp.Billable__c = true;
                    }
                }
            }
        }
    }
}