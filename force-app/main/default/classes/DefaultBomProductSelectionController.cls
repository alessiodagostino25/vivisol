public class DefaultBomProductSelectionController {
    
    @AuraEnabled
    public static List<PricebookEntryDTO> getPricebookEntries(Id contractTreatmentJobId, String searchValue, List<String> selectedIds) {
        List<Id> notToShow = new List<Id>();

        notToShow = DefaultBomProductSelectionService.getNotToShowIds(contractTreatmentJobId);

        return DefaultBomProductSelectionService.getPricebookEntries(contractTreatmentJobId, searchValue, selectedIds, notToShow, 100);
    }
}