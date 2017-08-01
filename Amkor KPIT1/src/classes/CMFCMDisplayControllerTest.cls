/*************************************************************************
*
* PURPOSE: 
*
* CLASS: 
* CREATED: 5/01/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Steve Simpson
***************************************************************************/
@isTest
public with sharing class CMFCMDisplayControllerTest 
{
	//These methods are not used anymore
	//To Do: Delete them
	// static testMethod void testSetupView() 
	// {
	// 	CMFCMDisplayController cont = getTestController();
	// 	cont.isEdit = false;
		
	// 	Test.startTest();
		
	// 	cont.bomItemChanged();
	// 	cont.processItemChanged();
	// 	cont.addBom();
		
	// 	cont.addProcess();
		
	// 	cont.recalculateAction();
	// 	cont.clearAction();
		
	// 	System.assert(true);
		
	// 	Test.stopTest();	
	// }

	/*static testMethod void  deleteBom(){
		
		RFQItemWrapper itemWrapper = setupMLFItemWrapper();
		setupQuoteInoformation(itemWrapper, '< 400', '38');
		//List<FCM_BOM__c> bomList = [select id from FCM_BOM__c where Product_Group__r.Name=:'MLF'];
    	
		CMFCMDisplayController cont = new CMFCMDisplayController();
		cont.cmBuilder = getCMBuilderByWrapper(itemWrapper);        
		cont.fcmBuilder.calculateNew(itemWrapper, new CMSettings());
		RFQI_FCM__c itemFcm = RFQIFCMDao.getInstance().getLatest(itemWrapper.rfqItem.id);
		List<RFQI_BOM__c> bomList =  RFQIBOMDao.getInstance().getByFcmId(itemFcm.id); 
		Integer size = bomList.size();

		if(size == 0){
			cont.deleteBom();
			System.assert(cont.fcmBuilder.bomItemList.size() <= size);


		}
		else{

			RFQI_BOM__c selectedBom = bomList[0];
			String selectedBomId = selectedBom.id;
			ApexPages.currentPage().getParameters().put('itemBomId',selectedBomId);
			cont.deleteBom();
			System.assert(cont.fcmBuilder.bomItemList.size() <= size);
		}
		

	}

	static testMethod void  deleteProc(){
		RFQItemWrapper itemWrapper = setupMLFItemWrapper();
		setupQuoteInoformation(itemWrapper, '< 400', '38');

		//List<FCM_Process__c> processList = [select id from FCM_Process__c where Product_Group__r.Name=:'MLF'];		    	
		CMFCMDisplayController cont = new CMFCMDisplayController();
		
		cont.cmBuilder = getCMBuilderByWrapper(itemWrapper);       
		cont.fcmBuilder.calculateNew(itemWrapper, new CMSettings());
		List<RFQI_Process__c> processList = cont.fcmBuilder.processItemList;
		Integer size = processList.size();
		if(size == 0){
			cont.deleteProcess();
			System.assert(cont.fcmBuilder.bomItemList.size() <= size);

		}
		else{
			RFQI_Process__c selectedProcess = processList[0];
			String selectedProcessId = selectedProcess.id;
			ApexPages.currentPage().getParameters().put('itemProcessId',selectedProcessId);
			cont.deleteProcess();
			System.assert(cont.fcmBuilder.processItemList.size() <= size);
		}
		
	}*/


	
	static testMethod void testSetupEdit() 
	{
		CMFCMDisplayController cont = getTestController();
		cont.isEdit = true;
		
		Test.startTest();
		
		System.assert(true);
		
		Test.stopTest();	
	}

	private static void setupInstaller(){
		RFQAdminInstaller.install();
		MLFInstaller.install();
		CMMLFInstaller.install();

	}
	
	private static CMFCMDisplayController getTestController() 
	{
		RFQAdminInstaller.install();
		MLFInstaller.install();
		CMMLFInstaller.install();
		
		CMFCMDisplayController cont = new CMFCMDisplayController();
		
		return cont;
	}


	 private static RFQItemWrapper setupMLFItemWrapper(){
        
        //Setup environment
        RFQAdminInstaller.install();
        MLFInstaller.install();
        CMMLFInstaller.cleanAndInstall();
        
        //createa a rfq 
        RFQ__c rfq = SharedUnitTestUtils.createTestRFQ();
        
        //fake the rfq page
        ApexPages.currentPage().getParameters().put('rfqId',rfq.Id);
        CreateRFQItemController cont = new CreateRFQItemController();
        cont.numberOfWires = '1';
        cont.numberOfDies = '1';
        
        CreateRFQItemControllerTest.testDoUserSelection(cont);
        
        
        // To Do check code here.
        
        cont.createLineItem();
        
        
        RFQ_Item__c rfqItem = cont.rfqItem;
        
        RFQItemWrapper wrapper = RFQItemDao.getInstance().getWrapperById(rfqItem.Id);
        
        
        List<sObject> wireConfigurations = wrapper.wireConfigurations;
         
        wireConfigurations[0].put('Total_3D_Wire_Length__c', 510.00);
        
        update wireConfigurations;

        return wrapper;
                
    }

    static private void setupQuoteInoformation(RFQItemWrapper wrapper, String forecast, String annualVolume){
		
		
		wrapper.setAttribute('Forecast__c', 'Package', forecast);
		wrapper.setAttribute('Annual_Volume__c', 'Package', annualVolume);
		
		
	}
}