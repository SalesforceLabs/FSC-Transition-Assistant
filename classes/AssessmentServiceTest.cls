@isTest
private class AssessmentServiceTest {
    static Integer RECORD_COUNT = Limits.getLimitQueries() + 1;
    static final Id INVALID_ID = Schema.Assessment__c.getSObjectType().getDescribe().getKeyPrefix() + '4x000002xEIYAA2';
    static final Id DUMMY_METADATA_ID = Schema.SFDC_Industry_Assessment_Question__mdt.getSObjectType().getDescribe().getKeyPrefix() + '4x000000lrM8AAI';
    static final Id CONTROLLING_QUESTION_ID = Schema.SFDC_Industry_Assessment_Question__mdt.getSObjectType().getDescribe().getKeyPrefix() + '4x000000lvLDAAY';
    static final String EXPECTED_VALUE = 'New';
    static final String TEST_LABEL = 'testLabel';
    static final String TEST_MESSAGE = 'Test message';
    static final String FIELD_BOOLEAN = 'Bulk_Scan_Complete__c';
    static final String FIELD_PICKLIST = 'Status__c';
    static final String FIELD_MULTISELECT = 'Selected_Products__c';
    static final String VALUE_BOOLEAN = 'TRUE';
    static final String VALUE_PICKLIST = 'New';
    static final String VALUE_MULTISELECT = 'FSC Banking';

    //static final String CONTROLLING_API_NAME = 'Status__c';
    //static final String API_NAME = 'Status__c';

    @IsTest
    static void industryMap_MetadataPopulated(){
        
        Test.startTest();
            Map<Id, SFDC_Industry__mdt> industryMap = AssessmentService.industryMap;
        Test.stopTest();

        System.assertNotEquals(null, industryMap, 'industryMap should not be null');
        System.assertNotEquals(new Set<Id>(), industryMap.keySet(), 'SFDC_Industry__mdt should have values populated');
    }

    @IsTest
    static void industryVerticalMap_MetadataPopulated(){
        
        Test.startTest();
            Map<String, List<SFDC_Industry_Vertical__mdt>> industryVerticalMap = AssessmentService.industryVerticalMap;
        Test.stopTest();

        System.assertNotEquals(null, industryVerticalMap, 'industryVerticalMap should not be null');
        System.assertNotEquals(
            new Set<String>(), 
            industryVerticalMap.keySet(), 
            'SFDC_Industry_Vertical__mdt should have values populated'
        );
    }

    @IsTest
    static void industryAssessmentQuestionList_MetadataPopulated(){
    
        Test.startTest();
            List<SFDC_Industry_Assessment_Question__mdt> questionList = AssessmentService.industryAssessmentQuestionList;
        Test.stopTest();

        System.assertNotEquals(null, questionList, 'industryAssessmentQuestionList should not be null');
        System.assertNotEquals(
            0, 
            questionList.size(),
            'SFDC_Industry_Assessment_Question__mdt should have values populated'
        );
    }

    @IsTest
    static void industryAssessmentQuestionMap_MetadataPopulated(){
        
        Test.startTest();
            Map<Id, SFDC_Industry_Assessment_Question__mdt> industryAssessmentQuestionMap = AssessmentService.industryAssessmentQuestionMap;
        Test.stopTest();

        System.assertNotEquals(null, industryAssessmentQuestionMap, 'industryAssessmentQuestionMap should not be null');
        System.assertNotEquals(
            new Set<Id>(), 
            industryAssessmentQuestionMap.keySet(),
            'SFDC_Industry_Assessment_Question__mdt should have values populated'
        );
    }

    @IsTest
    static void industryAssessmentQuestionBranchList_MetadataPopulated(){
    
        Test.startTest();
            List<SFDC_Industry_Assessment_Question_Branch__mdt> branchList = AssessmentService.industryAssessmentQuestionBranchList;
        Test.stopTest();

        System.assertNotEquals(null, branchList, 'industryAssessmentQuestionBranchList should not be null');
        System.assertNotEquals(
            0, 
            branchList.size(),
            'SFDC_Industry_Assessment_Question_Branch__mdt should have values populated'
        );
    }

