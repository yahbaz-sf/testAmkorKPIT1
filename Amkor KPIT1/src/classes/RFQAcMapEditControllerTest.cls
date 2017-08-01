/*************************************************************************
*
* PURPOSE: Tests the RFQAcMapEditController
*
* CLASS: RFQAcMapEditControllerTest
* CREATED: 3/06/2012 Ethos Solutions - www.ethos.com
* AUTHOR: Nathan Pilkington
***************************************************************************/

@isTest
private class RFQAcMapEditControllerTest {

    static testMethod void testAutoAddRequiredFields() {
        RFQAcMapEditController cont = getTestCreateControllerWithStep2Data();

        Test.startTest();

        cont.pfMappings[0].pfMap.Product_Group__c = [Select Id from Product_Group__c where name =: 'Flip Chip'].Id;
        cont.pfMappings[0].pfMap.Package_Family__c = [Select Id from Package_Family__c where name =: 'FC CSP'].Id;

        PageUtil.putParam('uniqueId', cont.pfMappings[0].uniqueId);

        cont.mappingPackageFamilyChanged();

        System.assertNotEquals(cont.pfMappings[0].fieldMaps.size(), 0, 'Should have added the required fields');

        for (RFQAcMapController.PfFieldMappingHolder fieldMap : cont.pfMappings[0].fieldMaps) {
            System.assert(!fieldMap.pfColumn.RFQI_PF_Field_Def__r.Not_Required_on_Import__c, 'Should not have auto-added any fields that are not required for import');
        }

        Test.stopTest();
    }

    static testMethod void testConstructorForCreate() {
        RFQAcMapEditController cont = getTestCreateController();
        
        Test.startTest();
        
        System.assert(cont.productGroups != null);
        System.assert(cont.packageFamilies != null);
        System.assert(cont.accountMap != null);
         
        System.assert(cont.removedAccountMapColumns != null);
        System.assert(cont.removedPfMappings != null);
        
        System.assert(cont.accountMap.Version__c == 1);
        
        System.assert(cont.pfMappings != null && cont.pfMappings.size() == 1, 'Should automatically insert 1 pf mapping');
        
        System.assert(cont.accountMapColumns != null);
        
        Test.stopTest();
    }
    
    static testMethod void testStep1() {
    	RFQAcMapEditController cont = getTestCreateController();
    	
    	Test.startTest();
    	
    	// Test trying to go to next step when proper values have not been added in
    	PageReference pf = cont.nextStep();
    	
    	System.assert(cont.currentStep == 1, 'Should not have advanced to next step because no valid values yet.');
    	
    	cont.accountMap.Name = 'Test ac map';
    	
    	cont.addAccountColumn();
    	
    	System.assert(cont.accountMapColumns.size() == 1, 'Should have added one column');
    	
    	cont.accountMapColumns[0].selected = true;
    	cont.removeSelectedColumns();
    	
    	System.assert(cont.accountMapColumns.size() == 0, 'Should have removed the selected column.');
    	
    	cont.addAccountColumn();
    	
    	pf = cont.nextStep();
    	
    	System.assert(cont.currentStep == 1, 'Still should not have advanced because column is missing a name');
    	
    	cont.accountMapColumns[0].accountMapColumn.Name = 'Test column';
    	
    	pf = cont.nextStep();
    	
    	System.assert(cont.currentStep == 2, 'Now should have advanced to the next step');
    	
    	Test.stopTest();
    }

    static testMethod void testAMK1657() {
        RFQAcMapController.PfFieldMappingHolder holder = new RFQAcMapController.PfFieldMappingHolder(new RFQ_Ac_Map_Pf_Column__c());
        System.assertEquals(holder.getFriendlyName(), 'UNKNOWN', 'field mapping holder should not throw exception on null PF Field def');

    }

