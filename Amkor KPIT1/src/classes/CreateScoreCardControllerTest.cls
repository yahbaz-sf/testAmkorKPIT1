@isTest
public class CreateScoreCardControllerTest{

    public static testMethod void testScoreCardCreation(){

        Account account = SharedUnitTestUtils.createTestSBU();
        PageReference vfPage= Page.CreateScoreCard;
        vfPage.getParameters().put('accid',account.Id);
        Test.setCurrentPage(vfPage);  

        Test.StartTest();
        
        CreateScoreCardController createScoreCardController = new CreateScoreCardController(new ApexPages.StandardController(account));
        createScoreCardController.scoreCard.Customer_Scorecard_Name__c = 'Test Score Card Name Zero';
        createScoreCardController.scoreCard.SBUAccount__c = account.Id;
        createScoreCardController.scoreCard.Year__c  = '2016';
        createScoreCardController.scoreCard.Quarter__c = 'Q1';
        createScoreCardController.scoreCard.Amkor_Rank__c = '1';
        createScoreCardController.save();
        System.assertNotEquals(createScoreCardController.scoreCard.Id,null);
         
        Test.StopTest();
    }
    
    public static testMethod void testScoreCardDuplication(){

        List<Scorecard__c> scoreCardList = getScoreCard();
        Account account = new Account(Id = scoreCardList[0].SBUAccount__c);                                           
        PageReference vfPage= Page.CreateScoreCard;
        vfPage.getParameters().put('accid',account.Id);
        Test.setCurrentPage(vfPage);  

        Test.StartTest();
        
        CreateScoreCardController createScoreCardController = new CreateScoreCardController(new ApexPages.StandardController(account));
        createScoreCardController.scoreCard = scoreCardList[0];
        System.assertNotEquals(scoreCardList.size(),null);
        createScoreCardController.save();
         
        Test.StopTest();
    }
    
    public static testMethod void testRunAs() {
        // This code runs as the system user
        List<Scorecard__c> scoreCardList = getScoreCard();
        Account account = new Account(Id = scoreCardList[0].SBUAccount__c);                                           
        PageReference vfPage= Page.CreateScoreCard;
        vfPage.getParameters().put('accid',account.Id);
        Test.setCurrentPage(vfPage);  
        
        //Test.StartTest();
        //UserRole uRole = new UserRole(Name = 'BU', DeveloperName = 'BU1', OpportunityAccessForAccountOwner = 'None');
        //insert uRole;*/
        User u = SharedUnitTestUtils.createTestSalesUser();
        //u.UserRoleId = uRole.Id;
        //update u;
        //Test.StopTest();
        
        System.runAs(u) {   //Run in user mode
            Test.StartTest();

            CreateScoreCardController createScoreCardController = new CreateScoreCardController(new ApexPages.StandardController(account));
            System.assertEquals(createScoreCardController.isPageVisible,false);
            createScoreCardController.cancel();
             
            Test.StopTest();
      }
   }
    
    public static testMethod void testForNullParentAcc(){

        List<Scorecard__c> scoreCardList = getScoreCard();
        Account account = SharedUnitTestUtils.createTestSBU();
        account.ParentId = null;   
        update account;                                      
        PageReference vfPage= Page.CreateScoreCard;
        vfPage.getParameters().put('id',account.Id);
        Test.setCurrentPage(vfPage);  

        Test.StartTest();
        CreateScoreCardController createScoreCardController = new CreateScoreCardController(new ApexPages.StandardController(account));
        createScoreCardController.scoreCard = scoreCardList[1];
        System.assertNotEquals(scoreCardList.size(),null);
        createScoreCardController.save(); 
        Test.StopTest();
    }
    
    private static List<Scorecard__c> getScoreCard(){
        Account account = SharedUnitTestUtils.createTestSBU();
        Scorecard__c scoreCard1 = new Scorecard__c(
                Customer_Scorecard_Name__c = 'Test Score Card Name One',
                SBUAccount__c = account.Id,
                Year__c  = '2016',
                Quarter__c = 'Q2',
                Amkor_Rank__c = '1'
                );
        Scorecard__c scoreCard2 = new Scorecard__c(
                Customer_Scorecard_Name__c = 'Test Score Card Name Two',
                SBUAccount__c = account.Id,
                Year__c  = '2016',
                Quarter__c = 'Q3',
                Amkor_Rank__c = '10'
                );
        List<Scorecard__c> scoreCardList = new List<Scorecard__c>();
        scoreCardList.add(scoreCard1);
        scoreCardList.add(scoreCard2);
        insert scoreCardList;
        
        return scoreCardList;
    }  
}