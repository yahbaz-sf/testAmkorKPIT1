/*************************************************************************
* 
* PURPOSE:  This class send the email to the users post referesh of the sandbox.
*         
* CLASS: PostRefreshSteps
* CREATED: 10/05/2016 KPIT Technologies LTD.
* AUTHOR: Lalit Singh
* 
**************************************************************************/
public class PostRefreshSteps{
    
    public static void UnmaskUsersEmails(){
        String maskStr1 = '@example.com';
        String maskStr2 = '=';
        List<User> lstOfUsersToUpdate = new List<User>();
        String aliases = Label.UserAliases;
        List<string> setUserAliasToUpdate;
        If(aliases!= null)
            setUserAliasToUpdate = aliases.split(';');
        List<user> lstOfUsers = [select id,email,Alias from user where Alias in :setUserAliasToUpdate];
        if(lstOfUsers!=null && lstOfUsers.size()>0){
           
            for(User objUser:lstOfUsers){
                if(objUser.email.contains(maskStr1) || objUser.email.contains(maskStr2)){
                    if(objUser.email.contains(maskStr1))
                        objUser.email = objUser.email.replace(maskStr1,'');
                    if(objUser.email.contains(maskStr2))
                        objUser.email = objUser.email.replace(maskStr2,'@');
                }
                lstOfUsersToUpdate.add(objUser);
            }
            
            if(lstOfUsersToUpdate!=null && lstOfUsersToUpdate.size()>0){
                update lstOfUsersToUpdate;
            }
        }
    }
}