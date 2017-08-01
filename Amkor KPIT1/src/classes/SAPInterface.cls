/*************************************************************************
* 
* PURPOSE: Interface methods for SAP integration Epic AMK-88
*         
* CLASS: SAPInterface
* CREATED: 03/04/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Jason Swenski
* 
**************************************************************************/
global class SAPInterface {
    
    private static final String STATUS_SUCCESS = 'Success';
    private static final String STATUS_ERROR = 'Error';
    
    /**
     * This method accepts a SD25DTCustomerBilling object from SAP and updates
     * the corresponding RFQ Line Items in SFDC if no match is found for a particular item
     * an exception process is launched. See AMK-192, AMK-82
     *
     * @param  billings - an object which contains a list of CPNs and Customers to match RFQ Line 
     *                    items to
     *
     */
    webService static void updateBillingItems(SD25DTCustomerBilling billings) {
        if(billings != null){
        	
        	logInterfaceAccess('updateBillingItems', billings);
            SAPInterfaceResult resultInstance = SAPBillingItemController.updateBillingItems(billings);
            
            if(resultInstance != null && resultInstance.isError){
            	
            	//Bhanu - 13-Apr-2016 : SFDC-SAP Interface Tickets : Providing Descriptive Error Mail 
				//Passed Additional Argument "customerHierarchy" to logInterfaceException method
				logInterfaceException('updateBillingItems',resultInstance, billings);
            }
        }
    }
    
    /**
     * This method accepts a SD26DTPricingAttribute object from SAP and makes
     * the corresponding attribute value available to be used by package families
     *
     * @param  attribute - an object which contains the attribute value and the target field to update
     *                    
     */
    webService static void updatePricingAttribute(SD26DTPricingAttribute attribute) {
         //SAPAttributeController
         if(attribute!= null){
            logInterfaceAccess('updatePricingAttribute', attribute);
            SAPInterfaceResult resultInstance = SAPAttributeController.updatePricingAttribute(attribute);
            
            if(resultInstance != null && resultInstance.isError){
			
				//Bhanu - 13-Apr-2016 : SFDC-SAP Interface Tickets : Providing Descriptive Error Mail 
				//Passed Additional Argument "customerHierarchy" to logInterfaceException method
				logInterfaceException('updatePricingAttribute', resultInstance, attribute);
			}
    	}
    }
    
    /**
      * This method accepts a ZIDEBMASDEBMAS06ZIDEBMASEXT object from SAP and makes
      * upserts customer accounts, see AMK-140
      *
      * @param  customerMaster - an esoteric SAP object that represents god knows what
      *                   
      */
    webService static void updateCustomerMaster(ZIDEBMASDEBMAS06ZIDEBMASEXT customerMaster) {
    	if(customerMaster != null){
    		
        	logInterfaceAccess('updateCustomerMaster', customerMaster);
            system.debug('---->customerMaster :  '+customerMaster);
        	SAPInterfaceResult resultInstance =  SAPCustomerMasterController.updateCustomerMaster(customerMaster);
        	system.debug('At Line number 73 :  '+resultInstance);
        
        	if(resultInstance != null && resultInstance.isError){
        	    //Bhanu - 13-Apr-2016 : SFDC-SAP Interface Tickets : Providing Descriptive Error Mail 
                //Passed Additional Argument "customerHierarchy" to logInterfaceException method
                logInterfaceException('updateCustomerMaster', resultInstance, customerMaster);
        	}
        }
    }
   
    /**
     * This method accepts a CONDA02 object from SAP and makes
     * updates the customer gold price
     *
     * @param  customerGold - an esoteric SAP object that represents god knows what
     *                   
     */
    webService static void updateCustomerGoldPrice(CONDA02 customerGold) {
        //SAPCustomerGoldPriceController
        if(customerGold != null){
        	
            logInterfaceAccess('updateCustomerGoldPrice', customerGold);
            SAPInterfaceResult resultInstance =  SAPCustomerGoldPriceController.updateCustomerGoldPrice(customerGold);  
            
            if(resultInstance != null && resultInstance.isError){
			
				//Bhanu - 13-Apr-2016 : SFDC-SAP Interface Tickets : Providing Descriptive Error Mail 
				//Passed Additional Argument "customerHierarchy" to logInterfaceException method
				logInterfaceException('updateCustomerGoldPrice',resultInstance, customerGold);
			} 
        }
    }
    
     /**
     * This method accepts a ZICUSHIE01 object from SAP and makes
     * updates the customer gold price
     *
     * @param  customerHierarchy - an esoteric SAP object that represents god knows what
     *                   
     */
    webService static void updateCustomerHierarchy(ZICUSHIE01 customerHierarchy) {
        //SAPCustomerHierarchyController
        if(customerHierarchy != null) {
            
            logInterfaceAccess('updateCustomerHierarchy', customerHierarchy);
            SAPInterfaceResult resultInstance = SAPCustomerHierachyController.updateCustomerHierarchy(customerHierarchy);
            
            if(resultInstance != null && resultInstance.isError){
                
                //Bhanu - 13-Apr-2016 : SFDC-SAP Interface Tickets : Providing Descriptive Error Mail 
                //Passed Additional Argument "customerHierarchy" to logInterfaceException method
                logInterfaceException('updateCustomerHierarchy', resultInstance, customerHierarchy);
            }
        }
    }
    
    //Outbound
    public static void transmitCPNToSAP(String cpnId) {
        Configured_Part_Number__c cpn = CPNDao.getInstance().getById(cpnId);
        try {
            logInterfaceAccess('transmitCPNToSAP', cpnId);
            SAPCPNTransmitController.transmitCPNToSAP(cpnId);
                //TODO - do not actually know this yet since 
                //transmission is in a future context
        //cpn.Status__c = CPNDao.STATUS_TRANSMITTED;
            
        }
        catch(Exception e) {
            logInterfaceException('transmitCPNToSAP',getExceptionData(e), null);
            System.debug(LoggingLevel.ERROR, '###Exception: ' + getExceptionData(e));
            //cpn.Status__c = CPNDao.STATUS_TRANSMIT_FAILED;
        }
        CPNDao.getInstance().saveCPN(cpn);
        
    }
    
    
    /**
     * This method stringifies an object passed into the interface and
     * writes a log item to the database
     *
     * @param methodName The method that the log item is coming from
     * @param inObj The object that was passed into the webservice method
     *
     */
     
    public static void logInterfaceAccess(String methodName, Object inObj) {
        System.debug('--->'+inObj);
        logInterfaceAccessJSON(methodName, inObj, STATUS_SUCCESS);
    }
    
    //***START************************************METHODS TO BE REMVED LATERE **********
    public static void logInterfaceException(String methodName, Object inObj,  Object dataFromSAP ) {
        logInterfaceAccessRAW(methodName, inObj, STATUS_ERROR, dataFromSAP);
    }
    public static void logInterfaceAccessRAW(String methodName, Object inObj, String status, Object dataFromSAP) {
        
    }
    //***END**************************************METHODS TO BE REMVED LATERE **********
    
    
    //Bhanu - 11-Apr-2016 : SFDC-SAP Interface Tickets : Providing Descriptive Error Mail 
    //Fix : Error Message & Message Content not updated correctly
    //public static void logInterfaceException(String methodName, Object inObj,  Object dataFromSAP ) {
    public static void logInterfaceException(String methodName, SAPInterfaceResult result,  Object dataFromSAP ) {
        logInterfaceAccessRAW(methodName, result, STATUS_ERROR, dataFromSAP);
    }
    
    //public static void logInterfaceAccessRAW(String methodName, Object inObj, String status, Object dataFromSAP) {
    public static void logInterfaceAccessRAW(String methodName, SAPInterfaceResult result, String status, Object dataFromSAP) {
        try {

            Boolean sentErrorEmail = true;
            
            System.debug(LoggingLevel.ERROR, '###Exception: ' + result.errorMessage);
            String message = createMessage(methodName, result);
            
            try{
                //AMK-2509: send email to sfdcAlerts@amkor.com containing SAP interface errors
                //EmailUtil.sendErrorEmail('New SAP Interface Error', 'Method Name: '+methodName+'\n\nMessage Content: '+String.valueOf(inObj)+'\n\nDate/Time: '+Datetime.now());
                EmailUtil.sendErrorEmail('New SAP Interface Error', message);
            }catch(Exception ex){
                sentErrorEmail = false;
            }
            
            SAP_Interface_Log__c logItem = new SAP_Interface_Log__c
            (
                Method_Name__c = methodName,
                Status__c = status,
                Sent_Error_Email__c = sentErrorEmail                
            );
            
            //Bhanu - 11-Apr-2016 : SFDC-SAP Interface Tickets : Providing Descriptive Error Mail 
            //Fix : Error Message & Message Content not updated correctly
            if(dataFromSAP != null) {
                logItem.Message_Content__c = String.valueOf(dataFromSAP);
            }
            if(String.isNotBlank(result.errorMessage)) {
                logItem.Error_Message__c = result.errorMessage;
            }
                
            insert logItem;
        } catch (Exception e) {
            // In case we couldn't serialize the object or something
            System.debug(LoggingLevel.ERROR, 'Exception while writing to interface log: ' + e);
        }
    }
     
    public static void logInterfaceAccessJSON(String methodName, Object inObj, String status) {
        try {
            String jsonVal = System.JSON.serializePretty(inObj);
            
            SAP_Interface_Log__c logItem = new SAP_Interface_Log__c
            (
                Method_Name__c = methodName,
                Message_Content__c = jsonVal,
                Status__c = status
            );
            
            insert logItem;
        } catch (Exception e) {
            // In case we couldn't serialize the object or something
            System.debug(LoggingLevel.ERROR, 'Exception while writing to interface log: ' + e);
        }
    }
    
    //this method creates a message from SAPInterfaceResult, so that it can be used to send email
    //TODO - refactor this out into a Util class
    public static String createMessage(String methodName, SAPInterfaceResult result) {
        String message = '';
        
        if(result != null && String.isNotBlank(methodName)) {
            message += 'Method Name: '+ methodName;
            message += '\n\nMessage Content: '+ result.errorMessage;
            message += '\n\nAccount Record: ' + result.accountList;
            message += '\n\nAccount Reference from SAP: ' + result.accountReference;  
        }
        system.debug('---->SAPInterface.createMessage(), returning message : ' + message);
        return message;
    }
    
    //TODO - refactor this out into a Util class
    private static String getExceptionData(Exception e) {   
        return String.valueOf(e) + ':' + e.getStackTraceString() + ':' + e.getLineNumber();
    }

    /*
    * Added to test/debug SAP messages, commented out because it will not be used in production
    * I was lazy and did not implement every sub list that could be on a component,
    * If there is a sublist that is needed (e.g. E1KNA1M.E1WRF6M) then follow the 
    * pattern given in the existing get* methods
    */
    
    //public static ZIDEBMASDEBMAS06ZIDEBMASEXT getTestZIDEBMASDEBMAS06ZIDEBMASEXTFromJSON(String rawMaster) {
    //    Map<String, Object> master = (Map<String, Object>)JSON.deserializeUntyped(rawMaster);

    //    ZIDEBMASDEBMAS06ZIDEBMASEXT customerMaster = new ZIDEBMASDEBMAS06ZIDEBMASEXT();
    //    customerMaster.EDI_DC40 = getEDI_DC40((Map<String, Object>)master.get('EDI_DC40'));
    //    customerMaster.E1KNA1M = getE1KNA1M((Map<String, Object>)master.get('E1KNA1M'));

    //    return customerMaster;
    //}

    //private static EDIDC40ZIDEBMASDEBMAS06ZIDEBMASEXT getEDI_DC40(Map<String, Object> values) 
    //{
    //    EDIDC40ZIDEBMASDEBMAS06ZIDEBMASEXT EDI_DC40 = new EDIDC40ZIDEBMASDEBMAS06ZIDEBMASEXT();
    //    EDI_DC40.TEST    = (String)values.get('TEST');
    //    EDI_DC40.TABNAM  = (String)values.get('TABNAM');
    //    EDI_DC40.STDVRS  = (String)values.get('STDVRS');
    //    EDI_DC40.STDMES  = (String)values.get('STDMES');
    //    EDI_DC40.STD     = (String)values.get('STD');
    //    EDI_DC40.STATUS  = (String)values.get('STATUS');
    //    EDI_DC40.SNDSAD  = (String)values.get('SNDSAD');
    //    EDI_DC40.SNDPRT  = (String)values.get('SNDPRT');
    //    EDI_DC40.SNDPRN  = (String)values.get('SNDPRN');
    //    EDI_DC40.SNDPOR  = (String)values.get('SNDPOR');
    //    EDI_DC40.SNDPFC  = (String)values.get('SNDPFC');
    //    EDI_DC40.SNDLAD  = (String)values.get('SNDLAD');
    //    EDI_DC40.SERIAL  = (String)values.get('SERIAL');
    //    EDI_DC40.SEGMENT = (String)values.get('SEGMENT');
    //    EDI_DC40.REFMES  = (String)values.get('REFMES');
    //    EDI_DC40.REFINT  = (String)values.get('REFINT');
    //    EDI_DC40.REFGRP  = (String)values.get('REFGRP');
    //    EDI_DC40.RCVSAD  = (String)values.get('RCVSAD');
    //    EDI_DC40.RCVPRT  = (String)values.get('RCVPRT');
    //    EDI_DC40.RCVPRN  = (String)values.get('RCVPRN');
    //    EDI_DC40.RCVPOR  = (String)values.get('RCVPOR');
    //    EDI_DC40.RCVPFC  = (String)values.get('RCVPFC');
    //    EDI_DC40.RCVLAD  = (String)values.get('RCVLAD');
    //    EDI_DC40.OUTMOD  = (String)values.get('OUTMOD');
    //    EDI_DC40.MESTYP  = (String)values.get('MESTYP');
    //    EDI_DC40.MESFCT  = (String)values.get('MESFCT');
    //    EDI_DC40.MESCOD  = (String)values.get('MESCOD');
    //    EDI_DC40.MANDT   = (String)values.get('MANDT');
    //    EDI_DC40.IDOCTYP = (String)values.get('IDOCTYP');
    //    EDI_DC40.EXPRSS  = (String)values.get('EXPRSS');
    //    EDI_DC40.DOCREL  = (String)values.get('DOCREL');
    //    EDI_DC40.DOCNUM  = (String)values.get('DOCNUM');
    //    EDI_DC40.DIRECT  = (String)values.get('DIRECT');
    //    EDI_DC40.CRETIM  = (String)values.get('CRETIM');
    //    EDI_DC40.CREDAT  = (String)values.get('CREDAT');
    //    EDI_DC40.CIMTYP  = (String)values.get('CIMTYP');
    //    EDI_DC40.ARCKEY  = (String)values.get('ARCKEY');

    //    return EDI_DC40;

    //}

    //private static ZIDEBMASEXTE1KNA1M getE1KNA1M(Map<String, Object> values)
    //{
    //    ZIDEBMASEXTE1KNA1M E1KNA1M = new ZIDEBMASEXTE1KNA1M();
    //    E1KNA1M.XZEMP    = (String)values.get('XZEMP');
    //    E1KNA1M.XXIPI    = (String)values.get('XXIPI');
    //    E1KNA1M.XSUBT    = (String)values.get('XSUBT');
    //    E1KNA1M.XSUB2    = (String)values.get('XSUB2');
    //    E1KNA1M.XICMS    = (String)values.get('XICMS');
    //    E1KNA1M.WERKS    = (String)values.get('WERKS');
    //    E1KNA1M.VBUND    = (String)values.get('VBUND');
    //    E1KNA1M.UWAER    = (String)values.get('UWAER');
    //    E1KNA1M.UMSA1    = (String)values.get('UMSA1');
    //    E1KNA1M.UMJAH    = (String)values.get('UMJAH');
    //    E1KNA1M.TXLW2    = (String)values.get('TXLW2');
    //    E1KNA1M.TXLW1    = (String)values.get('TXLW1');
    //    E1KNA1M.TXJCD    = (String)values.get('TXJCD');
    //    E1KNA1M.TELX1    = (String)values.get('TELX1');
    //    E1KNA1M.TELTX    = (String)values.get('TELTX');
    //    E1KNA1M.TELFX    = (String)values.get('TELFX');
    //    E1KNA1M.TELF2    = (String)values.get('TELF2');
    //    E1KNA1M.TELF1    = (String)values.get('TELF1');
    //    E1KNA1M.TELBX    = (String)values.get('TELBX');
    //    E1KNA1M.STRAS    = (String)values.get('STRAS');
    //    E1KNA1M.STKZU    = (String)values.get('STKZU');
    //    E1KNA1M.STKZN    = (String)values.get('STKZN');
    //    E1KNA1M.STKZA    = (String)values.get('STKZA');
    //    E1KNA1M.STCEG    = (String)values.get('STCEG');
    //    E1KNA1M.STCDT    = (String)values.get('STCDT');
    //    E1KNA1M.STCD4    = (String)values.get('STCD4');
    //    E1KNA1M.STCD3    = (String)values.get('STCD3');
    //    E1KNA1M.STCD2    = (String)values.get('STCD2');
    //    E1KNA1M.STCD1    = (String)values.get('STCD1');
    //    E1KNA1M.SPRASISO = (String)values.get('SPRASISO');
    //    E1KNA1M.SPRAS    = (String)values.get('SPRAS');
    //    E1KNA1M.SPERR    = (String)values.get('SPERR');
    //    E1KNA1M.SORTL    = (String)values.get('SORTL');
    //    E1KNA1M.SEGMENT  = (String)values.get('SEGMENT');
    //    E1KNA1M.RPMKR    = (String)values.get('RPMKR');
    //    E1KNA1M.REGIO    = (String)values.get('REGIO');
    //    E1KNA1M.PSTLZ    = (String)values.get('PSTLZ');
    //    E1KNA1M.PSTL2    = (String)values.get('PSTL2');
    //    E1KNA1M.PFORT    = (String)values.get('PFORT');
    //    E1KNA1M.PFACH    = (String)values.get('PFACH');
    //    E1KNA1M.PERIV    = (String)values.get('PERIV');
    //    E1KNA1M.ORT02    = (String)values.get('ORT02');
    //    E1KNA1M.ORT01    = (String)values.get('ORT01');
    //    E1KNA1M.NODEL    = (String)values.get('NODEL');
    //    E1KNA1M.NIELS    = (String)values.get('NIELS');
    //    E1KNA1M.NAME4    = (String)values.get('NAME4');
    //    E1KNA1M.NAME3    = (String)values.get('NAME3');
    //    E1KNA1M.NAME2    = (String)values.get('NAME2');
    //    E1KNA1M.NAME1    = (String)values.get('NAME1');
    //    E1KNA1M.MSGFN    = (String)values.get('MSGFN');
    //    E1KNA1M.MILVE    = (String)values.get('MILVE');
    //    E1KNA1M.LZONE    = (String)values.get('LZONE');
    //    E1KNA1M.LOEVM    = (String)values.get('LOEVM');
    //    E1KNA1M.LOCCO    = (String)values.get('LOCCO');
    //    E1KNA1M.LAND1    = (String)values.get('LAND1');
    //    E1KNA1M.KUNNR    = (String)values.get('KUNNR');
    //    E1KNA1M.KUKLA    = (String)values.get('KUKLA');
    //    E1KNA1M.KTOKD    = (String)values.get('KTOKD');
    //    E1KNA1M.KTOCD    = (String)values.get('KTOCD');
    //    E1KNA1M.KONZS    = (String)values.get('KONZS');
    //    E1KNA1M.KNRZA    = (String)values.get('KNRZA');
    //    E1KNA1M.KDKG5    = (String)values.get('KDKG5');
    //    E1KNA1M.KDKG4    = (String)values.get('KDKG4');
    //    E1KNA1M.KDKG3    = (String)values.get('KDKG3');
    //    E1KNA1M.KDKG2    = (String)values.get('KDKG2');
    //    E1KNA1M.KDKG1    = (String)values.get('KDKG1');
    //    E1KNA1M.KATR9    = (String)values.get('KATR9');
    //    E1KNA1M.KATR8    = (String)values.get('KATR8');
    //    E1KNA1M.KATR7    = (String)values.get('KATR7');
    //    E1KNA1M.KATR6    = (String)values.get('KATR6');
    //    E1KNA1M.KATR5    = (String)values.get('KATR5');
    //    E1KNA1M.KATR4    = (String)values.get('KATR4');
    //    E1KNA1M.KATR3    = (String)values.get('KATR3');
    //    E1KNA1M.KATR2    = (String)values.get('KATR2');
    //    E1KNA1M.KATR10   = (String)values.get('KATR10');
    //    E1KNA1M.KATR1    = (String)values.get('KATR1');
    //    E1KNA1M.JMZAH    = (String)values.get('JMZAH');
    //    E1KNA1M.JMJAH    = (String)values.get('JMJAH');
    //    E1KNA1M.HZUOR    = (String)values.get('HZUOR');
    //    E1KNA1M.GFORM    = (String)values.get('GFORM');
    //    E1KNA1M.FITYP    = (String)values.get('FITYP');
    //    E1KNA1M.FISKN    = (String)values.get('FISKN');
    //    E1KNA1M.FAKSD    = (String)values.get('FAKSD');
    //    //E1KNA1M.E1WRF6M  = (String)values.get('E1WRF6M');
    //    //E1KNA1M.E1WRF5M  = (String)values.get('E1WRF5M');
    //    //E1KNA1M.E1WRF4M  = (String)values.get('E1WRF4M');
    //    //E1KNA1M.E1WRF3M  = (String)values.get('E1WRF3M');
    //    //E1KNA1M.E1WRF1M  = (String)values.get('E1WRF1M');
    //    //E1KNA1M.E1WRF12  = (String)values.get('E1WRF12');
    //    //E1KNA1M.E1VCKUN  = (String)values.get('E1VCKUN');
    //    //E1KNA1M.E1T023X  = (String)values.get('E1T023X');
    //    //E1KNA1M.E1T023W  = (String)values.get('E1T023W');
    //    //E1KNA1M.E1KNVAM  = (String)values.get('E1KNVAM');
    //    //E1KNA1M.E1KNKAM  = (String)values.get('E1KNKAM');
    //    //E1KNA1M.E1KNEXM  = (String)values.get('E1KNEXM');
    //    //E1KNA1M.E1KNBKM  = (String)values.get('E1KNBKM');
    //    //E1KNA1M.E1KNASM  = (String)values.get('E1KNASM');
    //    //E1KNA1M.E1KNA1H  = (String)values.get('E1KNA1H');
    //    E1KNA1M.DTAWS = (String)values.get('DTAWS');
    //    E1KNA1M.DTAMS = (String)values.get('DTAMS');
    //    E1KNA1M.DATLT = (String)values.get('DATLT');
    //    E1KNA1M.COUNC = (String)values.get('COUNC');
    //    E1KNA1M.CIVVE = (String)values.get('CIVVE');
    //    E1KNA1M.CITYC = (String)values.get('CITYC');
    //    E1KNA1M.CFOPC = (String)values.get('CFOPC');
    //    E1KNA1M.CCC04 = (String)values.get('CCC04');
    //    E1KNA1M.CCC03 = (String)values.get('CCC03');
    //    E1KNA1M.CCC02 = (String)values.get('CCC02');
    //    E1KNA1M.CCC01 = (String)values.get('CCC01');
    //    E1KNA1M.CASSD = (String)values.get('CASSD');
    //    E1KNA1M.BUBKZ = (String)values.get('BUBKZ');
    //    E1KNA1M.BRSCH = (String)values.get('BRSCH');
    //    E1KNA1M.BRAN5 = (String)values.get('BRAN5');
    //    E1KNA1M.BRAN4 = (String)values.get('BRAN4');
    //    E1KNA1M.BRAN3 = (String)values.get('BRAN3');
    //    E1KNA1M.BRAN2 = (String)values.get('BRAN2');
    //    E1KNA1M.BRAN1 = (String)values.get('BRAN1');
    //    E1KNA1M.BEGRU = (String)values.get('BEGRU');
    //    E1KNA1M.BBSNR = (String)values.get('BBSNR');
    //    E1KNA1M.BBBNR = (String)values.get('BBBNR');
    //    E1KNA1M.BAHNS = (String)values.get('BAHNS');
    //    E1KNA1M.BAHNE = (String)values.get('BAHNE');
    //    E1KNA1M.AUFSD = (String)values.get('AUFSD');
    //    E1KNA1M.ANRED = (String)values.get('ANRED');

    //    E1KNA1M.E1KNVVM = getE1KNVVM((List<Object>)values.get('E1KNVVM'));
    //    E1KNA1M.E1KNVKM = getE1KNVKM((List<Object>)values.get('E1KNVKM'));
    //    E1KNA1M.E1KNKKM = getE1KNKKM((List<Object>)values.get('E1KNKKM'));
    //    E1KNA1M.E1KNB1M = getE1KNB1M((List<Object>)values.get('E1KNB1M'));

    //    return E1KNA1M;
    //}

    //private static List<ZIDEBMASEXTE1KNVVM> getE1KNVVM(List<Object> values)
    //{
    //    if (values == null) return null;
    //    List<ZIDEBMASEXTE1KNVVM> E1KNVVMList = new List<ZIDEBMASEXTE1KNVVM>();
    //    for (Object temp : values)
    //    {
    //        Map<String, Object> value = (Map<String, Object>)temp;
    //        ZIDEBMASEXTE1KNVVM E1KNVVM = new ZIDEBMASEXTE1KNVVM();
    //        E1KNVVM.ZTERM   = (String)value.get('ZTERM');
    //        E1KNVVM.WAERS   = (String)value.get('WAERS');
    //        E1KNVVM.VWERK   = (String)value.get('VWERK');
    //        E1KNVVM.VTWEG   = (String)value.get('VTWEG');
    //        E1KNVVM.VSORT   = (String)value.get('VSORT');
    //        E1KNVVM.VSBED   = (String)value.get('VSBED');
    //        E1KNVVM.VKORG   = (String)value.get('VKORG');
    //        E1KNVVM.VKGRP   = (String)value.get('VKGRP');
    //        E1KNVVM.VKBUR   = (String)value.get('VKBUR');
    //        E1KNVVM.VERSG   = (String)value.get('VERSG');
    //        E1KNVVM.UNTTO   = (String)value.get('UNTTO');
    //        E1KNVVM.UEBTO   = (String)value.get('UEBTO');
    //        E1KNVVM.UEBTK   = (String)value.get('UEBTK');
    //        E1KNVVM.SPART   = (String)value.get('SPART');
    //        E1KNVVM.SEGMENT = (String)value.get('SEGMENT');
    //        E1KNVVM.RDOFF   = (String)value.get('RDOFF');
    //        E1KNVVM.PVKSM   = (String)value.get('PVKSM');
    //        E1KNVVM.PRFRE   = (String)value.get('PRFRE');
    //        E1KNVVM.PODTG   = (String)value.get('PODTG');
    //        E1KNVVM.PODKZ   = (String)value.get('PODKZ');
    //        E1KNVVM.PLTYP   = (String)value.get('PLTYP');
    //        E1KNVVM.PERRL   = (String)value.get('PERRL');
    //        E1KNVVM.PERFK   = (String)value.get('PERFK');
    //        E1KNVVM.MSGFN   = (String)value.get('MSGFN');
    //        E1KNVVM.MRNKZ   = (String)value.get('MRNKZ');
    //        E1KNVVM.MEGRU   = (String)value.get('MEGRU');
    //        E1KNVVM.LPRIO   = (String)value.get('LPRIO');
    //        E1KNVVM.LOEVM   = (String)value.get('LOEVM');
    //        E1KNVVM.KZTLF   = (String)value.get('KZTLF');
    //        E1KNVVM.KZAZU   = (String)value.get('KZAZU');
    //        E1KNVVM.KVGR5   = (String)value.get('KVGR5');
    //        E1KNVVM.KVGR4   = (String)value.get('KVGR4');
    //        E1KNVVM.KVGR3   = (String)value.get('KVGR3');
    //        E1KNVVM.KVGR2   = (String)value.get('KVGR2');
    //        E1KNVVM.KVGR1   = (String)value.get('KVGR1');
    //        E1KNVVM.KURST   = (String)value.get('KURST');
    //        E1KNVVM.KTGRD   = (String)value.get('KTGRD');
    //        E1KNVVM.KONDA   = (String)value.get('KONDA');
    //        E1KNVVM.KLABC   = (String)value.get('KLABC');
    //        E1KNVVM.KKBER   = (String)value.get('KKBER');
    //        E1KNVVM.KDGRP   = (String)value.get('KDGRP');
    //        E1KNVVM.KALKS   = (String)value.get('KALKS');
    //        E1KNVVM.KABSS   = (String)value.get('KABSS');
    //        E1KNVVM.INCO2   = (String)value.get('INCO2');
    //        E1KNVVM.INCO1   = (String)value.get('INCO1');
    //        E1KNVVM.FAKSD   = (String)value.get('FAKSD');
    //        E1KNVVM.EIKTO   = (String)value.get('EIKTO');
    //        //E1KNVVM.E1KNVVH = (String)value.get('E1KNVVH');
    //        E1KNVVM.E1KNVPM = getE1KNVPM((List<Object>)value.get('E1KNVPM'));
    //        //E1KNVVM.E1KNVLM = (String)value.get('E1KNVLM');
    //        //E1KNVVM.E1KNVDM = (String)value.get('E1KNVDM');
    //        E1KNVVM.CHSPL   = (String)value.get('CHSPL');
    //        E1KNVVM.CASSD   = (String)value.get('CASSD');
    //        E1KNVVM.BZIRK   = (String)value.get('BZIRK');
    //        E1KNVVM.BOKRE   = (String)value.get('BOKRE');
    //        E1KNVVM.BLIND   = (String)value.get('BLIND');
    //        E1KNVVM.BEGRU   = (String)value.get('BEGRU');
    //        E1KNVVM.AWAHR   = (String)value.get('AWAHR');
    //        E1KNVVM.AUTLF   = (String)value.get('AUTLF');
    //        E1KNVVM.AUFSD   = (String)value.get('AUFSD');
    //        E1KNVVM.ANTLF   = (String)value.get('ANTLF');
    //        E1KNVVM.AGREL   = (String)value.get('AGREL');
    //        E1KNVVM.E1KNVIM = getE1KNVIM((List<Object>)value.get('E1KNVIM'));

    //        E1KNVVMList.add(E1KNVVM);
    //    }

    //    return E1KNVVMList;
    //}

    //private static List<ZIDEBMASEXTE1KNVPM> getE1KNVPM(List<Object> values)
    //{
    //    if (values == null) return null;
    //    List<ZIDEBMASEXTE1KNVPM> E1KNVPMList = new List<ZIDEBMASEXTE1KNVPM>();
    //    for (Object temp : values)
    //    {
    //        Map<String, Object> value = (Map<String, Object>)temp;
    //        ZIDEBMASEXTE1KNVPM E1KNVPM = new ZIDEBMASEXTE1KNVPM();
    //        E1KNVPM.SEGMENT = (String)value.get('SEGMENT');
    //        E1KNVPM.PARZA   = (String)value.get('PARZA');
    //        E1KNVPM.PARVW   = (String)value.get('PARVW');
    //        E1KNVPM.MSGFN   = (String)value.get('MSGFN');
    //        E1KNVPM.KUNN2   = (String)value.get('KUNN2');
    //        E1KNVPM.KNREF   = (String)value.get('KNREF');
    //        E1KNVPM.DEFPA   = (String)value.get('DEFPA');
    //        E1KNVPMList.add(E1KNVPM);
    //    }
    //    return E1KNVPMList;
    //}

    //private static List<ZIDEBMASEXTE1KNVIM> getE1KNVIM(List<Object> values)
    //{
    //    if (values == null) return null;
    //    List<ZIDEBMASEXTE1KNVIM> E1KNVIMList = new List<ZIDEBMASEXTE1KNVIM>();
    //    for (Object temp : values)
    //    {
    //        Map<String, Object> value = (Map<String, Object>)temp;
    //        ZIDEBMASEXTE1KNVIM E1KNVIM = new ZIDEBMASEXTE1KNVIM();
    //        E1KNVIM.TAXKD   = (String)value.get('TAXKD');
    //        E1KNVIM.TATYP   = (String)value.get('TATYP');
    //        E1KNVIM.SEGMENT = (String)value.get('SEGMENT');
    //        E1KNVIM.MSGFN   = (String)value.get('MSGFN');
    //        E1KNVIM.ALAND   = (String)value.get('ALAND');
    //        E1KNVIMList.add(E1KNVIM);
    //    }
    //    return E1KNVIMList;
    //}

    //private static List<ZIDEBMASEXTE1KNVKM> getE1KNVKM(List<Object> values)
    //{
        
    //    if (values == null) return null;
    //    List<ZIDEBMASEXTE1KNVKM> E1KNVKMList = new List<ZIDEBMASEXTE1KNVKM>();

    //    for (Object temp : values)
    //    {
    //        Map<String, Object> value = (Map<String, Object>)temp;
    //        ZIDEBMASEXTE1KNVKM E1KNVKM = new ZIDEBMASEXTE1KNVKM();
    //        E1KNVKM.VRTNR    = (String)value.get('VRTNR');
    //        E1KNVKM.UEPAR    = (String)value.get('UEPAR');
    //        E1KNVKM.TITELAP  = (String)value.get('TITELAP');
    //        E1KNVKM.TELF1    = (String)value.get('TELF1');
    //        E1KNVKM.SPNAM    = (String)value.get('SPNAM');
    //        E1KNVKM.SORTL    = (String)value.get('SORTL');
    //        E1KNVKM.SOBI2    = (String)value.get('SOBI2');
    //        E1KNVKM.SOBI1    = (String)value.get('SOBI1');
    //        E1KNVKM.SOAB2    = (String)value.get('SOAB2');
    //        E1KNVKM.SOAB1    = (String)value.get('SOAB1');
    //        E1KNVKM.SEGMENT  = (String)value.get('SEGMENT');
    //        E1KNVKM.SABI2    = (String)value.get('SABI2');
    //        E1KNVKM.SABI1    = (String)value.get('SABI1');
    //        E1KNVKM.SAAB2    = (String)value.get('SAAB2');
    //        E1KNVKM.SAAB1    = (String)value.get('SAAB1');
    //        E1KNVKM.PAVIP    = (String)value.get('PAVIP');
    //        E1KNVKM.PARVO    = (String)value.get('PARVO');
    //        E1KNVKM.PARNR    = (String)value.get('PARNR');
    //        E1KNVKM.PARLAISO = (String)value.get('PARLAISO');
    //        E1KNVKM.PARLA    = (String)value.get('PARLA');
    //        E1KNVKM.PARH5    = (String)value.get('PARH5');
    //        E1KNVKM.PARH4    = (String)value.get('PARH4');
    //        E1KNVKM.PARH3    = (String)value.get('PARH3');
    //        E1KNVKM.PARH2    = (String)value.get('PARH2');
    //        E1KNVKM.PARH1    = (String)value.get('PARH1');
    //        E1KNVKM.PARGE    = (String)value.get('PARGE');
    //        E1KNVKM.PARAU    = (String)value.get('PARAU');
    //        E1KNVKM.PAKN5    = (String)value.get('PAKN5');
    //        E1KNVKM.PAKN4    = (String)value.get('PAKN4');
    //        E1KNVKM.PAKN3    = (String)value.get('PAKN3');
    //        E1KNVKM.PAKN2    = (String)value.get('PAKN2');
    //        E1KNVKM.PAKN1    = (String)value.get('PAKN1');
    //        E1KNVKM.PAFKT    = (String)value.get('PAFKT');
    //        E1KNVKM.NMAIL    = (String)value.get('NMAIL');
    //        E1KNVKM.NAMEV    = (String)value.get('NAMEV');
    //        E1KNVKM.NAME1    = (String)value.get('NAME1');
    //        E1KNVKM.MSGFN    = (String)value.get('MSGFN');
    //        E1KNVKM.MOBI2    = (String)value.get('MOBI2');
    //        E1KNVKM.MOBI1    = (String)value.get('MOBI1');
    //        E1KNVKM.MOAB2    = (String)value.get('MOAB2');
    //        E1KNVKM.MOAB1    = (String)value.get('MOAB1');
    //        E1KNVKM.MIBI2    = (String)value.get('MIBI2');
    //        E1KNVKM.MIBI1    = (String)value.get('MIBI1');
    //        E1KNVKM.MIAB2    = (String)value.get('MIAB2');
    //        E1KNVKM.MIAB1    = (String)value.get('MIAB1');
    //        E1KNVKM.GBDAT    = (String)value.get('GBDAT');
    //        E1KNVKM.FRBI2    = (String)value.get('FRBI2');
    //        E1KNVKM.FRBI1    = (String)value.get('FRBI1');
    //        E1KNVKM.FRAB2    = (String)value.get('FRAB2');
    //        E1KNVKM.FRAB1    = (String)value.get('FRAB1');
    //        E1KNVKM.FAMST    = (String)value.get('FAMST');
    //        //E1KNVKM.E1KNVKH  = (String)value.get('E1KNVKH');
    //        E1KNVKM.DOBI2    = (String)value.get('DOBI2');
    //        E1KNVKM.DOBI1    = (String)value.get('DOBI1');
    //        E1KNVKM.DOAB2    = (String)value.get('DOAB2');
    //        E1KNVKM.DOAB1    = (String)value.get('DOAB1');
    //        E1KNVKM.DIBI2    = (String)value.get('DIBI2');
    //        E1KNVKM.DIBI1    = (String)value.get('DIBI1');
    //        E1KNVKM.DIAB2    = (String)value.get('DIAB2');
    //        E1KNVKM.DIAB1    = (String)value.get('DIAB1');
    //        E1KNVKM.BRYTH    = (String)value.get('BRYTH');
    //        E1KNVKM.ANRED    = (String)value.get('ANRED');
    //        E1KNVKM.AKVER    = (String)value.get('AKVER');
    //        E1KNVKM.ABTPA    = (String)value.get('ABTPA');
    //        E1KNVKM.ABTNR    = (String)value.get('ABTNR');
    //        E1KNVKMList.add(E1KNVKM);
    //    }

    //    return E1KNVKMList;
    //}

    //private static List<ZIDEBMASEXTE1KNKKM> getE1KNKKM(List<Object> values)
    //{
        
    //    if (values == null) return null;
    //    List<ZIDEBMASEXTE1KNKKM> E1KNKKMList = new List<ZIDEBMASEXTE1KNKKM>();

    //    for (Object temp : values)
    //    {
    //        Map<String, Object> value = (Map<String, Object>)temp;
    //        ZIDEBMASEXTE1KNKKM E1KNKKM = new ZIDEBMASEXTE1KNKKM();
    //        E1KNKKM.SEGMENT =(String)value.get('SEGMENT');
    //        E1KNKKM.SBGRP   =(String)value.get('SBGRP');
    //        E1KNKKM.SBDAT   =(String)value.get('SBDAT');
    //        E1KNKKM.REVDB   =(String)value.get('REVDB');
    //        E1KNKKM.PAYDB   =(String)value.get('PAYDB');
    //        E1KNKKM.NXTRV   =(String)value.get('NXTRV');
    //        E1KNKKM.MSGFN   =(String)value.get('MSGFN');
    //        E1KNKKM.KRAUS   =(String)value.get('KRAUS');
    //        E1KNKKM.KNKLI   =(String)value.get('KNKLI');
    //        E1KNKKM.KLIMK   =(String)value.get('KLIMK');
    //        E1KNKKM.KKBER   =(String)value.get('KKBER');
    //        E1KNKKM.KDGRP   =(String)value.get('KDGRP');
    //        E1KNKKM.GRUPP   =(String)value.get('GRUPP');
    //        //E1KNKKM.E1KNKKH =(String)value.get('E1KNKKH');
    //        E1KNKKM.DTREV   =(String)value.get('DTREV');
    //        E1KNKKM.DBWAE   =(String)value.get('DBWAE');
    //        E1KNKKM.DBRTG   =(String)value.get('DBRTG');
    //        E1KNKKM.DBRAT   =(String)value.get('DBRAT');
    //        E1KNKKM.DBPAY   =(String)value.get('DBPAY');
    //        E1KNKKM.DBMON   =(String)value.get('DBMON');
    //        E1KNKKM.DBEKR   =(String)value.get('DBEKR');
    //        E1KNKKM.CTLPC   =(String)value.get('CTLPC');
    //        E1KNKKM.CRBLB   =(String)value.get('CRBLB');
    //        E1KNKKMList.add(E1KNKKM);
    //    }

    //    return E1KNKKMList;
    //}

    //private static List<ZIDEBMASEXTE1KNB1M> getE1KNB1M(List<Object> values)
    //{
        
    //    if (values == null) return null;
    //    List<ZIDEBMASEXTE1KNB1M> E1KNB1MList = new List<ZIDEBMASEXTE1KNB1M>();

    //    for (Object temp : values)
    //    {
    //        Map<String, Object> value = (Map<String, Object>)temp;
    //        ZIDEBMASEXTE1KNB1M E1KNB1M = new ZIDEBMASEXTE1KNB1M();
    //        E1KNB1M.ZWELS     = (String)value.get('ZWELS');
    //        E1KNB1M.ZUAWA     = (String)value.get('ZUAWA');
    //        E1KNB1M.ZTERM     = (String)value.get('ZTERM');
    //        E1KNB1M.ZSABE     = (String)value.get('ZSABE');
    //        E1KNB1M.ZINRT     = (String)value.get('ZINRT');
    //        E1KNB1M.ZINDT     = (String)value.get('ZINDT');
    //        E1KNB1M.ZGRUP     = (String)value.get('ZGRUP');
    //        E1KNB1M.ZAMIV     = (String)value.get('ZAMIV');
    //        E1KNB1M.ZAMIR     = (String)value.get('ZAMIR');
    //        E1KNB1M.ZAMIO     = (String)value.get('ZAMIO');
    //        E1KNB1M.ZAMIM     = (String)value.get('ZAMIM');
    //        E1KNB1M.ZAMIB     = (String)value.get('ZAMIB');
    //        E1KNB1M.ZAHLS     = (String)value.get('ZAHLS');
    //        E1KNB1M.XZVER     = (String)value.get('XZVER');
    //        E1KNB1M.XVERR     = (String)value.get('XVERR');
    //        E1KNB1M.XPORE     = (String)value.get('XPORE');
    //        E1KNB1M.XEDIP     = (String)value.get('XEDIP');
    //        E1KNB1M.XDEZV     = (String)value.get('XDEZV');
    //        E1KNB1M.XAUSZ     = (String)value.get('XAUSZ');
    //        E1KNB1M.WEBTR     = (String)value.get('WEBTR');
    //        E1KNB1M.WBRSL     = (String)value.get('WBRSL');
    //        E1KNB1M.WAKON     = (String)value.get('WAKON');
    //        E1KNB1M.VZSKZ     = (String)value.get('VZSKZ');
    //        E1KNB1M.VRSZL     = (String)value.get('VRSZL');
    //        E1KNB1M.VRSPR     = (String)value.get('VRSPR');
    //        E1KNB1M.VRSNR     = (String)value.get('VRSNR');
    //        E1KNB1M.VRSDG     = (String)value.get('VRSDG');
    //        E1KNB1M.VRBKZ     = (String)value.get('VRBKZ');
    //        E1KNB1M.VLIBB     = (String)value.get('VLIBB');
    //        E1KNB1M.VERDT     = (String)value.get('VERDT');
    //        E1KNB1M.UZAWE     = (String)value.get('UZAWE');
    //        E1KNB1M.URLID     = (String)value.get('URLID');
    //        E1KNB1M.TOGRU     = (String)value.get('TOGRU');
    //        E1KNB1M.TLFXS     = (String)value.get('TLFXS');
    //        E1KNB1M.TLFNS     = (String)value.get('TLFNS');
    //        E1KNB1M.SREGL     = (String)value.get('SREGL');
    //        E1KNB1M.SPERR     = (String)value.get('SPERR');
    //        E1KNB1M.SEGMENT   = (String)value.get('SEGMENT');
    //        E1KNB1M.REMIT     = (String)value.get('REMIT');
    //        E1KNB1M.PERNR     = (String)value.get('PERNR');
    //        E1KNB1M.PERKZ     = (String)value.get('PERKZ');
    //        E1KNB1M.NODEL     = (String)value.get('NODEL');
    //        E1KNB1M.MSGFN     = (String)value.get('MSGFN');
    //        E1KNB1M.MGRUP     = (String)value.get('MGRUP');
    //        E1KNB1M.LOEVM     = (String)value.get('LOEVM');
    //        E1KNB1M.LOCKB     = (String)value.get('LOCKB');
    //        E1KNB1M.KVERM     = (String)value.get('KVERM');
    //        E1KNB1M.KULTG     = (String)value.get('KULTG');
    //        E1KNB1M.KNRZE     = (String)value.get('KNRZE');
    //        E1KNB1M.KNRZB     = (String)value.get('KNRZB');
    //        E1KNB1M.INTAD     = (String)value.get('INTAD');
    //        E1KNB1M.HBKID     = (String)value.get('HBKID');
    //        E1KNB1M.GUZTE     = (String)value.get('GUZTE');
    //        E1KNB1M.GRIDT     = (String)value.get('GRIDT');
    //        E1KNB1M.GRICD     = (String)value.get('GRICD');
    //        E1KNB1M.GMVKZD    = (String)value.get('GMVKZD');
    //        E1KNB1M.FRGRP     = (String)value.get('FRGRP');
    //        E1KNB1M.FDGRV     = (String)value.get('FDGRV');
    //        E1KNB1M.EKVBD     = (String)value.get('EKVBD');
    //        E1KNB1M.EIKTO     = (String)value.get('EIKTO');
    //        //E1KNB1M.E1KNBWM   = (String)value.get('E1KNBWM');
    //        //E1KNB1M.E1KNB5M   = (String)value.get('E1KNB5M');
    //        //E1KNB1M.E1KNB1H   = (String)value.get('E1KNB1H');
    //        E1KNB1M.DATLZ     = (String)value.get('DATLZ');
    //        E1KNB1M.CESSIONKZ = (String)value.get('CESSIONKZ');
    //        E1KNB1M.BUSAB     = (String)value.get('BUSAB');
    //        E1KNB1M.BUKRS     = (String)value.get('BUKRS');
    //        E1KNB1M.BLNKZ     = (String)value.get('BLNKZ');
    //        E1KNB1M.BEGRU     = (String)value.get('BEGRU');
    //        E1KNB1M.ALTKN     = (String)value.get('ALTKN');
    //        E1KNB1M.AKONT     = (String)value.get('AKONT');
    //        E1KNB1MList.add(E1KNB1M);
    //    }

    //    return E1KNB1MList;
    //}
    

}