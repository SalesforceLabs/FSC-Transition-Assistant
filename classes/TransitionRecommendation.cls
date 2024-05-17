/**
 * Define and execute actions for individual recommendations to make on an industry upgrade assessment
 */
public inherited sharing virtual class TransitionRecommendation extends TransitionRecommendationBase {

    //Recommendation Check values
    private static final IntMap LIMIT_MAP;
    static {
        LIMIT_MAP = new IntMap();
        for (SFDC_Limit__mdt limitMeta : SFDC_Limit__mdt.getAll().values()) {
            LIMIT_MAP.put(limitMeta.DeveloperName, Integer.valueOf(limitMeta.Value__c));
        }
    }
    private static final Integer ACCOUNT_HIERARCHY_WARN_THRESHOLD_PERCENT = LIMIT_MAP.get('AccountHierarchyWarnThresholdPercent', 0);
    private static final Integer RECORD_COUNT_HIGH_DATA_VOLUME_WARN = LIMIT_MAP.get('RecordCountHighVolume', 0);

    //Salesforce Limits
    private static final Integer CUSTOM_OBJECT_LIMIT = LIMIT_MAP.get('CustomObjectLimit', 0); //including managed packages
    private static final Integer CUSTOM_FIELD_LIMIT = LIMIT_MAP.get('CustomFieldLimitObject', 0); //800 max including managed packages
    private static final Integer CUSTOM_FIELD_LIMIT_ACTIVITIES = LIMIT_MAP.get('CustomFieldLimitActivity', 0); //20 professional edition -- support?
    private static final Integer LOOKUP_FIELD_LIMIT = LIMIT_MAP.get('CustomFieldLimitLookup', 0);
    private static final Integer LOOKUP_FIELD_LIMIT_ACTIVITIES_PER_OBJ = LIMIT_MAP.get('CustomFieldLimitLookupActivityPerObj', 0);
    private static final Integer MD_FIELD_LIMIT = LIMIT_MAP.get('CustomFieldLimitMasterDetail', 0);
    private static final Integer FK_FIELD_HARD_LIMIT = LIMIT_MAP.get('CustomFieldLimitForeignKeys', 0); //default 40 contact AE to increase to 50

    //FSC Package Stats
    //TODO could obtain and parse from ExternalUtilities.requestFSCObjectSchema(new List<String>{'Lead','Account', 'Contact', 'Opportunity', 'Task', 'Event'})
    private static final Integer FSC_FIELD_COUNT_LEAD = LIMIT_MAP.get('FSC_FieldCountLead', 9999);
    private static final Integer FSC_FIELD_COUNT_ACCOUNT = LIMIT_MAP.get('FSC_FieldCountAccount', 9999);
    private static final Integer FSC_FIELD_COUNT_CONTACT = LIMIT_MAP.get('FSC_FieldCountContact', 9999);
    private static final Integer FSC_FIELD_COUNT_OPPORTUNITY = LIMIT_MAP.get('FSC_FieldCountOpportunity', 9999);
    private static final Integer FSC_FIELD_COUNT_ACTIVITY = LIMIT_MAP.get('FSC_FieldCountActivity', 9999);
    private static final Integer FSC_FK_COUNT_LEAD = LIMIT_MAP.get('FSC_FieldCountLeadForeignKeys', 9999); //lookups account and contact
    private static final Integer FSC_FK_COUNT_ACCOUNT = LIMIT_MAP.get('FSC_FieldCountAccountForeignKeys', 9999); //lookup contact primary contact
    private static final Integer FSC_FK_COUNT_CONTACT = LIMIT_MAP.get('FSC_FieldCountContactForeignKeys', 9999); //lookup contact and user
    private static final Integer FSC_FK_COUNT_OPPORTUNITY = LIMIT_MAP.get('FSC_FieldCountOpportunityForeignKeys', 9999); //account, contact, user and financial account
    private static final Integer FSC_FK_COUNT_ACTIVITY = LIMIT_MAP.get('FSC_FieldCountActivityForeignKeys', 9999); //lookup Account for household

    private static final String MULTI_CURRENCY_OBJECT_NAME = 'CurrencyType';
    private static final String ACM_OBJECT_NAME = 'DatedConversionRate';


    private static final Map<String, Integer> STANDARD_OBJECT_FSC_LIMITS_MAP = new Map<String, Integer> {
        'Lead' => FSC_FIELD_COUNT_LEAD,
        'Account' => FSC_FIELD_COUNT_ACCOUNT,
        'Contact' => FSC_FIELD_COUNT_CONTACT,
        'Opportunity' => FSC_FIELD_COUNT_OPPORTUNITY
    };

    private static final Set<String> OBJECTS_CHECK_HIGH_VOLUME = new Set<String> {
        'Account',
        'Contact'
    };

    //Check for Einstein feature licenses
    private static final Set<String> FEATURE_LICENSE_KEYS = new Set<String> {
        'Einstein%'
    };

    //Check for Communities Users
    private static final Set<String> USER_LICENSE_KEYS = new Set<String> {
        'PID_Customer_Community%',
        'PID_Partner_Community%'
    };

    //Upgrade recommendation complexity thresholds
    //tbd may need some form fuzzy logic convert reasons to complexity values
    //TODO move config to custom metadata
    public static final Integer COMPLEXITY_THRESHOLD_BROWNFIELD_EASY = 2;
    public static final Integer COMPLEXITY_THRESHOLD_BROWNFIELD_COMPLEX = 4;
    public static final Integer COMPLEXITY_THRESHOLD_SCALE = 5; //values ranked 1-5

    public static final String OWD_CONTROLLED_BY_PARENT = 'ControlledByParent';

    public static final String SHARING_SETTINGS_RECOMMENDATION_TEXT = 'sharingSettingsCheck';
    public static final String SHARING_SETTINGS_APEX_SHARE_REASON = 'sharingSettingsHasApexSharing';
    public static final String SHARING_SETTINGS_CDS_REASON = 'sharingSettingsCDSReason';


    //Recommendation Actions
    public static Map<String,String> apexActionMap {
        get {
            if (apexActionMap == null) {
                StringMap textMap = new StringMap();
                //SFDC_Recommendation__mdt.getAll().values();
                for (SFDC_Recommendation__mdt recMeta : [SELECT DeveloperName, Recommendation_Apex__c FROM SFDC_Recommendation__mdt WHERE Recommendation_Apex__c != null]) {
                    textMap.put(recMeta.DeveloperName, Utilities.namespaceDot+recMeta.Recommendation_Apex__c);
                }
                apexActionMap = textMap.getMap();
            }
            return apexActionMap;
        }
        private set;
    }

    //Recommendation Texts
    public static Map<String,String> recommendTextMap {
        get {
            if (recommendTextMap == null) {
                StringMap textMap = new StringMap();
                for (SFDC_Recommendation__mdt recMeta : SFDC_Recommendation__mdt.getAll().values()) {
                    textMap.put(recMeta.DeveloperName, ToolingService.customLabelMap.get(Utilities.namespaceUnderscore+recMeta.Custom_Label__c));
                }
                recommendTextMap = textMap.getMap();
            }
            return recommendTextMap;
        }
        private set;
    }

    //managed packages with known limitations
    public static Map<String,ISV_Limitation_Warning__mdt> isvWarningMap {
        get {
            if (isvWarningMap == null) {
                isvWarningMap = new Map<String,ISV_Limitation_Warning__mdt>();
                for (ISV_Limitation_Warning__mdt isvWarningMeta : ISV_Limitation_Warning__mdt.getAll().values()) {
                    isvWarningMap.put(isvWarningMeta.Namespace__c.toLowerCase(), isvWarningMeta);
                }
            }
            return isvWarningMap;
        }
        private set;
    }

    //common custom objects that may cause conflicts
    public static Set<String> customObjectsToWarn {
        get {
            if (customObjectsToWarn == null) {
                customObjectsToWarn = new Set<String>();
                for (SFDC_Feature__mdt featureMeta : SFDC_Feature__mdt.getAll().values()) {
                    if (String.isNotBlank(featureMeta.Conflicting_Custom_Objects__c)) {
                        for (String objNameVal : featureMeta.Conflicting_Custom_Objects__c.split(',')) {
                            customObjectsToWarn.add(objNameVal.trim());
                        }
                    }
                }
            }
            return customObjectsToWarn;
        }
        private set;
    }

    //implement base method no logic needed here
    public virtual override TransitionRecommendation generate(Id assessmentId) { return this; }

    /**
     * Execute TransitionRecommendation action generate method via apex class name as string
     */
    public static TransitionRecommendation executeAction(Id assessmentId, String recommendationActionApexName) {
        TransitionRecommendation recommendation;
        Type apexType = Type.forName(recommendationActionApexName);
        if (apexType != null) {
            Object apexInstance = apexType.newInstance();
            if (apexInstance instanceOf TransitionRecommendation) {
                recommendation = ((TransitionRecommendation)apexInstance).generate(assessmentId);
            }
        }
        return recommendation;
    }

    /**
     * Execute all configured TransitionRecommendation actions
     */
    public static List<TransitionRecommendation> executeAllActions(Id assessmentId) {
        List<TransitionRecommendation> recommendations = new List<TransitionRecommendation>();
        for (String recommendationActionApexName : new Set<String>(apexActionMap.values())) {
            TransitionRecommendation rec = executeAction(assessmentId, recommendationActionApexName);
            //only add with populated values
            if (String.isNotBlank(rec.text) || (rec.reasons != null && !rec.reasons.isEmpty())) {
                recommendations.add(rec);
            }
        }
        return recommendations;
    }

    /**
     * String map force empty string when null
     */
    private class StringMap {
        private Map<String,String> textMap = new Map<String,String>();

        public void put(String key, String val) {
            textMap.put(key, val != null ? val : '');
        }

        private Map<String,String> getMap() {
            return textMap;
        }
    }

    /**
     * Integer map force 0 value when null and allow override when getting in Test mode
     */
    private class IntMap {
        private Map<String,Integer> intMap = new Map<String,Integer>();

        public Integer get(String key, Integer overrideTestVal) {
            return Test.isRunningTest() ? overrideTestVal : intMap.get(key);
        }

        public void put(String key, Integer val) {
            intMap.put(key, val != null ? val : 0);
        }
    }

    /**
     * Below are specific org checks and recommendation implementations
     */


    /**
     * SCAN ORG METADATA USAGE & LIMITS
     **/

    //Check Account Parent Id Usage (Hierarchy)
    public class CheckAccountHierarchy extends TransitionRecommendation {
        public override TransitionRecommendation generate(Id assessmentId) {

            Integer accountTotal = [SELECT COUNT() FROM Account];
            Integer accountHierarchyTotal = [SELECT COUNT() FROM Account WHERE ParentId != null];
            Decimal accountHierarchyUsage = accountTotal == 0 ? 0 : (accountHierarchyTotal / accountTotal) * 100;

            //set recommendation
            if (accountHierarchyUsage >= ACCOUNT_HIERARCHY_WARN_THRESHOLD_PERCENT) {
                this.complexity++;
                this.text = recommendTextMap.get('accountHierarchyUsageHigh');
                this.reasons.add(String.format(recommendTextMap.get('accountHierarchyUsageHighReason1'), new List<Object>{accountTotal}));
                this.reasons.add(String.format(recommendTextMap.get('accountHierarchyUsageHighReason2'), new List<Object>{accountHierarchyUsage}));
            }

            return this;
        }
    }

    //Check for Account Lookup/Master-Detail (custom Relationship Groups)
    public class CheckAccountRelations extends TransitionRecommendation {
        public override TransitionRecommendation generate(Id assessmentId) {

            Schema.DescribeSObjectResult objectDescribe = SchemaService.GLOBAL_DESCRIBE.get('Account').getDescribe();
            for (Schema.ChildRelationship childRelation : objectDescribe.getChildRelationships()) {
                if (childRelation.getChildSObject().getDescribe().isCustom()) {
                    //add rec reason for custom relation field
                    Schema.DescribeFieldResult fieldDescribe = childRelation.getField().getDescribe();
                    this.reasons.add(String.format(recommendTextMap.get('accountRelationsUsageReason'), new List<Object>{
                        childRelation.getChildSObject(),
                        fieldDescribe.getLabel() + ' ('+fieldDescribe.getName()+')',
                        (fieldDescribe.getRelationshipOrder() != null ? 'Master-Detail' : 'Lookup')
                    }));
                }
            }

            //set recommendation
            if (!this.reasons.isEmpty()) {
                this.complexity++;
                this.text = recommendTextMap.get('accountRelationsUsage');
            }

            return this;
        }
    }

    //Check for Account Roll-Up Summaries (custom Relationship Group Summaries)
    public class CheckAccountRollups extends TransitionRecommendation {
        public override TransitionRecommendation generate(Id assessmentId) {

            Map<String, Schema.SObjectField> accountFieldMap = SchemaService.GLOBAL_DESCRIBE.get('Account').getDescribe().fields.getMap();
            for (String fieldName : accountFieldMap.keySet()) {
                Schema.DescribeFieldResult fieldDescribe = accountFieldMap.get(fieldName).getDescribe();
                //Rollup Summary field
                if (fieldDescribe.isCustom() && fieldDescribe.isCalculated() && fieldDescribe.getCalculatedFormula() == null) {
                    this.reasons.add(String.format(recommendTextMap.get('accountRollupCalculationUsageReason'), new List<Object>{fieldDescribe.getName()}));
                }
            }

            //set recommendation
            if (!this.reasons.isEmpty()) {
                this.complexity++;
                this.text = recommendTextMap.get('accountRollupCalculationUsage');
            }

            return this;
        }
    }

    //check max limit custom fields post FSC install
    public class CheckCustomFieldLimits extends TransitionRecommendation {
        public override TransitionRecommendation generate(Id assessmentId) {
            //skip this scan logic if FSC is already installed
            if (TransitionReadinessUtility.getFscInstallationReadiness().hasPackage) { return this; }

            //Check for custom field limits on standard objects
            for (String standardObj : STANDARD_OBJECT_FSC_LIMITS_MAP.keySet()) {
                Integer fieldCountRequired = STANDARD_OBJECT_FSC_LIMITS_MAP.get(standardObj);
                //check object field limits
                Schema.DescribeSObjectResult objectDescribe = SchemaService.GLOBAL_DESCRIBE.get(standardObj).getDescribe();
                Map<String, Schema.SObjectField> objectFieldMap = objectDescribe.fields.getMap();
                Integer customFieldCount = 0;
                for (String fieldName : objectFieldMap.keySet()) {
                    Schema.DescribeFieldResult fieldDescribe = objectFieldMap.get(fieldName).getDescribe();
                    if (fieldDescribe.isCustom()) {
                        customFieldCount++;
                    }
                }
                //make recommendation
                if(customFieldCount >= CUSTOM_FIELD_LIMIT - fieldCountRequired) {
                    this.text = recommendTextMap.get('objectTooManyFields');
                    Integer fieldsNeeded = customFieldCount - (CUSTOM_FIELD_LIMIT - fieldCountRequired);
                    this.reasons.add(String.format(recommendTextMap.get('objectTooManyFieldsReasonTotal'), new List<Object>{objectDescribe.getLabel(), customFieldCount, fieldsNeeded}));
                }
            }

            //check Activity field limits special handling
            Schema.DescribeSObjectResult eventDescribe = SchemaService.GLOBAL_DESCRIBE.get('Event').getDescribe();
            Schema.DescribeSObjectResult taskDescribe = SchemaService.GLOBAL_DESCRIBE.get('Task').getDescribe();
            Map<String, Schema.SObjectField> eventFieldMap = eventDescribe.fields.getMap();
            //Map<String, Schema.SObjectField> taskFieldMap = taskDescribe.fields.getMap();

            //callout obtain FSC schema info on what lookups will be added
            Integer customFieldCountFSCActivity = 0;
            Map<String,String> activityLookupFSCObjectNameLabel = new Map<String,String>();
            ExternalUtilities.ExternalSchema fscSchemaMap = ExternalUtilities.requestFSCObjectSchema(new List<String>{'Event'});
            if (fscSchemaMap != null) {
                List<Object> fieldDescribes = (List<Object>)fscSchemaMap.get('fields');
                if (fieldDescribes != null) {
                    for (Object fieldDescObj : fieldDescribes) {
                        Map<String,Object> fieldDescribe = (Map<String,Object>)fieldDescObj;
                        if (Boolean.valueOf(fieldDescribe.get('custom'))) {
                            customFieldCountFSCActivity++;
                            if (String.valueOf(fieldDescribe.get('type')) == 'reference') {
                                String activityLookupName = String.valueOf(fieldDescribe.get('label')) + ' (' + String.valueOf(fieldDescribe.get('name')) + ')';
                                for (Object refStringObj : (List<Object>)fieldDescribe.get('referenceTo')) {
                                    activityLookupFSCObjectNameLabel.put(String.valueOf(refStringObj), activityLookupName);
                                }
                            }
                        }
                    }
                }
            }

            Integer customFieldCount = 0;
            Map<String,Integer> objectLookupCountMap = new Map<String,Integer>();
            //Activity custom fields are listed on both Task and Event describes
            for (String fieldName : eventFieldMap.keySet()) {
                Schema.DescribeFieldResult fieldDescribe = eventFieldMap.get(fieldName).getDescribe();
                if (fieldDescribe.isCustom()) {
                    customFieldCount++;
                    if (String.isNotBlank(fieldDescribe.getRelationshipName())) {
                        String relatedObjName = fieldDescribe.getReferenceTo()[0].getDescribe().getName();
                        Integer lookupCount = objectLookupCountMap.get(relatedObjName);
                        if (lookupCount == null) { lookupCount = 0; }
                        objectLookupCountMap.put(relatedObjName, ++lookupCount);
                    }
                }
            }

            //make recommendation exceed field limit
            if(customFieldCount >= CUSTOM_FIELD_LIMIT_ACTIVITIES - customFieldCountFSCActivity) {
                this.text += String.format(recommendTextMap.get('objectTooManyFields'), new List<Object>{
                    'Activity (' + taskDescribe.getLabel() + ' + ' + eventDescribe.getLabel() + ')',
                    customFieldCountFSCActivity
                });
                this.reasons.add(String.format(recommendTextMap.get('objectTooManyFieldsReasonTotal'), new List<Object>{'Activity', customFieldCount, (CUSTOM_FIELD_LIMIT_ACTIVITIES - customFieldCountFSCActivity)}));
            }

            //make recommendation when exceed lookup limit
            for (String lookupObjName : objectLookupCountMap.keySet()) {
                Integer lookupCount = objectLookupCountMap.get(lookupObjName);
                if (activityLookupFSCObjectNameLabel.containsKey(lookupObjName) && lookupCount >= LOOKUP_FIELD_LIMIT_ACTIVITIES_PER_OBJ) {
                    this.text += String.format(recommendTextMap.get('activityTooManyLookups'), new List<Object>{
                        'Activity (' + taskDescribe.getLabel() + ' + ' + eventDescribe.getLabel() + ')',
                        LOOKUP_FIELD_LIMIT_ACTIVITIES_PER_OBJ
                    });
                    this.reasons.add(String.format(recommendTextMap.get('objectTooManyFieldsReasonTotal'), new List<Object>{'Activity', lookupCount, activityLookupFSCObjectNameLabel.get(lookupObjName)}));
                    this.reasons.add(String.format(recommendTextMap.get('activityTooManyLookupsReasonTotal'), new List<Object>{'Activity', LOOKUP_FIELD_LIMIT_ACTIVITIES_PER_OBJ}));
                    break;
                }
            }

            //determine complexity
            if (String.isNotBlank(this.text)) {
                this.complexity++;
                this.severity = SeverityLevel.CRITICAL;
            }

            return this;
        }
    }

    //check for multi-currency and advanced currency management
    public class CheckCurrencySettings extends TransitionRecommendation {
        public override TransitionRecommendation generate(Id assessmentId) {
            //Multi-Currency
            if(SchemaService.isObjectAvailable(MULTI_CURRENCY_OBJECT_NAME)){
                this.text = recommendTextMap.get('hasCurrencyFeaturesEnabled');
                this.reasons.add(recommendTextMap.get('multiCurrencyEnabled'));

                //Advanced Currency Management (DatedConversionRate can be inspected via REST API to detect enable/disable state)
                ExternalUtilities.ExternalSchema acmSchema = ExternalUtilities.requestOrgObjectSchema(new List<String>{ACM_OBJECT_NAME});
                if(acmSchema!=null){
                    Map<String, Object> convertedSchema = (Map<String, Object>) acmSchema.objectDescribeMap.get('DatedConversionRate');
                    Boolean describeValue = Boolean.valueOf(convertedSchema.get('createable'));
                    if(describeValue==true){
                        this.reasons.add(recommendTextMap.get('advancedCurrencyEnabled'));
                        this.severity = SeverityLevel.WARNING;
                        this.complexity++;
                    }
                }
            }
            return this;
        }
    }

    //check custom integrations with external systems
    public class CheckOutboundIntegrations extends TransitionRecommendation {
        public override TransitionRecommendation generate(Id assessmentId) {


            return this;
        }
    }

    //check for ISV unmanaged or managed package conflicts
    public class CheckISVPackageConflicts extends TransitionRecommendation {
        public override TransitionRecommendation generate(Id assessmentId) {

            //check unmanaged packages
            for (String warningObj : customObjectsToWarn) {
                if (SchemaService.GLOBAL_DESCRIBE.containsKey(warningObj)) {
                    this.text = recommendTextMap.get('customObjectConflict');
                    this.reasons.add(String.format(recommendTextMap.get('customObjectConflictReason'), new List<Object>{SchemaService.GLOBAL_DESCRIBE.get(warningObj).getDescribe().getLabel()}));
                }
            }

            //check managed packages
            for (PackageLicense pl : [SELECT NamespacePrefix FROM PackageLicense LIMIT 1000]) {
                String installedNamespace = pl.NamespacePrefix.toLowerCase();
                if (isvWarningMap.containsKey(installedNamespace)) {
                    ISV_Limitation_Warning__mdt isvWarningMeta = isvWarningMap.get(installedNamespace);
                    this.text = recommendTextMap.get('isvPackageConflict');
                    String isvWarning = ToolingService.customLabelMap.get(Utilities.namespaceUnderscore+isvWarningMeta.Custom_Label__c);
                    if (String.isNotBlank(isvWarning)) {
                        this.reasons.add(isvWarning);
                    } else {
                        this.reasons.add(String.format(recommendTextMap.get('isvPackageConflictReason'), new List<Object>{isvWarningMeta.MasterLabel}));
                    }
                }
            }

            //determine complexity
            if (String.isNotBlank(text)) {
                this.complexity++;
                this.severity = SeverityLevel.WARNING;
            }

            return this;
        }
    }

    //check for Salesforce licensed features Einstien, Communities, etc.
    public class CheckLicensedFeatures extends TransitionRecommendation {
        public override TransitionRecommendation generate(Id assessmentId) {

            List<UserLicense> userLicenseTypes = [
                SELECT LicenseDefinitionKey, MasterLabel, UsedLicenses, TotalLicenses
                FROM UserLicense
                WHERE UsedLicenses > 0
                    AND LicenseDefinitionKey LIKE :USER_LICENSE_KEYS
            ];

            List<PermissionSetLicense> featureLicenseTypes = [
                SELECT PermissionSetLicenseKey, MasterLabel, UsedLicenses, TotalLicenses
                FROM PermissionSetLicense
                WHERE UsedLicenses > 0
                    AND PermissionSetLicenseKey LIKE :FEATURE_LICENSE_KEYS
            ];

            for (UserLicense licenseType : userLicenseTypes) {
                this.reasons.add(String.format(recommendTextMap.get('hasLicensedFeatureReason'), new List<Object>{
                    licenseType.MasterLabel,
                    licenseType.UsedLicenses,
                    licenseType.TotalLicenses
                }));
            }

            for (PermissionSetLicense licenseType : featureLicenseTypes) {
                this.reasons.add(String.format(recommendTextMap.get('hasLicensedFeatureReason'), new List<Object>{
                    licenseType.MasterLabel,
                    licenseType.UsedLicenses,
                    licenseType.TotalLicenses
                }));
            }

            if (!this.reasons.isEmpty()) {
                this.text = recommendTextMap.get('hasLicensedFeature');
            }

            return this;
        }
    }

    public class CheckSharingConfiguration extends TransitionRecommendation {
        public override TransitionRecommendation generate(Id assessmentId){

            Assessment__c assessment = AssessmentService.queryAssessment(assessmentId);
            MappingService.UpgradeMapping mapping = MappingService.getExistingMapping(assessment);

            Set<String> objectsToQuery = new Set<String>();
            Map<String,String> sourceToDestinationObject = new Map<String,String>();

            Boolean sourceMappingHasCustomObject = false;

            if (mapping != null && mapping.recommended != null) {
                for (MappingService.ObjectMapping objectMapping : mapping.recommended) {
                    //collect mapped object
                    if (objectMapping.mappingData != null) {
                        for (MappingService.MappingSelection mappingData : objectMapping.mappingData) {
                            if (String.isNotBlank(mappingData.source) && String.isNotBlank(mappingData.destination)) {
                                sourceToDestinationObject.put(mappingData.source, mappingData.destination);
                                objectsToQuery.add(mappingData.source);
                            }
                        }
                    }
                }
            }

            if(assessment.Is_B2C__c){
                Organization org = [SELECT Id, DefaultAccountAccess, DefaultContactAccess FROM Organization WHERE Id = :UserInfo.getOrganizationId()];
                if(org.DefaultContactAccess != TransitionRecommendation.OWD_CONTROLLED_BY_PARENT){
                    this.reasons.add(recommendTextMap.get('sharingSettingsCheckPersonAccountReason'));
                }
            }

            if(assessment.Has_Apex_Sharing__c){
                this.complexity++;
                this.reasons.add(recommendTextMap.get(SHARING_SETTINGS_APEX_SHARE_REASON));
            }

            if(assessment.Has_Apex_Sharing_on_CDS_Object__c){
                this.complexity++;
                this.reasons.add(recommendTextMap.get(SHARING_SETTINGS_CDS_REASON));
            }

            List<EntityDefinition> entityDefinitions = TransitionAnalysis.getEntityDefinitions(objectsToQuery);
            Map<String, EntityDefinition> objectToEntityDefinition = new Map<String, EntityDefinition>();

            for(EntityDefinition entityDefinition : entityDefinitions){
                objectToEntityDefinition.put(entityDefinition.QualifiedApiName, entityDefinition);
            }

            for(String sourceObjectName : sourceToDestinationObject.keySet()){
                String destinationObjectName = sourceToDestinationObject.get(sourceObjectName);

                EntityDefinition sourceDefinition = objectToEntityDefinition.get(sourceObjectName);
                EntityDefinition destinationDefinition = objectToEntityDefinition.get(destinationObjectName);

                if(sourceDefinition == NULL){
                    //This is probably an FSC Object that is not yet installed in the org
                    continue;
                } else if(sourceDefinition == NULL && destinationDefinition == NULL){
                    //Source not mapped, and Destination not present
                    continue;
                } else if(
                    sourceDefinition != NULL
                    && destinationDefinition != NULL
                    && sourceDefinition.InternalSharingModel != destinationDefinition.InternalSharingModel
                    && sourceDefinition.Label != destinationDefinition.Label
                ){

                    this.reasons.add(String.format(recommendTextMap.get('sharingSettingsCheckMismatchReason'), new List<Object>{
                        sourceDefinition.Label,
                        TransitionAnalysis.getSharingSettingLabel(sourceDefinition.InternalSharingModel),
                        destinationDefinition.Label,
                        TransitionAnalysis.getSharingSettingLabel(destinationDefinition.InternalSharingModel)
                    }));
                }

                if(sourceDefinition.QualifiedApiName.endsWith('__c')){
                    sourceMappingHasCustomObject = true;
                }
            }

            if(sourceMappingHasCustomObject){
                this.complexity++;
                this.reasons.add(recommendTextMap.get('sharingSettingsCustomObjectReplacesStand'));
            }


            if (!this.reasons.isEmpty()) {
                this.text = recommendTextMap.get(SHARING_SETTINGS_RECOMMENDATION_TEXT);
            }

            return this;
        }
    }

    /**
     * SCAN ORG DATA USAGE & LIMITS
     **/

    //Check for 250M+ Account records or PK chunking needs AccountContactRelation
    public class CheckHighDataVolume extends TransitionRecommendation {
        public override TransitionRecommendation generate(Id assessmentId) {

            for (Schema.DescribeSObjectResult objectDescribe : Schema.describeSObjects(new List<String>(OBJECTS_CHECK_HIGH_VOLUME))) {
                if (Limits.getQueries() < Limits.getLimitQueries()) {
                    Integer recordCount = Database.countQuery('SELECT COUNT() FROM ' + objectDescribe.getName());
                    if (recordCount >= RECORD_COUNT_HIGH_DATA_VOLUME_WARN) {
                        this.severity = SeverityLevel.WARNING;
                        this.text = recommendTextMap.get('recordHighDataVolume');
                        this.reasons.add(String.format(recommendTextMap.get('recordHighDataVolumeReason'),  new List<Object>{String.valueOf(recordCount.format()), objectDescribe.getLabel()}));
                        if (objectDescribe.getName() == 'Contact') {
                            reasons.add(recommendTextMap.get('recordHighDataVolumeReasonContact'));
                            reasons.add(recommendTextMap.get('recordHighDataVolumeReasonStorage'));
                        }
                    }
                }
            }

            return this;
        }
    }

    //calculate potential storage overage after adding FSC junction objects and activity tracking

    //query record totals and usage dates detect stale objects
}