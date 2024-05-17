@IsTest
private class ToolingServiceTest {
    static final String CUSTOM_OBJECT_RESPONSE = '{"size":13,"totalSize":13,"records":[{"SFDC_Help":"01I4x000000XY8tEAG","SFDC_Limit":"01I4x000000X0B6EAK","SFDC_Industry_Assessment_Question_Branch":"01I4x000000Wx6aEAC","SFDC_Feature":"01I4x000000WahLEAS","SFDC_Recommendation":"01I4x000000WaR8EAK","SFDC_Schema_Org":"01I4x000000WZLFEA4","SFDC_Industry_Mapping_Section":"01I4x000000XAANEA4","ISV_Limitation_Warning":"01I4x000000VYEtEAO","SFDC_Industry_Mapping_Object":"01I4x000000WamCEAS","SFDC_Industry_Assessment_Question":"01I4x000000VYEjEAO","SFDC_Industry_Vertical":"01I4x000000VYEeEAO","SFDC_Industry":"01I4x000000VYEZEA4","Assessment":"01I4x000000VYCnEAO"}]}';
    static final String EXTERNAL_STRING_RESPONSE = '{"size":10,"totalSize":10,"done":true,"queryLocator":null,"entityTypeName":"ExternalString","records":[{"attributes":{"type":"ExternalString","url":"/services/data/v50.0/tooling/sobjects/ExternalString/1014x000007AblEAAS"},"Id":"1014x000007AblEAAS","Name":"AssessmentReportSectionTitleApproach","Value":"Transition Approach","Language":"en_US"},{"attributes":{"type":"ExternalString","url":"/services/data/v50.0/tooling/sobjects/ExternalString/1014x000007AblYAAS"},"Id":"1014x000007AblYAAS","Name":"AssessmentReportSectionTitleResults","Value":"Assessment Results","Language":"en_US"},{"attributes":{"type":"ExternalString","url":"/services/data/v50.0/tooling/sobjects/ExternalString/1014x000007AbldAAC"},"Id":"1014x000007AbldAAC","Name":"AssessmentReportSectionTitleAnalysis","Value":"Migration Analysis","Language":"en_US"},{"attributes":{"type":"ExternalString","url":"/services/data/v50.0/tooling/sobjects/ExternalString/1014x000007Abl4AAC"},"Id":"1014x000007Abl4AAC","Name":"AssessmentReportSectionTitleIntro","Value":"Intro","Language":"en_US"},{"attributes":{"type":"ExternalString","url":"/services/data/v50.0/tooling/sobjects/ExternalString/1014x000007AblTAAS"},"Id":"1014x000007AblTAAS","Name":"AssessmentReportSectionTitleRecommendation","Value":"Upgrade Recommendation","Language":"en_US"},{"attributes":{"type":"ExternalString","url":"/services/data/v50.0/tooling/sobjects/ExternalString/1014x00000FAMcRAAX"},"Id":"1014x00000FAMcRAAX","Name":"QuestionIndustry","Value":"What industry product would you like to transition to?","Language":"en_US"},{"attributes":{"type":"ExternalString","url":"/services/data/v50.0/tooling/sobjects/ExternalString/1014x00000FAMcWAAX"},"Id":"1014x00000FAMcWAAX","Name":"QuestionCustomerRepresentation","Value":"How is your customer represented?","Language":"en_US"},{"attributes":{"type":"ExternalString","url":"/services/data/v50.0/tooling/sobjects/ExternalString/1014x00000FAMcbAAH"},"Id":"1014x00000FAMcbAAH","Name":"QuestionRelationshipGroupings","Value":"Do you group together your customers through any shared relationships?","Language":"en_US"},{"attributes":{"type":"ExternalString","url":"/services/data/v50.0/tooling/sobjects/ExternalString/1014x00000FAMcgAAH"},"Id":"1014x00000FAMcgAAH","Name":"QuestionRollups","Value":"Do these groups aggregate or summarize counts/sums of customer related products,services, or activities?","Language":"en_US"},{"attributes":{"type":"ExternalString","url":"/services/data/v50.0/tooling/sobjects/ExternalString/1014x00000FAGK9AAP"},"Id":"1014x00000FAGK9AAP","Name":"AssessmentReportSectionSummaryAnalysis","Value":"Here\'s a high-level view of how FSC features and customizations can be approached for possible migration . Use this information to create the first draft of your gap analysis. To get a closer look, click the link for each feature or customization for recommendations for specific changes. But remember: You\'re the Salesforce expert at your company. Leverage the usage data in each section to decide whether our recommendations are worth your effort. For example, if the report identifies AppExchange packages require a thoughtful rollout but no one is using them, cross that feature off your gap analysis.","Language":"en_US"}]};';
    static final String EXTERNAL_STRING_MALFORMED_RESPONSE = '{   "size":1,   "totalSize":1,   "done":true,   "queryLocator":null,   "entityTypeName":"ExternalString",   "invalid" : "",   "records":[      {         "attributes":{            "type":"ExternalString",            "url":"/services/data/v50.0/tooling/sobjects/ExternalString/1014x000007AblEAAS",            "invalid" : ""         },         "Id":"1014x000007AblEAAS",         "Name":"AssessmentReportSectionTitleApproach",         "MasterLabel":"AssessmentReportSectionTitleApproach",         "Value":"Transition Approach",   "Language":"en_US",      "invalid" : ""      }   ]}';
    static final String EXTERNAL_STRING_LOCALIZATION_RESPONSE = '{   "size":8,   "totalSize":8,   "done":true,   "queryLocator":null,   "entityTypeName":"ExternalStringLocalization",   "records":[      {         "attributes":{            "type":"ExternalStringLocalization",            "url":"/services/data/v50.0/tooling/sobjects/ExternalStringLocalization/01j4x00004dEERLAA4"         },         "ExternalStringId":"1014x000007Abl4AAC",         "Value":"Intro",         "Language":"es"      },      {         "attributes":{            "type":"ExternalStringLocalization",            "url":"/services/data/v50.0/tooling/sobjects/ExternalStringLocalization/01j4x00004dEERGAA4"         },         "ExternalStringId":"1014x000007AblEAAS",         "Value":"Enfoque de transición",         "Language":"es"      },      {         "attributes":{            "type":"ExternalStringLocalization",            "url":"/services/data/v50.0/tooling/sobjects/ExternalStringLocalization/01j4x00004dEERQAA4"         },         "ExternalStringId":"1014x000007AblTAAS",         "Value":"Recomendación de actualización",         "Language":"es"      },      {         "attributes":{            "type":"ExternalStringLocalization",            "url":"/services/data/v50.0/tooling/sobjects/ExternalStringLocalization/01j4x00004dEERVAA4"         },         "ExternalStringId":"1014x000007AblYAAS",         "Value":"Resultados de la evaluación",         "Language":"es"      },      {         "attributes":{            "type":"ExternalStringLocalization",            "url":"/services/data/v50.0/tooling/sobjects/ExternalStringLocalization/01j4x00004dEERBAA4"         },         "ExternalStringId":"1014x000007AbldAAC",         "Value":"Análisis de migración",         "Language":"es"      },      {         "attributes":{            "type":"ExternalStringLocalization",            "url":"/services/data/v50.0/tooling/sobjects/ExternalStringLocalization/01j4x00004dFbVSAA0"         },         "ExternalStringId":"1014x00000FAGK9AAP",         "Value":"Aquí hay una vista de alto nivel de cómo se pueden abordar las características y personalizaciones FSC para una posible migración. Utilice esta información para crear el primer borrador de su análisis de brechas. Para ver más de cerca, haga clic en el enlace de cada función o personalización para obtener recomendaciones de cambios específicos. Pero recuerde: usted es el experto en Salesforce de su empresa. Aproveche los datos de uso en cada sección para decidir si nuestras recomendaciones merecen su esfuerzo. Por ejemplo, si el informe identifica que los paquetes de AppExchange requieren una implementación cuidadosa pero nadie los está usando, tache esa característica de su análisis de brechas.",         "Language":"es"      },      {         "attributes":{            "type":"ExternalStringLocalization",            "url":"/services/data/v50.0/tooling/sobjects/ExternalStringLocalization/01j4x00004dGdboAAC"         },         "ExternalStringId":"1014x00000FAMcRAAX",         "Value":"Spanish translation test",         "Language":"es"      },      {         "attributes":{            "type":"ExternalStringLocalization",            "url":"/services/data/v50.0/tooling/sobjects/ExternalStringLocalization/01j4x00004dGdbtAAC"         },         "ExternalStringId":"1014x00000FAMcRAAX",         "Value":"Mexican spanish test",         "Language":"es_MX"      }   ]}';
    static final String EXTERNAL_STRING_LOCALIZATION_MALFORMED_RESPONSE = '{   "size":8,   "totalSize":8,   "done":true,   "queryLocator":null,   "entityTypeName":"ExternalStringLocalization",   "Invalid": "",   "records":[      {         "attributes":{            "type":"ExternalStringLocalization",            "url":"/services/data/v50.0/tooling/sobjects/ExternalStringLocalization/01j4x00004dEERLAA4",            "Invalid": ""         },         "ExternalStringId":"1014x000007Abl4AAC",         "Value":"Intro",         "Language":"es",         "Invalid": ""      }   ]}';
    static final String INSTALLED_SUBSCRIBER_PACKAGE_RESPONSE = '{"size":1,"totalSize":1,"done":true,"queryLocator":null,"entityTypeName":"InstalledSubscriberPackage","records":[{"SubscriberPackage":{"attributes":{"type":"SubscriberPackage","url":"/services/data/v50.0/tooling/sobjects/SubscriberPackage/03330000000wDAbAAM"},"NamespacePrefix":"sf_com_apps","Name":"Salesforce Connected Apps"},"SubscriberPackageVersion":{"attributes":{"type":"SubscriberPackageVersion","url":"/services/data/v50.0/tooling/sobjects/SubscriberPackageVersion/04t30000001DUvrAAG"},"Name":"Winter \'16","MajorVersion":1,"MinorVersion":7,"PatchVersion":0,"BuildNumber":1}}]}';
    static final String FSC_PACKAGE_RESPONSE = '{"size":2,"totalSize":2,"done":true,"queryLocator":null,"entityTypeName":"InstalledSubscriberPackage","records":[{"SubscriberPackage":{"attributes":{"type":"SubscriberPackage","url":"/services/data/v51.0/tooling/sobjects/SubscriberPackage/03380000000FSQMAA4"},"NamespacePrefix":null,"Name":"Financial Services Ext"},"SubscriberPackageVersion":{"attributes":{"type":"SubscriberPackageVersion","url":"/services/data/v51.0/tooling/sobjects/SubscriberPackageVersion/04t1E000001Iql5QAC"},"Id":"04t1E000001Iql5QAC","Name":"FSC ext","MajorVersion":218,"MinorVersion":1,"PatchVersion":0,"BuildNumber":1}},{"SubscriberPackage":{"attributes":{"type":"SubscriberPackage","url":"/services/data/v51.0/tooling/sobjects/SubscriberPackage/03380000000U1CPAA0"},"NamespacePrefix":"FinServ","Name":"Financial Services Cloud"},"SubscriberPackageVersion":{"attributes":{"type":"SubscriberPackageVersion","url":"/services/data/v51.0/tooling/sobjects/SubscriberPackageVersion/04t1E000000jb9RQAQ"},"Id":"04t1E000000jb9RQAQ","Name":"r230.3","MajorVersion":230,"MinorVersion":3,"PatchVersion":0,"BuildNumber":1}}]}';
    static final String ALTERNATE_LANGUAGE = 'es';

