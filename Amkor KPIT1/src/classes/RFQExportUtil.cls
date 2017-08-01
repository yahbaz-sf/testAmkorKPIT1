/*************************************************************************
* 
* PURPOSE:  This class provides misc. supporting functions for the export
*           controllers
*         
* CLASS: RFQExportUtil
* CREATED: 07/31/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Nathan Pilkington npilkington@ethos.com
* 
**************************************************************************/

public with sharing class RFQExportUtil {
    
    /**
     * Generate a PDF quote with the passed in RFQ Item IDs
     *
     * @param rfqId The ID of the RFQ to be generated
     * @param selectedRfqItems A comma seperated list of RFQ Item IDs to include on the quote
     * @param adderBreakoutItems (optional) Comma separated list of which RFQ Items to breakout adders for
     * @param lotChargeItems (optional) Comma separated list of which RFQ items to display account lot charges for
     * @param comments A string with the comments to be included on the RFQ Detail page of the exported PDF
     * @returns The ID of the PDF attachment
     */
    public static String generatePdfQuote(RFQ__c rfq, String selectedRfqItems, String adderBreakoutItems, String lotChargeItems, String separatePostTestItems, String comments) {

        PageReference pdf = Page.RFQPdfExport;
        pdf.getParameters().put('rfqId', rfq.Id);
        pdf.getParameters().put('selectedRfqItems', selectedRfqItems);
        pdf.getParameters().put('adderBreakoutItems', adderBreakoutItems);
        pdf.getParameters().put('lotChargeItems', lotChargeItems);
        pdf.getParameters().put('separatePostTestItems', separatePostTestItems);
        
        if (!StringUtils.isBlank(comments)) {
            // Clean any > or < chars and convert the newlines to line breaks
            comments = comments.escapeHtml4().replace('\n', '<br/>');
            pdf.getParameters().put('comments', comments);
        }
        
        Attachment attach = new Attachment();
        attach.Name = rfq.SBU_Name__r.Name + ', ' + rfq.RFQ_Name__c + ', ' + rfq.Name + ' Quote.pdf';
        attach.IsPrivate = false;
        attach.ParentId = rfq.Id;
        
        Blob body;
     
        try {
            system.debug('in Utils:  '+pdf);
            system.debug('RFQS:  '+rfq);
            body = pdf.getContent();
        } catch (Exception e) {
            // Apex tests do not support the getContent() call. 
            // TODO: Is there a better way to handle this? 
            System.debug('### Caught general exception: ' + e + ' -- ' + e.getStackTraceString());
            body = Blob.valueOf('Error while generating quote: ' + e + ' \r\n ' + e.getStackTraceString());
            attach.Name = 'ERROR.txt';
        } 
     
        attach.Body = body;
        
        insert attach;

        return attach.Id;
    }

    public static String generateCsvQuote(RFQ__c rfq, String selectedItems, Boolean isMasterFormat) {

        PageReference pf = isMasterFormat ? Page.RFQMasterQuoteExport : Page.RFQExport;
        pf.getParameters().put('selectedIds', selectedItems);
        pf.getParameters().put('rfqId', rfq.Id);

        Attachment attach = new Attachment();
        attach.Name = rfq.SBU_Name__r.Name + ', ' + rfq.RFQ_Name__c + ', ' + rfq.Name + ' Export.csv';
        attach.IsPrivate = false;
        attach.ParentId = rfq.Id;

        Blob body;
     
        try {
            body = pf.getContent();
        } catch (VisualforceException e) {
            // Apex tests do not support the getContent() call. 
            // TODO: Is there a better way to handle this? 
            System.debug('### Caught visualforce exception: ' + e);
            body = Blob.valueOf('Error while generating CSV: ' + e);
            attach.Name = 'CSV-ERROR.txt';
        } catch (Exception e) {
            System.debug('### Caught general exception: ' + e);
            //addError('Could not generate quote due to internal error');
            return null;
        }
     
        attach.Body = body;
        
        insert attach;


        return attach.Id;
    }

    /**
     * Generate an Excel quote with the passed in RFQ Item IDs
     *
     * @param rfqId The ID of the RFQ to be generated
     * @param selectedRfqItems A comma seperated list of RFQ Item IDs to include on the quote
     * @param adderBreakoutItems (optional) Comma separated list of which RFQ Items to breakout adders for
     * @param lotChargeItems (optional) Comma separated list of which RFQ items to display account lot charges for
     * @param comments A string with the comments to be included on the RFQ Detail page of the exported PDF
     * @returns The ID of the PDF attachment
     */
    public static String generateExcelQuote(RFQ__c rfq, String selectedRfqItems, String adderBreakoutItems, String lotChargeItems, String comments) {

        PageReference excel = Page.RFQExcelExport;
        excel.getParameters().put('rfqId', rfq.Id);
        excel.getParameters().put('selectedRfqItems', selectedRfqItems);
        excel.getParameters().put('adderBreakoutItems', adderBreakoutItems);
        excel.getParameters().put('lotChargeItems', lotChargeItems);
        
        if (!StringUtils.isBlank(comments)) {
            // Clean any > or < chars and convert the newlines to line breaks
            comments = comments.escapeHtml4().replace('\n', '<br/>');
            excel.getParameters().put('comments', comments);
        }
        
        Attachment attach = new Attachment();
        attach.Name = rfq.SBU_Name__r.Name + ', ' + rfq.RFQ_Name__c + ', ' + rfq.Name + ' Quote.xls';
        attach.IsPrivate = false;
        attach.ParentId = rfq.Id;
        
        Blob body;
     
        try {
            body = excel.getContent();
            } catch (Exception e) {
            // Apex tests do not support the getContent() call. 
            // TODO: Is there a better way to handle this? 
            System.debug('### Caught general exception: ' + e + ' -- ' + e.getStackTraceString());
            body = Blob.valueOf('Error while generating quote: ' + e + ' \r\n ' + e.getStackTraceString());
            attach.Name = 'ERROR.txt';
        } 
     
        attach.Body = body;
        
        insert attach;

        return attach.Id;
    }
}