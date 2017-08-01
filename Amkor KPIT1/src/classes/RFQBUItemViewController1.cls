/*************************************************************************
*
* PURPOSE: Controller for the BU Version of the RFQ Item view page
*
* CLASS: RFQItemViewController
* CREATED: 3/20/2012 Ethos Solutions - www.ethos.com
* AUTHOR: Jason M. Swenski
***************************************************************************/
public with sharing class RFQBUItemViewController1 extends RFQItemViewController {
     
    //SF-138
    public RFQI_BU_Notes_Attachments__c buNotesandAttachment;//{get;set;}
    public String buNAId15D{get;set;}
    public String buNAName{get;set;}
    public List<Attachment> buAttachments{get;set;}
    public List<Note> buNotes{get;set;}
    public String noteId{get;set;}
    public String attachmentId{get;set;}
    public String Id{get;set;}
    
    public RFQBUItemViewController1(ApexPages.StandardController sc) { 
        super(sc);
        layout.enabledSections.put('Cost and Price', true);

        if(ApexPages.currentPage().getParameters().get('clone') != null){
            Boolean isClone = Boolean.valueOf(ApexPages.currentPage().getParameters().get('clone'));
            if(isClone){
                ApexPages.Message cloneMsg = new ApexPages.Message(ApexPages.Severity.INFO,'You are now viewing a cloned RFQ Item.');
                ApexPages.addMessage(cloneMsg);
            }   
        }

        //SF-138
        initBUNotesAttachments();
        getAutoCostErrors();
        
    }
    
    //SF-138 - New Method
    public void initBUNotesAttachments() {
        System.Debug('--->initBUNotesAttachments, wrapper : ' + wrapper);
        if(wrapper != null && wrapper.rfqItem != null && wrapper.rfqItem.Id != null) {
            List<RFQI_BU_Notes_Attachments__c> buNandA = [select Id,Name from RFQI_BU_Notes_Attachments__c where RFQ_Item__c =: wrapper.rfqItem.Id];
            if(buNandA.size() > 0){
                buNotesandAttachment = buNandA[0];
                String bunaId = buNotesandAttachment.Id;
                buNAName = buNotesandAttachment.Name;
                buNAId15D = bunaId.subString(0,15);
            }
            System.Debug('--->initBUNotesAttachments, buNotesandAttachment : ' + buNotesandAttachment);
            
            if(buNotesandAttachment != null) {
                buNotes = [select Id,Title,CreatedById,CreatedDate,LastModifiedDate,LastModifiedById,ParentId from Note where parentId =: buNandA[0].Id order by LastModifiedDate DESC];
                buAttachments = [Select Id,Name,CreatedById,CreatedDate,LastModifiedById,LastModifiedDate,ParentId from Attachment where ParentId = :buNandA[0].Id order by LastModifiedDate DESC];
            }
            System.Debug('--->initBUNotesAttachments, buNotes : ' + buNotes);
            System.Debug('--->initBUNotesAttachments, buAttachments : ' + buAttachments);
        }
    }
    
    //SF-138 - New Method
    public void createBUNA() {
        if(buNotesandAttachment == null && wrapper != null && wrapper.rfqItem != null && wrapper.rfqItem.Id != null) {
            buNotesandAttachment = new RFQI_BU_Notes_Attachments__c(RFQ_Item__c = wrapper.rfqItem.Id);
            insert buNotesandAttachment; 
        }
        System.Debug('--->createBUNA, buNotesandAttachment : ' + buNotesandAttachment);
    }
    
    //used to get only BU sections
    protected override RFQILayout getLayout(RFQItemWrapper itemWrapper){
        return PFFieldDefDao.getInstance().getPackageFamilyLayout(itemWrapper.packageFamily.Id, itemWrapper.packageFamily.Layout_Version__c, itemWrapper.rfqItem.Layout_Version__c, 'BU');
    } 

    public override PageReference cloneItem() {
        RFQItemWrapper cloneWrapper = RFQItemDao.getInstance().cloneLineItem(wrapper,RFQItemDao.STATUS_BU_DRAFT,true, layout);
        PageReference pr = new PageReference('/apex/RFQBUItemView?id=' + cloneWrapper.rfqItem.Id);
        pr.setRedirect(true);
        return pr;   
    }

    public PageReference editPrice() {
        return new PageReference('/apex/RFQBUItemPriceEdit?id=' + wrapper.rfqItem.Id);
    }
    
    public PageReference buExport() {
        return new PageReference('/apex/RFQBuExport?id='+wrapper.rfqItem.Id);
    } 
    
    public PageReference launchSimulator(){
        return new PageReference('/apex/RFQCostModelSimulator?id='+wrapper.rfqItem.Id);
    }

    public PageReference importItem() {
        return new PageReference('/apex/RFQBUImport?rfqItemId='+wrapper.rfqItem.Id);
    }

    public override PageReference setupCostModel() {  
        //SF-138
        createBUNA();
        return setupCostModel(wrapper,true,false);
    }

    public Boolean getShowCloneButton() {
        if(getIsUnderApproval()) return false;  
        return true;
    }
    
    //SF-138
    public PageReference editNotes(){
         return new PageReference('/'+noteId+'/e?retURL=/apex/RFQBUItemView1?id='+wrapper.rfqItem.Id);
    }
    
    public PageReference deleteNotes(){
        if(noteId != null){
            Note no = new Note(id=noteId);
            delete no;
            buNotes = [select Id,Title,CreatedById,CreatedDate,LastModifiedDate,LastModifiedById,ParentId from Note where parentId =: buNotesandAttachment.Id order by Title];
            
        }
        return new PageReference('/apex/RFQBUItemView1?id='+wrapper.rfqItem.Id);
    }
    
    public PageReference editAttachments(){
         return new PageReference('/'+attachmentId+'/e?retURL=/apex/RFQBUItemView1?id='+wrapper.rfqItem.Id);
    }
    
    public PageReference viewAttachments(){
        return new PageReference('/servlet/servlet.FileDownload?file='+attachmentId);
    }
    
    public PageReference deleteAttachments(){
        if(attachmentId != null){
            Attachment at = new Attachment(id=attachmentId);
            delete at;
            buAttachments = [Select Id,Name,CreatedById,CreatedDate,LastModifiedById,LastModifiedDate,ParentId from Attachment where ParentId = :buNotesandAttachment.Id order by LastModifiedDate DESC];
        }
        return new PageReference('/apex/RFQBUItemView1?id='+wrapper.rfqItem.Id);
    }
    
    public PageReference goToId(){
        return new PageReference('/'+Id);
    }
}