/*************************************************************************
*
* PURPOSE: 
*
* CLASS: 
* CREATED: 5/13/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Steve Simpson
***************************************************************************/
public with sharing class CMMLFBuilder extends CMFCMBuilderBase
{
	public CMMLFBuilder()
	{
		
		bridge = new CMMLFBridge();		
		bomCalc = new CMMLFBOMCalc();		
		processCalc = new CMMLFProcessCalc();
	}

	protected override void loadPfSubClassMap(){
		pfSubClassMap = null;

		List<Package_Family__c> pfList = [Select id, name, Specific_RFQ_Item_Object__c,  Product_Group__c from Package_Family__c where Product_Group__c = : fcmBridge.wrapper.ProductGroup.id];
		pfSubClassMap = new Map<Package_Family__c, String>();
		for(Package_Family__c pf : pfList) {
			String subClass = getSubClassBySpecificRFQItem(pf.Specific_RFQ_Item_Object__c);
			Integer startIndex = subClass.indexOf('"');
			Integer endIndex = (subClass.lastIndexOf('"') == -1) ? subClass.length() : subClass.lastIndexOf('"') ;
			pfSubClassMap.put(pf, subClass.substring(startIndex+1, endIndex));
		}		
	}
	
	//Need it to get a sub Class 1 map ---- not sure if there is anyway to avoid it
	private String getSubClassBySpecificRFQItem(String pfName){

		if(pfName == null) return null;

		String subClassName = 'PF_Sub_Class_1__c';
		Map<String, Schema.SObjectField> objectFields = Schema.getGlobalDescribe().get(pfName).getDescribe().fields.getMap();
		Schema.SObjectField subClassField = objectFields.get(subClassName);
		
		if(subClassField != null){			
			return (String)subClassField.getDescribe().getDefaultValueFormula();
		}
		return null;			
	}

	public override Boolean shouldProcessAdderCostRules() {
		return true;
	}

	public override void processAdderCostRules(RFQItemWrapper wrapper) {
		// Add adder cost field to BU Price

		// AMK-2698 Removing math associated with BU Price.  The Operator should account for this when they want this to be added.
		//Decimal adderCost = getDecimal(wrapper.specificRfqItem, 'Adder_Cost__c', 0);

		//if (adderCost > 0) {
		//	// Per AMK-1455 Add adder cost to post-margined BU Price
		//	Decimal buPrice = (Decimal)wrapper.specificRfqItem.get('BU_Price__c');

		//	if (buPrice != null) {
		//		buPrice = buPrice + adderCost;
		//		wrapper.specificRfqItem.put('BU_Price__c', buPrice);
		//	}
		//}
	}
}