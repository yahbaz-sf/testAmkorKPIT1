@isTest
public with sharing class CMMarginControllerTest 
{

	public static testmethod void testExistingRecord()
	{
		List<CM_Margin__c> margins = setupTest();
		CM_Margin__c rec = margins[0];
		String recId = rec.Id;
		String verId = rec.CM_Margin_Version__c;
		PageUtil.putParam('versionId', rec.CM_Margin_Version__c);

		ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(rec);
		CMMarginController cont = new CMMarginController(sc);
		cont.setupAction();

		PageReference pr;

		pr = cont.editAction();
		System.assert(pr.getURL() == ('/' + rec.Id + '/e'));

		pr = cont.saveAction();
		System.assert(pr.getURL() == ('/' + rec.id));

		pr = cont.cancelAction();
		System.assert(pr.getURL() == ('/' + rec.id));

		pr = cont.deleteAction();
		System.assert(pr.getURL() == ('/' + verId));
		System.assert([SELECT Id FROM CM_Margin__c WHERE Id=:recId].size() == 0);
	}

	public static testmethod void testNewRecord()
	{
		List<CM_Margin__c> margins = setupTest();
		PageUtil.putParam('versionId', margins[0].CM_Margin_Version__c);

		CM_Margin__c rec = new CM_Margin__c();
		ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(rec);
		CMMarginController cont = new CMMarginController(sc);
		cont.setupAction();
		PageReference pr = cont.saveAction();

		//remove the slash in front
		String recId = pr.getURL().substring(1);

		CM_Margin__c margin = [SELECT Id, CM_Margin_Version__c FROM CM_Margin__c WHERE Id=:recId];

		System.assert(margin.CM_Margin_Version__c == margins[0].CM_Margin_Version__c);

	}

	private static List<CM_Margin__c> setupTest()
	{
		Product_Group__c pg = SharedUnitTestUtils.createProductGroupFromName('UnitTest', false);
		insert pg;

		List<CM_Margin_Version__c> verList = new List<CM_Margin_Version__c>();

		verList.add(new CM_Margin_Version__c(Product_Group__c=pg.Id, Status__c='Active', Version__c=3));
		verList.add(new CM_Margin_Version__c(Product_Group__c=pg.Id, Status__c='Pending', Version__c=4));
		insert verList;

		List<CM_Margin__c> margins = new List<CM_Margin__c>();
		for (CM_Margin_Version__c ver : verList)
		{
			
			margins.add(new CM_Margin__c(CM_Margin_Version__c=ver.Id, Margin__c=10));
			margins.add(new CM_Margin__c(CM_Margin_Version__c=ver.Id, Margin__c=20));
			margins.add(new CM_Margin__c(CM_Margin_Version__c=ver.Id, Margin__c=30));
		}

		insert margins;
		
		return margins;
	}
}