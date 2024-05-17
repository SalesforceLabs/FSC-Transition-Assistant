import { LightningElement, track, api } from 'lwc';

import apexSetStatus from '@salesforce/apex/AssessmentService.setStatus';
import getOrgDef from '@salesforce/apex/MappingService.getOrgDefinition';
import getMapping from '@salesforce/apex/MappingService.getMappingForSection';
import getJSON from '@salesforce/apex/MappingService.getRecommendedJSON';
import saveMappingFile from '@salesforce/apex/MappingService.saveMapping';
import getDefaultRts from '@salesforce/apex/MappingService.getDefaultRecordTypes';

import UINextButtonText from '@salesforce/label/c.UINextButtonText';
import UIBackButtonText from '@salesforce/label/c.UIBackButtonText';
import UICancelButtonText from '@salesforce/label/c.UICancelButtonText';
import MappingObjectDest from '@salesforce/label/c.MappingObjectDest';
import MappingObjectSource from '@salesforce/label/c.MappingObjectSource';

export default class MappingSection extends LightningElement {
    @api assessmentId;
    @api fscDefs;

    @track currentJSON;
    @track currentMappingData;
    @api mappingId = '';
    @api previousQuestion;
    @api hideDetails = false; //If true, hides the "Show Details" section from each mappingRow
    @api startAtEnd = false; //If true stars with the last mapping option first (used when going back rather than forward)
    @api indexOverride;
    @track sectionName = '';
    @track sectionHeaderText = '';
    @track sectionDescription = '';
    @track additionalInfo = null;

    @track orgSchema = [];
    @track objectCache = {};
    
    @track mappingData = [];
    //TEST Variable: switch when done
    // @track mappingData = [{"source":"", "destination":"", "fieldMapping":[{"source":"","destination":""}], "recordTypeMapping":[{"source":"","destination":""}]}, 
    // {"source":"", "destination":"", "fieldMapping":[{"source":"","destination":""}], "recordTypeMapping":[{"source":"","destination":""}]}];

    label = {
        UIBackButtonText,
        UINextButtonText,
        UICancelButtonText,
        MappingObjectDest,
        MappingObjectSource
    };

    @track mappingResult;

    @track isLoading = false;
    @track allAnswersList = [];
    @track answerList = [];
    @track mappingIndex = 0;

