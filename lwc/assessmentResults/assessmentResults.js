import { api, track, wire, LightningElement } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { getFieldValue } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import { subscribe, onError } from 'lightning/empApi';
import { refreshApex } from '@salesforce/apex';

//custom apex
import getResults from '@salesforce/apex/AssessmentResultsController.getAssessmentResults';
import getNamespacedObject from '@salesforce/apex/Utilities.getNamespacedObject';

//assessment record fields
import ID_FIELD from '@salesforce/schema/Assessment__c.Id';
import NAME_FIELD from '@salesforce/schema/Assessment__c.Name';
import CREATED_BY_FIELD from '@salesforce/schema/Assessment__c.CreatedBy.Name';
import CREATED_BY_ID_FIELD from '@salesforce/schema/Assessment__c.CreatedBy.Id';
import CREATED_DATE_FIELD from '@salesforce/schema/Assessment__c.CreatedDate';
import STATUS_FIELD from '@salesforce/schema/Assessment__c.Status__c';
import MAPPING_DATA_FIELD from '@salesforce/schema/Assessment__c.HasMappingData__c';
import PDF_GENERATION_COMPLETE_FIELD from '@salesforce/schema/Assessment__c.PDF_Generation_Complete__c';
const ASSESSMENT_FIELDS = [ID_FIELD, NAME_FIELD, CREATED_BY_FIELD, CREATED_BY_ID_FIELD, CREATED_DATE_FIELD, STATUS_FIELD, MAPPING_DATA_FIELD, PDF_GENERATION_COMPLETE_FIELD];
const ASSESSMENT_STATUS_REVIEW = 'Review'

//custom labels
import sectionIntroTitle from '@salesforce/label/c.AssessmentReportSectionTitleIntro'
import sectionWelcomeTitle from '@salesforce/label/c.AssessmentReportSectionTitleWelcome'
import sectionApproachTitle from '@salesforce/label/c.AssessmentReportSectionTitleApproach'
import sectionOverallRecommendation from '@salesforce/label/c.AssessmentReportSectionTitleOverallRecommendation'
import sectionRecommendationTitle from '@salesforce/label/c.AssessmentReportSectionTitleRecommendation'
import sectionResultsTitle from '@salesforce/label/c.AssessmentReportSectionTitleResults'
import sectionResultsSummary from '@salesforce/label/c.AssessmentReportSectionSummaryResults';
import sectionAnalysisTitle from '@salesforce/label/c.AssessmentReportSectionTitleAnalysis'
import sectionAnalysisSummary from '@salesforce/label/c.AssessmentReportSectionSummaryAnalysis'
import sectionSharingSettingResults from '@salesforce/label/c.AssessmentReportSectionSharingSettingResults'
import sectionProfileSummary from '@salesforce/label/c.AssessmentReportSectionTitleProfile'
import sectionProfileResults from '@salesforce/label/c.AssessmentReportSectionProfileResults'
import stillScanningWelcome from '@salesforce/label/c.AssessmentReportScanningTitle'
import stillScanningText from '@salesforce/label/c.AssessmentReportScanningDesc'
import scanningAssistText from '@salesforce/label/c.AssessmentReportScanningAssist'
import assessmentResultsEmptyTable from '@salesforce/label/c.AssessmentResultsEmptyTable'
import assessmentTableFeature from '@salesforce/label/c.AssessmentReportTableFeature'
import assessmentTablePriority from '@salesforce/label/c.AssessmentReportTablePriority'
import assessmentTableRecommendation from '@salesforce/label/c.AssessmentReportTableRecommendation'
import assessmentTableTransitionFrom from '@salesforce/label/c.AssessmentReportTableTransitionFrom'
import assessmentTableTransitionTo from '@salesforce/label/c.AssessmentReportTableTransitionTo'
import assessmentTableComponentType from '@salesforce/label/c.AssessmentReportTableComponentType'
import assessmentTableComponentName from '@salesforce/label/c.AssessmentReportTableComponentName'
import assessmentTableUsersAssigned from '@salesforce/label/c.AssessmentReportTableUsersAssigned'
import assessmentTableSharingInternal from '@salesforce/label/c.AssessmentReportTableSharingInternal'
import assessmentTableSharingExternal from '@salesforce/label/c.AssessmentReportTableSharingExternal'

export default class AssessmentResults extends NavigationMixin(LightningElement) {
    @api recordId;

    @wire(getRecord, { recordId: '$recordId', fields: ASSESSMENT_FIELDS})
    assessment;

    @track assessmentResults = {};
    @track isLoading = false;
    @track tableClass;

    @track resultsData;
    @track analysisData;
    @track approachData;
    @track accessData;
    @track sharingSettingData;

    @track analysisSortedBy;
    @track analysisSortDirection;

    //Data Change Event variables
    @track channelName = '/data/Assessment__ChangeEvent'

    /**
     * STATIC VALUES
     */

    activeSections = ["welcome"];

