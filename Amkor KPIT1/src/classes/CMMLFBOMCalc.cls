/*************************************************************************
*
* PURPOSE: 
*
* CLASS: 
* CREATED: 5/13/2013 Ethos Solutions - www.ethos.com 
* AUTHOR: Steve Simpson 
***************************************************************************/
public with sharing class CMMLFBOMCalc extends CMBOMCalcBase
{
	public CMMLFBridge mlfBridge {get{return (CMMLFBridge)fcmBridge;}}
	
	public override Boolean shouldAllowVariant(FCM_Bom__c row, String pfSubClass1)
	{
		if(pfSubClass1 == null)
		{
			return shouldAllowVariant(row);
		}

		if (row.Package_Family__c != null){
			if(pfSubClass1.compareTo(mlfBridge.getPF_Sub_Class_1()) != 0 ){							
				return false;
			}			
		}		
		if (row.Filter_Lead_Count__c != null && !fcmBridge.isLeadCountMatch(row.Filter_Lead_Count__c)) return false;
		return true;	
	}

	
		
	
	
	
	protected override void addCalc(RFQI_BOM__c itemBom, FCM_BOM__c selectedBom)
	{
		Decimal unitsPerStrip = mlfBridge.getUnitsPerStrip();
		Decimal stdWires = mlfBridge.getNumStandardWires();
		Decimal RSSBWires = mlfBridge.getRSSBWires();
		Decimal SSBWires = mlfBridge.getNumSSBWires();		
		 
		if(mlfBridge.getPF_Sub_Class_1() == null) return;
		

		//System.debug(LoggingLevel.ERROR, '##### start loadAction');
		
		if (mlfBridge.getPF_Sub_Class_1().compareTo('PMLF') == 0)		
		{
			
			if (selectedBom.Name == 'Leadframe')
			{					
				itemBom.Purchase_Price__c = unitsPerStrip == 0 ? 0 : mlfBridge.getSubstrateCostPerStrip()/unitsPerStrip;

			}
			if (selectedBom.Name == 'Epoxy')
			{
				Decimal total = ((mlfBridge.getDieX()/Decimal.valueOf(10))*(mlfBridge.getDieY()/Decimal.valueOf(10))*0.0025*Decimal.valueOf(1000));				
				itemBom.Standard_Usage__c = total;
			}
			
			if (selectedBom.Name == 'Mold Compound')
			{				
												
				itemBom.Standard_Usage__c = (unitsPerstrip == 0) ? 0 : mlfBridge.getEMCShot()/unitsPerStrip/2 ;				
			}
			if (selectedBom.Name == 'Tray')
			{
				itemBom.Material_Cost_Per_Unit__c =  itemBom.Standard_Usage__c * itemBom.Usage_Rate__c * (itemBom.Cum_Yield_Percent__c/100.0 );
				//System.debug(LoggingLevel.ERROR, '###### ' + selectedBom.Name + ' : ' + itemBom.Material_Cost_Per_Unit__c);
				return;
				
			}
			if (selectedBom.Name == 'Forming Gas')
			{				
				
				itemBom.Standard_Usage__c  =  (stdWires != 0 || RSSBWires != 0 || SSBWires != 0)  ? 3600.0 / (stdWires * 0.199 + RSSBWires * 0.222 + 0.259 * SSBWires) * 0.6/100000.0 : 0 ;
				
				//Check if they have PCC wire
				//Lalit SF-85
				Boolean hasPCCWire = mlfBridge.hasWireMaterial('AuPCC');				        		
				itemBom.Material_Cost_Per_Unit__c = hasPCCWire ? itemBom.Standard_Usage__c * itemBom.Usage_Rate__c * itemBom.Cum_Yield_Percent__c / 100.0 : 0.0;				
								

				return;				
			} 
		}
		if (mlfBridge.getPF_Sub_Class_1().compareTo('SMLF') == 0)		
		{
			if (selectedBom.Name == 'Leadframe')
			{				
				itemBom.Purchase_Price__c = unitsPerStrip == 0 ? 0 : mlfBridge.getSubstrateCostPerStrip()/unitsPerStrip;				
			}
			if (selectedBom.Name == 'Epoxy')
			{
				Decimal total = ((mlfBridge.getDieX()/10)*(mlfBridge.getDieY()/10)*2.54);				
				itemBom.Standard_Usage__c = total;
			}
			
			if (selectedBom.Name == 'Mold Compound')
			{				
				itemBom.Standard_Usage__c = mlfBridge.getBodySize()*mlfBridge.getBodySize()*0.85*0.7*1.95/1000.0/0.5;
			}
			if (selectedBom.Name == 'Mold Flash Tapes')
			{
				itemBom.Standard_Usage__c = unitsPerStrip == 0 ? 0 : 1000/unitsPerStrip;
			}
			if (selectedBom.Name == 'Saw Tape')
			{				
				itemBom.Standard_Usage__c = 1.0/656.0/2.0;

				itemBom.Material_Cost_Per_Unit__c = (itemBom.Cum_Yield_Percent__c > 0 && unitsPerStrip > 0) ? itemBom.Purchase_Price__c *  itemBom.Standard_Usage__c * itemBom.Usage_Rate__c / (itemBom.Cum_Yield_Percent__c/100.0 * unitsPerStrip) : 0;				
				//System.debug(LoggingLevel.ERROR, '###### ' + selectedBom.Name + ' : ' + itemBom.Material_Cost_Per_Unit__c);
				return;
			}
			if (selectedBom.Name == 'Saw Blade')
			{				
				//itemBom.Purchase_Price__c = 45.000;
				//itemBom.Standard_Usage__c = 99120.1922563418; 				
				itemBom.Material_Cost_Per_Unit__c = itemBom.Cum_Yield_Percent__c > 0 ? itemBom.Purchase_Price__c / itemBom.Standard_Usage__c * itemBom.Usage_Rate__c *  (itemBom.Cum_Yield_Percent__c/100.0) : 0;	
				//System.debug(LoggingLevel.ERROR, '###### ' + selectedBom.Name + ' : ' + itemBom.Material_Cost_Per_Unit__c);
				return;
			}
			if (selectedBom.Name == 'Tray')
			{
				
				itemBom.Material_Cost_Per_Unit__c = itemBom.Cum_Yield_Percent__c > 0 ? itemBom.Purchase_Price__c *  itemBom.Standard_Usage__c * itemBom.Usage_Rate__c / (itemBom.Cum_Yield_Percent__c/100.0 ) : 0;
				//System.debug(LoggingLevel.ERROR, '###### ' + selectedBom.Name + ' : ' + itemBom.Material_Cost_Per_Unit__c);
				return;
			}
		}


        //Lalit SF-85
		if (selectedBom.Name.contains('AuPCC'))
		{
			String wireMaterial = mlfBridge.getWireFieldValue('Wire_Material__c');
			//Lalit SF-85.
			if (wireMaterial != null && wireMaterial == 'AuPCC')
			{									
				addCalcStandardWire(itemBOm, selectedBom);
			}
			//System.debug(LoggingLevel.ERROR, '###### ' + selectedBom.Name + ' : ' + itemBom.Material_Cost_Per_Unit__c);			
			return;
		}
		
		if (selectedBom.Name.contains('Au'))
		{
			String wireMaterial = mlfBridge.getWireFieldValue('Wire_Material__c');
			
			if (wireMaterial != null && wireMaterial == 'Au')
			{					
				addCalcAuWire(itemBom, selectedBom);
			}		
			//System.debug(LoggingLevel.ERROR, '###### ' + selectedBom.Name + ' : ' + itemBom.Material_Cost_Per_Unit__c);	
			return;
		}
		
		
		itemBom.Material_Cost_Per_Unit__c = itemBom.Cum_Yield_Percent__c > 0 ? itemBom.Purchase_Price__c *  itemBom.Standard_Usage__c * itemBom.Usage_Rate__c / (itemBom.Cum_Yield_Percent__c/100.0 * 1000.0) : 0;
		//System.debug(LoggingLevel.ERROR, '###### ' + selectedBom.Name + ' : ' + itemBom.Material_Cost_Per_Unit__c);

	}
}