trigger RFQIStatusHistoryUpdated on RFQI_Status_History__c (after insert, before update) {

	Set<Id> rfqItemSet = new Set<Id>();
	
    	for (RFQI_Status_History__c status : Trigger.New)
    	{
    		rfqItemSet.add(status.RFQ_Item__c);
    	}
        
    	    RFQIStatusHistoryDao.getInstance().bulkUpdateTimes(rfqItemSet, Trigger.isInsert);
    
}