    @IsTest
    static void industryAssessmentControllingQuestionBranchMap_MetadataPopulated(){
    
        Test.startTest();
            Map<Id, List<SFDC_Industry_Assessment_Question_Branch__mdt>> branchMap = AssessmentService.industryAssessmentControllingQuestionBranchMap;
        Test.stopTest();

        System.assertNotEquals(null, branchMap, 'industryAssessmentControllingQuestionBranchMap should not be null');
        System.assertNotEquals(
            new Set<Id>(), 
            branchMap.keySet(),
            'SFDC_Industry_Assessment_Question_Branch__mdt should have values populated'
        );
    }

    @IsTest
    static void industryAssessmentFollowingQuestionBranchMap_MetadataPopulated(){
    
        Test.startTest();
            Map<Id, List<SFDC_Industry_Assessment_Question_Branch__mdt>> branchMap = AssessmentService.industryAssessmentFollowingQuestionBranchMap;
        Test.stopTest();

        System.assertNotEquals(null, branchMap, 'industryAssessmentFollowingQuestionBranchMap should not be null');
        System.assertNotEquals(
            new Set<Id>(), 
            branchMap.keySet(),
            'SFDC_Industry_Assessment_Question_Branch__mdt should have values populated'
        );
    }
    
    @IsTest
    static void getOrgVerticals_VerticalsReturned(){
        ToolingService.customLabelMap = new Map<String, String>{
            TEST_LABEL => TEST_MESSAGE
        };
        List<String> industryList = new List<String>(AssessmentService.industryVerticalMap.keySet());
        
        Test.startTest();
            List<AssessmentService.VerticalInfo> verticalList = AssessmentService.getOrgVerticals(industryList[0]);
        Test.stopTest();

        System.assertEquals(
            AssessmentService.industryVerticalMap.get(industryList[0]).size(),
            verticalList.size(), 
            'All verticals should be returned for the requested industry'
        );
        
    }

    @IsTest
    static void getOrgAssessments_RecordsReturned(){
        List<Assessment__c> setupAssessments = new List<Assessment__c>();
        for(Integer i = 0; i < RECORD_COUNT; i++) {
            setupAssessments.add(new Assessment__c());
        }
        insert setupAssessments;

        Test.startTest();
            List<AssessmentService.AssessmentInfo> returnedAssessments = AssessmentService.getOrgAssessments();
        Test.stopTest();

        System.assertEquals(
            RECORD_COUNT, 
            returnedAssessments.size(), 
            'All created Assessments should be returned'
        );
    }

    @IsTest
    static void getCurrentAssessmentQuestion_QuestionReturned(){
        ToolingService.customLabelMap = new Map<String, String>{
            TEST_LABEL => TEST_MESSAGE
        };
        Assessment__c setupAssessment = new Assessment__c(
            Current_Question_Id__c = AssessmentService.industryAssessmentQuestionList[0].Id
        );
        insert setupAssessment;

        Test.startTest();
            AssessmentService.AssessmentQuestion result = AssessmentService.getCurrentAssessmentQuestion(setupAssessment.Id);
        Test.stopTest();

        System.assertNotEquals(null, result, 'An AssessmentQuestion should be returned');
        System.assertEquals(
            AssessmentService.industryAssessmentQuestionList[0].Id, 
            result.QuestionId,
            'The returned question should contain info related to the current question'
        );
    }

