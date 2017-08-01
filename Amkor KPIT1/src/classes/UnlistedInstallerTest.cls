/*************************************************************************
* 
* PURPOSE:  This class tests the UnlistedInstaller Test
*         
* CLASS: UnlistedInstallerTest
* CREATED: 08/05/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Raghuveer Mandali
* 
**************************************************************************/
@isTest
private class UnlistedInstallerTest {
	
	static testMethod void testInstall() {
        List<Product_Group__c> prodGroup = [select Id from Product_Group__c where Name =: 'Unlisted'];

        Test.startTest();
        RFQAdminInstaller.install();
        UnlistedInstaller.install();
	Test.stopTest();

        System.assertEquals(prodGroup.size(), 0);
        
        
        prodGroup = [select Id from Product_Group__c where Name =: 'Unlisted'];

        //---Test only one dual leadframe installed
        System.assertEquals(prodGroup.size(), 1);
        
        //---Test if some PFs have been installed
        List<Package_Family__c> families = [select Id, Name from Package_Family__c where Product_Group__c = :prodGroup[0].Id];
        
        System.assertNotEquals(families.size(), 0);
	}
}