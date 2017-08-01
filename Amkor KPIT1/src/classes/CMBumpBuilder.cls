/*************************************************************************
*
* PURPOSE: Cost Model Engine for Bump package family
*
* CLASS: CMBumpBuilder
* CREATED: 8/15/2012 Ethos Solutions - www.ethos.com
* AUTHOR: Austin Delorme
***************************************************************************/
public virtual with sharing class CMBumpBuilder extends CMBuilder
{
	public CMBumpBuilder()
	{
		bridge = new CMOthersBridge();
	}

	public override void loadSettings(RFQItemWrapper itemWrapper, Boolean isReloaded)
	{}

	public override void onAttributeChange(RFQItemWrapper itemWrapper, String attributeName)
	{
		if(attributeName == 'BU_Price__c') 
		{
		    onBUPriceChanged(itemWrapper);
		} 
		else if (attributeName == 'BU_Price_Perc_GM__c')
		{
		    onBUPricePercGMChanged(itemWrapper);
		}                      
		
	}

	public void onBUPriceChanged(RFQItemWrapper itemWrapper)
	{
		Decimal buPrice = getDecimal(itemWrapper.specificRfqItem, 'BU_Price__c', 0.0);
		if(buPrice > 0.0)
		{
			Decimal salesTargetPrice = getDecimal(itemWrapper.specificRfqItem, 'Sales_Target_Price__c',0.0) == 0.0 ? getDecimal(itemWrapper.specificRfqItem, 'Customer_Target_Price__c', 0.0) : getDecimal(itemWrapper.specificRfqItem, 'Sales_Target_Price__c',0.0);
			Decimal totalCost = getDecimal(itemWrapper.specificRfqItem, 'Total_Cost__c', 0.0);
			Decimal totalVar =  getDecimal(itemWrapper.specificRfqItem, 'Variable_Costs_Total__c', 0.0);

			Decimal delta = (salesTargetPrice == 0.0) ? 0.0 : (buPrice - salesTargetPrice)/salesTargetPrice;                                     
			Decimal margin = (buPrice - totalCost)/buPrice;
			Decimal contMargin = (buPrice - totalVar)/buPrice;

			itemWrapper.specificRfqItem.put('BU_Margin__c', margin * 100.0);
			itemWrapper.specificRfqItem.put('Contribution_Margin_Perc__c', contMargin * 100.0);
		}
		else
		{
			String err = 'BU Price must be greater than 0. <br /> Please re-enter BU price. ';
    		addError(err);
		}
	}

	public void onBUPricePercGMChanged(RFQItemWrapper itemWrapper)
	{
		Decimal margin = getDecimal(itemWrapper.specificRfqItem, 'BU_Margin__c', 0.0)/100.0;
		if(1-margin > 0.0)
		{        
			Decimal salesTargetPrice = getDecimal(itemWrapper.specificRfqItem, 'Sales_Target_Price__c',0.0) == 0.0 ? getDecimal(itemWrapper.specificRfqItem, 'Customer_Target_Price__c', 0.0) : getDecimal(itemWrapper.specificRfqItem, 'Sales_Target_Price__c',0.0);        
			Decimal totalCost = getDecimal(itemWrapper.specificRfqItem, 'Total_Cost__c', 0.0);
			Decimal totalVar =  getDecimal(itemWrapper.specificRfqItem, 'Variable_Costs_Total__c', 0.0);

			Decimal buPrice = totalCost / (1 - margin);            
			Decimal delta = (salesTargetPrice != 0.0) ? (buPrice - salesTargetPrice)/salesTargetPrice : 0.0;
			Decimal contMargin = (buPrice - totalVar)/buPrice;

			itemWrapper.specificRfqItem.put('BU_Price__c',buPrice);
			itemWrapper.specificRfqItem.put('Contribution_Margin_Perc__c', contMargin * 100.0);
		}
		else
		{
			String err = 'Margin cannot be greater than or equal to 100. <br /> Please re-enter margin.';
			addError(err);
		}
	}

	
	public override void setEditabilityforNoCostModel(RFQILayout layout)
	{
		layout.changeEditability('Variable_Costs_Total__c',false);
		layout.changeEditability('Total_Fixed_Costs__c',false);
		layout.changeEditability('Total_Cost__c',false);
		layout.changeEditability('Customer_Target_Price__c',false);
		layout.changeEditability('Contribution_Margin_Perc__c',false);
		layout.changeEditability('Sales_Target_Price__c',false);
	}

	protected override void calcCostModel(RFQItemWrapper itemWrapper)
	{}
	

	protected override void calcResults(RFQItemWrapper itemWrapper, Boolean runCostModel)
	{


		Decimal materials = getDecimal(itemWrapper.specificRfqItem, 'Materials_Total__c', 0.0);
		Decimal otherVar = getDecimal(itemWrapper.specificRfqItem, 'Variable_Costs__c', 0.0);
		Decimal depreciation = getDecimal(itemWrapper.specificRfqItem, 'Depreciation__c', 0.0);
		Decimal otherFixed = getDecimal(itemWrapper.specificRfqItem, 'Fixed_Costs__c', 0.0);
		Decimal margin = getDecimal(itemWrapper.specificRfqItem, 'BU_Margin__c', 0.0) / 100;

		Decimal totalVar = materials + otherVar;
		Decimal totalFixed = depreciation + otherFixed;

		Decimal total = totalFixed + totalVar;
		Decimal buPrice = margin == 1 ? 0 : total/(1 - margin);

		Decimal grossMargin = (buPrice == 0) ? 0 : (buPrice - total)/buPrice * 100;

		Decimal contributionMargin = (buPrice == 0) ? 0 : (buPrice - totalVar)/buPrice * 100;

		itemWrapper.specificRfqItem.put('Variable_Costs_Total__c', totalVar);
		itemWrapper.specificRfqItem.put('Contribution_Margin_Perc__c', contributionMargin);
		itemWrapper.specificRfqItem.put('Total_Fixed_Costs__c', totalFixed);
		itemWrapper.specificRfqItem.put('Total_Cost__c', total);
		itemWrapper.specificRfqItem.put('BU_Price__c', buPrice);
	}

	public virtual Decimal getMeanForecast(String forecast)
	{
		return 0;
	}

    public override Map<String, String> getFieldMap()
    {
    	Map<String, String> fieldMap = new Map<String, String>();

    	fieldMap.put('price', 'BU_Price__c');
    	fieldMap.put('margin', 'BU_Margin__c');
    	fieldMap.put('totalCost', 'Total_Cost__c');

		return fieldMap;
    }
	
}