@isTest
private class EmailUtilTest {
	
	@isTest static void testSendErrorEmail() {
		try
        {
            EmailUtil.sendErrorEmail('Fake Subject', 'Fake message body');
        }
        catch (System.HandledException e) {
            return;
        }
	}
	
}