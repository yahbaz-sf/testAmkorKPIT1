/*************************************************************************
*
* PURPOSE: 
*
* CLASS: 
* CREATED: 5/01/2013 Ethos Solutions - www.ethos.com 
* AUTHOR: Steve Simpson 
***************************************************************************/
public virtual class CMFCMBridgeBase extends CMBridgeBase
{
	public FCM_Assumption__c fcmA {get; set;}	
	public SObject selectedWire {get; set;}
	public SObject selectedDie {get; set;}
	public SObject selectedPassive {get; set;}
	
	public Integer selectedDiePosition {get; set;}
	
	public virtual override void setup()
	{
		super.setup();
		loadFcmAssumption();
		loadcmPFList();
	}

	//load cmpflist
	protected virtual void loadcmPFList(){}
	
	public virtual void loadFcmAssumption()
	{
		if (fcmA == null)
		{
			List<FCM_Assumption__c> assumptionList = FCMAssumptionDao.getInstance().getByVersion(ver.id);
			if (assumptionList.size() > 0)
			{
				fcmA = assumptionList[0];
			}
			else
			{
				fcmA = new FCM_Assumption__c();
			}
		}
	}
	
	
	//Correct get value by using getDecimal function
	public virtual Decimal getCumYieldPercent()
	{
		return getDecimal(fcmA, 'Cum_Yield_Percent__c', 0); 		
	}

	public virtual Decimal getUtilizationEfficiency()
	{
		return getUtilizationEfficiency((String)wrapper.specificRfqItem.get('Forecast__c'));
	}
	public virtual Decimal getUtilizationEfficiency(String forecastVal)
	{
		//added param because some pfs (e.g. Flip Chip) need forecastVal to calculate this
		return getDecimal(fcmA, 'Utilization_Efficiency_Percent__c', 0.0); 		
	}
	
	public virtual Boolean getIsDedicated()
	{
		return fcmA == null ? false : fcmA.FCM_Is_Dedicated__c; 
		
	}
	
	public virtual Decimal getManufOHToProcessCost()
	{
		return getDecimal(fcmA, 'Manuf_OH_To_Process_Cost__c', 0.0);		
	}
	
	public virtual Decimal getQACostToProcessCost()
	{
		return getDecimal(fcmA, 'QA_Cost_To_Process_Cost__c', 0.0);	
	}
	
	public virtual Decimal getServiceCostToProcessCost()
	{
		return getDecimal(fcmA, 'Service_Cost_To_Process_Cost__c', 0.0);		
	}
	
	public virtual Decimal getAvailHoursPerWeek()
	{
		return getDecimal(fcmA, 'Available_Hours_Per_Week__c', 0.0);		
	}
	
	public virtual Decimal getDirectLaborRate()
	{	
		return getDecimal(fcmA, 'Direct_Labor_Rate__c', 0.0);				
	}
	
	public virtual Decimal getForecastVolumePerWeek()
	{
		return getForecastVolumePerWeek((String)wrapper.specificRfqItem.get('Forecast__c'));
	}
	
	public virtual Decimal getForecastVolumePerWeek( String forecastVal)
	{
		if (forecastVal == '< 50') return 1; 
		else if (forecastVal == '50 - 250') return 51; 
		else if (forecastVal == '250 - 1,000') return 251; 
		else if (forecastVal == '1,000 - 5,000') return 1001; 
		else if (forecastVal == '5,000 - 10,000') return 5001; 
		else if (forecastVal == '> 10,000') return 10001; 
		else if (forecastVal == 'Engineering Builds') return 1000; 
		
		return 1;
	}
	
	public virtual Decimal getOffEquipmentDirectToDirect()
	{
		return getDecimal(fcmA, 'Off_Equipment_Direct_To_Direct__c', 0.0);		
	}
	
	public virtual Decimal getEquipmentLifeInYears()
	{
		return getDecimal(fcmA, 'Equipment_Life__c', 0.0);		
	}
	
	public virtual Decimal getWorkWeeksPerYear()
	{
		return getDecimal(fcmA, 'Work_Weeks_Year__c', 0.0);		
	}
	
	public virtual Decimal getAnnualFacilityCostPerSqft()
	{
		return getDecimal(fcmA, 'Annual_Fac_Cost_Sqft__c', 0.0);
	}
	
	public virtual Decimal getIndirectLaborFactor()
	{
		return getIndirectLaborFactor((String)wrapper.specificRfqItem.get('Forecast__c'));
	}
	public virtual Decimal getIndirectLaborFactor(String forecastVal)
	{
		Decimal volumePerWeek = getForecastVolumePerWeek(forecastVal);
		
		if (fcmA == null) return 0;
		
		if (volumePerWeek < 300)
		{
			return getDecimal(fcmA, 'Forecast_Factor_1__c', 0.0); 
		}
		else if (volumePerWeek > 1000)
		{
			return getDecimal(fcmA, 'Forecast_Factor_3__c', 0.0); 
		}
		return getDecimal(fcmA, 'Forecast_Factor_2__c', 0.0);		
	}
	
	public virtual Decimal getMaterialFreightPercent()
	{
		return getDecimal(fcmA, 'Material_Freight_Percent__c', 0.0);		
	}
	
	public virtual Decimal getMaterialToolingPercent()
	{
		return getDecimal(fcmA, 'Material_Tooling_Percent__c', 0.0);		
	}
	
	public virtual Decimal getMaterialBrokeragePercent()
	{
		return getDecimal(fcmA, 'Material_Brokerage_Percent__c', 0.0);		
	}
	
	public virtual Decimal getAuCost()
	{
		return getDecimal(pg, 'Au_Cost__c', 0.0);		
	}
	
	public virtual Decimal getTotal3DWireLength()
	{		
		return getDecimal(selectedWire, 'Total_3D_Wire_Length__c', 0);			 
	}
	
	public virtual Decimal getNumberOfWires() 
	{		
		return getDecimal(selectedWire, 'Number_Of_Wires__c', 0);		
	}
	
	public virtual Boolean isLeadCountMatch(String inputVal)
	{
		//AMK-2064, saw mlf has different lead count field
		String fieldName = wrapper.productGroup.Name == 'MLF' && (String)wrapper.specificRfqItem.get('PF_Sub_Class_1__c') == 'SMLF' ? 'Lead_Count_Entry__c' : 'Lead_Count__c';
		String itemValue = (String)wrapper.specificRfqItem.get(fieldName);
		return inputVal == itemValue;
	}
	
	public virtual Boolean isFactoryMatch(String factoryId)
	{
		return true;
	}

	
	
	public virtual void writeResults(RFQI_FCM__c itemFcm){		
		writeResults(itemFcm, true);		
	}
	public virtual void writeResults(RFQI_FCM__c itemFcm, Boolean isUpdate)
	{
		
		wrapper.specificRfqItem.put( 'BU_Price_Perc_GM__c', itemFcm.Margin_Percent__c);

		Decimal buPrice = itemFcm.Total_Price__c == null ? 0 : (Decimal)itemFcm.Total_Price__c ;
		wrapper.specificRfqItem.put( 'BU_Price__c', buPrice);
		
		Decimal customerPrice = wrapper.specificRfqItem.get('Price_To_Customer__c') == null ? 0 : (Decimal)wrapper.specificRfqItem.get('Price_To_Customer__c');
		if(customerPrice < buPrice)
			wrapper.specificRfqItem.put('Price_To_Customer__c',buPrice);
		else
			wrapper.specificRfqItem.put('Price_To_Customer__c',customerPrice);
		wrapper.specificRfqItem.put( 'Materials_Subtotal__c', itemFcm.Total_Material_Cost__c);
		wrapper.specificRfqItem.put( 'QA_Cost__c', itemFcm.QA_Cost__c);
		wrapper.specificRfqItem.put( 'Service_Group_Cost__c', itemFcm.Service_Group_Cost__c);
		wrapper.specificRfqItem.put( 'Total_Cost__c', itemFcm.Total_Cost_of_Goods__c);
		wrapper.specificRfqItem.put( 'BU_Price_Perc_Delta_To_Target__c', itemFcm.Delta_to_Target_Percent__c);
		wrapper.specificRfqItem.put( 'Manufacturing_Overhead__c', itemFcm.Manufacturing_Overhead__c);

		wrapper.clearPriceToCustomerIfRequired();

		wrapper.specificRfqItem.put( 'CLAM_Direct_Labor__c', itemFcm.Total_Direct_Labor__c);
		wrapper.specificRfqItem.put( 'CLAM_Indirect_Labor__c', itemFcm.Total_Indirect_Labor__c);
		wrapper.specificRfqItem.put( 'CLAM_Depreciation__c', itemFcm.Total_Equipment_Depreciation__c);
		wrapper.specificRfqItem.put( 'CLAM_Facilities__c', itemFcm.Total_Facilities_Expense__c);

		wrapper.specificRfqItem.put( 'Materials_Leadframe__c', itemFcm.Total_BOM_Leadframe__c);
		wrapper.specificRfqItem.put( 'Materials_ODM__c', itemFcm.Total_BOM_ODM__c);
		wrapper.specificRfqItem.put( 'Materials_Total_Wire__c', itemFcm.Total_BOM_Wire__c);


		//System.debug(LoggingLevel.ERROR, '#### CLAM_Direct_Labor__c: ' + getDecimal(wrapper.specificRfqItem, 'CLAM_Direct_Labor__c', 0) );
		
		Decimal varCost = getDecimal(wrapper.specificRfqItem, 'CLAM_Direct_Labor__c', 0) + 
		getDecimal(itemFcm, 'Manufacturing_Overhead__c', 0) + 
		getDecimal(itemFcm, 'Total_Material_Cost__c', 0); 

		Decimal fixedCost = getDecimal(wrapper.specificRfqItem, 'CLAM_Indirect_Labor__c', 0) +
		getDecimal(wrapper.specificRfqItem, 'CLAM_Depreciation__c', 0) +
		getDecimal(wrapper.specificRfqItem, 'CLAM_Facilities__c', 0) +
		getDecimal(itemFcm, 'QA_Cost__c', 0) +
		getDecimal(itemFcm, 'Service_Group_Cost__c', 0); 	

		calculatePackageItemValue(wrapper, buPrice);

		Decimal materialPct = 0;
		if (itemFcm.Total_Cost_of_Goods__c != null && itemFcm.Total_Cost_of_Goods__c > 0 && itemFcm.Total_Material_Cost__c != null) materialPct = 100 * itemFcm.Total_Material_Cost__c / itemFcm.Total_Cost_of_Goods__c;
		wrapper.specificRfqItem.put( 'Materials_As_Perc_Cost__c', materialPct);
		//wrapper.specificRfqItem.put( 'Materials_Leadframe__c', itemFcm.xxx);
		//wrapper.specificRfqItem.put( 'Materials_ODM__c', itemFcm.xxx);
		//wrapper.specificRfqItem.put( 'Materials_Total_Wire__c', itemFcm.xxx);
		//wrapper.specificRfqItem.put( 'Adder_Cost__c', itemFcm.xxx);
		wrapper.specificRfqItem.put( 'Fixed_Costs__c', fixedCost);
		wrapper.specificRfqItem.put( 'Variable_Costs__c', varCost);
		
		
		if(isUpdate) update wrapper.specificRfqItem;
		
	}
	
	public virtual String getWireFieldValue(String fieldName)
	{
		return selectedWire == null ? '' : (String)selectedWire.get(fieldName);
	}
	
	public virtual String getDieFieldValue(String fieldName)
	{
		return selectedDie == null ? '' : (String)selectedDie.get(fieldName);
	}

	public virtual String getPassiveFieldValue(String fieldName)
	{
		return selectedPassive == null ? '' : (String)selectedPassive.get(fieldName);
	}
	
	public virtual Boolean getPassiveFieldBooleanMatch(String fieldName, Boolean boolVal)
	{
		return selectedPassive == null ? false : (Boolean)selectedPassive.get(fieldName) == boolVal;
	}
	
	public virtual Boolean getWireFieldBooleanMatch(String fieldName, Boolean boolVal)
	{
		return selectedWire == null ? false : (Boolean)selectedWire.get(fieldName) == boolVal;
	}
	
	public virtual Boolean getDieFieldBooleanMatch(String fieldName, Boolean boolVal)
	{
		return selectedDie == null ? false : (Boolean)selectedDie.get(fieldName) == boolVal;
	}
	
	public virtual Decimal getAccountTier()
	{
		//per Peter, accounts default to tier 3 if no Account_PG_Setting
		return getDecimal(acctPgSetting, 'Tier__c', 3.0);		
	}
	
	public virtual List<CM_Margin__c> getMarginList()
	{
		return new List<CM_Margin__c>();
	}
	
	public virtual Decimal getMarginPercent()
	{
		return getMarginPercent((String)wrapper.specificRfqItem.get('Forecast__c'));
	}
	public virtual Decimal getMarginPercent(String forecastVal)
	{
		List<CM_Margin__c> MarginList = getMarginList();
			
		Decimal volume = getForecastVolumePerWeek(forecastVal);
		CM_Margin__c selMargin = null;
		
		if (MarginList != null)
		{
			for(CM_Margin__c row : MarginList)
			{
				Decimal volume_floor = getDecimal(row, 'Volume_Floor__c', 0);
				if (volume_floor <= volume) selMargin = row;
			}
		}
		Decimal retVal = 0;
		if (selMargin != null && selMargin.Margin__c != null) retVal = selMargin.Margin__c;

		//if the margin has a value, set a flag indicating such
		hasAutomaticMargin = retVal > 0;
		return retVal;
	}
	
	public virtual Decimal getCustAuBase()
	{
		return getDecimal(acctPgSetting, 'Au_Base__c', 0.0);		 
	}
	
	public virtual Decimal getWireDiameter()
	{
		return getDecimal(selectedWire, 'Wire_Diameter__c', 0.0);		
	}
	
	public virtual Decimal getDieX()
	{
		return getDecimal(selectedDie, 'Die_Size_X__c', 0.0);				
	}

	public virtual Decimal getDieX(Integer pos){

		try{
			sObject obj =  wrapper.dieConfigurations.get(pos);
			return getDecimal(obj, 'Die_Size_X__c', 0.0);
		}
		catch(Exception e){
			debug.log('getDieX ERROR at position ' + pos, e);
			debug.log('e.getStackTraceString()', e.getStackTraceString());
			return 0.0;
		}		 

	}
	
	public virtual Decimal getDieY(Integer pos){
		try{			
			sObject obj =  wrapper.dieConfigurations.get(pos);
			return getDecimal(obj, 'Die_Size_Y__c', 0.0);
		}
		catch(Exception e){
			debug.log('getDieY ERROR at position ' + pos, e);
			debug.log('e.getStackTraceString()', e.getStackTraceString());
			return 0.0;
		}		 
		
	}

	public virtual Decimal getDieY()
	{
		return getDecimal(selectedDie, 'Die_Size_Y__c', 0.0);				
	}

	public virtual Decimal getDieWaferSize()
    {
    	if (selectedDie == null) selectedDie = wrapper.dieConfigurations.get(0);
        if (selectedDie != null)
        {
        	return getDecimal(selectedDie, 'Wafer_Size__c', 0);        	
        }
        return 0;
    }

    public virtual String getWireMaterial()
    {
    	return (String)selectedWire.get('Wire_Material__c');
    }

    public virtual Decimal getSalesTarget()
    {
    	Decimal target = getDecimal(wrapper.specificRfqItem, 'Sales_Target_Price__c', 0);
    	if (target == 0) getDecimal(wrapper.specificRfqItem, 'Customer_Target_Price__c', 0);
    	return target;
    }

    // public virtual Decimal getUsageRate()
    // {
    	
    // 	return getDecimal(fcmA, 'Usage_Rate__c', 0.0);
    // }

    public virtual void calculatePackageItemValue(RFQItemWrapper itemWrapper, Decimal buPrice)
    {
    	//empty method for now - Quad is the only one that needs this as of AMK-1273
    }

    public virtual Decimal getSubstrateMarkup()
	{
		return 0;
	}


}