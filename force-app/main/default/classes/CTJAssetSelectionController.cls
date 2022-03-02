public class CTJAssetSelectionController {
    
    @AuraEnabled(cacheable=true)
    public static List<AssetDTO> getAssets(String contractTreatmentId, String searchInput, List<Id> selectedIds, Integer queryLimit) {
        System.debug('----- in CTJAssetSelectionController.getAssets -----');
        
        List<String> assetQueryFields = new List<String>{'SerialNumber', 'Manufacturer_ID__c', 'Product2.Product_Name_Translate__c', 'Product2.Product_Code__c', 
        'Product2.Manufacturer_part_number__c', 'Product2.Product_Family__r.Product_Name_Translate__c'};
        List<String> contractAssetQueryFields = new List<String>{'Asset__c'};

        List<AssetDTO> DTOsToReturn = new List<AssetDTO>();
        List<Asset> assets = new List<Asset>();
        List<Asset> alreadySelectedAssets = new List<Asset>();
        List<Contract_Asset__c> contractAssetsRelatedToCT = new List<Contract_Asset__c>();
        List<Id> assetIdsToExclude = new List<Id>();
        String searchTerm = '%' + searchInput + '%';

        // Getting Assets already related to the selected CT, to exclude them from the next query of available assets

        contractAssetsRelatedToCT = ContractAssetDAO.getContractAssetsFromCTIds(contractAssetQueryFields, new List<String>{contractTreatmentId});

        for(Contract_Asset__c ca : contractAssetsRelatedToCT) {
            assetIdsToExclude.add(ca.Asset__c);
        }

        String query = 'SELECT ';
        for(Integer i = 0; i < assetQueryFields.size(); i++) {
        	query += assetQueryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Asset WHERE Id NOT IN: assetIdsToExclude';

        if(searchInput != null && searchInput != '' && searchInput.length() >= 3) {
            query += ' AND (SerialNumber LIKE: searchTerm OR Manufacturer_ID__c LIKE: searchTerm OR Product2.Product_Name_Translate__c LIKE: searchTerm ' +
            'OR Product2.Product_Code__c LIKE: searchTerm OR Product2.Manufacturer_part_number__c LIKE: searchTerm ' +
            'OR Product2.Product_Family__r.Product_Name_Translate__c LIKE: searchTerm)';
        }

        if(queryLimit != null) {
            query += ' LIMIT ' + queryLimit;
        }

        System.debug('CT Assets QUERY: ' + query);
        assets = Database.query(query);

        // Adding the already selected Assets to the results shown every time

        if(selectedIds != null && !selectedIds.isEmpty()) {
            alreadySelectedAssets = AssetDAO.getAssetsFromIds(assetQueryFields, selectedIds);

            for(Asset a : alreadySelectedAssets) {
                if(!assets.contains(a)) {
                    assets.add(a);
                }
            }
        }

        for(Asset a : assets) {
            AssetDTO dto = new AssetDTO(
                a.Id,
                a.SerialNumber,
                a.Manufacturer_ID__c,
                a.Product2.Product_Name_Translate__c,
                a.Product2.Product_Code__c,
                a.Product2.Manufacturer_part_number__c,
                a.Product2.Product_Family__r.Product_Name_Translate__c
            );

            DTOsToReturn.add(dto);
        }

        return DTOsToReturn;
    }

    @AuraEnabled
    public static void createContractAssets(List<String> assetIds, String contractTreatmentId) {
        List<Contract_Asset__c> newContractAssets = new List<Contract_Asset__c>();

        for(String assetId : assetIds) {
            Contract_Asset__c contractAsset = new Contract_Asset__c(
                Asset__c = assetId,
                Contract_Treatment__c = contractTreatmentId
            );

            newContractAssets.add(contractAsset);
        }

        if(!newContractAssets.isEmpty()) {
            List<Database.SaveResult> results = Database.insert(newContractAssets);
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<ContractAssetDTO> getContractAssetsForCT(String contractTreatmentId) {
        List<String> contractAssetQueryFields = new List<String>{'Asset__c', 'Contract_Treatment__c', 'Asset__r.SerialNumber', 'ProductName__c'};

        List<ContractAssetDTO> DTOsToReturn = new List<ContractAssetDTO>();
        List<Contract_Asset__c> contractAssets = ContractAssetDAO.getContractAssetsFromCTIds(contractAssetQueryFields, new List<String>{contractTreatmentId});

        for(Contract_Asset__c ca : contractAssets) {
            ContractAssetDTO dto = new ContractAssetDTO(
                ca.Id,
                ca.Asset__r.SerialNumber,
                ca.Contract_Treatment__c,
                ca.ProductName__c
            );

            DTOsToReturn.add(dto);
        }

        return DTOsToReturn;
    }

    @AuraEnabled
    public static void deleteContractAsset(String contractAssetId) {
        Contract_Asset__c contractAsset = [SELECT Id FROM Contract_Asset__c WHERE Id =: contractAssetId];

        if(contractAsset != null) {
            Database.DeleteResult result = Database.delete(contractAsset);
        }
    }
}