trigger RFQOpportunity on Opportunity (before update, after update, after insert, before insert) {

    Opportunity[] oldItems = Trigger.Old;
    Opportunity[] newItems = Trigger.New;
    //No longer needed because we set recordType on create and no longer have upside stage names
    //RecordType rt = [select Id, Name from RecordType where Name = 'Existing Opp' AND sObjectType = 'Opportunity' limit 1];
    //RecordType rt1 = [select Id, Name from RecordType where Name = 'Upside Request' AND sObjectType = 'Opportunity' limit 1];

/*

PER JSTEP stage doesn't matter can do what ever you want regardless of stage.
No longer needed.
    if(Trigger.isBefore && Trigger.isUpdate) {
        List<Id> oppIds = new List<Id>();
        for (Integer i = 0; i < oldItems.size(); i++) {
            //if new stage > rfq - check that the linked RFQ all items are in closed state
            if(newItems[i].StageName != null && oldItems[i].StageName != null) {
                if(newItems[i].StageName.contains('Closed') && !oldItems[i].StageName.contains('Closed') && newItems[i].RFQ__c != null) {
                    oppIds.add(newItems[i].Id);
                }
            }
        }
        if(oppIds.size() > 0) {
            List<Id> errorIds = RFQDao.canOpportunityClose(oppIds);
            for(Id opId : errorIds) {
                Trigger.newMap.get(opId).addError('Cannot advance Opportunity, RFQ exists and RFQ item statuses are not closed');
            }
        }
    }
*/
    //Ashish - 8-Mar-2016 : SF-12 Opportunity,RFQ & RFQ Item Relationship
    //Written this BEFORE INSERT block to populate unqique field 
    if(Trigger.isBefore && Trigger.isInsert) {
        for (Opportunity opty : newItems) {
            //populate unqique field
            opty.Unique_RFQ__c = opty.RFQ__c;
        }   
    }
    
    //Ashish - 8-Mar-2016 : SF-12 Opportunity,RFQ & RFQ Item Relationship
    //Written this BEFORE UPDATE block to preventing RFQ__c lookup updation from 1 value to other, 
    //However, null to value & value to null are allowed
    if(Trigger.isBefore && Trigger.isUpdate) {
        for (Opportunity opty : newItems) {
            
            Opportunity oldOpty = Trigger.oldMap.get(opty.Id);
            //check if RFQ__c has changed
            if(oldOpty != null && oldOpty.RFQ__c != opty.RFQ__c) {
                //populate unqique field
                opty.Unique_RFQ__c = opty.RFQ__c;
                    
                //check if its a value to value change (not value to null or null to value)
                if(oldOpty.RFQ__c != null && opty.RFQ__c != null) {
                    opty.addError('RFQ once selected on an opportunity cannot be changed.');
                }
            }
        }   
    }
    
    if(Trigger.isAfter && Trigger.isUpdate) {
        List<Id> oppIds = new List<Id>();
        for (Integer i = 0; i < oldItems.size(); i++) {
            //if new stage = rfq - create the RFQ and relink all the children
            //Bhanu - 21-June-2016 : Salesforce 69 - Opportunity Status Change
            //Updating Existing values with new value
            //if(newItems[i].StageName == 'RFQ' && oldItems[i].StageName != 'RFQ' && oldItems[i].RFQ__c == null) {
            if(newItems[i].StageName == 'RFQ/Quote' && oldItems[i].StageName != 'RFQ/Quote' && oldItems[i].RFQ__c == null) {
                oppIds.add(newItems[i].Id);
            }
        }
        if(oppIds.size() > 0) RFQDao.createFromOpportunity(oppIds);

        Set <Id> oppIdsForProjectRev = new Set<Id>();

        for (Integer i = 0; i < newItems.size(); i++) {
            if(newItems[i].Projected_Revenue__c != oldItems[i].Projected_Revenue__c && newItems[i].RFQ__c != null) oppIdsForProjectRev.add(newItems[i].id);
            if(newItems[i].Opportunity_Status__c != oldItems[i].Opportunity_Status__c && newItems[i].RFQ__c != null) oppIdsForProjectRev.add(newItems[i].id);
        }
        if(oppIdsForProjectRev.size() > 0) {
            List<RFQ__c> rfqs = [select Id, Opportunity__r.Projected_Revenue__c, Opportunity__r.Opportunity_Status__c, Status2__c, Projected_Revenue__c from RFQ__c where Opportunity__c in :oppIdsForProjectRev AND SBU_Name__r.ParentId != null AND sbu_name__r.inactive__c=false];
    
            List<RFQ__c> rfqToUpdate = new List<RFQ__c>();

            for(RFQ__c rfq : rfqs) {
                Boolean shouldAdd = false;
                if(rfq.Projected_Revenue__c != rfq.Opportunity__r.Projected_Revenue__c) {
                    rfq.Projected_Revenue__c = rfq.Opportunity__r.Projected_Revenue__c;
                    shouldAdd = true;
                }
                /*
                if((rfq.Status2__c != rfq.Opportunity__r.Opportunity_Status__c)) {
                    rfq.Status2__c = rfq.Opportunity__r.Opportunity_Status__c;
                    shouldAdd = true;
                }
                if(shouldAdd) rfqToUpdate.add(rfq);
                */
            }
            update rfqToUpdate;
        }   
        
        //Abhay - 1-Jan-2017 : Salesforce 128 - Align SBU number across all related objects when changed    
        // Whenever Account changes in the Opportunity ,folowing code changes the Account on corresponding RFQ .
        /******************* Start of SF-128 ******************************/
        /*list<String> lstAccountIds = new list<String>();
        for(Opportunity objOpp : Trigger.new){
            if(objOpp.accountId != Trigger.oldmap.get(objOpp.Id).accountId  ){
                lstAccountIds.add(objOpp.accountId);
                lstAccountIds.add(Trigger.oldmap.get(objOpp.Id).accountId );
            }
        }
        list<RFQ__c > lstRFQToUpdate = new list<RFQ__c >();
        Map<Id,Account> MapAcc = new Map<Id,Account>([Select id,ParentId from Account where ID IN :lstAccountIds]);
        for(Opportunity objOpp : Trigger.new){
            if(objOpp.accountId != Trigger.oldmap.get(objOpp.Id).accountId  ){
                String PreviousParentId = MapAcc.containsKey(Trigger.oldmap.get(objOpp.Id).accountId)?MapAcc.get(Trigger.oldmap.get(objOpp.Id).accountId).ParentId :Null;
                String NewParentId = MapAcc.containsKey(objOpp.accountId)?MapAcc.get(objOpp.accountId).ParentId:Null;
                
                if(PreviousParentId == NewParentId ){
                    RFQ__c objRFQ = new RFQ__c();
                    objRFQ.SBU_Name__c = objOpp.AccountId;
                    objRFQ.Id = objOpp.RFQ__c;
                    lstRFQToUpdate.add(objRFQ);
                }
            }
        } 
        update lstRFQToUpdate;
        /************************************* End of SF-128 *****************************/
    }

    if(Trigger.isAfter && Trigger.isInsert) {
        List<Id> oppIds = new List<Id>();
        for (Integer i = 0; i < newItems.size(); i++) {
            //if new stage = rfq - create the RFQ and relink all the children
            //Bhanu - 21-June-2016 : Salesforce 69 - Opportunity Status Change
            //Updating Existing values with new value
            //if(newItems[i].StageName == 'RFQ' && newItems[i].RFQ__c == null) {
            if(newItems[i].StageName == 'RFQ/Quote' && newItems[i].RFQ__c == null) {
                oppIds.add(newItems[i].Id);
            }
        }
        if(oppIds.size() > 0) RFQDao.createFromOpportunity(oppIds);
    }

}