public class CorporateTreatmentJobProductService {

    //This method handles the data in the datatables for family/product selection
    @AuraEnabled(cacheable=true)
    public static List<CorporateTreatmentJobProductDTO> getCorporateTreatmentJobProduct(String corporateTreatment, String corporateTreatmentJob, 
    String contractFramework, String contractTreatmentJobId, String picklistValue, String searchValue, 
    List<String> selectedFamilyStrings, List<String> allSelectedIds) {

        List<Id> selectedFamilyIds = (List<Id>) selectedFamilyStrings;
        List<Id> productIds = new List<Id>();
        List<Product2> products = new List<Product2>();
        List<Id> notToShowIds = new List<Id>();
        List<Id> contractFamiliesIds = new List<Id>();
        List<Id> familyIds = new List<Id>();
        List<Corporate_Treatment_Job_Product__c> productList = new List<Corporate_Treatment_Job_Product__c>();
        List<CorporateTreatmentJobProductDTO> productDTOs = new List<CorporateTreatmentJobProductDTO>();

        //A CF has a Pricebook2 associated. Via this Pricebook2, I can get the list of Product2Id associated on the PricebookEntry SObject
        Contract_Framework__c cf = CorporateTreatmentJobProductDAO.getContractFramework(contractFramework);
        Pricebook2 pricebook = CorporateTreatmentJobProductDAO.getPricebook(cf.Price_list_code__c);
        List<PricebookEntry> pricebookEntries = CorporateTreatmentJobProductDAO.getPricebookEntries(pricebook.Id);
        for(PricebookEntry pe : pricebookEntries) {
            productIds.add(pe.Product2Id);
        }
        //These are the products that have already been chosen and must not be shown
        List<Contract_Treatment_Job_Product__c> notToShowProducts = CorporateTreatmentJobProductDAO.getContractTJP(contractTreatmentJobId);
        for(Contract_Treatment_Job_Product__c prod : notToShowProducts) {
            notToShowIds.add(prod.Product__c);
            if(prod.Product__r.Product_Family__c == null && prod.Status__c == 'Active') {
                contractFamiliesIds.add(prod.Product__c);
            }
        }
        //These are the products that have already been selected
        List<Product2> selected = CorporateTreatmentJobProductDAO.getSelectedProduct2(allSelectedIds);
        
        List<Corporate_Treatment_Job_Product__c> families = CorporateTreatmentJobProductDAO.getFamilies(corporateTreatment, corporateTreatmentJob);
        for(Corporate_Treatment_Job_Product__c family : families) {
            familyIds.add(family.Product_Activities_Family__r.Id);
        }
        //Different queries for different search combinations
        if(picklistValue == '' && searchValue != '') {
            String toSearch = '%' + searchValue + '%';
            products = CorporateTreatmentJobProductDAO.getProduct2WithSearchValue(familyIds, contractFamiliesIds, selectedFamilyIds, toSearch, notToShowIds, productIds);
        }
        else if(picklistValue == '' && searchValue == '') {
            products = CorporateTreatmentJobProductDAO.getProduct2WithoutFilters(familyIds, contractFamiliesIds, selectedFamilyIds, notToShowIds, productIds);
        }
        else if(picklistValue != '' && searchValue != '') {
            String toSearch = '%' + searchValue + '%';
            products = CorporateTreatmentJobProductDAO.getProduct2WithSearchValueAndPicklistValue(familyIds, selectedFamilyIds, contractFamiliesIds, 
            toSearch, notToShowIds, picklistValue, productIds);
        }
        else {
            products = CorporateTreatmentJobProductDAO.getProduct2WithPicklistValue(familyIds, selectedFamilyIds, contractFamiliesIds, 
            notToShowIds, picklistValue, productIds);
        }
    
        for(Product2 p : selected) {
            if(!products.contains(p)) {
                products.add(p);
            }
        }

        //Returning a DTO for products
        for(Product2 p : products) {
            CorporateTreatmentJobProductDTO dto = new CorporateTreatmentJobProductDTO(p.Id, p.Product_Name_Translate__c, 
            p.Product_Code__c, p.Product_Family__r.Product_Name_Translate__c, p.Product_Family__r.Product_Code__c, 
            p.Manufacturer_Part_Number__c, 'ok');
            productDTOs.add(dto);
        }
        return productDTOs;
    }

