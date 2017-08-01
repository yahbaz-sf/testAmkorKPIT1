/*************************************************************************
*
* PURPOSE: Tests the RFQExportController Class
*
* CLASS: RFQExportControllerTest
* CREATED: 3/28/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Nathan Pilkington
***************************************************************************/

@isTest
private class RFQExportControllerTest {

    static testMethod void testRfqExport() {
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
        ApexPages.currentPage().getParameters().put('rfqId', testRfq.Id);
        RFQImportController cont = new RFQImportController();
        cont.fileContent = testBlob;
        cont.fileName = 'TestFile.csv';
        
        cont.selectedMapId = acMap.Id;
        PageReference pr = cont.mappingSelected();
        pr = cont.fileSelected();
        
        Test.startTest();

        List<RFQ_Item__c> rfqItems = [Select Id from RFQ_Item__c where RFQ__c =: testRfq.Id];

        String selectedIds = '';
        for (Integer i = 0; i < rfqItems.size(); i++) {
            if (selectedIds.length() > 0) selectedIds += ',';
            selectedIds += rfqItems[i].Id;
        }

        ApexPages.currentPage().getParameters().put('selectedIds', selectedIds);
        
        RfqExportController exportController = new RfqExportController();
        
        String csvOutput = exportController.getCsvOutput();
        
        System.assertNotEquals(csvOutput.length(), 0);
        
        System.debug(LoggingLevel.INFO, '### CSV Output is: ' + csvOutput);
        
        Test.stopTest();
    }


    static testMethod void testExportSelectController() {
        RFQItemWrapper wrapper = SharedUnitTestUtils.createPfAndLineItem();


        ApexPages.currentPage().getParameters().put('rfqId', [Select Id from RFQ__c limit 1].Id);

        RFQExportSelectController c = new RFQExportSelectController();

        PageReference pf = c.cancel();
        System.assertNotEquals(c, null, 'Should have canceled');

        System.assertEquals(c.selectedFormat, 'MASTER', 'Was not created from a import so should auto-select master quote format');

        List<SelectOption> options = c.getFormatOptions();
        System.assertEquals(options.size(), 1, 'Should only be 1 format option since only master is available');

        options = c.getExportOptions();
        System.assertEquals(options.size(), 2, 'Should have all and selected modes available');

        List<RFQItemHolder> selectItems = c.getSelectableItems();
        System.assertEquals(selectItems.size(), 1, 'Should only be 1 item available to select');

        c.selectionMode = 'ALL'; 

        pf = c.export();
        System.assertEquals(pf, null, 'Should have stayed on same page after export');
        System.assert(c.wasExported, 'Should now be in an exported state');

        List<attachment> attList = [Select Id from Attachment];
        System.assertEquals(attList.size(), 1, 'Should now have a single attachment for the CSV file: BU: ' + RFQSystemSettings.getIsBUUser());
    }


    static testMethod void testExportSelectControllerAMK1374() {
        
        RFQ_System_Settings__c sys = new RFQ_System_Settings__c(Is_BU_Profile__c=true,Name=UserInfo.getProfileId());
        insert sys;
       
        RFQItemWrapper wrapper = SharedUnitTestUtils.createPfAndLineItem();
        ApexPages.currentPage().getParameters().put('rfqId', [Select Id from RFQ__c limit 1].Id);

        Test.startTest();
        RFQExportSelectController c = new RFQExportSelectController();
        c.selectionMode = 'ALL'; 
        PageReference pf = c.cancel();
        pf = c.export();
      
        List<attachment> attList = [Select Id,ContentType,Name from Attachment];
        for(Attachment a : attList)
        System.assert(!a.Name.contains('.pdf'), 'BU Should not be able to Gen PDF even on export CSV. BU: ' + RFQSystemSettings.getIsBUUser());
        Test.stopTest();


    }
}