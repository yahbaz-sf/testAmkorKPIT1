trigger BeforeRFQIInsertUpdate on RFQ_Item__c (before Insert, before Update){
    
    if(trigger.isBefore && trigger.isInsert) {
        new RFQITriggerHandler().beforeInsert(trigger.new);
    }
    
    if(trigger.isBefore && trigger.isUpdate) {
        new RFQITriggerHandler().beforeUpdate(trigger.new, trigger.oldMap);
    }
}