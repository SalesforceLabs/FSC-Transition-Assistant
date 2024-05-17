@isTest
private class DependencyHelperTest {
    static final String TOOLING_RESPONSE_LAYOUTS = '{"size":2,"totalSize":2,"done":true,"queryLocator":null,"entityTypeName":"Layout","records":[{"Id":"00h1D000003Uh2rQAC","Name":"Approval Page Layout: Contact Approval 04a1D0000000Jtg","TableEnumOrId":"Contact"},{"Id":"00h1D000003UW5NQAW","Name":"Contact Layout","TableEnumOrId":"Contact"}]}';
    static final String TOOLING_RESPONSE_LAYOUTS_NAME = '{"size":1,"totalSize":1,"done":true,"queryLocator":null,"entityTypeName":"Layout","records":[{"Id":"00h1D000003UW5NQAW","Name":"Contact Layout","TableEnumOrId":"Contact"}]}';
    static final String TOOLING_RESPONSE_COMPACT_LAYOUT = '{"size":1,"totalSize":1,"done":true,"queryLocator":null,"entityTypeName":"CompactLayout","records":[{"Id":"0AH4x000001GwftGAC","DeveloperName":"Test_Compact_Layout","SobjectType":"Contact"}]}';
    static final String TOOLING_RESPONSE_FIELD_SETS = '{"size":1,"totalSize":1,"done":true,"queryLocator":null,"entityTypeName":"FieldSet","records":[{"Id":"0IX4x0000004YxgGAE","DeveloperName":"Contact_FieldSet_Test"}]}';
    static final String TOOLING_RESPONSE_FLOWS = '{"size":3,"totalSize":3,"done":true,"queryLocator":null,"entityTypeName":"Flow","records":[{"Id":"30154000000IZDrAAO","Definition":{"attributes":{"type":"FlowDefinition","url":"/services/data/v51.0/tooling/sobjects/FlowDefinition/300540000005wUjAAI"},"DeveloperName":"Contact_Process"},"IsTemplate":false,"MasterLabel":"Contact Process","ProcessType":"Workflow"},{"Id":"30154000000IZELAA4","Definition":{"attributes":{"type":"FlowDefinition","url":"/services/data/v51.0/tooling/sobjects/FlowDefinition/300540000005wUtAAI"},"DeveloperName":"Contact_Trigger_Flow_Test"},"IsTemplate":false,"MasterLabel":"Contact Trigger Flow Test","ProcessType":"AutoLaunchedFlow"},{"Id":"30154000000IZHAAA4","Definition":{"attributes":{"type":"FlowDefinition","url":"/services/data/v51.0/tooling/sobjects/FlowDefinition/300540000005wUyAAI"},"DeveloperName":"Contact_Screen_Flow_Test"},"IsTemplate":false,"MasterLabel":"Contact Screen Flow Test","ProcessType":"Flow"}]}';
    static final String TOOLING_RESPONSE_WORKFLOWS = '{"size":1,"totalSize":1,"done":true,"queryLocator":null,"entityTypeName":"WorkflowRule","records":[{"Id":"01Q1D000000BKdUUAW","Name":"Contact Awesome Workflow","TableEnumOrId":"Contact"}]}';
    static final String TOOLING_RESPONSE_WORKFLOW_ALERTS = '{"size":1,"totalSize":1,"done":true,"queryLocator":null,"entityTypeName":"WorkflowAlert","records":[{"Id":"01W1D0000000TRgUAM","DeveloperName":"Contact_New","EntityDefinitionId":"Contact"}]}';
    static final String TOOLING_RESPONSE_WORKFLOW_UPDATES = '{"size":1,"totalSize":1,"done":true,"queryLocator":null,"entityTypeName":"WorkflowFieldUpdate","records":[{"Id":"04Y1D0000001iScUAI","Name":"Set owner changed date","SourceTableEnumOrId":"Bank_Account__c"}]}';
    static final String TOOLING_RESPONSE_WORKFLOW_MESSAGES = '{"size":0,"totalSize":0,"done":true,"queryLocator":null,"entityTypeName":"WorkflowOutboundMessage","records":[]}';
    static final String TOOLING_RESPONSE_WORKFLOW_TASKS = '{"size":0,"totalSize":0,"done":true,"queryLocator":null,"entityTypeName":"WorkflowTask","records":[]}';
    static final String TOOLING_RESPONSE_VALIDATIONS = '{"size":1,"totalSize":1,"done":true,"queryLocator":null,"entityTypeName":"ValidationRule","records":[{"Id":"03d4x000000YbnEAAS","ValidationName":"Test_Validation","EntityDefinitionId":"Contact","Active":true}]}';
    static final String METADATA_RESPONSE_READ_FLOW = '{"Contact_Process":{"variables":[{"objectType":"Contact","isOutput":"true","isInput":"true","isCollection":"false","dataType":"SObject","name":"myVariable_current"},{"objectType":"Contact","isOutput":"false","isInput":"true","isCollection":"false","dataType":"SObject","name":"myVariable_old"}],"status":"Active","startElementReference":"isChangedDecision2_myRule_1_LastName","recordUpdates":{"object":"Contact","inputAssignments":{"value":{"elementReference":"formula_3_myRule_1_A1_0457386180"},"field":"Description","processMetadataValues":[{"value":{"stringValue":"String"},"name":"dataType"},{"value":{"booleanValue":"false"},"name":"isRequired"},{"value":{"stringValue":"Contact Description"},"name":"leftHandSideLabel"},{"value":{"stringValue":""},"name":"leftHandSideReferenceTo"},{"value":{"stringValue":"Formula"},"name":"rightHandSideType"}]},"filters":{"value":{"elementReference":"myVariable_current.Id"},"operator":"EqualTo","field":"Id","processMetadataValues":{"value":{"booleanValue":"true"},"name":"implicit"}},"filterLogic":"and","locationY":"200","locationX":"100","label":"Update Detail","name":"myRule_1_A1","processMetadataValues":[{"value":{"stringValue":"always"},"name":"evaluationType"},{"name":"extraTypeInfo"},{"value":{"booleanValue":"false"},"name":"isChildRelationship"},{"value":{"stringValue":"[Contact]"},"name":"reference"},{"name":"referenceTargetField"}]},"processType":"Workflow","processMetadataValues":[{"value":{"stringValue":"Contact"},"name":"ObjectType"},{"value":{"elementReference":"myVariable_current"},"name":"ObjectVariable"},{"value":{"elementReference":"myVariable_old"},"name":"OldObjectVariable"},{"value":{"stringValue":"onAllChanges"},"name":"TriggerType"}],"label":"Contact Process","interviewLabel":"Contact_Process-1_InterviewLabel","formulas":{"expression":"\\"Date Changed: \\" + TEXT(NOW())","dataType":"String","name":"formula_3_myRule_1_A1_0457386180","processMetadataValues":{"value":{"stringValue":"\\"Date Changed: \\" + TEXT(NOW()) "},"name":"originalFormula"}},"decisions":[{"rules":{"label":"isChangedRule_2_myRule_1_LastName","connector":{"targetReference":"myDecision"},"conditions":[{"rightValue":{"booleanValue":"false"},"operator":"IsNull","leftValueReference":"myVariable_old"},{"rightValue":{"elementReference":"myVariable_current.LastName"},"operator":"NotEqualTo","leftValueReference":"myVariable_old.LastName"}],"conditionLogic":"and","name":"isChangedRule_2_myRule_1_LastName"},"defaultConnectorLabel":"default","defaultConnector":{"targetReference":"myDecision"},"locationY":"0","locationX":"0","label":"isChangedDecision2_myRule_1_LastName","name":"isChangedDecision2_myRule_1_LastName"},{"rules":{"label":"Contact Name Change","connector":{"targetReference":"myRule_1_A1"},"conditions":{"rightValue":{"booleanValue":"true"},"operator":"EqualTo","leftValueReference":"isChangedRule_2_myRule_1_LastName","processMetadataValues":[{"value":{"stringValue":"Boolean"},"name":"inputDataType"},{"value":{"stringValue":"String"},"name":"leftHandSideType"},{"value":{"stringValue":"String"},"name":"operatorDataType"},{"value":{"stringValue":"Boolean"},"name":"rightHandSideType"}]},"conditionLogic":"and","name":"myRule_1"},"defaultConnectorLabel":"default","locationY":"0","locationX":"50","label":"myDecision","name":"myDecision","processMetadataValues":{"value":{"numberValue":"0.0"},"name":"index"}}],"apiVersion":"51.0","fullName":"Contact_Process"},"Contact_Trigger_Flow_Test":{"status":"Active","start":{"triggerType":"RecordAfterSave","recordTriggerType":"Create","object":"Contact","connector":{"targetReference":"Test_Assignment"},"locationY":"0","locationX":"50"},"processType":"AutoLaunchedFlow","processMetadataValues":[{"value":{"stringValue":"LightningFlowBuilder"},"name":"BuilderType"},{"value":{"stringValue":"AUTO_LAYOUT_CANVAS"},"name":"CanvasMode"},{"value":{"stringValue":"LightningFlowBuilder"},"name":"OriginBuilderType"}],"label":"Contact Trigger Flow Test","interviewLabel":"Contact Trigger Flow Test {!$Flow.CurrentDateTime}","assignments":{"assignmentItems":{"operator":"Assign","assignToReference":"$Record.Birthdate"},"locationY":"311","locationX":"176","label":"Test Assignment","name":"Test_Assignment"},"apiVersion":"51.0","fullName":"Contact_Trigger_Flow_Test"},"Contact_Screen_Flow_Test":{"variables":{"isOutput":"false","isInput":"true","isCollection":"false","dataType":"String","name":"recordId"},"status":"Active","start":{"connector":{"targetReference":"Get_Contact"},"locationY":"0","locationX":"50"},"screens":{"showHeader":"false","showFooter":"false","fields":{"storeOutputAutomatically":"true","isRequired":"true","inputsOnNextNavToAssocScrn":"UseStoredValues","inputParameters":[{"value":{"elementReference":"Get_Contact.FirstName"},"name":"firstName"},{"value":{"elementReference":"Get_Contact.LastName"},"name":"lastName"}],"fieldType":"ComponentInstance","extensionName":"flowruntime:name","name":"NameScreen"},"connector":{"targetReference":"Create_Contact"},"allowPause":"true","allowFinish":"true","allowBack":"true","locationY":"398","locationX":"176","label":"NameScreenUI","name":"NameScreenUI"},"recordUpdates":[{"inputReference":"Get_Contact","connector":{"targetReference":"NameScreenUI"},"locationY":"278","locationX":"176","label":"Update Contact","name":"Update_Contact"},{"object":"Contact","inputAssignments":{"value":{"stringValue":""},"field":"Email"},"filters":{"value":{"elementReference":"Get_Contact.Id"},"operator":"EqualTo","field":"Id"},"filterLogic":"and","locationY":"758","locationX":"176","label":"Update Specific Fields","name":"Update_Specific_Fields"}],"recordLookups":{"storeOutputAutomatically":"true","object":"Contact","getFirstRecordOnly":"true","filters":{"value":{"elementReference":"recordId"},"operator":"EqualTo","field":"Id"},"filterLogic":"and","connector":{"targetReference":"Update_Contact"},"assignNullValuesIfNoRecordsFound":"false","locationY":"158","locationX":"176","label":"Get Contact","name":"Get_Contact"},"recordDeletes":{"inputReference":"Get_Contact","connector":{"targetReference":"Update_Specific_Fields"},"locationY":"638","locationX":"176","label":"Delete Contact","name":"Delete_Contact"},"recordCreates":{"inputReference":"Get_Contact","connector":{"targetReference":"Delete_Contact"},"locationY":"518","locationX":"176","label":"Create Contact","name":"Create_Contact"},"processType":"Flow","processMetadataValues":[{"value":{"stringValue":"LightningFlowBuilder"},"name":"BuilderType"},{"value":{"stringValue":"AUTO_LAYOUT_CANVAS"},"name":"CanvasMode"},{"value":{"stringValue":"LightningFlowBuilder"},"name":"OriginBuilderType"}],"label":"Contact Screen Flow Test","interviewLabel":"Contact Screen Flow Test {!$Flow.CurrentDateTime}","apiVersion":"51.0","fullName":"Contact_Screen_Flow_Test"}}';
    static final String METADATA_RESPONSE_READ_WORKFLOW = '{"Contact":{"fullName":"Contact","alerts":{"fullName":"Notify_Owner_On_Birthday","description":"Notify Owner On Birthday","protected":"false","recipients":{"type":"owner"},"senderType":"CurrentUser","template":"unfiled$public/ContactFollowUpSAMPLE"},"fieldUpdates":{"fullName":"Update_Fax","field":"Fax","formula":"Phone","name":"Update Fax","notifyAssignee":"false","operation":"Formula","protected":"false","reevaluateOnChange":"false"},"outboundMessages":{"fullName":"Test_Outbound_Message","apiVersion":"51.0","endpointUrl":"https://fakeendpoint.salesforce.com","fields":["AccountId","Birthdate","Id","MailingCity"],"includeSessionId":"false","integrationUser":"sam@zennify.com.fscupgrade.enterprise","name":"Test Outbound Message","protected":"false","useDeadLetterQueue":"false"},"rules":[{"fullName":"Contact Awesome Workflow","actions":{"name":"Notify_Owner_On_Birthday","type":"Alert"},"active":"true","criteriaItems":{"field":"Contact.Birthdate","operation":"notEqual"},"triggerType":"onCreateOrTriggeringUpdate"},{"fullName":"Second Rule on Contact","actions":[{"name":"Update_Fax","type":"FieldUpdate"},{"name":"Test_Outbound_Message","type":"OutboundMessage"},{"name":"Task_Assigned","type":"Task"}],"active":"false","criteriaItems":{"field":"Contact.Fax","operation":"notEqual"},"triggerType":"onCreateOnly"}],"tasks":{"fullName":"Task_Assigned","assignedToType":"owner","dueDateOffset":"3","notifyAssignee":"false","priority":"Normal","protected":"false","status":"Not Started","subject":"Task Assigned"}}}';
    static final String METADATA_RESPONSE_READ_REPORTS = '{"unfiled$public/New_Case_Test_Report_EvT":{"timeFrameFilter":{"interval":"INTERVAL_CURRENT","dateColumn":"Case$ClosedDate"},"showSubTotals":"true","showGrandTotal":"true","showDetails":"true","scope":"user","reportType":"Case_Test__c","params":{"value":"1","name":"co"},"name":"New Case Test Report","format":"Tabular","columns":[{"field":"Case$CaseNumber"},{"field":"Case.Activities$Subject"},{"field":"Case.Activities$Account"},{"field":"Case.Activities$Id"},{"field":"Case.Activities$Description"}],"fullName":"unfiled$public/New_Case_Test_Report_EvT"},"unfiled$public/New_Test_View_Report_bij":{"timeFrameFilter":{"interval":"INTERVAL_CURRENT","dateColumn":"Assessment__c$CreatedDate"},"showSubTotals":"true","showGrandTotal":"true","showDetails":"true","scope":"user","reportType":"Test_View__c","params":{"value":"1","name":"co"},"name":"New Test View Report","format":"Tabular","columns":[{"field":"Assessment__c$Name"},{"field":"Assessment__c$Status__c"}],"fullName":"unfiled$public/New_Test_View_Report_bij"},"unfiled$public/flow_screen_prebuilt_report":{"timeFrameFilter":{"interval":"INTERVAL_LAST7","dateColumn":"FlowInterviewLog$CreatedDate"},"showSubTotals":"true","showGrandTotal":"true","showDetails":"false","scope":"organization","reportType":"screen_flows_prebuilt_crt__c","params":{"value":"1","name":"co"},"name":"Sample Flow Report: Screen Flows","groupingsDown":[{"sortOrder":"Asc","field":"FlowInterviewLog$FlowDeveloperName","dateGranularity":"Day"},{"sortOrder":"Asc","field":"FlowInterviewLog$InterviewStatus","dateGranularity":"Day"}],"format":"Summary","description":"Which flows run, what’s the status of each interview, and how long do users take to complete the screens?","columns":[{"field":"FlowInterviewLog.FlowInterviewLogs$LogEntryType"},{"field":"FlowInterviewLog.FlowInterviewLogs$ElementApiName"},{"field":"FlowInterviewLog.FlowInterviewLogs$ElementDurationInMinutes","aggregateTypes":["Sum","Average"]},{"field":"FlowInterviewLog$InterviewStartTimestamp"},{"field":"FlowInterviewLog$CreatedBy"}],"chart":{"titleSize":"18","titleColor":"#000000","textSize":"12","textColor":"#000000","summaryAxisRange":"Auto","size":"Medium","showValues":"false","showTotal":"false","showPercentage":"false","showAxisLabels":"true","secondaryGroupingColumn":"FlowInterviewLog$InterviewStatus","location":"CHART_BOTTOM","legendPosition":"Right","groupingColumn":"FlowInterviewLog$FlowDeveloperName","expandOthers":"true","enableHoverLabels":"false","chartType":"HorizontalBarStacked","chartSummaries":{"column":"RowCount","axisBinding":"y"},"backgroundFadeDir":"Diagonal","backgroundColor2":"#FFFFFF","backgroundColor1":"#FFFFFF"},"fullName":"unfiled$public/flow_screen_prebuilt_report"},"unfiled$public/All_Accounts_Report_YKP":{"timeFrameFilter":{"interval":"INTERVAL_CUSTOM","dateColumn":"CREATED_DATE"},"showSubTotals":"true","showGrandTotal":"true","showDetails":"true","scope":"organization","reportType":"AccountList","params":{"value":"1","name":"co"},"name":"All Accounts Report","format":"Tabular","columns":[{"field":"DUE_DATE"},{"field":"USERS.NAME"},{"field":"ACCOUNT.NAME"},{"field":"ADDRESS1_STATE"},{"field":"TYPE"},{"field":"RATING"},{"field":"LAST_UPDATE"}],"fullName":"unfiled$public/All_Accounts_Report_YKP"}}';
    static final String METADATA_RESPONSE_LIST_REPORTTYPES = '{"Case_Test":{"type":"ReportType","manageableState":"unmanaged","lastModifiedDate":"2021-03-22T21:36:43.000Z","lastModifiedByName":"Adam Mazzella","lastModifiedById":"0054x0000023y5iAAA","id":"0704x000000Ls2oAAC","fullName":"Case_Test","fileName":"reportTypes/Case_Test.reportType","createdDate":"2021-03-22T21:36:43.000Z","createdByName":"Adam Mazzella","createdById":"0054x0000023y5iAAA"},"Test_View":{"type":"ReportType","manageableState":"unmanaged","lastModifiedDate":"2021-03-22T21:35:46.000Z","lastModifiedByName":"Adam Mazzella","lastModifiedById":"0054x0000023y5iAAA","id":"0704x000000Ls2eAAC","fullName":"Test_View","fileName":"reportTypes/Test_View.reportType","createdDate":"2021-03-22T21:35:46.000Z","createdByName":"Adam Mazzella","createdById":"0054x0000023y5iAAA"},"screen_flows_prebuilt_crt":{"type":"ReportType","manageableState":"unmanaged","lastModifiedDate":"2020-12-16T18:28:22.000Z","lastModifiedByName":"Automated Process","lastModifiedById":"0054x000002eKJSAA2","id":"0704x0000019hFGAAY","fullName":"screen_flows_prebuilt_crt","fileName":"reportTypes/screen_flows_prebuilt_crt.reportType","createdDate":"2020-12-16T18:28:22.000Z","createdByName":"Automated Process","createdById":"0054x000002eKJSAA2"}}';
    static final String METADATA_RESPONSE_READ_REPORTTYPES = '{"Test_View":{"sections":{"masterLabel":"Assessments","columns":[{"table":"Assessment__c","field":"Id","checkedByDefault":"false"},{"table":"Assessment__c","field":"Owner","checkedByDefault":"false"},{"table":"Assessment__c","field":"Name","checkedByDefault":"true"},{"table":"Assessment__c","field":"CreatedDate","checkedByDefault":"false"},{"table":"Assessment__c","field":"CreatedBy","checkedByDefault":"false"},{"table":"Assessment__c","field":"LastModifiedDate","checkedByDefault":"false"},{"table":"Assessment__c","field":"LastModifiedBy","checkedByDefault":"false"},{"table":"Assessment__c","field":"Status__c","checkedByDefault":"false"},{"table":"Assessment__c","field":"Selected_Products__c","checkedByDefault":"false"},{"table":"Assessment__c","field":"Is_B2C__c","checkedByDefault":"false"},{"table":"Assessment__c","field":"Has_Relationship_Groups__c","checkedByDefault":"false"},{"table":"Assessment__c","field":"Upgrade_Recommendation__c","checkedByDefault":"false"},{"table":"Assessment__c","field":"MappingDataJSON__c","checkedByDefault":"false"},{"table":"Assessment__c","field":"AnalysisDataJSON__c","checkedByDefault":"false"},{"table":"Assessment__c","field":"Customer_Representation__c","checkedByDefault":"false"},{"table":"Assessment__c","field":"Relationship_Groupings__c","checkedByDefault":"false"},{"table":"Assessment__c","field":"Has_Rollups__c","checkedByDefault":"false"},{"table":"Assessment__c","field":"Bulk_Scan_Complete__c","checkedByDefault":"false"},{"table":"Assessment__c","field":"External_Data_In_Salesforce__c","checkedByDefault":"false"},{"table":"Assessment__c","field":"Has_Apex_Sharing__c","checkedByDefault":"false"},{"table":"Assessment__c","field":"Current_Question_Id__c","checkedByDefault":"false"},{"table":"Assessment__c","field":"Current_Question_Number__c","checkedByDefault":"false"},{"table":"Assessment__c","field":"Financial_Accounts_Leveraged__c","checkedByDefault":"false"}]},"label":"Test View","description":"This is a test","deployed":"true","category":"other","baseObject":"Assessment__c","fullName":"Test_View"},"screen_flows_prebuilt_crt":{"sections":[{"masterLabel":"Flow Interview Logs","columns":[{"table":"FlowInterviewLog","field":"Id","checkedByDefault":"false"},{"table":"FlowInterviewLog","field":"CreatedDate","checkedByDefault":"false"},{"table":"FlowInterviewLog","field":"CreatedBy","checkedByDefault":"false"},{"table":"FlowInterviewLog","field":"LastModifiedDate","checkedByDefault":"false"},{"table":"FlowInterviewLog","field":"LastModifiedBy","checkedByDefault":"false"},{"table":"FlowInterviewLog","field":"FlowDeveloperName","checkedByDefault":"false"},{"table":"FlowInterviewLog","field":"FlowInterviewGuid","checkedByDefault":"false"},{"table":"FlowInterviewLog","field":"FlowVersionNumber","checkedByDefault":"false"},{"table":"FlowInterviewLog","field":"InterviewStartTimestamp","checkedByDefault":"false"},{"table":"FlowInterviewLog","field":"InterviewEndTimestamp","checkedByDefault":"false"},{"table":"FlowInterviewLog","field":"InterviewDurationInMinutes","checkedByDefault":"false"},{"table":"FlowInterviewLog","field":"InterviewStatus","checkedByDefault":"false"},{"table":"FlowInterviewLog","field":"FlowNamespace","checkedByDefault":"false"}]},{"masterLabel":"Flow Interview Log Entries","columns":[{"table":"FlowInterviewLog.FlowInterviewLogs","field":"Id","checkedByDefault":"false"},{"table":"FlowInterviewLog.FlowInterviewLogs","field":"CreatedDate","checkedByDefault":"false"},{"table":"FlowInterviewLog.FlowInterviewLogs","field":"CreatedBy","checkedByDefault":"false"},{"table":"FlowInterviewLog.FlowInterviewLogs","field":"LastModifiedDate","checkedByDefault":"false"},{"table":"FlowInterviewLog.FlowInterviewLogs","field":"LastModifiedBy","checkedByDefault":"false"},{"table":"FlowInterviewLog.FlowInterviewLogs","field":"LogEntryType","checkedByDefault":"false"},{"table":"FlowInterviewLog.FlowInterviewLogs","field":"ElementApiName","checkedByDefault":"false"},{"table":"FlowInterviewLog.FlowInterviewLogs","field":"LogEntryTimestamp","checkedByDefault":"false"},{"table":"FlowInterviewLog.FlowInterviewLogs","field":"DurationSinceStartInMinutes","checkedByDefault":"false"},{"table":"FlowInterviewLog.FlowInterviewLogs","field":"ElementDurationInMinutes","checkedByDefault":"false"}]}],"label":"Screen Flows","join":{"relationship":"FlowInterviewLogs","outerJoin":"false"},"description":"Find out which flows get executed and how long users take to complete each flow screen.","deployed":"true","category":"other","baseObject":"FlowInterviewLog","autogenerated":"true","fullName":"screen_flows_prebuilt_crt"},"Case_Test":{"sections":[{"masterLabel":"Cases","columns":[{"table":"Case","field":"Id","checkedByDefault":"false"},{"table":"Case","field":"CaseNumber","checkedByDefault":"true"},{"table":"Case","field":"Contact","checkedByDefault":"false"},{"table":"Case","field":"Account","checkedByDefault":"false"},{"table":"Case","field":"Asset","checkedByDefault":"false"},{"table":"Case","field":"Parent","checkedByDefault":"false"},{"table":"Case","field":"SuppliedName","checkedByDefault":"false"},{"table":"Case","field":"SuppliedEmail","checkedByDefault":"false"},{"table":"Case","field":"SuppliedPhone","checkedByDefault":"false"},{"table":"Case","field":"SuppliedCompany","checkedByDefault":"false"},{"table":"Case","field":"Type","checkedByDefault":"false"},{"table":"Case","field":"Status","checkedByDefault":"false"},{"table":"Case","field":"Reason","checkedByDefault":"false"},{"table":"Case","field":"Origin","checkedByDefault":"false"},{"table":"Case","field":"Subject","checkedByDefault":"false"},{"table":"Case","field":"Priority","checkedByDefault":"false"},{"table":"Case","field":"Description","checkedByDefault":"false"},{"table":"Case","field":"IsClosed","checkedByDefault":"false"},{"table":"Case","field":"ClosedDate","checkedByDefault":"false"},{"table":"Case","field":"IsEscalated","checkedByDefault":"false"},{"table":"Case","field":"Owner","checkedByDefault":"false"},{"table":"Case","field":"CreatedDate","checkedByDefault":"false"},{"table":"Case","field":"CreatedBy","checkedByDefault":"false"},{"table":"Case","field":"LastModifiedDate","checkedByDefault":"false"},{"table":"Case","field":"LastModifiedBy","checkedByDefault":"false"},{"table":"Case","field":"EngineeringReqNumber__c","checkedByDefault":"false"},{"table":"Case","field":"SLAViolation__c","checkedByDefault":"false"},{"table":"Case","field":"Product__c","checkedByDefault":"false"},{"table":"Case","field":"PotentialLiability__c","checkedByDefault":"false"}]},{"masterLabel":"Activities","columns":[{"table":"Case.Activities","field":"IsTask","checkedByDefault":"false"},{"table":"Case.Activities","field":"Id","checkedByDefault":"false"},{"table":"Case.Activities","field":"Who","checkedByDefault":"false"},{"table":"Case.Activities","field":"Subject","checkedByDefault":"true"},{"table":"Case.Activities","field":"ActivityDate","checkedByDefault":"false"},{"table":"Case.Activities","field":"ActivityTimeOnly","checkedByDefault":"false"},{"table":"Case.Activities","field":"Status","checkedByDefault":"false"},{"table":"Case.Activities","field":"Priority","checkedByDefault":"false"},{"table":"Case.Activities","field":"Owner","checkedByDefault":"false"},{"table":"Case.Activities","field":"Description","checkedByDefault":"false"},{"table":"Case.Activities","field":"Account","checkedByDefault":"false"},{"table":"Case.Activities","field":"IsClosed","checkedByDefault":"false"},{"table":"Case.Activities","field":"CreatedDate","checkedByDefault":"false"},{"table":"Case.Activities","field":"CreatedBy","checkedByDefault":"false"},{"table":"Case.Activities","field":"LastModifiedDate","checkedByDefault":"false"},{"table":"Case.Activities","field":"LastModifiedBy","checkedByDefault":"false"},{"table":"Case.Activities","field":"CallDurationInSeconds","checkedByDefault":"false"},{"table":"Case.Activities","field":"CallType","checkedByDefault":"false"},{"table":"Case.Activities","field":"CallDisposition","checkedByDefault":"false"},{"table":"Case.Activities","field":"CallObject","checkedByDefault":"false"},{"table":"Case.Activities","field":"RecurrenceRegeneratedType","checkedByDefault":"false"},{"table":"Case.Activities","field":"TaskSubtype","checkedByDefault":"false"},{"table":"Case.Activities","field":"CompletedDateTime","checkedByDefault":"false"},{"table":"Case.Activities","field":"Location","checkedByDefault":"false"},{"table":"Case.Activities","field":"IsAllDayEvent","checkedByDefault":"false"},{"table":"Case.Activities","field":"ActivityDateTime","checkedByDefault":"false"},{"table":"Case.Activities","field":"DurationInMinutes","checkedByDefault":"false"},{"table":"Case.Activities","field":"IsPrivate","checkedByDefault":"false"},{"table":"Case.Activities","field":"ShowAs","checkedByDefault":"false"},{"table":"Case.Activities","field":"IsChild","checkedByDefault":"false"},{"table":"Case.Activities","field":"IsGroupEvent","checkedByDefault":"false"},{"table":"Case.Activities","field":"GroupEventType","checkedByDefault":"false"},{"table":"Case.Activities","field":"EventSubtype","checkedByDefault":"false"}]}],"label":"Case Test","join":{"relationship":"Activities","outerJoin":"true"},"description":"This is also a test","deployed":"true","category":"other","baseObject":"Case","fullName":"Case_Test"}}';

