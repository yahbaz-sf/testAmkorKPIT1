@isTest
private class SAPPackageAttributeCreateControllerTest {
    public static SAP_Pricing_Attribute__c createPricingAttribute(){
        SAP_Pricing_Attribute__c pricingAttr = new SAP_Pricing_Attribute__c(Attribute_Name__c = 'Test SAP Pricing Attribute Name',
                                                                            Attribute_Value__c = 'Test Value');
        insert pricingAttr; 
        return pricingAttr;                                                                     
    }

    public static testMethod void testForProductGroupsNotNULL(){
        List<SelectOption> testPckgFmly = new List<SelectOption>();
        List<SelectOption> testPrdGrp = new List<SelectOption>();
        List<SelectOption> testGetFields = new List<SelectOption>();
    
        SAP_Pricing_Attribute__c pricingAttr = createPricingAttribute();
        
        
        PageReference pageRef = Page.SAPPackageAttributeCreate;
        Test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('Id', pricingAttr.Id);
        SAPPackageAttributeCreateController sapController = new SAPPackageAttributeCreateController();
            
        Product_Group__c pg = new Product_Group__c();
        pg = SharedUnitTestUtils.createTestProductGroup();
        sapController.itemProductGroup = pg.Id;
        
        testPckgFmly = sapController.getPackageFamilies();
        testPrdGrp = sapController.getProductGroups();
        //testGetFields = sapController.getFields();
        
        sapController.createPackageAttribute();
        sapController.cancel();
    } 
    
    public static testMethod void testForNULLProductGroups(){
        List<SelectOption> testPckgFmly = new List<SelectOption>();
        List<SelectOption> testPrdGrp = new List<SelectOption>();
        List<SelectOption> testGetFields = new List<SelectOption>();
    
        SAP_Pricing_Attribute__c pricingAttr = createPricingAttribute();
        
        
        PageReference pageRef = Page.SAPPackageAttributeCreate;
        Test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('Id', pricingAttr.Id);
        SAPPackageAttributeCreateController sapController = new SAPPackageAttributeCreateController();
        //sapController.createPackageAttribute();
        
     
        Product_Group__c pg = new Product_Group__c();
        pg = SharedUnitTestUtils.createTestProductGroup();
        Package_Family__c pf = new Package_Family__c();
        pf = SharedUnitTestUtils.createTestPackageFamily();
        sapController.itemPackageFamily = pf.Id;
        sapController.itemProductGroup = pg.Id;
        
        testPckgFmly = sapController.getPackageFamilies();
        testPrdGrp = sapController.getProductGroups();
        //testGetFields = sapController.getFields();
    } 
}