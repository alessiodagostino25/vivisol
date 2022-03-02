public class ATASelectionController {
    
    @AuraEnabled(cacheable=true)
    public static List<AccountTreatmentAddressDTO> getATAs(Id accountTreatmentId) {
        return ATASelectionService.getATAs(accountTreatmentId);
    }
}