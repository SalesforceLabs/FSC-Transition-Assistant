import { LightningElement, api, track, wire} from 'lwc';
import {getObjectInfo, getPicklistValuesByRecordType} from 'lightning/uiObjectInfoApi';
import getNamespacedObject from '@salesforce/apex/Utilities.getNamespacedObject';
import getOrgType from '@salesforce/apex/AssessmentService.isInSandbox';
import getVerticals from '@salesforce/apex/AssessmentService.getOrgVerticals';
import getStartingQuestion from '@salesforce/apex/AssessmentService.getStartingQuestion';
import getAssessment from '@salesforce/apex/AssessmentService.getCurrentAssessmentQuestion';
import saveQuestionApex from '@salesforce/apex/AssessmentService.saveQuestion';
import apexSetStatus from '@salesforce/apex/AssessmentService.setStatus';
import getMapping from '@salesforce/apex/AssessmentService.getMappingSection';
import deleteSection from '@salesforce/apex/MappingService.deleteMappingSection';
import previousQuestion from '@salesforce/apex/AssessmentService.getPreviousQuestion';
import UINextButtonText from '@salesforce/label/c.UINextButtonText';
import UIBackButtonText from '@salesforce/label/c.UIBackButtonText';
import UICancelButtonText from '@salesforce/label/c.UICancelButtonText';
import UIPicklistPlaceholderText from '@salesforce/label/c.UIPicklistPlaceholderText';
import UICompleteAssessmentText from '@salesforce/label/c.UICompleteAssessmentText';
import UIStartAssessmentText from '@salesforce/label/c.UIStartAssessmentText';
import UISandboxDisclaimer from '@salesforce/label/c.AssessmentSandboxDisclaimer';
import UIOptionalDisclaimer from '@salesforce/label/c.AssessmentOptionalDisclaimer';
import UIQuestionDesc from '@salesforce/label/c.QuestionScreenDesc';

export default class QuestionScreen extends LightningElement {
    @api assessmentid;
    @api industryname;
    @api fscDefs;

    @track isSandbox = false;
    @track verticalId;
    @track verticalList;
    @track question;
    @track showStart = false;
    @track showVerticals;
    @track showQuestion;
    @track showNext;
    @track showBack;
    verticalCount = 0;
    picklistFields;
    currentQuestionRequired;

    label = {
        UIBackButtonText,
        UINextButtonText,
        UICancelButtonText,
        UIPicklistPlaceholderText,
        UICompleteAssessmentText,
        UIStartAssessmentText,
        UISandboxDisclaimer,
        UIOptionalDisclaimer,
        UIQuestionDesc
    };

    questionNumberChange = '';

    //Mapping variables
    @track lastQuestion;
    @track nextQuestion;
    @track lastMappableQuestion;
    @track startAtEndOfMap = false;
    @track overrideMappingIndex;
    @track currentMappingId;

    @wire(getNamespacedObject, {
            objectName: 'Assessment__c'
        })
        assessmentNamespaced;

    @wire(getObjectInfo, {
            objectApiName: '$assessmentNamespaced.data'
        })
        assessmentMetadata;

    @wire(getPicklistValuesByRecordType, {
            objectApiName: '$assessmentNamespaced.data',
            recordTypeId: '$assessmentMetadata.data.defaultRecordTypeId'
        })
        picklistValues({error, data}) {
            if (data) {
                this.picklistFields = data;

                if(this.assessmentid) {
                    this.loadAssessment();
                }
                else {
                    getVerticals({industryName: this.industryname})
                    .then(result => {
                        this.verticalList = JSON.parse(JSON.stringify(result));
                        this.showVerticals = true;
                        this.dispatchEvent(new CustomEvent("stoploading", {}));
                    })
                    .catch(error => {
                        this.error = error;
                    });
                }
            }
        }

    @wire(getOrgType, {})
        orgType({error, data}) {
            this.isSandbox = data;
        }

