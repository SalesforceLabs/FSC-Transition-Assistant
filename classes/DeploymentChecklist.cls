/**
 * The purpose of this class is to facilitate generation of deployment package items that can be selected
 * for automatic deployment
 */
public with sharing class DeploymentChecklist {
    private static final String ASSESSMENT_FILE_DEPLOYMENT_LIST = 'deploymentList';
    private static final String PACKAGE_INSTALL_STATUS_PROCESSING = 'Generating Deployment Package';

    /**
     * Generate list of deployable components from user defined mapping and Assessment migration analysis
     */
    @AuraEnabled(cacheable=true)
    public static List<DeploymentChecklistSection> generateDeploymentList(Id assessmentId) {
        List<DeploymentChecklistSection> deploymentSectionList = new List<DeploymentChecklistSection>();
        Map<String,DeploymentChecklistItem> idToItem = new Map<String,DeploymentChecklistItem>();
        //load user defined mapping
        MappingService.MappedComponents userMapping = MappingService.parseMappedComponents(assessmentId);

        //parse user defined mapping for new record types
        List<DeploymentChecklistItem>  deploymentItems = new List<DeploymentChecklistItem>();
        for (MappingService.RecordTypes recordTypeMapping : userMapping.recordTypeMappings) {
            if (recordTypeMapping.newMeta != null) {
                DeploymentChecklistItem checklistItem = new DeploymentChecklistItem();
                checklistItem.newMeta = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(recordTypeMapping.newMeta));
                checklistItem.isNew = true;
                checklistItem.componentType = DependencyHelper.TYPE_RECORD_TYPE;
                checklistItem.componentName = recordTypeMapping.newMeta.apiName;
                checklistItem.componentLabel = checklistItem.componentName + ' (NEW)';
                checklistItem.componentId = recordTypeMapping.source;
                checklistItem.sourceObject = recordTypeMapping.sourceObject;
                checklistItem.targetObject = userMapping.sourceToDestinationObject.get(recordTypeMapping.sourceObject.replace('__c', ''));
                deploymentItems.add(checklistItem);
                idToItem.put(checklistItem.componentId, checklistItem);
            }
        }
        if (!deploymentItems.isEmpty()) {
            deploymentSectionList.add(new DeploymentChecklistSection(DependencyHelper.TYPE_RECORD_TYPE, DependencyHelper.getTypeLabel(DependencyHelper.TYPE_RECORD_TYPE), deploymentItems));
        }
        
        //parse user defined mapping for new fields
        deploymentItems = new List<DeploymentChecklistItem>();
        for (MappingService.FieldMapping fieldMapping : userMapping.fieldMappings) {
            if (fieldMapping.newMeta != null) {
                DeploymentChecklistItem checklistItem = new DeploymentChecklistItem();
                checklistItem.newMeta = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(fieldMapping.newMeta));
                checklistItem.isNew = true;
                checklistItem.componentType = DependencyHelper.TYPE_CUSTOM_FIELD;
                checklistItem.componentName = fieldMapping.newMeta.apiName;
                checklistItem.componentLabel = checklistItem.componentName + ' (NEW)';
                checklistItem.componentId = fieldMapping.source;
                checklistItem.sourceObject = fieldMapping.sourceObject;
                checklistItem.targetObject = userMapping.sourceToDestinationObject.get(fieldMapping.sourceObject.replace('__c', ''));
                deploymentItems.add(checklistItem);
                idToItem.put(checklistItem.componentId, checklistItem);
            }
        }
        if (!deploymentItems.isEmpty()) {
            deploymentSectionList.add(new DeploymentChecklistSection(DependencyHelper.TYPE_CUSTOM_FIELD, DependencyHelper.getTypeLabel(DependencyHelper.TYPE_CUSTOM_FIELD), deploymentItems));
        }
        
        //parse Migration Analysis for all other deployable components migrating to FSC objects as parent
        deploymentItems = new List<DeploymentChecklistItem>();
        Map<String,List<DeploymentChecklistItem>> typeToItems = new Map<String,List<DeploymentChecklistItem>>();
        TransitionAnalysis analysis = TransitionAnalysis.loadAnalysis(assessmentId);
        if (analysis != null) {
            //loop top level object nodes
            for (TransitionAnalysis.MigrationAnalysisItem mai : analysis.migrationAnalysis) {
                String sourceObjectName = mai.fromComponentType == DependencyHelper.TYPE_CUSTOM_OBJECT ? mai.fromComponentName + '__c' : mai.fromComponentName;
                String targetObjectName = mai.toComponentName;
                //loop each component type
                for (TransitionAnalysis.MigrationAnalysisItem maiType : mai.children) {
                    if (maiType.fromComponentType != DependencyHelper.TYPE_RECORD_TYPE && 
                        maiType.fromComponentType != DependencyHelper.TYPE_CUSTOM_FIELD && 
                        TransitionAnalysis.COMPONENT_TYPES_DEPLOYABLE.contains(maiType.fromComponentType)) {
                        //add to deployment list for given type
                        for (TransitionAnalysis.MigrationAnalysisItem maiTypeComponent : maiType.children) {
                            List<DeploymentChecklistItem> items = typeToItems.get(maiType.fromComponentType);
                            if (items == null) { items = new List<DeploymentChecklistItem>(); }
                            DeploymentChecklistItem checklistItem = new DeploymentChecklistItem(maiTypeComponent, sourceObjectName, targetObjectName);
                            if (!idToItem.containsKey(checklistItem.componentId)) {
                                idToItem.put(checklistItem.componentId, checklistItem);
                                items.add(checklistItem);
                                typeToItems.put(maiType.fromComponentType, items);
                            }
                            //check component child references
                            for (TransitionAnalysis.MigrationAnalysisItem maiTypeComponentChild : maiTypeComponent.children) {
                                items = typeToItems.get(maiTypeComponentChild.fromComponentType);
                                if (items == null) { items = new List<DeploymentChecklistItem>(); }
                                //skip custom fields that are not NEW for deployment and we captured from mapping
                                if (maiTypeComponentChild.fromComponentType != DependencyHelper.TYPE_CUSTOM_FIELD && 
                                    !idToItem.containsKey(checklistItem.componentId) && 
                                    TransitionAnalysis.COMPONENT_TYPES_DEPLOYABLE.contains(maiTypeComponentChild.fromComponentType)) {
                                    DeploymentChecklistItem checklistChildItem = new DeploymentChecklistItem(maiTypeComponentChild, sourceObjectName, targetObjectName);
                                    idToItem.put(checklistChildItem.componentId, checklistChildItem);
                                    items.add(checklistChildItem);
                                    typeToItems.put(maiType.fromComponentType, items);
                                }
                            }
                        }
                    }
                }
            }
            //add collected items by component type
            for (String typeName : typeToItems.keySet()) {
                deploymentSectionList.add(new DeploymentChecklistSection(typeName, DependencyHelper.getTypeLabel(typeName), typeToItems.get(typeName)));
            }

            //parse out profiles/permission sets
            deploymentItems = new List<DeploymentChecklistItem>();
            for (TransitionAnalysis.MigrationAnalysisItem profilePermItem : analysis.accessInfoResults) {
                DeploymentChecklistItem checklistItem = new DeploymentChecklistItem(profilePermItem, '', '');
                idToItem.put(checklistItem.componentId, checklistItem);
                deploymentItems.add(checklistItem);
            }
            if (!deploymentItems.isEmpty()) {
                deploymentSectionList.add(new DeploymentChecklistSection(DependencyHelper.TYPE_PROFILE, Label.TypeProfilesPermissionSets, deploymentItems));
            }
        }

        return deploymentSectionList;
    }

    /**
     * Save results file and callout to external service to generate deployment package .zip
     * and save back so SF as ContentDocument related to assessmentId. Update Assessment Status for processing.
     */
    @AuraEnabled
    public static Boolean generateDeploymentPackage(Id assessmentId, Id deploymentFileId) {
        Boolean isProcessing = ExternalUtilities.requestGenerateDeploymentPackage(assessmentId, deploymentFileId);
        if (isProcessing) {
            AssessmentService.updateAssessment(new Assessment__c(Id = assessmentId, Sub_Status__c = PACKAGE_INSTALL_STATUS_PROCESSING));
        }
        return isProcessing;
    }

    /**
     * Save selected checkist items into a File for use with deployment package generation
     */
    @AuraEnabled
    public static Id saveDeploymentChecklist(Id assessmentId, String itemsToDeployJson) {
        Map<String,Object> deploymentMap = new Map<String,Object> {
            'mapping' => MappingService.parseMappedComponents(assessmentId),
            'deployment' => JSON.deserializeUntyped(itemsToDeployJson)
        };
        return FileUtility.writeFileData(assessmentId, ASSESSMENT_FILE_DEPLOYMENT_LIST, 'json', JSON.serialize(deploymentMap));
    }

    /**
     * Wrapper class for component section with list components for checkbox selection data table
     */
    public class DeploymentChecklistSection {
        @AuraEnabled public String sectionName;
        @AuraEnabled public String sectionLabel;
        @AuraEnabled public String sectionDescription;
        @AuraEnabled public List<DeploymentChecklistItem> components = new List<DeploymentChecklistItem>();
        public DeploymentChecklistSection() {}
        public DeploymentChecklistSection(String sectionName, String sectionLabel, List<DeploymentChecklistItem> components) {
            this.sectionName = sectionName;
            this.sectionLabel = sectionLabel;
            this.components = components;
        }
    }
    
    /**
     * Wrapper class for checkbox selection data table
     */
    public class DeploymentChecklistItem {
        @AuraEnabled public String componentId;
        @AuraEnabled public String componentName;
        @AuraEnabled public String componentLabel;
        @AuraEnabled public String componentType;
        @AuraEnabled public String componentUrl;
        @AuraEnabled public String sourceObject;
        @AuraEnabled public String targetObject;
        @AuraEnabled public Boolean isNew;
        @AuraEnabled public Map<String,Object> newMeta;

        public DeploymentChecklistItem() {}

        public DeploymentChecklistItem(TransitionAnalysis.MigrationAnalysisItem mai, String sourceObject, String targetObject) {
            this.componentId = mai.fromComponentId;
            this.componentType = mai.fromComponentType;
            this.componentName = mai.fromComponentName;
            this.componentLabel = mai.fromComponentName;
            this.componentUrl = mai.fromComponentUrl;
            this.sourceObject = sourceObject;
            this.targetObject = targetObject;
        }
    }
}