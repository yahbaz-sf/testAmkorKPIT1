//Trigger consolidation New code KPIT
public class RFQItriggerHandlerNew {

    public void beforeInsert(List < RFQ_Item__c > newRFQIs) {
        populateOpportunityonRFQItem(newRFQIs);
    }

    public void beforeUpdate(List < RFQ_Item__c > newRFQIs, Map < Id, RFQ_Item__c > oldRFQIsById) {
        List < RFQ_Item__c > eligibleRFQIs = new List < RFQ_Item__c > ();
        if (newRFQIs != null && oldRFQIsById != null) {
            for (RFQ_Item__c rfqi: newRFQIs) {
                if (rfqi.RFQ__c != null && rfqi.RFQ__c != oldRFQIsById.get(rfqi.id).RFQ__c) {
                    eligibleRFQIs.add(rfqi);
                }
            }

            if (eligibleRFQIs.size() > 0) {
                populateOpportunityonRFQItem(eligibleRFQIs);
            }
        }
    }

    public void populateOpportunityonRFQItem(List < RFQ_Item__c > rfqiRecords) {
        Set < Id > rfqIds = new Set < Id > ();
        Map < Id, RFQ__c > rfqMap;

        if (rfqiRecords != null) {

            for (RFQ_Item__c rfqi: rfqiRecords) {
                rfqIds.add(rfqi.RFQ__c);
            }
            if (rfqIds.size() > 0) {
                rfqMap = new Map < Id, RFQ__c > ([SELECT Opportunity__c FROM RFQ__c where id =: rfqIds]);
                for (RFQ_Item__c rfqi: rfqiRecords) {

                    if (rfqi.RFQ__c != null) {
                        RFQ__c rfq = rfqMap.get(rfqi.RFQ__c);
                        if (rfq != null && rfq.Opportunity__c != null) {
                            rfqi.Opportunity__c = rfq.Opportunity__c;
                        }
                    }
                }
            }
        }
    }

    Public void RFQIAddServiceStatusUpdate(List < RFQ_Item__c > rfqiNew, List < RFQ_Item__c > rfqiOld) {
        RFQ_Item__c[] oldItems = rfqiOld;
        RFQ_Item__c[] newItems = rfqiNew;

        List < RFQ_Item__c > rfqisToCheck = new List < RFQ_Item__c > ();
        for (RFQ_Item__c addedService: newItems) {
            //find all RFQIs that are an added service and going into a price complete status
            if (addedService.Parent_RFQ_Item__c != null && addedService.Service__c != 'Assembly' && addedService.Status__c == RFQItemDao.STATUS_PRICE_COMPLETE) {
                DebugUtils.write('check item', addedService.Id);
                rfqisToCheck.add(addedService);
            }
        }

        //find the parents of the service items found
        //if the parents are not yet price complete (or past),
        //then update status of added service to "pending assembly approval"
        if (!rfqisToCheck.isEmpty()) {

            //find all parent ids
            Set < String > parentIds = new Set < String > ();
            for (RFQ_Item__c service: rfqisToCheck) {
                parentIds.add(service.Parent_RFQ_Item__c);
            }

            Map < Id, sObject > parentItems = new Map < Id, sObject > (RFQItemDao.getInstance().getSObjectByIdSet('Id', parentIds));

            for (RFQ_Item__c service: rfqisToCheck) {
                RFQ_Item__c parent = (RFQ_Item__c) parentItems.get(service.Parent_RFQ_Item__c);
                //if parent is not approved, then place service into pending status
                if (!RFQItemDao.getInstance().statusGreaterOrEqual(parent, RFQItemDao.STATUS_PRICE_COMPLETE) && !StringUtils.isJSONBlank(parent.Multi_Volume__c)) {
                    service.Status__c = RFQItemDao.STATUS_PENDING_ASSEMBLY_APPROVAL;
                }
            }
        }
    }

