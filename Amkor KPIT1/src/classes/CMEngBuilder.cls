/*************************************************************************
*
* PURPOSE: Cost Model Engine for Wafer Die and Die Sales
*
* CLASS: CMDieBuilder
* CREATED: 2/14/14 Ethos Solutions - www.ethos.com
* AUTHOR: Austin Delorme
***************************************************************************/
public with sharing class CMEngBuilder extends CMBuilder
{
	public CMEngBuilder()
	{
		bridge = new CMOthersBridge();
	}

	protected override void calcCostModel(RFQItemWrapper itemWrapper){}

	public override void loadSettings(RFQItemWrapper itemWrapper, Boolean isReloaded){}

	public override void onAttributeChange(RFQItemWrapper itemWrapper, String attributeName) {}
	
	public override void setEditabilityforNoCostModel(RFQILayout layout) {}

	protected override void calcResults(RFQItemWrapper itemWrapper, Boolean runCostModel) {}

    public override Map<String, String> getFieldMap()
    {
    	Map<String, String> fieldMap = new Map<String, String>();

    	fieldMap.put('price', 'BU_Price__c');
    	fieldMap.put('subtotal', 'Sub_Total__c');

		return fieldMap;
    }

}