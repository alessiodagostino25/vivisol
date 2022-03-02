public class CaseTriggerHelper {
    
    public Case caseBeforeTrigger;
    public Account relatedAccount;

    public CaseTriggerHelper() {

    }

    public CaseTriggerHelper(Case inputCase) {
        this.caseBeforeTrigger = inputCase;
    }

    public CaseTriggerHelper(Case inputCase, Account relatedAccount) {
        this.caseBeforeTrigger = inputCase;
        this.relatedAccount = relatedAccount;
    }

    public Case handleAccountAndPatientField(){
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Account_Patient').getRecordTypeId();
        if (relatedAccount != null && relatedAccount.IsPersonAccount && relatedAccount.RecordTypeId == accRecordTypeId ){
            this.caseBeforeTrigger.Patient__c = this.caseBeforeTrigger.AccountId;
        }
        if (relatedAccount != null && relatedAccount.IsPersonAccount){
            this.caseBeforeTrigger.ContactId = relatedAccount.PersonContactId;
        }
        return this.caseBeforeTrigger;
    }

    public String getPatient(){
        return this.caseBeforeTrigger.Patient__c;
    }
}