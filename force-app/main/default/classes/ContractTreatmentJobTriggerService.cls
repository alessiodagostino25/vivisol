public class ContractTreatmentJobTriggerService {

    public class MyException extends Exception {}
    public static void CTJTriggerServicemehtod(List<Id> ctjids) {
        String exceptionlabel =  System.Label.ContractTreatmentJob_Expection;
        List<String> queryfields = new List<String>{'Id'};
        List<Contract_Treatment_Job__c> ctjs = ContractTreatmentJobDAO.getContractTreatmentJobfieldbyids(queryfields,ctjids);
        if (!ctjs.isEmpty()) {
            throw new MyException(exceptionlabel);
        }
    }

    public static void updateFrequencyAndDelivery(Map<Id, Contract_Treatment_Job__c> newMap, List<Contract_Treatment_Job__c> newList){
        Set<Id> contractTreatmentJobIds = new Set<Id>();
        contractTreatmentJobIds = newMap.keySet();
        List<String> CTJQueryFields = new List<String>{'Id', 'Contract_Treatment__r.Contract_Framework__r.Status__c'};
        List<Contract_Treatment_Job__c> jobs = ContractTreatmentJobDAO.getCTJsbyIds(CTJQueryFields,contractTreatmentJobIds);
        Map <String,String> contractStatusMap = new Map<String,String>();

        for (Contract_Treatment_Job__c job: jobs){
            contractStatusMap.put(job.Id,job.Contract_Treatment__r.Contract_Framework__r.Status__c);
        }
        for (Contract_Treatment_Job__c newJob: newList){
            if (contractStatusMap.get(newJob.Id) != 'Active'){
                newJob.Last_Propagated_Delivery_Channel__c = newJob.Delivery_Channel__c;
                newJob.Last_Propagated_Frequency__c = newJob.Frequency__c;
                newJob.Last_Propagated_Frequency_UOM__c = newJob.Frequency_Unit_of_measure__c;
                newJob.Last_Propagated_Frequency_Type__c = newJob.Frequency_Type__c;
            }
        }
    }

    public static void setExternalId(List<Contract_Treatment_Job__c> CTJs) {
        SObjectServiceClass.updateExternalId('Contract_Treatment_Job__c', 'Contract_Treatment_Job_Number__c', 'External_Id__c', CTJs);
    }

    public static void checkForBillable(List<Contract_Treatment_Job__c> CTJs) {
        System.debug('----- checkForBillable -----');

        List<String> contractTreatmentQueryFields = new List<String>{'All_Items_Billable__c'};

        List<String> relatedContractTreatmentIds = new List<String>();
        List<Contract_Treatment__c> relatedContractTreatments = new List<Contract_Treatment__c>();

        Map<String, Contract_Treatment__c> contractTreatmentMap = new Map<String, Contract_Treatment__c>();

        for(Contract_Treatment_Job__c ctj : CTJs) {
            relatedContractTreatmentIds.add(ctj.Contract_Treatment__c);
        }

        relatedContractTreatments = ContractTreatmentDAO.getContractTreatmentsFromIds(contractTreatmentQueryFields, relatedContractTreatmentIds);

        if(!relatedContractTreatments.isEmpty()) {
            for(Contract_Treatment__c ct : relatedContractTreatments) {
                contractTreatmentMap.put(ct.Id, ct);
            }

            for(Contract_Treatment_Job__c ctj : CTJs) {
                Contract_Treatment__c relatedContractTreatment = contractTreatmentMap.get(ctj.Contract_Treatment__c);

                if(relatedContractTreatment != null) {
                    if(relatedContractTreatment.All_Items_Billable__c == true) {
                        ctj.Billable__c = true;
                    }
                }
            }
        }
    }

    public static void setSTFFromCorporateTreatment(List<Contract_Treatment_Job__c> CTJs) {
        List<String> contractTreatmentIds = new List<String>();
        List<Contract_Treatment__c> contractTreatments = new List<Contract_Treatment__c>();

        Map<String, Contract_Treatment__c> contractTreatmentMap = new Map<String, Contract_Treatment__c>();

        for(Contract_Treatment_Job__c ctj : CTJs) {
            if(ctj.Contract_Treatment__c != null) {
                contractTreatmentIds.add(ctj.Contract_Treatment__c);
            }
        }

        if(!contractTreatmentIds.isEmpty()) {
            contractTreatments = [SELECT Corporate_Treatment__r.Scheduling_Time_Frame__c FROM Contract_Treatment__c WHERE Id IN: contractTreatmentIds];

            if(!contractTreatments.isEmpty()) {
                for(Contract_Treatment__c ct : contractTreatments) {
                    contractTreatmentMap.put(ct.Id, ct);
                }

                for(Contract_Treatment_Job__c ctj : CTJs) {
                    Contract_Treatment__c relatedContractTreatment = contractTreatmentMap.get(ctj.Contract_Treatment__c);

                    if(relatedContractTreatment != null) {
                        ctj.Scheduling_Time_Frame__c = relatedContractTreatment.Corporate_Treatment__r.Scheduling_Time_Frame__c;
                    }
                }
            }
        }
    }
}