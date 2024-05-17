/**
 * The purpose of this class is to facilitate all communication to the dedicated external API
 * that is responsible for processing tasks against this org
 */
public inherited sharing class ExternalUtilities {

    //External API details
    private static final String API_CREDENTIAL_NAME = 'callout:'+Utilities.namespaceUnderscore+'FSC_Transition_Assistant_API';
    private static final String ENDPOINT_DEPENDENCY_SCAN = '/scan';
    private static final String ENDPOINT_METADATA_LIST = '/metadata/list';
    private static final String ENDPOINT_METADATA_READ = '/metadata/read';
    private static final String ENDPOINT_TOOLING_QUERY = '/tooling/query';
    private static final String ENDPOINT_PACKAGE_SCHEMA = '/schema/describe';
    private static final String ENDPOINT_GENERATE_DEPLOYMENT_PACKAGE = '/generateDeploymentPackage';
    private static final String ENDPOINT_GENERATE_DOCUMENT = '/generateDocument';
    private static final String ENDPOINT_INSTALL_PACKAGES = '/installPackages';
    private static final String ENDPOINT_DEPLOY_PACKAGES = '/deployPackage';

    private static final String URI_ENCODING_SCHEME = 'UTF-8';

    //Native APIs if need to fallback
    //private static final String TOOLING_ENDPOINT_NATIVE = 'callout:Tooling_API/services/data/v50.0/tooling/query/?q=';

    //Dedicated FSC schema org instance
    private static final SFDC_Schema_Org__mdt FSC_SCHEMA_ORG = SFDC_Schema_Org__mdt.getInstance('FSC_Schema');
    private static final String FSC_PACKAGE_NAMESPACE = FSC_SCHEMA_ORG.Industry_Namespace__c;
    private static final Boolean FSC_SCHEMA_INSTANCE_SANDBOX = FSC_SCHEMA_ORG.Is_Sandbox__c;
    private static final String FSC_SCHEMA_INSTANCE_URL = FSC_SCHEMA_ORG.Instance_URL__c;
    private static final String FSC_SCHEMA_INSTANCE_USERNAME = FSC_SCHEMA_ORG.Username__c;
    private static final String FSC_SCHEMA_INSTANCE_VERSION = FSC_SCHEMA_ORG.API_Version__c;

    //HTTP settings
    private static final Integer HTTP_RESPONSE_TIMEOUT = 60000; //1 minute max wait
    @TestVisible
    private static final Integer HTTP_RESPONSE_CODE_FAILURE = 500;
    @TestVisible
    private static final Integer HTTP_RESPONSE_CODE_SUCCESS = 200;
    @TestVisible
    private static final Integer HTTP_RESPONSE_CODE_PROCESSING = 202;

    //Running user and Org
    private static final String INSTANCE_ID = UserInfo.getOrganizationId();
    private static final String INSTANCE_URL = URL.getSalesforceBaseUrl().toExternalForm();
    private static final Boolean IS_SANDBOX = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
    private static final String USERNAME = UserInfo.getUserName();
    private static String instanceApiVersion {
        get {
            if (instanceApiVersion == null) {
                instanceApiVersion = getOrgApiVersion();
            }
            return instanceApiVersion;
        }
        set;
    }

    //Platform Cache Keys
    private static final String CACHE_PARTITION = (String.isNotBlank(Utilities.namespace) ? Utilities.namespace : 'local')+'.FSCTransitionCache';
    private static final Cache.OrgPartition CACHE_ORG = Cache.Org.getPartition(CACHE_PARTITION);
    private static final String CACHE_KEY_ORG_VERSION_NAME = 'orgVersionName';
    private static final String CACHE_KEY_ORG_API_VERSION = 'orgApiVersion';


    /**
     * Tooling API Query execute
     */
    public static String executeToolingQuery(String queryString) {
        ToolingQueryRequest requestBody = new ToolingQueryRequest(queryString);

        return executeToolingQuery(requestBody);
    }

    public static String executeToolingQuery(ToolingQueryRequest requestBody) {
        HttpResponse res = postJSON(API_CREDENTIAL_NAME + ENDPOINT_TOOLING_QUERY, JSON.serialize(requestBody));

        return res.getStatusCode() == HTTP_RESPONSE_CODE_SUCCESS ? res.getBody() : null;
    }

    public static String executeFSCToolingQuery(String queryString) {
        ToolingQueryRequest requestBody = new ToolingQueryRequest(queryString);
        requestBody.OrgInfo = new OrgInfoHeader(
            ExternalUtilities.FSC_SCHEMA_INSTANCE_USERNAME,
            ExternalUtilities.FSC_SCHEMA_INSTANCE_URL,
            FSC_SCHEMA_INSTANCE_SANDBOX
        );
        return executeToolingQuery(requestBody);
    }

    /**
     * Metadata API List execute
     */
    public static ExternalSchema executeMetadataList(String componentType) {
        ExternalSchema metadataSchemaMap = new ExternalSchema();
        if (String.isNotBlank(componentType)) {
            MetadataListRequest requestBody = new MetadataListRequest(componentType);
            HttpResponse res = postJSON(API_CREDENTIAL_NAME + ENDPOINT_METADATA_LIST, JSON.serialize(requestBody));

            if(res.getStatusCode() == HTTP_RESPONSE_CODE_SUCCESS) {
                Object genericResponseObj = JSON.deserializeUntyped(res.getBody());
                if (genericResponseObj != null) {
                    metadataSchemaMap = new ExternalSchema((Map<String,Object>)genericResponseObj);
                }
            }
        }
        return metadataSchemaMap;
    }

    /**
     * Metadata API Read execute
     */
    public static ExternalSchema executeMetadataRead(String componentType, List<String> componentNames) {
        ExternalSchema metadataSchemaMap = new ExternalSchema();
        if (String.isNotBlank(componentType) && componentNames != null && !componentNames.isEmpty()) {
            MetadataReadRequest requestBody = new MetadataReadRequest(componentType, componentNames);
            HttpResponse res = postJSON(API_CREDENTIAL_NAME + ENDPOINT_METADATA_READ, JSON.serialize(requestBody));

            if(res.getStatusCode() == HTTP_RESPONSE_CODE_SUCCESS) {
                Object genericResponseObj = JSON.deserializeUntyped(res.getBody());
                if (genericResponseObj != null) {
                    metadataSchemaMap = new ExternalSchema((Map<String,Object>)genericResponseObj);
                }
            }
        }
        return metadataSchemaMap;
    }

    /**
     * Dependency API Bulk API 2.0 scan asynchronous
     */
    public static Boolean initiateBulkDependencyScan(Id assessmentId, MappingService.MappedComponents mapping) {

        DependencyScanRequest scanRequest = new DependencyScanRequest(assessmentId, mapping);
        HttpResponse res = postJSON(API_CREDENTIAL_NAME + ENDPOINT_DEPENDENCY_SCAN, JSON.serialize(scanRequest));

        return res.getStatusCode() == HTTP_RESPONSE_CODE_PROCESSING;
    }

    public static Boolean initiatePackageInstall(Id assessmentId, List<PackageInstallationController.PackageInfo> packages) {
        HttpResponse response = postJSON(API_CREDENTIAL_NAME + ENDPOINT_INSTALL_PACKAGES, JSON.serialize(new PackageInstallRequest(assessmentId, packages)));

        return response.getStatusCode() == HTTP_RESPONSE_CODE_PROCESSING || response.getStatusCode() == HTTP_RESPONSE_CODE_SUCCESS;
    }
    
    public static Boolean initiatePackageDeployment(PackageDeploymentController.DeploymentInfo deployment) {
        HttpResponse response = postJSON(API_CREDENTIAL_NAME + ENDPOINT_DEPLOY_PACKAGES, JSON.serialize(new PackageDeployRequest(deployment)));

        return response.getStatusCode() == HTTP_RESPONSE_CODE_PROCESSING || response.getStatusCode() == HTTP_RESPONSE_CODE_SUCCESS;
    }
    /**
     * Request Schema from components not installed in this org
     */
    public static ExternalSchema requestFSCObjectSchema(List<String> objectNames) {
        ExternalSchema externalFscSchema;
        if (objectNames != null && !objectNames.isEmpty()) {
            ExternalSchemaRequest requestBody = new ExternalSchemaRequest(FSC_PACKAGE_NAMESPACE, 'CustomObject', objectNames);
            requestBody.OrgInfo.ApiVersion = FSC_SCHEMA_INSTANCE_VERSION;

            HttpResponse res = postJSON(API_CREDENTIAL_NAME + ENDPOINT_PACKAGE_SCHEMA, JSON.serialize(requestBody));

            if(res.getStatusCode() == HTTP_RESPONSE_CODE_SUCCESS) {
                Object genericResponseObj = JSON.deserializeUntyped(res.getBody());
                if (genericResponseObj != null) {
                    externalFscSchema = new ExternalSchema((Map<String,Object>)genericResponseObj);
                }
            }
        }
        return externalFscSchema;
    }

    /**
     * Request Schema from components installed in this org
     */
    public static ExternalSchema requestOrgObjectSchema(List<String> objectNames) {
        ExternalSchema externalSchema;
        if (objectNames != null && !objectNames.isEmpty()) {
            ExternalSchemaRequest requestBody = new ExternalSchemaRequest('', 'CustomObject', objectNames);
            requestBody.OrgInfo = new OrgInfoHeader();
            requestBody.ForceRefresh = true;

            HttpResponse res = postJSON(API_CREDENTIAL_NAME + ENDPOINT_PACKAGE_SCHEMA, JSON.serialize(requestBody));

            if(res.getStatusCode() == HTTP_RESPONSE_CODE_SUCCESS) {
                Object genericResponseObj = JSON.deserializeUntyped(res.getBody());
                if (genericResponseObj != null) {
                    externalSchema = new ExternalSchema((Map<String,Object>)genericResponseObj);
                }
            }
        }
        return externalSchema;
    }

    /**
     * Request asynchronous generation of a deployment package to be save back in salesforce
     * @param assessmentId - Assessment record id
     * @param deploymentChecklistFileId - ContentVersion id of deployment checklist JSON file (generated by DeploymentChecklist)
     */
    public static Boolean requestGenerateDeploymentPackage(Id assessmentId, Id deploymentChecklistFileId) {
        Boolean isSuccess = false;
        if (assessmentId != null && deploymentChecklistFileId != null) {
            PackageGenerationRequest requestBody = new PackageGenerationRequest(assessmentId, deploymentChecklistFileId);
            HttpResponse res = postJSON(API_CREDENTIAL_NAME + ENDPOINT_GENERATE_DEPLOYMENT_PACKAGE, JSON.serialize(requestBody));
            isSuccess = res.getStatusCode() == HTTP_RESPONSE_CODE_PROCESSING;
        }
        return isSuccess;
    }

    /**
     * Request XLSX Document Generation for mapping data
     *
     * @param docBody - Wrapper object containing the sheets, columns, and rows
     * for display within the XLSX file
     */
    public static MappingDocResponse requestMappingXLSXDocument(MappingDocumentBody docBody) {
        MappingDocResponse resObject = new MappingDocResponse();
        HttpResponse res = postJSON(API_CREDENTIAL_NAME + ENDPOINT_GENERATE_DOCUMENT, JSON.serialize(docBody));

        if(res.getStatusCode() == HTTP_RESPONSE_CODE_SUCCESS) {
            resObject.xlsxData = res.getBodyAsBlob();
        }else{
            System.debug('==Error: '+res.getStatusCode()+' - '+res.getBody());
        }
        return resObject;
    }

    public static PdfDocumentResponse requestAssessmentAsPdf(Id assessmentId){
        PdfDocument pdfDocument = new PdfDocument(assessmentId);

        HttpResponse res = postJSON(API_CREDENTIAL_NAME + ENDPOINT_GENERATE_DOCUMENT, JSON.serialize(pdfDocument));
        System.debug(res.getStatusCode());
        if(res.getStatusCode() == HTTP_RESPONSE_CODE_PROCESSING){
            PdfDocumentResponse pdfResponse = new PdfDocumentResponse();
            pdfResponse.content = res.getBodyAsBlob();
            pdfResponse.recordId = assessmentId;

            return pdfResponse;
        }

        return null;
    }

    /**
     * Use Salesforce Status API to get current Org Release Version name
     */
    public static String getOrgVersionName() {
        String versionName = (String)CACHE_ORG.get(CACHE_KEY_ORG_VERSION_NAME);
        if (String.isBlank(versionName)) {
            versionName = String.valueOf(getOrgStatus().get('releaseVersion'));
            //cache 1 hour immutable this namespace only
            if (String.isNotBlank(versionName)) {
                CACHE_ORG.put(CACHE_KEY_ORG_VERSION_NAME, versionName, 3600, Cache.Visibility.NAMESPACE, true);
            }
        }
        return versionName;
    }

    /**
     * Use Salesforce API for this instance to get current Org API version number
     */
    public static String getOrgApiVersion() {
        String apiVersion = (String)CACHE_ORG.get(CACHE_KEY_ORG_API_VERSION);
        if (String.isBlank(apiVersion)) {
            apiVersion = String.valueOf([SELECT ApiVersion
                                         FROM ApexClass
                                         WHERE NamespacePrefix = :Utilities.namespace AND
                                               Name = 'ExternalUtilities'
                                         LIMIT 1][0].ApiVersion);
            //TBD if we want this callout
            //Otherwise just keep this class API version current
            /*HttpResponse res = getJSON(ExternalUtilities.INSTANCE_URL + '/services/data/');
            if (res.getStatusCode() == HTTP_RESPONSE_CODE_SUCCESS) {
                List<Object> responseList = (List<Object>)JSON.deserializeUntyped(res.getBody());
                if (responseList != null && !responseList.isEmpty()) {
                    Object latestVersion = responseList[responseList.size()-1];
                    apiVersion = String.valueOf(((Map<String,Object>)latestVersion).get('version'));
                }
            }*/
            //cache 1 hour immutable this namespace only
            if (String.isNotBlank(apiVersion)) {
                CACHE_ORG.put(CACHE_KEY_ORG_API_VERSION, apiVersion, 3600, Cache.Visibility.NAMESPACE, true);
            }
        }
        return apiVersion;
    }

    /**
     * Salesforce Status API to get current Org release and status
     */
    private static Map<String,Object> getOrgStatus() {
        Map<String,Object> responseMap = new Map<String,Object>();
        String instanceName = [SELECT InstanceName FROM Organization LIMIT 1].InstanceName;
        HttpResponse res = getJSON('https://api.status.salesforce.com/v1/instances/'+instanceName+'/status');
        if (res.getStatusCode() == HTTP_RESPONSE_CODE_SUCCESS) {
            Object responseObj = JSON.deserializeUntyped(res.getBody());
            responseMap = (Map<String,Object>)responseObj;
        }
        return responseMap;
    }

    /**
     * Wrapper for org and user detail for executing requests back to this org
     */
    private class OrgInfoHeader {
        private String OrgId = ExternalUtilities.INSTANCE_ID;
        private String Username = ExternalUtilities.USERNAME;
        private String InstanceUrl = ExternalUtilities.INSTANCE_URL;
        private Boolean IsSandbox = ExternalUtilities.IS_SANDBOX;
        private String ApiVersion = ExternalUtilities.instanceApiVersion;

        public OrgInfoHeader() {}

        public OrgInfoHeader(String username, String instanceUrl, Boolean isSandbox) {
            this.Username = username;
            this.InstanceUrl = instanceUrl;
            this.IsSandbox = isSandbox;
        }
    }

    /**
     * Wrapper class for initiating external dependency scan
     */
    public class DependencyScanRequest {
        private OrgInfoHeader OrgInfo = new OrgInfoHeader();
        private String Namespace = Utilities.namespaceUnderscore;
        public Id AssessmentId;
        public Map<String,String> ObjectMapping;
        public Map<String,String> FieldMapping;

        public DependencyScanRequest() {}

        public DependencyScanRequest(Id assessmentId, MappingService.MappedComponents mapping) {
            this.AssessmentId = assessmentId;
            if (mapping != null) {
                this.ObjectMapping = mapping.sourceToDestinationObject;
                this.FieldMapping = mapping.sourceToDestinationField;
            }
        }

        /*public DependencyScanRequest(List<Id> componentIds, List<String> customObjectNames, List<String> customFieldNames) {
            this.ComponentIds = componentIds;
            this.CustomObjectNames = customObjectNames;
            this.CustomFieldNames = customFieldNames;
        }*/
    }

    public class PackageInstallRequest {
        private OrgInfoHeader OrgInfo = new OrgInfoHeader();
        private String Namespace = Utilities.namespaceUnderscore;
        public Id AssessmentId;
        public List<PackageVersionInfo> Packages;

        public PackageInstallRequest() {}

        public PackageInstallRequest(Id assessmentId, List<PackageInstallationController.PackageInfo> packages) {
            this.AssessmentId = assessmentId;
            this.Packages = new List<PackageVersionInfo>();
            for(PackageInstallationController.PackageInfo packageInfo : packages) {
                this.Packages.add(new PackageVersionInfo(packageInfo));
            }
        }
    }

    public class PackageDeployRequest {
        private OrgInfoHeader OrgInfo = new OrgInfoHeader();
        private String Namespace = Utilities.namespaceUnderscore;
        public Id AssessmentId;
        public Id PackageFileId;

        public PackageDeployRequest() {}

        public PackageDeployRequest(PackageDeploymentController.DeploymentInfo deployment) {
            this.AssessmentId = deployment.AssessmentId;
            this.PackageFileId = deployment.DocumentId;
        }
    }

    public class PackageVersionInfo {
        public Id VersionId;
        public String Name;

        public PackageVersionInfo() {}

        public PackageVersionInfo(PackageInstallationController.PackageInfo packageInfo) {
            this.VersionId = packageInfo.VersionId;
            this.Name = packageInfo.Name;
        }
    }


    /**
     * Wrapper class for initiating external tooling
     */
    public class ToolingQueryRequest {
        private OrgInfoHeader OrgInfo = new OrgInfoHeader();
        public String Query;

        public ToolingQueryRequest(String query) {
            this.Query = query;
        }
    }

    /**
     * Wrapper class for initiating external metadata read
     */
    public class MetadataListRequest {
        private OrgInfoHeader OrgInfo = new OrgInfoHeader();
        public List<String> ComponentTypes;

        /**
         * @param componentType - Type of component like CustomObject, ReportType, etc.
         *                        Can prepend with foldername for Reports/Dashboards/ListViews (e.g. "Account/ListView")
         */
        public MetadataListRequest(String componentType) {
            this.ComponentTypes = new List<String>{componentType};
        }
    }

    /**
     * Wrapper class for initiating external metadata read
     */
    public class MetadataReadRequest {
        private OrgInfoHeader OrgInfo = new OrgInfoHeader();
        public String ComponentType;
        public List<String> ComponentNames;

        public MetadataReadRequest(String componentType, List<String> componentNames) {
            this.ComponentType = componentType;
            this.ComponentNames = componentNames;
        }
    }

    /**
     * Wrapper class for generating deployment packages
     */
    public class PackageGenerationRequest {
        private OrgInfoHeader OrgInfo = new OrgInfoHeader();
        public String AssessmentId;
        public String DeploymentChecklistFileId;
        public String Namespace;

        public PackageGenerationRequest(Id assessmentId, Id deploymentChecklistFileId) {
            this.AssessmentId = assessmentId;
            this.DeploymentChecklistFileId = deploymentChecklistFileId;
            this.Namespace = Utilities.namespaceUnderscore;
        }
    }

    /**
     * Wrapper class to request describing target package schema not installed in this org
     */
    public class ExternalSchemaRequest {
        private OrgInfoHeader OrgInfo;
        public String PackageName;
        public String ComponentType;
        public List<String> ComponentNames;
        public Boolean ForceRefresh;

        public ExternalSchemaRequest(String packageName, String componentType, String componentName) {
            this(
                packageName,
                componentType,
                componentName != null ? new List<String>{componentName} : null
            );
        }

        public ExternalSchemaRequest(String packageName, String componentType, List<String> componentNames) {
            this.PackageName = packageName;
            this.ComponentType = componentType;
            this.ComponentNames = componentNames;
            this.ForceRefresh = false;
            // Set FSC Schema Org
            if (this.PackageName != null && this.PackageName.toLowerCase() == FSC_PACKAGE_NAMESPACE.toLowerCase()) {
                OrgInfo = new OrgInfoHeader(
                    ExternalUtilities.FSC_SCHEMA_INSTANCE_USERNAME,
                    ExternalUtilities.FSC_SCHEMA_INSTANCE_URL,
                    FSC_SCHEMA_INSTANCE_SANDBOX
                );
            }
        }
    }

    /**
     * Wrapper class for response describing target package schema not installed in this org
     */
    public class ExternalSchema {
        public Map<String, Object> objectDescribeMap;

        public ExternalSchema() {
            this.objectDescribeMap = new Map<String,Object>();
        }

        public ExternalSchema(Map<String, Object> objectDescribeMap) {
            this.objectDescribeMap = objectDescribeMap;
        }

        public Object get(String fieldPath) {
            return Utilities.parseObjectValue(fieldPath, objectDescribeMap);
        }
    }

    /**
     * Wrapper classes for XLSX Document Generation request
     */
    public class MappingDocumentBody {
        private OrgInfoHeader OrgInfo;
        public MappingDocumentContent Content;
        public String Type;

        public MappingDocumentBody(MappingDocumentContent Content, String Type){
            this.Content = Content;
            this.OrgInfo = new OrgInfoHeader();
            this.Type = Type;
        }
    }

    public class MappingDocumentContent {
        public List<MappingDocumentSheet> Sheets;

        public MappingDocumentContent(List<MappingDocumentSheet> Sheets){
            this.Sheets = Sheets;
        }
    }

    public class MappingDocumentSheet {
        public String Name;
        public List<MappingDocumentColumn> Columns;
        public List<List<String>> DataRows;

        public MappingDocumentSheet(String name){
            this.Name = name;
            this.Columns = new List<MappingDocumentColumn>();
            this.DataRows = new List<List<String>>();
        }

        public MappingDocumentSheet(String name, List<MappingDocumentColumn> columns){
            this.Name = name;
            this.Columns = columns;
            this.DataRows = new List<List<String>>();
        }
    }

    public class MappingDocumentColumn {
        public String Name;
        public Integer Width;

        public MappingDocumentColumn(String name, Integer width){
            this.Name = name;
            this.Width = width;
        }
    }

    public class MappingDocResponse {
        public Blob xlsxData;

        public MappingDocResponse(){}
    }

    public class PdfDocument {
        private OrgInfoHeader OrgInfo = new OrgInfoHeader();
        public String Url;
        public String AssessmentId;
        public String Namespace = Utilities.namespaceUnderscore;
        public String Type = 'PDF';
        public String SessionToken = UserInfo.getSessionId();

        public PdfDocument(Id assessmentId){
            System.assertNotEquals(null, assessmentId, 'Assessment Id is required in order to process PDF Request.');
            this.AssessmentId = assessmentId;
            this.Url = String.format('{0}/lightning/r/{1}Assessment__c/{2}/view', new List<String>{
                this.OrgInfo.InstanceUrl,
                Utilities.namespaceUnderscore,
                assessmentId
            });
        }
    }

    public class PdfDocumentResponse {
        public Blob content;
        public Id recordId;
    }

    /**
     * Private REST HTTP Utility
     */

    /**
     * GET Request
     */
    private static HttpResponse getJSON(String endpoint) {
        return getJSON(endpoint, null);
    }

    private static HttpResponse getJSON(String endpoint, Map<String,String> headers) {
        //setup headers
        if (headers == null) {
            headers = new Map<String,String>();
        }
        headers.put('Accept','application/json');

        //send request
        return sendRequest(endpoint, 'GET', headers, null);
    }

    /**
     * POST Request
     */
    private static HttpResponse postJSON(String endpoint, String jsonBody) {
        return postJSON(endpoint, jsonBody, null);
    }

    private static HttpResponse postJSON(String endpoint, String jsonBody, Map<String,String> headers) {
        //setup headers
        if (headers == null) {
            headers = new Map<String,String>();
        }
        headers.putAll(new Map<String,String> {
            'Content-Type' => 'application/json',
            'Accept' => 'application/json'
        });

        //send request
        return sendRequest(endpoint, 'POST', headers, jsonBody);
    }

    /**
     * PRIVATE REQUEST HELPERS
     **/

    /**
     * Generic HTTP Request Send
     */
    private static HttpResponse sendRequest(String endpoint, String method, Map<String,String> headers, String body) {
        HttpResponse res = new HttpResponse();
        HttpRequest req = new HttpRequest();
        req.setMethod(method);
        req.setTimeout(HTTP_RESPONSE_TIMEOUT);
        req.setEndpoint(endpoint);
        if (headers != null) {
            for (String key : headers.keySet()) {
                req.setHeader(key, headers.get(key));
            }
        }

        if (String.isNotBlank(body)) {
            req.setBody(body);
        }

        //send request
        try {
            res = new Http().send(req);
        } catch (CalloutException e) {
            res.setStatusCode(HTTP_RESPONSE_CODE_FAILURE);
            res.setBody('Callout Failure: '+endpoint+'\n\n'+'Error: '+e.getMessage());
        }

        return res;
    }
}