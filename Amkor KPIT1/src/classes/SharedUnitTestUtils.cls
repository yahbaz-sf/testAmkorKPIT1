/*************************************************************************
* 
* PURPOSE:  Shared Unit Test methods
*          
*         
* CLASS: SharedUnitTestUtils
* CREATED: 03/07/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Jason Swenski
* 
**************************************************************************/
//Bhanu 18/July/2016 Increasing Code Coverage added @isTest 

@isTest(SeeAllData=false)
public class SharedUnitTestUtils {
    
    /**
    * Creates a dummy RFQ to use in Unit Tests, it also has the 
    * side affect of create a dummy SBU and dummy parent account
    *
    * @returns a dummy RFQ__c object
    */
    public static RFQ__c createTestRFQ() {
        
        //Bhanu - 3-Mar-2016 : 597492 Missing NRE on EXCEL + "Projected_Revenue__c" is now mandatory
        //Providing Mandatory field "Projected_Revenue__c" on RFQ Object in TestSetup
        //RFQ__c rfq = new RFQ__c(RFQ_Name__c ='Unit Test RFQ Name');
        RFQ__c rfq = new RFQ__c(RFQ_Name__c ='Unit Test RFQ Name', Projected_Revenue__c = 1234);
        rfq.SBU_Name__c = createTestSBU().Id;
        insert rfq;
        return rfq;
    }

     /**
    * Creates a dummy RFQ to use in Unit Tests, it also has the 
    * side affect of create a dummy SBU and dummy parent account
    *
    * @returns a dummy RFQ__c object
    */
    public static Opportunity createTestOpportunity() {
        
        //Bhanu - 3-Mar-2016 : 597492 Missing NRE on EXCEL + "Projected_Revenue__c" is now mandatory
        //Providing Mandatory field "Projected_Revenue__c" on RFQ Object in TestSetup
        Opportunity opp = new Opportunity(Name = 'ZZ Test Opportunity Unit Test',
                                RFQ__c = null,
                                AccountId = createTestSBU().Id,
                                StageName = 'Prospecting',
                                CloseDate = Date.today() + 1,
                                Projected_Revenue__c = 1234
                                );
            
         insert opp;
         return opp;
    }
    
    /**
    * Creates a dummy SBU and parent account
    *
    * @returns the dummy SBU Account object
    */
    public static Account createTestSBU() {
        
        Account parentAccount = new Account(Name = 'Unit Test Parent Account',AccountNumber='666', Sales_Region__c='East');
        insert parentAccount;
        Account sbu = new Account(AccountNumber='ZZZ666', Name = 'Unit Test SBU',ParentId = parentAccount.Id, Sales_Region__c='East');
        insert sbu;
        return sbu;
    }

    /**
    * Creates a new system admin user
    *
    * @returns a new user with some fields populated
    */
    public static User createTestUser(Boolean requiresApproval, Boolean isBU) {
        // TODO user proper profil
        String userName = getUniqueUserName('amkorUnitTestUser12345@amkor.com');

        Profile p = [select id from profile where name='System Administrator'];
        
        User u = new User(alias = 'standt', email='standarduser@testorg.com',
            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
            localesidkey='en_US', profileid = p.Id,
            timezonesidkey='America/Los_Angeles', username=userName);
        u.Requires_Approval__c = requiresApproval;
        insert u;

        if(isBU) {
            RFQ_System_Settings__c sys = new RFQ_System_Settings__c(Is_BU_Profile__c=true,Name=p.Id);
            insert sys;
        }         
        return u;
    }
    
    public static User createTestSalesUser() {
        // TODO user proper profil
        String userName = getUniqueUserName('amkorUnitTestUser12345@amkor.com');

        Profile p = [select id from profile where name='Sales Team'];

        User u = new User(alias = 'standt', email='standarduser@testorg.com',
            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
            localesidkey='en_US', profileid = p.Id,
            timezonesidkey='America/Los_Angeles', username=userName);
        //u.Requires_Approval__c = requiresApproval;
        insert u;

        /*if(isBU) {
            RFQ_System_Settings__c sys = new RFQ_System_Settings__c(Is_BU_Profile__c=true,Name=p.Id);
            insert sys;
        }*/
        return u;
    }

    public static User createTestUser(Boolean requiresApproval) {
        return createTestUser(requiresApproval, false);
    }

    public static User createTestBUUser() {
         return createTestUser(false, true);
    }

    public static User createTestUser() {
        return createTestUser(false);
    }

    /**
     * Encountered an issue where unit tests were failing because of non-unique usernames...
     * There is probably a better way to handle this
     */
    public static String getUniqueUserName(String seedName) {
        Boolean foundUnique = false;
        String userName = seedName;

        while (!foundUnique) {
            List<User> duplicateUser = [Select Id, username from User where username =: userName];
            if (duplicateUser.size() == 0) {
                foundUnique = true;
            }
            else {
                userName = userName + String.valueOf(Math.round(Math.random() * 5000));
            }
        }

        return userName;
    }