    static testMethod void testGetTypeLabel() {
        String objectLabel = Label.TypeCustomObject;
        String fakeType = 'FakeType';
        Test.startTest();
            String typeLabel = DependencyHelper.getTypeLabel(DependencyHelper.TYPE_CUSTOM_OBJECT);
            String fakeTypeLabel = DependencyHelper.getTypeLabel(fakeType);
        Test.stopTest();
        System.assertEquals(objectLabel, typeLabel, 'Expecting custom label value to be returned');
        System.assertNotEquals(fakeType, fakeTypeLabel, 'Expecting adjusted value to be returned');
    }
    
    static testMethod void testGetAllDependencies() {
        Test.setMock(HttpCalloutMock.class, new MockResponse(ExternalUtilities.HTTP_RESPONSE_CODE_SUCCESS, getDependencyApiMockResponseJson()));
        Test.startTest();

        List<ToolingService.MetadataComponentDependency> dependencies = DependencyHelper.getAllDependencies();

        Test.stopTest();

        System.assertNotEquals(true, dependencies.isEmpty(), 'Dependency results must exist');
    }

    static testMethod void testBuildTree() {
        Test.setMock(HttpCalloutMock.class, new MockResponse(ExternalUtilities.HTTP_RESPONSE_CODE_SUCCESS, getDependencyApiMockResponseJson()));
        Test.startTest();

        List<DependencyHelper.MetadataComponent> dependencyTreeList = DependencyHelper.buildDependencyTree(DependencyHelper.getAllDependencies());

        Test.stopTest();

        System.assertNotEquals(true, dependencyTreeList.isEmpty(), 'Dependency results must exist');
    }

