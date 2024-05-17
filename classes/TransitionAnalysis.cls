/**
 * Process upgrade analysis results
 */
public inherited sharing class TransitionAnalysis {
    @AuraEnabled public List<AssessmentResultItem> assessmentResults;
    @AuraEnabled public List<MigrationAnalysisItem> migrationAnalysis;
    @AuraEnabled public List<MigrationAnalysisItem> accessInfoResults;
    @AuraEnabled public List<MigrationAnalysisItem> sharingSettingResults;

    private static final String ASSESSMENT_FILE_ANALYSIS = 'analysis';

    //component types that can automatically be migrated
    public static final Set<String> COMPONENT_TYPES_DEPLOYABLE = new Set<String> {
        DependencyHelper.TYPE_CUSTOM_OBJECT,
        DependencyHelper.TYPE_RECORD_TYPE,
        DependencyHelper.TYPE_CUSTOM_FIELD,
        DependencyHelper.TYPE_FIELD_SET,
        DependencyHelper.TYPE_PAGE_LAYOUT,
        DependencyHelper.TYPE_COMPACT_LAYOUT,
        DependencyHelper.TYPE_PERMISSION_SET,
        DependencyHelper.TYPE_PROFILE
        //DependencyHelper.TYPE_APPROVAL_PROCESS,
        //DependencyHelper.TYPE_WOKFLOW_RULE,
        //DependencyHelper.TYPE_EMAIL_TEMPLATE,
        //DependencyHelper.TYPE_EMAIL_ALERT,
        //DependencyHelper.TYPE_FIELD_UPDATE,
        //DependencyHelper.TYPE_OUTBOUND_MESSAGE,
        //DependencyHelper.TYPE_WORKFLOW_TASK
    };

    private static final Map<String, String> SHARING_VALUE_TO_LABEL = new Map<String, String> {
        'ControlledByCampaign'  =>  'Controlled By Campaign',
        'ControlledByParent'  =>  'Controlled By Parent',
        'FullAccess'    =>  'Public Full Access',
        'Private'   =>  'Private',
        'ReadSelect'   =>  'Use',
        'ReadWrite' =>  'Public Read/Write',
        'ReadWriteTransfer' =>  'Public Read/Write/Transfer',
        'Read'  =>  'Public Read Only'
    };

    private Assessment__c assessment;
    private MappingService.MappedComponents mapping;

    public TransitionAnalysis() {}

    public TransitionAnalysis(Id assessmentId) {
        //load record and saved object mapping
        this.assessment = AssessmentService.queryAssessment(assessmentId);
        this.mapping = MappingService.parseMappedComponents(assessment);
    }

    /**
     * Load Analysis File and return this data type instance
     */
    public static TransitionAnalysis loadAnalysis(Id assessmentId) {
        TransitionAnalysis analysis;
        String analysisJson = FileUtility.readFileDataString(assessmentId, ASSESSMENT_FILE_ANALYSIS);
        if (String.isNotBlank(analysisJson)) {
            analysis = (TransitionAnalysis)JSON.deserialize(analysisJson, TransitionAnalysis.class);
        }
        return analysis;
    }

    /**
     * Save Analysis File and return file Id
     */
    public static Id saveAnalysis(Id assessmentId, TransitionAnalysis analysis) {
        //prevent saving private instance variables
        analysis.assessment = null;
        analysis.mapping = null;
        //save instance as result file
        return FileUtility.writeFileData(assessmentId, ASSESSMENT_FILE_ANALYSIS, 'json', JSON.serialize(analysis));
    }

    /**
     * Process Dependency API Results into an TransitionAnalysis with recommendations for Report Results view
     * @param dependencies - Raw result of Dependency API query
     */
    public TransitionAnalysis generateAnalysis(List<ToolingService.MetadataComponentDependency> dependencies) {
        if (dependencies != null) {
            //generate technical analysis using raw Dependency API response (Small Orgs)
            List<MigrationAnalysisItem> migrationAnalysis = buildAnalysisTree(DependencyHelper.buildDependencyTree(dependencies));
            return this.generateAnalysis(migrationAnalysis);
        }
        return this;
    }

    /**
     * Generate TransitionAnalysis with recommendations for Report Results view
     * @param migrationAnalysis - previously generated MigrationAnalysisItem tree with DAPI results
     */
    public TransitionAnalysis generateAnalysis(List<MigrationAnalysisItem> migrationAnalysis) {
        if (migrationAnalysis != null) {
            //generate finalized Migration Analysis
            this.migrationAnalysis = buildTypeGrouping(buildMissingRelationships(migrationAnalysis, mapping), mapping);

            //generate summary Assessment Results
            this.assessmentResults = buildAssessmentResults(assessment);

            //generate Permission Results
            this.accessInfoResults = buildAccessInfoResults(mapping.mappedObjects, mapping.mappedFields);

            //generate Sharing Results
            this.sharingSettingResults = buildSharingSettingResults(assessment, mapping.sourceToDestinationObject, mapping.mappedObjects);
        }
        return this;
    }

    /**
     * Build LWC data list for the Profiles / Permissions section of the upgrade report
     */
    @TestVisible
    private static List<MigrationAnalysisItem> buildAccessInfoResults(Set<String> mappedObjects, Set<String> mappedFields) {
        Map<String, List<ObjectPermissions>> objectPermissionMap = Utilities.groupByStrings('Parent.Profile.Name', [
            SELECT ParentId, Parent.ProfileId, Parent.Profile.Name, SobjectType
            FROM ObjectPermissions
            WHERE SObjectType IN: mappedObjects
                AND Parent.IsCustom = true
                AND Parent.Profile.Name != null
            ORDER BY Parent.Profile.Name, SobjectType
        ]);

        Map<String, List<FieldPermissions>> fieldPermissionMap = Utilities.groupByStrings('Parent.Profile.Name', [
            SELECT ParentId, Parent.ProfileId, Parent.Profile.Name, SobjectType, Field
            FROM FieldPermissions
            WHERE SObjectType IN: mappedObjects
                AND Parent.Profile.Name IN: objectPermissionMap.keySet()
                AND Parent.IsCustom = true
                AND Field IN: mappedFields
            ORDER BY Parent.Profile.Name, SobjectType, Field
        ]);

        Map<String, List<PermissionSet>> permissionSetMap = Utilities.groupByStrings('Profile.Name', [
            SELECT Name, ProfileId, Profile.Name, IsOwnedByProfile
            FROM PermissionSet
            WHERE IsOwnedByProfile = true
                AND Profile.Name IN: objectPermissionMap.keySet()
                AND IsCustom = true
                AND (NOT Name LIKE 'X00e%') //exclude permission sets that are profiles
            ORDER BY Name
        ]);

        Map<String, List<AggregateResult>> userProfileInfo = Utilities.groupByStrings('Name', [
            SELECT count(Id) profileCount, Profile.Name
            FROM User
            WHERE Profile.Name IN: objectPermissionMap.keySet()
            GROUP BY Profile.Name
        ]);

        List<MigrationAnalysisItem> accessInfoResults = new List<MigrationAnalysisItem>();
        for (String profile : objectPermissionMap.keySet()) {
            List<ObjectPermissions> objectInfoList = objectPermissionMap.get(profile);
            List<FieldPermissions> fieldPerms = fieldPermissionMap.get(profile);
            Map<String, List<FieldPermissions>> fieldsBySObjectMap = fieldPerms == null ? new Map<String, List<FieldPermissions>>() : Utilities.groupByStrings(FieldPermissions.SObjectType, fieldPerms);

            MigrationAnalysisItem item = new MigrationAnalysisItem();
            item.fromComponentId = objectInfoList[0].Parent.ProfileId;
            item.fromComponentName = objectInfoList[0].Parent.Profile.Name;
            item.fromComponentType = 'Profile';
            item.fromComponentUrl = '/lightning/setup/Profiles/page?address=%2F' + objectInfoList[0].Parent.ProfileId;
            item.reasonText = userProfileInfo.get(objectInfoList[0].Parent.Profile.Name) == null ? '0' : String.valueOf(userProfileInfo.get(objectInfoList[0].Parent.Profile.Name)[0].get('profileCount'));
            item.children = new List<MigrationAnalysisItem>();

            for(ObjectPermissions objectInfo : objectInfoList) {
                MigrationAnalysisItem objectItem = new MigrationAnalysisItem();
                objectItem.fromComponentId = objectInfo.Id;
                objectItem.fromComponentName = objectInfo.SObjectType.replace('__c', '');
                objectItem.fromComponentType = objectInfo.SObjectType.endsWith('__c') ? 'CustomObject' : 'StandardEntity';
                String objectNameId = objectItem.fromComponentType == 'CustomObject' ? String.valueOf(objectInfo.Id) : objectInfo.SObjectType;
                objectItem.fromComponentUrl = '/lightning/setup/Profiles/page?address=%2F' + objectInfo.Parent.ProfileId + '%3Fs%3DObjectsAndTabs%26o%3D' + objectNameId;
                objectItem.children = new List<MigrationAnalysisItem>();
                item.children.add(objectItem);

                List<FieldPermissions> fieldInfoList = fieldsBySObjectMap.get(objectInfo.SObjectType);
                if(fieldInfoList != null) {
                    for(FieldPermissions fieldInfo : fieldInfoList) {
                        MigrationAnalysisItem fieldItem = new MigrationAnalysisItem();
                        fieldItem.fromComponentId = fieldInfo.Id;
                        fieldItem.fromComponentName = fieldInfo.Field.replace(objectInfo.SObjectType + '.', '');
                        fieldItem.fromComponentType = 'CustomField';
                        fieldItem.fromComponentUrl = '/lightning/setup/Profiles/page?address=%2F' + fieldInfo.Parent.ProfileId + '%3Fs%3DObjectsAndTabs%26o%3D' + objectNameId;
                        objectItem.children.add(fieldItem);
                    }
                }
            }

            List<PermissionSet> permissionSetList = permissionSetMap.get(profile);
            if(permissionSetList != null) {
                for(PermissionSet permInfo : permissionSetList) {
                    MigrationAnalysisItem permItem = new MigrationAnalysisItem();
                    permItem.fromComponentId = permInfo.Id;
                    permItem.fromComponentName = permInfo.Name;
                    permItem.fromComponentType = 'PermissionSet';
                    permItem.fromComponentUrl = '/lightning/setup/PermSets/home';
                    item.children.add(permItem);
                }
            }
            item.children.sort();
            accessInfoResults.add(item);
        }

        accessInfoResults.sort();

        return accessInfoResults;
    }

    /**
     * Build LWC data list for the Assessment Results section of the upgrade report
     */
    private static List<AssessmentResultItem> buildAssessmentResults(Assessment__c assessment) {
        List<AssessmentResultItem> assessmentResults = new List<AssessmentResultItem>();
        Set<String> availableAssessmentFields = Schema.Assessment__c.getSObjectType().getDescribe().fields.getMap().keySet();
        //prioritize and recommend SFDC native features
        for (SFDC_Feature__mdt fscFeature : SFDC_Feature__mdt.getAll().values()) {
            String featureLabel = ToolingService.customLabelMap.get(Utilities.namespaceUnderscore+fscFeature.Custom_Label__c);
            String reasonLabel = ToolingService.customLabelMap.get(Utilities.namespaceUnderscore+fscFeature.Reason_Label__c);

            //default rollout priority and reason
            String priority = 'Low';
            String reasonText = Label.FeatureReasonDefault;//ToolingService.customLabelMap.get(Utilities.namespaceUnderscore+'FeatureReasonDefault');

            //detect result criteria fields
            if (String.isNotBlank(fscFeature.Assessment_Result_Fields__c)) {
                String[] fieldApiNames = fscFeature.Assessment_Result_Fields__c.split(',');
                for (String fieldApiName : fieldApiNames) {
                    fieldApiName = Utilities.namespaceUnderscore+fieldApiName;
                    if (availableAssessmentFields.contains(fieldApiName.toLowerCase())) {
                        //detect a populated field or true value
                        Object fieldValue = assessment.get(fieldApiName);
                        if (fieldValue != null && fieldValue instanceOf Boolean && Boolean.valueOf(fieldValue) ||
                            String.isNotBlank(String.valueOf(fieldValue)) && !(fieldValue instanceOf Boolean)) {

                            //set specified pritority and reason
                            priority = fscFeature.Priority__c;
                            reasonText = String.isNotBlank(reasonLabel) ? reasonLabel : reasonText;
                            break;
                        }
                    }
                }
            }

            AssessmentResultItem fdl = new AssessmentResultItem(featureLabel, priority);
            fdl.reasonText = reasonText;
            fdl.replaceWithFscUrl = fscFeature.Documentation_URL__c;
            assessmentResults.add(fdl);
        }
        assessmentResults.sort();
        return assessmentResults;
    }

    /**
     * Build LWC data list for the Org Sharing Settings section of the upgrade report
     */
    @TestVisible
    private static List<MigrationAnalysisItem> buildSharingSettingResults(Assessment__c assessment, Map<String, String> sourceToDestinationObject, Set<String> mappedObjects) {
        List<MigrationAnalysisItem> analysisItems = new List<MigrationAnalysisItem>();

        List<String> mappedObjectList = new List<String>();
        mappedObjectList.addAll(mappedObjects);
        System.debug(mappedObjects);

        ExternalUtilities.ExternalSchema metadataMap = ExternalUtilities.executeMetadataRead('SharingRules', mappedObjectList);

        Map<String, Map<String, String> > customObjectToApexSharingReasons = getApexSharingReasons( mappedObjects );

        for(EntityDefinition entityDefinition : getEntityDefinitions(mappedObjects)){
            MigrationAnalysisItem analysisItem = new MigrationAnalysisItem();
            analysisItem.fromComponentName = entityDefinition.Label;
            analysisItem.fromComponentType = 'Sharing Setting';
            analysisItem.fromComponentInternalSharing = getSharingSettingLabel(entityDefinition.InternalSharingModel);
            analysisItem.fromComponentExternalSharing = getSharingSettingLabel(entityDefinition.ExternalSharingModel);
            analysisItem.toComponentName = sourceToDestinationObject.get(entityDefinition.QualifiedApiName);

            List<MigrationAnalysisItem> childItems = getParsedSharingRuleItems(entityDefinition.QualifiedApiName, metadataMap);
            analysisItem.children = new List<MigrationAnalysisItem>();
            analysisItem.children.addAll(childItems);

            String shareObjectApiName = entityDefinition.QualifiedApiName.replace('__c','__share');
            List<MigrationAnalysisItem> apexSharingChildItems = getParsedApexSharingReasonItems( customObjectToApexSharingReasons.get( shareObjectApiName ) );
            analysisItem.children.addAll( apexSharingChildItems );

            analysisItems.add(analysisItem);
        }

        if(String.isNotBlank(assessment.ApexShareAnalysisJSON__c)){
            List<MigrationAnalysisItem> apexAnalysisItems = (List<MigrationAnalysisItem>)JSON.deserialize(assessment.ApexShareAnalysisJSON__c, List<MigrationAnalysisItem>.class);
            analysisItems.addAll(apexAnalysisItems);
        }


        return analysisItems;
    }

    public static Map<String, Map<String, String> > getApexSharingReasons( Set<String> sourceObjects ) {
        Map<String, Map<String, String> > sharingReasonMap = new Map<String, Map<String, String> >();
        Set<String> customObjects = new Set<String>();

        //Filter list to have only Custom Objects
        for ( String objectApiName : sourceObjects ) {
            if ( objectApiName.endsWith( '__c' ) ) {
                customObjects.add( objectApiName );
            }
        }

        //Grab the Picklist Entries for the Share object variant of the Custom Object. The entries contain the Apex Sharing
        // Reason with a __c suffix.
        for ( String customObject : customObjects ) {
            String shareObjectApiName = customObject.replace( '__c', '__share' );

            if ( SchemaService.GLOBAL_DESCRIBE.containsKey( shareObjectApiName ) ) {
                if( SchemaService.getFieldMap(shareObjectApiName).containsKey('RowCause')){
                    List<Schema.PicklistEntry> entries = SchemaService.getPicklistValues( shareObjectApiName, 'RowCause' );

                    //Find the Apex Sharing Reasons
                    for ( Schema.PicklistEntry entry : entries ) {
                        String entryValue = entry.getValue();

                        if ( entryValue.endsWith( '__c' ) ) {
                            if ( !sharingReasonMap.containsKey( shareObjectApiName ) ) {
                                sharingReasonMap.put( shareObjectApiName, new Map<String, String>() );
                            }

                            sharingReasonMap.get( shareObjectApiName ).put( entry.getLabel(), entry.getValue() );
                        }
                    }
                }
            }
        }

        return sharingReasonMap;
    }

    private static List<MigrationAnalysisItem> getParsedSharingRuleItems(String sObjectApiName, ExternalUtilities.ExternalSchema metadataMap){
        List<MigrationAnalysisItem> sharingCriteriaRuleItems = new List<MigrationAnalysisItem>();

        String sharingCriteriaRuleKey = sObjectApiName+'.sharingCriteriaRules';
        String sharingOwnerRuleKey = sObjectApiName+'.sharingOwnerRules';

        for(SchemaService.SharingCriteriaRule criteriaRule : parseCriteriaRules(sharingCriteriaRuleKey, metadataMap.get(sharingCriteriaRuleKey))){
            MigrationAnalysisItem analysisItem = new MigrationAnalysisItem();
            analysisItem.fromComponentName = criteriaRule.label;
            analysisItem.fromComponentType = 'Sharing Criteria Rule';
            analysisItem.reasonText = Label.SharingRuleReimplement;
            sharingCriteriaRuleItems.add(analysisItem);
        }

        for(SchemaService.SharingCriteriaRule ownerRule : parseCriteriaRules(sharingOwnerRuleKey, metadataMap.get(sharingOwnerRuleKey))){
            MigrationAnalysisItem analysisItem = new MigrationAnalysisItem();
            analysisItem.fromComponentName = ownerRule.label;
            analysisItem.fromComponentType = 'Sharing Owner Rule';
            analysisItem.reasonText = Label.SharingRuleReimplement;

            sharingCriteriaRuleItems.add(analysisItem);
        }


        return sharingCriteriaRuleItems;
    }

    private static List<MigrationAnalysisItem> getParsedApexSharingReasonItems( Map<String, String> apexSharingReasons ) {
        List<MigrationAnalysisItem> apexSharingReasonItems = new List<MigrationAnalysisItem>();

        if ( apexSharingReasons == null || apexSharingReasons.isEmpty() ) {
            return apexSharingReasonItems;
        }

        for ( String sharingReasonLabel : apexSharingReasons.keyset() ) {
            MigrationAnalysisItem analysisItem = new MigrationAnalysisItem();

            analysisItem.fromComponentName = String.format( '{0} ({1})', new List<String> {
                sharingReasonLabel,
                apexSharingReasons.get( sharingReasonLabel )
            } );
            analysisItem.fromComponentType = 'Apex Sharing Reason';
            analysisItem.reasonText = Label.SharingSettingsCDSReason;
            apexSharingReasonItems.add( analysisItem );
        }

        return apexSharingReasonItems;
    }

    public static void queryForSharingReasonsAsync(Id assessmentId, Map<String, Map<String, String>> customObjectToApexSharingReasons){
        List<ApexShareRecordQueryQueueable.QueryCriteria> criteria = new List<ApexShareRecordQueryQueueable.QueryCriteria>();

        for( String sObjectApiName : customObjectToApexSharingReasons.keySet() ){
            ApexShareRecordQueryQueueable.QueryCriteria criteriaItem = new ApexShareRecordQueryQueueable.QueryCriteria(sObjectApiName, customObjectToApexSharingReasons.get(sObjectApiName).values());
            criteria.add(criteriaItem);
        }

        if(!criteria.isEmpty()){
            System.enqueueJob(new ApexShareRecordQueryQueueable(assessmentId,criteria));
        } else {
            AssessmentService.updateAssessment(new Assessment__c(Id = assessmentId, Apex_Sharing_Scan_Complete__c = true));
        }
    }

    public static String getSharingSettingLabel(String value){
        if( SHARING_VALUE_TO_LABEL.containsKey(value)){
            return SHARING_VALUE_TO_LABEL.get(value);
        }
        //Return RAW value so we can catch it in UI and update map
        return value;
    }

    private static List<SchemaService.SharingCriteriaRule> parseCriteriaRules(String key, Object metadataObject){
        List<SchemaService.SharingCriteriaRule> criteriaRules = new List<SchemaService.SharingCriteriaRule>();

        if( metadataObject instanceof List<Object>){

            System.debug(metadataObject);
            List<SchemaService.SharingCriteriaRule> rules = (List<SchemaService.SharingCriteriaRule>)JSON.Deserialize(JSON.serialize(metadataObject), List<SchemaService.SharingCriteriaRule>.class);
            if(rules != null){
                criteriaRules.addAll(rules);
            }

        } else {

            SchemaService.SharingCriteriaRule criteriaRule = (SchemaService.SharingCriteriaRule)JSON.Deserialize(JSON.serialize(metadataObject), SchemaService.SharingCriteriaRule.class);

            if(criteriaRule != null){
                System.debug(criteriaRule);
                criteriaRules.add(criteriaRule);
            }
        }

        return criteriaRules;
    }

    public static List<EntityDefinition> getEntityDefinitions(Set<String> sObjectDeveloperNames) {
        return [SELECT Label, DeveloperName, QualifiedApiName, ExternalSharingModel, InternalSharingModel FROM EntityDefinition WHERE QualifiedApiName IN :sObjectDeveloperNames];
    }

    /**
     * Build LWC Tree Grid data list for the Migration Analysis section of the upgrade report
     * THIS LOGIC IS DUPLICATED IN HEROKU FOR LARGE ORGS DO NOT MODIFY WITHOUT KEEPING THAT IN SYNC
     */
    private static List<MigrationAnalysisItem> buildAnalysisTree(List<DependencyHelper.MetadataComponent> dependencies) {

        List<MigrationAnalysisItem> migrationAnalysis = new List<MigrationAnalysisItem>();

        //build tree and loop dependencies
        for (DependencyHelper.MetadataComponent componentDependency : dependencies) {
            MigrationAnalysisItem item = new MigrationAnalysisItem();
            item.fromComponentId = componentDependency.componentId;
            item.fromComponentName = componentDependency.componentLongname;
            item.fromComponentType = componentDependency.componentType;
            item.fromComponentUrl = componentDependency.componentUrl;
            //recurse children
            item.children = buildAnalysisTree(componentDependency.dependencies);
            migrationAnalysis.add(item);
        }

        migrationAnalysis.sort();

        return migrationAnalysis;
    }

    /**
     * Adjust Migration Analysis list to parent Custom Object over all child dependent component types
     * and perform additional API calls and query for mapping missing dependencies from Dependency API to Objects
     */
    private static List<MigrationAnalysisItem> buildMissingRelationships(List<MigrationAnalysisItem> migrationAnalysis, MappingService.MappedComponents userMapping) {
        Map<String, MigrationAnalysisItem> objectNameObject = new Map<String, MigrationAnalysisItem>();
        Map<String, MigrationAnalysisItem> componentNameToItem = new Map<String, MigrationAnalysisItem>();
        Map<String, String> objectIdToInternalName = new Map<String, String>();
        Map<String, String> objectNameToId = new Map<String, String>();
        List<String> layoutNames = new List<String>();
        List<String> objectNames = new List<String>();

        //prepare user mapped objects for fetching related items
        //Use object id from Tooling API
        Map<String,String> allCustomObjectNameIdMap = ToolingService.customObjectNameIdMap;
        for (String sourceObjectName : userMapping.mappedObjects) {
            objectNames.add(sourceObjectName);
            if (sourceObjectName.endsWith('__c')) {
                //get object id for custom objects from Tooling API
                String objectInternalName = sourceObjectName.replace('__c','');
                String objectId = allCustomObjectNameIdMap.get(objectInternalName);
                if (String.isNotBlank(objectId)) {
                    objectIdToInternalName.put(objectId, objectInternalName);
                    objectNameToId.put(sourceObjectName, objectId);
                }
            } else {
                //standard object name is id
                objectIdToInternalName.put(sourceObjectName, sourceObjectName);
                objectNameToId.put(sourceObjectName, sourceObjectName);
            }
        }

        for (MigrationAnalysisItem analysisItem : migrationAnalysis) {
            if (analysisItem.fromComponentType == DependencyHelper.TYPE_CUSTOM_OBJECT) {
                objectNameObject.put(analysisItem.fromComponentName, analysisItem);
                objectIdToInternalName.put(analysisItem.fromComponentId, analysisItem.fromComponentName);
                objectNameToId.put(analysisItem.fromComponentName + '__c', analysisItem.fromComponentId);
            } else if (analysisItem.fromComponentType == DependencyHelper.TYPE_STANDARD_OBJECT) {
                objectNameObject.put(analysisItem.fromComponentName, analysisItem);
                objectIdToInternalName.put(analysisItem.fromComponentId, analysisItem.fromComponentName);
                objectNameToId.put(analysisItem.fromComponentName, analysisItem.fromComponentId);
            } else if (analysisItem.fromComponentType == 'Layout') {
                layoutNames.add(analysisItem.fromComponentName);
                componentNameToItem.put(analysisItem.fromComponentName, analysisItem);
            } else {
                componentNameToItem.put(analysisItem.fromComponentName, analysisItem);
            }
        }

        //describe additional components each object
        if (!layoutNames.isEmpty()) {
            addObjectDependencies(DependencyHelper.getLayouts(layoutNames), objectIdToInternalName, objectNameObject, componentNameToItem, userMapping.sourceToDestinationObject); //Tooling API
        }
        if (!objectNames.isEmpty()) {
            addObjectDependencies(DependencyHelper.getObjectCompactLayouts(objectNames), objectIdToInternalName, objectNameObject, componentNameToItem, userMapping.sourceToDestinationObject); //Tooling API
            addObjectDependencies(DependencyHelper.getObjectFieldSets(objectNames), objectIdToInternalName, objectNameObject, componentNameToItem, userMapping.sourceToDestinationObject); //Schema describe + Tooling API
            addObjectDependencies(DependencyHelper.getObjectRecordTypes(objectNames), objectIdToInternalName, objectNameObject, componentNameToItem, userMapping.sourceToDestinationRecordType); //SOQL
            addObjectDependencies(DependencyHelper.getObjectListViews(objectNames), objectIdToInternalName, objectNameObject, componentNameToItem, userMapping.sourceToDestinationObject); //SOQL
            addObjectDependencies(DependencyHelper.getObjectApprovals(objectNames), objectIdToInternalName, objectNameObject, componentNameToItem, userMapping.sourceToDestinationObject); //SOQL
            addObjectDependencies(DependencyHelper.getObjectValidationRules(objectNames), objectIdToInternalName, objectNameObject, componentNameToItem, userMapping.sourceToDestinationObject); //Tooling API
            addObjectDependencies(DependencyHelper.getObjectProcessFlows(objectNames), objectIdToInternalName, objectNameObject, componentNameToItem, userMapping.sourceToDestinationObject); //Tooling API + Metadata API
        }
        if (!objectNameToId.isEmpty()) {
            addObjectDependencies(DependencyHelper.getObjectWorkflows(objectNameToId), objectIdToInternalName, objectNameObject, componentNameToItem, userMapping.sourceToDestinationObject); //Tooling API + Metadata API
            addObjectDependencies(DependencyHelper.getReportInfo(objectNameToId, userMapping.sourceToDestinationObject), objectIdToInternalName, objectNameObject, componentNameToItem, userMapping.sourceToDestinationObject); //SOQL + Metadata API
        }

        //reparent other child components back to object level children
        //Set<String> processedNames = new Set<String>();
        for (String objectName : objectNameObject.keySet()) {
            MigrationAnalysisItem objectItem = objectNameObject.get(objectName);

            //remove and skip unmapped objects
            if (/*String.isBlank(objectItem.toComponentName) || */!userMapping.sourceToDestinationObject.containsKey(objectItem.fromComponentName)) {
                objectNameObject.remove(objectName);
                continue;
            }
            //add grandchildren from delta list
            for (MigrationAnalysisItem objectChild : objectItem.children) {
                //System.debug('Processing '+objectItem.fromComponentName+' Child: ' + objectChild.fromComponentType + '-' + objectChild.fromComponentName);
                if (componentNameToItem.containsKey(objectChild.fromComponentName)) {
                    //System.debug('Found Matching Child Append Children: ' + componentNameToItem.get(objectChild.fromComponentName).children);
                    //objectChild.children = componentNameToItem.get(objectChild.fromComponentName).children;
                    objectChild.children.addAll(componentNameToItem.get(objectChild.fromComponentName).children);
                    objectChild.children.sort();
                    /*for (MigrationAnalysisItem existingGrandChild : componentNameToItem.get(objectChild.fromComponentName).children) {
                        for (MigrationAnalysisItem grandChild : objectChild.children) {
                            if (existingGrandChild.uuid != grandChild.uuid) {
                                objectChild.children.add(existingGrandChild);
                                break;
                            }
                        }
                    }*/
                    //processedNames.add(objectChild.fromComponentName);
                }
                //objectChild.fromComponentName += ' ('+objectChild.children.size()+')';
            }
            objectItem.children.sort();
            //objectItem.fromComponentName += ' ('+objectItem.children.size()+')';
        }

        //process remaining items
        /*for (String itemName : componentNameToItem.keySet()) {
            MigrationAnalysisItem otherItem = componentNameToItem.get(itemName);
            //remove duplicate listed items that were reparented
            if (processedNames.contains(itemName)) {
                componentNameToItem.remove(itemName);
                processedNames.remove(itemName);
            }
        }*/

        //build and return final list
        List<MigrationAnalysisItem> returnList = new List<MigrationAnalysisItem>(objectNameObject.values());
        //returnList.addAll(componentNameToItem.values());
        return returnList;
    }

    /**
     * Group dependencies to the objects they belong to and append to referenced collections
     */
    private static void addObjectDependencies(List<ToolingService.MetadataComponentDependency> dependencies,
                                           Map<String, String> objectIdToName,
                                           Map<String, MigrationAnalysisItem> objectNameObject,
                                           Map<String, MigrationAnalysisItem> componentNameToItem,
                                           Map<String,String> sourceToDestinationObject) {
        //group component dependencies into each object
        for (ToolingService.MetadataComponentDependency componentToObject : dependencies) {
            //determine referened object name
            String referencedComponentName = componentToObject.RefMetadataComponentName.startsWith('01I') ?
                                objectIdToName.get(componentToObject.RefMetadataComponentName) :
                                componentToObject.RefMetadataComponentName.replace('__c', '');
            MigrationAnalysisItem relatedComponent = componentNameToItem.get(componentToObject.MetadataComponentName);
            MigrationAnalysisItem existingParent = objectNameObject.get(referencedComponentName);
            //Create parent new if missing
            if (existingParent == null) {
                existingParent = new MigrationAnalysisItem();
                existingParent.fromComponentType = componentToObject.RefMetadataComponentType;
                existingParent.fromComponentName = componentToObject.RefMetadataComponentName.replace('__c', '');
                existingParent.fromComponentId = componentToObject.RefMetadataComponentId;
                existingParent.toComponentName = sourceToDestinationObject.containsKey(componentToObject.RefMetadataComponentName) ?
                sourceToDestinationObject.get(componentToObject.RefMetadataComponentName) :
                componentToObject.RefMetadataComponentName;
            }
            //rebuild url using new information of object name and id not always in DAPI
            existingParent.fromComponentUrl = new DependencyHelper.MetadataComponent(componentToObject.RefMetadataComponentName, componentToObject.RefMetadataComponentName, existingParent.fromComponentType, componentToObject.RefMetadataComponentId, existingParent.fromComponentName, null).componentUrl;

            //this is a new dependency we are adding that wasn't in previous list
            if (relatedComponent == null) {
                relatedComponent = new MigrationAnalysisItem();
                relatedComponent.fromComponentName = componentToObject.MetadataComponentName;
                relatedComponent.fromComponentType = componentToObject.MetadataComponentType;
                relatedComponent.fromComponentId = componentToObject.MetadataComponentId;
                if (componentToObject.MetadataComponentType == DependencyHelper.TYPE_RECORD_TYPE) {
                    String destinationRecordType = sourceToDestinationObject.get(existingParent.fromComponentName+'.'+relatedComponent.fromComponentName);
                    if (String.isNotBlank(destinationRecordType)) {
                        relatedComponent.toComponentName = destinationRecordType.split('\\.')[1];
                    }
                } else {
                    relatedComponent.toComponentName = sourceToDestinationObject.get(relatedComponent.fromComponentName);
                }
            }
            //rebuild url using new information of object name and id not always in DAPI
            relatedComponent.fromComponentUrl = new DependencyHelper.MetadataComponent(componentToObject.RefMetadataComponentName, componentToObject.RefMetadataComponentName, relatedComponent.fromComponentType, componentToObject.MetadataComponentId, relatedComponent.fromComponentName, componentToObject.MetadataComponentNamespace).componentUrl;

            //append to collections
            Boolean hasExisting = false;
            for (MigrationAnalysisItem existingChild : existingParent.children) {
                if (existingChild.fromComponentName == relatedComponent.fromComponentName) {
                    existingChild.children.addAll(relatedComponent.children);
                    hasExisting = true;
                    break;
                }
            }
            if (!hasExisting) {
                existingParent.children.add(relatedComponent);
            }
            if (existingParent.fromComponentType == DependencyHelper.TYPE_CUSTOM_OBJECT ||
                existingParent.fromComponentType == DependencyHelper.TYPE_STANDARD_OBJECT) {
                objectNameObject.put(existingParent.fromComponentName, existingParent);
            } else {
                componentNameToItem.put(componentToObject.MetadataComponentName, relatedComponent);
                //componentNameToItem.put(existingParent.fromComponentName, existingParent);
            }
            //todo adjust how this map is removing items we are losing MetadataComponentName Test_View -> RefMetadataComponentName New_Test_View_Report_bij (top item)
            if (objectNameObject.get(referencedComponentName) == null) {
                //componentNameToItem.put(existingParent.fromComponentName, existingParent);
            } else {
                //componentNameToItem.remove(componentToObject.MetadataComponentName);
            }
            componentNameToItem.remove(componentToObject.MetadataComponentName);
        }
    }

    /**
     * Adjust grouping Migration Analysis list for adding layer of each component type before listing the components
     */
    private static List<MigrationAnalysisItem> buildTypeGrouping(List<MigrationAnalysisItem> migrationAnalysis, MappingService.MappedComponents userMapping) {

        for (MigrationAnalysisItem item : migrationAnalysis) {
            item.reasonText = getComponentTypeRecommendation(item.fromComponentType).text;
            if (item.fromComponentType == DependencyHelper.TYPE_CUSTOM_OBJECT || item.fromComponentType == DependencyHelper.TYPE_STANDARD_OBJECT) {
                String objectDeveloperName = (item.fromComponentType == DependencyHelper.TYPE_CUSTOM_OBJECT ? item.fromComponentName+'__c' : item.fromComponentName);
                String objectId = (item.fromComponentType == DependencyHelper.TYPE_CUSTOM_OBJECT ? ToolingService.customObjectNameIdMap.get(item.fromComponentName) : item.fromComponentName);
                item.fromComponentUrl = new DependencyHelper.MetadataComponent(objectId, objectDeveloperName, item.fromComponentType, item.fromComponentId, item.fromComponentName, null).componentUrl;
                item.toComponentName = userMapping.sourceToDestinationObject.get(item.fromComponentName);
                //contact to account B2C special handing recommendation
                if (item.fromComponentName == 'Contact' && item.toComponentName == 'Account') {
                    item.reasonText = Label.RecComponentTypeContactB2C;
                }
                //get children to group types
                Map<String, MigrationAnalysisItem> typeNodeMap = new Map<String, MigrationAnalysisItem>();
                for (MigrationAnalysisItem objChild : item.children) {
                    MigrationAnalysisItem typeNode = typeNodeMap.get(objChild.fromComponentType);
                    if (typeNode == null) {
                        typeNode = new MigrationAnalysisItem();
                        typeNode.fromComponentName = objChild.fromComponentType;
                        typeNode.fromComponentType = objChild.fromComponentType;
                        typeNode.fromComponentUrl = new DependencyHelper.MetadataComponent(objectId, objectDeveloperName, objChild.fromComponentType, null, objChild.fromComponentType, null).componentUrl;
                    }
                    objChild.fromComponentUrl = new DependencyHelper.MetadataComponent(objectId, objectDeveloperName, objChild.fromComponentType, objChild.fromComponentId, objChild.fromComponentName, null).componentUrl;
                    //objChild.reasonText = getComponentTypeRecommendation(objChild.fromComponentType).text;
                    typeNode.reasonText = getComponentTypeRecommendation(typeNode.fromComponentType).text;
                    typeNode.children.add(objChild);
                    typeNodeMap.put(typeNode.fromComponentType, typeNode);
                }
                for (MigrationAnalysisItem typeNode : typeNodeMap.values()) {
                    //convert type to label and add dependency count
                    typeNode.fromComponentName = DependencyHelper.getTypeLabel(typeNode.fromComponentName) + ' ('+typeNode.children.size()+')';
                    //set field mappings
                    for (MigrationAnalysisItem component : typeNode.children) {
                        for (MigrationAnalysisItem componentChild : component.children) {
                            if (componentChild.fromComponentType == DependencyHelper.TYPE_CUSTOM_FIELD) {
                                componentChild.toComponentName = userMapping.sourceToDestinationField.get(objectDeveloperName+'.'+componentChild.fromComponentName+'__c');
                            }
                        }
                    }
                }
                item.children.clear();
                item.children.addAll(typeNodeMap.values());
            }
        }
        return migrationAnalysis;
    }

    /**
     * Determine how to recommend each type of metadata component dependency
     */
    private static TransitionRecommendation getComponentTypeRecommendation(String componentType) {
        TransitionRecommendation recommendation = new TransitionRecommendation();

        switch on componentType {
            when 'AuraComponentBundle', 'AuraComponent' {
                recommendation.text = Label.RecComponentTypeAuraComponentBundle;
            }
            when 'ApexClass' {
                recommendation.text = Label.RecComponentTypeApexClass;
            }
            when 'ApexPage' {
                recommendation.text = Label.RecComponentTypeApexPage;
            }
            when 'ApexTrigger' {
                recommendation.text = Label.RecComponentTypeApexTrigger;
            }
            when 'CustomObject' {
                recommendation.text = Label.RecComponentTypeCustomObject;
            }
            when 'CustomField' {
                recommendation.text = Label.RecComponentTypeCustomField;
            }
            when 'FlexiPage' {
                recommendation.text = Label.RecComponentTypeFlexiPage;
            }
            when 'Flow' {
                recommendation.text = Label.RecComponentTypeFlow;
            }
            when 'StandardEntity' {
                recommendation.text = Label.RecComponentTypeStandardObject;
            }
            when 'WorkflowRule' {
                recommendation.text = Label.RecComponentTypeWorkflowRule;
            }
            when else {
                if (COMPONENT_TYPES_DEPLOYABLE.contains(componentType)) {
                    recommendation.text = String.format(Label.RecComponentTypeAutomateDefault, new List<Object>{DependencyHelper.getTypeLabel(componentType)});
                } else {
                    recommendation.text = String.format(Label.RecComponentTypeDefault, new List<Object>{DependencyHelper.getTypeLabel(componentType)});
                }
            }
        }

        return recommendation;
    }

    /**
     * Custom Exceptions
     */
    public class AnalysisException extends Exception {}


    /**
     * Wrappers for LWC
     */

    /**
     * Assessment Results section data list type
     */
    public class AssessmentResultItem implements Comparable {
        @AuraEnabled public String uuid;
        @AuraEnabled public String priority;
        @AuraEnabled public String reasonText;
        @AuraEnabled public String replaceWithFscUrl;
        @AuraEnabled public String replaceWithFsc;
        //@AuraEnabled public List<AssessmentResultItem> children;

        public AssessmentResultItem(String replaceWithFsc, String priority) {
            this.replaceWithFsc = replaceWithFsc;
            this.priority = priority;
            this.uuid = Utilities.uuid();
        }

        /*public void addChild(AssessmentResultItem child) {
            if (this.children == null) {
                this.children = new List<AssessmentResultItem>();
            }
            this.children.add(child);
        }*/

        public Integer compareTo(Object compareTo) {
            AssessmentResultItem compareToObj = (AssessmentResultItem)compareTo;
            Map<String,Integer> sortMap = new Map<String,Integer> {
                'High' => 1,
                'Medium' => 2,
                'Low' => 3
            };
            if (sortMap.get(priority) == sortMap.get(compareToObj.priority)) return 0;
            if (sortMap.get(priority) > sortMap.get(compareToObj.priority)) return 1;
            return -1;
        }
    }

    /**
     * Migration Analysis section tree grid data list type
     */
    public class MigrationAnalysisItem implements Comparable {
        @AuraEnabled public String uuid = Utilities.uuid();
        public String fromComponentId;
        @AuraEnabled public String fromComponentName;
        @AuraEnabled public String fromComponentType;
        @AuraEnabled public String fromComponentUrl;
        @AuraEnabled public String fromComponentInternalSharing;
        @AuraEnabled public String fromComponentExternalSharing;
        @AuraEnabled public String toComponentName;
        @AuraEnabled public String toComponentUrl;
        @AuraEnabled public String reasonText;
        @AuraEnabled public List<MigrationAnalysisItem> children = new List<MigrationAnalysisItem>();

        public Integer compareTo(Object compareTo) {
            MigrationAnalysisItem compareToObj = (MigrationAnalysisItem)compareTo;
            //compare component type
            Integer compareInt = fromComponentType.compareTo(compareToObj.fromComponentType);
            if (compareInt != 0) return compareInt;

            //compare by component name
            compareInt = fromComponentName.compareTo(compareToObj.fromComponentName);

            return compareInt;
        }
    }
}