    @IsTest
    static void getStartingQuestion_StartingQuestionReturned(){
        ToolingService.customLabelMap = new Map<String, String>{
            TEST_LABEL => TEST_MESSAGE
        };

        List<SFDC_Industry_Vertical__mdt> verticalList = [
            SELECT DeveloperName, MasterLabel, Industry__r.DeveloperName, Industry__c, Display_Label__c,
                Icon_Name__c, Description_Label__c, Field__c, Value__c
            FROM SFDC_Industry_Vertical__mdt
        ];

        List<AssessmentService.VerticalInfo> setupVerticals = new List<AssessmentService.VerticalInfo>();
        for(SFDC_Industry_Vertical__mdt vertical : verticalList) {
            AssessmentService.VerticalInfo setupVertical = new AssessmentService.VerticalInfo(vertical);
            setupVertical.VerticalSelected = true;
            setupVerticals.add(setupVertical);
        }
        
        Test.startTest();
            AssessmentService.AssessmentQuestion result = AssessmentService.getStartingQuestion(setupVerticals);
        Test.stopTest();

        System.assertNotEquals(null, result, 'An AssessmentQuestion should be returned');
        System.assertEquals(1, [SELECT Id FROM Assessment__c].size(), 'A single Assessment should be created');
    }

    @IsTest
    static void saveQuestion_AssessmentUpdated(){
        Assessment__c setupAssessment = new Assessment__c();
        insert setupAssessment;

        SFDC_Industry_Assessment_Question__mdt question = AssessmentService.industryAssessmentQuestionList[0];

        AssessmentService.AssessmentQuestion setupAnswer = new AssessmentService.AssessmentQuestion();
        setupAnswer.AssessmentId = setupAssessment.Id;
        setupAnswer.AnswerFieldAPIName = Utilities.namespaceUnderscore+question.Answer_Field_API_Name__c;
        setupAnswer.AnswerDataType = AssessmentService.ASSESSMENT_FIELD_SCHEMA.get(setupAnswer.AnswerFieldAPIName).getDescribe().getType().name();
        if(setupAnswer.AnswerDataType == Schema.DisplayType.PICKLIST.name()) {
            setupAnswer.IsPicklist = true;
            setupAnswer.SelectedAnswer = null;
        }
        else if(setupAnswer.AnswerDataType == Schema.DisplayType.MULTIPICKLIST.name()) {
            setupAnswer.IsMultiSelect = true;
            setupAnswer.SelectedAnswer = null;
        }
        else if(setupAnswer.AnswerDataType == Schema.DisplayType.BOOLEAN.name()) {
            setupAnswer.IsCheckBox = true;
            setupAnswer.SelectedCheckbox = false;
        }
    
        AuraHandledException exceptionResult;
        Test.startTest();
            try {
                AssessmentService.saveQuestion(JSON.serialize(setupAnswer));
            } 
            catch (AuraHandledException caughtException) {
                exceptionResult = caughtException;
            }
        Test.stopTest();
        
        System.assertEquals(null, exceptionResult, 'An exception should not be thrown');

        List<Assessment__c> queriedAssessments = [SELECT Id FROM Assessment__c];

        System.assertEquals(1, queriedAssessments.size(), 'A single Assessment should be present');
    }

