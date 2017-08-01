/*************************************************************************
* 
* PURPOSE: Parameter for SAPInterface.updateBillingItems
*          created from SD25_MT_CustomerBilling.xsd
*
* CLASS: SD25DTCustomerBilling
* CREATED: 03/04/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Jason Swenski
* 
**************************************************************************/
global class SD25DTCustomerBilling {
	
	webservice List<Lineitems> lineitems {get; set;}

}