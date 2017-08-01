@isTest
public with sharing class CMTestModelControllerTest 
{

	public static testmethod void testExistingRecord()
	{
		List<CM_Test_Model__c> values = setupTest();
		CM_Test_Model__c rec = values[0];
		String recId = rec.Id;
		String verId = rec.CM_Version__c;
		PageUtil.putParam('versionId', rec.CM_Version__c);

		ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(rec);
		CMTestModelController cont = new CMTestModelController(sc);
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
		System.assert([SELECT Id FROM CM_Test_Model__c WHERE Id=:recId].size() == 0);
	}

	public static testmethod void testNewRecord()
	{
		List<CM_Test_Model__c> values = setupTest();
		PageUtil.putParam('versionId', values[0].CM_Version__c);

		CM_Test_Model__c rec = new CM_Test_Model__c();
		ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(rec);
		CMTestModelController cont = new CMTestModelController(sc);
		cont.setupAction();
		PageReference pr = cont.saveAction();

		//remove the slash in front
		String recId = pr.getURL().substring(1);

		CM_Test_Model__c value = [SELECT Id, CM_Version__c FROM CM_Test_Model__c WHERE Id=:recId];

		System.assert(value.CM_Version__c == values[0].CM_Version__c);

	}

	private static List<CM_Test_Model__c> setupTest()
	{
		Product_Group__c pg = SharedUnitTestUtils.createProductGroupFromName('UnitTest', false);
		insert pg;

		List<CM_Version__c> verList = new List<CM_Version__c>();

		verList.add(new CM_Version__c(Product_Group__c=pg.Id, Status__c='Active', Version__c=3));
		verList.add(new CM_Version__c(Product_Group__c=pg.Id, Status__c='Pending', Version__c=4));
		insert verList;

		List<CM_Test_Model__c> values = new List<CM_Test_Model__c>();
		for (CM_Version__c ver : verList)
		{
			
			values.add(new CM_Test_Model__c(CM_Version__c=ver.Id, Amkor_Price_Per_Sec__c=1));
			values.add(new CM_Test_Model__c(CM_Version__c=ver.Id, Amkor_Price_Per_Sec__c=2));
			values.add(new CM_Test_Model__c(CM_Version__c=ver.Id, Amkor_Price_Per_Sec__c=3));
		}

		insert values;
		
		return values;
	}
}