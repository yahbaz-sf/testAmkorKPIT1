/*************************************************************************
*
* PURPOSE: Prevents saving a new RFQ if the selected Customer Requestor's Account does not match selected SBU.
*
* TRIGGER: RFQCustomerRequestorMatch
* CREATED: 10/3/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Kyle Johnson
***************************************************************************/

trigger RFQCustomerRequestorMatch on RFQ__c (before insert, before update) {

    //Set <Id> contactIds = new Set <Id>();
    //Set <Id> accountIds = new Set <Id>();
    //List <Account> parentAccounts = new List <Account>();
    //Set <Id> parentAccountIds = new Set <Id>();
    //List <Account> childAccounts = new List <Account>();
    //Set <Id> childAccountIds = new Set <Id>();
    //List <Contact> newContacts = new List <Contact>();
    //Set <Id> newContactIds = new Set <Id>();
    
    //for(RFQ__c thisRFQ : Trigger.new){ //add contact and account records from trigger
    //    contactIds.add(thisRFQ.Customer_Requestor__c);
    //    accountIds.add(thisRFQ.SBU_Name__c);
    //}

    ////get the parent accounts (if any) of the selected SBU(s)
    //parentAccounts = [select ParentId from Account where Id in :accountIds];

    //for(Account parent : parentAccounts){ //convert sObject list of parent accts to Id set
    //    if(parent != null){
    //        parentAccountIds.add(parent.ParentId);
    //    }
    //}

    //if(!parentAccountIds.isEmpty()){ //there are parent accounts
    //    //get all child accounts of the parent
    //    childAccounts = [select Id from Account where ParentId in :parentAccountIds];
    //}

    //for (Account child : childAccounts) { //convert sObject list of child accts to Id set
    //    if(child != null){
    //        childAccountIds.add(child.Id);
    //    }
    //}

    ////select all contacts that are new from trigger and whose accounts are new from trigger
    //newContacts = [select Id from Contact where Id in :contactIds AND (AccountId in :accountIds OR AccountId in :parentAccountIds OR AccountId in :childAccountIds)];

    
    ////iterate list and add Ids to Set
    //for(Contact thisContact : newContacts){
    //    if(thisContact != null){
    //      newContactIds.add(thisContact.Id);    
    //    }
    //}
    
    ////add error if a Contact's Id is not contained in newContactIds set
    //for(RFQ__c thisRFQ : Trigger.new){
    //    if(thisRFQ.Customer_Requestor__c != null && !newContactIds.contains(thisRFQ.Customer_Requestor__c)){
    //        thisRFQ.addError('Customer Requestor Account does not match selected SBU.');
    //    }
    //}
}