public inherited sharing class SchemaService {

	//TODO: error handling for situations where object or field does not exist

	public static final Map<String, Schema.SObjectType> GLOBAL_DESCRIBE = Schema.getGlobalDescribe();
	private static Map<String, Schema.DescribeSObjectResult> objectApiNameToDescribeResult = new Map<String, Schema.DescribeSObjectResult>();

	private static final String MDT_SUFFIX = 'mdt';

	//Must filter on Standard Objects
	private static final Set<String> PREFIXES_TO_EXCLUDE = new Set<String>{
		'Action',
		'AI',
		'Aggregate',
		'Apex',
		'Api',
		'App',
		'Apple',
		// 'Assessment',
		'AssessmentIndicator',
		'AssessmentTask',
		'Async',
		'Aura',
		'Auth',
		'Authorization',
		'Background',
		'Brand',
		'Branding',
		'Bulk',
		'Business',
		'Category',
		'Collab',
		'Comm',
		'Content',
		'Cors',
		'Credential',
		'Cron',
		'Csp',
		'Custom',
		'Dashboard',
		'Datacloud',
		'Data',
		'Duplicate',
		'Email',
		'Entity',
		'Expression',
		'External',
		'Field',
		'File',
		'Flow',
		'Formula',
		'Lightning',
		'List',
		'Login',
		'ML',
		'Macro',
		'Mailmerge',
		'Matching',
		'Oauth',
		'Org',
		'Permission',
		'Platform',
		'Process',
		'Record',
		'Redirect',
		'Relationship',
		'Report',
		'Ui',
		'User',
		'Wave',
		'Web',
		'Work',
		'Visualforce'
	};

	//Must filter on Standard Objects
	private static final Set<String> SUFFIXES_TO_EXCLUDE = new Set<String>{
		'Share',
		'History',
		'Tag',
		'Feed',
		'Event' //Captures "ChangeEvent" too
	};

	/*
		Lowercase because we're filtering from describe fieldmap keys
	 */
	@TestVisible
	private static final Set<String> FIELDS_TO_EXCLUDE = new Set<String>{
		'isdeleted',
		'lastvieweddate',
		'lastreferenceddate',
		'systemmodstamp',
		'id',
		'recordtypeid'
	};

	private static String getPackageNamespace(){
		String packageNamespace = Utilities.namespaceUnderscore;
		List<String> namespaceParts = packageNamespace.splitByCharacterTypeCamelCase();

		if(namespaceParts.isEmpty()){
			//This will never get filtered on, and that's OK. Just need a value that won't have the possibility of being filtered.
			return 'UPGRADE_TOOL';
		}

		return namespaceParts[0];
	}

	@TestVisible
	static List<SFDC_Industry_Mapping_List_Core_Object__mdt> mappingOrderList {
		get {
			if(mappingOrderList == null) {
				mappingOrderList = [
					SELECT Object_API_Name__c, Sort_Order__c
					FROM SFDC_Industry_Mapping_List_Core_Object__mdt
					ORDER BY Sort_Order__c ASC
				];
			}
			return mappingOrderList;
		}
		set;
	}

	public static Schema.DescribeSObjectResult getDescribeResult(String sObjectApiName){
		if( !objectApiNameToDescribeResult.containsKey(sObjectApiName) ){
			try{
				Schema.DescribeSObjectResult sObjectDescribeResult = GLOBAL_DESCRIBE.get(sObjectApiName).getDescribe();
				objectApiNameToDescribeResult.put(sObjectApiName, sObjectDescribeResult);
			} catch(System.NullPointerException e){
				throw new AuraHandledException('The requested SObject does not exist in this organization: ' + sObjectApiName);
			}
		}

		return objectApiNameToDescribeResult.get( sObjectApiName );
	}

	public static Schema.SObjectType getSObjectType(String sObjectApiName){
		return GLOBAL_DESCRIBE.get(sObjectApiName);
	}

	public static List<Schema.PicklistEntry> getPicklistValues(String sObjectApiName, String fieldApiName){
		Schema.DescribeFieldResult fieldDescribe = getDescribeResult(sObjectApiName).fields.getMap().get(fieldApiName).getDescribe();
		return fieldDescribe.getPicklistValues();
	}

	public static Map<String, Schema.SObjectField> getFieldMap( String sObjectApiName ) {
		return getDescribeResult( sObjectApiName ).fields.getMap();
	}

	public static Map<String, Schema.FieldSet> getFieldSetMap( String sObjectApiName ) {
		return getDescribeResult( sObjectApiName ).fieldSets.getMap();
	}

	public static Map<String, Schema.RecordTypeInfo> getRecordTypeMap(String sObjectApiName){
		return getDescribeResult(sObjectApiName).getRecordTypeInfosByDeveloperName();
	}

	@AuraEnabled
	public static SchemaModel getSchemaModel(String sObjectApiName){

		Schema.DescribeSObjectResult objectDescribeResult = getDescribeResult(sObjectApiName);

		//Want to only exclude STANDARD objects
		if( isExcludedObject(objectDescribeResult) ){
			return null;
		}

		SchemaModel schemaModel = new SchemaModel(objectDescribeResult);

		for ( String fieldApiName : getFieldMap( sObjectApiName ).keySet() ) {
			if ( !FIELDS_TO_EXCLUDE.contains( fieldApiName ) ){
				Schema.SObjectField sObjectField = getFieldMap(sObjectApiName).get(fieldApiName);
				FieldModel fieldModel = new FieldModel(sObjectField);
				schemaModel.fields.add(fieldModel);
			}
		}

		for(Schema.FieldSet fieldSet : getFieldSetMap(sObjectApiName).values() ){
			FieldSetModel fieldSetModel = new FieldSetModel(fieldSet);
			schemaModel.fieldSets.add(fieldSetModel);
		}

		for(Schema.RecordTypeInfo recordTypeInfo : getRecordTypeMap(sObjectApiName).values()){
			RecordTypeModel recordTypeModel = new RecordTypeModel(recordTypeInfo);
			schemaModel.recordTypes.add(recordTypeModel);
		}

		return schemaModel;

	}

	@AuraEnabled
	public static List<String> getObjectsForOrg(){
		List<String> sObjectList = new List<String>();
		List<String> customObjectList = new List<String>();
		List<String> packageObjectList = new List<String>();
		List<String> standardObjectList = new List<String>();
		Set<String> coreObjects = new Set<String>();

		for(SFDC_Industry_Mapping_List_Core_Object__mdt coreObject : mappingOrderList) {
			Schema.SObjectType objectSchema = GLOBAL_DESCRIBE.get(coreObject.Object_API_Name__c);
			if(objectSchema != null) {
				sObjectList.add(coreObject.Object_API_Name__c);
				coreObjects.add(coreObject.Object_API_Name__c);
			}
		}		
		
		for(Schema.SObjectType fieldDescribe : GLOBAL_DESCRIBE.values()) {
			String objectApiName = fieldDescribe.getDescribe().getName();
			if(coreObjects.contains(objectApiName) == true || isExcludedObject(objectApiName) == true) continue;

			if(fieldDescribe.getDescribe().isCustom() == true) {
				if(objectApiName.countMatches('__') > 1) {
					packageObjectList.add(objectApiName);
				} 
				else {
					customObjectList.add(objectApiName);
				}
			} 
			else {
				standardObjectList.add(objectApiName);
			}
		}

		customObjectList.sort();
		packageObjectList.sort();
		standardObjectList.sort();
		sObjectList.addAll(customObjectList);
		sObjectList.addAll(packageObjectList);
		sObjectList.addAll(standardObjectList);

		return sObjectList;
	}

	@AuraEnabled
	public static Map<String, SchemaModel> getFullSchemaModelMap(){
		Map<String, SchemaModel> schemaModelMap = new Map<String, SchemaModel>();

		for(String sObjectApiName : GLOBAL_DESCRIBE.keySet()){
			SchemaModel schemaModel = getSchemaModel( sObjectApiName );
			if( schemaModel != null){
				schemaModelMap.put(schemaModel.value, schemaModel);
			}
		}

		return schemaModelMap;
	}

	public static Boolean isObjectAvailable(String objectName) {
		Boolean hasObject = false;
		try {
			hasObject = !Schema.describeSObjects(new List<String>{objectName}).isEmpty();
		} catch (System.NoAccessException e) {
			//object not accessible
			System.debug(e.getMessage());
		}
		return hasObject;
	}

	//This version does not check for `isAccessible` or `isCustom`
	private static Boolean isExcludedObject(String sObjectApiName){

		//Requires that sObjectApiName be the CamelCase version.
		List<String> objectNameParts = sObjectApiName.splitByCharacterTypeCamelCase();

		Integer lastIndex = objectNameParts.size() - 1;

		//Automatically exclude objects from package and Custom Metadata Types
		if( sObjectApiName.startsWith(getPackageNamespace()) || objectNameParts.get(lastIndex) == MDT_SUFFIX){
			return true;
		}

		//Don't want to exclude "Event" object or similar instances
		Boolean isExcludedBySuffix = ( SUFFIXES_TO_EXCLUDE.contains(objectNameParts.get(lastIndex)) && lastIndex > 0);
		Boolean isExcludedByPrefix = ( PREFIXES_TO_EXCLUDE.contains(objectNameParts.get(0)) && objectNameParts.size() > 1);

		return (isExcludedBySuffix || isExcludedByPrefix);
	}

	private static Boolean isExcludedObject(Schema.DescribeSObjectResult objectDescribeResult){

		String sObjectApiName = objectDescribeResult.getName();

		//Requires that sObjectApiName be the CamelCase version.
		List<String> objectNameParts = sObjectApiName.splitByCharacterTypeCamelCase();

		Integer lastIndex = objectNameParts.size() - 1;

		//Automatically exclude objects from package and Custom Metadata Types
		if( sObjectApiName.startsWith(getPackageNamespace()) || objectNameParts.get(lastIndex) == MDT_SUFFIX){
			return true;
		}

		//Don't want to exclude "Event" object or similar instances
		Boolean notCustomOrAccessible = (!objectDescribeResult.isAccessible() || !objectDescribeResult.isCustom());
		Boolean isExcludedBySuffix = ( notCustomOrAccessible && SUFFIXES_TO_EXCLUDE.contains(objectNameParts.get(lastIndex)) && lastIndex > 0);
		Boolean isExcludedByPrefix = ( notCustomOrAccessible && PREFIXES_TO_EXCLUDE.contains(objectNameParts.get(0)) && objectNameParts.size() > 1);

		return (isExcludedBySuffix || isExcludedByPrefix);
	}

	/* Inner Classes */

	public virtual class SchemaItem {
		@AuraEnabled
		public String label;

		@AuraEnabled
		public String value;
	}

	public class SchemaModel extends SchemaItem {

		@AuraEnabled
		public List<FieldModel> fields;

		@AuraEnabled
		public List<FieldSetModel> fieldSets;

		@AuraEnabled
		public List<RecordTypeModel> recordTypes;

		public SchemaModel(){
			this.fields = new List<FieldModel>();
			this.fieldSets = new List<FieldSetModel>();
			this.recordTypes = new List<RecordTypeModel>();
		}

		public SchemaModel(Schema.DescribeSObjectResult objectDescribeResult) {
			this.fields = new List<FieldModel>();
			this.fieldSets = new List<FieldSetModel>();
			this.recordTypes = new List<RecordTypeModel>();

			this.value = objectDescribeResult.getName();

			this.label = String.format('{0} ({1})', new List<String>{
				objectDescribeResult.getLabel(),
				this.value
			});
		}

		public void populateRecordTypeCounts(){
			Map<String, Integer> recordTypeIdToCount = SchemaAnalytics.getRecordCountByRecordType(this.value);

			for(RecordTypeModel recordTypeModel : this.recordTypes){
				if(recordTypeIdToCount.containsKey(recordTypeModel.recordTypeId)){
					recordTypeModel.recordCount = recordTypeIdToCount.get(recordTypeModel.recordTypeId);
				}
			}
		}
	}

	public class FieldModel extends SchemaItem {

		@AuraEnabled
		public String type;

		@AuraEnabled
		public Integer length;

		public FieldModel(Schema.SObjectField sObjectField){
			Schema.DescribeFieldResult fieldDescribe = sObjectField.getDescribe();

			this.type = String.valueOf(fieldDescribe.getType());
			this.length = fieldDescribe.getLength();
			this.value = fieldDescribe.getName();

			this.label = String.format( '{0} ({1})', new List<String> {
				fieldDescribe.getLabel(),
				this.value
			} );
		}
	}

	public class FieldSetModel extends SchemaItem {
		public FieldSetModel( Schema.FieldSet fieldSet ) {

			this.value = fieldSet.getName();

			this.label = String.format( '{0} ({1})', new List<String> {
					fieldSet.getLabel(),
					this.value
			} );
		}
	}

	public class RecordTypeModel extends SchemaItem {

		@AuraEnabled
		public Id recordTypeId;

		@AuraEnabled
		public Boolean isActive;

		@AuraEnabled
		public Integer recordCount;

		public RecordTypeModel(Schema.RecordTypeInfo recordTypeInfo){

			this.value = recordTypeInfo.getDeveloperName();
			this.recordTypeId = recordTypeInfo.getRecordTypeId();
			this.isActive = recordTypeInfo.isActive();
			this.recordCount = 0;

			this.label = String.format( '{0} ({1})', new List<String> {
					recordTypeInfo.getName(),
					this.value
			} );
		}
	}

	/* public virtual class SharingCriteriaBase {

		@AuraEnabled
		public String fullName;
	}

	public class SharingCriteria extends SharingCriteriaBase {

		@AuraEnabled
		public List<SharingCriteriaRule> sharingCriteriaRules;

		@AuraEnabled
		public List<SharingCriteriaRule> sharingOwnerRules;
	} */

	public class SharingCriteriaRule {

		@AuraEnabled
		public String fullName;

		@AuraEnabled
		public String label;
	}
}