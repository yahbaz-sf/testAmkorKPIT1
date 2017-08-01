/*************************************************************************
* 
* PURPOSE:  This class tests the Dual leadframe installer 
*         
* CLASS: DualLeadframeInstallerTest
* CREATED: 03/12/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Nathan Pilkington
* 
**************************************************************************/


@isTest
private class DualLeadframeInstallerTest {

    static testMethod void testInstall() {
    	
    	//---Install the admin package that these tests are dependent upon
    	
    	RFQAdminInstaller.install();
    	
    	//--- Test no product groups yet
        List<Product_Group__c> prodGroup = [select Id from Product_Group__c where Name =: 'Dual Leadframe'];
        System.assertEquals(prodGroup.size(), 0);
        
        //---Install the package groups and package families, field items
        DualLeadframeInstaller.install();
        prodGroup = [select Id from Product_Group__c where Name =: 'Dual Leadframe'];
        
        //---Test only one dual leadframe installed
        System.assertEquals(prodGroup.size(), 1);
        
        //---Test if some PFs have been installed
        List<Package_Family__c> families = [select Id, Name from Package_Family__c where Product_Group__c = :prodGroup[0].Id];
        
        System.assertNotEquals(families.size(), 0);
        
        //---Test if some field defs have been installed for each family
        for (Package_Family__c family : families)
        {
        	List<RFQI_PF_Field_Def__c> pfFieldDefs = [select Id, CPN_Attribute__c from RFQI_PF_Field_Def__c where Package_Family__c = :family.Id];
        	System.assertNotEquals(pfFieldDefs.size(), 0, 'Package family ' + family.Name);
        	
        	Integer foundCpnAttribs = 0;
        	
        	for (RFQI_PF_Field_Def__c fieldDef : pfFieldDefs) {
        		if (fieldDef.CPN_Attribute__c) foundCpnAttribs++;
        	}
        	
        	System.assertNotEquals(foundCpnAttribs, 0, 'Package family ' + family.Name + ' should have at least 1 CPN attribute');
        }

        Test.startTest();
        DualLeadframeInstaller.installDLFDefaultDrivers();
        for (Package_Family__c family : families)
        {
            List<RFQI_Default_Driver__c> drivers = [select Id from RFQI_Default_Driver__c where Package_Family__c = :family.Id];
            System.assertNotEquals(drivers.size(), 0, 'Package family ' + family.Name);
        }

        Test.stopTest();
    }

    public static testMethod void installForTest()
    {
        RFQAdminInstaller.install();
        DualLeadframeInstaller.installTest();
        List<Product_Group__c> prodGroup = [select Id from Product_Group__c where Name =: 'Dual Leadframe'];
        
        //---Test only one dual leadframe installed
        System.assertEquals(prodGroup.size(), 1);

         //---Test if some PFs have been installed
        List<Package_Family__c> families = [select Id, Name from Package_Family__c where Product_Group__c = :prodGroup[0].Id];
        
        System.assertNotEquals(families.size(), 0);

        DualLeadframeInstaller.installDLFDefaultDriversTest();
        for (Package_Family__c family : families)
        {
            List<RFQI_Default_Driver__c> drivers = [select Id from RFQI_Default_Driver__c where Package_Family__c = :family.Id];
            System.assertNotEquals(drivers.size(), 0, 'Package family ' + family.Name);
        }


    }
}