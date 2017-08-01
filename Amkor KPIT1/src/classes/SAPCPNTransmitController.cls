/*************************************************************************
* 
* PURPOSE: Main class for the outbound SAP CPN Transmission 
*          interface
*          
* CLASS: SAPCPNTransmitController
* CREATED: 05/24/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Jason Swenski
* 
**************************************************************************/
public with sharing class SAPCPNTransmitController {

    public class CPNTransmissionException extends Exception { }

    public static void transmitCPNToSAP(String cpnId){
    	transmit(cpnId);
    }
 
    @future(callout=true)
    private static void transmit(String cpnId){
		
  	    amkorComSd27Cpnattributetoecc.Cpnattribute_element sapCPN = new amkorComSd27Cpnattributetoecc.Cpnattribute_element();
	    sapCPN.Attributes = new List<amkorComSd27Cpnattributetoecc.Attributes_element>();
		
		List<CPN_Attribute__c> attributes = [select Configured_Part_Number__r.Name,Object__c,SAP_Name__c,Value__c,
		                                            Configured_Part_Number__r.Package_Family__r.Name,Configured_Part_Number__r.SHA512__c 
		                                     from CPN_Attribute__c where Configured_Part_Number__c =: cpnId];
		                                     
	    for(CPN_Attribute__c attrib : attributes) {
	    	sapCPN.CPNNumber = attrib.Configured_Part_Number__r.Name;
	    	sapCPN.PackageFamily = attrib.Configured_Part_Number__r.Package_Family__r.Name.toUpperCase();
	    	sapCPN.SHA512 = attrib.Configured_Part_Number__r.SHA512__c;
	    	
	    	amkorComSd27Cpnattributetoecc.Attributes_element element = new amkorComSd27Cpnattributetoecc.Attributes_element();
	        //Per Chandan, these need to be a specific length, luckly CPNNumber (above is 14 characters)
	    	element.AttributeName = StringUtils.chomp(attrib.SAP_Name__c,30);
	    	element.AttributeType = StringUtils.chomp(attrib.Object__c,60);
	    	element.AttributeValue = StringUtils.chomp(attrib.Value__c,60);
	    	sapCPN.Attributes.add(element);
	    }

	    Configured_Part_Number__c cpn = CPNDao.getInstance().getById(cpnId);
        
        try {
        	system.debug((String)System.JSON.serialize(sapCPN));
	        amkorComSd27Cpnattributetoecc.HTTPS_Port outboundInterface = new amkorComSd27Cpnattributetoecc.HTTPS_Port();
	        String response = outboundInterface.SD27_SIAOUT_CPNAttributeToECC(sapCPN);
            
            if(response == null || response.equalsIgnoreCase('Failed')){
                throw new CPNTransmissionException('SAP Server responded with Failed acknowledgement');
            }

	        SAP_Interface_Log__c logItem = new SAP_Interface_Log__c
	        (
    	  	    Method_Name__c = 'transmitCPNToSAP',
    		    Message_Content__c = response + ' CPN: ' + cpnId ,
    		    Status__c = 'Success'
	        );
            insert logItem;
            cpn.Status__c = CPNDao.STATUS_TRANSMITTED;

	    }
	    catch(Exception e) {

	        SAP_Interface_Log__c logItem = new SAP_Interface_Log__c
	        (
    	  	    Method_Name__c = 'transmitCPNToSAP',
    		    Message_Content__c = String.valueOf(e) + ' CPN: ' + cpnId,
    		    Status__c = 'Error'
	        );
            insert logItem;
            cpn.Status__c = CPNDao.STATUS_TRANSMIT_FAILED;
        }   
       
	    CPNDao.getInstance().saveCPN(cpn);
    }
}