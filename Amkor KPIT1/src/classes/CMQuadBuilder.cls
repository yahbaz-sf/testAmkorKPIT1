/*************************************************************************
*
* PURPOSE: 
*
* CLASS: 
* CREATED: 5/13/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Steve Simpson
***************************************************************************/
public with sharing class CMQuadBuilder extends CMFCMBuilderBase
{
	public CMQuadBuilder()
	{
		bridge = new CMQuadBridge();
		bomCalc = new CMQuadBOMCalc();
		processCalc = new CMQuadProcessCalc();
	}
}