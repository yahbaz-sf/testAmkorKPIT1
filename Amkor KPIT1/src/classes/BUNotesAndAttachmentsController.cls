/*
* Class:
* Shows the Notes and Attachments of BU Notes And Attachment Object
* on RFQ_Item__c Detail Page.
*/
public class BUNotesAndAttachmentsController{
    public List<Attachment> buAttachments{get;set;}
    public List<Note> buNotes{get;set;}
    public List<RFQI_BU_Notes_Attachments__c> buNandA{get;set;}
    public RFQ_Item__c rfqItem;
    public String noteId{get;set;}
    public String attachmentId{get;set;}
    public String rfqItemId{get;set;}
    public RFQI_BU_Notes_Attachments__c buNotesandAttachment{get;set;}
    public String buNotesandAttachmentId{get;set;}
    public String fifteenDigitbuNotesandAttachmentId{get;set;}    
    
    public BUNotesAndAttachmentsController(ApexPages.StandardController controller) {
        System.debug('--->controller'+controller);
        if(controller != null){
            rfqItem = (RFQ_Item__c)controller.getRecord();
            rfqItemId = controller.getId();
            
            //Apexpages.currentPage().getParameters().get('id');
            buNandA = [select Id,Name from RFQI_BU_Notes_Attachments__c where RFQ_Item__c =: rfqItem.Id];
            if(buNandA.size() < 0){
                createBUNotesAndAttachmentRecord(rfqItemId);
            }
            buNotesandAttachment = new RFQI_BU_Notes_Attachments__c(id = buNandA[0].Id);
            buNotesandAttachmentId = buNandA[0].Id;
            fifteenDigitbuNotesandAttachmentId = buNotesandAttachmentId.subString(0,15);
            buNotes = fetchBUNotes(buNandA[0]);
            buAttachments = fetchBUAttachments(buNandA[0]);
        }
    }
    
    public List<Note> fetchBUNotes(RFQI_BU_Notes_Attachments__c buNandA){
        buNotes = [select Id,Title,CreatedById,CreatedDate,LastModifiedDate,LastModifiedById,ParentId from Note where parentId =: buNandA.Id order by Title];
        return buNotes;
    }
    
    public List<Attachment> fetchBUAttachments(RFQI_BU_Notes_Attachments__c buNandA){
        buAttachments = [Select Id,Name,CreatedById,CreatedDate,LastModifiedById,LastModifiedDate,ParentId from Attachment where ParentId = :buNandA.Id order by Name];
        return buAttachments;
    }
    
    /*public PageReference editNotes(String noteId){
        return new PageReference('/'+noteId+'/e?retURL=%2F'+noteId);
    }*/
    
    public PageReference deleteNotes(){
        PageReference pR = null;
        if(noteId != null){
            Note no = new Note(id=noteId);
            delete no;
            buNotes = fetchBUNotes(buNandA[0]);
            pR = new PageReference('/'+rfqItem.Id);    
        }
        return pR;
    }
    
    /*public PageReference editAttachments(){
         return new PageReference('/'+attachmentId+'/e?retURL=%2F'+attachmentId);
    }*/
    
    public PageReference deleteAttachments(){
        PageReference pR = null;
        if(attachmentId != null){
            Attachment at = new Attachment(id=attachmentId);
            delete at;
            buAttachments = fetchBUAttachments(buNandA[0]);
            pR = new PageReference('/'+rfqItem.Id);    
        }
        return pR;
    }
    
    public void createBUNotesAndAttachmentRecord(String rfqItemId){
        boolean canShowNewButton = false;
        RFQI_BU_Notes_Attachments__c buNotesandAttachment = new RFQI_BU_Notes_Attachments__c(RFQ_Item__c = rfqItemId);
        insert buNotesandAttachment;
    }
   
    
}