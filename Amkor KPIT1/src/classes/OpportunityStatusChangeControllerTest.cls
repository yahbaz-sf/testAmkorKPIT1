@isTest(SeeAllData=false)
public class OpportunityStatusChangeControllerTest{
    public Opportunity oppty{get;set;}
    public boolean isAbleToChange{get;set;}
    
    
    public static testMethod void testOpportunityForRFQNull(){
                
        Opportunity oppty = new Opportunity();
        oppty = SharedUnitTestUtils.createTestOpportunity();        
        PageReference vfPage= new PageReference('/apex/OpportunityStatusChange'); 
        Test.setCurrentPage(vfPage);    
        
        OpportunityStatusChangeController opptyStatusChangeCtrl = new OpportunityStatusChangeController(new ApexPages.StandardController(oppty));               
        System.assertequals(opptyStatusChangeCtrl.isAbleToChange , True);
        
    }
    
    public static testMethod void testOpportunityForRFQNotNull(){
        RFQ__c rfq = new RFQ__c();
        rfq = SharedUnitTestUtils.createTestRFQ();
        Opportunity oppty = new Opportunity(Name = 'ZZ Test Opportunity Unit Test',
                                RFQ__c = rfq.Id
                                );
        
                    
        OpportunityStatusChangeController opptyStatusChangeCtrl = new OpportunityStatusChangeController(new ApexPages.StandardController(oppty));
        System.assertequals(opptyStatusChangeCtrl.isAbleToChange , False);
        
    }
    
}