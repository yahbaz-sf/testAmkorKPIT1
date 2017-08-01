trigger RFQOpptyCreate on RFQ__c (after insert,before update,before insert) {


    RFQ__c[] oldItems = Trigger.Old;
    RFQ__c[] newItems = Trigger.New;

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
        for(RFQ__c rfqTemp :Trigger.New ){
            rfqIdSet.add(rfqTemp.SBU_Name__c);
        }
        accList = [Select Id,Name,Sales_Region__c From Account where Id IN :rfqIdSet];
        for(Account accTemp :accList){
            mapRfqIdWithRegion.put(accTemp.Id,accTemp.Sales_Region__c);
        }
        for(RFQ__c temp : Trigger.new){
            temp.Account_Sales_Region__c = mapRfqIdWithRegion.get(temp.SBU_Name__c);
        }
    }
}