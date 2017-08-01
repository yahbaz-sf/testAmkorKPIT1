/*************************************************************************
*
* PURPOSE: 
*
* CLASS: 
* CREATED: 5/13/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Steve Simpson
***************************************************************************/
public with sharing class CMDualProcessCalc extends CMProcessCalcBase 
{
	protected override void addCalc(RFQI_Process__c itemProcess, FCM_Process__c selectedProcess)
	{
		if (selectedProcess.Category__c == 'Wirebond')
		{
			Decimal timeFactor = getDecimal(selectedProcess, 'Time_Per_Wire_Calc__c', 0) * getDecimal(itemProcess, 'Number_Of_Wires__c', 0) + getDecimal(selectedProcess, 'Index_Calc__c', 0);
			if (timeFactor > 0) itemProcess.Machine_UPH__c = Decimal.valueOf(Integer.valueOf(3600.00/timeFactor));
		}		
	}
}