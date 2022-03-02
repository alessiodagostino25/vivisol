public class PayrollHeaderTriggerService {
    public static void setNameAndCorporateRoleAndExternalId(List<Payroll_Header__c> payrollHeaders) {
        System.debug('----- setNameAndCorporateRoleAndExternalId -----');

        List<String> employeeIds = new List<String>();

        Map<String, Employee__c> employeeMap = new Map<String, Employee__c>();

        for(Payroll_Header__c payrollHeader : payrollHeaders) {
            if(payrollHeader.Employee__c != null) {
                employeeIds.add(payrollHeader.Employee__c);
            }
        }

        if(!employeeIds.isEmpty()) {
            List<Employee__c> employees = [SELECT Corporate_Role__c, Employee_Code__c FROM Employee__c WHERE Id IN: employeeIds];

            if(employees != null && !employees.isEmpty()) {
                for(Employee__c employee : employees) {
                    employeeMap.put(employee.Id, employee);
                }

                for(Payroll_Header__c payrollHeader : payrollHeaders) {
                    Employee__c relatedEmployee = employeeMap.get(payrollHeader.Employee__c);

                    if(relatedEmployee != null) {
                        payrollHeader.Corporate_Role__c = relatedEmployee.Corporate_Role__c;
                        payrollHeader.Name = 'PH' + relatedEmployee.Employee_Code__c + '_' + payrollHeader.Month__c + '-' + payrollHeader.Year__c;
                        
                        if(payrollHeader.External_Id__c == null) {
                            payrollHeader.External_Id__c = relatedEmployee.Employee_Code__c + payrollHeader.Month__c + payrollHeader.Year__c;
                        }
                        System.debug('External_Id__c: ' + payrollHeader.External_Id__c);
                    }
                }
            }
        }
    }

    public static void setBudgetItem(List<Payroll_Header__c> payrollHeaders) {
        List<String> budgetItemQueryFields = new List<String>{'Year__c', 'Month__c', 'Company__c'};

        List<String> years = new List<String>();
        List<String> months = new List<String>();
        List<String> companyIds = new List<String>();
        List<Budget_Item__c> allRelatedBudgetItems = new List<Budget_Item__c>();

        Map<String, Budget_Item__c> budgetItemMap = new Map<String, Budget_Item__c>();

        for(Payroll_Header__c payrollHeader : payrollHeaders) {
            if(payrollHeader.Year__c != null) {
                years.add(payrollHeader.Year__c);
            }
            if(payrollHeader.Month__c != null) {
                months.add(payrollHeader.Month__c);
            }
            if(payrollHeader.Company__c != null) {
                companyIds.add(payrollHeader.Company__c);
            }
        }

        if(!years.isEmpty() && !months.isEmpty() && !companyIds.isEmpty()) {
            allRelatedBudgetItems = BudgetItemDAO.getBudgetItemsFromYearMonthCompany(budgetItemQueryFields, years, months, companyIds);

            if(!allRelatedBudgetItems.isEmpty()) {
                for(Budget_Item__c budgetItem : allRelatedBudgetItems) {
                    if(budgetItem.Year__c != null && budgetItem.Month__c != null && budgetItem.Company__c != null) {
                        budgetItemMap.put(budgetItem.Year__c + '_' + budgetItem.Month__c + '_' + budgetItem.Company__c, budgetItem);
                    }
                }

                for(Payroll_Header__c payrollHeader : payrollHeaders) {
                    Budget_Item__c relatedBudgetItem;
                    String key = payrollHeader.Year__c + '_' + payrollHeader.Month__c + '_' + payrollHeader.Company__c;

                    if(key != null) {
                        relatedBudgetItem = budgetItemMap.get(key);

                        if(relatedBudgetItem != null) {
                            payrollHeader.Budget_Item__c = relatedBudgetItem.Id;
                        }
                    }
                }
            }
        }
    }
}