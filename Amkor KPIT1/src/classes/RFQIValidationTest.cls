/*************************************************************************
*
* PURPOSE: Test the methods in RFQDao.cls
*
* CLASS: RFQDao
* CREATED: 8/7/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Alejandro Molina
***************************************************************************/
@isTest
public class RFQIValidationTest {
    
    public static testmethod void testAmkorSelected() {

        RFQItemWrapper wrapper = setUpTest();
        enterRequiredFields(wrapper, 'C3', 2, 4);
        RFQItemDao.getInstance().saveLineItem(wrapper);

        String rfqId = wrapper.rfqItem.Id;
        ApexPages.StandardController sc = new ApexPages.StandardController(wrapper.rfqItem);
        RFQItemController controller = new RFQItemController(sc);

        //break down controller.submitItem() in order to play with SOQL limits - basically put Test.startTest()
        //in the middle of the method
        List<String> missingFields = new List<String>();
        String error;
        if (!controller.validateRequiredFields(wrapper, missingFields)) 
        {
            error = controller.getValidationErrors(wrapper);
        }
        wrapper.rfqItem.Has_Amkor_Selected__c = controller.validateAmkorSelected(wrapper);

        RFQItemApprovalRouting router = new RFQItemApprovalRouting(); 
        RFQItemApprovalRouting.RFQItemRoute itemRoute = router.route(wrapper);

        Test.startTest();
        //the wrapper will be saved in the calculatePrice()
        if(itemRoute.itemRouteType == RFQItemApprovalRouting.RoutingType.NONE) {
            controller.calculatePrice();                    
        }
        //check we need post price generation approval routing
        itemRoute = router.route(wrapper);
        RFQItemDao.getInstance().saveLineItem(wrapper);
        //end submitItem()        

        wrapper = RFQItemDao.getInstance().getWrapperById(rfqId);
        //some fields default to amkor selected, so this should be set
        System.assert(wrapper.rfqItem.Has_Amkor_Selected__c, 'Has_Amkor_Selected__c is: ' + wrapper.rfqItem.Has_Amkor_Selected__c);

        sc = new ApexPages.StandardController(wrapper.rfqItem);
        RFQBUItemAttributeEditController attribController = new RFQBUItemAttributeEditController(sc);
        attribController.reloadClone();

        attribController.saveAsNewRfqItem();

        ApexPages.Message[] messages = ApexPages.getMessages();

        Boolean stripWidthInvalid = false;
        for (ApexPages.Message msg : messages)
        {
            if (msg.getSummary().contains('Cannot approve item if any attributes are "Amkor Selected", "Amkor Specified", "Amkor Recommended", or "Amkor Preferred"')) {
                stripWidthInvalid = true;
                break;
            }
        }

        System.assert(stripWidthInvalid);
        Test.stopTest();
        
    }

    public static testmethod void testMLFDieObjects()
    {
        RFQItemWrapper wrapper = setupMLF();
        RFQILayout layout = setupDieLayout(wrapper.packageFamily.Id);

        wrapper.specificRfqItem.put('Body_Size__c', '08x08');
        wrapper.specificRfqItem.put('Factory__c', [select Id from Factory__c where Name = 'C3'].Id);
        wrapper = RFQItemDao.getInstance().refresh(wrapper);
        wrapper.setupChildObjectSections(layout);
        Test.startTest();
        Decimal dieConfigMax = DataUtils.getDecimal(wrapper.dieConfigurations[0], 'Max_Die_Size__c', 0);


        System.assert(dieConfigMax > 0);
        wrapper.dieConfigurations[0].put('Die_Size_X__c', dieConfigMax + 1);

        List<String> missingFields = new List<String>();
        Boolean isValid;
        System.assert(wrapper.dieConfigurations[0].Id != wrapper.dieConfigurations[1].Id);
        isValid = wrapper.validateRequiredFields(missingFields, layout);
        System.assert(!isValid, 'Item should fail - Die Size x is too large');

        //reset item
        wrapper.dieConfigurations[0].put('Die_Size_X__c', 0);
        isValid = wrapper.validateRequiredFields(missingFields, layout);
        System.assert(isValid, 'Item should not fail - Die Size X is 0');

        wrapper.dieConfigurations[0].put('Die_Size_Y__c', dieConfigMax + 1);
        isValid = wrapper.validateRequiredFields(missingFields, layout);
        System.assert(!isValid, 'Item should fail - Die Size Y too large');

        //reset item
        wrapper.dieConfigurations[0].put('Die_Size_Y__c', 0);
        isValid = wrapper.validateRequiredFields(missingFields, layout);
        System.assert(isValid, 'Item should not fail - Die Size Y is 0');

        wrapper.rfqItem.Do_Not_Auto_Price__c = false;
        wrapper.dieConfigurations[0].put('Die_Size_X__c', 1);
        wrapper.dieConfigurations[1].put('Die_Size_X__c', 2);
        wrapper.validateRequiredFields(missingFields, layout);
        System.assert(wrapper.rfqItem.Do_Not_Auto_Price__c, 'Item cannot price - Die Size X on second die config is too large');

        //reset item
        wrapper.rfqItem.Do_Not_Auto_Price__c = false;
        wrapper.dieConfigurations[0].put('Die_Size_X__c', 0);
        wrapper.dieConfigurations[1].put('Die_Size_X__c', 0);
        wrapper.validateRequiredFields(missingFields, layout);
        System.assert(!wrapper.rfqItem.Do_Not_Auto_Price__c, 'Item can price - Die Sizes are 0');

        wrapper.rfqItem.Do_Not_Auto_Price__c = false;
        wrapper.dieConfigurations[0].put('Die_Size_Y__c', 1);
        wrapper.dieConfigurations[1].put('Die_Size_Y__c', 2);
        wrapper.validateRequiredFields(missingFields, layout);
        System.assert(wrapper.rfqItem.Do_Not_Auto_Price__c, 'Item cannot price - Die Size Y on second die config is too large');

        wrapper.rfqItem.Do_Not_Auto_Price__c = false;
        wrapper.dieConfigurations.addAll(RFQItemDao.createDieObject(wrapper.packageFamily, wrapper.specificRfqItem.Id, 1));
        wrapper.setupChildObjectSections(layout);

        wrapper.validateRequiredFields(missingFields, layout);
        System.assert(wrapper.rfqItem.Do_Not_Auto_Price__c, 'Item cannot price - too many die configs');


        wrapper.specificRfqItem.put('Body_Size__c', '02x02');
        wrapper = RFQItemDao.getInstance().refresh(wrapper);
        wrapper.setupChildObjectSections(layout);

        isValid = wrapper.validateRequiredFields(missingFields, layout);
        System.assert(!isValid, 'Item should fail - Invalid body size');

        Test.stopTest();

    }

