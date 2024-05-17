/**
 * Utility class for performing industry upgrade readiness checks and component
 * dependency scans for migrating to a Salesforce industry cloud
 */
public inherited sharing class TransitionReadinessUtility {

	//Assessment run details
	private static String assessmentVersion {
		get {
			if (assessmentVersion == null) {
				assessmentVersion = 'DEV';
				if (String.isNotBlank(Utilities.namespace)) {
					ToolingService.InstalledSubscriberPackage installedPackage = ToolingService.installedPackageMap.get(Utilities.namespace);
					assessmentVersion = Utilities.namespace;//not in dev mode
					if (installedPackage != null && installedPackage.SubscriberPackageVersion != null) {
						assessmentVersion = installedPackage.SubscriberPackageVersion.MajorVersion + '.' +
											installedPackage.SubscriberPackageVersion.MinorVersion + '.' +
											installedPackage.SubscriberPackageVersion.PatchVersion + '-' +
											installedPackage.SubscriberPackageVersion.BuildNumber;
					}
				}
			}
			return assessmentVersion;
		}
		private set;
	}
	private static final String INSTANCE_EDITION = [SELECT OrganizationType FROM Organization WHERE Id = :UserInfo.getOrganizationId()].OrganizationType;
	private static final String INSTANCE_ID = UserInfo.getOrganizationId();

	private static final String ASSESSMENT_STATUS_SCAN = 'Scanning';
	private static final String ASSESSMENT_STATUS_REVIEW = 'Review';

	private static final String ASSESSMENT_SUBSTATUS_INITIATE = 'Initiate';
	private static final String ASSESSMENT_SUBSTATUS_APEX_SHARE_SCAN = 'Apex Share Scan';

	private static final String ASSESSMENT_FILE_MIGRATION_ANALYSIS = 'migrationAnalysis';

	//Platform Cache Keys
    private static final String CACHE_PARTITION = (String.isNotBlank(Utilities.namespace) ? Utilities.namespace : 'local')+'.FSCTransitionCache';
	private static final Cache.OrgPartition CACHE_ORG = Cache.Org.getPartition(CACHE_PARTITION);
	private static final Integer CACHE_TTL_HOUR = 3600;
	private static final Integer CACHE_TTL_MINUTE = 60;
	private static final String CACHE_KEY_FSC_INSTALL_READINESS = 'fscInstallReadiness';

	//private assessment record instance
	private static Assessment__c assessment;


	/**
	 * Run FSC Upgrade Assessment
	 */
	public static ReadinessResults performFscUpgradeAssessment(Id assessmentId) {
		ReadinessResults results = new ReadinessResults(UpgradeType.FSC);

		//load record with stored results
		assessment = getAssessment(assessmentId);

		//scan org into new analysis data based on assessment results
		if (String.isBlank(assessment.AnalysisDataJSON__c)) {
			//check FSC package install readiness
			results.installReadiness = getFscInstallationReadiness();

			//Create FSC install recommendations
			results.recommendations.add(getInstallRecommendation(results.installReadiness));

			//Perform all configured org Apex checks and collect recommendations
			results.recommendations.addAll(TransitionRecommendation.executeAllActions(assessmentId));

			//sort based on severity
			results.recommendations.sort();

			//initiate async dependency scan
			scanComponentDependenciesFuture(assessmentId);

			//save results progress
			if (assessment.Id != null) {
				assessment.AnalysisDataJSON__c = results.toString();
				assessment.Status__c = ASSESSMENT_STATUS_SCAN;
				assessment.Sub_Status__c = ASSESSMENT_SUBSTATUS_INITIATE;
				AssessmentService.updateAssessment(assessment);
			}
		}
		//load existing analysis data
		else {
			results = loadReadinessResults(assessment);
			results.analysis = TransitionAnalysis.loadAnalysis(assessmentId);
		}

		return results;
	}

	/**
	 * Determine Financial Services Cloud managed package installation readiness
	 * Result is cached in Platform Cache for repeated access accross contexts
	 */
	public static InstallReadiness getFscInstallationReadiness() {
		InstallReadiness readiness = (InstallReadiness)CACHE_ORG.get(CACHE_KEY_FSC_INSTALL_READINESS);
		if (readiness == null) {
			readiness = new InstallReadiness();

			//Get org feature flags
			readiness.hasPackage = ![SELECT Id FROM PackageLicense WHERE NamespacePrefix = 'FinServ'].isEmpty();
			readiness.hasLex = isLEXEnabled();
			readiness.hasPersonAccounts = isPersonAccountEnabled();
			readiness.hasContactToMultipleAccounts = isContactMultipleAccountsEnabled();
			readiness.isLicensesAvailable = hasFSCLicenses();

			//Determine FSC package install readiness (without licenses)
			readiness.isOrgInstallationReady =
				!readiness.hasPackage && //FSC not already installed
				readiness.hasLex && //Lightning Experience Enabled
				(assessment == null || (!assessment.Is_B2C__c || assessment.Is_B2C__c && readiness.hasPersonAccounts)) && //Person Accounts needed
				readiness.hasContactToMultipleAccounts; //Contacts To Multiple Accounts enabled

			CACHE_ORG.put(CACHE_KEY_FSC_INSTALL_READINESS, readiness, CACHE_TTL_MINUTE*5 , Cache.Visibility.NAMESPACE, true); //5 minutes
		}
		return readiness;
	}

	/**
	 * Retrieve and process component metadata dependencies
	 */
	@future(callout=true)
	public static void scanComponentDependenciesFuture(Id assessmentId) {
		scanComponentDependencies(assessmentId);
	}

	public static void scanComponentDependencies(Id assessmentId){
		//try to get all dependencies synchronously (small orgs only)
		List<ToolingService.MetadataComponentDependency> dependencies;
		try {
			dependencies = DependencyHelper.getAllDependencies();
		} catch(Exception e) {
			//result size too big or callout error -- do async processing
			System.debug(e.getMessage());
		}

		//synchronous processing of results
		if (dependencies != null && dependencies.size() < DependencyHelper.LIMIT_MAX_RECORDS_TOOLING) {
			processDependencies(assessmentId, dependencies);
		}

		else {
			//request external dependency scan via Bulk API 2.0 (Large orgs)
			MappingService.MappedComponents mapping = MappingService.parseMappedComponents(getAssessment(assessmentId));
			ExternalUtilities.initiateBulkDependencyScan(assessmentId, mapping);
		}
	}

	/**
	 * Callback from Flow after update of Assessment record Bulk Scan Complete = true ready to finalize
	 */
	public static void processScanResultsCallback(List<Id> assessmentIds) {
		if(System.isFuture() || System.isBatch()){
			ScanResultsQueueable.run(assessmentIds[0]); //limited to and expecting 1 record
		} else {
			processScanResultsFuture(assessmentIds[0]); //limited to and expecting 1 record
		}
	}

	@future(callout=true)
	public static void processScanResultsFuture(Id assessmentId) {
		//Load json from file deserialize into TransitionAnalysis lists of dependencies
		String fileDataJson = FileUtility.readFileDataString(assessmentId, ASSESSMENT_FILE_MIGRATION_ANALYSIS);
		if (String.isNotBlank(fileDataJson)) {
			//parse results file json data into list structure and process
			List<TransitionAnalysis.MigrationAnalysisItem> migrationAnalysis = (List<TransitionAnalysis.MigrationAnalysisItem>)JSON.deserialize(fileDataJson, List<TransitionAnalysis.MigrationAnalysisItem>.class);
			processAnalysis(assessmentId, migrationAnalysis);
		} /*else {
			throw new AnalysisException('File content missing "' + filename + '.json"');
		}*/
	}

	/**
	 * Process Dependency API Results into an TransitionAnalysis with recommendations for Report Results view
	 */
	private static void processDependencies(Id assessmentId, List<ToolingService.MetadataComponentDependency> dependencies) {
		if (assessmentId != null && dependencies != null) {
			Assessment__c assessment = getAssessment(assessmentId);
			if(!assessment.Apex_Sharing_Scan_Complete__c ) {
				assessment.Status__c = ASSESSMENT_STATUS_SCAN;
				assessment.Sub_Status__c = ASSESSMENT_SUBSTATUS_APEX_SHARE_SCAN;
				AssessmentService.updateAssessment(assessment);

				if(!System.isFuture() && !System.isBatch()){
					ApexShareRecordQueryQueueable.queryForSharingReasonsAsync(assessmentId);
				} else {
					try {
						ApexShareRecordQueryQueueable.queryForSharingReasons(assessmentId);
					} catch(Exception e){
						System.debug(e.getMessage());
           	 			System.debug(e.getStackTraceString());
					}
				}
			} else {
				//generate full analysis from raw dependencies
				TransitionAnalysis analysis = new TransitionAnalysis(assessmentId).generateAnalysis(dependencies);

				//Update assessment with analysis results for user review
				completeAssessmentAnalysis(assessmentId, analysis);
			}
		}
	}

	/**
	 * Process previously generated MigrationAnalysisItem Results into an TransitionAnalysis with recommendations for Report Results view
	 */
	private static void processAnalysis(Id assessmentId, List<TransitionAnalysis.MigrationAnalysisItem> migrationAnalysis) {
		if (assessmentId != null && migrationAnalysis != null) {
			//generate full analysis from pre-processed results
			TransitionAnalysis analysis = new TransitionAnalysis(assessmentId).generateAnalysis(migrationAnalysis);

			//Update assessment with analysis results for user review
			completeAssessmentAnalysis(assessmentId, analysis);
		}
	}

	/**
	 * Complete the Assessment report and mark ready for review
	 */
	private static void completeAssessmentAnalysis(Id assessmentId, TransitionAnalysis analysis) {
		//Update assessment with analysis results for user review
		assessment = getAssessment(assessmentId);
		ReadinessResults results = loadReadinessResults(assessment);
		if (results != null) {
			injectApexSharingRecommendations(assessment, results);
			//save related result file
			TransitionAnalysis.saveAnalysis(assessmentId, analysis);
			//generate overall recommendation
			results.overallRecommendation = generateOverallRecommendation(results, analysis);
			//set results
			assessment.AnalysisDataJSON__c = results.toString();
			assessment.Status__c = ASSESSMENT_STATUS_REVIEW; //Let user know ready for review
			AssessmentService.updateAssessment(assessment);
		}
	}

	/**
	 * Apex Sharing Reason / CDS Recommendations can't be performed until an analysis is complete
	 * so we have to intercept and inject them here if they don't exist.
	 */
	private static void injectApexSharingRecommendations(Assessment__c assessment, ReadinessResults results){
		String sharingRecommendationText = TransitionRecommendation.recommendTextMap.get(TransitionRecommendation.SHARING_SETTINGS_RECOMMENDATION_TEXT);
		String apexSharingReason = TransitionRecommendation.recommendTextMap.get(TransitionRecommendation.SHARING_SETTINGS_APEX_SHARE_REASON);
		String cdsReason = TransitionRecommendation.recommendTextMap.get(TransitionRecommendation.SHARING_SETTINGS_CDS_REASON);

		Boolean hasSharingSettingsCheck = false;
		Boolean hasApexSharingReason = false;
		Boolean hasApexCdsReason = false;

		for(TransitionRecommendation recommendation : results.recommendations){
			if(recommendation.text == sharingRecommendationText){
				hasSharingSettingsCheck = true;

				for(String reasonText : recommendation.reasons){
					if(assessment.Has_Apex_Sharing__c && reasonText == apexSharingReason){
						hasApexSharingReason = true;
					} else if(assessment.Has_Apex_Sharing_on_CDS_Object__c && reasonText == cdsReason){
						hasApexCdsReason = true;
					}
				}

				if(assessment.Has_Apex_Sharing__c && !hasApexSharingReason){
					recommendation.complexity++;
					recommendation.reasons.add(apexSharingReason);
				}

				if(assessment.Has_Apex_Sharing_on_CDS_Object__c && !hasApexCdsReason){
					recommendation.complexity++;
					recommendation.reasons.add(cdsReason);
				}
			}
		}

		if(!hasSharingSettingsCheck && (assessment.Has_Apex_Sharing__c || assessment.Has_Apex_Sharing_on_CDS_Object__c) ){
			try{
				TransitionRecommendation sharingRecommendations = TransitionRecommendation.executeAction(assessment.Id, TransitionRecommendation.apexActionMap.get(TransitionRecommendation.SHARING_SETTINGS_RECOMMENDATION_TEXT));
				results.recommendations.add(sharingRecommendations);
				results.recommendations.sort();
			} catch(Exception e){
				System.debug(e.getMessage());
				System.debug(e.getStackTraceString());
			}
		}
	}

	/**
	 * CHECK ORG FEATURES
	 **/


	//Check LEX enabled org
	public static Boolean isLEXEnabled() {
		Boolean hasLEX = false;
		// Check enabled org
		//(Metadata API) LightningExperienceSettings enableS1DesktopEnabled = true

		//Check LEX enabled users
		Integer totalUserCount = [SELECT COUNT() FROM User WHERE IsActive = true];
		Integer totalLEXUserCount = [SELECT COUNT() FROM User WHERE IsActive = true AND UserPreferencesLightningExperiencePreferred = true];
		Decimal percentOnLightning = ((totalLEXUserCount / totalUserCount) * 100);
		hasLEX = totalLEXUserCount > 1;

		return hasLEX;
	}

	//Check Person Accounts enabled
	public static Boolean isPersonAccountEnabled() {
		return Schema.sObjectType.Account.fields.getMap().containsKey('isPersonAccount');
	}

	//Check for Contact to Multiple Accounts
	public static Boolean isContactMultipleAccountsEnabled() {
		Boolean hasContactToMultipleAccounts = false;
		try {
			hasContactToMultipleAccounts = !Schema.describeSObjects(new List<String>{'AccountContactRelation'}).isEmpty();
		} catch (System.NoAccessException e) {
			System.debug('Please enable Contact to Multiple Accounts: /lightning/setup/AccountSettings/home');
		}
		return hasContactToMultipleAccounts;
	}

	//Check for feature licenses FSC
	public static Boolean hasFSCLicenses() {
		Boolean hasFSCLicenses = false;
		List<PermissionSetLicense> fscLicenses = [SELECT Id, UsedLicenses, TotalLicenses FROM PermissionSetLicense WHERE DeveloperName = 'FinServ_FinancialServicesCloudStandardPsl'];
		if (!fscLicenses.isEmpty()) {
			hasFSCLicenses = true;
			System.debug('This organization has ' + fscLicenses[0].TotalLicenses + ' FSC licenses and can proceed with installation and upgrade');
		}
		return hasFSCLicenses;
	}

	/**
	 * Generate recommendation for package installation readiness
	 */
	private static TransitionRecommendation getInstallRecommendation(InstallReadiness readiness) {
		TransitionRecommendation recommendation = new TransitionRecommendation();
		if (readiness.isOrgInstallationReady) {
			recommendation.text = TransitionRecommendation.recommendTextMap.get('orgFscInstallationReady');
		} else {
			if (readiness.hasPackage) {
				recommendation.text = TransitionRecommendation.recommendTextMap.get('hasFsc');
				recommendation.severity = TransitionRecommendationBase.SeverityLevel.SUCCESS;
			} else {
				recommendation.text = TransitionRecommendation.recommendTextMap.get('hasNoFsc');
				recommendation.severity = TransitionRecommendationBase.SeverityLevel.INFO;
				if (!readiness.hasLex) recommendation.reasons.add(TransitionRecommendation.recommendTextMap.get('hasNoLex'));
				if (assessment.Is_B2C__c && !readiness.hasPersonAccounts) recommendation.reasons.add(TransitionRecommendation.recommendTextMap.get('hasNoPersonAccounts'));
				if (!readiness.hasContactToMultipleAccounts) recommendation.reasons.add(TransitionRecommendation.recommendTextMap.get('hasNoContactMultipleAccounts'));
				if (!readiness.isLicensesAvailable) recommendation.reasons.add(TransitionRecommendation.recommendTextMap.get('hasNoFscLicenses'));
			}
		}
		return recommendation;
	}

	/**
	 * Determine overall upgrade approach based on results calculate a complexity score and provide recommendation
	 */
	private static TransitionRecommendation generateOverallRecommendation(ReadinessResults results, TransitionAnalysis analysis) {
		TransitionRecommendation recommendation = new TransitionRecommendation();
		//calculate total complexity score
		Integer totalComplexity = 0;
		for (TransitionRecommendation r : results.recommendations) {
			totalComplexity += r.complexity;
		}
		recommendation.complexity = totalComplexity;
		//TODO update complexity based on dependency analysis (e.g. total apex classes > some limit)

		Map<String,String> recommendTextMap = TransitionRecommendation.recommendTextMap;

		//Clean Upgrade
		if (recommendation.complexity <= TransitionRecommendation.COMPLEXITY_THRESHOLD_BROWNFIELD_EASY) {
			recommendation.text = recommendTextMap.get('upgradeApproachBrownfieldClean');
			recommendation.reasons.add(recommendTextMap.get('upgradeApproachBrownfieldCleanSummary'));
			recommendation.severity = TransitionRecommendationBase.SeverityLevel.SUCCESS;
		}

		//Complex Upgrade
		else if (recommendation.complexity > TransitionRecommendation.COMPLEXITY_THRESHOLD_BROWNFIELD_EASY &&
				recommendation.complexity <= TransitionRecommendation.COMPLEXITY_THRESHOLD_BROWNFIELD_COMPLEX) {
			recommendation.text = recommendTextMap.get('upgradeApproachBrownfieldComplex');
			recommendation.reasons.add(recommendTextMap.get('upgradeApproachBrownfieldComplexSummary'));
			recommendation.severity = TransitionRecommendationBase.SeverityLevel.WARNING;
		}

		//New Org
		else if (recommendation.complexity > TransitionRecommendation.COMPLEXITY_THRESHOLD_BROWNFIELD_COMPLEX) {
			recommendation.text = recommendTextMap.get('upgradeApproachGreenfield');
			recommendation.reasons.add(recommendTextMap.get('upgradeApproachGreenfieldSummary'));
			recommendation.severity = TransitionRecommendationBase.SeverityLevel.CRITICAL;
		}

		return recommendation;
	}


	/**
	 * Private Helper Methods
	 */

	 /**
	  * Assessment record loader
	  */
	private static Assessment__c getAssessment(Id assessmentId) {
		if (assessment == null) {
			assessment = AssessmentService.queryAssessment(assessmentId);
		}
		return assessment;
	}

	/**
	 * Method to convert JSON string into this data type
	 * TODO move into ReadinessResults class if moved to separate class
	 */
	private static ReadinessResults loadReadinessResults(Assessment__c assessment) {
		ReadinessResults results;
		//load existing results
		try {
			String jsonString = assessment.AnalysisDataJSON__c != null ? assessment.AnalysisDataJSON__c : '{}';
			results = (ReadinessResults)JSON.deserialize(jsonString, ReadinessResults.class);
		} catch(JSONException e) {
			throw new UpgradeException('Invalid ReadinessResults.class JSON: ' + e.getMessage());
		}
		return results;
	}

	/**
	 * Custom Exceptions
	 */

	public class UpgradeException extends Exception {}


	/**
	 * Wrapper Classes
	 **/

	/**
	 * Wrapper top level for all readiness results
	 * Assessment Report Results
	 */
	public class ReadinessResults {
		public String assessmentVersion {get; private set;}
		public Datetime dateRun {get; private set;}
		public Id orgId {get; private set;}
		public String orgEdition {get; private set;}
		public String orgVersion {get; private set;}
		public UpgradeType upgradeType {get; private set;}
		public InstallReadiness installReadiness {get; private set;}
		public TransitionRecommendation overallRecommendation {get; private set;}
		public List<TransitionRecommendation> recommendations {get; private set;}
		public TransitionAnalysis analysis {get; private set;}

		public ReadinessResults(UpgradeType upgradeType) {
			this.upgradeType = upgradeType;
			this.dateRun = Datetime.now();
			this.orgId = TransitionReadinessUtility.INSTANCE_ID;
			this.orgEdition = TransitionReadinessUtility.INSTANCE_EDITION;
			this.assessmentVersion = TransitionReadinessUtility.assessmentVersion;
			this.orgVersion = ExternalUtilities.getOrgVersionName(); //this performs API callout
			this.installReadiness = new InstallReadiness();
			this.recommendations = new List<TransitionRecommendation>();
		}

		/**
		 * Serialize into JSON
		 */
		public override String toString() {
			return JSON.serialize(this);
		}
	}

	/**
	 * Wrapper to represent overall package installation readiness
	 */
	public class InstallReadiness {
		@AuraEnabled public Boolean isOrgInstallationReady;
		@AuraEnabled public Boolean isLicensesAvailable;
		@AuraEnabled public Boolean hasPackage;
		@AuraEnabled public Boolean hasLex;
		@AuraEnabled public Boolean hasPersonAccounts;
		@AuraEnabled public Boolean hasContactToMultipleAccounts;
		@AuraEnabled public List<String> statusReasons = new List<String>();
	}

	/**
	 * Supported Industry Upgrade Types
	 **/
	public Enum UpgradeType {
		FSC
	}

	public Enum IndustryType {
		FSC_BANKING,
		FSC_WEALTH
		//FSC_MORTGAGE,
		//FSC_INSURANCE
	}
}