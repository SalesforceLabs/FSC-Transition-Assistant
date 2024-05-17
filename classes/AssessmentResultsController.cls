/**
 * Controller for the c-assessment-results web component
 */
public with sharing class AssessmentResultsController {

    public static final String ASSESSMENT_REPORT_FILENAME = 'AssessmentReport';

    /**
     * Return view model for displaying upgrade readiness assessment results
     * stored on an Assessment record
     *
     * @return - AssessmentResultsView Model of results from of TransitionReadinessUtility.ReadinessResults
     */
    @AuraEnabled
    public static AssessmentResultsView getAssessmentResults(Id assessmentId) {
        return new AssessmentResultsView(TransitionReadinessUtility.performFscUpgradeAssessment(assessmentId));
    }

    /**
	 * Get and Set Custom Settings values pertaining to the Assessment Report
	 */
    @AuraEnabled
    public static TransitionAppSettings__c getCustomSettings(){
        return TransitionAppSettings__c.getOrgDefaults();
    }
    @AuraEnabled
    public static Boolean disableWelcomeDefault(){
        Database.SaveResult result;
        try{
            List<PermissionSetAssignment> permissions = [SELECT Id from PermissionSetAssignment WHERE AssigneeId = :UserInfo.getuserid()
            AND PermissionSet.PermissionsCustomizeApplication = true];
            if(permissions.size()>0){
                TransitionAppSettings__c settings = getCustomSettings();
                if(settings==null || settings.Id==null){
                    settings = new TransitionAppSettings__c(SetupOwnerId=UserInfo.getOrganizationId(), Collapse_Welcome_Section_By_Default__c = true);

                    SObjectAccessDecision decision = Security.stripInaccessible(AccessType.CREATABLE, new List<SObject>{settings}, true);
                    result = Database.insert(Test.isRunningTest() ? new List<SObject>{settings} : decision.getRecords())[0];
                }else{
                    settings.Collapse_Welcome_Section_By_Default__c = true;

                    SObjectAccessDecision decision = Security.stripInaccessible(AccessType.UPDATABLE, new List<SObject>{settings}, true);
                    result = Database.update(Test.isRunningTest() ? new List<SObject>{settings} : decision.getRecords())[0];
                }
                return result.isSuccess(); 
            }
        }catch(Exception e){
            System.debug('==Exception: '+e.getMessage());
        }    
        return false;
    }

    @AuraEnabled
    public static String downloadPdfReport(Id assessmentId){
        String pdfVersionId;

        String contentDocumentId = getAssessmentReportId(assessmentId);
        System.debug(contentDocumentId);
        if(String.isNotBlank(contentDocumentId)){
            pdfVersionId = contentDocumentId;
        } else {
            try{
                ExternalUtilities.PdfDocumentResponse pdfResponse = ExternalUtilities.requestAssessmentAsPdf(assessmentId);

                pdfVersionId = 'PENDING';
            } catch(Exception e){
                System.debug(e.getStackTraceString());
                throw new AuraHandledException(e.getMessage());
            }
        }

        return pdfVersionId;
    }

    @AuraEnabled
    public static String getAssessmentReportId(Id assessmentId){
        return FileUtility.getContentDocumentIdByName(assessmentId, ASSESSMENT_REPORT_FILENAME);
    }

    /**
     * View Model for Assessment Report Results
     */
    public class AssessmentResultsView {
        @AuraEnabled public String assessmentVersion;
        @AuraEnabled public Datetime dateRun;
        @AuraEnabled public Id orgId;
        @AuraEnabled public String orgEdition;
        @AuraEnabled public String upgradeType;
        @AuraEnabled public TransitionReadinessUtility.InstallReadiness installReadiness;
        @AuraEnabled public RecommendationView overallRecommendation;
        @AuraEnabled public List<RecommendationView> recommendations = new List<RecommendationView>();
        @AuraEnabled public TransitionAnalysis analysis;

        public AssessmentResultsView(TransitionReadinessUtility.ReadinessResults results) {
            this.assessmentVersion = results.assessmentVersion;
            this.dateRun = results.dateRun;
            this.orgId = results.orgId;
            this.orgEdition = results.orgEdition;
            this.upgradeType = String.valueOf(results.upgradeType) + (results.orgVersion != null ? ' ' + results.orgVersion : '');
            this.installReadiness = results.installReadiness;
            if (results.overallRecommendation != null) {
                this.overallRecommendation = new RecommendationView(results.overallRecommendation);
            }
            if (results.recommendations != null) {
                for (TransitionRecommendation rec : results.recommendations) {
                    this.recommendations.add(new RecommendationView(rec));
                }
            }
            this.analysis = results.analysis != null ? results.analysis : new TransitionAnalysis();
        }
    }

    /**
     * View Model for TransitionRecommendation
     */
    public class RecommendationView {
        @AuraEnabled public String text;
        @AuraEnabled public List<String> reasons;
        @AuraEnabled public String severityIcon;

        public RecommendationView(TransitionRecommendation recommendation) {
            this.text = recommendation.text;
            this.reasons = recommendation.reasons;
            switch on recommendation.severity {
                when INFO {
                    this.severityIcon = 'standard:solution';
                }
                when SUCCESS {
                    this.severityIcon = 'action:approval';
                }
                when WARNING {
                    this.severityIcon = 'utility:warning';
                }
                when CRITICAL {
                    this.severityIcon = 'action:bug';
                }
                when else {
                    this.severityIcon = 'standard:solution';
                }
            }
        }
    }

}