    private static RFQItemWrapper setUpTest()
    {
        
        RFQAdminInstaller.install();
        RFQAdminInstaller.installFactories();
        
        FCCSPInstaller.install();
        RFQAdminInstaller.AMK1237();
        
        //get wrapper
        RFQItemWrapper wrapper = SharedUnitTestUtils.createLineItem('FC CSP');

        return wrapper;
    }

    private static RFQItemWrapper setupMLF()
    {
        Product_Group__c pg = SharedUnitTestUtils.createProductGroupFromName('MLF', false);
        insert pg;
        Package_Family__c pf = SharedUnitTestUtils.createPackageFamilyFromName('Punch Dual Row MLF', pg, 'RFQI_PUNCH_DUAL_ROW_MLF__c');
        pf.Specific_Die_Configuration_Object__c = 'RFQIDC_PUNCH_DUAL_ROW_MLF__c';
        pf.Specific_Wire_Configuration_Object__c = 'RFQIWC_PUNCH_DUAL_ROW_MLF__c';
        Factory__c fakeFactory = new Factory__c(Name = 'C3', Package_Family__c = 'MLF');
        insert fakeFactory;

        insert pf;


        return SharedUnitTestUtils.createLineItem('Punch Dual Row MLF', 1, 2);
    }

    private static RFQILayout setupDieLayout(String pfId)
    {
        RFQI_Section__c section = new RFQI_Section__c(Name='Die Description');
        insert section;

        RFQI_Field_Def__c def = new RFQI_Field_Def__c(Name='Die_Size_X__c');
        insert def;

        RFQI_PF_Field_Def__c pfDef = new RFQI_PF_Field_Def__c(RFQI_Section__c=section.Id, RFQI_Field_Def__c=def.Id, Package_Family__c=pfId);
        pfDef.RFQI_Section__r = section;

        Map<String, Boolean> enabledSections = new Map<String, Boolean>{'Die Description' => true};


        RFQILayout layout = new RFQILayout(new List<RFQI_PF_Field_Def__c>{pfDef}, enabledSections, 1, 1);

        return layout;
    }

    private static void enterRequiredFields(RFQItemWrapper itemWrapper, String factory, Decimal bodyX, Decimal bodyY)
    {
        Factory__c fact = [select Id from Factory__c where Name=:factory];

        itemWrapper.specificRfqItem.put('Factory__c', fact.Id);
        itemWrapper.specificRfqItem.put('Body_Size_X__c', bodyX);
        itemWrapper.specificRfqItem.put('Body_Size_Y__c', bodyY);

    }
    
    //Bhanu-L code coverage change
    private static testmethod void validateMethodsTest(){
      RFQItemWrapper wrapper = setUpTest();
      RFQILayout layout = setupDieLayout(wrapper.packageFamily.Id);
      String objName;
      Integer position = 1;
      List<String> missingFields = new List<String>();
      //List<sObject> wireConfigurations= new List<sObject>();
      
      Package_Family__c packageFamObj = SharedUnitTestUtils.createTestPackageFamily();
      RFQIValidation rfqValObj = new RFQIValidation(wrapper,layout);
      RFQItemWrapper wrapperforWireConfig = new RFQItemWrapper();
      //wireConfigurations.add(wrapperforWireConfig.wireConfigurations);
      //rfqValObj.validateWireConfigs(wrapperforWireConfig.wireConfigurations,wrapper.packageFamily,position,missingFields);
      rfqValObj.validateAllMLFDieObjects(objName,missingFields);
        
    }

}