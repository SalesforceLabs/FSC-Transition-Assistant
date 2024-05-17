import { LightningElement, track, api } from 'lwc';

//Custom Labels
import UIConfirmButtonText from '@salesforce/label/c.UIConfirmButtonText';
import UICancelButtonText from '@salesforce/label/c.UICancelButtonText';
import UICloseButtonText from '@salesforce/label/c.UICloseButtonText';
import UINextButtonText from '@salesforce/label/c.UINextButtonText';
import UIBackButtonText from '@salesforce/label/c.UIBackButtonText';
import NewMetaTitleField from '@salesforce/label/c.NewMetaTitleField';
import NewMetaTitleRecordType from '@salesforce/label/c.NewMetaTitleRecordType';
import NewMetaActive from '@salesforce/label/c.NewMetaActive';
import NewMetaApiName from '@salesforce/label/c.NewMetaApiName';
import NewMetaDecimals from '@salesforce/label/c.NewMetaDecimals';
import NewMetaDesc from '@salesforce/label/c.NewMetaDesc';
import NewMetaHelpText from '@salesforce/label/c.NewMetaHelpText';
import NewMetaLabel from '@salesforce/label/c.NewMetaLabel';
import NewMetaLength from '@salesforce/label/c.NewMetaLength';
import NewMetaRequired from '@salesforce/label/c.NewMetaRequired';
import NewMetaUnique from '@salesforce/label/c.NewMetaUnique';
import NewMetaExternalId from '@salesforce/label/c.NewMetaExternalId';
import NewMetaDefaultValue from '@salesforce/label/c.NewMetaDefaultValue';
import NewMetaConnectedObject from '@salesforce/label/c.NewMetaConnectedObject';
import NewMetaConnectedObjectPlaceholder from '@salesforce/label/c.NewMetaConnectedObjectPlaceholder';
import NewMetaChildRelationship from '@salesforce/label/c.NewMetaChildRelationship';

import NewMetaLocationNotation from '@salesforce/label/c.NewMetaLocationNotation';
import NewMetaPicklistValues from '@salesforce/label/c.NewMetaPicklistValues';
import NewMetaVisibleLines from '@salesforce/label/c.NewMetaVisibleLines';
import NewMetaDefaultChecked from '@salesforce/label/c.NewMetaDefaultChecked';
import NewMetaDefaultUnchecked from '@salesforce/label/c.NewMetaDefaultUnchecked';
import NewMetaReviewSummary from '@salesforce/label/c.NewMetaReviewSummary';

//Data Type Labels
import DataTypeCheckbox from '@salesforce/label/c.DataTypeCheckbox';
import DataTypeCurrency from '@salesforce/label/c.DataTypeCurrency';
import DataTypeDate from '@salesforce/label/c.DataTypeDate';
import DataTypeDatetime from '@salesforce/label/c.DataTypeDatetime';
import DataTypeEmail from '@salesforce/label/c.DataTypeEmail';
import DataTypeLocation from '@salesforce/label/c.DataTypeLocation';
import DataTypeLongText from '@salesforce/label/c.DataTypeLongText';
import DataTypeLookup from '@salesforce/label/c.DataTypeLookup';
import DataTypeMasterDetail from '@salesforce/label/c.DataTypeMasterDetail';
import DataTypeMultiSelect from '@salesforce/label/c.DataTypeMultiSelect';
import DataTypeNumber from '@salesforce/label/c.DataTypeNumber';
import DataTypePercent from '@salesforce/label/c.DataTypePercent';
import DataTypePhone from '@salesforce/label/c.DataTypePhone';
import DataTypePicklist from '@salesforce/label/c.DataTypePicklist';
import DataTypeRichText from '@salesforce/label/c.DataTypeRichText';
import DataTypeText from '@salesforce/label/c.DataTypeText';
import DataTypeTextArea from '@salesforce/label/c.DataTypeTextArea';
import DataTypeTime from '@salesforce/label/c.DataTypeTime';
import DataTypeUrl from '@salesforce/label/c.DataTypeUrl';

export default class MappingNewMetaModal extends LightningElement {
    //Boolean tracked variable to indicate if modal is open or not default value is false as modal is closed when page is loaded 
    @track isModalOpen = false;
    @api modalInfo;
    @api orgObjects = [];

