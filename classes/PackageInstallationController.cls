public with sharing class PackageInstallationController {
    @TestVisible
    static final String STATUS_REVIEW = 'Review';
    @TestVisible
    static final String INSTALL_STATUS_ERROR = 'ERROR';
    @TestVisible
    static final String METADATA_INSTALLED_PACKAGE = 'InstalledPackage';
    @TestVisible
    static final String KEY_ID = 'id';

    @TestVisible
    static Set<String> installedPackageExcludes {
        get {
            if(installedPackageExcludes == null) {
                installedPackageExcludes = Utilities.pluckStrings(Utilities.namespaceUnderscore + 'Package_Name__c', [
                    SELECT Package_Name__c
                    FROM SFDC_Industry_Package_Exclude__mdt
                ]);
            }
            return installedPackageExcludes;
        }
        set;
    }

    @TestVisible
    static List<SFDC_Industry_Package_Table_Assignment__mdt> installedPackageTableInfo {
        get {
            if(installedPackageTableInfo == null) {
                installedPackageTableInfo = [
                    SELECT Package_Name__c, Sort_Order__c, Selected__c, Description_Label__c
                    FROM SFDC_Industry_Package_Table_Assignment__mdt
                    ORDER BY Sort_Order__c ASC NULLS LAST
                ];
            }
            return installedPackageTableInfo;
        }
        set;
    }

    @TestVisible
    static Set<Id> installedPackageIds {
        get {
            if(installedPackageIds == null) {
                installedPackageIds = new Set<Id>();
                Map<String, Object> packageInfoMap = ExternalUtilities.executeMetadataList(METADATA_INSTALLED_PACKAGE).objectDescribeMap;
                for(String packageName : packageInfoMap.keyset()) {
                    installedPackageIds.add(((Id)((Map<String, Object>)packageInfoMap.get(packageName)).get(KEY_ID)));
                }
            }
            return installedPackageIds;
        }
        set;
    }

    @AuraEnabled
    public static InstalledPackageTableInfo getPackageList(Id assessmentId){
        if(assessmentId == null) return new InstalledPackageTableInfo();

        Assessment__c relatedAssessment;
        try {
            relatedAssessment = [
                SELECT PendingInstallPackagesJSON__c, ErrorInstallPackagesJSON__c, InstallDataJSON__c
                FROM Assessment__c
                WHERE Id =: assessmentId
            ];
        }
        catch(QueryException caughtException) {
            return new InstalledPackageTableInfo();
        }

        List<PackageInfo> installedPackages = new List<PackageInfo>();
        List<PackageInfo> uninstalledPackages = new List<PackageInfo>();
        List<PackageInfo> errorPackages = relatedAssessment.ErrorInstallPackagesJSON__c == null ? new List<PackageInfo>() : (List<PackageInfo>)JSON.deserialize(relatedAssessment.ErrorInstallPackagesJSON__c, List<PackageInfo>.class);
        List<PackageInfo> pendingPackages = relatedAssessment.PendingInstallPackagesJSON__c == null ? new List<PackageInfo>() : (List<PackageInfo>)JSON.deserialize(relatedAssessment.PendingInstallPackagesJSON__c, List<PackageInfo>.class);
        Set<Id> pendingPackageIds = new Set<Id>();
        for(PackageInfo pendingPackage : pendingPackages) {
            pendingPackageIds.add(pendingPackage.VersionId);
        }

        Set<String> sortedPackages = new Set<String>();
        for(SFDC_Industry_Package_Table_Assignment__mdt tableInfo : installedPackageTableInfo) {
            ToolingService.InstalledSubscriberPackage currentPackage = ToolingService.fscPackageMap.get(tableInfo.Package_Name__c);
            if(currentPackage == null || pendingPackageIds.contains(currentPackage.SubscriberPackageVersion.Id) == true) {
                continue;
            }
            
            sortedPackages.add(tableInfo.Package_Name__c);
            if(installedPackageIds.contains(currentPackage.SubscriberPackageVersion.Id) == false) {
                uninstalledPackages.add(new PackageInfo(currentPackage, tableInfo, tableInfo.Selected__c));
            }
            else {
                installedPackages.add(new PackageInfo(currentPackage, tableInfo, tableInfo.Selected__c));
            }
        }

        for(ToolingService.InstalledSubscriberPackage currentPackage : ToolingService.fscPackageMap.values()) {
            if(installedPackageExcludes.contains(currentPackage.SubscriberPackage.Name) == true || 
                sortedPackages.contains(currentPackage.SubscriberPackage.Name) == true ||
                pendingPackageIds.contains(currentPackage.SubscriberPackageVersion.Id) == true
            ) {
                continue;
            }

            if(installedPackageIds.contains(currentPackage.SubscriberPackageVersion.Id) == false) {
                uninstalledPackages.add(new PackageInfo(currentPackage));
            }
            else {
                installedPackages.add(new PackageInfo(currentPackage));
            }
        }

        return new InstalledPackageTableInfo(
            installedPackages, 
            pendingPackages,
            uninstalledPackages, 
            errorPackages,
            relatedAssessment.InstallDataJSON__c == null ? null : (InstallationResult)JSON.deserialize(relatedAssessment.InstallDataJSON__c, InstallationResult.class)
        );
    }

    @AuraEnabled
    public static void deploySelectedPackages(Id assessmentId, List<PackageInfo> selectedPackages){
        if(ExternalUtilities.initiatePackageInstall(assessmentId, selectedPackages) == true) {
            AssessmentService.updateAssessment(new Assessment__c(
                Id = assessmentId,
                Status__c = STATUS_REVIEW,
                InstallDataJSON__c = null,
                PendingInstallPackagesJSON__c = JSON.serialize(selectedPackages),
                ErrorInstallPackagesJSON__c = null
            ));
        }
    }

    public static void processPackageInstall(List<Assessment__c> newList, Map<Id, Assessment__c> oldMap){
        for(Assessment__c currentAssessment : newList) {
            if(currentAssessment.Status__c == STATUS_REVIEW && 
                currentAssessment.InstallDataJSON__c != null && 
                oldMap.get(currentAssessment.Id).InstallDataJSON__c == null
            ) {
                if(((InstallationResult)JSON.deserialize(currentAssessment.InstallDataJSON__c, InstallationResult.class)).status == INSTALL_STATUS_ERROR) {
                    currentAssessment.ErrorInstallPackagesJSON__c = currentAssessment.PendingInstallPackagesJSON__c;
                }
                currentAssessment.Sub_Status__c = null;
                currentAssessment.PendingInstallPackagesJSON__c = null;
            }
        }
    }

    public class InstalledPackageTableInfo {
        @AuraEnabled
        public List<PackageInfo> InstalledPackages {get;set;}
        @AuraEnabled
        public List<PackageInfo> PendingPackages {get;set;}
        @AuraEnabled
        public List<PackageInfo> UninstalledPackages {get;set;}
        @AuraEnabled
        public List<PackageInfo> ErrorPackages {get;set;}
        @AuraEnabled
        public InstallationResult InstallResult {get;set;}

        public InstalledPackageTableInfo() {}

        public InstalledPackageTableInfo(
            List<PackageInfo> installedPackages, 
            List<PackageInfo> pendingPackages, 
            List<PackageInfo> uninstalledPackages, 
            List<PackageInfo> errorPackages, 
            InstallationResult installResult
        ) {
            this.InstalledPackages = installedPackages;
            this.PendingPackages = pendingPackages;
            this.UninstalledPackages = uninstalledPackages;
            this.ErrorPackages = errorPackages;
            this.InstallResult =  installResult;
        }
    }


    public class PackageInfo {
        @AuraEnabled
        public Id VersionId {get;set;}
        @AuraEnabled
        public String Name {get;set;}
        @AuraEnabled
        public String Version {get;set;}
        @AuraEnabled
        public String PackageVersionName {get;set;}
        @AuraEnabled
        public String Description {get;set;}
        @AuraEnabled
        public Boolean IsSelected {get;set;}

        public PackageInfo() {}

        public PackageInfo(ToolingService.InstalledSubscriberPackage installedPackageInfo) {
            this.VersionId = installedPackageInfo.SubscriberPackageVersion.Id;
            this.Name = installedPackageInfo.SubscriberPackage.Name;
            this.Version = installedPackageInfo.SubscriberPackageVersion.MajorVersion + '.' + installedPackageInfo.SubscriberPackageVersion.MinorVersion;
            this.PackageVersionName = installedPackageInfo.SubscriberPackageVersion.Name;
            this.Description = '';
            this.IsSelected = false;
        }

        public PackageInfo(ToolingService.InstalledSubscriberPackage installedPackageInfo, SFDC_Industry_Package_Table_Assignment__mdt tableInfo, Boolean IsSelected) {
            this.VersionId = installedPackageInfo.SubscriberPackageVersion.Id;
            this.Name = installedPackageInfo.SubscriberPackage.Name;
            this.Version = installedPackageInfo.SubscriberPackageVersion.MajorVersion + '.' + installedPackageInfo.SubscriberPackageVersion.MinorVersion;
            this.PackageVersionName = installedPackageInfo.SubscriberPackageVersion.Name;
            this.Description = ToolingService.customLabelMap.get(Utilities.namespaceUnderscore + tableInfo.Description_Label__c) == null ? '' : ToolingService.customLabelMap.get(Utilities.namespaceUnderscore + tableInfo.Description_Label__c);
            this.IsSelected = IsSelected;
        }
    }

    public class InstallationResult {
        @AuraEnabled
        public String status {get; set;}
        @AuraEnabled
        public String error {get; set;}

        public InstallationResult() {}
    }

}