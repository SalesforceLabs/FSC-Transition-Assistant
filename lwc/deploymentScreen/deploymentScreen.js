import { LightningElement, api, track, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { subscribe, unsubscribe, onError, setDebugFlag, isEmpEnabled } from 'lightning/empApi';
import ID_FIELD from '@salesforce/schema/Assessment__c.Id';
import getDeployments from '@salesforce/apex/PackageDeploymentController.getDeploymentInfo';
import deployPackage from '@salesforce/apex/PackageDeploymentController.deployPackage';
import getNamespacedObject from '@salesforce/apex/Utilities.getNamespacedObject';
import UIDeploymentTableHeaderDescription from '@salesforce/label/c.UIDeploymentTableHeaderDescription';
import UIDeploymentTableHeaderAssessment from '@salesforce/label/c.UIDeploymentTableHeaderAssessment';
import UIDeploymentTableHeaderDeployment from '@salesforce/label/c.UIDeploymentTableHeaderDeployment';
import UIDeploymentTableHeaderDate from '@salesforce/label/c.UIDeploymentTableHeaderDate';
import UIDeploymentTableButtonDeploy from '@salesforce/label/c.UIDeploymentTableButtonDeploy';
import UIDeploymentTableDescriptionText from '@salesforce/label/c.UIDeploymentTableDescriptionText';
import UIDeploymentTableHeader from '@salesforce/label/c.UIDeploymentTableHeader';
import UIDeploymentTableHeaderStartDate from '@salesforce/label/c.UIDeploymentTableHeaderStartDate'
import UIDeploymentTableHeaderEndDate from '@salesforce/label/c.UIDeploymentTableHeaderEndDate'
import UIDeploymentTableHeaderInProgress from '@salesforce/label/c.UIDeploymentTableHeaderInProgress';
import UIDeploymentTableHeaderError from '@salesforce/label/c.UIDeploymentTableHeaderError';
import UIDeploymentTableHeaderAvailable from '@salesforce/label/c.UIDeploymentTableHeaderAvailable';
import UIDeploymentTableHeaderDeployed from '@salesforce/label/c.UIDeploymentTableHeaderDeployed';
import UIDeploymentTableAvailableDescriptionText from '@salesforce/label/c.UIDeploymentTableAvailableDescriptionText';
import UIDeploymentTableErrorDescriptionText from '@salesforce/label/c.UIDeploymentTableErrorDescriptionText';
import UIDeploymentTableDeployedDescriptionText from '@salesforce/label/c.UIDeploymentTableDeployedDescriptionText';
import UIDeploymentTableInProgressDescriptionText from '@salesforce/label/c.UIDeploymentTableInProgressDescriptionText';
import UIPackageTableErrorHeader from '@salesforce/label/c.UIPackageTableErrorHeader';
import UIDeploymentTableLoadingText from '@salesforce/label/c.UIDeploymentTableLoadingText';
const ASSESSMENT_FIELDS = [ID_FIELD];


export default class DeploymentScreen extends LightningElement {
    @api recordId;

    @track isLoading = true;
    @track showDeployedTable;
    @track showPendingTable;
    @track showDeployableTable;
    @track showErrorTable;
    @track buttonActive = false;
    @track deployedPackageList;
    @track pendingPackageList;
    @track deployablePackageList;
    @track errorPackageList;
    @track recordIds = [];
    subscribed = false;

    label = {
        UIDeploymentTableHeaderDescription,
        UIDeploymentTableHeaderAssessment,
        UIDeploymentTableHeaderDeployment,
        UIDeploymentTableHeaderDate,
        UIDeploymentTableButtonDeploy,
        UIDeploymentTableDescriptionText,
        UIDeploymentTableHeader,
        UIDeploymentTableHeaderStartDate,
        UIDeploymentTableHeaderEndDate,
        UIDeploymentTableHeaderInProgress,
        UIDeploymentTableHeaderError,
        UIDeploymentTableHeaderAvailable,
        UIDeploymentTableHeaderDeployed,
        UIDeploymentTableAvailableDescriptionText,
        UIDeploymentTableErrorDescriptionText,
        UIDeploymentTableDeployedDescriptionText,
        UIDeploymentTableInProgressDescriptionText,
        UIPackageTableErrorHeader,
        UIDeploymentTableLoadingText
    };
    
    deployTableColumns = [
        {label: this.label.UIDeploymentTableHeaderAssessment, fieldName: 'AssessmentUrl', type: 'url', typeAttributes: {label: {fieldName: 'AssessmentName', target: '_self'}}, hideDefaultActions: true},
        {label: this.label.UIDeploymentTableHeaderDescription, fieldName: 'Description', wrapText: true, hideDefaultActions: true}, 
        {label: this.label.UIDeploymentTableHeaderDeployment, fieldName: 'DocumentUrl', type: 'url', typeAttributes: {label: {fieldName: 'Name', target: '_blank'}}, hideDefaultActions: true},
        {label: this.label.UIDeploymentTableHeaderDate, fieldName: 'PackageCreatedDate', type: "date", typeAttributes:{month: "2-digit", day: "2-digit", year: "2-digit", hour: "2-digit", minute: "2-digit"}, hideDefaultActions: true},
        {type: "button", typeAttributes: {  
            label: this.label.UIDeploymentTableButtonDeploy,  
            name: this.label.UIDeploymentTableButtonDeploy,  
            title: this.label.UIDeploymentTableButtonDeploy,  
            disabled: false,  
            value: 'deploy',  
            variant: 'base'
        }}
    ];

    pendingTableColumns = [
        {label: this.label.UIDeploymentTableHeaderAssessment, fieldName: 'AssessmentUrl', type: 'url', typeAttributes: {label: {fieldName: 'AssessmentName', target: '_self'}}, hideDefaultActions: true},
        {label: this.label.UIDeploymentTableHeaderDescription, fieldName: 'Description', wrapText: true, hideDefaultActions: true}, 
        {label: this.label.UIDeploymentTableHeaderDeployment, fieldName: 'DocumentUrl', type: 'url', typeAttributes: {label: {fieldName: 'Name', target: '_blank'}}, hideDefaultActions: true},
        {label: this.label.UIDeploymentTableHeaderDate, fieldName: 'PackageCreatedDate', type: "date", typeAttributes:{month: "2-digit", day: "2-digit", year: "2-digit", hour: "2-digit", minute: "2-digit"}, hideDefaultActions: true},
        {label: this.label.UIDeploymentTableHeaderStartDate, fieldName: 'DeploymentStarttime', type: "date", typeAttributes:{month: "2-digit", day: "2-digit", year: "2-digit", hour: "2-digit", minute: "2-digit"}, hideDefaultActions: true},
    ];

    errorTableColumns = [
        {label: this.label.UIDeploymentTableHeaderAssessment, fieldName: 'AssessmentUrl', type: 'url', typeAttributes: {label: {fieldName: 'AssessmentName', target: '_self'}}, hideDefaultActions: true},
        {label: this.label.UIDeploymentTableHeaderDescription, fieldName: 'Description', wrapText: true, hideDefaultActions: true}, 
        {label: this.label.UIDeploymentTableHeaderDeployment, fieldName: 'DocumentUrl', type: 'url', typeAttributes: {label: {fieldName: 'Name', target: '_blank'}}, hideDefaultActions: true},
        {label: this.label.UIDeploymentTableHeaderDate, fieldName: 'PackageCreatedDate', type: "date", typeAttributes:{month: "2-digit", day: "2-digit", year: "2-digit", hour: "2-digit", minute: "2-digit"}, hideDefaultActions: true},
        {label: this.label.UIDeploymentTableHeaderStartDate, fieldName: 'DeploymentStarttime', type: "date", typeAttributes:{month: "2-digit", day: "2-digit", year: "2-digit", hour: "2-digit", minute: "2-digit"}, hideDefaultActions: true},
        {label: this.label.UIDeploymentTableHeaderEndDate, fieldName: 'DeploymentEndtime', type: "date", typeAttributes:{month: "2-digit", day: "2-digit", year: "2-digit", hour: "2-digit", minute: "2-digit"}, hideDefaultActions: true},
        {label: this.label.UIPackageTableErrorHeader, fieldName: 'ErrorMessage', wrapText: true, hideDefaultActions: true},
    ];

    deployedTableColumns = [
        {label: this.label.UIDeploymentTableHeaderAssessment, fieldName: 'AssessmentUrl', type: 'url', typeAttributes: {label: {fieldName: 'AssessmentName', target: '_self'}}, hideDefaultActions: true},
        {label: this.label.UIDeploymentTableHeaderDescription, fieldName: 'Description', hideDefaultActions: true},
        {label: this.label.UIDeploymentTableHeaderDeployment, fieldName: 'DocumentUrl', type: 'url', typeAttributes: {label: {fieldName: 'Name', target: '_blank'}}, hideDefaultActions: true},
        {label: this.label.UIDeploymentTableHeaderDate, fieldName: 'PackageCreatedDate', type: "date", typeAttributes:{month: "2-digit", day: "2-digit", year: "2-digit", hour: "2-digit", minute: "2-digit"}, hideDefaultActions: true},
        {label: this.label.UIDeploymentTableHeaderStartDate, fieldName: 'DeploymentStarttime', type: "date", typeAttributes:{month: "2-digit", day: "2-digit", year: "2-digit", hour: "2-digit", minute: "2-digit"}, hideDefaultActions: true},
        {label: this.label.UIDeploymentTableHeaderEndDate, fieldName: 'DeploymentEndtime', type: "date", typeAttributes:{month: "2-digit", day: "2-digit", year: "2-digit", hour: "2-digit", minute: "2-digit"}, hideDefaultActions: true},
    ];

    availableTableColumns = [
        {label: this.label.UIDeploymentTableHeaderAssessment, fieldName: 'AssessmentUrl', type: 'url', typeAttributes: {label: {fieldName: 'AssessmentName', target: '_self'}}, hideDefaultActions: true},
        {label: this.label.UIDeploymentTableHeaderDescription, fieldName: 'Description', wrapText: true, hideDefaultActions: true}, 
        {label: this.label.UIDeploymentTableHeaderDeployment, fieldName: 'DocumentUrl', type: 'url', typeAttributes: {label: {fieldName: 'Name', target: '_blank'}}, hideDefaultActions: true},
        {label: this.label.UIDeploymentTableHeaderDate, fieldName: 'PackageCreatedDate', type: "date", typeAttributes:{month: "2-digit", day: "2-digit", year: "2-digit", hour: "2-digit", minute: "2-digit"}, hideDefaultActions: true}
    ];


    @wire(getNamespacedObject, {objectName: 'Assessment'})
    handleNamespace(response) {
        if (response && response.data) {
            this.channelName = '/data/' + response.data + '__ChangeEvent';
        }
    }

    @wire(getRecord, { recordId: '$recordId', fields: ASSESSMENT_FIELDS})
    renderScreen({error, data}) {
        if (data) {
            this.assessment = data;
            this.getDeploymentTable();
        }
        else if(error) {
            this.isLoading = false;
            this.error = error;
        }
    }

    getDeploymentTable() {
        getDeployments()
        .then(result => {                    
            this.recordIds = result.AssessmentIds;
            this.deployedPackageList = result.DeployedPackages;
            this.pendingPackageList = result.PendingPackages;
            this.deployablePackageList = result.DeployablePackages;
            this.errorPackageList = result.ErrorPackages;
            this.installResult = result.InstallResult;
            this.showDeployedTable = this.deployedPackageList.length > 0;
            this.showPendingTable = this.pendingPackageList.length > 0;
            this.showDeployableTable = this.deployablePackageList.length > 0;
            this.showErrorTable = this.errorPackageList.length > 0;   
            if(!this.subscribed) {
                this.registerErrorListener();
                this.handleSubscribe();
                this.subscribed = true;
            }
            this.isLoading = false;
        })
        .catch(error => {
            this.isLoading = false;
            this.error = error;
        });
    }

    deploySelectedPackage(event){
        if(event.detail.action.value === 'deploy') {
            this.isLoading = true;
            deployPackage({deployment: event.detail.row})
            .then(result => {
                this.getDeploymentTable();
            })
            .catch(error => {
                this.isLoading = false;
                this.error = error;
            });
        }
    }

    handleSubscribe() {
        const monitorRecordIds = JSON.parse(JSON.stringify(this.recordIds));
        let self = this;

        const messageCallback = (response) => {
            if(response && response.data.payload && response.data.payload.ChangeEventHeader.recordIds && 
                response.data.payload.ChangeEventHeader.recordIds.some(r => monitorRecordIds.includes(r))
            ){
                this.getDeploymentTable();
            }
        };

        subscribe(this.channelName, -1, messageCallback).then(response => {});
    }
    
    registerErrorListener() {
        onError(error => {});
    }
}