    @IsTest
    static void saveQuestion_ExceptionThrown(){
        Assessment__c setupAssessment = new Assessment__c();
        insert setupAssessment;
        SFDC_Industry_Assessment_Question__mdt question = AssessmentService.industryAssessmentQuestionList[0];

        AssessmentService.AssessmentQuestion setupAnswer = new AssessmentService.AssessmentQuestion();
        setupAnswer.AnswerFieldAPIName = Utilities.namespaceUnderscore+question.Answer_Field_API_Name__c;
        setupAnswer.AnswerDataType = AssessmentService.ASSESSMENT_FIELD_SCHEMA.get(setupAnswer.AnswerFieldAPIName).getDescribe().getType().name();
        if(setupAnswer.AnswerDataType == Schema.DisplayType.PICKLIST.name()) {
            setupAnswer.IsPicklist = true;
            setupAnswer.SelectedAnswer = null;
        }
        else if(setupAnswer.AnswerDataType == Schema.DisplayType.MULTIPICKLIST.name()) {
            setupAnswer.IsMultiSelect = true;
            setupAnswer.SelectedAnswer = null;
        }
        else if(setupAnswer.AnswerDataType == Schema.DisplayType.BOOLEAN.name()) {
            setupAnswer.IsCheckBox = true;
            setupAnswer.SelectedCheckbox = false;
        }
    
        AuraHandledException exceptionResult;
        Test.startTest();
            try {
                AssessmentService.saveQuestion(JSON.serialize(setupAnswer));
            } 
            catch (AuraHandledException caughtException) {
                exceptionResult = caughtException;
            }
        Test.stopTest();
        
        System.assertNotEquals(null, exceptionResult, 'An AuraHandledException should  be thrown');
    }


    @IsTest
    static void getPreviousQuestion_PreviousQuestionReturned(){
        ToolingService.customLabelMap = new Map<String, String>{
            TEST_LABEL => TEST_MESSAGE
        };
        
        Assessment__c setupAssessment = new Assessment__c();
        insert setupAssessment;

        SFDC_Industry_Assessment_Question_Branch__mdt branch = [
            SELECT Controlling_Question__c, Following_Question__c
            FROM SFDC_Industry_Assessment_Question_Branch__mdt
            WHERE Following_Question__c != null
                AND Controlling_Question__c != null
                AND Is_Default_Outcome__c = true
            LIMIT 1
        ];

        SFDC_Industry_Assessment_Question__mdt question = AssessmentService.industryAssessmentQuestionMap.get(branch.Following_Question__c);

        AssessmentService.AssessmentQuestion setupAnswer = new AssessmentService.AssessmentQuestion();
        setupAnswer.QuestionId = question.Id;
        setupAnswer.QuestionNumber = 1;
        setupAnswer.AssessmentId = setupAssessment.Id;
        setupAnswer.AnswerFieldAPIName = Utilities.namespaceUnderscore+question.Answer_Field_API_Name__c;
        setupAnswer.AnswerDataType = AssessmentService.ASSESSMENT_FIELD_SCHEMA.get(setupAnswer.AnswerFieldAPIName).getDescribe().getType().name();
        if(setupAnswer.AnswerDataType == Schema.DisplayType.PICKLIST.name()) {
            setupAnswer.IsPicklist = true;
            setupAnswer.SelectedAnswer = null;
        }
        else if(setupAnswer.AnswerDataType == Schema.DisplayType.MULTIPICKLIST.name()) {
            setupAnswer.IsMultiSelect = true;
            setupAnswer.SelectedAnswer = null;
        }
        else if(setupAnswer.AnswerDataType == Schema.DisplayType.BOOLEAN.name()) {
            setupAnswer.IsCheckBox = true;
            setupAnswer.SelectedCheckbox = false;
        }
    
        Test.startTest();
            AssessmentService.AssessmentQuestion result = AssessmentService.getPreviousQuestion(JSON.serialize(setupAnswer));
        Test.stopTest();

        System.assertNotEquals(null, result, 'An AssessmentQuestion should be returned');

    }


    @IsTest
    static void queryAssessment_AssessmentReturned(){
        Assessment__c setupAssessment = new Assessment__c();
        insert setupAssessment;
        
        Test.startTest();
            Assessment__c result = AssessmentService.queryAssessment(setupAssessment.Id);
        Test.stopTest();

        System.assertNotEquals(null, result, 'An Assessment should be returned');
        System.assertEquals(setupAssessment.Id, result.Id, 'The returned assessment should match the given Id');
    }

