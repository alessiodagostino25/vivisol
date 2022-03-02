/* *
* @author Arturo Forneris
*/
public class ContractTreatmentJobSlaController {
    
    //This method return Contract Treatment Job SLA List by his contractTreatmentJobId
    @AuraEnabled(cacheable=true)
    public static List<Contract_Treatment_Job_SLA__c> getContractTreatmentJobSla(String contractTreatmentJobId) {
        List<Contract_Treatment_Job_SLA__c> cTJSlaList = ContractTreatmentJobSlaService.getSlaListByCTJId(contractTreatmentJobId);

        return cTJSlaList;
    }
}