    Public void SAPTransmit(List < RFQ_Item__c > rfqiNew) {
        RFQ_Item__c lineItem = rfqiNew[0];
        RFQItemDao itemDao = RFQItemDao.getInstance();
        //We only send to SAP if the status is greater than STATUS_PRICE_COMPLETE
        if (itemDao.statusGreaterOrEqual(lineItem, RFQItemDao.STATUS_PRICE_COMPLETE)) {
            lineItem = itemDao.getById(lineItem.Id);
            if (lineItem.Configured_Part_Number__c != null) {
                Configured_Part_Number__c cpn = CPNDao.getInstance().getById(lineItem.Configured_Part_Number__c);
                //Don't transmit CPNS that have already been transmitted
                if (cpn.Status__c == CPNDao.STATUS_PENDING) {
                    SAPInterface.transmitCPNToSAP(cpn.Id);
                }
            }
        }
        return; //we can only operate on 1, this can never happen in bulk.
    }

    public void RFQStatusUpdate(List < RFQ_Item__c > newRFQITems) {

        RFQ_Item__c[] newItems = newRFQITems;
        Set < Id > rfqIds = new Set < Id > ();
        //get all of the various RFQ for the updated RFQIs
        for (RFQ_Item__c r: newItems) {
            rfqIds.add(r.RFQ__c);
        }
        system.debug('RFQStatusUpdate trigger line number 23 queries limit :  ' + Limits.getQueries());
        List < RFQ_Item__c > rfqItems = [select Id, Status__c, RFQ__c, Opportunity__c from RFQ_Item__c where RFQ__c in: rfqIds];
        Set < Id > rfqsToClose = new Set < Id > ();
        Set < Id > rfqsToOpen = new Set < Id > ();
        for (RFQ_Item__c newItem: rfqItems) {
            system.debug('RFQStatusUpdate trigger line number 36 queries limit :  ' + Limits.getQueries());
            if (RFQItemDao.STATUS_CLOSED.contains(newItem.Status__c)) {
                rfqsToClose.add(newItem.RFQ__c);
            } else if (RFQItemDao.STATUS_OPEN.contains(newItem.Status__c)) {
                rfqsToOpen.add(newItem.RFQ__c);
            }
        }
        //Do not close an RFQ if any of the RFQItems has a status considered to be open
        rfqsToClose.removeAll(rfqsToOpen);
        if (rfqsToClose.size() > 0) RFQDao.closeRFQs(rfqsToClose);
        if (rfqsToOpen.size() > 0) RFQDao.openRFQs(rfqsToOpen);

        if (rfqIds.Size() > 0) {
            Map < String, Opportunity > opportunityMap = new Map < String, Opportunity > ();
            Map < Id, List < RFQ_Item__c >> itemsByOpportunity = new Map < Id, List < RFQ_Item__c >> ();
            for (RFQ_Item__c item: rfqItems) {
                system.debug('RFQStatusUpdate trigger line number 58 queries limit :  ' + Limits.getQueries());
                //Populate the itemsByOpportunity basically re-build the Opportinity RFQItem related list
                //why not just query it Who konws, maybe SFDC limitation or query limiter Really no telling
                if (itemsByOpportunity.containsKey(item.Opportunity__c)) {
                    //if the map already conatins the opportunity then add this RFQItem to it's list
                    itemsByOpportunity.get(item.Opportunity__c).add(item);
                } else {
                    //Opportunity is not currently in the map, so add it and add the RFQItem to the list
                    itemsByOpportunity.put(item.Opportunity__c, new List < RFQ_Item__c > {
                        item
                    });
                }
                //Build a map of Opportunity objects withe their Ids?
                //Again I'm really not sure why we are building a map
                if (!opportunityMap.containsKey(item.Opportunity__c)) {
                    //if the current RFQItem is not related to the Opportunity then add it to the map
                    Opportunity o = new Opportunity();
                    o.Id = item.Opportunity__c;
                    opportunityMap.put(o.Id, o);
                }
            }

            for (Opportunity o: opportunityMap.Values()) {
                RFQ_Item__c higestStatusedItem = RFQOpportunityDao.getHighestStatusItem(itemsByOpportunity.get(o.Id));
                o.StageName = RFQOpportunityDao.mapStatusToStage(higestStatusedItem);
                o.Opportunity_Status__c = RFQOpportunityDao.mapRFQStatusToOpportunityStatus(higestStatusedItem);
            }

            if (opportunityMap.size() > 0) {
                try {
                    system.debug('---->Trigger:RFQStatusUpdate (after update), opp before update call : ' + opportunityMap.Values());
                    //SALESFORCE-107 lalit singh : Volume config RFQI's are not getting created and responded back to Sales  Start
                    //Commenting below update statement temprarily for the testin purpose, we may comment permanently after discussion with Adam.
                    //update opportunityMap.Values();
                } catch (Exception e) {
                    // do nothing, still allow the item to update and the rfq to update
                }
            }
        }
    }

