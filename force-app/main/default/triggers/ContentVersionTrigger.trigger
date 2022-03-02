trigger ContentVersionTrigger on ContentVersion (after insert) {
    if(Trigger.isInsert && Trigger.isAfter) {
        List<ContentVersion> notChatterFiles = new List<ContentVersion>();

        for(ContentVersion cv : Trigger.new) {
            if(cv.Origin != 'H') {
                notChatterFiles.add(cv);
            }
        }

        if(!notChatterFiles.isEmpty()) {
            SObjectServiceClass.updateExternalId('ContentVersion', 'Content_Version_Number__c', 'External_Id__c', notChatterFiles);
        }
    }
}