public with sharing class AccountDAO {
  
    public static List<Account> getAccountNamebyId(String accountId) {
        String query = 'select Id,Name From Account where Id =:accountId';
        system.debug(query);
        return Database.query(query);
    }

    public static List<Account> getAccountFromIds(List<String> accountIds) {
        List<Account> relatedAccounts = [
        SELECT Id, Account_External_Id__c, RecordType.DeveloperName, FirstName, Salutation, 
        Entity_Type__c, Name, Name_2__c, Name_3__c, Name_4__c, MiddleName, LastName, PersonBirthdate, HealthCloudGA__DeceasedDate__pc, 
        HealthCloudGA__Gender__pc, Birth_city__pc,Birth_country__pc, Fiscal_Code__c, VAT_Number__c, Social_Security_Number__pc,
        PersonHomePhone, Work_Phone__c, Phone, PersonMobilePhone, PersonEmail, Email_B2B__c, Fax, ShippingStreet, ShippingPostalCode, 
        ShippingCity, ShippingStateCode, ShippingCountry, Shipping_Telephone__c, Address_ID__c, Patients_insurance_number__pc, 
        Iban__c, Billing_Reference__c, Customer_Purchase_Order_Number__c, 
        Customer_Purchase_Order_Date__c, Chamber_of_commerce_number__c, Language__c, Description, RecordType.Name, AutoNumber__c, ShippingCountryCode, IsPersonAccount,
        TransportationZone__c, Dunning_Email__c, Billing_Email__c, Bank_Account_Owner__c, Regional_Grouping__c, IsCreatedSAP__c, IsSyncSAP__c 
        FROM Account
        WHERE Id IN :accountIds
        ];
        
        return relatedAccounts;
    }

    public static Account getAccountFromId(List<String> queryFields, Id accountId) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
            query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Account WHERE Id =: accountId';
        System.debug('getAccountFromId QUERY: ' + query);
        
        return Database.query(query);
    }

    public static List<Account> getAccountFromRecordIds(List<String> queryFields, List<String> recordIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
            query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Account WHERE Account_External_Id__c IN: recordIds';
        System.debug('getAccountFromRecordIds QUERY: ' + query);
        
        return Database.query(query);
    }

    public static List<Account> getAccountIsSapSyncFromRecordIds(List<String> queryFields, List<Id> recordIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
            query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Account WHERE Id IN: recordIds';
        System.debug('getAccountIsSapSyncFromRecordIds QUERY: ' + query);
        
        return Database.query(query);
    }

}