    public static Product_Group__c createProductGroupFromName(String prodGroupName, Boolean service) {
        Product_Group__c productGroup = new Product_Group__c(Name = prodGroupName, Service__c = service);
        return productGroup;
    }

    public static Package_Family__c createPackageFamilyFromName(String packageFamilyName, Product_Group__c pg, String specificRfqItemObj) {
         Package_Family__c packageFamily = new Package_Family__c(Name = packageFamilyName, Product_Group__c = pg.Id, Specific_RFQ_Item_Object__c = specificRfqItemObj);
         return packageFamily;
    }
    
    /**
    * Creates a dummy Product Group object has the side effect
    * of creating a child Package Family object
    *
    * @returns the dummy Product_Group__c object
    */
    public static Product_Group__c createTestProductGroup() {
        
        Product_Group__c productGroup = new Product_Group__c(Name = 'Unit Test Product Group');
        insert productGroup;
        Package_Family__c packageFamily 
            = new Package_Family__c(Name = 'Unit Test Package Family', 
                                    Specific_RFQ_Item_Object__c = 'RFQI_SOIC_150mil_body__c',
                                    Specific_Wire_Configuration_Object__c = 'RFQIWC_SOIC_150mil_body__c',
                                    Specific_Die_Configuration_Object__c = 'RFQIDC_SOIC_150mil__c',
                                    Product_Group__c = productGroup.Id);
        insert packageFamily;
           
        return productGroup; 
    }
    
    
    /**
    * Does the same thing as createTestProductGroup but retuns the package
    * family object instead
    *
    * @returns the dummy Package_Family__c object
    */
    public static Package_Family__c createTestPackageFamily() {
         
        Product_Group__c productGroup = createTestProductGroup();
        return PackageFamilyDao.getInstance().getFamiliesByProductGroup(productGroup.Id)[0];
    }
    
    
    
    public static RFQI_PF_Field_Def__c createTestRFQIPFFieldDef(){
        
        RFQI_Section__c RFQISec2 = new RFQI_Section__c(Name='Package Description');
        insert RFQISec2;
        RFQI_Field_Def__c RFQIFD2 = new RFQI_Field_Def__c(Name='Number_Of_Die__c');
        insert RFQIFD2;
        Package_Family__c pf = SharedUnitTestUtils.createTestPackageFamily();
        
        RFQI_PF_Field_Def__c fd = new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = RFQIFD2.id, RFQI_Section__c = RFQISec2.id, Sequence__c = 2000, Package_Family__c = pf.id,CPN_Attribute__c = true, Generated__c = false);
        insert fd;
        
