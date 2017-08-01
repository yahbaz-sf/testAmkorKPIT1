/*************************************************************************
* 
* PURPOSE:  this class seeds fresh RFQ Item Field Definition data in fresh 
*           environments RFQAdminInstaller. This data is used by the
*           RFQItem.page to determine layouts/sections for fields
*         
* CLASS: RFQAdminInstaller
* CREATED: 03/12/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Jason Swenski
* 
**************************************************************************/
global class RFQAdminInstaller {
        
    global static void cleanAndInstallTest() {
        clean();
        install();
        FCCSPInstaller.install();
        FCCOCInstaller.install();
    }   
 
   /**
    * This method installs field definition and sections 
    * Into clean environments
    */
    global static void install() {
        

        installFieldDefinitions();
        installSections();
        incrementalInstallAMK1385();
        AMK1468();
        AMK1578();
        AMK1563();        
        //EngineeringServiceInstaller.installServiceSection();            
    }
    
    /**
    * This method cleans up all field definitions and
    * sections. Dangerous, don't use in customer environments
    * unless you know what you are doing
    */
    global static void clean() {
       
        List<RFQI_Field_Def__c> fieldDefs = [select Id from RFQI_Field_Def__c];
        if(fieldDefs.size() > 0) { delete fieldDefs; }
        
        
        List<RFQI_Section__c> sections = [select Id from RFQI_Section__c];
        if(sections.size() > 0) { delete sections; } 
        
        //cleanAccounts();
        //cleanFactories();
    }
    
    global static void cleanData()
    {
        List<RFQ__c> rfqList = [Select id from RFQ__c];
        delete rfqList;
        
        List<RFQ_Item__c> itemList = [Select id from RFQ_Item__c];
        delete itemList;
        
        List<Product_Group__c> pgList = [Select id from Product_Group__c];
        delete pgList;
        
        List<RFQI_Default_Driver__c> ddList = [Select id from RFQI_Default_Driver__c];
        delete ddList;
        
        cleanAccounts();
        cleanFactories(); 
        
        
    }
    
    global static void cleanAccounts() {
        List<Account> accounts = [select Id from Account];
        delete accounts;
    }
    
    global static void cleanFactories() {
        List<Factory__c> factories = [select Id from Factory__c];
        delete factories;
    }
    
    global static void installRFQSystemSettings(){
        RFQ_System_Settings__c RFQSS = RFQ_System_Settings__c.getOrgDefaults();
        if (RFQSS.Id == null)
        {
            RFQSS.BU_Pricer_Profile__c = 'BU Pricer';
            RFQSS.Sales_Management_Profile__c = 'Sales Management';
            RFQSS.Sales_Team_Profile__c = 'Sales Team';
            insert RFQSS;
        }
        
    }
    
    global static List<Factory__c> installFactories() {
        
        List<Factory__c> factories = new List<Factory__c>();
        

        //FIXME Disabling for purposes of importing data, for now
        //factories.add(new Factory__c(Name='ATP1', Package_Family__c = 'SOIC'));
        
        factories.add(new Factory__c(Name='K1',Package_Family__c='PBGA'));
        factories.add(new Factory__c(Name='K3',Package_Family__c='PBGA'));
        factories.add(new Factory__c(Name='K4',Package_Family__c='PBGA'));
        factories.add(new Factory__c(Name='P1',Package_Family__c='PBGA'));
        factories.add(new Factory__c(Name='P3',Package_Family__c='PBGA'));
        factories.add(new Factory__c(Name='T1',Package_Family__c='PBGA'));
        factories.add(new Factory__c(Name='T3',Package_Family__c='PBGA'));
        factories.add(new Factory__c(Name='T5',Package_Family__c='PBGA'));
        factories.add(new Factory__c(Name='C3',Package_Family__c='PBGA'));
        factories.add(new Factory__c(Name='J1',Package_Family__c='PBGA'));
        
        try {
            insert factories;
        }catch(Exception e) {
            system.debug('Could not install Factories: ' + e);
        }
        
        return factories;
        
    }
    
    
    global static void installAccounts() {
        
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

    global static void installAccountPGSettingsDualLeadframe()
    {
        List<Account_PG_Setting__c> acctPG = new List<Account_PG_Setting__c>();
        List<Product_Group__c> pgList = [select Id, name from Product_Group__c where name='Dual Leadframe'];
        String pgId = (pgList == null || pgList.size() == 0) ? '' : pgList.get(0).Id;

        List<Account> acctList = [select Id, name from Account];

        Map<String, String> acctMap = new Map<String, String>();

        for(Account row : acctList) acctMap.put(row.name, row.Id);

        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('ANALOG DEV. PHILIPPINES'), tier__c=Double.valueOf('1'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('ANALOG DEVICES B.V.'), tier__c=Double.valueOf('1'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('ANALOG DEVICES GEN TRIAS'), tier__c=Double.valueOf('1'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('ANALOG DEVICES INC.'), tier__c=Double.valueOf('1'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('ANALOG DEVICES INTERNATIONAL'), tier__c=Double.valueOf('1'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('ANALOG DEVICES INTERNATIONAL'), tier__c=Double.valueOf('1'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('ANALOG DEVICES, INC.'), tier__c=Double.valueOf('1'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('ALTERA CORPORATION'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('ALTERA CORPORATION (M) SD'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('ALTERA CORPORATION, INC.'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('AMIC TECHNOLOGY CORPORATION'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('AMIC TECHNOLOGY CORPORATION'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('AMS AG'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('AMS INTERNATIONAL AG'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('AUSTRIAMICROSYSTEMS AG'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('ATMEL AUTOMOTIVE GMBH'), tier__c=Double.valueOf('1'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('ATMEL CORPORATION - CO'), tier__c=Double.valueOf('1'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('ATMEL CORPORATION-SJ'), tier__c=Double.valueOf('1'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('ATMEL NANTES SA'), tier__c=Double.valueOf('1'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('ATMEL ROUSSET SAS'), tier__c=Double.valueOf('1'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('ATMEL TRADING COMPANY LTD.'), tier__c=Double.valueOf('1'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('ATMEL TRADING COMPANY LTD.'), tier__c=Double.valueOf('1'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('ATMEL TRADING COMPANY, LTD.'), tier__c=Double.valueOf('1'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('ATMEL TRADING COMPANY, LTD.'), tier__c=Double.valueOf('1'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('ATMEL TRADING COMPANY, LTD.'), tier__c=Double.valueOf('1'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('ATMEL TRADING COMPANY, LTD.'), tier__c=Double.valueOf('1'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('ATMEL TRADING COMPANY, LTD.'), tier__c=Double.valueOf('1'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('ATMEL TRADING COMPANY, LTD.'), tier__c=Double.valueOf('1'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('ATMEL TRADING COMPANY, LTD.'), tier__c=Double.valueOf('1'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('TSPC CORPORATION,  MN'), tier__c=Double.valueOf('1'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('ROBERT BOSCH G.M.B.H.'), tier__c=Double.valueOf('2'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('ROBERT BOSCH GMBH'), tier__c=Double.valueOf('2'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('ROBERT BOSCH INC.'), tier__c=Double.valueOf('2'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('BRILLIANCE SEMICONDUCTOR INC'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('BRILLIANCE SEMICONDUCTOR, INC.'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('BROADCOM CORPORATION'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('BROADCOM CORPORATION'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('BROADCOM CORPORATION'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('BROADCOM SINGAPORE PTE LTD'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('CIRRUS LOGIC'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('CIRRUS LOGIC, INC.'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('CONEXANT SYSTEMS, INC.'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('CONEXANT-CA'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('CONEXANT-FL'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('CONEXANT-NJ'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('AUTHENTEC'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('CORE COMPANY'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('CORE COMPANY'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('CORE COMPANY INC'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('CORE ISRAEL LTD'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('CYPRESS SEMICONDUCTOR'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('CYPRESS SEMICONDUCTOR CORPORATION'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('DELPHI CORPORATION'), tier__c=Double.valueOf('2'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('GENERAL MOTORS COMPONENTS HOLDINGS, LLC'), tier__c=Double.valueOf('2'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('EVERSPIN TECHNOLOGIES INC.'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('EVERSPIN TECHNOLOGIES PARENT'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('FAIRCHILD SEMI (M)SDN BHD'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('FAIRCHILD SEMICONDUCTOR CORPORATION'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('FAIRCHILD SEMICONDUCTOR CORPORATION'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('FAIRCHILD SEMICONDUCTOR INC.'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('FAIRCHILD SEMICONDUCTOR PORTLAND'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('FAIRCHILD SEMICONDUCTOR PTE LTD'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('FAIRCHILD SEMICONDUCTOR PTE LTD'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('FAIRCHILD SEMICONDUCTOR PTE LTD'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('FRONTIER SILICON LTD.'), tier__c=Double.valueOf('2'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('FRONTIER SILICON LTD.'), tier__c=Double.valueOf('2'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('FUJITSU MICROELECTRONICS'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('FUJITSU MICROELECTRONICS'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('FUJITSU MICROELECTRONICS LIMITED'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('FUJITSU SEMICONDUCTOR PACIFIC ASIA'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('FUJITSU SEMICONDUTOR WIRELESS PRODU'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('SUMITOMO ELECTRIC DEVICE'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('GLOBAL FOUNDRIES DRESDEN MODULE ONE'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('GLOBAL FOUNDRIES INC.'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('GLOBALFOUNDRIES MALTA'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('GLOBALFOUNDRIES SILICON PARTNERS PTE LTD'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('GLOBALFOUNDRIES SINGAPORE PTE LTD'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('GLOBALFOUNDRIES SINGAPORE TAMPINES PTE LTD'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('GLOBALFOUNDRIES US INC'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('SILICON MANUFACTURING PARTNERS PTE'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('I.C. HAUS G.M.B.H.'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('IC HAUS GMBH'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('IDT  SINGAPORE PTE LTD'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('IDT MALAYSIA SND. BHD. MALAYSIA SND. BHD.'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('IDT, INC.'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('INTEGRATED DEVICE TECHNOLOGY, INC.'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('INSIDE SECURE'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('INSIDE SECURE PARENT'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('VAULT IC FRANCE'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('IMC GMBH'), tier__c=Double.valueOf('2'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('INTEL CORPORATION'), tier__c=Double.valueOf('2'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('INTEL CORPORATION'), tier__c=Double.valueOf('2'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('INTEL CORPORATION'), tier__c=Double.valueOf('2'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('INTEL ISRAEL 74 LTD.'), tier__c=Double.valueOf('2'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('INTEL MOBILE COMMUNICATIONS'), tier__c=Double.valueOf('2'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('INTEL MOBILE COMMUNICATIONS GMBH'), tier__c=Double.valueOf('2'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('INTEL MOBILE COMMUNICATIONS GMBH PA'), tier__c=Double.valueOf('2'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('INTEL PRODUCTS (CHENGDU) LTD.'), tier__c=Double.valueOf('2'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('INTERSIL CORPORATION'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('INTERSIL CORPORATION'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('INTERSIL INT\'L OPERATIONS SDN. BHD.'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('LATTICE SEMICONDUCTOR CORPORATION'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('LATTICE SEMICONDUCTOR LIMITED'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('LINEAR TECHNOLOGY'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('LINEAR TECHNOLOGY'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('LSI CORPORATION'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('LSI LOGIC SINGAPORE'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('LSI LOGIC SINGAPORE PTE. LTD.'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('LSI TECHNOLOGY (SINGAPORE) PTE LTD'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('MAXIM DALLAS TERIDIAN'), tier__c=Double.valueOf('2'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('MAXIM INTEGRATED PRODUCTS'), tier__c=Double.valueOf('2'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('MAXIM INTEGRATED PRODUCTS'), tier__c=Double.valueOf('2'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('MAXIM INTEGRATED PRODUCTS'), tier__c=Double.valueOf('2'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('MAXIM INTEGRATED PRODUCTS'), tier__c=Double.valueOf('2'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('MELEXIS BULGARIA'), tier__c=Double.valueOf('2'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('MELEXIS G.M.B.H.'), tier__c=Double.valueOf('2'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('MELEXIS MICROELECTRONIC SYSTEMS'), tier__c=Double.valueOf('2'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('MELEXIS N.V.'), tier__c=Double.valueOf('2'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('MELEXIS TECHNOLOGIES NV'), tier__c=Double.valueOf('2'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('MELEXIS TECHNOLOGIES SA'), tier__c=Double.valueOf('2'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('MICREL, INC.'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('MICREL, INC.'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('MICROCHIP TECHNOLO INC.'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('MICROCHIP TECHNOLOGY (THAILAND)'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('MICROCHIP TECHNOLOGY INC.'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('MICROCHIP TECHNOLOGY THAILAND CO.'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('MICROCHIP TECHNOLOGY THAILAND CO. LTD'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('MICRON SEMICONDUCTOR ASIA (PTE) LIMITED'), tier__c=Double.valueOf('2'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('MICRON SEMICONDUCTOR ASIA (PTE) LIMITED'), tier__c=Double.valueOf('2'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('MICRON SEMICONDUCTOR ASIA (PTE) LIMITED'), tier__c=Double.valueOf('2'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('MICRON SEMICONDUCTOR ASIA PTE LTD'), tier__c=Double.valueOf('2'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('MICRON TECHNOLOGY, INC.'), tier__c=Double.valueOf('2'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('MICRON TECHNOLOGY, INC.'), tier__c=Double.valueOf('2'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('MICRON TECHNOLOGY, INC.'), tier__c=Double.valueOf('2'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('MICROSEMI CORPORATION'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('MICROSEMI MANILA PHILIPPINES, INC'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('MICROSEMI SEMICONDUCTOR'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('MICROSEMI SEMICONDUCTOR CORP'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('MICROSEMI SoC CORP'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('MIN XIN TECHNOLOGY (H.K.) ELEC'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('MIN XIN TECHNOLOGY CORP.'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('NX-AI-AUTO'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('NX-AI-CAR'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('NX-HOM-AVS'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('NX-HOM-DVS'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('NX-HOM-STB'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('NX-HOM-TVF'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('NX-MMS-AMS'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('NX-MMS-GA'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('NX-MMS-LOG'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('NX-MMS-SIC'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('NX-MMS-SSL'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('NX-MP-SS'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('NXP SEMI (THAILAND) LTD'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('NXP SEMI CABUYAO INC.'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('NXP SEMI GERMANY GMBH'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('NXP SEMI SWITZERLAND AG'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('NXP SEMI TAIWAN LTD'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('NXP SEMI UK LTD'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('NXP SEMI USA  INC'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('NXP SEMICONDUCTORS'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('NXP SEMICONDUCTORS AUSTRIA GMBH'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('NXP SEMICONDUCTORS B.V.'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('NXP SEMICONDUCTORS FRANCE SAS'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('PHILIPS SEMICONDUCTOR'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('FUJI'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('OMACHI FUJI CO.  LTD'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('OMACHI FUJI CO., LTD.'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('ON CFPG EUR'), tier__c=Double.valueOf('2'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('ON CFPG US'), tier__c=Double.valueOf('2'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('ON CFPG US'), tier__c=Double.valueOf('2'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('ON SEMI CZECH DESIGN CTR'), tier__c=Double.valueOf('2'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('ON SEMI SLOVAKIA  A.S.'), tier__c=Double.valueOf('2'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('ON SEMICONDUCTOR'), tier__c=Double.valueOf('2'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('ON SEMICONDUCTOR BELGIUM BVBA'), tier__c=Double.valueOf('2'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('ON SEMICONDUCTOR CANADA'), tier__c=Double.valueOf('2'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('ON SEMICONDUCTOR FRANCE  SAS'), tier__c=Double.valueOf('2'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('ON SEMICONDUCTOR IRELAND'), tier__c=Double.valueOf('2'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('ON SEMICONDUCTOR PHILLIP'), tier__c=Double.valueOf('2'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('ON SEMICONDUCTOR TRADING'), tier__c=Double.valueOf('2'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('ON SEMICONDUCTOR TRADING'), tier__c=Double.valueOf('2'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('ON SEMICONDUCTOR TRADING JAPAN'), tier__c=Double.valueOf('2'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('ON SEMICONDUCTOR TRADING LTD'), tier__c=Double.valueOf('2'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('ON-EG'), tier__c=Double.valueOf('2'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('SCI LLC'), tier__c=Double.valueOf('2'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('PRACTICAL COMPONENTS INC.'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('PRACTICAL COMPONENTS, INC.'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('RENESAS ELECTRONICS CORPORATION'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('RENESAS HITACHI'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('RENESAS KOMORO'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('RENESAS MITSUBISHI'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('RENESAS TAKASAKI'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('RENESAS-NEC'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('RENESAS-SAMPLE'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('R.F. MICRO DEVICES'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('R.F. MICRO DEVICES'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('RF MICRO DEVICES BEIJING CO. LTD. N'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('RF MICRO DEVICES, INC.'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('ROHM CO. LTD'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('ROHM CO. LTD PARENT'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('ROHM ELECTRONICS PHILIPPINES, INC.'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('SANY ELECTRIC CO., LTD.'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('SANYO LSI ELECTR. CO., LTD.'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('SANYO MEMORY DIV'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('SANYO-GUNMA'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('SAMSUNG ELECTRO-MECHANICS'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('SAMSUNG ELECTRONICS, CO. LTD'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('SAMSUNG ELECTRONICS, CO. LTD.'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('SAMSUNG SEMICONDUCTOR'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('SAMSUNG-TECH'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('SEC - SAMSUNG'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('SILICON IMAGE'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('SILICON IMAGE INT\'L. B.V.'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('SKYWORKS GLOBAL PTE LTD'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('SKYWORKS LUXEMBOURGE (MEXICALI)'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('SKYWORKS SOLUTIONS, INC.'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('SKYWORKS SOLUTIONS, INC.'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('SMSC HONG KONG'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('STANDARD MICROSYSTEM CORPORATION'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('STANDARD MICROSYSTEMS CORPORATION'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('STANDARD MICROSYSTEMS CORPORATION'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('ALCHIP TECHNOLOGIES INC'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('SCK FAB'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('SONY CORPORATION OF AMERICA'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('SONY ERICSSON MOBILE'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('SONY ERICSSON MOBILE COMMUNICATIONS'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('SONY ERICSSON MOBILE USA'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('SONY NAGASAKI - SCE'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('SONY SEMICONDUCTOR KYUSUY'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('SONY-OITA'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('SPANSION LLC'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('SPANSION LLC'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('ST MICROELECTRONICS'), tier__c=Double.valueOf('1'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('ST MICROELECTRONICS PTE'), tier__c=Double.valueOf('1'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('STE-ASIA PACIFIC - ENG'), tier__c=Double.valueOf('1'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('ST-ERICSSON (France) SAS'), tier__c=Double.valueOf('1'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('ST-ERICSSON ASIA PACIFIC PTE LTD'), tier__c=Double.valueOf('1'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('ST-ERICSSON-USA'), tier__c=Double.valueOf('1'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('STMICROELECTRONICS (CROLLES 2) SAS'), tier__c=Double.valueOf('1'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('STMICROELECTRONICS COMPANY'), tier__c=Double.valueOf('1'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('STMICROELECTRONICS PTE'), tier__c=Double.valueOf('1'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('STMICROELECTRONICS PTE'), tier__c=Double.valueOf('1'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('STMICROELECTRONICS PTE LTD IPD DIVISION'), tier__c=Double.valueOf('1'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('STMICROELECTRONICS PTE LTD MMS DIVISION'), tier__c=Double.valueOf('1'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('STMICROELECTRONICS PTE LTD MPG DIVISION'), tier__c=Double.valueOf('1'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('STMICROELECTRONICS PTE LTD NVG DIVISION'), tier__c=Double.valueOf('1'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('ST-STM-ENG'), tier__c=Double.valueOf('1'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('T I PHILIPPINES'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('TEXAS INSTRUMENTS'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('TEXAS INSTRUMENTS  INC.'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('TEXAS INSTRUMENTS (INDIA)'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('TEXAS INSTRUMENTS DEUTSCHLAND, G.M.B.H.'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('TEXAS INSTRUMENTS ELECTRONICS MALAYSIA SDN BHD'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('TEXAS INSTRUMENTS FRANCE'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('TEXAS INSTRUMENTS INCORP.'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('TEXAS INSTRUMENTS INCORPORATED'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('TEXAS INSTRUMENTS JAPAN'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('TEXAS INSTRUMENTS UK LIMITED'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('TEXAS INSTRUMENTS,  INC.'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('TEXAS INSTRUMENTS, INC.'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('TEXAS INSTRUMENTS, INC.'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('TI (PHIL), INC. TURNKEY'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('TI (PHILIPPINES)  INC'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('TI (PHILIPPINES)  INC.'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('TI MIHO'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('TI TAIWAN'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('TI TAIWAN'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('TI USA'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('TOKO  INC. SEMICOND.DIV.'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('TOKO INC.'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('TOSHIBA AMERICA, INC.'), tier__c=Double.valueOf('1'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('TOSHIBA CORPORATION'), tier__c=Double.valueOf('1'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('TOSHIBA CORPORATION & SEMICONDUCTOR & STORAGE PRODUCTS COMPANY OITA'), tier__c=Double.valueOf('1'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('TOSHIBA HIMEJI'), tier__c=Double.valueOf('1'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('TOSHIBA IWATE'), tier__c=Double.valueOf('1'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('TOSHIBA IWATE AIC'), tier__c=Double.valueOf('1'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('TOSHIBA LSI'), tier__c=Double.valueOf('1'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('TOSHIBA OITA'), tier__c=Double.valueOf('1'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('TOSHIBA SHANGHAI'), tier__c=Double.valueOf('1'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('TOSHIBA TRADING INCORPORATED'), tier__c=Double.valueOf('1'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('TPACS'), tier__c=Double.valueOf('1'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('SILICONIX SINGAPORE PTE LTD'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('VISHAY INTERTECHNOLOGY ASIA PTE LTD'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('VITESSE SEMICONDUCTOR CO.'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('VITESSE SEMICONDUCTOR CO.'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('XILINX ASIA PACIFIC PTE LTD.'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('XILINX IRELAND'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('XILINX, INC.'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('XILINX, INC.'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('ZMD AG'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));
        acctPG.add(new Account_PG_Setting__c(Account__c = acctMap.get('ZMD AG'), tier__c=Double.valueOf('3'), Product_Group__c=pgId));


        insert acctPG;
    }
    
    
    private static List<RFQI_Field_Def__c> installFieldDefinitions() {
        
        List<RFQI_Field_Def__c> defs = new List<RFQI_Field_Def__c>();
        
        //AMK-238 Adding costing/price fields
        defs.add(new RFQI_Field_Def__c(Name = 'CLAM_Direct_Labor__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Materials_Leadframe__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'BU_Price_Perc_GM__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'CLAM_Indirect_Labor__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Materials_Total_Wire__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'CLAM_Depreciation__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Materials_ODM__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'BU_Price_Perc_Delta_To_Target__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'CLAM_Facilities__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Materials_Subtotal__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Manufacturing_Overhead__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Materials_As_Perc_Cost__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Total_Cost__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'QA_Cost__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Variable_Costs__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Service_Group_Cost__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Adder_Cost__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Fixed_Costs__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Au_Price_Used__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'CLAM_Labor__c'));
        
        //Cost model attributes for PBGA
        //defs.add(new RFQI_Field_Def__c(Name = 'Materials_Subs__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Materials_Substrate__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'CLAM_WB__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Materials_Wire__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'CLAM_Others__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Materials_ODM_Other__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'CLAM_Total__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Total_Materials__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Cost_less_Substrate_New__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Total_Cost_with_Substrate_New__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Package_Item_Value__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Solderballs__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'CLAM_Mold__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'EMC__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'CLAM_Die_Attach__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'CLAM_Solderball_attach__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Tray__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'CLAM_S_G__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'CLAM_Marking__c'));
        //defs.add(new RFQI_Field_Def__c(Name = 'Passives__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Subs_Markup_Perc__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Assembly_GM_wo_Substrate__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Total_Perc_GM__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'CLAM_OCOGS__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Perc_IRR_New__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Perc_VAM_New__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'X1st_Capacitor_Cost_K__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'X2nd_Capacitor_Cost_K__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'CLAM_OH__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Model_UE_Perc__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'CLAM_Subtotal__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'CLAM_Subtotal_New__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Operating_Cash_u__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Perc_CM__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Materials_ODM_Mold__c'));
                
        defs.add(new RFQI_Field_Def__c(Name = 'Apply_3D_Factor__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Assembly__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Base_Customer_Au_Price__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Capacity_UE_Rate__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Complex_Adder__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'LGP_Market_Price__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Mold_Wastage__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Substrate_Perc_Markup__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Substrate_Unit__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Substrate_Waste__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Materials_Laminate__c'));
        
        //Cost Model addtributes for Test
        defs.add(new RFQI_Field_Def__c(Name = 'Tester_Price__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Unit_Cost_CLAM__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Cost_Sec_CLAM__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Total_GM_Perc__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Handler_Prober_Price__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Unit_Cost_Material__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Cost_Sec_Labor__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Target_IRR_at_GM__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Other_Equipment_Cost__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Unit_Cost_Labor__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Cost_sec_Depreciation__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Payback__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Tax_and_Freight_Cost__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Unit_Cost_Depreciation__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Cost_sec_Other__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Weekly_Revenue_Setup__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Unit_Cost_Other__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Total_Cost_per_Hour__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Monthly_Revenue_Setup__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Total_Unit_Cost__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Total_Cost_per_minute__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Unit_Cost_Other__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Total_Cost_per_Hour__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Monthly_Revenue_Setup__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Materials_Substrate__c'));
        
        //Cost Model attributes for WLFO        
        defs.add(new RFQI_Field_Def__c(Name = 'Materials_Bumping__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Materials_Assembly__c'));
        

        //Cost & Price section for Bump
        defs.add(new RFQI_Field_Def__c(Name = 'Materials_Total__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Variable_Costs_Total__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Depreciation__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Total_Fixed_Costs__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Cost_Data_Source__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'BU_Margin__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Contribution_Margin_Perc__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Gross_Margin_Perc__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Guildlline_Price_500__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Guildlline_Price_1500__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Guildlline_Price_GT_1500__c'));
        

        //AMK-238 adding additional fields for dynamic headers in visualforce item pages
        defs.add(new RFQI_Field_Def__c(Name = 'Au_Inclusive__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'RFQ_Item__r.Status__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'RFQ_Item__r.Service__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'RFQ_Item__r.Customer_Tier__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'RFQ_Item__r.RFQ__r.RFQ_Name__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'RFQ_Item__r.RFQ__r.SBU_Name__r.AccountNumber'));
        defs.add(new RFQI_Field_Def__c(Name = 'RFQ_Item__r.RFQ__r.SBU_Name__r.Customer_AU_Base_fml__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'RFQ_Item__r.Package_Family__r.Name'));
        defs.add(new RFQI_Field_Def__c(Name = 'RFQ_Item__r.RFQ__r.SBU_Name__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'RFQ_Item__r.RFQ__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'RFQ_Item__r.OwnerId'));
        defs.add(new RFQI_Field_Def__c(Name = 'RGQ_Projected_Annual_Revenue__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'RFQ_Item__r.CreatedById'));

        //normal attributes
        
        defs.add(new RFQI_Field_Def__c(Name = 'Additional_Components_In_Package__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Amkor_Bumped__c',Object__c='Die', Type__c='Boolean'));
        defs.add(new RFQI_Field_Def__c(Name = 'Amkor_Purchased_Substrate__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Amkor_Standard_BS_Interposer_Processing__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Amkor_Tooling__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Annual_Volume__c'));        
        defs.add(new RFQI_Field_Def__c(Name = 'Assembly_Package_Name__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'ATE_Platform__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Au_Factor__c', Object__c='Wire', Type__c='Decimal'));
        defs.add(new RFQI_Field_Def__c(Name = 'Automotive__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Average_2D_Wire_Length__c', Object__c='Wire', Type__c='Decimal'));
        defs.add(new RFQI_Field_Def__c(Name = 'Backside_Coat__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Backgrind__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Backgrinding_Required__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Bake_Dry_Pack__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Bake__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Bake_Hours__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Bake_Temperature__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Ball_Count__c', Object__c='Package', Type__c = 'Decimal'));
        defs.add(new RFQI_Field_Def__c(Name = 'Ball_Composition__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Ball_Composition_2nd_Step__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Ball_Count_Range__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Ball_Lead_Count__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Ball_Pad_Pitch__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Ball_Pitch__c', Object__c='Package', Type__c = 'String'));
        defs.add(new RFQI_Field_Def__c(Name = 'Ball_Scan__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Ball_Size__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Ball_Type__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Ball_Wire_Size_Ration__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Base_Customer_Au_Price__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'BF_Pitch__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'BGA__c', Object__c='Package', Type__c = 'Decimal'));
        defs.add(new RFQI_Field_Def__c(Name = 'BGA_Ball_Composition__c', Object__c='Package', Type__c = 'String'));
        defs.add(new RFQI_Field_Def__c(Name = 'BGA_Count__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'BGA_IGA_Top_Surface_Finish__c', Object__c='Package', Type__c = 'String'));
        defs.add(new RFQI_Field_Def__c(Name = 'BGA_IGA_Bottom_Surface_Finish__c', Object__c='Package', Type__c = 'String'));
        defs.add(new RFQI_Field_Def__c(Name = 'BGA_IGA_Pad_Opening__c', Object__c='Package', Type__c = 'String'));
        defs.add(new RFQI_Field_Def__c(Name = 'BGA_IGA_Pad_Metal_Size__c', Object__c='Package', Type__c = 'String'));
        defs.add(new RFQI_Field_Def__c(Name = 'BGA_Pitch__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Binning__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Body_X__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Body_Y__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Body_Z__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Body_Size__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Body_Size_X__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Body_Size_Y__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Body_Size_Z__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Body_Size_X_Y_Z__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Body_Thickness__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Bump_Composition__c', Object__c='Package', Type__c = 'String'));
        defs.add(new RFQI_Field_Def__c(Name = 'Bond_Finger_Pitch__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Bond_Finger_Surface_Finish__c', Object__c='Package', Type__c = 'String'));
        defs.add(new RFQI_Field_Def__c(Name = 'Bond_Pad_Opening__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Bump_Height__c', Object__c='Die', Type__c = 'Decimal'));
        defs.add(new RFQI_Field_Def__c(Name = 'Bump_Pad_Opening_Size__c', Object__c='Die', Type__c = 'Decimal'));
        defs.add(new RFQI_Field_Def__c(Name = 'Bump_Pad_Metal_Size__c', Object__c='Die', Type__c = 'Decimal'));
        defs.add(new RFQI_Field_Def__c(Name = 'Bond_Pad_Pitch__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Bump_Pad_Pitch__c', Object__c='Die', Type__c = 'Decimal'));
        defs.add(new RFQI_Field_Def__c(Name = 'Bump_Pad_Plating_Surface_Finish__c', Object__c='Package', Type__c = 'String'));
        defs.add(new RFQI_Field_Def__c(Name = 'Bump_Pitch__c', Object__c='Package', Type__c = 'String'));
        defs.add(new RFQI_Field_Def__c(Name = 'Bump_Type__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'BU_Price__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Sales_BU_Price__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'BU_Price_Per_Hour__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'BU_Price_per_Minute__c'));        
        defs.add(new RFQI_Field_Def__c(Name = 'BU_Price_Unit__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Burn_In__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Burn_in_Hours__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Burn_in_Temperature__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Capacitance__c', Object__c='Passive', Type__c = 'Decimal'));
        defs.add(new RFQI_Field_Def__c(Name = 'Capacitors__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Capacity_UE_Rate__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Chip_Bump_Pitch__c', Object__c='Die', Type__c='Decimal'));
        defs.add(new RFQI_Field_Def__c(Name = 'Chip_is_Memory__c', Object__c='Die', Type__c='Boolean'));
        defs.add(new RFQI_Field_Def__c(Name = 'Chip_On_Chip_Process__c', Object__c='Die', Type__c='Boolean'));
        defs.add(new RFQI_Field_Def__c(Name = 'Chip_On_Wafer_Process__c', Object__c='Die', Type__c='Boolean'));
        defs.add(new RFQI_Field_Def__c(Name = 'Chip_Power_Dissipation__c', Object__c='Die', Type__c='String'));
        defs.add(new RFQI_Field_Def__c(Name = 'Chip_Size_X__c', Object__c='Die', Type__c='Decimal'));
        defs.add(new RFQI_Field_Def__c(Name = 'Chip_Size_Y__c', Object__c='Die', Type__c='Decimal'));
        defs.add(new RFQI_Field_Def__c(Name = 'Chips_per_Package__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Closest_Die_to_Die_Spacing__c', Object__c='Die', Type__c='String'));
        defs.add(new RFQI_Field_Def__c(Name = 'Competitor_Au_Inclusive_Price__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Competitor__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Competitor_BU__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Competitor_Price__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Consign_Tester__c', Object__c='Insertion', Type__c = 'String'));
        defs.add(new RFQI_Field_Def__c(Name = 'Consign_Handler__c', Object__c='Insertion', Type__c = 'String'));
        defs.add(new RFQI_Field_Def__c(Name = 'Copper_Thickness_Core__c', Object__c='Package', Type__c = 'Decimal'));
        defs.add(new RFQI_Field_Def__c(Name = 'Copper_Thickness_External__c', Object__c='Package', Type__c = 'Decimal'));
        defs.add(new RFQI_Field_Def__c(Name = 'Copper_Thickness_Internal__c', Object__c='Package', Type__c = 'Decimal'));
        defs.add(new RFQI_Field_Def__c(Name = 'Core_Material__c', Object__c='Package', Type__c = 'String'));
        defs.add(new RFQI_Field_Def__c(Name = 'Core_Thickness__c', Object__c='Package', Type__c = 'String'));
        defs.add(new RFQI_Field_Def__c(Name = 'Core_Type__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'CPU_Price_Hour__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'CPU_Price_Hour__c', Object__c='Insertion', Type__c = 'Decimal'));
        defs.add(new RFQI_Field_Def__c(Name = 'CPU_Price_Second__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'CPU_Price_Second__c', Object__c='Insertion', Type__c = 'Decimal'));
        defs.add(new RFQI_Field_Def__c(Name = 'CSP__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Customer_Device_Name__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Customer_Project_Name__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Customer_Target_Price__c'));        
        defs.add(new RFQI_Field_Def__c(Name = 'Dam_SM_Type__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Dam_SM_Height__c', Object__c='Package', Type__c='Decimal'));
        defs.add(new RFQI_Field_Def__c(Name = 'Dam_SM_Width__c', Object__c='Package', Type__c='Decimal'));
        defs.add(new RFQI_Field_Def__c(Name = 'Design_ss__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Design__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Device_Application__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Device_Description__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Device_or_Program__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Device_Package__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Device_Project_Name__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Dice__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Die_Attach__c', Object__c='Die', Type__c='String'));
        defs.add(new RFQI_Field_Def__c(Name = 'Die_Attach_Type__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Die_Bump_Comp__c', Object__c='Die', Type__c='String'));
        defs.add(new RFQI_Field_Def__c(Name = 'Die_Bump_Count__c', Object__c='Die', Type__c='Decimal'));
        defs.add(new RFQI_Field_Def__c(Name = 'Die_Bump_Pitch__c', Object__c='Die', Type__c='String'));
        defs.add(new RFQI_Field_Def__c(Name = 'Die_Bump_Type__c', Object__c='Die', Type__c='String'));
        defs.add(new RFQI_Field_Def__c(Name = 'Die_Coat__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Dielectric_Thickness__c', Object__c='Die', Type__c='Decimal'));
        defs.add(new RFQI_Field_Def__c(Name = 'Dielectric_Type__c', Object__c='Die', Type__c='String'));
        defs.add(new RFQI_Field_Def__c(Name = 'Die_per_Month__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Die_Pitch__c', Object__c='Die', Type__c='Decimal'));
        defs.add(new RFQI_Field_Def__c(Name = 'Die_Singulation_Type__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Die_Size__c', Object__c='Die', Type__c='Decimal'));
        defs.add(new RFQI_Field_Def__c(Name = 'Die_Size_X__c', Object__c='Die', Type__c='Decimal'));
        defs.add(new RFQI_Field_Def__c(Name = 'Die_Size_X_PK__c', Object__c='Package', Type__c='Decimal'));
        defs.add(new RFQI_Field_Def__c(Name = 'Die_Size_Y__c', Object__c='Die', Type__c='Decimal'));
        defs.add(new RFQI_Field_Def__c(Name = 'Die_Size_Y_PK__c', Object__c='Package', Type__c='Decimal'));
        defs.add(new RFQI_Field_Def__c(Name = 'Die_Size_Z__c', Object__c='Die', Type__c='Decimal'));
        defs.add(new RFQI_Field_Def__c(Name = 'Die_Size_X_Y__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Die_Spacing__c', Object__c='Die', Type__c='String'));
        defs.add(new RFQI_Field_Def__c(Name = 'Die_Thickness__c', Object__c='Die', Type__c='Decimal'));
        defs.add(new RFQI_Field_Def__c(Name = 'Die_to_Die_Bump_Count__c', Object__c='Die', Type__c='Decimal'));
        defs.add(new RFQI_Field_Def__c(Name = 'Die_to_Die_Capillary_Underfill__c', Object__c='Die', Type__c='Boolean'));
        defs.add(new RFQI_Field_Def__c(Name = 'Die_to_Die_Index_Time__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Die_to_Die_NCP_Underfill__c', Object__c='Die', Type__c='Boolean'));
        defs.add(new RFQI_Field_Def__c(Name = 'Die_to_Die_Standoff__c', Object__c='Die', Type__c='Decimal'));
        defs.add(new RFQI_Field_Def__c(Name = 'Die_1_Size_Dim_X__c', Object__c='Die', Type__c='Decimal'));
        defs.add(new RFQI_Field_Def__c(Name = 'Die_1_Size_Dim_Y__c', Object__c='Die', Type__c='Decimal'));
        defs.add(new RFQI_Field_Def__c(Name = 'Die_1_Thickness__c', Object__c='Die', Type__c='Decimal'));
        defs.add(new RFQI_Field_Def__c(Name = 'Die_Wafer__c', Object__c='Die', Type__c='Decimal'));
        defs.add(new RFQI_Field_Def__c(Name = 'Die_Yield__c', Object__c='Die', Type__c='Decimal'));
        defs.add(new RFQI_Field_Def__c(Name = 'DFP__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Dim_X__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Dim_Y__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Dimension_Inspection__c', Object__c='Package', Type__c='Boolean'));
        defs.add(new RFQI_Field_Def__c(Name = 'Dimension_Inspection_Sample__c', Object__c='Package', Type__c='Decimal'));
        defs.add(new RFQI_Field_Def__c(Name = 'DPW__c', Object__c='Die', Type__c='Decimal'));
        defs.add(new RFQI_Field_Def__c(Name = 'Drypack__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Dry_Polish__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Dual_Bumping__c', Object__c='Die', Type__c='Boolean'));
        defs.add(new RFQI_Field_Def__c(Name = 'EAR__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'End_Market_Segment__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Endline_OS_Test__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Expected_Lot_Size__c', Object__c='Die', Type__c='Decimal'));
        defs.add(new RFQI_Field_Def__c(Name = 'Expected_Revenue__c', Object__c='Package', Type__c='Decimal'));
        defs.add(new RFQI_Field_Def__c(Name = 'External_Finish__c', Object__c='Package', Type__c='String'));
        defs.add(new RFQI_Field_Def__c(Name = 'Factory__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Factory_Selection__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Factory_Selected__c', Object__c='Insertion', Type__c ='String'));
        defs.add(new RFQI_Field_Def__c(Name = 'FC_Bump_Pad_Pitch__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'FC_or_WB__c', Object__c='Die', Type__c='Boolean'));
        defs.add(new RFQI_Field_Def__c(Name = 'FF_Test__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Fiducial_Bottom_Surface_Finish__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Fiducial_Top_Surface_Finish__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'First_Pass_Yield_Target__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'First_Test_time_per_die__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'FIXED_Test_Time__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Forecast__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Frame_Finish__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'FT_Hardware_Required__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'FVI__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'FVI_100__c', Object__c='Package', Type__c='Boolean'));
        defs.add(new RFQI_Field_Def__c(Name = 'GaAs_Die_Adder__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'GDPW__c', Object__c='Die', Type__c='Decimal'));
        defs.add(new RFQI_Field_Def__c(Name = 'GDPW_PK__c', Object__c='Package', Type__c='Decimal'));
        defs.add(new RFQI_Field_Def__c(Name = 'Gross_Die_Per_Wafer__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Handler__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Handler__c', Object__c='Insertion', Type__c='String'));
        defs.add(new RFQI_Field_Def__c(Name = 'Handler_Owner__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Handler_Model__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Handler_Model__c', Object__c='Insertion', Type__c='String'));
        defs.add(new RFQI_Field_Def__c(Name = 'Has_Been_Quoted_Before__c', Object__c='Package', Type__c='Boolean'));
        defs.add(new RFQI_Field_Def__c(Name = 'Heatspreader__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'HS_Adhesive__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'HVP_Anticipated_Start_Date__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Incoming_Wafer_Yield__c', Object__c='Die', Type__c='Decimal'));
        defs.add(new RFQI_Field_Def__c(Name = 'Index_Time__c'));        
        defs.add(new RFQI_Field_Def__c(Name = 'Ink_Mark__c', Object__c='Package', Type__c='Boolean'));
        defs.add(new RFQI_Field_Def__c(Name = 'Inline_OS_Test__c', Object__c='Package', Type__c='Boolean'));        
        defs.add(new RFQI_Field_Def__c(Name = 'Inspect__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Inspect_2__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Interposer_BS_Bump_Comp__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Interposer_Bump_Count__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Interposer_Bump_Pitch__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Interposer_Or_Active_TSV_Wafer__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Interposer_Size_X__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Interposer_Size_Y__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Interposer_Supplier__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Interposer_TSV_Depth__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Interposer_TSV_Diameter__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Interposer_TSV_Material__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Interposer_Wafer_Size__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'ITAR__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Layer_Configuration__c', Object__c='Package', Type__c = 'String'));
        defs.add(new RFQI_Field_Def__c(Name = 'Layer_Count__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'layer_count__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Laser_Via_Capture_Pad_Diam__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Laser_Groove__c', Object__c='Die', Type__c='Boolean'));
        defs.add(new RFQI_Field_Def__c(Name = 'Laser_Via_Capture_Pad_Diam__c', Object__c='Package', Type__c = 'String'));
        defs.add(new RFQI_Field_Def__c(Name = 'Laser_Mark__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Lazer_Groove__c', Object__c='Die'));
        defs.add(new RFQI_Field_Def__c(Name = 'Leadframe_Config__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Leadframe_Finish__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Lead_Count__c', Object__c='Package', Type__c='Decimal'));
        defs.add(new RFQI_Field_Def__c(Name = 'Lead_Pitch__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Leadscan__c'));        
        defs.add(new RFQI_Field_Def__c(Name = 'LGP_Market_Price__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Lid__c', Object__c='Package', Type__c='Boolean'));
        defs.add(new RFQI_Field_Def__c(Name = 'Lid_Adhesive__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Lid_Attach_Type__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Lid_Finish__c', Object__c='Package', Type__c='String'));
        defs.add(new RFQI_Field_Def__c(Name = 'Lid_Material__c', Object__c='Package', Type__c='String'));
        defs.add(new RFQI_Field_Def__c(Name = 'Lid_TIM__c', Object__c='Package', Type__c='String'));
        defs.add(new RFQI_Field_Def__c(Name = 'Lid_Size_X__c', Object__c='Package', Type__c='Decimal'));
        defs.add(new RFQI_Field_Def__c(Name = 'Lid_Size_Y__c', Object__c='Package', Type__c='Decimal'));
        defs.add(new RFQI_Field_Def__c(Name = 'Lid_Thickness__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Line__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Line_and_Space_Buildup__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Line_and_Space_Core__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Line_and_Space_Inner__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Line_and_Space_Outer__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Line_and_Space__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Line_Space_Inner__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Line_Space_Outer__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Line_Space_External_Layers__c', Object__c='Package', Type__c='Decimal'));
        defs.add(new RFQI_Field_Def__c(Name = 'Line_Space_Internal_Layers__c', Object__c='Package', Type__c='Decimal'));
        defs.add(new RFQI_Field_Def__c(Name = 'Line_Space_Core_Layers__c', Object__c='Package', Type__c='Decimal'));
        defs.add(new RFQI_Field_Def__c(Name = 'Line_Widths_External_Layers__c', Object__c='Package', Type__c='Decimal'));
        defs.add(new RFQI_Field_Def__c(Name = 'Line_Widths_Internal_Layers__c', Object__c='Package', Type__c='Decimal'));
        defs.add(new RFQI_Field_Def__c(Name = 'Line_Widths_Core_Layers__c', Object__c='Package', Type__c='Decimal'));
        defs.add(new RFQI_Field_Def__c(Name = 'Mark__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Marking_Type__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Max_Die_Size__c', Object__c='Die'));
        defs.add(new RFQI_Field_Def__c(Name = 'Max_Die__c', Object__c='Die', Type__c = 'Decimal'));
        defs.add(new RFQI_Field_Def__c(Name = 'Max_Package_Thickness__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Max_package_Thickness__c', Object__c='Package', Type__c = 'Decimal'));
        defs.add(new RFQI_Field_Def__c(Name = 'MaxPackage_Thickness__c', Object__c='Package', Type__c = 'String'));
        defs.add(new RFQI_Field_Def__c(Name = 'Mech_Via_Capture_Pad_Diam__c', Object__c='Package', Type__c = 'String'));
        defs.add(new RFQI_Field_Def__c(Name = 'Metal_Finish__c', Object__c='Package', Type__c = 'String'));
        defs.add(new RFQI_Field_Def__c(Name = 'Minimum_Bond_Finger_Pitch__c', Object__c='Package', Type__c = 'String'));
        defs.add(new RFQI_Field_Def__c(Name = 'Minimum_Line_Inner__c', Object__c='Package', Type__c = 'String'));
        defs.add(new RFQI_Field_Def__c(Name = 'Minimum_Line_Outer__c', Object__c='Package', Type__c = 'String'));
        defs.add(new RFQI_Field_Def__c(Name = 'Minimum_Saw_Street_100_Microns__c', Object__c='Die', Type__c = 'Boolean'));
        defs.add(new RFQI_Field_Def__c(Name = 'Minimum_Space_Inner__c', Object__c='Package', Type__c = 'String'));
        defs.add(new RFQI_Field_Def__c(Name = 'Minimum_Space_Outer__c', Object__c='Package', Type__c = 'String'));
        defs.add(new RFQI_Field_Def__c(Name = 'Mech_Via_Capture_Pad_Diam__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'MEMS__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'MEMS_CAP__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Metal_Finish__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'MIC__c', Object__c='Insertion', Type__c = 'Decimal'));
        defs.add(new RFQI_Field_Def__c(Name = 'Min_MSL_Requirement__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Min_RDL_Line_and_Space__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Misc__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Misc_ide__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Mold_Compound__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Mold_Process_Type__c', Object__c='Package', Type__c = 'String'));
        defs.add(new RFQI_Field_Def__c(Name = 'Mold_Type__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'MSF__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'MSM_or_Single__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'MCM_or_Stacked__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'New_Business__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Number_of_BGA_Balls__c', Object__c='Package', Type__c='Decimal'));
        defs.add(new RFQI_Field_Def__c(Name = 'Number_of_Bumps__c', Object__c='Die', Type__c='Decimal'));
        defs.add(new RFQI_Field_Def__c(Name = 'Number_of_Chips_per_Package__c', Object__c='Package', Type__c='Decimal'));
        defs.add(new RFQI_Field_Def__c(Name = 'Number_Of_Die__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Number_of_Insertions__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Number_of_Laser_Vias__c', Object__c='Package', Type__c = 'Decimal'));
        defs.add(new RFQI_Field_Def__c(Name = 'Number_of_Layers__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Number_of_Layers_Buildup__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Number_of_Layers_Core__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Number_of_Lazer_Vias__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Number_of_Mech_Vias__c', Object__c='Package', Type__c = 'Decimal'));
        //defs.add(new RFQI_Field_Def__c(Name = 'Number_of_Passives__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Number_of_Passives__c', Object__c='Passive', Type__c = 'Decimal'));
        defs.add(new RFQI_Field_Def__c(Name = 'Number_Of_RDL_Layers__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Number_of_Sites__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Number_of_Sites_in_Parallel__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Number_of_Sites_in_Parallel__c', Object__c='Insertion', Type__c = 'String'));
        defs.add(new RFQI_Field_Def__c(Name = 'Number_of_Stacked_Via__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Number_of_SMDs_On_Substrate__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Number_of_Times_per_Sorting__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Number_of_TMVs__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Number_of_TMV_Balls__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Number_of_Touchdown__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Number_of_Units_Strip__c',Object__c='Package', Type__c='Decimal'));
        defs.add(new RFQI_Field_Def__c(Name = 'Number_of_Wires__c',Object__c='Wire', Type__c='Decimal'));
        defs.add(new RFQI_Field_Def__c(Name = 'Number_Of_Wires__c',Object__c='Wire', Type__c='Decimal'));
        defs.add(new RFQI_Field_Def__c(Name = 'Open_Shorts_Test__c',Object__c='Package', Type__c='Boolean'));
        defs.add(new RFQI_Field_Def__c(Name = 'Operation__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Optical_Inspections__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Optical_Inspection_1__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Optical_Inspection_2__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Optical_Inspection_3__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'OSP__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'OS_Sampling__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'OS_Sampling_Perc__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'OS_Test__c', Object__c='Package', Type__c = 'Boolean'));
        defs.add(new RFQI_Field_Def__c(Name = 'OS_Test_Sample__c', Object__c='Package', Type__c = 'Decimal'));
        defs.add(new RFQI_Field_Def__c(Name = 'Other_Components__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Other_Options__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Other_Special_Instructions__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Package__c'));        
        defs.add(new RFQI_Field_Def__c(Name = 'Package_Description_Extended__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Package_Family_Max__c', Object__c='Package', Type__c = 'String'));
        defs.add(new RFQI_Field_Def__c(Name = 'Package_Assembly_per_Amkor_Rec__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Package_Structure__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Package_Thickness__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Package_Type__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Packing__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Packing_Method__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Packing_Type__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Passivation__c', Object__c='Package', Type__c = 'String'));
        defs.add(new RFQI_Field_Def__c(Name = 'Passivation_Type__c', Object__c='Die', Type__c = 'String'));
        defs.add(new RFQI_Field_Def__c(Name = 'Passive_Supplier__c', Object__c='Passive', Type__c = 'String'));
        defs.add(new RFQI_Field_Def__c(Name = 'Passive_Type__c', Object__c='Passive', Type__c = 'String'));
        defs.add(new RFQI_Field_Def__c(Name = 'Passives__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'PDL_Package__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Per_Hour_Price_to_Customer__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Per_Minute_Price_to_Customer__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Pitch__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Pizza_Wafer__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Plant__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Plating__c', Object__c='Package', Type__c = 'String'));
        defs.add(new RFQI_Field_Def__c(Name = 'Plasma_Before_Die_Attach__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Plasma_Before_Mold__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Plasma_Before_Wire_Bond__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Plating__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Prestacking__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Pre_Stacking__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Price_To_Customer__c'));        
        defs.add(new RFQI_Field_Def__c(Name = 'Probe_Model_Name__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Probe_Owner__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Prober__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Process_Finish__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Process_Type__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Product_Maturity__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Prototype__c', Object__c='Package', Type__c='Boolean'));
        defs.add(new RFQI_Field_Def__c(Name = 'Quote_Request_Type__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'RDL_Thickness__c', Object__c='Package', Type__c = 'String'));
        defs.add(new RFQI_Field_Def__c(Name = 'Resistance_Value__c', Object__c='Passive', Type__c = 'Decimal'));
        defs.add(new RFQI_Field_Def__c(Name = 'Restricted_Substrate_Supplier__c', Object__c='Package', Type__c = 'String'));
        defs.add(new RFQI_Field_Def__c(Name = 'Raw_Solder_Ball_Diameter__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'RDL_Required_On_Interposer_BS__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Restricted_Substrate_Supplier__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'RFQ_Test_Time__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Sales_Target_Price__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Scan__c', Object__c='Package', Type__c = 'Boolean'));
        defs.add(new RFQI_Field_Def__c(Name = 'Shipping_Tray__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Side_Spacer__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Si_Node__c'));        
        defs.add(new RFQI_Field_Def__c(Name = 'Size_of_Passives__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'SMD_Top_Surface_Finish__c', Object__c='Package', Type__c = 'String'));
        defs.add(new RFQI_Field_Def__c(Name = 'SMD_Bottom_Surface_Finish__c', Object__c='Package', Type__c = 'String'));
        defs.add(new RFQI_Field_Def__c(Name = 'Soak_Time_per_Insertion__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Solder_Balls__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Solderball_Type__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Soldermask__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Soldermask_Material__c', Object__c='Package', Type__c = 'String'));
        defs.add(new RFQI_Field_Def__c(Name = 'Soldermask_Registration__c', Object__c='Package', Type__c = 'String'));
        defs.add(new RFQI_Field_Def__c(Name = 'Soldermask_Type__c', Object__c='Package', Type__c = 'String'));
        defs.add(new RFQI_Field_Def__c(Name = 'Soldermask_Thickness__c', Object__c='Package', Type__c = 'String'));
        defs.add(new RFQI_Field_Def__c(Name = 'Solder_mask_Registration__c', Object__c='Package', Type__c = 'String'));
        defs.add(new RFQI_Field_Def__c(Name = 'Solder_Mask_Dam__c', Object__c='Package', Type__c = 'String'));
        defs.add(new RFQI_Field_Def__c(Name = 'Sort_Time_Per_Die__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Space__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Special_Adder__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Special_Instrument__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Special_Option__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Special_Options__c', Object__c='Package', Type__c = 'String'));
        defs.add(new RFQI_Field_Def__c(Name = 'Specific_Passive__c', Object__c='Passive', Type__c = 'String'));
        defs.add(new RFQI_Field_Def__c(Name = 'Stack_Up__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Stamped_Etched_Leadframe__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Standard_Rough_Leadframe__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Stiffener_Adhesive__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Strip_Matrix__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Strip_Surface_Finish__c', Object__c='Package', Type__c = 'String'));
        defs.add(new RFQI_Field_Def__c(Name = 'Strip_Test__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Strip_Width__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Strip_Width_Other__c', Object__c='Package', Type__c = 'Decimal'));
        defs.add(new RFQI_Field_Def__c(Name = 'Structure__c', Object__c='Package', Type__c = 'String'));
        defs.add(new RFQI_Field_Def__c(Name = 'Substrate_Ball_Pad_Pitch__c', Object__c='Package', Type__c = 'String'));
        defs.add(new RFQI_Field_Def__c(Name = 'Substrate_Body_Size__c', Object__c='Package', Type__c = 'String'));
        defs.add(new RFQI_Field_Def__c(Name = 'Substrate_Bond_Finger__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Substrate_Core__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Substrate_Core_Type__c', Object__c='Package', Type__c = 'String'));
        defs.add(new RFQI_Field_Def__c(Name = 'Substrate_Dielectric_Buildup_Type__c', Object__c='Package', Type__c = 'String'));
        defs.add(new RFQI_Field_Def__c(Name = 'Substrate_Finish__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Substrate_Layer_Count_Stack_Up__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Substrate_Layers__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Substrate_L_S__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Substrate_Process__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Substrate_S_M__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Substrate_Supplier__c', Object__c='Package', Type__c = 'String'));
        defs.add(new RFQI_Field_Def__c(Name = 'Substrate_Thickness__c', Object__c='Package', Type__c = 'String'));
        defs.add(new RFQI_Field_Def__c(Name = 'Substrate_thickness__c', Object__c='Package', Type__c = 'Decimal'));
        defs.add(new RFQI_Field_Def__c(Name = 'Substrate_Type__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Substrate_Width__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Tape_and_Reel__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Target_Mold_Cap_Thickness__c', Object__c='Package', Type__c='Decimal'));
        defs.add(new RFQI_Field_Def__c(Name = 'Technology_Node__c', Object__c='Die', Type__c='Decimal'));
        defs.add(new RFQI_Field_Def__c(Name = 'Temp__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Temp_and_Soak_Time__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Temperate__c', Object__c='Insertion', Type__c='String'));
        defs.add(new RFQI_Field_Def__c(Name = 'Temperature_Cycle__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Tester__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Tester__c', Object__c='Insertion', Type__c = 'String'));
        defs.add(new RFQI_Field_Def__c(Name = 'Tester_Model__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Tester_Model__c', Object__c='Insertion', Type__c = 'String'));
        defs.add(new RFQI_Field_Def__c(Name = 'Test_Owner__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Test_Owner_2__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Test_Time__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Test_Time__c', Object__c='Insertion', Type__c = 'Decimal'));
        defs.add(new RFQI_Field_Def__c(Name = 'Test_Time_to_Unit__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Test_Time_to_Unit__c', Object__c='Insertion', Type__c = 'Decimal'));
        defs.add(new RFQI_Field_Def__c(Name = 'TIM__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Include_SMT__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Include_TMV__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'TMV_Ball_Composition__c', Object__c='Package', Type__c = 'String'));
        defs.add(new RFQI_Field_Def__c(Name = 'TMV_Pitch__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Tolerance__c', Object__c='Passive', Type__c = 'String'));
        defs.add(new RFQI_Field_Def__c(Name = 'Total_Layer_Count__c', Object__c='Package', Type__c = 'String'));
        defs.add(new RFQI_Field_Def__c(Name = 'Total_2D_Wire_Length__c', Object__c='Wire', Type__c='Decimal'));
        defs.add(new RFQI_Field_Def__c(Name = 'Total_3D_Wire_Length__c', Object__c='Wire', Type__c='Decimal'));
        defs.add(new RFQI_Field_Def__c(Name = 'Total_Layer_Count__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Total_Number_of_I_O__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Total_Number_of_Vias__c', Object__c='Package', Type__c = 'Decimal'));
        defs.add(new RFQI_Field_Def__c(Name = 'Total_Test_Time__c', Object__c='Package', Type__c = 'Decimal'));
        defs.add(new RFQI_Field_Def__c(Name = 'Total_Test_Time__c', Object__c='Insertion', Type__c = 'Decimal'));
        defs.add(new RFQI_Field_Def__c(Name = 'Total_Via_Count__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Trace_Space_Width__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Turnkey__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Type_of_Bump__c', Object__c='Package', Type__c = 'String'));
        defs.add(new RFQI_Field_Def__c(Name = 'UBM_Dia__c', Object__c='Die', Type__c = 'Decimal'));
        defs.add(new RFQI_Field_Def__c(Name = 'UF__c', Object__c='Die', Type__c = 'String'));
        defs.add(new RFQI_Field_Def__c(Name = 'Underfill_Type__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Unit_Price_per_Test_Time__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Unit_Price_per_Test_Time__c', Object__c='Insertion', Type__c = 'Decimal'));
        defs.add(new RFQI_Field_Def__c(Name = 'Unit_Price_To_Customer__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Via_Count__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Via_Count_Layer_Type__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Via_Fill__c', Object__c='Package', Type__c = 'String'));
        defs.add(new RFQI_Field_Def__c(Name = 'Via_Fill_Wall_THK__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Via_Pad_Size__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Via_and_Pad_Size_Buildup__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Via_and_Pad_Size_Core__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Via_Size_Build_up__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Via_Size_Core__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Voltage__c', Object__c='Passive', Type__c='Decimal'));
        defs.add(new RFQI_Field_Def__c(Name = 'Wafer_Thickness_Post_Backgrind__c', Object__c='Die', Type__c='Decimal'));
        defs.add(new RFQI_Field_Def__c(Name = 'Wafer_Backgrind__c', Object__c='Die', Type__c='Boolean'));
        defs.add(new RFQI_Field_Def__c(Name = 'Wafer_Diameter__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Wafer_Dicing__c', Object__c='Die', Type__c='String'));
        defs.add(new RFQI_Field_Def__c(Name = 'Wafer_Inspection__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Wafer_Inspection_1__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Wafer_Inspection_2__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Wafer_Material__c',Object__c='Die', Type__c='String'));
        defs.add(new RFQI_Field_Def__c(Name = 'Wafer_Number_of_DPW__c', Object__c='Die', Type__c='Decimal'));
        defs.add(new RFQI_Field_Def__c(Name = 'Wafer_Number_of_GDPW__c', Object__c='Die', Type__c='Decimal'));
        defs.add(new RFQI_Field_Def__c(Name = 'Wafer_Technology__c',Object__c='Die', Type__c='String'));
        defs.add(new RFQI_Field_Def__c(Name = 'Wafer_Probe_Yield__c',Object__c='Die', Type__c='Decimal'));
        defs.add(new RFQI_Field_Def__c(Name = 'Wafer_Thickness__c',Object__c='Die', Type__c='Decimal'));
        defs.add(new RFQI_Field_Def__c(Name = 'wafer_thickness__c',Object__c='Die', Type__c='Decimal'));
        defs.add(new RFQI_Field_Def__c(Name = 'Wafer_Node__c',Object__c='Die', Type__c='String'));
        defs.add(new RFQI_Field_Def__c(Name = 'Wafer_Saw_Street__c',Object__c='Die', Type__c='String'));
        defs.add(new RFQI_Field_Def__c(Name = 'Wafer_Singulation__c', Object__c='Die', Type__c='String'));
        defs.add(new RFQI_Field_Def__c(Name = 'Wafer_Singulation_Type__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Wafer_Size__c', Object__c='Die', Type__c='String'));
        defs.add(new RFQI_Field_Def__c(Name = 'Wafer_Size_PK__c', Object__c='Package', Type__c='String'));
        defs.add(new RFQI_Field_Def__c(Name = 'Wafer_Stealth_Dicing__c', Object__c='Die', Type__c='String'));
        defs.add(new RFQI_Field_Def__c(Name = 'Wafer_Yield__c', Object__c='Die', Type__c='Decimal'));
        defs.add(new RFQI_Field_Def__c(Name = 'Wire_Configuration__c', Object__c='Wire', Type__c='String'));
        defs.add(new RFQI_Field_Def__c(Name = 'Wire_Diameter__c', Object__c='Wire', Type__c='String'));
        defs.add(new RFQI_Field_Def__c(Name = 'Wire_Material__c', Object__c='Wire', Type__c='String'));
        defs.add(new RFQI_Field_Def__c(Name = 'WBG_Required__c', Object__c='Die', Type__c='Boolean'));
        defs.add(new RFQI_Field_Def__c(Name = 'WBG_Final_Thickness__c', Object__c='Die', Type__c='Decimal'));
        defs.add(new RFQI_Field_Def__c(Name = 'Wire_Type_and_Size__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'WLCSP_Die_Processing_Needed__c', Object__c='Package', Type__c = 'Boolean'));
        defs.add(new RFQI_Field_Def__c(Name = 'WLCSP_CoC__c', Object__c='Die', Type__c='Boolean'));
        defs.add(new RFQI_Field_Def__c(Name = 'WLCSP_FT__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'WLCSP_KGD__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'WLCSP_Type__c', Object__c='Package', Type__c = 'String'));
        defs.add(new RFQI_Field_Def__c(Name = 'WS_hardware_requirement__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'X1st_Capacitor_Quantity__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'X1st_Capacitor_Type__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'X2D_Or_3D_Structure__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'X2nd_Capacitor_Quantity__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'X2nd_Capacitor_Type__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'X2_OPT_INSP_100__c', Object__c='Package', Type__c='Boolean'));
        defs.add(new RFQI_Field_Def__c(Name = 'X3RD_OPT_100__c', Object__c='Package', Type__c='Boolean'));
        defs.add(new RFQI_Field_Def__c(Name = 'X3RD_OPT_QA_GATE__c', Object__c='Package', Type__c='Boolean'));
        defs.add(new RFQI_Field_Def__c(Name = 'Zero_Delam_Required__c'));
        
        //forecast attributes
        defs.add(new RFQI_Field_Def__c(Name = 'Production_Start_Date__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Average_Monthly_Volume__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Estimated_Product_Life__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Ramp_Start_Month__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Ramp_Start_Volume__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Ramp_Stop_Month__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Ramp_Stop_Volume__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Average_Test_Lot_Size__c'));
        
        //NRE attributes
        defs.add(new RFQI_Field_Def__c(Name = 'Art_Work__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Assembly_Lot_Charge__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Assembly_OS_Test__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Auto_BAT__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Ball_Attach_Auto__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Ball_Attach_Manual__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Ball_Attach_Stencil__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Ball_Stencil__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'BGA_Attach_Manual_Tooling__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'BGA_Ball_Attach_Tooling__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'bHast__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'BLR_Simulation__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Bump_Stencil_Tool__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Carrier_Tape_Tooling__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Changekit_Tooling__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Custom_BA_Tooling__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Custom_B_A_Tooling__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Custom_Heatspreader_Tooling__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Custom_Lid_Tooling__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Custom_Mold_Chase__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Custom_Pocket_Tape__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Custom_Tray_Tooling__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Design_Fee__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Electrical_Simulation__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Engineering_Lot_Charge__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Etched_Leadframe_Tooling__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'ET_Checker__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Extra_Plasma__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Flux_Stencil__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Heater_Spreader_Design__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Interposer_Lot_Charge__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Interposer_Masks__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Load_Board_Design__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Leadframe_NRE__c', Type__c='Decimal'));
        defs.add(new RFQI_Field_Def__c(Name = 'Manual_BAT__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Masks__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Modeling_Charges__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Mold_Chase__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'MRT_TC_HAST_HTS__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'NRE_per_Jig__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Number_Of_Jigs__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Package_Singulation_Tool__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Package_Substrate_Co_Design__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Photo_Masks__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Laser_Masks__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Pogotower_Tooling__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Probe_Card_Design__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Program_Develop__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Reliability_Testing__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Ring_Carrier_Tooling__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Singulation__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'SIP_Solder_Stencil__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Small_Lot_Charge__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Stencil_for_SMT__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Stencil_Tooling__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Stamped_Leadframe_Tooling__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Substrate_Artwork_per_Supplier__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Substrate_Design__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Substrate_ET_Checker__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Substrate_Tooling__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'TC_Bond_Head_Tooling_Interposer__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'TC_Bond_Head_Tooling_per_Die__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Thermal_Simualtion__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'TMV_Ball_Attach_Tooling__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Total_NRE__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Tray__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'UF_Boat_Tooling__c'));        
        defs.add(new RFQI_Field_Def__c(Name = 'Other__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Other_Hardware_Design__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Wafflepack_Tooling__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'X3D_Wire_Bond_Simulation__c'));
        
        //quad new wire attributes - AMK-690
        defs.add(new RFQI_Field_Def__c(Name = 'Number_of_FWD_Wires__c', Object__c='Wire', Type__c='Decimal'));
        defs.add(new RFQI_Field_Def__c(Name = 'Number_of_SSB_Wires__c', Object__c='Wire', Type__c='Decimal'));


        //"Other" fields for manual entry on package
        defs.add(new RFQI_Field_Def__c(Name = 'BGA_Ball_Composition_Other__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Lid_Adhesive_Other__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Lid_Attach_Type_Other__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Lid_Finish_Other__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Lid_Material_Other__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'Lid_TIM_Other__c'));
        defs.add(new RFQI_Field_Def__c(Name = 'TMV_Ball_Composition_Other__c'));
        

        //"Other" fields for manual entry on wire
        defs.add(new RFQI_Field_Def__c(Name = 'Wire_Diameter_Other__c',Object__c='Wire', Type__c='Decimal'));
        
        try {
            insert defs;
        }catch(Exception e) {
            system.debug('Could not install field definitions: ' + e);
        }
        
        return defs;
    }
    
    private static List<RFQI_Section__c> installSections() {
        
        List<RFQI_Section__c> sections = new List<RFQI_Section__c>();
        sections.add(new RFQI_Section__c(Name = 'BU Header',Sequence__c = 1000));
        sections.add(new RFQI_Section__c(Name = 'Sales Header',Sequence__c = 1500));
        sections.add(new RFQI_Section__c(Name = 'Quote Information',Sequence__c = 2000));
        sections.add(new RFQI_Section__c(Name = 'Sales Price',Sequence__c = 3000));        
        sections.add(new RFQI_Section__c(Name = 'Cost and Price',Sequence__c = 4000));
        sections.add(new RFQI_Section__c(Name = 'Package Description',Sequence__c = 5000));
        sections.add(new RFQI_Section__c(Name = 'CPN Drivers',Sequence__c = 6000));
        sections.add(new RFQI_Section__c(Name = 'Wire Description',Sequence__c = 7000));
        sections.add(new RFQI_Section__c(Name = 'Forecast',Sequence__c = 8000));
        sections.add(new RFQI_Section__c(Name = 'Die Description',Sequence__c = 9000));
        sections.add(new RFQI_Section__c(Name = 'Substrate Description',Sequence__c = 10000));
        sections.add(new RFQI_Section__c(Name = 'Passive Description',Sequence__c = 11000));
        sections.add(new RFQI_Section__c(Name = 'Insertion Description',Sequence__c = 12000));
        sections.add(new RFQI_Section__c(Name = 'Service Description',Sequence__c = 12500));
        sections.add(new RFQI_Section__c(Name = 'Adders',Sequence__c = 13000));
        sections.add(new RFQI_Section__c(Name = 'Substrate CPN',Sequence__c = 14000));
        sections.add(new RFQI_Section__c(Name = 'NRE',Sequence__c = 15000));
        sections.add(new RFQI_Section__c(Name = 'Cost Model Reference',Sequence__c = 16000));
        
        
        
        try {
            insert sections;
        }catch(Exception e) {
            system.debug('Could not install RFQItem page sections: ' + e);
        }
         
        return sections;
    }
    
    
    // To Be run after the PG installers are run
    public static void updateSapFieldsForProductGroup(String pgName) {
    	List<RFQI_PF_Field_Def__c> fieldDefs = [Select Id, RFQI_Field_Def__r.Name from RFQI_PF_Field_Def__c where Package_Family__r.Product_Group__r.Name =: pgName];
    	
    	Map<String, String> sapFieldNameMap = getSapNameFieldMaps();
    	
    	for (RFQI_PF_Field_Def__c def : fieldDefs) {
    		String fieldName = def.RFQI_Field_Def__r.Name;
    		if (sapFieldNameMap.containsKey(fieldName)) {
    			def.SAP_Name__c = sapFieldNameMap.get(fieldName);
    		}	
    	}
    	
    	update fieldDefs;
    }
    
    private static Map<String, String> getSapNameFieldMaps() {
    	Map<String, String> result = new Map<String, String>();
    	
    	// Lines commented out are on the spreadsheet but couldn't find a good mapping for 
    	
    	//result.put('Configured Part Number','CPN');
		//result.put('Division','SPART');
		result.put('Plant__c','WERKS');
		result.put('RFQ_Item__r.Package_Family__r.Name','PKG_FAMLY_DESC');
		//result.put('PF Sub Class1','SUB_PKG_GROUP');
		//result.put('PF Sub Class2','ZZPACKAGE');
		result.put('Body_X__c','DMZ_X');
		result.put('Body_Y__c','DMZ_Y');
		result.put('Lead_Count__c','LEADCOUNT');
		result.put('Wire_Material__c','WIRE_MATERIAL1');
		result.put('Wire_Diameter__c','WIRE_DIA1');
		result.put('Number_of_wires','WIRES');
		result.put('Die_Size_X__c','CHIP_SIZE1_X');
		result.put('Die_Size_Y__c','CHIP_SIZE1_Y');
		result.put('Number_Of_Die__c','DIES');
		result.put('Wafer_Size__c','WAFER_SIZE1');
		result.put('Tester_Model_Name__c','EL_MDL');
		result.put('Test_Owner__c','EL_OWNER');
		result.put('Handler_Model_Name__c','HD_MDL');
		result.put('Handler_Owner__c','HD_OWNER');
		result.put('Temp__c','ZZTEMP');
		result.put('Gross_Die_Per_Wafer__c','DPW');
		result.put('Handler__c','HD_SITE');
		result.put('Operation__c','VORNR');
		result.put('Bake_Hours__c','BAKE_TIME');
		result.put('Burn_in_Hours__c','BAKE_TIME');
		result.put('Packing_Method__c','PACK_METHOD');
		//result.put('Laser Scribe(Y/N)','OP_LASER_SCRIBE');
		result.put('Extra_Plasma__c','OP_EXTRA_PLASMA');
		result.put('Optical_Inspections__c','OP_OPTICAL_INSP');
		//result.put('100% Final Visual (Y/N)','OP_FINAL_VISUAL');
		result.put('Bake_Dry_Pack__c','OP_DRYPACK_BAKE');
		result.put('Drypack__c','OP_DRYPACK_BAKE');
		result.put('Temperature_Cycle__c','OP_TEMP_CYCLE');
		//result.put('GsAs Wafer (Y/N)','OP_GSAS_WAFER');
		result.put('Die_Coat__c','OP_DIE_COAT');
		result.put('Open_Shorts_Test__c','OP_OPEN_SHORT');
		//result.put('Special Services (Y/N)','OP_SPECIAL_SERV');
		result.put('Leadframe_Finish__c','LF_FINISH');
		//result.put('Exposed Pad (Y/N)','PAD_TYPE');
		result.put('Wafer_Backgrind__c','OP_WBG');
		result.put('EMC__c','EMC_TYPE');
		result.put('Total_2D_Wire_Length__c','WIRE_LENGTH');
		result.put('Standard_Rough_Leadframe__c','LF_TYPE');
		result.put('Stamped_Etched_Leadframe__c','LF_MATERIAL');
		
		//result.put('Package Code','PKG');
		result.put('Wafer_Thickness__c','WAFER_THICKNESS1');
		result.put('Number_Of_Wires__c','WIRES1');
		result.put('Wire_Configuration__c','WIRESn');
		result.put('Total_2D_Wire_Length__c','WIRE_LENGHT1');
		//result.put('wire configs 2-16','WIRE_LENGHTn');
		result.put('Die_Attach__c','DIE_ATTACH1');
		//result.put('For Die 2-16','DIE_ATTACHn');
		result.put('Wafer_Singulation_Type__c','SINGULATION_TYPE1');
		//result.put('For Wafer 2-16','SINGULATION_TYPEn ');
		//result.put('Total Number of Capacitors','NO_CAPACITORS');
		//result.put('Total Number of Xtals','NO_XTALS');
		//result.put('Total Number of Filters','NO_FILTERS');
		result.put('Extra_Plasma__c','OP_XPLASMA_BDA');
		result.put('Plasma_Before_Wire_Bond__c','OP_XPLASMA_BWB');
		result.put('Plasma_Before_Mold__c','OP_XPLASMA_BM');
		result.put('Wafer_Inspection__c','OP_WAFER_INSPECTION');
		result.put('Optical_Inspection_1__c','OP_OPTICAL_INSP1');
		result.put('Optical_Inspection_2__c','OP_OPTICAL_INSP2');
		result.put('Optical_Inspection_3__c','OP_OPTICAL_INSP3');
		result.put('Bake__c','OP_BAKE');
		result.put('Frame_Finish__c','FRAME_FINISH');
    	
    	return result;
    }

    global static void AMK1222() {

        RFQI_Section__c section = new RFQI_Section__c();
        section.Name = 'BU Attributes';
        section.Sequence__c = 3500;
        section.Page_Type__c='BU';

        insert section;

        List<RFQI_Field_Def__c> defs = new List<RFQI_Field_Def__c>();
        defs.add(new RFQI_Field_Def__c(Name='Capacitor_Paste_Flux__c'));
        defs.add(new RFQI_Field_Def__c(Name='Flux__c'));
        defs.add(new RFQI_Field_Def__c(Name='Solder_Ball_Flux__c'));
        defs.add(new RFQI_Field_Def__c(Name='OM_Chase__c', Type__c='Decimal'));
        defs.add(new RFQI_Field_Def__c(Name='OM_Thickness__c', Type__c='Decimal'));
        defs.add(new RFQI_Field_Def__c(Name='LG_Pass__c', Type__c='Decimal'));
        defs.add(new RFQI_Field_Def__c(Name='Substrate_Purchase_Price__c', Type__c='Decimal'));
        defs.add(new RFQI_Field_Def__c(Name='Process_Include_LA_In_Line_Plasma__c', Type__c='Boolean'));
        defs.add(new RFQI_Field_Def__c(Name='Process_Include_Wafer_Mount_Stand_Alone__c', Type__c='Boolean'));
        defs.add(new RFQI_Field_Def__c(Name='Process_Include_Underfill_In_Line_Plasma__c', Type__c='Boolean'));
        defs.add(new RFQI_Field_Def__c(Name='Process_Include_Cap_Attached_on_BGA__c', Type__c='Boolean'));
        defs.add(new RFQI_Field_Def__c(Name='Process_Include_OS_Test__c', Type__c='Boolean'));
        defs.add(new RFQI_Field_Def__c(Name='Purchase_Price__c', Type__c='Decimal', Object__c='Passive'));

        insert defs;
    }

    global static void incrementalInstallAMK1385() {

        Account parentAccount = new Account(Name = 'Parent',AccountNumber='PROSPECT', Sales_Region__c = 'Japan');
        insert parentAccount;
   
        List<RFQ_System_Settings__c> settings = [select Id from RFQ_System_Settings__c];
        for(RFQ_System_Settings__c s : settings) {
            s.Prospect_Account_Id__c = parentAccount.Id;
        }
        update settings;

    }

    //-- Run to update records that need to be transitioned from Include NRE On Quote checkbox to new NRE Inclusion
    global static void AMK1314(){

        List <RFQ_Item__c> rfqItemsToUpdate = new List <RFQ_Item__c>();

        for(RFQ_Item__c item : [select Id, Include_NRE_On_Quote__c, NRE_Inclusion__c from RFQ_Item__c]){

            if(item.NRE_Inclusion__c == null){

                if(item.Include_NRE_On_Quote__c){
                    item.NRE_Inclusion__c = 'If Applicable';
                }else{
                    item.NRE_Inclusion__c = 'Not Applicable';
                }

                rfqItemsToUpdate.add(item);
            }
        }

        update rfqItemsToUpdate;

    }

    global static void AMK1432()
    {
        insert new RFQI_Section__c(Name='Deprecated Fields', Sequence__c=16000, Page_Type__c='Both');

        List<RFQI_Section__c> sections = [select Id, Name, Page_Type__c from RFQI_Section__c];

        for (RFQI_Section__c section : sections)
        {
            if (section.Name == 'Cost and Price' || section.Name == 'Cost Model Reference') section.Page_Type__c = 'BU';
            else if (section.Name == 'Quote Information') section.Page_Type__c = 'Sales';
            else section.Page_Type__c = 'Both';
        }

        List<Package_Family__c> families = [select Id, Layout_Version__c from Package_Family__c];
        for (Package_Family__c pf : families)
        {
            pf.Layout_Version__c = (pf.Layout_Version__c == null) ? 1 : pf.Layout_Version__c + 1;
        }

        update sections;
        update families;
    }
    global static void AMK1468()
    {
        DebugUtils debug = DebugUtils.getInstance();
        List<Package_Family__c> pfList = [select Id, Name, Specific_Wire_Configuration_Object__c from Package_Family__c where Specific_Wire_Configuration_Object__c != ''];

        insert new RFQI_Field_Def__c(Name='Customer_SAP_AU_Base__c', Object__c='Wire');
        List<RFQI_Field_Def__c> defList = [select Id, Name from RFQI_Field_Def__c where Name in ('Au_Inclusive__c', 'Customer_SAP_AU_Base__c')];

        RFQI_Section__c section = [select Id, Name from RFQI_Section__c where name='Wire Description'];

        List<RFQI_PF_Field_Def__c> insertList = new List<RFQI_PF_Field_Def__c>();

        Decimal seq;
        for (Package_Family__c pf : pfList)
        {   
            seq = 3100;
            for (RFQI_Field_Def__c def : defList)
            {
                insertList.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = def.Id, Package_Family__c = pf.Id, RFQI_Section__c = section.Id, Generated__c = true, Sequence__c = seq));
                seq += 10;

            }
        }

        insert insertList;
    }

    global static void AMK1237()
    {
        List<RFQI_PF_Field_Def__c> pfList = [select Id, Name, Has_Amkor_Selected__c from RFQI_PF_Field_Def__c where 
                                            (RFQI_Field_Def__r.Name='Restricted_Substrate_Supplier__c' and Package_Family__r.Name IN ('FC CSP', 'CABGA')) OR
                                            (RFQI_Field_Def__r.Name='BGA_Ball_Composition__c' and Package_Family__r.Name IN ('FC CSP')) OR
                                            (RFQI_Field_Def__r.Name='Strip_Width__c' and Package_Family__r.Name IN ('FC CSP', 'FC SCSP')) OR
                                            (RFQI_Field_Def__r.Name='Substrate_Supplier__c' and Package_Family__r.Name IN ('FC CSP', 'FC SCSP', 'PBGA', 'SCSP')) OR
                                            (RFQI_Field_Def__r.Name='TMV_Ball_Composition__c' and Package_Family__r.Name IN ('FC CSP', 'FC SCSP')) OR
                                            (RFQI_Field_Def__r.Name='Die_Thickness__c' and Package_Family__r.Name IN ('SCSP'))];

        for (RFQI_PF_Field_Def__c pf : pfList) 
        {

            pf.Has_Amkor_Selected__c = true;
        }

        update pfList;
    }

    global static void AMK1458() {
        List<Package_Family__c> packageFamilies = [select Id from Package_Family__c];
        List<RFQI_PF_Field_Def__c> pfFieldDefs = new List<RFQI_PF_Field_Def__c>();
        RFQI_Field_Def__c fieldDef = new RFQI_Field_Def__c(Name='Quote_Request_Type__c');
        Map<String, RFQI_Section__c> sections = FieldBuilderHelper.getSectionMap();


        insert fieldDef;

        for (Package_Family__c family : packageFamilies) {
            pfFieldDefs.add(new RFQI_PF_Field_Def__c(Package_Family__c = family.Id, Required__c = false, RFQI_Field_Def__c= fieldDef.Id, RFQI_Section__c = sections.get('Quote Information').Id, Sequence__c = 2200));
            pfFieldDefs.add(new RFQI_PF_Field_Def__c(Package_Family__c = family.Id, Required__c = false, RFQI_Field_Def__c= fieldDef.Id, RFQI_Section__c = sections.get('BU Header').Id, Sequence__c = 2000));
        }

        insert pfFieldDefs;

    }

    global static void AMK1578() {

        List<RFQI_Field_Def__c> defs = [select Name,Id from RFQI_Field_Def__c where Name =:'Customer_SAP_AU_Base__c'];

        for(RFQI_Field_Def__c def : defs) {
            def.Name = 'Customer_AU_Base_fml__c';
        }
        update defs;

    }


    global static void AMK1510() {
        List<RFQI_PF_Field_Def__c> fieldDefs = [Select Id from RFQI_PF_Field_Def__c where RFQI_Field_Def__r.Name in ('Wire_Configuration__c', 'Wire_Material__c', 'Wire_Diameter__c', 'Number_of_Wires__c' )];

        for (RFQI_PF_Field_Def__c field : fieldDefs) {
            field.Not_Required_on_Import__c = true;
        }

        update fieldDefs;


        List<Package_Family__c> pfs = [Select Id from Package_Family__c where Has_Factory_Field__c = true];

        RFQI_Field_Def__c factoryField = [Select Id from RFQI_Field_Def__c where Name = 'Factory__c'];

        List<RFQI_PF_Field_Def__c> newFactoryFields = new List<RFQI_PF_Field_Def__c>();

        for (Package_Family__c pf : pfs) {
            RFQI_PF_Field_Def__c newField = new RFQI_PF_Field_Def__c(Package_Family__c=pf.Id,RFQI_Field_Def__c=factoryField.Id,Required__c=true);
            newFactoryFields.add(newField);
        }

        insert newFactoryFields;
    }

    global static void AMK1563() {
        List<Package_Family__c> pFamilies = [select Id from Package_Family__c];
        List<RFQI_PF_Field_Def__c>  fieldToAdd = new List<RFQI_PF_Field_Def__c>();
        Map<String, RFQI_Section__c> sections = FieldBuilderHelper.getSectionMap();
        List<RFQI_Field_Def__c> fieldDefs = new List<RFQI_Field_Def__c>();
        fieldDefs.add(new RFQI_Field_Def__c(Name='Decision_To_Buy__c'));
        fieldDefs.add(new RFQI_Field_Def__c(Name='Target_Price_Multiservice__c'));
        insert fieldDefs;

        for(Package_Family__c family : pFamilies) {
            fieldToAdd.add(new RFQI_PF_Field_Def__c(RFQI_Section__c = sections.get('Quote Information').Id, Package_Family__c = family.Id, RFQI_Field_Def__c = fieldDefs[0].Id, Sequence__c = 2210, Required__c = true));
            fieldToAdd.add(new RFQI_PF_Field_Def__c(RFQI_Section__c = sections.get('BU Header').Id, Package_Family__c = family.Id, RFQI_Field_Def__c = fieldDefs[0].Id, Sequence__c = 2010));
            fieldToAdd.add(new RFQI_PF_Field_Def__c(RFQI_Section__c = sections.get('Quote Information').Id, Package_Family__c = family.Id, RFQI_Field_Def__c = fieldDefs[1].Id, Sequence__c = 1105));
            fieldToAdd.add(new RFQI_PF_Field_Def__c(RFQI_Section__c = sections.get('BU Header').Id, Package_Family__c = family.Id, RFQI_Field_Def__c = fieldDefs[1].Id, Sequence__c = 2020));
        }

        insert fieldToAdd;
    }

    global static void AMK1566() {
        List<RFQI_PF_Field_Def__c> fieldsToUpdate = [select Id, Is_Manual_Entry__c, RFQI_Field_Def__r.Name from RFQI_PF_Field_Def__c where Package_Family__r.No_Cost_Model__c =: true];
        List<Package_Family__c> families = [select Id, Has_Manual_Entry_Fields__c from Package_Family__c where No_Cost_Model__c =: true];

        for(Package_Family__c pf : families) {
            pf.Has_Manual_Entry_Fields__c = true;
        }

        for(RFQI_PF_Field_Def__c field : fieldsToUpdate) {
            if(field.RFQI_Field_Def__r.Name == 'BU_Price__c' || field.RFQI_Field_Def__r.Name == 'Total_Cost_with_Substrate_New__c' || field.RFQI_Field_Def__r.Name == 'Total_Cost__c') {
                field.Is_Manual_Entry__c = true;
            }
        }

        update fieldsToUpdate;
        update families;
    }

    public static void AMK1766() {
        List<RFQ_Item__c> rfqItems = [select Id, Forecast_Minimum__c, Forecast_Maximum__c, Product_Group_Name__c, Package_Item_Value__c, Package_Family_Name__c from RFQ_Item__c where Package_Family_Name__c =: 'Bump'];
        List<RFQI_Bump__c> bumps = [select Id, Forecast__c, RFQ_Item__r.Id from RFQI_Bump__c];

        for(RFQ_Item__c item : rfqItems) {
            for(RFQI_Bump__c bump : bumps) {
                if(bump.RFQ_Item__r.Id == item.Id) {
                    try {
                        Map<String, Decimal> forecastMap = RFQItemDao.getInstance().getMaxMinForecast(String.valueOf(bump.get('Forecast__c')), item.Product_Group_Name__c, item.Package_Family_Name__c);
                        item.Forecast_Minimum__c = forecastMap.get('min');
                        item.Forecast_Maximum__c = forecastMap.get('max');
                        item.Package_Item_Value__c = ((item.Forecast_Minimum__c+item.Forecast_Maximum__c)/2)*(Decimal)bump.get('Price_To_Customer__c');
                    }
                    catch(Exception e){}
                }
            }
        }
        update rfqItems;

    }

    public static void AMK1765() {
        List<RFQ_Item__c> rfqItems = [select Id, Forecast_Minimum__c, Forecast_Maximum__c, Product_Group_Name__c, Package_Item_Value__c, Package_Family_Name__c from RFQ_Item__c where Package_Family_Name__c =: 'WLCSP'];
        List<RFQI_WLCSP__c> WLCSPs = [select Id, Forecast__c, RFQ_Item__r.Id from RFQI_WLCSP__c];

        for(RFQ_Item__c item : rfqItems) {
            for(RFQI_WLCSP__c wlcsp : WLCSPs) {
                if(wlcsp.RFQ_Item__r.Id == item.Id) {
                    try {
                        Map<String, Decimal> forecastMap = RFQItemDao.getInstance().getMaxMinForecast(String.valueOf(wlcsp.get('Forecast__c')), item.Product_Group_Name__c, item.Package_Family_Name__c);
                        item.Forecast_Minimum__c = forecastMap.get('min');
                        item.Forecast_Maximum__c = forecastMap.get('max');
                        item.Package_Item_Value__c = ((item.Forecast_Minimum__c+item.Forecast_Maximum__c)/2)*(Decimal)wlcsp.get('Price_To_Customer__c');
                    }
                    catch(Exception e){}
                }
            }
        }
        update rfqItems;

    }

    public static void addbodyXY() {
        List<Package_Family__c> families = [select Id, Name, Product_Group__r.Name from Package_Family__c];
        List<RFQI_PF_Field_Def__c> fieldDefs = [select Id, RFQI_Field_Def__r.Name, Package_Family__r.Name from RFQI_PF_Field_Def__c];
        Map<string, RFQI_Field_Def__c> fields = FieldBuilderHelper.getFieldDefs();

        for(Package_Family__c family : families) {
            if(family.Product_Group__r.Name == 'Dual Leadframe' || family.Product_Group__r.Name == 'Quad Leadframe' || family.Name == 'PBGA' && family.Name != 'CERDIP' && family.Name != 'SZIP J1 Only') {
                Boolean bodyXExists = false;
                Boolean bodyYExists = false;
                for(RFQI_PF_Field_Def__c field : fieldDefs) {
                    if(field.Package_Family__r.Name == family.Name) {
                        if(field.RFQI_Field_Def__r.Name == 'Body_X__c') {
                            bodyXExists = true;
                        }
                        if(field.RFQI_Field_Def__r.Name == 'Body_Y__c') {
                            bodyYExists = true;
                        }
                    }
                }
                if(!bodyXExists) {
                    fieldDefs.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fields.get('Body_X__c').Id, Package_Family__c = family.Id, CPN_Attribute__c = true, SAP_Name__c = 'DMZ_X'));
                }
                if(!bodyYExists) {
                    fieldDefs.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fields.get('Body_Y__c').Id, Package_Family__c = family.Id, CPN_Attribute__c = true, SAP_Name__c = 'DMZ_Y'));
                }
            }        
        }

        upsert fieldDefs;
    }

    public static void updateSAPNames() {
        List<RFQI_PF_Field_Def__c> fieldsToUpdate= [select Id, RFQI_Field_Def__r.Name, SAP_Name__c from RFQI_PF_Field_Def__c];

        for(RFQI_PF_Field_Def__c field : fieldsToUpdate) {
            if(field.RFQI_Field_Def__r.Name == 'Wire_Material__c') {field.SAP_Name__c = 'WIRE_MATERIAL_TYPE1';}
            if(field.RFQI_Field_Def__r.Name == 'Total_2D_Wire_Length__c') {field.SAP_Name__c = 'WIRE_LENGHT1';}
            if(field.RFQI_Field_Def__r.Name == 'Wire_Diameter__c') {field.SAP_Name__c = 'WIRE_DIA1';}
            if(field.RFQI_Field_Def__r.Name == 'Wire_Configuration__c') {field.SAP_Name__c = 'WIRE_CONFIGURATION1';}
            if(field.RFQI_Field_Def__r.Name == 'Factory__c') {field.SAP_Name__c = 'WERKS';}
            if(field.RFQI_Field_Def__r.Name == 'Wafer_Size__c') {field.SAP_Name__c = 'WAFER_SIZE1';}
            if(field.RFQI_Field_Def__r.Name == 'RFQ_Item__r.Package_Family__r.Name') {field.SAP_Name__c = 'PKG_FAMLY_DESC';}
            if(field.RFQI_Field_Def__r.Name == 'Packing_Type__c') {field.SAP_Name__c = 'PACKING_TYPE';}
            if(field.RFQI_Field_Def__r.Name == 'Plasma_Before_Wire_Bond__c') {field.SAP_Name__c = 'OP_XPLASMA_BWB';}
            if(field.RFQI_Field_Def__r.Name == 'Plasma_Before_Mold__c') {field.SAP_Name__c = 'OP_XPLASMA_BM';}
            if(field.RFQI_Field_Def__r.Name == 'Plasma_Before_Die_Attach__c') {field.SAP_Name__c = 'OP_XPLASMA_BDA';}
            if(field.RFQI_Field_Def__r.Name == 'X3RD_OPT_100__c') {field.SAP_Name__c = 'OP_X3_OPT_INS';}
            if(field.RFQI_Field_Def__r.Name == 'X2_OPT_INSP_100__c') {field.SAP_Name__c = 'OP_X2_OPT_INS';}
            if(field.RFQI_Field_Def__r.Name == 'Wafer_Backgrind__c') {field.SAP_Name__c = 'OP_WBG';}
            if(field.RFQI_Field_Def__r.Name == 'Wafer_Inspection__c') {field.SAP_Name__c = 'OP_WAFER_INSPECTION';}
            if(field.RFQI_Field_Def__r.Name == 'Temperature_Cycle__c') {field.SAP_Name__c = 'OP_TEMP_CYCLE';}
            if(field.RFQI_Field_Def__r.Name == 'Laser_Groove__c') {field.SAP_Name__c = 'OP_GROOVE';}
            if(field.RFQI_Field_Def__r.Name == 'FVI_100__c') {field.SAP_Name__c = 'OP_FVI_100';}
            if(field.RFQI_Field_Def__r.Name == 'Bake_Dry_Pack__c') {field.SAP_Name__c = 'OP_DRYPACK_BAKE';}
            if(field.RFQI_Field_Def__r.Name == 'Die_Coat__c') {field.SAP_Name__c = 'OP_DIE_COAT';}
            if(field.RFQI_Field_Def__r.Name == 'Bake__c') {field.SAP_Name__c = 'OP_BAKE';}
            if(field.RFQI_Field_Def__r.Name == 'Number_Of_Wires__c') {field.SAP_Name__c = 'NO_OF_WB1';}
            if(field.RFQI_Field_Def__r.Name == 'Lead_Count__c') {field.SAP_Name__c = 'NO_OF_LEADCOUNT';}
            if(field.RFQI_Field_Def__r.Name == 'Mold_Compound__c') {field.SAP_Name__c = 'MOLD_COMPOUND_TYPE';}
            if(field.RFQI_Field_Def__r.Name == 'Leadframe_Finish__c') {field.SAP_Name__c = 'LF_FINISH';}
            if(field.RFQI_Field_Def__r.Name == 'Body_Y__c' || field.RFQI_Field_Def__r.Name == 'Body_Size_Y__c') {field.SAP_Name__c = 'DMZ_Y';}
            if(field.RFQI_Field_Def__r.Name == 'Body_X__c' || field.RFQI_Field_Def__r.Name == 'Body_Size_X__c') {field.SAP_Name__c = 'DMZ_X';}
            if(field.RFQI_Field_Def__r.Name == 'Die_Attach__c') {field.SAP_Name__c = 'DIE_ATTACH_MATERIAL_TYPE1';}
            if(field.RFQI_Field_Def__r.Name == 'Die_Size_Y__c' || field.RFQI_Field_Def__r.Name == 'Die_Size_Y_PK__c') {field.SAP_Name__c = 'CHIP_SIZE1_Y';}
            if(field.RFQI_Field_Def__r.Name == 'Die_Size_X__c' || field.RFQI_Field_Def__r.Name == 'Die_Size_X_PK__c') {field.SAP_Name__c = 'CHIP_SIZE1_X';}
        }
        update fieldsToUpdate;
    }

    public static void AMK1832()
    {
        Set<String> statuses = new Set<String>
        {
            RFQItemDao.STATUS_PRICE_COMPLETE,
            RFQItemDao.STATUS_PRICE_ESCALATION,
            RFQItemDao.STATUS_QUOTED,
            RFQItemDao.STATUS_PROGRAM_LOSS,
            RFQItemDao.STATUS_PROGRAM_CANCELED,
            RFQItemDao.STATUS_PROGRAM_WIN,
            RFQItemDao.STATUS_PRODUCTION_WIN,
            RFQItemDao.STATUS_NO_BID
        };
        //update past RFQ items that were cloned and then approved without generating a CPN

        List<RFQ_Item__c> items = [Select Id, Status__c from RFQ_Item__c WHERE Configured_Part_Number__c='' AND Status__c in:statuses LIMIT 1];
        List<RFQ_Item__c> updateList = new List<RFQ_Item__c>();
        for (RFQ_Item__c item : items)
        {
            RFQItemWrapper wrapper = RFQItemDao.getInstance().getWrapperById(item.Id);
            CPN cpn = CPNDao.getInstance().getCPN(wrapper);
            wrapper.rfqItem.Configured_Part_Number__c = cpn.cpnId;            
            updateList.add(wrapper.rfqItem);          

        }
        update updateList;
    }

    public static void AMK1708()
    {
        //add new section for NRE child objects, add two new fields to it
        //deprecate nre "other" fields, update the package family layout
        List<sObject> updateList = new List<sObject>();

        RFQI_Section__c section = new RFQI_Section__c();
        section.Name='NRE Configurations';
        section.Sequence__c = 15000;
        section.Page_Type__c='Both';
        insert section;

        List<RFQI_Field_Def__c> defs = new List<RFQI_Field_Def__c>();
        defs.add(new RFQI_Field_Def__c(Name='Description__c', Object__c='NRE'));
        defs.add(new RFQI_Field_Def__c(Name='Price__c', Type__c='Decimal', Object__c='NRE'));
        insert defs;

        List<RFQI_PF_Field_Def__c> oldDefs = [SELECT Id, Package_Family__c, Deprecated__c FROM RFQI_PF_Field_Def__c WHERE RFQI_Section__r.Name='NRE' and RFQI_Field_Def__r.Name='Other__c'];
        Set<Id> pfsWithOther = new Set<Id>();
        for (RFQI_PF_Field_Def__c def : oldDefs) 
        {
            def.Deprecated__c = true;
            pfsWithOther.add(def.Package_Family__c);
            updateList.add(def);
        }

        List<Package_Family__c> pfs = [SELECT Id, Layout_Version__c FROM Package_Family__c];
        List<RFQI_PF_Field_Def__c> newDefs = new List<RFQI_PF_Field_Def__c>();
        Decimal seq = 0;
        for (Package_Family__c pf : pfs)
        {
            for (RFQI_Field_Def__c def : defs)
            {
                newDefs.add(new RFQI_PF_Field_Def__c(RFQI_Section__c=section.Id, Package_Family__c=pf.Id, RFQI_Field_Def__c=def.Id, Sequence__c=seq));
                seq += 100;
            }
            if (pfsWithOther.contains(pf.Id))
            {
                pf.Layout_Version__c = (pf.Layout_Version__c == null) ? 1 : pf.Layout_Version__c + 1;
                updateList.add(pf);
            }
        }

        insert newDefs;
        update updateList;
    }
    
    public static void dieAreaFieldDef() { 
        RFQI_Field_Def__c dieArea = new RFQI_Field_Def__c(Name = 'Die_Area__c', Object__c = 'Die', Type__c = 'Decimal');
        insert dieArea;
    }
    public static void dieAreaPFFieldDef() {
        List<Package_Family__c> families = [select Id, Name from Package_Family__c where Specific_Die_Configuration_Object__c !=: null];
        List<RFQI_PF_Field_Def__c> fieldDefs = [select Id, RFQI_Field_Def__r.Name, Package_Family__r.Name from RFQI_PF_Field_Def__c];
        Map<string, RFQI_Field_Def__c> fields = FieldBuilderHelper.getFieldDefs();
        for(Package_Family__c family : families) {
            Boolean dieAreaExists = false;
            for(RFQI_PF_Field_Def__c field : fieldDefs) {
                if(field.Package_Family__r.Name == family.Name) {
                    if(field.RFQI_Field_Def__r.Name == 'Die_Area__c') {
                        dieAreaExists = true;
                    }
                }
            }
            if(!dieAreaExists) {
                fieldDefs.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fields.get('Die_Area__c').Id, Package_Family__c = family.Id, CPN_Attribute__c = true, SAP_Name__c = 'DIE_AREA'));
            }
        }
        upsert fieldDefs;
    }

    public static void AMK1849() {
        List<RFQI_PF_Field_Def__c> fields = [select Id, RFQI_Field_Def__r.Name, CPN_Attribute__c from RFQI_PF_Field_Def__c];
        for(RFQI_PF_Field_Def__c field : fields) {
            if(field.RFQI_Field_Def__r.Name == 'Die_Size_Y__c' || field.RFQI_Field_Def__r.Name == 'Die_Size_X__c' || field.RFQI_Field_Def__r.Name == 'Body_Size__c') {field.CPN_Attribute__c = false;}
        }
        update fields;
    }

    public static void AMK1805()
    {
        List<RFQI_PF_Field_Def__c> pfDefs = [SELECT Id, Required__c FROM RFQI_PF_Field_Def__c WHERE RFQI_Field_Def__r.Name='Quote_Request_Type__c' and RFQI_Section__r.Name='Quote Information'];

        for (RFQI_PF_Field_Def__c def : pfDefs) def.Required__c = true;

        update pfDefs;
    }

    public static void AMK2057() {
        RFQI_Field_Def__c fieldDef = new RFQI_Field_Def__c(Name='Lead_Count_fml__c');
        insert fieldDef;

        List<String> nameList = new List<String>
        {
            'Die_1_Size_Dim_X__c',
            'Die_1_Size_Dim_Y__c',
            'Die_1_Thickness__c',
            'Lead_Count__c',
            'Die_Thickness__c',
            'Number_of_BGA_Balls__c',
            'Heatspreader__c',
            'Inline_OS_Test__c',
            'Endline_OS_Test__c'
        };

        List<RFQI_PF_Field_Def__c> defs = [SELECT Id, CPN_Attribute__c, RFQI_Field_Def__r.Name, SAP_Name__c FROM RFQI_PF_Field_Def__c WHERE RFQI_Field_Def__r.Name in :nameList AND Package_Family__r.Product_Group__r.Name =: 'Dual Leadframe'];

        for (RFQI_PF_Field_Def__c def : defs) {
            if(def.RFQI_Field_Def__r.Name == 'Die_Thickness__c') {
                def.CPN_Attribute__c = true;
            }
            if(def.RFQI_Field_Def__r.Name == 'Die_1_Size_Dim_X__c' || def.RFQI_Field_Def__r.Name == 'Die_1_Size_Dim_Y__c' || def.RFQI_Field_Def__r.Name == 'Die_1_Thickness__c' || def.RFQI_Field_Def__r.Name == 'Lead_Count__c') {
                def.CPN_Attribute__c = false;
            }
            if(def.RFQI_Field_Def__r.Name == 'Number_of_BGA_Balls__c') {def.SAP_Name__c = 'NO_OF_LEADCOUNT';}
            if(def.RFQI_Field_Def__r.Name == 'Heatspreader__c') {def.SAP_Name__c = 'BOM_HEATSPREADER';}
            if(def.RFQI_Field_Def__r.Name == 'Inline_OS_Test__c') {def.SAP_Name__c = 'OP_INLINE_OS_TEST';}
            if(def.RFQI_Field_Def__r.Name == 'Endline_OS_Test__c') {def.SAP_Name__c = 'OP_ENDLINE_OS_TEST';}
        }

          List<Package_Family__c> families = [select Id, Name from Package_Family__c where Product_Group__r.Name = 'Dual Leadframe'];

          for(Package_Family__c family : families) {
            if(family.Name != 'CERDIP' && family.Name != 'SZIP J1 Only') {
              defs.add(new RFQI_PF_Field_Def__c(RFQI_Field_Def__c = fieldDef.Id, Package_Family__c = family.Id, CPN_Attribute__c = true, SAP_Name__c = 'NO_OF_LEADCOUNT'));
            }
          }

            upsert defs;
    }

}