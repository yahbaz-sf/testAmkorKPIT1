/*************************************************************************
*
* PURPOSE: Controller for the RFQ Item view page
*
* CLASS: RFQItemViewController
* CREATED: 3/12/2012 Ethos Solutions - www.ethos.com
* AUTHOR: Jason M. Swenski
***************************************************************************/
public virtual with sharing class RFQItemViewController extends RFQItemController {
//Ashish: 13-Apr-2017: SF-139: Renaming the section of passive Description for package family 'MEMS'.
public string sectionTitle {set;get;}

//Abhay-A:16-May-2017 :SF-195:Win / Loss / Cancel Reason Enhancement
public boolean displayPopup {get; set;}  

public String status {get; set;} 

public String clickedButton {get; set;} 

public String errorMessage {get; set;}


public RFQItemViewController(ApexPages.StandardController sc) {
  
	super(sc);
	


	//Ashish: 13-Apr-2017: SF-139: Renaming the section of passive Description for package family 'MEMS'.
	sectionTitle='Passive Description';
    
	if(wrapper.packageFamily.Name=='MEMS'){
		sectionTitle='Other Components';            
	}
	system.debug('wrapper.specificRfqItem : '+wrapper.specificRfqItem);
	system.debug('wrapper.RfqItem : '+wrapper.RfqItem);
}
 
/**
* This method is the underlying action for the Edit button
* on the RFQ Item View page. It toggles the view into edit mode.
*/

  //Abhay-A:16-May-2017 : SF-195:Win / Loss / Cancel Reason Enhancement
  /*methods for displaying and hiding a popup*/

    public void closePopup() {        
        displayPopup = false;   
        
    }    
      public void showPopup() {  
        wrapper.rfqItem.Quoted_Status__c=status;
        //Abhay:09-Jun-2017:SF-195: Changed Status_Comments__c to null.
        wrapper.rfqItem.Status_Comments__c = null;
        //Abhay-A:13-June-2017 :SF-195:Win / Loss / Cancel Reason Enhancement
	    wrapper.rfqItem.StatusReason__c=null;

        System.debug('Apex funciton call');
        System.debug('status as set by param'+ wrapper.rfqItem.Quoted_Status__c);

            displayPopup = true;     
           // setStatusField(status);
    }
    
public PageReference editMode() {
	return new PageReference('/apex/RFQItemEdit?id=' + wrapper.rfqItem.Id);     
}

public PageReference recallApproval() {
	if(ApprovalUtils.isUnderApproval(wrapper.rfqItem.Id)) {
	
	   wrapper.clearPrices();

		ApprovalUtils.recall(wrapper.rfqItem.Id);
		if(wrapper.rfqItem.Status__c == RFQItemDao.STATUS_PRICE_PENDING_BU || wrapper.rfqItem.Status__c == RFQItemDao.STATUS_SALES_REQ_PREAPPROVAL || wrapper.rfqItem.Status__c == RFQItemDao.STATUS_PRICE_SUBMIT) {
			return setStatus(RFQItemDao.STATUS_NEW);
		}
		else if(wrapper.rfqItem.Status__c == RFQItemDao.STATUS_PRICE_ESCALATION){
			return setStatus(RFQItemDao.STATUS_PRICE_COMPLETE);
		}
		
	}
	return null;
}
  
/**
* This method is the underlying action for the Edit button
* on the RFQ Item View page. It toggles the view into edit mode.
*/
public PageReference requestEscalation() {
	if ((Decimal)wrapper.specificRfqItem.get('BU_Price__c') < (Decimal)wrapper.specificRfqItem.get('Price_To_Customer__c')) 
	{
			addError('You cannot escalate an RFQ Item with Price To Customer greater than the BU Price');
			return null;
	}

	return new PageReference('/apex/RFQItemEscalation?id=' + wrapper.rfqItem.Id);
}
//Bhanu - 29-June-2016 : Salesforce 69 - New Opportunity STAGE changes
//Adding Set as Qual button and removing obsolete Status 
/* public PageReference setAsWonPrototype() {
	return setStatus(RFQItemDao.STATUS_WON_PROTOTYPE);
}
 
public PageReference setAsWonQual() {
	return setStatus(RFQItemDao.STATUS_WON_QUALIFICATION);
} */

//Abhay A-11-May-2017 :changes for SF-195 MADE HERE.

/*public PageReference setAsQual() {
	return setReasonComment(RFQItemDao.STATUS_Qual);
}

public PageReference setAsProgramWin() {
	return setReasonComment(RFQItemDao.STATUS_PROGRAM_WIN);
}
 
public PageReference setAsProgramLoss() {
	return setReasonComment(RFQItemDao.STATUS_PROGRAM_LOSS);
}

public PageReference setAsProgramCancelled() {
	PageReference pg = setReasonComment(RFQItemDao.STATUS_PROGRAM_CANCELED);
	recallApproval();
	return pg;
}*/

//Abhay-A:16-May-2017 :SF-195:Win / Loss / Cancel Reason Enhancement
public PageReference submit() {
    String tempClickedButton;
    if(clickedButton!=null){
        tempClickedButton = clickedButton;    
    }
    else{
        tempClickedButton=' ';
    }
    
    System.debug('button is'+clickedButton);
    if(tempClickedButton.equals('qualified'))
    {
        	return setReasonComment(RFQItemDao.STATUS_Qual);
    }
     else if(tempClickedButton.equals('won'))
    {
        	return setReasonComment(RFQItemDao.STATUS_PROGRAM_WIN);
    }
    else if(tempClickedButton.equals('lost'))
    {
      return setReasonComment(RFQItemDao.STATUS_PROGRAM_LOSS);
    }
    else if(tempClickedButton.equals('canceled'))
    {
        	PageReference pg = setReasonComment(RFQItemDao.STATUS_PROGRAM_CANCELED);
	        recallApproval();
	        return pg;
        
    }
    
	return null;
}
//Abhay-A:16-May-2017 :SF-195:Win / Loss / Cancel Reason Enhancement
private PageReference setReasonComment(String status)
{
	Boolean updateReasonComment = false;
	wrapper.rfqItem.Quoted_Status__c = status;
	
	if(wrapper.rfqItem.Quoted_Status__c != null  )
	{
		if(wrapper.rfqItem.StatusReason__c == null)
		{
			   
                wrapper.rfqItem.StatusReason__c.addError('Please select the Reason');
			updateReasonComment = true;
		}
		
		//Abhay:09-Jun-2017 :SF-195: Changed expression to include StatusReason__c = "Multi-service quote non competitive" and error message. 
    		if(wrapper.rfqItem.StatusReason__c == 'Other' && wrapper.rfqItem.Status_Comments__c == null)
    		{
                wrapper.rfqItem.Status_Comments__c.addError('Please Fill the Comments');
                updateReasonComment = true;
    			
    		}
    		
    		if(wrapper.rfqItem.StatusReason__c =='Multi-service quote non competitive' && wrapper.rfqItem.Status_Comments__c == null)
    		{
    		    wrapper.rfqItem.Status_Comments__c.addError('Please list which service(s) were non competitive');
    			updateReasonComment = true;
    		}

	}
	
	if(!updateReasonComment)
		{
		    
			return setStatus(status);
		}
	else{
		return null;
	}	
}
//Till Here SF-195
private PageReference setStatus(String status) {
    
	wrapper.rfqItem.Status__c = status;
	

	if (!RFQItemDao.getInstance().saveLineItem(wrapper)) return null;
	PageReference pg = new PageReference('/apex/RFQItemView?id=' + wrapper.rfqItem.Id);
	pg.setRedirect(true);
	return pg;
}

}