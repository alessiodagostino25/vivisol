global class AutoscheduleActivitiesTherapyInvocable {
    
    @InvocableMethod
    global static void autoscheduleActivitiesTherapy(List<Id> accountTreatmentIds) {
        System.debug('AutoscheduleActivitiesTherapyInvocable, accountTreatmentIds: ' + accountTreatmentIds);

        //ATMainComponentController.autoscheduleProcess(accountTreatmentIds[0], null);
        AutoscheduleActivitiesTherapyBatch autoschedulingBatch = new AutoscheduleActivitiesTherapyBatch();
        autoschedulingBatch.accountTreatmentIds = accountTreatmentIds;

        Database.executeBatch(autoschedulingBatch, 1);
    }
}