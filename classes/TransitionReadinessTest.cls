@isTest
private class TransitionReadinessTest {

    static testMethod void testUpgradeAssessment() {
        //get the assessment (should already exist passed from lightning record page)
        Id assessmentId = [SELECT Id FROM Assessment__c LIMIT 1][0].Id;

        MockResponse mockResponses = new MockResponse(ExternalUtilities.HTTP_RESPONSE_CODE_SUCCESS, '{}'); //installed assessment version will be empty in dev
        mockResponses.addResponse(ExternalUtilities.HTTP_RESPONSE_CODE_SUCCESS, '{"releaseVersion": "Spring \'21 Patch 9.2"}'); //org release version SF status api
        mockResponses.addResponse(ExternalUtilities.HTTP_RESPONSE_CODE_SUCCESS, '{}'); //tooling labels response
        mockResponses.addResponse(ExternalUtilities.HTTP_RESPONSE_CODE_SUCCESS, '{}'); //tooling TransitionRecommendation.CheckCustomFieldLimits
        mockResponses.addResponse(ExternalUtilities.HTTP_RESPONSE_CODE_SUCCESS, '{}'); //tooling TransitionRecommendation.CheckCustomFieldLimits
        mockResponses.addResponse(ExternalUtilities.HTTP_RESPONSE_CODE_SUCCESS, '{}'); //tooling TransitionRecommendation.CheckCurrencySettings
        mockResponses.addResponse(ExternalUtilities.HTTP_RESPONSE_CODE_SUCCESS, '{}'); //sync dependency tooling response 1
        mockResponses.addResponse(ExternalUtilities.HTTP_RESPONSE_CODE_PROCESSING, 'Processing'); //async dependency tooling response 2
        Test.setMock(HttpCalloutMock.class, mockResponses);
        Test.startTest();

        //Run with an assessment record
        TransitionReadinessUtility.ReadinessResults results = TransitionReadinessUtility.performFscUpgradeAssessment(assessmentId);
        
        Test.stopTest();

        //verify results
        System.assertNotEquals(null, results.installReadiness, 'Installation readiness results should be generated');
        System.assertNotEquals(null, results.recommendations, 'Recommendation list results should be generated');
    }

    /**
     * TODO CLEAN UP THIS TEST AND FUNCTION FOR LOADING ASSESSMENT VS PERFORM ASSESSMENT
     */
    static testMethod void testUpgradeAnalysis() {
        //get the assessment (should already exist passed from lightning record page)
        Id assessmentId = [SELECT Id FROM Assessment__c LIMIT 1][0].Id;

        Test.startTest();

        //Process dependency results
        Boolean hasVoidError = false;
        try {
            TransitionReadinessUtility.processScanResultsCallback(new List<Id>{assessmentId});
        } catch (Exception e) {
            hasVoidError = true;
        }
        
        //verify results
        //results = TransitionReadinessUtility.performFscUpgradeAssessment(assessmentId);
        Test.stopTest();

        //System.assertNotEquals(null, results.analysis, 'Analyis results should be generated');
        System.assert(!hasVoidError, 'Void callback should execute without exceptions');
    }

    @TestSetup
    static void makeData() {
        //create a new assessment
        Assessment__c assessment = new Assessment__c();
        insert assessment;
    }

}