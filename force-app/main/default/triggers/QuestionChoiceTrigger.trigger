trigger QuestionChoiceTrigger on QuestionChoice__c (before insert, before update) {

    if (Trigger.isBefore){
        QuestionChoiceTriggerHelper helperBeforeInsert = new QuestionChoiceTriggerHelper(trigger.new);
        for (QuestionChoice__c tmp : trigger.new){
            helperBeforeInsert.setsingleQuestion(tmp);
            helperBeforeInsert.handleQuestionChoiceBeforeCreate();     
        }
        helperBeforeInsert.updateQuestions();
    }

    if(Trigger.isUpdate){ 
        QuestionChoiceTriggerHelper helperBeforeUpdate = new QuestionChoiceTriggerHelper(trigger.new, trigger.oldMap);
        helperBeforeUpdate.handleQuestionChoiceBeforeUpdate();
        helperBeforeUpdate.updateQuestions();
    }

}