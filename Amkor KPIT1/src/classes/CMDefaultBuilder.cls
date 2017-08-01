/*************************************************************************
*
* PURPOSE: Default Cost model Implementation class for Product Groups with
* no Cost Model
*
* CLASS: CMDefaultBuilder
* CREATED: 7/18/13/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Austin Delorme
***************************************************************************/
public virtual with sharing class CMDefaultBuilder extends CMBuilder 
{
	public CMDefaultBuilder()
	{
		bridge = new CMDefaultBridge();
	}

	
	//To Do:
	public override void loadSettings(RFQItemWrapper itemWrapper, Boolean isReloaded){}
	
	protected override void calcCostModel(RFQItemWrapper itemWrapper) {}

	protected override void calcResults(RFQItemWrapper itemWrapper, Boolean runCostModel) {}

	public override void onAttributeChange(RFQItemWrapper itemWrapper, String attributeName) {}
	
	public override void setEditabilityforNoCostModel(RFQILayout layout) {}
}