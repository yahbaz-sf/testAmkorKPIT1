@isTest
public class FCMAssumptionControllerTest{
    public static testMethod void testAssumption(){
    
        Package_Family__c pf = SharedUnitTestUtils.createTestPackageFamily();
        Factory__c factory = new Factory__c(Name = 'Test Factory',Package_Family__c = pf.Id);
        Product_Group__c pg =  SharedUnitTestUtils.createTestProductGroup();
        CM_Version__c cmVersion = new CM_Version__c(Product_Group__c = pg.Id);
        insert cmVersion;
        FCM_Assumption__c fcmAssumption = new FCM_Assumption__c(Package_Family__c = pf.Id,
                                                                Factory__c = factory.Id,
                                                                CM_Version__c = cmVersion.Id,
                                                                Product_Group__c = pg.Id);
        insert fcmAssumption;
        PageReference pgRef = Page.FCMAssumptionEdit;
        Test.setCurrentPage(pgRef);   
        PageUtil.putParam('versionId',cmVersion.Id);                                                     
        FCMAssumptionController controller = new FCMAssumptionController(new ApexPages.StandardController(fcmAssumption));  
        controller.setupAction();
        controller.editAction();
        controller.saveAction();
        controller.cancelAction();
        controller.deleteAction();                                                   
    }
    
    public static testMethod void testNullAssumption(){      
        PageReference pgRef = Page.FCMAssumptionEdit;
        Test.setCurrentPage(pgRef);                                                    
        FCMAssumptionController controller = new FCMAssumptionController(new ApexPages.StandardController(new FCM_Assumption__c()));
        controller.setupAction();
    }
}