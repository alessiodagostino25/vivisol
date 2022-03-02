public class QuestionChoiceTriggerHelper {

    public List<QuestionChoice__c> questionChoiceBefore;
    private QuestionChoice__c singleQuestionChoice;
    private Map<String,Decimal> questionOrderNumberMap = new Map<String,Decimal>();
    private List<String> questionIds = new List<String>();
    private List<Question__c> questionsToUpdate = new List<Question__c>();
    private Map<Id, QuestionChoice__c> oldQuestionChoiceMap = new Map<Id, QuestionChoice__c>();

    public QuestionChoiceTriggerHelper(List<QuestionChoice__c> inputQuestionChoice) {
        this.questionChoiceBefore = inputQuestionChoice;
        for (QuestionChoice__c tmp : inputQuestionChoice){
            questionIds.add(tmp.Question__c);
        }
        this.queryForQuestionnaireSection();
    }

    public QuestionChoiceTriggerHelper(List<QuestionChoice__c> inputQuestionChoice, Map<Id, QuestionChoice__c> oldQuestions) {
        this.questionChoiceBefore = inputQuestionChoice;
        this.oldQuestionChoiceMap = oldQuestions;
        for (QuestionChoice__c tmp : inputQuestionChoice){
            questionIds.add(tmp.Question__c);
        }
        this.queryForQuestionnaireSection();
    }

    private void queryForQuestionnaireSection(){
        List<String> questionFields = new List<String>{'OrderNumber__c'};
        List<Question__c> queriedSections = QuestionDAO.getQuestionsByIds(questionFields, this.questionIds);
        for(Question__c tmp: queriedSections){
            this.questionOrderNumberMap.put(tmp.Id, tmp.OrderNumber__c);
        }
    }

    public void setsingleQuestion (QuestionChoice__c inputChoice){
        this.singleQuestionChoice = inputChoice;
    }

    public void handleQuestionChoiceBeforeCreate (){
        if (this.singleQuestionChoice.NextQuestion__c != null){
            Question__c tmp = new Question__c();
            tmp.id = singleQuestionChoice.NextQuestion__c;
            tmp.DependentAnswer__c = this.singleQuestionChoice.Question__c;
            Decimal tmpOrderNumner = questionOrderNumberMap.get(this.singleQuestionChoice.Question__c);
            if (tmpOrderNumner != null){
                tmp.OrderNumber__c = tmpOrderNumner + 0.1;
            } 
            this.questionsToUpdate.add(tmp);
        }
    }

    public void handleQuestionChoiceBeforeUpdate (){
        for (QuestionChoice__c tmpQuestionChoice : questionChoiceBefore){
            QuestionChoice__c oldQuestionChoice = oldQuestionChoiceMap.get(tmpQuestionChoice.Id);
            if (tmpQuestionChoice.NextQuestion__c != oldQuestionChoice.NextQuestion__c){
                if (tmpQuestionChoice.NextQuestion__c != null){
                    Question__c tmp = new Question__c();
                    tmp.id = tmpQuestionChoice.NextQuestion__c;
                    tmp.DependentAnswer__c = tmpQuestionChoice.Question__c;
                    Decimal tmpOrderNumner = questionOrderNumberMap.get(tmpQuestionChoice.Question__c);
                    if (tmpOrderNumner != null){
                        tmp.OrderNumber__c = tmpOrderNumner + 0.1;
                    } 
                    this.questionsToUpdate.add(tmp);
                }
                if (oldQuestionChoice.NextQuestion__c != null) {
                    Question__c tmp = new Question__c();
                    tmp.id = oldQuestionChoice.NextQuestion__c;
                    tmp.DependentAnswer__c = null;
                    tmp.OrderNumber__c = null;
                    this.questionsToUpdate.add(tmp);
                }
            } 
        }
    }

    public void updateQuestions (){
        update this.questionsToUpdate;
    }
}