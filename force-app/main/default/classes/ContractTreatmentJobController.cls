/* *
* @author Arturo Forneris
*/
public class ContractTreatmentJobController {

    @AuraEnabled(cacheable=true)
    public static List<Contract_Treatment_Job__c> getContractTreatmentJob( String contractTreatmentRecordId ) {
        System.debug('contractTreatmentRecordId: ' + contractTreatmentRecordId);
        List<Contract_Treatment_Job__c> queriedJobs = ContractTreatmentJobDAO.getContractTreatmentJobByCTId(contractTreatmentRecordId);
        System.debug('queriedJobs: ' + queriedJobs);
        return queriedJobs;
    }

    @AuraEnabled(cacheable=true)
    public static List<Contract_Treatment_Job__c> getContractTreatmentName( String contractTreatmentRecordId ) {
        String query = 'SELECT Name FROM Contract_Treatment_Job__c';
        String key = contractTreatmentRecordId;
        query += ' WHERE Contract_Treatment__c =:key';
        System.debug(query) ;
        return Database.query( query );
    }

    /* *
    * Gets <code> getCorporateJobFromContractJob </code > This method return a corporateTreatmentJob by his contractTreatmentJobId.
    *
    * @param contractTreatmentJobId String
    * @return corporateTreatmentJobId String
    */
    @AuraEnabled(cacheable=true)
    public static String getCorporateJobFromContractJob(String contractTreatmentJobId) {
        String corporateTreatmentJobId = ContractTreatmentJobService.getCorporateTreatmentJobByCTJId(contractTreatmentJobId);

        return corporateTreatmentJobId;
    }

    /* *
    * Gets <code> getCorporateTreatment </code > This method return a corporateTreatmentId by his contractTreatmentJobId.
    *
    * @param contractTreatmentJobId String
    * @return corporateTreatmentId String
    */
    @AuraEnabled(cacheable=true)
    public static String getCorporateTreatment(String contractTreatmentJobId) {
        String corporateTreatmentId = ContractTreatmentJobService.getCorporateTreatmentByCTJId(contractTreatmentJobId);

        return corporateTreatmentId;
    }

    /* *
    * Gets <code> cloneContractTreatmentJob </code > This method clone a Contract Treatment Job and his related Contract Treatment Job Sla and Contract Treatment Job Product.
    *
    * @param String contractTreatmentJobIdToCopy, String corporateTreatmentJob, String contractTreatmentJobCode, String contractTreatmentRecordId
    * @return String newCTJ
    */
    @AuraEnabled
    public static String cloneContractTreatmentJob(String contractTreatmentJobIdToCopy, String corporateTreatmentJob, String contractTreatmentJobCode, String contractTreatmentRecordId, String contractFrameworkId) {
        System.debug(contractTreatmentJobIdToCopy);
        System.debug(corporateTreatmentJob);
        System.debug(contractTreatmentJobCode);
        System.debug(contractTreatmentRecordId);
        System.debug(contractFrameworkId);
        String newCTJ = ContractTreatmentJobService.copyContractTreatmentJobAndRlated(contractTreatmentJobIdToCopy, corporateTreatmentJob, contractTreatmentJobCode, contractTreatmentRecordId, contractFrameworkId);

        return newCTJ;
    }

    /* *
    * Gets <code> getContractTreatmentJobClonable </code > This method return the List of clonable Contract Treatment Job referred the corporateTreatmentJob and contractTreatmentJobCode selected by the user in the create Job modal.
    *
    * @param String corporateTreatmentJob, String contractTreatmentJobCode, String contractTreatmentRecordId
    * @return List cTJClonableList
    */
    //
    @AuraEnabled(cacheable=true)
    public static List<ContractTreatmentJobDTO> getContractTreatmentJobClonable(String corporateTreatmentJob, String corporateTreatmentId, 
    String contractTreatmentRecordId, String searchTerm) {
        List<ContractTreatmentJobDTO> toReturn = new List<ContractTreatmentJobDTO>();
        List<Contract_Treatment_Job__c> cTJClonableList = ContractTreatmentJobService.getCTJClonableList(corporateTreatmentJob, corporateTreatmentId, 
        contractTreatmentRecordId, searchTerm);

        for(Contract_Treatment_Job__c ctj : cTJClonableList) {
            ContractTreatmentJobDTO dto = new ContractTreatmentJobDTO(ctj);
            toReturn.add(dto);
        }
        
        return toReturn;
        //return cTJClonableList;
    }

    @AuraEnabled(cacheable=true)
    public static Boolean checkIfJobAlreadyExist(String corporateTreatmentJob, String contractTreatmentJobCode, String contractTreatmentRecordId) {
        Boolean check = ContractTreatmentJobService.getCTJbyCorTJandCTJCode(corporateTreatmentJob, contractTreatmentJobCode, contractTreatmentRecordId);

        return check;
    }

    /*
    @AuraEnabled(cacheable=true)
    public static Boolean getDefaultBOM(String contractTreatmentJobId) {
        Contract_Treatment_Job__c ctj = ContractTreatmentJobDAO.getContractTreatmentJobByCTJId(contractTreatmentJobId);

        return ctj.Default_BOM__c;
    }
    */

}