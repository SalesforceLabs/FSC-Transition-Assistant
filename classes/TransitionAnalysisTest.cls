@IsTest
private class TransitionAnalysisTest {
    static final Boolean NEW_ASSESSMENT_TEST_B2C = true;
    static final String NEW_ASSESSMENT_STATUS = 'New';
    static final String NEW_ASSESSMENT_PRODUCTS = 'FSC Banking';
    static final String API_RESPONSE_CUSTOM_OBJECT = '{"size":13,"totalSize":13,"records":[{"SFDC_Help":"01I4x000000XY8tEAG","SFDC_Limit":"01I4x000000X0B6EAK","SFDC_Industry_Assessment_Question_Branch":"01I4x000000Wx6aEAC","SFDC_Feature":"01I4x000000WahLEAS","SFDC_Recommendation":"01I4x000000WaR8EAK","SFDC_Schema_Org":"01I4x000000WZLFEA4","SFDC_Industry_Mapping_Section":"01I4x000000XAANEA4","ISV_Limitation_Warning":"01I4x000000VYEtEAO","SFDC_Industry_Mapping_Object":"01I4x000000WamCEAS","SFDC_Industry_Assessment_Question":"01I4x000000VYEjEAO","SFDC_Industry_Vertical":"01I4x000000VYEeEAO","SFDC_Industry":"01I4x000000VYEZEA4","Assessment":"01I4x000000VYCnEAO"}]}';
    static final String API_RESPONSE_LAYOUTS = '{"size":5,"totalSize":5,"done":true,"queryLocator":null,"entityTypeName":"Layout","records":[{"Id":"00h4x0000015xPuAAI","Name":"Assessment Layout","TableEnumOrId":"01I4x000000VYCnEAO"},{"Id":"00h4x000003wlu6AAA","Name":"Account (Marketing) Layout","TableEnumOrId":"Account"},{"Id":"00h4x000003wlu7AAA","Name":"Account (Sales) Layout","TableEnumOrId":"Account"},{"Id":"00h4x000003wlu8AAA","Name":"Account (Support) Layout","TableEnumOrId":"Account"},{"Id":"00h4x000003wlu9AAA","Name":"Account Layout","TableEnumOrId":"Account"}]}';
    static final String API_RESPONSE_COMPACT_LAYOUT = '{"size":1,"totalSize":1,"done":true,"queryLocator":null,"entityTypeName":"CompactLayout","records":[{"Id":"0AH4x000001GwftGAC","DeveloperName":"Test_Compact_Layout","SobjectType":"Contact"}]}';
    static final String API_RESPONSE_FIELD_SETS = '{"size":1,"totalSize":1,"done":true,"queryLocator":null,"entityTypeName":"FieldSet","records":[{"Id":"0IX4x0000004YxgGAE","DeveloperName":"Contact_FieldSet_Test"}]}';
    static final String API_RESPONSE_VALIDATIONS = '{"size":1,"totalSize":1,"done":true,"queryLocator":null,"entityTypeName":"ValidationRule","records":[{"Id":"03d4x000000YbnEAAS","ValidationName":"Test_Validation","EntityDefinitionId":"Contact","Active":true}]}';
    static final String API_RESPONSE_LABELS = '{"size":1,"totalSize":1,"done":true,"queryLocator":null,"entityTypeName":"ExternalString","records":[{"Id":"1014x000007Abl4AAC","Name":"AssessmentReportSectionTitleIntro","Value":"Intro","Language":"en_US"}]}';
    static final String API_RESPONSE_FLOWS = '{"size":0,"totalSize":0,"done":true,"queryLocator":null,"entityTypeName":"Flow","records":[]}';
    static final String API_RESPONSE_WORKFLOWS = '{"size":0,"totalSize":0,"done":true,"queryLocator":null,"entityTypeName":"WorkflowRule","records":[]}';
    static final String API_RESPONSE_METADATA_READ_SHARING = '{"objectDescribeMap":{"Account":{"sharingCriteriaRules":[{"criteriaItems":{"value":"1","operation":"equals","field":"Name"},"sharedTo":{"allInternalUsers":""},"label":"Test","description":"Test","accountSettings":{"opportunityAccessLevel":"None","contactAccessLevel":"Read","caseAccessLevel":"None"},"accessLevel":"Read","fullName":"Test"},{"criteriaItems":{"value":"Z","operation":"equals","field":"Name"},"sharedTo":{"allInternalUsers":""},"label":"Test2","accountSettings":{"opportunityAccessLevel":"None","contactAccessLevel":"Read","caseAccessLevel":"None"},"accessLevel":"Read","fullName":"Test2"}],"fullName":"Account"}}}';
    static final String API_RESPONSE_METADATA_READ_REPORTS = '{"unfiled$public/New_Case_Test_Report_EvT":{"timeFrameFilter":{"interval":"INTERVAL_CURRENT","dateColumn":"Case$ClosedDate"},"showSubTotals":"true","showGrandTotal":"true","showDetails":"true","scope":"user","reportType":"Case_Test__c","params":{"value":"1","name":"co"},"name":"New Case Test Report","format":"Tabular","columns":[{"field":"Case$CaseNumber"},{"field":"Case.Activities$Subject"},{"field":"Case.Activities$Account"},{"field":"Case.Activities$Id"},{"field":"Case.Activities$Description"}],"fullName":"unfiled$public/New_Case_Test_Report_EvT"},"unfiled$public/New_Test_View_Report_bij":{"timeFrameFilter":{"interval":"INTERVAL_CURRENT","dateColumn":"Assessment__c$CreatedDate"},"showSubTotals":"true","showGrandTotal":"true","showDetails":"true","scope":"user","reportType":"Test_View__c","params":{"value":"1","name":"co"},"name":"New Test View Report","format":"Tabular","columns":[{"field":"Assessment__c$Name"},{"field":"Assessment__c$Status__c"}],"fullName":"unfiled$public/New_Test_View_Report_bij"},"unfiled$public/flow_screen_prebuilt_report":{"timeFrameFilter":{"interval":"INTERVAL_LAST7","dateColumn":"FlowInterviewLog$CreatedDate"},"showSubTotals":"true","showGrandTotal":"true","showDetails":"false","scope":"organization","reportType":"screen_flows_prebuilt_crt__c","params":{"value":"1","name":"co"},"name":"Sample Flow Report: Screen Flows","groupingsDown":[{"sortOrder":"Asc","field":"FlowInterviewLog$FlowDeveloperName","dateGranularity":"Day"},{"sortOrder":"Asc","field":"FlowInterviewLog$InterviewStatus","dateGranularity":"Day"}],"format":"Summary","description":"Which flows run, what’s the status of each interview, and how long do users take to complete the screens?","columns":[{"field":"FlowInterviewLog.FlowInterviewLogs$LogEntryType"},{"field":"FlowInterviewLog.FlowInterviewLogs$ElementApiName"},{"field":"FlowInterviewLog.FlowInterviewLogs$ElementDurationInMinutes","aggregateTypes":["Sum","Average"]},{"field":"FlowInterviewLog$InterviewStartTimestamp"},{"field":"FlowInterviewLog$CreatedBy"}],"chart":{"titleSize":"18","titleColor":"#000000","textSize":"12","textColor":"#000000","summaryAxisRange":"Auto","size":"Medium","showValues":"false","showTotal":"false","showPercentage":"false","showAxisLabels":"true","secondaryGroupingColumn":"FlowInterviewLog$InterviewStatus","location":"CHART_BOTTOM","legendPosition":"Right","groupingColumn":"FlowInterviewLog$FlowDeveloperName","expandOthers":"true","enableHoverLabels":"false","chartType":"HorizontalBarStacked","chartSummaries":{"column":"RowCount","axisBinding":"y"},"backgroundFadeDir":"Diagonal","backgroundColor2":"#FFFFFF","backgroundColor1":"#FFFFFF"},"fullName":"unfiled$public/flow_screen_prebuilt_report"},"unfiled$public/All_Accounts_Report_YKP":{"timeFrameFilter":{"interval":"INTERVAL_CUSTOM","dateColumn":"CREATED_DATE"},"showSubTotals":"true","showGrandTotal":"true","showDetails":"true","scope":"organization","reportType":"AccountList","params":{"value":"1","name":"co"},"name":"All Accounts Report","format":"Tabular","columns":[{"field":"DUE_DATE"},{"field":"USERS.NAME"},{"field":"ACCOUNT.NAME"},{"field":"ADDRESS1_STATE"},{"field":"TYPE"},{"field":"RATING"},{"field":"LAST_UPDATE"}],"fullName":"unfiled$public/All_Accounts_Report_YKP"}}';
    static final String API_RESPONSE_METADATA_READ_REPORTTYPES = '{"Case_Test":{"type":"ReportType","manageableState":"unmanaged","lastModifiedDate":"2021-03-22T21:36:43.000Z","lastModifiedByName":"Adam Mazzella","lastModifiedById":"0054x0000023y5iAAA","id":"0704x000000Ls2oAAC","fullName":"Case_Test","fileName":"reportTypes/Case_Test.reportType","createdDate":"2021-03-22T21:36:43.000Z","createdByName":"Adam Mazzella","createdById":"0054x0000023y5iAAA"},"Test_View":{"type":"ReportType","manageableState":"unmanaged","lastModifiedDate":"2021-03-22T21:35:46.000Z","lastModifiedByName":"Adam Mazzella","lastModifiedById":"0054x0000023y5iAAA","id":"0704x000000Ls2eAAC","fullName":"Test_View","fileName":"reportTypes/Test_View.reportType","createdDate":"2021-03-22T21:35:46.000Z","createdByName":"Adam Mazzella","createdById":"0054x0000023y5iAAA"},"screen_flows_prebuilt_crt":{"type":"ReportType","manageableState":"unmanaged","lastModifiedDate":"2020-12-16T18:28:22.000Z","lastModifiedByName":"Automated Process","lastModifiedById":"0054x000002eKJSAA2","id":"0704x0000019hFGAAY","fullName":"screen_flows_prebuilt_crt","fileName":"reportTypes/screen_flows_prebuilt_crt.reportType","createdDate":"2020-12-16T18:28:22.000Z","createdByName":"Automated Process","createdById":"0054x000002eKJSAA2"}}';
    static final String API_RESPONSE_METADATA_LIST_REPORTTYPES = '{"Test_View":{"sections":{"masterLabel":"Assessments","columns":[{"table":"Assessment__c","field":"Id","checkedByDefault":"false"},{"table":"Assessment__c","field":"Owner","checkedByDefault":"false"},{"table":"Assessment__c","field":"Name","checkedByDefault":"true"},{"table":"Assessment__c","field":"CreatedDate","checkedByDefault":"false"},{"table":"Assessment__c","field":"CreatedBy","checkedByDefault":"false"},{"table":"Assessment__c","field":"LastModifiedDate","checkedByDefault":"false"},{"table":"Assessment__c","field":"LastModifiedBy","checkedByDefault":"false"},{"table":"Assessment__c","field":"Status__c","checkedByDefault":"false"},{"table":"Assessment__c","field":"Selected_Products__c","checkedByDefault":"false"},{"table":"Assessment__c","field":"Is_B2C__c","checkedByDefault":"false"},{"table":"Assessment__c","field":"Has_Relationship_Groups__c","checkedByDefault":"false"},{"table":"Assessment__c","field":"Upgrade_Recommendation__c","checkedByDefault":"false"},{"table":"Assessment__c","field":"MappingDataJSON__c","checkedByDefault":"false"},{"table":"Assessment__c","field":"AnalysisDataJSON__c","checkedByDefault":"false"},{"table":"Assessment__c","field":"Customer_Representation__c","checkedByDefault":"false"},{"table":"Assessment__c","field":"Relationship_Groupings__c","checkedByDefault":"false"},{"table":"Assessment__c","field":"Has_Rollups__c","checkedByDefault":"false"},{"table":"Assessment__c","field":"Bulk_Scan_Complete__c","checkedByDefault":"false"},{"table":"Assessment__c","field":"External_Data_In_Salesforce__c","checkedByDefault":"false"},{"table":"Assessment__c","field":"Has_Apex_Sharing__c","checkedByDefault":"false"},{"table":"Assessment__c","field":"Current_Question_Id__c","checkedByDefault":"false"},{"table":"Assessment__c","field":"Current_Question_Number__c","checkedByDefault":"false"},{"table":"Assessment__c","field":"Financial_Accounts_Leveraged__c","checkedByDefault":"false"}]},"label":"Test View","description":"This is a test","deployed":"true","category":"other","baseObject":"Assessment__c","fullName":"Test_View"},"screen_flows_prebuilt_crt":{"sections":[{"masterLabel":"Flow Interview Logs","columns":[{"table":"FlowInterviewLog","field":"Id","checkedByDefault":"false"},{"table":"FlowInterviewLog","field":"CreatedDate","checkedByDefault":"false"},{"table":"FlowInterviewLog","field":"CreatedBy","checkedByDefault":"false"},{"table":"FlowInterviewLog","field":"LastModifiedDate","checkedByDefault":"false"},{"table":"FlowInterviewLog","field":"LastModifiedBy","checkedByDefault":"false"},{"table":"FlowInterviewLog","field":"FlowDeveloperName","checkedByDefault":"false"},{"table":"FlowInterviewLog","field":"FlowInterviewGuid","checkedByDefault":"false"},{"table":"FlowInterviewLog","field":"FlowVersionNumber","checkedByDefault":"false"},{"table":"FlowInterviewLog","field":"InterviewStartTimestamp","checkedByDefault":"false"},{"table":"FlowInterviewLog","field":"InterviewEndTimestamp","checkedByDefault":"false"},{"table":"FlowInterviewLog","field":"InterviewDurationInMinutes","checkedByDefault":"false"},{"table":"FlowInterviewLog","field":"InterviewStatus","checkedByDefault":"false"},{"table":"FlowInterviewLog","field":"FlowNamespace","checkedByDefault":"false"}]},{"masterLabel":"Flow Interview Log Entries","columns":[{"table":"FlowInterviewLog.FlowInterviewLogs","field":"Id","checkedByDefault":"false"},{"table":"FlowInterviewLog.FlowInterviewLogs","field":"CreatedDate","checkedByDefault":"false"},{"table":"FlowInterviewLog.FlowInterviewLogs","field":"CreatedBy","checkedByDefault":"false"},{"table":"FlowInterviewLog.FlowInterviewLogs","field":"LastModifiedDate","checkedByDefault":"false"},{"table":"FlowInterviewLog.FlowInterviewLogs","field":"LastModifiedBy","checkedByDefault":"false"},{"table":"FlowInterviewLog.FlowInterviewLogs","field":"LogEntryType","checkedByDefault":"false"},{"table":"FlowInterviewLog.FlowInterviewLogs","field":"ElementApiName","checkedByDefault":"false"},{"table":"FlowInterviewLog.FlowInterviewLogs","field":"LogEntryTimestamp","checkedByDefault":"false"},{"table":"FlowInterviewLog.FlowInterviewLogs","field":"DurationSinceStartInMinutes","checkedByDefault":"false"},{"table":"FlowInterviewLog.FlowInterviewLogs","field":"ElementDurationInMinutes","checkedByDefault":"false"}]}],"label":"Screen Flows","join":{"relationship":"FlowInterviewLogs","outerJoin":"false"},"description":"Find out which flows get executed and how long users take to complete each flow screen.","deployed":"true","category":"other","baseObject":"FlowInterviewLog","autogenerated":"true","fullName":"screen_flows_prebuilt_crt"},"Case_Test":{"sections":[{"masterLabel":"Cases","columns":[{"table":"Case","field":"Id","checkedByDefault":"false"},{"table":"Case","field":"CaseNumber","checkedByDefault":"true"},{"table":"Case","field":"Contact","checkedByDefault":"false"},{"table":"Case","field":"Account","checkedByDefault":"false"},{"table":"Case","field":"Asset","checkedByDefault":"false"},{"table":"Case","field":"Parent","checkedByDefault":"false"},{"table":"Case","field":"SuppliedName","checkedByDefault":"false"},{"table":"Case","field":"SuppliedEmail","checkedByDefault":"false"},{"table":"Case","field":"SuppliedPhone","checkedByDefault":"false"},{"table":"Case","field":"SuppliedCompany","checkedByDefault":"false"},{"table":"Case","field":"Type","checkedByDefault":"false"},{"table":"Case","field":"Status","checkedByDefault":"false"},{"table":"Case","field":"Reason","checkedByDefault":"false"},{"table":"Case","field":"Origin","checkedByDefault":"false"},{"table":"Case","field":"Subject","checkedByDefault":"false"},{"table":"Case","field":"Priority","checkedByDefault":"false"},{"table":"Case","field":"Description","checkedByDefault":"false"},{"table":"Case","field":"IsClosed","checkedByDefault":"false"},{"table":"Case","field":"ClosedDate","checkedByDefault":"false"},{"table":"Case","field":"IsEscalated","checkedByDefault":"false"},{"table":"Case","field":"Owner","checkedByDefault":"false"},{"table":"Case","field":"CreatedDate","checkedByDefault":"false"},{"table":"Case","field":"CreatedBy","checkedByDefault":"false"},{"table":"Case","field":"LastModifiedDate","checkedByDefault":"false"},{"table":"Case","field":"LastModifiedBy","checkedByDefault":"false"},{"table":"Case","field":"EngineeringReqNumber__c","checkedByDefault":"false"},{"table":"Case","field":"SLAViolation__c","checkedByDefault":"false"},{"table":"Case","field":"Product__c","checkedByDefault":"false"},{"table":"Case","field":"PotentialLiability__c","checkedByDefault":"false"}]},{"masterLabel":"Activities","columns":[{"table":"Case.Activities","field":"IsTask","checkedByDefault":"false"},{"table":"Case.Activities","field":"Id","checkedByDefault":"false"},{"table":"Case.Activities","field":"Who","checkedByDefault":"false"},{"table":"Case.Activities","field":"Subject","checkedByDefault":"true"},{"table":"Case.Activities","field":"ActivityDate","checkedByDefault":"false"},{"table":"Case.Activities","field":"ActivityTimeOnly","checkedByDefault":"false"},{"table":"Case.Activities","field":"Status","checkedByDefault":"false"},{"table":"Case.Activities","field":"Priority","checkedByDefault":"false"},{"table":"Case.Activities","field":"Owner","checkedByDefault":"false"},{"table":"Case.Activities","field":"Description","checkedByDefault":"false"},{"table":"Case.Activities","field":"Account","checkedByDefault":"false"},{"table":"Case.Activities","field":"IsClosed","checkedByDefault":"false"},{"table":"Case.Activities","field":"CreatedDate","checkedByDefault":"false"},{"table":"Case.Activities","field":"CreatedBy","checkedByDefault":"false"},{"table":"Case.Activities","field":"LastModifiedDate","checkedByDefault":"false"},{"table":"Case.Activities","field":"LastModifiedBy","checkedByDefault":"false"},{"table":"Case.Activities","field":"CallDurationInSeconds","checkedByDefault":"false"},{"table":"Case.Activities","field":"CallType","checkedByDefault":"false"},{"table":"Case.Activities","field":"CallDisposition","checkedByDefault":"false"},{"table":"Case.Activities","field":"CallObject","checkedByDefault":"false"},{"table":"Case.Activities","field":"RecurrenceRegeneratedType","checkedByDefault":"false"},{"table":"Case.Activities","field":"TaskSubtype","checkedByDefault":"false"},{"table":"Case.Activities","field":"CompletedDateTime","checkedByDefault":"false"},{"table":"Case.Activities","field":"Location","checkedByDefault":"false"},{"table":"Case.Activities","field":"IsAllDayEvent","checkedByDefault":"false"},{"table":"Case.Activities","field":"ActivityDateTime","checkedByDefault":"false"},{"table":"Case.Activities","field":"DurationInMinutes","checkedByDefault":"false"},{"table":"Case.Activities","field":"IsPrivate","checkedByDefault":"false"},{"table":"Case.Activities","field":"ShowAs","checkedByDefault":"false"},{"table":"Case.Activities","field":"IsChild","checkedByDefault":"false"},{"table":"Case.Activities","field":"IsGroupEvent","checkedByDefault":"false"},{"table":"Case.Activities","field":"GroupEventType","checkedByDefault":"false"},{"table":"Case.Activities","field":"EventSubtype","checkedByDefault":"false"}]}],"label":"Case Test","join":{"relationship":"Activities","outerJoin":"true"},"description":"This is also a test","deployed":"true","category":"other","baseObject":"Case","fullName":"Case_Test"}}';
    static final String USER_MAPPING_JSON = '{"recommended":[{"mappingData":[{"destination":"Account","fieldMapping":[{"source":"LastName","destination":"LastName"}],"recordTypeMapping":[{"source":"Master","destination":"PersonAccount"}],"showDetails":true,"source":"Contact"}],"sectionName":"People (B2C)"},{"mappingData":[{"destination":"FinServ__FinancialAccount__c","fieldMapping":[{"source":"Name","destination":"Name"}],"recordTypeMapping":[{"source":"Master","destination":"CheckingAccount"}],"showDetails":true,"source":"Assessment__c"},{"destination":"FinServ__FinancialAccountRole__c","fieldMapping":[{}],"recordTypeMapping":[{}],"source":""}],"sectionName":"Checking Account"}],"additional":[]}';
    static final String APEX_SHARING_ANALYSIS_JSON = '[]'; //TODO

