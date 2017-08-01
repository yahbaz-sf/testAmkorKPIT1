/*************************************************************************
* 
* PURPOSE: Interface unit test methods for SAP integration Epic AMK-88
*          
* CLASS: SAPInterfaceTest
* CREATED: 03/04/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Jason Swenski 
* 
**************************************************************************/
@isTest
private class SAPInterfaceTest {
	private static String TEST_EMP_NUMBER = '12345';
    private static String TEST_EMP_NUMBER2 = '54321';
    private static String TEST_EMP_NUMBER3 = '12321';

	/**
    * Tests SAPInterface.updatePricingAttribute interface method
    */
	private static testMethod void updatePricingAttributeTest() {
		
		Test.startTest();
        SAPInterface.updatePricingAttribute(getTestSD26DTPricingAttribute());
        Test.stopTest();

        List<SAP_Interface_Log__c> logItems = [Select Id from SAP_Interface_Log__c];
        System.assertNotEquals(logItems.size(), 0, 'Should have inserted a log');
         
        List<SAP_Pricing_Attribute__c> attItems = [Select Id from SAP_Pricing_Attribute__c];
        System.assertNotEquals(attItems.size(), 0, 'Should have inserted an attribute record');
    }
    
    private static testMethod void updateCustomerHierarchyTest() {
    	Account child = new Account(Name='Test1', AccountNumber = '13');
    	Account parent = new Account(Name='Test2',AccountNumber = '14');
    	insert child;
    	insert parent;
    	
    	Test.startTest();
    	SAPInterface.updateCustomerHierarchy(getTestZICUSHIE01('13','14'));
    	Test.stopTest();

    	List<SAP_Interface_Log__c> logItems = [Select Id from SAP_Interface_Log__c];
        System.assertNotEquals(logItems.size(), 0, 'Should have inserted a log');
    
        child = (Account)[select Id,AccountNumber,ParentId from Account where Id =: child.Id];
        System.assert(child.ParentId == parent.Id);
     
    }
    
    /**
    * Tests SAPInterface.updateBillingItems interface method
    */
	private static testMethod void updateBillingItemsTest() {
		
        Test.startTest();
        SAPInterface.updateBillingItems(getTestSD25DTCustomerBilling());
        Test.stopTest();

        List<SAP_Interface_Log__c> logItems = [Select Id from SAP_Interface_Log__c];
        System.assertNotEquals(logItems.size(), 0, 'Should have inserted a log');
    }
    
    /**
    * Tests SAPInterface.updateCustomerMaster interface method
    */
    private static testMethod void customerMasterTest() {
    	
    	SAPInstaller.install();

        User user = null;

        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs ( thisUser ) {
    	
        	user = SharedUnitTestUtils.createTestUser();
        	user.SAP_Partner_Number__c = TEST_EMP_NUMBER;
        	update user;
        }
    	Id rtId = RecordTypeUtils.getRecordTypeId('Account', 'Approved');
        

        Test.startTest();
    	String testAccountNumber = 'ZZTESTACCOUNT_NUMBER1';
    	SAPInterface.updateCustomerMaster(getTestZIDEBMASDEBMAS06ZIDEBMASEXT(testAccountNumber));
        Test.stopTest();

    	List<SAP_Interface_Log__c> logItems = [Select Id from SAP_Interface_Log__c];
        System.assertNotEquals(logItems.size(), 0, 'Should have inserted a log');
        
        //should have also inserted an account
        List<Account> account = [select Id,AccountNumber,RecordTypeId,OwnerId from Account where AccountNumber =: testAccountNumber]; //Make it select the specific one
        System.assert(account.size() > 0);                                                                       //we created to prove AMK-672
        
 		System.assertEquals(account[0].OwnerId, user.Id, 'Account Owner Id should have been set properly');
        System.assertEquals(account[0].RecordTypeId,rtId ,'Interfaced accounts should be approved record type');
		account = [select Id,Incoterms_2__c from Account];
        System.assert(account.size() > 0);
        System.assert(account[0].Incoterms_2__c =='TESTINCO2'); //Test for AMK-695
    }

