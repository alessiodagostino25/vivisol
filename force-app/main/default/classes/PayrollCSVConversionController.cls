public inherited sharing class PayrollCSVConversionController {
    @AuraEnabled
    public static void convertCSV(String contentDocumentId, Integer month, String year, String companyId) {
        System.debug('----- convertCSV -----');

        ConvertCSVToRecordsBatch batch = new ConvertCSVToRecordsBatch(
            contentDocumentId,
            month,
            year,
            companyId
        );

        Database.executeBatch(batch);
    }
}