    loadAssessment() {
        getAssessment({assessmentId: this.assessmentid})
        .then(result => {
            this.question = result;
            //this.loadQuestionSection();
            if(result.CurrentMappingIndex){
                console.log("Go directly to mapping!");
                const questionData = this.prepQuestionForSave();
				const preparedQuestion = JSON.stringify(questionData);
                saveQuestionApex({currentQuestionJson: preparedQuestion})
                .then(questionResult => {
                    console.log("==Save Question Result: ",result);
                    getMapping({currentQuestionJson: preparedQuestion})
                    .then(mappingResult => {
                        if(mappingResult) {
                            console.log("Mapping result: ",mappingResult);
                            //Mapping(s), get mapping before going to next question
                            this.addPicklistValues();
                            this.startAtEndOfMap = false;
                            this.showQuestion = false;
                            this.overrideMappingIndex = result.CurrentMappingIndex;
                            this.currentMappingId = mappingResult;
                            if(questionResult){
                                this.nextQuestion = questionResult;
                            }else{
                                this.nextQuestion = null
                            }
                            
                            //this.lastQuestion = this.question;
                            //this.question = result;
                            
                        }
                        else {
                            //No mappings; load next question
                            this.question = result;
                            //TODO: Remember this function when returning to normal questions
                            this.loadQuestionSection();
                        }
                        this.dispatchEvent(new CustomEvent("stoploading", {}));
                    })
                    .catch(error => {
                        console.log("==Error: ",error);
                        this.error = error;
                    });  
                })
                .catch(error => {
                    console.log("==Error: ",error);
                    this.error = error;
                });

            
            }else{
                this.loadQuestionSection();
            }
        })
        .catch(error => {
            this.error = error;
        });
    }

    startAssessment() {
        this.showVerticals = false;
        getStartingQuestion({verticalList: this.verticalList})
        .then(result => {
            if(result) {
                this.question = result;
                this.loadQuestionSection();
            }
            else {
                this.dispatchEvent(new CustomEvent("assessmentcomplete", {detail: this.assessmentid}));
            }
        })
        .catch(error => {
            this.error = error;
        });
    }

    loadQuestionSection() {
        if(!this.question){
            apexSetStatus({assessmentId: this.assessmentid, questionId: 'MAP', index: '', mappingIndex: '', numberChange: ''})
            .then(statusResult => {
                this.questionNumberChange = '';
                this.dispatchEvent(new CustomEvent("assessmentcomplete", {detail: this.assessmentid}));
            })
            .catch(error => {
                console.log("==Error: ",error);
                this.error = error;
            }); 
        }else{
            if(this.assessmentid){
                console.log("Set status for question: ",this.question);
                apexSetStatus({assessmentId: this.assessmentid, questionId: this.question.QuestionId, index: this.question.QuestionNumber, mappingIndex: '', numberChange: this.questionNumberChange})
                .then(statusResult => {
                    this.questionNumberChange = '';
                    this.showNext = !this.question.IsRequired;
                    this.showBack = this.question.QuestionNumber > 1;
                    this.currentQuestionRequired = this.question.IsRequired;
                    this.addPicklistValues();
                    this.showQuestion = true;
                    this.dispatchEvent(new CustomEvent("stoploading", {}));
                })
                .catch(error => {
                    console.log("==Error: ",error);
                    this.error = error;
                });   
            }else{
                this.questionNumberChange = '';
                this.showNext = !this.question.IsRequired;
                this.showBack = this.question.QuestionNumber > 1;
                this.currentQuestionRequired = this.question.IsRequired;
                this.addPicklistValues();
                this.showQuestion = true;
            }
            
        }

    }

