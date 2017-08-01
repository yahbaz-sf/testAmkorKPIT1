trigger ScoreCardTrigger on Scorecard__c (before insert, before update) {
     
     if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {      
        ScoreCardTriggerHandler handler = new ScoreCardTriggerHandler();
        handler.populateUniqueKey(trigger.new);
     }   
}