    static testMethod void testGetLayouts() {
        String layoutName = 'Contact Layout';
        Test.setMock(HttpCalloutMock.class, new MockResponse(ExternalUtilities.HTTP_RESPONSE_CODE_SUCCESS, TOOLING_RESPONSE_LAYOUTS_NAME));
        Test.startTest();
            List<ToolingService.MetadataComponentDependency> dependencies = DependencyHelper.getLayouts(new List<String>{layoutName});
        Test.stopTest();
        System.assertEquals(1, dependencies.size(), 'Expecting 1 layout returned');
        System.assertEquals(layoutName, dependencies[0].MetadataComponentName, 'MetadataComponentName should match the layout name retrieved');
    }

    static testMethod void testGetObjectLayouts() {
        String objectName = 'Contact';
        Test.setMock(HttpCalloutMock.class, new MockResponse(ExternalUtilities.HTTP_RESPONSE_CODE_SUCCESS, TOOLING_RESPONSE_LAYOUTS));
        Test.startTest();
            List<ToolingService.MetadataComponentDependency> dependencies = DependencyHelper.getObjectLayouts(new List<String>{objectName});
        Test.stopTest();
        System.assertEquals(2, dependencies.size(), 'Expecting 2 layouts returned from sample payload TOOLING_RESPONSE_LAYOUTS');
        for (ToolingService.MetadataComponentDependency mcd : dependencies) {
            System.assertNotEquals(null, mcd.MetadataComponentName, 'MetadataComponentName should be retrieved and populated');
        }
    }