    /*
    * Tests the functionality of the if/else statement for number length checking and name assignment at Line 68 of SAPCustomerMasterController.cls (five digits)
    */

    private static testMethod void fiveDigitTest() {
        
        SAPInstaller.install();

        User user = null;

        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs ( thisUser ) {
        
            user = SharedUnitTestUtils.createTestUser();
            user.SAP_Partner_Number__c = TEST_EMP_NUMBER;
            update user;
        }
        Id rtId = RecordTypeUtils.getRecordTypeId('Account', 'Approved');
        

        Test.startTest();
        String testAccountNumber = '0000053193';
        SAPInterface.updateCustomerMaster(getTestZIDEBMASDEBMAS06ZIDEBMASEXT(testAccountNumber));
        
        Test.stopTest();

        List<SAP_Interface_Log__c> logItems = [Select Id from SAP_Interface_Log__c];
        System.assertNotEquals(logItems.size(), 0, 'Should have inserted a log');
        
        //should have also inserted an account
        List<Account> account = [select Name,Id,AccountNumber,RecordTypeId,OwnerId from Account where AccountNumber =: testAccountNumber]; //Make it select the specific one

        System.assertEquals(account.get(0).Name, 'Parent Account');

    }

    /*
    * Tests the functionality of the if/else statement for number length checking and name assignment at Line 68 of SAPCustomerMasterController.cls (three digits)
    */

    private static testMethod void threeDigitTest() {
        
        SAPInstaller.install();

        User user = null;

        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs ( thisUser ) {
        
            user = SharedUnitTestUtils.createTestUser();
            user.SAP_Partner_Number__c = TEST_EMP_NUMBER;
            update user;
        }
        Id rtId = RecordTypeUtils.getRecordTypeId('Account', 'Approved');
        

        Test.startTest();
        String testAccountNumber = '00000193';
        SAPInterface.updateCustomerMaster(getTestZIDEBMASDEBMAS06ZIDEBMASEXT(testAccountNumber));
        
        Test.stopTest();

        List<SAP_Interface_Log__c> logItems = [Select Id from SAP_Interface_Log__c];
        System.assertNotEquals(logItems.size(), 0, 'Should have inserted a log');
        
        //should have also inserted an account
        List<Account> account = [select Name,Id,AccountNumber,RecordTypeId,OwnerId from Account where AccountNumber =: testAccountNumber]; //Make it select the specific one

        System.assertEquals(account.get(0).Name, 'Test Account');

    }