    /**
     * Custom labels
     */
    label = {
        //titles
        sectionIntroTitle,
        sectionWelcomeTitle,
        sectionApproachTitle,
        sectionOverallRecommendation,
        sectionRecommendationTitle,
        sectionResultsTitle,
        sectionAnalysisTitle,
        sectionSharingSettingResults,
        sectionProfileSummary,
        sectionProfileResults,
        //summaries
        sectionAnalysisSummary,
        sectionResultsSummary,
        //Still Scanning Messages
        stillScanningText,
        stillScanningWelcome,
        scanningAssistText,
        //empty table
        assessmentResultsEmptyTable,
        //table columns
        assessmentTableFeature,
        assessmentTablePriority,
        assessmentTableRecommendation,
        assessmentTableTransitionFrom,
        assessmentTableTransitionTo,
        assessmentTableComponentType,
        assessmentTableComponentName,
        assessmentTableUsersAssigned,
        assessmentTableSharingInternal,
        assessmentTableSharingExternal
    };

    /**
     * Datatable columns
     */

    resultsColumns = [
        {label: this.label.assessmentTableFeature, fieldName: 'replaceWithFscUrl', type: 'url', typeAttributes: { target: "_blank", label: { fieldName: 'replaceWithFsc' } }},
        {label: this.label.assessmentTablePriority, fieldName: 'priority', type: 'text'},
        {label: this.label.assessmentTableRecommendation, fieldName: 'reasonText', type: 'text', wrapText: true, typeAttributes: { linkify: true }}
    ];
    analysisColumns = [
        {label: this.label.assessmentTableTransitionFrom, fieldName: 'fromComponentUrl', type: 'url', typeAttributes: { target: "_blank", label: { fieldName: 'fromComponentName' } }},
        {label: this.label.assessmentTableComponentType, fieldName: 'fromComponentType', type: 'text'},
        {label: this.label.assessmentTableTransitionTo, fieldName: 'toComponentName', type: 'text'},
        {label: this.label.assessmentTableRecommendation, fieldName: 'reasonText', type: 'text', wrapText: true, typeAttributes: { linkify: true }}
    ];
    accessInfoColumns = [
        {label: this.label.assessmentTableComponentName, fieldName: 'fromComponentUrl', type: 'url', typeAttributes: { target: "_blank", label: { fieldName: 'fromComponentName' } }},
        {label: this.label.assessmentTableComponentType, fieldName: 'fromComponentType', type: 'text'},
        {label: this.label.assessmentTableUsersAssigned, fieldName: 'reasonText', type: 'text', wrapText: true}
    ];
    sharingSettingColumns = [
        {label: this.label.assessmentTableTransitionFrom, fieldName: 'fromComponentName', type: 'text'},
        {label: this.label.assessmentTableComponentType, fieldName: 'fromComponentType', type: 'text'},
        {label: this.label.assessmentTableSharingInternal, fieldName: 'fromComponentInternalSharing', type: 'text'},
        {label: this.label.assessmentTableSharingExternal, fieldName: 'fromComponentExternalSharing', type: 'text'},
        {label: this.label.assessmentTableRecommendation, fieldName: 'reasonText', type: 'text', wrapText: true }
    ];

    /**
     * GETTERS for conditional display
     */

    get status() {
        return getFieldValue(this.assessment.data, STATUS_FIELD);
    }
    get isPdfGenerationComplete() {
        return getFieldValue(this.assessment.data, PDF_GENERATION_COMPLETE_FIELD);
    }
    get isScanning() {
        return (!this.isLoading && this.assessment && this.assessment.data && this.status !== ASSESSMENT_STATUS_REVIEW);
    }
    get hasSharingSettingData() {
        return this.sharingSettingData && this.sharingSettingData.length > 0;
    }
    get hasAccessData() {
        return this.accessData && this.accessData.length > 0;
    }
    get hasAnalysisData() {
        return this.analysisData && this.analysisData.length > 0;
    }

    /**
     * Wires
     */

    //No __c due to ChangeEvents not needing it
    @wire(getNamespacedObject, {objectName: 'Assessment'})
    handleNamespace(response) {
        if (response && response.data) {
            this.channelName = '/data/'+response.data+'__ChangeEvent';
            //Subscribe to record changes
            this.registerErrorListener();
            this.handleSubscribe();
        }
    }

    /**
     * Component Loaded
     */
    connectedCallback() {
        //load results
        this.isLoading = true;
        this.tableClass = 'assessmentTable' + this.uuid();
        getResults({assessmentId: this.recordId})
            .then(result => {
                this.assessmentResults = result;
                this.resultsData = this.assessmentResults.analysis.assessmentResults || [];
                this.analysisData = this.adjustTreeGridChildren(this.assessmentResults.analysis.migrationAnalysis) || [];
                this.transitionApproach = this.assessmentResults.analysis.transitionApproach || [];
                this.accessData = this.adjustTreeGridChildren(this.assessmentResults.analysis.accessInfoResults) || [];
				this.sharingSettingData = this.adjustTreeGridChildren(this.assessmentResults.analysis.sharingSettingResults) || [];
                this.isLoading = false;
            })
            .catch(error => {
                console.log(error);
                this.isLoading = false;
            });
    }

