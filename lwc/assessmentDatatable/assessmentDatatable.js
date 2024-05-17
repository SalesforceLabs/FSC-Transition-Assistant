import LightningDatatable from 'lightning/datatable';
import assessmentDataTableRichTextComponent from './assessmentDataTableRichTextComponent.html';

export default class AssessmentDatatable extends LightningDatatable {
    static customTypes = {
        richText: {
            template: assessmentDataTableRichTextComponent
        }
    };
}