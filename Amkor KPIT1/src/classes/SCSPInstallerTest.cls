/*************************************************************************
* 
* PURPOSE:  This is a Test Class for the SCSPInstaller class (cloned
			from DualLeadframeInstallerTest)
*         
* CLASS: SCSPInstallerTest
* CREATED: 05/10/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Raghuveer Mandali
* 
**************************************************************************/
@isTest
private class SCSPInstallerTest {

    private static testMethod void testInstall() {
    	
        //---Install the admin package that these tests are dependent upon
    	
    	RFQAdminInstaller.install();
    	
    	//--- Test no product groups yet
        List<Product_Group__c> prodGroup = [select Id from Product_Group__c where Name =: 'SCSP'];
        System.assertEquals(prodGroup.size(), 0);
        
        //---Install the package groups and package families, field items
        SCSPInstaller.install();
        prodGroup = [select Id from Product_Group__c where Name =: 'SCSP'];
        
        //---Test only one SCSP installed
        System.assertEquals(prodGroup.size(), 1);
        
        //---Test if some PFs have been installed
        List<Package_Family__c> families = [select Id, Name from Package_Family__c where Product_Group__c = :prodGroup[0].Id];
        
        System.assertNotEquals(families.size(), 0);
        
        //---Test if some field defs have been installed for each family
        for (Package_Family__c family : families)
        {
        	List<RFQI_PF_Field_Def__c> pfFieldDefs = [select Id from RFQI_PF_Field_Def__c where Package_Family__c = :family.Id];
        	System.assertNotEquals(pfFieldDefs.size(), 0, 'Package family ' + family.Name);
        }

    }
}