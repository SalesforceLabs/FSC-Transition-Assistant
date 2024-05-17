import { LightningElement, api, track, } from 'lwc';

//custom apex
import getContent from '@salesforce/apex/TransitionReadinessHelp.getHelpContent';

//custom labels
import helpTitle from '@salesforce/label/c.HelpTitle'

export default class HelpSidebar extends LightningElement {

    @track isLoading = false;
    @track mainItems = [];
    @track sideItems = [];

    label = {
        helpTitle
    };

    connectedCallback() {
        //load results
        this.isLoading = true;
        getContent()
        .then(result => {
            console.log('==Res',result);
            this.mainItems = result.mainItems;
            this.sideItems = result.sideItems;
            
            this.isLoading = false;
        })
        .catch(error => {
            console.log(error);
            this.isLoading = false;
        });
    }
}