    @track step;

    @track metaLabel = '';
    @track apiName = '';
    @track dataType = '';
    @track description = '';
    @track helpText = '';
    @track rtActive = false;
    @track required = false;
    @track unique = false;
    @track defaultValue = '';
    @track length;

    @track connectedObject = '';
    @track childRelationshipName = '';

    @track dataType = '';

    // fieldOptions = [{"label":"Checkbox","value":"bool"},{"label":"Date","value":"date"},{"label":"Date/Time","value":"datetime"},{"label":"Email","value":"email"},{"label":"Number","value":"integer"},{"label":"Phone","value":"phone"},{"label":"Text","value":"text"},{"label":"Text Area","value":"textarea"}, 
    // {"label":"URL","value":"url"}];

    label = {
        UIConfirmButtonText,
        UICancelButtonText,
        UICloseButtonText,
        UINextButtonText,
        UIBackButtonText,
        NewMetaTitleField,
        NewMetaTitleRecordType,
        NewMetaActive,
        NewMetaApiName,
        NewMetaDecimals,
        NewMetaDesc,
        NewMetaHelpText,
        NewMetaLabel,
        NewMetaLength,
        NewMetaRequired,
        NewMetaUnique,
        NewMetaExternalId,
        NewMetaDefaultValue,
        NewMetaConnectedObject,
        NewMetaConnectedObjectPlaceholder,
        NewMetaChildRelationship,
        DataTypeCheckbox,
        DataTypeCurrency,
        DataTypeDate,
        DataTypeDatetime,
        DataTypeEmail,
        DataTypeLocation,
        DataTypeLongText,
        DataTypeLookup,
        DataTypeMasterDetail,
        DataTypeMultiSelect,
        DataTypeNumber,
        DataTypePercent,
        DataTypePhone,
        DataTypePicklist,
        DataTypeRichText,
        DataTypeText,
        DataTypeTextArea,
        DataTypeTime,
        DataTypeUrl,
        NewMetaLocationNotation,
        NewMetaPicklistValues,
        NewMetaVisibleLines,
        NewMetaDefaultChecked,
        NewMetaDefaultUnchecked,
        NewMetaReviewSummary
    };

    connectedCallback(){
        this.openModal();
    }

    @api
    openModal() {
        // to open modal set isModalOpen track value as true
        this.isModalOpen = true;
        this.step = (this.isRecordType===true) ? 2 : 1;
        console.log("==Step: "+this.step);
        console.log("==RT? "+this.isRecordType);
    }
    closeModal() {
        this.dispatchEvent(new CustomEvent("closemodal", {}));
        this.step = 0;
    }
    goBack(){
        this.step = (this.isStep3) ? 2 : 1;
    }
    goNext(){
        const allValid = [...this.template.querySelectorAll('lightning-input')]
        .reduce((validSoFar, inputCmp) => {
                    inputCmp.reportValidity();
                    return validSoFar && inputCmp.checkValidity();
        }, true);

        const radiosValid = [...this.template.querySelectorAll('lightning-radio-group')]
        .reduce((validSoFar, inputCmp) => {
                    inputCmp.reportValidity();
                    return validSoFar && inputCmp.checkValidity();
        }, true);

        if(allValid && radiosValid){
            this.step = (this.isStep1) ? 2 : 3;
        }
    }
    saveItem() {
        //Validate
        // const allValid = [...this.template.querySelectorAll('lightning-input')]
        // .reduce((validSoFar, inputCmp) => {
        //             inputCmp.reportValidity();
        //             return validSoFar && inputCmp.checkValidity();
        // }, true);

        // if(allValid){
        //Assemble data
        var newMetadata = {};
        newMetadata.label = this.metaLabel;
        newMetadata.apiName = this.apiName;
        newMetadata.description = this.description;
        if(this.modalInfo.type==='rt'){
            newMetadata.active = this.rtActive;
        }else{
            newMetadata.dataType = this.dataType;
            newMetadata.helpText = this.helpText;
            newMetadata.length = this.length;
            newMetadata.required = this.required;
            newMetadata.unique = this.unique;
            newMetadata.defaultValue = this.defaultValue;
            newMetadata.connectedObject = this.connectedObject;
            newMetadata.childRelationshipName = this.childRelationshipName;
        }
        console.log("Add Field: ",newMetadata);
        this.dispatchEvent(new CustomEvent("saveandclosemodal", {detail: newMetadata}));
        // }      
    }

