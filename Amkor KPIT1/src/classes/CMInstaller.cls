/*************************************************************************
*
* PURPOSE: Global CM Installer logic
*
* CLASS: CMInstaller
* CREATED: 5/01/2013 Ethos Solutions - www.ethos.com 
* AUTHOR: Steve Simpson
***************************************************************************/
global class CMInstaller 
{
	global static void cleanAndInstall() 
	{
		clean();
		install();
	}
	
	global static void install() {
		installMLF();
		installQuad();
		installDual();
	}

	global static void installMLF() {
		CMMLFInstaller.install();
	}

	global static void installQuad(){
		CMQuadInstaller.install();
	}

	global static void installDual() {
        CMDualInstaller.install();
		CMDualMarginInstaller.install();
	}
	
	global static void clean()
	{
		CMDualInstaller.clean();
		CMDualMarginInstaller.clean();
	}
	
	global static void cleanData()
	{
		List<RFQI_Process__c> processList = [Select id from RFQI_Process__c];
		delete processList;
		
		List<FCM_Match_Condition__c> matchList = [Select id from FCM_Match_Condition__c];
		delete matchList;
		
		List<FCM_BOM__c> bomList = [Select id from FCM_BOM__c];
		delete bomList;
		
		List<FCM_Process__c> procList = [Select id from FCM_Process__c];
		delete procList;
		
		List<RFQI_FCM__c> iFcmList = [Select id from RFQI_FCM__c];
		delete iFcmList;
	}
}