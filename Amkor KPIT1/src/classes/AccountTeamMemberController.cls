public class AccountTeamMemberController extends BaseController{

    public List<AccountTeamMember> mems {get;set;}
    public Account acct {get;set;}
    public AccountTeamMember newMem {get;set;}
    public boolean showbutton {get;set;}


    public AccountTeamMemberController(ApexPages.StandardController sc) {
        acct = AccountDao.getInstance().getAccountById(sc.getId());
        mems = [select Id, UserId, TeamMemberRole from AccountTeamMember where AccountId =: acct.Id];
        newMem = new AccountTeamMember(AccountId = acct.Id);    

        //Bhanu - 5-Apr-2016 : Managing visibility of Add Account Team Member Button  
        //Add Account Team Member Button is visible to System Administrator and  System Administrator - No Expire Profile

        showbutton =false;          
        List<Profile> profileList = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
        if(profileList.Size()>0){
        String curProfile = profileList[0].Name;        
        if(curProfile=='System Administrator'|| curProfile=='System Administrator - No Expire')
        showbutton =true;
        }
        //--------------

    }

    public PageReference addMember() {
        String dmlObject = 'Account Team Member';
        try{
            
            if(newMem.UserId == null) {
                addError('Please enter a user');
                return null;
            }
            if(newMem.TeamMemberRole == null) {
                addError('Please select a role');
                return null;
            }
            //Lalit - 07-Sep-2016 : Salesforce-129 : Determine default permissions for account team memebers.
            newMem.OpportunityAccessLevel = 'Edit';
            //Ashish - 16-Nov-2016 : Salesforce-129 : New Accounts Section for Customer Scorecard
            //setting the Account & case access in AccountTeamMember only. Will comment out AccountShare insertion code
            newMem.AccountAccessLevel = 'Edit';
            newMem.CaseAccessLevel = 'Edit';
            insert newMem;
            
            //Ashish - 16-Nov-2016 : Salesforce-129 : New Accounts Section for Customer Scorecard
            //Commenting out AccountShare insertion code as Account & case access is set in AccountTeamMember only. 
            /*if(newMem.UserId != acct.OwnerId) {
                dmlObject = 'Account Share';
                insert new AccountShare(AccountId = acct.Id, OpportunityAccessLevel = 'Edit', CaseAccessLevel = 'Edit', AccountAccessLevel = 'Edit', UserOrGroupId = newMem.UserId);
            
            }*/
            List<RFQ__Share> rfqSharings = new List<RFQ__Share>();
            List<RFQ__c> rfqsForAccount = [select Id from RFQ__c where SBU_Name__c =: acct.Id];
            for(RFQ__c rfq : rfqsForAccount) {
                rfqSharings.add(new RFQ__Share(ParentId = rfq.Id, UserOrGroupId = newMem.UserId, AccessLevel = 'Edit', RowCause = Schema.RFQ__Share.RowCause.Account_Sharing__c));
            }
            dmlObject = 'RFQ Share';
            insert rfqSharings;
            newMem = new AccountTeamMember(AccountId = acct.Id);
            mems = [select Id, UserId, TeamMemberRole from AccountTeamMember where AccountId =: acct.Id];
            
        }
        catch(Exception e){
            addError('Error while creating ' + dmlObject + ' : ' + e.getmessage());
        }
        return null;
    }

    public void deleteMember() {
        String delId = getParam('delId');
        String uId = getParam('uId');
        List<String> rfqIds = new List<String>();
        List<RFQ__c> rfqsForAccount = [select Id from RFQ__c where SBU_Name__c =: acct.Id];
        for(RFQ__c rfq : rfqsForAccount) {
            rfqIds.add(rfq.Id);
        }
        try{
            delete [select Id from AccountShare where AccountId =: acct.Id and UserOrGroupId =: uId];
            delete [select Id from AccountTeamMember where Id =: delId];
            delete [select Id from RFQ__Share where UserOrGroupId =: uId AND ParentId in: rfqIds];
        }
        catch(Exception e) {
            addError('Cannot delete account owner');
            system.debug('Error: ' + e);
        }
        
        mems = [select Id, UserId, TeamMemberRole from AccountTeamMember where AccountId =: acct.Id];
    }

}