    @IsTest
    static void generateAnalysis_All(){
        Assessment__c mainAssessment = getTestAssessment();

        MockResponse mockResponses = new MockResponse(ExternalUtilities.HTTP_RESPONSE_CODE_SUCCESS, API_RESPONSE_CUSTOM_OBJECT); //tooling Custom Objects response
        mockResponses.addResponse(ExternalUtilities.HTTP_RESPONSE_CODE_SUCCESS, API_RESPONSE_LAYOUTS);  //tooling Layouts response
        mockResponses.addResponse(ExternalUtilities.HTTP_RESPONSE_CODE_SUCCESS, API_RESPONSE_COMPACT_LAYOUT);  //tooling CompactLayout response
        //mockResponses.addResponse(ExternalUtilities.HTTP_RESPONSE_CODE_SUCCESS, API_RESPONSE_FIELD_SETS);  //tooling FieldSet response
        mockResponses.addResponse(ExternalUtilities.HTTP_RESPONSE_CODE_SUCCESS, API_RESPONSE_VALIDATIONS);  //tooling ValidationRule response
        mockResponses.addResponse(ExternalUtilities.HTTP_RESPONSE_CODE_SUCCESS, API_RESPONSE_FLOWS);  //tooling Flows response
        mockResponses.addResponse(ExternalUtilities.HTTP_RESPONSE_CODE_SUCCESS, API_RESPONSE_WORKFLOWS);  //tooling Workflows response
        mockResponses.addResponse(ExternalUtilities.HTTP_RESPONSE_CODE_SUCCESS, API_RESPONSE_METADATA_READ_REPORTS); //metadata api reports
        mockResponses.addResponse(ExternalUtilities.HTTP_RESPONSE_CODE_SUCCESS, API_RESPONSE_METADATA_LIST_REPORTTYPES); //metadata api reports
        mockResponses.addResponse(ExternalUtilities.HTTP_RESPONSE_CODE_SUCCESS, API_RESPONSE_METADATA_READ_REPORTTYPES); //metadata api reports
        mockResponses.addResponse(ExternalUtilities.HTTP_RESPONSE_CODE_SUCCESS, API_RESPONSE_LABELS);  //tooling Labels response
        mockResponses.addResponse(ExternalUtilities.HTTP_RESPONSE_CODE_SUCCESS, API_RESPONSE_METADATA_READ_SHARING);  //metadata sharing rules response
        Test.setMock(HttpCalloutMock.class, mockResponses);
        Test.startTest();

        TransitionAnalysis transitionAnalysis = new TransitionAnalysis(mainAssessment.Id).generateAnalysis(getMockMetadataComponentDependencies());

        Test.stopTest();

        System.assertNotEquals(null, transitionAnalysis.assessmentResults, 'Assessment Results should be generated for this scenario');
        System.assertNotEquals(null, transitionAnalysis.migrationAnalysis, 'Migration Analysis should be generated for this scenario');
        System.assertNotEquals(null, transitionAnalysis.accessInfoResults, 'Access permission results should be generated for this scenario');
        System.assertNotEquals(null, transitionAnalysis.sharingSettingResults, 'Sharing settings should be generated for this scenario');
    }

