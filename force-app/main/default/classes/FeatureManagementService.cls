public without sharing class FeatureManagementService {
    public static List<Feature_Activation_Config__mdt> metadatas;
    public static Map<String, Boolean> metadataMap;

    public static void getMetadatas() {
        if(metadatas == null) {
            System.debug('FeatureManagementService - Performing Metadata Query');
            metadatas = [SELECT Feature_Code__c, Status__c FROM Feature_Activation_Config__mdt];
            System.debug('getMetadatas - Metadatas: ' + metadatas);

            metadataMap = new Map<String, Boolean>();
            
            for(Feature_Activation_Config__mdt metadata : metadatas) {
                metadataMap.put(metadata.Feature_Code__c, metadata.Status__c);
            }
        }
    }

    public static Boolean getFeatureStatus(String featureCode) {
        Boolean status;

        if(metadataMap == null) {
            getMetadatas();
        }

        System.debug('getFeatureStatus - MetadataMap: ' + metadataMap);
        status = metadataMap.get(featureCode);

        if(status == null) {
            return true;
        }

        System.debug('getFeatureStatus - Status: ' + status);
        return status;
    }

    public static Boolean getFeatureStatus(String featureCode, Boolean defaultStatus) {
        Boolean status;

        if(metadataMap == null) {
            getMetadatas();
        }

        System.debug('getFeatureStatus - MetadataMap: ' + metadataMap);
        status = metadataMap.get(featureCode);

        if(status == null) {
            return defaultStatus;
        }

        System.debug('getFeatureStatus - Status: ' + status);
        return status;
    }
}