@isTest
public with sharing class FCMMatchConditionControllerTest 
{

	public static testmethod void testExistingBomRecord()
	{
		List<FCM_Match_Condition__c> values = setupTest();
		FCM_Match_Condition__c rec = values[0];
		String recId = rec.Id;

		ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(rec);
		FCMMatchConditionController cont = new FCMMatchConditionController(sc);
		cont.setupAction();

		PageReference pr;

		pr = cont.editAction();
		System.assert(pr.getURL() == ('/' + rec.Id + '/e'));

		pr = cont.saveAction();
		System.assert(pr.getURL() == ('/' + rec.id));

		pr = cont.cancelAction();
		System.assert(pr.getURL() == ('/' + rec.id));

		pr = cont.deleteAction();
		System.assert(pr.getURL() == ('/' + rec.FCM_BOM__c));
		System.assert([SELECT Id FROM FCM_Match_Condition__c WHERE Id=:recId].size() == 0);
	}

	public static testmethod void testExistingProcessRecord()
	{
		List<FCM_Match_Condition__c> values = setupTest();
		FCM_Match_Condition__c rec = values[4];
		String recId = rec.Id;

		ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(rec);
		FCMMatchConditionController cont = new FCMMatchConditionController(sc);
		cont.setupAction();

		PageReference pr;

		pr = cont.editAction();
		System.assert(pr.getURL() == ('/' + rec.Id + '/e'));

		pr = cont.saveAction();
		System.assert(pr.getURL() == ('/' + rec.id));

		pr = cont.cancelAction();
		System.assert(pr.getURL() == ('/' + rec.id));

		pr = cont.deleteAction();
		System.assert(pr.getURL() == ('/' + rec.FCM_Process__c));
		System.assert([SELECT Id FROM FCM_Match_Condition__c WHERE Id=:recId].size() == 0);
	}

	public static testmethod void testNewRecord()
	{
		List<FCM_Match_Condition__c> values = setupTest();
		String bomId = values[0].FCM_BOM__c;
		PageUtil.putParam('bomId', bomId);

		FCM_Match_Condition__c rec = new FCM_Match_Condition__c();
		ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(rec);
		FCMMatchConditionController cont = new FCMMatchConditionController(sc);
		cont.setupAction();
		PageReference pr = cont.saveAction();

		//remove the slash in front
		String recId = pr.getURL().substring(1);

		FCM_Match_Condition__c value = [SELECT Id, FCM_BOM__c FROM FCM_Match_Condition__c WHERE Id=:recId];
		System.assert(value.FCM_BOM__c == bomId);


	}

	private static List<FCM_Match_Condition__c> setupTest()
	{
		Product_Group__c pg = SharedUnitTestUtils.createProductGroupFromName('UnitTest', false);
		insert pg;

		List<CM_Version__c> verList = new List<CM_Version__c>();

		verList.add(new CM_Version__c(Product_Group__c=pg.Id, Status__c='Active', Version__c=3));
		insert verList;

		FCM_BOM__c bom = new FCM_BOM__c(CM_Version__c=verList[0].Id);
		insert bom;

		FCM_Process__c process = new FCM_Process__c(CM_Version__c=verList[0].Id);
		insert process;

		List<FCM_Match_Condition__c> values = new List<FCM_Match_Condition__c>();
		for (CM_Version__c ver : verList)
		{
			
			values.add(new FCM_Match_Condition__c(FCM_BOM__c=bom.Id, Match_Type__c='ItemTextValue'));
			values.add(new FCM_Match_Condition__c(FCM_BOM__c=bom.Id, Match_Type__c='ItemNumberValue'));
			values.add(new FCM_Match_Condition__c(FCM_BOM__c=bom.Id, Match_Type__c='ItemBoolean'));

			values.add(new FCM_Match_Condition__c(FCM_Process__c=process.Id, Match_Type__c='ItemTextValue'));
			values.add(new FCM_Match_Condition__c(FCM_Process__c=process.Id, Match_Type__c='ItemNumberValue'));
			values.add(new FCM_Match_Condition__c(FCM_Process__c=process.Id, Match_Type__c='ItemBoolean'));
		}

		insert values;
		
		return values;
	}
}