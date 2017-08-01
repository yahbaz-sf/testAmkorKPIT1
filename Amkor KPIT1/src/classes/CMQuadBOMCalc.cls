/*************************************************************************
*
* PURPOSE: 
*
* CLASS: 
* CREATED: 5/13/2013 Ethos Solutions - www.ethos.com 
* AUTHOR: Steve Simpson
***************************************************************************/
public with sharing class CMQuadBOMCalc extends CMBOMCalcBase 
{
	protected override void addCalc(RFQI_BOM__c itemBom, FCM_BOM__c selectedBom)
	{
		if (selectedBom.Category__c == 'Quad-Au')
		{
			//---TODO, convert to standard Au
			Decimal auBase = fcmBridge.getAuCost();
			Decimal umStd = 0.095944;
			Double wireDiameter = fcmBridge.getWireDiameter(); // pow cannot accept decimal
			Decimal procAdder = getDecimal(selectedBom, 'Cost_Per_Unit_Calc__c', 0);
			
			itemBom.Purchase_Price__c = (auBase * umStd * Math.pow(wireDiameter, 2) + procAdder) / 1000.00;
			itemBom.Standard_Usage__c = UnitUtils.getInstance().convert(getDecimal(itemBom, 'Total_3D_Wire_Length__c', 0), UnitUtils.UNIT_MM, UnitUtils.Unit_FT); 
			itemBom.Usage_Rate__c = getDecimal(selectedBom, 'Usage_Rate_Calc__c', 0);		
			
			if(itemBom.Cum_Yield_Percent__c > 0) 
			{
				itemBom.Material_Cost_Per_Unit__c = getDecimal(itemBom, 'Purchase_Price__c', 0) * getDecimal(itemBom, 'Usage_Rate__c', 0) * getDecimal(itemBom, 'Standard_Usage__c', 0 ) * 100.00 / getDecimal(itemBom, 'Cum_Yield_Percent__c', 0 );
			}
			else
			{
				itemBom.Material_Cost_Per_Unit__c = 0.00;
			}
			
		}
		else if (selectedBom.Category__c == 'Quad-Wire')
		{
			addCalcStandardWire(itemBom, selectedBom);					
		}
		else if (selectedBom.Category__c == 'Quad-MC')
		{
			itemBom.Purchase_Price__c = getDecimal(selectedBom, 'Purchase_Price_Calc__c', 0);	
			itemBom.Standard_Usage__c = getDecimal(selectedBom, 'Standard_Usage_Calc__c', 0);				
			itemBom.Usage_Rate__c = getDecimal(selectedBom, 'Usage_Rate_Calc__c', 0);
			
			if(itemBom.Cum_Yield_Percent__c > 0 )
				itemBom.Material_Cost_Per_Unit__c = getDecimal(itemBom, 'Purchase_Price__c', 0) * getDecimal(itemBom, 'Usage_Rate__c', 0) * getDecimal(itemBom, 'Standard_Usage__c', 0)/ (getDecimal(itemBom, 'Cum_Yield_Percent__c', 0) * 10);
			else
				itemBom.Material_Cost_Per_Unit__c = 0.00;
		}
		else if (selectedBom.Category__c == 'Quad-EP')
		{
			itemBom.Purchase_Price__c = getDecimal(selectedBom, 'Purchase_Price_Calc__c', 0);
			itemBom.Standard_Usage__c = UnitUtils.getInstance().convert(fcmBridge.getDieX() * fcmBridge.getDieY() / 10, UnitUtils.UNIT_MIL, UnitUtils.UNIT_MM);			
			itemBom.Usage_Rate__c = getDecimal(selectedBom, 'Usage_Rate_Calc__c', 0);	
			if(itemBom.Cum_Yield_Percent__c > 0 ) 
			{
				itemBom.Material_Cost_Per_Unit__c = getDecimal(itemBom, 'Purchase_Price__c', 0) * getDecimal(itemBom, 'Usage_Rate__c', 0) * getDecimal(itemBom, 'Standard_Usage__c', 0)/ (getDecimal(itemBom, 'Cum_Yield_Percent__c', 0));
			}
			else
			{
				itemBom.Material_Cost_Per_Unit__c = 0.00;
			}
		}
		else if(selectedBom.Category__c == 'Leadframe')
		{
			//no math is needed here to get base price, as we have costs based on body size per the spreadsheet in AMK-914
			itemBom.Purchase_Price__c = getDecimal(selectedBom, 'Purchase_Price_Calc__c', 0);
			Decimal baseCost = itemBom.Purchase_Price__c;
			Decimal epadAdder = 0;
			Decimal PPFAdder = 0;

			if (fcmBridge.wrapper.specificRfqItem.get('Leadframe_Config__c') != null && (String)fcmBridge.wrapper.specificRfqItem.get('Leadframe_Config__c') == 'epad')
			{
				epadAdder = baseCost * 0.02;
			}
			if ( fcmBridge.wrapper.specificRfqItem.get('Leadframe_Finish__c') != null && ((String)fcmBridge.wrapper.specificRfqItem.get('Leadframe_Finish__c')).contains('PPF'))
			{
				PPFAdder = baseCost * 0.05;
			}
			
			itemBom.Material_Cost_Per_Unit__c = baseCost + epadAdder + PPFAdder;
		}
	}
}