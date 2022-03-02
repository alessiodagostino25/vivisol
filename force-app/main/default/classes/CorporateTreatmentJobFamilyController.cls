public with sharing class CorporateTreatmentJobFamilyController {

    @AuraEnabled(cacheable=true)
    public static List<CorporateTreatmentJobProductDTO> getCorporateTreatmentJobFamily(String corporateTreatment, String corporateTreatmentJob, 
    String contractFramework, String contractTreatmentJobId, String picklistValue, String searchValue, List<String> allSelectedIds/*, List<String> alreadySelectedProducts*/) { //NON MOSTRARE PRODOTTI GIA' INSERITI
        System.debug('ALL SELECTED Family Ids: ' + allSelectedIds);
        System.debug('search value'+searchValue) ;
        System.debug('Corporate Treatment passato alla query: ' + corporateTreatment);
        System.debug('Corporate Treatment Job passato alla query: ' + corporateTreatmentJob);
        System.debug('Id del Contract Framework passato alla query: ' + contractFramework);
        System.debug('Picklist value: ' + picklistValue);
        Contract_Framework__c cf = [SELECT Id, Price_list_code__c FROM Contract_Framework__c WHERE Id =: contractFramework];
        System.debug('Contract Framework: ' + cf);
        System.debug('Price_list_code: ' + cf.Price_list_code__c);
        Pricebook2 pricebook = [SELECT Id, Name FROM Pricebook2 WHERE Id =: cf.Price_list_code__c];
        System.debug('Pricebook passato: ' + pricebook.Name);
        List<PricebookEntry> pricebookEntries = [SELECT Product2Id FROM PricebookEntry WHERE Pricebook2Id =: pricebook.Id AND IsActive = true];
        System.debug('Lista pricebookentries: ' + pricebookEntries);
        List<Id> productIds = new List<Id>();
        List<Corporate_Treatment_Job_Product__c> productList = new List<Corporate_Treatment_Job_Product__c>();
        List<CorporateTreatmentJobProductDTO> productDTOs = new List<CorporateTreatmentJobProductDTO>();
        for(PricebookEntry pe : pricebookEntries) {
            productIds.add(pe.Product2Id);
        }
        List<Contract_Treatment_Job_Product__c> notToShowProducts = [SELECT Id, Product__c, Product__r.Product_Family__c FROM Contract_Treatment_Job_Product__c 
                                                                     WHERE Contract_Treatment_Job__c =: contractTreatmentJobId];
        List<Id> notToShowIds = new List<Id>();
        for(Contract_Treatment_Job_Product__c prod : notToShowProducts) {
            notToShowIds.add(prod.Product__c);
            if (prod.Product__r.Product_Family__c != null){
                notToShowIds.add(prod.Product__r.Product_Family__c);
            }
        }

        List<Corporate_Treatment_Job_Product__c> selected = [SELECT Id, Product_Activities_Family__c, Product_Activities_Family__r.Product_Name_Translate__c,
                                                            Product_Activities_Family__r.Product_Code__c FROM Corporate_Treatment_Job_Product__c 
                                                            WHERE Id IN: allSelectedIds];
        System.debug('SIZE OF SELECTED: ' + selected.size() + 'SELECTED: ' + selected);
        System.debug('NOT TO SHOW IDS: ' + notToShowIds);
        System.debug('ProductIds: ' + productIds);
        System.debug('You are querying for the family selection page');
        if(picklistValue == '' && searchValue != '') {
            String toSearch = '%' + searchValue + '%';
            System.debug('sei nell if senza picklistValue ma con searchValue');
            productList = [SELECT Product_Activities_Family__r.Product_Name_Translate__c, Product_Activities_Family__r.Product_Code__c FROM Corporate_Treatment_Job_Product__c 
                    WHERE Product_Activities_Family__r.Product_Family__c = null 
                    AND Product_Activities_Family__r.IsActive = true
                    AND Corporate_Treatment__c =: corporateTreatment 
                    AND Corporate_Treatment_Job__c =: corporateTreatmentJob
                    AND Product_Activities_Family__c IN: productIds
                    AND Product_Activities_Family__c NOT IN: notToShowIds
                    AND (Product_Activities_Family__r.Product_Name_Translate__c LIKE: toSearch
                    OR Product_Activities_Family__r.Product_Code__c LIKE: toSearch)
                    LIMIT 100];
        }
        else if(picklistValue == '' && searchValue == '') {
            System.debug('sei nell else if con picklistValue null e con searchValue null');
            productList = [SELECT Product_Activities_Family__r.Product_Name_Translate__c, Product_Activities_Family__r.Product_Code__c, Product_Activities_Family__c FROM Corporate_Treatment_Job_Product__c 
                    WHERE Product_Activities_Family__r.Product_Family__c = null 
                    AND Product_Activities_Family__r.IsActive = true 
                    AND Corporate_Treatment__c =: corporateTreatment 
                    AND Corporate_Treatment_Job__c =: corporateTreatmentJob
                    AND Product_Activities_Family__c IN: productIds
                    AND Product_Activities_Family__c NOT IN: notToShowIds
                    LIMIT 100];
                    System.debug('QUERY SIZE: ' + productList.size());
        }
        else if(picklistValue != '' && searchValue != '') {
            String toSearch = '%' + searchValue + '%';
            System.debug('sei nell else if con picklistValue e searchValue');
            productList = [SELECT Product_Activities_Family__r.Product_Name_Translate__c, Product_Activities_Family__r.Product_Code__c, Product_Activities_Family__c FROM Corporate_Treatment_Job_Product__c 
                    WHERE Product_Activities_Family__r.Product_Family__c = null 
                    AND Product_Activities_Family__r.IsActive = true 
                    AND Corporate_Treatment__c =: corporateTreatment 
                    AND Corporate_Treatment_Job__c =: corporateTreatmentJob
                    AND Product_Activities_Family__c IN: productIds
                    AND Product_Activities_Family__c NOT IN: notToShowIds
                    AND toLabel(Product_Activities_Family__r.Type__c) =: picklistValue
                    AND (Product_Activities_Family__r.Product_Name_Translate__c LIKE: toSearch
                    OR Product_Activities_Family__r.Product_Code__c LIKE: toSearch)
                    LIMIT 100];
                    
        }
        else {
            System.debug('sei nell else if con picklistValue ma senza searchValue');
            System.debug('picklistValue passato: ' + picklistValue);
            productList = [SELECT Id, Product_Activities_Family__r.Product_Name_Translate__c, Product_Activities_Family__r.Product_Code__c, Product_Activities_Family__c FROM Corporate_Treatment_Job_Product__c 
                    WHERE Product_Activities_Family__r.Product_Family__c = null 
                    AND Product_Activities_Family__r.IsActive = true 
                    AND Corporate_Treatment__c =: corporateTreatment 
                    AND Corporate_Treatment_Job__c =: corporateTreatmentJob
                    AND Product_Activities_Family__c IN: productIds
                    AND Product_Activities_Family__c NOT IN: notToShowIds
                    AND toLabel(Product_Activities_Family__r.Type__c) =: picklistValue
                    LIMIT 100];
        }
        for(Corporate_Treatment_Job_Product__c p : selected) {
            if(!productList.contains(p)) {
                productList.add(p);
            }
        }
        for(Corporate_Treatment_Job_Product__c p : productList) {
            if(!allSelectedIds.contains(p.Product_Activities_Family__c)) {
                CorporateTreatmentJobProductDTO dto = new CorporateTreatmentJobProductDTO(p.Id, p.Product_Activities_Family__c, p.Product_Activities_Family__r.Product_Name_Translate__c, p.Product_Activities_Family__r.Product_Code__c, 'false', 'ok');
                productDTOs.add(dto);
                System.debug('DTO with FALSE on selected added');
            }
            else {
                CorporateTreatmentJobProductDTO dto = new CorporateTreatmentJobProductDTO(p.Id, p.Product_Activities_Family__c, p.Product_Activities_Family__r.Product_Name_Translate__c, p.Product_Activities_Family__r.Product_Code__c, 'true', 'ok');
                productDTOs.add(dto);
                System.debug('DTO with TRUE on selected added');
            }
        }
        return productDTOs;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<ProductTypeDTO> getProductTypes(){
        List<ProductTypeDTO> ptDTOs = new List<ProductTypeDTO>();
        Schema.DescribeFieldResult dfr = Product2.Type__c.getDescribe();
        List<Schema.PicklistEntry> picklistEntries = dfr.getPicklistValues();
        for(Schema.PicklistEntry pe : picklistEntries) {
            if(pe.getValue() != 'ZSRT' && pe.getValue() != null && pe.getValue() != 'ZJOB') {
                ptDTOs.add(new ProductTypeDTO((String) pe.getLabel(), (String) pe.getLabel()));
            }
        }
        return ptDTOs;
    }
}