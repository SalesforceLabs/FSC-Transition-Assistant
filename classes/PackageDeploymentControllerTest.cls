@isTest
private class PackageDeploymentControllerTest {
    static Integer RECORD_COUNT = 3;
    static final String JSON_SUCCESS = '{"status":"SUCCESS"}';
    static final String JSON_ERROR = '{"status":"ERROR","error":"Installation errors: 1) Missing Organization Feature: ContactsToMultipleAccounts"}';
    static final String DOCUMENT_TITLE = 'Deployment';
    static final String DOCUMENT_PATH = 'Deployment.zip';
    static final Blob DOCUMENT_DATA = Blob.valueOf('Deployment');


    @IsTest
    static void getDeploymentInfo_DeployablePackagesPresent(){
        List<ContentVersion> setupContentVersions = new List<ContentVersion>();
        List<Assessment__c> setupAssessments = new List<Assessment__c>();

        for(Integer i = 0; i < RECORD_COUNT; i++) {
            setupContentVersions.add( new ContentVersion(
                Title = DOCUMENT_TITLE,
                PathOnClient = DOCUMENT_PATH,
                VersionData = DOCUMENT_DATA
            ));
            setupAssessments.add(new Assessment__c(
                Status__c = PackageDeploymentController.STATUS_REVIEW
            ));
        }
        insert setupContentVersions;
        insert setupAssessments;

        List<ContentDocument> setupDocuments = [
            SELECT Id
            FROM ContentDocument
        ];

        List<ContentDocumentLink> setupDocumentLinks = new List<ContentDocumentLink>();
        for(Integer i = 0; i < RECORD_COUNT; i++) {
            setupDocumentLinks.add(new ContentDocumentLink(
                LinkedEntityId = setupAssessments[i].Id,
                ContentDocumentId = setupDocuments[i].Id
            ));
        }
        insert setupDocumentLinks;

        Test.startTest();
            PackageDeploymentController.DeployedPackageTableInfo result = PackageDeploymentController.getDeploymentInfo();
        Test.stopTest();

        System.assertNotEquals(null, result.AssessmentIds, 'AssessmentIds should be populated');
        System.assertEquals(Utilities.pluckIds(setupAssessments), result.AssessmentIds, 'AssessmentIds should have an entry for each assessment');
        System.assertNotEquals(null, result.DeployablePackages, 'DeployablePackages should be populated');
        System.assertEquals(RECORD_COUNT, result.DeployablePackages.size(), 'DeployedPackages should have an entry for each assessment');
    }


    @IsTest
    static void getDeploymentInfo_DeployedPackagesPresent(){
        List<ContentVersion> setupContentVersions = new List<ContentVersion>();
        List<Assessment__c> setupAssessments = new List<Assessment__c>();

        for(Integer i = 0; i < RECORD_COUNT; i++) {
            setupContentVersions.add( new ContentVersion(
                Title = DOCUMENT_TITLE,
                PathOnClient = DOCUMENT_PATH,
                VersionData = DOCUMENT_DATA
            ));
            setupAssessments.add(new Assessment__c(
                Status__c = PackageDeploymentController.STATUS_REVIEW
            ));
        }
        insert setupContentVersions;
        insert setupAssessments;

        List<ContentDocument> setupDocuments = [
            SELECT Id
            FROM ContentDocument
        ];

        List<ContentDocumentLink> setupDocumentLinks = new List<ContentDocumentLink>();
        for(Integer i = 0; i < RECORD_COUNT; i++) {
            setupDocumentLinks.add(new ContentDocumentLink(
                LinkedEntityId = setupAssessments[i].Id,
                ContentDocumentId = setupDocuments[i].Id
            ));
        }
        insert setupDocumentLinks;

        for(Integer i = 0; i < RECORD_COUNT; i++) {
            setupAssessments[i].DeployedPackageJSON__c = JSON.serialize(new PackageDeploymentController.DeploymentInfo(
                setupDocumentLinks[i],
                setupAssessments[i]
            ));
        }        
        update setupAssessments;

        Test.startTest();
            PackageDeploymentController.DeployedPackageTableInfo result = PackageDeploymentController.getDeploymentInfo();
        Test.stopTest();

        System.assertNotEquals(null, result.AssessmentIds, 'AssessmentIds should be populated');
        System.assertEquals(Utilities.pluckIds(setupAssessments), result.AssessmentIds, 'AssessmentIds should have an entry for each assessment');
        System.assertNotEquals(null, result.DeployedPackages, 'DeployedPackages should be populated');
        System.assertEquals(RECORD_COUNT, result.DeployedPackages.size(), 'DeployedPackages should have an entry for each assessment');
        System.assertNotEquals(null, result.DeployablePackages, 'DeployablePackages should be populated');
        System.assertEquals(0, result.DeployablePackages.size(), 'DeployedPackages should be empty');
    }

