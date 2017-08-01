//Trigger Consolidation New Code
trigger RFQtrigger on RFQ__c ( before Delete,after Insert, after Update){
    
    if(trigger.isBefore && trigger.isDelete){
        
        new RFQTriggerHandler().RFQDeleted(trigger.old);
    }
    
    if(trigger.isAfter && trigger.isInsert){
        
        new RFQTriggerHandler().RFQAccountTeamMemberSharing(trigger.new);
        new RFQTriggerHandler().RFQOpptyCreate(trigger.new, trigger.old);
        
    }
    if(Trigger.isBefore) {
        new RFQTriggerHandler().RFQOpptyCreate(trigger.new, trigger.old);
    }
    
    if(trigger.isAfter && trigger.isUpdate){
        
        new RFQTriggerHandler().CopyProjectRev(trigger.new, trigger.old ,Trigger.newMap);
        
    }
    
    
}