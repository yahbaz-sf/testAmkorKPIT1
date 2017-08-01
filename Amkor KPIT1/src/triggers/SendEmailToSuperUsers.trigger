trigger SendEmailToSuperUsers on RFQ_item__c (after update) {

    RFQ_item__c[] oldItems = Trigger.Old;
    RFQ_item__c[] newItems = Trigger.New;

    List<Messaging.SingleEmailMessage> dummyMessages = new List<Messaging.SingleEmailMessage>();
    
    List<RFQ_Item__c> rfqItems = new List<RFQ_Item__c>();
    List<Id> rfqItemIds = new List<Id>();

    Boolean emailNeeded = false;
    system.debug('SendEmailToSuperUsers trigger line number 12 queries limit :  '+Limits.getQueries());
    //@TODO get rfq items with rfq__r.sbu_name__r.region__c for each rfqi_tests__c and pass this item to getSuperUserEmails() 
    for (Integer i = 0; i < oldItems.size(); i++)
    {
        if (oldItems[i].Status__c != newItems[i].Status__c && newItems[i].Status__c == RFQItemDao.STATUS_PRICE_COMPLETE && newItems[i].Package_Family_Name__c == AMKVARS.PF_TEST)
        {   
            rfqItemIds.add(oldItems[i].Id);
            emailNeeded = true;
        }
    }
    
    system.debug('SendEmailToSuperUsers trigger line number 23 queries limit :  '+Limits.getQueries());
    if (emailNeeded)
    {
        system.debug('SendEmailToSuperUsers trigger line number 25 queries limit :  '+Limits.getQueries());
        Id templateId = [SELECT Id, Name FROM EmailTemplate where DeveloperName =: 'RFQI_Status_Update'].Id;
        system.debug('SendEmailToSuperUsers trigger line number 27 queries limit :  '+Limits.getQueries());
        Contact c = [select id, Email from Contact where email <> null limit 1];
        system.debug('SendEmailToSuperUsers trigger line number 29 queries limit :  '+Limits.getQueries());
        
        rfqItems = [select Id, RFQ__r.SBU_Name__r.Sales_Region__c from RFQ_Item__c where Id in: rfqItemIds];
        system.debug('SendEmailToSuperUsers trigger line number 32 queries limit :  '+Limits.getQueries());
        Map<String, List<String>> superUserEmailMap = RFQItemDao.getInstance().getSuperUserEmails(rfqItems);
        system.debug('value of the superUserEmailMap  : '+superUserEmailMap);
        for(RFQ_Item__c rfqItem : rfqItems) {

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
        try 
        {
        Messaging.sendEmail(dummyMessages);
        }
        catch (EmailException e) 
        {
            DebugUtils.write(e.getMessage(), e.getStackTraceString());
        }
        Database.rollback(sp);

        List<Messaging.SingleEmailMessage> realEmails = new List<Messaging.SingleEmailMessage>();
        for (Messaging.SingleEmailMessage email : dummyMessages) {
            Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
            emailToSend.setToAddresses(email.getToAddresses());
            emailToSend.setPlainTextBody(email.getPlainTextBody());
            emailToSend.setHTMLBody(email.getHTMLBody());
            emailToSend.setSubject(email.getSubject());
            system.debug('emailtosend : '+emailToSend);
            realEmails.add(emailToSend);
            system.debug('value of the realEmails: '+realEmails);
        }

        try 
        {
            Messaging.sendEmail(realEmails);
        }
        catch (EmailException e) 
        {
            DebugUtils.write(e.getMessage(), e.getStackTraceString());
        }
    }


}