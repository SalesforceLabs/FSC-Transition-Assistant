/**
 * @Desc:  Provided a list of Share objects, this queries those objects for custom Apex Share Reasons
**/
public inherited sharing class ApexShareRecordQueryQueueable implements Queueable, Database.AllowsCallouts {

    private Id assessmentId;
    private QueryCriteria queryCriteriaItem;
    private List<QueryCriteria> queryCriteria;
    private Assessment__c assessment;
    private MappingService.MappedComponents mapping;

    private Integer totalCriteria;
    private Integer criteriaChecked = 0;

    private static final String ASSESSMENT_FILE_ANALYSIS = 'analysis';

    public ApexShareRecordQueryQueueable(Id assessmentId, List<QueryCriteria> queryCriteria) {
        this.assessmentId = assessmentId;
        this.queryCriteria = queryCriteria;

        this.totalCriteria = queryCriteria.size();

        for(QueryCriteria criteria : queryCriteria){
            System.debug(criteria);
            if(criteria.hasBeenProcessed){
                this.criteriaChecked++;
            } else if(!criteria.hasBeenProcessed && this.queryCriteriaItem == NULL){
                this.queryCriteriaItem = criteria;
                break;
            }
        }
    }

    public void execute(QueueableContext context){
        if(this.queryCriteria.isEmpty()){
            //If there is nothing to query, we need to scan Apex for Active classes that create *Share records
            executeApexShareReferenceScanBatch();
        }
        //Could potentially update QueryCriteria to have a flag, and then do a single update at the end of all the queries
        if(this.queryCriteriaItem == NULL) {
            return;
        }

        if( hasSharingReasonsInUse() ){
            updateAssessment(true, false);
        }

        this.queryCriteriaItem.hasBeenProcessed = true;
        this.criteriaChecked++;

        if(this.totalCriteria > this.criteriaChecked){
            System.enqueueJob(new ApexShareRecordQueryQueueable(this.assessmentId, this.queryCriteria));
        } else if( this.totalCriteria == this.criteriaChecked){
            executeApexShareReferenceScanBatch();
        }
    }

    /**
     * @Desc:  Queries __Share object for existence of custom Apex Sharing Reasons
     */
    private Boolean hasSharingReasonsInUse() {

        final String SHARE_QUERY = 'SELECT COUNT(Id), RowCause FROM {0} WHERE RowCause IN ({1}{2}{3}) GROUP BY RowCause';
        final String singleQuote = '\'';
        final String separator = '\',\'';
        String joinedSharingReasons = String.join( this.queryCriteriaItem.sharingReasons, separator );

        String queryString = String.format( SHARE_QUERY, new List<String> {
            queryCriteriaItem.sObjectApiName,
            singleQuote,
            joinedSharingReasons,
            singleQuote
        } );

        List<AggregateResult> sharingReasonQuery = Database.query( queryString );

        if ( !sharingReasonQuery.isEmpty() ) {
            return true;
        }

        return false;
    }

    /**
     *
     * @param hasApexSharing If object has a Custom Apex Share Reason
     * @param isScanComplete If all items have been scanned
     */
    private void updateAssessment(Boolean hasApexSharing, Boolean isScanComplete){
        Assessment__c assessment = new Assessment__c(Id = this.assessmentId);
        if(hasApexSharing){
            assessment.Has_Apex_Sharing__c = true;
        }
        if(isScanComplete){
            assessment.Apex_Sharing_Scan_Complete__c = true;
        }
        AssessmentService.updateAssessment(assessment);
    }

    /**
     * Queue up the next phase of scanning of Apex classes
     */
    private void executeApexShareReferenceScanBatch(){
        ApexShareReferenceScanBatch.run(this.assessmentId);
    }

    /**
     * Wrapper to help with processing of multiple objects and Apex Share Reasons
     */
    public class QueryCriteria {
        public String sObjectApiName;
        public Boolean hasBeenProcessed;
        public List<String> sharingReasons;

        public QueryCriteria(String sObjectApiName, List<String> sharingReasons){
            this.sObjectApiName = sObjectApiName;
            this.hasBeenProcessed = false;
            this.sharingReasons = sharingReasons;
        }
    }


    /**
     * Begin scan process for Sharing Reasons
     */
    @future(callout = true)
    public static void queryForSharingReasonsAsync(Id assessmentId){
        queryForSharingReasons(assessmentId);
    }

    public static void queryForSharingReasons(Id assessmentId){
        try{
            Assessment__c assessment = AssessmentService.queryAssessment(assessmentId);
            MappingService.MappedComponents mapping = MappingService.parseMappedComponents(assessment);

            Map<String, Map<String, String> > customObjectToApexSharingReasons = TransitionAnalysis.getApexSharingReasons( mapping.mappedObjects );

            List<ApexShareRecordQueryQueueable.QueryCriteria> criteria = new List<ApexShareRecordQueryQueueable.QueryCriteria>();

            for( String sObjectApiName : customObjectToApexSharingReasons.keySet() ){
                ApexShareRecordQueryQueueable.QueryCriteria criteriaItem = new ApexShareRecordQueryQueueable.QueryCriteria(sObjectApiName, customObjectToApexSharingReasons.get(sObjectApiName).values());
                criteria.add(criteriaItem);
            }

            System.enqueueJob(new ApexShareRecordQueryQueueable(assessmentId,criteria));

        } catch(Exception e){
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
        }
    }
}