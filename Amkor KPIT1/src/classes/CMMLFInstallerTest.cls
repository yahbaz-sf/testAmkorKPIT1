/*************************************************************************
*
* PURPOSE: Test code for CMMLFInstaller
*
* CLASS: CMMLFInstallerTest
* CREATED: 5/01/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Steve Simpson
***************************************************************************/
@isTest
public with sharing class CMMLFInstallerTest 
{
	static testMethod void testInstall() 
	{
		CMMLFInstaller.clean();
		//Make sure product group is zero
		List<Product_Group__c> prodGroup = [select Id from Product_Group__c where Name =: 'MLF'];
        System.assertEquals(prodGroup.size(), 0);
        
		//make sure no FCM data 
		List<FCM_Match_Condition__c> matchList = [select id from FCM_Match_Condition__c];
		System.assertEquals(matchList.size(), 0);
		List<FCM_BOM__c> bomList = [select id from FCM_BOM__c];
		System.assertEquals(bomList.size(), 0);
		
		List<FCM_Process__c> procList = [select id from FCM_Process__c];
		System.assertEquals(procList.size(), 0);			
		
		List<FCM_Assumption__c> assumptionList = [Select id from FCM_Assumption__c];
		System.assertEquals(assumptionList.size(), 0);
		
		List<CM_Version__c> verList = [select id from CM_Version__c];
		System.assertEquals(verList.size(), 0);
		
		//Install all dependent packages
		RFQAdminInstaller.install();
		MLFInstaller.install();
		CMMLFInstaller.install();
		
		prodGroup = [select Id from Product_Group__c where Name =: 'MLF'];
        
        //---Test only one quad leadframe installed
        System.assert(prodGroup.size() == 1);
		
		matchList = [select Id from FCM_Match_Condition__c];
		System.assert(matchList.size() > 0);
		
		
		bomList = [select id from FCM_BOM__c where Product_Group__c =: prodGroup[0].Id];
		System.assert(bomList.size() > 0);
		
		procList = [select id from FCM_Process__c where Product_Group__c =: prodGroup[0].Id];
		System.assert(procList.size() > 0);			
		
		assumptionList = [Select id from FCM_Assumption__c where Product_Group__c =: prodGroup[0].Id];
		System.assert(assumptionList.size() > 0);
		
		verList = [select id from CM_Version__c where Product_Group__c =: prodGroup[0].Id];
		System.assert(verList.size() > 0);
		
	     
        //---Test if some PFs have been installed
        List<Package_Family__c> families = [select Id, Name from Package_Family__c where Product_Group__c = :prodGroup[0].Id];
        
        System.assert(families.size() > 0);
        
        //---Test if some field defs have been installed for each family
        for (Package_Family__c family : families)
        {
        	List<RFQI_PF_Field_Def__c> pfFieldDefs = [select Id from RFQI_PF_Field_Def__c where Package_Family__c = :family.Id];
        	System.assertNotEquals(pfFieldDefs.size(), 0, 'Package family ' + family.Name);
        }
	}
	static testMethod void testIncrementalInstalls() 
	{
        
		//Install all dependent packages
		RFQAdminInstaller.install();
		MLFInstaller.install();
		CMMLFInstaller.install();
		CMMLFInstaller.incrementalInstall1();
		CMMLFInstaller.incrementalInstall_AMK1426();


		List<Product_Group__c> prodGroup = [select Id from Product_Group__c where Name =: 'MLF'];
		List<CM_Version__c> verList = [select id from CM_Version__c where Product_Group__c =: prodGroup[0].Id];
		System.assert(verList.size() > 1, 'Should be at least 2 - one active, one archived');
		
		List<FCM_Assumption__c> assumptionList = [Select id from FCM_Assumption__c where Product_Group__c =: prodGroup[0].Id];
		System.assert(assumptionList.size() > 0);

        
        
	}
}