    @IsTest
    static void getDeploymentInfo_ErrorPackagesPresent(){
        List<ContentVersion> setupContentVersions = new List<ContentVersion>();
        List<Assessment__c> setupAssessments = new List<Assessment__c>();

        for(Integer i = 0; i < RECORD_COUNT; i++) {
            setupContentVersions.add( new ContentVersion(
                Title = DOCUMENT_TITLE,
                PathOnClient = DOCUMENT_PATH,
                VersionData = DOCUMENT_DATA
            ));
            setupAssessments.add(new Assessment__c(
                Status__c = PackageDeploymentController.STATUS_REVIEW,
                DeploymentDataJSON__c = JSON_ERROR
            ));
        }
        insert setupContentVersions;
        insert setupAssessments;

        List<ContentDocument> setupDocuments = [
            SELECT Id
            FROM ContentDocument
        ];

        List<ContentDocumentLink> setupDocumentLinks = new List<ContentDocumentLink>();
        for(Integer i = 0; i < RECORD_COUNT; i++) {
            setupDocumentLinks.add(new ContentDocumentLink(
                LinkedEntityId = setupAssessments[i].Id,
                ContentDocumentId = setupDocuments[i].Id
            ));
        }
        insert setupDocumentLinks;

        for(Integer i = 0; i < RECORD_COUNT; i++) {
            setupAssessments[i].ErrorDeployPackagesJSON__c = JSON.serialize(new PackageDeploymentController.DeploymentInfo(
                setupDocumentLinks[i],
                setupAssessments[i]
            ));
        }        
        update setupAssessments;

        Test.startTest();
            PackageDeploymentController.DeployedPackageTableInfo result = PackageDeploymentController.getDeploymentInfo();
        Test.stopTest();

        System.assertNotEquals(null, result.AssessmentIds, 'AssessmentIds should be populated');
        System.assertEquals(Utilities.pluckIds(setupAssessments), result.AssessmentIds, 'AssessmentIds should have an entry for each assessment');
        System.assertNotEquals(null, result.ErrorPackages, 'ErrorPackages should be populated');
        System.assertEquals(RECORD_COUNT, result.ErrorPackages.size(), 'ErrorPackages should have an entry for each assessment');
        System.assertNotEquals(null, result.DeployablePackages, 'DeployablePackages should be populated');
        System.assertEquals(RECORD_COUNT, result.DeployablePackages.size(), 'DeployedPackages should have an entry for each assessment');
    }

    @IsTest
    static void getDeploymentInfo_PendingPackagesPresent(){
        List<ContentVersion> setupContentVersions = new List<ContentVersion>();
        List<Assessment__c> setupAssessments = new List<Assessment__c>();

        for(Integer i = 0; i < RECORD_COUNT; i++) {
            setupContentVersions.add( new ContentVersion(
                Title = DOCUMENT_TITLE,
                PathOnClient = DOCUMENT_PATH,
                VersionData = DOCUMENT_DATA
            ));
            setupAssessments.add(new Assessment__c(
                Status__c = PackageDeploymentController.STATUS_REVIEW
            ));
        }
        insert setupContentVersions;
        insert setupAssessments;

        List<ContentDocument> setupDocuments = [
            SELECT Id
            FROM ContentDocument
        ];

        List<ContentDocumentLink> setupDocumentLinks = new List<ContentDocumentLink>();
        for(Integer i = 0; i < RECORD_COUNT; i++) {
            setupDocumentLinks.add(new ContentDocumentLink(
                LinkedEntityId = setupAssessments[i].Id,
                ContentDocumentId = setupDocuments[i].Id
            ));
        }
        insert setupDocumentLinks;

        for(Integer i = 0; i < RECORD_COUNT; i++) {
            setupAssessments[i].PendingDeployPackagesJSON__c = JSON.serialize(new PackageDeploymentController.DeploymentInfo(
                setupDocumentLinks[i],
                setupAssessments[i]
            ));
        }        
        update setupAssessments;

        Test.startTest();
            PackageDeploymentController.DeployedPackageTableInfo result = PackageDeploymentController.getDeploymentInfo();
        Test.stopTest();

        System.assertNotEquals(null, result.AssessmentIds, 'AssessmentIds should be populated');
        System.assertEquals(Utilities.pluckIds(setupAssessments), result.AssessmentIds, 'AssessmentIds should have an entry for each assessment');
        System.assertNotEquals(null, result.PendingPackages, 'PendingPackages should be populated');
        System.assertEquals(RECORD_COUNT, result.PendingPackages.size(), 'PendingPackages should have an entry for each assessment');
        System.assertNotEquals(null, result.DeployablePackages, 'DeployablePackages should be populated');
        System.assertEquals(0, result.DeployablePackages.size(), 'DeployedPackages should be empty');
    }


