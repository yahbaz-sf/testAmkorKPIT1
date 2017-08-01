/*************************************************************************
* 
* PURPOSE:  This class tests the SOIC150 installer 
*         
* CLASS: SOIC150InstallerTest
* CREATED: 08/05/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Raghuveer Mandali
* 
**************************************************************************/
@isTest
private class SOIC150InstallerTest {
	
	static testMethod void testInstall() {
		RFQAdminInstaller.install();

		List<Product_Group__c> prodGroup = [select Id from Product_Group__c where Name =: 'Dual Leadframe'];
        System.assertEquals(prodGroup.size(), 0);
        
        SOIC150Installer.install();
        prodGroup = [select Id from Product_Group__c where Name =: 'Dual Leadframe'];

        //---Test only one dual leadframe installed
        System.assertEquals(prodGroup.size(), 1);
        
        //---Test if some PFs have been installed
        List<Package_Family__c> families = [select Id, Name from Package_Family__c where Product_Group__c = :prodGroup[0].Id];
        
        System.assertNotEquals(families.size(), 0);
	}
	
	
	
}