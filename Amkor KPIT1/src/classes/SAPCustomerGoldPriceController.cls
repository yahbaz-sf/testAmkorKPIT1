/*************************************************************************
* 
* PURPOSE: This class does the main work of creating new 
*          Gold Base records for customer accounts
*                   
* CLASS: SAPCustomerGoldPriceController
* CREATED: 05/15/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Jason Swenski
* 
**************************************************************************/
public with sharing class SAPCustomerGoldPriceController {


    public class SAPCustomerGoldNoAccountFoundException extends Exception{}
    public class SAPCustomerGoldCurrencyException extends Exception{}
    
    //Bhanu 12-Apr-16
    //public static void updateCustomerGoldPrice(CONDA02 customerGold)
    public static SAPInterfaceResult updateCustomerGoldPrice(CONDA02 customerGold) {
        //Bhanu 12-Apr-2016
        SAPInterfaceResult resultInstance = new SAPInterfaceResult();
        
        try{
            
            if(customerGold != null && customerGold.IDOC != null && customerGold.IDOC.E1KOMG !=null ) {
                
                String HIENR = customerGold.IDOC.E1KOMG.HIENR;
                //Lalit - 24-Nov-2016 : Salesforce-53 :SAP GoldBase Needs to be applied to the SBU level
                //getting the value from VAKEY_LONG tag from SAP
                String VAKEY = customerGold.IDOC.E1KOMG.VAKEY_LONG;
                String VKORG = customerGold.IDOC.E1KOMG.VKORG;
                String DATAB = '';
                String KBETR = '';
                String KONWA = '';
                String KPEIN = '';
                
                //Per Chandan - even though we have these structures has potentially having
                //multiple items under this list, there is only one idoc record being sent
                //and therefore we should only create 1 gold base item linked to the account
                //so we will flatten these lists into the above attributes {DATAB, KBETR...KPEIN}
                
                List<CONDA02E1KONH> E1KONH = customerGold.IDOC.E1KOMG.E1KONH;
                for(CONDA02E1KONH e : E1KONH) {
                    if(e.DATAB != null) DATAB = e.DATAB;
                    List<CONDA02E1KONP> E1KONP = e.E1KONP;
                    for(CONDA02E1KONP c : E1KONP){
                        if(c.KBETR != null) KBETR = c.KBETR;
                        if(c.KONWA != null) KONWA = c.KONWA;
                        if(c.KPEIN != null) KPEIN = c.KPEIN;
                    }
                }
                
                //Lalit - 24-Nov-2016 : Salesforce-53 :SAP GoldBase Needs to be applied to the SBU level
                //getting the values from the sap and passing to our filtering method.
                //List<Account> accounts = [select Id from Account where AccountNumber =: HIENR];
                List<Account> accounts = queryAccounts(HIENR,VAKEY);
                
                if(accounts.size() > 0) {
                    
                    //see if we should update one. Logic from XLS:
                    //If the combination of HIENR, VKORG and DATAB are already in SFDC, then overwrite. Else insert. 
                
                                                 
                    SAP_Gold_Base__c goldBase = new SAP_Gold_Base__c(Account__c = accounts[0].Id);
                    goldBase.DATAB__c = DATAB;
                    goldBase.HIENR__c = HIENR;
                    goldBase.KBETR__c = KBETR;
                    goldBase.KONWA__c = KONWA;
                    goldBase.KPEIN__c = KPEIN;
                    goldBase.VKORG__c = VKORG;
                    goldBase.Newest__c = KONWA == 'USD' ? true : false;
                    goldBase.Rate__c = Decimal.valueOf(KBETR);
                    goldBase.Pricing_Unit__c = KONWA;
                    goldBase.Currency__c = KONWA;
    
                    List<SAP_Gold_Base__c> goldBases = new List<SAP_Gold_Base__c>();
                    if(goldBase.Newest__c) {
                        //Lalit - 24-Nov-2016 : Salesforce-53 :SAP GoldBase Needs to be applied to the SBU level
                        //Putting the value from AccountNumber into the HIENR instead of The sap Tag HIENR.
                        goldBases = [select Id from SAP_Gold_Base__c where HIENR__c =: accounts[0].AccountNumber];
                        for(SAP_Gold_Base__c gb :goldBases) {
                            gb.Newest__c = false;
                        }
                    }
                  
                    goldBases.add(goldBase);
                    
                    //Bhanu 14-Apr-2016
                    resultInstance.process = 'Upserting Gold Base Records';
                    upsert goldBases;
    
                    if(KONWA != 'USD') {
                        throw new SAPCustomerGoldCurrencyException('Currency not USD for: ' + goldBase.Id);
                    }
                }  
                else {
                    throw new SAPCustomerGoldNoAccountFoundException('No account found for HIENR: ' + HIENR + ', OR VAKEY: ' + VAKEY);
                }
                
                //Bhanu 14-Apr-2016
                resultInstance.process = '';
                                
            }
        } catch(Exception e){
            resultInstance.addError('Error while ' + resultInstance.process + ' : ' + e.getMessage() + ', Location : ' + e.getStackTraceString());
        }
        
        system.debug('---->SAPCustomerGoldPriceController.updateCustomerGoldPrice(), returning resultInstance : ' + resultInstance);
        return resultInstance;
        
    }
    
    //Lalit - 24-Nov-2016 : Salesforce-53 :SAP GoldBase Needs to be applied to the SBU level
    //New method:queryAccounts created to separate the logic for the accounts.
    public static List<Account> queryAccounts(String HIENR , String VAKEY ){
        List<Account> accounts = new List<Account>();
        system.debug('---->queryAccounts, HIENR : ' + HIENR + ', VAKEY : ' + VAKEY);
        if(String.isNotBlank(HIENR)){
            accounts = [select Id,AccountNumber from Account where AccountNumber =: HIENR];
        }
        
        if(accounts.size() < 1 && String.isNotBlank(VAKEY) && VAKEY.length() > 10) {
            VAKEY = VAKEY.right(10);
            system.debug('---->queryAccounts, 10 char VAKEY : ' + VAKEY);
            accounts = [select Id,AccountNumber from Account where AccountNumber =: VAKEY];
        }
        system.debug('---->queryAccounts, returning accounts : ' + accounts);
        return accounts;
    }
}