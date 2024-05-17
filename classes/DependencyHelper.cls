/**
 * The purpose of this class is to facilitate Dependency API queries and results processing
 */
public inherited sharing class DependencyHelper {

    public static final String TYPE_CUSTOM_OBJECT = 'CustomObject';
    public static final String TYPE_CUSTOM_FIELD = 'CustomField';
    public static final String TYPE_STANDARD_OBJECT = 'StandardEntity';
    public static final String TYPE_APEX_CLASS = 'ApexClass';
    public static final String TYPE_APEX_TRIGGER = 'ApexTrigger';
    public static final String TYPE_VISUALFORCE_PAGE = 'ApexPage';
    public static final String TYPE_EMAIL_TEMPLATE = 'EmailTemplate';
    public static final String TYPE_LIST_VIEW = 'ListView';
    public static final String TYPE_PAGE_LAYOUT = 'Layout';
    public static final String TYPE_COMPACT_LAYOUT = 'CompactLayout';
    public static final String TYPE_FIELD_SET = 'FieldSet';
    public static final String TYPE_LIGHTNING_PAGE = 'FlexiPage';
    public static final String TYPE_APPROVAL_PROCESS = 'ProcessDefinition';
    public static final String TYPE_EMAIL_ALERT = 'WorkflowAlert';
    public static final String TYPE_FLOW = 'Flow';
    public static final String TYPE_FIELD_UPDATE = 'WorkflowFieldUpdate';
    public static final String TYPE_OUTBOUND_MESSAGE = 'WorkflowOutboundMessage';
    public static final String TYPE_WOKFLOW_RULE = 'WorkflowRule';
    public static final String TYPE_WORKFLOW_TASK = 'WorkflowTask';
    public static final String TYPE_VALIDATION_RULE = 'ValidationRule';
    public static final String TYPE_PROFILE = 'Profile';
    public static final String TYPE_PERMISSION_SET = 'PermissionSet';
    public static final String TYPE_RECORD_TYPE = 'RecordType';  
    public static final String TYPE_REPORT = 'Report';
    public static final String TYPE_DASHBOARD = 'Dashboard';
    public static final String TYPE_REPORTTYPE = 'ReportType';    
    public static final String KEY_REPORTTYPE = 'reportType';

    private static final Map<String,String> TYPE_TO_LABEL = new Map<String,String> {
        //use getTypeLabel method for public access
        TYPE_CUSTOM_OBJECT => Label.TypeCustomObject,
        TYPE_STANDARD_OBJECT => Label.TypeStandardObject,
        TYPE_PAGE_LAYOUT => Label.TypePageLayout,
        TYPE_APPROVAL_PROCESS => Label.TypeApprovalProcess,
        TYPE_EMAIL_ALERT => Label.TypeEmailAlert,
        TYPE_OUTBOUND_MESSAGE => Label.TypeOutboundMessage,
        TYPE_LIGHTNING_PAGE => Label.TypeLightningPage,
        TYPE_VISUALFORCE_PAGE => Label.TypeVisualforcePage
    }; 

    private static final String DEPENDENCY_QUERY_TEMPLATE = 'SELECT {0} FROM MetadataComponentDependency';
    private static final List<String> DEPENDENCY_QUERY_FIELDS = new List<String>{
        'MetadataComponentId', 'MetadataComponentType', 'MetadataComponentName', 'MetadataComponentNamespace', 
        'RefMetadataComponentId', 'RefMetadataComponentType', 'RefMetadataComponentNamespace', 'RefMetadataComponentName'
    };

    private static final Set<String> FILTER_COMPONENT_TYPES_REGEX = new Set<String> {
        '.*__mdt$'/*, 'PermissionSetLicense', 'StandardEntity', 'User'*/
    };

    private static final Set<String> FILTER_COMPONENT_NAMES_REGEX = new Set<String> {
        'flexipage:.*'
    };

    public static final Integer LIMIT_MAX_RECORDS_TOOLING = 2000; //Dependency API Limit for Tooling

    @TestVisible
    static Map<String, Report> reportNameMap {
        get {
            if(reportNameMap == null) {
                reportNameMap = new Map<String, Report>();
                for (Report r : [
                    SELECT Id, FolderName, NamespacePrefix, DeveloperName
                    FROM Report
                    WHERE NamespacePrefix = null
                    LIMIT: (Limits.getLimitQueryRows() - Limits.getQueryRows())
                ]) {
                    //future state when namespaced reports are added group by developername to avoid syntax related issues
                    //ex: et4ae5__ExactTarget_Admin/et4ae5__Clicked
                    reportNameMap.put((r.FolderName != 'Public Reports' ? (r.FolderName + '/') : 'unfiled$public/') + r.DeveloperName, r);
                }
            }
            
            return reportNameMap;
        }
        set;
    }

    /**
     * Translate system type name to human readable label for given metadata component type
     */
    public static String getTypeLabel(String typeName) {
        return typeName == null ? null : 
                TYPE_TO_LABEL.containsKey(typeName) ? TYPE_TO_LABEL.get(typeName) : 
                String.join(typeName.splitByCharacterTypeCamelCase(),' ');
    }

    /**
     * Retreive org dependencies using the Dependency API via Tooling API query
     */
    public static List<ToolingService.MetadataComponentDependency> getAllDependencies() {
        return ToolingService.queryDependencies(
            String.format(DEPENDENCY_QUERY_TEMPLATE, new List<Object>{ String.join(DEPENDENCY_QUERY_FIELDS, ',') })
        );
    }

    /**
     * THIS LOGIC IS DUPLICATED IN HEROKU FOR LARGE ORGS DO NOT MODIFY WITHOUT KEEPING THAT IN SYNC
     * Process flat list of dependency references returned from Dependency API into a tree
     * for a top down representation of org dependencies
     */
    public static List<MetadataComponent> buildDependencyTree(List<ToolingService.MetadataComponentDependency> dependencyList) {
        Map<String, MetadataComponent> parentComponentMap = new Map<String, MetadataComponent>();
        for (ToolingService.MetadataComponentDependency dependency : dependencyList) {
            MetadataComponent currentParent;
            MetadataComponent child;
            if(dependency.RefMetadataComponentType == TYPE_CUSTOM_OBJECT || 
                dependency.RefMetadataComponentType == TYPE_STANDARD_OBJECT) {
                currentParent = new MetadataComponent(
                    dependency.RefMetadataComponentType, 
                    dependency.RefMetadataComponentId, 
                    dependency.RefMetadataComponentName, 
                    dependency.RefMetadataComponentNamespace
                );  
                child = new MetadataComponent(
                    dependency.MetadataComponentType,
                    dependency.MetadataComponentId, 
                    dependency.MetadataComponentName, 
                    dependency.MetadataComponentNamespace
                );
            }
            else {
                currentParent = new MetadataComponent(
                    dependency.MetadataComponentType,
                    dependency.MetadataComponentId, 
                    dependency.MetadataComponentName, 
                    dependency.MetadataComponentNamespace
                );
                child = new MetadataComponent(
                    dependency.RefMetadataComponentType, 
                    dependency.RefMetadataComponentId, 
                    dependency.RefMetadataComponentName, 
                    dependency.RefMetadataComponentNamespace
                );
            }
    
            if (doFilter(currentParent) || doFilter(child)) {
                continue;
            }

            MetadataComponent existingParent = parentComponentMap.get(currentParent.componentLongname);
            if(existingParent == null) {
                parentComponentMap.put(currentParent.componentLongname, currentParent);
            }
            else {
                currentParent = existingParent;
            }

            if(currentParent.childKeys.contains(child.componentLongname) == false) {
                currentParent.childKeys.add(child.componentLongname);
                currentParent.dependencies.add(child);
                child.parent = currentParent;
            }
        }

        return parentComponentMap.values();
    }

    /**
     * THIS LOGIC IS DUPLICATED IN HEROKU FOR LARGE ORGS DO NOT MODIFY WITHOUT KEEPING THAT IN SYNC
     * Return true if component should be filtered out of processing or results
     */
    private static Boolean doFilter(MetadataComponent component) {
        Boolean doFilter = false;
        //filter this package components out of subscriber org results
        if (String.isNotBlank(Utilities.namespace) && Utilities.namespace == component.componentNamespace) { 
            doFilter = true;
        }

        //filter specific component types
        if (!doFilter) {
            for (String regexPattern : FILTER_COMPONENT_TYPES_REGEX) {
                if (Pattern.matches(regexPattern, component.componentType)) {
                    doFilter = true;
                    break;
                }
            }
        }

        //filter specific component names
        if (!doFilter) {
            for (String regexPattern : FILTER_COMPONENT_NAMES_REGEX) {
                if (Pattern.matches(regexPattern, component.componentName)) {
                    doFilter = true;
                    break;
                }
            }
        }
        
        return doFilter;
    }

    /**
     * Below are methods to query additional component types not returned by the Dependency API
     */

    /**
     * Get Page Layouts via Tooling API
     */
    public static List<ToolingService.MetadataComponentDependency> getLayouts(List<String> layoutNames) {
        return getMissingDependencies(layoutNames, TYPE_PAGE_LAYOUT, 'Name', true);
    }

    /**
     * Get Page Layouts tied to Object Id via Tooling API
     */
    public static List<ToolingService.MetadataComponentDependency> getObjectLayouts(List<String> sObjectIds) {
        return getMissingDependencies(sObjectIds, TYPE_PAGE_LAYOUT, 'TableEnumOrId', true);
    }

    /**
     * Get Compact Layouts tied to Object Names via Tooling API
     */
    public static List<ToolingService.MetadataComponentDependency> getObjectCompactLayouts(List<String> sObjectNames) {
        return getMissingDependencies(sObjectNames, TYPE_COMPACT_LAYOUT, 'DeveloperName', 'SobjectType', true); //note case sensitivity in SobjectType
    }

    /**
     * Get List Views tied to Object Names via SOQL
     */
    public static List<ToolingService.MetadataComponentDependency> getObjectListViews(List<String> sObjectNames) {
        return getMissingDependencies(sObjectNames, TYPE_LIST_VIEW, 'SObjectType', false);
    }

    /**
     * Get Approval Process tied to Object Names via SOQL
     */
    public static List<ToolingService.MetadataComponentDependency> getObjectApprovals(List<String> sObjectNames) {
        return getMissingDependencies(sObjectNames, TYPE_APPROVAL_PROCESS, 'Name', 'TableEnumOrId', 'State = \'Active\'', false);
    }

    /**
     * Get Record Types tied to Object Names via SOQL
     */
    public static List<ToolingService.MetadataComponentDependency> getObjectRecordTypes(List<String> sObjectNames) {
        List<ToolingService.MetadataComponentDependency> existingRecordTypes = getMissingDependencies(sObjectNames, TYPE_RECORD_TYPE, 'DeveloperName', 'SObjectType', null/*'IsActive = true'*/, false);
        Map<String,List<ToolingService.MetadataComponentDependency>> objectNameToRecordTypes = new Map<String,List<ToolingService.MetadataComponentDependency>>();
        for (ToolingService.MetadataComponentDependency objectRecordTypeMcd : existingRecordTypes) {
            List<ToolingService.MetadataComponentDependency> objectTypeRefs = objectNameToRecordTypes.get(objectRecordTypeMcd.RefMetadataComponentName);
            if (objectTypeRefs == null) { objectTypeRefs = new List<ToolingService.MetadataComponentDependency>(); }
            objectTypeRefs.add(objectRecordTypeMcd);
            objectNameToRecordTypes.put(objectRecordTypeMcd.RefMetadataComponentName, objectTypeRefs);
        }
        for (String sObjectName : sObjectNames) {
            //add Master as a dependency when missing
            if(!objectNameToRecordTypes.containsKey(sObjectName)) {
                ToolingService.MetadataComponentDependency mcd = new ToolingService.MetadataComponentDependency();
                mcd.MetadataComponentName = 'Master';
                mcd.metadataComponentType = TYPE_RECORD_TYPE;
                mcd.RefMetadataComponentName = sObjectName;
                mcd.RefMetadataComponentType = sObjectName.endsWith('__c') || sObjectName.startsWith('01I') ? TYPE_CUSTOM_OBJECT : TYPE_STANDARD_OBJECT;
                existingRecordTypes.add(mcd);
            }
        }
        return existingRecordTypes;
    }

    /**
     * Get FieldSets tied to Object Names via Schema Describe
     */
    public static List<ToolingService.MetadataComponentDependency> getObjectFieldSets(List<String> sObjectNames) {
        List<ToolingService.MetadataComponentDependency> fieldSetDependencies = new List<ToolingService.MetadataComponentDependency>();
        List<Schema.DescribeSObjectResult> objectDescribes = Schema.describeSObjects(sObjectNames);
        
        //collect related field set names
        List<String> fieldSetNames = new List<String>();
        for (Schema.DescribeSObjectResult objectDescribe : objectDescribes) {
            String objectName = objectDescribe.getName();
            if (objectDescribe.fieldSets != null) {
                for (Schema.FieldSet fieldSet : objectDescribe.fieldsets.getMap().values()) {
                    fieldSetNames.add(fieldSet.getName());

                    //add dependency to parent object
                    ToolingService.MetadataComponentDependency fieldSetDependency = new ToolingService.MetadataComponentDependency();
                    fieldSetDependency.RefMetadataComponentId = objectName.endsWith('__c') ? ToolingService.customObjectNameIdMap.get(objectName.replace('__c', '')) : objectName;
                    fieldSetDependency.RefMetadataComponentType = objectName.endsWith('__c') ? TYPE_CUSTOM_OBJECT : TYPE_STANDARD_OBJECT;
                    fieldSetDependency.RefMetadataComponentName = objectName.replace('__c', '');
                    fieldSetDependency.MetadataComponentType = TYPE_FIELD_SET;
                    fieldSetDependency.MetadataComponentName = fieldSet.getName();
                    fieldSetDependencies.add(fieldSetDependency);
                    //add dependency for each field
                    for (Schema.FieldSetMember fieldMember : fieldSet.getFields()) {
                        fieldSetDependency = new ToolingService.MetadataComponentDependency();
                        fieldSetDependency.RefMetadataComponentType = TYPE_FIELD_SET;
                        fieldSetDependency.RefMetadataComponentName = fieldSet.getName();
                        fieldSetDependency.MetadataComponentType = fieldMember.getFieldPath().endsWith('__c') ? TYPE_CUSTOM_FIELD : 'StandardField';
                        fieldSetDependency.MetadataComponentName = fieldMember.getFieldPath();
                        fieldSetDependencies.add(fieldSetDependency);
                    }
                }
            }
        }
        
        Map<String,Id> fieldSetNameToId = new Map<String,Id>();
        if (!fieldSetNames.isEmpty()) {
            //get Id of field sets from Tooling API
            String toolingResponse = ExternalUtilities.executeToolingQuery('SELECT Id,DeveloperName FROM '+TYPE_FIELD_SET+' WHERE DeveloperName IN (\''+String.join(fieldSetNames, '\',\'') + '\')');
            if (String.isNotBlank(toolingResponse)) {
                Object toolingResponseGeneric = JSON.deserializeUntyped(toolingResponse);
                Map<String,Object> toolingResponseMap = (Map<String,Object>)toolingResponseGeneric;
                List<Object> records = (List<Object>)toolingResponseMap.get('records');
                if (records != null && !records.isEmpty()) {
                    for (Object recordObj : records) {
                        Map<String,Object> toolingObj = (Map<String,Object>)recordObj;
                        fieldSetNameToId.put((String)toolingObj.get('DeveloperName'), (Id)toolingObj.get('Id'));
                    }
                }
            }
        }

        //populate Id for URL linking
        for (ToolingService.MetadataComponentDependency mcd : fieldSetDependencies) {
            if (mcd.MetadataComponentType == TYPE_FIELD_SET) {
                mcd.MetadataComponentId = fieldSetNameToId.get(mcd.MetadataComponentName);
            } else if (mcd.RefMetadataComponentType == TYPE_FIELD_SET) {
                mcd.RefMetadataComponentId = fieldSetNameToId.get(mcd.RefMetadataComponentName);
            }
        }

        return fieldSetDependencies;
    }

    /**
     * Get Validation Rules tied to Object Names via Tooling API
     */
    public static List<ToolingService.MetadataComponentDependency> getObjectValidationRules(List<String> sObjectNames) {
        return getMissingDependencies(sObjectNames, TYPE_VALIDATION_RULE, 'ValidationName', 'EntityDefinitionId', 'Active = true', true);
    }

    /**
     * Get Reports, Report Types, Dashboards tied to Object Names via Metadata API
     */
    public static List<ToolingService.MetadataComponentDependency> getReportInfo(Map<String,String> objectIdMap, Map<String, String> sourceToDestinationObject) {
        List<ToolingService.MetadataComponentDependency> reportDependencyList = new List<ToolingService.MetadataComponentDependency>();
        if(reportNameMap.isEmpty()) { return reportDependencyList; }

        //Get dashboards
        Map<Id, List<DashboardComponent>> reportDashboardMap = Utilities.groupByIds(DashBoardComponent.CustomReportId, [
            SELECT CustomReportId, DashboardId, Dashboard.Title, Dashboard.NamespacePrefix
            FROM DashboardComponent
            WHERE Dashboard.NameSpacePrefix = null
            LIMIT: (Limits.getLimitQueryRows() - Limits.getQueryRows())
        ]);

        //Get metadata info on reports
        Map<String, Object> reportMetadataMap = ExternalUtilities.executeMetadataRead(TYPE_REPORT, new List<String>(reportNameMap.keySet())).objectDescribeMap;
        //Get report types and ids for report types
        Map<String, Object> reportTypeListMap = ExternalUtilities.executeMetadataList(TYPE_REPORTTYPE).objectDescribeMap;


        //Group report metadata by report type
        Map<String, List<Object>> reportMetadataByReportTypeMap = new Map<String, List<Object>>();
        for(String reportMetadataKey : reportMetadataMap.keySet()) {
            Map<String, Object> reportMetadata = (Map<String, Object>)reportMetadataMap.get(reportMetadataKey);
            String reportType = (String)reportMetadata.get(KEY_REPORTTYPE);
            if (String.isNotBlank(reportType)) {
                //Standard Report Type on Custom Object
                if (reportType.startsWith('CustomEntity$') && reportType.endsWith('__c')) {
                    String baseObject = reportType.split('\\$')[1];
                    //add dependency Report to Object if object mapped
                    if (sourceToDestinationObject.containsKey(baseObject.replace('__c', ''))) {
                        Report reportInfo = reportNameMap.get(((String)reportMetadata.get('fullName')));
                        ToolingService.MetadataComponentDependency reportDependency = new ToolingService.MetadataComponentDependency();
                        reportDependency.RefMetadataComponentId = objectIdMap.get(baseObject);
                        reportDependency.RefMetadataComponentType = baseObject.endsWith('__c') ? TYPE_CUSTOM_OBJECT : TYPE_STANDARD_OBJECT;
                        reportDependency.RefMetadataComponentName = baseObject;
                        reportDependency.MetadataComponentId = reportInfo.Id;
                        reportDependency.MetadataComponentType = TYPE_REPORT;
                        reportDependency.MetadataComponentName = reportInfo.DeveloperName;
                        reportDependencyList.add(reportDependency);
                    }
                } 
                //Custom Report Type map for processing report type
                else if(reportType.endsWith('__c')) {
                    String formattedReportType = reportType.removeEnd('__c');
                    List<Object> reportMetadataList = reportMetadataByReportTypeMap.get(formattedReportType);
                    if(reportMetadataList == null) { reportMetadataList = new List<Object>(); }
                    reportMetadataList.add(reportMetadataMap.get(reportMetadataKey));
                    reportMetadataByReportTypeMap.put(formattedReportType, reportMetadataList);
                }
            }
        }

        //Get report type metadata for reports
        Map<String, Object> reportTypeMetadataMap = ExternalUtilities.executeMetadataRead(TYPE_REPORTTYPE, new List<String>(reportMetadataByReportTypeMap.keySet())).objectDescribeMap;

        //Process custom report types starting at report type iterate through and build object dependencies
        for(String reportType : reportMetadataByReportTypeMap.keySet()) {
            Map<String, Object> reportTypeInfo = (Map<String, Object>)reportTypeMetadataMap.get(reportType);
            if(reportTypeInfo == null) continue;
            String baseObject = (String)reportTypeInfo.get('baseObject');
            //if report type isn't related to user mapped objects skip
            if(baseObject == null || sourceToDestinationObject.containsKey(baseObject.replace('__c', '')) == false || reportTypeListMap.get(reportType) == null) continue;
            
            String reportTypeId = (String)((Map<String, Object>)reportTypeListMap.get(reportType)).get('id');

            //dependency Report Type to Object
            ToolingService.MetadataComponentDependency reportTypeObjectDependency = new ToolingService.MetadataComponentDependency();
            reportTypeObjectDependency.RefMetadataComponentId = objectIdMap.get(baseObject);
            reportTypeObjectDependency.RefMetadataComponentType = baseObject.endsWith('__c') ? TYPE_CUSTOM_OBJECT : TYPE_STANDARD_OBJECT;
            reportTypeObjectDependency.RefMetadataComponentName = baseObject;
            reportTypeObjectDependency.MetadataComponentId = reportTypeId;
            reportTypeObjectDependency.MetadataComponentType = TYPE_REPORTTYPE;
            reportTypeObjectDependency.MetadataComponentName = reportType;
            reportDependencyList.add(reportTypeObjectDependency);

            List<Object> reportMetadataList = reportMetadataByReportTypeMap.get(reportType);
            if(reportMetadataList == null) continue;

            for(Object reportMetadata : reportMetadataList) {
                String reportFullName = (String)((Map<String, Object>)reportMetadata).get('fullName');
                if(reportFullName == null) continue;
                Report reportInfo = reportNameMap.get(reportFullName);
                if(reportInfo == null) continue;
                //dependency report type to report
                ToolingService.MetadataComponentDependency reportTypeDependency = new ToolingService.MetadataComponentDependency();
                reportTypeDependency.RefMetadataComponentId = reportInfo.Id;
                reportTypeDependency.RefMetadataComponentType = TYPE_REPORT;
                reportTypeDependency.RefMetadataComponentName = reportInfo.DeveloperName;
                reportTypeDependency.MetadataComponentId = reportTypeId;
                reportTypeDependency.MetadataComponentType = TYPE_REPORTTYPE;
                reportTypeDependency.MetadataComponentName = reportType;
                reportDependencyList.add(reportTypeDependency);
                //dependency report to parent object
                reportTypeDependency = new ToolingService.MetadataComponentDependency();
                reportTypeDependency.RefMetadataComponentId = objectIdMap.get(baseObject);
                reportTypeDependency.RefMetadataComponentType = baseObject.endsWith('__c') ? TYPE_CUSTOM_OBJECT : TYPE_STANDARD_OBJECT;
                reportTypeDependency.RefMetadataComponentName = baseObject;
                reportTypeDependency.MetadataComponentId = reportInfo.Id;
                reportTypeDependency.MetadataComponentType = TYPE_REPORT;
                reportTypeDependency.MetadataComponentName = reportInfo.DeveloperName;
                reportDependencyList.add(reportTypeDependency);
            }
        }

        //process Dashboards related to Reports added
        List<ToolingService.MetadataComponentDependency> dashboardMcdList = new List<ToolingService.MetadataComponentDependency>();
        for (ToolingService.MetadataComponentDependency reportMcd : reportDependencyList) {
            if (reportMcd.MetadataComponentType == TYPE_REPORT) {
                List<DashBoardComponent> relatedDashboards = reportDashboardMap.get(reportMcd.MetadataComponentId);
                if(relatedDashboards == null) continue;
    
                Set<String> objectDashIdProcessed = new Set<String>();
                for(DashboardComponent component : relatedDashboards) {
                    //dependency on the parent report
                    ToolingService.MetadataComponentDependency reportDependency = new ToolingService.MetadataComponentDependency();
                    reportDependency.RefMetadataComponentId = component.DashBoardId;
                    reportDependency.RefMetadataComponentType = TYPE_DASHBOARD;
                    reportDependency.RefMetadataComponentName = component.Dashboard.Title;
                    reportDependency.MetadataComponentId = reportMcd.MetadataComponentId;
                    reportDependency.MetadataComponentType = TYPE_REPORT;
                    reportDependency.MetadataComponentName = reportMcd.MetadataComponentName;
                    dashboardMcdList.add(reportDependency);
                    //dependency on the parent object
                    if (!objectDashIdProcessed.contains(reportMcd.RefMetadataComponentName+component.DashBoardId)) {
                        reportDependency = new ToolingService.MetadataComponentDependency();
                        reportDependency.RefMetadataComponentId = reportMcd.RefMetadataComponentId;
                        reportDependency.RefMetadataComponentType = reportMcd.RefMetadataComponentType;
                        reportDependency.RefMetadataComponentName = reportMcd.RefMetadataComponentName;
                        reportDependency.MetadataComponentId = component.DashBoardId;
                        reportDependency.MetadataComponentType = TYPE_DASHBOARD;
                        reportDependency.MetadataComponentName = component.Dashboard.Title;
                        dashboardMcdList.add(reportDependency);
                        objectDashIdProcessed.add(reportMcd.RefMetadataComponentName+component.DashBoardId);
                    }
                }
            }
        }
        reportDependencyList.addAll(dashboardMcdList);

        return reportDependencyList;
    }

    /**
     * Get Process Builder and Flow tied to Object Names via Tooling API and Metadata API
     */
    public static List<ToolingService.MetadataComponentDependency> getObjectProcessFlows(List<String> sObjectNames) {
        Set<String> sObjectNameSet = new Set<String>(sObjectNames);
        List<ToolingService.MetadataComponentDependency> activeFlows = new List<ToolingService.MetadataComponentDependency>();
        
        //Get active Flows
        String toolingResponse = ExternalUtilities.executeToolingQuery('SELECT Id, Definition.DeveloperName, ProcessType FROM Flow WHERE Definition.NamespacePrefix = null AND Status = \'Active\'');
        Map<String, Map<String,Object>> flowNameToToolingObj = new Map<String, Map<String,Object>>();
        if (String.isNotBlank(toolingResponse)) {
            Object toolingResponseGeneric = JSON.deserializeUntyped(toolingResponse);
            Map<String,Object> toolingResponseMap = (Map<String,Object>)toolingResponseGeneric;
            List<Object> records = (List<Object>)toolingResponseMap.get('records');
            if (records != null && !records.isEmpty()) {
                for (Object recordObj : records) {
                    Map<String,Object> toolingObj = (Map<String,Object>)recordObj;
                    String developerName = String.valueOf(((Map<String,Object>)toolingObj.get('Definition')).get('DeveloperName'));
                    flowNameToToolingObj.put(developerName, toolingObj);
                }
            }
        }
        
        //Fetch metadata for active flows
        if (!flowNameToToolingObj.isEmpty()) {
            ExternalUtilities.ExternalSchema flowSchemaMap = ExternalUtilities.executeMetadataRead(TYPE_FLOW, new List<String>(flowNameToToolingObj.keySet()));
            //process each active flow
            for (String flowName : flowNameToToolingObj.keySet()) {
                Map<String,Object> toolingObj = flowNameToToolingObj.get(flowName);
                Map<String,Object> metadataObj = (Map<String,Object>)flowSchemaMap.get(flowName);
                if (metadataObj == null) continue;

                switch on String.valueOf(toolingObj.get('ProcessType')) {
                    //Process Builder
                    when 'Workflow' {
                        //find sobject type in metadata
                        Object metaValueListObj = metadataObj.get('processMetadataValues');
                        if (metaValueListObj != null && metaValueListObj instanceOf List<Object>) {
                            for (Object metaValueObj : (List<Object>)metaValueListObj) {
                                Map<String,Object> metaValue = (Map<String,Object>)metaValueObj;
                                if (String.valueOf(metaValue.get('name')) == 'ObjectType') {
                                    String sobjectName = String.valueOf(((Map<String,Object>)metaValue.get('value')).get('stringValue'));
                                    //only add for requested object name
                                    if (String.isNotBlank(sobjectName) && sObjectNameSet.contains(sobjectName)) {
                                        ToolingService.MetadataComponentDependency mcd = new ToolingService.MetadataComponentDependency();
                                        mcd.MetadataComponentId = (String)toolingObj.get('Id');
                                        mcd.MetadataComponentName = flowName + ' (ProcessBuilder)';
                                        mcd.MetadataComponentType = TYPE_FLOW;
                                        mcd.RefMetadataComponentName = sobjectName;
                                        mcd.RefMetadataComponentType = mcd.RefMetadataComponentName != null && mcd.RefMetadataComponentName.endsWith('__c') ? TYPE_CUSTOM_OBJECT : TYPE_STANDARD_OBJECT;
                                        activeFlows.add(mcd);
                                    }
                                }
                            }
                        }
                    }
                    //Screen Flow
                    when 'Flow' {
                        //find sobject type in metadata
                        //find sobject type in recordLookup metadata
                        FlowParse mcdParse = parseFlowElementForObject(flowName, 'Screen', toolingObj, metadataObj.get('recordLookups'), sObjectNameSet);
                        activeFlows.addAll(mcdParse.mcds);

                        //find sobject type in recordUpdate metadata
                        if (!mcdParse.remainingSObjects.isEmpty()) {
                            mcdParse = parseFlowElementForObject(flowName, 'Screen', toolingObj, metadataObj.get('recordUpdates'), mcdParse.remainingSObjects);
                            activeFlows.addAll(mcdParse.mcds);
                        }

                        //find sobject type in recordDelete metadata
                        if (!mcdParse.remainingSObjects.isEmpty()) {
                            mcdParse = parseFlowElementForObject(flowName, 'Screen', toolingObj, metadataObj.get('recordDeletes'), mcdParse.remainingSObjects);
                            activeFlows.addAll(mcdParse.mcds);
                        }
                    }
                    //Auto launched
                    when 'AutoLaunchedFlow' {
                        Object startObj = metadataObj.get('start');
                        if (startObj != null && startObj instanceOf Map<String,Object>) {
                            Map<String,Object> startObjMap = (Map<String,Object>)startObj;
                            //Check for Trigger based Flow
                            //only add for requested object name
                            String sobjectName = String.valueOf(startObjMap.get('object'));
                            if (String.isNotBlank(sobjectName) && sObjectNameSet.contains(sobjectName)) {
                                ToolingService.MetadataComponentDependency mcd = new ToolingService.MetadataComponentDependency();
                                mcd.MetadataComponentId = (String)toolingObj.get('Id');
                                mcd.MetadataComponentName = flowName + ' (Trigger)';
                                mcd.MetadataComponentType = TYPE_FLOW;
                                mcd.RefMetadataComponentName = sobjectName;
                                mcd.RefMetadataComponentType = mcd.RefMetadataComponentName != null && mcd.RefMetadataComponentName.endsWith('__c') ? TYPE_CUSTOM_OBJECT : TYPE_STANDARD_OBJECT;
                                activeFlows.add(mcd);
                            } 
                        }
                        //Auto flow non-trigger based
                        else {
                            //find sobject type in recordLookup metadata
                            FlowParse mcdParse = parseFlowElementForObject(flowName, TYPE_FLOW, toolingObj, metadataObj.get('recordLookups'), sObjectNameSet);
                            activeFlows.addAll(mcdParse.mcds);

                            //find sobject type in recordUpdate metadata
                            if (!mcdParse.remainingSObjects.isEmpty()) {
                                mcdParse = parseFlowElementForObject(flowName, TYPE_FLOW, toolingObj, metadataObj.get('recordUpdates'), mcdParse.remainingSObjects);
                                activeFlows.addAll(mcdParse.mcds);
                            }

                            //find sobject type in recordDelete metadata
                            if (!mcdParse.remainingSObjects.isEmpty()) {
                                mcdParse = parseFlowElementForObject(flowName, TYPE_FLOW, toolingObj, metadataObj.get('recordDeletes'), mcdParse.remainingSObjects);
                                activeFlows.addAll(mcdParse.mcds);
                            }
                        }
                    }
                }
            }
        }

        return activeFlows;
    }

    /**
     * Parse Flow metadata XML->JSON for SObjectType and create MetadataComponentDependency
     */
    private class FlowParse {
        Set<String> remainingSObjects;
        List<ToolingService.MetadataComponentDependency> mcds = new List<ToolingService.MetadataComponentDependency>();
    }
    private static FlowParse parseFlowElementForObject(String flowName, String flowType, Map<String,Object> toolingObj, Object flowMetadataObj, Set<String> objectNames) {
        FlowParse response = new FlowParse();
        response.remainingSObjects = new Set<String>(objectNames);
        if (flowMetadataObj != null) {
            //find sobject type in flow metadata
            List<Object> recordMetadataObjList;
            if (flowMetadataObj instanceOf List<Object>) { recordMetadataObjList = (List<Object>)flowMetadataObj; } 
            else { recordMetadataObjList = new List<Object>{flowMetadataObj}; }
    
            //process flow metadata elements
            for (Object metaValueObj : recordMetadataObjList) {
                Map<String,Object> metaValue = (Map<String,Object>)metaValueObj;
                String sobjectName = String.valueOf(metaValue.get('object'));
                //only add for requested object name
                if (String.isNotBlank(sobjectName) && response.remainingSObjects.contains(sobjectName)) {
                    ToolingService.MetadataComponentDependency mcd = new ToolingService.MetadataComponentDependency();
                    mcd.MetadataComponentId = (String)toolingObj.get('Id');
                    mcd.MetadataComponentName = flowName + (flowType != TYPE_FLOW ? (' ('+flowType+')') : '');
                    mcd.MetadataComponentType = TYPE_FLOW;
                    mcd.RefMetadataComponentName = sobjectName;
                    mcd.RefMetadataComponentType = mcd.RefMetadataComponentName != null && mcd.RefMetadataComponentName.endsWith('__c') ? TYPE_CUSTOM_OBJECT : TYPE_STANDARD_OBJECT;
                    response.mcds.add(mcd);
                    response.remainingSObjects.remove(sobjectName);
                }
            }
        }
        return response;
    }

    /**
     * Get WorkflowRules, WorkflowFieldUpdates, WorkflowAlert, WorkflowTask, WorkflowOutboundMessage tied to Object Names via Tooling API and Metadata API
     */
    public static List<ToolingService.MetadataComponentDependency> getObjectWorkflows(Map<String,String> objectNameIdMap) {
        List<String> sObjectNames = new List<String>(objectNameIdMap.keySet());
        List<ToolingService.MetadataComponentDependency> allWorkflows = getMissingDependencies(sObjectNames, TYPE_WOKFLOW_RULE, 'TableEnumOrId', true);
        List<ToolingService.MetadataComponentDependency> activeWorkflows = new List<ToolingService.MetadataComponentDependency>();
        
        if (!allWorkflows.isEmpty()) {
            //To filter to only active we need another callout to read from metadata API
            Map<String,Object> objectNameToWorkflows = ExternalUtilities.executeMetadataRead('Workflow', sObjectNames).objectDescribeMap;
            Set<String> activeAlerts = new Set<String>();
            Set<String> activeFieldUpdates = new Set<String>();
            Set<String> activeOutboundMessages = new Set<String>();
            Set<String> activeTasks = new Set<String>();
            for (ToolingService.MetadataComponentDependency workflowMcd : allWorkflows) {
                Map<String,Object> objectWorkflowMetadata = (Map<String,Object>)objectNameToWorkflows.get(workflowMcd.RefMetadataComponentName);
                if (objectWorkflowMetadata != null) {
                    //parse rules object or list
                    Object rulesObj = objectWorkflowMetadata.get('rules');
                    if (rulesObj != null) {
                        List<Object> rulesObjList;
                        if (!(rulesObj instanceOf List<Object>)) {
                            rulesObjList = new List<Object>{rulesObj};
                        } else {
                            rulesObjList = (List<Object>)rulesObj;
                        }
                        //loop rules list for the object
                        for(Object workflowMetadataObj : rulesObjList) {
                            //remove inactive from workflows
                            Map<String,Object> workflowMetadata = (Map<String,Object>)workflowMetadataObj;
                            if (String.valueOf(workflowMetadata.get('active')) == 'true' && 
                                workflowMcd.MetadataComponentName.equalsIgnoreCase(String.valueOf(workflowMetadata.get('fullName')))) {
                                //add to list as active workflow
                                activeWorkflows.add(workflowMcd);
        
                                //parse active actions object or list
                                List<Object> actionObjList = new List<Object>();
                                //capture workflow actions
                                Object actionObj = workflowMetadata.get('actions');
                                if (actionObj != null) {
                                    if (!(actionObj instanceOf List<Object>)) {
                                        actionObjList.add(actionObj);
                                    } else {
                                        actionObjList.addAll((List<Object>)actionObj);
                                    }
                                }
                                //capture time trigger actions
                                Object workflowTimeTiggersObj = workflowMetadata.get('workflowTimeTriggers');
                                if (workflowTimeTiggersObj != null) {
                                    List<Object> timeObjList;
                                    if (!(workflowTimeTiggersObj instanceOf List<Object>)) {
                                        timeObjList = new List<Object>{workflowTimeTiggersObj};
                                    } else {
                                        timeObjList = (List<Object>)workflowTimeTiggersObj;
                                    }
                                    for (Object timeObj : timeObjList) {
                                        Map<String,Object> timeEntry = (Map<String,Object>)timeObj;
                                        Object timeActionObj = timeEntry.get('actions');
                                        if (timeActionObj != null) {
                                            if (!(timeActionObj instanceOf List<Object>)) {
                                                actionObjList.add(timeActionObj);
                                            } else {
                                                actionObjList.addAll((List<Object>)timeActionObj);
                                            }
                                        }
                                    }
                                }
                                for (Object actionEntryObj : actionObjList) {
                                    Map<String,Object> actionEntry = (Map<String,Object>)actionEntryObj;
                                    switch on String.valueOf(actionEntry.get('type')) {
                                        when 'Alert' {
                                            activeAlerts.add(String.valueOf(actionEntry.get('name')));
                                        }
                                        when 'FieldUpdate' {
                                            activeFieldUpdates.add(String.valueOf(actionEntry.get('name')));
                                        }
                                        when 'OutboundMessage' {
                                            activeOutboundMessages.add(String.valueOf(actionEntry.get('name')));
                                        }
                                        when 'Task' {
                                            activeTasks.add(String.valueOf(actionEntry.get('name')));
                                        }
                                    }
                                }
                                break;
                            }
                        }
                    }
                }
            }

            //get related workflow actions and only add active to final list
            List<ToolingService.MetadataComponentDependency> allAlerts = getMissingDependencies(objectNameIdMap.values(), TYPE_EMAIL_ALERT, 'DeveloperName', 'EntityDefinitionId', true);
            for(ToolingService.MetadataComponentDependency alertMcd : allAlerts) {
                if (activeAlerts.contains(alertMcd.MetadataComponentName)) { //developer name should exact match
                    activeWorkflows.add(alertMcd);
                }
            }
            List<ToolingService.MetadataComponentDependency> allFieldUpdates = getMissingDependencies(sObjectNames, TYPE_FIELD_UPDATE, 'SourceTableEnumOrId', true);
            for(ToolingService.MetadataComponentDependency updateMcd : allFieldUpdates) {
                if (activeFieldUpdates.contains(updateMcd.MetadataComponentName.replaceAll(' ','_'))) { //we can't get developer name to try to match from name
                    activeWorkflows.add(updateMcd);
                }
            }
            List<ToolingService.MetadataComponentDependency> allOutboundMessages = getMissingDependencies(objectNameIdMap.values(), TYPE_OUTBOUND_MESSAGE, 'EntityDefinitionId', true);
            for(ToolingService.MetadataComponentDependency outboundMsgMcd : allOutboundMessages) {
                if (activeOutboundMessages.contains(outboundMsgMcd.MetadataComponentName.replaceAll(' ','_'))) { //we can't get developer name to try to match from name
                    activeWorkflows.add(outboundMsgMcd);
                }
            }
            List<ToolingService.MetadataComponentDependency> allTasks = getMissingDependencies(objectNameIdMap.values(), TYPE_WORKFLOW_TASK, 'Subject', 'EntityDefinitionId', true);
            for(ToolingService.MetadataComponentDependency taskMcd : allTasks) {
                if (activeTasks.contains(taskMcd.MetadataComponentName.replaceAll(' ','_'))) { //we can't get developer name to try to match from name
                    activeWorkflows.add(taskMcd);
                }
            }
        }
        return activeWorkflows;
    }

    /**
     * Query components using Tooling API query or Apex SOQL and related to dependent object names as type returned from Dependency API
     * This is to help add component types missing from Dependency API
     */
    private static List<ToolingService.MetadataComponentDependency> getMissingDependencies(List<String> sObjectNames, String componentType, String keyField, Boolean useTooling) { 
        return getMissingDependencies(sObjectNames, componentType, 'Name', keyField, useTooling);
    }
    private static List<ToolingService.MetadataComponentDependency> getMissingDependencies(List<String> sObjectNames, String componentType, String nameField, String keyField, Boolean useTooling) {
        return getMissingDependencies(sObjectNames, componentType, nameField, keyField, '', useTooling);
    }
    private static List<ToolingService.MetadataComponentDependency> getMissingDependencies(List<String> sObjectNames, String componentType, String nameField, String keyField, String whereStatement, Boolean useTooling) {
        List<ToolingService.MetadataComponentDependency> newDependencies = new List<ToolingService.MetadataComponentDependency>();
        whereStatement = String.isNotBlank(whereStatement) ? (' AND ' + whereStatement) : '';
        if (useTooling) {
            String keySelection = (keyfield != nameField ? keyField : 'TableEnumOrId');
            String toolingResponse = ExternalUtilities.executeToolingQuery('SELECT Id,'+nameField+','+keySelection+' FROM '+componentType+' WHERE '+keyField+' IN (\''+String.join(sObjectNames, '\',\'') + '\')'+whereStatement);
            if (String.isNotBlank(toolingResponse)) {
                Object toolingResponseGeneric = JSON.deserializeUntyped(toolingResponse);
                Map<String,Object> toolingResponseMap = (Map<String,Object>)toolingResponseGeneric;
                List<Object> records = (List<Object>)toolingResponseMap.get('records');
                if (records != null && !records.isEmpty()) {
                    for (Object recordObj : records) {
                        Map<String,Object> toolingObj = (Map<String,Object>)recordObj;
                        ToolingService.MetadataComponentDependency mcd = new ToolingService.MetadataComponentDependency();
                        mcd.MetadataComponentId = (String)toolingObj.get('Id');
                        mcd.MetadataComponentName = (String)toolingObj.get(nameField);
                        mcd.MetadataComponentType = componentType;
                        mcd.RefMetadataComponentName = (String)toolingObj.get(keySelection);
                        mcd.RefMetadataComponentType = mcd.RefMetadataComponentName != null && mcd.RefMetadataComponentName.endsWith('__c') ? TYPE_CUSTOM_OBJECT : TYPE_STANDARD_OBJECT;
                        newDependencies.add(mcd);
                    }
                }
            }
        } else {
            for (SObject componentTypeObj : Database.query('SELECT Id, Name, '+keyField+' FROM '+componentType+' WHERE '+keyField+' IN :sObjectNames'+whereStatement)) {
                ToolingService.MetadataComponentDependency mcd = new ToolingService.MetadataComponentDependency();
                mcd.MetadataComponentId = (String)componentTypeObj.get('Id');
                mcd.MetadataComponentName = (String)componentTypeObj.get('Name');
                mcd.metadataComponentType = componentType;
                mcd.RefMetadataComponentName = (String)componentTypeObj.get(keyField);
                mcd.RefMetadataComponentType = mcd.RefMetadataComponentName != null && (mcd.RefMetadataComponentName.endsWith('__c') || mcd.RefMetadataComponentName.startsWith('01I')) ? TYPE_CUSTOM_OBJECT : TYPE_STANDARD_OBJECT;
                newDependencies.add(mcd);
            }
        }
        return newDependencies;
    }
    
    /**
	 * Wrapper for Salesforce Metadata Component Type dependency tree
	 */
	public class MetadataComponent {
        public String componentType;
        public String componentId;
        public String componentName;
        public String componentNamespace;
        public String componentLongname;
        public String componentUrl;
        public String parentObjectId;
        public String parentObjectName;
        public List<MetadataComponent> dependencies;
        public MetadataComponent parent;
        Set<String> childKeys;
        public MetadataComponent(String componentType, String componentId, String componentName, String componentNamespace) {
            this(null, componentType, componentId, componentName, componentNamespace);
        }

        public MetadataComponent(String parentObjectName, String componentType, String componentId, String componentName, String componentNamespace) {
            this(null, parentObjectName, componentType, componentId, componentName, componentNamespace);
        }

        public MetadataComponent(String parentObjectId, String parentObjectName, String componentType, String componentId, String componentName, String componentNamespace) {
            this.parentObjectId = parentObjectId;
            this.parentObjectName = parentObjectName;
            this.componentType = componentType;
            this.componentId = componentId;
            this.componentName = componentName;
            this.componentNamespace = componentNamespace;
            this.componentLongname = (String.isNotBlank(componentNamespace) ? (componentNamespace + '.') : '') + componentName;
            this.dependencies = new List<MetadataComponent>();
            this.childKeys = new Set<String>();
            this.componentUrl = URL.getSalesforceBaseUrl().toExternalForm();
            this.setUrl();
        }

        private void setUrl() {
            switch on componentType {
                when 'ApexClass' {
                    this.componentUrl += '/lightning/setup/ApexClasses/' + (String.isNotBlank(componentId) ? ('page?address=%2F' + componentId) : 'home');
                }
                when 'ApexTrigger' {
                    this.componentUrl += '/lightning/setup/ApexTriggers/' + (String.isNotBlank(componentId) ? ('page?address=%2F' + componentId) : 'home');
                }
                when 'CompactLayout' {
                    this.componentUrl += '/lightning/setup/ObjectManager/' + parentObjectId + '/CompactLayouts/' + (String.isNotBlank(componentId) ? (componentId + '/') : '') + 'view';
                }
                when 'CustomObject' {
                    this.componentUrl += '/lightning/setup/ObjectManager/' + componentId + '/Details/view';
                }
                when 'Dashboard' {
                    this.componentUrl += '/lightning/' + (String.isNotBlank(componentId) ? ('r/Dashboard/' + componentId + '/view') : 'o/Dashboard/home');
                }
                when 'EmailTemplate' {
                    this.componentUrl += '/lightning/setup/CommunicationTemplatesEmail/' + (String.isNotBlank(componentId) ? ('page?address=%2F' + componentId) : 'home');
                }
                when 'FieldSet' {
                    this.componentUrl += '/lightning/setup/ObjectManager/' + parentObjectId + '/FieldSets/' + (String.isNotBlank(componentId) ? (componentId + '/') : '') + 'view';
                }
                when 'FlexiPage' {
                    this.componentUrl += '/lightning/setup/ObjectManager/' + parentObjectId + '/LightningPages/' + (String.isNotBlank(componentId) ? (componentId + '/') : '') + 'view';
                }
                when 'Layout' {
                    this.componentUrl += '/lightning/setup/ObjectManager/' + parentObjectId + '/PageLayouts/' + (String.isNotBlank(componentId) ? (componentId + '/') : '') + 'view';
                }
                when 'ListView' {
                    this.componentUrl += '/lightning/o/' + parentObjectName + '/list' + (String.isNotBlank(componentId) ? ('?filterName=' + componentId) : '');
                }
                when 'ProcessDefinition' {
                    this.componentUrl += '/lightning/setup/ApprovalProcesses/' + (String.isNotBlank(componentId) ? ('page?address=%2F' + componentId) : 'home');
                }
                when 'RecordType' {
                    this.componentUrl += '/lightning/setup/ObjectManager/' + parentObjectId + '/RecordTypes/' + (String.isNotBlank(componentId) ? (componentId + '/') : '') + 'view';
                }
                when 'Report' {
                    this.componentUrl += '/lightning/' + (String.isNotBlank(componentId) ? ('r/Report/' + componentId + '/view') : 'o/Report/home');
                }
                when 'ReportType' {
                    this.componentUrl += '/lightning/setup/CustomReportTypes/' + (String.isNotBlank(componentId) ? ('page?address=%2F' + componentId) : 'home');
                }
                when 'StandardEntity' {
                    this.componentUrl += '/lightning/setup/ObjectManager/' + componentName + '/Details/view';
                }
                when 'WorkflowAlert' {
                    this.componentUrl += '/lightning/setup/WorkflowEmails/' + (String.isNotBlank(componentId) ? ('page?address=%2F' + componentId) : 'home');
                }
                when 'WorkflowFieldUpdate' {
                    this.componentUrl += '/lightning/setup/WorkflowFieldUpdates/' + (String.isNotBlank(componentId) ? ('page?address=%2F' + componentId) : 'home');
                }
                when 'WorkflowOutboundMessage' {
                    this.componentUrl += '/lightning/setup/WorkflowOutboundMessaging/' + (String.isNotBlank(componentId) ? ('page?address=%2F' + componentId) : 'home');
                }
                when 'WorkflowRule' {
                    this.componentUrl += '/lightning/setup/WorkflowRules/' + (String.isNotBlank(componentId) ? ('page?address=%2F' + componentId) : 'home');
                }
                when 'WorkflowTask' {
                    this.componentUrl += '/lightning/setup/WorkflowTasks/' + (String.isNotBlank(componentId) ? ('page?address=%2F' + componentId) : 'home');
                }
                when else {
                    this.componentUrl += '/' + componentId;
                }
            }
        }
    }

}