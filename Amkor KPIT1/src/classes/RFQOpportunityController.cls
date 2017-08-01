public with sharing class RFQOpportunityController extends BaseController{
  
    private Opportunity op;
    private Id rfqId;

    public Boolean shouldClose { get; set; }

  public RFQOpportunityController(ApexPages.StandardController sc) {    
        op = (Opportunity) sc.getRecord();
        shouldClose = false;

        rfqId = [select RFQ__c from Opportunity where Id =: op.Id].RFQ__c;
  }
    
    /**
    * This method is the underlying action for the Add Item button on the
    * RFQ View page
    *
    * @returns a PageReference to the CreateRFQItem.page
    */
    public PageReference addItem() {
        
        PageReference pg = new PageReference('/apex/CreateRFQItem');
        pg.getParameters().put('oppId',op.Id);
        if(!StringUtils.isBlank(rfqId)) pg.getParameters().put('rfqId',rfqId);
        pg.setRedirect(true);
        return pg;
    }

    public PageReference setStatusToClosed() {
        List<RFQ_Item__c> items = [select Id, Status__c from RFQ_Item__c where Opportunity__c =: op.Id];

        if(items.size() == 0) {
            return setStatus();
        }
        else {
            Boolean shouldSetStatus = true;
            for(RFQ_Item__c r : items) {
                if(RFQItemDao.STATUS_OPEN.contains(r.Status__c)) shouldSetStatus = false;
            }
            if(shouldSetStatus) return setStatus();
            else {
                addError('Please Close all items');
                return null;
            }
        }
        return null;
    }

    public PageReference setStatus() {
        Op.Opportunity_Status__c = 'Closed';
        update Op;
        shouldClose = true;
        return null;
    }
}