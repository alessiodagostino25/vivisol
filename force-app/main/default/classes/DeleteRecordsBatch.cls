global class DeleteRecordsBatch implements Database.Batchable<sObject>{
    private String objectName;
    private String whereCondition;

    global Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('objectName: ' + objectName);
        System.debug('whereCondition: ' + whereCondition);

        String query = 'SELECT Id FROM ' + objectName;

        if(whereCondition != null) {
            query += ' WHERE ' + whereCondition;
        }

        System.debug('QUERY: ' + query);
		return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<SObject> records) {
        System.debug('Deleting ' + records.size() + ' records of ' + objectName + ' where ' + whereCondition);

        List<Database.DeleteResult> results = Database.delete(records);
    }

    global void finish(Database.BatchableContext bc) {
        system.debug('DONE'); //TODO
    }

    global DeleteRecordsBatch(String objectName, String whereCondition) {
        this.objectName = objectName;
        this.whereCondition = whereCondition;
    }
}