/*************************************************************************
* 
* PURPOSE: Inner Parameter SD25DTCustomerBilling for 
*          SAPInterface.updateBillingItems created from 
*          SD25_MT_CustomerBilling.xsd each of these 
*          should be matched to an RFQ Line Item in SFDC
*
* CLASS: Lineitems
* CREATED: 03/04/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Jason Swenski
* 
**************************************************************************/
global class Lineitems {
	
    webservice String Mandt {get; set;}
    webservice String Erdat {get; set;}
    webservice String Erzet {get; set;}
    webservice String Cpn {get; set;}
    webservice String Kunrg {get; set;}
    webservice String Fkdat {get; set;}
    webservice String Kunag {get; set;}
    webservice String ZztargetDevice {get; set;}
    webservice String Zzpkct {get; set;}
    webservice String Zzdmsn {get; set;}
    webservice String Zzlead {get; set;}
    webservice String Vkorg {get; set;}
    webservice String Fkimg {get; set;}
    webservice String Vrkme {get; set;}
    webservice String IfStatus {get; set;}
    webservice String Ernam {get; set;}
    webservice String Aedat {get; set;}
    webservice String Aezet {get; set;}
    webservice String Aenam {get; set;}	

}