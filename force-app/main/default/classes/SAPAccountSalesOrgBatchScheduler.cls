global without sharing class SAPAccountSalesOrgBatchScheduler implements Schedulable {
    private Integer batchGroup;

    global void execute(SchedulableContext scon) {
        SAPAccountSalesOrgBatch batch = new SAPAccountSalesOrgBatch(this.batchGroup);

		Database.executeBatch(batch, 15);
    }
    
    global SAPAccountSalesOrgBatchScheduler(Integer batchGroup) {
        this.batchGroup = batchGroup;
    }
}