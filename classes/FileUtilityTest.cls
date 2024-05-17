@isTest
private class FileUtilityTest {
    private static final String TEST_FILE_NAME = 'test';
    private static final String TEST_FILE_TYPE = 'json';
    private static final String TEST_FILE_DATA = '"Hello world"';

    static testMethod void testFileSave() {

        //load existing record id to test
        Id accountId = [SELECT Id FROM Account LIMIT 1][0].Id;
        
        Test.startTest();

        //save a new file
        FileUtility.writeFileData(accountId, TEST_FILE_NAME, TEST_FILE_TYPE, TEST_FILE_DATA);

        Test.stopTest();

        //verify file saves
        List<ContentVersion> content = [SELECT VersionData FROM ContentVersion WHERE Title = :TEST_FILE_NAME LIMIT 1];
        System.assertNotEquals(true, content.isEmpty(), 'File must get created and exist');
        System.assertEquals(TEST_FILE_DATA, content[0].VersionData.toString(), 'File data must be populated and equal what was saved');
    }

    static testMethod void testFileLoad_ContentDocumentId() {

        //load existing record id to test
        Id accountId = [SELECT Id FROM Account LIMIT 1][0].Id;
        //execute file save to create a file for test loading
        FileUtility.writeFileData(accountId, TEST_FILE_NAME, TEST_FILE_TYPE, TEST_FILE_DATA);
        
        Test.startTest();

        //load content doc id
        Id contentDocId = FileUtility.getContentDocumentIdByName(accountId, TEST_FILE_NAME);
        
        Test.stopTest();

        //verify file loads
        System.assertNotEquals(null, contentDocId, 'ContentDocumentId must be populated from saved ContentVersion');
    }

    static testMethod void testFileLoad_ContentVersionData() {

        //load existing record id to test
        Id accountId = [SELECT Id FROM Account LIMIT 1][0].Id;
        //execute file save to create a file for test loading
        FileUtility.writeFileData(accountId, TEST_FILE_NAME, TEST_FILE_TYPE, TEST_FILE_DATA);
        
        Test.startTest();

        //load file data as string
        String fileDataString = FileUtility.readFileDataString(accountId, TEST_FILE_NAME);
        
        Test.stopTest();

        //verify file loads
        System.assertEquals(TEST_FILE_DATA, fileDataString, 'File data must be populated and equal what was saved');
    }

    @TestSetup
    static void makeData() {
        //create a record to relate file to
        Account acc = new Account(Name='Test');
        insert acc;
    }

}