    @IsTest
    static void deployPackage_AssessmentUpdated(){
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

        Test.setMock(HttpCalloutMock.class, new MockResponse(ExternalUtilities.HTTP_RESPONSE_CODE_SUCCESS, JSON_SUCCESS));

        Test.startTest();
            PackageDeploymentController.deployPackage(setupDeployment);
        Test.stopTest();
        
        Assessment__c requeriedAssessment = [
            SELECT Status__c, DeploymentDataJSON__c, PendingDeployPackagesJSON__c, ErrorDeployPackagesJSON__c
            FROM Assessment__c
            WHERE Id =: setupAssessment.Id
        ];

        System.assertEquals(PackageDeploymentController.STATUS_REVIEW, requeriedAssessment.Status__c, 'Status__c should be set to Review');
        System.assertEquals(null, requeriedAssessment.DeploymentDataJSON__c, 'DeploymentDataJSON__c should be set to null');
        System.assertNotEquals(null, requeriedAssessment.PendingDeployPackagesJSON__c, 'PendingDeployPackagesJSON__c should be set');
        System.assertEquals(null, requeriedAssessment.ErrorDeployPackagesJSON__c, 'ErrorDeployPackagesJSON__c should be set to null');
    }

    @IsTest
    static void processPackageDeployment_ErrorPackagesPresent(){
        AssessmentTriggerHandler.bypassTriggerForTestSetup = true;

        List<ContentVersion> setupContentVersions = new List<ContentVersion>();
        List<Assessment__c> setupAssessments = new List<Assessment__c>();

        for(Integer i = 0; i < RECORD_COUNT; i++) {
            setupContentVersions.add( new ContentVersion(
                Title = DOCUMENT_TITLE,
                PathOnClient = DOCUMENT_PATH,
                VersionData = DOCUMENT_DATA
            ));
            setupAssessments.add(new Assessment__c(
                Status__c = PackageDeploymentController.STATUS_REVIEW,
                DeploymentDataJSON__c = JSON_ERROR
            ));
        }
        insert setupContentVersions;
        insert setupAssessments;

        List<ContentDocument> setupDocuments = [
            SELECT Id
            FROM ContentDocument
        ];

        List<ContentDocumentLink> setupDocumentLinks = new List<ContentDocumentLink>();
        for(Integer i = 0; i < RECORD_COUNT; i++) {
            setupDocumentLinks.add(new ContentDocumentLink(
                LinkedEntityId = setupAssessments[i].Id,
                ContentDocumentId = setupDocuments[i].Id
            ));
        }
        insert setupDocumentLinks;

        for(Integer i = 0; i < RECORD_COUNT; i++) {
            setupAssessments[i].PendingDeployPackagesJSON__c = JSON.serialize(new PackageDeploymentController.DeploymentInfo(
                setupDocumentLinks[i],
                setupAssessments[i]
            ));
        }        
        update setupAssessments;

        List<Assessment__c> oldList = setupAssessments.deepClone(true, false, false);
        for(Assessment__c old : oldList) {
            old.DeploymentDataJSON__c = null;
        }

        Test.startTest();
            PackageDeploymentController.processPackageDeployment(setupAssessments, new Map<Id, Assessment__c>(oldList));
        Test.stopTest();

        for(Assessment__c updatedAssessment : setupAssessments) {
            System.assertNotEquals(null, updatedAssessment.ErrorDeployPackagesJSON__c, 'ErrorDeployPackagesJSON__c should be set');
            System.assertEquals(null, updatedAssessment.DeployedPackageJSON__c, 'DeployedPackageJSON__c should be set to null');
            System.assertEquals(null, updatedAssessment.PendingDeployPackagesJSON__c, 'PendingDeployPackagesJSON__c should be set to null');
        }
    }