     /**
    * Tests SAPInterface.updateCustomerMaster interface method
    */
    private static testMethod void customerMasterContactTest() {
        
        SAPInstaller.install();
        String accNumber = 'ZZTESTACCOUNT_NUMBER1';
        User user = null;
        User user2 = null;
        User user3 = null;
        User user4 = null;
        List<AccountTeamMember> mems = new List<AccountTeamMember>();
        Account parentAcct = new Account(Name='Parent',AccountNumber='ParentTest1', Sales_Region__c='East');
        insert parentAcct;
        Account newAccount = new Account(Name='Test',AccountNumber=accNumber, ParentId = parentAcct.Id, Sales_Region__c='East');
        insert newAccount;

        RFQ__c rfq = new RFQ__c();
        rfq.SBU_Name__c = newAccount.Id;
        rfq.RFQ_Name__c = 'Test RFQ';
        
        //Bhanu - 3-Mar-2016 : 597492 Missing NRE on EXCEL + "Projected_Revenue__c" is now mandatory
		//Providing Mandatory field "Projected_Revenue__c" on RFQ Object in TestSetup
		rfq.Projected_Revenue__c = 1234;		
        insert rfq;

        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs ( thisUser ) {
        
            user = SharedUnitTestUtils.createTestUser();
            user.SAP_Partner_Number__c = TEST_EMP_NUMBER;
            update user;
            user2 = SharedUnitTestUtils.createTestUser();
            user2.SAP_Partner_Number__c = TEST_EMP_NUMBER2;
            update user2;
            user3 = SharedUnitTestUtils.createTestUser();
            mems.add(new AccountTeamMember(AccountId = newAccount.Id, UserId = user3.Id, TeamMemberRole = 'Asia Sales Sup Tuse'));
            insert new RFQ__Share(ParentId=rfq.Id, UserOrGroupId = user3.Id,  AccessLevel = 'Edit', RowCause = Schema.RFQ__Share.RowCause.Account_Sharing__c);
            user4 = SharedUnitTestUtils.createTestUser();
            user4.SAP_Partner_Number__c = TEST_EMP_NUMBER3;
            update user4;
        }
        newAccount.Asia_Sales_Sup_Tuse__c = user3.Id;
        update newAccount;
        Id rtId = RecordTypeUtils.getRecordTypeId('Account', 'Approved');

        
        mems.add(new AccountTeamMember(AccountId = newAccount.Id, UserId = user.Id, TeamMemberRole = 'Executive VP'));
        mems.add(new AccountTeamMember(AccountId = newAccount.Id, UserId = user2.Id, TeamMemberRole = 'Central Quote Rep'));
        mems.add(new AccountTeamMember(AccountId = newAccount.Id, UserId = user4.Id, TeamMemberRole = 'Region Manager'));
        insert mems;
        
        Test.startTest();
        SAPInterface.updateCustomerMaster(getTestContactZIDEBMASDEBMAS06ZIDEBMASEXT(accNumber));
        Test.stopTest();


        List<SAP_Interface_Log__c> logItems = [Select Id from SAP_Interface_Log__c];
        System.assertNotEquals(logItems.size(), 0, 'Should have inserted a log');
        
        //make sure people section gets updated correctly 
        Account testAccount = [select Executive_VP_Admin__c,Regional_VP_Admin__c, Mid_Level_Manager__c, OwnerId, Asia_Sales_Sup_Tuse__c 
                                   from Account where AccountNumber =: accNumber];
        System.assertEquals(testAccount.Executive_VP_Admin__c,user2.Id);
        System.assertEquals(testAccount.Regional_VP_Admin__c,user2.Id);
        System.assertEquals(testAccount.Mid_Level_Manager__c,user4.Id);
        system.assertEquals(testAccount.OwnerId,user.Id);
        system.assertEquals(testAccount.Asia_Sales_Sup_Tuse__c,null);

         List<AccountTeamMember> members = [select Id, UserId, TeamMemberRole from AccountTeamMember where AccountId =: testAccount.Id];
         List<AccountShare> acctShare = [select Id, OpportunityAccessLevel from AccountShare where AccountId =: testAccount.Id AND UserOrGroupId =: user2.Id];

        for(AccountTeamMember m : members) {
            system.assertNotEquals(m.UserId,user3.Id);
            if(m.UserId == user.Id) {
                system.assertEquals(m.TeamMemberRole, 'Account Manager');
            }
            else if(m.UserId == user2.Id) {
                system.assertEquals(m.TeamMemberRole, 'Executive VP Admin');
            }
            else if(m.UserId == user4.Id) {
                system.assertEquals(m.TeamMemberRole, 'Region Manager');
            }
        }

        List<RFQ__Share> shares = [select Id from RFQ__Share where UserOrGroupId = :user3.Id AND ParentId = :rfq.Id];
        System.assertEquals(shares.size(), 0);

        system.assertNotEquals(members.size(), 0);
        system.assertNotEquals(acctShare.size(), 0);

        system.assertEquals('Edit', acctShare[0].OpportunityAccessLevel);
    }
    
