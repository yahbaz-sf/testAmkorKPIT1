/*************************************************************************
* 
* PURPOSE:  This class tests the MEMS Installer
*         
* CLASS: MEMSInstallerTest
* CREATED: 08/05/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Raghuveer Mandali
* 
**************************************************************************/
@isTest
private class MEMSInstallerTest {

	static testMethod void testInstall() {
		RFQAdminInstaller.install();

		List<Product_Group__c> prodGroup = [select Id from Product_Group__c where Name =: 'MEMS'];
        System.assertEquals(prodGroup.size(), 0);
        
        MEMSInstaller.install();
        prodGroup = [select Id from Product_Group__c where Name =: 'MEMS'];

        //---Test only one dual leadframe installed
        System.assertEquals(prodGroup.size(), 1);
        
        //---Test if some PFs have been installed
        List<Package_Family__c> families = [select Id, Name from Package_Family__c where Product_Group__c = :prodGroup[0].Id];
        
        System.assertNotEquals(families.size(), 0);
	}
}