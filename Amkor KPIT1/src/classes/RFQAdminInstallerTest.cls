/*************************************************************************
* 
* PURPOSE:  unit tests for RFQAdminInstaller
*          
*         
* CLASS: RFQAdminInstallerTest
* CREATED: 05/19/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Raghuveer Mandali
* 
**************************************************************************/
@isTest
private class RFQAdminInstallerTest {

    private static testMethod void installTest() {
        RFQAdminInstaller.install();
        List<RFQI_Field_Def__c> fd = [Select Id from RFQI_Field_Def__c];
        system.assert(fd.size() != 0);
        
        RFQAdminInstaller.installFactories();
		List<Factory__c> factories = [Select Id from Factory__c];
        system.assert(factories.size() != 0);
        
       /* RFQAdminInstaller.installAccounts();
        List<Account> accounts = [Select Id from Account];
        system.assert(accounts.size() != 0);
        
        RFQAdminInstaller.cleanAccounts();
        accounts = [Select Id from Account];
        system.assert(accounts.size() == 0);*/
        
        RFQAdminInstaller.cleanFactories();
        factories = [Select Id from Factory__c];
        system.assert(factories.size() == 0);
        
        RFQAdminInstaller.installRFQSystemSettings();
        RFQ_System_Settings__c RFQSS = [Select Id from RFQ_System_Settings__c];
        system.assert(RFQSS != null);
        
    }
}