    /**
    * Tests SAPInterface.customerGoldTest interface method
    */
    private static testMethod void customerGoldTest() {
    	SAPInstaller.install();
    	SharedUnitTestUtils.createTestSBU();
    	
    	Test.startTest();
    	SAPInterface.updateCustomerGoldPrice(getTestCONDA02('666','123','USD'));
        SAPInterface.updateCustomerGoldPrice(getTestCONDA02('666','777','USD'));
        SAPInterface.updateCustomerGoldPrice(getTestCONDA02('666','888','TWD')); //this shouldn't get loaded
    	Test.stopTest();

    	List<SAP_Interface_Log__c> logItems = [Select Id from SAP_Interface_Log__c];
        System.assertNotEquals(logItems.size(), 0, 'Should have inserted a log');
        
        List<SAP_Gold_Base__c> goldBases = [select Id,Newest__c from SAP_Gold_Base__c];
        System.assert(goldBases.size() == 3,'Should have inserted a couple gold base record attached to an account');

        goldBases = [select Id,Newest__c,Rate__c from SAP_Gold_Base__c where Newest__c =: true];
        System.assert(Math.abs(goldBases[0].Rate__c - 777) < 0.000001,'better be the newest one');
        System.assert(goldBases.size() == 1,'Should be only one new one');

       
    }
    
    private static testMethod void transmitCPNToSAPTest() {
    	SAPInstaller.install();
    	SharedUnitTestUtils.createTestSBU();
    	RFQAdminInstaller.install();
    	PBGAInstaller.installTest();
    	RFQItemWrapper wrapper = SharedUnitTestUtils.createLineItem('PBGA');
    	CPN cpn = CPNDao.getInstance().getCPN(wrapper);
    	
    	
    	Test.startTest();
    	Test.setMock(WebServiceMock.class, new SAPTransmitRespMock());
    	SAPInterface.transmitCPNToSAP(cpn.cpnId);
    	Test.stopTest();
    	
    	List<SAP_Interface_Log__c> logItems = [Select Id,Message_Content__c,Status__c from SAP_Interface_Log__c];
        System.assertNotEquals(logItems.size(), 0, 'Should have inserted a log');
        
        Boolean foundMockResponse = false;
        for(SAP_Interface_Log__c item : logItems) {
           
            System.assert(item.Status__c != 'Error', 'We got an error in the log? WTF Mate?');

        	if(item.Status__c == 'Success') {
        		foundMockResponse = true;
        		break;
        	}
        }
        System.assert(foundMockResponse, 'Should have gotten a mock response but did not find it');
    }
    
    private static testMethod void transmitCPNToSAPTriggerTest() {
    	SAPInstaller.install();
    	SharedUnitTestUtils.createTestSBU();
    	RFQAdminInstaller.install();
    	PBGAInstaller.installTest();
    	//RFQAdminInstaller.installRFQSystemSettings();
    	RFQItemWrapper wrapper = SharedUnitTestUtils.createLineItem('PBGA');
    	CPN cpn = CPNDao.getInstance().getCPN(wrapper);
    	
    	
    	Test.startTest();
    	
    	Test.setMock(WebServiceMock.class, new SAPTransmitRespMock());
    	wrapper.rfqItem.Status__c = RFQItemDao.STATUS_PRICE_COMPLETE; //this should activate the trigger
    	wrapper.rfqItem.Configured_Part_Number__c = cpn.cpnId;
    	RFQItemDao.getInstance().saveLineItem(wrapper);
    
    	Test.stopTest();
    	
    	Configured_Part_Number__c cpnRecord = [select Status__c from Configured_Part_Number__c where Id =: cpn.cpnId ];

        //AMK-1792
        //CPN_Attribute__c testAttrib = [select Object__c from CPN_Attribute__c where Configured_Part_Number__c =: cpn.cpnId limit 1];
        //System.assert(testAttrib.Object__c.contains(':'));

    	System.assert(cpnRecord.Status__c != CPNDao.STATUS_PENDING, 'Status should have updated to transmitted or transmit failed');
    	System.debug('Status: ' + cpnRecord.Status__c );
    
    }
    
    
    private static ZICUSHIE01 getTestZICUSHIE01(String childId, String parentId) {
    	ZICUSHIE01 zkush = new ZICUSHIE01();
    	zkush.IDOC = new ZICUSTHIEZICUSHIE01();
    	zkush.IDOC.ZISKKHIE = new List<ZICUSHIE01ZISKKHIE>();
    	ZICUSHIE01ZISKKHIE relation = new ZICUSHIE01ZISKKHIE();
    	relation.HKUNNR = parentId;
    	relation.KUNNR = childId;
    	zkush.IDOC.ZISKKHIE.add(relation);
    	return zkush;
    }
    
