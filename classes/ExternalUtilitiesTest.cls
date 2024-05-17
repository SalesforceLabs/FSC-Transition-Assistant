@isTest
private class ExternalUtilitiesTest {
    static final String RESPONSE_DATA_EXTERNAL_SCHEMA = '{"FinServ__FinancialAccount__c":{"name":"FinServ__FinancialAccount__c","label":"Financial Account","recordTypeInfos":[{"active":true,"available":true,"defaultRecordTypeMapping":true,"developerName":"BankingAccount","master":false,"name":"Bank Account","recordTypeId":"01256000001bZWrAAM","urls":{"layout":"/services/data/v50.0/sobjects/FinServ__FinancialAccount__c/describe/layouts/01256000001bZWrAAM"}}],"fields":[{"aggregatable":true,"aiPredictionField":false,"autoNumber":false,"byteLength":18,"calculated":false,"calculatedFormula":null,"cascadeDelete":false,"caseSensitive":false,"compoundFieldName":null,"controllerName":null,"createable":true,"custom":true,"defaultValue":null,"defaultValueFormula":null,"defaultedOnCreate":false,"dependentPicklist":false,"deprecatedAndHidden":false,"digits":0,"displayLocationInDecimal":false,"encrypted":false,"externalId":false,"extraTypeInfo":null,"filterable":true,"filteredLookupInfo":{"controllingFields":[],"dependent":false,"optionalFilter":false},"formulaTreatNullNumberAsZero":false,"groupable":true,"highScaleNumber":false,"htmlFormatted":false,"idLookup":false,"inlineHelpText":null,"label":"Primary Owner","length":18,"mask":null,"maskType":null,"name":"FinServ__PrimaryOwner__c","nameField":false,"namePointing":false,"nillable":false,"permissionable":false,"picklistValues":[],"polymorphicForeignKey":false,"precision":0,"queryByDistance":false,"referenceTargetField":null,"referenceTo":["Account"],"relationshipName":"FinServ__PrimaryOwner__r","relationshipOrder":null,"restrictedDelete":true,"restrictedPicklist":false,"scale":0,"searchPrefilterable":true,"soapType":"tns:ID","sortable":true,"type":"reference","unique":false,"updateable":true,"writeRequiresMasterRead":false}]},"FinServ__FinancialAccountRole__c":{"name":"FinServ__FinancialAccountRole__c","label":"Financial Account Role","recordTypeInfos":[],"fields":[]}}';
    static final String RESPONSE_DATA_TOOLING_QUERY = '{"size":25,"totalSize":25,"done":true,"queryLocator":null,"entityTypeName":"ApexClass","records":[{"Name":"ExternalUtilitiesTest"}]}';
    static final String RESPONSE_DATA_METADATA_LIST = '{"ComponentSampleName":{}}';
    static final String RESPONSE_DATA_METADATA_READ = '{"Account":{},"Contact":{}}';
    static final String PACKAGE_NAME = 'Package';    
    static final String PACKAGE_VERSION = '1.1';
    static final String PACKAGE_ID = '04t30000001AGSuAAO';
    static final String DOCUMENT_TITLE = 'Deployment';
    static final String DOCUMENT_PATH = 'Deployment.zip';
    static final Blob DOCUMENT_DATA = Blob.valueOf('Deployment');

    static testMethod void testExecuteToolingQuery() {
        Test.setMock(HttpCalloutMock.class, new MockResponse(ExternalUtilities.HTTP_RESPONSE_CODE_SUCCESS, RESPONSE_DATA_TOOLING_QUERY));
        Test.startTest();
            String toolingResponseData = ExternalUtilities.executeToolingQuery('SELECT Name FROM ApexClass');
        Test.stopTest();
        
        System.assertEquals(RESPONSE_DATA_TOOLING_QUERY, toolingResponseData, 'Tooling query must return expected response');
    }

    static testMethod void testExecuteFSCToolingQuery() {
        Test.setMock(HttpCalloutMock.class, new MockResponse(ExternalUtilities.HTTP_RESPONSE_CODE_SUCCESS, RESPONSE_DATA_TOOLING_QUERY));
        Test.startTest();
            String toolingResponseData = ExternalUtilities.executeFSCToolingQuery('SELECT Name FROM ApexClass');
        Test.stopTest();
        
        System.assertEquals(RESPONSE_DATA_TOOLING_QUERY, toolingResponseData, 'Tooling query must return expected response');
    }

