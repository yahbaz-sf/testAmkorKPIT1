/*************************************************************************
* 
* PURPOSE: Class containing Email utility methods
*         
* CLASS: SAPInterface
* CREATED: 11/17/2014 Ethos Solutions - www.ethos.com
* AUTHOR: Kyle Johnson
* 
**************************************************************************/
public class EmailUtil {
	
	/**
     * This method sends an email to the Amkor sfdcAlerts email address
     * containing exception/error details
     *
     * @param subject The subject of the email message we want to send
     * @param message The message (probably exception) being sent
     *
     */
	public static void sendErrorEmail(String subject, String message){

		List<Organization> orgs = [select IsSandbox from Organization];

		//only send if it's in Prod and not the sandboxes
		if(!orgs.isEmpty() && !orgs[0].IsSandbox){

			// the current transaction is committed.
			Messaging.reserveSingleEmailCapacity(1);

			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			String[] toAddresses = new String[] {'sfdcAlerts@amkor.com'}; 
			mail.setToAddresses(toAddresses);
			mail.setSenderDisplayName('SFDC Error Logger');
			mail.setSubject( String.isNotBlank(subject) ? subject : 'New SFDC Error' );
			mail.setPlainTextBody(message);

			//set allOrNone to false to allow non-error messages to be sent even if some fail
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }, false);
		}
	}
}