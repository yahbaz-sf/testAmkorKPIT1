public without sharing class CreateNotesAndAttachmentController {
    public String scorecardId;
    public String parentId;
    public String scoreCardName;
    public string isNoteORAttchmt{get;set;}
    private boolean showError = false;
    private boolean provideAccessOnParent = false;
    public List<Scorecard__c> notesNAttachmentList {get;set;}
    public List<attachmentWrapper> attachmentWrapperList {get;set;}
    private static final string Note = 'Note';
    private static final string Attachment = 'Attachment';
    private set<Id> accessibleAccIds;

    
    Public Scorecard__c sc;
    public String attachmentURL;
    public String notesURL;
    public Boolean hasAccessForUser;
    
    public CreateNotesAndAttachmentController(Apexpages.standardController stdctlr) {
         system.debug('..custom controller...');
         scorecardId = stdctlr.getId();
         system.debug('scorecardId=== '+scorecardId);
         fetchNotesAndAttachments();
     }
    
    public CreateNotesAndAttachmentController() {
        system.debug('--->CreateNotesAndAttachmentController, unparameterised constructor');
        scorecardId =  Apexpages.currentPage().getParameters().get('scid');
        parentId = Apexpages.currentPage().getParameters().get('parentId');
        scoreCardName = Apexpages.currentPage().getParameters().get('name');
        isNoteORAttchmt = Apexpages.currentPage().getParameters().get('typ');
        system.debug('--->CreateNotesAndAttachmentController,, scorecardId: '+scorecardId+' parentId : '+parentId+' isNoteORAttchmt: '+isNoteORAttchmt+' scoreCardName: '+scoreCardName);
        if(scorecardId==null || parentId == null || scoreCardName == null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Invalid URL.'));
        }
        else{
            attachmentURL = 'p/attach/NoteAttach?pid='+scorecardId+'&parentname='+scoreCardName+'&retURL='+scorecardId;
            notesURL = '002/e?parent_id='+scorecardId+'&retURL='+scorecardId;
            checkAccountAccess(parentId);
           // fetchNotesAndAttachments();            
     }
    }
    
    private void checkAccountAccess(Id pid){
         set<Id> allAccountIds = new set<Id>(); 
         accessibleAccIds = new set<Id>();
         Id currentuserId = UserInfo.getUserId();
        if(string.isNotBlank(pid)){
            for(Account sbuAcc : [select Id from account where parentId = :pid]){
                allAccountIds.add(sbuAcc.Id);
            }
            allAccountIds.add(pid);
        }
        system.debug('--->checkAccountAccess, currentuserId : ' + currentuserId + ', allAccountIds : ' + allAccountIds);
        
        set<Id> groupIds = getRoleGroupIds();
        
        for(Accountshare aShare : [Select id,accountaccesslevel,accountId 
                                   From accountshare 
                                   Where accountid in :allAccountIds 
                                   And (userorgroupid = :currentuserId
                                   OR userorgroupid IN :groupIds)]){
            if((aShare.accountaccesslevel =='Edit' || aShare.accountaccesslevel =='All')){
                accessibleAccIds.add(aShare.accountId);
            }        
        }
        system.debug('--->checkAccountAccess, accessibleAccIds : ' + accessibleAccIds+' pid : '+pid);
        if(accessibleAccIds.size() > 0) {
            if(!accessibleAccIds.contains(pid)){
                provideAccessOnParent = true;
                System.Debug('--->Inside If: provideAccessOnParent '+provideAccessOnParent);
            }
        }else{
            showError = true;
        }
        system.debug('--->checkAccountAccess, provideAccessOnParent : ' + provideAccessOnParent + ', showError : ' + showError);
    }
  
    public set<Id> getRoleGroupIds() {
        set<Id> groupIds;
        map<Id,Group> groupMap = new map<Id,Group>([SELECT Id, Name, DeveloperName,Type, RelatedId, Email, DoesIncludeBosses,DoesSendEmailToMembers 
                                                    FROM Group 
                                                    where RelatedId = :userInfo.getUserRoleId()]);
        system.debug('--->getRoleGroupIds, groupMap : ' + groupMap);
        if(groupMap.size() > 0) {
            groupIds = groupMap.keyset();
        }
        system.debug('--->getRoleGroupIds, returning groupIds : ' + groupIds);
        return groupIds;
    }
    
    //check which button triggerred the action and redirect accordingly
    public PageReference getAccessNCreateAttachementrNotes(){
        system.debug('--->getAccessNCreateAttachementrNotes, parentId : ' + parentId);
        PageReference pageRef;
        if(String.isNotBlank(parentId)){
            if(showError) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'User is not allowed to create Attachment or Notes'));      
            } else {
                if(provideAccessOnParent){
                    giveAccessOnParent();
                }
                if(isNoteORAttchmt.equals(Note)){
                    pageRef = createNotes();
                }else if( isNoteORAttchmt.equals(Attachment)){
                    pageRef = createAttachment();
                }
            }
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Some code is broken, please retry or contact SFDC Admin/Developer'));
        }
        system.debug('--->getAccessNCreateAttachementrNotes, returning pageRef : ' + pageRef);
        return pageRef;
    }
    
    public PageReference createAttachment(){
        PageReference attachmentPage = null; 
        System.debug('In createAttachment method');
        attachmentPage = new PageReference('/' +attachmentURL);
        return attachmentPage;
        
    }
    
    public PageReference createNotes(){
        PageReference notesPage = null;
        System.debug('In createNotes method');
        notesPage = new PageReference('/' +notesURL);
        return notesPage;
        
    }
    public void giveAccessOnParent(){
        system.debug('...create parent sharing###');
        Id currentUserId = UserInfo.getUserId();
        system.debug('..parentId....'+parentId);
        
        //NEED TO PUT BELOW CODE IN TRY CATCH
        AccountShare accShare = new AccountShare(
                                        accountaccesslevel = 'Edit',
                                        USERORGROUPID = currentUserId,
                                        Accountid = parentId,
                                        OpportunityAccessLevel = 'None'
                                        //CaseAccessLevel = 'None',
                                        //ContactAccessLevel = 'Edit'
                                        );
        
        system.debug('--->giveAccessOnParent, accShare : ' + accShare);
        insert accShare;        
    }                               
                                                                
    
    public void fetchNotesAndAttachments(){
        notesNAttachmentList = [SELECT Id,Name,(SELECT Id,Title FROM Notes),
               (SELECT Id,Name FROM Attachments) FROM Scorecard__c where Id =: scorecardId];
        System.Debug('na'+notesNAttachmentList+'.. '+scorecardId);
        if(notesNAttachmentList.size() > 0){
            Scorecard__c card = notesNAttachmentList[0];
            attachmentWrapperList = getNoteAttachmentWrapper(card);
        }      
         
    }
    
    public class attachmentWrapper{
        public String Id{get;set;}
        public String whattype{get;set;}
        public String Title{get;set;}
        public attachmentWrapper(String Id, String whattype, String title){
            this.Id = Id;
            this.whattype = whattype;
            this.Title = title;
        }
    }
    
    public List<attachmentWrapper> getNoteAttachmentWrapper(Scorecard__c card){
        List<attachmentWrapper> awrapperList = new List<attachmentWrapper>();
        
        for(Attachment a : card.Attachments){
            awrapperList.add(new attachmentWrapper(a.Id, 'Attachment', a.Name) );
        }
        for(Note n : card.Notes){
            awrapperList.add(new attachmentWrapper(n.Id,'Note',n.Title));
        }
        system.debug('...awrapper..'+awrapperList);
        return awrapperList;    
    }
        
}