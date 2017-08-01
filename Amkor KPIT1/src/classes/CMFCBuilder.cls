/*************************************************************************
*
* PURPOSE: Cost Model Engine for Flip Chip product group
* 
*
* CLASS: CMFCBuilder
* CREATED: 7/18/2012 Ethos Solutions - www.ethos.com
* AUTHOR: Chia Yuan Chunag
***************************************************************************/
public abstract class CMFCBuilder extends CMFCMBuilderBase
{
	
	String rfqiType;

	public CMFCBuilder()
	{
		bridge = new CMFCBridge();
		bomCalc = new CMFCBOMCalc();
		processCalc = new CMFCProcessCalc();
		
	}

	//---Setup Calc references
	public override void setup(RFQItemWrapper pWrapper, Boolean needsBridgeSetup) 
	{
		super.setup(pWrapper, needsBridgeSetup);
		rfqiType = getSpecificRfqType(pWrapper);
	}
	

	public override void loadSettings(RFQItemWrapper itemWrapper, Boolean isReloaded){

		//load attributes
		List<String> attributes = new List<String> ();
		attributes.add('Assembly_GM_wo_Substrate__c');
		attributes.add('Subs_Markup_Perc__c');

		List<String> pfAttributes = new List<String>();
		pfAttributes.add('Assembly_GM_wo_Substrate__c');
		pfAttributes.add('Subs_Markup_Perc__c');
		
		super.loadSettingsByPFAttributes(itemWrapper, isReloaded, attributes, pfAttributes);		


	}

	protected override void recalcSummaryWithoutCostModel()
	{
		RFQItemWrapper itemWrapper = fcmBridge.wrapper;
        
        //Lalit - 21-Marc-2017 : Salesforce-119 : FC BGA Recalc Issue at BU Screen
        //Commenting these fields, now total cost will not be dependent upon these 4 values.
		/*Decimal clamSubtotal = getDecimal(itemWrapper.specificRfqItem, 'CLAM_Subtotal_New__c', 0.0);
		Decimal materialSubstrate = getDecimal(itemWrapper.specificRfqItem, 'Materials_Substrate__c', 0.0);
		Decimal materialODM = getDecimal(itemWrapper.specificRfqItem, 'Materials_ODM__c', 0.0);
		Decimal othersCost = getDecimal(itemWrapper.specificRfqItem, 'Others_Cost__c', 0.0);*/
		Decimal buPrice = getDecimal(itemWrapper.specificRfqItem, 'BU_Price__c', 0.0);
		//Decimal totalCost = materialSubstrate + clamSubtotal + materialODM + othersCost;
		//we will get the direct value for total cost.
		Decimal totalCost = getDecimal(itemWrapper.specificRfqItem, 'Total_Cost_with_Substrate_New__c', 0.0);
		system.debug('CMFCBuilder #62 totalCost : '+totalCost);
		Decimal totalGM = buPrice == 0 ? 0 : (buPrice - totalCost) / (buPrice);
		system.debug('CMFCBuilder #64 totalGM : '+totalGM);
		
		itemWrapper.specificRfqItem.put('Total_Perc_GM__c', totalGM * 100.0);
		//itemWrapper.specificRfqItem.put('Total_Cost_with_Substrate_New__c', totalCost);
		system.debug('CMFCBuilder itemWrapper.specificRfqItem :  '+itemWrapper.specificRfqItem);

        itemWrapper.clearPriceToCustomerIfRequired(); 
		
		//update itemWrapper.specificRfqItem;
	}

	protected override void recalcSummaryValues(RFQI_FCM__c itemFcm)
	{
		debug.log('fcBuilder.recalcSummaryValues');
		//update itemFcm;		//---Save any updates to the percent fields
		//itemFcm = RFQIFCMDao.getInstance().getById(itemFcm.id);		//---Reload the Item FCM (with the updated roll up summaries)
		
		//---BOM Totaling
		itemFcm.Material_Freight__c = itemFcm.Material_Freight_Percent__c * itemFcm.Sub_Total_Material_Cost__c/100;
		itemFcm.Material_Tooling__c = itemFcm.Material_Tooling_Percent__c * itemFcm.Sub_Total_Material_Cost__c/100;
		itemFcm.Material_Brokerage__c = itemFcm.Material_Brokerage_Percent__c * itemFcm.Sub_Total_Material_Cost__c/100;

		itemFcm.Total_Material_Cost__c = itemFcm.Sub_Total_Material_Cost__c + itemFcm.Material_Freight__c + itemFcm.Material_Tooling__c + itemFcm.Material_Brokerage__c;
		
		//---Process Totaling 
		itemFcm.Manufacturing_Overhead__c = itemFcm.Total_Cost_Per_Unit__c * itemFcm.Manuf_OH_To_Process_Cost__c;
		itemFcm.QA_Cost__c = itemFcm.Total_Cost_Per_Unit__c * itemFcm.QA_Cost_To_Process_Cost__c;
		itemFcm.Service_Group_Cost__c = itemFcm.Total_Cost_Per_Unit__c * itemFcm.Service_Cost_To_Process_Cost__c;
		itemFcm.CLAM__c = itemFcm.Total_Cost_Per_Unit__c + itemFcm.Manufacturing_Overhead__c + itemFcm.QA_Cost__c + itemFcm.Service_Group_Cost__c;

		
		//---Overall Total
		itemFcm.Total_Cost_of_Goods__c = itemFcm.Total_Material_Cost__c + itemFcm.CLAM__c;
		itemFcm.Other_Cost_Of_Goods_Sold__c = itemFcm.CLAM__c - itemFcm.Manufacturing_Overhead__c - itemFcm.Total_Equipment_Depreciation__c - itemFcm.Total_Direct_Labor__c;

		//---Overall Price
		itemFcm.Total_Price__c = (itemFcm.CLAM__c + itemFcm.Total_Material_Cost__c - itemFcm.Total_BOM_Substrate__c) / (1 - itemFcm.Margin_Less_Substrate_Percent__c/100.0) + itemFcm.Total_BOM_Substrate__c * (1 + itemFcm.Substrate_Markup_Percent__c/100);
		itemFcm.Margin_Percent__c = (itemFcm.Total_Price__c == 0) ? 0 : (itemFcm.Total_Price__c - itemFcm.Total_Cost_of_Goods__c)/itemFcm.Total_Price__c * 100;
		itemFcm.VAM_Percent__c = (itemFcm.Total_Price__c - itemFcm.Total_Material_Cost__c == 0) ? 0 : (itemFcm.Total_Price__c - itemFcm.Total_Cost_of_Goods__c) / (itemFcm.Total_Price__c - itemFcm.Total_Material_Cost__c);
		//update itemFcm;					//---Update the top level item  
	}

