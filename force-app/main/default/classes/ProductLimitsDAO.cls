public with sharing class ProductLimitsDAO {

    //Used in getInactiveLimits
    public static List<Contract_Product_Limit__c> getInactiveSelectedLimits(String contractTreatmentId, List<String> allSelectedIds) {

        return [SELECT Id, Name, Contract_Treatment__c, Frequency__c, Frequency_Unit_of_measure__c,
                Max_Quantity__c, Min_Quantity__c, Product__c, Product__r.Name, Product__r.Product_Code__c, Quantity_Unit_of_measure__c, Status__c, Configured_Checkbox__c
                FROM Contract_Product_Limit__c 
                WHERE Contract_Treatment__c =: contractTreatmentId
                AND Status__c = 'Inactive'
                AND Product__c IN: allSelectedIds];
    }

    public static List<Contract_Product_Limit__c> getInactiveLimitsWithoutFilters(String contractTreatmentId) {

        return [SELECT Id, Name, Contract_Treatment__c, Frequency__c, Frequency_Unit_of_measure__c,
                Max_Quantity__c, Min_Quantity__c, Product__c, Product__r.Name, Product__r.Product_Code__c, Quantity_Unit_of_measure__c, Status__c, Configured_Checkbox__c
                FROM Contract_Product_Limit__c 
                WHERE Contract_Treatment__c =: contractTreatmentId
                AND Status__c = 'Inactive'
                LIMIT 100];
    }

    public static List<Contract_Product_Limit__c> getInactiveLimitsTypeProducts(String contractTreatmentId) {

        return [SELECT Id, Name, Contract_Treatment__c, Frequency__c, Frequency_Unit_of_measure__c,
                Max_Quantity__c, Min_Quantity__c, Product__c, Product__r.Name, Product__r.Product_Code__c, Quantity_Unit_of_measure__c, Status__c, Configured_Checkbox__c
                FROM Contract_Product_Limit__c 
                WHERE Contract_Treatment__c =: contractTreatmentId
                AND Status__c = 'Inactive'
                AND Product__r.Type__c != null 
                AND Product__r.Type__c != 'ZSRT'
                AND Product__r.Type__c != 'ZJOB'
                AND Product__r.Type__c != 'ZSER'
                LIMIT 100];
    }

    public static List<Contract_Product_Limit__c> getInactiveLimitsTypeServices(String contractTreatmentId) {

        return [SELECT Id, Name, Contract_Treatment__c, Frequency__c, Frequency_Unit_of_measure__c,
                Max_Quantity__c, Min_Quantity__c, Product__c, Product__r.Name, Product__r.Product_Code__c, Quantity_Unit_of_measure__c, Status__c, Configured_Checkbox__c
                FROM Contract_Product_Limit__c 
                WHERE Contract_Treatment__c =: contractTreatmentId
                AND Status__c = 'Inactive'
                AND Product__r.Type__c != null 
                AND Product__r.Type__c = 'ZSER'
                LIMIT 100];
    }

    public static List<Contract_Product_Limit__c> getInactiveLimitsWithSearchValue(String contractTreatmentId, String toSearch) {

        return [SELECT Id, Name, Contract_Treatment__c, Frequency__c, Frequency_Unit_of_measure__c,
                Max_Quantity__c, Min_Quantity__c, Product__c, Product__r.Name, Product__r.Product_Code__c, Quantity_Unit_of_measure__c, Status__c, Configured_Checkbox__c
                FROM Contract_Product_Limit__c 
                WHERE Contract_Treatment__c =: contractTreatmentId
                AND Status__c = 'Inactive'
                AND Product__r.Type__c != null 
                AND (Product__r.Product_Name_Translate__c LIKE: toSearch
                OR Product__r.Product_Code__c LIKE: toSearch
                OR Product__r.Name LIKE: toSearch)
                LIMIT 100];
    }

    public static List<Contract_Product_Limit__c> getInactiveLimitsProductsWithSearch(String contractTreatmentId, String toSearch) {

        return [SELECT Id, Name, Contract_Treatment__c, Frequency__c, Frequency_Unit_of_measure__c,
                Max_Quantity__c, Min_Quantity__c, Product__c, Product__r.Name, Product__r.Product_Code__c, Quantity_Unit_of_measure__c, Status__c, Configured_Checkbox__c
                FROM Contract_Product_Limit__c 
                WHERE Contract_Treatment__c =: contractTreatmentId
                AND Status__c = 'Inactive'
                AND Product__r.Type__c != null 
                AND (Product__r.Product_Name_Translate__c LIKE: toSearch
                OR Product__r.Product_Code__c LIKE: toSearch
                OR Product__r.Name LIKE: toSearch)
                AND Product__r.Type__c != null 
                AND Product__r.Type__c != 'ZSRT'
                AND Product__r.Type__c != 'ZJOB'
                AND Product__r.Type__c != 'ZSER'
                LIMIT 100];
    }

    public static List<Contract_Product_Limit__c> getInactiveLimitsServicesWithSearch(String contractTreatmentId, String toSearch) {

        return [SELECT Id, Name, Contract_Treatment__c, Frequency__c, Frequency_Unit_of_measure__c,
                Max_Quantity__c, Min_Quantity__c, Product__c, Product__r.Name, Product__r.Product_Code__c, Quantity_Unit_of_measure__c, Status__c, Configured_Checkbox__c
                FROM Contract_Product_Limit__c 
                WHERE Contract_Treatment__c =: contractTreatmentId
                AND Status__c = 'Inactive'
                AND Product__r.Type__c != null 
                AND (Product__r.Product_Name_Translate__c LIKE: toSearch
                OR Product__r.Product_Code__c LIKE: toSearch
                OR Product__r.Name LIKE: toSearch)
                AND Product__r.Type__c != null 
                AND Product__r.Type__c = 'ZSER'
                LIMIT 100];
    }

    //Used in getLimits
    public static List<Contract_Product_Limit__c> getLimitsWithoutFilters(String contractTreatmentId) {

        return [SELECT Id, Name, Contract_Treatment__c, Frequency__c, Frequency_Unit_of_measure__c,
                Max_Quantity__c, Min_Quantity__c, Product__c, Product__r.Name, Product__r.Type__c, Product__r.Product_Code__c, 
                Quantity_Unit_of_measure__c, Status__c, Configured_Checkbox__c
                FROM Contract_Product_Limit__c 
                WHERE Status__c = 'Active' AND Contract_Treatment__c =: contractTreatmentId];
    }

    public static List<Contract_Product_Limit__c> getLimitsTypeProducts(String contractTreatmentId) {

        return [SELECT Id, Name, Contract_Treatment__c, Frequency__c, Frequency_Unit_of_measure__c,
                Max_Quantity__c, Min_Quantity__c, Product__c, Product__r.Name, Product__r.Product_Code__c, Quantity_Unit_of_measure__c, Status__c, Configured_Checkbox__c
                FROM Contract_Product_Limit__c 
                WHERE Contract_Treatment__c =: contractTreatmentId
                AND Status__c = 'Active'
                AND Product__r.Type__c != null 
                AND Product__r.Type__c != 'ZSRT'
                AND Product__r.Type__c != 'ZJOB'
                AND Product__r.Type__c != 'ZSER'
                LIMIT 100];
    }

    public static List<Contract_Product_Limit__c> getLimitsTypeServices(String contractTreatmentId) {

        return [SELECT Id, Name, Contract_Treatment__c, Frequency__c, Frequency_Unit_of_measure__c,
                Max_Quantity__c, Min_Quantity__c, Product__c, Product__r.Name, Product__r.Product_Code__c, Quantity_Unit_of_measure__c, Status__c, Configured_Checkbox__c
                FROM Contract_Product_Limit__c 
                WHERE Contract_Treatment__c =: contractTreatmentId
                AND Status__c = 'Active'
                AND Product__r.Type__c != null 
                AND Product__r.Type__c = 'ZSER'
                LIMIT 100];
    }

    public static List<Contract_Product_Limit__c> getLimitsWithSearchValue(String contractTreatmentId, String toSearch) {

        return [SELECT Id, Name, Contract_Treatment__c, Frequency__c, Frequency_Unit_of_measure__c,
                Max_Quantity__c, Min_Quantity__c, Product__c, Product__r.Name, Product__r.Product_Code__c, Quantity_Unit_of_measure__c, Status__c, Configured_Checkbox__c
                FROM Contract_Product_Limit__c 
                WHERE Contract_Treatment__c =: contractTreatmentId
                AND Status__c = 'Active'
                AND Product__r.Type__c != null 
                AND (Product__r.Product_Name_Translate__c LIKE: toSearch
                OR Product__r.Product_Code__c LIKE: toSearch
                OR Product__r.Name LIKE: toSearch)
                LIMIT 100];
    }

    public static List<Contract_Product_Limit__c> getLimitsProductsWithSearch(String contractTreatmentId, String toSearch) {

        return [SELECT Id, Name, Contract_Treatment__c, Frequency__c, Frequency_Unit_of_measure__c,
                Max_Quantity__c, Min_Quantity__c, Product__c, Product__r.Name, Product__r.Product_Code__c, Quantity_Unit_of_measure__c, Status__c, Configured_Checkbox__c
                FROM Contract_Product_Limit__c 
                WHERE Contract_Treatment__c =: contractTreatmentId
                AND Status__c = 'Active'
                AND Product__r.Type__c != null 
                AND (Product__r.Product_Name_Translate__c LIKE: toSearch
                OR Product__r.Product_Code__c LIKE: toSearch
                OR Product__r.Name LIKE: toSearch)
                AND Product__r.Type__c != null 
                AND Product__r.Type__c != 'ZSRT'
                AND Product__r.Type__c != 'ZJOB'
                AND Product__r.Type__c != 'ZSER'
                LIMIT 100];
    }

    public static List<Contract_Product_Limit__c> getLimitsServicesWithSearch(String contractTreatmentId, String toSearch) {

        return [SELECT Id, Name, Contract_Treatment__c, Frequency__c, Frequency_Unit_of_measure__c,
                Max_Quantity__c, Min_Quantity__c, Product__c, Product__r.Name, Product__r.Product_Code__c, Quantity_Unit_of_measure__c, Status__c, Configured_Checkbox__c
                FROM Contract_Product_Limit__c 
                WHERE Contract_Treatment__c =: contractTreatmentId
                AND Status__c = 'Active'
                AND Product__r.Type__c != null 
                AND (Product__r.Product_Name_Translate__c LIKE: toSearch
                OR Product__r.Product_Code__c LIKE: toSearch
                OR Product__r.Name LIKE: toSearch)
                AND Product__r.Type__c != null 
                AND Product__r.Type__c = 'ZSER'
                LIMIT 100];
    }

    //Used in updateLimitsToActive
    public static List<Contract_Product_Limit__c> getLimitsToUpdate(List<String> productIds, String contractTreatmentId) {

        return [SELECT Id, Status__c FROM Contract_Product_Limit__c 
                WHERE Product__c IN: productIds 
                AND Contract_Treatment__c =: contractTreatmentId];
    }

    //Used in deleteLimit
    public static Contract_Product_Limit__c getLimitToDelete(String limitId) {

        return [SELECT Id, Name, Contract_Treatment__c, Frequency__c, Frequency_Unit_of_measure__c,
                Max_Quantity__c, Min_Quantity__c, Product__c, Product__r.Name, Quantity_Unit_of_measure__c, Status__c
                FROM Contract_Product_Limit__c WHERE Id =: limitId];
    }
}