    public void RFQStatusHistory(List < RFQ_Item__c > rfqiNew, List < RFQ_Item__c > rfqiOld) {
        RFQ_Item__c[] oldItems = rfqiOld;
        RFQ_Item__c[] newItems = rfqiNew;

        List < RFQI_Status_History__c > deleteList = new List < RFQI_Status_History__c > ();
        List < RFQI_Status_History__c > insertList = new List < RFQI_Status_History__c > ();

        Map < Id, RFQItemWrapper > result = new Map < Id, RFQItemWrapper > ();
        Map < Id, Package_Family__c > pfMap = new Map < Id, Package_Family__c > (PackageFamilyDao.getInstance().getAllPackageFamilies());

        Set < String > rfqitemIds = new Set < String > ();
        for (RFQ_Item__c item: newItems) rfqitemIds.add(item.Id);

        List < RFQI_Status_History__c > statusHistories = RFQIStatusHistoryDao.getInstance().getByRfqItems(rfqitemIds);
        system.debug('RFQStatusHistory at line number 25 statusHistories' + statusHistories);
        Map < Id, List < RFQI_Status_History__c >> statusMap = new Map < Id, List < RFQI_Status_History__c >> ();

        List < RFQI_Status_History__c > histList;
        for (RFQI_Status_History__c history: statusHistories) {
            system.debug('RFQStatusHistory at line number 25 history : ' + history);
            if (statusMap.containsKey(history.RFQ_Item__c)) {
                statusMap.get(history.RFQ_Item__c).add(history);
            } else {
                histList = new List < RFQI_Status_History__c > ();
                histList.add(history);
                statusMap.put(history.RFQ_Item__c, histList);
            }
        }
        system.debug('RFQStatusHistory at line number 43 statusMap : ' + statusMap);
        for (RFQ_Item__c rfqItem: newItems) {

            RFQItemWrapper wrapper = new RFQItemWrapper();
            wrapper.rfqItem = rfqItem;
            wrapper.statusHistories = statusMap.get(rfqItem.Id);
            result.put(rfqItem.Id, wrapper);
        }

        // Go through all the items and see if any statuses have changed, if so then make a new status history
        for (Integer i = 0; i < oldItems.size(); i++) {
            if (!(StringUtils.isMatch(oldItems[i].Status__c, newItems[i].Status__c))) {
                RFQItemWrapper wrapper = result.get(newItems[i].Id);
                if (RFQItemDao.reportableStatuses.contains(newItems[i].Status__c)) {
                    //add new status if should report on it 
                    RFQIStatusHistoryDao.getInstance().updateStatusHistory(wrapper, insertList);
                } else if (RFQItemDao.getInstance().statusLessOrEqual(newItems[i].Status__c, oldItems[i].Status__c)) {
                    RFQIStatusHistoryDao.getInstance().deleteStatusHistory(wrapper, deleteList);
                }
            }
        }
        if (!insertList.isEmpty()) insert insertList;
        if (!deleteList.isEmpty()) delete deleteList;
    }