    submitQuestion() {
        //this.lastQuestion = this.question;
        //console.log("==Set Last Question: ",JSON.parse(JSON.stringify(this.lastQuestion)));
                const questionData = this.prepQuestionForSave();
				const preparedQuestion = JSON.stringify(questionData);

				console.log('==Prepared Question: ', preparedQuestion);

        saveQuestionApex({currentQuestionJson: preparedQuestion})
        .then(result => {
            console.log("==Save Question Result: ",result);
            if(result) {
                if(!this.assessmentid){
                    console.log('==Set Id: ',result.AssessmentId);
                    this.assessmentid = result.AssessmentId;
                }
                //Mapping check
                if(questionData.SelectedAnswer || (questionData.SelectedAnswers && questionData.SelectedAnswers.length > 0)){
                    getMapping({currentQuestionJson: preparedQuestion})
                    .then(mappingResult => {
                        if(mappingResult) {
                            console.log("Mapping result: ",mappingResult);
                            //Mapping(s), get mapping before going to next question
                            this.startAtEndOfMap = false;
                            this.overrideMappingIndex = null;
                            this.showQuestion = false;
                            this.currentMappingId = mappingResult;
                            this.nextQuestion = result;
                            //this.question = result;
                        }
                        else {
                            //No mappings; load next question
                            var allAnswersList = this.combineAnswerList();

                            console.log("==Question: ",this.question);
                            deleteSection({assessmentId: this.assessmentid,answerValues: allAnswersList})
                            .then((deleteResult) => {
                                //load next question
                                this.question = result;
                                this.nextQuestion = null;
                                //TODO: Remember this function when returning to normal questions
                                this.questionNumberChange = 'next';
                                this.loadQuestionSection();
                            })
                            .catch(error => {
                                console.log("==Error: ",error);
                                this.error = error;
                            });
                        }
                    })
                    .catch(error => {
                        console.log("==Error: ",error);
                        this.error = error;
                    });
                }else {
                    //No mappings

                    //Delete any existing mappings for this section
                    var allAnswersList = this.combineAnswerList();

                    console.log("==Question: ",this.question);
                    deleteSection({assessmentId: this.assessmentid,answerValues: allAnswersList})
                    .then((deleteResult) => {
                        //load next question
                        this.question = result;
                        this.nextQuestion = null;
                        //TODO: Remember this function when returning to normal questions
                        this.questionNumberChange = 'next';
                        this.loadQuestionSection();
                    })
                    .catch(error => {
                        console.log("==Error: ",error);
                        this.error = error;
                    });     
                }               
            }
            else {
                //Mapping check (scenario where no next question exists)
                console.log("Last question");
                if(questionData.SelectedAnswer || (questionData.SelectedAnswers && questionData.SelectedAnswers.length > 0)){
                    getMapping({currentQuestionJson: preparedQuestion})
                    .then(mappingResult => {
                        if(mappingResult) {
                            console.log("Mapping result: ",mappingResult);
                            //Mapping(s), get mapping before going to next question
                            this.startAtEndOfMap = false;
                            this.showQuestion = false;
                            this.currentMappingId = mappingResult;
                            console.log("Has mapping");
                            this.nextQuestion = null;
                            //this.question = null;
                        }
                        else {
                            //No mappings; next screen
                            //this.question = result;
                            //TODO: Remember this function when returning to normal questions
                            var allAnswersList = this.combineAnswerList();

                            console.log("==Question: ",this.question);
                            deleteSection({assessmentId: this.assessmentid,answerValues: allAnswersList})
                            .then((deleteResult) => {
                                //Set status and progress to mapping
                                apexSetStatus({assessmentId: this.assessmentid, questionId: 'MAP', index: this.question.QuestionNumber, mappingIndex: '', numberChange: ''})
                                .then(statusResult => {
                                    this.questionNumberChange = '';
                                    this.dispatchEvent(new CustomEvent("assessmentcomplete", {detail: this.assessmentid}));
                                })
                                .catch(error => {
                                    console.log("==Error: ",error);
                                    this.error = error;
                                });
                            })
                            .catch(error => {
                                console.log("==Error: ",error);
                                this.error = error;
                            });
                        }
                    })
                    .catch(error => {
                        console.log("==Error: ",error);
                        this.error = error;
                    });
                }else{
                    //No mappings; next screen

                    //Delete any existing mappings for this section
                    var allAnswersList = this.combineAnswerList();

                    console.log("==Question: ",this.question);
                    deleteSection({assessmentId: this.assessmentid,answerValues: allAnswersList})
                    .then((deleteResult) => {
                        //Set status and progress to mapping
                        apexSetStatus({assessmentId: this.assessmentid, questionId: 'MAP', index: this.question.QuestionNumber, mappingIndex: '', numberChange: ''})
                        .then(statusResult => {
                            this.questionNumberChange = '';
                            this.dispatchEvent(new CustomEvent("assessmentcomplete", {detail: this.assessmentid}));
                        })
                        .catch(error => {
                            console.log("==Error: ",error);
                            this.error = error;
                        });
                    })
                    .catch(error => {
                        console.log("==Error: ",error);
                        this.error = error;
                    });  
                }
                
            }
        })
        .catch(error => {
            console.log("==Error: ",error);
            this.error = error;
        });
    }

