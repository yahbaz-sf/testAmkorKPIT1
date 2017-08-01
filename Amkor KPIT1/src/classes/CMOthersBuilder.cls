/*************************************************************************
*
* PURPOSE: Cost Model Engine for various Product Groups 
* (Advanced)
*
* CLASS: CMOthersBuilder
* CREATED: 7/17/2012 Ethos Solutions - www.ethos.com
* AUTHOR: Austin Delorme
***************************************************************************/
public virtual with sharing class CMOthersBuilder extends CMBuilder
{
	public CMOthersBuilder()
	{
		bridge = new CMOthersBridge();
	}





	//To Do:
	protected override void calcCostModel(RFQItemWrapper itemWrapper){}

	//To Do:
	public override void loadSettings(RFQItemWrapper itemWrapper, Boolean isReloaded){
		//setup(pWrapper);

	}

	
	public override void onAttributeChange(RFQItemWrapper itemWrapper, String attributeName){}

	public override void setEditabilityforNoCostModel(RFQILayout layout)
	{
		layout.changeEditability('Competitor__c',false);
		layout.changeEditability('Competitor_Price__c',false);
		layout.changeEditability('CLAM_Subtotal_New__c',false);
		layout.changeEditability('Customer_Target_Price__c',false);
		layout.changeEditability('Materials_Subtotal__c',false);

		layout.changeEditability('BU_Price__c',false);
		layout.changeEditability('Total_Cost_with_Substrate_New__c',false);
		layout.changeEditability('Cost_less_Substrate_New__c',false);
		layout.changeEditability('Total_Perc_GM__c',false);
		layout.changeEditability('Perc_IRR_New__c',false);
		layout.changeEditability('Perc_VAM_New__c',false);
		
		
	
	}

	protected override void calcResults(RFQItemWrapper itemWrapper, Boolean runCostModel)
	{
		Decimal clamOverhead = getDecimal(itemWrapper.specificRfqItem, 'CLAM_OH__c', 0.0);
		Decimal clamDepreciation = getDecimal(itemWrapper.specificRfqItem, 'CLAM_Depreciation__c', 0.0);
		Decimal clamOCOGS = getDecimal(itemWrapper.specificRfqItem, 'CLAM_OCOGS__c', 0.0);
		Decimal clamLabor = getDecimal(itemWrapper.specificRfqItem, 'CLAM_Labor__c', 0.0);
		
		Decimal clamSubtotal = clamDepreciation + clamLabor + clamOCOGS + clamOverhead;

		//not all PFs have materials wire
		Decimal materialWire;
		try {
			materialWire = getDecimal(itemWrapper.specificRfqItem, 'Materials_Wire__c', 0.0);
		} catch(Exception e) {
			materialWire = 0;
		}
		Decimal materialSubstrate = getDecimal(itemWrapper.specificRfqItem, 'Materials_Substrate__c', 0.0);
		Decimal materialODM = getDecimal(itemWrapper.specificRfqItem, 'Materials_ODM__c', 0.0);
		Decimal materialSubtotal = materialSubstrate + materialODM + materialWire;
		
		Decimal totalCost = materialSubtotal + clamSubtotal;
		Decimal costLessSubstrate = totalCost - materialSubstrate;

		//not all PFs have substrate markup
		Decimal substrateMarkup;
		try {
			substrateMarkup = getDecimal(itemWrapper.specificRfqItem, 'Subs_Markup_Perc__c', 0.0) / 100;
		} catch (Exception e) {
			substrateMarkup = 0;
		}
		Decimal assemblyGM = getDecimal(itemWrapper.specificRfqItem, 'Assembly_GM_wo_Substrate__c', 0.0) / 100;
		Decimal buPrice = (assemblyGM == 1) ? 0 : materialSubstrate * (1 + substrateMarkup) + costLessSubstrate / (1 - assemblyGM);
		Decimal totalGM = buPrice == 0 ? 0 : (buPrice - totalCost) / (buPrice);
		totalGM *= 100.0;
						

		itemWrapper.specificRfqItem.put('Materials_Subtotal__c', materialSubtotal);
		itemWrapper.specificRfqItem.put('BU_Price__c', buPrice);
		
		itemWrapper.specificRfqItem.put('CLAM_Subtotal_New__c', clamSubtotal);
		itemWrapper.specificRfqItem.put('Total_Cost_with_Substrate_New__c', totalCost);
		itemWrapper.specificRfqItem.put('Cost_less_Substrate_New__c', costLessSubstrate);
		itemWrapper.specificRfqItem.put('Total_Perc_GM__c', totalGM);

		/*Decimal customerPrice = getDecimal(itemWrapper.specificRfqItem, 'Price_To_Customer__c', 0.0);
		if(customerPrice < buPrice)
			itemWrapper.specificRfqItem.put('Price_To_Customer__c', buPrice);
        else
        	itemWrapper.specificRfqItem.put('Price_To_Customer__c', customerPrice);*/

        itemWrapper.clearPriceToCustomerIfRequired();

	}

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