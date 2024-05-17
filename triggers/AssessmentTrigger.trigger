trigger AssessmentTrigger on Assessment__c (before update, after update) {
    switch on Trigger.operationType {
        when BEFORE_UPDATE {
            AssessmentTriggerHandler.beforeUpdate(Trigger.newMap, Trigger.oldMap);
        }
        when AFTER_UPDATE {
            AssessmentTriggerHandler.afterUpdate(Trigger.newMap, Trigger.oldMap);
        }
    }
}