    prevQuestion() {
        console.log("Event received");
        try{
            if(this.question.QuestionNumber===1){
                console.log("Load current question");
                //this.question = this.lastQuestion;
                this.currentMappingId = null;
                this.loadQuestionSection();
            }else{
                console.log("Load last question.")
                const preparedQuestion = JSON.stringify(this.prepQuestionForSave());

                console.log('==Prepared Question: ', preparedQuestion);
                previousQuestion({currentQuestionJson: preparedQuestion})
                .then(result => {
                    if(result) {
                        console.log("Go to question: ",result);
                        //if(this.lastMappableQuestion && result.QuestionId === this.lastMappableQuestion.QuestionId){
                        if(this.showQuestion === true && (result.SelectedAnswer || (result.SelectedAnswers && result.SelectedAnswers.length > 0))){
                            console.log("DO MAPPING");
                            getMapping({currentQuestionJson: JSON.stringify(this.prepQuestionForSave(result))})
                            .then(mappingResult => {
                                if(mappingResult) {
                                    console.log("Mapping result: ",mappingResult);
                                    //Mapping(s), get mapping before going to next question
                                    this.overrideMappingIndex = null;
                                    this.startAtEndOfMap = true;
                                    this.showQuestion = false;
                                    this.currentMappingId = mappingResult;
                                    if(result.IsPicklist === true || result.IsMultiSelect === true) {
                                        result.AnswerValues = this.findPicklistValuesByFieldName(result.AnswerFieldAPIName);
                                    }
                                    this.nextQuestion = this.question;
                                    this.question = result;
                                    //this.lastQuestion = this.lastMappableQuestion;
                                    //this.question = result;
                                    //this.lastMappableQuestion = null;
                                    console.log("Start at end: "+this.startAtEndOfMap);
                                }
                            })
                            .catch(error => {
                                console.log("==Error: ",error);
                                this.error = error;
                            });
                        }else{
                            this.question = result;
                            this.showQuestion = true;
                            this.currentMappingId = null;
                            this.questionNumberChange = 'back';
                            this.loadQuestionSection();
                        }

                        
                    }
                })
                .catch(error => {
                    //console.log("==ERROR: ",error);
                    this.error = error;
                });
            }
            
        }catch(e){
            console.log("==ERROR: ",e);
        }
		
    }

    cancelAssessment() {
        this.dispatchEvent(new CustomEvent("closequestionscreen", {}));
    }

