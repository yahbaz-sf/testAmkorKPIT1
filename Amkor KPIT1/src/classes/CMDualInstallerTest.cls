/*************************************************************************
*
* PURPOSE: Test code for CMDualInstaller
*
* CLASS: CMDualInstallerTest
* CREATED: 5/01/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Steve Simpson
***************************************************************************/
@isTest
public with sharing class CMDualInstallerTest 
{
	public final static String PRODUCT_GROUP = 'Dual Leadframe';
	static testMethod void testInstall() 
	{
		RFQAdminInstaller.install();
		DualLeadframeInstaller.installTest();
        CMDualInstaller.install();

		Test.startTest();
		

		List<FCM_Assumption__c> assumptionList = [select id from FCM_Assumption__c where Product_Group__r.name=:PRODUCT_GROUP];
		System.assert(assumptionList.size() > 0);

		List<FCM_BOM__c> bomList = [select id from FCM_BOM__c where Product_Group__r.Name=:PRODUCT_GROUP];
		System.assert(bomList.size() > 0);

		List<FCM_Process__c> procList = [select id from FCM_Process__c where Product_Group__r.Name=:PRODUCT_GROUP];
		System.assert(procList.size() > 0);

		List<FCM_Match_Condition__c> matchList = [select id from FCM_Match_Condition__c where FCM_BOM__r.Product_Group__r.Name=:PRODUCT_GROUP OR FCM_Process__r.Product_Group__r.Name=:PRODUCT_GROUP];
		System.assert(matchList.size() > 0);

		Test.stopTest();
	}
}