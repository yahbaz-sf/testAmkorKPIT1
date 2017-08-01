/*************************************************************************
*
* PURPOSE: 
*
* CLASS: 
* CREATED: 5/13/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Steve Simpson
***************************************************************************/
public with sharing class CMDualBOMCalc extends CMBOMCalcBase
{
	protected override void addCalc(RFQI_BOM__c itemBom, FCM_BOM__c selectedBom)
	{
		if (selectedBom.Category__c == 'Mold')
		{
			addCalcStandard(itemBom, selectedBom);
		}
		else if (selectedBom.Category__c == 'AuWire')
		{
			addCalcAuWire(itemBom, selectedBom);
		}
		else if (selectedBom.Category__c == 'Wire')
		{
			addCalcStandardWire(itemBom, selectedBom);
		}
		else if (selectedBom.Category__c == 'FormingGas')
		{
			itemBom.Purchase_Price__c = getDecimal(selectedBom, 'Cost_Per_Unit_Calc__c', 0);		
			
			//---Simulate the Wirebond UPH Calc
			Decimal auWireBondUPH = 0;
			Decimal timeFactor = (selectedBom.Time_Per_Wire_Calc__c == null ? 0 : selectedBom.Time_Per_Wire_Calc__c) * fcmBridge.getNumberOfWires() + (selectedBom.Index_Calc__c == null ? 0 : selectedBom.Index_Calc__c);
			
			if (timeFactor > 0) auWireBondUPH = Decimal.valueOf(3600)/timeFactor;
			
			itemBom.Standard_Usage__c = auWireBondUPH * itemBom.Utilization_Efficiency__c/Decimal.valueOf(100);   											
				
			if (itemBom.Standard_Usage__c > 0) itemBom.Usage_Rate__c = Decimal.valueOf(72)/itemBom.Standard_Usage__c;
			itemBom.Material_Cost_Per_Unit__c = itemBom.Cum_Yield_Percent__c > 0 ? itemBom.Purchase_Price__c *  itemBom.Usage_Rate__c / (itemBom.Cum_Yield_Percent__c/Decimal.valueOf(100)) : 0;
		}
		else if (selectedBom.Category__c == 'Leadframe')
		{
			addCalcStandard(itemBom, selectedBom);
		}
		else if (selectedBom.Category__c == 'Standard')
		{
			addCalcStandard(itemBom, selectedBom);
		}
		
		//DebugUtils.getInstance().log('Cost per unit for ' + itemBom.name + ', Category ' + selectedBom.Category__c + ' is ' + itemBom.Material_Cost_Per_Unit__c);
	}
}