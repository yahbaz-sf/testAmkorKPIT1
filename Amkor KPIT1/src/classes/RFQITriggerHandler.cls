public class RFQITriggerHandler{
    
    public void beforeInsert(List<RFQ_Item__c > newRFQIs){
        populateOpportunityonRFQItem(newRFQIs);
    }
    
    public void beforeUpdate(List<RFQ_Item__c > newRFQIs, Map<Id,RFQ_Item__c> oldRFQIsById){
        List<RFQ_Item__c > eligibleRFQIs = new List<RFQ_Item__c >();
        if(newRFQIs != null && oldRFQIsById != null) {
            for(RFQ_Item__c rfqi : newRFQIs){
                if(rfqi.RFQ__c != null && rfqi.RFQ__c != oldRFQIsById.get(rfqi.id).RFQ__c){
                    eligibleRFQIs.add(rfqi);
                }   
            }
            
            if(eligibleRFQIs.size() > 0) {
                populateOpportunityonRFQItem(eligibleRFQIs);
            }
        }
    }
    
    public void populateOpportunityonRFQItem(List<RFQ_Item__c > rfqiRecords){
        Set<Id> rfqIds = new Set<Id>();
        Map<Id,RFQ__c> rfqMap;
        
        if(rfqiRecords != null) {
        
            for(RFQ_Item__c rfqi : rfqiRecords){
                rfqIds.add(rfqi.RFQ__c);
            }
            if(rfqIds.size() > 0) {
                rfqMap = new Map<Id,RFQ__c>([SELECT Opportunity__c FROM RFQ__c where id =: rfqIds]);
                for(RFQ_Item__c rfqi : rfqiRecords){
                    
                    if(rfqi.RFQ__c != null) {
                        RFQ__c rfq = rfqMap.get(rfqi.RFQ__c);
                        if(rfq != null && rfq.Opportunity__c != null) {
                            rfqi.Opportunity__c = rfq.Opportunity__c;
                        }
                    }
                }
            }
        }
    }
    
}