    connectedCallback(){
        //Call function to retrieve object set by feature (or all if blank)
        this.isLoading = true;
        console.log("==Assessment Id: ",this.assessmentId);
        console.log("==Recieved Id: ",this.mappingId);
        console.log("==previousQuestion: ",this.previousQuestion);
        if(this.previousQuestion){
            //this.sectionDescription = this.previousQuestion.SelectedAnswer;
            console.log("==Answer Values: ",this.previousQuestion.AnswerValues);
            if(this.previousQuestion.AnswerValues){
                this.previousQuestion.AnswerValues.forEach(answer => {
                    this.allAnswersList.push(answer.label);
                });
            }
            if(this.previousQuestion.ExcludeOptions){
                this.previousQuestion.ExcludeOptions.forEach(answer => {
                    this.allAnswersList.push(answer);
                });
            }
            
            console.log("==Seclected Answers: ",this.previousQuestion.SelectedAnswer);
            console.log("==Multi Answers: ",this.previousQuestion.SelectedAnswers);
        }

        //Get existing JSON
        getJSON({assessmentId: this.assessmentId})
        .then(existingJSON => {
            console.log("==Existing: ",existingJSON);
            if(existingJSON){
                this.currentJSON = existingJSON;
            }
            //Get Mapping
            getMapping({sectionId: this.mappingId, hideDetails: true})
            .then(mappingResult => {
                console.log('==Result: ',mappingResult);
                this.mappingResult = mappingResult;
                this.sectionName = mappingResult.sectionTitle;

                var answerName;

                console.log("Override?: "+this.indexOverride);
                //Single Select Answers
                if(this.previousQuestion.SelectedAnswers && this.previousQuestion.SelectedAnswers.length > 0){
                    //Multi Select Answers
                    answerName = this.previousQuestion.SelectedAnswers[0];
                    this.sectionDescription = mappingResult.sectionDescription.replace('{0}','<b>'+this.previousQuestion.SelectedAnswers[0]+'</b>');
                    this.previousQuestion.SelectedAnswers.forEach(answerValue => {
                        this.answerList.push(answerValue);
                    });

                    //If going backwards, start at last index
                    if(this.startAtEnd===true){
                        this.mappingIndex = this.answerList.length-1;
                        answerName = this.previousQuestion.SelectedAnswers[this.mappingIndex];
                        this.sectionDescription = mappingResult.sectionDescription.replace('{0}','<b>'+this.previousQuestion.SelectedAnswers[this.mappingIndex]+'</b>');
                    }else if(this.indexOverride){
                        console.log("Set Override");
                        this.mappingIndex = this.indexOverride;
                        answerName = this.previousQuestion.SelectedAnswers[this.mappingIndex];
                        this.sectionDescription = mappingResult.sectionDescription.replace('{0}','<b>'+this.previousQuestion.SelectedAnswers[this.mappingIndex]+'</b>');
                        this.indexOverride = null;
                    }
                }else if(this.previousQuestion.SelectedAnswer){
                    if(this.previousQuestion.SelectedAnswer==='Both'){
                        //Split answers values
                        answerName = this.previousQuestion.AnswerValues[0].label;
                        this.sectionDescription = mappingResult.sectionDescription.replace('{0}','<b>'+this.previousQuestion.AnswerValues[0].label+'</b>');
                        this.previousQuestion.AnswerValues.forEach(answerValue => {
                            if(answerValue.label!=='Both'){
                                this.answerList.push(answerValue.label);
                            }
                        });

                        //If going backwards, start at last index
                        if(this.startAtEnd===true){
                            this.mappingIndex = this.answerList.length-1;
                            answerName = this.previousQuestion.AnswerValues[this.mappingIndex].label;
                            this.sectionDescription = mappingResult.sectionDescription.replace('{0}','<b>'+this.previousQuestion.AnswerValues[this.mappingIndex].label+'</b>');
                        }else if(this.indexOverride){
                            console.log("Set Override");
                            this.mappingIndex = this.indexOverride;
                            answerName = this.previousQuestion.AnswerValues[this.mappingIndex].label;
                            this.sectionDescription = mappingResult.sectionDescription.replace('{0}','<b>'+this.previousQuestion.AnswerValues[this.mappingIndex].label+'</b>');
                            this.indexOverride = null;
                        }
                    }else{
                        answerName = this.previousQuestion.SelectedAnswer;
                        this.sectionDescription = mappingResult.sectionDescription.replace('{0}','<b>'+this.previousQuestion.SelectedAnswer+'</b>');
                        this.answerList.push(this.previousQuestion.SelectedAnswer);
                        console.log("==Selected Answers Array: ",this.previousQuestion.SelectedAnswers);
                    }
                }
                console.log("==Answer List: ",this.answerList);
                
                if(this.currentJSON){
                    //Check if we should load previous values
                    var found = false;
                    var parsedJSON = JSON.parse(this.currentJSON);
                    parsedJSON.recommended.forEach(sectionInfo => {
                        console.log("Section Name: "+answerName);
                        console.log("JSON Name: "+sectionInfo.sectionName);
                        if(sectionInfo.sectionName === answerName){
                            sectionInfo.mappingData.forEach(objectRow => {
                                var oRow = {"source":objectRow.source, "destination":objectRow.destination, "fieldMapping":objectRow.fieldMapping, "recordTypeMapping":objectRow.recordTypeMapping, "label":this.fscDefs[objectRow.destination].formattedLabel};
                                this.mappingData.push(oRow);
                            });
                            found = true;
                        }
                    });

                    if(found!==true){
                        mappingResult.sectionMappings.forEach(objectRow => {
                            var oRow = {"source":"", "destination":objectRow.sourceObject, "fieldMapping":[], "recordTypeMapping":[], "label":this.fscDefs[objectRow.sourceObject].formattedLabel};
                            this.mappingData.push(oRow);
                        });
                    }
                }else{
                    mappingResult.sectionMappings.forEach(objectRow => {
                        var oRow = {"source":"", "destination":objectRow.sourceObject, "fieldMapping":[], "recordTypeMapping":[], "label":this.fscDefs[objectRow.sourceObject].formattedLabel};
                        this.mappingData.push(oRow);
                    });
                }

                this.indexOverride = null;

                getDefaultRts({sectionNames: this.answerList})
                .then(result => {
                    console.log('==Defaults Result',result);  
                    this.defaultRecordTypeMap = result;

                    this.mappingData.forEach(objectRow => {
                        if(this.defaultRecordTypeMap[this.answerList[this.mappingIndex]+objectRow.destination] && this.defaultRecordTypeMap[this.answerList[this.mappingIndex]+objectRow.destination].additionalInfo){
                            console.log("Show Additional Info: "+this.defaultRecordTypeMap[this.answerList[this.mappingIndex]+objectRow.destination].additionalInfo);
                            this.additionalInfo = this.defaultRecordTypeMap[this.answerList[this.mappingIndex]+objectRow.destination].additionalInfo;
                        }
                    });   
                })
                .catch(error => {
                    console.log(error);
                    //this.isLoading = false;
                });

                apexSetStatus({assessmentId: this.assessmentId, questionId: this.previousQuestion.QuestionId, index: this.previousQuestion.QuestionNumber, mappingIndex: this.mappingIndex, numberChange: ''})
                .then(statusResult => {
                    getOrgDef()
                    .then(schemaResult => {
                        this.orgSchema = [{"value":"", "label":"-- None --"}];
                        schemaResult.forEach(objectName => {
                            this.orgSchema.push({"value":objectName, "label":objectName});
                        });
                        // this.orgSchema.sort(function(a,b) {return (a.label > b.label) ? 1 : ((b.label > a.label) ? -1 : 0);} );
                        console.log("==Objects: ",this.orgSchema);
                        this.isLoading = false;
                    })
                    .catch(error => {
                        console.log('Error 1: ',error);
                        this.isLoading = false;
                    });
                })
                .catch(error => {
                    console.log("==Error: ",error);
                    this.error = error;
                }); 
                
                //this.mappingData = mappingResult.sectionMappings;
                //Get Object List
                
            })
            .catch(error => {
                console.log('Error 2: ',error);
                this.isLoading = false;
            });
        })
        .catch(error => {
            console.log('Error 3: ',error);
        });
    }