    @IsTest
    static void setStatus_StatusSet(){
        Assessment__c setupAssessment = new Assessment__c(Current_Question_Number__c = 1);
        insert setupAssessment;

        SFDC_Industry_Assessment_Question_Branch__mdt branch = [
            SELECT Controlling_Question__c, Following_Question__c
            FROM SFDC_Industry_Assessment_Question_Branch__mdt
            WHERE Following_Question__c != null
                AND Controlling_Question__c != null
                AND Is_Default_Outcome__c = true
            LIMIT 1
        ];

        SFDC_Industry_Assessment_Question__mdt question = AssessmentService.industryAssessmentQuestionMap.get(branch.Following_Question__c);
        
        Test.startTest();
            Boolean statusSet = AssessmentService.setStatus(setupAssessment.Id, question.Id, '0', '0', 'next');
            Boolean mapStatusSet = AssessmentService.setStatus(setupAssessment.Id, 'MAP', '', '', '');
        Test.stopTest();

        System.assertNotEquals(false, statusSet, '"True" should be returned');
        System.assertNotEquals(false, mapStatusSet, '"True" should be returned');
    }

    @IsTest
    static void getMappingSection_MappingReturned(){
        Assessment__c setupAssessment = new Assessment__c();
        insert setupAssessment;

        SFDC_Industry_Assessment_Question__mdt question = AssessmentService.industryAssessmentQuestionList[0];

        AssessmentService.AssessmentQuestion setupAnswer = new AssessmentService.AssessmentQuestion();
        setupAnswer.AssessmentId = setupAssessment.Id;
        setupAnswer.AnswerFieldAPIName = Utilities.namespaceUnderscore+question.Answer_Field_API_Name__c;
        setupAnswer.AnswerDataType = AssessmentService.ASSESSMENT_FIELD_SCHEMA.get(setupAnswer.AnswerFieldAPIName).getDescribe().getType().name();
        if(setupAnswer.AnswerDataType == Schema.DisplayType.PICKLIST.name()) {
            setupAnswer.IsPicklist = true;
            setupAnswer.SelectedAnswer = null;
        }
        else if(setupAnswer.AnswerDataType == Schema.DisplayType.MULTIPICKLIST.name()) {
            setupAnswer.IsMultiSelect = true;
            setupAnswer.SelectedAnswer = null;
        }
        else if(setupAnswer.AnswerDataType == Schema.DisplayType.BOOLEAN.name()) {
            setupAnswer.IsCheckBox = true;
            setupAnswer.SelectedCheckbox = false;
        }
    
        AuraHandledException exceptionResult;
        Id sectionId;
        Test.startTest();
            try {
                sectionId = AssessmentService.getMappingSection(JSON.serialize(setupAnswer));
            } 
            catch (AuraHandledException caughtException) {
                exceptionResult = caughtException;
            }
        Test.stopTest();
        
        System.assertEquals(null, sectionId, 'sectionId should be null');
    }

    @IsTest
    static void evaluateExcludes_NoExcludesPresent(){
        AssessmentService.industryAssessmentQuestionExcludeMap = new Map<Id, List<SFDC_Industry_Assessment_Exclude__mdt>>();

        SFDC_Industry_Assessment_Question__mdt setupQuestion = new SFDC_Industry_Assessment_Question__mdt();
        Assessment__c setupAssessment = new Assessment__c();

        Test.startTest();
            Set<String> result = AssessmentService.evaluateExcludes(setupQuestion, setupAssessment);
        Test.stopTest();
        
        System.assertEquals(new Set<String>(), result, 'An empty set should be returned when no excludes are found');
    }

