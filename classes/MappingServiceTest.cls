@isTest
private class MappingServiceTest {
    static final String EXTERNAL_STRINGS = '{ "size": 15, "totalSize": 15, "done": true, "queryLocator": null, "entityTypeName": "ExternalString", "records": [ { "attributes": { "type": "ExternalString", "url": "/services/data/v50.0/tooling/sobjects/ExternalString/1014x000007AblEAAS" }, "Id": "1014x000007AblEAAS", "Name": "MappingDocTitle", "Value": "Transition Approach", "Language": "en_US" }, { "attributes": { "type": "ExternalString", "url": "/services/data/v50.0/tooling/sobjects/ExternalString/1014x000007AblYAAS" }, "Id": "1014x000007AblYAAS", "Name": "MappingDocExtension", "Value": "Assessment Results", "Language": "en_US" }, { "attributes": { "type": "ExternalString", "url": "/services/data/v50.0/tooling/sobjects/ExternalString/1014x000007AbldAAC" }, "Id": "1014x000007AbldAAC", "Name": "MappingDocColumnSection", "Value": "Migration Analysis", "Language": "en_US" }, { "attributes": { "type": "ExternalString", "url": "/services/data/v50.0/tooling/sobjects/ExternalString/1014x000007Abl4AAC" }, "Id": "1014x000007Abl4AAC", "Name": "MappingDocColumnType", "Value": "Intro", "Language": "en_US" }, { "attributes": { "type": "ExternalString", "url": "/services/data/v50.0/tooling/sobjects/ExternalString/1014x000007AblTAAS" }, "Id": "1014x000007AblTAAS", "Name": "MappingDocColumnSourceObject", "Value": "Upgrade Recommendation", "Language": "en_US" }, { "attributes": { "type": "ExternalString", "url": "/services/data/v50.0/tooling/sobjects/ExternalString/1014x00000FAMcRAAX" }, "Id": "1014x00000FAMcRAAX", "Name": "MappingDocColumnDestObject", "Value": "What industry product would you like to transition to?", "Language": "en_US" }, { "attributes": { "type": "ExternalString", "url": "/services/data/v50.0/tooling/sobjects/ExternalString/1014x00000FAMcWAAX" }, "Id": "1014x00000FAMcWAAX", "Name": "MappingDocColumnSource", "Value": "How is your customer represented?", "Language": "en_US" }, { "attributes": { "type": "ExternalString", "url": "/services/data/v50.0/tooling/sobjects/ExternalString/1014x00000FAMcbAAH" }, "Id": "1014x00000FAMcbAAH", "Name": "MappingDocColumnDest", "Value": "Do you group together your customers through any shared relationships?", "Language": "en_US" }, { "attributes": { "type": "ExternalString", "url": "/services/data/v50.0/tooling/sobjects/ExternalString/1014x00000FAMcgAAH" }, "Id": "1014x00000FAMcgAAH", "Name": "MappingDocSectionAdditional", "Value": "Do these groups aggregate or summarize counts/sums of customer related products,services, or activities?", "Language": "en_US" }, { "attributes": { "type": "ExternalString", "url": "/services/data/v50.0/tooling/sobjects/ExternalString/1014x00000FAGK9AAP" }, "Id": "1014x00000FAGK9AAP", "Name": "MappingDocTypeField", "Value": "Here\'s a high-level view of how FSC features and customizations can be approached for possible migration . Use this information to create the first draft of your gap analysis. To get a closer look, click the link for each feature or customization for recommendations for specific changes. But remember: You\'re the Salesforce expert at your company. Leverage the usage data in each section to decide whether our recommendations are worth your effort. For example, if the report identifies AppExchange packages require a thoughtful rollout but no one is using them, cross that feature off your gap analysis.", "Language": "en_US" }, { "attributes": { "type": "ExternalString", "url": "/services/data/v50.0/tooling/sobjects/ExternalString/1014x00000FAGK9AAP" }, "Id": "1014x00000FAGK9AAP", "Name": "MappingDocTypeRT", "Value": "Here\'s a high-level view of how FSC features and customizations can be approached for possible migration . Use this information to create the first draft of your gap analysis. To get a closer look, click the link for each feature or customization for recommendations for specific changes. But remember: You\'re the Salesforce expert at your company. Leverage the usage data in each section to decide whether our recommendations are worth your effort. For example, if the report identifies AppExchange packages require a thoughtful rollout but no one is using them, cross that feature off your gap analysis.", "Language": "en_US" }, { "attributes": { "type": "ExternalString", "url": "/services/data/v50.0/tooling/sobjects/ExternalString/1014x00000FAGK9AAP" }, "Id": "1014x00000FAGK9AAP", "Name": "MappingDocColumnDataType", "Value": "Data Type", "Language": "en_US" }, { "attributes": { "type": "ExternalString", "url": "/services/data/v50.0/tooling/sobjects/ExternalString/1014x00000FAGK9AAP" }, "Id": "1014x00000FAGK9AAP", "Name": "MappingDocColumnDecimalPlaces", "Value": "Decimal Places", "Language": "en_US" }, { "attributes": { "type": "ExternalString", "url": "/services/data/v50.0/tooling/sobjects/ExternalString/1014x00000FAGK9AAP" }, "Id": "1014x00000FAGK9AAP", "Name": "MappingDocColumnConflict", "Value": "Conflict for Transition?", "Language": "en_US" }, { "attributes": { "type": "ExternalString", "url": "/services/data/v50.0/tooling/sobjects/ExternalString/1014x00000FAGK9AAP" }, "Id": "1014x00000FAGK9AAP", "Name": "MappingDocColumnRequired", "Value": "Required?", "Language": "en_US" }, { "attributes": { "type": "ExternalString", "url": "/services/data/v50.0/tooling/sobjects/ExternalString/1014x00000FAGK9AAP" }, "Id": "1014x00000FAGK9AAP", "Name": "MappingDocColumnLength", "Value": "Length", "Language": "en_US" } ] }';
    static final String MAPPING_JSON = '{"recommended":[{"mappingData":[{"destination":"Account","fieldMapping":[{"source":"MasterRecordId","destination":"MasterRecordId","userGenerated":"true"},{"source":"LastName","destination":"LastName","userGenerated":"true"},{"source":"FirstName","destination":"FirstName","userGenerated":"true"},{"source":"Salutation","destination":"Salutation","userGenerated":"true"},{"source":"Name","destination":"Name","userGenerated":"true"},{"source":"OtherStreet","destination":"PersonOtherStreet","userGenerated":"true"},{"source":"OtherCity","destination":"PersonOtherCity","userGenerated":"true"},{"source":"OtherState","destination":"PersonOtherState","userGenerated":"true"},{"source":"OtherPostalCode","destination":"PersonOtherPostalCode","userGenerated":"true"},{"source":"OtherCountry","destination":"PersonOtherCountry","userGenerated":"true"},{"source":"OtherLatitude","destination":"PersonOtherLatitude","userGenerated":"true"},{"source":"OtherLongitude","destination":"PersonOtherLongitude","userGenerated":"true"},{"source":"OtherGeocodeAccuracy","destination":"PersonOtherGeocodeAccuracy","userGenerated":"true"},{"source":"OtherAddress","destination":"PersonOtherAddress","userGenerated":"true"},{"source":"MailingStreet","destination":"PersonMailingStreet","userGenerated":"true"},{"source":"MailingCity","destination":"PersonMailingCity","userGenerated":"true"},{"source":"MailingState","destination":"PersonMailingState","userGenerated":"true"},{"source":"MailingPostalCode","destination":"PersonMailingPostalCode","userGenerated":"true"},{"source":"MailingCountry","destination":"PersonMailingCountry","userGenerated":"true"},{"source":"MailingLatitude","destination":"PersonMailingLatitude","userGenerated":"true"},{"source":"MailingLongitude","destination":"PersonMailingLongitude","userGenerated":"true"},{"source":"MailingGeocodeAccuracy","destination":"PersonMailingGeocodeAccuracy","userGenerated":"true"},{"source":"MailingAddress","destination":"PersonMailingAddress","userGenerated":"true"},{"source":"Phone","destination":"Phone","userGenerated":"true"},{"source":"Fax","destination":"Fax","userGenerated":"true"},{"source":"HomePhone","destination":"PersonHomePhone","userGenerated":"true"},{"source":"OtherPhone","destination":"PersonOtherPhone","userGenerated":"true"},{"source":"AssistantPhone","destination":"PersonAssistantPhone","userGenerated":"true"},{"source":"Email","destination":"PersonEmail","userGenerated":"true"},{"source":"Title","destination":"PersonTitle","userGenerated":"true"},{"source":"Department","destination":"PersonDepartment","userGenerated":"true"},{"source":"LeadSource","destination":"PersonLeadSource","userGenerated":"true"},{"source":"Birthdate","destination":"PersonBirthdate","userGenerated":"true"},{"source":"Description","destination":"Description","userGenerated":"true"},{"source":"OwnerId","destination":"OwnerId","userGenerated":"true"},{"source":"CreatedDate","destination":"CreatedDate","userGenerated":"true"},{"source":"CreatedById","destination":"CreatedById","userGenerated":"true"},{"source":"LastModifiedDate","destination":"LastModifiedDate","userGenerated":"true"},{"source":"LastModifiedById","destination":"LastModifiedById","userGenerated":"true"},{"source":"LastActivityDate","destination":"LastActivityDate","userGenerated":"true"},{"source":"LastCURequestDate","destination":"PersonLastCURequestDate","userGenerated":"true"},{"source":"LastCUUpdateDate","destination":"PersonLastCUUpdateDate","userGenerated":"true"},{"source":"EmailBouncedReason","destination":"PersonEmailBouncedReason","userGenerated":"true"},{"source":"EmailBouncedDate","destination":"PersonEmailBouncedDate","userGenerated":"true"},{"source":"PhotoUrl","destination":"PhotoUrl","userGenerated":"true"},{"source":"Jigsaw","destination":"Jigsaw","userGenerated":"true"},{"source":"IndividualId","destination":"PersonIndividualId","userGenerated":"true"}],"recordTypeMapping":[{"source":"Master","destination":"Master","userGenerated":"true"}],"showDetails":true,"source":"Contact"}],"sectionName":"People (B2C)"},{"mappingData":[{"destination":"FinServ__FinancialAccount__c","fieldMapping":[{"source":"Name","destination":"Name","userGenerated":"true"},{"source":"AccountNumber","destination":"FinServ__FinancialAccountNumber__c","userGenerated":"true"},{"source":"Ownership","destination":"FinServ__Ownership__c","userGenerated":"true"},{"source":"OwnerId","destination":"OwnerId","userGenerated":"true"},{"source":"CreatedDate","destination":"CreatedDate","userGenerated":"true"},{"source":"CreatedById","destination":"CreatedById","userGenerated":"true"},{"source":"LastModifiedDate","destination":"LastModifiedDate","userGenerated":"true"},{"source":"LastModifiedById","destination":"LastModifiedById","userGenerated":"true"},{"source":"LastActivityDate","destination":"LastActivityDate","userGenerated":"true"}],"recordTypeMapping":[{"source":"Master","destination":"Master","userGenerated":"true"}],"showDetails":true,"source":"Account"},{"destination":"FinServ__FinancialAccountRole__c","fieldMapping":[{}],"recordTypeMapping":[{}],"source":""}],"sectionName":"Checking Account"},{"mappingData":[{"destination":"FinServ__FinancialAccount__c","fieldMapping":[{"source":"OwnerId","destination":"OwnerId","userGenerated":"true"},{"source":"Name","destination":"Name","userGenerated":"true"},{"source":"CreatedDate","destination":"CreatedDate","userGenerated":"true"},{"source":"CreatedById","destination":"CreatedById","userGenerated":"true"},{"source":"LastModifiedDate","destination":"LastModifiedDate","userGenerated":"true"},{"source":"LastModifiedById","destination":"LastModifiedById","userGenerated":"true"},{"source":"Name","destination":"FinServ__Status__c","userGenerated":"true"}],"recordTypeMapping":[{"source":"Master","destination":"Master","userGenerated":"true"}],"showDetails":true,"source":"Account"},{"destination":"FinServ__FinancialAccountRole__c","fieldMapping":[{}],"recordTypeMapping":[{}],"source":""}],"sectionName":"Loans"}],"additional":[]}';
    static final String FSC_DATA_JSON = '{"FinServ__FinancialAccount__c":{"name":"FinServ__FinancialAccount__c","label":"Financial Account","recordTypeInfos":[{"active":true,"available":true,"defaultRecordTypeMapping":true,"developerName":"BankingAccount","master":false,"name":"Bank Account","recordTypeId":"01256000001bZWrAAM","urls":{"layout":"/services/data/v50.0/sobjects/FinServ__FinancialAccount__c/describe/layouts/01256000001bZWrAAM"}}],"fields":[{"aggregatable":true,"aiPredictionField":false,"autoNumber":false,"byteLength":18,"calculated":false,"calculatedFormula":null,"cascadeDelete":false,"caseSensitive":false,"compoundFieldName":null,"controllerName":null,"createable":true,"custom":true,"defaultValue":null,"defaultValueFormula":null,"defaultedOnCreate":false,"dependentPicklist":false,"deprecatedAndHidden":false,"digits":0,"displayLocationInDecimal":false,"encrypted":false,"externalId":false,"extraTypeInfo":null,"filterable":true,"filteredLookupInfo":{"controllingFields":[],"dependent":false,"optionalFilter":false},"formulaTreatNullNumberAsZero":false,"groupable":true,"highScaleNumber":false,"htmlFormatted":false,"idLookup":false,"inlineHelpText":null,"label":"Primary Owner","length":18,"mask":null,"maskType":null,"name":"FinServ__PrimaryOwner__c","nameField":false,"namePointing":false,"nillable":false,"permissionable":false,"picklistValues":[],"polymorphicForeignKey":false,"precision":0,"queryByDistance":false,"referenceTargetField":null,"referenceTo":["Account"],"relationshipName":"FinServ__PrimaryOwner__r","relationshipOrder":null,"restrictedDelete":true,"restrictedPicklist":false,"scale":0,"searchPrefilterable":true,"soapType":"tns:ID","sortable":true,"type":"reference","unique":false,"updateable":true,"writeRequiresMasterRead":false}]},"FinServ__FinancialAccountRole__c":{"name":"FinServ__FinancialAccountRole__c","label":"Financial Account Role","recordTypeInfos":[],"fields":[]}}';
    static final String MAPPING_JSON_COMPLETE = '{"recommended":[{"mappingData":[{"destination":"Account","fieldMapping":[{"source":"MasterRecordId","destination":"MasterRecordId","userGenerated":"true"},{"source":"LastName","destination":"LastName","userGenerated":"true"},{"source":"FirstName","destination":"FirstName","userGenerated":"true"},{"source":"Salutation","destination":"Salutation","userGenerated":"true"},{"source":"Name","destination":"Name","userGenerated":"true"},{"source":"OtherStreet","destination":"PersonOtherStreet","userGenerated":"true"},{"source":"OtherCity","destination":"PersonOtherCity","userGenerated":"true"},{"source":"OtherState","destination":"PersonOtherState","userGenerated":"true"},{"source":"OtherPostalCode","destination":"PersonOtherPostalCode","userGenerated":"true"},{"source":"OtherCountry","destination":"PersonOtherCountry","userGenerated":"true"},{"source":"OtherLatitude","destination":"PersonOtherLatitude","userGenerated":"true"},{"source":"OtherLongitude","destination":"PersonOtherLongitude","userGenerated":"true"},{"source":"OtherGeocodeAccuracy","destination":"PersonOtherGeocodeAccuracy","userGenerated":"true"},{"source":"OtherAddress","destination":"PersonOtherAddress","userGenerated":"true"},{"source":"MailingStreet","destination":"PersonMailingStreet","userGenerated":"true"},{"source":"MailingCity","destination":"PersonMailingCity","userGenerated":"true"},{"source":"MailingState","destination":"PersonMailingState","userGenerated":"true"},{"source":"MailingPostalCode","destination":"PersonMailingPostalCode","userGenerated":"true"},{"source":"MailingCountry","destination":"PersonMailingCountry","userGenerated":"true"},{"source":"MailingLatitude","destination":"PersonMailingLatitude","userGenerated":"true"},{"source":"MailingLongitude","destination":"PersonMailingLongitude","userGenerated":"true"},{"source":"MailingGeocodeAccuracy","destination":"PersonMailingGeocodeAccuracy","userGenerated":"true"},{"source":"MailingAddress","destination":"PersonMailingAddress","userGenerated":"true"},{"source":"Phone","destination":"Phone","userGenerated":"true"},{"source":"Fax","destination":"Fax","userGenerated":"true"},{"source":"HomePhone","destination":"PersonHomePhone","userGenerated":"true"},{"source":"OtherPhone","destination":"PersonOtherPhone","userGenerated":"true"},{"source":"AssistantPhone","destination":"PersonAssistantPhone","userGenerated":"true"},{"source":"Email","destination":"PersonEmail","userGenerated":"true"},{"source":"Title","destination":"PersonTitle","userGenerated":"true"},{"source":"Department","destination":"PersonDepartment","userGenerated":"true"},{"source":"LeadSource","destination":"PersonLeadSource","userGenerated":"true"},{"source":"Birthdate","destination":"PersonBirthdate","userGenerated":"true"},{"source":"Description","destination":"Description","userGenerated":"true"},{"source":"OwnerId","destination":"OwnerId","userGenerated":"true"},{"source":"CreatedDate","destination":"CreatedDate","userGenerated":"true"},{"source":"CreatedById","destination":"CreatedById","userGenerated":"true"},{"source":"LastModifiedDate","destination":"LastModifiedDate","userGenerated":"true"},{"source":"LastModifiedById","destination":"LastModifiedById","userGenerated":"true"},{"source":"LastActivityDate","destination":"LastActivityDate","userGenerated":"true"},{"source":"LastCURequestDate","destination":"PersonLastCURequestDate","userGenerated":"true"},{"source":"LastCUUpdateDate","destination":"PersonLastCUUpdateDate","userGenerated":"true"},{"source":"EmailBouncedReason","destination":"PersonEmailBouncedReason","userGenerated":"true"},{"source":"EmailBouncedDate","destination":"PersonEmailBouncedDate","userGenerated":"true"},{"source":"PhotoUrl","destination":"PhotoUrl","userGenerated":"true"},{"source":"Jigsaw","destination":"Jigsaw","userGenerated":"true"},{"source":"IndividualId","destination":"PersonIndividualId","userGenerated":"true"}],"recordTypeMapping":[{"source":"Master","destination":"Master","userGenerated":"true"}],"showDetails":true,"source":"Contact"}],"sectionName":"People (B2C)"},{"mappingData":[{"destination":"FinServ__FinancialAccount__c","fieldMapping":[{"source":"Name","destination":"Name","userGenerated":"true"},{"source":"AccountNumber","destination":"FinServ__FinancialAccountNumber__c","userGenerated":"true"},{"source":"Ownership","destination":"FinServ__Ownership__c","userGenerated":"true"},{"source":"OwnerId","destination":"OwnerId","userGenerated":"true"},{"source":"CreatedDate","destination":"CreatedDate","userGenerated":"true"},{"source":"CreatedById","destination":"CreatedById","userGenerated":"true"},{"source":"LastModifiedDate","destination":"LastModifiedDate","userGenerated":"true"},{"source":"LastModifiedById","destination":"LastModifiedById","userGenerated":"true"},{"source":"LastActivityDate","destination":"LastActivityDate","userGenerated":"true"}],"recordTypeMapping":[{"source":"Master","destination":"Master","userGenerated":"true"}],"showDetails":true,"source":"Account"},{"destination":"FinServ__FinancialAccountRole__c","fieldMapping":[{}],"recordTypeMapping":[{}],"source":""}],"sectionName":"Checking Account"},{"mappingData":[{"destination":"FinServ__FinancialAccount__c","fieldMapping":[{"source":"OwnerId","destination":"OwnerId","userGenerated":"true"},{"source":"Name","destination":"Name","userGenerated":"true"},{"source":"CreatedDate","destination":"CreatedDate","userGenerated":"true"},{"source":"CreatedById","destination":"CreatedById","userGenerated":"true"},{"source":"LastModifiedDate","destination":"LastModifiedDate","userGenerated":"true"},{"source":"LastModifiedById","destination":"LastModifiedById","userGenerated":"true"},{"source":"Name","destination":"FinServ__Status__c","userGenerated":"true"}],"recordTypeMapping":[{"source":"Master","destination":"Master","userGenerated":"true"}],"showDetails":true,"source":"Account"},{"destination":"FinServ__FinancialAccountRole__c","fieldMapping":[{}],"recordTypeMapping":[{}],"source":""}],"sectionName":"Loans"}],"additional":[{"userGenerated":"true","showDetails":true,"source":"Case","destination":"FinServ__LifeEvent__c","fieldMapping":[{"destination":"Name","source":"CaseNumber","truncate":"false","userGenerated":"true"}],"recordTypeMapping":[{"source":"Master","destination":"Master","userGenerated":"true"}]}]}';
    static final String XLSX_DATA_JSON = '{"Type":"XLSX","Content":{"Sheets":[{"Name":"FinServ__FinancialAccount__c","DataRows":[["Field","Assessment__c","FinServ__FinancialAccount__c","OwnerId","OwnerId"],["Field","Assessment__c","FinServ__FinancialAccount__c","Name","Name"],["Field","Assessment__c","FinServ__FinancialAccount__c","CreatedDate","CreatedDate"],["Field","Assessment__c","FinServ__FinancialAccount__c","CreatedById","CreatedById"],["Field","Assessment__c","FinServ__FinancialAccount__c","LastModifiedDate","LastModifiedDate"],["Field","Assessment__c","FinServ__FinancialAccount__c","LastModifiedById","LastModifiedById"],["Field","Assessment__c","FinServ__FinancialAccount__c","Status__c","FinServ__Status__c"],["Record Type","Assessment__c","FinServ__FinancialAccount__c","Master","Master"]],"Columns":[{"Width":11,"Name":"Type"},{"Width":13,"Name":"Org Object"},{"Width":28,"Name":"Future Object"},{"Width":16,"Name":"Source"},{"Width":18,"Name":"Destination"}]}]}}';
    static final String MALFORMED_JSON = '{   "objectMapping":[      }';
    static final List<String> REQUESTED_OBJECT_LIST = new List<String>{'FinServ__FinancialAccount__c', 'FinServ__FinancialAccountRole__c'};
    static final String FILE_NAME = 'mapping.json';

