/*************************************************************************
*
* PURPOSE: 
*
* CLASS: 
* CREATED: 5/13/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Steve Simpson
***************************************************************************/
public with sharing class CMMLFProcessCalc extends CMProcessCalcBase 
{
	public CMMLFBridge mlfBridge {get{return (CMMLFBridge)fcmBridge;}}
	
	

	
	protected override Decimal getUtilization(RFQI_Process__c itemProcess)
	{
		return getUtilization(itemProcess, '');
	}
	
	protected override Decimal getUtilization(RFQI_Process__c itemProcess, String newForecast)
	{	
		if(itemProcess.Name == 'Wire Bond - Die 1' && mlfBridge.getPF_Sub_Class_1() == 'PMLF')
			return mlfBridge.getUtilizationCompoundEfficiency(); 
		else
			return fcmBridge.getUtilizationEfficiency(); 
	}

	public override Boolean shouldAllowVariant(FCM_Process__c row, String pfSubClass1)
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
		if (row.Filter_Lead_Count__c != null && !fcmBridge.isLeadCountMatch(row.Filter_Lead_Count__c)){ 
			
			return false;
		}
		if (row.Filter_Factory__c != null && !fcmBridge.isFactoryMatch(row.Filter_Factory__c)){ 
			
			return false;
		}
			
		return true;	
	}


	
	
	protected override void addCalc(RFQI_Process__c itemProcess, FCM_Process__c selectedProcess)
	{
		
		if(mlfBridge.getPF_Sub_Class_1() == null) return;
		
		
		if (mlfBridge.getPF_Sub_Class_1().compareTo('PMLF') == 0)		
		{				
			if (selectedProcess.Name == 'Wafer B/G - Die 1' || selectedProcess.Name == 'Wafer B/G - Die 2')
			{	
				itemProcess.Machine_UPH__c = 14 * mlfBridge.getDieNumGDPW();
			}
			if (selectedProcess.Name == 'Wafer Mount - Die 1' || selectedProcess.Name == 'Wafer Mount - Die 2')
			{	
				itemProcess.Machine_UPH__c = 74 * mlfBridge.getDieNumGDPW();
			}
			if (selectedProcess.Name == 'Saw - Die 1')
			{	
				Decimal dieSum = mlfBridge.getDieX(0) + mlfBridge.getDieY(0);
				if (dieSum > 0) itemProcess.Machine_UPH__c = 360000.00/((dieSum)*2.00);
			}
			if (selectedProcess.Name == 'Saw - Die 2')
			{	
				Decimal dieSum = mlfBridge.getDieX(1) + mlfBridge.getDieY(1);
				if (dieSum > 0) itemProcess.Machine_UPH__c = 360000.00/((dieSum)*2.00);
			}
			if (selectedProcess.Name == 'D/A Cure - Die 1')
			{	
				itemProcess.Machine_UPH__c = 222.00 * mlfBridge.getUnitsPerStrip();
			}
			if (selectedProcess.Name == 'D/A Cure - Die 2')
			{	
				itemProcess.Machine_UPH__c = 222.00 * mlfBridge.getNumStandardWires();		
			}
			if (selectedProcess.Name == 'Wire Bond - Die 1')
			{	
				Decimal wireFactor = (mlfBridge.getNumStandardWires()*0.199) + (mlfBridge.getRSSBWires()*0.222) + (mlfBridge.getNumSSBWires()*0.259);
				if (wireFactor > 0) itemProcess.Machine_UPH__c = 3600.00 / wireFactor;
			}
			if (selectedProcess.Name == 'Wire Bond - Die 2')
			{	
				Decimal wireFactor = (mlfBridge.getNumStandardWires()*0.16) + (mlfBridge.getRSSBWires()*0.22) + (mlfBridge.getNumSSBWires()*0.259);
				if (wireFactor > 0) itemProcess.Machine_UPH__c = 3600.00 / wireFactor;
			}
			if (selectedProcess.Name == 'Mold')
			{	
				itemProcess.Machine_UPH__c = 25.00 * mlfBridge.getUnitsPerStrip() * 2.00 * 1.5;
			}
			if (selectedProcess.Name == 'Chemical Deflash')
			{	
				itemProcess.Machine_UPH__c = 360.00 * mlfBridge.getUnitsPerStrip();
			}
			if (selectedProcess.Name == 'P/Cure')
			{	
				itemProcess.Machine_UPH__c = 42.00 * mlfBridge.getUnitsPerStrip();
			}
			if (selectedProcess.Name == 'Laser')
			{	
				itemProcess.Machine_UPH__c = 112.00 * mlfBridge.getUnitsPerStrip();
			}
			if (selectedProcess.Name == 'S/PLT')
			{	
				itemProcess.Machine_UPH__c = 310.00 * mlfBridge.getUnitsPerStrip();
			}
			if (selectedProcess.Name == 'Singulate')
			{	
				itemProcess.Machine_UPH__c = 35.00 * 60.00 * mlfBridge.getSubstrateNumberPerColumn();
			}
			if (selectedProcess.Name == 'FVI')
			{	
				itemProcess.Machine_UPH__c = 70.00 * mlfBridge.getUnitsPerStrip();
			}
			if (selectedProcess.Name == 'Pack')
			{	
				itemProcess.Machine_UPH__c = 355.00 * mlfBridge.getUnitsPerStrip();
			}
			
			//---STANDARD CALC
			if (selectedProcess.Name == '2nd Op - Die 1' || selectedProcess.Name == '2nd Op - Die 2' ||
					 selectedProcess.Name == 'D/A - Die 1' || selectedProcess.Name == 'D/A - Die 2' ||
					 selectedProcess.Name == '3rd Op - Die 1' || selectedProcess.Name == '3rd Op - Die 2')
			{	
				//---STANDARD CALC
			}
		}
		if (mlfBridge.getPF_Sub_Class_1().compareTo('SMLF') == 0)		
		{				
			if (selectedProcess.Name == 'Wafer B/G - Die 1' || selectedProcess.Name == 'Wafer B/G - Die 2')
			{	
				itemProcess.Machine_UPH__c = 14 * mlfBridge.getDieNumGDPW();
			}
			if (selectedProcess.Name == 'Wafer Mount - Die 1' || selectedProcess.Name == 'Wafer Mount - Die 2')
			{	
				itemProcess.Machine_UPH__c = 74 * mlfBridge.getDieNumGDPW();
			}
			if (selectedProcess.Name == 'Saw - Die 1')
			{	
				Decimal dieSum = mlfBridge.getDieX(0) + mlfBridge.getDieY(0);
				if (dieSum > 0) itemProcess.Machine_UPH__c = 3600.00 * 100.00 /((dieSum)*2.00);
			}
			if(selectedProcess.Name == 'Saw - Die 2'){
				Decimal dieSum = mlfBridge.getDieX(1) + mlfBridge.getDieY(1);				
				if (dieSum > 0) itemProcess.Machine_UPH__c = 3600.00 * 100.00 /((dieSum)*2.00);

			}
			if (selectedProcess.Name == 'D/A Cure')
			{	
				itemProcess.Machine_UPH__c = 120.00 * mlfBridge.getUnitsPerStrip();
			}
			if (selectedProcess.Name == 'Wire Bond')
			{	
				Decimal wireFactor = (mlfBridge.getNumStandardWires()*0.16) + (mlfBridge.getRSSBWires()*0.22) + (mlfBridge.getNumSSBWires()*0.259);
				if (wireFactor > 0) itemProcess.Machine_UPH__c = 3600.00/wireFactor;
			}
			if (selectedProcess.Name == 'Mold')
			{	
				itemProcess.Machine_UPH__c = 24.6 * mlfBridge.getUnitsPerStrip() * 2.00;
			}
			if (selectedProcess.Name == 'Tape Removal')
			{	
				itemProcess.Machine_UPH__c = 196.00 * mlfBridge.getUnitsPerStrip();
			}
			if (selectedProcess.Name == 'P/Cure' || selectedProcess.Name == 'Post-Plate Bake')
			{	
				itemProcess.Machine_UPH__c = 40.00 * 20.00 * mlfBridge.getUnitsPerStrip() / 4.00;
			}
			if (selectedProcess.Name == 'Chemical Deflash/Plating')
			{	
				itemProcess.Machine_UPH__c = 1142.00 * mlfBridge.getUnitsPerStrip();
			}
			if (selectedProcess.Name == 'Laser Mark')
			{	
				itemProcess.Machine_UPH__c = 47.00 * mlfBridge.getUnitsPerStrip();
			}
			if (selectedProcess.Name == 'Saw Singulate')
			{	
				itemProcess.Machine_UPH__c = 9706.00;
			}
			if (selectedProcess.Name == 'Pack')
			{	
				itemProcess.Machine_UPH__c = 355.00 * mlfBridge.getUnitsPerStrip();
			}
			
			if (selectedProcess.Name == '2nd Op - Die 1' || selectedProcess.Name == '2nd Op - Die 2' ||
					selectedProcess.Name == 'D/A' || selectedProcess.Name == 'FVI Q')
			{	
				//---STANDARD CALC
			}
		}
	}
}