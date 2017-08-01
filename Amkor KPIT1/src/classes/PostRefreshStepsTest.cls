/*************************************************************************
* 
* PURPOSE:  Test class for PostRefreshSteps
*         
* CLASS: PostRefreshStepsTest
* CREATED: 10/05/2016 KPIT Technologies LTD.
* AUTHOR: Lalit Singh
* 
**************************************************************************/
@isTest
public class PostRefreshStepsTest {

    public static testMethod void test() {
        List<User> users = new List<User>();
        Set<string> setUserAliasToUpdate = new Set<string>{'jstep','acrum'};
        Profile p = [SELECT id FROM profile WHERE name='System Administrator'];
            for (String name : setUserAliasToUpdate)
                {
                    User u = new User(alias = name, email='standarduser=amkor.com@example.com',
                        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                        localesidkey='en_US', profileid = p.Id,
                        timezonesidkey='America/Los_Angeles', username='name@test.com'+math.random());
                    users.add(u);
                }
                insert users;
                
                PostRefreshSteps.UnmaskUsersEmails();
                List<user> tempuser = [select id,email from user where id=:users[0].id];
                system.assertEquals('standarduser@amkor.com', tempuser[0].email);
            }

}