    //This method return the Product Types to show in the picklist for datatable's filter 
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

    //This method creates a new Contract Treatment Job Product
    @AuraEnabled
    public static void createCTJP(List<String> productsToCreate, String contractTreatmentJob) {

        List<Contract_Product_Limit__c> limitsToInsert = new List<Contract_Product_Limit__c>();
        List<Id> presentLimitsIds = new List<Id>();
        List<Id> notToCreateIds = new List<Id>();
        List<Contract_Treatment_Job_Product__c> CTJPToInsert = new List<Contract_Treatment_Job_Product__c>();
        List<Id> productIds = new List<Id>();
        List<ContractTreatmentJobProductDTO> dtoList = new List<ContractTreatmentJobProductDTO>();

        Contract_Treatment_Job__c ctj = CorporateTreatmentJobProductDAO.getCTJ(contractTreatmentJob);
        Id contractTreatmentId = ctj.Contract_Treatment__c;
        List<Contract_Treatment_Job_Product__c> notToCreate = CorporateTreatmentJobProductDAO.getContractTJP(contractTreatmentJob);

        //When CTJPs are created, limits are also created for them, with a Status__c of "Inactive"
        List<Contract_Product_Limit__c> presentLimits = CorporateTreatmentJobProductDAO.getPresentLimits(contractTreatmentId);

        for(Contract_Product_Limit__C p : presentLimits) {
            presentLimitsIds.add(p.Product__c);
        }

        for(Contract_Treatment_Job_Product__c p : notToCreate) {
            notToCreateIds.add(p.Product__c);
        }

        Id contractTreatmentJobId = (Id) contractTreatmentJob;
        for(String p : productsToCreate) {
            if(!notToCreateIds.contains(p)) {
                productIds.add(p);
            }
        }
        List<Product2> products = CorporateTreatmentJobProductDAO.getProducts(productIds);

        //Creating new CTJP
        for(Product2 product : products) {
            Contract_Treatment_Job_Product__c ctjp = new Contract_Treatment_Job_Product__c(
                Product__c = product.Id,
                Contract_Treatment_Job__c = contractTreatmentJobId
            );
            CTJPToInsert.add(ctjp);
        }
        if(!CTJPToInsert.isEmpty()) {
            insert CTJPToInsert;
            // For every new product, insert a Limit with a pending status to show in limitSelection page ONLY IF a Limit for that Product__c isn't already present
            for(Contract_Treatment_Job_Product__c p : CTJPToInsert) {
                if(!presentLimitsIds.contains(p.Product__c)) {
                    Contract_Product_Limit__c lim = new Contract_Product_Limit__c(Product__c = p.Product__c, 
                                                                                  Contract_Treatment__c = contractTreatmentId, Status__c = 'Inactive');
                    limitsToInsert.add(lim);
                }
            }
            insert limitsToInsert;
            //List<Contract_Treatment_Job_Product__c> allInsertedCTJPs = CorporateTreatmentJobProductDAO.getAllInsertedCTJPs(productIds, contractTreatmentJobId);
        }  
    }

    //This method gets the Contract Treatment Job Products to show in the configuration page
    @AuraEnabled(cacheable=true)
    public static List<CorporateTreatmentJobProductDTO> getCTJP(String contractTreatmentJob, String searchValue) {
        List<CorporateTreatmentJobProductDTO> productDTOs = new List<CorporateTreatmentJobProductDTO>();
        List<Contract_Treatment_Job_Product__c> createdCTJP = new List<Contract_Treatment_Job_Product__C>();
        String toSearch = '%' + searchValue + '%';

        if(searchValue != '') {
            createdCTJP = CorporateTreatmentJobProductDAO.getCreatedCTJPWithSearchValue(contractTreatmentJob, toSearch);
        }
        else {
            createdCTJP = CorporateTreatmentJobProductDAO.getCreatedCTJPWithoutSearchValue(contractTreatmentJob);
        }

        //Return DTOs for CTJPs
        for(Contract_Treatment_Job_Product__c product : createdCTJP) {
            CorporateTreatmentJobProductDTO dto = new CorporateTreatmentJobProductDTO(product.Id, product.Product__r.Product_Name_Translate__c, product.Product__r.Product_Code__c,
            product.Product__r.Family_Name__c, product.Product__r.Manufacturer_Part_Number__c, product.Configured_Checkbox__c, product.Product__r.Type__c, product.Min_Quantity__c,
            product.Max_Quantity__c, product.Quantity_Unit_of_Measure__c, product.Quantity__c, product.Status__c, product.Billable__c);
            productDTOs.add(dto);
        }
        return productDTOs;
    }

