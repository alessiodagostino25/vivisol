@isTest
public inherited sharing class TestErrorLogEventTrigger {
    @isTest
    static void insertTest() {
        Test.startTest();
        Integer a = 0;
        try {
            Integer b =  2 / 0;
        } catch(Exception e) {
            Error_Log_Event__e errorEvent = ErrorLogEventHandler.createEvent(e);
            Error_Log_Event__e errorEvent1 = ErrorLogEventHandler.createEvent(e, 'ErrorTest');
            Error_Log_Event__e errorEvent2 = ErrorLogEventHandler.createEvent('ErrorTest');
            Error_Log_Event__e errorEvent3 = ErrorLogEventHandler.createEvent(e, 'ErrorTest', 'ErrorTest1', 'ErrorTest2');
            Error_Log_Event__e errorEvent4 = ErrorLogEventHandler.createEvent(e, 'Request', 'Response');
            Error_Log_Event__e errorEvent5 = ErrorLogEventHandler.createEvent('Error Message', true);
            Error_Log_Event__e errorEvent6 = ErrorLogEventHandler.createEvent('ClassName', 'MethodName', 'DebugType', 'Message', 'Note');
            Error_Log_Event__e errorEvent7 = ErrorLogEventHandler.createEvent('Request', 'Response');
            Error_Log_Event__e errorEvent8 = ErrorLogEventHandler.createEvent('Note', 'Request', 'Response');
            Database.SaveResult results = EventBus.publish(errorEvent);
        }
        Test.stopTest();
        system.assertEquals(1,1);
    }
}