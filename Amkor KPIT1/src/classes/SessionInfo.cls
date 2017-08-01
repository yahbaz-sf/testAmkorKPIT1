/*************************************************************************
*
* PURPOSE: Methods for user session information
*
* CLASS: SessionInfo
* CREATED: 3/21/2012 Ethos Solutions - www.ethos.com
* AUTHOR: Jason M. Swenski
***************************************************************************/
public class SessionInfo {
	
	public static String getUserProfileName() {
    	return [select Name from Profile where Id =: UserInfo.getProfileId()].Name;
    }

}