/*************************************************************************
*
* PURPOSE: Extension Methods for operating on a CPN object
*
* CLASS: CPNController
* CREATED: 8/19/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Jason M. Swenski
***************************************************************************/
public virtual with sharing class CPNController extends BaseController{
	
    public Configured_Part_Number__c cpn {get; set;}

    public CPNController(ApexPages.StandardController sc) {
        cpn = (Configured_Part_Number__c) sc.getRecord();
        cpn = CPNDao.getInstance().getById(cpn.Id);
    }

    public PageReference transmit() {
    	//SAP doesn't like to get things twice and will choke if
    	//the item has been transmitted already
    	if(cpn.Status__c != 'Transmitted') {
    		SAPInterface.transmitCPNToSAP(cpn.Id);
    	}

    	PageReference pg = new PageReference('/' + cpn.Id);
    	pg.setRedirect(true);
    	return pg;
    }
}