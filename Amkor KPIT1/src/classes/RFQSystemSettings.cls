/*************************************************************************
*
* PURPOSE: Base Controller for the RFQ Item view/edit page
*
* CLASS: RFQItemController
* CREATED: 4/12/2012 Ethos Solutions - www.ethos.com
* AUTHOR: Raghu Mandali
***************************************************************************/
public class RFQSystemSettings{
    

    /* This method determines if a user can access both the BU and Sales screens
     *
     * @returns true if the user is a hybrid user
     *
     */
    public static String getProspectAccountId() {
        return RFQ_System_Settings__c.getInstance(UserInfo.getProfileId()).Prospect_Account_Id__c;
    }


    /* This method determines if a user can access both the BU and Sales screens
     *
     * @returns true if the user is a hybrid user
     *
     */
    public static Boolean getIsHybridUser() {
        return getIsHybridUser(UserInfo.getProfileId());
    }
    public static Boolean getIsHybridUser(String profileId) {
        return RFQ_System_Settings__c.getInstance(profileId).Is_Hybrid_Profile__c;
    }
    
    /* This methods returns the name of the Queue that represents the BPG users
     *
     *  @returns a string name for the salesforce Queue (Group) the represents the BPG useres
     *
     */
    public static String getBPGWorkQueueName() {
        return RFQ_System_Settings__c.getInstance(UserInfo.getProfileId()).BPG_Work_Queue__c; 
    }
    
    /* This method returns true if the user is a BU User
     *
     * @returns true if the user is defined as a BU user
     *
     */
    public static Boolean getIsBUUser() {
        return getIsBUUser(UserInfo.getProfileId());
    } 
    /* This method returns true if the user is a BU User
     *
     * @returns true if the user is defined as a BU user
     *
     */
     public static Boolean getIsBUUser(String profileId) {
        return RFQ_System_Settings__c.getInstance(profileId).Is_BU_Profile__c;
    } 

    /* This method returns returns the endpoint for the CPN --> SAP interface
     * 
     * @returns a string URL which is the endpoint for the SAP interface
     *
     */
    public static String getSAPCPNEndpoint() {
        return RFQ_System_Settings__c.getOrgDefaults().SAP_CPN_Transmission_Endpoint__c; 
    }

    public static String getSAPCPNAuthorization() {
        String credentials = RFQ_System_Settings__c.getOrgDefaults().SAP_CPN_Transmission_User__c + 
                             ':' + RFQ_System_Settings__c.getOrgDefaults().SAP_CPN_Transmission_Password__c;
   
        return 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(credentials));
    }
}