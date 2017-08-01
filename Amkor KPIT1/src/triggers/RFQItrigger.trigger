//Trigger consolidation New code Kpit
trigger RFQItrigger on RFQ_Item__c(before Insert, before Update, after Insert, after Update) {

    if (trigger.isBefore && trigger.isInsert) {

        new RFQITriggerHandlerNew().populateOpportunityonRFQItem(trigger.new);
        new RFQITriggerHandlerNew().beforeInsert(trigger.new);
    }

    if (trigger.isBefore && trigger.isUpdate) {

        /*need update*/
        new RFQITriggerHandlerNew().populateOpportunityonRFQItem(trigger.new);

        new RFQITriggerHandlerNew().RFQIAddServiceStatusUpdate(trigger.new, trigger.old);
        new RFQITriggerHandlerNew().beforeUpdate(trigger.new, trigger.oldMap);
    }

    if (trigger.isAfter) {

        new RFQITriggerHandlerNew().SAPTransmit(trigger.new);
        //new RFQITriggerHandlerNew().RFQStatusUpdate(trigger.new); this trigger is running only in the after update event.
    }

    if (trigger.isAfter && trigger.isUpdate) {
        
        new RFQITriggerHandlerNew().RFQStatusUpdate(trigger.new);
        new RFQITriggerHandlerNew().RFQStatusHistory(trigger.new, trigger.old);
        new RFQITriggerHandlerNew().SendEmailToSuperUsers(trigger.new, trigger.old);
    }
}