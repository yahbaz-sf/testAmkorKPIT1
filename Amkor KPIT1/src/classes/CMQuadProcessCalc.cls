/*************************************************************************
*
* PURPOSE: 
*
* CLASS: 
* CREATED: 5/13/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Steve Simpson
***************************************************************************/
public with sharing class CMQuadProcessCalc extends CMProcessCalcBase 
{
    public CMQuadBridge quadBridge {get{return (CMQuadBridge)fcmBridge;}}
	protected override void addCalc(RFQI_Process__c itemProcess, FCM_Process__c selectedProcess)
	{
        if (selectedProcess.Name == 'W/B/G 1-W/B/G_18.0+-0.5M TOLERANCE')
            {   
                Decimal waferSize = quadBridge.getDieWaferSize();
                Decimal GDPW = quadBridge.getDieNumGDPW();
                if (waferSize < 200) itemProcess.Machine_UPH__c = 20 * GDPW;
                else if (waferSize > 200) itemProcess.Machine_UPH__c = 8 * GDPW;
                else itemProcess.Machine_UPH__c = 14 * GDPW;
            }

        if (selectedProcess.Name == 'W/B/Q_5 WFRS / LOT')
        {
        	//---TODO, what is the value?
            return;
        }
        if (selectedProcess.Name == 'WAF/M-WAF/M_')
        {
            itemProcess.Machine_UPH__c = 40 * quadBridge.getDieNumGDPW();
        }
        if (selectedProcess.Name == 'W/B_Wire-W/B_200+-10C AU')
        {
            itemProcess.Machine_UPH__c = quadBridge.getWireBondUPH();
        }        
	}

   	protected override Decimal getDirectLabor(RFQI_Process__c itemProcess)
	{
		if (itemProcess.Forecast_Volume_Per_Week__c > 0) return (1.0/itemProcess.Machines_Per_Person__c)*itemProcess.Equipment_Needed__c*itemProcess.Available_Hours_Per_Week__c*itemProcess.Direct_Labor_Rate__c*(4/3.0)*(1.0+itemProcess.Off_Equipment_Direct_To_Direct__c)/(itemProcess.Forecast_Volume_Per_Week__c*1000.00);
		return 0;
	}

}