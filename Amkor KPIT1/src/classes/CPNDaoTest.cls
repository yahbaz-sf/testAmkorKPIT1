/*************************************************************************
* 
* PURPOSE: Test methods for CPNDao 
*          
* CLASS: CPNDaoTest
* CREATED: 03/19/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Raghuveer Mandali
* 
**************************************************************************/
@isTest
private class CPNDaoTest {

    /**
    * Tests getInstance for CPNDao
    */
    private static testmethod void setupController(){
    	RFQAdminInstaller.install();
        FCCSPInstaller.install();
        RFQItemWrapper wrapper = SharedUnitTestUtils.createLineItem('FC SCSP', 1, 1, 0, 1);
        CPN cpn = CPNDao.getInstance().getCPN(wrapper);
        wrapper.rfqItem.Configured_Part_Number__c = cpn.cpnId;
        RFQItemDao.getInstance().saveLineItem(wrapper);
        system.assert(wrapper.rfqItem.Configured_Part_Number__c == cpn.cpnId);
    }
    
    /**
    * Tests getCPNByAttributes for CPNDao
    */
    /*private static testmethod void testgetCPNByAttributes(){
    	CPNDao cd = CPNDao.getInstance();
    	sObject item = SharedUnitTestUtils.createTestRFQ();
    	List<sObject> wc = new List<sObject>();
    	Package_Family__c pf = SharedUnitTestUtils.createTestPackageFamily();
    	system.assert(cd.getCPNByAttributes(item, wc, pf) != null);

    	
    	
   }*/
}