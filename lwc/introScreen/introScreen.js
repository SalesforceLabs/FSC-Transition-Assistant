import { LightningElement, track, wire, api} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';

//Apex Classes
import getOrgAssessments from '@salesforce/apex/AssessmentService.getOrgAssessments';
import clone from '@salesforce/apex/AssessmentService.cloneAssessment';
import updateAssessmentDescription from '@salesforce/apex/AssessmentService.updateAssessmentDescription';
import getOrgType from '@salesforce/apex/AssessmentService.isInSandbox';
import getMapping from '@salesforce/apex/MappingService.getObjectMappingForAssessment';
import getFSCDef from '@salesforce/apex/MappingService.getFSCSchema';

//Labels
import UIAssessmentTitle from '@salesforce/label/c.UIAssessmentTitle';
import UIIntroTableActionText from '@salesforce/label/c.UIIntroTableActionText';
import UIIntroTableActionClone from '@salesforce/label/c.UIIntroTableActionClone';
import UIIntroTableHeaderName from '@salesforce/label/c.UIIntroTableHeaderName';
import UIIntroTableHeaderDate from '@salesforce/label/c.UIIntroTableHeaderDate';
import UIIntroTableHeaderStatus from '@salesforce/label/c.UIIntroTableHeaderStatus';
import UIIntroTableHeaderDescription from '@salesforce/label/c.UIIntroTableHeaderDescription';
import UINewAssessmentButtonText from '@salesforce/label/c.UINewAssessmentButtonText';
import UISandboxDisclaimer from '@salesforce/label/c.AssessmentSandboxDisclaimer';
import AssessmentIntroTitle from '@salesforce/label/c.AssessmentIntroTitle';
import AssessmentIntroDesc from '@salesforce/label/c.AssessmentIntroDesc';
import AssessmentStatusMapping from '@salesforce/label/c.AssessmentStatusMapping';

export default class IntroScreen extends NavigationMixin(LightningElement) {
    @track showAssessment;
    @track showAssessmentTable;
    @track assessmentList;
    @track assessmentId;
    @track showNewButton;

    @api isLoading = false;

    @track currentStep = "1";

    @track fscSchema = [];
    @track fscDefs = {};

    @track mappingData = {};

    assessmentResponse;
    label = {
        UIIntroTableActionText,
        UIIntroTableActionClone,
        UIIntroTableHeaderDate,
        UIIntroTableHeaderName,
        UIIntroTableHeaderStatus,
        UIIntroTableHeaderDescription,
        UINewAssessmentButtonText,
        AssessmentIntroTitle,
        AssessmentIntroDesc,
        AssessmentStatusMapping,
        UISandboxDisclaimer
    };

    @wire(getOrgAssessments, {})
    processAssessmentList(response) {
        this.isLoading = true;
        if (response) {
            this.assessmentResponse = response;
            if(this.assessmentResponse.data) {
                this.assessmentList = JSON.parse(JSON.stringify(this.assessmentResponse.data));
                this.resetPage();
            }
        }
        this.isLoading = false;
    }

    @wire(getOrgType, {})
    orgType({error, data}) {
        this.isSandbox = data;
    }

