/*************************************************************************
*
* PURPOSE: 
*
* CLASS: 
* CREATED: 5/01/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Steve Simpson
***************************************************************************/
@isTest
public with sharing class FCMProcessControllerTest 
{
	static testMethod void testSetup() 
	{
		FCMProcessController cont = null;
		
		Test.startTest();
			
		cont = getTestController('Wirebond');
		cont.setupAction();
		
		System.assert(true);
		
		Test.stopTest();
	}
	
	static testMethod void testViewAndUpdate() 
	{
		FCMProcessController cont = getTestController('Standard');
		
		Test.startTest();
		
		cont.setupAction();
		cont.updateCategory();
		cont.updateValues();
		cont.saveAction();
		
		System.assert(true);
		
		Test.stopTest();
	}
	
	static testMethod void testCancel() 
	{
		FCMProcessController cont = getTestController('Wirebond');
		
		Test.startTest();
		
		cont.setupAction();
		cont.updateCategory();
		cont.updateValues();
	
		cont.cancelAction();
	
		System.assert(true);
		
		Test.stopTest();
	}
	
	static testMethod void testEdit() 
	{
		FCMProcessController cont = getTestController('Standard');
		
		Test.startTest();
		
		cont.setupAction();		
		cont.addVariantAction();
		
		System.assert(true);
		
		Test.stopTest();
	}
	
	static testMethod void testVariant() 
	{
		FCMProcessController cont = getTestController('Standard');
		
		Test.startTest();
		
		cont.setupAction();		
		cont.editAction();
		cont.addVariantAction();

		
		System.assert(true);
		
		Test.stopTest();
	}
	
	static testMethod void testDelete() 
	{
		FCMProcessController cont = getTestController('Standard');
		
		Test.startTest();
		
		cont.setupAction();		
		cont.deleteAction();
		
		System.assert(true);
		
		Test.stopTest();
	}
	
	static testMethod void testClone() 
	{
		FCMProcessController cont = getTestController('Standard');
		
		Test.startTest();
		
		cont.setupAction();		
		cont.cloneAction();
		
		System.assert(true);
		
		Test.stopTest();
	}
	
	private static FCMProcessController getTestController(String cat) 
	{
		RFQAdminInstaller.install();
		MLFInstaller.install();
		CMMLFInstaller.install();
		
		List<FCM_Process__c> bomList = [select id from FCM_Process__c where Product_Group__r.Name=:'MLF'];
		ApexPages.StandardController sc = new ApexPages.StandardController(bomList[0]);
    	FCMProcessController controller = new FCMProcessController(sc);
    	
    	return controller;
	}
}