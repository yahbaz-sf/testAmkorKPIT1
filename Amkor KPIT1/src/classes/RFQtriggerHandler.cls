//Trigger consolidation Code
Public class RFQtriggerHandler {
    
    Public void RFQAccountTeamMemberSharing(List < RFQ__c > newItems) {

        Set < Id > sbuIds = new Set < Id > ();

        for (RFQ__c n: newItems) {
            sbuIds.add(n.SBU_Name__c);
        }

        List < AccountTeamMember > mems = [select Id, UserId, AccountId from AccountTeamMember where AccountId in: sbuIds];
        List < RFQ__Share > rfqSharings = new List < RFQ__Share > ();
        for (RFQ__c n: newItems) {
            for (AccountTeamMember m: mems) {
                if (m.AccountId == n.SBU_Name__c) {
                    rfqSharings.add(new RFQ__Share(ParentId = n.Id, UserOrGroupId = m.UserId, AccessLevel = 'Edit', RowCause = Schema.RFQ__Share.RowCause.Account_Sharing__c));
                }
            }
        }
        insert rfqSharings;
    }

    Public void RFQOpptyCreate(List < RFQ__c > newItems, List < RFQ__c > oldItems) {
        //create opportunity
        if(Trigger.isAfter && Trigger.isInsert) {
        Set<Id> rfqsNeedingOpps = new Set<Id>();
        //create opportunity
        for (Integer i = 0; i < newItems.size(); i++) {
            if(newItems[i].Opportunity__c == null) {
                rfqsNeedingOpps.add(newItems[i].Id);
            }
        }
            if(rfqsNeedingOpps.size() > 0) RFQOpportunityDao.createFromRFQ(rfqsNeedingOpps);
        }
        // Lalit (23/06/2016): Code change for populating the Account Region Value in the RFQ to further updation of the sharing Rules.
        if(Trigger.isBefore) {
            List<Account> accList = new List<Account>();
            Set<Id> rfqIdSet = new Set<Id>();
            Map<Id,String> mapRfqIdWithRegion =  new Map<Id,String>();
            for(RFQ__c rfqTemp :newItems ){
                rfqIdSet.add(rfqTemp.SBU_Name__c);
            }
            accList = [Select Id,Name,Sales_Region__c From Account where Id IN :rfqIdSet];
            for(Account accTemp :accList){
                mapRfqIdWithRegion.put(accTemp.Id,accTemp.Sales_Region__c);
            }
            for(RFQ__c temp : newItems){
                temp.Account_Sales_Region__c = mapRfqIdWithRegion.get(temp.SBU_Name__c);
            }
        }
    }

    Public void CopyProjectRev(List < RFQ__c > newItems, List < RFQ__c > oldItems, Map < Id, RFQ__c > newRFQsById) {

        List < RFQ_Item__c > rfqItems = new List < RFQ_Item__c > ();
        Set < Id > rfqIds = new Set < Id > ();
        //Ashish - 8-Mar-2016 : SF-12 Opportunity,RFQ & RFQ Item Relationship
        Set < Id > rfqIdsForOptyUpdate = new Set < Id > ();

        for (Integer i = 0; i < newItems.size(); i++) {
            if (newItems[i].Projected_Revenue__c != oldItems[i].Projected_Revenue__c && newItems[i].Opportunity__c != null) rfqIds.add(newItems[i].id);
            if (newItems[i].Status2__c != oldItems[i].Status2__c && newItems[i].Opportunity__c != null) rfqIds.add(newItems[i].id);

            //Ashish - 8-Mar-2016 : SF-12 Opportunity,RFQ & RFQ Item Relationship
            if (newItems[i].Opportunity__c != oldItems[i].Opportunity__c && newItems[i].Opportunity__c != null) {
                rfqIdsForOptyUpdate.add(newItems[i].id);
            }
        }

        List < Opportunity > oppsToUpdate = new List < Opportunity > ();
        if (rfqIds.size() > 0) {
            List < Opportunity > opps = [select Id, Projected_Revenue__c, Opportunity_Status__c, RFQ__r.Status2__c, RFQ__r.Projected_Revenue__c from Opportunity where RFQ__c in: rfqIds];


            for (Opportunity opp: opps) {
                Boolean shouldAdd = false;
                if (opp.RFQ__r.Projected_Revenue__c != opp.Projected_Revenue__c) {
                    opp.Projected_Revenue__c = opp.RFQ__r.Projected_Revenue__c;
                    shouldAdd = true;
                }
                /*
                if(opp.RFQ__r.Status2__c != opp.Opportunity_Status__c) {
                    opp.Opportunity_Status__c = opp.RFQ__r.Status2__c;
                    shouldAdd = true;
                }
                */
                if (shouldAdd) oppsToUpdate.add(opp);
            }
        }

        //Ashish - 8-Mar-2016 : SF-12 Opportunity,RFQ & RFQ Item Relationship
        //Written logic to update opportunity on RFQItems when RFQ's Opportunity is changed
        if (rfqIdsForOptyUpdate.size() > 0) {
            rfqItems = [Select Id, Name, RFQ__c, Opportunity__c from RFQ_Item__c where RFQ__c in: rfqIdsForOptyUpdate];
            if (rfqItems.size() > 0) {
                for (RFQ_Item__c item: rfqItems) {
                    item.Opportunity__c = newRFQsById.get(item.RFQ__c).Opportunity__c;
                }
            }
        }

        //Ashish - 8-Mar-2016 : SF-12 Opportunity,RFQ & RFQ Item Relationship
        //This code was inside opportunity for loop moved it code here 
        if (oppsToUpdate.size() > 0) {
            update oppsToUpdate;
        }

        //Ashish - 8-Mar-2016 : SF-12 Opportunity,RFQ & RFQ Item Relationship
        if (rfqItems.size() > 0) {
            update rfqItems;
        }
    }


    Public void RFQDeleted(List < RFQ__c > oldItems) {

        delete[select id from RFQ_Item__c where RFQ__c in: oldItems];

    }
}