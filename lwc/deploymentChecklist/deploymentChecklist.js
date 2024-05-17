import { LightningElement, api, track, wire } from 'lwc';
import { subscribe, unsubscribe, onError, setDebugFlag, isEmpEnabled } from 'lightning/empApi';
import { getRecord } from 'lightning/uiRecordApi';
import { getFieldValue } from 'lightning/uiRecordApi';

//custom apex
import generateDeploymentList from '@salesforce/apex/DeploymentChecklist.generateDeploymentList';
import generateDeploymentPackage from '@salesforce/apex/DeploymentChecklist.generateDeploymentPackage';
import saveDeploymentChecklist from '@salesforce/apex/DeploymentChecklist.saveDeploymentChecklist';
import getNamespacedObject from '@salesforce/apex/Utilities.getNamespacedObject';

//Record Fields
//import STATUS_FIELD from '@salesforce/schema/Assessment__c.Status__c';
import SUB_STATUS_FIELD from '@salesforce/schema/Assessment__c.Sub_Status__c';
const ASSESSMENT_FIELDS = [SUB_STATUS_FIELD];

//custom labels
import deploymentChecklistDescription from '@salesforce/label/c.DeploymentChecklistDescription'
import deploymentChecklistTitle from '@salesforce/label/c.DeploymentChecklistTitle'
import deploymentPackageProcessing from '@salesforce/label/c.DeploymentPackageProcessing'
import buttonLabelGenerateDeploymentPackage from '@salesforce/label/c.UIButtonGenerateDeploymentPackage'
import columnComponentType from '@salesforce/label/c.UIDeployTableColumnComponentType'
import columnComponentName from '@salesforce/label/c.UIDeployTableColumnComponentName'
import columnSourceObject from '@salesforce/label/c.UIDeployTableColumnSourceObject'
import columnTargetObject from '@salesforce/label/c.UIDeployTableColumnTargetObject'
import loadingText from '@salesforce/label/c.UILoadingText'

const PACKAGE_INSTALL_STATUS_PROCESSING = 'Generating Deployment Package'
const PACKAGE_INSTALL_STATUS_READY = 'Deployment Package Ready'

export default class DeploymentChecklist extends LightningElement {
    @api recordId;
    //Data Change Event variables
    channelName = '/data/Assessment__ChangeEvent'

    @wire(getRecord, { recordId: '$recordId', fields: ASSESSMENT_FIELDS})
    assessment;

    @wire(getNamespacedObject, {objectName: 'Assessment'})
    wiredNamespace(response) {
        if (response && response.data) {
            this.channelName = '/data/'+response.data+'__ChangeEvent';
            //Subscribe to record changes
            this.handleSubscribe();
            this.registerErrorListener();
        }
    }

    @wire(generateDeploymentList, { assessmentId: '$recordId' })
    wiredChecklist(response) {
        if (response.data) {
            if (this.statusProcessing) {
                this.statusMessage = this.label.deploymentPackageProcessing;
            } else {
                //set response data in tables
                this.deploymentSections = response.data;
                this.selectedComponents = response.data;
                this.isLoading = false;
            }
        }
    }

    @track deploymentSections = [];
    selectedComponents = [];
    sortedBy;
    sortDirection;
    isLoading = true;
    statusMessage;

    get statusProcessing() {
        return getFieldValue(this.assessment.data, SUB_STATUS_FIELD) === PACKAGE_INSTALL_STATUS_PROCESSING;
    }

    /**
     * STATIC VALUES
     */
    
    label = {
        buttonLabelGenerateDeploymentPackage,
        columnComponentType,
        columnComponentName,
        columnSourceObject,
        columnTargetObject,
        deploymentChecklistDescription,
        deploymentChecklistTitle,
        deploymentPackageProcessing,
        loadingText
    };
    
    checklistColumns = [
        {label: this.label.columnComponentType, fieldName: 'componentType', type: 'text', sortable: true},
        {label: this.label.columnComponentName, fieldName: 'componentUrl', type: 'url', typeAttributes: { target: "_blank", label: { fieldName: 'componentLabel' } }, sortable: true},
        {label: this.label.columnSourceObject, fieldName: 'sourceObject', type: 'text', sortable: true},
        {label: this.label.columnTargetObject, fieldName: 'targetObject', type: 'text', sortable: true}
    ];

    /**
     * Datatable row checkbox selected event handler
     */
    rowSelected(event) {
        //process selected items build selectedComponets lsit
        let componentSection = {
            sectionName: event.detail.sectionName,
            components: event.detail.selectedRows
        };

        const newList = [];
        for (const section of this.selectedComponents) {
            newList.push(section.sectionName === componentSection.sectionName ? componentSection : section);
        }
        this.selectedComponents = newList;
    }

    /**
     * Generate Deployment Package button onclick handler
     */
    generatePackage(event) {
        this.isLoading = true;
        //get sections with selected components
        const itemsToDeploy = [];
        for (const section of this.selectedComponents) {
            if (section.components && section.components.length) {
                itemsToDeploy.push(section);
            }
        }
        console.log(JSON.parse(JSON.stringify(itemsToDeploy)));
        //save file
        saveDeploymentChecklist({assessmentId: this.recordId, itemsToDeployJson: JSON.stringify(itemsToDeploy)})
            .then((result) => {
                //callout for package generation
                generateDeploymentPackage({assessmentId: this.recordId, deploymentFileId: result})
                    .then((result) => {
                        if (result === true) {
                            this.statusMessage = this.label.deploymentPackageProcessing;
                        } else {
                            this.isLoading = false;
                            //todo display error
                        }
                    })
                    .catch((error) => {
                        console.log('ERROR:',error);
                        this.isLoading = false;
                    });
            })
            .catch((error) => {
                console.log('ERROR:',error);
                this.isLoading = false;
            });

    }

    /**
     * Change Event Subscribe for status changes
     */
    handleSubscribe() {
        // Callback invoked whenever a new event message is received
        const recordId = this.recordId;
        let self = this;

        // Invoke subscribe method of empApi. Pass reference to messageCallback
        subscribe(this.channelName, -1, function(response) {
            //If changed Assessment is this one, update status
            if(response && 
                response.data.payload && 
                response.data.payload.ChangeEventHeader.recordIds && 
                response.data.payload.ChangeEventHeader.recordIds.includes(recordId) && 
                response.data.payload[SUB_STATUS_FIELD.fieldApiName] === PACKAGE_INSTALL_STATUS_READY) {
                
                //refreshApex(self.assessment);
                //self.connectedCallback();
                self.statusMessage = null;
                self.isLoading = false;
            }
        });
    }

    registerErrorListener() {
        // Invoke onError empApi method
        onError(error => {
            console.log('Received error from server: ', JSON.stringify(error));
        });
    }

}