    @IsTest
    static void customLabelMap_MapPopulatedOnSuccess(){
        Test.setMock(
            HttpCalloutMock.class, 
            new MockResponse(
                ExternalUtilities.HTTP_RESPONSE_CODE_SUCCESS, 
                '', 
                EXTERNAL_STRING_RESPONSE, 
                new Map<String, String>()
        ));

        Test.startTest();
            Map<String, String> customLabelMap = ToolingService.customLabelMap;
        Test.stopTest();
        
        System.assertNotEquals(null, customLabelMap, 'customLabelMap should be returned');
        System.assertNotEquals(new Set<String>(), customLabelMap.keySet(), 'customLabelMap should have keys');
    }

    @IsTest
    static void customLabelMap_TranslationsReturned(){
        ToolingService.userLanguage = ALTERNATE_LANGUAGE;

        MockResponse setupResponses = new MockResponse(
            ExternalUtilities.HTTP_RESPONSE_CODE_SUCCESS, 
            '', 
            EXTERNAL_STRING_RESPONSE, 
            new Map<String, String>()
        );
        setupResponses.addResponse(
            ExternalUtilities.HTTP_RESPONSE_CODE_SUCCESS, 
            '', 
            EXTERNAL_STRING_LOCALIZATION_RESPONSE, 
            new Map<String, String>()
        );

        Test.setMock( HttpCalloutMock.class, setupResponses);

        Test.startTest();
            Map<String, String> customLabelMap = ToolingService.customLabelMap;
        Test.stopTest();
        
        System.assertNotEquals(null, customLabelMap, 'customLabelMap should be returned');
        System.assertNotEquals(new Set<String>(), customLabelMap.keySet(), 'customLabelMap should have keys');
    }

