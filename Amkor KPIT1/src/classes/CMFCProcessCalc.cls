public with sharing class CMFCProcessCalc extends CMProcessCalcBase
{
	public CMFCBridge fcBridge {get{return (CMFCBridge)fcmBridge;}}

	//---TODO find better wat to get die size
	private Decimal dieSize {get {return fcBridge.getDieX(0);} }

	protected override void addCalc(RFQI_Process__c itemProcess, FCM_Process__c selectedProcess)
	{
		Decimal uph = 0;
		if (selectedProcess.Category__c == 'WBG')
		{
			//40 * GDPW * Die Yield / Num Die / Num Die
			Decimal GDPW = fcBridge.getDieGDPW();

			uph = selectedProcess.UPH_Calc__c * GDPW * (fcBridge.getChipYield()/100);
		}
		else if (selectedProcess.Category__c == 'WBG-Grinding')
		{
			Decimal GDPW = fcBridge.getDieGDPW();
			Decimal chipYield = fcBridge.getChipYield()/100;

			uph = (fcBridge.getChipYield() == 0) ? 0 : selectedProcess.UPH_Calc__c * Math.pow((Double)fcBridge.getWBGThickness(), (Double)selectedProcess.UPH_Exponent_Calc__c) * GDPW / chipYield;
		}

		else if (selectedProcess.Category__c == 'WBG-Inspect')
		{
			//40 * GDPW * Die Yield / Num Die / Num Die
			Decimal GDPW = fcBridge.getDieGDPW();


			uph = (fcBridge.getChipYield() == 0) ? 0 : selectedProcess.UPH_Calc__c * GDPW / (fcBridge.getChipYield()/100);
		}
		else if (selectedProcess.Category__c == 'Wafer Mount')
		{
			//mult by num die again because will be added once per die
			uph = selectedProcess.UPH_Calc__c * fcBridge.getDieGDPW();
		}

		else if (selectedProcess.Category__c == 'Laser Groove')
		{
			Decimal lgCalc = fcBridge.getLGCalc();
			Decimal numDies = fcBridge.getNumberOfDies();
			uph = (numDies == 0 || lgCalc == 0) ? 0 : selectedProcess.UPH_Calc__c * Math.pow(Double.valueOf(dieSize), Double.valueOf(selectedProcess.UPH_Exponent_Calc__c)) * (fcBridge.getChipYield()/100) / numDies * lgCalc;
		}

		else if (selectedProcess.Category__c == 'Wafer Saw')
		{
			uph = selectedProcess.UPH_Calc__c * Math.pow(Double.valueOf(dieSize), Double.valueOf(selectedProcess.UPH_Exponent_Calc__c)) * (fcBridge.getChipYield()/100);
			//uph = uph / fcBridge.getNumberOfDies();
		}

		else if (selectedProcess.Category__c == 'Standard Divide Die')
		{
			uph = selectedProcess.UPH_Calc__c / fcBridge.getNumberOfDies();
		}

		else if (selectedProcess.Category__c == 'Standard')
		{
			uph = selectedProcess.UPH_Calc__c;
		}

		else if (selectedProcess.Category__c == 'Boat')
		{
			uph = selectedProcess.UPH_Calc__c * fcBridge.getUnitPerBoat();
		}

		else if (selectedProcess.Category__c == 'UF Dispense')
		{
			Decimal dieX = fcBridge.getDieX();
			uph = (6.2197*dieX*dieX - 233.89*dieX + 2564.3);
		}

		else if (selectedProcess.Category__c == 'Lid Attach')
		{
			uph = selectedProcess.UPH_Calc__c * Math.pow(Double.valueOf(dieSize), Double.valueOf(selectedProcess.UPH_Exponent_Calc__c)) / fcBridge.getLidCount();
		}

		else if (selectedProcess.Category__c == 'OS Test')
		{
			uph = selectedProcess.UPH_Calc__c / fcBridge.getOSSamplingPerc();
		}

		else if (selectedProcess.Category__c == 'Tray')
		{
			uph = selectedProcess.UPH_Calc__c * fcBridge.getUnitPerTray();
		}

		else if (selectedProcess.Category__c == 'OM')
		{
			uph = selectedProcess.UPH_Calc__c * fcBridge.getOMChase();
		}

		else if (selectedProcess.Category__c == 'OM Plate')
		{
			uph = selectedProcess.UPH_Calc__c * fcBridge.getOMChase();
		}

		else if (selectedProcess.Category__c == 'Tooling')
		{
			uph = 0;
		}

		else if (selectedProcess.Category__c == 'Capacitor')
		{
			Decimal capCount = fcBridge.getTotalNumberOfCapacitors();

			Decimal uphMultCalc = -0.0059 * capCount + 1.1481;
			Decimal capAtMult;

			if (capCount <= 0 || uphMultCalc > 1) capAtMult = 1;
			else capAtMult = uphMultCalc;

			uph = (fcBridge.getNumberOfDies() == 0) ? 0 : 1000 * fcBridge.getCapacitorUPHFactor() * capAtMult / fcBridge.getNumberOfDies();
		}

		itemProcess.Machine_UPH__c = (uph < 0) ? 10 : uph;
	}

	protected override void overrideEquipmentDepreciation(RFQI_Process__c itemProcess, String newForecast)
	{
		if (itemProcess.Category__c == 'Tooling')
		{
			if (newForecast == null)
			{
				Decimal capForecast = fcBridge.getCapacityForecast();
				itemProcess.Equipment_Depreciation__c = (capForecast == 0) ? 0 : fcBridge.getToolingForecast()/capForecast/(7*52);
			}
			else
			{
				Decimal capForecast = fcBridge.getCapacityForecast(newForecast);
				itemProcess.Equipment_Depreciation__c = (capForecast == 0) ? 0 : fcBridge.getToolingForecast(newForecast)/capForecast/(7*52);	
			}
		} 
	}

	protected override void overrideMachineCostPerUnit(RFQI_Process__c itemProcess, FCM_Process__c selectedProcess)
	{
		if (itemProcess.Category__c == 'OM Plate')
		{
			itemProcess.Machine_Cost_Per_Unit__c = getDecimal(selectedProcess, 'Equipment_Cost_Calc__c', 0) * fcBridge.getOMChase();
		} 
	}

}