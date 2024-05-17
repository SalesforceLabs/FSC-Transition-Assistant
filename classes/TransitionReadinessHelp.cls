/***********************************************************************************
 * 
 * Class that controls content and actions shown in the "helpSidebar" component
 * 
 **********************************************************************************/
public with sharing class TransitionReadinessHelp {

    //Help Component Location Titles
    private static final String HELP_LOCATION_MAIN = 'Help Sidebar - Main Link';
    private static final String HELP_LOCATION_SIDE = 'Help Sidebar - Side Link';
    
    /*******************************************************************************
    * Main function for retrieving help content; retrieves from Heroku DB, and 
    * then deserializes + returns the HelpContent data.
    * 
    * Split into "mainLinks" (boxed items within component), and 
    * "supplementaryLinks" (in the "Related Articles" section)
    * 
    ******************************************************************************/
    @AuraEnabled
    public static HelpContent getHelpContent() {
        HelpContent sidebarContent = new HelpContent();
        List<String> sidebarLocations = new List<String>{HELP_LOCATION_MAIN, HELP_LOCATION_SIDE};
        //Query Custom Metadata Type
        List<SFDC_Help__mdt> helpMetadata = [SELECT Title_Label__c, Description_Label__c, Icon_Name__c, Link_URL__c, Location__c 
        FROM SFDC_Help__mdt WHERE Location__c IN :sidebarLocations Order By Title_Label__c ASC];

        HelpItem tempItem;
        for (SFDC_Help__mdt helpItem : helpMetadata) {
            //Retrieve label/translation info and create Help Item
            tempItem = new HelpItem(ToolingService.customLabelMap.get(Utilities.namespaceUnderscore+helpItem.Title_Label__c), 
            ToolingService.customLabelMap.get(Utilities.namespaceUnderscore+helpItem.Description_Label__c), 
            helpItem.Icon_Name__c, 
            helpItem.Link_URL__c);
            
            //Place Help Item in appropriate List
            if(helpItem.Location__c == HELP_LOCATION_MAIN){
                sidebarContent.mainItems.add(tempItem);
            }else{
                sidebarContent.sideItems.add(tempItem);
            }
        }
        return sidebarContent;
    }


    /*******************************************************************************
    * Related wrapped objects. The "iconName" attribute under HelpItem is optional 
    * for all items in the "sideItems" list.
    ******************************************************************************/
    public class HelpContent {
        @AuraEnabled
        public List<HelpItem> mainItems {get;set;}

        @AuraEnabled
        public List<HelpItem> sideItems {get;set;}

        public HelpContent(){
            this.mainItems = new List<HelpItem>();
            this.sideItems = new List<HelpItem>();
        }
    }

    public class HelpItem {
        @AuraEnabled
        public String title {get;set;}
        @AuraEnabled
        public String description {get;set;}
        @AuraEnabled
        public String iconName {get;set;}
        @AuraEnabled
        public String link {get;set;}

        public HelpItem(String title, String description, String iconName, String link){
            this.title = title;
            this.description = description;
            this.iconName = iconName;
            this.link = link;
        }
    }
}