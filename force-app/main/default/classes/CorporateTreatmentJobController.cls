/* *
* @author Arturo Forneris
*/
public class CorporateTreatmentJobController {

    @AuraEnabled(cacheable=true)
    public static List<Corporate_Treatment_Job__c> getCorporateTreatmentJob(String corporateTreatmentId) {
        String query = 'SELECT Corporate_Treatment_Job__c FROM Corporate_Treatment_Job_Product__c';
        String key = corporateTreatmentId;
        query += ' WHERE Corporate_Treatment_Job__r.Id =:key';
        query += ' GROUP BY Corporate_Treatment_Job__c';
        return Database.query( query );
    }
}