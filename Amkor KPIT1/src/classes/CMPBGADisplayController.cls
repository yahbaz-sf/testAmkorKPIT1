/*************************************************************************
*
* PURPOSE: Controller for Component used to display PBGA Results
*
* CLASS: CMPBGADisplayController
* CREATED: 5/01/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Steve Simpson
***************************************************************************/
public with sharing class CMPBGADisplayController {
	
	public CMPBGABuilder pbgaBuild {get; private set;}
	public CMBuilder builder{get; set{
		pbgaBuild = (CMPBGABuilder) value;}}
	public Boolean showDetails {get; set;}	
	public CMBuilder pbgaBuilder {get; set;}
	
	public CMPBGADisplayController()
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