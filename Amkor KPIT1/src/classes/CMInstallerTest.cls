/*************************************************************************
*
* PURPOSE: Test code for CMInstaller
*
* CLASS: CMInstallerTest
* CREATED: 5/01/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Steve Simpson
***************************************************************************/
@isTest
public with sharing class CMInstallerTest 
{
    static testMethod void testClean() {
        Test.startTest();
        CMInstaller.clean();
        Test.stopTest();
	}

	static testMethod void testInstallDual()  {
		
        RFQAdminInstaller.install();
        DualLeadframeInstaller.installTest();

		Test.startTest();
		CMInstaller.installDual();
		Test.stopTest();
	}

	static testMethod void testInstallQuad()  {
		
        RFQAdminInstaller.install();
        QuadLeadframeInstaller.install();

		Test.startTest();
		CMInstaller.installQuad();
		Test.stopTest();
	}

	static testMethod void testInstallMLF()  {
		
        RFQAdminInstaller.install();
        MLFInstaller.install();

		Test.startTest();
		CMInstaller.installMLF();
		Test.stopTest();
	}


}