/**
*   This Class contains the logic for creating Scorecard.
*
*/
public class CreateScoreCardController {
    
    public String accountId{get;set;}
    public String accountName{get;set;}
    public String accountNumber{get;set;}
    public Scorecard__c scoreCard{get;set;}
    public Boolean isPageVisible{get;set;}
    public Boolean hasEditAccess;
  
    public CreateScoreCardController(ApexPages.StandardController controller) {
        accountId = Apexpages.currentPage().getParameters().get('accid');
        accountName = Apexpages.currentPage().getParameters().get('name');
        accountNumber = Apexpages.currentPage().getParameters().get('no');
        isPageVisible = false;
        hasEditAccess = hasEditAccessOnScorecard(accountId);
        System.Debug('***'+accountId);
        if(String.isNotBlank(accountId)){
            if(hasEditAccess){
                getData();
            }
            else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.ScorecardUserAccessError));
            }
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.ScorecardNullAccError));
        }
    }
  
    public void getData() {
        List<Account> accountList = [Select Id,ParentId From Account where Id =:accountId];
        if(accountList.size() > 0) {
            if(accountList[0].ParentId != null ){
                scoreCard = new Scorecard__c();
                scoreCard.SBUAccount__c = accountList[0].Id;  //Creating Scorecard at SBU level but not at the parent level.
                isPageVisible = true;
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.ScorecardAttachAtSBUError));
            }
        }
    }
    public Boolean hasEditAccessOnScorecard(String accountId){
        hasEditAccess = false;
        List<UserRecordAccess> userRecAccList = [SELECT HasAllAccess,HasEditAccess,MaxAccessLevel,RecordId FROM UserRecordAccess WHERE UserId = : UserInfo.getUserId() AND RecordId =: accountId];
        
        if(userRecAccList.size()>0){
            hasEditAccess = userRecAccList[0].HasEditAccess;
        }
        return hasEditAccess;   
    }
    
    public PageReference cancel(){
        PageReference pageRef = new PageReference('/' + accountId);
        return pageRef;
    }
    
    public PageReference save() {
        PageReference pageRef;
        String dupScoreScard;
        List<Scorecard__c> scList = [SELECT Name,Year__c,Quarter__c,SBUAccount__c FROM Scorecard__c WHERE Year__c =: scoreCard.Year__c AND Quarter__c =: scoreCard.Quarter__c AND SBUAccount__c =: scoreCard.SBUAccount__c];
        try {
            if(scList!=null && scList.size()>0 && scList[0].Year__c != null && scList[0].Quarter__c != null){
                dupScoreScard = scList[0].Name;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Duplicate value exists on record '+ dupScoreScard + ' Year '+ scoreCard.Year__c + ' and ' + 'Quarter '+scoreCard.Quarter__c));
            }
            else{
                insert scoreCard;
                pageRef = new PageReference('/' + scoreCard.Id);
            }
        } catch(Exception ex) {     
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            System.debug('--->save(), Exception : ' + ex);
        } 
        return pageRef;
    } 
}