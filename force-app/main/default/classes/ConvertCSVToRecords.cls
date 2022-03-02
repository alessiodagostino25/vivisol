public without sharing class ConvertCSVToRecords {
    public class CSVParsingException extends Exception {}

    public static Integer employeeCodeIndex;
    public static Integer firstNameIndex;
    public static Integer lastNameIndex;
    public static Integer hiringDateIndex;
    public static Integer exitDateIndex;
    public static Integer FTEWeightIndex;
    public static String contentDocument;
    public static Map<String, List<String>> employeeToRowsMap = new Map<String, List<String>>();
    public static final Schema.SObjectField EMPLOYEE_EXTERNAL_ID = Employee__c.Fields.Employee_Code__c;
    public static final Schema.SObjectField PAYROLL_HEADER_EXTERNAL_ID = Payroll_Header__c.Fields.External_Id__c;
    public static final Schema.SObjectField PAYROLL_ITEM_EXTERNAL_ID = Payroll_Item__c.Fields.External_Id__c;
    public static List<Error_Log_Event__e> errorLogEvents = new List<Error_Log_Event__e>();

    static Blob getCsvContent( String contentDocumentId) {        
        ContentVersion csvFile = [SELECT 
                                    VersionData 
                                    FROM ContentVersion 
                                    WHERE ContentDocumentId = :contentDocumentId 
                                    AND IsLatest = true
                                ];
        System.debug('contentDocumentId is: ' + contentDocumentId);
        System.debug('csvFile is: ' + csvFile);
        return csvFile.VersionData;
    }

    /* Converting the CSV file input(BLOB format) to a string */
    static String blobToString(Blob input, String inCharset){
        String hex = EncodingUtil.convertToHex(input);
        System.assertEquals(0, hex.length() & 1);
        final Integer bytesCount = hex.length() >> 1;
        String[] bytes = new String[bytesCount];
        for(Integer i = 0; i < bytesCount; ++i)
            bytes[i] =  hex.mid(i << 1, 2);
        return EncodingUtil.urlDecode('%' + String.join(bytes, '%'), inCharset);
    } 

    static Object getConvertedFieldValue(Schema.DisplayType fieldType, String fieldValue){
        System.debug('getConvertedFieldValue input fieldValue: ' + fieldValue);
        Object convertedFieldValue;

        switch on fieldType {//Setting Field value based on the field data type
            when BOOLEAN {
                convertedfieldValue = String.isEmpty(fieldValue) ? false : Boolean.valueOf(fieldValue);
            }
            when DOUBLE {
                convertedfieldValue = String.isEmpty(fieldValue) ? null : Decimal.valueOf(fieldValue);
            }
            when CURRENCY {
                String noCommas = fieldValue.deleteWhitespace().replace(',', '.');
                String onlyOneDot;
                Integer dotCountMatches = noCommas.countMatches('.');

                System.debug('noCommas: ' + noCommas);
                System.debug('dotCountMatches: ' + dotCountMatches);

                if(dotCountMatches > 1) {
                    System.debug('Replacing dot');
                    onlyOneDot = noCommas.replaceFirst('\\.', '');
                    System.debug('onlyOneDot: ' + onlyOneDot);
                }

                if(onlyOneDot != null) {
                    convertedfieldValue = String.isEmpty(fieldValue) ? null : Decimal.valueOf(onlyOneDot.deleteWhitespace().replace('$',''));
                }
                else {
                    convertedfieldValue = String.isEmpty(fieldValue) ? null : Decimal.valueOf(noCommas.deleteWhitespace().replace('$',''));
                }

                System.debug('convertedFieldValue: ' + convertedFieldValue);
            }
            when INTEGER {
                convertedfieldValue = String.isEmpty(fieldValue) ? null : Integer.valueOf(fieldValue);
            }
            when DATE {
                convertedfieldValue = String.isEmpty(fieldValue) ? null : Date.parse(fieldValue);
            }
            when PERCENT {
                Integer dotCountMatches = fieldValue.countMatches(',');

                if(dotCountMatches >= 1) {
                    String replacedComma = fieldValue.replaceFirst(',', '.');
                    convertedfieldValue = String.isEmpty(replacedComma) ? null : Decimal.valueOf(replacedComma);
                }
                else {
                    convertedfieldValue = String.isEmpty(fieldValue) ? null : Decimal.valueOf(fieldValue);
                }
            }
            when else { 
                convertedfieldValue = fieldValue;
            }
        }

        return convertedFieldValue;
    }

    public class FlowCustomException extends Exception{}

    @TestVisible
    static Schema.DisplayType getFieldType(map<String, SObjectField> fieldMap, String fieldApiName) {
        if(fieldMap.get(fieldApiName) == null) {
            throw new FlowCustomException('Invalid Field Error: '+ fieldApiName + '. Please double check the API name of the field.');
        }           
        return fieldMap.get(fieldApiName).getDescribe().getType();
    }

    static List<Employee__c> createEmployees(List<String> employeeCodes, Company__c company) {
        List<Employee__c> toCreate = new List<Employee__c>();

        for(String employeeCode : employeeCodes) {
            List<String> relatedRows = employeeToRowsMap.get(employeeCode);

            if(relatedRows != null) {
                String firstRow = relatedRows[0];
                
                if(firstRow != null) {
                    List<String> relatedFields = firstRow.split(';');

                    if(relatedFields != null && !relatedFields.isEmpty()) {
                        String firstName;
                        String lastName;
                        String name;
                        Date hiringDate;
                        Date exitDate;
                        String companyId;

                        if(firstNameIndex != null && firstNameIndex != -1) {
                            firstName = relatedFields[firstNameIndex];
                        }
                        if(lastNameIndex != null && lastNameIndex != -1) {
                            lastName = relatedFields[lastNameIndex];
                        }
                        if(firstName != null && lastName != null) {
                            name = firstName + ' ' + lastName;
                        }
                        
                        try {
                            if(hiringDateIndex != null && hiringDateIndex != -1) {
                                if(relatedFields[hiringDateIndex] != null) {
                                    hiringDate = (Date) getConvertedFieldValue(Schema.DisplayType.DATE, relatedFields[hiringDateIndex]);
                                }
                            }
                            if(exitDateIndex != null && exitDateIndex != -1) {
                                if(relatedFields[exitDateIndex] != null) {
                                    exitDate = (Date) getConvertedFieldValue(Schema.DisplayType.DATE, relatedFields[exitDateIndex]);
                                }
                            }
                        }
                        catch(TypeException e) {
                            Error_Log_Event__e event = ErrorLogEventHandler.createEmployeeEvent(
                                company.Company_Code__c,
                                employeeCode,
                                e.getMessage(),
                                contentDocument
                            );
                            errorLogEvents.add(event);
                        }

                        if(company != null && company.Id != null) {
                            companyId = company.Id;
                        }

                        Employee__c newEmployee = new Employee__c(
                            Employee_Code__c = employeeCode,
                            First_Name__c = firstName,
                            Last_Name__c = lastName,
                            Name = name,
                            Hiring_Date__c = hiringDate,
                            Exit_Date__c = exitDate,
                            Company__c = companyId
                        );

                        toCreate.add(newEmployee);
                        System.debug('newEmployee created: ' + newEmployee);
                    }
                }
            }
        }

        return toCreate;
    }

    /**
     * TODO Redirect da notifica fine batch a report per successI/errori
     */

    public static List<Error_Log_Event__e> convert(String contentDocumentId, Integer month, String year, String companyId) {
        System.debug('----- convert -----');

        System.debug('companyId: ' + companyId);

        List<Payroll_Header__c> payrollHeadersToInsert = new List<Payroll_Header__c>();
        List<String> notMatchedEmployeeCodes = new List<String>();
        List<Payroll_Item__c> payrollItemsToInsert = new List<Payroll_Item__c>();
        List<Employee__c> employees = new List<Employee__c>();
        List<Employee__c> employeesToUpdate = new List<Employee__c>();
        List<Employee__c> employeesToInsert = new List<Employee__c>();
        Company__c company = new Company__c();

        List<Company__c> companyList = [SELECT Id, Company_Code__c FROM Company__c WHERE Id =: companyId LIMIT 1];

        if(companyList != null && !companyList.isEmpty()) {
            company = companyList[0];
        }

        System.debug('company: ' + company);

        contentDocument = contentDocumentId;
        String stringMonth = String.valueOf(month);

        SObjectType headerSObjType = ((SObject)Type.forName('Payroll_Header__c').newInstance()).getSObjectType();         
        map<String,SObjectField> headerFieldMap = headerSObjType.getDescribe().fields.getMap();

        SObjectType itemSObjType = ((SObject)Type.forName('Payroll_Item__c').newInstance()).getSObjectType();         
        map<String,SObjectField> itemFieldMap = itemSObjType.getDescribe().fields.getMap();

        SObjectType employeeSObjType = ((SObject)Type.forName('Employee__c').newInstance()).getSObjectType();         
        map<String,SObjectField> employeeFieldMap = employeeSObjType.getDescribe().fields.getMap();

        Blob csvBlobContent = getCsvContent(contentDocumentId);
        String csvStringContent = blobToString(csvBlobContent, 'ISO-8859-1');
        csvStringContent = csvStringContent.replaceAll('(\r\n|\r)','\n');

        String[] csvRows = csvStringContent.split('\n');
        String[] fields = csvRows[0].split(';'); //Gives all the API names of the fields from the 1st CSV row 
        csvRows.remove(0);

        System.debug('Fields: ' + fields);

        map<String,Schema.DisplayType> fieldToFieldTypeMap = new map<String,Schema.DisplayType>();
        map<String,String> headerFieldNameMap = new map<String,String>();
        map<String,String> itemFieldNameMap = new map<String,String>();
        Map<String, String> employeeFieldNameMap = new Map<String, String>();
        Map<String, Payroll_Header__c> payrollHeaderMap = new Map<String, Payroll_Header__c>();
        Map<Payroll_Header__c, String> employeeCodeMap = new Map<Payroll_Header__c, String>();
        Map<Payroll_Item__c, Payroll_Header__c> itemToHeaderMap = new Map<Payroll_Item__c, Payroll_Header__c>();
        Map<String, Employee__c> employeeMap = new Map<String, Employee__c>();
        Map<Integer, String> indexToColumnNameMap = new Map<Integer, String>();
        Map<String, List<String>> columnToRelatedFieldsMap = new Map<String, List<String>>();
        Map<String, Payroll_Item__c> payrollItemMap = new Map<String, Payroll_Item__c>();

        for (String field : fields) {
            String fieldApiName = field;
            Integer index = fields.indexOf(field);

            switch on field {
                when 'Employee Code' {
                    employeeCodeIndex = index;
                }
                when 'First Name' {
                    firstNameIndex = index;
                }
                when 'Last Name' {
                    lastNameIndex = index;
                }
                when 'Hiring Date' {
                    hiringDateIndex = index;
                }
                when 'Exit Date' {
                    exitDateIndex = index;
                }
                when 'FTE weight' {
                    FTEWeightIndex = index;
                }
            }

            if(headerFieldMap.get(fieldApiName) == null && itemFieldMap.get(fieldApiName) == null && employeeFieldMap.get(fieldApiName) == null) {
                fieldApiName = fieldApiName.replaceAll(' ', '_').replaceAll('[^a-zA-Z0-9_]', '');   // Convert to alphanumeric and underscore
                fieldApiName = fieldApiName.replaceAll('__', '_') + '__c';                            // Remove extra _s and add __c to end  
            }   

            indexToColumnNameMap.put(index, fieldApiName);

            System.debug('field: ' + field);
            System.debug('fieldApiName: ' + fieldApiName);
            
            if(headerFieldMap.get(fieldApiName) != null) {
                System.debug('Header field!');
                fieldToFieldTypeMap.put(fieldApiName, getFieldType(headerFieldMap, fieldApiName));
                headerFieldNameMap.put(field, fieldApiName);
            }
            else if(itemFieldMap.get(fieldApiName) != null) {
                System.debug('Item field!');
                fieldToFieldTypeMap.put(fieldApiName, getFieldType(itemFieldMap, fieldApiName));
                itemFieldNameMap.put(field, fieldApiName);
            }
            else if(employeeFieldMap.get(fieldApiName) != null) {
                System.debug('Employee field!');
                fieldToFieldTypeMap.put(fieldApiName, getFieldType(employeeFieldMap, fieldApiName));
                employeeFieldNameMap.put(field, fieldApiName);
            }
            else {
                throw new CSVParsingException();
            }
        }

        System.debug('fieldToFieldTypeMap: ' + fieldToFieldTypeMap);
        System.debug('headerFieldNameMap: ' + headerFieldNameMap);
        System.debug('itemFieldNameMap: ' + itemFieldNameMap);
        System.debug('employeeFieldNameMap: ' + employeeFieldNameMap);
        System.debug('FTEWeightIndex: ' + FTEWeightIndex);

        for(String csvRow : csvRows) {
            System.debug('Splitted csvRow: ' + csvRow.split(';'));
            if((csvRow.split(';')).size() > employeeCodeIndex) {
                String employeeCode = csvRow.split(';')[employeeCodeIndex];

                if(employeeCode != null) {
                    if(employeeToRowsMap.get(employeeCode) == null) {
                        employeeToRowsMap.put(employeeCode, new List<String>());
                    }
                    employeeToRowsMap.get(employeeCode).add(csvRow);
                }
            }
        }

        System.debug('employeeToRowsMap: ' + employeeToRowsMap);
        System.debug('employeeCodeIndex: ' + employeeCodeIndex);

        // Getting all the Employees from employeeCode

        if(!employeeToRowsMap.isEmpty()) {
            employees = [SELECT Employee_Code__c, First_Name__c, Last_Name__c, Hiring_Date__c, Exit_Date__c, Company__c 
                        FROM Employee__c WHERE Employee_Code__c IN: employeeToRowsMap.keySet()];
        }

        if(!employees.isEmpty()) {
            for(Employee__c e : employees) {
                employeeMap.put(e.Employee_Code__c, e);
            }
        }

        System.debug('--- Creating Payroll Headers... ---');

        for(String employeeCode : employeeToRowsMap.keySet()) {
            List<String> relatedRows = employeeToRowsMap.get(employeeCode);
            if(relatedRows != null) {
                String firstRow = relatedRows[0];
                System.debug('firstRow: ' + firstRow);
                
                if(firstRow != null) {
                    List<String> relatedFields = firstRow.split(';');
                    System.debug('relatedFields in firstRow: ' + relatedFields);

                    if(relatedFields != null && !relatedFields.isEmpty() && employeeCodeIndex != null && employeeCodeIndex != -1) {
                        Employee__c relatedEmployee = employeeMap.get(relatedFields[employeeCodeIndex]);
                        Employee__c tmpEmployee = new Employee__c(Employee_Code__c = relatedFields[employeeCodeIndex]);
                        
                        Payroll_Header__c payrollHeader = new Payroll_Header__c(
                            Company__c = company.Id,
                            Company_Code__c = company.Company_Code__c,
                            Employee__r = tmpEmployee,
                            Month__c = stringMonth,
                            Year__c = year,
                            External_Id__c = relatedFields[employeeCodeIndex] + stringMonth + String.valueOf(year)
                        );

                        if(relatedFields.size() > FTEWeightIndex && relatedFields[FTEWeightIndex] != null && relatedFields[FTEWeightIndex] != '') {
                            payrollHeader.FTE_weight__c = (Decimal) getConvertedFieldValue(Schema.DisplayType.PERCENT, relatedFields[FTEWeightIndex]);
                        }

                        System.debug('----- New PayrollHeader created: ');
                        System.debug(payrollHeader);
                        System.debug('New PayrollHeader Employee: ');
                        System.debug(tmpEmployee);

                        payrollHeaderMap.put(relatedFields[employeeCodeIndex], payrollHeader);
                        employeeCodeMap.put(payrollHeader, relatedFields[employeeCodeIndex]);
                        payrollHeadersToInsert.add(payrollHeader);

                        if(relatedEmployee != null) {
                            if(exitDateIndex != null && exitDateIndex != -1) {
                                if(relatedFields[exitDateIndex] != null) {
                                    try {
                                        Date exitDate = (Date) getConvertedFieldValue(Schema.DisplayType.DATE, relatedFields[exitDateIndex]);

                                        if(exitDate != null && exitDate != relatedEmployee.Exit_Date__c) {
                                            relatedEmployee.Exit_Date__c = exitDate;
                                            employeesToUpdate.add(relatedEmployee);
                                        }
                                    }
                                    catch(TypeException e) {
                                        Error_Log_Event__e event = ErrorLogEventHandler.createEmployeeEvent(
                                            company.Company_Code__c,
                                            relatedFields[employeeCodeIndex],
                                            e.getMessage(),
                                            contentDocumentId
                                        );
                                        errorLogEvents.add(event);
                                    }
                                }
                            }
                        }
                        else {
                            if(!notMatchedEmployeeCodes.contains(relatedFields[employeeCodeIndex])) {
                                notMatchedEmployeeCodes.add(relatedFields[employeeCodeIndex]);
                            }
                        }
                    }
                }
            }
        }

        // Eventually creating missing Employees

        if(!notMatchedEmployeeCodes.isEmpty()) {
            employeesToInsert = createEmployees(notMatchedEmployeeCodes, company);
        }

        if(!employeesToInsert.isEmpty()) {
            employeesToUpdate.addAll(employeesToInsert);
        }

        // Employee Upsert and error handling

        if(!employeesToUpdate.isEmpty()) {
            System.debug('Upserting ' + employeesToUpdate.size() + ' Employees...');
            List<Database.UpsertResult> results = Database.upsert(employeesToUpdate, EMPLOYEE_EXTERNAL_ID, false);

            if(results != null) {
				for(Database.UpsertResult result : results) {
					System.debug('Employee upsert success: ' + result.isSuccess());

					if(!result.isSuccess()) {
						Database.Error[] errors = result.getErrors();

						if(errors != null) {
							for(Database.Error error : errors) {
                                Employee__c relatedRecord = employeesToUpdate[results.indexOf(result)];

                                if(relatedRecord != null) {
                                    Error_Log_Event__e event = ErrorLogEventHandler.createEmployeeEvent(
                                        company.Company_Code__c,
                                        relatedRecord.Employee_Code__c,
                                        error.getMessage(),
                                        contentDocumentId
                                    );
                                    errorLogEvents.add(event);
                                }
							}
						}
					}
				}
            }
        }

        /* if(!employeesToInsert.isEmpty()) {
            System.debug('Inserting ' + employeesToInsert.size() + ' Employees...');
            List<Database.SaveResult> results = Database.insert(employeesToInsert);

            // TODO handle errors
        } */

        // Header Upsert and error handling

        if(!payrollHeadersToInsert.isEmpty()) {
            System.debug('Upserting ' + payrollHeadersToInsert.size() + ' Payroll Headers...');
            List<Database.UpsertResult> results = Database.upsert(payrollHeadersToInsert, PAYROLL_HEADER_EXTERNAL_ID, false);

            if(results != null) {
				for(Database.UpsertResult result : results) {
					System.debug('PayrollHeader upsert success: ' + result.isSuccess());

					if(!result.isSuccess()) {
						Database.Error[] errors = result.getErrors();

						if(errors != null) {
							for(Database.Error error : errors) {
                                Payroll_Header__c relatedRecord = payrollHeadersToInsert[results.indexOf(result)];

                                if(relatedRecord != null) {
                                    Error_Log_Event__e event = ErrorLogEventHandler.createPayrollHeaderEvent(
                                        relatedRecord.Company_Code__c,
                                        employeeCodeMap.get(relatedRecord),
                                        error.getMessage(),
                                        contentDocumentId
                                    );
                                    errorLogEvents.add(event);
                                }
							}
						}
					}
				}
			}
        }

        System.debug('--- Creating Payroll Items... ---');

        System.debug('companyId: ' + companyId);
        System.debug('company: ' + company);

        System.debug('indexToColumnNameMap: ' + indexToColumnNameMap);

        /* for(String csvRow : csvRows) {
            List<String> relatedFieldValues = csvRow.split(';');
            System.debug('relatedFieldValues: ' + relatedFieldValues);
            System.debug('csvRows.indexOf(csvRow): ' + csvRows.indexOf(csvRow));

            for(String relatedFieldValue : relatedFieldValues) {
                System.debug('indexToColumnMap value: ' + indexToColumnNameMap.get(relatedFieldValues.indexOf(relatedFieldValue)));
                
                if(columnToRelatedFieldsMap.get(indexToColumnNameMap.get(relatedFieldValues.indexOf(relatedFieldValue))) == null) {
                    columnToRelatedFieldsMap.put(indexToColumnNameMap.get(relatedFieldValues.indexOf(relatedFieldValue)), new List<String>());
                }
                columnToRelatedFieldsMap.get(indexToColumnNameMap.get(relatedFieldValues.indexOf(relatedFieldValue))).add(relatedFieldValue);
            }
        } */

        for(Integer i = 0; i < csvRows.size(); i++) {
            String csvRow = csvRows[i];
            List<String> relatedFieldValues = csvRow.split(';');
            System.debug('relatedFieldValues: ' + relatedFieldValues);
            System.debug('csvRows.indexOf(csvRow): ' + i);

            for(Integer j = 0; j < relatedFieldValues.size(); j++) {
                System.debug('indexToColumnMap value: ' + indexToColumnNameMap.get(j));
                
                if(columnToRelatedFieldsMap.get(indexToColumnNameMap.get(j)) == null) {
                    columnToRelatedFieldsMap.put(indexToColumnNameMap.get(j), new List<String>());
                }
                columnToRelatedFieldsMap.get(indexToColumnNameMap.get(j)).add(relatedFieldValues[j]);
            }
        }

        System.debug('columnToRelatedFieldsMap: ' + columnToRelatedFieldsMap);

        for(Integer i = 0; i < csvRows.size(); i++) {
            String csvRow = csvRows[i];
            List<String> relatedFieldValues = csvRow.split(';');
            if(relatedFieldValues.size() >= employeeCodeIndex) {
                Payroll_Header__c relatedPayrollHeader = payrollHeaderMap.get(relatedFieldValues[employeeCodeIndex]);
                String relatedEmployeeCode = relatedFieldValues[employeeCodeIndex];

                System.debug('relatedFieldValues before removal: ' + relatedFieldValues);

                /* relatedFieldValues.remove(employeeCodeIndex);
                relatedFieldValues.remove(firstNameIndex - 1);
                relatedFieldValues.remove(lastNameIndex - 2);
                relatedFieldValues.remove(hiringDateIndex - 3);
                relatedFieldValues.remove(exitDateIndex - 4); 
                */
            
                System.debug('columnToRelatedFieldsMap.getEmployeeCode: ' + columnToRelatedFieldsMap.get('Employee_Code__c'));
                System.debug('csvRow index: ' + i);
                System.debug('related EmployeeCode field: ' + columnToRelatedFieldsMap.get('Employee_Code__c')[i]);
                System.debug('related FirstName field: ' + columnToRelatedFieldsMap.get('First_Name__c')[i]);
                System.debug('related LastName field: ' + columnToRelatedFieldsMap.get('Last_Name__c')[i]);
                System.debug('related HiringDate field: ' + columnToRelatedFieldsMap.get('Hiring_Date__c')[i]);
                System.debug('related ExitDate field: ' + columnToRelatedFieldsMap.get('Exit_Date__c')[i]);
                System.debug('related FTE weight field: ' + columnToRelatedFieldsMap.get('FTE_weight__c')[i]);
                System.debug('indice da rimuovere: ' + relatedFieldValues.indexOf(columnToRelatedFieldsMap.get('FTE_weight__c')[i]));
                relatedFieldValues.remove(relatedFieldValues.indexOf(columnToRelatedFieldsMap.get('Employee_Code__c')[i]));
                relatedFieldValues.remove(relatedFieldValues.indexOf(columnToRelatedFieldsMap.get('First_Name__c')[i]));
                relatedFieldValues.remove(relatedFieldValues.indexOf(columnToRelatedFieldsMap.get('Last_Name__c')[i]));
                relatedFieldValues.remove(relatedFieldValues.indexOf(columnToRelatedFieldsMap.get('Hiring_Date__c')[i]));
                relatedFieldValues.remove(relatedFieldValues.indexOf(columnToRelatedFieldsMap.get('Exit_Date__c')[i]));

                if((columnToRelatedFieldsMap.get('FTE_weight__c'))[i] != null && relatedFieldValues.indexOf(columnToRelatedFieldsMap.get('FTE_weight__c')[i]) > -1) {
                    relatedFieldValues.remove(relatedFieldValues.indexOf(columnToRelatedFieldsMap.get('FTE_weight__c')[i]));
                }

                System.debug('relatedFieldValues: ' + relatedFieldValues);
                System.debug('relatedFieldValues.size: ' + relatedFieldValues.size());

                if(relatedPayrollHeader != null) {
                    Payroll_Item__c payrollItem = new Payroll_Item__c();

                    for(Integer j = 0; j < relatedFieldValues.size(); j++) {
                        String field = itemFieldNameMap.values()[j];
                        System.debug('Index: ' + j);
                        System.debug('field: ' + field);
                        System.debug('relatedFieldValue: ' + relatedFieldValues[j]);

                        Schema.DisplayType fieldType = fieldToFieldTypeMap.get(field);
                        System.debug('fieldType: ' + fieldType);
                        try {
                            payrollItem.put(field, getConvertedFieldValue(fieldType, relatedFieldValues[j]));
                        }
                        catch(TypeException e) {
                            Error_Log_Event__e event = ErrorLogEventHandler.createPayrollItemEvent(
                                payrollItem,
                                relatedPayrollHeader,
                                employeeCodeMap,
                                e.getMessage(),
                                contentDocumentId
                            );
                            errorLogEvents.add(event);
                        }
                    }

                    payrollItem.put('Payroll_Header__c', relatedPayrollHeader.Id);
                    payrollItem.put('External_Id__c', relatedEmployeeCode + relatedPayrollHeader.Month__c + relatedPayrollHeader.Year__c + 
                    payrollItem.Item_Code__c);

                    String key = String.valueOf(payrollItem.Payroll_Header__c) + '_' + String.valueOf(payrollItem.Item_Code__c);

                    if(payrollItemMap.containsKey(key)) {
                        Payroll_Item__c toSum = payrollItemMap.get(key);

                        if(toSum != null) {
                            toSum.Amount__c = toSum.Amount__c + payrollItem.Amount__c;
                        }
                    }
                    else {
                        System.debug('----- New Payroll Item created: ');
                        System.debug(payrollItem);

                        payrollItemsToInsert.add(payrollItem);
                        itemToHeaderMap.put(payrollItem, relatedPayrollHeader);
                        payrollItemMap.put(key, payrollItem);
                    }
                }
            }
        }

        // Item Upsert and error handling

        if(!payrollItemsToInsert.isEmpty()) {
            System.debug('Upserting ' + payrollItemsToInsert.size() + ' Payroll Items...');
            List<Database.UpsertResult> results = Database.upsert(payrollItemsToInsert, PAYROLL_ITEM_EXTERNAL_ID, false);

            if(results != null) {
				for(Database.UpsertResult result : results) {
					System.debug('PayrollItem upsert success: ' + result.isSuccess());

					if(!result.isSuccess()) {
						Database.Error[] errors = result.getErrors();

						if(errors != null) {
							for(Database.Error error : errors) {
                                Payroll_Item__c relatedRecord = payrollItemsToInsert[results.indexOf(result)];

                                if(relatedRecord != null) {
                                    Payroll_Header__c relatedHeader = itemToHeaderMap.get(relatedRecord);

                                    Error_Log_Event__e event = ErrorLogEventHandler.createPayrollItemEvent(
                                        relatedRecord,
                                        relatedHeader,
                                        employeeCodeMap,
                                        error.getMessage(),
                                        contentDocumentId
                                    );
                                    errorLogEvents.add(event);
                                }
							}
						}
					}
				}
			}
        }

        if(!errorLogEvents.isEmpty()) {
            List<Database.SaveResult> publishResults = EventBus.publish(errorLogEvents);
        }

        return errorLogEvents;
    }
}