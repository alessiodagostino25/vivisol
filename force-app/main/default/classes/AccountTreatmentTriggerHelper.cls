public class AccountTreatmentTriggerHelper {
    
    public Account_Treatment__c accountTreatment;
    public List <Account_Treatment__c> newAccountTreatmentList;
    public List <Account_Treatment__c> oldAccountTreatmentList;
    public Map <Id,Account_Treatment__c> oldAccountTreatmentMap;
    public Map <Id,Account_Treatment__c> newAccountTreatmentMap;
    public List<Account_Treatment_History__c> accountHistories = new List<Account_Treatment_History__c>();
    public String recordTypeId;
    public List<String> fieldsToChange = new list<String> { 'Apneahypopnea_index_with_treatment__c', 'APAP_min_pressure__c', 'APAP_Mmax_pressure__c',
    'Autostart__c', 'BiPAP_Epap__c', 'BiPAP_Ipap__c', 'BPM__c', 'Name', 'Status__c', 'Business_Line__c', 'C_flex_EPR_soft__c', /*'Compliance__c', 'Threshold_day__c',*/ 'CPAP_pressure__c',
    'Cycle__c', 'EPAP__c', 'ESS__c', 'Humidification_mode__c', 'Max_EPAP__c', 'Max_IPAP__c', 'Max_pressure__c', 'Max_Pressure_support__c', 'Max_EPAP__c',
    'Min_Pressure_support__c', 'Neck_circumference__c', 'PAP_type__c', 'Pressure_support__c', 'Ramp_pressure__c', 'Ramp_time__c', 'Risetime__c', 'Start_EPAP__c',
    'Treatment__c', 'Ti__c', 'TiMax__c', 'TiMin__c', 'Trigger__c'};

    List<ObjectMapping__mdt> mappingfields = [SELECT Source_Field__c, Target_Field__c, isCheckBox__c, Source_Object__c, Target_Object__c
    FROM ObjectMapping__mdt
    WHERE Source_Object__r.DeveloperName = 'Account_Treatment' AND Target_Object__r.DeveloperName = 'Account_Treatment_History'];

    /* public Map<String,String> transformMap = new Map<String,String>{'Account_Treatment__c' => 'Id','Name' => 'Name','AHI_After_treatment__c' => 'Apneahypopnea_index_with_treatment__c',
    'APAP_min_pressure__c' => 'APAP_min_pressure__c','APAP_Mmax_pressure__c' => 'APAP_Mmax_pressure__c','Autostart__c' => 'Autostart__c','BiPAP_Epap__c' => 'BiPAP_Epap__c',
    'BiPAP_Ipap__c' => 'BiPAP_Ipap__c','BPM__c' => 'BPM__c','Business_Line__c' => 'Business_Line__c', 'Cflex_EPR_soft__c' => 'C_flex_EPR_soft__c',/*'Compliance__c' => 'Compliance__c',
    'Compliance_days_a_week__c' => 'Threshold_day__c','CPAP_pressure__c' => 'CPAP_pressure__c','Cycle__c' => 'Cycle__c','EPAP__c' => 'EPAP__c','ESS__c' => 'ESS__c',
    'Humidification_mode__c' => 'Humidification_mode__c','Max_EPAP__c' => 'Max_EPAP__c','Max_IPAP__c' => 'Max_IPAP__c','Max_pressure__c' => 'Max_pressure__c',
    'Max_Pressure_support__c' => 'Max_Pressure_support__c','Min_EPAP__c' => 'Max_EPAP__c','Min_Pressure_support__c' => 'Min_Pressure_support__c',
    'Neck_circumference__c' => 'Neck_circumference__c','PAPtype__c' => 'PAP_type__c','Pressure_support__c' => 'Pressure_support__c','Ramp_pressure__c' => 'Ramp_pressure__c',
    'Ramp_time__c' => 'Ramp_time__c','Risetime__c' => 'Risetime__c' , 'Start_EPAP__c' => 'Start_EPAP__c', 'Sub_Treatment__c' => 'Treatment__c','Ti__c' => 'Ti__c',
    'TiMax__c' => 'TiMax__c','TiMin__c' => 'TiMin__c', 'Trigger__c' => 'Trigger__c'}; */

    public AccountTreatmentTriggerHelper() {

    }

    public AccountTreatmentTriggerHelper( List <Account_Treatment__c> newList,  List <Account_Treatment__c> oldList,Map <Id,Account_Treatment__c> oldMap, Map <Id,Account_Treatment__c> newMap) {
        this.newAccountTreatmentList = newList;
        this.oldAccountTreatmentList = oldList;
        this.newAccountTreatmentMap = newMap;
        this.oldAccountTreatmentMap = oldMap;

        List<RecordType> recordTypeList = [SELECT Id FROM RecordType WHERE DeveloperName = 'ATH_History'];

        if(recordTypeList != null && !recordTypeList.isEmpty()) {
            this.recordTypeId = recordTypeList[0].Id;
        }
    }

    public List<Account_Treatment_History__c> getHistories(){
        return this.accountHistories;
    }

    public void initListHistory(){
        List<Account_Treatment_History__c> historyList = new List<Account_Treatment_History__c>();
        for (Account_Treatment__c accTreat : this.newAccountTreatmentList){
            if (accTreat.Status__c == 'A' && (this.oldAccountTreatmentMap.get(accTreat.Id).Status__c == 'W') && this.isChanged(accTreat, this.oldAccountTreatmentMap.get(accTreat.Id))){
                Account_Treatment_History__c tmpHistory = initHistory(accTreat);
                historyList.add(tmpHistory);
            }
        }
        this.accountHistories = historyList;
    }

    private Account_Treatment_History__c initHistory(Account_Treatment__c treatment){
        Account_Treatment_History__c history = new Account_Treatment_History__c();
        history.RecordTypeId = recordTypeId;

        for (ObjectMapping__mdt mapping : mappingfields){
            history.put(mapping.Target_Field__c, treatment.get(mapping.Source_Field__c));
        }
        return history;
    }

    private Boolean isChanged(Account_Treatment__c newAccTreat, Account_Treatment__c oldAccTreat){
        System.Debug('fieldsToChange: ' + this.fieldsToChange);
        for (String fieldName : this.fieldsToChange){
            if (newAccTreat.get(fieldname) != oldAccTreat.get(fieldName)){
                return true;
            }
        } 
        return false;

    }

}