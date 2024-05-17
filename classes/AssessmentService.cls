public with sharing class AssessmentService {
    @TestVisible
    static final Map<String, Schema.SObjectField> ASSESSMENT_FIELD_SCHEMA = Schema.SObjectType.Assessment__c.fields.getMap();
    static final Set<String> REQUIRED_ASSESSMENT_FIELDS = new Set<String>{
        Utilities.namespaceUnderscore + 'Current_Question_Id__c',
        Utilities.namespaceUnderscore + 'Current_Question_Number__c'
    };
    static final String ASSESSMENT_QUERY_TEMPLATE = 'SELECT {0} FROM Assessment__c WHERE ID =: assessmentId';
    static final String ASSESSMENT_QUESTION_TEMPLATE = '{0}. {1}';
    static final String HAS_PERSON_ACCOUNTS_ASSESSMENT_VALUE = 'People (B2C)';
    static final String NO_PERSON_ACCOUNTS_ASSESSMENT_VALUE = 'Businesses (B2B)';
    static final String HAS_PERSON_ACCOUNTS_ASSESSMENT_FIELD =  Utilities.namespaceUnderscore + 'Customer_Representation__c';
    static final String HAS_PERSON_ACCOUNTS_REPORT_FIELD = Utilities.namespaceUnderscore + 'Is_B2C__c';
    static final String STARTING_QUESTION_API_NAME = 'Starting_Question';
    static final String COMPARISON_TYPE_CONTAINS = 'Contains';
    static final String STATUS_MAPPING = 'Mapping';
    static final String STATUS_ASSESSMENT = 'Questionnaire';
    static final String STATUS_NEW = 'New';
    static final String STATUS_REVIEW = 'Review';
    static final String STATUS_SCANNING = 'Scanning';

    @TestVisible
    static Map<Id, SFDC_Industry__mdt> industryMap {
        get {
            if(industryMap == null) {
                industryMap = new Map<Id, SFDC_Industry__mdt>([
                    SELECT DeveloperName, MasterLabel, Package_Id__c, Package_Namespace__c, Package_Version__c, Product_Name__c
                    FROM SFDC_Industry__mdt
                    ORDER BY MasterLabel ASC
                ]);
            }
            return industryMap;
        }
        set;
    }

    @TestVisible
    static Map<String, List<SFDC_Industry_Vertical__mdt>> industryVerticalMap {
        get {
            if(industryVerticalMap == null) {
                industryVerticalMap = Utilities.groupByStrings('Industry__r.DeveloperName', [
                    SELECT DeveloperName, MasterLabel, Industry__r.DeveloperName, Industry__c, Display_Label__c,
                        Icon_Name__c, Description_Label__c, Field__c, Value__c
                    FROM SFDC_Industry_Vertical__mdt
                    ORDER BY MasterLabel ASC
                ]);
            }
            return industryVerticalMap;
        }
        set;
    }

    @TestVisible
    static List<SFDC_Industry_Assessment_Question__mdt> industryAssessmentQuestionList {
        get {
            if(industryAssessmentQuestionList == null) {
                industryAssessmentQuestionList = [
                    SELECT DeveloperName, MasterLabel, Answer_Field_API_Name__c,
                        Question_Required__c, Question_Label_Name__c
                    FROM SFDC_Industry_Assessment_Question__mdt
                ];
            }
            return industryAssessmentQuestionList;
        }
        set;
    }

    @TestVisible
    static Map<Id, SFDC_Industry_Assessment_Question__mdt> industryAssessmentQuestionMap {
        get {
            if(industryAssessmentQuestionMap == null) {
                industryAssessmentQuestionMap = new Map<Id, SFDC_Industry_Assessment_Question__mdt>(industryAssessmentQuestionList);
            }
            return industryAssessmentQuestionMap;
        }
        set;
    }


    @TestVisible
    static List<SFDC_Industry_Assessment_Question_Branch__mdt> industryAssessmentQuestionBranchList {
        get {
            if(industryAssessmentQuestionBranchList == null) {
                industryAssessmentQuestionBranchList = [
                    SELECT Controlling_Question__c, Following_Question__c, Controlling_Question_Value__c, Is_Default_Outcome__c
                    FROM SFDC_Industry_Assessment_Question_Branch__mdt
                    ORDER BY Is_Default_Outcome__c ASC NULLS FIRST
                ];
            }
            return industryAssessmentQuestionBranchList;
        }
        set;
    }

    @TestVisible
    static Map<Id, List<SFDC_Industry_Assessment_Question_Branch__mdt>> industryAssessmentControllingQuestionBranchMap {
        get {
            if(industryAssessmentControllingQuestionBranchMap == null) {
                industryAssessmentControllingQuestionBranchMap = Utilities.groupByIds(
                    Utilities.namespaceUnderscore + 'Controlling_Question__c',
                    industryAssessmentQuestionBranchList
                );
            }
            return industryAssessmentControllingQuestionBranchMap;
        }
        set;
    }

    @TestVisible
    static Map<Id, List<SFDC_Industry_Assessment_Question_Branch__mdt>> industryAssessmentFollowingQuestionBranchMap {
        get {
            if(industryAssessmentFollowingQuestionBranchMap == null) {
                industryAssessmentFollowingQuestionBranchMap = Utilities.groupByIds(
                    Utilities.namespaceUnderscore + 'Following_Question__c',
                    industryAssessmentQuestionBranchList
                );
            }
            return industryAssessmentFollowingQuestionBranchMap;
        }
        set;
    }

    @TestVisible
    static Map<Id, List<SFDC_Industry_Assessment_Exclude__mdt>> industryAssessmentQuestionExcludeMap {
        get {
            if(industryAssessmentQuestionExcludeMap == null) {
                industryAssessmentQuestionExcludeMap = Utilities.groupByIds(Utilities.namespaceUnderscore + 'SFDC_Industry_Assessment_Question__c', [
                    SELECT SFDC_Industry_Assessment_Question__c, Controlling_Field__c, Controlling_Value__c, Exclude_Value__c
                    FROM SFDC_Industry_Assessment_Exclude__mdt
                ]);
            }
            return industryAssessmentQuestionExcludeMap;
        }
        set;
    }

    @AuraEnabled(cacheable=true)
    public static Boolean isInSandbox(){
        Organization org = [SELECT IsSandbox FROM Organization LIMIT 1];

        return org.IsSandbox;
    }

    @AuraEnabled(cacheable=true)
    public static List<VerticalInfo> getOrgVerticals(String industryName){
        List<VerticalInfo> orgVerticals = new List<VerticalInfo>();
        for(SFDC_Industry_Vertical__mdt currentVertical : industryVerticalMap.get(industryName)) {
            orgVerticals.add(new VerticalInfo(currentVertical));
        }

        return orgVerticals;
    }

    @AuraEnabled(cacheable=true)
    public static List<AssessmentInfo> getOrgAssessments(){
        List<AssessmentInfo> orgAssessments = new List<AssessmentInfo>();
        for(Assessment__c currentAssessment : [
            SELECT Id, Name, Status__c, CreatedDate, Description__c
            FROM Assessment__c
            ORDER BY CreatedDate ASC, Name ASC
        ]) {
            orgAssessments.add(new AssessmentInfo(currentAssessment));
        }

        return orgAssessments;
    }

    @AuraEnabled
    public static AssessmentQuestion getCurrentAssessmentQuestion(Id assessmentId) {
        Assessment__c currentAssessment = queryAssessment(assessmentId);
        Id questionId = (currentAssessment.Current_Question_Id__c.contains('|'))
        ? currentAssessment.Current_Question_Id__c.split('\\|')[0] : currentAssessment.Current_Question_Id__c;

        return new AssessmentQuestion(industryAssessmentQuestionMap.get(questionId), currentAssessment);
    }

    @AuraEnabled
    public static AssessmentQuestion getStartingQuestion(List<VerticalInfo> verticalList) {
        if(verticalList == null || verticalList.isEmpty()) return null;

        AssessmentQuestion startingQuestion = new AssessmentQuestion(industryAssessmentQuestionMap.get([
            SELECT Following_Question__c
            FROM SFDC_Industry_Assessment_Question_Branch__mdt
            WHERE Industry__c =: verticalList[0].IndustryId
                AND Controlling_Question__c = null
        ].Following_Question__c), 1);

        Map<String, List<String>> selectedVerticalInfoMap = new Map<String, List<String>>();
        for(VerticalInfo vertical : verticalList) {
            if(vertical.VerticalSelected == true) {
                List<String> currentValues = selectedVerticalInfoMap.get(vertical.Field);
                if(currentValues == null) {
                    selectedVerticalInfoMap.put(vertical.Field, new List<String>{vertical.Value});
                }
                else {
                    currentValues.add(vertical.value);
                }
            }
        }

        Assessment__c newAssessment = new Assessment__c(
            Current_Question_Number__c = 1,
            Current_Question_Id__c = startingQuestion.QuestionId
        );
        for(String key : selectedVerticalInfoMap.keySet()) {
            newAssessment.put(key, 	String.join(selectedVerticalInfoMap.get(key), ';'));
        }

        Database.SaveResult dmlResult = insertAssessment(newAssessment);
        startingQuestion.AssessmentId = dmlResult?.getId();
        return startingQuestion;
    }

    @AuraEnabled
    public static AssessmentQuestion saveQuestion(String currentQuestionJson){
        AssessmentQuestion nextQuestion;
        AssessmentQuestion currentQuestion = (AssessmentQuestion)JSON.deserialize(currentQuestionJson, AssessmentQuestion.class);

        // Assessment__c currentAssessment = new Assessment__c(
        //     Id = currentQuestion.AssessmentId,
        //     Status__c = STATUS_ASSESSMENT
        // );

        Assessment__c currentAssessment = queryAssessment(currentQuestion.AssessmentId);
        //currentAssessment.Status__c = STATUS_ASSESSMENT;

        try{
            if(currentQuestion.IsCheckBox == true) {
                currentAssessment.put(currentQuestion.AnswerFieldAPIName, currentQuestion.SelectedCheckbox);
            }
            else {
                currentAssessment.put(currentQuestion.AnswerFieldAPIName, currentQuestion.SelectedAnswer);
                if(currentQuestion.AnswerFieldAPIName == HAS_PERSON_ACCOUNTS_ASSESSMENT_FIELD) {
                    currentAssessment.put(
                        HAS_PERSON_ACCOUNTS_REPORT_FIELD,
                        !String.isBlank(currentQuestion.SelectedAnswer) && currentQuestion.SelectedAnswer != NO_PERSON_ACCOUNTS_ASSESSMENT_VALUE
                    );
                }
            }


            List<SFDC_Industry_Assessment_Question_Branch__mdt> branchOutcomes = industryAssessmentControllingQuestionBranchMap.get(currentQuestion.QuestionId);
            //No remaining branches assessment is complete
            if(branchOutcomes == null) {
                //currentAssessment.Status__c = STATUS_MAPPING;
            }
            else {
                SFDC_Industry_Assessment_Question_Branch__mdt selectedOutcome;
                for(SFDC_Industry_Assessment_Question_Branch__mdt outcome : branchOutcomes) {
                    if((outcome.Is_Default_Outcome__c == true) ||
                        (currentQuestion.IsCheckBox == true && currentQuestion.SelectedCheckbox != null && currentQuestion.SelectedCheckbox == Boolean.valueOf(outcome.Controlling_Question_Value__c)) ||
                        (currentQuestion.IsPicklist == true && String.isBlank(currentQuestion.SelectedAnswer) == false && currentQuestion.SelectedAnswer == outcome.Controlling_Question_Value__c) ||
                        (currentQuestion.IsMultiSelect == true && String.isBlank(currentQuestion.SelectedAnswer) == false && currentQuestion.SelectedAnswer.contains(outcome.Controlling_Question_Value__c))
                    ) {
                        selectedOutcome = outcome;
                        break;
                    }
                }

                Integer originalNumber = currentQuestion.QuestionNumber;
                //Based on the current selection there is no related branch that requires another question assessment is complete
                if(selectedOutcome == null) {
                    //currentAssessment.Status__c = STATUS_MAPPING;
                }
                //continue to next question
                else {
                    currentAssessment.Current_Question_Number__c = currentQuestion.QuestionNumber + 1;
                    //currentAssessment.Current_Question_Id__c = selectedOutcome.Following_Question__c;
                    nextQuestion = new AssessmentQuestion(selectedOutcome, currentAssessment);
                    currentAssessment.Current_Question_Number__c = originalNumber;
                }
            }

            updateAssessment(currentAssessment);
        }
        catch (Exception caughtException) {
            throw new AuraHandledException(caughtException.getMessage());
        }

        return nextQuestion;
    }


    @AuraEnabled
    public static AssessmentQuestion getPreviousQuestion(String currentQuestionJson){
        AssessmentQuestion currentQuestion = (AssessmentQuestion)JSON.deserialize(currentQuestionJson, AssessmentQuestion.class);

        List<SFDC_Industry_Assessment_Question_Branch__mdt> branchOutcomes = industryAssessmentFollowingQuestionBranchMap.get(currentQuestion.QuestionId);

        Assessment__c currentAssessment = queryAssessment(currentQuestion.AssessmentId);
        SFDC_Industry_Assessment_Question__mdt previousQuestion;
        for(SFDC_Industry_Assessment_Question_Branch__mdt outcome : branchOutcomes) {
            SFDC_Industry_Assessment_Question__mdt possiblePreviousQuestion = industryAssessmentQuestionMap.get(outcome.Controlling_Question__c);
            if(possiblePreviousQuestion != null) {
                Schema.DisplayType fieldType = ASSESSMENT_FIELD_SCHEMA.get(Utilities.namespaceUnderscore+possiblePreviousQuestion.Answer_Field_API_Name__c).getDescribe().getType();
                Object previousQuestionAnswer = currentAssessment.get(Utilities.namespaceUnderscore+possiblePreviousQuestion.Answer_Field_API_Name__c);
                if(outcome.Is_Default_Outcome__c == true ||
                    (previousQuestionAnswer != null && (
                        (fieldType == Schema.DisplayType.BOOLEAN && (Boolean)previousQuestionAnswer == Boolean.valueOf(outcome.Controlling_Question_Value__c)) ||
                        (previousQuestionAnswer != null && fieldType == Schema.DisplayType.MULTIPICKLIST && new Set<String>(((String)previousQuestionAnswer).split(';')).contains(outcome.Controlling_Question_Value__c)) ||
                        (previousQuestionAnswer != null && fieldType == Schema.DisplayType.PICKLIST && (String)previousQuestionAnswer== outcome.Controlling_Question_Value__c)
                ))) {
                    previousQuestion = possiblePreviousQuestion;
                    break;
                }
            }
        }


        //Integer originalNumber = currentQuestion.QuestionNumber;
        currentAssessment.Current_Question_Number__c = currentQuestion.QuestionNumber - 1;
        //currentAssessment.Current_Question_Id__c = previousQuestion.Id;

        AssessmentQuestion pastQuestion = new AssessmentQuestion(previousQuestion, currentAssessment);
        //currentAssessment.Current_Question_Number__c = originalNumber;

        updateAssessment(currentAssessment);

        return pastQuestion;
    }

    @AuraEnabled
    public static Boolean setStatus(String assessmentId, String questionId, String index, String mappingIndex, String numberChange) {

        Assessment__c currentAssessment = [SELECT Id, Current_Question_Id__c, Current_Question_Number__c, Status__c
        FROM Assessment__c WHERE Id = :assessmentId];
        if(questionId == 'MAP'){
            currentAssessment.Status__c = STATUS_MAPPING;
        }else{
            String qId = (!String.isBlank(mappingIndex)) ? questionId + '|' + mappingIndex : questionId;
            currentAssessment.Current_Question_Id__c = qId;
            //Set question number if neeeded
            if(numberChange=='next'){
                currentAssessment.Current_Question_Number__c = currentAssessment.Current_Question_Number__c + 1;
            }
            //currentAssessment.Current_Question_Number__c = Integer.valueOf(index);
            currentAssessment.Status__c = STATUS_ASSESSMENT;
        }

        updateAssessment(currentAssessment);

		return true;
	}

    @AuraEnabled
    public static Id getMappingSection(String currentQuestionJson){
        Id mappingSectionId;
        AssessmentQuestion currentQuestion;
        try{
            currentQuestion = (AssessmentQuestion)JSON.deserialize(currentQuestionJson, AssessmentQuestion.class);
        } catch(Exception caughtException) {
            throw new AuraHandledException(caughtException.getMessage());
        }
        if (currentQuestion != null) {
            //Query mapping metadata
            List<SFDC_Industry_Mapping_Section__mdt> mappingSections = [SELECT Id, Triggering_Answer__c FROM SFDC_Industry_Mapping_Section__mdt WHERE Controlling_Question__c = :currentQuestion.QuestionId];
            if(!mappingSections.isEmpty()){
                System.debug('==TEST: '+mappingSections[0]);
                if(!String.isBlank(mappingSections[0].Triggering_Answer__c)){
                    if(currentQuestionJson.contains(ToolingService.customLabelMap.get(Utilities.namespaceUnderscore + mappingSections[0].Triggering_Answer__c))){
                        mappingSectionId = mappingSections[0].Id;
                    }
                }else{
                    mappingSectionId = mappingSections[0].Id;
                }
            }
        }
        return mappingSectionId;
    }

    /**
	 * Query Assessment Record by ID
	 * select all accessible fields
	 */
	public static Assessment__c queryAssessment(Id assessmentId) {
		//determine all fields to query
		Set<String> fieldNames = new Set<String>();
		for(Schema.SObjectField field : Schema.SObjectType.Assessment__c.fields.getMap().values()) {
			Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
			if(fieldDescribe.isAccessible() || Test.isRunningTest()) {
				fieldNames.add(fieldDescribe.getName());
			}
		}
		return queryAssessment(assessmentId, fieldNames);
	}

    /**
     * Insert  Assessment__c with Object and FLS security checks
     */
    public static Database.SaveResult insertAssessment(Assessment__c assessment) {
        Database.SaveResult result;
        try {
            // Strip fields that are not creatable and perform object create access check
            SObjectAccessDecision decision = Security.stripInaccessible(AccessType.CREATABLE, new List<SObject>{assessment}, true);
            result = Database.insert(Test.isRunningTest() ? new List<SObject>{assessment} : decision.getRecords())[0];
        } catch (System.NoAccessException e) {
            //No object create access
            System.debug(e.getMessage());
        }
        return result;
    }

    /**
     * Update Assessment__c with Object and FLS security checks
     */
    public static Database.SaveResult updateAssessment(Assessment__c assessment) {
        Database.SaveResult result;
        try {
            // Strip fields that are not updateable and perform object update access check
            SObjectAccessDecision decision = Security.stripInaccessible(AccessType.UPDATABLE, new List<SObject>{assessment}, true);
            result = Database.update(Test.isRunningTest() ? new List<SObject>{assessment} : decision.getRecords())[0];
        } catch (System.NoAccessException e) {
            //No object update access
            System.debug(e.getMessage());
        }
        return result;
    }

    /**
     * Clones a single Assessment__c record
     */
    @AuraEnabled
    public static Id cloneAssessment(Id assessmentId){
        Id clonedId;
        if(assessmentId != null){
            try{
                Assessment__c source = [SELECT Id, MappingDataJson__c, Customer_Representation__c, Description__c, External_Data_In_Salesforce__c,
                Financial_Accounts_Leveraged__c, Has_Branch_Management__c, Has_Relationship_Groups__c, HasMappingData__c, 
                Is_B2C__c, Relationship_Groupings__c, Selected_Products__c FROM Assessment__c WHERE Id = :assessmentId];
                Assessment__c clone = source.clone();
                clone.Status__c = STATUS_ASSESSMENT;
                clone.Current_Question_Number__c = 1;
                clone.Current_Question_Id__c = [SELECT Following_Question__c FROM SFDC_Industry_Assessment_Question_Branch__mdt WHERE DeveloperName = :STARTING_QUESTION_API_NAME LIMIT 1].Following_Question__c;
                Database.SaveResult createResult = insertAssessment(clone);
                if(createResult?.isSuccess()){
                    clonedId = createResult.getId();
                }
            }catch (Exception caughtException) {
                throw new AuraHandledException(caughtException.getMessage());
            }
        }
        return clonedId;
    }

	/**
	 * Query Assessment Record by ID
	 * select specific fields
	 */
	public static Assessment__c queryAssessment(Id assessmentId, Set<String> fieldApiNames) {
		Assessment__c assessment;

		if (assessmentId != null && fieldApiNames != null) {
			String dynamicQuery = 'SELECT {0} FROM ' + Utilities.namespaceUnderscore + 'Assessment__c WHERE Id = :assessmentId';
			List<Assessment__c> assessmentList = Database.query(String.format(dynamicQuery, new List<String>{
				String.join(new List<String>(fieldApiNames), ', ')
			}));

			if (!assessmentList.isEmpty()) {
				assessment = assessmentList[0];
			}
		}

		return assessment;
	}

    @AuraEnabled
    public static void updateAssessmentDescription(Id assessmentId, String description) {
        updateAssessment(new Assessment__c(
            Id =  assessmentId,
            Description__c = description
        ));
    }

    @TestVisible
    static Set<String> evaluateExcludes(SFDC_Industry_Assessment_Question__mdt question, Assessment__c currentAssessment) {

        List<SFDC_Industry_Assessment_Exclude__mdt> excludeList = industryAssessmentQuestionExcludeMap.get(question.Id);
        if(excludeList == null) return new Set<String>();

        Set<String> excludeValues = new Set<String>();
        for(SFDC_Industry_Assessment_Exclude__mdt exclude : excludeList) {
            String namespacedControllingField = Utilities.namespaceUnderscore + exclude.Controlling_Field__c;
            String dataType = ASSESSMENT_FIELD_SCHEMA.get(namespacedControllingField).getDescribe().getType().name();

            if(currentAssessment.get(namespacedControllingField) != null && (
                (dataType == Schema.DisplayType.PICKLIST.name() && currentAssessment.get(namespacedControllingField) == exclude.Controlling_Value__c) ||
                (dataType == Schema.DisplayType.MULTIPICKLIST.name() && new Set<String>(((String)currentAssessment.get(namespacedControllingField)).split(';')) == new Set<String>(exclude.Controlling_Value__c.split(';'))) ||
                (dataType == Schema.DisplayType.BOOLEAN.name() && currentAssessment.get(namespacedControllingField) == Boolean.valueOf(exclude.Controlling_Value__c))
            )) {
                excludeValues.add(exclude.Exclude_Value__c);
            }
        }
        
        return excludeValues;
    }

    public class VerticalInfo {
        @AuraEnabled
        public Id VerticalId {get;set;}
        @AuraEnabled
        public Id IndustryId {get;set;}
        @AuraEnabled
        public String Name {get;set;}
        @AuraEnabled
        public String Icon {get;set;}
        @AuraEnabled
        public String Description {get;set;}
        @AuraEnabled
        public String Field {get;set;}
        @AuraEnabled
        public String Value {get;set;}
        @AuraEnabled
        public Boolean VerticalSelected{get;set;}

        public VerticalInfo() {}

        public VerticalInfo(SFDC_Industry_Vertical__mdt vertical) {
            this.VerticalId = vertical.Id;
            this.IndustryId = vertical.Industry__c;
            this.Name = ToolingService.customLabelMap.get(Utilities.namespaceUnderscore + vertical.Display_Label__c) == null ? '' : ToolingService.customLabelMap.get(Utilities.namespaceUnderscore + vertical.Display_Label__c);
            this.Icon = vertical.Icon_Name__c;
            this.Description = ToolingService.customLabelMap.get(Utilities.namespaceUnderscore + vertical.Description_Label__c) == null ? '' : ToolingService.customLabelMap.get(Utilities.namespaceUnderscore + vertical.Description_Label__c);
            this.Field = vertical.Field__c;
            this.Value = vertical.Value__c;
            this.VerticalSelected = false;
        }
    }


    public class AssessmentInfo {
        @AuraEnabled
        public Id AssessmentId {get;set;}
        @AuraEnabled
        public String Name {get;set;}
        @AuraEnabled
        public String Status {get;set;}
        @AuraEnabled
        public Datetime CreatedDate {get;set;}
        @AuraEnabled
        public String Description {get;set;}
        @AuraEnabled
        public Boolean InProgress {get;set;}
        @AuraEnabled
        public Boolean Editable {get;set;}

        public AssessmentInfo() {}

        public AssessmentInfo(Assessment__c assessment) {
            this.AssessmentId = assessment.Id;
            this.Name = assessment.Name;
            this.Status = assessment.Status__c;
            this.CreatedDate = assessment.CreatedDate;
            this.Description = assessment.Description__c;
            this.InProgress = assessment.Status__c != STATUS_REVIEW && assessment.Status__c != STATUS_SCANNING;
            this.Editable = false;

        }
    }

    public class AssessmentQuestion {
        @AuraEnabled
        public String AssessmentId {get;set;}

        @AuraEnabled
        public String QuestionId {get;set;}

        @AuraEnabled
        public String CurrentMappingIndex {get;set;}

        @AuraEnabled
        public Integer QuestionNumber {get; set;}

        @AuraEnabled
        public String QuestionText {get; set;}

        @AuraEnabled
        public String AnswerFieldAPIName {get; set;}

        @AuraEnabled
        public String AnswerDataType {get; set;}

        @AuraEnabled
        public List<Schema.PicklistEntry> AnswerValues {get; set;}

        @AuraEnabled
        public String SelectedAnswer {get; set;}

        @AuraEnabled
        public List<String> SelectedAnswers {get; set;}

        @AuraEnabled
        public Boolean SelectedCheckbox {get; set;}

        @AuraEnabled
        public Boolean AnsweredQuestion {get; set;}

        @AuraEnabled
        public Boolean IsPicklist {get; set;}

        @AuraEnabled
        public Boolean IsMultiSelect {get; set;}

        @AuraEnabled
        public Boolean IsCheckBox {get; set;}

        @AuraEnabled
        public Boolean IsRequired {get; set;}

        @AuraEnabled
        public Boolean HasError {get; set;}

        @AuraEnabled
        public String ErrorMessage {get; set;}

        @AuraEnabled
        public Set<String> ExcludeOptions {get; set;}

        public AssessmentQuestion(SFDC_Industry_Assessment_Question__mdt questionTemplate, Integer questionNumber) {
            this.QuestionId = questionTemplate.Id;
            this.QuestionNumber = questionNumber;
            this.AnswerFieldAPIName =  Utilities.namespaceUnderscore + questionTemplate.Answer_Field_API_Name__c;
            this.AnswerDataType = ASSESSMENT_FIELD_SCHEMA.get(this.AnswerFieldAPIName).getDescribe().getType().name();
            this.SelectedAnswers = new List<String>();
            this.ExcludeOptions = new Set<String>();
            this.IsRequired = questionTemplate.Question_Required__c;
            this.QuestionText = String.format(
                ASSESSMENT_QUESTION_TEMPLATE,
                new List<Object>{
                    this.QuestionNumber,
                    ToolingService.customLabelMap.get(Utilities.namespaceUnderscore + questionTemplate.Question_Label_Name__c) == null ? '' : ToolingService.customLabelMap.get(Utilities.namespaceUnderscore + questionTemplate.Question_Label_Name__c)
            });

            if(this.AnswerDataType == Schema.DisplayType.PICKLIST.name()) {
                this.SelectedAnswer = (String)ASSESSMENT_FIELD_SCHEMA.get(this.AnswerFieldAPIName).getDescribe().getDefaultValue() == null ? '' : (String)ASSESSMENT_FIELD_SCHEMA.get(this.AnswerFieldAPIName).getDescribe().getDefaultValue();
                this.IsPicklist = true;
            }
            else if(this.AnswerDataType == Schema.DisplayType.MULTIPICKLIST.name()) {
                this.SelectedAnswer = (String)ASSESSMENT_FIELD_SCHEMA.get(this.AnswerFieldAPIName).getDescribe().getDefaultValue() == null ? '' : (String)ASSESSMENT_FIELD_SCHEMA.get(this.AnswerFieldAPIName).getDescribe().getDefaultValue();
                this.IsMultiSelect = true;
            }
            else if(this.AnswerDataType == Schema.DisplayType.BOOLEAN.name()) {
                this.SelectedCheckbox = (Boolean)ASSESSMENT_FIELD_SCHEMA.get(this.AnswerFieldAPIName).getDescribe().getDefaultValue();
                this.IsCheckBox = true;

            }

            if(questionTemplate.Answer_Field_API_Name__c == HAS_PERSON_ACCOUNTS_ASSESSMENT_FIELD && Schema.sObjectType.Account.fields.getMap().containsKey('isPersonAccount') == true) {
                this.SelectedAnswer = HAS_PERSON_ACCOUNTS_ASSESSMENT_VALUE;
            }
        }

        public AssessmentQuestion(SFDC_Industry_Assessment_Question__mdt questionTemplate, Assessment__c currentAssessment) {
            this.AssessmentId = currentAssessment.Id;
            this.QuestionId = questionTemplate.Id;
            this.CurrentMappingIndex = (currentAssessment.Current_Question_Id__c != null && currentAssessment.Current_Question_Id__c.contains('|'))
            ? currentAssessment.Current_Question_Id__c.split('\\|')[1] : '';
            this.QuestionNumber = (Integer)currentAssessment.Current_Question_Number__c;
            this.AnswerFieldAPIName =  Utilities.namespaceUnderscore + questionTemplate.Answer_Field_API_Name__c;
            this.AnswerDataType = ASSESSMENT_FIELD_SCHEMA.get(this.AnswerFieldAPIName).getDescribe().getType().name();
            this.SelectedAnswers = new List<String>();
            this.ExcludeOptions = new Set<String>();
            this.IsRequired = questionTemplate.Question_Required__c;
            this.QuestionText = String.format(
                ASSESSMENT_QUESTION_TEMPLATE,
                new List<Object>{
                    this.QuestionNumber,
                    ToolingService.customLabelMap.get(Utilities.namespaceUnderscore + questionTemplate.Question_Label_Name__c) == null ? '' : ToolingService.customLabelMap.get(Utilities.namespaceUnderscore + questionTemplate.Question_Label_Name__c)
            });

            if(this.AnswerDataType == Schema.DisplayType.PICKLIST.name()) {
                this.SelectedAnswer = (String)currentAssessment.get(this.AnswerFieldAPIName);
                this.AnsweredQuestion = this.SelectedAnswer != null;
                this.IsPicklist = true;
                this.ExcludeOptions = evaluateExcludes(questionTemplate, currentAssessment);
            }
            else if(this.AnswerDataType == Schema.DisplayType.MULTIPICKLIST.name()) {
                this.SelectedAnswer = (String)currentAssessment.get(this.AnswerFieldAPIName);
                this.AnsweredQuestion = this.SelectedAnswer != null;
                this.SelectedAnswers = this.SelectedAnswer == null ? new List<String>() : this.SelectedAnswer.split(';');
                this.IsMultiSelect = true;
                this.ExcludeOptions = evaluateExcludes(questionTemplate, currentAssessment);
            }
            else if(this.AnswerDataType == Schema.DisplayType.BOOLEAN.name()) {
                this.SelectedCheckbox = (Boolean)currentAssessment.get(this.AnswerFieldAPIName);
                this.AnsweredQuestion = this.SelectedCheckbox != null;
                this.IsCheckBox = true;
            }
        }

        public AssessmentQuestion(SFDC_Industry_Assessment_Question_Branch__mdt questionBranch, Assessment__c currentAssessment) {
            SFDC_Industry_Assessment_Question__mdt questionTemplate = industryAssessmentQuestionMap.get(questionBranch.Following_Question__c);
            this.AssessmentId = currentAssessment.Id;
            this.QuestionId = questionTemplate.Id;
            this.QuestionNumber = (Integer)currentAssessment.Current_Question_Number__c;
            this.AnswerFieldAPIName =  Utilities.namespaceUnderscore + questionTemplate.Answer_Field_API_Name__c;
            this.AnswerDataType = ASSESSMENT_FIELD_SCHEMA.get(this.AnswerFieldAPIName).getDescribe().getType().name();
            this.SelectedAnswers = new List<String>();
            this.ExcludeOptions = new Set<String>();
            this.IsRequired = questionTemplate.Question_Required__c;
            this.QuestionText = String.format(
                ASSESSMENT_QUESTION_TEMPLATE,
                new List<Object>{
                    this.QuestionNumber,
                    ToolingService.customLabelMap.get(Utilities.namespaceUnderscore + questionTemplate.Question_Label_Name__c) == null ? '' : ToolingService.customLabelMap.get(Utilities.namespaceUnderscore + questionTemplate.Question_Label_Name__c)
            });

            if(this.AnswerDataType == Schema.DisplayType.PICKLIST.name()) {
                this.SelectedAnswer = (String)currentAssessment.get(this.AnswerFieldAPIName);
                this.AnsweredQuestion = this.SelectedAnswer != null;
                this.IsPicklist = true;
                this.ExcludeOptions = evaluateExcludes(questionTemplate, currentAssessment);
            }
            else if(this.AnswerDataType == Schema.DisplayType.MULTIPICKLIST.name()) {
                this.SelectedAnswer = (String)currentAssessment.get(this.AnswerFieldAPIName);
                this.AnsweredQuestion = this.SelectedAnswer != null;
                this.SelectedAnswers = this.SelectedAnswer == null ? new List<String>() : this.SelectedAnswer.split(';');
                this.IsMultiSelect = true;
                this.ExcludeOptions = evaluateExcludes(questionTemplate, currentAssessment);
            }
            else if(this.AnswerDataType == Schema.DisplayType.BOOLEAN.name()) {
                this.SelectedCheckbox = (Boolean)currentAssessment.get(this.AnswerFieldAPIName);
                this.AnsweredQuestion = this.SelectedCheckbox != null;
                this.IsCheckBox = true;
            }
        }

        public AssessmentQuestion() {}
    }
}