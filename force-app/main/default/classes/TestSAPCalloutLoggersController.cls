@IsTest
public class TestSAPCalloutLoggersController {

    @isTest
    static void testGetCalloutLoggersAccount(){
        Account a = TestDataFactory.createPersonAccountWithExternalId('CALLOUT_1');
        insert a;

        Account_Company__c accCompany = TestDataFactory.createAccountCompany();
        insert accCompany;
        Account_Sales_Organization__c aso = TestDataFactory.getAso(a.Id);
        insert aso;

        Callout_Logger__c logger = TestDataFactory.initCalloutLogger();
        logger.Related_Account__c = a.id;
        insert logger;

        Callout_Logger__c asoLogger = TestDataFactory.initCalloutLogger();
        asoLogger.Related_Account_Sales_Organization__c = aso.id;
        insert asoLogger;

        Callout_Logger__c companyLogger = TestDataFactory.initCalloutLogger();
        companyLogger.Related_Account_Company__c = accCompany.id;
        insert companyLogger;

        List<CalloutLoggerDTO> accountResponse = new List<CalloutLoggerDTO>();
        List<CalloutLoggerDTO> accountCompanyResponse = new List<CalloutLoggerDTO>();
        List<CalloutLoggerDTO> asoResponse = new List<CalloutLoggerDTO>();
        
        Test.startTest();

        accountResponse = SAPCalloutLoggersController.getCalloutLoggers(a.id, 'Account', null);
        accountCompanyResponse = SAPCalloutLoggersController.getCalloutLoggers(accCompany.id, 'Account_Company__c', null);
        asoResponse = SAPCalloutLoggersController.getCalloutLoggers(aso.id, 'Account_Sales_Organization__c', null);

        Test.stopTest();

        System.assert(accountResponse.size() != 0);
        System.assert(accountCompanyResponse.size() != 0);
        System.assert(asoResponse.size() != 0);
    }

}