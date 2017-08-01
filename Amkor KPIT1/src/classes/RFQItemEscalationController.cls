/*************************************************************************
*
* PURPOSE: Controller for the RFQ Item Escalation page
*
* CLASS: RFQItemEscalationController
* CREATED: 3/12/2012 Ethos Solutions - www.ethos.com
* AUTHOR: Jason M. Swenski
***************************************************************************/
public with sharing class RFQItemEscalationController extends RFQItemEditController {
	
	public RFQI_Escalation__c escalation {get;set;}
	
	public RFQItemEscalationController(ApexPages.StandardController sc) {
		super(sc);
		escalation = new RFQI_Escalation__c();
	} 
	
	/**
    * Creates an escalation object used for reporting, and attempts to launch an approval process
    *
    * @returns a PageReference to the view page if successful, null otherwise
    */
	public PageReference escalate() {
		try { 
	            if ((Decimal)wrapper.specificRfqItem.get('BU_Price__c') < (Decimal)wrapper.specificRfqItem.get('Price_To_Customer__c')) 
	            {
	                    addError('You cannot escalate an RFQ Item with Price To Customer greater than the BU Price');
	                    return null;
	            }
            }
            catch(Exception e){}

		try {
			wrapper.rfqItem.Status__c = RFQItemDao.STATUS_PRICE_ESCALATION;
			//Lalit for sf-68
			//neeed to update the wrapper here.
			update wrapper.rfqItem;
            ApprovalUtils.startApproval(wrapper.rfqItem.Id, escalation.Reason__c + ': ' + escalation.Comments__c);
            escalation.RFQ_Item__c = wrapper.rfqItem.Id;		
		    insert escalation;
            
        } catch(Exception e){
    	    addError(Label.RFQ_ERR_0003);
    		return null;
        } 
		return new PageReference('/apex/RFQItemView?id='+wrapper.rfqItem.Id);
	}
}