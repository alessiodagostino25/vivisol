@isTest
public class TestQuestionTrigger {

    @isTest
    static void testInsertAndUpdateQuestion() {

        Questionnaire__c questionnaire = TestDataFactory.createQuestionnaire();
        insert questionnaire;

        QuestionnaireSection__c questionnaireSection1 = TestDataFactory.initQuestionnaireSection(questionnaire);
        insert questionnaireSection1;

        QuestionnaireSection__c questionnaireSection2 = TestDataFactory.initQuestionnaireSection(questionnaire);
        questionnaireSection2.Order_Number__c = 2; 
        insert questionnaireSection2;

        Question__c testQuestion = TestDataFactory.initQuestion(questionnaire, questionnaireSection1);

        Test.startTest();
        insert testQuestion;

        testQuestion.QuestionnaireSection__c = questionnaireSection2.Id;
        update testQuestion;

        testQuestion.QuestionnaireSection__c = null;
        update testQuestion;
        Test.stopTest();

    }

}