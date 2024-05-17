/**
 * Assessment__c object Trigger handler
 */
public inherited sharing class AssessmentTriggerHandler {

    private static final String STATUS_SCANNING = 'Scanning';
    private static final String STATUS_REVIEW = 'Review';

    private static final String SUBSTATUS_INITIATE = 'Initiate';
    private static final String SUBSTATUS_BULK_SCAN = 'Bulk Scan';
    private static final String SUBSTATUS_APEX_SHARE_SCAN = 'Apex Share Scan';
    private static final String SUBSTATUS_FINALIZING = 'Finalizing';

    @TestVisible
    static Boolean bypassTriggerForTestSetup = false;

    public static void beforeUpdate(Map<Id, Assessment__c> newMap, Map<Id, Assessment__c> oldMap){
        if(bypassTriggerForTestSetup == true) return;
        List<Assessment__c> newList = newMap.values();
        PackageInstallationController.processPackageInstall(newList, oldMap);
        PackageDeploymentController.processPackageDeployment(newList, oldMap);
        for (Id assessmentId : newMap.keySet()) {
            Assessment__c newRecord = newMap.get(assessmentId);
            Assessment__c oldRecord = oldMap.get(assessmentId);

            if(newRecord.Status__c == STATUS_SCANNING && oldRecord.Status__c != STATUS_SCANNING){
                newRecord.Sub_Status__c = SUBSTATUS_BULK_SCAN;
            }

            //detect toggle Bulk_Scan_Complete__c to true
            if( (newRecord.Bulk_Scan_Complete__c && !oldRecord.Bulk_Scan_Complete__c)
                && newRecord.Status__c == STATUS_SCANNING
                && newRecord.Sub_Status__c == SUBSTATUS_INITIATE) {
                newRecord.Sub_Status__c = SUBSTATUS_APEX_SHARE_SCAN;
            }

            if( (newRecord.Apex_Sharing_Scan_Complete__c && !oldRecord.Apex_Sharing_Scan_Complete__c)
                && newRecord.Status__c == STATUS_SCANNING
                && newRecord.Sub_Status__c == SUBSTATUS_APEX_SHARE_SCAN) {
                    newRecord.Status__c = STATUS_SCANNING;
                    newRecord.Sub_Status__c = SUBSTATUS_FINALIZING;
            }
        }
    }

    /**
     * AFTER UPDATE trigger handler for Assessment__c
     */
    public static void afterUpdate(Map<Id, Assessment__c> newMap, Map<Id, Assessment__c> oldMap) {
        if(bypassTriggerForTestSetup == true) return;

        Map<Id, Assessment__c> recordsToProcessScanComplete = new Map<Id, Assessment__c>();
        //detect record field changes
        for (Id assessmentId : newMap.keySet()) {
            Assessment__c newRecord = newMap.get(assessmentId);
            Assessment__c oldRecord = oldMap.get(assessmentId);

            //detect toggle Bulk_Scan_Complete__c to true
            if(newRecord.Bulk_Scan_Complete__c && !oldRecord.Bulk_Scan_Complete__c) {
                ApexShareRecordQueryQueueable.queryForSharingReasonsAsync(newRecord.Id);

            } else if( (newRecord.Apex_Sharing_Scan_Complete__c && !oldRecord.Apex_Sharing_Scan_Complete__c)
                        || (newRecord.Sub_Status__c == SUBSTATUS_FINALIZING && oldRecord.Sub_Status__c != SUBSTATUS_FINALIZING) ){ //detect toggle Apex_Sharing_Scan_Complete__c to true
                if(newRecord.Bulk_Scan_Complete__c){
                    recordsToProcessScanComplete.put(newRecord.Id, newRecord);
                } else {
                    //Need to call CompleteAnalysis here
                    DependencyScanQueueable.run(newRecord.Id);
                }
            }
        }

        //Execute callback to finalize analysis processing after Bulk_Scan_Complete__c
        if (!recordsToProcessScanComplete.isEmpty()) {
            TransitionReadinessUtility.processScanResultsCallback(new List<Id>(recordsToProcessScanComplete.keySet()));
        }
    }
}