    @IsTest
    static void buildAccessInfoResults() {
        Set<String> setupObjects = new Set<String> { 'Account' };
        Set<String> setupFields = new Set<String> { 'Account.Phone' };

        Test.startTest();

        List<TransitionAnalysis.MigrationAnalysisItem> result = TransitionAnalysis.buildAccessInfoResults(setupObjects, setupFields);

        Test.stopTest();

        System.assertNotEquals(null, result, 'A list of MigrationAnalysisItem should be returned');
    }

    @IsTest
    static void buildSharingSettingsResults() {
        Map<String, String> sourceToDestinationObject = new Map<String, String> {
            'Account' => '',
            'Contact' => '',
            'Assessment' => ''
        };

        Set<String> mappedObjects = new Set<String> {
            'Account',
            'Contact',
            'Assessment__c'
        };

        Assessment__c assessment = getTestAssessment();

        MockResponse mockResponses = new MockResponse(ExternalUtilities.HTTP_RESPONSE_CODE_SUCCESS, API_RESPONSE_METADATA_READ_SHARING); //metadata read response
        Test.setMock(HttpCalloutMock.class, mockResponses);
        Test.startTest();

        List<TransitionAnalysis.MigrationAnalysisItem> sharingAnalysisItems = TransitionAnalysis.buildSharingSettingResults(assessment, sourceToDestinationObject, mappedObjects);

        Test.stopTest();

        System.assertEquals(sourceToDestinationObject.size(), sharingAnalysisItems.size(), 'Sharing Analysis should have returned the same amount of results as the setup map');
    }

