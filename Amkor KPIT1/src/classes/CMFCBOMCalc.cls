/*************************************************************************
*
* PURPOSE: Specific BOM calculations for Flip Chip - BGA
*
* CLASS: 
* CREATED: 5/13/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Steve Simpson
***************************************************************************/
public with sharing class CMFCBOMCalc extends CMBOMCalcBase{

	public CMFCBridge fcBridge {get{return (CMFCBridge)fcmBridge;}}

	
	protected override void addCalc(RFQI_BOM__c itemBom, FCM_BOM__c selectedBom)
	{
		debug.log('selectedBom.Category__c', selectedBom.Category__c, false);
		debug.log('selectedBom.Name', selectedBom.Name, false);
		if (selectedBom.Category__c == 'Flux')
		{
			itemBom.Standard_Usage__c = 10 * fcBridge.getNumberOfDies();
		}
		else if (selectedBom.Category__c == 'Paste/Flux')
		{
			itemBom.Standard_Usage__c = fcBridge.getTotalCapacitorStandardUsage();
		}
		else if (selectedBom.Category__c == 'Capacitor')
		{
			itemBom.Standard_Usage__c = fcBridge.getCapacitorStandardUsage();
			itemBom.Purchase_Price__c = fcBridge.getCapacitorPurchasePrice();
		}
		else if (selectedBom.Category__c == 'Substrate')
		{
			itemBom.Purchase_Price__c = fcBridge.getSubstratePurchasePrice();
		}
		else if (selectedBom.Category__c == 'Underfill')
		{
			itemBom.Standard_Usage__c = ((fcBridge.getDieY() * fcBridge.getDieX()) * 0.06) * 2 * getDecimal(selectedBom, 'Standard_Usage_Calc__c', 0);
		}
		else if (selectedBom.Category__c == 'Adhesive')
		{
			itemBom.Standard_Usage__c = (4*fcBridge.getLidFoot()*(fcBridge.getBodySize() - fcBridge.getLidFoot())) * 0.06 * getDecimal(selectedBom, 'Standard_Usage_Calc__c', 0);
		}
		else if (selectedBom.Category__c == 'TIM')
		{
			itemBom.Standard_Usage__c = (fcBridge.getDieY() * fcBridge.getDieX()) * fcBridge.getDAThickness() * 2.2 * getDecimal(selectedBom, 'Standard_Usage_Calc__c', 0);
		}
		else if (selectedBom.Category__c == 'Solder Balls')
		{
			itemBom.Standard_Usage__c = fcBridge.getBallCount();
		}
		else if (selectedBom.Category__c == 'Tray')
		{
			itemBom.Standard_Usage__c = fcBridge.getUnitPerTray();
		}
		else if (selectedBom.Category__c == 'OverMold')
		{
			itemBom.Standard_Usage__c = (fcBridge.getRecommendedPellets() / fcBridge.getUnitsPerPellet() / (1 + fcBridge.getPercWastePerShot())) / fcBridge.getNumberOfDies();
			itemBom.Usage_Rate__c = 1 + fcBridge.getPercWastePerShot();
		}
		else if (selectedBom.Category__c == 'OverMold Softec')
		{
			itemBom.Standard_Usage__c = 1000 / 200 / (getDecimal(selectedBom, 'Standard_Usage_Calc__c', 0) * fcBridge.getOMChase());
		}


		if (selectedBom.Category__c == 'Tray')
		{
			itemBom.Material_Cost_Per_Unit__c = (itemBom.Standard_Usage__c == 0 || itemBom.Cum_Yield_Percent__c == 0) ? 0 : itemBom.Purchase_Price__c / itemBom.Standard_Usage__c * itemBom.Usage_Rate__c / (itemBom.Cum_Yield_Percent__c/100);
		}
		else if (selectedBom.Category__c == 'WBG Tape')
		{
			Decimal gdpw = fcBridge.getDieGDPW();
			itemBom.Material_Cost_Per_Unit__c = (gdpw == 0) ? 0 : (selectedBom.Purchase_Price_Calc__c / gdpw) / fcBridge.getNumberOfDies();
		}
		else 
		{
			itemBom.Material_Cost_Per_Unit__c = (itemBom.Cum_Yield_Percent__c == 0) ? 0 : itemBom.Purchase_Price__c*itemBom.Standard_Usage__c*itemBom.Usage_Rate__c/itemBom.Cum_Yield_Percent__c/10;
			
		}

	}
}