    @IsTest
    static void customLabelMap_MapPopulatedOnSuccessFromMalformedResponse(){
        Test.setMock(
            HttpCalloutMock.class, 
            new MockResponse(
                ExternalUtilities.HTTP_RESPONSE_CODE_SUCCESS, 
                '', 
                EXTERNAL_STRING_MALFORMED_RESPONSE, 
                new Map<String, String>()
        ));

        Test.startTest();
            Map<String, String> customLabelMap = ToolingService.customLabelMap;
        Test.stopTest();
        
        System.assertNotEquals(null, customLabelMap, 'customLabelMap should be returned');
        System.assertNotEquals(new Set<String>(), customLabelMap.keySet(), 'customLabelMap should have keys');
    }

    @IsTest
    static void customLabelMap_MapEmptyOnError(){
        Test.setMock(
            HttpCalloutMock.class, 
            new MockResponse(
                ExternalUtilities.HTTP_RESPONSE_CODE_FAILURE, 
                '', 
                '', 
                new Map<String, String>()
        ));

        Test.startTest();
            Map<String, String> customLabelMap = ToolingService.customLabelMap;
        Test.stopTest();
        
        System.assertNotEquals(null, customLabelMap, 'customLabelMap should be returned');
        System.assertEquals(new Set<String>(), customLabelMap.keySet(), 'customLabelMap should not have keys');
    }

