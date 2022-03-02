trigger QuestionTrigger on Question__c (before insert, before update) {

    QuestionTriggerHelper helper = new QuestionTriggerHelper(Trigger.new);

    if (Trigger.isInsert){
        for (Question__c q : Trigger.new ) {
            q = helper.handleSectionOnQuestion(q, true);
        }
    }

    if (Trigger.isUpdate){
        for (Question__c q : Trigger.new ) {
            q = helper.handleSectionOnQuestion(q, false);
        }
    }

}