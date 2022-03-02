@isTest
public class TestDeleteContentDocumentBatch {
    @isTest
    static void batchTest() {
        ContentVersion contentVersion = new ContentVersion(
            To_Be_Deleted__c = true,
            Title = 'Test Title',
            PathOnClient = 'TestTitle.pdf',
            VersionData = Blob.valueOf('Test Data')
        );
        insert contentVersion;

        Test.startTest();

        Database.executeBatch(new DeleteContentDocumentBatch());

        Test.stopTest();

        List<ContentVersion> contentVersions = [SELECT Id FROM ContentVersion];
        
        System.assertEquals(0, contentVersions.size());
    }
}