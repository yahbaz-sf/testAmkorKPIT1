/*************************************************************************
*
* PURPOSE: Controller for Component used to display PBGA Results
*
* CLASS: CMOthersDisplayController
* CREATED: 7/19/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Chia Yuan Chuang
***************************************************************************/
public with sharing class CMFCDisplayController {
	
	public CMFCBuilder fcBuilder {get; private set;}
	public CMBuilder builder{get; set{fcBuilder = (CMFCBuilder) value;}}
	public Boolean showDetails {get; set;}
	
	public CMFCDisplayController()
	{
		showDetails = false;
	}
	
	public PageReference showAction()
	{
		showDetails = true;
		System.debug(LoggingLevel.Error, '####showAction: ' + fcBuilder.debugList);
		return null;
	}
	
	public PageReference hideAction()
	{
		showDetails = false;
		return null;
	}
}