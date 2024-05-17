public with sharing class DependencyScanQueueable implements Queueable, Database.AllowsCallouts{

    private Id assessmentId;

    public DependencyScanQueueable(Id assessmentId) {
        this.assessmentId = assessmentId;
    }

    public void execute(QueueableContext context){
        TransitionReadinessUtility.scanComponentDependencies(this.assessmentId);
    }

    public static void run(Id assessmentId){
        System.enqueueJob(new DependencyScanQueueable(assessmentId));
    }
}