    //This method gets Ids of Family products
    @AuraEnabled(cacheable=true)
    public static List<String> getFamilyIds(String contractTreatmentJob){
        List<String> familyIds = new List<String>();

        List<Contract_Treatment_Job_Product__c> createdCTJP = CorporateTreatmentJobProductDAO.getCreatedFamilyCTJP(contractTreatmentJob);
        for(Contract_Treatment_Job_Product__c p : createdCTJP) {
            familyIds.add((String) p.Id);
        }
        return familyIds;
        
    }

    //This method gets Ids of Not-Family products
    @AuraEnabled(cacheable=true)
    public static List<String> getProductIds(String contractTreatmentJob){
        List<String> productIds = new List<String>();

        List<Contract_Treatment_Job_Product__c> createdCTJP = CorporateTreatmentJobProductDAO.getCreatedProductCTJP(contractTreatmentJob);
        for(Contract_Treatment_Job_Product__c p : createdCTJP) {
            productIds.add((String) p.Id);
        }
        return productIds;
    }

    //This method deletes a Contract Treatment Job Product
    @AuraEnabled
    public static void deleteProduct(String productId){
        Contract_Treatment_Job_Product__c toDelete = new Contract_Treatment_Job_Product__c();
        toDelete = CorporateTreatmentJobProductDAO.getCTJPFromId(productId);
        delete toDelete;
    }

    public static Boolean checkForCTJPActivation(String CTJPId) {
        System.debug('----- checkForCTJPActivation -----');

        List<String> CTJPQueryFields = new List<String>{'Status__c', 'Contract_Treatment_Job__c', 'Family__c', 'Product__r.Product_Family__c'};

        List<Contract_Treatment_Job_Product__c> CTJPList = ContractTreatmentJobProductDAO.getCTJPsFromIds(CTJPQueryFields, new List<Id>{CTJPId});
        Contract_Treatment_Job_Product__c CTJP = CTJPList[0];

        // If a Family CTJP is being activated, I need to check if there are already active CTJP for this CTJ related to the family of this CTJP. If so, it can't be activated

        if(CTJP.Family__c == null) {
            List<Contract_Treatment_Job_Product__c> CTJPsRelatedToFamily = [SELECT Id FROM Contract_Treatment_Job_Product__c
                                                                            WHERE Contract_Treatment_Job__c =: CTJP.Contract_Treatment_Job__c
                                                                            AND Id !=: CTJPId
                                                                            AND Status__c = 'Active'
                                                                            AND Product__r.Product_Family__c =: CTJP.Product__c];

            System.debug('CTJPsRelatedToFamily: ' + CTJPsRelatedToFamily);

            if(CTJPsRelatedToFamily != null && !CTJPsRelatedToFamily.isEmpty()) {
                return false;
            }
        }

        // If a single CTJP is being activated, I need to check if there is already its family as an active CTJP. If so, it can't be activated

        else {
            List<Contract_Treatment_Job_Product__c> activeRelatedFamilyCTJPs = [SELECT Id FROM Contract_Treatment_Job_Product__c
                                                                                WHERE Contract_Treatment_Job__c =: CTJP.Contract_Treatment_Job__c
                                                                                AND Id !=: CTJPId
                                                                                AND Status__c = 'Active'
                                                                                AND Product__c =: CTJP.Family__c];
            
            System.debug('activeRelatedFamilyCTJPs: ' + activeRelatedFamilyCTJPs);

            if(activeRelatedFamilyCTJPs != null && !activeRelatedFamilyCTJPs.isEmpty()) {
                return false;
            }
        }

        return true;
    }

    public static String getCTJPFamily(String CTJPId) {
        System.debug('----- getCTJPFamily -----');

        List<String> CTJPQueryFields = new List<String>{'Family__c'};

        List<Contract_Treatment_Job_Product__c> CTJPList = ContractTreatmentJobProductDAO.getCTJPsFromIds(CTJPQueryFields, new List<Id>{CTJPId});
        Contract_Treatment_Job_Product__c CTJP = CTJPList[0];

        return CTJP.Family__c;
    }
}