    static testMethod void testAutoCreateColumns() {
        RFQAcMapEditController cont = getTestCreateController();
        cont.accountMap.Name = 'Test ac map';

        String testFile = 'Device Name,Lead Count\n150 Mil,10\n150 Mil,20';
        Blob testBlob = Blob.valueOf(testFile);

        cont.fileContent = testBlob;
        cont.fileName = 'TestFile.csv'; 
        
        Test.startTest();

        PageReference pf = cont.nextStep();

        System.assertEquals(cont.currentStep, 2, 'Should have advanced to the next step');

        System.assertEquals(cont.accountMapColumns.size(), 2, 'Should have automatically created 2 columns from the CSV');

        Test.stopTest();
    }
    
    static testMethod void testStep2() {
    	RFQAcMapEditController cont = getTestCreateControllerWithStep1Data();
    	
    	Test.startTest();
    	
    	PageReference pf = cont.nextStep();
    	
    	System.assert(cont.currentStep == 2, 'Should have advanced to second step without issue');
    	
    	pf = cont.nextStep();
    	
    	System.assert(cont.currentStep == 2, 'Should not have advanced to next step because device name column is missing');
    	
    	cont.accountMap.Device_Name_Column__c = 'Test Column';
    	
    	pf = cont.nextStep();
    	
    	System.assert(cont.currentStep == 3, 'Now should have advanced to next step since the device name column is selected');
    	
    	Test.stopTest();
    }
    
    static testMethod void testStep3() {
    	RFQAcMapEditController cont = getTestCreateControllerWithStep2Data();
    	
    	Test.startTest();
    	
    	PageReference pf = cont.nextStep();
    	pf = cont.nextStep();
    	
    	System.assert(cont.currentStep == 3, 'Should have advanced to third step without issue');
    	
    	pf = cont.saveMappingDraft();
    	
    	System.assert(pf == null, 'Should not have saved because required information is not entered');
    	
    	cont.addPfMapping();
    	
    	System.assert(cont.pfMappings.size() == 2, 'Should now be the auto-added one plus the new one');
    	
    	cont.removeLastPfMapping();
    	
    	System.assert(cont.pfMappings.size() == 1, 'Should have removed the new pf mapping');
    	
    	List<SelectOption> accountColumnOptions = cont.getAccountColumnOptions();
    	System.assert(accountColumnOptions.size() > 0, 'Should be able to select some of the columns entered on previous screen');
    	
    	List<SelectOption> productGroupOptions = cont.getProductGroupOptions();
    	System.assert(productGroupOptions.size() > 1, 'Should be some product groups to select');
    	
    	RFQAcMapController.PfMappingHolder mappingHolder = cont.pfMappings[0];
    	
    	mappingHolder.pfMap.Account_Device_Name__c = 'Test device name';
    	
    	mappingHolder.pfMap.Product_Group__c = productGroupOptions[1].getValue();
    	
    	List<SelectOption> availablePf = mappingHolder.getSelectablePackageFamilies();
    	
    	System.assert(availablePf.size() > 1, 'Should be at least one PF available (Beside the "None selected option")');
    	
    	List<SelectOption> availableFields = mappingHolder.getSelectableFields();
    	System.assert(availableFields.size() == 0, 'No available fields yet because no PF has been selected');
    	
    	mappingHolder.pfMap.Package_Family__c = availablePf[1].getValue();
    	
    	availableFields = mappingHolder.getSelectableFields();
    	System.assert(availableFields.size() > 0, 'Should now have some fields available');
    	
    	System.assert(mappingHolder.fieldMaps.size() == 0, 'Should not have any field maps yet');
    	
    	mappingHolder.addFieldMapping();
    	
    	System.assert(mappingHolder.fieldMaps.size() > 0, 'Should have added a field mapping');
    	
    	mappingHolder.fieldMaps[0].selected = true;
    	
    	mappingHolder.removeFieldMappings();
    	
    	System.assert(mappingHolder.fieldMaps.size() == 0, 'Should have removed all selected field mappings');
    	
    	mappingHolder.addFieldMapping();
    	
    	mappingHolder.fieldMaps[0].pfColumn.RFQ_Ac_Map_Column__c = 'Test Column';
    	mappingHolder.fieldMaps[0].pfColumn.RFQI_PF_Field_Def__c = availableFields[1].getValue();
    	
    	List<RFQ_Ac_Map__c> maps = [Select ID from RFQ_Ac_Map__c];
    	System.assert(maps.size() == 0, 'Should not be any maps yet');
    	
    	pf = cont.saveMappingDraft();
    	
		maps = [Select ID from RFQ_Ac_Map__c];
		
		System.assert(maps.size() == 1, 'Should now have a map');
		
		List<RFQ_Ac_Map_Column__c> columnList = [Select Id from RFQ_Ac_Map_Column__c where RFQ_Ac_Map__c = :cont.accountMap.Id];
		
		System.assert(columnList.size() > 0, 'Should be some columns');
		
		List<RFQ_Ac_Map_Pf__c> mapPfList = [Select Id from RFQ_Ac_Map_Pf__c where RFQ_Ac_Map__c = :cont.accountMap.Id];
		
		System.assert(mapPfList.size() > 0, 'Should be some PF Mappings');
		
		for (RFQ_Ac_Map_Pf__c row : mapPfList) {
			List<RFQ_Ac_Map_Pf_Column__c> fieldMapList = [select Id from RFQ_Ac_Map_Pf_Column__c where RFQ_Ac_Map_Pf__c = :row.Id];
			System.assert(fieldMapList.size() > 0, 'Should have some field maps for each PF mapping');
		}
		
		
		RFQ_Ac_Map__c acMap = cont.accountMap;
		
		ApexPages.StandardController sc = new ApexPages.StandardController(acMap);
    	
    	cont = new RFQAcMapEditController(sc);
    	
    	
    	pf = cont.saveMappingActive();
    	
    	maps = [Select ID, RecordTypeId from RFQ_Ac_Map__c];
    	
    	String rtId = [Select Id from RecordType where DeveloperName = 'Active' and SobjectType = 'RFQ_Ac_Map__c'].Id;
    	
    	System.assertEquals(rtId, maps[0].RecordTypeId, 'Should have been saved as active');
		
		pf = cont.saveMappingClone();
		
		maps = [Select ID, RecordTypeId from RFQ_Ac_Map__c order by Version__c];
		
		System.assert(maps.size() == 2, 'Should now have the original map plus the cloned child');
		
		
		System.assertNotEquals(maps[0].RecordTypeId, maps[1].RecordTypeId, 'One map should be inactive and the other should be active');

        delete maps[1];

        maps = [Select ID, RecordTypeId from RFQ_Ac_Map__c order by Version__c];

        System.assertEquals(rtId, maps[0].RecordTypeId, 'Should have been changed back to active');

    	Test.stopTest();
    }
    
