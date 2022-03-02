@isTest
public class TestQuestionChoiceTrigger {
 
    @isTest
    static void testInsertAndUpdateQuestionChoice() {

        Questionnaire__c questionnaire = TestDataFactory.createQuestionnaire();
        insert questionnaire;

        QuestionnaireSection__c questionnaireSection1 = TestDataFactory.initQuestionnaireSection(questionnaire);
        insert questionnaireSection1;

        QuestionnaireSection__c questionnaireSection2 = TestDataFactory.initQuestionnaireSection(questionnaire);
        questionnaireSection2.Order_Number__c = 2; 
        insert questionnaireSection2;

        Question__c testQuestion = TestDataFactory.initQuestion(questionnaire, questionnaireSection1);
        insert testQuestion;
        Question__c testQuestion2 = TestDataFactory.initQuestion(questionnaire, questionnaireSection2);
        insert testQuestion2;

        QuestionChoice__c testQuestionChoice = TestDataFactory.initQuestionChoice(testQuestion, testQuestion2);

        Test.startTest();
        insert testQuestionChoice;

        testQuestionChoice.NextQuestion__c = null;

        update testQuestionChoice;

        Test.stopTest();

    }

    @isTest
    static void testUpdateQuestionChoice() {

        Questionnaire__c questionnaire = TestDataFactory.createQuestionnaire();
        insert questionnaire;

        QuestionnaireSection__c questionnaireSection1 = TestDataFactory.initQuestionnaireSection(questionnaire);
        insert questionnaireSection1;

        QuestionnaireSection__c questionnaireSection2 = TestDataFactory.initQuestionnaireSection(questionnaire);
        questionnaireSection2.Order_Number__c = 2; 
        insert questionnaireSection2;

        Question__c testQuestion = TestDataFactory.initQuestion(questionnaire, questionnaireSection1);
        insert testQuestion;
        Question__c testQuestion2 = TestDataFactory.initQuestion(questionnaire, questionnaireSection2);
        insert testQuestion2;

        QuestionChoice__c testQuestionChoice = TestDataFactory.initQuestionChoice(testQuestion, null);
        insert testQuestionChoice;

        Test.startTest();
        testQuestionChoice.NextQuestion__c = testQuestion2.Id;
        update testQuestionChoice;
        Test.stopTest();

    }
}