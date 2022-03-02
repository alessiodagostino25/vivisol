global class DeleteRecordsSchedulable implements Schedulable {
    private String objectName;
    private String whereCondition;

    global void execute(SchedulableContext scon) {
        DeleteRecordsBatch batch = new DeleteRecordsBatch(
            this.objectName,
            this.whereCondition
        );

		Database.executeBatch(batch);
    }
    
    global DeleteRecordsSchedulable(String objectName, String whereCondition) {
        this.objectName = objectName;
        this.whereCondition = whereCondition;
    }
}