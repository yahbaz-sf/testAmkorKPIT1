trigger RFQDeleted on RFQ__c (before delete) {

    RFQ__c[] oldItems = Trigger.Old;
    RFQ__c[] newItems = Trigger.New;

   delete [select id from RFQ_Item__c where RFQ__c in : oldItems];

}