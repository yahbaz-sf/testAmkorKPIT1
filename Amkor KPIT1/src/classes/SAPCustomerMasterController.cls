public class SAPCustomerMasterController {

    private static SAPTranslationUtil translator;
    private static Map<String, String> listOfRoles = new Map<String, String> {
        'Account_Manager__c' => 'Account Manager',
        'Central_Quote_Rep__c' => 'Central Quote Rep',
        'Collection_Rep__c' => 'Collection Rep',
        'Customer_Rep__c' => 'Customer Rep',
        'Executive_VP__c' => 'Executive VP',
        'Executive_VP_Admin__c' => 'Executive VP Admin',
        'Mid_Level_Manager__c' => 'Region Manager',
        'Regional_VP__c' => 'Regional VP',
        'Regional_VP_Admin__c' => 'Regional VP Admin',
        'Regional_VP_CSM__c' => 'Regional CSM',
        'Sales_Administrator__c' => 'Sales Administrator',
        'Sec_Account_Manager__c' => 'Sec. Account Manager',
        'Secondary_Cust_Rep__c' => 'Secondary Cust Rep',
        'Test_Sales_Super_User__c' => 'Test Sales Super User',
        'TPM_TTPM__c'  => 'TPM',
        'TTPM__c'  => 'TTPM',
        'Asia_Sales_Sup_VP__c' => 'Asia Sales Sup VP',
        'Asia_Sales_Sup_CSM__c' => 'Asia Sales Sup CSM',
        'Asia_Sales_Sup_ActM__c' => 'Asia Sales Sup ActM',
        'Asia_Sales_Sup_CSR__c' => 'Asia Sales Sup CSR',
        'Asia_Sales_Sup_TPM__c' => 'Asia Sales Sup TPM',
        'Asia_Sales_Sup_TTPM__c' => 'Asia Sales Sup TTPM',
        'Asia_Sales_Sup_Tuse__c'  => 'Asia Sales Sup Tuse',
		        
		//SF-59 Added by Abhay
		'Billing_Manager__c'  => 'Billing Manager',
        'CS_Team_Lead__c'  => 'CS Team Lead',
        'eBusiness_Manager__c'  => 'eBusiness Manager',
        'Exec_Test_VP__c'  => 'Exec Test VP',
        'Regional_TPM_Manager__c'  => 'Regional TPM Manager',
        'Third_Cust_Rep__c'  => 'Third Cust Rep',
        'TPM_Secondary__c'  => 'TPM (Secondary)',
        'TPM_Third__c'  => 'TPM (Third)',
        'TTPM_Secondary__c'  => 'TTPM (Secondary)'

    };

    private static Map<String, Integer> weightMap = new Map<String, Integer> {
        'Executive VP' => 10,
        'Regional VP' => 20,
        'Regional CSM' => 30,
        'Asia Sales Sup VP' => 40,
        'Region Manager' => 50,
        'Account Manager' => 60,
        'Asia Sales Sup ActM' => 70,
        'Test Sales Super User' => 80,
        'Asia Sales Sup Tuse' => 90,
        'Customer Rep' => 100,
        'Asia Sales Sup CSR' => 110,
        'Asia Sales Sup CSM' => 120,
        'TPM' => 130,
        'Asia Sales Sup TPM' => 140,
        'TTPM' => 150,
        'Asia Sales Sup TTPM' => 160,
        'Sec. Account Manager' => 170,
        'Secondary Cust Rep' => 180,
        'Executive VP Admin' => 190,
        'Regional VP Admin' => 200,
        'Sales Administrator' => 210,
        'Collection Rep' => 220,
        'Central Quote Rep' => 230,
		
		//SF-59 Added by Abhay
		'Billing Manager' => 240,
		'CS Team Lead' => 250,
		'eBusiness Manager' => 260,
		'Exec Test VP' => 270,
		'Regional TPM Manager' => 280,
		'Third Cust Rep' => 290,
		'TPM (Secondary)' => 300,
		'TPM (Third)' => 310,
		'TTPM (Secondary)' => 320

    };

    //Bhanu 12-Apr-2016
    //public static void updateCustomerMaster(ZIDEBMASDEBMAS06ZIDEBMASEXT customerMaster) 
    public static SAPInterfaceResult updateCustomerMaster(ZIDEBMASDEBMAS06ZIDEBMASEXT customerMaster) {
        
        //Bhanu 12-Apr-2016 
        SAPInterfaceResult resultInstance = new SAPInterfaceResult();

        translator = SAPTranslationUtil.getInstance();
		//If it is 0001 then it can be the customer or Parent.  
        //If it is Z001 then it is Amkor Personnel. For example, 
        //Account Manager, Customer Rep, etc
        if(customerMaster == null || customerMaster.E1KNA1M == null) {
            System.debug('Cannot process this message. Message is null'); 
        }
        else if(customerMaster.E1KNA1M.KTOKD == '0001') {
            resultInstance.process = 'Syncing SalesForce Account with SAP Data';
            resultInstance = updateAccount(customerMaster, resultInstance);
            system.debug('line 74 resultInstance   : '+resultInstance);
            
            if(resultInstance != null && !resultInstance.isError){
                resultInstance.process = 'Updating TeamMembers and providing Access to RFQs associated with Account';
                resultInstance = updateContacts(customerMaster, resultInstance);        
            }
            
            resultInstance.process = '';
        }
        else {
            System.debug('Cannot process message, could not handle value in KTOKD');
        }
        
        //Bhanu 12-Apr-2016
        system.debug('----> SAPCustomerMasterController.updateCustomerMaster(), returning resultInstance : ' + resultInstance);
        return resultInstance;  
    }

    private static Account getAccount(ZIDEBMASDEBMAS06ZIDEBMASEXT customerMaster) {
        List<Account> accounts = new List<Account>();
        
        String accountNumber = '';
        if(customerMaster.E1KNA1M != null && customerMaster.E1KNA1M.KUNNR != null) {
            accounts = AccountDao.getInstance().getAccountByNumber(customerMaster.E1KNA1M.KUNNR, true);
            accountNumber = customerMaster.E1KNA1M.KUNNR;
        }
        
        Account account = new Account();
        account.AccountNumber = accountNumber;
        if(accounts.size() != 0) {
            account = accounts[0];
        }

        return account; 

    }
    
    //private static void updateAccount(ZIDEBMASDEBMAS06ZIDEBMASEXT customerMaster, SAPInterfaceResult resultInstance) {
    private static SAPInterfaceResult updateAccount(ZIDEBMASDEBMAS06ZIDEBMASEXT customerMaster, SAPInterfaceResult resultInstance) {    
        try{
            Id rtId = RecordTypeUtils.getRecordTypeId('Account', 'Approved');
            /*
            String accountNumber = '';
            if(customerMaster.E1KNA1M != null && customerMaster.E1KNA1M.KUNNR != null) {
                accounts = AccountDao.getInstance().getAccountByNumber(customerMaster.E1KNA1M.KUNNR);
                accountNumber = customerMaster.E1KNA1M.KUNNR;
            }
            
            Account account = new Account();
            if(accounts.size() != 0) {
                account = accounts[0];
            }*/
    
            Account account = getAccount(customerMaster);
            
            //Bhanu 13-Apr-2016
            resultInstance.accountList.add(account);
    
            account.RecordTypeId = rtId;
            ZIDEBMASEXTE1KNA1M E1KNA1M = customerMaster.E1KNA1M;
    
            String accountDigits = account.AccountNumber;
            
            Integer accountNameLength = accountDigits.replaceAll('^0+(?!$)', '').length();
            
            
                if(accountNameLength == 5){
                    account.Name = StringUtils.sanitize(E1KNA1M.NAME1);
                    
                }
                else {
                    account.Name = StringUtils.sanitize(E1KNA1M.NAME3) + ' ' + StringUtils.sanitize(E1KNA1M.NAME4);
                }
    
                if(StringUtils.isBlank(account.Name)){
                    throw new AccountBlankException('Account Name cannot be blank');
                }
            
            //account.AccountNumber = accountNumber;
            account.ShippingCity = StringUtils.chomp(E1KNA1M.ORT01,35);
            account.ShippingPostalCode = StringUtils.chomp(E1KNA1M.PSTLZ,15);
            account.ShippingState = StringUtils.chomp(E1KNA1M.REGIO,75);
            account.ShippingStreet = StringUtils.chomp(E1KNA1M.STRAS,150);
            account.ShippingCountry = StringUtils.chomp(E1KNA1M.LAND1,75);
    
            //AMK-1352
            account.Inactive__c = E1KNA1M.LOEVM == 'X';
            
            //TODO - map to the SAP Data fields on account as well as performing translation
            account.BillingCity = StringUtils.chomp(E1KNA1M.ORT01,35);
            account.BillingPostalCode = StringUtils.chomp(E1KNA1M.PSTLZ,15);
            account.BillingState = StringUtils.chomp(E1KNA1M.REGIO,75);
            account.BillingStreet = StringUtils.chomp(E1KNA1M.STRAS,150);
            account.BillingCountry = StringUtils.chomp(E1KNA1M.LAND1,75);
            
            account.Combo_Billing_Flag__c = translator.transform('E1KNA1M.KATR2.',E1KNA1M.KATR2);
            account.T_Stock_Flag__c = translator.transform('E1KNA1M.KATR5.',E1KNA1M.KATR5);
            account.Reject_Billing__c = translator.transform('E1KNA1M.KATR7.',E1KNA1M.KATR7);
            
            account.KATR2__c = E1KNA1M.KATR2;
            account.KATR5__c = E1KNA1M.KATR5;
            account.KATR7__c = E1KNA1M.KATR7;
            if(E1KNA1M.E1KNA11 != null && E1KNA1M.E1KNA11.ZISKKATR != null) {
                account.Gold_Billing_Flag__c = translator.transform('E1KNA1M.E1KNA11.ZISKKATR.ZZIKATR11.',E1KNA1M.E1KNA11.ZISKKATR.ZZIKATR11);
                account.Engg_Lot_Flag__c = translator.transform('E1KNA1M.E1KNA11.ZISKKATR.ZZIKATR12.',E1KNA1M.E1KNA11.ZISKKATR.ZZIKATR12);
                account.Fast_Track_Flag__c = translator.transform('E1KNA1M.E1KNA11.ZISKKATR.ZZIKATR13.',E1KNA1M.E1KNA11.ZISKKATR.ZZIKATR13);
                account.Small_Lot_Flag__c = translator.transform('E1KNA1M.E1KNA11.ZISKKATR.ZZIKATR14.',E1KNA1M.E1KNA11.ZISKKATR.ZZIKATR14);
                account.Qual_Lot_Flag__c = translator.transform('E1KNA1M.E1KNA11.ZISKKATR.ZZIKATR15.',E1KNA1M.E1KNA11.ZISKKATR.ZZIKATR15);
                account.Scrap_Billing__c = translator.transform('E1KNA1M.E1KNA11.ZISKKATR.ZZIKATR30.',E1KNA1M.E1KNA11.ZISKKATR.ZZIKATR30);
            
                //copy over untransformed data as well... too bad these were too big for formulas
                account.ZZIKATR11__c = E1KNA1M.E1KNA11.ZISKKATR.ZZIKATR11;
                account.ZZIKATR12__c = E1KNA1M.E1KNA11.ZISKKATR.ZZIKATR12;
                account.ZZIKATR13__c = E1KNA1M.E1KNA11.ZISKKATR.ZZIKATR13;
                account.ZZIKATR14__c = E1KNA1M.E1KNA11.ZISKKATR.ZZIKATR14;
                account.ZZIKATR15__c = E1KNA1M.E1KNA11.ZISKKATR.ZZIKATR15;
                account.ZZIKATR30__c = E1KNA1M.E1KNA11.ZISKKATR.ZZIKATR30;
                
            }
                
            // Update owner Id
            if(E1KNA1M.E1KNVVM != null && E1KNA1M.E1KNVVM.size() > 0) {
                String KDGRP = E1KNA1M.E1KNVVM[0].KDGRP;
                ZIDEBMASEXTE1KNVVM E1KNVVM = getE1KNVVMSegment(KDGRP,E1KNA1M.E1KNVVM);
                if (E1KNVVM != null && E1KNVVM.E1KNVPM != null) {
                    for (ZIDEBMASEXTE1KNVPM segment : E1KNVVM.E1KNVPM) {
                        if (segment.PARVW == 'ZA') {
                            String employeeNumber = segment.KUNN2;
                            if (!StringUtils.isBlank(employeeNumber)) {
                                User accountOwner = UserDao.getInstance().getUserBySAPPartnerNumber(employeeNumber);
                                if (accountOwner != null) {
                                    account.OwnerId = accountOwner.Id;
                                }
                            }
                        }
                    }
                }
            }

            System.debug('---->KTOKD::'+E1KNA1M.KTOKD);
            System.debug('---->HZUOR::'+E1KNA1M.HZUOR);
            System.debug('---->E1KNA1M.E1KNVVM::'+E1KNA1M.E1KNVVM);
            System.debug('---->E1KNA1M.E1KNVVM.size()'+E1KNA1M.E1KNVVM.size());
            if(!(E1KNA1M.KTOKD == '0001' && E1KNA1M.HZUOR == '1')) {
                
                if(E1KNA1M.E1KNVVM != null && E1KNA1M.E1KNVVM.size() > 0) {
                    
                    //grab the customer group off the first segment
                    String KDGRP = E1KNA1M.E1KNVVM[0].KDGRP;
                    account.Customer_Group__c = translator.transform('E1KNA1M.E1KNVVM.KDGRP.',KDGRP);
                    account.KDGRP__c = KDGRP;
                    ZIDEBMASEXTE1KNVVM E1KNVVM = getE1KNVVMSegment(KDGRP,E1KNA1M.E1KNVVM);
                    System.debug('---->E1KNVVM'+E1KNVVM);
                    if(E1KNVVM != null) {
                        
                        account.Sales_Organization__c = E1KNVVM.VKORG;
                        account.Incoterms_2__c = E1KNVVM.INCO2;
                        account.Currency__c = E1KNVVM.WAERS;
                        System.debug('---->VKBUR::'+E1KNVVM.VKBUR);
                        account.Incoterms_1__c = translator.transform('E1KNA1M.E1KNVVM.INCO1.',E1KNVVM.INCO1);
                        account.Payment_Terms__c = translator.transform('E1KNA1M.E1KNVVM.ZTERM.',E1KNVVM.ZTERM);
                        account.Sales_Region__c = translator.transform('E1KNA1M.E1KNVVM.VKBUR.',E1KNVVM.VKBUR);
                        System.debug('---->account.Sales_Region__c::'+account.Sales_Region__c);
                        account.INCO1__c = E1KNVVM.INCO1;
                        account.ZTERM__c = E1KNVVM.ZTERM;
                        account.VKBUR__c = E1KNVVM.VKBUR;
                    }
                }
            }
            
            resultInstance.process = 'Upserting SalesForce Account with SAP Data';
            //Lalit - 31-Sep-2016 : Salesforce-36 :Inactive accounts from SAP to SFDC.
            //Checking whether Account Region is Inactive/Active and upserting only for Active Accounts.
            Boolean isActiveRegion = checkForInActiveAccounts(string.valueOf(account.Sales_Region__c));
            System.debug('---->here::'+string.valueOf(account.Sales_Region__c));
            System.debug('---->isActiveRegion::'+isActiveRegion);
            if(isActiveRegion){
                upsert account;
            }
        } catch(Exception e){
            resultInstance.addError('Error while ' + resultInstance.process + ' : ' + e.getMessage() + ', Location : ' + e.getStackTraceString());
        }
        System.debug('---->resultInstance::'+resultInstance);
        return resultInstance;
    }
    
    //Lalit - 31-Sep-2016 : Salesforce-36 :Inactive accounts from SAP to SFDC.
    //New method to Account is Active/Inactive.
    public static Boolean checkForInActiveAccounts(string salesRegion){
        set<string> setOfInActiveAccountNames = new set<string>();
        
            List<SalesRegion__c> lstOfInActiveAccounts = SalesRegion__c.getall().values();
        System.debug('---->lstOfInActiveAccounts::'+lstOfInActiveAccounts);
            if(lstOfInActiveAccounts!=null && lstOfInActiveAccounts.size()>0){
                for(SalesRegion__c objRegion:lstOfInActiveAccounts){
                    setOfInActiveAccountNames.add(objRegion.name);
                }
            }
                if(!setOfInActiveAccountNames.contains(salesRegion)){
                    return true;
                }
                else{
                    return false;
                }
    }
    
    private static ZIDEBMASEXTE1KNVVM getE1KNVVMSegment(String KDGRP, List<ZIDEBMASEXTE1KNVVM> candidates) {
        
        /*
        There will be multiple E1KNVVM segments. Use the below logic to determine which ones to load.

        1. If E1KNA1M-KTOKD = 'Z001' do not load this segment (E1KNVVM)
        2. If E1KNA1M-KTOKD = '0001' and E1KNA1M-HZUOR = 1 then do not load this segment (E1KNVVM)
        3. Else read the field KDGRP from the first E1KNVVM segment. 
            
           If KDGRP = 'Z1' then only use the E1KNVVM Segment where VKORG = 'K001'. 
           Ignore all other E1KNVVM Segments. 
           
           If KDGRP = 'Z2' then use E1KNVVM Segment where VKORG = 'U001'. 
           If KDGRP = 'Z4' then use E1KNVVM Segment where VKORG = 'J001'. 
           If KDGRP = 'Z6' then use E1KNVVM Segment where VKORG = 'T001'. 
           If KDGRP = 'Z7' then use E1KNVVM Segment where VKORG = 'T002'. 
           If KDGRP = 'Z8' then use E1KNVVM Segment where VKORG = 'C001'. 
           If KDGRP = 'Z9' then use E1KNVVM Segment where VKORG = 'J002'.
        */  
         
        String VKORG = '';
        if(KDGRP == 'Z1') VKORG = 'K001';
        else if(KDGRP == 'Z2') VKORG = 'U001';
        else if(KDGRP == 'Z4') VKORG = 'J001';
        else if(KDGRP == 'Z6') VKORG = 'T001';
        else if(KDGRP == 'Z7') VKORG = 'T002';
        else if(KDGRP == 'Z8') VKORG = 'C001';
        else if(KDGRP == 'Z9') VKORG = 'J002';
		
		//Abhay - 31st-Jan-2017 : Salesforce-115: Japan Sales region is not populating in SFDC for customer Murata
        /****** SF-115 Starts *************/
        else if(KDGRP == 'ZJ') VKORG = 'J003';
        else if(KDGRP == 'Z5') VKORG = 'P001';
        else if(KDGRP == 'Z5') VKORG = 'K001';
        else if(KDGRP == 'Z5') VKORG = 'S001';
        else if(KDGRP == 'Z0') VKORG = 'M001';
        /****** SF-115 Ends ***********/
        
        for(ZIDEBMASEXTE1KNVVM segment : candidates) {
            if(segment.VKORG == VKORG) return segment;
        }
        return null;
    }
    
    
    //private static void updateContacts(ZIDEBMASDEBMAS06ZIDEBMASEXT customerMaster) {
    private static SAPInterfaceResult updateContacts(ZIDEBMASDEBMAS06ZIDEBMASEXT customerMaster, SAPInterfaceResult resultInstance) {
        
        try{
            Account account = getAccount(customerMaster);
            
            ZIDEBMASEXTE1KNA1M E1KNA1M = customerMaster.E1KNA1M;
            
            //Ashish - 26-Oct-2016 : Salesforce-141 : SAP interface Error while Updating TeamMembers
            //Added following null check to avoid null pointer exception
            //Additionally, SAP should send data in E1KNVVM list which coming as null right now
            String KDGRP = '';
            if(E1KNA1M != null && E1KNA1M.E1KNVVM != null && E1KNA1M.E1KNVVM.size() > 0 && E1KNA1M.E1KNVVM[0] != null){
                 KDGRP = E1KNA1M.E1KNVVM[0].KDGRP;    
            
                ZIDEBMASEXTE1KNVVM E1KNVVM = getE1KNVVMSegment(KDGRP,E1KNA1M.E1KNVVM);
                Map<String,String> personMap = new Map<String,String>();
        
                if(E1KNVVM != null && E1KNVVM.E1KNVPM != null) {
                    for(ZIDEBMASEXTE1KNVPM E1KNVPM : E1KNVVM.E1KNVPM) {
                    	//SF-59 Added by Abhay : Added Partner Function Codes from ZV to YB 
                        if(E1KNVPM.PARVW != null && 'ZA,ZC,ZD,ZE,ZF,ZG,ZH,ZI,ZJ,ZK,ZL,ZN,ZO,ZP,ZT,ZR,Z1,Z2,Z3,Z4,Z5,Z6,Z7,ZV,YD,ZU,Z8,YC,YE,YA,YG,YB'.contains(E1KNVPM.PARVW.toUpperCase())){
                            if(E1KNVPM.KUNN2 != null) {
                                personMap.put(getPersonField(E1KNVPM.PARVW.toUpperCase()),E1KNVPM.KUNN2);
                            }
                        }
                    }
                }
        
                Set<String> ids = new Set<String>();
                ids.addAll(personMap.values());
                List<User> users = UserDao.getInstance().getUsersBySAPPartnerNumbers(ids);
        
                Map<String,String> sapIdToPrimaryKey = new Map<String,String>();
        
                for(User u : users) {
                    sapIdToPrimaryKey.put(u.SAP_Partner_Number__c,u.Id);
                }
        
                //AMK-2630 setting people section to null before populating
                for(String role : listOfRoles.keyset()) {
                    account.put(role, null);
                }
        
                for(String key : personMap.keySet()) {
                    account.put(key,sapIdToPrimaryKey.get(personMap.get(key)));
                }
                
                resultInstance.process = 'Updating People Section for Account';
                update account;
        
                //delete [select Id from AccountTeamMember where AccountId =: Account.Id];
        
                List<AccountTeamMember> currentMembers = [select Id, TeamMemberRole, CreatedById, UserId from AccountTeamMember where AccountId =: Account.Id];
        
                List<AccountTeamMember> members = new List<AccountTeamMember>();
                List<AccountTeamMember> membersDEL = new List<AccountTeamMember>();
                List<AccountShare> acctShare = new List<AccountShare>();
        
                for(AccountTeamMember c : currentMembers) {
                    if(c.CreatedById == UserInfo.getUserId()) membersDEL.add(c);
                    else members.add(c);
                }
        
                for(String role : listOfRoles.keyset()) {
                    if(account.get(role) != null) {
                        Id roleId = (Id)account.get(role);
                        Boolean shouldAdd = true;
                        for(AccountTeamMember a : members) {
                            if(a.UserId == roleId && a.CreatedById != null && a.CreatedById != UserInfo.getUserId()) shouldAdd = false;
                            else if(a.UserId == roleId && weightMap.get(a.TeamMemberRole) < weightMap.get(listOfRoles.get(role))) shouldAdd = false;
                        }
                        if(shouldAdd) {
                            //Lalit - 07-Sep-2016 : Salesforce-129 : Determine default permissions for account team memebers.
                            //setting Opportunity access to edit for AccountTeamMember
                            //Ashish - 16-Nov-2016 : Salesforce-129 : New Accounts Section for Customer Scorecard
                            //setting the Account & case access in AccountTeamMember only & commenting out AccountShare insertion code
                            members.add(new AccountTeamMember(AccountId = account.Id, UserId = roleId, OpportunityAccessLevel = 'Edit', 
                                                            AccountAccessLevel = 'Edit', CaseAccessLevel = 'Edit', TeamMemberRole = listOfRoles.get(role)));
                            /*if(account.get(role) != account.OwnerId) {
                                acctShare.add(new AccountShare(AccountId = account.Id, OpportunityAccessLevel = 'Edit', CaseAccessLevel = 'Edit', AccountAccessLevel = 'Edit', UserOrGroupId = roleId));
                            }*/
                        }
                    } 
                }
        
                List<RFQ__Share> rfqSharings = new List<RFQ__Share>();
        
                List<RFQ__c> rfqsForAccount = [select Id from RFQ__c where SBU_Name__c =: account.Id];
                List<Id> rfqIds = new List<Id>();
                for(RFQ__c rfq : rfqsForAccount) {
                    rfqIds.add(rfq.Id);
                    for(AccountTeamMember mem : members) {
                        rfqSharings.add(new RFQ__Share(ParentId = rfq.Id, UserOrGroupId = mem.UserId, AccessLevel = 'Edit', RowCause = Schema.RFQ__Share.RowCause.Account_Sharing__c));
                    }
                }
        
                Set<String> idList = new Set<String>();
                for(AccountTeamMember d : membersDEL) {
                    idList.add(d.UserId);
                }
                
                resultInstance.process = 'Deleting and revoking Access from Old Account TeamMembers';
                Database.delete([select Id from RFQ__Share where UserOrGroupId in :idList AND ParentId in: rfqIds], false);
                //resultInstance.process = 'Removing Account TeamMember';
                Database.delete(membersDEL, false);
                
                resultInstance.process = 'Providing Access to RFQs associated with Account';
                Database.insert(rfqSharings, false);
                resultInstance.process = 'Upserting Current and New TeamMember';
                upsert members;
                //Ashish - 16-Nov-2016 : Salesforce-129 : New Accounts Section for Customer Scorecard
                //Commenting the Accountshare insert statement.
                //Database.insert(acctShare, false);
            }
        } catch(Exception e){
            resultInstance.addError('Error while ' + resultInstance.process + ' : ' + e.getMessage() + ', Location : ' + e.getStackTraceString());
        }
        
        return resultInstance;
        
    }

    private static String getPersonField(String sapCode) {
        if(sapCode == 'ZA') return 'Account_Manager__c';
        if(sapCode == 'ZC') return 'Collection_Rep__c';
        if(sapCode == 'ZD') return 'Executive_VP_Admin__c';
        if(sapCode == 'ZE') return 'Executive_VP__c';
        if(sapCode == 'ZF') return 'Sales_Administrator__c';
        if(sapCode == 'ZG') return 'Regional_VP_CSM__c';
        if(sapCode == 'ZH') return 'Regional_VP_Admin__c';
        if(sapCode == 'ZI') return 'Secondary_Cust_Rep__c';
        if(sapCode == 'ZJ') return 'Sec_Account_Manager__c';
        if(sapCode == 'ZK') return 'Customer_Rep__c';
        if(sapCode == 'ZL') return 'Central_Quote_Rep__c';
        if(sapCode == 'ZN') return 'Mid_Level_Manager__c';
        if(sapCode == 'ZO') return 'Test_Sales_Super_User__c';
        if(sapCode == 'ZP') return 'TPM_TTPM__c';
        if(sapCode == 'ZT') return 'TTPM__c';
        if(sapCode == 'ZR') return 'Regional_VP__c';
        if(sapCode == 'Z1') return 'Asia_Sales_Sup_VP__c';
        if(sapCode == 'Z2') return 'Asia_Sales_Sup_CSM__c';
        if(sapCode == 'Z3') return 'Asia_Sales_Sup_ActM__c';
        if(sapCode == 'Z4') return 'Asia_Sales_Sup_CSR__c';
        if(sapCode == 'Z5') return 'Asia_Sales_Sup_TPM__c';
        if(sapCode == 'Z6') return 'Asia_Sales_Sup_TTPM__c';
        if(sapCode == 'Z7') return 'Asia_Sales_Sup_Tuse__c';
		//SF-59 Added by Abhay
		if(sapCode == 'ZV') return 'Billing_Manager__c';
        if(sapCode == 'YD') return 'CS_Team_Lead__c';
        if(sapCode == 'ZU') return 'eBusiness_Manager__c';
        if(sapCode == 'Z8') return 'Exec_Test_VP__c';
        if(sapCode == 'YC') return 'Regional_TPM_Manager__c';
        if(sapCode == 'YE') return 'Third_Cust_Rep__c';
        if(sapCode == 'YA') return 'TPM_Secondary__c';
        if(sapCode == 'YG') return 'TPM_Third__c';
        if(sapCode == 'YB') return 'TTPM_Secondary__c';
        return '';
    }

}