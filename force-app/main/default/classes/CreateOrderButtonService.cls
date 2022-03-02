public class CreateOrderButtonService {
    
    @AuraEnabled
    public static OrderDTO getPrefilledOrder(String caseId) {

        Case c = CaseDAO.getCaseForOrder(caseId);

        OrderDTO dtoToReturn;

        if(c.Account.IsPersonAccount == true) {

            dtoToReturn = new OrderDTO(
                c.AccountId, 
                c.ContactId, 
                c.AccountId,
                c.Contract_Treatment__c,
                c.Account.Location__c,
                c.Account.Location__c,
                null,
                null,
                null, 
                null,
                c.Account.Location__r.VisitorAddress.Street,
                c.Account.Location__r.VisitorAddress.PostalCode,
                c.Account.Location__r.VisitorAddress.City,
                c.Account.Location__r.VisitorAddress.StateCode,
                c.Account.Location__r.VisitorAddress.CountryCode,
                c.Account.Location__r.VisitorAddress.Street,
                c.Account.Location__r.VisitorAddress.PostalCode,
                c.Account.Location__r.VisitorAddress.City,
                c.Account.Location__r.VisitorAddress.StateCode,
                c.Account.Location__r.VisitorAddress.CountryCode);
        }

        else if(c.Account.IsPersonAccount == false) {

            dtoToReturn = new OrderDTO(
                c.AccountId, 
                c.ContactId, 
                c.Contract_Treatment__r.Contract_Framework__r.Customer__c,
                c.Contract_Treatment__c,
                c.Account.Location__c,
                c.Contract_Treatment__r.Contract_Framework__r.Customer__r.Location__c,
                c.Contract_Treatment__r.Contract_Framework__r.Customer__r.Billing_reference__c,
                c.Contract_Treatment__r.Contract_Framework__r.Customer__r.Customer_Purchase_Order_Number__c,
                c.Contract_Treatment__r.Contract_Framework__r.Customer__r.Customer_Purchase_Order_Date__c, 
                c.Contract_Treatment__r.Contract_Framework__r.Payment_Condition__c,
                c.Account.ShippingStreet,
                c.Account.ShippingPostalCode,
                c.Account.ShippingCity,
                c.Account.ShippingStateCode,
                c.Account.ShippingCountryCode,
                c.Contract_Treatment__r.Contract_Framework__r.Customer__r.LocationStreet__c,
                c.Contract_Treatment__r.Contract_Framework__r.Customer__r.LocationPostalCode__c,
                c.Contract_Treatment__r.Contract_Framework__r.Customer__r.LocationCity__c,
                c.Contract_Treatment__r.Contract_Framework__r.Customer__r.LocationStateCode__c,
                c.Contract_Treatment__r.Contract_Framework__r.Customer__r.LocationCountryCode__c);
        }
        System.debug('DTO: ' + dtoToReturn);    
        return dtoToReturn;

        /*List<Create_Button_Mapping__mdt> mdts = [SELECT Field_API_Name__c, Field_To_Copy__c FROM Create_Button_Mapping__mdt];
        Map<String, String> returnMap = new Map<String,String>();
        List<String> fieldsToQuery = new List<String>();
        String stringForQuery;

        for(Create_Button_Mapping__mdt mdt : mdts) {
            fieldsToQuery.add(mdt.Field_To_Copy__c);
        }
        for(Integer i = 0; i < fieldsToQuery.size(); i++) {
            if(stringForQuery == null) {
                stringForQuery = fieldsToQuery[i] + ', ';
            }
            else if(i < fieldsToQuery.size() - 1) {
                stringForQuery += fieldsToQuery[i] + ', ';
            }
            else {
                stringForQuery += fieldsToQuery[i];
            }
        }
        System.debug('String for query: ' + stringForQuery);

        String query = 'SELECT ' + stringForQuery + ' FROM Case WHERE Id = ' + '\'' + caseId + '\'';

        System.debug('Query: ' + query);

        Case c = Database.query(query);
        for(String fieldName : fieldsToQuery) {
            //This gives problems: I should use getSObject() for related fields, but I cannot know 
            System.debug('Field from case: ' + (String) c.get(fieldName)); 
        }

        //Would like to return a map with 'Order Field: Case field from query'. But i cannot manage to iterate over fields of queried Case*/
    }

    @AuraEnabled
    public static OrderDTO getNotPrefilledOrder(){
        
        return new OrderDTO();
    }
}