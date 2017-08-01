/*************************************************************************
*
* PURPOSE: This class handles unit testing for routing for RFQ Line Items 
*          in non draft mode. 
*
* CLASS: RFQItemApprovalControllerTest
* CREATED: 4/26/2012 Ethos Solutions - www.ethos.com
* AUTHOR: Jason M. Swenski
***************************************************************************/
@isTest
private class RFQItemApprovalRoutingTest {

    private static testmethod void testRoutePre() {
   
    	RFQAdminInstaller.install();
    	PBGAInstaller.installTest();
    
        Package_Family__c packageFam = [select Id from Package_Family__c where Name =: 'PBGA'];
    	packageFam.No_Cost_Model__c = true;	
    	update packageFam;
    	
    	RFQItemWrapper wrapper = SharedUnitTestUtils.createLineItem('PBGA');
    	wrapper.rfqItem.Status__c = RFQItemDao.STATUS_PRICE_SUBMIT;
    	RFQItemDao.getInstance().saveLineItem(wrapper);
    
    	Test.startTest();
    		
    	RFQItemApprovalRouting router = new RFQItemApprovalRouting();
    	
    	RFQItemApprovalRouting.RFQItemRoute itemRoute = router.route(wrapper);
    	
    	System.assert(itemRoute.itemRouteType == RFQItemApprovalRouting.RoutingType.PRE_APPROVAL);
    	//no approval so it should have failed;
    	//System.assert(!itemRoute.isSuccess);
    	
    	Test.stopTest();
    }
    

    private static testmethod void testRoutePost() {
    	
    	RFQAdminInstaller.install();
    	PBGAInstaller.install();
    	Product_Group__c prodGroup = [select Id from Product_Group__c where Name =: 'PBGA'];
    	prodGroup.Generated_Price_Requires_Sales_Review__c = true;	
    	update prodGroup;
    	
    	RFQItemWrapper wrapper = SharedUnitTestUtils.createLineItem('PBGA');
    	wrapper.rfqItem.Status__c = RFQItemDao.STATUS_PRICE_COMPLETE;
    	RFQItemApprovalRouting router = new RFQItemApprovalRouting();
    	Test.startTest();
    	
    	RFQItemApprovalRouting.RFQItemRoute itemRoute = router.route(wrapper);
    	
    	//better be post.    	
    	System.assert(itemRoute.itemRouteType == RFQItemApprovalRouting.RoutingType.POST_APPROVAL);
		//System.assert(itemRoute.approvalError == Label.RFQ_ERR_0006);
    	//no approval so it should have failed;
    	//System.assert(!itemRoute.isSuccess);
    	
    	Test.stopTest();
    }
    
    private static testmethod void testRouteNone() {
    	
    	RFQAdminInstaller.install();
    	PBGAInstaller.install();
    	
    	RFQItemWrapper wrapper = SharedUnitTestUtils.createLineItem('PBGA');
    	wrapper.rfqItem.Status__c = RFQItemDao.STATUS_PRICE_SUBMIT;
    	RFQItemApprovalRouting router = new RFQItemApprovalRouting();
    	Test.startTest();
    	
    	RFQItemApprovalRouting.RFQItemRoute itemRoute = router.route(wrapper);
    	
    	//better be post.
    	System.assert(itemRoute.itemRouteType == RFQItemApprovalRouting.RoutingType.NONE);
    	//no approval needed so it should still be marked as success
    	System.assert(itemRoute.isSuccess);
    	
    	Test.stopTest();
    }
}