    @IsTest
    static void processPackageDeployment_SuccessPackagesPresent(){
        AssessmentTriggerHandler.bypassTriggerForTestSetup = true;

        List<ContentVersion> setupContentVersions = new List<ContentVersion>();
        List<Assessment__c> setupAssessments = new List<Assessment__c>();

        for(Integer i = 0; i < RECORD_COUNT; i++) {
            setupContentVersions.add( new ContentVersion(
                Title = DOCUMENT_TITLE,
                PathOnClient = DOCUMENT_PATH,
                VersionData = DOCUMENT_DATA
            ));
            setupAssessments.add(new Assessment__c(
                Status__c = PackageDeploymentController.STATUS_REVIEW,
                DeploymentDataJSON__c = JSON_SUCCESS
            ));
        }
        insert setupContentVersions;
        insert setupAssessments;

        List<ContentDocument> setupDocuments = [
            SELECT Id
            FROM ContentDocument
        ];

        List<ContentDocumentLink> setupDocumentLinks = new List<ContentDocumentLink>();
        for(Integer i = 0; i < RECORD_COUNT; i++) {
            setupDocumentLinks.add(new ContentDocumentLink(
                LinkedEntityId = setupAssessments[i].Id,
                ContentDocumentId = setupDocuments[i].Id
            ));
        }
        insert setupDocumentLinks;

        for(Integer i = 0; i < RECORD_COUNT; i++) {
            setupAssessments[i].PendingDeployPackagesJSON__c = JSON.serialize(new PackageDeploymentController.DeploymentInfo(
                setupDocumentLinks[i],
                setupAssessments[i]
            ));
        }        
        update setupAssessments;

        List<Assessment__c> oldList = setupAssessments.deepClone(true, false, false);
        for(Assessment__c old : oldList) {
            old.DeploymentDataJSON__c = null;
        }

        Test.startTest();
            PackageDeploymentController.processPackageDeployment(setupAssessments, new Map<Id, Assessment__c>(oldList));
        Test.stopTest();

        for(Assessment__c updatedAssessment : setupAssessments) {
            System.assertEquals(null, updatedAssessment.ErrorDeployPackagesJSON__c, 'ErrorDeployPackagesJSON__c should be set to null');
            System.assertNotEquals(null, updatedAssessment.DeployedPackageJSON__c, 'DeployedPackageJSON__c should be set');
            System.assertEquals(null, updatedAssessment.PendingDeployPackagesJSON__c, 'PendingDeployPackagesJSON__c should be set to null');
        }
    }


    @IsTest
    static void processPackageDeployment_TriggerFiredSuccessfully(){
        List<ContentVersion> setupContentVersions = new List<ContentVersion>();
        List<Assessment__c> setupAssessments = new List<Assessment__c>();

        for(Integer i = 0; i < RECORD_COUNT; i++) {
            setupContentVersions.add( new ContentVersion(
                Title = DOCUMENT_TITLE,
                PathOnClient = DOCUMENT_PATH,
                VersionData = DOCUMENT_DATA
            ));
            setupAssessments.add(new Assessment__c(
                Status__c = PackageDeploymentController.STATUS_REVIEW
            ));
        }
        insert setupContentVersions;
        insert setupAssessments;

        List<ContentDocument> setupDocuments = [
            SELECT Id
            FROM ContentDocument
        ];

        List<ContentDocumentLink> setupDocumentLinks = new List<ContentDocumentLink>();
        for(Integer i = 0; i < RECORD_COUNT; i++) {
            setupDocumentLinks.add(new ContentDocumentLink(
                LinkedEntityId = setupAssessments[i].Id,
                ContentDocumentId = setupDocuments[i].Id
            ));
        }
        insert setupDocumentLinks;

        for(Integer i = 0; i < RECORD_COUNT; i++) {
            setupAssessments[i].PendingDeployPackagesJSON__c = JSON.serialize(new PackageDeploymentController.DeploymentInfo(
                setupDocumentLinks[i],
                setupAssessments[i]
            ));
            setupAssessments[i].DeploymentDataJSON__c = JSON_SUCCESS;

        }        

        Test.startTest();
            update setupAssessments;
        Test.stopTest();

        List<Assessment__c> requeriedAssessments = [
            SELECT ErrorDeployPackagesJSON__c, DeployedPackageJSON__c, PendingDeployPackagesJSON__c
            FROM Assessment__c
            WHERE Id IN: Utilities.pluckIds(setupAssessments)
        ];

        System.assertEquals(
            Utilities.pluckIds(setupAssessments), 
            Utilities.pluckIds(requeriedAssessments), 
            'All created Assessments should be requeried'
        );

        for(Assessment__c updatedAssessment : requeriedAssessments) {
            System.assertEquals(null, updatedAssessment.ErrorDeployPackagesJSON__c, 'ErrorDeployPackagesJSON__c should be set to null');
            System.assertNotEquals(null, updatedAssessment.DeployedPackageJSON__c, 'DeployedPackageJSON__c should be set');
            System.assertEquals(null, updatedAssessment.PendingDeployPackagesJSON__c, 'PendingDeployPackagesJSON__c should be set to null');
        }
    }
}