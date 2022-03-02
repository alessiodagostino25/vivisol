public class ATASelectionService {
    
    public static List<AccountTreatmentAddressDTO> getATAs(Id accountTreatmentId) {
        List<AccountTreatmentAddressDTO> toReturn = new List<AccountTreatmentAddressDTO>();
        
        List<String> queryFields = new List<String>{'Location__r.Name', 'Location__r.VisitorAddress.AddressType', 'Location__r.Address__c',
        'Start_Date__c', 'End_Date__c', 'Default__c'};

        List<Account_Treatment_Address__c> relatedATAs = AccountTreatmentAddressDAO.getATAsFromAccountTreatment(queryFields, accountTreatmentId);

        if(relatedATAs != null) {
            for(Account_Treatment_Address__c ata : relatedATAs) {
                AccountTreatmentAddressDTO dto = new AccountTreatmentAddressDTO(
                    ata.Id,
                    ata.Location__r.Name, 
                    ata.Location__r.VisitorAddress.AddressType, 
                    ata.Location__r.Address__c,
                    ata.Start_Date__c,
                    ata.End_Date__c,
                    ata.Default__c);

                    toReturn.add(dto);
            }
        }

        return toReturn;
    }
}