    static testMethod void testGetCompactLayouts() {
        String objectName = 'Contact';
        Test.setMock(HttpCalloutMock.class, new MockResponse(ExternalUtilities.HTTP_RESPONSE_CODE_SUCCESS, TOOLING_RESPONSE_COMPACT_LAYOUT));
        Test.startTest();
            List<ToolingService.MetadataComponentDependency> dependencies = DependencyHelper.getObjectCompactLayouts(new List<String>{objectName});
        Test.stopTest();
        System.assertEquals(1, dependencies.size(), 'Expecting 1 layouts returned from sample payload TOOLING_RESPONSE_COMPACT_LAYOUT');
        for (ToolingService.MetadataComponentDependency mcd : dependencies) {
            System.assertNotEquals(null, mcd.MetadataComponentName, 'MetadataComponentName should be retrieved and populated');
        }
    }

    static testMethod void testGetValidationRules() {
        String objectName = 'Contact';
        Test.setMock(HttpCalloutMock.class, new MockResponse(ExternalUtilities.HTTP_RESPONSE_CODE_SUCCESS, TOOLING_RESPONSE_VALIDATIONS));
        Test.startTest();
            List<ToolingService.MetadataComponentDependency> dependencies = DependencyHelper.getObjectValidationRules(new List<String>{objectName});
        Test.stopTest();
        System.assertEquals(1, dependencies.size(), 'Expecting 1 validation rule returned from sample payload TOOLING_RESPONSE_VALIDATIONS');
        for (ToolingService.MetadataComponentDependency mcd : dependencies) {
            System.assertNotEquals(null, mcd.MetadataComponentName, 'MetadataComponentName should be retrieved and populated');
        }
    }