    @TestSetup
    static void makeData(){
        Assessment__c mainAssessment = new Assessment__c(
            Status__c = NEW_ASSESSMENT_STATUS,
            Selected_Products__c = NEW_ASSESSMENT_PRODUCTS,
            MappingDataJSON__c = USER_MAPPING_JSON,
            Is_B2C__c = NEW_ASSESSMENT_TEST_B2C,
            ApexShareAnalysisJSON__c = APEX_SHARING_ANALYSIS_JSON
        );

        insert mainAssessment;
    }

    private static Assessment__c getTestAssessment(){
        return [SELECT Id, Status__c, Selected_Products__c, ApexShareAnalysisJSON__c FROM Assessment__c WHERE Status__c = :NEW_ASSESSMENT_STATUS AND Selected_Products__c = :NEW_ASSESSMENT_PRODUCTS LIMIT 1];
    }

    private static List<ToolingService.MetadataComponentDependency> getMockMetadataComponentDependencies() {
        ToolingService.MetadataComponentDependency accountDependency = new ToolingService.MetadataComponentDependency();
        accountDependency.MetadataComponentId = Utilities.uuid();
        accountDependency.MetadataComponentName = 'AccountTrigger';
        accountDependency.MetadataComponentType = 'ApexTrigger';
        accountDependency.RefMetadataComponentId = Utilities.uuid();
        accountDependency.RefMetadataComponentName = 'Account';
        accountDependency.RefMetadataComponentType = 'StandardEntity';

        ToolingService.MetadataComponentDependency assessmentDependency = new ToolingService.MetadataComponentDependency();
        assessmentDependency.MetadataComponentId = Utilities.uuid();
        assessmentDependency.MetadataComponentName = 'AssessmentTrigger';
        assessmentDependency.MetadataComponentType = 'ApexTrigger';
        assessmentDependency.RefMetadataComponentId = Utilities.uuid();
        assessmentDependency.RefMetadataComponentName = 'Assessment__c';
        assessmentDependency.RefMetadataComponentType = 'CustomObject';

        ToolingService.MetadataComponentDependency assessmentFieldDependency = new ToolingService.MetadataComponentDependency();
        assessmentFieldDependency.MetadataComponentId = Utilities.uuid();
        assessmentFieldDependency.MetadataComponentName = 'Assessment Layout';
        assessmentFieldDependency.MetadataComponentType = 'Layout';
        assessmentFieldDependency.RefMetadataComponentId = Utilities.uuid();
        assessmentFieldDependency.RefMetadataComponentName = 'AssessmentField__c';
        assessmentFieldDependency.RefMetadataComponentType = 'CustomField';

        return new List<ToolingService.MetadataComponentDependency> {
            accountDependency,
            assessmentDependency,
            assessmentFieldDependency
        };
    }
}