    @IsTest
    static void customLabelTranslationMap_MapPopulatedOnSuccess(){
        Test.setMock(
            HttpCalloutMock.class, 
            new MockResponse(
                ExternalUtilities.HTTP_RESPONSE_CODE_SUCCESS, 
                '', 
                EXTERNAL_STRING_LOCALIZATION_RESPONSE, 
                new Map<String, String>()
        ));

        Test.startTest();
            Map<String, List<ToolingService.ExternalStringLocalization>> customLabelTranslationMap = ToolingService.customLabelTranslationMap;
        Test.stopTest();
        
        System.assertNotEquals(null, customLabelTranslationMap, 'customLabelTranslationMap should be returned');
        System.assertNotEquals(new Set<String>(), customLabelTranslationMap.keySet(), 'customLabelTranslationMap should have keys');
    }

    @IsTest
    static void customLabelTranslationMap_MapPopulatedOnSuccessFromMalformedResponse(){
        Test.setMock(
            HttpCalloutMock.class, 
            new MockResponse(
                ExternalUtilities.HTTP_RESPONSE_CODE_SUCCESS, 
                '', 
                EXTERNAL_STRING_LOCALIZATION_MALFORMED_RESPONSE, 
                new Map<String, String>()
        ));

        Test.startTest();
            Map<String, List<ToolingService.ExternalStringLocalization>> customLabelTranslationMap = ToolingService.customLabelTranslationMap;
        Test.stopTest();
        
        System.assertNotEquals(null, customLabelTranslationMap, 'customLabelTranslationMap should be returned');
        System.assertNotEquals(new Set<String>(), customLabelTranslationMap.keySet(), 'customLabelTranslationMap should have keys');
    }

