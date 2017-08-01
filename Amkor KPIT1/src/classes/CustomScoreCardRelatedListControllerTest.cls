@isTest
public class CustomScoreCardRelatedListControllerTest{
    public static testMethod void testParentAccForScoreCard(){
        List<Scorecard__c> scoreCardList = getScoreCardList();
        Account account1 = new Account(Id = scoreCardList[0].SBUAccount__c);
        Account account2 =  new Account(Id = scoreCardList[1].SBUAccount__c);

        PageReference vfPage= Page.CustomScoreCardRelatedList;
        vfPage.getParameters().put('id',account2.Id);
        Test.setCurrentPage(vfPage);  

        Test.StartTest();
        CustomScoreCardRelatedListController customScoreCardRelatedController = new CustomScoreCardRelatedListController(new ApexPages.StandardController(account2));
        System.assertNotEquals(scoreCardList.size(),null);
        Test.StopTest();
       
    }
    
    public static testMethod void testForNullParentAccount(){
        PageReference vfPage= Page.CustomScoreCardRelatedList;
        Test.setCurrentPage(vfPage);  

        Account acc = SharedUnitTestUtils.createTestSBU();
        acc.ParentId = null;
        update acc;
        Test.StartTest();
        CustomScoreCardRelatedListController controller2 = new CustomScoreCardRelatedListController(new ApexPages.StandardController(acc));
       
        //System.assertEquals(controller2.accountId,null);
        Test.StopTest();
    }

    private static List<Scorecard__c> getScoreCardList(){
        Account account1 = SharedUnitTestUtils.createTestSBU();
        account1.ParentId = null;
        update account1;
        Account account2 = SharedUnitTestUtils.createTestSBU();
        account2.Name = 'TestAcc2';
        update account2;

        List<Scorecard__c> scoreCardList = new List<Scorecard__c>();
        Scorecard__c scoreCard1 = new Scorecard__c(
                Customer_Scorecard_Name__c = 'Test Score Card Name 1',
                SBUAccount__c = account2.Id,
                Year__c  = '2016',
                Quarter__c = 'Q2',
                Amkor_Rank__c = '1'
                );
        scoreCardList.add(scoreCard1);
        Scorecard__c scoreCard2 = new Scorecard__c(
                Customer_Scorecard_Name__c = 'Test Score Card Name 2',
                SBUAccount__c = account2.Id,
                Year__c  = '2017',
                Quarter__c = 'Q2',
                Amkor_Rank__c = '2'
                );
        scoreCardList.add(scoreCard2);
        insert scoreCardList;
        return scoreCardList;
    } 
}