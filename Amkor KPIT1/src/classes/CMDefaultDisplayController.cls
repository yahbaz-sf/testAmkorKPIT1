/*************************************************************************
*
* PURPOSE: Controller for Component used to display Default Results
*
* CLASS: CMDefaultDisplayController
* CREATED: 7/18/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Chia Yuan Chuang
***************************************************************************/
public with sharing class CMDefaultDisplayController {
	
	public CMDefaultBuilder defaultBuilder {get; private set;}
	public CMBuilder builder{get; set{defaultBuilder = (CMDefaultBuilder) value;}}
	public Boolean showDetails {get; set;}
	
	public CMDefaultDisplayController()
	{
		showDetails = false;
	}
	
	public PageReference showAction()
	{
		showDetails = true;
		System.debug(LoggingLevel.Error, '####showAction: ' + defaultBuilder.debugList);
		return null;
	}
	
	public PageReference hideAction()
	{
		showDetails = false;
		return null;
	}
}