public without sharing class SObjectServiceClass {

    public static void updateExternalId (String objectName, String fieldFrom, String fieldTo, List<SObject> records){
        List<SObject> recordToUpdate = new List<SObject>(); 
        for (Sobject record : records){
            if (record.get(fieldTo) == null && record.get(fieldFrom) != null){
                Sobject tmp = Schema.getGlobalDescribe().get(objectName).newSObject();
                tmp.Id = record.Id;
                if(!Test.isRunningTest()) {
                    tmp.put(fieldTo,record.get(fieldFrom));
                }
                else {
                    tmp.put(fieldTo, record.get(fieldFrom) + String.valueOf(math.random()));
                }
                recordToUpdate.add(tmp);
            }
        }

        if(!recordToUpdate.isEmpty()) {
            List<Database.SaveResult> results = Database.update(recordToUpdate);
        }
    }

    @future
    public static void updateExternalIdFuture(String objectName, String fieldFrom, String fieldTo, List<String> recordIds) {
        List<SObject> records = new List<SObject>();
        List<SObject> recordToUpdate = new List<SObject>(); 

        records = Database.query('SELECT ' + fieldFrom + ', ' + fieldTo + ' FROM ' + objectName + ' WHERE Id IN: recordIds');

        for (Sobject record : records) {
            if (record.get(fieldTo) == null && record.get(fieldFrom) != null){
                Sobject tmp = Schema.getGlobalDescribe().get(objectName).newSObject();
                tmp.Id = record.Id;
                if(!Test.isRunningTest()) {
                    tmp.put(fieldTo,record.get(fieldFrom));
                }
                else {
                    tmp.put(fieldTo, record.get(fieldFrom) + String.valueOf(math.random()));
                }
                recordToUpdate.add(tmp);
            }
        }

        if(!recordToUpdate.isEmpty()) {
            List<Database.SaveResult> results = Database.update(recordToUpdate);
        }
    }

    public static void updateGenericField(String objectName, String newValue, String field, List<SObject> records) {
        List<SObject> recordsToUpdate = new List<SObject>();

        for(SObject record : records) {
            Sobject tmp = Schema.getGlobalDescribe().get(objectName).newSObject();

            tmp.Id = record.Id;
            if(record.get(field) != newValue) {
                tmp.put(field, newValue);

                recordsToUpdate.add(tmp);
            }
        }

        if(!recordsToUpdate.isEmpty()) {
            List<Database.SaveResult> results = Database.update(recordsToUpdate);
        }
    }

    public static void updateGenericFieldNoDML(String objectName, String newValue, String field, List<SObject> records) {
        for(SObject record : records) {
            if(record.get(field) != newValue) {
                record.put(field, newValue);
            }
        }
    }

    public static void setIsPortalSync(List<SObject> records, Map<Id, SObject> oldMap, String objectName, Boolean checkProfile, Boolean performDML) {
        List<SObject> toUpdate = new List<SObject>();
        Boolean profileCheckOk = false;

        if(checkProfile == false) {
            profileCheckOk = true;
        }
        else {
            Profile adminMulesoft = [SELECT Id FROM Profile WHERE Name = 'System_Admin_Mulesoft'];

            if(UserInfo.getProfileId() != adminMulesoft.Id) {
                profileCheckOk = true;
            }
        }

        if(profileCheckOk) {
            List<Pimcore_Field_Mapping__mdt> fieldMappings = [SELECT Object__c, Field__c FROM Pimcore_Field_Mapping__mdt WHERE Object__c =: objectName];

            if(fieldMappings != null && !fieldMappings.isEmpty()) {
                for(SObject record : records) {
                    SObject oldRecord = oldMap.get((String)record.get('Id'));

                    if(oldRecord != null) {
                        for(Pimcore_Field_Mapping__mdt fieldMapping : fieldMappings) {
                            if(oldRecord.get(fieldMapping.Field__c) != record.get(fieldMapping.Field__c)) {
                                toUpdate.add(record);
                                break;
                            }
                        }
                    }
                }

                if(!toUpdate.isEmpty()) {
                    if(performDML) {
                        updateGenericField(objectName, '03', 'Is_Portal_Sync__c', toUpdate);
                    }
                    else {
                        updateGenericFieldNoDML(objectName, '03', 'IS_Portal_Sync__c', toUpdate);
                    }
                }
            }
        }
    }

}