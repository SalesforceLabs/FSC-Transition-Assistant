import { LightningElement, api, track, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import { subscribe, unsubscribe, onError, setDebugFlag, isEmpEnabled } from 'lightning/empApi';
import ID_FIELD from '@salesforce/schema/Assessment__c.Id';
import getPackages from '@salesforce/apex/PackageInstallationController.getPackageList';
import deploySelectedPackages from '@salesforce/apex/PackageInstallationController.deploySelectedPackages';
import getNamespacedObject from '@salesforce/apex/Utilities.getNamespacedObject';
import UIPackageTableHeaderName from '@salesforce/label/c.UIPackageTableHeaderName';
import UIPackageTableHeaderVersion from '@salesforce/label/c.UIPackageTableHeaderVersion';
import UIPackageTableHeaderDescription from '@salesforce/label/c.UIPackageTableHeaderDescription';
import UIPackageTableButtonText from '@salesforce/label/c.UIPackageTableButtonText';
import UIPackageTableHeaderText from '@salesforce/label/c.UIPackageTableHeaderText';
import UIPackageTableNoResultsText from '@salesforce/label/c.UIPackageTableNoResultsText';
import UIPackageTableDescriptionText from '@salesforce/label/c.UIPackageTableDescriptionText';
import UIPackageTableLoadingText from '@salesforce/label/c.UIPackageTableLoadingText';
import UIPackageTableRecommendedHeader from '@salesforce/label/c.UIPackageTableRecommendedHeader';
import UIPackageTableInstalledHeader from '@salesforce/label/c.UIPackageTableInstalledHeader';
import UIPackageTableInstallingHeader from '@salesforce/label/c.UIPackageTableInstallingHeader';
import UIPackageTableErrorHeader from '@salesforce/label/c.UIPackageTableErrorHeader';
import UIPackageTableRecommendedDescription from '@salesforce/label/c.UIPackageTableRecommendedDescription';
import UIPackageTableInstalledDescription from '@salesforce/label/c.UIPackageTableInstalledDescription';
import UIPackageTableInstallingDescription from '@salesforce/label/c.UIPackageTableInstallingDescription';
import UIPackageTableErrorDescription from '@salesforce/label/c.UIPackageTableErrorDescription';

const ASSESSMENT_FIELDS = [ID_FIELD];

export default class PackageScreen extends LightningElement {
    @api recordId;

    @track isLoading = true;
    @track showRecommendedTable;
    @track showPendingTable;
    @track showInstalledTable;
    @track showErrorTable;
    @track buttonActive = false;
    @track installedPackageList;
    @track pendingPackageList;
    @track uninstalledPackageList;
    @track errorPackageList;
    @track installResult;
    @track preSelectedPackages = [];
    @track channelName = '/data/Assessment__ChangeEvent'
    
    assessment;
    selectedPackages = [];
    label = {
        UIPackageTableHeaderName,
        UIPackageTableHeaderVersion,
        UIPackageTableHeaderDescription,
        UIPackageTableButtonText,
        UIPackageTableHeaderText,
        UIPackageTableNoResultsText,
        UIPackageTableDescriptionText,
        UIPackageTableLoadingText,
        UIPackageTableRecommendedHeader,
        UIPackageTableInstalledHeader,
        UIPackageTableInstallingHeader,
        UIPackageTableErrorHeader,
        UIPackageTableRecommendedDescription,
        UIPackageTableInstalledDescription,
        UIPackageTableInstallingDescription,
        UIPackageTableErrorDescription
    };
    columns = [
        {label: this.label.UIPackageTableHeaderName, fieldName: 'Name', hideDefaultActions: true},
        {label: this.label.UIPackageTableHeaderVersion, fieldName: 'Version', hideDefaultActions: true},
        {label: this.label.UIPackageTableHeaderDescription, type: 'richText', fieldName: 'Description', hideDefaultActions: true}
    ];

    @wire(getNamespacedObject, {objectName: 'Assessment'})
    handleNamespace(response) {
        if (response && response.data) {
            this.channelName = '/data/' + response.data + '__ChangeEvent';
            this.registerErrorListener();
            this.handleSubscribe();
        }
    }

    @wire(getRecord, { recordId: '$recordId', fields: ASSESSMENT_FIELDS})
    renderScreen({error, data}) {
        if (data) {
            this.assessment = data;
            this.getPackageTable();
        }
        else if(error) {
            this.isLoading = false;
            this.error = error;
        }
    }

    getPackageTable() {
        getPackages({assessmentId: this.recordId})
        .then(result => {
            this.installedPackageList = result.InstalledPackages;
            this.pendingPackageList = result.PendingPackages;
            this.uninstalledPackageList = result.UninstalledPackages;
            this.errorPackageList = result.ErrorPackages;
            this.installResult = result.InstallResult;

            this.showPendingTable = this.pendingPackageList.length > 0;
            this.showRecommendedTable = this.uninstalledPackageList.length > 0;
            this.showInstalledTable = this.installedPackageList.length > 0;
            this.showErrorTable = this.errorPackageList.length > 0;
            if(!this.showPendingTable) {
                let selectedRows = [];
                let selectedPackagesOnLoad = [];
                for(let row of this.uninstalledPackageList) {
                    if(row.IsSelected) {
                        selectedRows.push(row.VersionId);
                        selectedPackagesOnLoad.push(row);
                    }
                }
                this.preSelectedPackages = selectedRows;
                this.selectedPackages = selectedPackagesOnLoad;
                this.buttonActive = this.preSelectedPackages.length > 0;
            }
            this.isLoading = false;
        })
        .catch(error => {
            this.isLoading = false;
            this.error = error;
        });
    }

    getSelectedPackages(event) {
        this.selectedPackages = event.detail.selectedRows;
        this.buttonActive = this.selectedPackages.length > 0;
    }

    installPackages() {
        this.buttonActive = false;
        this.isLoading = true;
        deploySelectedPackages({assessmentId: this.recordId, selectedPackages: this.selectedPackages})
        .then(result => {
            this.getPackageTable();
            this.isLoading = false;
        })
        .catch(error => {
            this.isLoading = false;
            this.error = error;
        });
    }

    handleSubscribe() {
        const recordId = this.recordId;
        let self = this;

        const messageCallback = (response) => {
            if(response && response.data.payload && response.data.payload.ChangeEventHeader.recordIds && 
                response.data.payload.ChangeEventHeader.recordIds.includes(recordId)
            ){
                this.getPackageTable();
            }
        };

        subscribe(this.channelName, -1, messageCallback).then(response => {});
    }
    
    registerErrorListener() {
        onError(error => {});
    }
}