    @IsTest
    static void getObjectMappingForAssessment_PopulatedObjectMappingReturned(){
				Test.setMock(HttpCalloutMock.class, new MockResponse(ExternalUtilities.HTTP_RESPONSE_CODE_SUCCESS, MAPPING_JSON));

        Assessment__c setupAssessment = new Assessment__c(
            MappingDataJson__c = MAPPING_JSON
        );
        insert setupAssessment;

        Exception returnedException;
        MappingService.UpgradeMapping returnedMapping;
        Test.startTest();
            try {
                returnedMapping = MappingService.getObjectMappingForAssessment(setupAssessment.Id);
            }
            catch(AuraHandledException caughtException) {
                returnedException = caughtException;
            }
        Test.stopTest();

        System.assertEquals(null, returnedException, 'An AuraHandled exception should not be thrown');
        System.assertNotEquals(null, returnedMapping.recommended, 'A List of ObjectMapping should be returned');
    }


    @IsTest
    static void getObjectMappingForAssessment_StartingObjectMappingReturned(){
        Test.setMock(HttpCalloutMock.class, new MockResponse(ExternalUtilities.HTTP_RESPONSE_CODE_SUCCESS, FSC_DATA_JSON));

        Assessment__c setupAssessment = new Assessment__c();
        insert setupAssessment;

        Exception returnedException;
        MappingService.UpgradeMapping returnedMapping;
        Test.startTest();
            try {
                returnedMapping = MappingService.getObjectMappingForAssessment(setupAssessment.Id);
            }
            catch(AuraHandledException caughtException) {
                returnedException = caughtException;
            }
        Test.stopTest();

        System.assertEquals(null, returnedException, 'An AuraHandled exception should not be thrown');
        System.assertNotEquals(null, returnedMapping, 'A List of ObjectMapping should be returned');
    }

