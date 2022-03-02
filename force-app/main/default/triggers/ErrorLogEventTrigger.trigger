trigger ErrorLogEventTrigger on Error_Log_Event__e (after insert) {
    List<Error_Log__c> errorList = new List<Error_Log__c>();
    for (Error_Log_Event__e event : Trigger.New) {
        Error_Log__c log = new Error_Log__c();
        log.Error_Message__c = event.Error_Message__c;
        log.User__c = event.User__c;
        log.Date__c = event.Date__c;
        log.Error_Row__c = event.Error_Row__c;
        log.Stack_Trace__c = event.Stack_Trace__c;
        log.Class_Name__c = event.Class_Name__c;
        log.Method_Name__c = event.Method_Name__c;
        log.Log_Typology__c = event.Log_Typology__c;
        log.Exception_Type__c = event.Exception_Type__c;
        log.Note__c = event.Note__c;
        log.Company_Code__c = event.Company_Code__c;
        log.Employee_Code__c = event.Employee_Code__c;
        log.Item_Code__c = event.Item_code__c;
        log.Description__c = event.Description__c;
        log.Amount__c = event.Amount__c;
        log.Object__c = event.Object__c;
        log.Content_Document__c = event.Content_Document__c;

        errorList.add(log);
    }
    
    insert errorList;
}