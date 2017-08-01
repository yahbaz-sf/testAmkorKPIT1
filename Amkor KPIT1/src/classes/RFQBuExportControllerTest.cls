/*************************************************************************
* 
* PURPOSE:  This class tests the RFQBuExportController
* CLASS: RFQBuExportControllerTest
* CREATED: 4/17/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Nathan Pilkington npilkington@ethos.com
* 
**************************************************************************/

@isTest
private class RFQBuExportControllerTest {

    static testMethod void testRfqBuExportController() {
        RFQAdminInstaller.install();
        PBGAInstaller.install();
        CABGAInstaller.install();

        RFQItemWrapper item = SharedUnitTestUtils.createLineItem('PBGA');
        item.volumeList.add(new RFQIVolume(false));
        item.rfqItem.Multi_Volume__c = JSON.serialize(item.volumeList);
        update item.rfqItem;

        RFQ_Item__c lineItem = [Select Id, RFQ__c, Package_Family__c from RFQ_Item__c];
        /*
        //Bhanu 20 July 2016 Increasing Code coverage starts
        Test.startTest();
        ApexPages.currentPage().getParameters().put('rfqId',lineItem.RFQ__c); 
        ApexPages.currentPage().getParameters().put('selectedIds',lineItem.id);
        ApexPages.currentPage().getParameters().put('pfId',lineItem.Package_Family__c);         
        RFQBuExportController contwithoutid = new RFQBuExportController();
        Test.stopTest();
        
        stacktrace for error - 
        Error Message   System.NullPointerException: Attempt to de-reference a null object
        Stack Trace Class.RFQItemWrapper.calculateAttributeVisibility: line 495, column 1
        Class.RFQBuExportController.setupLayout: line 380, column 1
        Class.RFQBuExportController.<init>: line 97, column 1
        Class.RFQBuExportControllerTest.testRfqBuExportController: line 30, column 1
        //Bhanu 20 July 2016 Increasing Code coverage ends
        */        
        ApexPages.currentPage().getParameters().put('id',lineItem.Id); 
        RFQBuExportController cont = new RFQBuExportController();
        List<RFQItemWrapper> itemList = cont.wrappers;
        System.assert(itemList.size() == 1, 'Should have one item wrapper');


        System.assert(!StringUtils.isBlank(cont.csvOutput), 'Should have some CSV output');


        // Test AMK-1711, include blank wire/die columns on CSV for CABGA even if no wire/die objects

        Test.startTest();
        RFQItemWrapper cabgaItem = SharedUnitTestUtils.createLineItem('CABGA');
        RFQItemDao.createDieObject(cabgaItem.packageFamily, cabgaItem.specificRfqItem.Id,1);
        cabgaItem = RFQItemDao.getInstance().getWrapperById(cabgaItem.rfqItem.Id);
        PageUtil.putParam('id', cabgaItem.rfqItem.Id);
        cont = new RFQBuExportController();
        String csvOutput = cont.csvOutput;
        Test.stopTest();

        System.assert(!StringUtils.isBlank(csvOutput), 'Should have some CSV output');
        System.assertEquals(cabgaItem.wireConfigurations.size(), 1, 'Should have only one wire configuration');
        System.assertEquals(cabgaItem.dieConfigurations.size(), 1, 'Should only have one die config');
        System.assert(csvOutput.contains('Number of Wires 2'), 'Should have a second number of wires column even though there is only one wire config');
        System.assert(csvOutput.contains('Laser Groove 4'), 'Should have a fourth laser groove even though only one die config');
        /*
        //Bhanu 20 July 2016 Increasing Code coverage starts
        cont.getRemoteFieldValues(item, 'Quoted_Status__c');
        Stack Trace :
        Error Message   System.NullPointerException: Attempt to de-reference a null object
        Class.RFQBuExportController.getRemoteFieldValues: line 440, column 1
        Class.RFQBuExportControllerTest.testRfqBuExportController: line 68, column 1
        //Bhanu 20 July 2016 Increasing Code coverage ends
        */
    }
}