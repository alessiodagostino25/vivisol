public class MeritPolicyHeaderTriggerQueueable implements Queueable {
    
    public MeritPolicyHeaderTriggerHelper policies;

    public MeritPolicyHeaderTriggerQueueable(MeritPolicyHeaderTriggerHelper inputPolicies) {
        this.policies = inputPolicies;
    }

    public void execute (QueueableContext context){
        Integer currentIndex = policies.getCurrentIndex();
        policies.setSingleHeader(currentIndex);
        System.debug('Header: ' + policies.getSingleHeader());
        policies.setPreviousYearPolicyItemMap();
        policies.setAllLastYearPayrollHeaders();
        policies.setAllBaseGrossSalary();
        List<Employee__c> employeeList = policies.getCurentEmployeeList();
        List<Merit_Policy_Item__c> items = new List<Merit_Policy_Item__c>();
        for (Employee__c singleEmployee : employeeList){
            Merit_Policy_Item__c item = new Merit_Policy_Item__c();
            item.Employee__c = singleEmployee.Id;
            item.Corporate_Role__c = singleEmployee.Corporate_Role__c;
            item.Merit_Policy_Header__c = policies.getSingleHeader().Id;
            item.Merit_Increase_Previous_Year__c = policies.getAnnualMeritIncreaseByEmployee(singleEmployee);
            item.Bonus_Previous_Year__c = policies.getBonusPreviousYearByEmployee(singleEmployee);
            item.Annual_Base_Gross_Salary_Previous_Year__c = policies.getAnnualBaseSalaryByEmployee(singleEmployee);
            item.Total_Gross_Salary_Previous_Year__c = policies.getTotalGrossSalaryByEmployee(singleEmployee);
            item.Allowance_Previous_Year__c = policies.getAllowancePreviousYearByEmployee(singleEmployee);
            item.Benefit_Previous_Year__c = policies.getBenefitPreviousYearByEmployee(singleEmployee);
            item.Overtime_Previous_Year__c = policies.getOvertimePreviousYearByEmployee(singleEmployee);

            item.Global_Gross_Salary_Previous_Year__c = item.Total_Gross_Salary_Previous_Year__c + item.Allowance_Previous_Year__c + item.Benefit_Previous_Year__c
            + item.Overtime_Previous_Year__c;
            
            item.Monthly_Base_Gross_Salary_Previous_Year__c = policies.getMonthlySalaryPreviousYearByEmployee(singleEmployee);

            item.Monthly_Base_Gross_Salary_This_Year__c = policies.getThisYearSalaryByEmployee(singleEmployee);
            item.Monthly_Total_Gross_Salary_This_Year__c = policies.getThisYearTotalGrossSalaryByEmployee(singleEmployee);
            item.FTE_weight__c = policies.getThisYearFTEWeightByEmployee(singleEmployee);

            items.add(item);
        }

        insert items;

        System.debug(policies.getCurentEmployeeList().size());
        policies.setCurrentIndex(currentIndex + 1);

        if (policies.getHeaders().size() > currentIndex + 1 ){
            //rieseguo il processo
            MeritPolicyHeaderTriggerHelper newHelper = new MeritPolicyHeaderTriggerHelper(policies.getHeaders());
            MeritPolicyHeaderTriggerQueueable updateJob = new MeritPolicyHeaderTriggerQueueable(newHelper);
            // enqueue the job for processing
            ID jobID = System.enqueueJob(updateJob);
        }

    }
}