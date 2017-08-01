@isTest
public class CMMarginVersionControllerTest
{
	public static testmethod void testPage1()
	{
		List<CM_Margin_Version__c> vers = setupTest();
		ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(vers[2]);
		CMMarginVersionController cont = new CMMarginVersionController(sc);
		cont.setupViewAction();
		System.assert(!cont.isNew, 'Record exists');
		System.assert(cont.hasPending, 'Pending version was added');
		System.assert(cont.hasActive, 'Pending version was added');

		PageReference pr;

		pr = cont.editAction();
		System.assert(pr.getURL().contains('/' + vers[2].Id + '/e'));

		pr = cont.showPendingAction();
		System.assert(pr.getURL().contains('/' + vers[3].Id));

		pr = cont.showActiveAction();
		System.assert(pr.getURL().contains('/' + vers[2].Id));

		pr = cont.makePendingAction();
		System.assert(pr == null, 'Pending version exists');

		pr = cont.makeActiveAction();
		System.assert(pr == null, 'Cannot make active version pending');

		pr = cont.deleteAction();
		System.assert(pr == null, 'Cannot delete active version');

		pr = cont.saveAction();
		System.assert(pr.getURL().contains('/' + vers[2].Id));

		pr = cont.cancelAction();
		System.assert(pr.getURL().contains('/' + vers[2].Id));

		ApexPages.currentPage().getParameters().put('pgId', vers[2].Product_Group__c);

		pr = cont.viewActiveListAction();
		System.assert(pr.getURL().contains('/' + vers[2].Id));

		pr = cont.viewPendingListAction();
		System.assert(pr.getURL().contains('/' + vers[3].Id));

		//delete pending version
		delete vers[3];

		//made a new pending version
		pr = cont.viewPendingListAction();
		List<CM_Margin_Version__c> verList = CMMarginVersionDao.getInstance().getByPGAndStatus(vers[2].Product_Group__c, 'Pending');
		System.assert(pr.getURL().contains('/' + verList[0].Id));


	}

	private static List<CM_Margin_Version__c> setupTest()
	{
		Product_Group__c pg = SharedUnitTestUtils.createProductGroupFromName('UnitTest', false);
		insert pg;

		List<CM_Margin_Version__c> verList = new List<CM_Margin_Version__c>();

		verList.add(new CM_Margin_Version__c(Product_Group__c=pg.Id, Status__c='Archived', Version__c=1));
		verList.add(new CM_Margin_Version__c(Product_Group__c=pg.Id, Status__c='Deleted', Version__c=1));
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
		
		return verList;
	}

}