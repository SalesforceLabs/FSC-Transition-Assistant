import { LightningElement, track, api } from 'lwc';

export default class MappingRow extends LightningElement {

    @api hideDetails = false; //If true, hides the "Show Details" section from this row
    //Schema should be retrieved by the mappingSection or top-level component instead
    @api orgSchema = [];
    @api rowIndex;

    //@track mappingInfo = {"source":"", "destination":"", "fieldMapping":[{"source":"","destination":""}], "recordTypeMapping":[{"source":"","destination":""}]};
    @api mappingInfo;
    @track sourceDef = {"recordTypes":[], "fields":[]};
    @api objectCache = {};

    label = {

    };

    @track isLoading = false;

    connectedCallback(){
        //this.mappingInfo = JSON.parse(JSON.stringify(this.mappingInfo))
    }

    @api
    reset(e){
        //this.mappingInfo = JSON.parse(JSON.stringify(this.mappingInfo));
        //this.mappingInfo.source = '';
        var sourceCombobox = this.template.querySelector('lightning-combobox');
        sourceCombobox.value = '';
        console.log("Reset");
    }

    optionClicked(e){
        this.isLoading = true;
        new Promise(
            (resolve,reject) => {
              setTimeout(()=> {
                  this.selectRow(e);
                  resolve();
              }, 0);
          }).then(
              () => this.isLoading = false
          );
    }

    /* Combobox Functions */
    selectRow(e){
        //this.isLoading = true;
        //this.mappingInfo = JSON.parse(JSON.stringify(this.mappingInfo));
        console.log("Row selected");
        // try{
            //var index = e.target.dataset.index;
            //var level = e.target.dataset.level;
            //var type = e.target.dataset.type;
            var value = e.detail.value;

            this.dispatchEvent(new CustomEvent("sourceselect", {detail: {row: this.rowIndex, value: value}}));

        //     console.log("==Value: "+value);

        //     if(level==='object'){
        //         if(type==='source'){
        //             this.dispatchEvent(new CustomEvent("sourceselect", {detail: {row: this.rowIndex, value: value}}));
        //             //this.mappingInfo.source = value;
        //             // if(!value){
        //             //     delete this.mappingInfo.showDetails;
        //             // }else{
        //             //     console.log("Set show details");
        //             //     this.mappingInfo.showDetails = true;
        //             // }
        //         }else{
        //             this.mappingInfo.destination = value;
        //         }
        //     }else if(level==='recordtype'){
        //         if(type==='source'){
        //             this.recordTypeMapping[index].source = value;
        //         }else{
        //             if(value==='new'){
        //                 //Pop-up new field modal
        //                 this.popupModal('recordtype');
        //             }else{
        //                 this.recordTypeMapping[index].destination = value;
        //             }          
        //         }
        //     }else if(level==='field'){
        //         if(type==='source'){
        //             this.fieldMapping[index].source = value;
        //         }else{
        //             if(value==='new'){
        //                 //Pop-up new field modal
        //                 this.popupModal('field');
        //             }else{
        //                 this.fieldMapping[index].destination = value;
        //             }
        //         }
        //     }
        // }catch(e){
        //     console.log("==ERROR: ",e);
        // }
        //console.log("Complete: ",this.mappingInfo);
        //this.isLoading = false;
    }

    addRow(e){
        var level = e.target.dataset.level;
        if(level==='recordtype'){
            this.mappingInfo.recordTypeMapping.push({"userGenerated":"true"});
        }else if(level==='field'){
            this.mappingInfo.fieldMapping.push({"userGenerated":"true"});
        }
    }

    removeRow(e){
        var index = e.target.dataset.index;
        var level = e.target.dataset.level;

        if(level==='recordtype'){
            this.mappingInfo.recordTypeMapping.splice(index, 1);
        }else if(level==='field'){
            this.mappingInfo.fieldMapping.splice(index, 1);
        }
    }

    get shouldShowDetails(){
        return this.hideDetails !== true && this.mappingInfo.showDetails;
    }

    /** New Field/RT Modal Actions */
    popupModal(type){

    }

}