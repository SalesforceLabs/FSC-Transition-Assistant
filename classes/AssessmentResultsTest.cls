@isTest
private class AssessmentResultsTest {

    static testMethod void testController_NewAssessment() {
        //create a new assessment
        Assessment__c assessment = new Assessment__c();
        insert assessment;
        
        MockResponse mockResponses = new MockResponse(ExternalUtilities.HTTP_RESPONSE_CODE_SUCCESS, '{}'); //installed assessment version will be empty in dev
        mockResponses.addResponse(ExternalUtilities.HTTP_RESPONSE_CODE_SUCCESS, '{"releaseVersion": "Spring \'21 Patch 9.2"}'); //org release version SF status api
        mockResponses.addResponse(ExternalUtilities.HTTP_RESPONSE_CODE_SUCCESS, '{}'); //tooling labels response
        mockResponses.addResponse(ExternalUtilities.HTTP_RESPONSE_CODE_SUCCESS, '{}'); //sync dependency tooling response 1
        mockResponses.addResponse(ExternalUtilities.HTTP_RESPONSE_CODE_PROCESSING, 'Processing'); //async dependency tooling response 2
        Test.setMock(HttpCalloutMock.class, mockResponses);
        Test.startTest();

        //load new results for component
        AssessmentResultsController.AssessmentResultsView resultsView = AssessmentResultsController.getAssessmentResults(assessment.Id);
        
        Test.stopTest();

        //verify results
        System.assertNotEquals(null, resultsView, 'Results view must be generated');
    }

    static testMethod void testController_ExistingAssessment() {
        //create a new assessment
        Assessment__c assessment = new Assessment__c();
        insert assessment;
        
        MockResponse mockResponses = new MockResponse(ExternalUtilities.HTTP_RESPONSE_CODE_SUCCESS, '{}'); //installed assessment version will be empty in dev
        mockResponses.addResponse(ExternalUtilities.HTTP_RESPONSE_CODE_SUCCESS, '{"releaseVersion": "Spring \'21 Patch 9.2"}'); //org release version SF status api
        mockResponses.addResponse(ExternalUtilities.HTTP_RESPONSE_CODE_SUCCESS, '{}'); //tooling labels response
        mockResponses.addResponse(ExternalUtilities.HTTP_RESPONSE_CODE_SUCCESS, '{}'); //sync dependency tooling response 1
        mockResponses.addResponse(ExternalUtilities.HTTP_RESPONSE_CODE_PROCESSING, 'Processing'); //async dependency tooling response 2
        Test.setMock(HttpCalloutMock.class, mockResponses);
        Test.startTest();

        //load new results for component
        AssessmentResultsController.AssessmentResultsView resultsView = AssessmentResultsController.getAssessmentResults(assessment.Id);

        //reload existing results for component
        //API callouts SHOULD NOT repeat loading saved report results
        AssessmentResultsController.AssessmentResultsView resultsViewReloaded = AssessmentResultsController.getAssessmentResults(assessment.Id);
        
        Test.stopTest();

        //verify results
        System.assertNotEquals(null, resultsViewReloaded, 'Reloaded results must be populated');
        System.assertEquals(resultsView.dateRun, resultsViewReloaded.dateRun, 'Results should be same when reloaded');
    }
}