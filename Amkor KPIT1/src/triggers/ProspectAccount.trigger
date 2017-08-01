trigger ProspectAccount on Account (before insert,after update) {
  
  Account[] oldItems = Trigger.Old;
  Account[] newItems = Trigger.New;
  if(Trigger.isBefore && Trigger.isInsert){  
  Id rtId = RecordTypeUtils.getRecordTypeId('Account', 'Prospect');
  String prospectParentId = RFQSystemSettings.getProspectAccountId();
    //Account[] newItems = Trigger.New;
    for(Account a : newItems) {
        if(StringUtils.isBlank(a.AccountNumber)) {
            a.AccountNumber = 'PROSPECT';
            a.RecordTypeId = rtId;
            //a.ParentId = prospectParentId; 
            //a.ParentId = '0011700000iejlS';  // Created for test purpose.
        }
    }
   }
   //Lalit (24/06/2016):functionality for populating the correct sales region from an account to the RFQ if we are changing the Account region.
    if(Trigger.isAfter && Trigger.isUpdate) {
        set<Id> accIdSet = new Set<Id>();
        List<RFQ__c> lstRFQ = new List<RFQ__c>();
        List<RFQ__c> lstToUpdate = new List<RFQ__c>();
        Map<Id,String> mapaccvalues = new Map<Id,String>();
    
        for (Account newAcc: newItems) {
            //Ashish N - 15-Jun-2017 : Salesforce-227 : Error while Updating SalesForce Account with SAP Data. 
            //Added condition to filter out inactive accounts.
            if (!newAcc.Inactive__c && newAcc.Sales_Region__c != Trigger.oldmap.get(newAcc.id).Sales_Region__c) {
                accIdSet.add(newAcc.Id);
                mapaccvalues.put(newAcc.Id, newAcc.Sales_Region__c);
            }
        }
        lstRFQ = [Select Id, Name, SBU_Name__c, Account_Sales_Region__c From RFQ__C where SBU_Name__c IN :accIdSet ];
        for(RFQ__c rfqTemp : lstRFQ){
            rfqTemp.Account_Sales_Region__c = mapaccvalues.get(rfqTemp.SBU_Name__c );
            lstToUpdate.add(rfqTemp);
        }
        update lstToUpdate;
    }
}