    goPrevious(){
        this.additionalInfo = null;
        this.isLoading = true;
        console.log("Previous");
        console.log("Mapping Index: "+this.mappingIndex);
        if(this.mappingIndex==0){
            //Go back to previous question
            this.dispatchEvent(new CustomEvent("goback", {}));
            console.log("Prev Question fired");
        }else{
            console.log("Prev Mapping");
            //Go back to previous mapping
            this.mappingIndex--;
            var sectionName = this.answerList[this.mappingIndex];
            this.sectionDescription = this.mappingResult.sectionDescription.replace('{0}','<b>'+sectionName+'</b>');

            var parsedJSON = JSON.parse(this.currentJSON);

            //Load previous sources (if any)
            this.mappingData = [];
            parsedJSON.recommended.forEach(sectionInfo => {
                if(sectionInfo.sectionName === sectionName){
                    sectionInfo.mappingData.forEach(objectRow => {
                        var oRow = {"source":objectRow.source, "destination":objectRow.destination, "fieldMapping":objectRow.fieldMapping, "recordTypeMapping":objectRow.recordTypeMapping, "label":this.fscDefs[objectRow.destination].formattedLabel};
                        this.mappingData.push(oRow);
                    });
                }
            });

            this.mappingData.forEach(objectRow => {
                if(this.defaultRecordTypeMap[this.answerList[this.mappingIndex]+objectRow.destination] && this.defaultRecordTypeMap[this.answerList[this.mappingIndex]+objectRow.destination].additionalInfo){
                    console.log("Show Additional Info: "+this.defaultRecordTypeMap[this.answerList[this.mappingIndex]+objectRow.destination].additionalInfo);
                    this.additionalInfo = this.defaultRecordTypeMap[this.answerList[this.mappingIndex]+objectRow.destination].additionalInfo;
                }
            });

            apexSetStatus({assessmentId: this.assessmentId, questionId: this.previousQuestion.QuestionId, index: this.previousQuestion.QuestionNumber, mappingIndex: this.mappingIndex, numberChange: ''})
            .then(statusResult => {
                this.isLoading = false;
            })
            .catch(error => {
                console.log("==Error: ",error);
                this.error = error;
            }); 

            // this.mappingResult.sectionMappings.forEach(objectRow => {
            //     var oRow = {"source":"", "destination":objectRow.sourceObject, "fieldMapping":objectRow.fieldMapping, "recordTypeMapping":objectRow.recordTypes};
            //     this.mappingData.push(oRow);
            // });
            console.log("Complete");
        }
    }