    static testMethod void testExecuteMetadataList() {
        String typeToList = 'ConnectedApp';

        Test.setMock(HttpCalloutMock.class, new MockResponse(ExternalUtilities.HTTP_RESPONSE_CODE_SUCCESS, RESPONSE_DATA_METADATA_LIST));
        Test.startTest();
            ExternalUtilities.ExternalSchema metadataMap = ExternalUtilities.executeMetadataList(typeToList);
        Test.stopTest();
        
        System.assertNotEquals(null, metadataMap, 'Request must return populated component metadata info');
    }

    static testMethod void testExecuteMetadataRead() {
        List<String> objectsToDescribe = new List<String>{'Account', 'Contact'};

        Test.setMock(HttpCalloutMock.class, new MockResponse(ExternalUtilities.HTTP_RESPONSE_CODE_SUCCESS, RESPONSE_DATA_METADATA_READ));
        Test.startTest();
            ExternalUtilities.ExternalSchema metadataMap = ExternalUtilities.executeMetadataRead('CustomObject', objectsToDescribe);
        Test.stopTest();
        
        for (String objectName : objectsToDescribe) {
            System.assertNotEquals(null, metadataMap.get(objectName), 'Request must return populated object metadata info');
        }
    }

    static testMethod void testInitiateBulkDependencyScan() {
        Test.setMock(HttpCalloutMock.class, new MockResponse(ExternalUtilities.HTTP_RESPONSE_CODE_PROCESSING, 'ok'));
        Test.startTest();
            Boolean isSuccess = ExternalUtilities.initiateBulkDependencyScan(null, new MappingService.MappedComponents());
        Test.stopTest();
        
        System.assertEquals(true, isSuccess, 'Request must return true for success');
    }

    static testMethod void testRequestGenerateDeploymentPackage() {
        Assessment__c assessment = new Assessment__c();
        insert assessment;
        Id fileId = FileUtility.writeFileData(assessment.Id, 'test', 'json', '{}');
        Test.setMock(HttpCalloutMock.class, new MockResponse(ExternalUtilities.HTTP_RESPONSE_CODE_PROCESSING, 'ok'));
        Test.startTest();
            Boolean isSuccess = ExternalUtilities.requestGenerateDeploymentPackage(assessment.Id, fileId);
        Test.stopTest();
        
        System.assertEquals(true, isSuccess, 'Request must return true for success');
    }

    static testMethod void testRequestExternalSchema_FSC() {
        List<String> objectsToDescribe = new List<String>{'FinServ__FinancialAccount__c', 'FinServ__FinancialAccountRole__c'};
        
        Test.setMock(HttpCalloutMock.class, new MockResponse(ExternalUtilities.HTTP_RESPONSE_CODE_SUCCESS, RESPONSE_DATA_EXTERNAL_SCHEMA));
        Test.startTest();
            ExternalUtilities.ExternalSchema fscSchema = ExternalUtilities.requestFSCObjectSchema(objectsToDescribe);
        Test.stopTest();
        
        System.assertNotEquals(null, fscSchema, 'Request must return populated instance');
        for (String objectName : objectsToDescribe) {
            System.assertNotEquals(null, fscSchema.get(objectName+'.recordTypeInfos'), 'Request must return populated record type info');
            System.assertNotEquals(null, fscSchema.get(objectName+'.fields'), 'Request must return populated fields');

            List<Object> fieldMapList = (List<Object>)fscSchema.get(objectName+'.fields');
            for (Object fieldMapObj : fieldMapList) {
                Map<String,Object> fieldMap = (Map<String,Object>)fieldMapObj;
                System.assertNotEquals(null, fieldMap.get('name'), objectName+' schema must return populated name field');
                System.assertNotEquals(null, fieldMap.get('label'), objectName+' schema must return populated label field');
                System.assertNotEquals(null, fieldMap.get('type'), objectName+' schema must return populated type field');
                System.assertNotEquals(null, fieldMap.get('length'), objectName+' schema must return populated length field');
            }
        }
    }

    static testMethod void testGetOrgVersionName() {
        String releaseName = 'Spring \'21 Patch 9.2';
        Test.setMock(HttpCalloutMock.class, new MockResponse(ExternalUtilities.HTTP_RESPONSE_CODE_SUCCESS, '{"releaseVersion": "'+releaseName+'"}'));
        Test.startTest();
            String result = ExternalUtilities.getOrgVersionName();
        Test.stopTest();
        
        System.assertEquals(releaseName, result, 'Result must match expected value');
    }

    static testMethod void testGetOrgApiVersion() {
        String apiVersion = '51.0';
        Test.setMock(HttpCalloutMock.class, new MockResponse(ExternalUtilities.HTTP_RESPONSE_CODE_SUCCESS, '[{"version": "1.0"},{"version": "'+apiVersion+'"}]'));
        Test.startTest();
            String result = ExternalUtilities.getOrgApiVersion();
        Test.stopTest();
        
        System.assertEquals(apiVersion, result, 'Result must match expected value');
    }

