public class MeritPolicyHeaderTriggerHelper {

    Public List <Merit_Policy_Header__c> headers = new List<Merit_Policy_Header__c>();
    Private List<String> headerCompanies = new List<String>();
    Private Map<String, String> headerCompaniesMap = new Map<String, String> ();
    Private Map<String, Map<String, String>> companyAnnualBudgetMap = new Map<String, Map<String, String>> ();
    Private List<Employee__c> employeeList = new List<Employee__c>();
    Private List<Employee__c> singleHeaderEmployeeList = new List<Employee__c>();
    Private List<String> employeeIdsList = new List<String>(); 
    Private Map<String, Merit_Policy_Item__c> employeeLastMIMap = new Map<String, Merit_Policy_Item__c>();
    Private Map<String, List<Employee__c>> companyEmployeeMap = new Map<String, List<Employee__c>>();
    Private Map<String, MeritPolicyItem> meritItemsMap = new Map<String, MeritPolicyItem>();
    Private Map<String, Decimal> lastYearJulySalaryMap = new Map<String, Decimal>();
    Private Map<String, Decimal> thisYearSalaryMap = new Map<String, Decimal>();
    Private Map<String, Decimal> thisYearTotalGrossSalaryMap = new Map<String, Decimal>();
    private Map<String, Decimal> thisYearFTEWeightMap = new Map<String, Decimal>();
    Private Map<String, String> companyCodeMap = new Map<String, String>();

    Private Merit_Policy_Header__c singleHeader;
    Private Integer currentIndexNumber = 0;

    public MeritPolicyHeaderTriggerHelper() {

    }

    public MeritPolicyHeaderTriggerHelper(List<Merit_Policy_Header__c> inputHeaders) {
        this.headers = inputHeaders;
        for (Merit_Policy_Header__c singleHeader : inputHeaders){
            this.headerCompanies.add(singleHeader.Company__c);
            headerCompaniesMap.put(singleHeader.Id, singleHeader.Company__c);
        }
        this.queryForEmployee();
        this.queryForCompany();
        this.queryForAnnualBudget();
    }

    private void queryForAnnualBudget (){
        List<String> budgetQueryFields = new List<String>{'Id', 'Company__c', 'Year__c'};
        List<Annual_Budget__c> queriedBudget = AnnualBudgetDAO.getAnnualBudgetsByCompany(budgetQueryFields, headerCompanies);
        for (Annual_Budget__c tmpBudget : queriedBudget) {
            Map<String, String> tmpInnerMap = companyAnnualBudgetMap.get(tmpBudget.Company__c);
            if (tmpInnerMap == null){
                tmpInnerMap = new Map<String, String>();
                tmpInnerMap.put(tmpBudget.Year__c, tmpBudget.Id);
            } else{
                tmpInnerMap.put(tmpBudget.Year__c, tmpBudget.Id);
            }
            companyAnnualBudgetMap.put(tmpBudget.Company__c, tmpInnerMap);
        }
    }

    private void queryForEmployee (){
        List<String> employeeQueryFields = new List<String>{'Id', 'Corporate_Role__c', 'Company__c'};
        this.employeeList = EmployeeDAO.getAStatusEmployeeByCompany(employeeQueryFields, headerCompanies);
        for (Employee__c tmpEmp : this.employeeList) {
            this.employeeIdsList.add(tmpEmp.Id);
            List<Employee__c> tmpList = companyEmployeeMap.get(tmpEmp.Company__c);
            if (tmpList == null){
                tmpList = new List<Employee__c>();
                tmpList.add(tmpEmp);
            } else {
                tmpList.add(tmpEmp);
            }
            companyEmployeeMap.put(tmpEmp.Company__c, tmpList);
        }
    }

    private void queryForCompany (){
        List<String> companyIds = this.headerCompanies;
        List<String> companyQueryFields = new List<String>{'Id', 'Company_Code__c'};
        String query = ' SELECT Company_Code__c FROM Company__c'
        + ' WHERE Id IN :companyIds';
        List<Company__c> queriedCompany = Database.query(query);

        for (Company__c tmpCompany : queriedCompany) {
            this.companyCodeMap.put(tmpCompany.Id, tmpCompany.Company_Code__c);
        }
    }

    public Merit_Policy_Header__c handleCompanyCode(Merit_Policy_Header__c inputHeader){
        inputHeader.Company_Code__c = this.companyCodeMap.get(inputHeader.Company__c);
        return inputHeader;
    }