    static testMethod void testGetProcessFlows() {
        String objectName = 'Contact';
        MockResponse mockResponses = new MockResponse(ExternalUtilities.HTTP_RESPONSE_CODE_SUCCESS, TOOLING_RESPONSE_FLOWS);
        mockResponses.addResponse(ExternalUtilities.HTTP_RESPONSE_CODE_SUCCESS, METADATA_RESPONSE_READ_FLOW);
        Test.setMock(HttpCalloutMock.class, mockResponses);
        Test.startTest();
            List<ToolingService.MetadataComponentDependency> dependencies = DependencyHelper.getObjectProcessFlows(new List<String>{objectName});
        Test.stopTest();
        System.assertNotEquals(true, dependencies.isEmpty(), 'Expecting flow components returned from sample payload TOOLING_RESPONSE_FLOWS and METADATA_RESPONSE_READ_FLOW');
        for (ToolingService.MetadataComponentDependency mcd : dependencies) {
            System.assertNotEquals(null, mcd.MetadataComponentName, 'MetadataComponentName should be retrieved and populated');
        }
    }

    static testMethod void testGetObjectWorkflows() {
        String objectName = 'Contact';
        MockResponse mockResponses = new MockResponse(ExternalUtilities.HTTP_RESPONSE_CODE_SUCCESS, TOOLING_RESPONSE_WORKFLOWS);
        mockResponses.addResponse(ExternalUtilities.HTTP_RESPONSE_CODE_SUCCESS, METADATA_RESPONSE_READ_WORKFLOW);
        mockResponses.addResponse(ExternalUtilities.HTTP_RESPONSE_CODE_SUCCESS, TOOLING_RESPONSE_WORKFLOW_ALERTS);
        mockResponses.addResponse(ExternalUtilities.HTTP_RESPONSE_CODE_SUCCESS, TOOLING_RESPONSE_WORKFLOW_UPDATES);
        mockResponses.addResponse(ExternalUtilities.HTTP_RESPONSE_CODE_SUCCESS, TOOLING_RESPONSE_WORKFLOW_MESSAGES);
        mockResponses.addResponse(ExternalUtilities.HTTP_RESPONSE_CODE_SUCCESS, TOOLING_RESPONSE_WORKFLOW_TASKS);
        Test.setMock(HttpCalloutMock.class, mockResponses);
        Test.startTest();
            List<ToolingService.MetadataComponentDependency> dependencies = DependencyHelper.getObjectWorkflows(new Map<String,String>{objectName=>objectName});
        Test.stopTest();
        System.assertNotEquals(true, dependencies.isEmpty(), 'Expecting workflow components returned from sample payload TOOLING_RESPONSE_WORKFLOWS');
        for (ToolingService.MetadataComponentDependency mcd : dependencies) {
            System.assertNotEquals(null, mcd.MetadataComponentName, 'MetadataComponentName should be retrieved and populated');
        }
    }

