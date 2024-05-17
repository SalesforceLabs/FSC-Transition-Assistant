public inherited sharing class ToolingService {

    static final String EXTERNAL_STRING_QUERY = 'SELECT Id, Name, Value, Language FROM ExternalString WHERE NamespacePrefix = \''+Utilities.namespace+'\'';
    static final String EXTERNAL_STRING_LOCALIZATION_QUERY = 'SELECT ExternalStringId, Value, Language FROM ExternalStringLocalization';
    static final String INSTALLED_PACKAGE_QUERY = 'SELECT SubscriberPackage.NamespacePrefix, SubscriberPackage.Name, SubscriberPackageVersion.Id, SubscriberPackageVersion.Name, SubscriberPackageVersion.MajorVersion, SubscriberPackageVersion.MinorVersion, SubscriberPackageVersion.PatchVersion, SubscriberPackageVersion.BuildNumber FROM InstalledSubscriberPackage';
    static final String SUBSCRIBER_CUSTOM_OBJECT_QUERY = 'SELECT Id, DeveloperName FROM CustomObject WHERE NamespacePrefix = null';

    @TestVisible
    static String userLanguage  {
        get {
            if(userLanguage == null) {
                userLanguage = UserInfo.getLanguage();
            }
            return userLanguage;
        }
        set; 
    }

    public static Map<String, String> customLabelMap {
        get {
            if(customLabelMap == null) {
                customLabelMap = new Map<String, String>();
                String response = getExternalStringResponse();
                if(response != null) {
                    List<ExternalString> labelList = parseExternalStringResponse(response).records;
                    if(labelList != null) {
                        for(ExternalString label : labelList) {
                            customLabelMap.put(Utilities.namespaceUnderscore+label.Name, label.Value);
                            if(userLanguage != label.Language) {
                                List<ExternalStringLocalization> translations = customLabelTranslationMap.get(label.Id);
                                if(translations != null) {
                                    for(ExternalStringLocalization translation : translations) {
                                        if(userLanguage == translation.Language) {
                                            customLabelMap.put(Utilities.namespaceUnderscore+label.Name, translation.Value);
                                            break;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            return customLabelMap;
        }
        set;
    }

    @TestVisible
    static Map<String, List<ExternalStringLocalization>> customLabelTranslationMap {
        get {
            if(customLabelTranslationMap == null) {
                customLabelTranslationMap = new Map<String, List<ExternalStringLocalization>>();
                String response = getExternalStringLocalizationResponse();
                if(response != null) {
                    List<ExternalStringLocalization> labelList = parseExternalStringLocalizationResponse(response).records;
                    if(labelList != null) {
                        for(ExternalStringLocalization label : labelList) {
                            List<ExternalStringLocalization> currentList = customLabelTranslationMap.get(label.ExternalStringId);
                            if(currentList == null) {
                                customLabelTranslationMap.put(label.ExternalStringId, new List<ExternalStringLocalization>{label});
                            }
                            else {
                                currentList.add(label);
                            }
                        }    
                    }
                }
            }
            return customLabelTranslationMap;
        }
        set;
    }

    public static Map<String, InstalledSubscriberPackage> fscPackageMap {
        get {
            if(fscPackageMap == null) {
                fscPackageMap = new Map<String, InstalledSubscriberPackage>();
                String response = getFSCPackageResponse();
                if(response != null) {
                    List<InstalledSubscriberPackage> packageList = parseInstalledSubscriberPackageResponse(response).records;
                    if(packageList != null) {
                        for(InstalledSubscriberPackage installedPackage : packageList) {
                            fscPackageMap.put(installedPackage.SubscriberPackage.Name, installedPackage);
                        }
                    }
                }
            }
            return fscPackageMap;
        }
        set;
    }

    public static Map<String, InstalledSubscriberPackage> installedPackageMap {
        get {
            if(installedPackageMap == null) {
                installedPackageMap = new Map<String, InstalledSubscriberPackage>();
                String response = getInstalledSubscriberPackageResponse();
                if(response != null) {
                    List<InstalledSubscriberPackage> packageList = parseInstalledSubscriberPackageResponse(response).records;
                    if(packageList != null) {
                        for(InstalledSubscriberPackage installedPackage : packageList) {
                            installedPackageMap.put(installedPackage.SubscriberPackage.NamespacePrefix, installedPackage);
                        }
                    }
                }
            }
            return installedPackageMap;
        }
        private set;
    }

    public static Map<String, String> customObjectNameIdMap {
        get {
            if(customObjectNameIdMap == null) {
                customObjectNameIdMap = new Map<String, String>();
                String response = getSubscriberCustomObjectResponse();
                if(response != null) {
                    List<CustomObject> responseList = parseCustomObjectResponse(response).records;
                    if(responseList != null) {
                        for(CustomObject customObject : responseList) {
                            customObjectNameIdMap.put(customObject.DeveloperName, customObject.Id);
                        }
                    }
                }
            }
            return customObjectNameIdMap;
        }
        private set;
    }

    public static String getSubscriberCustomObjectResponse(){
        return ExternalUtilities.executeToolingQuery(SUBSCRIBER_CUSTOM_OBJECT_QUERY);
    }

    public static String getExternalStringResponse(){
        return ExternalUtilities.executeToolingQuery(EXTERNAL_STRING_QUERY);
    }

    public static String getExternalStringLocalizationResponse(){
        return ExternalUtilities.executeToolingQuery(EXTERNAL_STRING_LOCALIZATION_QUERY);
    }

    public static String getInstalledSubscriberPackageResponse(){
        return ExternalUtilities.executeToolingQuery(INSTALLED_PACKAGE_QUERY);
    }

    public static String getFSCPackageResponse(){
        return ExternalUtilities.executeFSCToolingQuery(INSTALLED_PACKAGE_QUERY);
    }

    /**
     * Dependency API Tooling Query
     */
    public static List<MetadataComponentDependency> queryDependencies(String queryString) {
        ToolingMetadataComponentDependencyResponse toolingResponse = parseMetadataComponentDependencyResponse(
            ExternalUtilities.executeToolingQuery(queryString)
        );
        return toolingResponse != null ? toolingResponse.records : null;
    }

    /**
     * JSON Parse to data types
     */

    public static ToolingCustomObjectResponse parseCustomObjectResponse(String jsonStr) {
        return (ToolingCustomObjectResponse)JSON.deserialize(
            jsonStr, 
            ToolingCustomObjectResponse.class
        );
    }

    @TestVisible
    static ToolingExternalStringResponse parseExternalStringResponse(String jsonStr) {
        return (ToolingExternalStringResponse)JSON.deserialize(
            jsonStr, 
            ToolingExternalStringResponse.class
        );    
    }

    public static ToolingExternalStringLocalizationResponse parseExternalStringLocalizationResponse(String jsonStr) {
        return (ToolingExternalStringLocalizationResponse)JSON.deserialize(
            jsonStr, 
            ToolingExternalStringLocalizationResponse.class
        );
    }

    public static ToolingInstalledSubscriberPackageResponse parseInstalledSubscriberPackageResponse(String jsonStr) {
        return (ToolingInstalledSubscriberPackageResponse)JSON.deserialize(
            jsonStr, 
            ToolingInstalledSubscriberPackageResponse.class
        );
    }

    public static ToolingMetadataComponentDependencyResponse parseMetadataComponentDependencyResponse(String jsonStr) {
        return (ToolingMetadataComponentDependencyResponse)JSON.deserialize(
            jsonStr, 
            ToolingMetadataComponentDependencyResponse.class
        );
    }

    public static List<MetadataComponentDependency> parseMetadataComponentDependencyList(String jsonStr) {
        return (List<MetadataComponentDependency>)JSON.deserialize(
            jsonStr, 
            List<MetadataComponentDependency>.class
        );
    }

    /**
     * CustomObject Tooling Query Response
     */
    public class ToolingCustomObjectResponse {
        public Integer size;
        public Integer totalSize;
        public List<CustomObject> records;
    }

    /**
     * ExternalString Tooling Query Response
     */
    public class ToolingExternalStringResponse {
        public Integer size {get;set;} 
        public Integer totalSize {get;set;} 
        public Boolean done {get;set;} 
        public Object queryLocator {get;set;} 
        public String entityTypeName {get;set;} 
        public List<ExternalString> records {get;set;} 
    }

    /**
     * ExternalStringLocalization Tooling Query Response
     */
    public class ToolingExternalStringLocalizationResponse {
        public Integer size {get;set;} 
        public Integer totalSize {get;set;} 
        public Boolean done {get;set;} 
        public Object queryLocator {get;set;} 
        public String entityTypeName {get;set;} 
        public List<ExternalStringLocalization> records {get;set;} 
    }

    /**
     * InstalledSubscriberPackage Tooling Query Response
     */
    public class ToolingInstalledSubscriberPackageResponse {
        public Integer size;
        public Integer totalSize;
        public List<InstalledSubscriberPackage> records;
    }

    /**
     * Dependency API Tooling Query Response
     */
    public class ToolingMetadataComponentDependencyResponse {
        public Integer size;
        public Integer totalSize;
        public List<MetadataComponentDependency> records;
    }

    /**
     * Custom Object Tooling Data Type
     */
    public class CustomObject {
        public String Id {get;set;}
        public String DeveloperName {get;set;}
    }

    /**
     * Custom Label Tooling Data Type
     */
    public class ExternalString {
        public String Id {get;set;}
        public String Name {get;set;}
        public String Language {get;set;}
        public String Value {get;set;}
    }

    /**
     * Custom Label Translation Tooling Data Type
     */
    public class ExternalStringLocalization {
        public String ExternalStringId {get;set;}
        public String Value {get;set;}
        public String Language {get;set;}
    }

    /**
     * InstalledSubscriberPackage Data Type
     */
    public class InstalledSubscriberPackage {
        public SubscriberPackage SubscriberPackage {get;set;}
        public SubscriberPackageVersion SubscriberPackageVersion {get;set;}
    }

    /**
     * Dependency API Tooling Data Type
     */
    public class MetadataComponentDependency {
        public String MetadataComponentId;
        public String MetadataComponentType;
        public String MetadataComponentName;
        public String MetadataComponentNamespace;
        public String RefMetadataComponentId;
        public String RefMetadataComponentType;
        public String RefMetadataComponentNamespace;
        public String RefMetadataComponentName;
    }

    /**
     * SubscriberPackage Data Type
     */
    public class SubscriberPackage {
        public String Name {get;set;}
        public String NamespacePrefix {get;set;}
    }

    /**
     * SubscriberPackageVersion Data Type
     */
    public class SubscriberPackageVersion {
        public String Id {get;set;}
        public String Name {get;set;}
        public String MajorVersion {get;set;}
        public String MinorVersion {get;set;}
        public String PatchVersion {get;set;}
        public String BuildNumber {get;set;}
    }

}