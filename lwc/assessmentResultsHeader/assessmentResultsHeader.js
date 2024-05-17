import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getFieldValue } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';

//assessment record fields
import ID_FIELD from '@salesforce/schema/Assessment__c.Id';
import NAME_FIELD from '@salesforce/schema/Assessment__c.Name';
import CREATED_BY_FIELD from '@salesforce/schema/Assessment__c.CreatedBy.Name';
import CREATED_BY_ID_FIELD from '@salesforce/schema/Assessment__c.CreatedBy.Id';
import CREATED_DATE_FIELD from '@salesforce/schema/Assessment__c.CreatedDate';
import MAPPING_DATA_FIELD from '@salesforce/schema/Assessment__c.HasMappingData__c';
import PDF_GENERATION_COMPLETE_FIELD from '@salesforce/schema/Assessment__c.PDF_Generation_Complete__c';

//custom labels
import headerLabelCreatedBy from '@salesforce/label/c.AssessmentReportHeaderCreatedBy'
import headerLabelDate from '@salesforce/label/c.AssessmentReportHeaderDate'
import headerLabelLicensesPurchased from '@salesforce/label/c.AssessmentReportHeaderLicensesPurchased'
import headerLabelOrgId from '@salesforce/label/c.AssessmentReportHeaderOrgId'
import headerLabelOrgType from '@salesforce/label/c.AssessmentReportHeaderOrgType'
import headerLabelReadyToUpgrade from '@salesforce/label/c.AssessmentReportHeaderReadyUpgrade'
import headerLabelReadyToUpgradeNo from '@salesforce/label/c.AssessmentReportHeaderReadyUpgradeNo'
import headerLabelReadyToUpgradeYes from '@salesforce/label/c.AssessmentReportHeaderReadyUpgradeYes'
import headerLabelUpgradeType from '@salesforce/label/c.AssessmentReportHeaderUpgradeType'
import headerLabelVersion from '@salesforce/label/c.AssessmentReportHeaderVersion'
import toastSuccessTitle from '@salesforce/label/c.ToastTitleSuccess'
import toastSuccessMessage from '@salesforce/label/c.ToastMessageLinkCopied'
import copyLinkMessage from '@salesforce/label/c.ReportCopyMappingDocLink'

//Apex Methods
import exportMapping from '@salesforce/apex/MappingService.generateMappingFile';
import getMappingFileId from '@salesforce/apex/MappingService.getMappingFileLink';
import downloadPdfReport from '@salesforce/apex/AssessmentResultsController.downloadPdfReport';
import getPdfContentDocumentId from '@salesforce/apex/AssessmentResultsController.getAssessmentReportId';


export default class AssessmentResultsHeader extends NavigationMixin(LightningElement) {
    @api assessment;
    @api results;

    xlsxId = '';
    pdfId;

    isLoading = false;

    hasPdfRequestBeenClicked = false;

    //custom labels
    label = {
        //header
        headerLabelCreatedBy,
        headerLabelDate,
        headerLabelLicensesPurchased,
        headerLabelOrgId,
        headerLabelOrgType,
        headerLabelReadyToUpgrade,
        headerLabelReadyToUpgradeNo,
        headerLabelReadyToUpgradeYes,
        headerLabelUpgradeType,
        headerLabelVersion,
        toastSuccessTitle,
        toastSuccessMessage,
        copyLinkMessage
    };

    /**
     * GETTERS
     */

    get id(){
        return getFieldValue(this.assessment.data, ID_FIELD);
    }

    get name() {
        return getFieldValue(this.assessment.data, NAME_FIELD);
    }

    get createdby() {
        return {
            name:  getFieldValue(this.assessment.data, CREATED_BY_FIELD),
            id:  getFieldValue(this.assessment.data, CREATED_BY_ID_FIELD)
        };
    }

    get createddate() {
        return  getFieldValue(this.assessment.data, CREATED_DATE_FIELD);
    }

    get mappingdata(){
        return getFieldValue(this.assessment.data, MAPPING_DATA_FIELD);
    }