    static testMethod void testGetObjectApprovals() {
        String objectName = 'Contact';
        Test.startTest();
            List<ToolingService.MetadataComponentDependency> dependencies = DependencyHelper.getObjectApprovals(new List<String>{objectName});
        Test.stopTest();
        System.assertNotEquals(null, dependencies, 'Expecting list to be created but not populated this org might not have ProcessDefinition on the object');
    }

    static testMethod void testGetObjectRecordTypes() {
        String objectName = 'Contact';
        Test.startTest();
            List<ToolingService.MetadataComponentDependency> dependencies = DependencyHelper.getObjectRecordTypes(new List<String>{objectName});
        Test.stopTest();
        System.assertNotEquals(null, dependencies, 'Expecting list to be created but not populated this org might not have RecordType on the object');
    }

    static testMethod void testGetObjectListViews() {
        String objectName = 'Contact';
        Test.startTest();
            List<ToolingService.MetadataComponentDependency> dependencies = DependencyHelper.getObjectListViews(new List<String>{objectName});
        Test.stopTest();
        System.assertNotEquals(null, dependencies, 'Expecting list to be created but not populated this org might not have ProcessDefinition on the object');
    }

    static testMethod void testGetObjectFieldSets() {
        String objectName = 'Contact';
        Test.setMock(HttpCalloutMock.class, new MockResponse(ExternalUtilities.HTTP_RESPONSE_CODE_SUCCESS, TOOLING_RESPONSE_FIELD_SETS));
        Test.startTest();
            List<ToolingService.MetadataComponentDependency> dependencies = DependencyHelper.getObjectFieldSets(new List<String>{objectName});
        Test.stopTest();
        System.assertNotEquals(null, dependencies, 'Expecting list to be created but not populated this org might not have FieldSet on the object');
    }

