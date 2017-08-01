public abstract class CMBOMCalcBase 
{
	public CMFCMBridgeBase fcmBridge {get; set;}

	public DebugUtils debug {get {return DebugUtils.getInstance();} }
	
	//---Round up function
	public Double roundUp(Double inputVal)
	{
		Decimal tempVal = (inputVal == null) ? 0 : Decimal.valueOf(inputVal);
		return Double.valueOf(tempVal.setScale(0));
	}
	
	//---Round up function
	public Decimal roundUp(Decimal inputVal)
	{
		Decimal tempVal = (inputVal == null) ? 0 : inputVal;
		return tempVal.setScale(0);
	}
	
	//---A specific bom was selected, add to the item bom 
	public void add(RFQI_BOM__c itemBom, FCM_BOM__c selectedBom)
	{

		
		if (itemBom.Total_3D_Wire_Length__c == null) itemBom.Total_3D_Wire_Length__c = 0;
		
		if (selectedBom == null) return;
		
		itemBom.name = selectedBom.name;
		itemBom.Group__c = selectedBom.Group_Calc__c;
		itemBom.Description__c = selectedBom.Description_Calc__c;
		itemBom.SID__c = selectedBom.SID_Calc__c;
		itemBom.UOM__c = selectedBom.UOM_Calc__c == null ? '' : selectedBom.UOM_Calc__c;


		itemBom.Purchase_Price__c = getDecimal(selectedBom, 'Purchase_Price_Calc__c', 0);
		itemBom.Standard_Usage__c = getDecimal(selectedBom, 'Standard_Usage_Calc__c', 0);
		
		itemBom.Usage_Rate__c = getDecimal(selectedBom, 'Usage_Rate_Calc__c', 0);		
		itemBom.SID__c = '';
		itemBom.Cum_Yield_Percent__c = fcmBridge.getCumYieldPercent();
		
		itemBom.Au_Cost__c = fcmBridge.getAuCost();		
		itemBom.Total_3D_Wire_Length__c = fcmBridge.getTotal3DWireLength();
		itemBom.Utilization_Efficiency__c = fcmBridge.getUtilizationEfficiency();

		itemBom.Material_Cost_Per_Unit__c = 0;
		addCalc(itemBom, selectedBom);
	} 
	
	protected abstract void addCalc(RFQI_BOM__c itemBom, FCM_BOM__c selectedBom);
	
	
	protected void addCalcStandardWire(RFQI_BOM__c itemBom, FCM_BOM__c selectedBom)
	{
		//we cannot just get value from the object because it is double. All value should be called from getDecimal method.
		itemBom.Purchase_Price__c = getDecimal(selectedBom, 'Purchase_Price_Calc__c', 0);		

		itemBom.Standard_Usage__c = UnitUtils.getInstance().convert(getDecimal(itemBom, 'Total_3D_Wire_Length__c', 0), UnitUtils.UNIT_MM, UnitUtils.UNIT_FT);
		itemBom.Usage_Rate__c = getDecimal(selectedBom, 'Usage_Rate_Calc__c', 0);


		// System.debug(LoggingLevel.ERROR, '#### PCC Total_3D_Wire_Length__c is ' + getDecimal(itemBom, 'Total_3D_Wire_Length__c', 0));
		// System.debug(LoggingLevel.ERROR, '#### PCC Purchase price is ' + itemBom.Purchase_Price__c);
		// System.debug(LoggingLevel.ERROR, '#### PCC Std Usage is ' + itemBom.Standard_Usage__c);
		// System.debug(LoggingLevel.ERROR, '#### PCC Usage rate is ' + itemBom.Usage_Rate__c);
		// System.debug(LoggingLevel.ERROR, '#### PCC Cum Yield is ' + itemBom.Cum_Yield_Percent__c);
		
		if(itemBom.Cum_Yield_Percent__c > 0 )
			itemBom.Material_Cost_Per_Unit__c = itemBom.Purchase_Price__c * itemBom.Usage_Rate__c * itemBom.Standard_Usage__c * 100.00 / getDecimal(itemBom, 'Cum_Yield_Percent__c', 0);
		else
			itemBom.Material_Cost_Per_Unit__c = 0.00;			
	}
	
	protected void addCalcAuWire(RFQI_BOM__c itemBom, FCM_BOM__c selectedBom)
	{
		itemBom.Purchase_Price__c = (getDecimal(selectedBom, 'Troy_Oz_Cost_Calc__c', 0) * getDecimal(itemBom, 'Au_Cost__c', 0) + getDecimal(selectedBom, 'Mfg_Cost_Calc__c', 0)) / 1000.00;
		
		itemBom.Standard_Usage__c = UnitUtils.getInstance().convert(getDecimal(itemBom, 'Total_3D_Wire_Length__c', 0), UnitUtils.UNIT_MM, UnitUtils.UNIT_FT);
		itemBom.Usage_Rate__c = getDecimal(selectedBom, 'Usage_Rate_Calc__c', 0);

		// System.debug(LoggingLevel.ERROR, '#### Au Total_3D_Wire_Length__c is ' + getDecimal(itemBom, 'Total_3D_Wire_Length__c', 0));
		// System.debug(LoggingLevel.ERROR, '#### Au Purchase price is ' + itemBom.Purchase_Price__c);
		// System.debug(LoggingLevel.ERROR, '#### Au Std Usage is ' + itemBom.Standard_Usage__c);
		// System.debug(LoggingLevel.ERROR, '#### Au Usage rate is ' + itemBom.Usage_Rate__c);
		// System.debug(LoggingLevel.ERROR, '#### Au Cum Yield is ' + itemBom.Cum_Yield_Percent__c);	

		
		if(itemBom.Cum_Yield_Percent__c > 0 )
			itemBom.Material_Cost_Per_Unit__c = getDecimal(itemBom, 'Purchase_Price__c', 0) * getDecimal(itemBom, 'Usage_Rate__c', 0) * getDecimal(itemBom, 'Standard_Usage__c', 0) * 100.00 / getDecimal(itemBom, 'Cum_Yield_Percent__c', 0);
		else
			itemBom.Material_Cost_Per_Unit__c = 0.00;				
	}
	
	protected void addCalcStandard(RFQI_BOM__c itemBom, FCM_BOM__c selectedBom)
	{
		itemBom.Purchase_Price__c = getDecimal(selectedBom, 'Purchase_Price_Calc__c', 0);	
		itemBom.Standard_Usage__c = getDecimal(selectedBom, 'Standard_Usage_Calc__c', 0);				
		itemBom.Usage_Rate__c = getDecimal(selectedBom, 'Usage_Rate_Calc__c', 0);
		
		if(itemBom.Cum_Yield_Percent__c > 0 )
			itemBom.Material_Cost_Per_Unit__c = getDecimal(itemBom, 'Purchase_Price__c', 0) * getDecimal(itemBom, 'Usage_Rate__c', 0) * getDecimal(itemBom, 'Standard_Usage__c', 0)/ (getDecimal(itemBom, 'Cum_Yield_Percent__c', 0) * 10);
		else
			itemBom.Material_Cost_Per_Unit__c = 0.00;
	}

	public Boolean shouldAllowVariant(FCM_Bom__c row)
	{
		if (row.Package_Family__c != null && fcmBridge.wrapper.packageFamily.id != row.Package_Family__c) return false;
		if (row.Filter_Lead_Count__c != null && !fcmBridge.isLeadCountMatch(row.Filter_Lead_Count__c)) return false;
		return true;	
	}
	
	
	//---Determine if the Variant is allowed for the current values
	public virtual Boolean shouldAllowVariant(FCM_Bom__c row, String subClass)
	{
		if(subClass == null)
		{
			return shouldAllowVariant(row);
		}
		if (row.Package_Family__c != null && fcmBridge.wrapper.packageFamily.id != row.Package_Family__c) return false;
		if (row.Filter_Lead_Count__c != null && !fcmBridge.isLeadCountMatch(row.Filter_Lead_Count__c)) return false;
		return true;		
	}
	
	
	
	//---Process to update all the inherited values of all the boms, this is best used for batch imports and data cleanup
	public static void updateAllBomCalc()
	{
		List<FCM_BOM__c> bomList = FCMBOMDao.getInstance().getAll();
		Map<String, FCM_BOM__c> bomMap = new Map<String, FCM_BOM__c>(); 
		for(FCM_BOM__c bom : bomList) bomMap.put(bom.id, bom);
		
		for(FCM_BOM__c bom : bomList) 
		{
			if (bom.Parent_BOM__c == null)
			{
				updateBomCalc( bom, null);
			}
			else
			{
				FCM_BOM__c parentBom = bomMap.get(bom.Parent_BOM__c);
				updateBomCalc( bom, parentBom);
			}
		} 
		
		update bomList;
	}
	
	//---Update bom fields from self or parent
	public static void updateBomCalc(FCM_BOM__c bom, FCM_BOM__c parentBom)
	{
		//updateCalcField(bom, parentBom, 'AUF');
		updateCalcField(bom, parentBom, 'Base_Quantity');
		updateCalcField(bom, parentBom, 'Column');
		updateCalcField(bom, parentBom, 'Cost_Per_Unit');
		updateCalcField(bom, parentBom, 'Description');
		updateCalcField(bom, parentBom, 'Etch_Adder');
		updateCalcField(bom, parentBom, 'Mfg_Cost');
		updateCalcField(bom, parentBom, 'Purchase_Price');
		updateCalcField(bom, parentBom, 'Rough_Adder');
		updateCalcField(bom, parentBom, 'Row');
		updateCalcField(bom, parentBom, 'SID');
		updateCalcField(bom, parentBom, 'Standard_Usage');
		updateCalcField(bom, parentBom, 'Strip_Sublot');
		updateCalcField(bom, parentBom, 'Troy_Oz_Cost');
		updateCalcField(bom, parentBom, 'Units_Per_Strip');
		updateCalcField(bom, parentBom, 'UOM');
		updateCalcField(bom, parentBom, 'Usage_Rate');
		updateCalcField(bom, parentBom, 'Usage_Scrap_Rate');
		updateCalcField(bom, parentBom, 'Index');
		updateCalcField(bom, parentBom, 'Time_Per_Wire');
		updateCalcField(bom, parentBom, 'Group');
	}
	
	//---Update the Calc fields from either self or parent
	private static void updateCalcField(FCM_BOM__c bom, FCM_BOM__c parentBom, String fieldBaseName)
	{
		String sourceName = fieldBaseName + '__c';
		String orName = fieldBaseName + '_OR__c';
		String calcName = fieldBaseName + '_Calc__c';


		Boolean isOR = (Boolean)bom.get(orName);
		
		if (isOR != null && isOR == true)
		{
			bom.put(calcName, bom.get(sourceName));
		}
		else
		{
			if (parentBom == null)
			{
				bom.put(calcName, null);
			}
			else
			{
				bom.put(calcName, parentBom.get(sourceName));
			}
		}
	}
	
	//---Get decimal value from attribute
	public Decimal getDecimal(sObject obj, String fieldName, Decimal defVal) 
	{
		if(obj == null) return defVal;
        if(obj.get(fieldName) == null) return defVal;
        return Decimal.valueOf(String.valueOf(obj.get(fieldName)));
	}
}