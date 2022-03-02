public class QuestionTriggerHelper {

    private List<Question__c> questionBeforeTrigger = new List<Question__c>();
    private List<String> questionnaireSectionsId = new List<String>();
    private Map<String,Decimal> sectionOrderNumberMap = new Map<String,Decimal>();

    public QuestionTriggerHelper(List<Question__c> inputQuestions) {
        this.questionBeforeTrigger = inputQuestions;
        for (Question__c tmp : inputQuestions){
            this.questionnaireSectionsId.add(tmp.QuestionnaireSection__c);
        }
        this.queryForQuestionnaireSection();
    }

    private void queryForQuestionnaireSection(){
        List<String> CTQueryFields = new List<String>{'Order_Number__c'};
        List<QuestionnaireSection__c> queriedSections = QuestionnaireSectionDAO.getQuestionnaireSectionsByIds(CTQueryFields, questionnaireSectionsId);
        for(QuestionnaireSection__c tmp: queriedSections){
            this.sectionOrderNumberMap.put(tmp.Id, tmp.Order_Number__c);
        }
    }

    public Question__c handleSectionOnQuestion(Question__c inputQuestion, Boolean isInsert){
        if (isInsert){
            Decimal tmpOrderNumber = sectionOrderNumberMap.get(inputQuestion.QuestionnaireSection__c);
            if (tmpOrderNumber!=null){
                inputQuestion.Section_Picklist__c = String.valueOf(tmpOrderNumber);
            }
        } else{
            Decimal tmpOrderNumber = sectionOrderNumberMap.get(inputQuestion.QuestionnaireSection__c);
            if (tmpOrderNumber!=null){
                inputQuestion.Section_Picklist__c = String.valueOf(tmpOrderNumber);
            } else {
                inputQuestion.Section_Picklist__c = null;
            }
        }
        return inputQuestion;
    }

}