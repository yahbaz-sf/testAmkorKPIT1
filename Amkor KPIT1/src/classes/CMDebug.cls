/*************************************************************************
*
* PURPOSE: A holder object for CM Debug messages
*
* CLASS: 
* CREATED: 5/01/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Steve Simpson
***************************************************************************/
public with sharing class CMDebug 
{
	public String message {get; set;}
	
	public CMDebug()
	{}	
	
	public CMDebug(String pMessage)
	{
		message = pMessage;
	}
}