    public Merit_Policy_Header__c handleAnnualBudget(Merit_Policy_Header__c inputHeader){
        Map<String, String> tmpInnerMap = companyAnnualBudgetMap.get(inputHeader.Company__c);
        if (tmpInnerMap == null){
            return inputHeader;
        } else{
            inputHeader.Annual_Budget__c = tmpInnerMap.get(inputHeader.Year__c);
        }
        return inputHeader;
    }

    public List<Employee__c> getCurentEmployeeList (){
        return this.singleHeaderEmployeeList;
    }

    public List<Merit_Policy_Header__c> getHeaders (){
        return this.headers;
    }

    public void setSingleHeader (Integer inputIndex){
        this.singleHeader = headers[inputIndex];
        String tmpCompany = this.singleHeader.Company__c;
        if (companyEmployeeMap.get(tmpCompany) != null){
            this.singleHeaderEmployeeList = companyEmployeeMap.get(tmpCompany);
        } else {
            this.singleHeaderEmployeeList = new List<Employee__c>();
        }
    }

    public Merit_Policy_Header__c getSingleHeader (){
        return this.singleHeader;
    }

    public Integer getCurrentIndex (){
        return this.currentIndexNumber;
    }
    
    public void setCurrentIndex (Integer inputIndex){
        this.currentIndexNumber = inputIndex;
    }

    public void setPreviousYearPolicyItemMap (){
        List<String> meritPolicyQueryFields = new List<String>{'Id', 'Annual_Merit_Increase_3__c', 'New_Annual_Base_Gross_Salary_3__c',
        'One_Time_Payment_Bonus_3__c', 'MBO_Payment_3__c', 'Employee__c', 'New_Total_Annual_Gross_Salary_3__c' };
        Integer currentYear = Integer.valueOf(singleHeader.Year__c);
        String lastYear = String.valueOf(currentYear - 1);
        List <Merit_Policy_Item__c> items = MeritPolicyItemDAO.getMeritPolicyItemByEmpoleeAndYear(meritPolicyQueryFields, this.employeeIdsList, lastYear);
        for (Merit_Policy_Item__c queriedItem : items){
            this.employeeLastMIMap.put(queriedItem.Employee__c, queriedItem);
        }
    }

    public Decimal getAnnualMeritIncreaseByEmployee (Employee__c inputEmployee) {
        Merit_Policy_Item__c tmpItem = employeeLastMIMap.get(inputEmployee.Id);
        if (tmpItem!=null){
            return tmpItem.Annual_Merit_Increase_3__c;
        } else {
            return 0;
        }
    }

    public Decimal getAnnualBaseSalaryByEmployee (Employee__c inputEmployee) {
        Merit_Policy_Item__c tmpItem = employeeLastMIMap.get(inputEmployee.Id);
        if (tmpItem!=null){
            return tmpItem.New_Annual_Base_Gross_Salary_3__c;
        } else {
            return 0;
        }
    }

    public Decimal getTotalGrossSalaryByEmployee (Employee__c inputEmployee) {
        Merit_Policy_Item__c tmpItem = employeeLastMIMap.get(inputEmployee.Id);
        if (tmpItem!=null){
            return tmpItem.New_Total_Annual_Gross_Salary_3__c;
        } else {
            return 0;
        }
    }

    public Decimal getBonusPreviousYearByEmployee (Employee__c inputEmployee) {
        Merit_Policy_Item__c tmpItem = employeeLastMIMap.get(inputEmployee.Id);
        if (tmpItem!=null){
            Decimal tmpOneTime = tmpItem.One_Time_Payment_Bonus_3__c;
            Decimal tmpMBO = tmpItem.MBO_Payment_3__c;
            if (tmpOneTime != null && tmpMBO != null){
                return tmpOneTime + tmpMBO;
            } else{
                return 0;
            }
        } else {
            return 0;
        }
    }

    public Decimal getAllowancePreviousYearByEmployee (Employee__c inputEmployee) {
        MeritPolicyItem tmpItem = this.meritItemsMap.get(inputEmployee.Id);
        if (tmpItem!=null){
            return tmpItem.sumAllowance;
        } else {
            return 0;
        }
    }

    public Decimal getBenefitPreviousYearByEmployee (Employee__c inputEmployee) {
        MeritPolicyItem tmpItem = this.meritItemsMap.get(inputEmployee.Id);
        if (tmpItem!=null){
            return tmpItem.sumBenefit;
        } else {
            return 0;
        }
    }

