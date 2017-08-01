/*************************************************************************
*
* PURPOSE: Tests the RFQImportController
*
* CLASS: RFQImportController
* CREATED: 3/28/2012 Ethos Solutions - www.ethos.com
* AUTHOR: Nathan Pilkington
***************************************************************************/
@isTest
private class RFQImportControllerTest {

    static testMethod void testRfqImportProcess() {
        // setupTestData();
        
        // Setup reference data
        
        RFQAdminInstaller.install(); 
        DualLeadframeInstaller.installTest(); 
        
        Package_Family__c pf = [Select Id from Package_Family__c where Name = 'SOIC 150mil Body'];
        Product_Group__c pg = [Select Id from Product_Group__c where Name = 'Dual Leadframe'];
        RFQI_PF_Field_Def__c fieldDef = [Select Id from RFQI_PF_Field_Def__c where Package_Family__c = :pf.Id and RFQI_Field_Def__r.Name = 'Lead_Count__c'];
        
        // Setup Test data
        Account a = SharedUnitTestUtils.createTestSBU();
        
        String rtId = AccountFileMapDao.getInstance().getActiveRtId();
        
        RFQ_Ac_Map__c acMap = new RFQ_Ac_Map__c(Name='Test Map',RecordTypeId=rtId,Account__c=a.Id,Device_Name_Column__c='Device Name',Version__c=1);
        
        insert acMap;
    
        RFQ_Ac_Map_Pf__c pfMap = new RFQ_Ac_Map_Pf__c(Account_Device_Name__c='150 Mil',Package_Family__c=pf.Id,Product_Group__c=pg.Id,RFQ_Ac_Map__c=acMap.Id);
        
        insert pfMap;
        
        RFQ_Ac_Map_Pf_Column__c column1 = new RFQ_Ac_Map_Pf_Column__c();
        column1.RFQ_Ac_Map_Column__c = 'Lead Count';
        column1.RFQ_Ac_Map_Pf__c = pfMap.Id;
        column1.RFQI_PF_Field_Def__c = fieldDef.Id;
        
        insert column1;
        
        //Bhanu - 3-Mar-2016 : 597492 Missing NRE on EXCEL + "Projected_Revenue__c" is now mandatory
        //Providing Mandatory field "Projected_Revenue__c" on RFQ Object in TestSetup       
        //RFQ__c testRfq = new RFQ__c(SBU_Name__c=a.Id,RFQ_Name__c='Import test RFQ');
        RFQ__c testRfq = new RFQ__c(SBU_Name__c=a.Id,RFQ_Name__c='Import test RFQ', Projected_Revenue__c = 1234);
        insert testRfq;
        
        
        String testFile = 'Device Name,Lead Count\n150 Mil,10\n150 Mil,20';
        Blob testBlob = Blob.valueOf(testFile);
        
        // Start test

        Test.startTest();
        
        // Test when no RFQ specified
        RFQImportController cont = new RFQImportController();
        System.assertEquals(cont.currentStep, 0);
        
        ApexPages.currentPage().getParameters().put('rfqId', testRfq.Id);
        cont = new RFQImportController();
        
        List<SelectOption> mapOptions = cont.getMappingOptions();
        
        System.assertNotEquals(mapOptions.size(), 0, 'Should have some account map options'); 
        
        PageReference pr = cont.returnToRfq();
        System.assertNotEquals(pr, null, 'Should have returned to rfq page');
        
        pr = cont.returnToMapSelect();
        System.assertEquals(pr, null, 'Should stay on same page');
        
        // Select a mapping
        
        cont.selectedMapId = acMap.Id;
        pr = cont.mappingSelected();
        System.assertEquals(cont.currentStep, 2, 'Should have advanced to next step');
        
        // Select a file
        
        cont.fileContent = testBlob;
        cont.fileName = 'TestFile.csv';
        
        pr = cont.fileSelected();


        System.assertEquals(pr, null, 'Should stay on the same page to start the AJAX postback process');
        
        System.assertNotEquals(cont.attachmentId, null, 'Should have stored the attachment ID so AJAX Postbacks can grab the attachment');

        List<Attachment> atList = [Select Id from Attachment];
        System.assertNotEquals(atList.size(), 0, 'Should have attached a file to the RFQ');


        PageUtil.putParam('attachId', cont.attachmentId);
        PageUtil.putParam('accountMapId', cont.accountMap.Id);

        cont.processNextBatch();

        List<RFQ_Item__c> rfqItems = [Select Id, Status__c from RFQ_Item__c where RFQ__c =: testRfq.Id and Status__c =: RFQItemDao.STATUS_IMPORT_PENDING];
        System.assertNotEquals(rfqItems.size(), 0, 'Should have created some RFQ Items that are pending defaults');

        PageUtil.putParam('rfqId', testRfq.Id);
        ImportDefaultsController defaultsController = new ImportDefaultsController();

        System.assertEquals(defaultsController.numberRemaining, rfqItems.size(), 'The number of records remaining to process should be equal to the pending import items for the RFQ');

        defaultsController.submitNextItem();

        List<RFQ_Item__c> remainingRfqItems = [Select Id, Status__c from RFQ_Item__c where RFQ__c =: testRfq.Id and Status__c =: RFQItemDao.STATUS_IMPORT_PENDING];

        System.assertNotEquals(remainingRfqItems.size(), rfqItems.size(), 'Should have processed one of the items');
        
        //Bhanu 21 July 2016 Increasing Code coverage starts
        cont.buViewRedirect();
        cont.deleteIncompleteRecords();
        cont.resumeProcessing();
        //cont.cleanupBadImport(testRfq.Id);
        //Bhanu 21 July 2016 Increasing Code coverage ends
        
        Test.stopTest();
    }
    

}