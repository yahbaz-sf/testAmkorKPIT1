/*************************************************************************
*
* PURPOSE: 
*
* CLASS: 
* CREATED: 5/13/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Steve Simpson
***************************************************************************/
public with sharing class CMDualBuilder extends CMFCMBuilderBase 
{
	public CMDualBuilder()
	{
		bridge = new CMDualBridge();
		bomCalc = new CMDualBOMCalc();
		processCalc = new CMDualProcessCalc();
	}
}