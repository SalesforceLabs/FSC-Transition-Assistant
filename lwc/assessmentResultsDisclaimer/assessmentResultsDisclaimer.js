import { LightningElement } from 'lwc';

//Apex
import getSettings from '@salesforce/apex/AssessmentResultsController.getCustomSettings';
import turnOffWelcome from '@salesforce/apex/AssessmentResultsController.disableWelcomeDefault';

//Custom Labels
import AssessmentReportWelcomeText from '@salesforce/label/c.AssessmentReportWelcomeText';
import AssessmentReportWelcomeCheckboxText from '@salesforce/label/c.AssessmentReportWelcomeCheckboxText';
import UIContinueButtonText from '@salesforce/label/c.UIContinueButtonText';

export default class AssessmentResultsDisclaimer extends LightningElement {

    showUserPrompt = false;
    dontShowSelected = false;

    label = {
        AssessmentReportWelcomeText,
        AssessmentReportWelcomeCheckboxText,
        UIContinueButtonText
    }

    connectedCallback(){
        getSettings({})
        .then(result => {
            this.showUserPrompt = (result) ? !result.Collapse_Welcome_Section_By_Default__c : true;
            if(this.showUserPrompt!==true){
                this.dispatchEvent(new CustomEvent("showreport", {}));
            }
        })
        .catch(error => {
            console.log(error);
        });
    }

    continueClicked(){
        if(this.dontShowSelected===true){
            turnOffWelcome({})
            .then(result => {
                this.showUserPrompt = false;
            })
            .catch(error => {
                console.log(error);
            });
        }
        this.dispatchEvent(new CustomEvent("showreport", {}));
    }

    setDontShow(e){
        this.dontShowSelected = e.detail.checked;
    }
}