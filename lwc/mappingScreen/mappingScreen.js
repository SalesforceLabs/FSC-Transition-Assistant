import { LightningElement, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

//Apex Methods
import getObjectMapping from '@salesforce/apex/MappingService.getObjectMappingForAssessment';
import getOrgDef from '@salesforce/apex/MappingService.getOrgDefinition';
import getObjectDef from '@salesforce/apex/MappingService.getInfoForSObject';
import saveMappingFile from '@salesforce/apex/MappingService.saveMapping';
import getFSCDef from '@salesforce/apex/MappingService.getFSCSchema';
import getDefaultRts from '@salesforce/apex/MappingService.getDefaultRecordTypes';

//Custom Labels
import UISaveButtonText from '@salesforce/label/c.UISaveButtonText';
import UICancelButtonText from '@salesforce/label/c.UICancelButtonText';
import UIPicklistPlaceholderText from '@salesforce/label/c.UIPicklistPlaceholderText';
import UIFinishButtonText from '@salesforce/label/c.UIFinishButtonText';
import UIBackButtonText from '@salesforce/label/c.UIBackButtonText';
import ToastTitleSuccess from '@salesforce/label/c.ToastTitleSuccess';
import ToastTitleError from '@salesforce/label/c.ToastTitleError';
import ToastMessageMappingSaved from '@salesforce/label/c.ToastMessageMappingSaved';
import ToastMessageAutoMap from '@salesforce/label/c.ToastMessageAutoMap';
import ToastMessageError from '@salesforce/label/c.ToastMessageError';

import MappingAdditionalDesc from '@salesforce/label/c.MappingAdditionalDesc';
import MappingAdditionalTitle from '@salesforce/label/c.MappingAdditionalTitle';
import MappingDetailsTitle from '@salesforce/label/c.MappingDetailsTitle';
import MappingFieldAdd from '@salesforce/label/c.MappingFieldAdd';
import MappingFieldDest from '@salesforce/label/c.MappingFieldDest';
import MappingFieldSource from '@salesforce/label/c.MappingFieldSource';
import MappingFieldTitle from '@salesforce/label/c.MappingFieldTitle';
import MappingIntro from '@salesforce/label/c.MappingIntro';
import MappingObjectAdd from '@salesforce/label/c.MappingObjectAdd';
import MappingObjectDest from '@salesforce/label/c.MappingObjectDest';
import MappingObjectRemove from '@salesforce/label/c.MappingObjectRemove';
import MappingObjectSource from '@salesforce/label/c.MappingObjectSource';
import MappingRecommendedDesc from '@salesforce/label/c.MappingRecommendedDesc';
import MappingRecommendedTitle from '@salesforce/label/c.MappingRecommendedTitle';
import MappingRTAdd from '@salesforce/label/c.MappingRTAdd';
import MappingRTDest from '@salesforce/label/c.MappingRTDest';
import MappingRTSource from '@salesforce/label/c.MappingRTSource';
import MappingRTTitle from '@salesforce/label/c.MappingRTTitle';

export default class MappingScreen extends NavigationMixin(LightningElement) {

    @api assessmentid;
    @track isLoading = false;
    

    @track assessment = {};

    //Temp variable to work with Apex
    @track newMappings = [];
    @track additionalMappings = [];

    //Object Definitions
    @track orgSchema = [];
    @api fscSchema = [];

    //Object Data
    @track objectDefs = {};
    @api fscDefs = {};

    @track mappings = [{"isSet": "true"}, {}];
    //@track orgSchema = [{"value":"","label":"-- None --"},{"value":"Test_Object__c", "label":"Test Object (Test_Object__c)", "fields":["Field1__c", "Field2__c", "Field3__c"]}, {"value":"Test_Object2__c", "label":"Test Object 2 (Test_Object2__c)", "fields":["Field4__c", "Field5__c", "Field6__c"]}];

    @track activeSections = [];

    @track defaultRecordTypeMap = {};

    @track currentMappingData;

    //Modal variables
    @track showModal = false;
    @track modalInfo = {};

    //@track mappings = [{"source":"Test_Object__c","destination":"FinServ__FinancialAccount__c", "fields":[{"source":"TestField__c","destination":"Address1__c"}]}];

    label = {
        UISaveButtonText,
        UICancelButtonText,
        UIPicklistPlaceholderText,
        UIFinishButtonText,
        UIBackButtonText,
        MappingAdditionalDesc,
        MappingAdditionalTitle,
        MappingDetailsTitle,
        MappingFieldAdd,
        MappingFieldDest,
        MappingFieldSource,
        MappingFieldTitle,
        MappingIntro,
        MappingObjectAdd,
        MappingObjectDest,
        MappingObjectRemove,
        MappingObjectSource,
        MappingRecommendedDesc,
        MappingRecommendedTitle,
        MappingRTAdd,
        MappingRTDest,
        MappingRTSource,
        MappingRTTitle,
        ToastTitleSuccess,
        ToastTitleError,
        ToastMessageMappingSaved,
        ToastMessageError,
        ToastMessageAutoMap
    };

    connectedCallback(){
        console.log("==Assessment Id: ",this.assessmentid);
        console.log("Defs: "+this.fscDefs);
        this.isLoading = true;
        // getFSCDef()
        // .then(fscResult => {
        //     console.log("==FSC Data: ",fscResult);
        //     //this.fscSchema = fscResult;
        //     fscResult.forEach(fscObject => {
        //         this.fscSchema.push({"label":fscObject.sourceObjectLabel + ' (' + fscObject.sourceObject +')', "value":fscObject.sourceObject, "desc":fscObject.sourceObjectDesc});
        //         this.fscDefs[fscObject.sourceObject] = fscObject;
        //     });
        getOrgDef()
        .then(schemaResult => {
            this.orgSchema = [{"value":"", "label":"-- None --"}];
            schemaResult.forEach(objectName => {
                this.orgSchema.push({"value":objectName, "label":objectName});
            });
            // this.orgSchema.sort(function(a,b) {return (a.label > b.label) ? 1 : ((b.label > a.label) ? -1 : 0);} );
            console.log("==Objects: ",this.orgSchema);

            getObjectMapping({assessmentId:this.assessmentid})
            .then(result => {
                console.log('==MAP JSON OBJECT',result);
                this.newMappings = result.recommended;
                if(result.additional){
                    this.additionalMappings = result.additional;
                }else{
                    this.additionalMappings = [];
                }
                this.isLoading = false;
                this.dispatchEvent(new CustomEvent("stoploading", {}));
            })
            .catch(error => {
                console.log(error);
                this.isLoading = false;
            });
        })
        .catch(error => {
            console.log(error);
            this.isLoading = false;
        });
        // });
        // .catch(error => {
        //     console.log(error);
        //     this.isLoading = false;
        // });

        
    }

    addRow(e){
        //TODO: Add top-level index as well
        var index = e.target.dataset.index;
        var objectIndex = e.target.dataset.objectindex;
        var type = e.target.dataset.type;
        console.log("Add row");

        if(type==='additional'){
            try{
                if(this.additionalMappings[objectIndex].fieldMapping){
                    this.additionalMappings[objectIndex].fieldMapping.push({"destination": "", "source": "", "truncate": "false", "userGenerated":"true"});
                }else{
                    this.additionalMappings[objectIndex].fieldMapping = [{"destination": "", "source": "", "truncate": "false", "userGenerated":"true"}];
                }
                console.log("Row added");
            }catch(error){
                console.log('==ERROR: ', error);
            }
        }else{
            console.log("Add row to index: "+index+ ' and objectindex '+objectIndex);
            try{
                if(this.newMappings[index].mappingData[objectIndex].fieldMapping){
                    this.newMappings[index].mappingData[objectIndex].fieldMapping.push({"destination": "", "source": "", "truncate": "false", "userGenerated":"true"});
                }else{
                    this.newMappings[index].mappingData[objectIndex].fieldMapping = [{"destination": "", "source": "", "truncate": "false", "userGenerated":"true"}];
                }
                console.log("Row added");
            }catch(error){
                console.log('==ERROR: ', error);
            }
        }
        
        
    }

    addRecordTypeRow(e){
        //TODO: Add top-level index as well
        var index = e.target.dataset.index;
        var objectIndex = e.target.dataset.objectindex;
        var type = e.target.dataset.type;
        console.log("Add row");

        if(type==='additional'){
            try{
                if(this.additionalMappings[objectIndex].recordTypeMapping){
                    this.additionalMappings[objectIndex].recordTypeMapping.push({"destination": "", "source": "", "truncate": "false", "userGenerated":"true"});
                }else{
                    this.additionalMappings[objectIndex].recordTypeMapping = [{"destination": "", "source": "", "truncate": "false", "userGenerated":"true"}];
                }
                console.log("Row added");
            }catch(error){
                console.log('==ERROR: ', error);
            }
        }else{
            console.log("Add row to index: "+index+ ' and objectindex '+objectIndex);
            try{
                if(this.newMappings[index].mappingData[objectIndex].recordTypeMapping){
                    this.newMappings[index].mappingData[objectIndex].recordTypeMapping.push({"destination": "", "source": "", "truncate": "false", "userGenerated":"true"});
                }else{
                    this.newMappings[index].mappingData[objectIndex].recordTypeMapping = [{"destination": "", "source": "", "truncate": "false", "userGenerated":"true"}];
                }
                console.log("Row added");
            }catch(error){
                console.log('==ERROR: ', error);
            }
        }
        
        
    }

    //TODO: Look into combining row additions (and destinguish via data attribute)
    addObjectRow(e){
        console.log("Add object row");
        var index = e.target.dataset.index;
        var type = e.target.dataset.type;
        console.log("Add row to index: "+index);
        if(type==='additional'){
            this.additionalMappings.push({"userGenerated":"true"});
        }else{
            this.newMappings[index].mappingData.push({"userGenerated":"true"});
        }
    }

    removeRow(e){
        var index = e.target.dataset.index;
        var fieldIndex = e.target.dataset.fieldindex;
        var objectIndex = e.target.dataset.objectindex;
        var type = e.target.dataset.type;
        console.log("Remove row");
        if(type==='additional'){
            this.additionalMappings[objectIndex].fieldMapping.splice(fieldIndex, 1);
        }else{
            console.log("Remove row to index: "+index, 'at row '+fieldIndex);
            this.newMappings[index].mappingData[objectIndex].fieldMapping.splice(fieldIndex, 1);
        }
        console.log("Row removed");
    }

    removeRecordTypeRow(e){
        var index = e.target.dataset.index;
        var objectIndex = e.target.dataset.objectindex;
        var rtIndex = e.target.dataset.rtindex;
        var type = e.target.dataset.type;
        console.log("Remove row");
        if(type==='additional'){
            this.additionalMappings[objectIndex].recordTypeMapping.splice(rtIndex, 1);
        }else{
            console.log("Remove row to index: "+index, 'at row '+rtIndex);
            this.newMappings[index].mappingData[objectIndex].recordTypeMapping.splice(rtIndex, 1);
        }
        
        console.log("Row removed");
    }

    removeObjectRow(e){
        var index = e.target.dataset.index;
        var objectIndex = e.target.dataset.objectindex;
        var type = e.target.dataset.type;
        console.log("Remove row");
        if(type==='additional'){
            this.additionalMappings.splice(objectIndex, 1);
        }else{
            console.log("Remove row to index: "+index, 'at row '+objectIndex);
            this.newMappings[index].mappingData.splice(objectIndex, 1);
        }
        
        console.log("Row removed");
    }

    handleToggleSection(){

    }

    handleToggleObjectSection(e){
        try{
            var index = e.target.dataset.index;
            var objectIndex = e.target.dataset.objectindex;
            var type = e.target.dataset.type;

            console.log("==Args: "+index+' | '+objectIndex + ' | '+type);
        }catch(e){
            console.log('==ERROR: ',e);
        }
        
    }

    orgSchemaSelect(e){
        var index = e.target.dataset.index;
        var objectIndex = e.target.dataset.objectindex;
        var value = e.detail.value;
        var type = e.target.dataset.type;
        console.log("Selected Object at indices "+index+' and '+objectIndex);
        console.log("Selected value: "+value);
        if(!value){
            if(type==='additional'){
                delete this.additionalMappings[objectIndex].showDetails
            }else{
                delete this.newMappings[index].mappingData[objectIndex].showDetails
            }
            
        }else{
            //Get Object Def
            if(!this.objectDefs[value]){
                this.isLoading = true;
                getObjectDef({apiName: value})
                .then(result => {
                    console.log('==Object Res',result);
                        
                    if(type==='additional'){
                        this.additionalMappings[objectIndex].sourceDef = result;
                        this.additionalMappings[objectIndex].showDetails = true;
                    this.additionalMappings[objectIndex].source = value;
                    }else{
                        this.newMappings[index].mappingData[objectIndex].sourceDef = result;
                        this.newMappings[index].mappingData[objectIndex].showDetails = true;
                        this.newMappings[index].mappingData[objectIndex].source = value;
                    }

                    //Cache object for future use
                    this.objectDefs[value] = result;
                    
                    this.isLoading = false;
                })
                .catch(error => {
                    console.log(error);
                    this.isLoading = false;
                });
            }else{
                if(type==='additional'){
                    this.additionalMappings[objectIndex].sourceDef = this.objectDefs[value];
                    this.additionalMappings[objectIndex].showDetails = true;
                    this.additionalMappings[objectIndex].source = value;
                }else{
                    this.newMappings[index].mappingData[objectIndex].sourceDef = this.objectDefs[value];
                    this.newMappings[index].mappingData[objectIndex].showDetails = true;
                    this.newMappings[index].mappingData[objectIndex].source = value;
                }
            } 
        }
    }

    fscSchemaSelect(e){
        this.isLoading = true;
        var index = e.target.dataset.index;
        var objectIndex = e.target.dataset.objectindex;
        var value = e.detail.value;
        var type = e.target.dataset.type;
        console.log("Selected Object at indices "+index+' and '+objectIndex);
        console.log("Selected value: "+value);
        try{
            if(type==='additional'){
                this.additionalMappings[objectIndex].destination = value;
                //Set fields and record types
                var mappingInfo = this.fscDefs[value];
                this.additionalMappings[objectIndex].destinationDef = mappingInfo;
                // this.additionalMappings[objectIndex].destin = mappingInfo.fieldMapping;
                // this.additionalMappings[objectIndex].rtList = mappingInfo.recordTypes;
            }else{
                this.newMappings[index].mappingData[objectIndex].destination = value;
            } 
            this.isLoading = false;
        }catch(e){
            console.log("==ERROR: ",e);
        }
        
    }

    orgRecordTypeSelect(e){
        var index = e.target.dataset.index;
        var objectIndex = e.target.dataset.objectindex;
        var recordTypeIndex = e.target.dataset.recordtyypeindex;
        var value = e.detail.value;
        var type = e.target.dataset.type;
        console.log("Selected Object at feature "+index+' and object '+objectIndex+ ' and record type '+recordTypeIndex);
        console.log("Selected value: "+value);

        if(type==='additional'){
            this.additionalMappings[objectIndex].recordTypeMapping[recordTypeIndex].source = value;
        }else{
            this.newMappings[index].mappingData[objectIndex].recordTypeMapping[recordTypeIndex].source = value;
        }
    }

    fscRecordTypeSelect(e){
        var index = e.target.dataset.index;
        var objectIndex = e.target.dataset.objectindex;
        var recordTypeIndex = e.target.dataset.recordtyypeindex;
        var value = e.detail.value;
        var type = e.target.dataset.type;
        console.log("Selected Object at feature "+index+' and object '+objectIndex+ ' and record type '+recordTypeIndex);
        console.log("Selected value: "+value);

        if(value==='new'){
            console.log("New rt");
            try{
                this.modalInfo = {'category':type,'indicies':[index, objectIndex, recordTypeIndex],'type':'rt'};
                this.openModal();
            }catch(e){
                console.log("==ERROR: ",e);
            }
            
        }else{
            if(type==='additional'){
                this.additionalMappings[objectIndex].recordTypeMapping[recordTypeIndex].destination = value;
            }else{
                this.newMappings[index].mappingData[objectIndex].recordTypeMapping[recordTypeIndex].destination = value;
            }
        }

        
    }

    orgFieldSelect(e){
        var index = e.target.dataset.index;
        var objectIndex = e.target.dataset.objectindex;
        var fieldIndex = e.target.dataset.fieldindex;
        var value = e.detail.value;
        var type = e.target.dataset.type;
        console.log("Selected Object at feature "+index+' and object '+objectIndex+ ' and field '+fieldIndex);
        console.log("Selected value: "+value);

        if(type==='additional'){
            this.additionalMappings[objectIndex].fieldMapping[fieldIndex].source = value;
        }else{
            this.newMappings[index].mappingData[objectIndex].fieldMapping[fieldIndex].source = value;
        }
    }

    fscFieldSelect(e){
        var index = e.target.dataset.index;
        var objectIndex = e.target.dataset.objectindex;
        var fieldIndex = e.target.dataset.fieldindex;
        var value = e.detail.value;
        var type = e.target.dataset.type;
        console.log("Selected Object at feature "+index+' and object '+objectIndex+ ' and field '+fieldIndex);
        console.log("Selected value: "+value);

        if(value==='new'){
            this.modalInfo = {'category':type,'indicies':[index, objectIndex, fieldIndex],'type':'field'};
            this.openModal();
        }else{
            if(type==='additional'){
                this.additionalMappings[objectIndex].fieldMapping[fieldIndex].destination = value;
            }else{
                this.newMappings[index].mappingData[objectIndex].fieldMapping[fieldIndex].destination = value;
            }
        }  
    }

    removeItem(){
        console.log("Remove");
    }

    //TODO: Merge saveProgress and completeMapping so it can reuse code
    saveProgress(){
        this.isLoading = true;
        console.log("Save");
        console.log("==Mappings: ",this.newMappings);
        console.log("==Additional Mappings: ",this.additionalMappings);
        var isEmpty = true;

        //Combine mappings
        try{
            var mappingFileData = {};
            mappingFileData.recommended = [];
            mappingFileData.additional = [];
            this.newMappings.forEach(row => {
                var recRow = JSON.parse(JSON.stringify(row));
                if(recRow.mappingData){
                    recRow.mappingData.forEach(selection => {
                        if((selection.fieldMapping && selection.fieldMapping.length>0 )|| (selection.recordTypeMapping && selection.recordTypeMapping.length>0)){
                            isEmpty = false;
                        }
                        delete selection.sourceDef;
                        delete selection.destinationDef;
                    });
                    mappingFileData.recommended.push(recRow);
                }
            });

            this.additionalMappings.forEach(row => {
                if(row.showDetails){
                    var mappingItem = JSON.parse(JSON.stringify(row));
                    delete mappingItem.rtList;
                    delete mappingItem.fieldList;
                    delete mappingItem.sourceDef;
                    delete mappingItem.destinationDef;
                    mappingFileData.additional.push(mappingItem);
                }
            });
        }catch(e){
            console.log('==ERROR: ',e);
        }

        saveMappingFile({recordId: this.assessmentid, filename: 'mapping', filetype:'json', filedata: JSON.stringify(mappingFileData), isEmpty: isEmpty})
        .then(result => {
            console.log('==Object Res',result);
            
            this.isLoading = false;
            
            const evt = new ShowToastEvent({
                title: this.label.ToastTitleSuccess,
                message: this.label.ToastMessageMappingSaved,
                variant: 'success',
            });
            this.dispatchEvent(evt);
        })
        .catch(error => {
            console.log(error);
            this.isLoading = false;
            const evt = new ShowToastEvent({
                title: this.label.ToastTitleError,
                message: this.label.ToastMessageError,
                variant: 'success',
            });
            this.dispatchEvent(evt);
        });
    }

    completeMapping() {
        this.isLoading = true;
        console.log("==Mappings: ",this.newMappings);
        console.log("==Additional Mappings: ",this.additionalMappings);
        var isEmpty = true;

        //Combine mappings
        try{
            var mappingFileData = {};
            mappingFileData.recommended = [];
            mappingFileData.additional = [];
            this.newMappings.forEach(row => {
                var recRow = JSON.parse(JSON.stringify(row));
                if(recRow.mappingData){
                    recRow.mappingData.forEach(selection => {
                        if((selection.fieldMapping && selection.fieldMapping.length>0 )|| (selection.recordTypeMapping && selection.recordTypeMapping.length>0)){
                            isEmpty = false;
                        }
                        delete selection.sourceDef;
                        delete selection.destinationDef;
                    });
                    mappingFileData.recommended.push(recRow);
                }
            });

            this.additionalMappings.forEach(row => {
                if(row.showDetails){
                    var mappingItem = JSON.parse(JSON.stringify(row));
                    delete mappingItem.rtList;
                    delete mappingItem.fieldList;
                    delete mappingItem.sourceDef;
                    delete mappingItem.destinationDef;
                    mappingFileData.additional.push(mappingItem);
                }
            });
        }catch(e){
            console.log('==ERROR: ',e);
        }
        

        console.log("==JSON to save: ",mappingFileData);

        saveMappingFile({recordId: this.assessmentid, filename: 'mapping', filetype:'json', filedata: JSON.stringify(mappingFileData), isEmpty: isEmpty})
        .then(result => {
            console.log('==Object Res',result);
            
            this.isLoading = false;
            console.log("Mapping saved");

            //Navigate to Assessment Detail
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.assessmentid,
                    actionName: 'view'
                },
            });
            //this.dispatchEvent(new CustomEvent("closemappingscreen", {}));
        })
        .catch(error => {
            console.log(error);
            this.isLoading = false;
        });
    }

    openModal(){
        this.showModal = true;
    }

    saveAndCloseModal(event){
        //Make additions to mapping
        try{
            var sectionIndex = this.modalInfo.indicies[0];
            var objectIndex = this.modalInfo.indicies[1];
            var newMeta = event.detail;
            if(this.modalInfo.type==='rt'){
                var recordTypeIndex = this.modalInfo.indicies[2];
                if(this.modalInfo.category==='additional'){
                    console.log("New rt, additional at indicies "+objectIndex+' and '+recordTypeIndex);

                    this.additionalMappings[objectIndex].destinationDef.recordTypes.unshift({label: '[NEW] ' + newMeta.label, value: newMeta.apiName, newMeta: newMeta});
                    this.additionalMappings[objectIndex].recordTypeMapping[recordTypeIndex].destination = newMeta.apiName;
                    this.additionalMappings[objectIndex].recordTypeMapping[recordTypeIndex].newMeta = newMeta;
                    console.log("==DesDef: ",this.additionalMappings[objectIndex].destinationDef.recordTypes);
                }else{
                    console.log("New rt, main at indicies "+sectionIndex+' and '+objectIndex+' and '+recordTypeIndex);

                    this.newMappings[sectionIndex].mappingData[objectIndex].destinationDef.recordTypes.unshift({label: '[NEW] ' + newMeta.label, value: newMeta.apiName, newMeta: newMeta});
                    this.newMappings[sectionIndex].mappingData[objectIndex].recordTypeMapping[recordTypeIndex].destination = newMeta.apiName;
                    this.newMappings[sectionIndex].mappingData[objectIndex].recordTypeMapping[recordTypeIndex].newMeta = newMeta;
                }
            }else{
                var fieldIndex = this.modalInfo.indicies[2];
                if(this.modalInfo.category==='additional'){
                    console.log("New field, additional at indicies "+objectIndex+' and '+fieldIndex);

                    this.additionalMappings[objectIndex].destinationDef.fieldMapping.unshift({label: '[NEW] ' + newMeta.label, value: newMeta.apiName, newMeta: newMeta});
                    this.additionalMappings[objectIndex].fieldMapping[fieldIndex].destination = newMeta.apiName;
                    this.additionalMappings[objectIndex].fieldMapping[fieldIndex].newMeta = newMeta;
                }else{
                    console.log("New field, main at indicies "+sectionIndex+' and '+objectIndex+' and '+fieldIndex);

                    this.newMappings[sectionIndex].mappingData[objectIndex].destinationDef.fieldMapping.unshift({label: '[NEW] ' + newMeta.label, value: newMeta.apiName, newMeta: newMeta});
                    this.newMappings[sectionIndex].mappingData[objectIndex].fieldMapping[fieldIndex].destination = newMeta.apiName;
                    this.newMappings[sectionIndex].mappingData[objectIndex].fieldMapping[fieldIndex].newMeta = newMeta;
                }
            }
        }catch(e){
            console.log("==ERROR: ",e);
        }
        

        this.closeModal();
    }

    closeModal(){
        this.showModal = false;
    }

    cancelAssessment() {
        this.dispatchEvent(new CustomEvent("closemappingscreen", {}));
    }

    autoMapClicked(){
        this.isLoading = true;
        new Promise(
            (resolve,reject) => {
              setTimeout(()=> {
                  this.autoMap();
                  resolve();
              }, 0);
          }).then(
              () => this.isLoading = false
          );
    }

    autoMap(){
        //Retrieve Default Record Types
        // if(!this.defaultRecordTypeMap || this.defaultRecordTypeMap === {}){
            var sectionNames = [];
            //Iterate through sections
            this.newMappings.forEach(mappingSection => {
                sectionNames.push(mappingSection.sectionName);
            });

            //Call Apex
            getDefaultRts({sectionNames: sectionNames})
            .then(result => {
                console.log('==Defaults Result',result);  
                this.defaultRecordTypeMap = result;

                try{
                    //Recommended
                    this.newMappings.forEach(mappingSection => {
                        mappingSection.mappingData.forEach(recommendedMapping => {
                            //TODO: Check for "expanded" attribute (may need to create) to determine whether or not "automap" attribute needs to added instead

                            this.mapSection(recommendedMapping, mappingSection) 
                        });
                    });
                    //Additional
                    this.additionalMappings.forEach(objectMapping => {
                        this.mapSection(objectMapping, null);
                    });
                    
                    const evt = new ShowToastEvent({
                        title: this.label.ToastTitleSuccess,
                        message: this.label.ToastMessageAutoMap,
                        variant: 'success',
                    });
                    this.dispatchEvent(evt);
                    
                }catch(e){
                    console.log('==ERROR: ',e);
                }
            })
            .catch(error => {
                console.log(error);
                this.isLoading = false;
            });
        // }

        //Iterate through mappings and create new rows for each list
        // try{
        //     //Recommended
        //     this.newMappings.forEach(mappingSection => {
        //         mappingSection.mappingData.forEach(recommendedMapping => {
        //             this.mapSection(recommendedMapping, mappingSection) 
        //         });
        //     });
        //     //Additional
        //     this.additionalMappings.forEach(objectMapping => {
        //         this.mapSection(objectMapping, null);
        //     }); 
        // }catch(e){
        //     console.log('==ERROR: ',e);
        // }
    }

    mapSection(recommendedMapping, mappingSection){
        console.log('==Current Mapping: ',recommendedMapping);
        if(recommendedMapping.showDetails){
            var recordTypeDestinations = [];
            var fieldDestinations = [];
            //Grab existing mapped rows
            if(!recommendedMapping.recordTypeMapping){
                recommendedMapping.recordTypeMapping = [];
            }else{
                recommendedMapping.recordTypeMapping.forEach(rtRow => {
                    if(rtRow.destination){
                        recordTypeDestinations.push(rtRow.destination);
                    }
                });
            }
            
            if(!recommendedMapping.fieldMapping){
                recommendedMapping.fieldMapping = [];
            }else{
                recommendedMapping.fieldMapping.forEach(fieldRow => {
                    if(fieldRow.destination){
                        fieldDestinations.push(fieldRow.destination);
                    }
                });
            }
            
            // recommendedMapping.recordTypeMapping = [];
            // recommendedMapping.fieldMapping = [];

            //Check if default Record Type is present 
            var noMaster = false;

            recommendedMapping.recordTypeMapping.forEach(rtRow => {
                if(this.defaultRecordTypeMap[mappingSection.sectionName+recommendedMapping.destination] && rtRow.destination === this.defaultRecordTypeMap[mappingSection.sectionName+recommendedMapping.destination].apiName){
                    console.log("Found Default");
                    noMaster = true;
                }
            });

           

            //Record Types
            if(recommendedMapping.sourceDef){
                recommendedMapping.sourceDef.recordTypes.forEach(sourceRtFull => {
                    var defaultFound = false;
                    recommendedMapping.destinationDef.recordTypes.forEach(destinationRtFull => {
                        //String label to contain only actual name
                        var sourceRt = sourceRtFull.label.substring(0, sourceRtFull.label.indexOf(' ('));
                        var destinationRt = destinationRtFull.label.substring(0, destinationRtFull.label.indexOf(' ('));
                        //console.log("Source: ",sourceRt, " |Destination: "+destinationRt);

                        //TEST TODO REMOVE
                        if(mappingSection && this.defaultRecordTypeMap){
                            console.log("Default? ",this.defaultRecordTypeMap[mappingSection.sectionName+recommendedMapping.destination]);
                        }

                        //Also map Master if destination equals object name
                        if(sourceRt === destinationRt || (recommendedMapping.source === destinationRt && recommendedMapping.source === 'Master')){
                            if(!recordTypeDestinations.includes(destinationRtFull.value)){
                                if(sourceRt!=='Master' || (sourceRt==='Master' && noMaster===false)){
                                    recommendedMapping.recordTypeMapping.push({source: sourceRtFull.value, destination: destinationRtFull.value, "userGenerated":"true"});
                                }  
                            }
                        }
                        //Check API Name if label doesn't match
                        else if(sourceRtFull.value === destinationRtFull.value){
                            if(!recordTypeDestinations.includes(destinationRtFull.value)){
                                recommendedMapping.recordTypeMapping.push({source: sourceRtFull.value, destination: destinationRtFull.value, "userGenerated":"true"});
                            }
                        }
                    });

                });

                //Fields
                recommendedMapping.sourceDef.fields.forEach(sourceFieldFull => {
                    recommendedMapping.destinationDef.fieldMapping.forEach(destinationFieldFull => {
                        var sourceField = sourceFieldFull.label.substring(0, sourceFieldFull.label.indexOf(' ('));
                        var destinationField = destinationFieldFull.label.substring(0, destinationFieldFull.label.indexOf(' ('));
                        //console.log("Source: ",sourceField, " |Destination: "+destinationField);
                        
                        if(sourceField === destinationField){
                            //Check if they are the same data type as well
                            var sourceType = sourceFieldFull.label.substring(sourceFieldFull.label.lastIndexOf('(')+1, sourceFieldFull.label.lastIndexOf(')'));
                            var destType = destinationFieldFull.type.charAt(0).toUpperCase() + destinationFieldFull.type.slice(1);
                            if(sourceType===destType){
                                if(!fieldDestinations.includes(destinationFieldFull.value)){
                                    recommendedMapping.fieldMapping.push({source: sourceFieldFull.value, destination: destinationFieldFull.value, "userGenerated":"true"});
                                }
                            }
                        }
                        //Check API Name if label doesn't match
                        else if(sourceFieldFull.value === destinationFieldFull.value){
                            //Check if they are the same data type as well
                            var sourceType = sourceFieldFull.label.substring(sourceFieldFull.label.lastIndexOf('(')+1, sourceFieldFull.label.lastIndexOf(')'));
                            var destType = destinationFieldFull.type.charAt(0).toUpperCase() + destinationFieldFull.type.slice(1);
                            if(sourceType===destType){
                                if(!fieldDestinations.includes(destinationFieldFull.value)){
                                    recommendedMapping.fieldMapping.push({source: sourceFieldFull.value, destination: destinationFieldFull.value, "userGenerated":"true"});
                                }
                            }
                        }
                    });
                });
            }
            
        }
    }

    get recommendListEmpty(){
        return !this.newMappings || this.newMappings.length === 0;
    }

    goBack(){
        console.log("Go back to assessment");
        this.dispatchEvent(new CustomEvent("backfrommapping", {}));
    }
}