    setLabel(e){
        this.metaLabel = e.detail.value;
    }
    setApiName(e){
        this.apiName = e.detail.value;
    }
    setDescription(e){
        this.description = e.detail.value;
    }
    setHelpText(e){
        this.helpText = e.detail.value;
    }
    setDataType(e){
        this.dataType = e.detail.value;
        console.log("Type: "+this.dataType);
        console.log("Test: ",e.detail);
    }
    setActive(e){
        this.rtActive = e.detail.checked;
    }
    setRequired(e){
        console.log("Checked? "+e.detail.checked + ' | '+e.detail.value)
        this.required = e.detail.checked;
    }
    setUnique(e){
        this.unique = e.detail.checked;
    }
    setDefaultValue(e){
        this.defaultValue = e.detail.value;
    }
    setLength(e){
        this.length = e.detail.value;
    }
    setConnectedObject(e){
        this.connectedObject = e.detail.value;
    }
    setChildRelatonshipName(e){
        this.childRelationshipName = e.detail.value;
    }
    autoSetApiName(e){
        if(!this.apiName){
            var value = e.currentTarget.value;
            this.apiName = value.replaceAll(' ', '_');
        }
    }

    get fieldOptions(){
        return [{ label: this.label.DataTypeCheckbox, value: 'Checkbox'},{ label: this.label.DataTypeCurrency, value: 'Currency'},{ label: this.label.DataTypeDate, value: 'Date'},{ label: this.label.DataTypeDatetime, value: 'DateTime'},{ label: this.label.DataTypeEmail, value: 'Email'},{ label: this.label.DataTypeLocation, value: 'Location'},
        { label: this.label.DataTypeLookup, value: 'Lookup'},{ label: this.label.DataTypeMasterDetail, value: 'MasterDetail'},{ label: this.label.DataTypeNumber, value: 'Number'},{ label: this.label.DataTypePercent, value: 'Percent'},{ label: this.label.DataTypePhone, value: 'Phone'},{ label: this.label.DataTypePicklist, value: 'Picklist'},{ label: this.label.DataTypeMultiSelect, value: 'MultiselectPicklist'},{ label: this.label.DataTypeText, value: 'Text'},
        { label: this.label.DataTypeTextArea, value: 'TextArea'},{ label: this.label.DataTypeLongText, value: 'LongTextArea'},{ label: this.label.DataTypeRichText, value: 'LongTextArea'},{ label: this.label.DataTypeTime, value: 'Time'},{ label: this.label.DataTypeUrl, value: 'Url'}];
    }

    get checkedOptions(){
        return [{ label: this.label.NewMetaDefaultChecked, value: 'true'},{ label: this.label.NewMetaDefaultUnchecked, value: 'false'}]
    }

    get HeaderText(){
        //TODO: Move to Label
        return (this.modalInfo.type==='rt') ? this.label.NewMetaTitleRecordType : this.label.NewMetaTitleField;
    }

    get hasLength(){
        return (this.dataType === 'Text' || this.dataType === 'TextArea' || this.dataType === 'LongTextArea' || this.dataType === 'Number') ? true : false;
    }

    get showConnectedObject(){
        return (this.dataType === 'MasterDetail' || this.dataType === 'Lookup');
    }

    get showRequired(){
        return this.dataType!=='MasterDetail';
    }

    get showUnique(){
        return this.dataType!=='Lookup' && this.dataType!== 'MasterDetail';
    }

    get showDefault(){
        return this.dataType!=='Lookup' && this.dataType!== 'MasterDetail';
    }

    /* Data Type Specific Inputs */
    get showLocationNotation(){
        return this.dataType === 'Location';
    }

    get showVisibleLines(){
        return this.dataType === 'LongTextArea';
    }

    get showBooleanDefaultValue(){
        return this.dataType === 'Checkbox';
    }
    /* General Screen/Input Showing */

    get isRecordType(){
        return this.modalInfo.type==='rt';
    }

    get isStep1(){
        return this.step === 1;
    }

    get isStep2(){
        return this.step === 2;
    }

    get isStep3(){
        return this.step === 3;
    }
}