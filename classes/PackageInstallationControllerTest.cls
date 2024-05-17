@isTest
private class PackageInstallationControllerTest {
    static Integer RECORD_COUNT = Limits.getLimitQueries() + 1;
    static final String PACKAGE_NAME_1 = 'Package 1';    
    static final String PACKAGE_NAME_2 = 'Package 2';
    static final String PACKAGE_VERSION = '1.1';
    static final String PACKAGE_MAJOR_VERSION = '1';
    static final String PACKAGE_MINOR_VERSION = '1';
    static final String PACKAGE_ID = '04t30000001AGSuAAO';
    static final String PACKAGE_ID_UNINSTALLED= '04t30000001AGSuAA1';

    static final String DUMMY_JSON = '{}';
    static final String PACKAGE_JSON = '[{"VersionId":"04t1E000000jb9RQAQ","Version":"230.3","PackageVersionName":"r230.3","Name":"Financial Services Cloud","IsSelected":true}]';
    static final String INSTALL_ERROR_JSON = '{"status":"ERROR","error":"Installation errors: 1) Missing Organization Feature: ContactsToMultipleAccounts"}';
    static final String PACKAGE_LIST_RESPONSE = '{"sf_com_apps":{"type":"InstalledPackage","namespacePrefix":"sf_com_apps","lastModifiedDate":"2021-01-22T23:02:40.000Z","lastModifiedByName":"Automated Process","lastModifiedById":"0054x000002eKJSAA2","id":"04t30000001AGSuAAO","fullName":"sf_com_apps","fileName":"installedPackages/sf_com_apps.installedPackage","createdDate":"2021-01-22T23:02:40.000Z","createdByName":"Automated Process","createdById":"0054x000002eKJSAA2"}}';