    navigateToRecordViewPage(evt) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: evt.target.dataset.id,
                actionName: 'view'
            }
        });
    }

    toggleEdit(evt) {
        let Id = evt.target.dataset.id;
        for(let index = 0; index < this.assessmentList.length; index++) {
            if(Id === this.assessmentList[index].AssessmentId) {
                this.template.querySelector("section.slds-popover[data-id='" + Id + "']").classList.toggle('slds-hidden');
                if(this.assessmentList[index].Editable) {
                    this.assessmentList[index].Editable = false;
                    updateAssessmentDescription({assessmentId: Id, description: this.assessmentList[index].Description})
                    .catch(error => {
                        this.error = error;
                    });
                }
                else {
                    this.assessmentList[index].Editable = true;
                    this.template.querySelector("lightning-textarea[data-id='" + Id + "']").focus()
                }
                break;
            }
        }
    }

    
    updateDescription(evt) {
        let Id = evt.target.dataset.id;
        for(let index = 0; index < this.assessmentList.length; index++) {
            if(Id === this.assessmentList[index].AssessmentId) {
                this.assessmentList[index].Description = evt.detail.value;
                break;
            }
        }
    }

    connectedCallback(){
        refreshApex(this.assessmentResponse);
    }

    renderedCallback(){}

    resumeClicked(evt){
        this.assessmentId = evt.target.dataset.id;
        var status = evt.target.dataset.status;
        this.currentStep = (status===this.label.AssessmentStatusMapping) ? "2" : "1";
        this.isLoading = true;
        console.log("Resume clicked");
        return new Promise(
            (resolve,reject) => {
              setTimeout(()=> {
                  this.renderAssessment();
                  resolve();
              }, 500);
          }).then(
              () => console.log("resume")
          );
    }

    stopLoading(){
        this.isLoading = false;
    }
    

    renderAssessment() {
        this.isLoading = true;

        getMapping({assessmentId:this.assessmentId})
        .then(mapResult => {
            if(mapResult){
                if(!mapResult.additional){
                    this.additionalMappings = [];
                }
                this.mappingData = mapResult;
            }
            if(!this.fscSchema || this.fscSchema.length === 0){
                getFSCDef({})
                .then(fscResult => {
                    if (fscResult) {
                        this.fscSchema = [];
                        this.fscDefs = {};
                        fscResult.forEach(fscObject => {
                            this.fscSchema.push({"label":fscObject.sourceObjectLabel, "value":fscObject.sourceObject, "desc":fscObject.sourceObjectDesc});
                            this.fscDefs[fscObject.sourceObject] = fscObject;
                            this.fscDefs[fscObject.sourceObject].formattedLabel = fscObject.sourceObjectLabel;
                        });
                    }

                    this.showAssessment = true;
                    this.showAssessmentTable = false;
                    this.showNewButton = false;
                    this.isLoading = false;

                })
                .catch(error => {
                    console.log(error);
                    this.isLoading = false;
                });
            }else{
                this.showAssessment = true;
                this.showAssessmentTable = false;
                this.showNewButton = false;
            }
        })
        .catch(error => {
            console.log(error);
        });
    }


    newAssessment(evt) {
        this.mappingData = {"recommended":[],"additional":[]};
        if(!this.fscSchema || this.fscSchema.length === 0){
            this.isLoading = true;
            getFSCDef({})
            .then(fscResult => {
                console.log("==FSC Data: ",fscResult);
                if (fscResult) {
                    fscResult.forEach(fscObject => {
                        this.fscSchema.push({"label":fscObject.sourceObjectLabel, "value":fscObject.sourceObject, "desc":fscObject.sourceObjectDesc});
                        this.fscDefs[fscObject.sourceObject] = fscObject;
                        this.fscDefs[fscObject.sourceObject].formattedLabel = fscObject.sourceObjectLabel;
                    });
                }
                this.currentStep = "1";
                this.assessmentId = null;
                this.showAssessment = true;
                this.showAssessmentTable = false;
                this.showNewButton = false;
                this.isLoading = false;
            })
            .catch(error => {
                console.log(error);
                this.isLoading = false;
            });
        }else{
            this.currentStep = "1";
            this.assessmentId = null;
            this.showAssessment = true;
            this.showAssessmentTable = false;
            this.showNewButton = false;
        }  
    }

    reloadPage(){
        refreshApex(this.assessmentResponse);
        this.resetPage();
    }

    goToMapping(e){
        this.assessmentId = e.detail;
        console.log("Go To Mapping: ",this.assessmentId);
        this.currentStep = "2";
    }

    goBackToAssessment(e){
        console.log("Back to Assessment:")
        this.currentStep = "1";
        this.showAssessment = true;
        this.showAssessmentTable = false;
        this.showNewButton = false;
    }

    getFSCDefinitions(){
        console.log("Get defs");
        getFSCDef({})
        .then(fscResult => {
            console.log("==FSC Data: ",fscResult);
            if (fscResult) {
                fscResult.forEach(fscObject => {
                    this.fscSchema.push({"label":fscObject.sourceObjectLabel, "value":fscObject.sourceObject, "desc":fscObject.sourceObjectDesc});
                    this.fscDefs[fscObject.sourceObject] = fscObject;
                    this.fscDefs[fscObject.sourceObject].formattedLabel = fscObject.sourceObjectLabel;
                });
            }
            this.showAssessment = true;
            this.showAssessmentTable = false;
            this.showNewButton = false;
            this.isLoading = false;
        })
        .catch(error => {
            console.log(error);
            this.isLoading = false;
        });
    }

    cloneClicked(evt){
        this.isLoading = true;
        var sourceId = evt.target.dataset.id;
        clone({assessmentId: sourceId})
        .then(cloneResult => {
            console.log("==Clone Result: ",cloneResult);
            try{
                if(cloneResult){
                    this.assessmentId = cloneResult;
                    this.currentStep = "1";
                    this.isLoading = true;
                    console.log("Resume clicked");
                    return new Promise(
                        (resolve,reject) => {
                        setTimeout(()=> {
                            this.renderAssessment();
                            resolve();
                        }, 500);
                    }).then(
                        () => console.log("resume")
                    );
                }else{
                    this.isLoading = false;
                }
            }catch(e){
                console.log("==Clone callback error: ",e);
            }          
        })
        .catch(error => {
            console.log(error);
            this.isLoading = false;
        });
    }

    resetPage() {
        this.showAssessmentTable = this.assessmentList.length > 0;
        this.showAssessment = false;
        this.assessmentId = null;
        this.showNewButton = true;
    }

    get isStep1(){
        return this.currentStep == "1";
    }

    get isStep2(){
        return this.currentStep == "2";
    }

    get cardTitle(){
        return (this.showNewButton) ? this.label.AssessmentIntroTitle : '';
    }
}