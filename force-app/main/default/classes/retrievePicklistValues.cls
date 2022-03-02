global class retrievePicklistValues {

    @InvocableMethod(label='Get picklist values and labels' description='Returns the list of picklist values  and labels to the specified object and fieldname.')
    global static List<labelandvalue> getPicklistValues(List<objectandfield> objectandfieldvalues) {

        String objectName = objectandfieldvalues[0].objectapiname;
        String fieldName = objectandfieldvalues[0].fieldapiname ;

        List<labelandvalue> picklistvaluesandlabelslist = new List<labelandvalue>();
        Schema.SObjectType s = Schema.getGlobalDescribe().get(objectName) ;
        Schema.DescribeSObjectResult r = s.getDescribe() ;
        Map<String,Schema.SObjectField> fields = r.fields.getMap() ;
        Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            labelandvalue picklistvaluesandlabels = new labelandvalue();
            picklistvaluesandlabels.label = pickListVal.getLabel(); 
            picklistvaluesandlabels.value = pickListVal.getValue();
            picklistvaluesandlabelslist.add(picklistvaluesandlabels) ;
        }   
        return picklistvaluesandlabelslist ;
    }


    global class objectandfield {
        @InvocableVariable(label='objectapiname for Input' description='yourDescription')
        global String objectapiname;

        @InvocableVariable(label='fieldapiname for Input' description='yourDescription' )
        global String fieldapiname;
    }

    global class labelandvalue {
        @InvocableVariable(label='label and value for Output' description='yourDescription' )
        global String label;
        @InvocableVariable(label='label and value for Output' description='yourDescription' )
        global String value ;
    }
}