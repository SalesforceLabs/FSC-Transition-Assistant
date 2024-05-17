import { LightningElement, api } from 'lwc';

export default class AssessmentRecommendation extends LightningElement {
    @api recommendation;

    get severityIconSize() {
        return 'medium';//recommendation.severityIcon.indexOf()
    }

    get shouldShowRecommendation(){
        return this.recommendation && this.recommendation.hasOwnProperty('severityIcon');
    }
}