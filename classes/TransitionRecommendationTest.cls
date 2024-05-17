@isTest
private class TransitionRecommendationTest {

    private static final String API_RESPONSE_FSC_SCHEMA = '{"objectDescribeMap":{"Event":{"urls":{"sobject":"/services/data/v51.0/sobjects/Event","layouts":"/services/data/v51.0/sobjects/Event/describe/layouts","quickActions":"/services/data/v51.0/sobjects/Event/quickActions","uiNewRecord":"https://computing-customer-7699-dev-ed.cs95.my.salesforce.com/00U/e","describe":"/services/data/v51.0/sobjects/Event/describe","defaultValues":"/services/data/v51.0/sobjects/Event/defaultValues?recordTypeId&fields","eventSeriesUpdates":"/services/data/v51.0/sobjects/Event/{ID}/fromThisEventOnwards","uiEditTemplate":"https://computing-customer-7699-dev-ed.cs95.my.salesforce.com/{ID}/e","uiDetailTemplate":"https://computing-customer-7699-dev-ed.cs95.my.salesforce.com/{ID}","rowTemplate":"/services/data/v51.0/sobjects/Event/{ID}","compactLayouts":"/services/data/v51.0/sobjects/Event/describe/compactLayouts"},"updateable":true,"undeletable":true,"triggerable":true,"supportedScopes":[{"name":"delegated","label":"My delegated events"},{"name":"everything","label":"All events"},{"name":"mine","label":"My events"},{"name":"team","label":"My team\'s events"}],"sobjectDescribeOption":"FULL","searchable":true,"searchLayoutable":true,"retrieveable":true,"replicateable":true,"recordTypeInfos":[{"urls":{"layout":"/services/data/v51.0/sobjects/Event/describe/layouts/0120x000001Ee2oAAC"},"recordTypeId":"0120x000001Ee2oAAC","name":"Advisor Event","master":false,"developerName":"AdvisorEvent","defaultRecordTypeMapping":false,"available":false,"active":true},{"urls":{"layout":"/services/data/v51.0/sobjects/Event/describe/layouts/0120x000001Ee2pAAC"},"recordTypeId":"0120x000001Ee2pAAC","name":"Client Associate Event","master":false,"developerName":"ClientAssociateEvent","defaultRecordTypeMapping":false,"available":false,"active":true},{"urls":{"layout":"/services/data/v51.0/sobjects/Event/describe/layouts/012000000000000AAA"},"recordTypeId":"012000000000000AAA","name":"Master","master":true,"developerName":"Master","defaultRecordTypeMapping":true,"available":true,"active":true}],"queryable":true,"networkScopeFieldName":null,"namedLayoutInfos":[],"name":"Event","mruEnabled":true,"mergeable":false,"lookupLayoutable":null,"listviewable":null,"layoutable":true,"labelPlural":"Events","label":"Event","keyPrefix":"00U","isSubtype":false,"isInterface":false,"implementsInterfaces":null,"implementedBy":null,"hasSubtypes":false,"fields":[{"writeRequiresMasterRead":false,"updateable":true,"unique":false,"type":"reference","sortable":true,"soapType":"tns:ID","searchPrefilterable":false,"scale":0,"restrictedPicklist":false,"restrictedDelete":false,"relationshipOrder":null,"relationshipName":"FinServ__Household__r","referenceTo":["Account"],"referenceTargetField":null,"queryByDistance":false,"precision":0,"polymorphicForeignKey":false,"picklistValues":[],"permissionable":true,"nillable":true,"namePointing":false,"nameField":false,"name":"FinServ__Household__c","maskType":null,"mask":null,"length":18,"label":"Household","inlineHelpText":null,"idLookup":false,"htmlFormatted":false,"highScaleNumber":false,"groupable":true,"formulaTreatNullNumberAsZero":false,"filteredLookupInfo":null,"filterable":true,"extraTypeInfo":null,"externalId":false,"encrypted":false,"displayLocationInDecimal":false,"digits":0,"deprecatedAndHidden":false,"dependentPicklist":false,"defaultedOnCreate":false,"defaultValueFormula":null,"defaultValue":null,"custom":true,"createable":true,"controllerName":null,"compoundFieldName":null,"caseSensitive":false,"cascadeDelete":false,"calculatedFormula":null,"calculated":false,"byteLength":18,"autoNumber":false,"aiPredictionField":false,"aggregatable":true}]}}}';
    private static final String API_RESPONSE_ACM_SCHEMA = '{"createable":true}';

    static testMethod void testRecommendationAbstractGenerate_NullId() {
        TransitionRecommendation recommendation;

        Test.startTest();
            recommendation = new TransitionRecommendation().generate(null);
        Test.stopTest();

        System.assertNotEquals(null, recommendation, 'Recommendation instance should be available');
    }

    static testMethod void testAccessRecommendationTextMap() {
        Map<String,String> recommendTextMap;
        //This test invokes ToolingService.customLabelMap
        Test.setMock(HttpCalloutMock.class, new MockResponse(ExternalUtilities.HTTP_RESPONSE_CODE_SUCCESS, '{}'));
        Test.startTest();
            recommendTextMap = TransitionRecommendation.recommendTextMap;
        Test.stopTest();

        System.assertNotEquals(null, recommendTextMap, 'Recommendation text map instance should be available');
        System.assertNotEquals(true, recommendTextMap.isEmpty(), 'At least one recommendation text should be generated dynamically');
    }

    static testMethod void testExecuteRecommendations() {
        Assessment__c assessment = new Assessment__c();
        insert assessment;
        List<TransitionRecommendation> recommendations = new List<TransitionRecommendation>();

        //This test invokes callouts in some of the recommendation checks
        MockResponse mockResponses = new MockResponse(ExternalUtilities.HTTP_RESPONSE_CODE_SUCCESS, '{}'); //toling labels text not needed for this test
        mockResponses.addResponse(ExternalUtilities.HTTP_RESPONSE_CODE_SUCCESS, API_RESPONSE_FSC_SCHEMA); //CheckCustomFieldLimits - FSC org schema describe
        mockResponses.addResponse(ExternalUtilities.HTTP_RESPONSE_CODE_SUCCESS, API_RESPONSE_ACM_SCHEMA); //CheckCurrencySettings - Advanced currency management check
        
        Test.setMock(HttpCalloutMock.class, mockResponses);
        Test.startTest();
            recommendations.addAll(TransitionRecommendation.executeAllActions(assessment.Id));
        Test.stopTest();

        System.assertNotEquals(true, recommendations.isEmpty(), 'At least one recommendation instance should be generated dynamically');
    }
}