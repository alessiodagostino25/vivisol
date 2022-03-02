public class DefaultBomProductSelectionService {
    
    public static List<PricebookEntryDTO> getPricebookEntries(Id contractTreatmentJobId, String searchValue, List<String> selectedIds, List<Id> notToShow, 
    Integer queryLimit) {
        List<PricebookEntryDTO> dtoList = new List<PricebookEntryDTO>();
        List<PricebookEntry> selectedPricebookEntries = new List<PricebookEntry>();
        List<PricebookEntry> pricebookEntries = new List<PricebookEntry>();

        List<String> queryFields = new List<String>{
            'Product2.Product_Name_Translate__c', 'Product2.Product_Code__c', 
            'Product2.Product_Family__r.Product_Name_Translate__c', 
            'Product2.Manufacturer_part_number__c'};

        System.debug('selectedIds: ' + selectedIds);
        System.debug('notToShow: ' + notToShow);
        selectedPricebookEntries = PricebookEntryDAO.getPricebookEntriesFromId(queryFields, selectedIds);

        if(searchValue == '') {

            System.debug('searchValue = null');
            //Nothing inserted in the search bar, simply return the PricebookEntries
            pricebookEntries = PricebookEntryDAO.getPricebookEntriesFromJobId(queryFields, contractTreatmentJobId, notToShow, true, queryLimit);
        }
        else {

            System.debug('searchValue = ' + searchValue);
            //Something is in the search bar, I'll pass it for the query
            pricebookEntries = PricebookEntryDAO.getPricebookEntriesWithSearch(queryFields, contractTreatmentJobId, searchValue, notToShow, queryLimit);
        }

        //Adding the already selected PricebookEntries to the list of PricebookEntries to return to front-end

        for(PricebookEntry pe : selectedPricebookEntries) {
            if(!pricebookEntries.contains(pe)) {
                pricebookEntries.add(pe);
            }
        }

        // Building DTOs to return
        for(PricebookEntry pe : pricebookEntries) {
            PricebookEntryDTO dto = new PricebookEntryDTO(pe.Id, null, pe.Product2.Product_Name_Translate__c, pe.Product2.Product_Code__c, 
                                                          pe.Product2.Product_Family__r.Product_Name_Translate__c, pe.Product2.Manufacturer_part_number__c, false);
            dtoList.add(dto);
        }

        System.debug('dtoList: ' + dtoList);
        return dtoList;
    }

    public static List<Id> getNotToShowIds(Id contractTreatmentJobId) {
        List<String> queryFieldsForPricebookEntries = new List<String>{'Product2Id'};
        List<String> queryFields = new List<String>{'Contract_Treatment_Job_Product__c', 'Product__c'};
        List<Id> productIds = new List<Id>();
        List<Id> notToShowIds = new List<Id>();

        List<PricebookEntry> pricebookEntries = PricebookEntryDAO.getPricebookEntriesFromJobId(queryFieldsForPricebookEntries, contractTreatmentJobId, null, false, null);
        System.debug('Related PricebookEntries(for notToShow): ' + pricebookEntries.size());

        for(PricebookEntry pe : pricebookEntries) {
            productIds.add(pe.Product2Id);
        }

        List<Id> defaultBOMProductIds = new List<Id>();
        List<Contract_Treatment_Default_BOM__c> defaultBOMList = ContractTreatmentDefaultBomDAO.getCTDBOMFromProductIds(queryFields, productIds, contractTreatmentJobId);

        for(Contract_Treatment_Default_BOM__c defaultBOM : defaultBOMList) {
            defaultBOMProductIds.add(defaultBOM.Product__c);
        }
        for(PricebookEntry pe : pricebookEntries) {
            if(defaultBOMProductIds.contains(pe.Product2Id)) {
                notToShowIds.add(pe.Id);
            }
        }

        System.debug('Not to show Ids: ' + notToShowIds.size());
        return notToShowIds;
    }
}