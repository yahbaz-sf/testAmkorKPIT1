/*************************************************************************
*
* PURPOSE: 
*
* CLASS: 
* CREATED: 5/13/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Steve Simpson
***************************************************************************/
public abstract class CMProcessCalcBase 
{
	public CMFCMBridgeBase fcmBridge {get; set;}
	
	public DebugUtils debug {get {return DebugUtils.getInstance();} }
	
	//---Round up function
	/*
	public Double roundUp(Double inputVal)
	{
		Decimal tempVal = (inputVal == null) ? 0 : Decimal.valueOf(inputVal);
		return Double.valueOf(tempVal.setScale(0));
	}
	*/
	//---Round up function ( in excel sheet, the formula is ROUNDUP(D1,0.1), it will round up to Integer)
	public Decimal roundUp(Decimal inputVal)
	{		
		return (inputVal == null) ? 0 : Math.ceil(inputVal);
	}
	
	//---A specific processs was selected, add to the item processs 
	public void add(RFQI_Process__c itemProcess, FCM_Process__c selectedProcess)
	{			
		debug.log('add Process', selectedProcess.Name, false);
		itemProcess.Name = selectedProcess.Name;
		itemProcess.Category__c = selectedProcess.Category__c;
		itemProcess.Machines_Per_Person__c = 0.0;
		itemProcess.Machine_UPH__c = 0.0;
		itemProcess.Machine_Cost_Per_Unit__c = 0.0;
		itemProcess.Footprint_Per_Machine__c = 0.0;
		itemProcess.Utilization_Efficiency__c = 0.0;
		itemProcess.Net_UPH__c = 0.0;
		itemProcess.Standard_HPK__c = 0.0;
		itemProcess.K_Units_Per_Week__c = 0.0;
		itemProcess.Is_Dedicated__c = false;
		itemProcess.Equipment_Needed__c = 0.0;
		itemProcess.Total_Capital__c = 0.0;
		itemProcess.Total_Sqft__c = 0.0;
		itemProcess.People_Needed__c = 0.0;
		itemProcess.Direct_Labor__c = 0.0;
		itemProcess.Indirect_Labor__c = 0.0;
		itemProcess.Equipment_Depreciation__c = 0.0;
		itemProcess.Facilities_Expense__c = 0.0;
		itemProcess.Total_Cost_Per_Unit__c = 0.0;
		itemProcess.Number_Of_Wires__c = fcmBridge.getNumberOfWires();
		itemProcess.Forecast_Volume_Per_Week__c = fcmBridge.getForecastVolumePerWeek();
		itemProcess.Utilization_Efficiency__c = getUtilization(itemProcess); 
		itemProcess.Available_Hours_Per_Week__c = fcmBridge.getAvailHoursPerWeek();
		itemProcess.Is_Dedicated__c = fcmBridge.getIsDedicated();
		itemProcess.Direct_Labor_Rate__c = fcmBridge.getDirectLaborRate();
		itemProcess.Off_Equipment_Direct_To_Direct__c = fcmBridge.getOffEquipmentDirectToDirect();
		itemProcess.Indirect_Labor_Factor__c = fcmBridge.getIndirectLaborFactor();
		itemProcess.Equipment_Life__c = fcmBridge.getEquipmentLifeInYears();
		itemProcess.Work_Weeks_Year__c = fcmBridge.getWorkWeeksPerYear();
		itemProcess.Annual_Fac_Cost_Sqft__c = fcmBridge.getAnnualFacilityCostPerSqft();
		
		if (selectedProcess == null) return;
		
		itemProcess.Equipment__c = selectedProcess.Equipment_Calc__c;
		
		itemProcess.Machines_Per_Person__c = getDecimal(selectedProcess, 'MMR_Calc__c', 0.0);		
		itemProcess.Machine_UPH__c = getDecimal(selectedProcess, 'UPH_Calc__c', 0.0);				
		addCalc(itemProcess, selectedProcess);
		
		itemProcess.Machine_Cost_Per_Unit__c = getDecimal(selectedProcess, 'Equipment_Cost_Calc__c', 0);
		overrideMachineCostPerUnit(itemProcess, selectedProcess);
		itemProcess.Footprint_Per_Machine__c = getDecimal(selectedProcess, 'Footprint_Per_Machine_Calc__c', 0);		
				
		
		itemProcess.Net_UPH__c = itemProcess.Machine_UPH__c * itemProcess.Utilization_Efficiency__c/100.00;
		itemProcess.Standard_HPK__c = itemProcess.Net_UPH__c > 0 ? 1000.00 / itemProcess.Net_UPH__c : 0;
		itemProcess.K_Units_Per_Week__c = itemProcess.Net_UPH__c * itemProcess.Available_Hours_Per_Week__c / 1000.00;

		if (itemProcess.K_Units_Per_Week__c > 0)
		{
			itemProcess.Equipment_Needed__c = itemProcess.Forecast_Volume_Per_Week__c/ itemProcess.K_Units_Per_Week__c;
			if (itemProcess.Is_Dedicated__c) itemProcess.Equipment_Needed__c = roundUp( itemProcess.Equipment_Needed__c); 
		}
		//DebugUtils.write('itemProcess.Name', itemProcess.Name);
		//DebugUtils.write('itemProcess.Forecast_Volume_Per_Week__c', itemProcess.Forecast_Volume_Per_Week__c);
		//DebugUtils.write('itemProcess.K_Units_Per_Week__c', itemProcess.K_Units_Per_Week__c);
		//DebugUtils.write('itemProcess.Equipment_Needed__c', itemProcess.Equipment_Needed__c);

		
		itemProcess.Total_Capital__c = itemProcess.Equipment_Needed__c * itemProcess.Machine_Cost_Per_Unit__c;
		itemProcess.Total_Sqft__c = itemProcess.Footprint_Per_Machine__c * itemProcess.Equipment_Needed__c * 2.5 * 1.5;
			
		if (itemProcess.Machines_Per_Person__c > 0)
		{
			itemProcess.People_Needed__c = 3.0 * itemProcess.Equipment_Needed__c / itemProcess.Machines_Per_Person__c;
			if (itemProcess.Is_Dedicated__c) itemProcess.People_Needed__c = roundUp(itemProcess.People_Needed__c);
			
			itemProcess.Direct_Labor__c = getDirectLabor(itemProcess);
		}
			
		itemProcess.Indirect_Labor__c = itemProcess.Direct_Labor__c * itemProcess.Indirect_Labor_Factor__c;
					
		if (itemProcess.Equipment_Life__c  > 0 && itemProcess.Work_Weeks_Year__c > 0 && itemProcess.Forecast_Volume_Per_Week__c > 0)
		{
			itemProcess.Equipment_Depreciation__c = (itemProcess.Total_Capital__c*1000.00)/itemProcess.Equipment_Life__c /(itemProcess.Work_Weeks_Year__c+2.0)/itemProcess.Forecast_Volume_Per_Week__c/1000.00;
		}
		overrideEquipmentDepreciation(itemProcess);
			
		if (itemProcess.Forecast_Volume_Per_Week__c > 0 && itemProcess.Work_Weeks_Year__c > 0)
		{
			itemProcess.Facilities_Expense__c = itemProcess.Total_Sqft__c * itemProcess.Annual_Fac_Cost_Sqft__c/itemProcess.Work_Weeks_Year__c/itemProcess.Forecast_Volume_Per_Week__c/1000.00;
		}
		


		itemProcess.Total_Cost_Per_Unit__c = itemProcess.Direct_Labor__c + itemProcess.Indirect_Labor__c + itemProcess.Equipment_Depreciation__c + itemProcess.Facilities_Expense__c;
	}