    @IsTest
    static void evaluateExcludes_PicklistValueMatch(){
        AssessmentService.industryAssessmentQuestionExcludeMap = new Map<Id, List<SFDC_Industry_Assessment_Exclude__mdt>>();
        AssessmentService.industryAssessmentQuestionExcludeMap.put(null, new List<SFDC_Industry_Assessment_Exclude__mdt>{
            new SFDC_Industry_Assessment_Exclude__mdt(
                Controlling_Field__c = FIELD_PICKLIST,
                Controlling_Value__c = VALUE_PICKLIST,
                Exclude_Value__c = EXPECTED_VALUE
            )
        });

        SFDC_Industry_Assessment_Question__mdt setupQuestion = new SFDC_Industry_Assessment_Question__mdt();
        Assessment__c setupAssessment = new Assessment__c();
        setupAssessment.put(Utilities.namespaceUnderscore+FIELD_PICKLIST, VALUE_PICKLIST);

        Test.startTest();
            Set<String> result = AssessmentService.evaluateExcludes(setupQuestion, setupAssessment);
        Test.stopTest();
        
        System.assertEquals(new Set<String>{EXPECTED_VALUE}, result, 'A set containing the expected value should be returned');
    }

    @IsTest
    static void evaluateExcludes_MultiselectValueMatch(){
        AssessmentService.industryAssessmentQuestionExcludeMap = new Map<Id, List<SFDC_Industry_Assessment_Exclude__mdt>>();
        AssessmentService.industryAssessmentQuestionExcludeMap.put(null, new List<SFDC_Industry_Assessment_Exclude__mdt>{
            new SFDC_Industry_Assessment_Exclude__mdt(
                Controlling_Field__c = FIELD_MULTISELECT,
                Controlling_Value__c = VALUE_MULTISELECT,
                Exclude_Value__c = EXPECTED_VALUE
            )
        });

        SFDC_Industry_Assessment_Question__mdt setupQuestion = new SFDC_Industry_Assessment_Question__mdt();
        Assessment__c setupAssessment = new Assessment__c();
        setupAssessment.put(Utilities.namespaceUnderscore+FIELD_MULTISELECT, VALUE_MULTISELECT);

        Test.startTest();
            Set<String> result = AssessmentService.evaluateExcludes(setupQuestion, setupAssessment);
        Test.stopTest();
        
        System.assertEquals(new Set<String>{EXPECTED_VALUE}, result, 'A set containing the expected value should be returned');
    }

    @IsTest
    static void evaluateExcludes_BooleanValueMatch(){
        AssessmentService.industryAssessmentQuestionExcludeMap = new Map<Id, List<SFDC_Industry_Assessment_Exclude__mdt>>();
        AssessmentService.industryAssessmentQuestionExcludeMap.put(null, new List<SFDC_Industry_Assessment_Exclude__mdt>{
            new SFDC_Industry_Assessment_Exclude__mdt(
                Controlling_Field__c = FIELD_BOOLEAN,
                Controlling_Value__c = VALUE_BOOLEAN,
                Exclude_Value__c = EXPECTED_VALUE
            )
        });

        SFDC_Industry_Assessment_Question__mdt setupQuestion = new SFDC_Industry_Assessment_Question__mdt();
        Assessment__c setupAssessment = new Assessment__c();
        setupAssessment.put(Utilities.namespaceUnderscore+FIELD_BOOLEAN, Boolean.valueOf(VALUE_BOOLEAN));

        Test.startTest();
            Set<String> result = AssessmentService.evaluateExcludes(setupQuestion, setupAssessment);
        Test.stopTest();
        
        System.assertEquals(new Set<String>{EXPECTED_VALUE}, result, 'A set containing the expected value should be returned');
    }

    @IsTest
    static void updateAssessmentDescription_DescriptionUpdated(){
        Assessment__c setupAssessment = new Assessment__c();
        insert setupAssessment;
        
        Test.startTest();
            AssessmentService.updateAssessmentDescription(setupAssessment.Id, EXPECTED_VALUE);
        Test.stopTest();
        
        Assessment__c updatedAssessment = [
            SELECT Description__c
            FROM Assessment__c
            WHERE Id =: setupAssessment.Id
        ];

        System.assertEquals(EXPECTED_VALUE, updatedAssessment.Description__c, 'Description should be updated to its expected value');
    }
}