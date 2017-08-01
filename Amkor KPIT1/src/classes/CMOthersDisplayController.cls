/*************************************************************************
*
* PURPOSE: Controller for Component used to display PBGA Results
*
* CLASS: CMOthersDisplayController
* CREATED: 7/18/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Chia Yuan Chuang
***************************************************************************/
public with sharing class CMOthersDisplayController {
	
	public CMOthersBuilder othersBuilder {get; private set;}
	public CMBuilder builder{get; set{othersBuilder = (CMOthersBuilder) value;}}
	public Boolean showDetails {get; set;}
	
	public CMOthersDisplayController()
	{
		showDetails = false;
	}
	
	public PageReference showAction()
	{
		showDetails = true;
		System.debug(LoggingLevel.Error, '####showAction: ' + othersBuilder.debugList);
		return null;
	}
	
	public PageReference hideAction()
	{
		showDetails = false;
		return null;
	}
}