    cancelAssessment() {
        this.dispatchEvent(new CustomEvent("closeassessment", {}));
        console.log("Cancel event fired");
    }

    selectRow(e){
        try{
            var index = e.target.dataset.index;
            var value = e.detail.value;
            this.mappingData[index].source = value;
            if(!value){
                delete this.mappingData[index].showDetails;
            }else{
                console.log("Set show details");
                this.mappingData[index].showDetails = true;
            }
        }catch(e){
            console.log('==ERROR: ',e);
        }
        
    }

    // sourceselected(e){
    //     var rowIndex = e.detail.row;
    //     var value = e.detail.value;
    //     this.mappingData[rowIndex].source = value;
    //     this.mappingData[rowIndex].showDetails = true;
    //     console.log('Value sent: '+value+ ' at row '+rowIndex);
    // }

    @api
    submitMapping(){
        this.isLoading = true;
        console.log("Save mapping");

        // var mappingCmps = this.template.querySelectorAll('c-mapping-row');
        // console.log("==Mappings: ",mappingCmps);

        try{
            var mappingList = [];
            this.mappingData.forEach(mappingItem => {
                // if(cmp.mappingInfo){
                    //var mappingItem = JSON.parse(JSON.stringify(cmp.mappingInfo));

                    // mappingItem.fieldMapping = [];
                    // mappingItem.recordTypeMapping = [];
                    //mappingItem.showDetails = true;

                    //TODO: Restore this when ready
                    if(!mappingItem.fieldMapping){
                        mappingItem.fieldMapping = [];
                    }
                    if(!mappingItem.recordTypeMapping){
                        mappingItem.recordTypeMapping = [];
                    }
                    
                    if(mappingItem.source){
                        mappingItem.showDetails = true;
                    }
                    // 

                    // //Check if default RT should apply
                    // if(this.defaultRecordTypeMap && this.defaultRecordTypeMap[this.answerList[this.mappingIndex]+mappingItem.destination]){
                    //         var defaultFound = false;
                    //         mappingItem.recordTypeMapping.forEach(rtMapping => {
                    //             if(rtMapping.destination === this.defaultRecordTypeMap[this.answerList[this.mappingIndex]+mappingItem.destination]){
                    //                 defaultFound = true;
                    //             }
                    //         });
                    //         if(defaultFound===false){
                    //             mappingItem.recordTypeMapping.push({source: 'Master', destination: this.defaultRecordTypeMap[this.answerList[this.mappingIndex]+mappingItem.destination], "userGenerated":"true"});
                    //         }else{
                    //             console.log("Default found");
                    //         }
                    // }

                    //Insert section name
                    //mappingItem.sectionName = this.sectionName + ' - ' + this.answerList[this.mappingIndex];
                    mappingList.push(mappingItem);
                    //cmp.reset();
                // }
            });

            if(mappingList){
                //Call Apex (updated function will parse and populate appropriate top-level layer)
                console.log("==To add to JSON: ",mappingList);
                if(!this.currentJSON){
                    //Create new structure
                    this.currentMappingData = {"recommended":[], "additional":[]};
                    //Add default
                    if(mappingList){
                        mappingList.forEach(objectRow => {
                            console.log("==Check: "+this.answerList[this.mappingIndex]+objectRow.destination);
                            console.log("Current answer: "+this.answerList[this.mappingIndex]);
                            console.log("Mapping Item: ",this.sectionName);

                            if(this.defaultRecordTypeMap[this.answerList[this.mappingIndex]+objectRow.destination]){
                                console.log("Add default: "+this.defaultRecordTypeMap[this.answerList[this.mappingIndex]+objectRow.destination].apiName);
                                objectRow.recordTypeMapping.push({"source":"Master", "destination": this.defaultRecordTypeMap[this.answerList[this.mappingIndex]+objectRow.destination].apiName, "userGenerated":"true"});
                            }
                        });
                    }
                    this.currentMappingData.recommended.push({"sectionName":this.answerList[this.mappingIndex], "mappingData":mappingList});
                    this.currentJSON = JSON.stringify(this.currentMappingData);
                }else{
                    //TODO: Update existing structure and save
                    this.currentMappingData = JSON.parse(this.currentJSON);
                    console.log("==Update existing: ",this.currentMappingData);

                    //Check if section already exists
                    var found = false;

                    for (let index = 0; index < this.currentMappingData.recommended.length; index++) {
                        if(this.currentMappingData.recommended[index].sectionName === this.answerList[this.mappingIndex]){
                            this.currentMappingData.recommended[index] = {"sectionName":this.answerList[this.mappingIndex], "mappingData":mappingList};
                            found = true;
                            console.log("Section updated");
                        }
                        //If item not in selected answers list, delete it
                        if(!this.answerList.includes(this.currentMappingData.recommended[index].sectionName) && this.allAnswersList.includes(this.currentMappingData.recommended[index].sectionName)){
                            console.log("Delete "+this.currentMappingData.recommended[index].sectionName);
                            this.currentMappingData.recommended.splice(index, 1);
                            index--;
                        }
                        
                    }
                    // this.currentMappingData.recommended.forEach((section, index) => {
                    //     if(section.sectionName === this.answerList[this.mappingIndex]){
                    //         this.currentMappingData.recommended[index] = {"sectionName":this.answerList[this.mappingIndex], "mappingData":mappingList};
                    //         found = true;
                    //         console.log("Section updated");
                    //     }
                    // });

                    if(found===false){
                        //Add default
                        if(mappingList){
                            mappingList.forEach(objectRow => {
                                console.log("==Check: "+this.answerList[this.mappingIndex]+objectRow.destination);
                                console.log("Current answer: "+this.answerList[this.mappingIndex]);
                                console.log("Mapping Item: ",this.sectionName);
                                if(this.defaultRecordTypeMap[this.answerList[this.mappingIndex]+objectRow.destination]){
                                    console.log("Add default: "+this.defaultRecordTypeMap[this.answerList[this.mappingIndex]+objectRow.destination].apiName);
                                    objectRow.recordTypeMapping = [{"source":"Master", "destination": this.defaultRecordTypeMap[this.answerList[this.mappingIndex]+objectRow.destination].apiName, "userGenerated":"true"}];
                                }
                            });
                        }
                           
                        //Add to mapping
                        this.currentMappingData.recommended.push({"sectionName":this.answerList[this.mappingIndex], "mappingData":mappingList});  
                    }
                }
                console.log("To save: ",this.currentMappingData);
                saveMappingFile({recordId: this.assessmentId, filename: 'mapping', filetype:'json', filedata: JSON.stringify(this.currentMappingData), isEmpty: true})
                .then(result => {
                    this.additionalInfo = null;

                    console.log('==Object Res',result); 
                    console.log("Mapping saved");
                    this.currentJSON = JSON.stringify(this.currentMappingData);

                    //If other mappings in loop, go to the next one. Else, go to next question
                    if(this.answerList.length > this.mappingIndex+1){
                        console.log("Next Mapping");
                        try{
                            this.mappingIndex++;
                            this.sectionDescription = this.mappingResult.sectionDescription.replace('{0}','<b>'+this.answerList[this.mappingIndex]+'</b>');

                            this.mappingData = [];

                            var found = false;
                            var parsedJSON = JSON.parse(this.currentJSON);
                            console.log("Answer List: ",this.answerList);
                            parsedJSON.recommended.forEach(sectionInfo => {
                                console.log("Section name: "+sectionInfo.sectionName);
                                console.log("Compare to: "+this.answerList[this.mappingIndex]);
                                if(sectionInfo.sectionName === this.answerList[this.mappingIndex] || sectionInfo.sectionName === this.answerList[this.mappingIndex].label ){
                                    sectionInfo.mappingData.forEach(objectRow => {
                                        var oRow = {"source":objectRow.source, "destination":objectRow.destination, "fieldMapping":objectRow.fieldMapping, "recordTypeMapping":objectRow.recordTypeMapping, "label":this.fscDefs[objectRow.destination].formattedLabel};
                                        this.mappingData.push(oRow);
                                    });
                                    found = true;
                                }
                            });
                            if(found!==true){
                                this.mappingResult.sectionMappings.forEach(objectRow => {
                                    var oRow = {"source":"", "destination":objectRow.sourceObject, "fieldMapping":objectRow.fieldMapping, "recordTypeMapping":objectRow.recordTypes, "label":this.fscDefs[objectRow.sourceObject].formattedLabel};
                                    this.mappingData.push(oRow);
                                });
                            }

                            this.mappingData.forEach(objectRow => {
                                if(this.defaultRecordTypeMap[this.answerList[this.mappingIndex]+objectRow.destination] && this.defaultRecordTypeMap[this.answerList[this.mappingIndex]+objectRow.destination].additionalInfo){
                                    console.log("Show Additional Info: "+this.defaultRecordTypeMap[this.answerList[this.mappingIndex]+objectRow.destination].additionalInfo);
                                    this.additionalInfo = this.defaultRecordTypeMap[this.answerList[this.mappingIndex]+objectRow.destination].additionalInfo;
                                }
                            });
                            
                            apexSetStatus({assessmentId: this.assessmentId, questionId: this.previousQuestion.QuestionId, index: this.previousQuestion.QuestionNumber, mappingIndex: this.mappingIndex, numberChange: ''})
                            .then(statusResult => {
                                this.isLoading = false;
                            })
                            .catch(error => {
                                console.log("==Error: ",error);
                                this.error = error;
                            }); 
                            console.log("Complete");
                        }catch(e){
                            console.log("==ERROR: ",e);
                        }
                        
                    }else{
                        console.log("Next Question");
                        this.dispatchEvent(new CustomEvent("nextquestion", {}));
                    }
                })
                .catch(error => {
                    console.log(error);
                    this.isLoading = false;
                });
            }     
        }catch(e){
            console.log("==Error: ",e);
        }      
        this.isLoading = false;
    }

    get hasAdditionalInfo(){
        return this.additionalInfo !==null && this.additionalInfo !== undefined && this.additionalInfo !== '';
    }
}