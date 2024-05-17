public with sharing class PackageDeploymentController {
    @TestVisible 
    static final String FILETYPE_ZIP = 'ZIP';
    @TestVisible
    static final String STATUS_REVIEW = 'Review';
    @TestVisible
    static final String INSTALL_STATUS_ERROR = 'ERROR';
    @TestVisible
    static final String DOWNLOAD_URL_PREFIX = '/sfc/servlet.shepherd/document/download/';
    @TestVisible
    static final Datetime NOW = Datetime.now();
    
    @AuraEnabled
    public static DeployedPackageTableInfo getDeploymentInfo(){
        Map<Id, Assessment__c> orgAssessmentMap = new Map<Id, Assessment__c>([
            SELECT Id, Description__c, DeploymentDataJSON__c, ErrorDeployPackagesJSON__c, PendingDeployPackagesJSON__c, DeployedPackageJSON__c
            FROM Assessment__c
            WHERE Status__c =: STATUS_REVIEW
        ]);

        List<ContentDocumentLink> deploymentZips = [
            SELECT LinkedEntityId, LinkedEntity.Name, ContentDocumentId, ContentDocument.CreatedDate, 
                ContentDocument.Description, ContentDocument.Title
            FROM ContentDocumentLink 
            WHERE LinkedEntityId IN: orgAssessmentMap.keySet()
                AND ContentDocument.FileType =: FILETYPE_ZIP
            ORDER BY ContentDocument.CreatedDate DESC
        ];

        Set<Id> assessmentIds = new Set<Id>();
        List<DeploymentInfo> deployedPackages = new List<DeploymentInfo>();
        Set<Id> deployedPackageIds = new Set<Id>();
        List<DeploymentInfo> pendingPackages = new List<DeploymentInfo>();
        Set<Id> pendingPackageIds = new Set<Id>();
        List<DeploymentInfo> deployablePackages = new List<DeploymentInfo>();
        List<DeploymentInfo> errorPackages = new List<DeploymentInfo>();
        Set<Id> errorPackageIds = new Set<Id>();
        for(ContentDocumentLink deploymentZip : deploymentZips) {
            Assessment__c relatedAssessment = orgAssessmentMap.get(deploymentZip.LinkedEntityId);
            assessmentIds.add(relatedAssessment.Id);

            if(relatedAssessment.DeployedPackageJSON__c != null) {
                DeploymentInfo successfulDeployment = (DeploymentInfo)JSON.deserialize(relatedAssessment.DeployedPackageJSON__c, DeploymentInfo.class);
                if(deployedPackageIds.contains(successfulDeployment.DocumentId) == false) {
                    deployedPackages.add(successfulDeployment);
                    deployedPackageIds.add(successfulDeployment.DocumentId);
                }
            }

            if(relatedAssessment.PendingDeployPackagesJSON__c != null) {
                DeploymentInfo pendingDeployment = (DeploymentInfo)JSON.deserialize(relatedAssessment.PendingDeployPackagesJSON__c, DeploymentInfo.class);
                if(pendingPackageIds.contains(pendingDeployment.DocumentId) == false) {
                    pendingPackages.add(pendingDeployment);
                    pendingPackageIds.add(pendingDeployment.DocumentId);
                }
            }

            if(relatedAssessment.ErrorDeployPackagesJSON__c != null) {
                DeploymentInfo errorDeployment = (DeploymentInfo)JSON.deserialize(relatedAssessment.ErrorDeployPackagesJSON__c, DeploymentInfo.class);
                if(errorPackageIds.contains(errorDeployment.DocumentId) == false) {
                    if(relatedAssessment.DeploymentDataJSON__c != null) {
                        DeploymentResult relatedResult = (DeploymentResult)JSON.deserialize(relatedAssessment.DeploymentDataJSON__c, DeploymentResult.class);
                        if(relatedResult.status == INSTALL_STATUS_ERROR) {
                            errorDeployment.ErrorMessage = relatedResult.error;
                        }
                    }
                    errorPackages.add(errorDeployment);
                    errorPackageIds.add(errorDeployment.DocumentId);
                }
            }
        }

        for(ContentDocumentLink deploymentZip : deploymentZips) {
            if(pendingPackageIds.contains(deploymentZip.ContentDocumentId) == false && deployedPackageIds.contains(deploymentZip.ContentDocumentId) == false) {
                deployablePackages.add(new DeploymentInfo(deploymentZip, orgAssessmentMap.get(deploymentZip.LinkedEntityId)));
            }
        }

        return new DeployedPackageTableInfo(
            assessmentIds,
            deployedPackages,
            pendingPackages,
            deployablePackages,
            errorPackages
        ); 
    }

    @AuraEnabled
    public static void deployPackage(DeploymentInfo deployment){
        if(ExternalUtilities.initiatePackageDeployment(deployment) == true) {
            deployment.DeploymentStarttime = NOW;
            AssessmentService.updateAssessment(new Assessment__c(
                Id = deployment.AssessmentId,
                Status__c = STATUS_REVIEW,
                DeploymentDataJSON__c = null,
                PendingDeployPackagesJSON__c = JSON.serialize(deployment),
                ErrorDeployPackagesJSON__c = null
            ));
        }
    }

    public static void processPackageDeployment(List<Assessment__c> newList, Map<Id, Assessment__c> oldMap){
        for(Assessment__c currentAssessment : newList) {
            if(currentAssessment.Status__c == STATUS_REVIEW && 
                currentAssessment.DeploymentDataJSON__c != null && 
                oldMap.get(currentAssessment.Id).DeploymentDataJSON__c == null &&
                currentAssessment.PendingDeployPackagesJSON__c != null
            ) {
                DeploymentInfo pendingDeployment = (DeploymentInfo)JSON.deserialize(currentAssessment.PendingDeployPackagesJSON__c, DeploymentInfo.class);
                pendingDeployment.DeploymentEndtime = NOW;
                String updatedPendingJSON = JSON.serialize(pendingDeployment);
                if(((DeploymentResult)JSON.deserialize(currentAssessment.DeploymentDataJSON__c, DeploymentResult.class)).status == INSTALL_STATUS_ERROR) {
                    currentAssessment.ErrorDeployPackagesJSON__c = updatedPendingJSON;
                }
                else {
                    currentAssessment.DeployedPackageJSON__c = updatedPendingJSON;
                }
                currentAssessment.PendingDeployPackagesJSON__c = null;
            }
        }
    }

    public class DeploymentInfo {
        @AuraEnabled
        public Id DocumentId {get;set;}
        @AuraEnabled
        public String DocumentUrl {get;set;}
        @AuraEnabled
        public String Name {get;set;}
        @AuraEnabled
        public Id AssessmentId {get;set;}
        @AuraEnabled
        public String AssessmentUrl {get;set;}
        @AuraEnabled
        public String AssessmentName {get;set;}
        @AuraEnabled
        public String Description {get;set;}
        @AuraEnabled
        public String ErrorMessage {get;set;}
        @AuraEnabled
        public Datetime PackageCreatedDate {get;set;}
        @AuraEnabled
        public Datetime DeploymentStarttime {get;set;}
        @AuraEnabled
        public Datetime DeploymentEndtime {get;set;}
        @AuraEnabled
        public Boolean IsSelected {get;set;}

        public DeploymentInfo() {}

        public DeploymentInfo(ContentDocumentLink deployment, Assessment__c parentAssessment) {
            this.DocumentId = deployment.ContentDocumentId;
            this.DocumentUrl = DOWNLOAD_URL_PREFIX + this.DocumentId;
            this.Name = deployment.ContentDocument.Title;
            this.AssessmentId = deployment.LinkedEntityId;
            this.AssessmentName = deployment.LinkedEntity.Name;
            this.AssessmentUrl = '/' + this.AssessmentId;
            this.Description = parentAssessment.Description__c;
            this.PackageCreatedDate = deployment.ContentDocument.CreatedDate;
            this.IsSelected = false;
        }
    }

    public class DeploymentResult {
        @AuraEnabled
        public String status {get; set;}
        @AuraEnabled
        public String error {get; set;}

        public DeploymentResult() {}
    }

    public class DeployedPackageTableInfo {
        @AuraEnabled
        public Set<Id> AssessmentIds {get;set;}
        @AuraEnabled
        public List<DeploymentInfo> DeployedPackages {get;set;}
        @AuraEnabled
        public List<DeploymentInfo> PendingPackages {get;set;}
        @AuraEnabled
        public List<DeploymentInfo> DeployablePackages {get;set;}
        @AuraEnabled
        public List<DeploymentInfo> ErrorPackages {get;set;}

        public DeployedPackageTableInfo() {}

        public DeployedPackageTableInfo(
            Set<Id> assessmentIds,
            List<DeploymentInfo> deployedPackages, 
            List<DeploymentInfo> pendingPackages, 
            List<DeploymentInfo> deployablePackages, 
            List<DeploymentInfo> errorPackages
        ) {
            this.AssessmentIds = assessmentIds;
            this.DeployedPackages = deployedPackages;
            this.PendingPackages = pendingPackages;
            this.DeployablePackages = deployablePackages;
            this.ErrorPackages = errorPackages;
        }
    }
}