    get shouldShowMappingDocButtons(){
        return this.mappingdata === true;
    }

    get isPdfGenerationComplete() {
        return getFieldValue(this.assessment.data, PDF_GENERATION_COMPLETE_FIELD);
    }

    get hasPdfBeenRequested(){
        return (!this.isPdfGenerationComplete && this.hasPdfRequestBeenClicked);
    }

    /**
     * Retrieve xlsx link if present
     */
    // connectedCallback(){
    //     console.log('==Assessment Id: '+this.id);
    //     getMappingFileId({recordId: this.id})
    //     .then(result => {
    //         this.xlsxId = result;
    //     })
    //     .catch(error => {
    //         console.log(error);
    //     });
    // }

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
     * Export Mapping Document
     */
     exportDoc(){
        this.isLoading = true;
        exportMapping({recordId: this.id, forceRefresh: false})
        .then(result => {
            //Download File
            if(result){
                this.xlsxId = result;
                //window.location.href = result;
                this[NavigationMixin.Navigate]({
                    type: 'standard__namedPage',
                    attributes: {
                        pageName: 'filePreview'
                    },
                    state : {
                        // assigning ContentDocumentId to show the preview of file
                        selectedRecordId: result
                    }
                });
            }else{
                console.log("Null result");
            }
        })
        .catch(error => {
            console.log('Error: ',error);
        }).finally(() => {
            this.isLoading = false;
        });
    }

    async downloadPdf(){
        this.isLoading = true;

        try{
            let pdfResult = await downloadPdfReport({assessmentId: this.id});

            if(this.hasPdfRequestBeenClicked){
                this.popToast('PDF Report In Progress', 'Your request is in the queue. When the file has finished generating it will begin downloading.', 'info');
            } else if(pdfResult !== 'PENDING'){
                this.pdfId = pdfResult;

                this.navigateToFilePreview(this.pdfId);
            } else {
                this.hasPdfRequestBeenClicked = true;

                this.popToast('PDF Report Requested', 'Your PDF is being generated. You will be notified when it is ready for download.', 'success');
            }

        } catch(error){
            console.error(error);
            this.popToast('Error Encountered', 'There was an issue contacting the PDF Generation Service.', 'error');
        } finally {
            this.isLoading = false;
        }
    }

    @api
    async updateDownloadButtonStatus(){
        console.log('PDF Download button updated');
        this.popToast('PDF Report Ready', 'Your PDF Report is ready and will now download', 'info');

        if(!this.pdfId){
            this.pdfId = await getPdfContentDocumentId({assessmentId: this.id});
        }

        this.navigateToFilePreview(this.pdfId);
    }

    popToast(title, message, variant = 'info'){
        const toastEvent = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });

        this.dispatchEvent(toastEvent);
    }

    navigateToFilePreview(contentDocumentId){
        this[NavigationMixin.Navigate]({
                type: 'standard__namedPage',
                attributes: {
                    pageName: 'filePreview'
                },
                state: {
                    selectedRecordId: contentDocumentId
                }
            })
    }

    /**
     * Copy Mapping Document Link
     */

    // copyDocLink(){
    //     let tempTextAreaField = document.createElement('textarea');
    //     tempTextAreaField.style = 'position:fixed;top:-5rem;height:1px;width:10px;';

    //     // Assign the content we want to copy to the clipboard to the temporary text area field
    //     tempTextAreaField.value = this.xlsxLink;

    //     // Append it to the body of the page
    //     document.body.appendChild(tempTextAreaField);

    //     // Select the content of the temporary markup field
    //     tempTextAreaField.select();

    //     // Run the copy function to put the content to the clipboard
    //     document.execCommand('copy');

    //     // Remove the temporary element from the DOM as it is no longer needed
    //     tempTextAreaField.remove();

    //     const evt = new ShowToastEvent({
    //         title: this.label.toastSuccessTitle,
    //         message: this.label.toastSuccessMessage,
    //         variant: 'success',
    //     });
    //     this.dispatchEvent(evt);
    // }


}