        fd = [select Id, Name, Bucket_Strategy__c, RFQI_PF_Field_Def__c.RFQI_Field_Def__r.Name from RFQI_PF_Field_Def__c where Id = : fd.Id];
        return fd;
    }
    
        public static RFQI_PF_Field_Def__c createTestRFQIPFFieldDefwc(){
        
        RFQI_Section__c RFQISec2 = new RFQI_Section__c(Name='Wire Description');
        insert RFQISec2;
        RFQI_Field_Def__c RFQIFD2 = new RFQI_Field_Def__c(Name='Number_Of_Wires__c');
        insert RFQIFD2;
        Package_Family__c pf = SharedUnitTestUtils.createTestPackageFamily();
        
        RFQI_PF_Field_Def__c fd = new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = RFQIFD2.id, RFQI_Section__c = RFQISec2.id, Sequence__c = 2000, Package_Family__c = pf.id,CPN_Attribute__c = true, Generated__c = false);
        
        insert fd;
        return fd;
    }
    
        /**
    * Creates a dummy RFQI_PF_Field_Def
    *
    * @returns the dummy RFQI_PF_Field_Def
    */
    public static list<RFQI_PF_Field_Def__c> createTestRFQIPFFieldDefList(){
        
        List<RFQI_PF_Field_Def__c> pfFieldDefs = new List<RFQI_PF_Field_Def__c>();
        
        RFQI_Section__c RFQISec = new RFQI_Section__c(Name='Package Description');
        insert RFQISec;
        RFQI_Section__c RFQISec2 = new RFQI_Section__c(Name='Wire Description');
        insert RFQISec2;
        RFQI_Field_Def__c RFQIFD = new RFQI_Field_Def__c(Name='Lead_Count__c');
        insert RFQIFD;
        RFQI_Field_Def__c RFQIFD2 = new RFQI_Field_Def__c(Name='Au_Factor__c');
        insert RFQIFD2;
        Package_Family__c pf = SharedUnitTestUtils.createTestPackageFamily();
        
        pfFieldDefs.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = RFQIFD.id, RFQI_Section__c = RFQISec.id,Sequence__c = 1000, Package_Family__c = pf.id, CPN_Attribute__c = true, Generated__c = false));
        pfFieldDefs.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = RFQIFD2.id, RFQI_Section__c = RFQISec2.id,Sequence__c = 2000, Package_Family__c = pf.id, CPN_Attribute__c = false, Generated__c = false));
        pfFieldDefs[0].Bucket_Strategy__c = 'Equal Intervals';
        pfFieldDefs[0].Equal_Interval_Length__c = 2;
        pfFieldDefs[0].Equal_Interval_Start__c = 1;
        insert pfFieldDefs;
        return pfFieldDefs;
    }

    public static RFQItemWrapper createPfAndLineItem() {
        return createLineItem(createTestPackageFamily().Name);
    }

    public static RFQItemWrapper createLineItem(String packageFamily, RFQ__c rfq) {
        Package_Family__c packageFam = [select Id, Layout_Version__c from Package_Family__c where Name =: packageFamily];
        
        String rfqId = null;
        if(rfq != null) rfqId = rfq.Id;

        RFQ_Item__c item = RFQItemDao.getInstance().createItem(rfqId, packageFam.Id , 'Assembly', 1, packageFam.Layout_Version__c);
        
        return RFQItemDao.getInstance().getWrapperById(item.Id);
    }
    
    public static RFQItemWrapper createLineItem(String packageFamily){
        
        return createLineItem(packageFamily,createTestRFQ().Id);
    }

    public static RFQItemWrapper createLineItem(String packageFamily, ID rfqId){
        
        Package_Family__c packageFam = [select Id, Layout_Version__c from Package_Family__c where Name =: packageFamily];
        RFQ_Item__c item = RFQItemDao.getInstance().createItem(rfqId, packageFam.Id , 'Assembly', 1, packageFam.Layout_Version__c);
        return RFQItemDao.getInstance().getWrapperById(item.Id);
    }
    
    public static RFQItemWrapper createLineItem(String packageFamily, Integer numberOfWires, Integer numberOfDies) {
        return createLineItem(packageFamily, numberOfWires, numberOfDies, 0 , 0);
    }
    
    
    public static RFQItemWrapper createLineItem(String packageFamily, Integer numberOfWires, Integer numberOfDies, Integer numberOfInsertions, Integer numberOfPassives){
        
       
        String packageId = [select Id from Package_Family__c where Name =: packageFamily].Id;
        RFQ_Item__c item = RFQItemDao.getInstance().createItem(createTestRFQ().Id, packageId , 'Assembly', numberOfWires, numberOfDies, numberOfInsertions, numberOfPassives);
        
        return RFQItemDao.getInstance().getWrapperById(item.Id);
    }

    static public void setupCMVersion(String productGroup, Decimal Wire_Ball_Ratio, Decimal Wire_Die_Thickness, Decimal Wire_Loop_Height, Decimal Wire_DA_Thickness, Decimal Wire_Paddle_Down) {

        Product_Group__c pg = [Select ID from Product_Group__c where Name=: productGroup];
        CM_Version__c PBGAVersion = new CM_Version__c();
        PBGAVersion.Product_Group__c = pg.Id;
        PBGAVersion.Status__c = 'Active';
        PBGAVersion.Version__c = 1;
        PBGAVersion.Wire_Ball_Ratio__c = Wire_Ball_Ratio;
        PBGAVersion.Wire_DA_Thickness__c = Wire_DA_Thickness;
        PBGAVersion.Wire_Die_Thickness__c = Wire_Die_Thickness;
        PBGAVersion.Wire_Loop_Height__c = Wire_Loop_Height;
        PBGAVersion.Wire_Paddle_Down__c = Wire_Paddle_Down;

        try{
            insert PBGAVersion;
        }
        catch(DmlException e){
            System.debug(LoggingLevel.ERROR, e);
        }   
    }

    public static ApexPages.Standardcontroller setupStandardControllerWithItem() {

        RFQAdminInstaller.install();
        PBGAInstaller.installTest();
        RFQItemWrapper wrapper = SharedUnitTestUtils.createLineItem('PBGA');
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(wrapper.rfqItem);
        ApexPages.currentPage().getParameters().put('edit','1');
        System.debug('--->Inside the SharedUnitTestUtils class :  '+sc);
        return sc;
    }

    public static void applyDefaultDrivers(RFQItemWrapper wrapper) {

        List<RFQI_Default_Driver__c> defaultDrivers = DefaultDriverDao.getDefaultDriversForPackageFamily(wrapper.packageFamily.Id);


        String itemObject = wrapper.packageFamily.Specific_RFQ_Item_Object__c;
        String wireObject = wrapper.packageFamily.Specific_Wire_Configuration_Object__c;
        String dieObject = wrapper.packageFamily.Specific_Die_Configuration_Object__c;
        String passiveObject = wrapper.packageFamily.Specific_Passive_Configuration_Object__c;
        String insertionObject = wrapper.packageFamily.Specific_Insertion_Configuration_Object__c;
        
        BaseDao itemDao = new BaseDao(itemObject);
        BaseDao wireDao = StringUtils.isBlank(wireObject) ? null : new BaseDao(wireObject);
        BaseDao dieDao = StringUtils.isBlank(dieObject) ? null : new BaseDao(dieObject);
        BaseDao passiveDao = StringUtils.isBlank(passiveObject) ? null : new BaseDao(passiveObject);
        BaseDao insertionDao = StringUtils.isBlank(insertionObject) ? null : new BaseDao(insertionObject);
        

        

        for (RFQI_Default_Driver__c driver : defaultDrivers) {

            String fieldName = driver.Driver__r.Name;
            String oType = driver.Driver__r.Object__c;
            String fieldValue = String.valueOf(wrapper.getAttribute(fieldName, oType, 0));

            // If parent driver value is not null
            if (!StringUtils.isBlank(fieldValue)) {

                Object val = null;
                String childVal = driver.Child_Value__c;

                Object childFieldVal = wrapper.getAttribute(driver.Child__r.Name, driver.Child__r.Object__c, 0);

                // Only apply the default value if the child value is null or 0
                if (childFieldVal == null || childFieldVal == 0) {
                    if (driver.Read__c) {
                        if (driver.Driver_Value__c != null) {

                            // Re-save and re-grab to refresh the formula
                            RFQItemDao.getInstance().saveLineItem(wrapper);
                            refreshObjectForWrapper(wrapper, oType, itemDao, wireDao, dieDao, passiveDao, insertionDao);

                            // Get the formula field value
                            Object rawVal = wrapper.getAttribute(driver.Driver_Value__c, oType, 0);
                            
                            if (rawVal != null){
                                String strVal = String.valueOf(rawVal);
                                if (!StringUtils.isBlank(strVal)) {
                                    val = DataUtils.convert(strVal, driver.Child__r.Type__c);
                                    wrapper.setAttribute(driver.Child__r.Name, driver.Child__r.Object__c, val, false);   
                                }
                            }
                        }
                    }
                    else if (fieldValue == driver.Driver_Value__c) {
                        val = DataUtils.convert(childVal,driver.Child__r.Type__c);
                        wrapper.setAttribute(driver.Child__r.Name, driver.Child__r.Object__c, val, false);
                    }
                }
            }
        }

        wrapper.rfqItem.Status__c = RFQItemDao.STATUS_NEW;

        RFQItemDao.getInstance().saveLineItem(wrapper);
    }

    private static void refreshObjectForWrapper(RFQItemWrapper wrapper, String objectType, BaseDao itemDao, BaseDao wireDao, BaseDao dieDao, BaseDao passiveDao, BaseDao insertionDao) {
        if (objectType == RFQItemWrapper.PACKAGE_OBJECT) {
            wrapper.specificRfqItem = itemDao.getSObjectById(wrapper.specificRfqItem.Id);
        }
        else if (objectType == RFQItemWrapper.WIRE_OBJECT) {
            wrapper.wireConfigurations = wireDao.getSObjects('Parent__c = ' + BaseDao.quote(wrapper.specificRfqItem.Id)); 
            system.debug('377 wrapper.wireConfigurations'+ wrapper.wireConfigurations);
        }
        else if (objectType == RFQItemWrapper.DIE_OBJECT) {
            wrapper.dieConfigurations = dieDao.getSObjects('Parent__c = ' + BaseDao.quote(wrapper.specificRfqItem.Id)); 
            system.debug('381 wrapper.wireConfigurations'+ wrapper.wireConfigurations);
        }
        else if (objectType == RFQItemWrapper.INSERTION_OBJECT) {
            wrapper.insertionConfigurations = insertionDao.getSObjects('Parent__c = ' + BaseDao.quote(wrapper.specificRfqItem.Id));
            system.debug('385 wrapper.wireConfigurations'+ wrapper.wireConfigurations);
        }
        else if (objectType == RFQItemWrapper.PASSIVE_OBJECT) {
            wrapper.passiveConfigurations = passiveDao.getSObjects('Parent__c = ' + BaseDao.quote(wrapper.specificRfqItem.Id));
            system.debug('389 wrapper.wireConfigurations'+ wrapper.wireConfigurations);
        }
    }
    

}