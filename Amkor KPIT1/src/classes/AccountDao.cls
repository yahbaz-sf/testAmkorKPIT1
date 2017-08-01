/*************************************************************************
*
* PURPOSE: 
*
* CLASS: AccountDao
* CREATED: 3/12/2012 Ethos Solutions - www.ethos.com
* AUTHOR: 
***************************************************************************/
public with sharing class AccountDao extends BaseDao {
	
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
        'Regional_VP_CSM__c' => 'Regional VP CSM',
        'Sales_Administrator__c' => 'Sales Administrator',
        'Sec_Account_Manager__c' => 'Sec. Account Manager',
        'Secondary_Cust_Rep__c' => 'Secondary Cust Rep',
        'Test_Sales_Super_User__c' => 'Test Sales Super User',
        'TPM_TTPM__c'  => 'TPM/TTPM'
    };


	private static final AccountDao AccountDao = new AccountDao();
	
	private AccountDao(){  super('Account'); }
	
	public static AccountDao getInstance() {
        return AccountDao;
    }

    @future
    public static void createManualShareRules(List<Id> acctIds) {
        List<RFQ__Share> rfqSharings = new List<RFQ__Share>();
        List<Account> accounts = [select Id, OwnerId, Account_Manager__c, Central_Quote_Rep__c, Collection_Rep__c, Customer_Rep__c, Executive_VP__c, Executive_VP_Admin__c, Mid_Level_Manager__c, Regional_VP__c, Regional_VP_Admin__c, Regional_VP_CSM__c, Sales_Administrator__c, Sec_Account_Manager__c, Secondary_Cust_Rep__c, Test_Sales_Super_User__c, TPM_TTPM__c, (select Id from RFQs__r) from Account where Id in: acctIds AND Inactive__c=false];
        for(Account account : accounts) {
            for(RFQ__c rfq : account.RFQs__r) {
                 for(String role : listOfRoles.keyset()) {
                    if(account.get(role) != null) {
                        rfqSharings.add(new RFQ__Share(ParentId = rfq.Id, UserOrGroupId = (Id)account.get(role), AccessLevel = 'Edit', RowCause = Schema.RFQ__Share.RowCause.Account_Sharing__c));
                    }
                 }
            }
        }
        insert rfqSharings;
    }
    
    public Account getAccountById(String accountId) {
        addSingleField('Parent.Name');
        addSingleField('Parent.AccountNumber');
    	return (Account)getSObjectById(accountId);
    }
    
    public List<Account> getAccountByNumber(String accountNumber) {
        return getAccountByNumber(accountNumber, false);
    }
    
    public List<Account> getAccountByNumber(String accountNumber, Boolean includeInactive) {
        if (includeInactive)
            return (List<Account>)getSObjects('AccountNumber =' + BaseDao.quote(accountNumber));
        else
            return (List<Account>)getSObjects('AccountNumber =' + BaseDao.quote(accountNumber)  + ' AND Inactive__c=false');
    }

    public static void installAccounts() {
        
        Map<String,String> parentLink = new Map<String,String>();
        parentLink.put('74','20000099');
        parentLink.put('74','20000063');
        parentLink.put('74','20000185');
        parentLink.put('74','20000142');
        parentLink.put('76','20000084');
        parentLink.put('76','20000019');
        parentLink.put('76','20000164');
        parentLink.put('76','20000143');
        parentLink.put('81','20000084');
        parentLink.put('81','20000019');
        parentLink.put('81','20000164');
        parentLink.put('81','20000143');
        parentLink.put('102','20000084');
        parentLink.put('102','20000019');
        parentLink.put('102','20000164');
        parentLink.put('102','20000143');
        parentLink.put('110','20000080');
        parentLink.put('110','20000010');
        parentLink.put('110','20000163');
        parentLink.put('110','20000142');
        parentLink.put('120','20000066');
        parentLink.put('120','20000011');
        parentLink.put('120','20000167');
        parentLink.put('120','20000142');
        parentLink.put('125','20000099');
        parentLink.put('125','20000063');
        parentLink.put('125','20000185');
        parentLink.put('125','20000142');
        parentLink.put('131','20000099');
        parentLink.put('131','20000063');
        parentLink.put('131','20000185');
        parentLink.put('131','20000142');
        parentLink.put('144','20000066');
        parentLink.put('144','20000011');
        parentLink.put('144','20000167');
        parentLink.put('144','20000142');
        parentLink.put('150','20000099');
        parentLink.put('150','20000063');
        parentLink.put('150','20000185');
        parentLink.put('150','20000142');
        parentLink.put('152','20000099');
        parentLink.put('152','20000063');
        parentLink.put('152','20000185');
        parentLink.put('152','20000126');
        parentLink.put('152','20000142');
        parentLink.put('153','20000084');
        parentLink.put('153','20000019');
        parentLink.put('153','20000164');
        parentLink.put('153','20000143');
        parentLink.put('154','20000099');
        parentLink.put('154','20000063');
        parentLink.put('154','20000185');
        parentLink.put('154','20000142');
        parentLink.put('156','20000084');
        parentLink.put('156','20000019');
        parentLink.put('156','20000164');
        parentLink.put('156','20000143');
        parentLink.put('218','20000099');
        parentLink.put('218','20000063');
        parentLink.put('218','20000185');
        parentLink.put('218','20000142');
        parentLink.put('225','20000099');
        parentLink.put('225','20000063');
        parentLink.put('225','20000185');
        parentLink.put('225','20000142');
        parentLink.put('235','20000069');
        parentLink.put('235','20000019');
        parentLink.put('235','20000164');
        parentLink.put('235','20000143');
        parentLink.put('242','20000099');
        parentLink.put('242','20000063');
        parentLink.put('242','20000185');
        parentLink.put('242','20000142');
        parentLink.put('263','20000099');
        parentLink.put('263','20000063');
        parentLink.put('263','20000185');
        parentLink.put('263','20000142');
        parentLink.put('278','20000080');
        parentLink.put('278','20000010');
        parentLink.put('278','20000163');
        parentLink.put('278','20000142');
        parentLink.put('287','20000099');
        parentLink.put('287','20000063');
        parentLink.put('287','20000185');
        parentLink.put('287','20000142');
        parentLink.put('418','20000066');
        parentLink.put('418','20000011');
        parentLink.put('418','20000167');
        parentLink.put('418','20000142');
        parentLink.put('425','20000066');
        parentLink.put('425','20000011');
        parentLink.put('425','20000167');
        parentLink.put('425','20000142');
        parentLink.put('470','20000099');
        parentLink.put('470','20000063');
        parentLink.put('470','20000185');
        parentLink.put('470','20000142');
        parentLink.put('955','20000099');
        parentLink.put('955','20000063');
        parentLink.put('955','20000185');
        parentLink.put('955','20000142');
        parentLink.put('172','20000027');
        parentLink.put('172','20000007');
        parentLink.put('172','20000237');
        parentLink.put('172','20000015');
        parentLink.put('172','20000138');
        parentLink.put('203','20000027');
        parentLink.put('203','20000007');
        parentLink.put('203','20000237');
        parentLink.put('203','20000015');
        parentLink.put('203','20000138');
        parentLink.put('271','20000037');
        parentLink.put('271','20000060');
        parentLink.put('271','20000119');
        parentLink.put('271','20000015');
        parentLink.put('271','20000138');
        parentLink.put('280','20000096');
        parentLink.put('280','20000060');
        parentLink.put('280','20000153');
        parentLink.put('280','20000128');
        parentLink.put('280','20000143');
        parentLink.put('283','20000040');
        parentLink.put('283','20000100');
        parentLink.put('283','20000138');
        parentLink.put('295','20000040');
        parentLink.put('295','20000100');
        parentLink.put('295','20000138');
        parentLink.put('320','20000037');
        parentLink.put('320','20000019');
        parentLink.put('320','20000119');
        parentLink.put('320','20000015');
        parentLink.put('320','20000138');
        parentLink.put('339','20000096');
        parentLink.put('339','20000018');
        parentLink.put('339','20000058');
        parentLink.put('339','20000128');
        parentLink.put('339','20000143');
        parentLink.put('350','20000076');
        parentLink.put('350','20000238');
        parentLink.put('350','20000055');
        parentLink.put('350','20000127');
        parentLink.put('350','20000142');
        parentLink.put('418','20000066');
        parentLink.put('418','20000011');
        parentLink.put('418','20000167');
        parentLink.put('418','20000126');
        parentLink.put('418','20000142');
        parentLink.put('425','20000066');
        parentLink.put('425','20000011');
        parentLink.put('425','20000167');
        parentLink.put('425','20000126');
        parentLink.put('425','20000142');
        parentLink.put('453','20000068');
        parentLink.put('453','20000005');
        parentLink.put('453','20000156');
        parentLink.put('453','20000127');
        parentLink.put('453','20000143');
        parentLink.put('463','20000048');
        parentLink.put('463','20000008');
        parentLink.put('463','20000177');
        parentLink.put('463','20000015');
        parentLink.put('463','20000143');
        parentLink.put('466','20000076');
        parentLink.put('466','20000238');
        parentLink.put('466','20000055');
        parentLink.put('466','20000127');
        parentLink.put('466','20000142');
        parentLink.put('485','20000025');
        parentLink.put('485','20000007');
        parentLink.put('485','20000109');
        parentLink.put('485','20000130');
        parentLink.put('485','20000138');
        parentLink.put('522','20000096');
        parentLink.put('522','20000008');
        parentLink.put('522','20000051');
        parentLink.put('522','20000015');
        parentLink.put('522','20000143');
        parentLink.put('610','20000091');
        parentLink.put('610','20000014');
        parentLink.put('610','20000140');
        parentLink.put('610','20000137');
        parentLink.put('610','20000126');
        parentLink.put('610','20000142');
        parentLink.put('657','20000232');
        parentLink.put('657','20000010');
        parentLink.put('657','20000173');
        parentLink.put('657','20000137');
        parentLink.put('657','20000034');
        parentLink.put('672','20000041');
        parentLink.put('672','20000004');
        parentLink.put('672','20000056');
        parentLink.put('672','20000128');
        parentLink.put('672','20000143');
        parentLink.put('707','20000041');
        parentLink.put('707','20000004');
        parentLink.put('707','20000056');
        parentLink.put('707','20000128');
        parentLink.put('707','20000143');
        parentLink.put('822','20000147');
        parentLink.put('822','20000063');
        parentLink.put('822','20000185');
        parentLink.put('822','20000126');
        parentLink.put('822','20000142');
        parentLink.put('846','20000091');
        parentLink.put('846','20000014');
        parentLink.put('846','20000140');
        parentLink.put('846','20000137');
        parentLink.put('846','20000142');
        parentLink.put('855','20000094');
        parentLink.put('855','20000009');
        parentLink.put('855','20000077');
        parentLink.put('855','20000137');
        parentLink.put('855','20000034');
        parentLink.put('1262','20000027');
        parentLink.put('1262','20000149');
        parentLink.put('1262','20000237');
        parentLink.put('1262','20000138');
        
        List<Account> accounts = new List<Account>();
        
        accounts.add(new Account(  
                            Name='ATMEL TRADING COMPANY, LTD.',
                            Customer_Group__c='Z2',
                            Incoterms_1__c='EXW',
                            Incoterms_2__c='DELIVERING PLANT',
                            Currency__c='USD',
                            Payment_Terms__c='AA45',
                            Sales_Region__c='0013',
                            T_Stock_Flag__c='01',
                            Reject_Billing__c='',
                            Precious_Metals__c='003',
                            ShippingStreet='1-10-01 SUNTECH @ PENANG LINTANG MAYANG PASIR 3 11950 BAYAN BARU',
                            ShippingCity='PENANG',
                            ShippingPostalCode='',
                            ShippingState='',
                            ShippingCountry='MY',
                            AccountNumber='74'));
        accounts.add(new Account(  
                            Name='ANALOG DEVICES INC.',
                            Customer_Group__c='Z2',
                            Incoterms_1__c='EXW',
                            Incoterms_2__c='DELIVERING PLANT',
                            Currency__c='USD',
                            Payment_Terms__c='AA30',
                            Sales_Region__c='0014',
                            T_Stock_Flag__c='',
                            Reject_Billing__c='',
                            Precious_Metals__c='',
                            ShippingStreet='TECHNOLOGY WAY  ',
                            ShippingCity='NORWOOD',
                            ShippingPostalCode='2062',
                            ShippingState='MA',
                            ShippingCountry='US',
                            AccountNumber='76'));
        accounts.add(new Account(  
                            Name='ANALOG DEVICES INTERNATIONAL',
                            Customer_Group__c='Z2',
                            Incoterms_1__c='EXW',
                            Incoterms_2__c='DELIVERING PLANT',
                            Currency__c='USD',
                            Payment_Terms__c='AA30',
                            Sales_Region__c='0014',
                            T_Stock_Flag__c='',
                            Reject_Billing__c='',
                            Precious_Metals__c='',
                            ShippingStreet='RAHEEM BUSINESS PARK     RAHEEN  ',
                            ShippingCity='LIMERICK',
                            ShippingPostalCode='',
                            ShippingState='',
                            ShippingCountry='IE',
                            AccountNumber='81'));
        accounts.add(new Account(  
                            Name='ANALOG DEVICES INTERNATIONAL',
                            Customer_Group__c='Z2',
                            Incoterms_1__c='EXW',
                            Incoterms_2__c='DELIVERING PLANT',
                            Currency__c='USD',
                            Payment_Terms__c='AA30',
                            Sales_Region__c='0014',
                            T_Stock_Flag__c='01',
                            Reject_Billing__c='',
                            Precious_Metals__c='',
                            ShippingStreet='RAHEEM INDUSTRIAL ESTATE  ',
                            ShippingCity='LIMERICK',
                            ShippingPostalCode='',
                            ShippingState='',
                            ShippingCountry='IE',
                            AccountNumber='102'));
        accounts.add(new Account(  
                            Name='ALTERA CORPORATION, INC.',
                            Customer_Group__c='Z2',
                            Incoterms_1__c='EXW',
                            Incoterms_2__c='DELIVERING PLANT',
                            Currency__c='USD',
                            Payment_Terms__c='AA30',
                            Sales_Region__c='0013',
                            T_Stock_Flag__c='01',
                            Reject_Billing__c='002',
                            Precious_Metals__c='002',
                            ShippingStreet='INNOVATION DRIVE  ',
                            ShippingCity='SAN JOSE',
                            ShippingPostalCode='95134',
                            ShippingState='CA',
                            ShippingCountry='US',
                            AccountNumber='110'));
        accounts.add(new Account(  
                            Name='LSI LOGIC SINGAPORE PTE. LTD.',
                            Customer_Group__c='Z2',
                            Incoterms_1__c='EXW',
                            Incoterms_2__c='DELIVERING PLANT',
                            Currency__c='USD',
                            Payment_Terms__c='Z15N',
                            Sales_Region__c='0013',
                            T_Stock_Flag__c='02',
                            Reject_Billing__c='',
                            Precious_Metals__c='002',
                            ShippingStreet='PO BOX 99  ',
                            ShippingCity='PATHUMTHANI',
                            ShippingPostalCode='121200',
                            ShippingState='',
                            ShippingCountry='SG',
                            AccountNumber='120'));
        accounts.add(new Account(  
                            Name='ATMEL TRADING COMPANY, LTD.',
                            Customer_Group__c='Z2',
                            Incoterms_1__c='EXW',
                            Incoterms_2__c='DELIVERING PLANT',
                            Currency__c='USD',
                            Payment_Terms__c='AA45',
                            Sales_Region__c='0013',
                            T_Stock_Flag__c='01',
                            Reject_Billing__c='',
                            Precious_Metals__c='003',
                            ShippingStreet='1-10-01 SUNTECH @ PENANG LINTANG MAYANG PASIR 3 11950 BAYAN BARU',
                            ShippingCity='PENANG',
                            ShippingPostalCode='',
                            ShippingState='',
                            ShippingCountry='MY',
                            AccountNumber='125'));
        accounts.add(new Account(  
                            Name='ATMEL AUTOMOTIVE GMBH',
                            Customer_Group__c='Z2',
                            Incoterms_1__c='EXW',
                            Incoterms_2__c='DELIVERING PLANT',
                            Currency__c='USD',
                            Payment_Terms__c='AA45',
                            Sales_Region__c='0013',
                            T_Stock_Flag__c='',
                            Reject_Billing__c='',
                            Precious_Metals__c='',
                            ShippingStreet=' THERESIENSTRASSE 2 ',
                            ShippingCity='HEILBRONN',
                            ShippingPostalCode='74072',
                            ShippingState='',
                            ShippingCountry='DE',
                            AccountNumber='131'));
        accounts.add(new Account(  
                            Name='LSI LOGIC SINGAPORE',
                            Customer_Group__c='Z2',
                            Incoterms_1__c='EXW',
                            Incoterms_2__c='DELIVERING PLANT',
                            Currency__c='USD',
                            Payment_Terms__c='Z15N',
                            Sales_Region__c='0013',
                            T_Stock_Flag__c='',
                            Reject_Billing__c='',
                            Precious_Metals__c='002',
                            ShippingStreet='(SINGAPORE) PTE LTD 3 KALLANG SECTOR ',
                            ShippingCity='SINGAPORE',
                            ShippingPostalCode='349278',
                            ShippingState='',
                            ShippingCountry='SG',
                            AccountNumber='144'));
        accounts.add(new Account(  
                            Name='ATMEL CORPORATION - CO',
                            Customer_Group__c='Z2',
                            Incoterms_1__c='EXW',
                            Incoterms_2__c='DELIVERING PLANT',
                            Currency__c='USD',
                            Payment_Terms__c='AA45',
                            Sales_Region__c='0013',
                            T_Stock_Flag__c='',
                            Reject_Billing__c='',
                            Precious_Metals__c='',
                            ShippingStreet='E. CHEYENNE MTN. BLVD.  ',
                            ShippingCity='COLORADO SPRINGS',
                            ShippingPostalCode='80906',
                            ShippingState='CO',
                            ShippingCountry='US',
                            AccountNumber='150'));
        accounts.add(new Account(  
                            Name='ATMEL TRADING COMPANY, LTD.',
                            Customer_Group__c='Z2',
                            Incoterms_1__c='EXW',
                            Incoterms_2__c='DELIVERING PLANT',
                            Currency__c='USD',
                            Payment_Terms__c='AA45',
                            Sales_Region__c='0013',
                            T_Stock_Flag__c='01',
                            Reject_Billing__c='',
                            Precious_Metals__c='003',
                            ShippingStreet='1-10-01 SUNTECH @ PENANG LINTANG MAYANG PASIR 3 11950 BAYAN BARU',
                            ShippingCity='PENANG',
                            ShippingPostalCode='',
                            ShippingState='',
                            ShippingCountry='MY',
                            AccountNumber='152'));
        accounts.add(new Account(  
                            Name='ANALOG DEV. PHILIPPINES',
                            Customer_Group__c='Z2',
                            Incoterms_1__c='EXW',
                            Incoterms_2__c='DELIVERING PLANT',
                            Currency__c='USD',
                            Payment_Terms__c='AA30',
                            Sales_Region__c='0014',
                            T_Stock_Flag__c='',
                            Reject_Billing__c='',
                            Precious_Metals__c='',
                            ShippingStreet='JAVALERA GENERAL TRIAS GATEWAY BUSINESS PARK ',
                            ShippingCity='CAVITE',
                            ShippingPostalCode='4107',
                            ShippingState='',
                            ShippingCountry='PH',
                            AccountNumber='153'));
        accounts.add(new Account(  
                            Name='ATMEL CORPORATION-SJ',
                            Customer_Group__c='Z2',
                            Incoterms_1__c='EXW',
                            Incoterms_2__c='DELIVERING PLANT',
                            Currency__c='USD',
                            Payment_Terms__c='AA45',
                            Sales_Region__c='0013',
                            T_Stock_Flag__c='',
                            Reject_Billing__c='',
                            Precious_Metals__c='',
                            ShippingStreet='ORCHARD PARKWAY  ',
                            ShippingCity='SAN JOSE',
                            ShippingPostalCode='95131',
                            ShippingState='CA',
                            ShippingCountry='US',
                            AccountNumber='154'));
        accounts.add(new Account(  
                            Name='ANALOG DEVICES GEN TRIAS',
                            Customer_Group__c='Z2',
                            Incoterms_1__c='EXW',
                            Incoterms_2__c='DELIVERING PLANT',
                            Currency__c='USD',
                            Payment_Terms__c='AA30',
                            Sales_Region__c='0014',
                            T_Stock_Flag__c='',
                            Reject_Billing__c='',
                            Precious_Metals__c='',
                            ShippingStreet='GATEWAY BUSINESS PARK JAVALERA GENERAL TRIAS ',
                            ShippingCity='CAVITE',
                            ShippingPostalCode='',
                            ShippingState='',
                            ShippingCountry='PH',
                            AccountNumber='156'));
        accounts.add(new Account(  
                            Name='ATMEL NANTES SA',
                            Customer_Group__c='Z2',
                            Incoterms_1__c='EXW',
                            Incoterms_2__c='DELIVERING PLANT',
                            Currency__c='USD',
                            Payment_Terms__c='AA30',
                            Sales_Region__c='0013',
                            T_Stock_Flag__c='',
                            Reject_Billing__c='',
                            Precious_Metals__c='003',
                            ShippingStreet='44306 NANTES ATTN: FINANCE DEPT. ',
                            ShippingCity='',
                            ShippingPostalCode='',
                            ShippingState='',
                            ShippingCountry='FR',
                            AccountNumber='218'));
        accounts.add(new Account(  
                            Name='ATMEL TRADING COMPANY, LTD.',
                            Customer_Group__c='Z2',
                            Incoterms_1__c='EXW',
                            Incoterms_2__c='DELIVERING PLANT',
                            Currency__c='USD',
                            Payment_Terms__c='AA45',
                            Sales_Region__c='0013',
                            T_Stock_Flag__c='',
                            Reject_Billing__c='',
                            Precious_Metals__c='003',
                            ShippingStreet='1-10-01 SUNTECH @ PENANG LINTANG MAYANG PASIR 3 11950 BAYAN BARU',
                            ShippingCity='PENANG',
                            ShippingPostalCode='',
                            ShippingState='',
                            ShippingCountry='MY',
                            AccountNumber='225'));
        accounts.add(new Account(  
                            Name='ANALOG DEVICES B.V.',
                            Customer_Group__c='Z2',
                            Incoterms_1__c='EXW',
                            Incoterms_2__c='DELIVERING PLANT',
                            Currency__c='USD',
                            Payment_Terms__c='AA30',
                            Sales_Region__c='0014',
                            T_Stock_Flag__c='',
                            Reject_Billing__c='',
                            Precious_Metals__c='',
                            ShippingStreet='BAY F-1 RAHEEN INDUSTRIAL ESTATE ',
                            ShippingCity='LIMERICK',
                            ShippingPostalCode='',
                            ShippingState='',
                            ShippingCountry='IE',
                            AccountNumber='235'));
        accounts.add(new Account(  
                            Name='ATMEL ROUSSET SAS',
                            Customer_Group__c='Z2',
                            Incoterms_1__c='EXW',
                            Incoterms_2__c='DELIVERING PLANT',
                            Currency__c='USD',
                            Payment_Terms__c='AA30',
                            Sales_Region__c='0013',
                            T_Stock_Flag__c='',
                            Reject_Billing__c='',
                            Precious_Metals__c='003',
                            ShippingStreet='13106 ROUSSET CEDEX ATTN: FINANCE DEPT. ',
                            ShippingCity='',
                            ShippingPostalCode='',
                            ShippingState='',
                            ShippingCountry='FR',
                            AccountNumber='242'));
        accounts.add(new Account(  
                            Name='ATMEL TRADING COMPANY, LTD.',
                            Customer_Group__c='Z2',
                            Incoterms_1__c='EXW',
                            Incoterms_2__c='DELIVERING PLANT',
                            Currency__c='USD',
                            Payment_Terms__c='AA45',
                            Sales_Region__c='0013',
                            T_Stock_Flag__c='',
                            Reject_Billing__c='',
                            Precious_Metals__c='003',
                            ShippingStreet='1-10-01 SUNTECH @ PENANG LINTANG MAYANG PASIR 3 11950 BAYAN BARU',
                            ShippingCity='PENANG',
                            ShippingPostalCode='',
                            ShippingState='',
                            ShippingCountry='MY',
                            AccountNumber='263'));
        accounts.add(new Account(  
                            Name='ALTERA CORPORATION (M) SD',
                            Customer_Group__c='Z2',
                            Incoterms_1__c='EXW',
                            Incoterms_2__c='DELIVERING PLANT',
                            Currency__c='USD',
                            Payment_Terms__c='AA30',
                            Sales_Region__c='0013',
                            T_Stock_Flag__c='01',
                            Reject_Billing__c='',
                            Precious_Metals__c='002',
                            ShippingStreet='PLOT 6 BAYAN LEPAS TECH. MEDAN BAYAN LEPAS ',
                            ShippingCity='PENANG',
                            ShippingPostalCode='11900',
                            ShippingState='',
                            ShippingCountry='MY',
                            AccountNumber='278'));
        accounts.add(new Account(  
                            Name='ATMEL TRADING COMPANY LTD.',
                            Customer_Group__c='Z2',
                            Incoterms_1__c='EXW',
                            Incoterms_2__c='DELIVERING PLANT',
                            Currency__c='USD',
                            Payment_Terms__c='AA45',
                            Sales_Region__c='0013',
                            T_Stock_Flag__c='01',
                            Reject_Billing__c='',
                            Precious_Metals__c='',
                            ShippingStreet='1-10-01 SUNTECH @ PENANG LINTANG MAYANG PASIR 3 11950 BAYAN BARU',
                            ShippingCity='PENANG',
                            ShippingPostalCode='',
                            ShippingState='',
                            ShippingCountry='MY',
                            AccountNumber='287'));
        accounts.add(new Account(  
                            Name='LSI CORPORATION',
                            Customer_Group__c='Z2',
                            Incoterms_1__c='EXW',
                            Incoterms_2__c='DELIVERING PLANT',
                            Currency__c='USD',
                            Payment_Terms__c='Z15N',
                            Sales_Region__c='0013',
                            T_Stock_Flag__c='',
                            Reject_Billing__c='',
                            Precious_Metals__c='002',
                            ShippingStreet='ARROWSWEST DRIVE  ',
                            ShippingCity='COLORADO SPRINGS',
                            ShippingPostalCode='80907',
                            ShippingState='CO',
                            ShippingCountry='US',
                            AccountNumber='418'));
        accounts.add(new Account(  
                            Name='LSI TECHNOLOGY (SINGAPORE) PTE LTD',
                            Customer_Group__c='Z2',
                            Incoterms_1__c='EXW',
                            Incoterms_2__c='DELIVERING PLANT',
                            Currency__c='USD',
                            Payment_Terms__c='Z15N',
                            Sales_Region__c='0013',
                            T_Stock_Flag__c='01',
                            Reject_Billing__c='',
                            Precious_Metals__c='002',
                            ShippingStreet='PO BOX 99  ',
                            ShippingCity='PATHUMTHANI',
                            ShippingPostalCode='12120',
                            ShippingState='37',
                            ShippingCountry='TH',
                            AccountNumber='425'));
        accounts.add(new Account(  
                            Name='ATMEL TRADING COMPANY, LTD.',
                            Customer_Group__c='Z2',
                            Incoterms_1__c='EXW',
                            Incoterms_2__c='DELIVERING PLANT',
                            Currency__c='USD',
                            Payment_Terms__c='AA45',
                            Sales_Region__c='0013',
                            T_Stock_Flag__c='01',
                            Reject_Billing__c='',
                            Precious_Metals__c='003',
                            ShippingStreet='1-10-01 SUNTECH @ PENANG LINTANG MAYANG PASIR 3 11950 BAYAN BARU',
                            ShippingCity='PENANG',
                            ShippingPostalCode='',
                            ShippingState='',
                            ShippingCountry='MY',
                            AccountNumber='470'));
        accounts.add(new Account(  
                            Name='ATMEL TRADING COMPANY, LTD.',
                            Customer_Group__c='Z2',
                            Incoterms_1__c='EXW',
                            Incoterms_2__c='DELIVERING PLANT',
                            Currency__c='USD',
                            Payment_Terms__c='AA45',
                            Sales_Region__c='0013',
                            T_Stock_Flag__c='',
                            Reject_Billing__c='',
                            Precious_Metals__c='003',
                            ShippingStreet=' 1-10-05SUNTECH @ PENANG CYBERCITY LINTANG MAYANG PASIR 3',
                            ShippingCity='PENANG',
                            ShippingPostalCode='11950',
                            ShippingState='',
                            ShippingCountry='MY',
                            AccountNumber='955'));
        accounts.add(new Account(  
                            Name='ANALOG DEVICES, INC.',
                            Customer_Group__c='',
                            Incoterms_1__c='',
                            Incoterms_2__c='',
                            Currency__c='',
                            Payment_Terms__c='',
                            Sales_Region__c='',
                            T_Stock_Flag__c='',
                            Reject_Billing__c='',
                            Precious_Metals__c='',
                            ShippingStreet='  ',
                            ShippingCity='',
                            ShippingPostalCode='',
                            ShippingState='',
                            ShippingCountry='US',
                            AccountNumber='5000'));
        accounts.add(new Account(  
                            Name='ATMEL TRADING COMPANY LTD.',
                            Customer_Group__c='',
                            Incoterms_1__c='',
                            Incoterms_2__c='',
                            Currency__c='',
                            Payment_Terms__c='',
                            Sales_Region__c='',
                            T_Stock_Flag__c='',
                            Reject_Billing__c='',
                            Precious_Metals__c='',
                            ShippingStreet='  ',
                            ShippingCity='',
                            ShippingPostalCode='',
                            ShippingState='',
                            ShippingCountry='US',
                            AccountNumber='7000'));
        accounts.add(new Account(  
                            Name='LSI CORPORATION',
                            Customer_Group__c='',
                            Incoterms_1__c='',
                            Incoterms_2__c='',
                            Currency__c='',
                            Payment_Terms__c='',
                            Sales_Region__c='',
                            T_Stock_Flag__c='',
                            Reject_Billing__c='',
                            Precious_Metals__c='',
                            ShippingStreet='  ',
                            ShippingCity='',
                            ShippingPostalCode='',
                            ShippingState='',
                            ShippingCountry='US',
                            AccountNumber='40000'));
        accounts.add(new Account(  
                            Name='ALTERA CORPORATION',
                            Customer_Group__c='',
                            Incoterms_1__c='',
                            Incoterms_2__c='',
                            Currency__c='',
                            Payment_Terms__c='',
                            Sales_Region__c='',
                            T_Stock_Flag__c='',
                            Reject_Billing__c='',
                            Precious_Metals__c='',
                            ShippingStreet='  ',
                            ShippingCity='',
                            ShippingPostalCode='',
                            ShippingState='',
                            ShippingCountry='US',
                            AccountNumber='41078'));
                            
                            
                            
       accounts.add(new Account(  
                            Name='AIROHA TECHNOLOGY CORP.',
                            Customer_Group__c='Z2',
                            Incoterms_1__c='EXW',
                            Incoterms_2__c='DELIVERING PLANT',
                            Currency__c='USD',
                            Payment_Terms__c='AA30',
                            Sales_Region__c='0015',
                            T_Stock_Flag__c='',
                            Reject_Billing__c='',
                            Precious_Metals__c='',
                            ShippingStreet='5F.  NO.6-5  DUSING ROAD',
                            ShippingCity='HSINCHU',
                            ShippingPostalCode=' 300',
                            ShippingState='',
                            ShippingCountry='',
                            AccountNumber='172'));

        accounts.add(new Account(  
                            Name='ALCHIP TECHNOLOGIES INC',
                            Customer_Group__c='Z2',
                            Incoterms_1__c='EXW',
                            Incoterms_2__c='DELIVERING PLANT',
                            Currency__c='USD',
                            Payment_Terms__c='AA45',
                            Sales_Region__c='0015',
                            T_Stock_Flag__c='',
                            Reject_Billing__c='',
                            Precious_Metals__c='',
                            ShippingStreet='9F',
                            ShippingCity='',
                            ShippingPostalCode='',
                            ShippingState='TAIPEI CITY 114',
                            ShippingCountry='',
                            AccountNumber='203'));

        accounts.add(new Account(  
                            Name='MICROCHIP TECHNOLOGY THAILAND CO.',
                            Customer_Group__c='Z2',
                            Incoterms_1__c='EXW',
                            Incoterms_2__c='DELIVERING PLANT',
                            Currency__c='USD',
                            Payment_Terms__c='AA30',
                            Sales_Region__c='0015',
                            T_Stock_Flag__c='',
                            Reject_Billing__c='',
                            Precious_Metals__c='',
                            ShippingStreet='14 MOO 1 T.WANGTAKIEN',
                            ShippingCity='A. MUANG CHACHERNGSAO',
                            ShippingPostalCode='24000',
                            ShippingState='',
                            ShippingCountry='TH',
                            AccountNumber='271'));

        accounts.add(new Account(  
                            Name='ON CFPG US',
                            Customer_Group__c='Z2',
                            Incoterms_1__c='EXW',
                            Incoterms_2__c='DELIVERING PLANT',
                            Currency__c='USD',
                            Payment_Terms__c='AA30',
                            Sales_Region__c='0014',
                            T_Stock_Flag__c='',
                            Reject_Billing__c='',
                            Precious_Metals__c='',
                            ShippingStreet='BUCKSKIN ROAD',
                            ShippingCity='POCATELLO',
                            ShippingPostalCode='83201',
                            ShippingState='ID',
                            ShippingCountry='US',
                            AccountNumber='280'));

        accounts.add(new Account(  
                            Name='SONY-OITA',
                            Customer_Group__c='Z4',
                            Incoterms_1__c='EXW',
                            Incoterms_2__c='DELIVERING PLANT',
                            Currency__c='USD',
                            Payment_Terms__c='AA30',
                            Sales_Region__c='0008',
                            T_Stock_Flag__c='',
                            Reject_Billing__c='',
                            Precious_Metals__c='',
                            ShippingStreet='SHINAGAWA-KU',
                            ShippingCity='',
                            ShippingPostalCode='141-0031 JAPAN',
                            ShippingState='TOKYO 141-0031 JAPAN',
                            ShippingCountry='1410031',
                            AccountNumber='283'));

        accounts.add(new Account(  
                            Name='SONY NAGASAKI - SCE',
                            Customer_Group__c='Z4',
                            Incoterms_1__c='EXW',
                            Incoterms_2__c='DELIVERING PLANT',
                            Currency__c='USD',
                            Payment_Terms__c='AA30',
                            Sales_Region__c='0008',
                            T_Stock_Flag__c='',
                            Reject_Billing__c='',
                            Precious_Metals__c='',
                            ShippingStreet='ISAHAYA-SHI',
                            ShippingCity='1883-43',
                            ShippingPostalCode=' TSUKUBA-CHO',
                            ShippingState='',
                            ShippingCountry='854-0065  SONY SEMI',
                            AccountNumber='295'));

        accounts.add(new Account(  
                            Name='MARVELL ASIA PTE. LTD.',
                            Customer_Group__c='Z2',
                            Incoterms_1__c='EXW',
                            Incoterms_2__c='DELIVERING PLANT',
                            Currency__c='USD',
                            Payment_Terms__c='AA30',
                            Sales_Region__c='0015',
                            T_Stock_Flag__c='',
                            Reject_Billing__c='',
                            Precious_Metals__c='',
                            ShippingStreet='8 TAI SENG LINK',
                            ShippingCity='',
                            ShippingPostalCode='534158',
                            ShippingState='',
                            ShippingCountry='SG',
                            AccountNumber='320'));

        accounts.add(new Account(  
                            Name='INTEL CORPORATION',
                            Customer_Group__c='Z2',
                            Incoterms_1__c='EXW',
                            Incoterms_2__c='DELIVERING PLANT',
                            Currency__c='USD',
                            Payment_Terms__c='ZN30',
                            Sales_Region__c='0014',
                            T_Stock_Flag__c='',
                            Reject_Billing__c='',
                            Precious_Metals__c='',
                            ShippingStreet='P.O. BOX 1000',
                            ShippingCity='HILLSBORO',
                            ShippingPostalCode='97123-1000',
                            ShippingState='OR',
                            ShippingCountry='US',
                            AccountNumber='339'));

        accounts.add(new Account(  
                            Name='MAXIM DALLAS TERIDIAN',
                            Customer_Group__c='Z2',
                            Incoterms_1__c='EXW',
                            Incoterms_2__c='DELIVERING PLANT',
                            Currency__c='USD',
                            Payment_Terms__c='AA45',
                            Sales_Region__c='0013',
                            T_Stock_Flag__c='',
                            Reject_Billing__c='',
                            Precious_Metals__c='',
                            ShippingStreet='',
                            ShippingCity='',
                            ShippingPostalCode='',
                            ShippingState='',
                            ShippingCountry='',
                            AccountNumber='350'));

        accounts.add(new Account(  
                            Name='LSI CORPORATION',
                            Customer_Group__c='Z2',
                            Incoterms_1__c='EXW',
                            Incoterms_2__c='DELIVERING PLANT',
                            Currency__c='USD',
                            Payment_Terms__c='Z15N',
                            Sales_Region__c='0013',
                            T_Stock_Flag__c='',
                            Reject_Billing__c='',
                            Precious_Metals__c='',
                            ShippingStreet='ARROWSWEST DRIVE',
                            ShippingCity='COLORADO SPRINGS',
                            ShippingPostalCode='80907',
                            ShippingState='CO',
                            ShippingCountry='US',
                            AccountNumber='418'));

        accounts.add(new Account(  
                            Name='LSI TECHNOLOGY (SINGAPORE) PTE LTD',
                            Customer_Group__c='Z2',
                            Incoterms_1__c='EXW',
                            Incoterms_2__c='DELIVERING PLANT',
                            Currency__c='USD',
                            Payment_Terms__c='Z15N',
                            Sales_Region__c='0013',
                            T_Stock_Flag__c='',
                            Reject_Billing__c='',
                            Precious_Metals__c='',
                            ShippingStreet='PO BOX 99',
                            ShippingCity='PATHUMTHANI',
                            ShippingPostalCode='12120',
                            ShippingState='37',
                            ShippingCountry='TH',
                            AccountNumber='425'));

        accounts.add(new Account(  
                            Name='QUALCOMM INC.',
                            Customer_Group__c='Z2',
                            Incoterms_1__c='EXW',
                            Incoterms_2__c='DELIVERING PLANT',
                            Currency__c='USD',
                            Payment_Terms__c='AA45',
                            Sales_Region__c='0014',
                            T_Stock_Flag__c='',
                            Reject_Billing__c='',
                            Precious_Metals__c='',
                            ShippingStreet='PACIFIC CENTER BLVD',
                            ShippingCity='SAN DIEGO',
                            ShippingPostalCode='92191-9042',
                            ShippingState='CA',
                            ShippingCountry='US',
                            AccountNumber='453'));

        accounts.add(new Account(  
                            Name='FREESCALE SEMI ATX',
                            Customer_Group__c='Z2',
                            Incoterms_1__c='EXW',
                            Incoterms_2__c='DELIVERING PLANT',
                            Currency__c='USD',
                            Payment_Terms__c='AA60',
                            Sales_Region__c='0014',
                            T_Stock_Flag__c='',
                            Reject_Billing__c='',
                            Precious_Metals__c='',
                            ShippingStreet='P.O. BOX 20922',
                            ShippingCity='PHOENIX',
                            ShippingPostalCode='85036',
                            ShippingState='AZ',
                            ShippingCountry='US',
                            AccountNumber='463'));

        accounts.add(new Account(  
                            Name='MAXIM INTEGRATED PRODUCTS',
                            Customer_Group__c='Z2',
                            Incoterms_1__c='EXW',
                            Incoterms_2__c='DELIVERING PLANT',
                            Currency__c='USD',
                            Payment_Terms__c='AA45',
                            Sales_Region__c='0013',
                            T_Stock_Flag__c='',
                            Reject_Billing__c='',
                            Precious_Metals__c='',
                            ShippingStreet='P.O. BOX 11767',
                            ShippingCity='BALLSBRIDGE   DUBLIN 4',
                            ShippingPostalCode='',
                            ShippingState='',
                            ShippingCountry='IE',
                            AccountNumber='466'));

        accounts.add(new Account(  
                            Name='NEC CORPORATION',
                            Customer_Group__c='Z2',
                            Incoterms_1__c='EXW',
                            Incoterms_2__c='DELIVERING PLANT',
                            Currency__c='USD',
                            Payment_Terms__c='AA30',
                            Sales_Region__c='0008',
                            T_Stock_Flag__c='',
                            Reject_Billing__c='',
                            Precious_Metals__c='',
                            ShippingStreet='38 ANG MO KIO INDUST.PARK',
                            ShippingCity='2 SINGAPORE 2056',
                            ShippingPostalCode='',
                            ShippingState='',
                            ShippingCountry='SG',
                            AccountNumber='485'));

        accounts.add(new Account(  
                            Name='FREESCALE SEMI INC PHX',
                            Customer_Group__c='Z2',
                            Incoterms_1__c='EXW',
                            Incoterms_2__c='DELIVERING PLANT',
                            Currency__c='USD',
                            Payment_Terms__c='AA60',
                            Sales_Region__c='0014',
                            T_Stock_Flag__c='',
                            Reject_Billing__c='',
                            Precious_Metals__c='',
                            ShippingStreet='P. O. BOX 20922',
                            ShippingCity='PHOENIX',
                            ShippingPostalCode='85036',
                            ShippingState='AZ',
                            ShippingCountry='US',
                            AccountNumber='522'));

        accounts.add(new Account(  
                            Name='MINDSPEED',
                            Customer_Group__c='Z2',
                            Incoterms_1__c='EXW',
                            Incoterms_2__c='DELIVERING PLANT',
                            Currency__c='USD',
                            Payment_Terms__c='AA30',
                            Sales_Region__c='0013',
                            T_Stock_Flag__c='',
                            Reject_Billing__c='',
                            Precious_Metals__c='',
                            ShippingStreet='P.O. BOX 9639',
                            ShippingCity='NEWPORT BEACH',
                            ShippingPostalCode='92658-9639',
                            ShippingState='CA',
                            ShippingCountry='US',
                            AccountNumber='610'));

        accounts.add(new Account(  
                            Name='INFINEON TECHNOLOGIES',
                            Customer_Group__c='Z2',
                            Incoterms_1__c='EXW',
                            Incoterms_2__c='DELIVERING PLANT',
                            Currency__c='USD',
                            Payment_Terms__c='AA60',
                            Sales_Region__c='0006',
                            T_Stock_Flag__c='',
                            Reject_Billing__c='',
                            Precious_Metals__c='',
                            ShippingStreet='8 KALLANG SECTOR',
                            ShippingCity='SINGAPORE',
                            ShippingPostalCode='349282',
                            ShippingState='',
                            ShippingCountry='SG',
                            AccountNumber='657'));

        accounts.add(new Account(  
                            Name='TEXAS INSTRUMENTS  INC.',
                            Customer_Group__c='Z2',
                            Incoterms_1__c='EXW',
                            Incoterms_2__c='DELIVERING PLANT',
                            Currency__c='USD',
                            Payment_Terms__c='AA30',
                            Sales_Region__c='0014',
                            T_Stock_Flag__c='',
                            Reject_Billing__c='',
                            Precious_Metals__c='',
                            ShippingStreet='P.O. BOX 655214',
                            ShippingCity='DALLAS',
                            ShippingPostalCode='75265-5214',
                            ShippingState='TX',
                            ShippingCountry='US',
                            AccountNumber='672'));

        accounts.add(new Account(  
                            Name='TI (PHILIPPINES)  INC.',
                            Customer_Group__c='Z2',
                            Incoterms_1__c='EXW',
                            Incoterms_2__c='DELIVERING PLANT',
                            Currency__c='USD',
                            Payment_Terms__c='AA30',
                            Sales_Region__c='0014',
                            T_Stock_Flag__c='',
                            Reject_Billing__c='',
                            Precious_Metals__c='',
                            ShippingStreet='PEZA LOAKAN ROAD',
                            ShippingCity='BAGUIO CITY',
                            ShippingPostalCode='2600',
                            ShippingState='',
                            ShippingCountry='PH',
                            AccountNumber='707'));

        accounts.add(new Account(  
                            Name='SPANSION LLC',
                            Customer_Group__c='Z2',
                            Incoterms_1__c='EXW',
                            Incoterms_2__c='DELIVERING PLANT',
                            Currency__c='USD',
                            Payment_Terms__c='AA30',
                            Sales_Region__c='0013',
                            T_Stock_Flag__c='',
                            Reject_Billing__c='',
                            Precious_Metals__c='',
                            ShippingStreet='DE GUINE',
                            ShippingCity='SUNNYVALE',
                            ShippingPostalCode='94088',
                            ShippingState='CA',
                            ShippingCountry='US',
                            AccountNumber='822'));

        accounts.add(new Account(  
                            Name='BROADCOM SINGAPORE PTE LTD',
                            Customer_Group__c='Z2',
                            Incoterms_1__c='EXW',
                            Incoterms_2__c='DELIVERING PLANT',
                            Currency__c='USD',
                            Payment_Terms__c='AA45',
                            Sales_Region__c='0013',
                            T_Stock_Flag__c='',
                            Reject_Billing__c='',
                            Precious_Metals__c='',
                            ShippingStreet='29 WOODLANDS IND. PARK E1',
                            ShippingCity='#03-13/16. NORTHTECH(LOB3)',
                            ShippingPostalCode='757716',
                            ShippingState='',
                            ShippingCountry='SG',
                            AccountNumber='846'));

        accounts.add(new Account(  
                            Name='STMICROELECTRONICS PTE',
                            Customer_Group__c='Z2',
                            Incoterms_1__c='EXW',
                            Incoterms_2__c='DELIVERING PLANT',
                            Currency__c='USD',
                            Payment_Terms__c='AA30',
                            Sales_Region__c='0006',
                            T_Stock_Flag__c='',
                            Reject_Billing__c='',
                            Precious_Metals__c='',
                            ShippingStreet='28 ANG MO KIO',
                            ShippingCity='',
                            ShippingPostalCode='',
                            ShippingState='',
                            ShippingCountry='',
                            AccountNumber='855'));

        accounts.add(new Account(  
                            Name='ACARD TECHNOLOGY CORP',
                            Customer_Group__c='Z6',
                            Incoterms_1__c='EXW',
                            Incoterms_2__c='DELIVERING PLANT',
                            Currency__c='TWD',
                            Payment_Terms__c='TA30',
                            Sales_Region__c='0015',
                            T_Stock_Flag__c='',
                            Reject_Billing__c='',
                            Precious_Metals__c='',
                            ShippingStreet='SEC 1 KWANG FU ROAD',
                            ShippingCity='SANCHUNG TAIPEI HSIEN',
                            ShippingPostalCode='241',
                            ShippingState='',
                            ShippingCountry='TW',
                            AccountNumber='1262'));

        accounts.add(new Account(  
                            Name='RENESAS ELECTRONICS CORPORATION',
                            Customer_Group__c='',
                            Incoterms_1__c='',
                            Incoterms_2__c='',
                            Currency__c='',
                            Payment_Terms__c='',
                            Sales_Region__c='',
                            T_Stock_Flag__c='',
                            Reject_Billing__c='',
                            Precious_Metals__c='',
                            ShippingStreet='',
                            ShippingCity='',
                            ShippingPostalCode='',
                            ShippingState='',
                            ShippingCountry='JP',
                            AccountNumber='10010'));

        accounts.add(new Account(  
                            Name='QUALCOMM GLOBAL TRADING PTE',
                            Customer_Group__c='',
                            Incoterms_1__c='',
                            Incoterms_2__c='',
                            Currency__c='',
                            Payment_Terms__c='',
                            Sales_Region__c='',
                            T_Stock_Flag__c='',
                            Reject_Billing__c='',
                            Precious_Metals__c='',
                            ShippingStreet='',
                            ShippingCity='',
                            ShippingPostalCode='',
                            ShippingState='',
                            ShippingCountry='',
                            AccountNumber='10045'));

        accounts.add(new Account(  
                            Name='ALCHIP TECHNOLOGIES',
                            Customer_Group__c='',
                            Incoterms_1__c='',
                            Incoterms_2__c='',
                            Currency__c='',
                            Payment_Terms__c='',
                            Sales_Region__c='',
                            T_Stock_Flag__c='',
                            Reject_Billing__c='',
                            Precious_Metals__c='',
                            ShippingStreet='',
                            ShippingCity='',
                            ShippingPostalCode='',
                            ShippingState='',
                            ShippingCountry='',
                            AccountNumber='10069'));

        accounts.add(new Account(  
                            Name='AIROHA TECHNOLOGY CORP',
                            Customer_Group__c='',
                            Incoterms_1__c='',
                            Incoterms_2__c='',
                            Currency__c='',
                            Payment_Terms__c='',
                            Sales_Region__c='',
                            T_Stock_Flag__c='',
                            Reject_Billing__c='',
                            Precious_Metals__c='',
                            ShippingStreet='',
                            ShippingCity='',
                            ShippingPostalCode='',
                            ShippingState='',
                            ShippingCountry='TW',
                            AccountNumber='10126'));

        accounts.add(new Account(  
                            Name='SPANSION LLC',
                            Customer_Group__c='',
                            Incoterms_1__c='',
                            Incoterms_2__c='',
                            Currency__c='',
                            Payment_Terms__c='',
                            Sales_Region__c='',
                            T_Stock_Flag__c='',
                            Reject_Billing__c='',
                            Precious_Metals__c='',
                            ShippingStreet='',
                            ShippingCity='',
                            ShippingPostalCode='',
                            ShippingState='CA',
                            ShippingCountry='US',
                            AccountNumber='10164'));

        accounts.add(new Account(  
                            Name='ACARD TECHNOLOGY CORP.',
                            Customer_Group__c='',
                            Incoterms_1__c='',
                            Incoterms_2__c='',
                            Currency__c='',
                            Payment_Terms__c='',
                            Sales_Region__c='',
                            T_Stock_Flag__c='',
                            Reject_Billing__c='',
                            Precious_Metals__c='',
                            ShippingStreet='',
                            ShippingCity='',
                            ShippingPostalCode='',
                            ShippingState='',
                            ShippingCountry='TW',
                            AccountNumber='10190'));

        accounts.add(new Account(  
                            Name='MAXIM INTEGRATED PRODUCTS',
                            Customer_Group__c='',
                            Incoterms_1__c='',
                            Incoterms_2__c='',
                            Currency__c='',
                            Payment_Terms__c='',
                            Sales_Region__c='',
                            T_Stock_Flag__c='',
                            Reject_Billing__c='',
                            Precious_Metals__c='',
                            ShippingStreet='',
                            ShippingCity='',
                            ShippingPostalCode='',
                            ShippingState='',
                            ShippingCountry='US',
                            AccountNumber='16000'));

        accounts.add(new Account(  
                            Name='FREESCALE SEMICONDUCTOR',
                            Customer_Group__c='',
                            Incoterms_1__c='',
                            Incoterms_2__c='',
                            Currency__c='',
                            Payment_Terms__c='',
                            Sales_Region__c='',
                            T_Stock_Flag__c='',
                            Reject_Billing__c='',
                            Precious_Metals__c='',
                            ShippingStreet='',
                            ShippingCity='',
                            ShippingPostalCode='',
                            ShippingState='',
                            ShippingCountry='',
                            AccountNumber='17000'));

        accounts.add(new Account(  
                            Name='INFINEON TECHNOLOGIES AG',
                            Customer_Group__c='',
                            Incoterms_1__c='',
                            Incoterms_2__c='',
                            Currency__c='',
                            Payment_Terms__c='',
                            Sales_Region__c='',
                            T_Stock_Flag__c='',
                            Reject_Billing__c='',
                            Precious_Metals__c='',
                            ShippingStreet='',
                            ShippingCity='',
                            ShippingPostalCode='',
                            ShippingState='',
                            ShippingCountry='US',
                            AccountNumber='24000'));

        accounts.add(new Account(  
                            Name='STMICROELECTRONICS COMPANY',
                            Customer_Group__c='',
                            Incoterms_1__c='',
                            Incoterms_2__c='',
                            Currency__c='',
                            Payment_Terms__c='',
                            Sales_Region__c='',
                            T_Stock_Flag__c='',
                            Reject_Billing__c='',
                            Precious_Metals__c='',
                            ShippingStreet='',
                            ShippingCity='',
                            ShippingPostalCode='',
                            ShippingState='',
                            ShippingCountry='US',
                            AccountNumber='26000'));

        accounts.add(new Account(  
                            Name='TEXAS INSTRUMENTS INCORPORATED',
                            Customer_Group__c='',
                            Incoterms_1__c='',
                            Incoterms_2__c='',
                            Currency__c='',
                            Payment_Terms__c='',
                            Sales_Region__c='',
                            T_Stock_Flag__c='',
                            Reject_Billing__c='',
                            Precious_Metals__c='',
                            ShippingStreet='',
                            ShippingCity='',
                            ShippingPostalCode='',
                            ShippingState='',
                            ShippingCountry='US',
                            AccountNumber='27000'));

        accounts.add(new Account(  
                            Name='LSI CORPORATION',
                            Customer_Group__c='',
                            Incoterms_1__c='',
                            Incoterms_2__c='',
                            Currency__c='',
                            Payment_Terms__c='',
                            Sales_Region__c='',
                            T_Stock_Flag__c='',
                            Reject_Billing__c='',
                            Precious_Metals__c='',
                            ShippingStreet='',
                            ShippingCity='',
                            ShippingPostalCode='',
                            ShippingState='',
                            ShippingCountry='US',
                            AccountNumber='40000'));

        accounts.add(new Account(  
                            Name='MINDSPEED TECHNOLOGIES',
                            Customer_Group__c='',
                            Incoterms_1__c='',
                            Incoterms_2__c='',
                            Currency__c='',
                            Payment_Terms__c='',
                            Sales_Region__c='',
                            T_Stock_Flag__c='',
                            Reject_Billing__c='',
                            Precious_Metals__c='',
                            ShippingStreet='',
                            ShippingCity='',
                            ShippingPostalCode='',
                            ShippingState='',
                            ShippingCountry='',
                            AccountNumber='41001'));

        accounts.add(new Account(  
                            Name='MICROCHIP TECHNOLOGY INC.',
                            Customer_Group__c='',
                            Incoterms_1__c='',
                            Incoterms_2__c='',
                            Currency__c='',
                            Payment_Terms__c='',
                            Sales_Region__c='',
                            T_Stock_Flag__c='',
                            Reject_Billing__c='',
                            Precious_Metals__c='',
                            ShippingStreet='',
                            ShippingCity='',
                            ShippingPostalCode='',
                            ShippingState='',
                            ShippingCountry='TH',
                            AccountNumber='42000'));

        accounts.add(new Account(  
                            Name='INTEL CORPORATION',
                            Customer_Group__c='',
                            Incoterms_1__c='',
                            Incoterms_2__c='',
                            Currency__c='',
                            Payment_Terms__c='',
                            Sales_Region__c='',
                            T_Stock_Flag__c='',
                            Reject_Billing__c='',
                            Precious_Metals__c='',
                            ShippingStreet='',
                            ShippingCity='',
                            ShippingPostalCode='',
                            ShippingState='',
                            ShippingCountry='DK',
                            AccountNumber='49000'));

        accounts.add(new Account(  
                            Name='BROADCOM CORPORATION',
                            Customer_Group__c='',
                            Incoterms_1__c='',
                            Incoterms_2__c='',
                            Currency__c='',
                            Payment_Terms__c='',
                            Sales_Region__c='',
                            T_Stock_Flag__c='',
                            Reject_Billing__c='',
                            Precious_Metals__c='',
                            ShippingStreet='',
                            ShippingCity='',
                            ShippingPostalCode='',
                            ShippingState='',
                            ShippingCountry='SG',
                            AccountNumber='52000'));

        accounts.add(new Account(  
                            Name='MARVELL TECHNOLOGY GROUP',
                            Customer_Group__c='',
                            Incoterms_1__c='',
                            Incoterms_2__c='',
                            Currency__c='',
                            Payment_Terms__c='',
                            Sales_Region__c='',
                            T_Stock_Flag__c='',
                            Reject_Billing__c='',
                            Precious_Metals__c='',
                            ShippingStreet='',
                            ShippingCity='',
                            ShippingPostalCode='',
                            ShippingState='',
                            ShippingCountry='SG',
                            AccountNumber='56000'));

        accounts.add(new Account(  
                            Name='ON SEMICONDUCTOR',
                            Customer_Group__c='',
                            Incoterms_1__c='',
                            Incoterms_2__c='',
                            Currency__c='',
                            Payment_Terms__c='',
                            Sales_Region__c='',
                            T_Stock_Flag__c='',
                            Reject_Billing__c='',
                            Precious_Metals__c='',
                            ShippingStreet='',
                            ShippingCity='',
                            ShippingPostalCode='',
                            ShippingState='',
                            ShippingCountry='US',
                            AccountNumber='58000'));

        accounts.add(new Account(  
                            Name='SONY CORPORATION OF AMERICA',
                            Customer_Group__c='',
                            Incoterms_1__c='',
                            Incoterms_2__c='',
                            Currency__c='',
                            Payment_Terms__c='',
                            Sales_Region__c='',
                            T_Stock_Flag__c='',
                            Reject_Billing__c='',
                            Precious_Metals__c='',
                            ShippingStreet='',
                            ShippingCity='',
                            ShippingPostalCode='',
                            ShippingState='',
                            ShippingCountry='HK',
                            AccountNumber='57000'));
     	if(test.isRunningTest()){
            for(Account acc:accounts){
                acc.Sales_Region__c = 'Korea';
            }
        } 
        
        insert accounts;
        
       // update accounts;
       
        Map<String,Account> numIdMap = new Map<String,Account>();
        
        for(Account ac : accounts){
            numIdMap.put(ac.AccountNumber,ac);
        }
        
        for(String child : parentLink.keySet()) {
        
            Account childAccount = numIdMap.get(child);
            String parentNumber = parentLink.get(child);
            Account parent = numIdmap.get(parentNumber);
           
            try {
            
                childAccount.ParentId = parent.Id;
            } catch(Exception e){ system.debug('PARENT: ' + parentNumber + ' CHILD: ' + child); }
          
           
            
        }
        update accounts;
        
    }
    
}