/*************************************************************************
*
* PURPOSE: Controller for Component used to display CABGA/SCSP Results
*
* CLASS: CMCABGADisplayController
* CREATED: 8/5/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Austin Delorme
***************************************************************************/
public with sharing class CMCABGADisplayController {
	
	public CMCABGABuilder cabgaBuilder {get; private set;}
	public CMBuilder builder{get; set{cabgaBuilder = (CMCABGABuilder) value;}}
	public Boolean showDetails {get; set;}
	
	public CMCABGADisplayController()
	{
		showDetails = false;
	}
	
	public PageReference showAction()
	{
		showDetails = true;
		return null;
	}
	
	public PageReference hideAction()
	{
		showDetails = false;
		return null;
	}
}