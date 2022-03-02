trigger CaseTrigger on Case (before insert, after insert, before update, after update) {

    List<String> accountIds = new List<String>();
    List<Id> caseUpdateList = new List<Id>();
  


    for (Case c : Trigger.new ) {
        if(c.AccountId != null){
            accountIds.add(c.AccountId);
        }
    }

    Map<ID, Account> accountMap = new Map<ID, Account>([SELECT Id, isPersonAccount,RecordTypeId, PersonContactId FROM Account where Id IN: accountIds]);

    if (trigger.isBefore){
        for (Case c : Trigger.new ) {
            if (c.AccountId != null){
                CaseTriggerHelper helper = new CaseTriggerHelper(c, accountMap.get(c.AccountId));
                c = helper.handleAccountAndPatientField();
            }
        }
    }

    if(Trigger.isInsert && Trigger.isBefore) {
        List<Case> toUpdateTreatmentAndCT = new List<Case>();

        for(Case c : Trigger.new) {
            if(c.Account_Treatment__c != null && c.Autoscheduled__c == false) {
                toUpdateTreatmentAndCT.add(c);
            }
        }

        // Filling Treatment__c and Contract_Treatment__c

        if(!toUpdateTreatmentAndCT.isEmpty()) {
            CaseHelper.updateTreatmentAndCT(toUpdateTreatmentAndCT);
        }
    }

    if(Trigger.isInsert && Trigger.isAfter) {
        // Filling External_Id__c

        CaseHelper.setExternalId(Trigger.new);
    }

    if(Trigger.isUpdate && Trigger.isBefore) {
        List<Case> toUpdateTreatmentAndCT = new List<Case>();
        List<Case> toCheckForClosure = new List<Case>();

        for(Case c : Trigger.new) {
            Case oldRecord = Trigger.oldMap.get(c.Id);

            if(c.Account_Treatment__c != null && c.Autoscheduled__c == false && oldRecord.Account_Treatment__c != c.Account_Treatment__c) {
                toUpdateTreatmentAndCT.add(c);
            }

            if(c.Status == 'Closed' && oldRecord.Status != 'Closed') {
                toCheckForClosure.add(c);
            }
        }

        // Filling Treatment__c and Contract_Treatment__c

        if(!toUpdateTreatmentAndCT.isEmpty()) {
            CaseHelper.updateTreatmentAndCT(toUpdateTreatmentAndCT);
        }

        // Checking if the Case can be closed. Otherwise, throwing an exception (open activities)

        if(!toCheckForClosure.isEmpty()) {
            CaseHelper.checkForClosure(toCheckForClosure);
        }
    }

    if(Trigger.isUpdate && Trigger.isAfter){
        for (Case c : Trigger.new ) {
            if ((c.Status != trigger.oldMap.get(c.Id).Status || c.Type != trigger.oldMap.get(c.Id).Type ||c.Treatment__c != trigger.oldMap.get(c.Id).Treatment__c ||c.Subtype__c != trigger.oldMap.get(c.Id).Subtype__c) && c.Status != 'Working' && c.Status != 'Closed' && c.Status != 'Canceled'){
                caseUpdateList.add(c.Id) ;   
            }
        }
        if(!caseUpdateList.isEmpty()){
            CaseHelper.setDmlOptions(caseUpdateList);
        }
    }
}