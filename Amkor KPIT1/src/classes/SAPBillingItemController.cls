/*************************************************************************
* 
* PURPOSE: This class does the main work of creating new 
*          Billing Item records
*                   
* CLASS: SAPBillingItemController
* CREATED: 05/17/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Jason Swenski
* 
**************************************************************************/
public with sharing class SAPBillingItemController {
	//Bhanu 12-Apr-2016 
	//public static void updateBillingItems(SD25DTCustomerBilling billings)
	public static SAPInterfaceResult updateBillingItems(SD25DTCustomerBilling billings) {
		//Bhanu 12-Apr-2016 
		SAPInterfaceResult resultInstance = new SAPInterfaceResult();
		
		try{		
			List<SAP_Billing_Item__c> billingItems = new List<SAP_Billing_Item__c>();				
			Set<String> cpnNames = new Set<String>();
			
			if(billings != null && billings.lineitems != null) {
				
				for(Lineitems l : billings.lineitems) {
			        
			        if(l.Cpn != null) cpnNames.add(l.Cpn);
			        
			        billingItems.add(new SAP_Billing_Item__c
			            (
			                MANDT__c = l.Mandt,
			                ERDAT__c = l.Erdat,
			                ERZET__c = l.Erzet,
			                CPN__c = l.Cpn,
			                KUNRG__c = l.Kunrg,
			                FKDAT__c = l.Fkdat,
			                KUNAG__c = l.Kunag,
			                ZZTARGETDEVICE__c = l.ZztargetDevice,
			                ZZPKCT__c = l.Zzpkct,
			                ZZDMSN__c = l.Zzdmsn,
			                ZZLEAD__c = l.Zzlead,
			                VKORG__c = l.Vkorg,
			                FKIMG__c = l.Fkimg,
			                VRKME__c = l.Vrkme,
			                IFSTATUS__c = l.IfStatus,
			                ERNAM__c = l.Ernam,
			                AEDAT__c = l.Aedat,
			                AEZET__c = l.Aezet,
			                AENAM__c = l.Aenam
			            )
			        );     				
				}
				
				//TODO - really need to remove all the inline DML/SOQL out of these interface classes
				//Grab the CPNs that were sent over
				List<Configured_Part_Number__c> cpnList 
				    = [select Id,Name from Configured_Part_Number__c where Name in:cpnNames];
				    
				//Shove the CPNs in to a Map for easy access
				Map<String,Configured_Part_Number__c> cpnMap = new Map<String,Configured_Part_Number__c>();
				for(Configured_Part_Number__c cpn : cpnList) cpnMap.put(cpn.Name,cpn);
				
				//loop over the billing items we generated above and link them to a CPN
				for(SAP_Billing_Item__c item : billingItems) {
					Configured_Part_Number__c cpn = cpnMap.get(item.CPN__c);
					if(cpn != null) item.Configured_Part_Number__c = cpn.Id;
				}
				
				//Bhanu 14-Apr-2016
	            resultInstance.process = 'Inserting Billing Items';
				insert billingItems;
				
				//Set all the RFQs that have this CPN to production win 
				//**** TODO ***** we need to make sure the RFQ__r.Account.AccountNumber =: KUNNAG or what not
				//chandan needs to answer this question still
				List<RFQ_Item__c> prodWinRFQIs = new List<RFQ_Item__c>();
				for(RFQ_Item__c item : [select Id from RFQ_Item__c where Configured_Part_Number__c in:cpnList]) {
					item.Status__c = RFQItemDao.STATUS_PRODUCTION_WIN;
					prodWinRFQIs.add(item);
				} 
				
				//List<RFQ__c> prodWinRFQs = new List<RFQ__c>();
				//for(RFQ__c rfq : [select Id,Status__c from RFQ__c where Id in:rfqIds]){
				//	rfq.Status__c = 'Production Win';
				//	prodWinRFQs.add(rfq);
				//}
				
				//Bhanu 14-Apr-2016
	            resultInstance.process = 'Updating RFQ Items associated with CPN to Production Win Status';
				update prodWinRFQIs;	
				
				//Bhanu 14-Apr-2016
                resultInstance.process = '';
			} 
		} catch(Exception e){
			resultInstance.addError('Error while ' + resultInstance.process + ' : ' + e.getMessage() + ', Location : ' + e.getStackTraceString());
		}
		//Bhanu 12-Apr-2016 
		system.debug('---->SAPBillingItemController.updateBillingItems(), returning resultInstance : ' + resultInstance);
		return resultInstance;
	}

}