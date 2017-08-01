/*************************************************************************
*
* PURPOSE: Test class
*
* CLASS: FCMBOMControllerTest
* CREATED: 5/01/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Steve Simpson
***************************************************************************/
@isTest
public with sharing class FCMBOMControllerTest 
{
	/*static testMethod void testSetup() 
	{
		FCMBOMController cont = null;
		
		Test.startTest();
		
		cont = getTestController('Mold');
		cont.setupAction();
		
		cont = getTestController('AuWire');
		cont.setupAction();
		
		cont = getTestController('Wire');
		cont.setupAction();
		
		System.assert(true);
		
		Test.stopTest();
	}*/
	
	static testMethod void testViewAndUpdate() 
	{
		FCMBOMController cont = getTestController('Standard');
		
		Test.startTest();
		
		cont.setupAction();
		cont.updateCategory();
		cont.updateValues();
		PageReference pf = cont.saveAction();
		
		System.assert(pf != null);
		
		Test.stopTest();
	}
	
	static testMethod void testCancel() 
	{
		FCMBOMController cont = getTestController('Standard');
		
		Test.startTest();
		
		cont.setupAction();
		cont.updateCategory();
		cont.updateValues();
	
		PageReference pf = cont.cancelAction();
	
		System.assert(pf != null);
		
		Test.stopTest();
	}
	
	static testMethod void testEdit() 
	{
		FCMBOMController cont = getTestController('Standard');
		
		Test.startTest();
		
		cont.setupAction();		
		PageReference pf = cont.addVariantAction();
		
		System.assert(pf != null);
		
		Test.stopTest();
	}
	
	static testMethod void testVariant() 
	{
		FCMBOMController cont = getTestController('Standard');
		
		Test.startTest();
		
		cont.setupAction();		
		cont.editAction();
		PageReference pf = cont.addVariantAction();

		
		System.assert(pf != null);
		
		Test.stopTest();
	}
	
	static testMethod void testDelete() 
	{
		FCMBOMController cont = getTestController('Standard');
		
		Test.startTest();
		
		cont.setupAction();		
		PageReference pf = cont.deleteAction();
		
		System.assert(pf != null);
		
		Test.stopTest();
	}
	
	static testMethod void testClone() 
	{
		FCMBOMController cont = getTestController('Standard');
		
		Test.startTest();
		
		cont.setupAction();		
		PageReference pf = cont.cloneAction();
		
		System.assert(pf != null);
		
		Test.stopTest();
	}
	
	private static FCMBOMController getTestController(String cat) 
	{
		RFQAdminInstaller.install();
		MLFInstaller.install();
		CMMLFInstaller.install();
		
		List<FCM_BOM__c> bomList = [select id from FCM_BOM__c where Product_Group__r.Name=:'MLF'];
		ApexPages.StandardController sc = new ApexPages.StandardController(bomList[0]);
    	FCMBOMController controller = new FCMBOMController(sc);
    	
    	return controller;
	}
}