    private static CONDA02 getTestCONDA02(String accountNumber, String rate, String cur) {
    	
    	CONDA02 conda = new CONDA02();
    	conda.IDOC = new CONDACONDA02();
    	conda.IDOC.E1KOMG = new CONDA02E1KOMG();
    	conda.IDOC.E1KOMG.HIENR = accountNumber;
    	conda.IDOC.E1KOMG.VKORG = 'Org';
    	
    	conda.IDOC.E1KOMG.E1KONH = new List<CONDA02E1KONH>();
    	CONDA02E1KONH E1KONH = new CONDA02E1KONH();
    	E1KONH.DATAB = 'Data B';
    	CONDA02E1KONP E1KONP = new CONDA02E1KONP();
    	E1KONP.KBETR = rate;
    	E1KONP.KONWA = cur;
    	E1KONP.KPEIN = 'KPEIN';
    	
    	E1KONH.E1KONP = new List<CONDA02E1KONP>();
    	E1KONH.E1KONP.add(E1KONP);
    	conda.IDOC.E1KOMG.E1KONH.add(E1KONH);
    	
    	return conda;
    }

     private static ZIDEBMASDEBMAS06ZIDEBMASEXT getTestContactZIDEBMASDEBMAS06ZIDEBMASEXT(String accountNumber) {
        
        ZIDEBMASDEBMAS06ZIDEBMASEXT customerMaster = new ZIDEBMASDEBMAS06ZIDEBMASEXT();
        
        customerMaster.EDI_DC40 = new EDIDC40ZIDEBMASDEBMAS06ZIDEBMASEXT();
        customerMaster.E1KNA1M = new ZIDEBMASEXTE1KNA1M();
        customerMaster.E1KNA1M.E1KNA11 = new ZIDEBMASEXTE1KNA11();
        customerMaster.E1KNA1M.E1KNKAM = new ZIDEBMASEXTE1KNKAM();
        customerMaster.E1KNA1M.KTOKD = '0001';
        customerMaster.E1KNA1M.NAME3 = 'Test';
        customerMaster.E1KNA1M.NAME4 = 'Account';
        customerMaster.E1KNA1M.KUNNR = accountNumber; //Adding this in to test AMK-672
        
        
        customerMaster.E1KNA1M.E1KNA1H = new List<ZIDEBMASEXTE1KNA1H>();
        customerMaster.E1KNA1M.E1KNVVM = new List<ZIDEBMASEXTE1KNVVM>();
        
        ZIDEBMASEXTE1KNVVM E1KNVVM = new ZIDEBMASEXTE1KNVVM();
        E1KNVVM.E1KNVPM = new List<ZIDEBMASEXTE1KNVPM>();
        
        ZIDEBMASEXTE1KNVPM segment = new ZIDEBMASEXTE1KNVPM();
        segment.PARVW = 'ZA';
        segment.KUNN2 = TEST_EMP_NUMBER;
        E1KNVVM.E1KNVPM.add(segment);

        ZIDEBMASEXTE1KNVPM segment2 = new ZIDEBMASEXTE1KNVPM();
        segment2.PARVW = 'ZD';
        segment2.KUNN2 = TEST_EMP_NUMBER2;
        E1KNVVM.E1KNVPM.add(segment2);

        ZIDEBMASEXTE1KNVPM segment3 = new ZIDEBMASEXTE1KNVPM();
        segment3.PARVW = 'ZH';
        segment3.KUNN2 = TEST_EMP_NUMBER2;
        E1KNVVM.E1KNVPM.add(segment3);

        ZIDEBMASEXTE1KNVPM segment4 = new ZIDEBMASEXTE1KNVPM();
        segment4.PARVW = 'ZN';
        segment4.KUNN2 = TEST_EMP_NUMBER3;
        E1KNVVM.E1KNVPM.add(segment4);
        
        //For testing of AMK-695
        E1KNVVM.KDGRP = 'Z1';
        E1KNVVM.VKORG = 'K001';
        E1KNVVM.INCO2 = 'TESTINCO2';
        
        customerMaster.E1KNA1M.E1KNVVM.add(E1KNVVM);
        
        
        customerMaster.E1KNA1M.E1KNB1M = new List<ZIDEBMASEXTE1KNB1M>();
        customerMaster.E1KNA1M.E1KNBKM = new List<ZIDEBMASEXTE1KNBKM>();
        customerMaster.E1KNA1M.E1KNVAM = new List<ZIDEBMASEXTE1KNVAM>();
        customerMaster.E1KNA1M.E1WRF12 = new List<ZIDEBMASEXTE1WRF12>();
        customerMaster.E1KNA1M.E1WRF4M = new List<ZIDEBMASEXTE1WRF4M>();
        customerMaster.E1KNA1M.E1KNVKM = new List<ZIDEBMASEXTE1KNVKM>();
        customerMaster.E1KNA1M.E1KNEXM = new List<ZIDEBMASEXTE1KNEXM>();
        customerMaster.E1KNA1M.E1KNASM = new List<ZIDEBMASEXTE1KNASM>();    
        customerMaster.E1KNA1M.E1KNKKM = new List<ZIDEBMASEXTE1KNKKM>();
        customerMaster.E1KNA1M.E1VCKUN = new List<ZIDEBMASEXTE1VCKUN>();
        customerMaster.E1KNA1M.E1WRF1M = new List<ZIDEBMASEXTE1WRF1M>();
        customerMaster.E1KNA1M.E1WRF3M = new List<ZIDEBMASEXTE1WRF3M>();
        customerMaster.E1KNA1M.E1WRF5M = new List<ZIDEBMASEXTE1WRF5M>();
        customerMaster.E1KNA1M.E1WRF6M = new List<ZIDEBMASEXTE1WRF6M>();
        customerMaster.E1KNA1M.E1T023W = new List<ZIDEBMASEXTE1T023W>();
        customerMaster.E1KNA1M.E1T023X = new List<ZIDEBMASEXTE1T023X>();
        
        customerMaster.E1KNA1M.E1KNA1H.add( new ZIDEBMASEXTE1KNA1H());
        customerMaster.E1KNA1M.E1KNVVM.add( new ZIDEBMASEXTE1KNVVM());
        customerMaster.E1KNA1M.E1KNB1M.add( new ZIDEBMASEXTE1KNB1M());
        customerMaster.E1KNA1M.E1KNBKM.add( new ZIDEBMASEXTE1KNBKM());
        customerMaster.E1KNA1M.E1KNVAM.add( new ZIDEBMASEXTE1KNVAM());
        customerMaster.E1KNA1M.E1WRF12.add( new ZIDEBMASEXTE1WRF12());
        customerMaster.E1KNA1M.E1WRF4M.add( new ZIDEBMASEXTE1WRF4M());
        customerMaster.E1KNA1M.E1KNVKM.add( new ZIDEBMASEXTE1KNVKM());
        customerMaster.E1KNA1M.E1KNEXM.add( new ZIDEBMASEXTE1KNEXM());
        customerMaster.E1KNA1M.E1KNASM.add( new ZIDEBMASEXTE1KNASM());  
        customerMaster.E1KNA1M.E1KNKKM.add( new ZIDEBMASEXTE1KNKKM());
        customerMaster.E1KNA1M.E1VCKUN.add( new ZIDEBMASEXTE1VCKUN());
        customerMaster.E1KNA1M.E1WRF1M.add( new ZIDEBMASEXTE1WRF1M());
        customerMaster.E1KNA1M.E1WRF3M.add( new ZIDEBMASEXTE1WRF3M());
        customerMaster.E1KNA1M.E1WRF5M.add( new ZIDEBMASEXTE1WRF5M());
        customerMaster.E1KNA1M.E1WRF6M.add( new ZIDEBMASEXTE1WRF6M());
        customerMaster.E1KNA1M.E1T023W.add( new ZIDEBMASEXTE1T023W());
        customerMaster.E1KNA1M.E1T023X.add( new ZIDEBMASEXTE1T023X());

        return customerMaster;
    }
    
