/*************************************************************************
*
* PURPOSE: Test code for ServiceInstaller
*
* CLASS: ServiceInstallerTest
* CREATED: 07/07/2016 KPIT Technologies Ltd.
* AUTHOR: Bhanu Suthar
***************************************************************************/
@isTest
public with sharing class ServiceInstallerTest
{
    static testMethod void testInstall(){
        
        RFQAdminInstaller.install();
        
        ServiceInstaller.install();
        
        List<Product_Group__c> prodGroup = [select Id from Product_Group__c where Name =: 'Standalone Services'];
        
        prodGroup = [select Id from Product_Group__c];
        
        List<Package_Family__c> families = [select Id, Name from Package_Family__c where Product_Group__c = :prodGroup[0].Id];
        
        serviceInstaller.incrementalInstall1();
        serviceInstaller.AMK1818();
        serviceInstaller.AMK1819Part1();
        serviceInstaller.AMK1819();
        serviceInstaller.AMK1825();
        serviceInstaller.AMK1870();
        serviceInstaller.AMK1870_2();
        serviceInstaller.AMK1870_3();
    
    }
}