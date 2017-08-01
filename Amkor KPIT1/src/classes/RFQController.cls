/*************************************************************************
* 
* PURPOSE: a custom controller for RFQ methods mostly related to custom 
*          action buttons on the RFQ detail page
*         
* CLASS: RFQController
* CREATED: 03/06/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Jason Swenski
* 
**************************************************************************/
public virtual with sharing class RFQController extends BaseController {

    public RFQ__c rfq {get; set;}
    private Id oppId;

    public Boolean shouldClose { get; set; }

    public RFQController(ApexPages.StandardController sc) {
        rfq = (RFQ__c) sc.getRecord();
        shouldClose = false;
        oppId = [select Opportunity__c from RFQ__c where Id =: rfq.Id].Opportunity__c;
    }
    
    /**
    * This method is the underlying action for the Add Item button on the
    * RFQ View page
    *
    * @returns a PageReference to the CreateRFQItem.page
    */
    public PageReference addItem() {
            
        PageReference pg = new PageReference('/apex/CreateRFQItem'); 
        pg.setRedirect(true); 
        pg.getParameters().put('rfqId',rfq.Id); 
        if(oppId != null) pg.getParameters().put('oppId',oppId); 
        return pg;
    }

    public PageReference setStatusToClosedCanceled() {
        List<RFQ_Item__c> items = [select Id, Status__c from RFQ_Item__c where RFQ__c =: rfq.Id];

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
    }

    public PageReference setStatus() {
        rfq.Status2__c = 'Closed Canceled';
        update rfq;
        shouldClose = true;
        return null;
    }
     
    public PageReference priceAll() {
        
        return new PageReference('/'+rfq.Id);    
    }
  
}