    /**
     * Component Rendered
     */
    hasRendered = false;
    renderedCallback() {
        if (!this.hasRendered && !this.isLoading && !this.isScanning) {
            this.applyForceWrap();
            this.hasRendered = true;
        }
    }

    /**
     * Workaround hack to force default Wrap Text on lightning-tree-grid until made available feature.
     * Hides the ability to change Wrap/Clip
     */
    applyForceWrap() {
        let container = this.template.querySelector('.' + this.tableClass);
        if (!container) return;

        const style = document.createElement('style');
        style.innerText = `
            .`+ this.tableClass + ` thead .slds-button_icon-bare {
                display: none;
            }
            .`+ this.tableClass + ` tbody .slds-truncate {
                text-overflow: inherit;
                white-space: normal;
                word-wrap: break-word;
                overflow-wrap: break-word;
            }
        `;
        container.appendChild(style);
    }

    /**
     * Adjust children list from Apex wrapper to _children list expected by lightning-tree-grid
     */
    adjustTreeGridChildren(datalist) {
        if (datalist && Array.isArray(datalist)) {
            let self = this;
            datalist.forEach(function(row) {
                if (row.hasOwnProperty('children') && Array.isArray(row.children) && row.children.length > 0) {
                    row['_children'] = self.adjustTreeGridChildren(JSON.parse(JSON.stringify(row.children)));
                }
                delete row.children;
            });
        }
        return datalist;
    }

    /**
     * Navigate to Salesforce Record
     */
    navigateToRecord(event) {
        this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: event.target.getAttribute("data-record-id"),
                    actionName: 'view'
                }
            });
    }

    /**
     * Subscribe to Assessment ChangeEvent
     */
    handleSubscribe() {
        // Callback invoked whenever a new event message is received
        const recordId = this.recordId;
        const self = this;
        const messageCallback = function(response) {
            //If changed Assessment is this one, update status
            if(response &&
                response.data.payload &&
                response.data.payload.ChangeEventHeader.recordIds &&
                response.data.payload.ChangeEventHeader.recordIds.includes(recordId)) {

                if(response.data.payload[STATUS_FIELD.fieldApiName] === ASSESSMENT_STATUS_REVIEW) {
                    refreshApex(self.assessment);
                    self.connectedCallback();
                } else if (!self.isPdfGenerationComplete && response.data.payload[PDF_GENERATION_COMPLETE_FIELD.fieldApiName]){
                    //Update the Download PDF button or show notification that PDF Generation is complete to user
                    self.handleDownloadButtonStatus();
                }
            }
        };

        // Invoke subscribe method of empApi. Pass reference to messageCallback
        subscribe(this.channelName, -1, messageCallback);
    }

    /**
     * empApi Error Listener
     */
    registerErrorListener() {
        // Invoke onError empApi method
        onError(error => {
            console.log('Received error from server: ', JSON.stringify(error));
        });
    }

    /**
     * Handle CDC Event when PDF Generation Complete Checkbox is ticked TRUE
     */
    handleDownloadButtonStatus(){
        this.template.querySelector('c-assessment-results-header').updateDownloadButtonStatus();
    }

    /**
     * Simple UUIDV4 function to uniquely identify this component instance
     */
    uuid() {
        return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function (c) {
            var r = Math.random() * 16 | 0, v = c == 'x' ? r : (r & 0x3 | 0x8);
            return v.toString(16);
        });
    }

    /**
     * COLUMN SORTING FUNCTIONS
     **/
    updateAnalysisColumnSorting(event) {
        let fieldName = event.detail.fieldName;
        let sortDirection = event.detail.sortDirection;
        let data = JSON.parse(JSON.stringify(this.analysisData));
        // assign the latest attribute with the sorted column fieldName and sorted direction
        this.analysisSortedBy = fieldName;
        this.analysisSortedDirection = sortDirection;
        this.analysisData = this.sortData(fieldName, sortDirection, data);
    }

    sortData(fieldName, sortDirection, data) {
        var reverse = sortDirection !== 'asc';
        //sorts the rows based on the column header that's clicked
        data.sort(this.sortBy(fieldName, reverse));
        return data;
    }

    sortBy(field, reverse, primer) {
        var key = primer ?
            function(x) {return primer(x[field])} :
            function(x) {return x[field]};
        //checks if the two rows should switch places
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            // eslint-disable-next-line no-return-assign, no-sequences
            return a = key(a) || "", b = key(b) || "", reverse * ((a > b) - (b > a));
        }
    }

    /** Welcome Section Event Handler **/
    showreport(){
        this.activeSections = ["intro", "overallrecommendation", "recommendation", "results", "analysis", "profileInfo", "sharingSettingInfo"];
    }

}