/***********************************************************************************
 * Class that controls content and actions shown in the mapping-related components
 * (namely, mappingSection, and mappingScreen)
 **********************************************************************************/

public inherited sharing class MappingService {

    public static String EMPTY_MAPPING_JSON = '{"recommended":[],"additional":[]}';

    public static String FILENAME_MAPPINGDOC {get{return (String.isBlank(FILENAME_MAPPINGDOC)) ? ToolingService.customLabelMap.get(Utilities.namespaceUnderscore + 'MappingDocTitle') : FILENAME_MAPPINGDOC;}set;}
    public static String FILEEXTENSION_MAPPINGDOC {get{return (String.isBlank(FILEEXTENSION_MAPPINGDOC)) ? ToolingService.customLabelMap.get(Utilities.namespaceUnderscore + 'MappingDocExtension') : FILEEXTENSION_MAPPINGDOC;}set;}
    // public static List<String> COLUMNS_MAPPINGDOC {
    //     get {
    //         if (COLUMNS_MAPPINGDOC == null) {
    //             return new List<String>{ToolingService.customLabelMap.get(Utilities.namespaceUnderscore + 'MappingDocColumnSection'),
    //             ToolingService.customLabelMap.get(Utilities.namespaceUnderscore + 'MappingDocColumnType'),
    //             ToolingService.customLabelMap.get(Utilities.namespaceUnderscore + 'MappingDocColumnSourceObject'),
    //             ToolingService.customLabelMap.get(Utilities.namespaceUnderscore + 'MappingDocColumnDestObject'),
    //             ToolingService.customLabelMap.get(Utilities.namespaceUnderscore + 'MappingDocColumnSource'),
    //             ToolingService.customLabelMap.get(Utilities.namespaceUnderscore + 'MappingDocColumnDest'),
    //             ToolingService.customLabelMap.get(Utilities.namespaceUnderscore + 'MappingDocColumnDataType'),
    //             ToolingService.customLabelMap.get(Utilities.namespaceUnderscore + 'MappingDocColumnRequired'),
    //             ToolingService.customLabelMap.get(Utilities.namespaceUnderscore + 'MappingDocColumnLength'),
    //             ToolingService.customLabelMap.get(Utilities.namespaceUnderscore + 'MappingDocColumnDecimalPlaces'),
    //             ToolingService.customLabelMap.get(Utilities.namespaceUnderscore + 'MappingDocColumnConflict')};
    //         }
    //         return COLUMNS_MAPPINGDOC;
    //     }
    //     set;
    // }

    public static List<SFDC_Industry_Mapping_Export_Definition__mdt> COLUMNS_MAPPINGDOC {
        get {
            if (COLUMNS_MAPPINGDOC == null) {
                List<SFDC_Industry_Mapping_Export_Definition__mdt> columnList = new List<SFDC_Industry_Mapping_Export_Definition__mdt>();
                List<SFDC_Industry_Mapping_Export_Definition__mdt> exportDefs = [SELECT Id, Index__c, Label_Name__c, Wrapper_Attribute_Name__c, Wrapper_Object__c 
                FROM SFDC_Industry_Mapping_Export_Definition__mdt ORDER BY Index__c LIMIT :(Limits.getLimitQueryRows() - Limits.getQueryRows())];

                for (Integer i = 0; i < exportDefs.size(); i++) {
                    exportDefs[i].Label_Name__c = ToolingService.customLabelMap.get(Utilities.namespaceUnderscore + exportDefs[i].Label_Name__c);
                }

                return columnList;
            }
            return COLUMNS_MAPPINGDOC;
        }
        set;
    }

    public static final Integer MAX_SHEET_NAME_SIZE = 23;

    //COLUMN INDICIES
    private static final Integer COLUMN_INDEX_SOURCE_OBJECT = 0;
    private static final Integer COLUMN_INDEX_DEST_OBJECT = 1;
    private static final Integer COLUMN_INDEX_SOURCE = 2;
    private static final Integer COLUMN_INDEX_DEST = 3;
    private static final Integer COLUMN_INDEX_DEST_DATATYPE = 4;
    private static final Integer COLUMN_INDEX_DEST_REQUIRED = 5;
    private static final Integer COLUMN_INDEX_DEST_LENGTH = 6;
    private static final Integer COLUMN_INDEX_DEST_DECIMALS = 7;
    private static final Integer COLUMN_INDEX_CONFLICT = 8;

    public static String SECTION_ADDITIONAL {get{return (String.isBlank(SECTION_ADDITIONAL)) ? ToolingService.customLabelMap.get(Utilities.namespaceUnderscore + 'MappingDocSectionAdditional') : SECTION_ADDITIONAL;}set;}
    public static String ROWVALUE_FIELD {get{return (String.isBlank(ROWVALUE_FIELD)) ? ToolingService.customLabelMap.get(Utilities.namespaceUnderscore + 'MappingDocTypeField') : ROWVALUE_FIELD;}set;}
    public static String ROWVALUE_RECORDTYPE {get{return (String.isBlank(ROWVALUE_RECORDTYPE)) ? ToolingService.customLabelMap.get(Utilities.namespaceUnderscore + 'MappingDocTypeRT') : ROWVALUE_RECORDTYPE;}set;}

    @TestVisible
    static List<String> objectMappingList {
        get {
            if(objectMappingList == null) {
                objectMappingList = new List<String>(Utilities.pluckStrings(Utilities.namespaceUnderscore + 'Object_API_Name__c',[
                    SELECT Object_API_Name__c
                    FROM SFDC_Industry_Mapping_Object__mdt WHERE Enabled__c = true ORDER BY Index__c
                ]));
                objectMappingList.sort();
            }
            return objectMappingList;
        }
        set;
    }

    @TestVisible
    static Map<String, SFDC_Industry_Mapping_Object__mdt> fscDescMap {
        get {
            if(fscDescMap == null) {
                fscDescMap = new Map<String, SFDC_Industry_Mapping_Object__mdt>();
                List<SFDC_Industry_Mapping_Object__mdt> mapObjects = [SELECT Object_API_Name__c, Description_Label__c, Hidden_Record_Types__c FROM SFDC_Industry_Mapping_Object__mdt WHERE Enabled__c = true];
                for (SFDC_Industry_Mapping_Object__mdt def : mapObjects) {
                    fscDescMap.put(def.Object_API_Name__c, def);
                }
            }
            return fscDescMap;
        }
        set;
    }

    /***********************************************************************************
     * Retrieves a MappingSection (including section name, and corresponding objects 
     * that should be mapped within that section) for use within the assessment.
     * 
     * @param sectionId - The id of the section metadata to retrieve details for
     * @param hideDetails - If true, does not retrieve field and record type data
     * for the relevant section objects, and only returns the object data
     **********************************************************************************/
    @AuraEnabled
    public static MappingSection getMappingForSection(Id sectionId, Boolean hideDetails){
        //try {
        //Get Section Info
        if(sectionId != null){
            List<SFDC_Industry_Mapping_Section__mdt> sectionInfo = [SELECT Id, DeveloperName, MasterLabel, Description__c
            FROM SFDC_Industry_Mapping_Section__mdt WHERE Id = :sectionId];

            if(sectionInfo.size()>0){
                //Get new mapping
                List<SFDC_Industry_Mapping_Object__mdt> sectionObjects = [SELECT Object_API_Name__c FROM
                SFDC_Industry_Mapping_Object__mdt WHERE Mapping_Section__c = :sectionId ORDER BY Object_API_Name__c];

                List<String> objectNames = new List<String>();
                for (SFDC_Industry_Mapping_Object__mdt objectMeta : sectionObjects) {
                    objectNames.add(objectMeta.Object_API_Name__c);
                }

                MappingSection section = new MappingSection();
                section.sectionTitle = sectionInfo[0].MasterLabel;
                section.sectionValue = sectionInfo[0].DeveloperName;
                section.sectionDescription = sectionInfo[0].Description__c;

                //If hideDetails is false, don't retrieve FSC Schema, just set the names
                ObjectMapping tempMapping;
                // if(hideDetails){
                //     section.sectionMappings = new List<ObjectMapping>();
                //     for (String oName : objectNames) {
                //         tempMapping = new ObjectMapping();
                //         tempMapping.destinationObjectLabel = oName;
                //         tempMapping.destinationObject = oName;
                //         section.sectionMappings.add(tempMapping);
                //     }
                // }else{
                //     section.sectionMappings = buildObjectMappingList(objectNames);
                // }
                section.sectionMappings = buildObjectMappingList(objectNames);
                if(hideDetails){
                    for (ObjectMapping oRow : section.sectionMappings) {
                        oRow.recordTypes = new List<RecordTypes>();
                        oRow.fieldMapping = new List<FieldMapping>();
                    }
                }
                return section;
            }
        }
        return null;
    }

    /***********************************************************************************
     * Deletes all mappings from a particular section (used when revising questions 
     * within the assessment)
     * 
     * @param assessmentId - Id of the current assessment
     * @param answerValues - A list containing all sections to delete
     **********************************************************************************/
    @AuraEnabled
    public static void deleteMappingSection(Id assessmentId, List<String> answerValues){
        Set<String> answerValuesSet = new Set<String>(answerValues);
        String mappingJson = getRecommendedJSON(assessmentId);
        if(!String.isBlank(mappingJson)){
            UpgradeMapping mappingDef = (UpgradeMapping) JSON.deserialize(mappingJson, UpgradeMapping.class);
            for (Integer i = mappingDef.recommended.size()-1; i >= 0; i--) {
                if(answerValuesSet.contains(mappingDef.recommended[i].sectionName)){
                    mappingDef.recommended.remove(i);
                }
            }
            AssessmentService.updateAssessment(new Assessment__c(Id = assessmentId, MappingDataJSON__c = JSON.serialize(mappingDef)));  
        }    
    }

    /***********************************************************************************
     * Retrieves the current saved Mapping data for a specific assessment.
     * 
     * @param assessmentId - The id of the assessment to read from
     **********************************************************************************/
    @AuraEnabled
    public static String getRecommendedJSON(Id assessmentId){
        if(assessmentId!=null){
            Assessment__c requestedAssessment = [
                    SELECT MappingDataJson__c
                    FROM Assessment__c
                    WHERE Id =: assessmentId
                ];
            return requestedAssessment.MappingDataJson__c;
        }
        return null;
    }

    /***********************************************************************************
     * Saves JSON mapping data into the specified assessment.
     * 
     * @param recordId - The id of the assessment to save to
     * @param filename - [Deprecated] The name of the File attachment
     * @param filetype - [Deprecated] The file extension to use when saving
     * @param filedata - The JSON representation of mapping info, as a String
     **********************************************************************************/
    @AuraEnabled
    public static Boolean saveMapping(Id recordId, String filename, String filetype, String filedata, Boolean isEmpty){
        Database.SaveResult assessmentSaveResult = AssessmentService.updateAssessment(new Assessment__c(Id = recordId, MappingDataJSON__c = filedata, HasMappingData__c = !isEmpty));
        return assessmentSaveResult != null ? assessmentSaveResult.isSuccess() : false;
    }

    /***********************************************************************************
     * Gets a map containing the default record types for the given list of
     * sections
     * 
     * @param sectionNames - The list of sections to retrieve records for
     **********************************************************************************/
    @AuraEnabled
    public static Map<String,DefaultRecordType> getDefaultRecordTypes(List<String> sectionNames){
        Map<String, DefaultRecordType> defaultList = new Map<String, DefaultRecordType>();

        if(sectionNames!=null && !sectionNames.isEmpty()){
            List<SFDC_Industry_Default_Record_Type__mdt> defaultRecordTypes = 
            [SELECT API_Name__c, Additional_Information__c, Controlling_Question_Value__c, Related_Object__r.Object_API_Name__c
            FROM SFDC_Industry_Default_Record_Type__mdt 
            WHERE Controlling_Question_Value__c IN :sectionNames];

            for (SFDC_Industry_Default_Record_Type__mdt defaultRt : defaultRecordTypes) {
                defaultRt.Additional_Information__c = ToolingService.customLabelMap.get(Utilities.namespaceUnderscore + defaultRt.Additional_Information__c);
                defaultList.put(defaultRt.Controlling_Question_Value__c+defaultRt.Related_Object__r.Object_API_Name__c, 
                new DefaultRecordType(defaultRt.Controlling_Question_Value__c+defaultRt.Related_Object__r.Object_API_Name__c, defaultRt.API_Name__c, defaultRt.Additional_Information__c));
            }

            
        }
        
        return defaultList;    
    }

    /***********************************************************************************
     * Retrieves the object schema for the current org
     **********************************************************************************/
    @AuraEnabled
    public static List<String> getOrgDefinition(){
		return SchemaService.getObjectsForOrg();
    }

    /***********************************************************************************
     * Retrieves specific field and record type information for the specified
     * SObject
     * 
     * @param apiName - The API Name of the SObject to retrieve details for
     **********************************************************************************/
    @AuraEnabled
    public static ObjectDef getInfoForSObject(String apiName){
			SchemaService.SchemaModel schemaModel = SchemaService.getSchemaModel(apiName);
			schemaModel.populateRecordTypeCounts();
			ObjectDef definition = new ObjectDef(schemaModel);
			return definition;
    }

    /***********************************************************************************
     * Given an Assessment record, retrieves and parses its respective mapping.
     * 
     * @param assessmentRecord - An Assessment__c record that contains mapping data
     * to be extracted and parsed
     **********************************************************************************/
    public static UpgradeMapping getExistingMapping (Assessment__c assessmentRecord){
        try{
            if(assessmentRecord!=null && assessmentRecord.MappingDataJson__c!=null){
                    return (UpgradeMapping) System.JSON.deserialize(
                        assessmentRecord.MappingDataJson__c,
                        UpgradeMapping.class
                    );
            }
        } catch(System.JSONException e){
            throw new AuraHandledException(e.getMessage());
        }
        return null;
    }

    /***********************************************************************************
     * For use within the final "mapping review" screen of the assessment. Retrieves
     * and parses the MappingDataJson__c value for the specified assessment record.
     * 
     * @param assessmentId - The id of the assessment to read from
     **********************************************************************************/
    @AuraEnabled
    public static UpgradeMapping getObjectMappingForAssessment(Id assessmentId){
        //try {
            Assessment__c requestedAssessment = [
                SELECT MappingDataJson__c
                FROM Assessment__c
                WHERE Id =: assessmentId
            ];

            //UpgradeMapping serializedMapping = (UpgradeMapping) JSON.deserialize(requestedAssessment.MappingDataJson__c, UpgradeMapping.class);
            UpgradeMapping serializedMapping = getExistingMapping(requestedAssessment);

            //Grab relevant data to add to mappings
            Set<String> fscDefs = new Set<String>();
            
            if(serializedMapping!=null){
                //Set Source Schema
                for (ObjectMapping sections : serializedMapping.recommended) {
                    for (MappingSelection recMapping : sections.mappingData) {
                        if(!String.isBlank(recMapping.source)){
                            recMapping.sourceDef = getInfoForSObject(recMapping.source);
                        }
                        if(!String.isBlank(recMapping.destination)){
                            fscDefs.add(recMapping.destination);
                        }
                    }
                }

                for (MappingSelection addMapping : serializedMapping.additional) {
                    if(!String.isBlank(addMapping.source)){
                        addMapping.sourceDef = getInfoForSObject(addMapping.source);
                    }
                    if(!String.isBlank(addMapping.destination)){
                        fscDefs.add(addMapping.destination);
                    }
                }

                //Set FSC Schema
                ExternalUtilities.ExternalSchema fscSchema = ExternalUtilities.requestFSCObjectSchema(new List<String>(fscDefs));
                if(fscSchema != null) {
                    for (ObjectMapping sections : serializedMapping.recommended) {
                        for(MappingSelection recMapping : sections.mappingData) {
                            Map<String, Object> requestedSchema = (Map<String, Object>)fscSchema.get(recMapping.destination);
                            if(requestedSchema != null) {
                                recMapping.destinationDef = new ObjectMapping(requestedSchema);
                            }
                        }
                    }

                    serializedMapping.recommended = removeHiddenValues(serializedMapping.recommended);
                    
                    for(MappingSelection addMapping : serializedMapping.additional) {
                        Map<String, Object> requestedSchema = (Map<String, Object>)fscSchema.get(addMapping.destination);
                        if(requestedSchema != null) {
                            addMapping.destinationDef = new ObjectMapping(requestedSchema);
                        }
                    }
                }
            }else{
                //If empty (all questions skipped, just produce a blank UpgradeMapping)
                serializedMapping = new UpgradeMapping();
                serializedMapping.recommended = new List<ObjectMapping>();
                serializedMapping.additional = new List<MappingSelection>();
            }

            return serializedMapping;
    }

    /***********************************************************************************
     * Retrieves the object schema for the FSC reference org
     **********************************************************************************/
    @AuraEnabled
    public static List<ObjectMapping> getFSCSchema(){
        List<ObjectMapping> fscSchema = buildObjectMappingList(objectMappingList);

        return removeHiddenValues(fscSchema);
    }

    private static List<ObjectMapping> removeHiddenValues(List<ObjectMapping> mapping){
        //Get Mapping Object Metadata to check for hidden rt's/fields
        Map<String, Set<String>> objectNameToHiddenRtMap = new Map<String, Set<String>>();
        List<SFDC_Industry_Mapping_Object__mdt> objectMeta = [SELECT Id, Object_API_Name__c, Hidden_Record_Types__c From SFDC_Industry_Mapping_Object__mdt Limit :(Limits.getLimitQueryRows() - Limits.getQueryRows())];
        for (SFDC_Industry_Mapping_Object__mdt objectMap : objectMeta) {
            if(!String.isBlank(objectMap.Hidden_Record_Types__c)){
                objectNameToHiddenRtMap.put(objectMap.Object_API_Name__c, new Set<String>(objectMap.Hidden_Record_Types__c.split(',')));
            }
        }

        for (ObjectMapping objectMap : mapping) {
            if(objectNameToHiddenRtMap.containsKey(objectMap.sourceObject)){
                for (Integer i = objectMap.recordTypes.size()-1; i >=0; i--) {
                    if(objectNameToHiddenRtMap.get(objectMap.sourceObject).contains(objectMap.recordTypes[i].source)){
                        objectMap.recordTypes.remove(i);
                    }
                }
            }
        }
        return mapping;
    }

    /***********************************************************************************
     * Constructs a wrapper object representing the object data for the list of 
     * objects specified (containing field and record type data as well).
     * 
     * @param objectList - A list of Strings representing the API Names for the objects
     * to retrieve data for
     **********************************************************************************/
    public static List<ObjectMapping> buildObjectMappingList(List<String> objectList) {
        List<ObjectMapping> objectMapping = new List<ObjectMapping>();

        ExternalUtilities.ExternalSchema schemaMap = ExternalUtilities.requestFSCObjectSchema(objectList);
        if(schemaMap != null) {
            for(String requestedObject : objectList) {
                Map<String, Object> requestedSchema = (Map<String, Object>)schemaMap.get(requestedObject);
                if(requestedSchema != null) {
                    objectMapping.add(new ObjectMapping(requestedSchema));
                }
            }
        }
        return objectMapping;
    }

    /***********************************************************************************
     * Retrieves and organizes the components (objects, fields, record types, etc.) 
     * that are involved in a particular mapping.
     * 
     * 2 versions: one accepts the id of an assessment and one accepts an 
     * assessment record.
     * 
     * @param assessmentId - The id of the assessment to read mapping data from
     * or
     * @param assessment - The assessment to read mapping data from. This should 
     * only be used if the "MappingDataJson__c" field has been retrieved
     **********************************************************************************/
    public static MappedComponents parseMappedComponents(Id assessmentId){
        //load saved object mapping
        Assessment__c assessment = AssessmentService.queryAssessment(assessmentId);
        //parse
        return parseMappedComponents(assessment);
    }

    public static MappedComponents parseMappedComponents(Assessment__c assessment){
        MappedComponents result = new MappedComponents();
        MappingService.UpgradeMapping mapping = MappingService.getExistingMapping(assessment);

        //prepare object mapping for matching and filters
        if(mapping != null){
            //Run through the Recommended list
            if (mapping.recommended != null) {
                for (MappingService.ObjectMapping objectMapping : mapping.recommended) {
                    //collect mapped object
                    if (objectMapping.mappingData != null) {
                        for (MappingService.MappingSelection mappingData : objectMapping.mappingData) {
                            //map object info
                            if (String.isNotBlank(mappingData.source) && String.isNotBlank(mappingData.destination)) {
                                result.mappedObjects.add(mappingData.source);
                                result.sourceToDestinationObject.put(mappingData.source.replace('__c', ''), mappingData.destination);
                            }
                            //collect mapped record types
                            if (mappingData.recordTypeMapping != null) {
                                for (MappingService.RecordTypes recordTypeMapping : mappingData.recordTypeMapping) {
                                    if (String.isNotBlank(recordTypeMapping.source) && String.isNotBlank(recordTypeMapping.destination)) {
                                        recordTypeMapping.sourceObject = mappingData.source;
                                        result.recordTypeMappings.add(recordTypeMapping);
                                        result.sourceToDestinationRecordType.put(mappingData.source.replace('__c', '')+'.'+recordTypeMapping.source, mappingData.destination+'.'+recordTypeMapping.destination);
                                        //result.sourceToDestinationRecordType.put(mappingData.source+'.'+recordTypeMapping.source, mappingData.destination+'.'+recordTypeMapping.destination);
                                    }
                                }
                            }
                            //collect mapped fields
                            if (mappingData.fieldMapping != null) {
                                for (MappingService.FieldMapping fieldMapping : mappingData.fieldMapping) {
                                    if (String.isNotBlank(fieldMapping.source) && String.isNotBlank(fieldMapping.destination)) {
                                        fieldMapping.sourceObject = mappingData.source;
                                        result.fieldMappings.add(fieldMapping);
                                        result.mappedFields.add(mappingData.source + '.' + fieldMapping.source);
                                        //result.sourceToDestinationField.put(fieldMapping.source.replace('__c', ''), fieldMapping.destination);
                                        result.sourceToDestinationField.put(mappingData.source+'.'+fieldMapping.source, mappingData.destination+'.'+fieldMapping.destination);
                                    }
                                }
                            }
                        }
                    }
                }
            }
            //Run through the Additional list
            if(mapping.additional != null){
                for (MappingService.MappingSelection mappingData : mapping.additional) {
                    //map object info
                    if (String.isNotBlank(mappingData.source) && String.isNotBlank(mappingData.destination)) {
                        result.mappedObjects.add(mappingData.source);
                        result.sourceToDestinationObject.put(mappingData.source.replace('__c', ''), mappingData.destination);
                    }
                    //collect mapped record types
                    if (mappingData.recordTypeMapping != null) {
                        for (MappingService.RecordTypes recordTypeMapping : mappingData.recordTypeMapping) {
                            if (String.isNotBlank(recordTypeMapping.source) && String.isNotBlank(recordTypeMapping.destination)) {
                                recordTypeMapping.sourceObject = mappingData.source;
                                result.recordTypeMappings.add(recordTypeMapping);
                                result.sourceToDestinationRecordType.put(mappingData.source.replace('__c', '')+'.'+recordTypeMapping.source, mappingData.destination+'.'+recordTypeMapping.destination);
                                //result.sourceToDestinationRecordType.put(mappingData.source+'.'+recordTypeMapping.source, mappingData.destination+'.'+recordTypeMapping.destination);
                            }
                        }
                    }
                    //collect mapped fields
                    if (mappingData.fieldMapping != null) {
                        for (MappingService.FieldMapping fieldMapping : mappingData.fieldMapping) {
                            if (String.isNotBlank(fieldMapping.source) && String.isNotBlank(fieldMapping.destination)) {
                                fieldMapping.sourceObject = mappingData.source;
                                result.fieldMappings.add(fieldMapping);
                                result.mappedFields.add(mappingData.source + '.' + fieldMapping.source);
                                //result.sourceToDestinationField.put(fieldMapping.source.replace('__c', ''), fieldMapping.destination);
                                result.sourceToDestinationField.put(mappingData.source+'.'+fieldMapping.source, mappingData.destination+'.'+fieldMapping.destination);
                            }
                        }
                    }
                }
            }
        }

        return result;
    }

    /***********************************************************************************
     * Calls out to the external Heroku mapping file service to generate an 
     * xlsx document for a given mapping file, and return the Id of the content to 
     * download
     * 
     * @param recordId - The id of the assessment to save to
     * @param forceRefresh - If true, makes a callout to Heroku regardless of whether
     * or not there is an existing xlsx document for this assessment
     **********************************************************************************/
    @AuraEnabled
    public static String generateMappingFile(Id recordId, Boolean forceRefresh){
        String documentId;
        //Check if file already exists (can just query that rather than generating a new doc)
        ContentVersion fileVersion;
        if(!forceRefresh){
            documentId = FileUtility.getContentDocumentIdByName(recordId, FILENAME_MAPPINGDOC);
        }

        //Call out to ExternalUtilities function, with the given info.
        if(forceRefresh || documentId==null){
            Assessment__c assessment = [SELECT MappingDataJson__c FROM Assessment__c WHERE Id = :recordId];
            ExternalUtilities.MappingDocumentBody docBody = convertMappingBody(assessment);

            System.debug('==BODY: '+JSON.serialize(docBody));
            
            if(docBody.Content.Sheets.size()>0){
                ExternalUtilities.MappingDocResponse res = ExternalUtilities.requestMappingXLSXDocument(docBody);

                if(res.xlsxData==null){
                    return null;
                }

                System.debug('==XLSX Data: '+res.xlsxData);

                //Insert file
                documentId = FileUtility.writeFileData(recordId, FILENAME_MAPPINGDOC, FILEEXTENSION_MAPPINGDOC, res.xlsxData);
            }
            
        }

        return documentId;
    }

    /***********************************************************************************
     * Helper function that takes a "recommend|additional" mapping configuration, and
     * converts it into spreadsheet-like format.
     * 
     * @param assessment - The assesment to grab and convert the mapping from
     **********************************************************************************/
    private static ExternalUtilities.MappingDocumentBody convertMappingBody(Assessment__c assessment){
        
        //Map out mappings from both sections
        Map<String, ExternalUtilities.MappingDocumentSheet> objectNameToConfigMap = new Map<String, ExternalUtilities.MappingDocumentSheet>();
        UpgradeMapping mappingObject = getExistingMapping(assessment);

        ExternalUtilities.MappingDocumentSheet currentSheet;
        List<ExternalUtilities.MappingDocumentColumn> columnList;
        List<Integer> columnWidths;



        for (ObjectMapping section : mappingObject.recommended) {
            for (MappingSelection sectionRow : section.mappingData) {
                objectNameToConfigMap = generateSheet(section.sectionName, sectionRow, objectNameToConfigMap);
            }
        }

        for (MappingSelection additionalRow : mappingObject.additional) {
            objectNameToConfigMap = generateSheet(SECTION_ADDITIONAL, additionalRow, objectNameToConfigMap);
        }

        //Truncate and number sheets
        Integer sheetCount = 1;
        String sheetName;
        for (ExternalUtilities.MappingDocumentSheet sheet : objectNameToConfigMap.values()) {
            //sheet.Name = sheet.Name.replace('FinServ__', '');
            sheetName = sheetCount+') ';
            sheetName += sheet.Name.abbreviate(MAX_SHEET_NAME_SIZE);
            sheet.Name = sheetName;
            sheetCount++;
        }

        return new ExternalUtilities.MappingDocumentBody(new ExternalUtilities.MappingDocumentContent(objectNameToConfigMap.values()), FILEEXTENSION_MAPPINGDOC.toUpperCase());
    }

    /***********************************************************************************
    * Helper function that iterates through a MappingSelection and returns a 
    * MappingDocumentSheet
    * 
    * @param sectionName - If present, the current section to use
    * @param selection - The current selection to run through
    * @param objectNameToConfigMap - The current map containing all sheets for 
    * this doc
    **********************************************************************************/
    private static Map<String, ExternalUtilities.MappingDocumentSheet> generateSheet(String sectionName, MappingSelection selection, Map<String, ExternalUtilities.MappingDocumentSheet> objectNameToConfigMap){
        ExternalUtilities.MappingDocumentSheet currentSheet;
        List<ExternalUtilities.MappingDocumentColumn> columnList = new List<ExternalUtilities.MappingDocumentColumn>();
        List<Integer> columnWidths= new List<Integer>{sectionName.length(), ROWVALUE_RECORDTYPE.length()}; 
        
        for (SFDC_Industry_Mapping_Export_Definition__mdt column : COLUMNS_MAPPINGDOC) {
            columnWidths.add(column.Label_Name__c.length());
        }

        System.debug('Check Additional for Key: '+selection.destination);
        System.debug('Already present?: '+objectNameToConfigMap.containsKey(selection.destination));

        currentSheet = (objectNameToConfigMap.containsKey(selection.destination)) ? objectNameToConfigMap.get(selection.destination) : new ExternalUtilities.MappingDocumentSheet(selection.destination);
        if(objectNameToConfigMap.containsKey(selection.destination)){
            columnList = currentSheet.Columns;
            columnWidths = new List<Integer>(); 
            
            for (ExternalUtilities.MappingDocumentColumn column : columnList) {
                columnWidths.add(column.Width);
            }
        }

        List<String> sheetRow;
        if(selection.fieldMapping!=null){
            for (FieldMapping fieldRow : selection.fieldMapping) {

                //Retrieve fieldRow data to allow for dynamic value retrieval
                Map<String, Object> newMetaMap = (fieldRow.newMeta!=null) ? fieldRow.newMeta.mapify() : null;

                if(fieldRow.source!=null && fieldRow.destination!=null){
                    //Add initial field data
                    sheetRow = new List<String>{sectionName, ROWVALUE_FIELD, selection.source, selection.destination, fieldRow.source, fieldRow.destination};

                    //If this is a new field, add those values to the row
                    if(newMetaMap!=null){
                        sheetRow.addAll(new List<String>{fieldRow.newMeta.dataType, ''+fieldRow.newMeta.required, fieldRow.newMeta.length, fieldRow.newMeta.decimalPlaces});
                        //sheetRow.add(fieldRow.newMeta.conflict);
                    }

                    //Add row to sheet
                    currentSheet.DataRows.add(sheetRow);



                    //Potentially set column widths
                    // if(selection.source.length() > columnWidths[COLUMN_INDEX_SOURCE_OBJECT]){
                    //     columnWidths[COLUMN_INDEX_SOURCE_OBJECT] = selection.source.length();
                    // }
                    // if(selection.destination.length() > columnWidths[COLUMN_INDEX_DEST_OBJECT]){
                    //     columnWidths[COLUMN_INDEX_DEST_OBJECT] = selection.destination.length();
                    // }
                    // if(fieldRow.source.length() > columnWidths[COLUMN_INDEX_SOURCE]){
                    //     columnWidths[COLUMN_INDEX_SOURCE] = fieldRow.source.length();
                    // }
                    // if(fieldRow.destination.length() > columnWidths[COLUMN_INDEX_DEST]){
                    //     columnWidths[COLUMN_INDEX_DEST] = fieldRow.destination.length();
                    // }
                }
            }
        }
        
        if(selection.recordTypeMapping!=null){
            for (RecordTypes rtRow : selection.recordTypeMapping) {
                if(rtRow.source!=null && rtRow.destination!=null){
                    currentSheet.DataRows.add(new List<String>{sectionName, ROWVALUE_RECORDTYPE, selection.source, selection.destination, rtRow.source, rtRow.destination});

                    //Potentially set column widths
                    // if(selection.source.length() > columnWidths[COLUMN_INDEX_SOURCE_OBJECT]){
                    //     columnWidths[COLUMN_INDEX_SOURCE_OBJECT] = selection.source.length();
                    // }
                    // if(selection.destination.length() > columnWidths[COLUMN_INDEX_DEST_OBJECT]){
                    //     columnWidths[COLUMN_INDEX_DEST_OBJECT] = selection.destination.length();
                    // }
                    // if(rtRow.source.length() > columnWidths[COLUMN_INDEX_SOURCE]){
                    //     columnWidths[COLUMN_INDEX_SOURCE] = rtRow.source.length();
                    // }
                    // if(rtRow.destination.length() > columnWidths[COLUMN_INDEX_DEST]){
                    //     columnWidths[COLUMN_INDEX_DEST] = rtRow.destination.length();
                    // }
                }
            }
        }
        
        columnList = new List<ExternalUtilities.MappingDocumentColumn>();
        for (Integer i = 0; i < COLUMNS_MAPPINGDOC.size(); i++) {
            columnList.add(new ExternalUtilities.MappingDocumentColumn(COLUMNS_MAPPINGDOC[i].Label_Name__c, columnWidths[i]));
        }
        currentSheet.Columns = columnList;

        //Add sheet to map
        if(currentSheet.DataRows.size()>0){
            objectNameToConfigMap.put(selection.destination, currentSheet);
        } 
        return objectNameToConfigMap;
    }

    /***********************************************************************************
    * If present, retreives the Mapping XLSX document Id for the given assessment.
    * 
    * @param assessment - The assesment to grab the file Id for.
    **********************************************************************************/
    @AuraEnabled
    public static String getMappingFileLink(Id recordId){
        return FileUtility.getContentDocumentIdByName(recordId, FILENAME_MAPPINGDOC);
    }

    /***********************************************************************************
     * Wrappers for Mapping data
     **********************************************************************************/
    public class UpgradeMapping {
        @AuraEnabled
        public List<ObjectMapping> recommended;

        @AuraEnabled
        public List<MappingSelection> additional;

        public UpgradeMapping() {}
    }

    public class ObjectMapping {
        @AuraEnabled
        public String sectionName;
        @AuraEnabled
        public String sourceObject;
        @AuraEnabled
        public String sourceObjectLabel;
        @AuraEnabled
        public String sourceObjectDesc;
        @AuraEnabled
        public String destinationObject;
        @AuraEnabled
        public String destinationObjectLabel;
        @AuraEnabled
        public String destinationObjectDesc;
        @AuraEnabled
        public List<RecordTypes> recordTypes;
        @AuraEnabled
        public List<FieldMapping> fieldMapping;
        @AuraEnabled
        public List<FieldSetMapping> fieldSets;
        @AuraEnabled
        public List<MappingSelection> mappingData;

        public ObjectMapping() {}

        public ObjectMapping(Map<String, Object> schema) {
            SFDC_Industry_Mapping_Object__mdt objectMeta = fscDescMap.get((String)schema.get('name'));
            Set<String> hiddenRts = new Set<String>();
            if(!String.isBlank(objectMeta.Hidden_Record_Types__c)){
                hiddenRts = new Set<String>(objectMeta.Hidden_Record_Types__c.split(','));
            }
            this.sourceObject = (String)schema.get('name');
            this.sourceObjectLabel = (String)schema.get('label') + ' (' + (String)schema.get('name') + ')';
            this.sourceObjectDesc =  ToolingService.customLabelMap.get(Utilities.namespaceUnderscore+objectMeta.Description_Label__c);
            this.recordTypes = new List<RecordTypes>();
            this.fieldMapping = new List<FieldMapping>();
            this.fieldSets = new List<FieldSetMapping>();
            //this.mappingSelection = new List<MappingSelection>();

            List<Object> recordTypeInfos = (List<Object>)schema.get('recordTypeInfos');
            RecordTypes newRt = new RecordTypes();
            //TODO: Move to label
            newRt.label = '+ New Record Type';
            newRt.value = 'new';
            this.recordTypes.add(newRt);
            Map<String, Object> recordTypeInfoMap;
            if(recordTypeInfos != null) {
                for(Object recordTypeInfo : recordTypeInfos) {
                    recordTypeInfoMap = (Map<String, Object>)recordTypeInfo;
                    if(!hiddenRts.contains((String)recordTypeInfoMap.get('developerName'))){
                        this.recordTypes.add(new RecordTypes(recordTypeInfoMap));
                    }
                }
            }

            List<Object> fields = (List<Object>)schema.get('fields');
            FieldMapping newField = new FieldMapping();
            //TODO: Move to label
            newField.label = '+ New Field';
            newField.value = 'new';
            this.fieldMapping.add(newField);
            if(fields != null) {
                for(Object field : fields) {
                    this.fieldMapping.add(new FieldMapping((Map<String, Object>)field));
                }
            }
        }
    }

	public virtual class MappingItem {
        @AuraEnabled
        public String source;
        @AuraEnabled
        public String sourceLabel;
        @AuraEnabled
        public String destination;
        @AuraEnabled
        public String destinationLabel;
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String value;

        public MappingItem(){
            this.label = sourceLabel;
            this.value = source;
        }
	}

    public class FieldMapping extends MappingItem {
        @AuraEnabled
        public String truncate;
        @AuraEnabled
        public String type;
        @AuraEnabled
        public String userGenerated;
        @AuraEnabled
        public NewFieldMeta newMeta;

        //public Map<String,String> newMeta;
        public String sourceObject;

        public FieldMapping() {}

        public FieldMapping(Map<String, Object> fieldInfo) {
            this.source = (String)fieldInfo.get('name');
            String dataType = (String)fieldInfo.get('type');
            this.sourceLabel = (String)fieldInfo.get('label') + ' (' +this.source + ') ' + ' ('+dataType.capitalize()+')';
            this.type = dataType;
            this.label = this.sourceLabel;
            this.value = this.source;
        }
    }

    public class FieldSetMapping extends MappingItem {

    }

    public class RecordTypes extends MappingItem {

        @AuraEnabled
        public String recordTypeId;
        @AuraEnabled
        public Boolean available;
        @AuraEnabled
        public Boolean defaultRecordTypeMapping;
        @AuraEnabled
        public Boolean master;
        @AuraEnabled
        public String userGenerated;
        @AuraEnabled
        public NewRecordTypeMeta newMeta;

        //public Map<String,String> newMeta;
        public String sourceObject;

        public RecordTypes() {}

        public RecordTypes(Map<String, Object> recordTypeInfo) {
            this.source = (String)recordTypeInfo.get('developerName');
            this.sourceLabel = (String)recordTypeInfo.get('name') + ' (' + this.source +')';
            this.recordTypeId = (String)recordTypeInfo.get('recordTypeId');
            this.available = (Boolean)recordTypeInfo.get('available');
            this.defaultRecordTypeMapping = (Boolean)recordTypeInfo.get('defaultRecordTypeMapping');
            this.master = (Boolean)recordTypeInfo.get('master');
            this.label = this.sourceLabel;
            this.value = this.source;
        }
    }

    public class MappingSelection {
        @AuraEnabled
        public Boolean showDetails {get;set;}

        @AuraEnabled
        public String source {get;set;}

        @AuraEnabled
        public String destination {get;set;}

        @AuraEnabled
        public ObjectDef sourceDef {get;set;}

        @AuraEnabled
        public ObjectMapping destinationDef {get;set;}

        @AuraEnabled
        public List<RecordTypes> recordTypeMapping {get;set;}

        @AuraEnabled
        public List<FieldMapping> fieldMapping {get;set;}

        public MappingSelection() {}
    }

    //BB Todo: Enhance to be more universal
    public class ObjectDef {
        //API Name
        @AuraEnabled
        public String value {get;set;}

        //Object Label
        @AuraEnabled
        public String label {get;set;}

        @AuraEnabled
        public List<PicklistUtility.ComboboxValue> recordTypes {get;set;}

        @AuraEnabled
        public List<PicklistUtility.ComboboxValue> fields {get;set;}

        @AuraEnabled
				public List<PicklistUtility.ComboboxValue> fieldSets {get;set;}

				public ObjectDef(SchemaService.SchemaModel schemaModel){
					this.value = schemaModel.value;
					this.label = schemaModel.label;
					this.recordTypes = PicklistUtility.getComboboxValues(schemaModel.recordTypes);
					this.fields = PicklistUtility.getComboboxValues(schemaModel.fields);
					this.fieldSets = PicklistUtility.getComboboxValues(schemaModel.fieldSets);
				}
    }

    public class MappingSection {
        @AuraEnabled
        public String sectionTitle {get;set;}
        @AuraEnabled
        public String sectionValue {get;set;}
        @AuraEnabled
        public String sectionDescription {get;set;}
        @AuraEnabled
        public List<ObjectMapping> sectionMappings {get;set;}
    }

    public virtual class NewMeta {
        @AuraEnabled
        public String label {get;set;}
        @AuraEnabled
        public String apiName {get;set;}
        @AuraEnabled
        public String description {get;set;}
        @AuraEnabled 
        public String conflict {get;set;}

        public NewMeta() {}

        public NewMeta(String label, String apiName, String description, String conflict){
            this.label = label;
            this.apiName = apiName;
            this.description = description;
            this.conflict = conflict;
        }

        public Map<String, Object> mapify(){
            return (Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(this));
        }
    }

    public class NewRecordTypeMeta extends NewMeta {
        @AuraEnabled
        public Boolean active {get;set;}

        public NewRecordTypeMeta() {}

        public NewRecordTypeMeta(String label, String apiName, String description, String conflict, Boolean active){
            super(label, apiName, description, conflict);
            this.active = active;
        }
    }

    public class NewFieldMeta extends NewMeta {
        @AuraEnabled
        public String dataType {get;set;}
        @AuraEnabled
        public String helpText {get;set;}
        @AuraEnabled
        public String length {get;set;}
        @AuraEnabled
        public String decimalPlaces {get;set;}
        @AuraEnabled
        public Boolean required {get;set;}
        @AuraEnabled
        public Boolean unique {get;set;}
        @AuraEnabled
        public String defaultValue {get;set;}
        @AuraEnabled
        public String connectedObject {get;set;}
        @AuraEnabled
        public String childRelationshipName {get;set;}

        public NewFieldMeta() {}

        public NewFieldMeta(String label, String apiName, String description, String conflict, String dataType, String helpText, String length, String decimals, Boolean required){
            super(label, apiName, description, conflict);
            this.dataType = dataType;
            this.helpText = helpText;
            this.length = length;
            this.decimalPlaces = decimals;
            this.required = required;
        }
    }

    /***********************************************************************************
     * Wrapper for Default Record Type Data
     **********************************************************************************/
    public class DefaultRecordType {
        @AuraEnabled
        public String key {get;set;}
        @AuraEnabled
        public String apiName {get;set;}
        @AuraEnabled
        public String additionalInfo {get;set;}

        public DefaultRecordType(String key, String apiName, String additionalInfo){
            this.key = key;
            this.apiName = apiName;
            this.additionalInfo = additionalInfo;
        }
    }

    /***********************************************************************************
     * Wrapper for scanning/automation using mapping data
     **********************************************************************************/
    public class MappedComponents {
        public Map<String,String> sourceToDestinationObject {get;set;}
        public Map<String,String> sourceToDestinationField {get;set;}
        public Map<String,String> sourceToDestinationRecordType {get;set;}
        public Map<String,List<String>> objectToRecordTypes {get;set;}
        public Set<String> mappedObjects {get;set;}
        public Set<String> mappedFields {get;set;}
        public List<FieldMapping> fieldMappings {get;set;}
        public List<RecordTypes> recordTypeMappings {get;set;}

        public MappedComponents() {
            this.sourceToDestinationObject = new Map<String, String>();
            this.sourceToDestinationField = new Map<String, String>();
            this.sourceToDestinationRecordType = new Map<String, String>();
            this.objectToRecordTypes = new Map<String,List<String>>();
            this.mappedObjects = new Set<String>();
            this.mappedFields = new Set<String>();
            this.fieldMappings = new List<FieldMapping>();
            this.recordTypeMappings = new List<RecordTypes>();
        }
    }

}