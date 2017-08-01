@isTest
public class TestSetupDemo {
    public static List<Account> accounts;
     
    @testSetup static void setupWrappers()
    {
       accounts = new List<Account>();
        for(Integer i=0;i < 10;i++){
            accounts.add(new Account(Name = 'Test Acc'));
        }
        insert accounts;
        System.debug('--->'+[SELECT Id, Name FROM Account]);
    }
}