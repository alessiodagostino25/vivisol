public class ATATriggerService {

    public static void updateDefault(List<Account_Treatment_Address__c> ATAs, Boolean isUpdate) {
        List<String> queryFieldsForATA = new List<String>{'Account_Treatment__c', 'Default__c'};
        List<Id> relatedATIds = new List<Id>();
        List<Account_Treatment_Address__c> ATAsToUpdate = new List<Account_Treatment_Address__c>();

        Map<Id, List<Account_Treatment_Address__c>> ATIdToATAsMap = new Map<Id, List<Account_Treatment_Address__c>>();

        // Getting all the related AT Ids
        for(Account_Treatment_Address__c ata : ATAs) {
            relatedATIds.add(ata.Account_Treatment__c);
        }

        // Retrieving all the ATAs related to the ATs of the ATAs in ATAs List
        List<Account_Treatment_Address__c> allATAs = AccountTreatmentAddressDAO.getATAsFromAccountTreatments(queryFieldsForATA, relatedATIds);

        // Building a AT.Id --> List<Related ATAs> Map
        if(allATAs != null) {
            for(Account_Treatment_Address__c ata : allATAs) {
                if(ATIdToATAsMap.get(ata.Account_Treatment__c) == null) {
                    ATIdToATAsMap.put(ata.Account_Treatment__c, new List<Account_Treatment_Address__c>());
                }
                ATIdToATAsMap.get(ata.Account_Treatment__c).add(ata);
            }
        }

        for(Account_Treatment_Address__c ata : ATAs) {
            List<Account_Treatment_Address__c> ATAsRelatedToAT = ATIdToATAsMap.get(ata.Account_Treatment__c);
            List<Account_Treatment_Address__c> relatedDefaultATAs = new List<Account_Treatment_Address__c>();

            if(ATAsRelatedToAT != null) {
                for(Account_Treatment_Address__c relatedATA : ATAsRelatedToAT) {
                    if(relatedATA.Default__c == true && 
                    (isUpdate == false || (isUpdate == true && relatedATA.Id != ata.Id))) {
                        relatedDefaultATAs.add(relatedATA);
                    }
                }
            }

            if(ATAsRelatedToAT == null && ata.Default__c == false) {
                ata.Default__c = true;
            }
            else if(!relatedDefaultATAs.isEmpty()) {
                if(ata.Default__c == true) {
                    for(Account_Treatment_Address__c defaultATA : relatedDefaultATAs) {
                        defaultATA.Default__c = false;

                        ATAsToUpdate.add(defaultATA);
                    }
                }
            }
        }

        if(!ATAsToUpdate.isEmpty()) {
            update ATAsToUpdate;
        }
    }
}