public without sharing class ErrorLogEventHandler {
    private final static Integer MAXLENGTH = 32768;
    private final static String exceptionLogType = 'Exception';
    private final static String infoLogType = 'Info';

    public static Error_Log_Event__e createEvent(Exception e) {
        return initializeEvent(e, '', '', '', exceptionLogType);
    }

    public static Error_Log_Event__e createEvent(Exception e, String note) {
        return initializeEvent(e, note, '', '', exceptionLogType);
    }

    public static Error_Log_Event__e createEvent(Exception e, String note, String request, String response) {
        return initializeEvent(e, note, request, response, exceptionLogType);
    }

    public static Error_Log_Event__e createEvent(Exception e, String request, String response) {
        return initializeEvent(e, '', request, response, exceptionLogType);
    }

    public static Error_Log_Event__e createEvent(String note) {
        return initializeInfoLogEvent(note, '', '');
    }

    public static Error_Log_Event__e createEvent(String errorMessage, Boolean isError) {
        return initializeLogEventWithBoolean(errorMessage, isError);
    }

    public static Error_Log_Event__e createEvent(String className, String methodName, String debugType, String message, String note) {
        return initializeDebuggerEvent(className, methodName, debugType, message, note);
    }

    public static Error_Log_Event__e createEvent(String request, String response) {
        return initializeInfoLogEvent('', request, response);
    }

    public static Error_Log_Event__e createEvent(String note, String request, String response) {
        return initializeInfoLogEvent(note, request, response);
    }

    public static Error_Log_Event__e createPayrollHeaderEvent(String companyCode, String employeeCode, String errorMessage, String contentDocumentId) {
        return initializePayrollHeaderEvent(companyCode, employeeCode, errorMessage, contentDocumentId);
    }

    public static Error_Log_Event__e createPayrollItemEvent(Payroll_Item__c payrollItem, Payroll_Header__c relatedPayrollHeader,
    Map<Payroll_Header__c, String> employeeCodeMap, String errorMessage, String contentDocumentId) {
        return initializePayrollItemEvent(payrollItem, relatedPayrollHeader, employeeCodeMap, errorMessage, contentDocumentId);
    }

    public static Error_Log_Event__e createEmployeeEvent(String companyCode, String employeeCode, String errorMessage, String contentDocumentId) {
        return initializeEmployeeEvent(companyCode, employeeCode, errorMessage, contentDocumentId);
    }

    /*
    public static Error_Log_Event__e createEvent(List<Object> databaseResults){
        List<String> databaseErrors = new List<String>();
        List<DatabaseGenericResult> results = DatabaseGenericResult.resultsToGenericResults(databaseResults);

        for(DatabaseGenericResult res: results) {
            if(!res.isSuccess()) {
                databaseErrors.add(String.valueOf(res.getErrors()));
            }
        }

        if(!databaseErrors.isEmpty()) {
            return initializeInfoLogEvent(String.valueOf(databaseErrors),'','');
        } else {
            return null;
        }
    }*/

    private static Error_Log_Event__e initializeInfoLogEvent(String note, String request, String response) {
        try {//exception type doesn't really matter, we just need a stack trace
            throw new MathException(note);
        } catch (Exception e) {
            return initializeInfoEvent(e, note, infoLogType);
        }
    }

    //prendiamo un booleano per decidere che tipo di log mostrare
    private static Error_Log_Event__e initializeLogEventWithBoolean(String message, Boolean isError) {
        try {//exception type doesn't really matter, we just need a stack trace
            if (isError == true) {
                throw new DmlException(message);
            } else {
                throw new DmlException('Info Event');
            }
        } catch (Exception e) {
            if (isError == true) {
                return initializeInfoEvent(e, 'Error Event', exceptionLogType);
            } else {
                return initializeInfoEvent(e, message, infoLogType);
            }
        }
    }

    //initializes all the record fields
    private static Error_Log_Event__e initializeEvent(Exception e, String note, String request, String response, String logType) {
        String className;
        String methodName;

        List<String> namingInfo = extractNamingInfo(e);
        className = namingInfo.get(0);
        methodName = namingInfo.get(1);

        Error_Log_Event__e eventLog = new Error_Log_Event__e(User__c = UserInfo.getUserId(),
                Date__c = System.now(),
                Error_Message__c = e.getMessage(),
                Exception_Type__c = logType == exceptionLogType ? e.getTypeName() : null,
                Error_Row__c = String.valueOf(e.getLineNumber()),
                Stack_Trace__c = e.getStackTraceString(),
                Class_Name__c = className,
                Method_Name__c = methodName,
                Log_Typology__c = LogType,
                Note__c = note.abbreviate(MAXLENGTH));

        System.Debug('Inserito evento: ' + eventLog);
        return eventLog;
    }

    //initializes all the record fields
    private static Error_Log_Event__e initializeInfoEvent(Exception e, String note, String logType) {
        String className;
        String methodName;

        List<String> namingInfo = extractNamingInfo(e);
        className = namingInfo.get(0);
        methodName = namingInfo.get(1);

        Error_Log_Event__e eventLog = new Error_Log_Event__e(User__c = UserInfo.getUserId(),
                Date__c = System.now(),
                Error_Message__c = e.getMessage(),
                Exception_Type__c = logType,
                Stack_Trace__c = e.getStackTraceString(),
                Class_Name__c = className,
                Method_Name__c = methodName,
                Log_Typology__c = LogType,
                Note__c = note.abbreviate(MAXLENGTH));

        System.debug('STACK TRACE: ' + e.getStackTraceString());
        System.debug('NAMING INFO: ' + namingInfo);
        System.Debug('Inserito evento: ' + eventLog);
        return eventLog;
    }

    //initializes all the record fields
    private static Error_Log_Event__e initializeDebuggerEvent(String className, String methodName, String debugType, String message, String note) {

        Error_Log_Event__e eventLog = new Error_Log_Event__e(User__c = UserInfo.getUserId(),
                Date__c = System.now(),
                Error_Message__c = message,
                Exception_Type__c = debugType,
                Stack_Trace__c = 'Empty',
                Class_Name__c = className,
                Method_Name__c = methodName,
                Log_Typology__c = infoLogType,
                Note__c = note);

        System.Debug('Inserito evento: ' + eventLog);
        return eventLog;
    }

    //returns a List of Strings where the first one is the className and the second one is the methodName
    private static List<String> extractNamingInfo(Exception e) {
        String mainLine;

        List<String> traces = e.getStackTraceString().split('\n');
        System.debug('STACK TRACE: ' + e.getStackTraceString());
        for (String trace : traces) {
            if (!trace.contains('Class.ErrorLogEventHandler.')) {
                //first trace not containing 'Class.LogHandler.' string is the original class/method we are interested in
                mainLine = trace;
                break;
            }
        }
        System.debug(mainLine);

        List<String> namingInfo = mainLine.left(mainLine.indexOf(':')).split('\\.');
        if (namingInfo.size() > 1) {
            //classica stringa di stackTrace Class.nomeClasse.nomeMetodo
            namingInfo.remove(0); //remove 'Class' string;
        } else {
            /* stackTrace strano, metto questo pezzo per evitare che il codice si spacchi se mai si dovesse ottenere uno stackTrace del genere.
             * Se qualcuno riesce a ottenere un caso del genere me lo faccia sapere (per ora sono riuscito ad ottenerlo solo tramite
             * codice eseguito come anonymous block, che però è un caso particolare e out of scope per l' utilizzo dell' oggetto Log__c)
             */
            return new List<String>(2);
        }
        return namingInfo;
    }

    private static Error_Log_Event__e initializePayrollHeaderEvent(String companyCode, String employeeCode, String errorMessage, String contentDocumentId) {
        Error_Log_Event__e eventLog = new Error_Log_Event__e(
            User__c = UserInfo.getUserId(),
            Date__c = System.now(),
            Error_Message__c = errorMessage,
            Exception_Type__c = 'ERROR',
            Stack_Trace__c = 'Empty',
            Class_Name__c = 'ConvertCSVToRecords',
            Method_Name__c = 'convert',
            Log_Typology__c = 'Info',
            Company_Code__c = companyCode,
            Employee_Code__c = employeeCode,
            Object__c = 'Payroll_Header__c',
            Content_Document__c = contentDocumentId
        );

        System.Debug('Inserito evento: ' + eventLog);
        return eventLog;
    }

    private static Error_Log_Event__e initializePayrollItemEvent(Payroll_Item__c payrollItem, Payroll_Header__c relatedPayrollHeader,
    Map<Payroll_Header__c, String> employeeCodeMap, String errorMessage, String contentDocumentId) {
        Error_Log_Event__e eventLog = new Error_Log_Event__e(
            User__c = UserInfo.getUserId(),
            Date__c = System.now(),
            Error_Message__c = errorMessage,
            Exception_Type__c = 'ERROR',
            Stack_Trace__c = 'Empty',
            Class_Name__c = 'ConvertCSVToRecords',
            Method_Name__c = 'convert',
            Log_Typology__c = 'Info',
            Item_Code__c = payrollItem.Item_Code__c,
            Description__c = payrollItem.Description__c,
            Amount__c = String.valueOf(payrollItem.Amount__c),
            Object__c = 'Payroll_Item__c',
            Content_Document__c = contentDocumentId
        );

        if(relatedPayrollHeader != null) {
            eventLog.Company_Code__c = relatedPayrollHeader.Company_Code__c;

            if(employeeCodeMap != null) {
                eventLog.Employee_Code__c = employeeCodeMap.get(relatedPayrollHeader);
            }
        }

        System.Debug('Inserito evento: ' + eventLog);
        return eventLog;
    }

    private static Error_Log_Event__e initializeEmployeeEvent(String companyCode, String employeeCode, String errorMessage, String contentDocumentId) {
        Error_Log_Event__e eventLog = new Error_Log_Event__e(
            User__c = UserInfo.getUserId(),
            Date__c = System.now(),
            Error_Message__c = errorMessage,
            Exception_Type__c = 'ERROR',
            Stack_Trace__c = 'Empty',
            Class_Name__c = 'ConvertCSVToRecords',
            Method_Name__c = 'convert',
            Log_Typology__c = 'Info',
            Company_Code__c = companyCode,
            Employee_Code__c = employeeCode,
            Object__c = 'Employee__c',
            Content_Document__c = contentDocumentId
        );

        System.Debug('Inserito evento: ' + eventLog);
        return eventLog;
    }
}