    /**
     * Generate response from Dependency API
     */
    private static String getDependencyApiMockResponseJson() {
        ToolingService.ToolingMetadataComponentDependencyResponse toolingResult = new ToolingService.ToolingMetadataComponentDependencyResponse();
        toolingResult.size = 1;
        toolingResult.totalSize = 1;
        toolingResult.records = new List<ToolingService.MetadataComponentDependency>();

        ToolingService.MetadataComponentDependency mcd = new ToolingService.MetadataComponentDependency();
        mcd.MetadataComponentName = 'Test__c';
        mcd.MetadataComponentType = 'CustomObject';
        mcd.RefMetadataComponentName = 'SomeClass';
        mcd.RefMetadataComponentType = 'ApexClass';
        toolingResult.records.add(mcd);

        ToolingService.MetadataComponentDependency accountDependency = new ToolingService.MetadataComponentDependency();
        accountDependency.MetadataComponentId = Utilities.uuid();
        accountDependency.MetadataComponentName = 'AccountTrigger';
        accountDependency.MetadataComponentType = 'ApexTrigger';
        accountDependency.RefMetadataComponentId = Utilities.uuid();
        accountDependency.RefMetadataComponentName = 'Account';
        accountDependency.RefMetadataComponentType = 'StandardEntity';
        toolingResult.records.add(accountDependency);

        ToolingService.MetadataComponentDependency assessmentDependency = new ToolingService.MetadataComponentDependency();
        assessmentDependency.MetadataComponentId = Utilities.uuid();
        assessmentDependency.MetadataComponentName = 'AssessmentTrigger';
        assessmentDependency.MetadataComponentType = 'ApexTrigger';
        assessmentDependency.RefMetadataComponentId = Utilities.uuid();
        assessmentDependency.RefMetadataComponentName = 'Assessment__c';
        assessmentDependency.RefMetadataComponentType = 'CustomObject';
        toolingResult.records.add(assessmentDependency);

        ToolingService.MetadataComponentDependency assessmentFieldDependency = new ToolingService.MetadataComponentDependency();
        assessmentFieldDependency.MetadataComponentId = Utilities.uuid();
        assessmentFieldDependency.MetadataComponentName = 'Assessment Layout';
        assessmentFieldDependency.MetadataComponentType = 'Layout';
        assessmentFieldDependency.RefMetadataComponentId = Utilities.uuid();
        assessmentFieldDependency.RefMetadataComponentName = 'AssessmentField__c';
        assessmentFieldDependency.RefMetadataComponentType = 'CustomField';
        toolingResult.records.add(assessmentFieldDependency);

        return JSON.serialize(toolingResult);
    }