    addPicklistValues() {
        if(this.question.IsPicklist === true || this.question.IsMultiSelect === true) {
            this.question.AnswerValues = this.findPicklistValuesByFieldName(this.question.AnswerFieldAPIName);
            if(this.question.ExcludeOptions && this.question.ExcludeOptions.length) {
                let answersAfterExclusion = [];
                let excludeSet = new Set(this.question.ExcludeOptions);
                for(let index = 0; index < this.question.AnswerValues.length; index++) {
                    if(excludeSet.has(this.question.AnswerValues[index].label) == false) {
                        answersAfterExclusion.push(this.question.AnswerValues[index]);
                    }
                }
                this.question.AnswerValues = answersAfterExclusion;

                if(this.question.SelectedAnswer && excludeSet.has(this.question.SelectedAnswer)) {
                    this.question.SelectedAnswer = '';     
                }

                if(this.question.SelectedAnswers && this.question.SelectedAnswers.length) {
                    let selectedAnswersAfterExclusion = [];
                    for(let index = 0; index < this.question.SelectedAnswers.length; index++) {
                        if(excludeSet.has(this.question.SelectedAnswers[index]) == false) {
                            selectedAnswersAfterExclusion.push(this.question.SelectedAnswers[index]);
                        }
                    }
                    this.question.SelectedAnswers = selectedAnswersAfterExclusion;
                }
            }
        }
    }

    prepQuestionForSave(qOverride) {
        var question = (qOverride) ? qOverride : this.question;
        let clonedQuestion = JSON.parse(JSON.stringify(question));
        delete clonedQuestion.AnswerValues;
        if(clonedQuestion.IsMultiSelect === true) {
            clonedQuestion.SelectedAnswer = clonedQuestion.SelectedAnswers.join(';');
        }
        delete clonedQuestion.SelectedAnswers;
        return clonedQuestion;
    }

    findPicklistValuesByFieldName(fieldName){
        return this.picklistFields.picklistFieldValues[fieldName].values;
    }

    handleCombobox(event) {
        this.question.SelectedAnswer = event.detail.value;
        if(this.currentQuestionRequired && this.question.SelectedAnswer) {
            this.showNext = true;
        }
        else if(this.currentQuestionRequired) {
            this.showNext = false;
        }
    }

    handleCheckboxGroup(event) {
        this.question.SelectedAnswers = event.detail.value;
        if(this.currentQuestionRequired && this.question.SelectedAnswers.length > 0) {
            this.showNext = true;
        }
        else if(this.currentQuestionRequired) {
            this.showNext = false;
        }
    }

    handleToggle(event) {
        this.question.SelectedCheckbox = this.template.querySelector("[data-index='0']").checked;
        if(this.currentQuestionRequired && this.question.SelectedCheckbox) {
            this.showNext = true;
        }
        else if(this.currentQuestionRequired) {
            this.showNext = false;
        }
    }

    handleVerticalSelection(event) {
        this.verticalList[event.currentTarget.dataset.index].VerticalSelected = this.template.querySelector("[data-index='" + event.currentTarget.dataset.index + "']").checked;
        if(this.verticalList[event.currentTarget.dataset.index].VerticalSelected) {
            this.verticalCount++;
        }
        else {
            this.verticalCount--;
        }

        this.showStart = this.verticalCount > 0;
    }

    nextQuestionFromMapping(e){
        console.log("Next Q Event Received");
        //this.lastMappableQuestion = this.lastQuestion;
        console.log("Next question: ",this.nextQuestion);
        this.currentMappingId = null;
        this.question = this.nextQuestion;
        this.nextQuestion = null;
        this.questionNumberChange = 'next';
        this.loadQuestionSection();
    }

    previousQuestionFromMapping(e){
        this.currentMappingId = null;
        this.questionNumberChange = 'back';
        this.loadQuestionSection();
    }

    combineAnswerList(){
        var allAnswersList = [];
        this.question.AnswerValues.forEach(answerOption => {
            allAnswersList.push(answerOption.value);
        });
        this.question.ExcludeOptions.forEach(excludeOption => {
            allAnswersList.push(excludeOption);
        });
        return allAnswersList;
    }

    get showMapping(){
        return this.currentMappingId;
    }
}