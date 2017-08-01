/*************************************************************************
*
* PURPOSE: Unit Tests for PackageFamilyDao
*
* CLASS: PackageFamilyDaoTest
* CREATED: 3/06/2012 Ethos Solutions - www.ethos.com
* AUTHOR: Jason M. Swenski
***************************************************************************/
@isTest
private class PackageFamilyDaoTest {
	
	/**
    * Tests the PackageFamilyDao getting a list of families by related group
    */
	private static testmethod void testGetByGroup() {
		
		Product_Group__c prodGroup = SharedUnitTestUtils.createTestProductGroup();
		List<Package_Family__c> families 
		    = PackageFamilyDao.getInstance().getFamiliesByProductGroup(prodGroup.Id);
		System.assert(families.size() > 0);
	}
	
	/**
    * Tests getting a particular Package_Family__c by Id
    */
	private static testmethod void testGetById() {
		
		Package_Family__c family = SharedUnitTestUtils.createTestPackageFamily();
		Package_Family__c otherFamily = PackageFamilyDao.getInstance().getById(family.Id);	
		System.assert(family.Id == otherFamily.Id);
		System.assert(family.Name == otherFamily.Name);
	
	}

}