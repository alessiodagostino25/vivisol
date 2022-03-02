public with sharing class CorporateTreatmentJobProductDAO {

    public static Contract_Framework__c getContractFramework(String CFId) {

        return [SELECT Id, Price_list_code__c FROM Contract_Framework__c WHERE Id =: CFId];
    }

    public static Pricebook2 getPricebook(Id pricebookId) {

        return [SELECT Id, Name FROM Pricebook2 WHERE Id =: pricebookId];
    }

    public static List<PricebookEntry> getPricebookEntries(Id pricebookId) {

        return [SELECT Product2Id FROM PricebookEntry WHERE Pricebook2Id =: pricebookId AND IsActive = true];
    }

    public static List<Contract_Treatment_Job_Product__c> getContractTJP(String contractTreatmentJobId) {

        return [SELECT Id, Product__c, Product__r.Product_Family__c, Status__c FROM Contract_Treatment_Job_Product__c
                WHERE Contract_Treatment_Job__c =: contractTreatmentJobId];
    }

    public static List<Product2> getSelectedProduct2(List<String> allSelectedIds) {

        return [SELECT Id, Product_Name_Translate__c, Product_Code__c, Product_Family__r.Product_Name_Translate__c,
                Product_Family__r.Product_Code__c, Manufacturer_Part_Number__c FROM Product2
                WHERE Id IN: allSelectedIds];
    }

    public static List<Corporate_Treatment_Job_Product__c> getFamilies(String corporateTreatment, String corporateTreatmentJob) {

        return [SELECT Product_Activities_Family__r.Id FROM Corporate_Treatment_Job_Product__c 
                WHERE Product_Activities_Family__r.Product_Family__c = null
                AND Corporate_Treatment__c =: corporateTreatment
                AND Corporate_Treatment_Job__c =: corporateTreatmentJob];
    }

    public static List<Product2> getProduct2WithSearchValue(List<Id> familyIds, List<Id> contractFamiliesIds, List<Id> selectedFamilyIds, String toSearch, 
    List<Id> notToShowIds, List<Id> PEProductIds) {

        return [SELECT Product_Name_Translate__c, Product_Code__c, Product_Family__c, Product_Family__r.Product_Name_Translate__c, Product_Family__r.Product_Code__c,
                Manufacturer_part_number__c FROM Product2 
                WHERE Product_Family__c != NULL
                AND Id IN: PEProductIds 
                AND IsActive = true 
                AND Product_Family__c NOT IN: contractFamiliesIds
                AND Product_Family__c NOT IN: selectedFamilyIds
                AND Product_Family__c IN: familyIds
                AND (Product_Name_Translate__c LIKE: toSearch
                OR Product_Code__c LIKE:toSearch
                OR Product_Family__r.Product_Name_Translate__c LIKE:toSearch
                OR Product_Family__r.Product_Code__c LIKE:toSearch
                OR Manufacturer_part_number__c LIKE:toSearch)
                AND Id NOT IN: notToShowIds
                LIMIT 100];
    }

    public static List<Product2> getProduct2WithoutFilters(List<Id> familyIds, List<Id> contractFamiliesIds, List<Id> selectedFamilyIds, List<Id> notToShowIds, 
    List<Id> PEProductIds) {

        return [SELECT Product_Name_Translate__c, Product_Code__c, Product_Family__c, Product_Family__r.Product_Name_Translate__c, Product_Family__r.Product_Code__c,
                Manufacturer_part_number__c FROM Product2  
                WHERE Product_Family__c IN: familyIds
                AND Id IN: PEProductIds 
                AND IsActive = true 
                AND Product_Family__c != NULL
                AND Product_Family__c NOT IN: contractFamiliesIds
                AND Product_Family__c NOT IN: selectedFamilyIds
                AND Id NOT IN: notToShowIds
                LIMIT 100];
    }

    public static List<Product2> getProduct2WithSearchValueAndPicklistValue(List<Id> familyIds, List<Id> selectedFamilyIds, List<Id> contractFamiliesIds, 
    String toSearch, List<Id> notToShowIds, String picklistValue, List<Id> PEProductIds) {

        return [SELECT Product_Name_Translate__c, Product_Code__c, Product_Family__c, Product_Family__r.Product_Name_Translate__c, Product_Family__r.Product_Code__c,
                Manufacturer_part_number__c FROM Product2 
                WHERE Product_Family__c IN: familyIds 
                AND Id IN: PEProductIds 
                AND IsActive = true 
                AND Product_Family__c NOT IN: selectedFamilyIds
                AND Product_Family__c NOT IN: contractFamiliesIds
                AND (Product_Name_Translate__c LIKE: toSearch
                OR Product_Code__c LIKE:toSearch
                OR Product_Family__r.Product_Name_Translate__c LIKE:toSearch
                OR Product_Family__r.Product_Code__c LIKE:toSearch
                OR Manufacturer_part_number__c LIKE:toSearch)
                AND Id NOT IN: notToShowIds
                AND toLabel(Type__c) =: picklistValue
                LIMIT 100];
    }

    public static List<Product2> getProduct2WithPicklistValue(List<Id> familyIds, List<Id> selectedFamilyIds, List<Id> contractFamiliesIds, 
    List<Id> notToShowIds, String picklistValue, List<Id> PEProductIds) {

        return [SELECT Product_Name_Translate__c, Product_Code__c, Product_Family__c, Product_Family__r.Product_Name_Translate__c, Product_Family__r.Product_Code__c,
                Manufacturer_part_number__c FROM Product2 
                WHERE Product_Family__c IN: familyIds
                AND Id IN: PEProductIds 
                AND IsActive = true 
                AND Product_Family__c NOT IN: selectedFamilyIds
                AND Product_Family__c NOT IN: contractFamiliesIds
                AND Id NOT IN: notToShowIds
                AND toLabel(Type__c) =: picklistValue
                LIMIT 100];
    }

    //Used in Product Types
    public static List<AggregateResult> getProductTypesLabels() {

        return [SELECT toLabel(Type__c) type FROM Product2 WHERE Type__c != 'ZSRT' AND Type__c != null 
                AND Type__c != 'ZJOB' GROUP BY Type__c];
    }

    //Used in Create CTJP
    public static Contract_Treatment_Job__c getCTJ(String contractTreatmentJob) {

        return [SELECT Id, Contract_Treatment__c FROM Contract_Treatment_Job__c WHERE Id =: contractTreatmentJob];
    }

    public static List<Contract_Product_Limit__c> getPresentLimits(Id contractTreatmentId) {

        return [SELECT Name, Contract_Treatment__c, Frequency__c, Frequency_Unit_of_measure__c,
                Max_Quantity__c, Min_Quantity__c, Product__c, Product__r.Name, Quantity_Unit_of_measure__c
                FROM Contract_Product_Limit__c WHERE Contract_Treatment__c =: contractTreatmentId];
    }

    public static List<Product2> getProducts(List<Id> productIds) {

        return [SELECT Id, Name FROM Product2 WHERE Id IN: productIds];
    }

    /*public static List<Contract_Treatment_Job_Product__c> getAllInsertedCTJPs(List<Id> productIds, Id contractTreatmentJobId) {

        return [SELECT Id, Name, Product__c, Contract_Treatment_Job__c 
                FROM Contract_Treatment_Job_Product__c
                WHERE Product__c IN: productIds
                AND Contract_Treatment_Job__c =: contractTreatmentJobId];
    }*/

    //Used in Get CTJP
    public static List<Contract_Treatment_Job_Product__c> getCreatedCTJPWithSearchValue(String contractTreatmentJob, String toSearch) {

        return [SELECT Id, Name, Product__c, Product__r.Product_Name_Translate__c, Product__r.Family_Name__c, 
                Contract_Treatment_Job__c,
                Product__r.Product_Code__c, Product__r.Product_Family__r.Product_Name_Translate__c,
                Product__r.Manufacturer_Part_Number__c, Configured_Checkbox__c, Min_Quantity__c, Max_Quantity__c,
                Quantity_Unit_of_measure__c, Quantity__c,
                toLabel(Product__r.Type__c), Status__c, Billable__c FROM Contract_Treatment_Job_Product__c
                WHERE Contract_Treatment_Job__c =: contractTreatmentJob
                AND (Product__r.Product_Name_Translate__c LIKE: toSearch
                OR Product__r.Family_Name__c LIKE: toSearch
                OR Product__r.Product_Code__c LIKE: toSearch
                OR Product__r.Product_Family__r.Product_Name_Translate__c LIKE: toSearch
                OR Product__r.Manufacturer_Part_Number__c LIKE: toSearch)
                LIMIT 100];
    }

    public static List<Contract_Treatment_Job_Product__c> getCreatedCTJPWithoutSearchValue(String contractTreatmentJob) {

        return [SELECT Id, Name, Product__c, Product__r.Product_Name_Translate__c, Product__r.Family_Name__c,
                Contract_Treatment_Job__c,
                Product__r.Product_Code__c, Product__r.Product_Family__r.Product_Name_Translate__c,
                Product__r.Manufacturer_Part_Number__c, Configured_Checkbox__c, Min_Quantity__c, Max_Quantity__c,
                Quantity_Unit_of_measure__c, Quantity__c,
                toLabel(Product__r.Type__c), Status__c, Billable__c FROM Contract_Treatment_Job_Product__c
                WHERE Contract_Treatment_Job__c =: contractTreatmentJob
                LIMIT 100];
    }

    //Used in Get Family Ids
    public static List<Contract_Treatment_Job_Product__c> getCreatedFamilyCTJP(String contractTreatmentJob) {

        return [SELECT Id, Name, Product__c, Product__r.Product_Name_Translate__c, 
                Contract_Treatment_Job__c,
                Product__r.Product_Code__c, Product__r.Product_Family__r.Product_Name_Translate__c,
                Product__r.Manufacturer_Part_Number__c,
                Product_Type__c FROM Contract_Treatment_Job_Product__c
                WHERE Contract_Treatment_Job__c =: contractTreatmentJob
                AND Product__r.Product_Family__c = null];
    }

    //Used in Get Product Ids
    public static List<Contract_Treatment_Job_Product__c> getCreatedProductCTJP(String contractTreatmentJob) {

        return [SELECT Id, Name, Product__c, Product__r.Product_Name_Translate__c, 
                Contract_Treatment_Job__c,
                Product__r.Product_Code__c, Product__r.Product_Family__r.Product_Name_Translate__c,
                Product__r.Manufacturer_Part_Number__c,
                Product_Type__c FROM Contract_Treatment_Job_Product__c
                WHERE Contract_Treatment_Job__c =: contractTreatmentJob
                AND Product__r.Product_Family__c != null];
    }

    //Used in Delete CTJP
    public static Contract_Treatment_Job_Product__c getCTJPFromId(String productId) {

        return [SELECT Id FROM Contract_Treatment_Job_Product__c WHERE Id =: productId];
    }

}