    @IsTest
    static void customLabelTranslationMap_MapEmptyOnError(){
        Test.setMock(
            HttpCalloutMock.class, 
            new MockResponse(
                ExternalUtilities.HTTP_RESPONSE_CODE_FAILURE, 
                '', 
                '', 
                new Map<String, String>()
        ));

        Test.startTest();
        Map<String, List<ToolingService.ExternalStringLocalization>> customLabelTranslationMap = ToolingService.customLabelTranslationMap;
        Test.stopTest();
        
        System.assertNotEquals(null, customLabelTranslationMap, 'customLabelTranslationMap should be returned');
        System.assertEquals(new Set<String>(), customLabelTranslationMap.keySet(), 'customLabelTranslationMap should not have keys');
    }

    @IsTest
    static void customObjectNameIdMap_MapPopulatedOnSuccess(){
        Test.setMock(
            HttpCalloutMock.class, 
            new MockResponse(
                ExternalUtilities.HTTP_RESPONSE_CODE_SUCCESS, 
                '', 
                CUSTOM_OBJECT_RESPONSE, 
                new Map<String, String>()
        ));

        Test.startTest();
            Map<String, String> customObjectNameIdMap = ToolingService.customObjectNameIdMap;
        Test.stopTest();
        
        System.assertNotEquals(null, customObjectNameIdMap, 'customObjectNameIdMap should be returned');
        System.assertNotEquals(new Set<String>(), customObjectNameIdMap.keySet(), 'customObjectNameIdMap should have keys');
    }

    @IsTest
    static void fscPackageMap_MapPopulatedOnSuccess(){
        Test.setMock(
            HttpCalloutMock.class, 
            new MockResponse(
                ExternalUtilities.HTTP_RESPONSE_CODE_SUCCESS, 
                '', 
                FSC_PACKAGE_RESPONSE, 
                new Map<String, String>()
        ));

        Test.startTest();
            Map<String, ToolingService.InstalledSubscriberPackage> fscPackageMap = ToolingService.fscPackageMap;
        Test.stopTest();
        
        System.assertNotEquals(null, fscPackageMap, 'fscPackageMap should be returned');
        System.assertNotEquals(new Set<String>(), fscPackageMap.keySet(), 'fscPackageMap should have keys');
    }

    @IsTest
    static void installedPackageMap_MapPopulatedOnSuccess(){
        Test.setMock(
            HttpCalloutMock.class, 
            new MockResponse(
                ExternalUtilities.HTTP_RESPONSE_CODE_SUCCESS, 
                '', 
                INSTALLED_SUBSCRIBER_PACKAGE_RESPONSE, 
                new Map<String, String>()
        ));

        Test.startTest();
            Map<String, ToolingService.InstalledSubscriberPackage> installedPackageMap = ToolingService.installedPackageMap;
        Test.stopTest();
        
        System.assertNotEquals(null, installedPackageMap, 'installedPackageMap should be returned');
        System.assertNotEquals(new Set<String>(), installedPackageMap.keySet(), 'installedPackageMap should have keys');
    }

    @IsTest
    static void installedPackageMap_MapEmptyOnError(){
        Test.setMock(
            HttpCalloutMock.class, 
            new MockResponse(
                ExternalUtilities.HTTP_RESPONSE_CODE_FAILURE, 
                '', 
                '', 
                new Map<String, String>()
        ));

        Test.startTest();
            Map<String, ToolingService.InstalledSubscriberPackage> installedPackageMap = ToolingService.installedPackageMap;
        Test.stopTest();
        
        System.assertNotEquals(null, installedPackageMap, 'installedPackageMap should be returned');
        System.assertEquals(new Set<String>(), installedPackageMap.keySet(), 'installedPackageMap should not have keys');
    }
}