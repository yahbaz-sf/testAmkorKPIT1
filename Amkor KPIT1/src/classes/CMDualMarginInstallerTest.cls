@isTest
private class CMDualMarginInstallerTest {

    private static testmethod void testInstaller() {
	    
 		RFQAdminInstaller.install();
 		DualLeadframeInstaller.installTest();
	    CMDualInstaller.install();

	    Test.startTest();
	    
		CMDualMarginInstaller.install();
	    Test.stopTest();
	}


}