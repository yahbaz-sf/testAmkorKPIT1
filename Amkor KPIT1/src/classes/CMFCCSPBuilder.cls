/*************************************************************************
*
* PURPOSE: Cost Model Engine for FC CSP/FC SCSP
*
* CLASS: CMFCCSPBuilder
* CREATED: 2/14/14 Ethos Solutions - www.ethos.com
* AUTHOR: Austin Delorme
***************************************************************************/
public virtual with sharing class CMFCCSPBuilder extends CMBuilder
{
	public CMFCCSPBuilder()
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
    	fieldMap.put('margin', 'Total_Perc_GM__c');
    	fieldMap.put('subsMarkup', 'Subs_Markup_Perc__c');
    	fieldMap.put('marginNoSubstrate', 'Assembly_GM_wo_Substrate__c');
    	fieldMap.put('subsCost', 'Materials_Substrate__c');
    	fieldMap.put('totalCost', 'Total_Cost_with_Substrate_New__c');
    	fieldMap.put('costLessSubs', 'Cost_less_Substrate_New__c');

		return fieldMap;
    }

}