	//recalculate the % GM and % Delta fields on the RFQI when the BU Price has been manually updated
	protected override void recalcSummaryWithCostModel()
	{
		debug.log('fcBuilder.recalcSummaryWithCostModel');
		itemFcm.Sales_Target__c = fcmBridge.getDecimal(fcmBridge.wrapper.specificRfqItem, 'Sales_Target_Price__c', 0.0);
		if (itemFcm.Sales_Target__c == 0.0) itemFcm.Sales_Target__c = fcmBridge.getDecimal(fcmBridge.wrapper.specificRfqItem, 'Customer_Target_Price__c', 0.0);

		getMarginPercent(itemFcm);
		itemFcm.Substrate_Markup_Percent__c = fcmBridge.getSubstrateMarkup();
		itemFcm.Total_Price__c = (itemFcm.CLAM__c + itemFcm.Total_Material_Cost__c - itemFcm.Total_BOM_Substrate__c) / (1 - itemFcm.Margin_Less_Substrate_Percent__c/100.0) + itemFcm.Total_BOM_Substrate__c * (1 + itemFcm.Substrate_Markup_Percent__c/100);
		itemFcm.Margin_Percent__c = (itemFcm.Total_Price__c - itemFcm.Total_Cost_of_Goods__c)/itemFcm.Total_Price__c * 100;
		itemFcm.VAM_Percent__c = (itemFcm.Total_Price__c - itemFcm.Total_Cost_of_Goods__c) / (itemFcm.Total_Price__c - itemFcm.Total_Material_Cost__c);
		system.debug('itemFcm : '+itemFcm);
		update itemFcm;
	}

	private String getSpecificRfqType(RFQItemWrapper wrapper){
		
		Schema.SObjectType type = wrapper.specificRfqItem.getsObjectType();
		Schema.DescribeSObjectResult result = type.getDescribe();
		return result.getLabel();

	}

	public override void onAttributeChange(RFQItemWrapper itemWrapper, String attributeName)
	{
		fcmBridge.wrapper = itemWrapper;
		if(attributeName == 'BU_Price__c') 
		{
		    system.debug('onAttributeChange calls : ');
		    recalcSummaryWithoutCostModel();
		}    
	}

	public override void setEditabilityforNoCostModel(RFQILayout layout){


		layout.changeEditability('Total_Cost_with_Substrate_New__c',false);
		layout.changeEditability('Total_Perc_GM__c',false);
	}

	protected override void getMarginPercent(RFQI_FCM__c itemFcm)
	{
		try 
		{
			itemFcm.Margin_Less_Substrate_Percent__c = getDecimal(fcmBridge.wrapper.specificRfqItem, 'Assembly_GM_wo_Substrate__c', 0.0);
		} 
		catch (Exception e) 
		{
			debug.log('Error in getMarginPercent', e);
		}
	}

	public override Map<String, String> getFieldMap()
    {
    	Map<String, String> fieldMap = new Map<String, String>();

    	fieldMap.put('price', 'BU_Price__c');
    	fieldMap.put('margin', 'Total_Perc_GM__c');
    	fieldMap.put('totalCost', 'Total_Cost_with_Substrate_New__c');
		//fieldMap.put('subsMarkup', 'Subs_Markup_Perc__c');
		//fieldMap.put('subsCost', 'Materials_Substrate__c');
		fieldMap.put('marginNoSubstrate', 'Assembly_GM_wo_Substrate__c');
    	//fieldMap.put('othersCost', 'Others_Cost__c');

		return fieldMap;
    }
}