    @IsTest
    static void getObjectMappingForAssessment_AuraHandledExceptionThrown(){
				Test.setMock(HttpCalloutMock.class, new MockResponse(ExternalUtilities.HTTP_RESPONSE_CODE_FAILURE, MALFORMED_JSON));

        Assessment__c setupAssessment = new Assessment__c(
            MappingDataJson__c = MALFORMED_JSON
        );
        insert setupAssessment;

        Exception returnedException;
        MappingService.UpgradeMapping returnedMapping;
        Test.startTest();
            try {
                returnedMapping = MappingService.getObjectMappingForAssessment(setupAssessment.Id);
            }
            catch(AuraHandledException caughtException) {
                returnedException = caughtException;
            }
        Test.stopTest();

        System.assertNotEquals(null, returnedException, 'An AuraHandled exception should be thrown');
    }

    @IsTest
    static void getMappingForSection() {
        Exception returnedException;

        MockResponse mockResponses = new MockResponse(ExternalUtilities.HTTP_RESPONSE_CODE_SUCCESS, FSC_DATA_JSON);
        mockResponses.addResponse(ExternalUtilities.HTTP_RESPONSE_CODE_SUCCESS, FSC_DATA_JSON);

        Test.setMock(HttpCalloutMock.class, mockResponses);
        
        SFDC_Industry_Mapping_Section__mdt section = [Select Id From SFDC_Industry_Mapping_Section__mdt Limit 1];
        MappingService.MappingSection returnedSection;
        Test.startTest();
            try {
                //Show details
                returnedSection = MappingService.getMappingForSection(section.Id, false);
                System.assertNotEquals(null, returnedSection, 'Section data should be returned');

                //Hide details this time
                returnedSection = MappingService.getMappingForSection(section.Id, true);
                System.assertNotEquals(null, returnedSection, 'Section data should be returned');
            }
            catch(AuraHandledException caughtException) {
                returnedException = caughtException;
            }
        Test.stopTest();
    }