	//---Used for manual calc of Equip Depreciation
	protected virtual void overrideEquipmentDepreciation(RFQI_Process__c itemProcess)
	{
		overrideEquipmentDepreciation(itemProcess, null);
	}

	protected virtual void overrideEquipmentDepreciation(RFQI_Process__c itemProcess, String newForecast)
	{
		//---do nothing at this level, may be overridden at a subclass
	}

	protected virtual void overrideMachineCostPerUnit(RFQI_Process__c itemProcess, FCM_Process__c selectedProcess)
	{
		//---do nothing at this level, may be overridden at a subclass
	}

	protected virtual Decimal getUtilization(RFQI_Process__c itemProcess){
		return fcmBridge.getUtilizationEfficiency(); 
	}

	protected virtual Decimal getUtilization(RFQI_Process__c itemProcess, String newForecast)
	{
		return fcmBridge.getUtilizationEfficiency(newForecast);
	}
	
	protected virtual Decimal getDirectLabor(RFQI_Process__c itemProcess)
	{
		if (itemProcess.Forecast_Volume_Per_Week__c > 0) return (1.0/itemProcess.Machines_Per_Person__c)*itemProcess.Equipment_Needed__c*itemProcess.Available_Hours_Per_Week__c*itemProcess.Direct_Labor_Rate__c*(1.0+itemProcess.Off_Equipment_Direct_To_Direct__c)/(itemProcess.Forecast_Volume_Per_Week__c*1000.00);
		return 0;
	}
	
