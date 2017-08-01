trigger CopyProjectRev on RFQ__c (after update) {

    RFQ__c[] oldItems = Trigger.Old;
    RFQ__c[] newItems = Trigger.New;

    List<RFQ_Item__c> rfqItems = new List<RFQ_Item__c>();  
    Set <Id> rfqIds = new Set<Id>();
    //Ashish - 8-Mar-2016 : SF-12 Opportunity,RFQ & RFQ Item Relationship
    Set <Id> rfqIdsForOptyUpdate = new Set<Id>();

    if(Trigger.isAfter && Trigger.isUpdate) {
        for (Integer i = 0; i < newItems.size(); i++) {
            if(newItems[i].Projected_Revenue__c != oldItems[i].Projected_Revenue__c && newItems[i].Opportunity__c != null) rfqIds.add(newItems[i].id);
            if(newItems[i].Status2__c != oldItems[i].Status2__c && newItems[i].Opportunity__c != null) rfqIds.add(newItems[i].id);
            
            //Ashish - 8-Mar-2016 : SF-12 Opportunity,RFQ & RFQ Item Relationship
            if(newItems[i].Opportunity__c != oldItems[i].Opportunity__c && newItems[i].Opportunity__c != null) {
                rfqIdsForOptyUpdate.add(newItems[i].id);
            }
        }
        
        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        if(rfqIds.size() > 0) {
            List<Opportunity> opps = [select Id, Projected_Revenue__c, Opportunity_Status__c, RFQ__r.Status2__c, RFQ__r.Projected_Revenue__c from Opportunity where RFQ__c in: rfqIds];
            

            for(Opportunity opp : opps) {
                Boolean shouldAdd = false;
                if(opp.RFQ__r.Projected_Revenue__c != opp.Projected_Revenue__c) {
                    opp.Projected_Revenue__c = opp.RFQ__r.Projected_Revenue__c;
                    shouldAdd = true;
                }
                /*
                if(opp.RFQ__r.Status2__c != opp.Opportunity_Status__c) {
                    opp.Opportunity_Status__c = opp.RFQ__r.Status2__c;
                    shouldAdd = true;
                }
                */
                if(shouldAdd) oppsToUpdate.add(opp);
            }
        }
        
        //Ashish - 8-Mar-2016 : SF-12 Opportunity,RFQ & RFQ Item Relationship
        //Written logic to update opportunity on RFQItems when RFQ's Opportunity is changed
        if(rfqIdsForOptyUpdate.size() > 0) {
            rfqItems = [Select Id, Name, RFQ__c, Opportunity__c from RFQ_Item__c where RFQ__c in :rfqIdsForOptyUpdate];
            if(rfqItems.size() > 0) {
                for(RFQ_Item__c item : rfqItems) {
                    item.Opportunity__c = trigger.newMap.get(item.RFQ__c).Opportunity__c;
                }
            }
        }
        
        //Ashish - 8-Mar-2016 : SF-12 Opportunity,RFQ & RFQ Item Relationship
        //This code was inside opportunity for loop moved it code here 
        if(oppsToUpdate.size() > 0) {
            update oppsToUpdate;
        }
        
        //Ashish - 8-Mar-2016 : SF-12 Opportunity,RFQ & RFQ Item Relationship
        if(rfqItems.size() > 0) {
            update rfqItems;
        }
    }
}