    @IsTest
    static void getRecommendedJSON(){
        Assessment__c setupAssessment = new Assessment__c(
            MappingDataJson__c = MAPPING_JSON
        );
        insert setupAssessment;

        Test.startTest();
            String JSON = MappingService.getRecommendedJSON(setupAssessment.Id);
        Test.stopTest();

        System.assertNotEquals(null, JSON, 'Recommended JSON should be returned');
    }

    @IsTest
    static void getOrgDefinition(){
        Test.startTest();
            List<String> definitionList = MappingService.getOrgDefinition();
        Test.stopTest();

        System.assertNotEquals(null, definitionList, 'Org Def should be returned');
    }

    @IsTest
    static void saveMapping(){
        Assessment__c setupAssessment = new Assessment__c(
            MappingDataJson__c = '{}'
        );
        insert setupAssessment;

        Test.startTest();
            Boolean isSuccess = MappingService.saveMapping(setupAssessment.Id, FILE_NAME, '.json', MAPPING_JSON, true);
        Test.stopTest();

        setupAssessment = [Select MappingDataJson__c From Assessment__c Where Id = :setupAssessment.Id];

        System.assertNotEquals(false, isSuccess, 'Assessment update failed');
        System.assertNotEquals('{}', setupAssessment.MappingDataJson__c, 'Recommended JSON should be returned');
    }

