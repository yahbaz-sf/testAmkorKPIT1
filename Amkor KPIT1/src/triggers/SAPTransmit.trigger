/*************************************************************************
* 
* PURPOSE: SAPTransmit trigger calls out to SAP to send over the CPN
*          
*          
* CLASS: SAPTransmit
* CREATED: 06/12/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Jason Swenski
* 
**************************************************************************/
trigger SAPTransmit on RFQ_Item__c (after insert, after update) {

    RFQ_Item__c lineItem = Trigger.new[0];
        RFQItemDao itemDao = RFQItemDao.getInstance();
        //We only send to SAP if the status is greater than STATUS_PRICE_COMPLETE
        if(itemDao.statusGreaterOrEqual(lineItem,RFQItemDao.STATUS_PRICE_COMPLETE)) {
            lineItem = itemDao.getById(lineItem.Id);
            if(lineItem.Configured_Part_Number__c != null) {
            Configured_Part_Number__c cpn = CPNDao.getInstance().getById(lineItem.Configured_Part_Number__c);
            //Don't transmit CPNS that have already been transmitted
                if(cpn.Status__c == CPNDao.STATUS_PENDING) {
                    SAPInterface.transmitCPNToSAP(cpn.Id);
                }
            }
        }
        return; //we can only operate on 1, this can never happen in bulk.
}