    private static RFQAcMapEditController getTestCreateControllerWithStep1Data() {
    	RFQAcMapEditController cont = getTestCreateController();
    	cont.accountMap.Name = 'Test ac map';
    	RFQAcMapController.AccountMapColumnHolder columnHolder = new RFQAcMapController.AccountMapColumnHolder(new RFQ_Ac_Map_Column__c(Name='Test Column'));
    	cont.accountMapColumns.add(columnHolder);
    	
    	return cont;
    }
    
    private static RFQAcMapEditController getTestCreateControllerWithStep2Data() {
    	RFQAcMapEditController cont = getTestCreateControllerWithStep1Data();
    	
    	cont.accountMap.Device_Name_Column__c = 'Test Column';
    	
    	return cont;
    }
    

    private static RFQAcMapEditController getTestCreateController() {
    	
    	RFQAdminInstaller.cleanAndInstallTest();
        RFQAdminInstaller.AMK1510();
    	
    	Account a = new Account(Name='Test account', Sales_Region__c = 'Japan');
    	insert a;
    	
    	String rtId = [Select Id from RecordType where SobjectType = 'RFQ_Ac_Map__c' and Name = 'Draft'].Id;
    	
    	RFQ_Ac_Map__c mapObj = new RFQ_Ac_Map__c();
    	mapObj.Account__c = a.Id;
    	mapObj.RecordTypeId = rtId;
    	
    	ApexPages.StandardController sc = new ApexPages.StandardController(mapObj);
    	
    	RFQAcMapEditController controller = new RFQAcMapEditController(sc);
    	
    	return controller;
    }
}