    /* @IsTest
    static void saveObjectMapping_MappingSavedSuccessfully(){

        Assessment__c setupAssessment = new Assessment__c();
        insert setupAssessment;

        MappingService.UpgradeMapping setupMapping = (MappingService.UpgradeMapping) System.JSON.deserialize(
            MAPPING_JSON,
            MappingService.UpgradeMapping.class
        );

        Exception returnedException;
        Test.startTest();
            try {
                MappingService.saveObjectMapping(setupAssessment.Id, setupMapping.objectMapping);
            }
            catch(AuraHandledException caughtException) {
                returnedException = caughtException;
            }
        Test.stopTest();

        System.assertEquals(null, returnedException, 'An AuraHandled exception should not be thrown');

        Assessment__c requeriedAssessment = [
            SELECT MappingDataJson__c
            FROM Assessment__c
            WHERE Id =: setupAssessment.Id
        ];
        System.assertNotEquals(
            null,
            requeriedAssessment.MappingDataJson__c,
            'Mapping JSON should be stored on the Assessment'
        );
    } */

    /* @IsTest
    static void saveObjectMapping_AuraHandledExceptionThrown(){

        MappingService.UpgradeMapping setupMapping = (MappingService.UpgradeMapping) System.JSON.deserialize(
            MAPPING_JSON,
            MappingService.UpgradeMapping.class
        );

        Exception returnedException;
        Test.startTest();
            try {
                MappingService.saveObjectMapping(null, setupMapping.objectMapping);
            }
            catch(AuraHandledException caughtException) {
                returnedException = caughtException;
            }
        Test.stopTest();

        System.assertNotEquals(null, returnedException, 'An AuraHandled exception should be thrown');
    } */

