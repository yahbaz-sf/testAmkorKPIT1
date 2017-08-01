@isTest
public class OpportunityEditControllerTest{
    public Opportunity oppty{get;set;}
    public boolean isAbleToChange{get;set;}
    
    
    public static testMethod void testOpportunityForRFQNull(){
                
        Opportunity oppty = new Opportunity();
        oppty = SharedUnitTestUtils.createTestOpportunity();        
        PageReference vfPage= new PageReference('/apex/OpportunityEdit'); 
        Test.setCurrentPage(vfPage);    
        
        OpportunityEditController opptyEditCtrl = new OpportunityEditController(new ApexPages.StandardController(oppty));               
        System.assertequals(opptyEditCtrl.isAbleToChange , True);
        
    }
    
    public static testMethod void testOpportunityForRFQNotNull(){
        RFQ__c rfq = new RFQ__c();
        rfq = SharedUnitTestUtils.createTestRFQ();
        Opportunity oppty = new Opportunity(Name = 'ZZ Test Opportunity Unit Test',
                                RFQ__c = rfq.Id
                                );
        OpportunityEditController opptyEditCtrl = new OpportunityEditController(new ApexPages.StandardController(oppty));
        System.assertequals(opptyEditCtrl.isAbleToChange , False);
        
    }
    
}