    public Decimal getMonthlySalaryPreviousYearByEmployee (Employee__c inputEmployee) {
        Decimal tmpSalary = this.lastYearJulySalaryMap.get(inputEmployee.Id);
        if (tmpSalary!=null){
            return tmpSalary;
        } else {
            return 0;
        }
    }

    public Decimal getThisYearSalaryByEmployee (Employee__c inputEmployee) {
        Decimal tmpSalary = this.thisYearSalaryMap.get(inputEmployee.Id);
        if (tmpSalary!=null){
            return tmpSalary;
        } else {
            return 0;
        }
    }

    public Decimal getThisYearTotalGrossSalaryByEmployee (Employee__c inputEmployee) {
        Decimal tmpSalary = this.thisYearTotalGrossSalaryMap.get(inputEmployee.Id);
        if (tmpSalary!=null){
            return tmpSalary;
        } else {
            return 0;
        }
    }

    public Decimal getOvertimePreviousYearByEmployee (Employee__c inputEmployee) {
        MeritPolicyItem tmpItem = this.meritItemsMap.get(inputEmployee.Id);
        if (tmpItem!=null){
            return tmpItem.sumOvertime;
        } else {
            return 0;
        }
    }

    public Decimal getThisYearFTEWeightByEmployee(Employee__c inputEmployee) {
        Decimal tmpFTEWeight = this.thisYearFTEWeightMap.get(inputEmployee.Id);

        if(tmpFTEWeight != null) {
            return tmpFTEWeight;
        }
        else {
            return 0;
        }
    }

    public void setAllLastYearPayrollHeaders (){
        List<String> queryFields = new List<String>{'Sum (Allowance__c)', 'sum (Benefit__c)',
        'sum (Overtime__c)', 'Employee__c' };
        Integer currentYear = Integer.valueOf(singleHeader.Year__c);
        String lastYear = String.valueOf(currentYear - 1);

        List<String> employeeIds = this.employeeIdsList;

        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
            query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Payroll_Header__c WHERE Employee__c IN :employeeIds AND Year__c = :lastYear and Employee__c != null group by Employee__c';
        AggregateResult[] groupedResults = Database.query(query);

        for (AggregateResult result : groupedResults){
            MeritPolicyItem tmpItem = new MeritPolicyItem(result.get('expr0'), result.get('expr1'), result.get('expr2'));
            this.meritItemsMap.put(String.valueOf(result.get('Employee__c')), tmpItem);
        }
    }

    public void setAllBaseGrossSalary (){
        List<String> queryFields = new List<String>{'id', 'Base_Gross_Salary__c', 'Total_Gross_Salary__c'};
        Integer currentYear = Integer.valueOf(singleHeader.Year__c);
        String lastYear = String.valueOf(currentYear - 1);
        String currYearString = String.valueOf(currentYear);
        String month = '7';

        List<String> employeeIds = this.employeeIdsList;

        String query = ' SELECT employee__c, Year__c, Month__c, Base_Gross_Salary__c, Monthly_Base_Gross_Salary__c, Monthly_Total_Gross_Salary__c, Total_Gross_Salary__c, ' +
            'FTE_weight__c FROM Payroll_Header__c ' +
            'WHERE Employee__c IN :employeeIds Order by employee__c, Year__c, Month__c';
        List<Payroll_Header__c> groupedResults = Database.query(query);

        for (Payroll_Header__c result : groupedResults){
            if (result.Year__c == currYearString){
                this.thisYearSalaryMap.put(result.Employee__c, result.Monthly_Base_Gross_Salary__c);
                this.thisYearTotalGrossSalaryMap.put(result.Employee__c, result.Monthly_Total_Gross_Salary__c);
                this.thisYearFTEWeightMap.put(result.Employee__c, result.FTE_weight__c);
            } else if (result.Year__c == lastYear && result.Month__c == month){
                this.lastYearJulySalaryMap.put(result.Employee__c, result.Monthly_Base_Gross_Salary__c);
            }
        }
    }

    private class MeritPolicyItem{
        public Decimal sumAllowance = 0;
        public Decimal sumBenefit = 0;
        public Decimal sumOvertime = 0;

        public MeritPolicyItem(Object inputAllowance, Object inputBenefit, Object inputOvertime) {
            if (inputAllowance != null){
                this.sumAllowance = Decimal.valueOf(String.valueOf(inputAllowance));
            }
            if (inputBenefit != null){
                this.sumBenefit = Decimal.valueOf(String.valueOf(inputBenefit));
            }
            if (inputOvertime != null){
                this.sumOvertime = Decimal.valueOf(String.valueOf(inputOvertime));
            }
        }
    }

}