    @IsTest
    static void installedPackageIds_SetBuiltCorrectly(){
        Test.setMock(HttpCalloutMock.class, new MockResponse(ExternalUtilities.HTTP_RESPONSE_CODE_SUCCESS, PACKAGE_LIST_RESPONSE));

        
        Test.startTest();
            Set<Id> result = PackageInstallationController.installedPackageIds;
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'A set should be returned');
        System.assertEquals(new Set<Id>{PACKAGE_ID}, result, 'The returned set should match its expected value');
    }
    
    @IsTest
    static void getPackageList_UnsortedListReturned(){
        ToolingService.fscPackageMap = new Map<String, ToolingService.InstalledSubscriberPackage>();

        ToolingService.SubscriberPackage setupSubscriberPackage1 = new ToolingService.SubscriberPackage();
        setupSubscriberPackage1.Name = PACKAGE_NAME_1;
        ToolingService.SubscriberPackageVersion setupPackageVersion1 = new ToolingService.SubscriberPackageVersion();
        setupPackageVersion1.Name = PACKAGE_NAME_1;
        setupPackageVersion1.Id = PACKAGE_ID;
        setupPackageVersion1.MajorVersion = PACKAGE_MAJOR_VERSION;
        setupPackageVersion1.MinorVersion = PACKAGE_MINOR_VERSION;
        ToolingService.InstalledSubscriberPackage setupPackage1 = new ToolingService.InstalledSubscriberPackage();
        setupPackage1.SubscriberPackage = setupSubscriberPackage1;
        setupPackage1.SubscriberPackageVersion = setupPackageVersion1;
        ToolingService.fscPackageMap.put(PACKAGE_NAME_1, setupPackage1);

        ToolingService.SubscriberPackage setupSubscriberPackage2 = new ToolingService.SubscriberPackage();
        setupSubscriberPackage2.Name = PACKAGE_NAME_2;
        ToolingService.SubscriberPackageVersion setupPackageVersion2 = new ToolingService.SubscriberPackageVersion();
        setupPackageVersion2.Name = PACKAGE_NAME_2;
        setupPackageVersion2.Id = PACKAGE_ID_UNINSTALLED;
        setupPackageVersion2.MajorVersion = PACKAGE_MAJOR_VERSION;
        setupPackageVersion2.MinorVersion = PACKAGE_MINOR_VERSION;
        ToolingService.InstalledSubscriberPackage setupPackage2 = new ToolingService.InstalledSubscriberPackage();
        setupPackage2.SubscriberPackage = setupSubscriberPackage2;
        setupPackage2.SubscriberPackageVersion = setupPackageVersion2;
        ToolingService.fscPackageMap.put(PACKAGE_NAME_2, setupPackage2);

        PackageInstallationController.installedPackageIds = new Set<Id>{PACKAGE_ID};

        Assessment__c setupAssessment = new Assessment__c();
        insert setupAssessment;

        Test.startTest();
            PackageInstallationController.InstalledPackageTableInfo result = PackageInstallationController.getPackageList(setupAssessment.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'A InstalledPackageTableInfo should be returned');
    }

    @IsTest
    static void getPackageList_ExcludedListReturned(){
        ToolingService.fscPackageMap = new Map<String, ToolingService.InstalledSubscriberPackage>();

        ToolingService.SubscriberPackage setupSubscriberPackage1 = new ToolingService.SubscriberPackage();
        setupSubscriberPackage1.Name = PACKAGE_NAME_1;
        ToolingService.SubscriberPackageVersion setupPackageVersion1 = new ToolingService.SubscriberPackageVersion();
        setupPackageVersion1.Name = PACKAGE_NAME_1;
        setupPackageVersion1.Id = PACKAGE_ID;
        setupPackageVersion1.MajorVersion = PACKAGE_MAJOR_VERSION;
        setupPackageVersion1.MinorVersion = PACKAGE_MINOR_VERSION;
        ToolingService.InstalledSubscriberPackage setupPackage1 = new ToolingService.InstalledSubscriberPackage();
        setupPackage1.SubscriberPackage = setupSubscriberPackage1;
        setupPackage1.SubscriberPackageVersion = setupPackageVersion1;
        ToolingService.fscPackageMap.put(PACKAGE_NAME_1, setupPackage1);

        ToolingService.SubscriberPackage setupSubscriberPackage2 = new ToolingService.SubscriberPackage();
        setupSubscriberPackage2.Name = PACKAGE_NAME_2;
        ToolingService.SubscriberPackageVersion setupPackageVersion2 = new ToolingService.SubscriberPackageVersion();
        setupPackageVersion2.Name = PACKAGE_NAME_2;
        setupPackageVersion2.Id = PACKAGE_ID;
        setupPackageVersion2.MajorVersion = PACKAGE_MAJOR_VERSION;
        setupPackageVersion2.MinorVersion = PACKAGE_MINOR_VERSION;
        ToolingService.InstalledSubscriberPackage setupPackage2 = new ToolingService.InstalledSubscriberPackage();
        setupPackage2.SubscriberPackage = setupSubscriberPackage2;
        setupPackage2.SubscriberPackageVersion = setupPackageVersion2;
        ToolingService.fscPackageMap.put(PACKAGE_NAME_2, setupPackage2);


        PackageInstallationController.installedPackageExcludes = new Set<String>{PACKAGE_NAME_1, PACKAGE_NAME_2};

        Assessment__c setupAssessment = new Assessment__c(
            PendingInstallPackagesJSON__c = PACKAGE_JSON
        );
        insert setupAssessment;

        Test.setMock(HttpCalloutMock.class, new MockResponse(ExternalUtilities.HTTP_RESPONSE_CODE_SUCCESS, PACKAGE_LIST_RESPONSE));

        Test.startTest();
            PackageInstallationController.InstalledPackageTableInfo result = PackageInstallationController.getPackageList(setupAssessment.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'A InstalledPackageTableInfo should be returned');
    }

    @IsTest
    static void getPackageList_SortedListReturned(){
        ToolingService.fscPackageMap = new Map<String, ToolingService.InstalledSubscriberPackage>();

        ToolingService.SubscriberPackage setupSubscriberPackage1 = new ToolingService.SubscriberPackage();
        setupSubscriberPackage1.Name = PACKAGE_NAME_1;
        ToolingService.SubscriberPackageVersion setupPackageVersion1 = new ToolingService.SubscriberPackageVersion();
        setupPackageVersion1.Name = PACKAGE_NAME_1;
        setupPackageVersion1.Id = PACKAGE_ID;
        setupPackageVersion1.MajorVersion = PACKAGE_MAJOR_VERSION;
        setupPackageVersion1.MinorVersion = PACKAGE_MINOR_VERSION;
        ToolingService.InstalledSubscriberPackage setupPackage1 = new ToolingService.InstalledSubscriberPackage();
        setupPackage1.SubscriberPackage = setupSubscriberPackage1;
        setupPackage1.SubscriberPackageVersion = setupPackageVersion1;
        ToolingService.fscPackageMap.put(PACKAGE_NAME_1, setupPackage1);

        ToolingService.SubscriberPackage setupSubscriberPackage2 = new ToolingService.SubscriberPackage();
        setupSubscriberPackage2.Name = PACKAGE_NAME_2;
        ToolingService.SubscriberPackageVersion setupPackageVersion2 = new ToolingService.SubscriberPackageVersion();
        setupPackageVersion2.Name = PACKAGE_NAME_2;
        setupPackageVersion2.Id = PACKAGE_ID_UNINSTALLED;
        setupPackageVersion2.MajorVersion = PACKAGE_MAJOR_VERSION;
        setupPackageVersion2.MinorVersion = PACKAGE_MINOR_VERSION;
        ToolingService.InstalledSubscriberPackage setupPackage2 = new ToolingService.InstalledSubscriberPackage();
        setupPackage2.SubscriberPackage = setupSubscriberPackage2;
        setupPackage2.SubscriberPackageVersion = setupPackageVersion2;
        ToolingService.fscPackageMap.put(PACKAGE_NAME_2, setupPackage2);

        PackageInstallationController.installedPackageTableInfo = new List<SFDC_Industry_Package_Table_Assignment__mdt>();
        PackageInstallationController.installedPackageTableInfo.add(new SFDC_Industry_Package_Table_Assignment__mdt(
            Package_Name__c = PACKAGE_NAME_2,
            Sort_Order__c = 1
        ));
        PackageInstallationController.installedPackageTableInfo.add(new SFDC_Industry_Package_Table_Assignment__mdt(
            Package_Name__c = PACKAGE_NAME_1,
            Sort_Order__c = 2
        ));

        Assessment__c setupAssessment = new Assessment__c();
        insert setupAssessment;

        PackageInstallationController.installedPackageIds = new Set<Id>{PACKAGE_ID};

        Test.setMock(HttpCalloutMock.class, new MockResponse(ExternalUtilities.HTTP_RESPONSE_CODE_SUCCESS, PACKAGE_LIST_RESPONSE));

        Test.startTest();
            PackageInstallationController.InstalledPackageTableInfo result = PackageInstallationController.getPackageList(setupAssessment.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'A InstalledPackageTableInfo should be returned');
    }

    @IsTest
    static void getPackageList_QueryExceptionThrown(){
        ToolingService.fscPackageMap = new Map<String, ToolingService.InstalledSubscriberPackage>();

        ToolingService.SubscriberPackage setupSubscriberPackage1 = new ToolingService.SubscriberPackage();
        setupSubscriberPackage1.Name = PACKAGE_NAME_1;
        ToolingService.SubscriberPackageVersion setupPackageVersion1 = new ToolingService.SubscriberPackageVersion();
        setupPackageVersion1.Name = PACKAGE_NAME_1;
        setupPackageVersion1.Id = PACKAGE_ID;
        setupPackageVersion1.MajorVersion = PACKAGE_MAJOR_VERSION;
        setupPackageVersion1.MinorVersion = PACKAGE_MINOR_VERSION;
        ToolingService.InstalledSubscriberPackage setupPackage1 = new ToolingService.InstalledSubscriberPackage();
        setupPackage1.SubscriberPackage = setupSubscriberPackage1;
        setupPackage1.SubscriberPackageVersion = setupPackageVersion1;
        ToolingService.fscPackageMap.put(PACKAGE_NAME_1, setupPackage1);

        ToolingService.SubscriberPackage setupSubscriberPackage2 = new ToolingService.SubscriberPackage();
        setupSubscriberPackage2.Name = PACKAGE_NAME_2;
        ToolingService.SubscriberPackageVersion setupPackageVersion2 = new ToolingService.SubscriberPackageVersion();
        setupPackageVersion2.Name = PACKAGE_NAME_2;
        setupPackageVersion2.Id = PACKAGE_ID_UNINSTALLED;
        setupPackageVersion2.MajorVersion = PACKAGE_MAJOR_VERSION;
        setupPackageVersion2.MinorVersion = PACKAGE_MINOR_VERSION;
        ToolingService.InstalledSubscriberPackage setupPackage2 = new ToolingService.InstalledSubscriberPackage();
        setupPackage2.SubscriberPackage = setupSubscriberPackage2;
        setupPackage2.SubscriberPackageVersion = setupPackageVersion2;
        ToolingService.fscPackageMap.put(PACKAGE_NAME_2, setupPackage2);

        PackageInstallationController.installedPackageTableInfo = new List<SFDC_Industry_Package_Table_Assignment__mdt>();
        PackageInstallationController.installedPackageTableInfo.add(new SFDC_Industry_Package_Table_Assignment__mdt(
            Package_Name__c = PACKAGE_NAME_2,
            Sort_Order__c = 1
        ));
        PackageInstallationController.installedPackageTableInfo.add(new SFDC_Industry_Package_Table_Assignment__mdt(
            Package_Name__c = PACKAGE_NAME_1,
            Sort_Order__c = 2
        ));

        PackageInstallationController.installedPackageIds = new Set<Id>{PACKAGE_ID};

        Test.startTest();
            PackageInstallationController.InstalledPackageTableInfo result = PackageInstallationController.getPackageList(PACKAGE_ID);
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'A InstalledPackageTableInfo should be returned');
        
    }

    @IsTest
    static void deploySelectedPackages_AssessmentUpdated(){
        AssessmentTriggerHandler.bypassTriggerForTestSetup = true;

        PackageInstallationController.PackageInfo setupPackage = new PackageInstallationController.PackageInfo();
        setupPackage.VersionId = PACKAGE_ID;
        setupPackage.Name = PACKAGE_NAME_1;
        setupPackage.Version = PACKAGE_VERSION;
        
        List<PackageInstallationController.PackageInfo> setupPackages = new List<PackageInstallationController.PackageInfo>{
            setupPackage
        };

        Test.setMock(HttpCalloutMock.class, new MockResponse(ExternalUtilities.HTTP_RESPONSE_CODE_PROCESSING, ''));

        Assessment__c setupAssessment = new Assessment__c(
            InstallDataJSON__c = DUMMY_JSON
        );
        insert setupAssessment;
        
        Test.startTest();
            PackageInstallationController.deploySelectedPackages(setupAssessment.Id, setupPackages);
        Test.stopTest();
        
        Assessment__c requeriedAssessment = [
            SELECT Id, InstallDataJSON__c
            FROM Assessment__c
            WHERE Id =: setupAssessment.Id
        ];

        System.assertEquals(
            null, 
            requeriedAssessment.InstallDataJSON__c, 
            'InstallDataJSON__c should be set to its expected value'
        );
    }

    @IsTest
    static void processPackageInstall_SubStatusCleared(){
        AssessmentTriggerHandler.bypassTriggerForTestSetup = true;
        List<Assessment__c> setupAssessments = new List<Assessment__c>();
        for(Integer i = 0; i < RECORD_COUNT; i++) {
            setupAssessments.add(new Assessment__c(
                Status__c = PackageInstallationController.STATUS_REVIEW,
                InstallDataJSON__c = DUMMY_JSON
            ));
        }
        insert setupAssessments;

        Map<Id, Assessment__c> oldMap = new Map<Id, Assessment__c>(setupAssessments.deepClone(true, false, false));
        for(Assessment__c oldAssessment : oldMap.values()) {
            oldAssessment.InstallDataJSON__c = null;
        }

        Test.startTest();
            PackageInstallationController.processPackageInstall(setupAssessments, oldMap);
        Test.stopTest();

        for(Assessment__c setupAssessment : setupAssessments) {
            System.assertEquals(null, setupAssessment.Sub_Status__c, 'Sub_Status__c should be null');
        }
    }

    @IsTest
    static void processPackageInstall_ErrorResponseReturned(){
        AssessmentTriggerHandler.bypassTriggerForTestSetup = true;
        List<Assessment__c> setupAssessments = new List<Assessment__c>();
        for(Integer i = 0; i < RECORD_COUNT; i++) {
            setupAssessments.add(new Assessment__c(
                Status__c = PackageInstallationController.STATUS_REVIEW,
                InstallDataJSON__c = INSTALL_ERROR_JSON
            ));
        }
        insert setupAssessments;

        Map<Id, Assessment__c> oldMap = new Map<Id, Assessment__c>(setupAssessments.deepClone(true, false, false));
        for(Assessment__c oldAssessment : oldMap.values()) {
            oldAssessment.InstallDataJSON__c = null;
        }

        Test.startTest();
            PackageInstallationController.processPackageInstall(setupAssessments, oldMap);
        Test.stopTest();

        for(Assessment__c setupAssessment : setupAssessments) {
            System.assertEquals(null, setupAssessment.Sub_Status__c, 'Sub_Status__c should be null');
        }
    }


    @IsTest
    static void processPackageInstall_TriggerUpdatesSubStatus(){
        AssessmentTriggerHandler.bypassTriggerForTestSetup = true;
        List<Assessment__c> setupAssessments = new List<Assessment__c>();
        for(Integer i = 0; i < RECORD_COUNT; i++) {
            setupAssessments.add(new Assessment__c(
                Status__c = PackageInstallationController.STATUS_REVIEW,
                InstallDataJSON__c = null
            ));
        }
        insert setupAssessments;
        AssessmentTriggerHandler.bypassTriggerForTestSetup = false;

        for(Assessment__c setupAssessment : setupAssessments) {
            setupAssessment.InstallDataJSON__c = DUMMY_JSON;
        }

        Test.startTest();
            update setupAssessments;
        Test.stopTest();

        List<Assessment__c> requeriedAssessments = [SELECT Sub_Status__c FROM Assessment__c];
        System.assertEquals(RECORD_COUNT, requeriedAssessments.size(), 'The correct number of assessments should be requeried');
        for(Assessment__c result : requeriedAssessments) {
            System.assertEquals(null, result.Sub_Status__c, 'Sub_Status__c should be null');
        }
    }
}