	protected abstract void addCalc(RFQI_Process__c itemProcess, FCM_Process__c selectedProcess);
	
	
	//---Determine if the Variant is allowed for the current values
	public Boolean shouldAllowVariant(FCM_Process__c row)
	{
		if (row.Package_Family__c != null && fcmBridge.wrapper.packageFamily.id != row.Package_Family__c) return false;
		if (row.Filter_Lead_Count__c != null && !fcmBridge.isLeadCountMatch(row.Filter_Lead_Count__c)) return false;
		if (row.Filter_Factory__c != null && !fcmBridge.isFactoryMatch(row.Filter_Factory__c)) return false;
		return true;	
	}

	public virtual Boolean shouldAllowVariant(FCM_Process__c row, String specificRFQ)
	{
		if(specificRFQ == null)
		{
			return shouldAllowVariant(row);
		}
		if (row.Package_Family__c != null && fcmBridge.wrapper.packageFamily.id != row.Package_Family__c) return false;
		if (row.Filter_Lead_Count__c != null && !fcmBridge.isLeadCountMatch(row.Filter_Lead_Count__c)) return false;
		if (row.Filter_Factory__c != null && !fcmBridge.isFactoryMatch(row.Filter_Factory__c)) return false;
		return true;	
	}
	
	
	
	//---Process to update all the inherited values of all the procs, this is best used for batch imports and data cleanup 
	public static void updateAllProcessCalc()
	{
		List<FCM_Process__c> processList = FCMProcessDao.getInstance().getAll();
		Map<String, FCM_Process__c> processMap = new Map<String, FCM_Process__c>(); 
		for(FCM_Process__c proc : processList) processMap.put(proc.id, proc);
		
		for(FCM_Process__c proc : processList) 
		{			
			if (proc.Parent_Process__c == null)
			{
				updateProcessCalc( proc, null);
			}
			else
			{
				FCM_Process__c parentProcess = processMap.get(proc.Parent_Process__c);
				updateProcessCalc( proc, parentProcess);
			}
		} 
		
		update processList;
	}
	
	//---Update bom fields from self or parent
	public static void updateProcessCalc(FCM_Process__c rec, FCM_Process__c parentRec)
	{
		updateCalcField(rec, parentRec, 'Equipment'); 
		updateCalcField(rec, parentRec, 'Footprint_Per_Machine'); 
		updateCalcField(rec, parentRec, 'MMR'); 
		updateCalcField(rec, parentRec, 'Equipment_Cost'); 
		updateCalcField(rec, parentRec, 'Time_Per_Wire');
		updateCalcField(rec, parentRec, 'Index');
		updateCalcField(rec, parentRec, 'UPH');
		updateCalcField(rec, parentRec, 'Factory_UPH');
		updateCalcField(rec, parentRec, 'UPH_Exponent');
		
	}
	
	//---Update the Calc fields from either self or parent
	private static void updateCalcField(FCM_Process__c rec, FCM_Process__c parentRec, String fieldBaseName)
	{
		String sourceName = fieldBaseName + '__c';
		String orName = fieldBaseName + '_OR__c';
		String calcName = fieldBaseName + '_Calc__c';
		
		Boolean isOR = (Boolean)rec.get(orName);
		
		if (isOR != null && isOR == true)
		{
			rec.put(calcName, rec.get(sourceName));
		}
		else
		{
			if (parentRec == null)
			{
				rec.put(calcName, null);
			}
			else
			{
				rec.put(calcName, parentRec.get(sourceName));
			}
		}
	}
	
