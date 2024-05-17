@isTest
private class AssessmentTriggerTest {
    static testMethod void testAssessmentAfterUpdate_BulkScanComplete() {
        Assessment__c assessment = new Assessment__c();
        insert assessment;

        Test.startTest();
            assessment.Bulk_Scan_Complete__c = true;
            update assessment;
        Test.stopTest();

        System.assert(true, 'This test should complete without exception invokes a void method. No results expected.');
    }
}