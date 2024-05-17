/**
 * The purpose of this utility class is to interact with Salesforce Files (ContentDocument).
 */
public inherited sharing class FileUtility {
    private static final Integer MAX_FILE_BYTES = Limits.getLimitHeapSize(); //TODO refine
    private static final Set<String> SUPPORTED_FILE_TYPES = new Set<String> {
        'json', 'csv', 'pdf'
    };

    /**
     * Query and load file content data as String
     * @param recordId - Parent record a ContentDocument file is related to via ContentDocumentId
     * @param filename - Title of a ContentDocument file stored (without file extension)
     */
    public static String readFileDataString(Id recordId, String filename) {
        Blob data = readFileData(recordId, filename);
        return data != null ? data.toString() : null;
    }

    /**
     * Returns the ContentDocument Id for a given file
     * @param recordId - Parent record a ContentDocument file is related to via ContentDocumentId
     * @param filename - Title of a ContentDocument file stored (without file extension)
     */
    public static Id getContentDocumentIdByName(Id recordId, String filename) {
        return getLatestContentVersion(recordId, filename)?.ContentDocumentId;
    }

    /**
     * Query and load file content data
     * @param recordId - Parent record a ContentDocument file is related to via ContentDocumentId
     * @param filename - Title of a ContentDocument file stored (without file extension)
     * TBD determine maximum file sizes for display in SF -- larger responses will require link to file
     * TODO add error handling
     */
	public static Blob readFileData(Id recordId, String filename) {
		return getLatestContentVersion(recordId, filename)?.VersionData;
    }

    /**
     * Write file content data as String
     * @param recordId - Parent record a ContentDocument will be related to via ContentDocumentId
     * @param filename - Title of a ContentDocument file to be stored (without file extension)
     * @param filetype - File content type extension
     * @param filedata - Raw file content
	 * TBD determine maximum file sizes for display in SF -- larger responses will require link to file
     * TODO read file existing first to set new version or overrwrite
     * TODO add error handling
	 */
    public static Id writeFileData(Id recordId, String filename, String filetype, String filedata) {
        return writeFileData(recordId, filename, filetype, Blob.valueOf(filedata));
    }
    public static Id writeFileData(Id recordId, String filename, String filetype, Blob filedata) {
        Id contentDocumentId;
        //Insert ContentVerson record with file data and name
        ContentVersion cv = new ContentVersion();
        cv.ContentLocation = 'S';
        cv.VersionData = filedata;
        cv.Title = filename;
        cv.PathOnClient = filename + '.' + filetype; //or csv or json
        Database.SaveResult insertResult = insertContent(cv);

        //Get ContentDocumentId and link to record with ContentDocumentLink
        if (insertResult != null && insertResult.isSuccess()) {
            cv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: insertResult.getId()];
            contentDocumentId = cv.ContentDocumentId;
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = cv.ContentDocumentId;
            cdl.LinkedEntityId = recordId; //use Assessment record Id
            cdl.ShareType = 'V'; //View
            insertContent(cdl);
        }

        return contentDocumentId;
    }

    private static ContentVersion getLatestContentVersion(Id recordId, String filename) {
        ContentVersion fileVersion;
        if (recordId != null && String.isNotBlank(filename)) {
			List<ContentDocumentLink> cdls = [
				SELECT ContentDocumentId
				FROM ContentDocumentLink
                WHERE LinkedEntityId = :recordId
                    AND ContentDocument.Title = :filename
                    AND ContentDocument.FileExtension IN :SUPPORTED_FILE_TYPES
                    ORDER BY ContentDocument.CreatedDate DESC LIMIT 1
			];

			if (!cdls.isEmpty()) {
				//Get file data -- most likely need to check file size first before getting contents -- small files only
				List<ContentVersion> fileVersions = [
					SELECT Id, ContentDocumentId, ContentSize, ContentUrl, FileExtension, VersionData
					FROM ContentVersion
					WHERE ContentDocumentId = :cdls[0].ContentDocumentId
					AND IsLatest = true
				];

				if (!fileVersions.isEmpty()) {
					fileVersion = fileVersions[0];
					/*switch on fileVersionData[0].FileExtension {
						when 'json' {
							try {
								String jsonDataStr = fileVersionData[0].VersionData.toString();
							} catch (JSONException e) {
								System.debug('Corrupt file: ' + e.getMessage());
							}
						}
						when 'csv' {
							List<String> dataRows = fileVersionData[0].VersionData.toString().split('\n');
							List<String> headerColumns = dataRows[0].split(',');
							System.debug('CSV Data Columns: ' + String.join(headerColumns, ','));
						}
					}*/
				}
			}
		}
        return fileVersion;
    }

    /**
     * Insert content sobject with Object and FLS security checks
     */
    private static Database.SaveResult insertContent(SObject contentRecord) {
        Database.SaveResult result;
        try {
            // Strip fields that are not updateable and perform object update access check
            SObjectAccessDecision decision = Security.stripInaccessible(AccessType.CREATABLE, new List<SObject>{contentRecord}, true);
            result = Database.insert(decision.getRecords())[0];
        } catch (System.NoAccessException e) {
            //No object update access
        }
        return result;
    }
}