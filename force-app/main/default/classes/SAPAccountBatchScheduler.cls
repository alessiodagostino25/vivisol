global without sharing class SAPAccountBatchScheduler implements Schedulable {
    private Integer batchGroup;

    global void execute(SchedulableContext scon) {
        SAPAccountBatch batch = new SAPAccountBatch(this.batchGroup);

		Database.executeBatch(batch, 10);
    }
    
    global SAPAccountBatchScheduler(Integer batchGroup) {
        this.batchGroup = batchGroup;
    }
}