public class ScoreCardTriggerHandler{
    
    public Account parentCustomerName;
    public Account accNames;
    
    public ScoreCardTriggerHandler(){
         parentCustomerName = new Account();        
         accNames = new Account();
    }
    
    public void populateUniqueKey(List<Scorecard__c> scList){
              
        if(scList != null) {
            for(Scorecard__c sc: scList){ 
                if(String.isNotBlank(sc.Year__c) && String.isNotBlank(sc.Quarter__c)) {
                   sc.Unique_Key__c = sc.SBUAccount__c+ '-' + sc.Year__c + '-' + sc.Quarter__c;   
                }
            }    
        }
    } 

}