public class CTModalityTriggerService {
    public static void checkSubTreatment(List<Contract_Treatment_Modality__c> CTModalities) {
        List<String> CTMQueryFields = new List<String>{'Contract_Treatment__c', 'Sub_Treatment__c', 'Rebate__c', 'RecordTypeId', 'Installation_Type__c'};

        List<Contract_Treatment_Modality__c> treatmentCTMs = new List<Contract_Treatment_Modality__c>();
        List<Contract_Treatment_Modality__c> rebateCTMs = new List<Contract_Treatment_Modality__c>();
        List<String> contractTreatmentIds = new List<String>();
        List<String> relatedIds = new List<String>();
        List<Contract_Treatment_Modality__c> allRelatedOtherModalities = new List<Contract_Treatment_Modality__c>();

        Map<String, Contract_Treatment_Modality__c> treatmentCTMMap = new Map<String, Contract_Treatment_Modality__c>();
        Map<String, Contract_Treatment_Modality__c> rebateCTMMap = new Map<String, Contract_Treatment_Modality__c>();

        String treatmentRTId = CTModalitiesModalController.getModalitytRTIdFromName('CTM_Treatment');
        String rebateRTId = CTModalitiesModalController.getModalitytRTIdFromName('CTM_Rebate');

        /* if(treatmentRTId != null) {
            for(Contract_Treatment_Modality__c ctm : CTModalities) {
                if(ctm.Contract_Treatment__c != null && ctm.Sub_Treatment__c != null && ctm.RecordTypeId == treatmentRTId) {
                    contractTreatmentIds.add(ctm.Contract_Treatment__c);
                    subTreatments.add(ctm.Sub_Treatment__c);
                    ctmMap.put(String.valueOf(ctm.Contract_Treatment__c) + '_' + String.valueOf(ctm.Sub_Treatment__c), ctm);

                    // This is for update handling

                    if(ctm.Id != null) {
                        relatedIds.add(ctm.Id);
                    }
                }
            }

            if(!contractTreatmentIds.isEmpty() && !subTreatments.isEmpty()) {
                allRelatedOtherModalities = ContractTreatmentModalityDAO.getActiveTreatmentCTModalitiesFromCTAndSubTreatment(
                    CTMQueryFields, 
                    contractTreatmentIds, 
                    subTreatments,
                    relatedIds);

                for(Contract_Treatment_Modality__c ctm : allRelatedOtherModalities) {
                    String key = String.valueOf(ctm.Contract_Treatment__c) + '_' + String.valueOf(ctm.Sub_Treatment__c);

                    if(ctmMap.containsKey(key)) {
                        Contract_Treatment_Modality__c duplicate = ctmMap.get(key);
                        duplicate.addError(Label.CT_TreatmentModalities_DuplicateException);
                    }
                }
            }
        } */

        if(treatmentRTId != null && rebateRTId != null) {
            for(Contract_Treatment_Modality__c ctm : CTModalities) {
                if(ctm.RecordTypeId == treatmentRTId) {
                    treatmentCTMs.add(ctm);
                    if(ctm.Contract_Treatment__c != null) {
                        treatmentCTMMap.put(String.valueOf(ctm.Contract_Treatment__c) + '_' + String.valueOf(ctm.Sub_Treatment__c) + '_' + 
                        String.valueOf(ctm.Installation_Type__c), 
                        ctm);
                    }
                }
                else if(ctm.RecordTypeId == rebateRTId) {
                    rebateCTMs.add(ctm);

                    if(ctm.Contract_Treatment__c != null && ctm.Rebate__c != null) {
                        rebateCTMMap.put(String.valueOf(ctm.Contract_Treatment__c) + '_' + String.valueOf(ctm.Rebate__c), ctm);
                    }
                }

                if(ctm.Contract_Treatment__c != null) {
                    contractTreatmentIds.add(ctm.Contract_Treatment__c);
                }

                // This is for update handling
    
                if(ctm.Id != null) {
                    relatedIds.add(ctm.Id);
                }
            }

            if((!treatmentCTMs.isEmpty() || !rebateCTMs.isEmpty()) && !contractTreatmentIds.isEmpty()) {
                System.debug('treatmentCTMMap: ' + treatmentCTMMap);
                System.debug('rebateCTMMap: ' + rebateCTMMap);

                allRelatedOtherModalities = ContractTreatmentModalityDAO.getActiveCTMsFromCTs(CTMQueryFields, contractTreatmentIds, relatedIds);

                for(Contract_Treatment_Modality__c ctm : allRelatedOtherModalities) {
                    System.debug('Other ctm found: ' + ctm);

                    if(ctm.RecordTypeId == treatmentRTId) {
                        System.debug('This is a Treatment CTM');
                        String key = String.valueOf(ctm.Contract_Treatment__c) + '_' + String.valueOf(ctm.Sub_Treatment__c) + '_' + String.valueOf(ctm.Installation_Type__c);
                        System.debug('key: ' + key);

                        if(treatmentCTMMap.containsKey(key)) {
                            System.debug('Duplicate found!');
                            Contract_Treatment_Modality__c duplicate = treatmentCTMMap.get(key);
                            duplicate.addError(Label.CT_TreatmentModalities_DuplicateException);
                        }
                    }
                    else if(ctm.RecordTypeId == rebateRTId) {
                        System.debug('This is a Rebate CTM');
                        String key = String.valueOf(ctm.Contract_Treatment__c) + '_' + String.valueOf(ctm.Rebate__c);
                        System.debug('key: ' + key);

                        if(rebateCTMMap.containsKey(key)) {
                            System.debug('Duplicate found!');
                            Contract_Treatment_Modality__c duplicate = rebateCTMMap.get(key);
                            duplicate.addError(Label.CT_RebateModalities_DuplicateException);
                        }
                    }
                }
            }
        }
    }
}