    @IsTest
    static void initiatePackageInstall_ProcessingResponseReceived() {
        Assessment__c setupAssessment = new Assessment__c();
        insert setupAssessment;

        PackageInstallationController.PackageInfo setupPackage = new PackageInstallationController.PackageInfo();
        setupPackage.VersionId = PACKAGE_ID;
        setupPackage.Name = PACKAGE_NAME;
        setupPackage.Version = PACKAGE_VERSION;
        
        List<PackageInstallationController.PackageInfo> setupPackages = new List<PackageInstallationController.PackageInfo>{
            setupPackage
        };

        Test.setMock(HttpCalloutMock.class, new MockResponse(ExternalUtilities.HTTP_RESPONSE_CODE_PROCESSING, ''));

        Test.startTest();
            Boolean result = ExternalUtilities.initiatePackageInstall(setupAssessment.Id, setupPackages);
        Test.stopTest();
        
        System.assertEquals(true, result, 'Result should be true when a processing response code is returned');
    }

    @IsTest
    static void initiatePackageInstall_ErrorResponseReceived() {
        Assessment__c setupAssessment = new Assessment__c();
        insert setupAssessment;

        PackageInstallationController.PackageInfo setupPackage = new PackageInstallationController.PackageInfo();
        setupPackage.VersionId = PACKAGE_ID;
        setupPackage.Name = PACKAGE_NAME;
        setupPackage.Version = PACKAGE_VERSION;
        
        List<PackageInstallationController.PackageInfo> setupPackages = new List<PackageInstallationController.PackageInfo>{
            setupPackage
        };

        Test.setMock(HttpCalloutMock.class, new MockResponse(ExternalUtilities.HTTP_RESPONSE_CODE_FAILURE, ''));

        Test.startTest();
            Boolean result = ExternalUtilities.initiatePackageInstall(setupAssessment.Id, setupPackages);
        Test.stopTest();
        
        System.assertEquals(false, result, 'Result should be false when an error response code is returned');
    }

    @IsTest
    static void initiatePackageDeployment_SuccessResponseReceived(){
        ContentVersion setupContentVersion = new ContentVersion(
            Title = DOCUMENT_TITLE,
            PathOnClient = DOCUMENT_PATH,
            VersionData = DOCUMENT_DATA
        );
        insert setupContentVersion;

        Assessment__c setupAssessment = new Assessment__c();
        insert setupAssessment;
        
        ContentDocument setupDocument = [
            SELECT Id
            FROM ContentDocument
        ];

        ContentDocumentLink setupDocumentLink = new ContentDocumentLink(
            LinkedEntityId = setupAssessment.Id,
            ContentDocumentId = setupDocument.Id
        );

        insert setupDocumentLink;

        PackageDeploymentController.DeploymentInfo setupDeployment = new PackageDeploymentController.DeploymentInfo(
            setupDocumentLink,
            setupAssessment
        );

        Test.setMock(HttpCalloutMock.class, new MockResponse(ExternalUtilities.HTTP_RESPONSE_CODE_PROCESSING, ''));

        Test.startTest();
            Boolean result = ExternalUtilities.initiatePackageDeployment(setupDeployment);

        Test.stopTest();
        
        System.assertEquals(true, result, 'Result should be true when a processing response code is returned');
    }

    @IsTest
    static void initiatePackageDeployment_ErrorResponseReceived(){
        ContentVersion setupContentVersion = new ContentVersion(
            Title = DOCUMENT_TITLE,
            PathOnClient = DOCUMENT_PATH,
            VersionData = DOCUMENT_DATA
        );
        insert setupContentVersion;

        Assessment__c setupAssessment = new Assessment__c();
        insert setupAssessment;
        
        ContentDocument setupDocument = [
            SELECT Id
            FROM ContentDocument
        ];

        ContentDocumentLink setupDocumentLink = new ContentDocumentLink(
            LinkedEntityId = setupAssessment.Id,
            ContentDocumentId = setupDocument.Id
        );

        insert setupDocumentLink;

        PackageDeploymentController.DeploymentInfo setupDeployment = new PackageDeploymentController.DeploymentInfo(
            setupDocumentLink,
            setupAssessment
        );

        Test.setMock(HttpCalloutMock.class, new MockResponse(ExternalUtilities.HTTP_RESPONSE_CODE_FAILURE, ''));

        Test.startTest();
            Boolean result = ExternalUtilities.initiatePackageDeployment(setupDeployment);
        Test.stopTest();
        
        System.assertEquals(false, result, 'Result should be true when a processing response code is returned');
    }
}