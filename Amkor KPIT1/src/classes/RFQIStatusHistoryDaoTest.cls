/*************************************************************************
*
* PURPOSE: Test code for RFQIStatusHistoryDao
*
* CLASS: RFQIStatusHistoryDaoTest
* CREATED: 07/07/2016 KPIT Technologies Ltd.
* AUTHOR: Bhanu Suthar
***************************************************************************/
@isTest
public with sharing class RFQIStatusHistoryDaoTest
{
      static testMethod void testInstall(){
        Test.StartTest();
        RFQIStatusHistoryDao.AMK1719();
        RFQIStatusHistoryDao.AMK1842();
        RFQIStatusHistoryDao.AMK1843();
        RFQIStatusHistoryDao.AMK1846();
        Test.StopTest();
      }
}