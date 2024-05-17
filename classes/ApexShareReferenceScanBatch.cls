/**
 * Perform Regex on Apex Class Bodies to see if a __Share object is being referenced.
 * We scan all Apex classes since a `String` or `Id` might be passed into the `ParentId` field on the `Share` object
 */
public inherited sharing class ApexShareReferenceScanBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {

    public static final Integer DEFAULT_BATCH_SIZE = 10;

    private Id assessmentId;
    private Boolean hasReferenceToShare = false;
    private Boolean hasReferenceToShareOnCDS = false;
    private MappingService.MappedComponents mapping;

    private final String query = 'SELECT Id, Name, Body FROM ApexClass WHERE Status = \'Active\' AND NamespacePrefix != \''+Utilities.namespace+'\'';

    public ApexShareReferenceScanBatch(Id assessmentId) {
        this.assessmentId = assessmentId;
        this.mapping = MappingService.parseMappedComponents(assessmentId);
    }

    public Database.QueryLocator start(Database.BatchableContext batchableContext){
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext batchableContext, List<sObject> scope){

        List<TransitionAnalysis.MigrationAnalysisItem> migrationAnalysisItems = new List<TransitionAnalysis.MigrationAnalysisItem>();

        Pattern shareObjectReference = Pattern.compile('(?mi)([\\w_]+__share)');
        //Only Account and Opportunity are supported by CDS currently.
        Pattern cdsPattern = Pattern.compile('(?mi)(AccountShare|OpportunityShare)');

        Set<String> sharesFound = new Set<String>();

        try{
            for(ApexClass apexClass : (List<ApexClass>)scope){
                Matcher patternMatcher = shareObjectReference.matcher(apexClass.Body);
                Matcher cdsMatcher = cdsPattern.matcher(apexClass.Body);

                //Check for references to a Custom Object Share
                while( patternMatcher.find() ){

                    String relatedCustomObjectApiName = patternMatcher.group().replaceAll('(?i)(__share)', '__c');

                    if( !sharesFound.contains(patternMatcher.group().toLowerCase())
                        && (this.mapping.mappedObjects.contains(relatedCustomObjectApiName) || this.mapping.mappedObjects.contains(relatedCustomObjectApiName.toLowerCase()))
                    ) {
                        hasReferenceToShare = true;
                        TransitionAnalysis.MigrationAnalysisItem migrationAnalysisItem = createMigrationAnalysisItem(apexClass, patternMatcher.group(), Label.SharingSettingsApexReason);
                        migrationAnalysisItems.add(migrationAnalysisItem);

                        sharesFound.add(patternMatcher.group().toLowerCase());
                    }
                }
                //Check for references to CDS Object share
                while( cdsMatcher.find()){

                    String standardCustomObjectApiName = cdsMatcher.group().replaceAll('(?i)(share)', '');

                    if( !sharesFound.contains(cdsMatcher.group().toLowerCase())
                        && (this.mapping.mappedObjects.contains(standardCustomObjectApiName) || this.mapping.mappedObjects.contains(standardCustomObjectApiName.toLowerCase()))
                    ) {
                        hasReferenceToShareOnCDS = true;

                        TransitionAnalysis.MigrationAnalysisItem migrationAnalysisItem = createMigrationAnalysisItem(apexClass, cdsMatcher.group(), Label.SharingSettingsCDSReason);
                        migrationAnalysisItems.add(migrationAnalysisItem);

                        sharesFound.add(cdsMatcher.group().toLowerCase());
                    }
                }

            }

            if(!migrationAnalysisItems.isEmpty()) {
                AssessmentService.updateAssessment(new Assessment__c(
                    Id = this.assessmentId,
                    ApexShareAnalysisJSON__c = JSON.serialize(migrationAnalysisItems)
                ));
            }
        } catch(Exception e){
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
        }
    }

    private TransitionAnalysis.MigrationAnalysisItem createMigrationAnalysisItem(ApexClass apexClass, String shareObjectName, String reasonText){
        TransitionAnalysis.MigrationAnalysisItem migrationAnalysisItem = new TransitionAnalysis.MigrationAnalysisItem();
        migrationAnalysisItem.fromComponentName = shareObjectName;
        migrationAnalysisItem.fromComponentType = DependencyHelper.TYPE_CUSTOM_OBJECT;
        migrationAnalysisItem.children = new List<TransitionAnalysis.MigrationAnalysisItem>();

        TransitionAnalysis.MigrationAnalysisItem childMigrationAnalysisItem = new TransitionAnalysis.MigrationAnalysisItem();
        childMigrationAnalysisItem.fromComponentName = apexClass.Name;
        childMigrationAnalysisItem.fromComponentType = DependencyHelper.TYPE_APEX_CLASS;
        childMigrationAnalysisItem.fromComponentUrl = new DependencyHelper.MetadataComponent(DependencyHelper.TYPE_APEX_CLASS, apexClass.Id, null, null).componentUrl;
        childMigrationAnalysisItem.toComponentName = shareObjectName;
        childMigrationAnalysisItem.reasonText = reasonText;

        migrationAnalysisItem.children.add(childMigrationAnalysisItem);

        return migrationAnalysisItem;
    }

    public void finish(Database.BatchableContext batchableContext){
        if(hasReferenceToShare && hasReferenceToShareOnCDS){
            updateAssessment(true, true, true);
        } else if(hasReferenceToShare){
            updateAssessment(true, false, true);
        } else if(hasReferenceToShareOnCDS){
            updateAssessment(false, true, true);
        } else {
            updateAssessment(false, false, true);
        }
    }

    /**
     *
     * @param hasApexSharing If object has a Custom Apex Share Reason
     * @param isScanComplete If all items have been scanned
     */
    private void updateAssessment(Boolean hasApexSharing, Boolean hasReferenceToShareOnCDS, Boolean isScanComplete){
        Assessment__c assessment = new Assessment__c(Id = this.assessmentId);
        if(hasApexSharing){
            assessment.Has_Apex_Sharing__c = true;
        }
        if(hasReferenceToShareOnCDS){
            assessment.Has_Apex_Sharing_on_CDS_Object__c = true;
        }
        if(isScanComplete){
            assessment.Apex_Sharing_Scan_Complete__c = true;
        }
        AssessmentService.updateAssessment(assessment);
    }

    /**
     *
     * @param assessmentId record Id of Assessment
     * @param apexClassNames Unique Apex Class Names to check for references to __Share objects
     */
    public static void run(Id assessmentId){
        Database.executeBatch(new ApexShareReferenceScanBatch(assessmentId), DEFAULT_BATCH_SIZE);
    }
}