    @IsTest
    static void getReportInfo_ResponseReturned() {
        MockResponse mockResponses = new MockResponse(ExternalUtilities.HTTP_RESPONSE_CODE_SUCCESS, METADATA_RESPONSE_READ_REPORTS);
        mockResponses.addResponse(ExternalUtilities.HTTP_RESPONSE_CODE_SUCCESS, METADATA_RESPONSE_LIST_REPORTTYPES);
        mockResponses.addResponse(ExternalUtilities.HTTP_RESPONSE_CODE_SUCCESS, METADATA_RESPONSE_READ_REPORTTYPES);
        Test.setMock(HttpCalloutMock.class, mockResponses);

        Map<String, String> objectToIdMap = new Map<String, String>{
            'Case' => 'Case',
            'Assessment__c' => ''
        };

        Map<String, String> objectMapping = new Map<String, String>{
            'Case' => 'Case',
            'Assessment__c' => 'Assessment__c'
        };

        DependencyHelper.reportNameMap = new Map<String, Report>{
            'TestFolder/Critical_Report_sgm' => new Report(), 
            'TestFolder/New_Case_Test_Report_j5B' => new Report(), 
            'unfiled$public/All_Accounts_Report_YKP' => new Report(), 
            'unfiled$public/New_Case_Test_Report_EvT' => new Report(), 
            'unfiled$public/New_Test_View_Report_bij' => new Report(), 
            'unfiled$public/flow_screen_prebuilt_report' => new Report() 
        };

        Test.startTest();
            List<ToolingService.MetadataComponentDependency> dependencies = DependencyHelper.getReportInfo(objectToIdMap, objectMapping);
        Test.stopTest();


        System.assertNotEquals(true, dependencies.isEmpty(), 'A list of dependencies should be returned');
    }
}