public class OpportunityStatusChangeController{

    public Opportunity opportunity{get;set;}
    public boolean isAbleToChange{get;set;}
    public boolean allowToGoBack{get;set;}
    public String errorMessage = System.Label.Oppty_Status_Change_Error;
    
    public OpportunityStatusChangeController(ApexPages.StandardController controller){
        opportunity = new Opportunity();
        opportunity = (Opportunity)controller.getRecord();
        checkOpportunityStatus();
    }
    
    public void checkOpportunityStatus(){
       
        if(opportunity.RFQ__c==null){
            isAbleToChange = true;
            allowToGoBack = false;
            System.Debug('Status can be changed');
        }
        else{
            isAbleToChange = false;
            allowToGoBack = true;
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR,errorMessage)); 
        }
    }
}