    private static ZIDEBMASDEBMAS06ZIDEBMASEXT getTestZIDEBMASDEBMAS06ZIDEBMASEXT(String accountNumber) {
    	
    	ZIDEBMASDEBMAS06ZIDEBMASEXT customerMaster = new ZIDEBMASDEBMAS06ZIDEBMASEXT();
    	
    	customerMaster.EDI_DC40 = new EDIDC40ZIDEBMASDEBMAS06ZIDEBMASEXT();
    	customerMaster.E1KNA1M = new ZIDEBMASEXTE1KNA1M();
    	customerMaster.E1KNA1M.E1KNA11 = new ZIDEBMASEXTE1KNA11();
    	customerMaster.E1KNA1M.E1KNKAM = new ZIDEBMASEXTE1KNKAM();
    	customerMaster.E1KNA1M.KTOKD = '0001';
        customerMaster.E1KNA1M.NAME1 = 'Parent Account';
    	customerMaster.E1KNA1M.NAME3 = 'Test';
    	customerMaster.E1KNA1M.NAME4 = 'Account';
    	customerMaster.E1KNA1M.KUNNR = accountNumber; //Adding this in to test AMK-672
        //AMK-2047 test
    	customerMaster.E1KNA1M.ORT01 ='123456789-123456789-123456789-123456789-123456789-';
    	
		customerMaster.E1KNA1M.E1KNA1H = new List<ZIDEBMASEXTE1KNA1H>();
		customerMaster.E1KNA1M.E1KNVVM = new List<ZIDEBMASEXTE1KNVVM>();
		
		ZIDEBMASEXTE1KNVVM E1KNVVM = new ZIDEBMASEXTE1KNVVM();
		E1KNVVM.E1KNVPM = new List<ZIDEBMASEXTE1KNVPM>();
		
		ZIDEBMASEXTE1KNVPM segment = new ZIDEBMASEXTE1KNVPM();
		segment.PARVW = 'ZA';
		segment.KUNN2 = TEST_EMP_NUMBER;
		E1KNVVM.E1KNVPM.add(segment);
		
		//For testing of AMK-695
		E1KNVVM.KDGRP = 'Z1';
		E1KNVVM.VKORG = 'K001';
		E1KNVVM.INCO2 = 'TESTINCO2';
		
		customerMaster.E1KNA1M.E1KNVVM.add(E1KNVVM);
		
		
		customerMaster.E1KNA1M.E1KNB1M = new List<ZIDEBMASEXTE1KNB1M>();
		customerMaster.E1KNA1M.E1KNBKM = new List<ZIDEBMASEXTE1KNBKM>();
		customerMaster.E1KNA1M.E1KNVAM = new List<ZIDEBMASEXTE1KNVAM>();
		customerMaster.E1KNA1M.E1WRF12 = new List<ZIDEBMASEXTE1WRF12>();
		customerMaster.E1KNA1M.E1WRF4M = new List<ZIDEBMASEXTE1WRF4M>();
		customerMaster.E1KNA1M.E1KNVKM = new List<ZIDEBMASEXTE1KNVKM>();
		customerMaster.E1KNA1M.E1KNEXM = new List<ZIDEBMASEXTE1KNEXM>();
		customerMaster.E1KNA1M.E1KNASM = new List<ZIDEBMASEXTE1KNASM>();	
		customerMaster.E1KNA1M.E1KNKKM = new List<ZIDEBMASEXTE1KNKKM>();
		customerMaster.E1KNA1M.E1VCKUN = new List<ZIDEBMASEXTE1VCKUN>();
		customerMaster.E1KNA1M.E1WRF1M = new List<ZIDEBMASEXTE1WRF1M>();
		customerMaster.E1KNA1M.E1WRF3M = new List<ZIDEBMASEXTE1WRF3M>();
		customerMaster.E1KNA1M.E1WRF5M = new List<ZIDEBMASEXTE1WRF5M>();
		customerMaster.E1KNA1M.E1WRF6M = new List<ZIDEBMASEXTE1WRF6M>();
		customerMaster.E1KNA1M.E1T023W = new List<ZIDEBMASEXTE1T023W>();
		customerMaster.E1KNA1M.E1T023X = new List<ZIDEBMASEXTE1T023X>();
		
		customerMaster.E1KNA1M.E1KNA1H.add( new ZIDEBMASEXTE1KNA1H());
		customerMaster.E1KNA1M.E1KNVVM.add( new ZIDEBMASEXTE1KNVVM());
		customerMaster.E1KNA1M.E1KNB1M.add( new ZIDEBMASEXTE1KNB1M());
		customerMaster.E1KNA1M.E1KNBKM.add( new ZIDEBMASEXTE1KNBKM());
		customerMaster.E1KNA1M.E1KNVAM.add( new ZIDEBMASEXTE1KNVAM());
		customerMaster.E1KNA1M.E1WRF12.add( new ZIDEBMASEXTE1WRF12());
		customerMaster.E1KNA1M.E1WRF4M.add( new ZIDEBMASEXTE1WRF4M());
		customerMaster.E1KNA1M.E1KNVKM.add( new ZIDEBMASEXTE1KNVKM());
		customerMaster.E1KNA1M.E1KNEXM.add( new ZIDEBMASEXTE1KNEXM());
		customerMaster.E1KNA1M.E1KNASM.add( new ZIDEBMASEXTE1KNASM());	
		customerMaster.E1KNA1M.E1KNKKM.add( new ZIDEBMASEXTE1KNKKM());
		customerMaster.E1KNA1M.E1VCKUN.add( new ZIDEBMASEXTE1VCKUN());
		customerMaster.E1KNA1M.E1WRF1M.add( new ZIDEBMASEXTE1WRF1M());
		customerMaster.E1KNA1M.E1WRF3M.add( new ZIDEBMASEXTE1WRF3M());
		customerMaster.E1KNA1M.E1WRF5M.add( new ZIDEBMASEXTE1WRF5M());
		customerMaster.E1KNA1M.E1WRF6M.add( new ZIDEBMASEXTE1WRF6M());
		customerMaster.E1KNA1M.E1T023W.add( new ZIDEBMASEXTE1T023W());
		customerMaster.E1KNA1M.E1T023X.add( new ZIDEBMASEXTE1T023X());

        return customerMaster;
    }

