global without sharing class SAPAccountCompanyBatchScheduler implements Schedulable {
    private Integer batchGroup;

    global void execute(SchedulableContext scon) {
        SAPAccountCompanyBatch batch = new SAPAccountCompanyBatch(this.batchGroup);

		Database.executeBatch(batch, 15);
    }
    
    global SAPAccountCompanyBatchScheduler(Integer batchGroup) {
        this.batchGroup = batchGroup;
    }
}