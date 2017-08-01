/*************************************************************************
*
* PURPOSE: Test code for CMQuadInstaller
*
* CLASS: CMQuadInstallerTest
* CREATED: 5/01/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Steve Simpson
***************************************************************************/
@isTest
public with sharing class CMQuadInstallerTest 
{
	static testMethod void testInstall() {
        
        RFQAdminInstaller.install();
        QuadLeadframeInstaller.install();

        Test.startTest();
		CMQuadInstaller.install();
		Test.stopTest();
	}
}