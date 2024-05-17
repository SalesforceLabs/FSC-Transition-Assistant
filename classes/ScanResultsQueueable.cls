public with sharing class ScanResultsQueueable implements Queueable, Database.AllowsCallouts{
    Id assessmentId;

    public ScanResultsQueueable(Id assessmentId) {
        this.assessmentId = assessmentId;
    }

    public void execute(QueueableContext context){
        TransitionReadinessUtility.processScanResultsFuture(this.assessmentId);
    }

    public static void run(Id assessmentId){
        System.enqueueJob(new ScanResultsQueueable(assessmentId));
    }
}