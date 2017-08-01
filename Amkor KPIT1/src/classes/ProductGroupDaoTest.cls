/*************************************************************************
*
* PURPOSE: Unit Tests for Product_Group__c 
*
* CLASS: ProductGroupDaoTest
* CREATED: 3/07/2012 Ethos Solutions - www.ethos.com
* AUTHOR: Jason M. Swenski
***************************************************************************/
@isTest
private class ProductGroupDaoTest {
	
	/**
    * Tests getting all available Product Groups
    */
	private static testmethod void testGetAllProductGroups() {
		
		Product_Group__c prodGroup = SharedUnitTestUtils.createTestProductGroup();
		List<Product_Group__c> allGroups = ProductGroupDao.getInstance().getAllProductGroups();
		System.assert(allGroups.size() > 0);
	}
	
	/**
    * Tests getting a particular Product_Group__c by Id
    */
	private static testmethod void testGetById() {
		
		Product_Group__c prodGroup = SharedUnitTestUtils.createTestProductGroup();
		Product_Group__c otherProdGroup = ProductGroupDao.getInstance().getById(prodGroup.Id);
		System.assert(prodGroup.Name == otherProdGroup.Name);
		System.assert(prodGroup.Id == otherProdGroup.Id);		
	}

	private static testmethod void testGetAllProductGroupByRfq() {
		Product_Group__c testProdGroup = SharedUnitTestUtils.createTestProductGroup();
		RFQItemWrapper wrapper = SharedUnitTestUtils.createLineItem('Unit Test Package Family');
		Set<Product_Group__c> pgs = ProductGroupDao.getInstance().getAllProductGroupByRfq(wrapper.rfqItem.RFQ__r.Id);
		system.assert(pgs.size() == 1);
		system.assert(pgs.contains(wrapper.productGroup));
	}
}