    @IsTest
    static void buildObjectMappingList_RequestedObjectMappingsReturned() {
        MockResponse mockResponses = new MockResponse(ExternalUtilities.HTTP_RESPONSE_CODE_SUCCESS, FSC_DATA_JSON);
        mockResponses.addResponse(ExternalUtilities.HTTP_RESPONSE_CODE_SUCCESS, FSC_DATA_JSON);

        Test.setMock(HttpCalloutMock.class, mockResponses);

        Test.startTest();
            List<MappingService.ObjectMapping> result = MappingService.getFSCSchema();
        Test.stopTest();

        System.assertNotEquals(null, result, 'A list of ObjectMappings should be returned');
        System.assertEquals(
            REQUESTED_OBJECT_LIST.size(),
            result.size(),
            'There should be an item in the list for each requested object'
        );
    }

    @IsTest
    static void parseMappedComponents_WithRecordId() {
        Assessment__c setupAssessment = new Assessment__c(
            MappingDataJson__c = MAPPING_JSON_COMPLETE
        );
        insert setupAssessment;

        Test.startTest();
            MappingService.MappedComponents result = MappingService.parseMappedComponents(setupAssessment.Id);
        Test.stopTest();

        System.assertNotEquals(null, result, 'The Components wrapper should not be empty');
    }

