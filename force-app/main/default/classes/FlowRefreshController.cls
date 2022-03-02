public without sharing class FlowRefreshController {
    public class InvalidIdException extends Exception {}

    @AuraEnabled
    public static List<SObject> getSObject(String recordId) {
        if(Pattern.compile( '[a-zA-Z0-9]{15}|[a-zA-Z0-9]{18}' ).matcher(recordId).matches()) {
            Id validId = (Id) recordId;
            String sObjName = validId.getSObjectType().getDescribe().getName();

            if(sObjName != null) {
                String query = 'SELECT Id FROM ' + sObjName + ' WHERE Id =: recordId';

                if(sObjName == 'ProductRequestLineItem') {
                    query += ' AND Availability__c != null';
                }

                return Database.query(query);
            }
        }
        else {
            throw new InvalidIdException('Invalid Id provided');
        }

        return null;
    }
}