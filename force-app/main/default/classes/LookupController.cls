public with sharing class LookupController {
    private final static Integer MAX_RESULTS = 5;

    @AuraEnabled(Cacheable=true)
    public static List<LookupSearchResult> search(String searchTerm, List<String> selectedIds, String accountId) {
        // Prepare query paramters
        searchTerm += '*';

        // Execute search query
        List<List<SObject>> searchResults = [
            FIND :searchTerm
            IN ALL FIELDS
            RETURNING
                Location(Id, Name, Account__r.Name, Account__c WHERE Id NOT IN :selectedIds AND Account__c = :accountId)
            LIMIT :MAX_RESULTS
        ];

        // Prepare results
        List<LookupSearchResult> results = new List<LookupSearchResult>();

        // Extract Locations & convert them into LookupSearchResult
        String locationIcon = 'standard:location';
        Schema.Location[] locations = (List<Schema.Location>) searchResults[0];
        for (Schema.Location l : locations) {
            results.add(
                new LookupSearchResult(
                    l.Id,
                    'Location',
                    locationIcon,
                    l.Name,
                    l.Account__r.Name
                )
            );
        }

        // Optionnaly sort all results on title
        results.sort();

        return results;
    }
    @AuraEnabled(Cacheable=true)
    public static List<LookupSearchResult> assetsearch(String searchTerm, List<String> selectedIds) {
        // Prepare query paramters
        searchTerm += '*';

        // Execute search query
        List<List<SObject>> searchResults = [
            FIND :searchTerm
            IN ALL FIELDS
            RETURNING
                Asset(Id, Name WHERE Id NOT IN :selectedIds )
            LIMIT :MAX_RESULTS
        ];

        // Prepare results
        List<LookupSearchResult> results = new List<LookupSearchResult>();

        // Extract Locations & convert them into LookupSearchResult
        String assetIcon = 'standard:asset_object';
        Asset[] assets = (List<Asset>) searchResults[0];
        for (Asset a : assets) {
            results.add(
                new LookupSearchResult(
                    a.Id,
                    'Asset',
                    assetIcon,
                    a.Name,
                    a.Name
                )
            );
        }

        // Optionnaly sort all results on title
        results.sort();

        return results;
    }
    
    @AuraEnabled(Cacheable=true)
    public static List<LookupSearchResult> contractTreatmentJobProductSearch(String searchTerm, List<String> selectedIds, String accountId) {
        // Prepare query paramters
        searchTerm += '*';
        system.debug('contractTreatmentJobId: ' + accountId);
        system.debug('searchTerm: ' + searchTerm);
        system.debug('selectedIds: ' + selectedIds);

        // Execute search query
        List<List<SObject>> searchResults = [
            FIND :searchTerm
            IN ALL FIELDS
            RETURNING
                Contract_Treatment_Job_Product__c(Id, Name, Product__r.Name, Product_Code__c WHERE Contract_Treatment_Job__c = :accountId and Status__c = 'Active' )
            LIMIT :MAX_RESULTS
        ];

        // Prepare results
        List<LookupSearchResult> results = new List<LookupSearchResult>();

        // Extract Locations & convert them into LookupSearchResult
        Contract_Treatment_Job_Product__c[] products = (List<Contract_Treatment_Job_Product__c>) searchResults[0];
        for (Contract_Treatment_Job_Product__c ctjp : products) {
            results.add(
                new LookupSearchResult(
                    ctjp.Id,
                    'Contract_Treatment_Job_Product__c',
                    'standard:record',
                    ctjp.Product__r.Name,
                    ctjp.Product_Code__c
                )
            );
        }

        // Optionnaly sort all results on title
        results.sort();

        return results;
    }

    @AuraEnabled(Cacheable=true)
    public static List<LookupSearchResult> contractFrameworkSearch(String searchTerm, String contractFrameworkId) {
        // Prepare query paramters
        searchTerm += '*';
        system.debug('searchTerm: ' + searchTerm);
        System.debug('contractFrameworkId: ' + contractFrameworkId);

        // Execute search query
        List<List<SObject>> searchResults = [
            FIND :searchTerm
            IN ALL FIELDS
            RETURNING
                Contract_Framework__c(Id, Name, Contract_Number__c WHERE Id != :contractFrameworkId AND Status__c != 'Inactive')
            LIMIT :MAX_RESULTS
        ];

        // Prepare results
        List<LookupSearchResult> results = new List<LookupSearchResult>();

        // Extract Locations & convert them into LookupSearchResult
        Contract_Framework__c[] CFs = (List<Contract_Framework__c>) searchResults[0];
        for (Contract_Framework__c cf : CFs) {
            results.add(
                new LookupSearchResult(
                    cf.Id,
                    'Contract_Framework__c',
                    'standard:record',
                    cf.Name,
                    cf.Contract_Number__c
                )
            );
        }

        // Optionnaly sort all results on title
        results.sort();

        return results;
    }

    @AuraEnabled(Cacheable=true)
    public static List<LookupSearchResult> assetsFromPESearch(String searchTerm, String pricebookEntryId) {
        // Prepare query paramters
        searchTerm += '*';
        system.debug('searchTerm: ' + searchTerm);
        System.debug('pricebookEntryId: ' + pricebookEntryId);

        PricebookEntry pe = [SELECT Id, Product2Id, Product2.Type__c FROM PricebookEntry WHERE Id =: pricebookEntryId];

        System.debug('pricebookEntry.Product2.Type: ' + pe.Product2.Type__c);

        List<List<SObject>> searchResults = new List<List<SObject>>();

        // Execute search query

        if(pe.Product2.Type__c == 'ZSER') {
            searchResults = [
                FIND :searchTerm
                IN ALL FIELDS
                RETURNING
                    Asset(Id, Name, SerialNumber)
                LIMIT :MAX_RESULTS
            ];
        }
        else {
            searchResults = [
                FIND :searchTerm
                IN ALL FIELDS
                RETURNING
                    Asset(Id, Name, SerialNumber WHERE Product2Id =: pe.Product2Id)
                LIMIT :MAX_RESULTS
            ];
        }

        // Prepare results
        List<LookupSearchResult> results = new List<LookupSearchResult>();

        // Extract Locations & convert them into LookupSearchResult
        Asset[] assets = (List<Asset>) searchResults[0];
        for (Asset a : assets) {
            results.add(
                new LookupSearchResult(
                    a.Id,
                    'Asset',
                    'standard:record',
                    a.Name,
                    a.SerialNumber
                )
            );
        }

        // Optionnaly sort all results on title
        results.sort();

        return results;
    }

    @AuraEnabled(Cacheable=true)
    public static List<LookupSearchResult> searchZJOBProductsForContractFramework(String searchTerm, String contractFrameworkId) {
        // Prepare query paramters
        searchTerm += '*';
        system.debug('searchTerm: ' + searchTerm);
        System.debug('contractFrameworkId: ' + contractFrameworkId);

        Contract_Framework__c contractFramework = [SELECT Price_list_code__r.External_ID__c FROM Contract_Framework__c WHERE Id =: contractFrameworkId];
        String pricebookToSearch = '%' + contractFramework.Price_list_code__r.External_ID__c + '%';

        // Execute search query
        List<List<SObject>> searchResults = [
            FIND :searchTerm
            IN ALL FIELDS
            RETURNING
                Product2(Id, Product_Name_Translate__c, Product_Code__c WHERE PriceBooks__c LIKE: pricebookToSearch AND Type__c = 'ZJOB')
            LIMIT :MAX_RESULTS
        ];

        // Prepare results
        List<LookupSearchResult> results = new List<LookupSearchResult>();

        // Extract Locations & convert them into LookupSearchResult
        Product2[] products = (List<Product2>) searchResults[0];
        for (Product2 p : products) {
            results.add(
                new LookupSearchResult(
                    p.Id,
                    'Product2',
                    'standard:record',
                    p.Product_Name_Translate__c,
                    p.Product_Code__c
                )
            );
        }

        // Optionnaly sort all results on title
        results.sort();

        return results;
    }

    @AuraEnabled(Cacheable=true)
    public static List<LookupSearchResult> searchZSRTProductsForContractFramework(String searchTerm, String contractFrameworkId) {
        // Prepare query paramters
        searchTerm += '*';
        system.debug('searchTerm: ' + searchTerm);
        System.debug('contractFrameworkId: ' + contractFrameworkId);

        Contract_Framework__c contractFramework = [SELECT Price_list_code__r.External_ID__c  FROM Contract_Framework__c WHERE Id =: contractFrameworkId];
        String pricebookToSearch = '%' + contractFramework.Price_list_code__r.External_ID__c + '%';

        // Execute search query
        List<List<SObject>> searchResults = [
            FIND :searchTerm
            IN ALL FIELDS
            RETURNING
                Product2(Id, Product_Name_Translate__c, Product_Code__c WHERE PriceBooks__c LIKE: pricebookToSearch AND Type__c = 'ZSRT')
            LIMIT :MAX_RESULTS
        ];

        // Prepare results
        List<LookupSearchResult> results = new List<LookupSearchResult>();

        // Extract Locations & convert them into LookupSearchResult
        Product2[] products = (List<Product2>) searchResults[0];
        for (Product2 p : products) {
            results.add(
                new LookupSearchResult(
                    p.Id,
                    'Product2',
                    'standard:record',
                    p.Product_Name_Translate__c,
                    p.Product_Code__c
                )
            );
        }

        // Optionnaly sort all results on title
        results.sort();

        return results;
    }

    @AuraEnabled(Cacheable=true)
    public static List<LookupSearchResult> searchZSERProductsForContractFramework(String searchTerm, String contractFrameworkId) {
        // Prepare query paramters
        searchTerm += '*';
        system.debug('searchTerm: ' + searchTerm);
        System.debug('contractFrameworkId: ' + contractFrameworkId);

        Contract_Framework__c contractFramework = [SELECT Price_list_code__r.External_ID__c  FROM Contract_Framework__c WHERE Id =: contractFrameworkId];
        String pricebookToSearch = '%' + contractFramework.Price_list_code__r.External_ID__c + '%';

        // Execute search query
        List<List<SObject>> searchResults = [
            FIND :searchTerm
            IN ALL FIELDS
            RETURNING
                Product2(Id, Product_Name_Translate__c, Product_Code__c WHERE PriceBooks__c LIKE: pricebookToSearch AND Type__c = 'ZSER')
            LIMIT :MAX_RESULTS
        ];

        // Prepare results
        List<LookupSearchResult> results = new List<LookupSearchResult>();

        // Extract Locations & convert them into LookupSearchResult
        Product2[] products = (List<Product2>) searchResults[0];
        for (Product2 p : products) {
            results.add(
                new LookupSearchResult(
                    p.Id,
                    'Product2',
                    'standard:record',
                    p.Product_Name_Translate__c,
                    p.Product_Code__c
                )
            );
        }

        // Optionnaly sort all results on title
        results.sort();

        return results;
    }

    @AuraEnabled(Cacheable=true)
    public static List<LookupSearchResult> searchPlants(String searchTerm, String pricebookEntryId) {
        // Prepare query paramters
        searchTerm += '*';
        system.debug('searchTerm: ' + searchTerm);
        System.debug('pricebookEntryId: ' + pricebookEntryId);

        // Execute search query
        List<List<SObject>> searchResults = [
            FIND :searchTerm
            IN ALL FIELDS
            RETURNING
                Location(Id, Name, LocationType WHERE LocationType = 'Plant')
            LIMIT :MAX_RESULTS
        ];

        // Prepare results
        List<LookupSearchResult> results = new List<LookupSearchResult>();

        // Extract Locations & convert them into LookupSearchResult
        Schema.Location[] locations = (List<Schema.Location>) searchResults[0];
        for (Schema.Location l : locations) {
            results.add(
                new LookupSearchResult(
                    l.Id,
                    'Location',
                    'standard:record',
                    l.Name,
                    l.LocationType
                )
            );
        }

        // Optionnaly sort all results on title
        results.sort();

        return results;
    }

    @AuraEnabled(Cacheable=true)
    public static List<LookupSearchResult> searchStorageLocations(String searchTerm, String pricebookEntryId) {
        // Prepare query paramters
        searchTerm += '*';
        system.debug('searchTerm: ' + searchTerm);
        System.debug('pricebookEntryId: ' + pricebookEntryId);

        // Execute search query
        List<List<SObject>> searchResults = [
            FIND :searchTerm
            IN ALL FIELDS
            RETURNING
                Location(Id, Name, LocationType WHERE LocationType = 'Warehouse')
            LIMIT :MAX_RESULTS
        ];

        // Prepare results
        List<LookupSearchResult> results = new List<LookupSearchResult>();

        // Extract Locations & convert them into LookupSearchResult
        Schema.Location[] locations = (List<Schema.Location>) searchResults[0];
        for (Schema.Location l : locations) {
            results.add(
                new LookupSearchResult(
                    l.Id,
                    'Location',
                    'standard:record',
                    l.Name,
                    l.LocationType
                )
            );
        }

        // Optionnaly sort all results on title
        results.sort();

        return results;
    }

}