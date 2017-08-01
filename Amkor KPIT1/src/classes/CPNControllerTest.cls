@isTest
private class CPNControllerTest {
	
	public static testMethod void testTransmit() {
        
        SAPInstaller.install();
    	SharedUnitTestUtils.createTestSBU();
    	RFQAdminInstaller.install();
    	PBGAInstaller.installTest();
    	RFQItemWrapper wrapper = SharedUnitTestUtils.createLineItem('PBGA');
    	CPN cpn = CPNDao.getInstance().getCPN(wrapper);
    	Configured_Part_Number__c cpnDBObj = CPNDao.getInstance().getById(cpn.cpnId);
    	ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(cpnDBObj);

    	CPNController cont = new CPNController(sc);
    	
    	Test.startTest();
    	Test.setMock(WebServiceMock.class, new SAPTransmitRespMock());
        cont.transmit();

    	Test.stopTest();
    	
    	List<SAP_Interface_Log__c> logItems = [Select Id,Message_Content__c,Status__c from SAP_Interface_Log__c];
        System.assertNotEquals(logItems.size(), 0, 'Should have inserted a log');
        
        Boolean foundMockResponse = false;
        for(SAP_Interface_Log__c item : logItems) {
        	if(item.Status__c == 'Success') {
        		foundMockResponse = true;
        		break;
        	}
        }
        System.assert(foundMockResponse, 'Should have gotten a mock response but did not find it');

        cpnDBObj = CPNDao.getInstance().getById(cpn.cpnId);
        System.assert(cpnDBObj.Status__c == 'Transmitted');
        
	}
}