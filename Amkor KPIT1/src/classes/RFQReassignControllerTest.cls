/*************************************************************************
*
* PURPOSE: Test the methods in RFQReassignController.cls
*
* CLASS: RFQReassignControllerTest
* CREATED: 10/8/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Joe DePetro
***************************************************************************/
@isTest
private class RFQReassignControllerTest {
	
	private static string retUrlStr
	{
		get {  return '/apex/RFQProcessInstance';}
	}

	private static testMethod void testNullSetup()
	{
		RFQReassignController reassignController = new RFQReassignController();
		Test.startTest();
    	System.assert(reassignController.isApproverUser == true);
    	reassignController.loadAction();
    	System.assert(reassignController.workItem == null);
		Test.stopTest();
	}

	private static testMethod void testSetup()
	{
		Test.startTest();

		RFQReassignController reassignController = setupController();
    	System.assert(reassignController.isApproverUser == true);
    	reassignController.loadAction();
    	System.assert(reassignController.workItem != null);
    	
		Test.stopTest();
	}

	private static testMethod void testReassign()
	{
		RFQReassignController reassignController = setupController();
		Test.startTest();
		reassignController.loadAction();

		PageReference pr = reassignController.Reassign();
		System.assert(pr != null);
		System.assert(pr.getUrl() == retUrlStr);

		//-- now we have to test an approval process that is assigned to a user and not a group as
		//-- it was above.

		Test.stopTest();
	}

	private static testMethod void testHelperMethods()
	{

		RFQReassignController reassignController = setupController();
		Test.startTest();
		reassignController.loadAction();
		PageReference pr = reassignController.cancel();
    	System.assert(pr != null);
    	System.assert(pr.getUrl() == retUrlStr);

    	List<SelectOption> optList = reassignController.getQueuesList();
    	System.assert(optList != null);
    	System.assert(optList.size() > 0);

    	reassignController.isUserStr = 'User';
    	pr = reassignController.updateIsUser();
    	System.assert(pr == null);
    	System.assert(reassignController.isApproverUser == true);
    	reassignController.isUserStr = 'Test';
    	pr = reassignController.updateIsUser();
    	System.assert(pr == null);
    	System.assert(reassignController.isApproverUser == false);
    	Test.stopTest();
	}

	private static RFQReassignController setupController() 
	{
		RFQItemWrapper wrapper = SharedUnitTestUtils.createPfAndLineItem();
        ApprovalUtils.startApproval(wrapper.rfqItem.Id,'test');
		ApexPages.currentPage().getParameters().put('id',wrapper.rfqItem.Id);
		ApexPages.currentPage().getParameters().put('retURL',retUrlStr);
		RFQReassignController cont = new RFQReassignController();
		return cont;
	}
	

}