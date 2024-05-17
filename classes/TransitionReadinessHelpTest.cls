/***********************************************************************************
 * Test class for "TransitionReadinessHelp"
 * 
 **********************************************************************************/

@isTest
public with sharing class TransitionReadinessHelpTest {

    static final String EXTERNAL_STRING_RESPONSE = '{"size":9,"totalSize":9,"done":true,"queryLocator":null,"entityTypeName":"ExternalString","records":[{"attributes":{"type":"ExternalString","url":"/services/data/v50.0/tooling/sobjects/ExternalString/1014x000007AblEAAS"},"Id":"1014x000007AblEAAS","Name":"HelpAdminGuideTitle","Value":"Admin Guide","Language":"en_US"},{"attributes":{"type":"ExternalString","url":"/services/data/v50.0/tooling/sobjects/ExternalString/1014x000007AblYAAS"},"Id":"1014x000007AblYAAS","Name":"HelpAdminGuideDesc","Value":"In-depth information about the configuration and automation of Financial Services Cloud.","Language":"en_US"},{"attributes":{"type":"ExternalString","url":"/services/data/v50.0/tooling/sobjects/ExternalString/1014x000007AbldAAC"},"Id":"1014x000007AbldAAC","Name":"HelpTrailheadTitle","Value":"Trailhead","Language":"en_US"},{"attributes":{"type":"ExternalString","url":"/services/data/v50.0/tooling/sobjects/ExternalString/1014x000007Abl4AAC"},"Id":"1014x000007Abl4AAC","Name":"HelpTrailheadDesc","Value":"Explore the many features of Financial Services Cloud via our specialized learning paths.","Language":"en_US"},{"attributes":{"type":"ExternalString","url":"/services/data/v50.0/tooling/sobjects/ExternalString/1014x000007AblTAAS"},"Id":"1014x000007AblTAAS","Name":"HelpFSCInstallTitle","Value":"Financial Services Cloud Installation Guide","Language":"en_US"},{"attributes":{"type":"ExternalString","url":"/services/data/v50.0/tooling/sobjects/ExternalString/1014x00000FAMcRAAX"},"Id":"1014x00000FAMcRAAX","Name":"HelpReleaseNotesTitle","Value":"Current Release Notes (Spring \'21)","Language":"en_US"},{"attributes":{"type":"ExternalString","url":"/services/data/v50.0/tooling/sobjects/ExternalString/1014x00000FAMcWAAX"},"Id":"1014x00000FAMcWAAX","Name":"HelpFSCDataModelTitle","Value":"FSC Data Model Overview","Language":"en_US"},{"attributes":{"type":"ExternalString","url":"/services/data/v50.0/tooling/sobjects/ExternalString/1014x00000FAMcbAAH"},"Id":"1014x00000FAMcbAAH","Name":"HelpTrailblazerTitle","Value":"Financial Services Cloud Trailblazer Community","Language":"en_US"}]};';
    
    @isTest
    static void testGetHelpContent(){
        Test.setMock(HttpCalloutMock.class, 
            new MockResponse(
                ExternalUtilities.HTTP_RESPONSE_CODE_SUCCESS, 
                '', 
                EXTERNAL_STRING_RESPONSE, 
                new Map<String, String>()
        ));

        Test.startTest();
        TransitionReadinessHelp.HelpContent content = TransitionReadinessHelp.getHelpContent();
        Test.stopTest();

        System.assert(content!=null, 'Content not found.');
        System.assert(content.mainItems != null && content.mainItems.size()>0 , 'No items found in "mainItems" list.');
        System.assert(content.sideItems != null && content.sideItems.size()>0 , 'No items found in "sideItems" list.');
    }

    // @isTest
    // static void testGetHelpContentFailure(){
    //     MockResponse res = new MockResponse(500, 'Internal Server Error', null, new Map<String, String>());
    //     Test.setMock(HttpCalloutMock.class, res);

    //     Test.startTest();
    //     TransitionReadinessHelp.HelpContent content = TransitionReadinessHelp.getHelpContent();
    //     Test.stopTest();

    //     System.assert(content==null, 'Mock callout did not return non-200 status.');
    // }
}