	//update fields on process when forecast is different, AMK-1447
	public String updateProcFieldsForVolume(RFQI_Process__c itemProcess, String newForecast)
	{
		String debug = '';
		itemProcess.Number_Of_Wires__c = fcmBridge.getNumberOfWires();
		itemProcess.Forecast_Volume_Per_Week__c = fcmBridge.getForecastVolumePerWeek(newForecast);
		itemProcess.Utilization_Efficiency__c = getUtilization(itemProcess, newForecast); 
		itemProcess.Available_Hours_Per_Week__c = fcmBridge.getAvailHoursPerWeek();
		itemProcess.Is_Dedicated__c = fcmBridge.getIsDedicated();
		itemProcess.Direct_Labor_Rate__c = fcmBridge.getDirectLaborRate();
		itemProcess.Off_Equipment_Direct_To_Direct__c = fcmBridge.getOffEquipmentDirectToDirect();
		itemProcess.Indirect_Labor_Factor__c = fcmBridge.getIndirectLaborFactor(newForecast);
		itemProcess.Equipment_Life__c = fcmBridge.getEquipmentLifeInYears();
		itemProcess.Work_Weeks_Year__c = fcmBridge.getWorkWeeksPerYear();
		itemProcess.Annual_Fac_Cost_Sqft__c = fcmBridge.getAnnualFacilityCostPerSqft();


		itemProcess.Net_UPH__c = itemProcess.Machine_UPH__c * itemProcess.Utilization_Efficiency__c/100.00;
		itemProcess.Standard_HPK__c = itemProcess.Net_UPH__c > 0 ? 1000.00 / itemProcess.Net_UPH__c : 0;
		itemProcess.K_Units_Per_Week__c = itemProcess.Net_UPH__c * itemProcess.Available_Hours_Per_Week__c / 1000.00;

		if (itemProcess.K_Units_Per_Week__c > 0)
		{
			itemProcess.Equipment_Needed__c = itemProcess.Forecast_Volume_Per_Week__c/ itemProcess.K_Units_Per_Week__c;
			if (itemProcess.Is_Dedicated__c) itemProcess.Equipment_Needed__c = roundUp( itemProcess.Equipment_Needed__c); 
		}
		
		itemProcess.Total_Capital__c = itemProcess.Equipment_Needed__c * itemProcess.Machine_Cost_Per_Unit__c;
		itemProcess.Total_Sqft__c = itemProcess.Footprint_Per_Machine__c * itemProcess.Equipment_Needed__c * 2.5 * 1.5;
			
		if (itemProcess.Machines_Per_Person__c > 0)
		{
			itemProcess.People_Needed__c = 3.0 * itemProcess.Equipment_Needed__c / itemProcess.Machines_Per_Person__c;
			if (itemProcess.Is_Dedicated__c) itemProcess.People_Needed__c = roundUp(itemProcess.People_Needed__c);
			
			itemProcess.Direct_Labor__c = getDirectLabor(itemProcess);
		}
			
		itemProcess.Indirect_Labor__c = itemProcess.Direct_Labor__c * itemProcess.Indirect_Labor_Factor__c;
					
		if (itemProcess.Equipment_Life__c  > 0 && itemProcess.Work_Weeks_Year__c > 0 && itemProcess.Forecast_Volume_Per_Week__c > 0)
		{
			itemProcess.Equipment_Depreciation__c = (itemProcess.Total_Capital__c*1000.00)/itemProcess.Equipment_Life__c /(itemProcess.Work_Weeks_Year__c+2.0)/itemProcess.Forecast_Volume_Per_Week__c/1000.00;
		}
		overrideEquipmentDepreciation(itemProcess, newForecast);
			
		if (itemProcess.Forecast_Volume_Per_Week__c > 0 && itemProcess.Work_Weeks_Year__c > 0)
		{
			itemProcess.Facilities_Expense__c = itemProcess.Total_Sqft__c * itemProcess.Annual_Fac_Cost_Sqft__c/itemProcess.Work_Weeks_Year__c/itemProcess.Forecast_Volume_Per_Week__c/1000.00;
		}

		itemProcess.Total_Cost_Per_Unit__c = itemProcess.Direct_Labor__c + itemProcess.Indirect_Labor__c + itemProcess.Equipment_Depreciation__c + itemProcess.Facilities_Expense__c;
		//debug += '###itemProcess.Name: ' + itemProcess.Name;
		//debug += '###itemProcess.Indirect_Labor_Factor__c: ' + itemProcess.Indirect_Labor_Factor__c;
		//debug += '###itemProcess.Direct_Labor__c: ' + itemProcess.Direct_Labor__c;
		//debug += '###itemProcess.Indirect_Labor__c: ' + itemProcess.Indirect_Labor__c;
		//debug += '###itemProcess.Equipment_Depreciation__c: ' + itemProcess.Equipment_Depreciation__c;
		//debug += '###itemProcess.Facilities_Expense__c: ' + itemProcess.Facilities_Expense__c;
		//debug += '###itemProcess.Total_Cost_Per_Unit__c: ' + itemProcess.Total_Cost_Per_Unit__c;
		return debug;
	}

	public Decimal getDecimal(sObject obj, String fieldName, Decimal defVal) 
	{
		if(obj.get(fieldName) == null) return defVal;
        return Decimal.valueOf(String.valueOf(obj.get(fieldName)));
			
	}
}