    /**
    * Creates test SD26DTPricingAttribute object
    */
	private static SD26DTPricingAttribute getTestSD26DTPricingAttribute() {
		
		SD26DTPricingAttribute attribute = new SD26DTPricingAttribute();
		List<ITEM> items = new List<ITEM>();
		ITEM i = new ITEM();
		i.obj_name = 'Test Attribute Name';
		i.obj_value = 'Test Value';
		items.add(i);
		attribute.item = items;
		
		return attribute;
	}
	
	/**
    * Creates test SD25DTCustomerBilling object
    */
	private static SD25DTCustomerBilling getTestSD25DTCustomerBilling() {
		
		SD25DTCustomerBilling billingItems = new SD25DTCustomerBilling();
		List<Lineitems> lineItemsList = new List<Lineitems>();
		
		for(Integer i = 0; i < 10; i++)
		{
			Lineitems item = new Lineitems();
  			item.Mandt = '';
		    item.Erdat = '';
		    item.Erzet = '';
		    item.Cpn = '';
		    item.Kunrg = '';
		    item.Fkdat = '';
		    item.Kunag  = '';
		    item.ZztargetDevice = ''; 
		    item.Zzpkct = '';
		    item.Zzdmsn = '';
		    item.Zzlead = '';
		    item.Vkorg = '';
		    item.Fkimg = '';
		    item.Vrkme = '';
		    item.IfStatus = '';
		    item.Ernam = '';
		    item.Aedat = '';
		    item.Aezet = '';
		    item.Aenam = '';	
		      	
		    lineItemsList.add(item);
		}
		billingItems.lineitems = lineItemsList;
		return billingItems;
	}

}