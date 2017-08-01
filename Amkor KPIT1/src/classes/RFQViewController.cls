/*************************************************************************
*
* PURPOSE: Controller for the RFQView page which is just a thin wrapper
*          around the page layout to provide messages
*
* CLASS: RFQViewController
* CREATED: 6/17/2012 Ethos Solutions - www.ethos.com
* AUTHOR: Jason Swenski
***************************************************************************/
public with sharing class RFQViewController extends RFQController {
	
    public RFQViewController(ApexPages.StandardController sc) {
        super(sc);
        String message = ApexPages.currentPage().getParameters().get('message');
        String messageType = ApexPages.currentPage().getParameters().get('type');
        if(!StringUtils.isBlank(message)) {
        	if(messageType == 'error' || StringUtils.isBlank(messageType)) {
        		addError(message);
        	}
        	else if(messageType == 'info') addInfo(message);
        	else if(messageType == 'warn') addWarning(message);
        	else if(messageType == 'confirm') addConfirm(message);
        }
    }
    
    /* This method assigns the RFQ to the BPG work queue, it requires that there is an attachment and
     * no existing RFQ line items 
     *
     * @returns a page refrence with a confirmation or error message
     */
    public PageReference assignToBPG() {
    	
    	PageReference pg; 
    	ID queueId;
    	List<Group> queues = [select Id from Group where Name =: RFQSystemSettings.getBPGWorkQueueName()];
    	if(queues.size() > 0) queueId = queues[0].Id; 
    	else {
    		//Can we determine the queue to assign to?
    		return refreshWithMessage('Could not find the BPG Work Queue','error');
    	}
    	//Are there any existing RFQ Items?
    	if([select Id from RFQ_Item__c where RFQ__c =: rfq.Id].size() > 0) {	
    		return refreshWithMessage('There are existing line items on this RFQ, could not assign to BPG','error');
    	}
        
        List<Attachment> attachments = [select Id from Attachment where ParentId =: rfq.Id];
    	if(attachments.size() < 1) {
    		//If there are no attachments the BPG can't do anything with this
    		return refreshWithMessage('No attachment on this RFQ','error');
    	}
    	else{
    		//Otherwise we're good, assign it to the queue
            RFQ_BPG_Map_Request__c req = new RFQ_BPG_Map_Request__c(
                RFQ__c = rfq.Id,
                OwnerId = queueId
            );

            insert req;
    		return refreshWithMessage('Assigned To BPG','confirm');
    	}

       return refreshWithMessage('Uh-oh, something went wrong when trying to assign to the BPG','warning');
    }
    
    private PageReference refreshWithMessage(String message, String typeMessage) {    
		PageReference pg = new PageReference('/apex/RFQView?id=' + rfq.Id + '&message=' + message + '&type=' + typeMessage);
		pg.setRedirect(true);
		return pg;
    }
    
     
    /* This method assigns the RFQ to the the current user - it is used for taking the RFQ
     * out of a queue
     *
     * @returns a page refrence with a confirmation or error message
     */
    public PageReference assignToMe() {
    	
    	rfq.OwnerId = UserInfo.getUserId();
    	RFQDao.getInstance().save(rfq);
    	PageReference pg = new PageReference('/apex/RFQView?id=' + rfq.Id + '&message=You have been assigned to this RFQ&type=confirm');
    	pg.setRedirect(true);
    	return pg;
    }
}