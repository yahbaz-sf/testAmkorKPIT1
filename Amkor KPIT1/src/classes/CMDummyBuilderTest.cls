@isTest
private class CMDummyBuilderTest {
    private static CMDummyBuilder CMDbuilder;
    
    @isTest
    Private static void Test1(){
        RFQAdminInstaller.install();
        //RFQAdminInstaller.installAccounts();
        RFQAdminInstaller.installFactories();
        //RFQAdminInstaller.installRFQSystemSettings();
        MEMSInstaller.install();

        //Bharat - 26-Apr-2017: SF-139: Cavity MEMS Sales RFQ Item Create screens.
        //Re-naming 'Cavity MEMS' to 'MEMS' package family.
        RFQItemWrapper wrapper = SharedUnitTestUtils.createLineItem('MEMS');
        RFQILayout layout = setupLayout(wrapper);
        
        
        CMDbuilder = new CMDummyBuilder();
        CMDbuilder.setEditabilityforNoCostModel(layout);
        CMDbuilder.onAttributeChange(wrapper, '');
        CMDbuilder.loadSettings(wrapper,false);
       
        
        
    }
    
     private static RFQILayout setupLayout(RFQItemWrapper wrapper)
    {
        RFQILayout layout = PFFieldDefDao.getInstance().getPackageFamilyLayout(wrapper.packageFamily.Id, wrapper.packageFamily.Layout_Version__c, (Decimal)wrapper.rfqItem.get('Layout_Version__c'));

        return layout;
    }

}