    public void SendEmailToSuperUsers(List<RFQ_Item__c> rfqiNew, List<RFQ_Item__c> rfqiOld) {
        RFQ_item__c[] oldItems = rfqiOld;
        RFQ_item__c[] newItems = rfqiNew;

        List < Messaging.SingleEmailMessage > dummyMessages = new List < Messaging.SingleEmailMessage > ();

        List < RFQ_Item__c > rfqItems = new List < RFQ_Item__c > ();
        List < Id > rfqItemIds = new List < Id > ();

        Boolean emailNeeded = false;
        system.debug('SendEmailToSuperUsers trigger line number 12 queries limit :  ' + Limits.getQueries());
        //@TODO get rfq items with rfq__r.sbu_name__r.region__c for each rfqi_tests__c and pass this item to getSuperUserEmails() 
        for (Integer i = 0; i < oldItems.size(); i++) {
            if (oldItems[i].Status__c != newItems[i].Status__c && newItems[i].Status__c == RFQItemDao.STATUS_PRICE_COMPLETE && newItems[i].Package_Family_Name__c == AMKVARS.PF_TEST) {
                rfqItemIds.add(oldItems[i].Id);
                emailNeeded = true;
            }
        }

        system.debug('SendEmailToSuperUsers trigger line number 23 queries limit :  ' + Limits.getQueries());
        if (emailNeeded) {
            system.debug('SendEmailToSuperUsers trigger line number 25 queries limit :  ' + Limits.getQueries());
            Id templateId = [SELECT Id, Name FROM EmailTemplate where DeveloperName =: 'RFQI_Status_Update'].Id;
            system.debug('SendEmailToSuperUsers trigger line number 27 queries limit :  ' + Limits.getQueries());
            Contact c = [select id, Email from Contact where email <> null limit 1];
            system.debug('SendEmailToSuperUsers trigger line number 29 queries limit :  ' + Limits.getQueries());

            rfqItems = [select Id, RFQ__r.SBU_Name__r.Sales_Region__c from RFQ_Item__c where Id in: rfqItemIds];
            system.debug('SendEmailToSuperUsers trigger line number 32 queries limit :  ' + Limits.getQueries());
            Map < String, List < String >> superUserEmailMap = RFQItemDao.getInstance().getSuperUserEmails(rfqItems);
            system.debug('value of the superUserEmailMap  : ' + superUserEmailMap);
            for (RFQ_Item__c rfqItem: rfqItems) {

                DebugUtils.write('superUserEmailMap', superUserEmailMap);

                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setTemplateId(templateId);
                email.setToAddresses(superUserEmailMap.get(rfqItem.Id));
                email.setTargetObjectId(c.Id); //dummy contact
                email.setwhatId(rfqItem.Id); //rfq item

                dummyMessages.add(email);

            }

            // Send the emails in a transaction, then roll it back
            //logic gotten from http://www.opfocus.com/blog/sending-emails-in-salesforce-to-non-contacts-using-apex/
            Savepoint sp = Database.setSavepoint();
            try {
                Messaging.sendEmail(dummyMessages);
            } catch (EmailException e) {
                DebugUtils.write(e.getMessage(), e.getStackTraceString());
            }
            Database.rollback(sp);

            List < Messaging.SingleEmailMessage > realEmails = new List < Messaging.SingleEmailMessage > ();
            for (Messaging.SingleEmailMessage email: dummyMessages) {
                Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
                emailToSend.setToAddresses(email.getToAddresses());
                emailToSend.setPlainTextBody(email.getPlainTextBody());
                emailToSend.setHTMLBody(email.getHTMLBody());
                emailToSend.setSubject(email.getSubject());
                system.debug('emailtosend : ' + emailToSend);
                realEmails.add(emailToSend);
                system.debug('value of the realEmails: ' + realEmails);
            }

            try {
                Messaging.sendEmail(realEmails);
            } catch (EmailException e) {
                DebugUtils.write(e.getMessage(), e.getStackTraceString());
            }
        }
    }
}