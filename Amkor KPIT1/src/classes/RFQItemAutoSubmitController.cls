public with sharing class RFQItemAutoSubmitController extends RFQItemController {
	
    public Integer failedItems {get; set;}
    public Boolean isProcessing {get; set;}
    public Integer numberLeft {get;set;}

	public RFQItemAutoSubmitController(ApexPages.StandardController sc) {
		super(sc);
        isProcessing = true;
		String sfailedItems = getParam('failed');
        numberLeft = Integer.valueOf(getParam('numberLeft'));
		if(!StringUtils.isBlank(sFailedItems)){
		    failedItems = Integer.valueOf(sFailedItems);
		}
		else{
		    failedItems = 0;
		}
	}

	public PageReference submitItemAutomatic() {
        
        try {
            submitItem();
        }
        catch(Exception e) {
            wrapper.rfqItem.Status__c = RFQItemDao.STATUS_NEW;
            update wrapper.rfqItem;
            failedItems++;
        }

        String nextId = getNext();
        if(nextId == null){
            isProcessing = false;
            if(failedItems > 0) {
                addWarning(failedItems + ' item(s) had problems submitting, these items were returned to a New status.');
            }
            else {
                addConfirm('All items have been submitted, you may close this window');
                return Page.closePage;
            }
            return null;    
        }
        
        PageReference pg = new PageReference('/apex/RFQItemAutoSubmit?id='+nextId + '&failed='+failedItems + '&numberLeft='+numberLeft);
        pg.setRedirect(true);
        return pg;
	}

	public String getNext() {
        List<RFQ_Item__c> nextItem = [select Id from RFQ_Item__c where RFQ__c =: wrapper.rfqItem.RFQ__c and Status__c =: RFQItemDao.STATUS_PRICE_SUBMIT];
        numberLeft = nextItem.size();
        if(numberLeft == 0) return null;
        return nextItem[0].Id;
	}


}