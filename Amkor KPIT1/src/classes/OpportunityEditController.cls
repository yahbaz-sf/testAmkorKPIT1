public class OpportunityEditController{

     public Opportunity opportunity{get;set;}
     public boolean isAbleToChange{get;set;}
     public boolean notAbleToChange{get;set;}

     public String errorMessage = System.Label.OpptyStageEditInfo;
     public OpportunityEditController(ApexPages.StandardController controller){
        opportunity = new Opportunity();
        opportunity = (Opportunity)controller.getRecord();
        checkForRFQorRFQItemForOpportunity();  
     }
     
     public void checkForRFQorRFQItemForOpportunity(){
         List<RFQ_Item__c> rfqItems = new List<RFQ_Item__c>();
         rfqItems = RFQOpportunityDao.getRFQItems(opportunity);
         if((opportunity.RFQ__c == null) && (opportunity.StageName != 'RFQ/Quote') && (rfqItems.size() == 0)){
             isAbleToChange = true;
             notAbleToChange = false;
         }
         else{
             isAbleToChange = false;
             notAbleToChange = true;
             //The below message should be shown only if the Value of Opty stage changes ONLY FROM "RFQ/Quote" to
             //"Closed Program Win", "Closed Program Loss", "Closed Program Cancel".
             
             ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.INFO,errorMessage));
         }
     }
}