    @IsTest
    static void generateMappingFile_FileGenerated() {
        Assessment__c setupAssessment = new Assessment__c(
            MappingDataJson__c = MAPPING_JSON_COMPLETE
        );
        insert setupAssessment;

        MockResponse mockResponses = new MockResponse(
            ExternalUtilities.HTTP_RESPONSE_CODE_SUCCESS, 
            '', 
            EXTERNAL_STRINGS, 
            new Map<String, String>()
        );

        mockResponses.addResponse(
            ExternalUtilities.HTTP_RESPONSE_CODE_SUCCESS, 
            '', 
            XLSX_DATA_JSON, 
            new Map<String, String>()
        );
        
        // MockResponse mockResponses = new MockResponse(ExternalUtilities.HTTP_RESPONSE_CODE_SUCCESS, XLSX_DATA_JSON);

        Test.setMock(HttpCalloutMock.class, mockResponses);

        Test.startTest();
            String documentId = MappingService.getMappingFileLink(setupAssessment.Id);
            System.assertEquals(null, documentId, 'File should not exist yet.');

            String result = MappingService.generateMappingFile(setupAssessment.Id, true);

            documentId = MappingService.getMappingFileLink(setupAssessment.Id);
        Test.stopTest();

        System.assertNotEquals(null, result, 'The id of the xlsx file should be returned');
        //TODO: Update once Excel is fully complete
        //System.assertNotEquals(null, documentId, 'File should exist.');
    }
}