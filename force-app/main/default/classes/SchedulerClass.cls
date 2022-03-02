global class SchedulerClass {

    public static void scheduleAccountSalesOrganizationLogsBatch(String jobName){
		// Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
		String sch0 = '20 00 * * * ?';
		System.schedule(jobName + ' hh:00', sch0, new AccountSalesOrganizationLogsBatch());
	}
	
    public static void scheduleAccountCompanyLogsBatch(String jobName){
		// Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
		String sch0 = '20 00 * * * ?';
		System.schedule(jobName + ' hh:00', sch0, new AccountCompanyLogsBatch());
	}
	
    public static void scheduleAddressSyncSapBatch(String jobName) {
        // Scheduled every day at 4:30 am
        String sch0 = '0 30 4 * * ?';
        System.schedule(jobName + ' hh:00', sch0, new AddressSyncSapBatch());
	}
	
    public static void scheduleAssignAccountLogsBatch(String jobName){
		// Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
		String sch0 = '00 00 * * * ?';
		System.schedule(jobName + ' xx:00', sch0, new AssignAccountLogsBatch());
	}
	
    public static void scheduleAssignAddressLogsBatch(String jobName) {
		// Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
		String sch0 = '20 00 * * * ?';
		System.schedule(jobName + ' hh:00', sch0, new AssignAddressLogsBatch());
	}
	
    public static void scheduleAssignCalloutLoggerChain(String jobName){
		// Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
		String sch0 = '00 00 * * * ?';
		String sch1 = '00 10 * * * ?';
		String sch2 = '00 20 * * * ?';
		String sch3 = '00 30 * * * ?';
		String sch4 = '00 40 * * * ?';
		String sch5 = '00 50 * * * ?';
		System.schedule(jobName + ' hh:00', sch0, new AssignContractFrameworkBatch());
		System.schedule(jobName + ' hh:10', sch1, new AssignContractFrameworkBatch());
		System.schedule(jobName + ' hh:20', sch2, new AssignContractFrameworkBatch());
		System.schedule(jobName + ' hh:30', sch3, new AssignContractFrameworkBatch());
		System.schedule(jobName + ' hh:40', sch4, new AssignContractFrameworkBatch());
		System.schedule(jobName + ' hh:50', sch5, new AssignContractFrameworkBatch());
	}
	
    public static void scheduleCalloutLoggerResolutionBatch(String jobName) {
        // Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
        String sch0 = '0 0 0 * * ?';
        System.schedule(jobName + ' hh:00', sch0, new CalloutLoggerResolutionBatch());
	}
	
    public static void scheduleMaintenanceWorkOrderBatch(String jobName){
		// Scheduled every day at 4:30 am
		String sch0 = '0 30 4 * * ?';
		System.schedule(jobName + ' hh:00', sch0, new MaintenanceWorkOrderBatch());
	}
	
    public static void scheduleProductFamilyCodesBatch(String jobName) {
		// Scheduled every day at 4:30 am
		String sch0 = '0 30 4 * * ?';
		System.schedule(jobName + ' 04:30', sch0, new ProductFamilyCodesBatch());
	}
	
    public static void scheduleRelatedAccountTreatmentJobBatch(String jobName) {
		// Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
		String sch0 = '0 0 * * * ?';
		System.schedule(jobName + ' hh:00', sch0, new RelatedAccountTreatmentJobBatch());
	}
	
    public static void scheduleServiceTerritoryUpdateBatch() {
		String CRON_EXP = '0 15 * * * ?';
		String CRON_EXP1 = '0 30 * * * ?';
		String CRON_EXP2 = '0 45 * * * ?';
		String CRON_EXP3 = '0 0 * * * ?';
		System.schedule('ServiceTerritoryUpdateBatch hh:15', CRON_EXP, new ServiceTerritoryUpdateBatch());
		System.schedule('ServiceTerritoryUpdateBatch hh:30', CRON_EXP1, new ServiceTerritoryUpdateBatch());
		System.schedule('ServiceTerritoryUpdateBatch hh:45', CRON_EXP2, new ServiceTerritoryUpdateBatch());
		System.schedule('ServiceTerritoryUpdateBatch hh:00', CRON_EXP3, new ServiceTerritoryUpdateBatch());
	}

	public static void scheduleServiceTerritoryCheckBatch() {
		String CRON_EXP = '0 0 * * * ?';
		String CRON_EXP1 = '0 30 * * * ?';
		System.schedule('ServiceTerritoryCheckBatch hh:00', CRON_EXP, new ServiceTerritoryCheckBatch());
		System.schedule('ServiceTerritoryCheckBatch hh:30', CRON_EXP1, new ServiceTerritoryCheckBatch());
	}
	
    public static void scheduleServiceResourceBatch(String jobName){
		// Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
		String sch0 = '0 0 22 * * ?';
		System.schedule(jobName + ' hh:22:00', sch0, new ServiceResourceBatch());
	}
	
    public static void scheduleWorkOrderAddressAlignmentBatch(String jobName){
		// Scheduled every day at 4:30 am
		String sch0 = '0 30 1 * * ?';
		System.schedule(jobName + ' 01:30', sch0, new WorkOrderAddressAlignmentBatch());
  	}
  
	public static void scheduleContractFrameworkEventBatch(String jobName){
		// Scheduled every day at 4:30 am
		String sch0 = '0 30 4 * * ?';
		System.schedule(jobName + ' 04:30', sch0, new ContractFrameworkEventBatch());
	}
	  
	public static void scheduleSAPMeasurement(String jobName) {
		String sch0 = '0 00 * * * ?';
		String sch1 = '0 30 * * * ?';
		System.schedule(jobName + ' hh:00', sch0, new SAPMeasurementBatch());
		System.schedule(jobName + ' hh:30', sch1, new SAPMeasurementBatch());
	}
	
	public static void scheduleDatesAdjustment(String jobName) {
		String sch0 = '0 0 20 * * ?';
		System.schedule(jobName + ' 20:00', sch0, new ActivitiesDatesAdjustmentBatch());
	}
	public static void scheduleWorkOrderSapAlignmentBatch(String jobName) {
		String sch0 = '0 0 8 * * ?';
		System.schedule(jobName + '8:00', sch0, new WorkOrderSapAlignmentBatch());
	}

	public static void scheduleAccountTreatmentSuspensionBatch(String jobName) {
		// Scheduled every day at 4:30 am
		String sch0 = '0 30 4 * * ?';
		System.schedule(jobName + ' 04:30', sch0, new AccountTreatmentSuspensionBatch());
	}

	public static void scheduleDeleteRecordsBatch() {
		List<Delete_Batch_Setting__mdt> deleteBatchSettings = new List<Delete_Batch_Setting__mdt>();

		deleteBatchSettings = [SELECT Name__c, ObjectAPIName__c, SchedulingCronExp__c, WhereCondition__c FROM Delete_Batch_Setting__mdt];

		if(!deleteBatchSettings.isEmpty()) {
			for(Delete_Batch_Setting__mdt setting : deleteBatchSettings) {
				String jobName = setting.Name__c;
				String objectName = setting.ObjectAPIName__c;
				String cronExpression = setting.SchedulingCronExp__c;
				String whereCondition = setting.WhereCondition__c;

				DeleteRecordsSchedulable schedulable = new DeleteRecordsSchedulable(objectName, whereCondition);

				try {
					System.schedule(jobName, cronExpression, schedulable);
				}
				catch(System.AsyncException e) {
					System.debug(e.getMessage());
				}
			}
		}
	}

	public static void scheduleSAPAccountBatch() {
		String sch0 = '0 10 0 * * ?';

		SAPAccountBatchScheduler scheduler0 = new SAPAccountBatchScheduler(0);
		SAPAccountBatchScheduler scheduler1 = new SAPAccountBatchScheduler(1);
		SAPAccountBatchScheduler scheduler2 = new SAPAccountBatchScheduler(2);
		SAPAccountBatchScheduler scheduler3 = new SAPAccountBatchScheduler(3);
		SAPAccountBatchScheduler scheduler4 = new SAPAccountBatchScheduler(4);

		System.schedule('SAPAccountBatch Group 0', sch0, scheduler0);
		System.schedule('SAPAccountBatch Group 1', sch0, scheduler1);
		System.schedule('SAPAccountBatch Group 2', sch0, scheduler2);
		System.schedule('SAPAccountBatch Group 3', sch0, scheduler3);
		System.schedule('SAPAccountBatch Group 4', sch0, scheduler4);
	}

	public static void scheduleSAPAccountSalesOrgBatch() {
		String sch0 = '0 0 2 * * ?';

		SAPAccountSalesOrgBatchScheduler scheduler0 = new SAPAccountSalesOrgBatchScheduler(0);
		SAPAccountSalesOrgBatchScheduler scheduler1 = new SAPAccountSalesOrgBatchScheduler(1);
		SAPAccountSalesOrgBatchScheduler scheduler2 = new SAPAccountSalesOrgBatchScheduler(2);
		SAPAccountSalesOrgBatchScheduler scheduler3 = new SAPAccountSalesOrgBatchScheduler(3);
		SAPAccountSalesOrgBatchScheduler scheduler4 = new SAPAccountSalesOrgBatchScheduler(4);

		System.schedule('SAPAccountSalesOrgBatch Group 0', sch0, scheduler0);
		System.schedule('SAPAccountSalesOrgBatch Group 1', sch0, scheduler1);
		System.schedule('SAPAccountSalesOrgBatch Group 2', sch0, scheduler2);
		System.schedule('SAPAccountSalesOrgBatch Group 3', sch0, scheduler3);
		System.schedule('SAPAccountSalesOrgBatch Group 4', sch0, scheduler4);
	}

	public static void scheduleSAPAccountCompanyBatch() {
		String sch0 = '0 15 2 * * ?';

		SAPAccountCompanyBatchScheduler scheduler0 = new SAPAccountCompanyBatchScheduler(0);
		SAPAccountCompanyBatchScheduler scheduler1 = new SAPAccountCompanyBatchScheduler(1);
		SAPAccountCompanyBatchScheduler scheduler2 = new SAPAccountCompanyBatchScheduler(2);
		SAPAccountCompanyBatchScheduler scheduler3 = new SAPAccountCompanyBatchScheduler(3);
		SAPAccountCompanyBatchScheduler scheduler4 = new SAPAccountCompanyBatchScheduler(4);

		System.schedule('SAPAccountCompanyBatch Group 0', sch0, scheduler0);
		System.schedule('SAPAccountCompanyBatch Group 1', sch0, scheduler1);
		System.schedule('SAPAccountCompanyBatch Group 2', sch0, scheduler2);
		System.schedule('SAPAccountCompanyBatch Group 3', sch0, scheduler3);
		System.schedule('SAPAccountCompanyBatch Group 4', sch0, scheduler4);
	}
}