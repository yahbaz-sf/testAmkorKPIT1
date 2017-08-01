/*************************************************************************
*
* PURPOSE: Test method for CM Version Controller
*
* CLASS: CMVersionControllerTest
* CREATED: 6/10/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Steve Simpson
***************************************************************************/
@isTest
public with sharing class CMVersionControllerTest 
{
	static testMethod void testActiveList() 
	{
		CMVersionController cont = null;
		
		Test.startTest();

		cont = getTestController();
		String expectedUrl = '/' + [select Id from CM_Version__c where Product_Group__r.Name='Dual Leadframe'][0].Id;
		
		ApexPages.currentPage().getParameters().put('pgId', [Select Id from Product_Group__c where Name='Dual Leadframe'].Id);
		PageReference pg = cont.viewActiveListAction();

		System.assert(pg.getUrl() == expectedUrl);
		
		Test.stopTest();
	}

	static testMethod void testHasPendingVersions()
	{
		CMVersionController cont = null;
		
		Test.startTest();

		cont = getTestController();
		
		PageReference pg = cont.makePendingAction();
		String expectedUrl = '/' + [select Id from CM_Version__c where Product_Group__r.Name='Dual Leadframe' and Status__c='Pending'][0].Id;

		//only an active version installed
		System.assert(pg.getUrl() == expectedUrl);

		pg = cont.makePendingAction();


		System.assert(pg == null);
		
		Test.stopTest();
	}
	
	
	static testMethod void testPendingList() 
	{
		CMVersionController cont = null;
		
		Test.startTest();

		cont = getTestController();
		String expectedUrl = '/' + [select Id from CM_Version__c where Product_Group__r.Name='Dual Leadframe'][0].Id;
		
		ApexPages.currentPage().getParameters().put('pgId', [Select Id from Product_Group__c where Name='Dual Leadframe'].Id);
		PageReference pg = cont.deleteAction();

		//cm version is active, cannot delete
		System.assert(pg == null);

		expectedUrl = '/' + [select Id from CM_Version__c where Product_Group__r.Name='Dual Leadframe' and Status__c='Active'][0].Id;
		pg = cont.viewPendingListAction();

		String pendingId = pg.getUrl().remove('/');
		CM_Version__c pendingVersion = [select Id, Name, Status__c, Product_Group__c from CM_Version__c where id=:pendingId];
		ApexPages.StandardController sc2 = new ApexPages.StandardController(pendingVersion);
		CMVersionController pendingCont = new CMVersionController(sc2);

		pg = pendingCont.deleteAction();
		System.assert(pg.getUrl() == expectedUrl, pg.getUrl());

		Test.stopTest();
	} 

	static testMethod void testSetupAndView()
	{
		CMVersionController cont = null;
		
		Test.startTest();
		cont = getTestController();
		
		PageReference pg = cont.setupViewAction();
		System.assert(pg == null);

		pg = cont.setupEditAction();
		System.assert(pg == null);
		
		Test.stopTest();
	}

	static testMethod void testEdit()
	{
		CMVersionController cont = null;
		
		Test.startTest();
		cont = getTestController('Pending');
		
		PageReference pg = cont.editAction();
		String expectedUrl = '/' + [select Id from CM_Version__c where Product_Group__r.Name='Dual Leadframe' and Status__c='Pending'][0].Id + '/e';

		System.assert(pg.getUrl() == expectedUrl);

		
		Test.stopTest();
	}


	static testMethod void testMakeActive() 
	{
		CMVersionController cont = null;
		
		Test.startTest();

		cont = getTestController();

		ApexPages.currentPage().getParameters().put('pgId', [Select Id from Product_Group__c where Name='Dual Leadframe'].Id);
		String expectedUrl = '/' + [select Id from CM_Version__c where Product_Group__r.Name='Dual Leadframe' and Status__c='Active'][0].Id;
		PageReference pg = cont.viewPendingListAction();

		String pendingId = pg.getUrl().remove('/');
		CM_Version__c pendingVersion = [select Id, Name, Status__c, Product_Group__c from CM_Version__c where id=:pendingId];
		ApexPages.StandardController sc2 = new ApexPages.StandardController(pendingVersion);
		CMVersionController pendingCont = new CMVersionController(sc2);

		expectedUrl = '/' + pendingId;
		pg = pendingCont.makeActiveAction();
		
		pendingVersion = [select Id, Name, Status__c, Product_Group__c from CM_Version__c where id=:pendingId];
		System.assert(pg.getUrl() == expectedUrl, pg.getUrl());
		System.assert(pendingVersion.Status__c == 'Active', pendingVersion.Status__c);

		Test.stopTest();
	} 






	
	private static CMVersionController getTestController() 
	{
		return getTestController('Active');
	}

	private static CMVersionController getTestController(String status) 
	{
		RFQAdminInstaller.install();
		DualLeadframeInstaller.installTest();
		CMDualInstaller.install();
		Product_Group__c pg = [Select Id, Name from Product_Group__c where Name='Dual Leadframe'];
		List<CM_Version__c> verList = CMVersionDao.getInstance().getByPGAndStatus(pg.Id, status);
		
		CM_Version__c ver;
		if(verList != null && verList.size() > 0 )
			ver = verList[0];					
		else{
			ver = new CM_Version__c(Product_Group__c=pg.Id,Version__c=1, Status__c=status);
			insert ver;				
		}
			
		
		
		ApexPages.StandardController sc = new ApexPages.StandardController(ver);
    	CMVersionController controller = new CMVersionController(sc);
    	
    	return controller;
	}
	
	private static CMVersionController getTestControllerList() 
	{
		RFQAdminInstaller.install();
		DualLeadframeInstaller.installTest();
		CMDualInstaller.install();

		// Only dual should be installed at this point
		Product_Group__c pg = [Select Id from Product_Group__c];
		
		CM_Version__c ver = new CM_Version__c(Product_Group__c=pg.Id,Version__c=1);
		insert ver;
		
		ApexPages.StandardController sc = new ApexPages.StandardController(ver);
    	CMVersionController controller = new CMVersionController(sc);
    	
    	return controller;
	}
}