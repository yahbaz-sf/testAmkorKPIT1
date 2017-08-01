/*************************************************************************
*
* PURPOSE: 
*
* CLASS: CMSettings
* CREATED: 6/12/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Steve Simpson
***************************************************************************/
public with sharing class CMSettings 
{
	public Boolean usePending {get; set;}
	
	public CMSettings()
	{
		usePending = false;
	}
}