/*************************************************************************
* 
* PURPOSE:  this class seeds fresh SAP Translation data into  
*           environments. This data is used by the
*           SAPInterface module to determine translations for data
*           sent over from SAP
*         
* CLASS: SAPInstaller
* CREATED: 05/14/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Jason Swenski
* 
**************************************************************************/
global class SAPInstaller {

    global static void install() {
        List<SAP_Translation__c> translations = new List<SAP_Translation__c>();
        addKATR2(translations);
        addKATR5(translations);
        addKATR7(translations);
        addZZIKKATR11(translations);
        addZZIKKATR12(translations);
        addZZIKKATR13(translations);
        addZZIKKATR14(translations);
        addZZIKKATR15(translations);
        addZZIKKATR30(translations);
        addE1KNVVMKDGRP(translations);
        addE1KNVVMVKBUR(translations);
        addE1KNVVMINCO1(translations);
        addE1KNVPMPARVW(translations);
        addE1KNVVMZTERM(translations);
        insert translations;
    }
    
    global static void clean() {
       
        delete [select Id from SAP_Translation__c];
    }

    private static void addKATR2(List<SAP_Translation__c> translations) {
    	translations.add(new SAP_Translation__c(Code__c='E1KNA1M.KATR2.',Value__c='Non Combo Customer'));
    	translations.add(new SAP_Translation__c(Code__c='E1KNA1M.KATR2.01',Value__c='Combo B + P'));
    	translations.add(new SAP_Translation__c(Code__c='E1KNA1M.KATR2.02',Value__c='Combo B + P + R'));
    	translations.add(new SAP_Translation__c(Code__c='E1KNA1M.KATR2.03',Value__c='Combo A + T'));
    	translations.add(new SAP_Translation__c(Code__c='E1KNA1M.KATR2.04',Value__c='Combo P + R'));
    	
    	translations.add(new SAP_Translation__c(Code__c='E1KNA1M.KATR2.11',Value__c='Combo P+R & A+T'));
    	translations.add(new SAP_Translation__c(Code__c='E1KNA1M.KATR2.12',Value__c='Combo B+P & A+T'));
    	translations.add(new SAP_Translation__c(Code__c='E1KNA1M.KATR2.13',Value__c='Combo B+P+R & A+T'));
    }
    
    private static void addKATR5(List<SAP_Translation__c> translations) {
    	translations.add(new SAP_Translation__c(Code__c='E1KNA1M.KATR5.',Value__c='Non T-Stock Customer'));
    	translations.add(new SAP_Translation__c(Code__c='E1KNA1M.KATR5.01',Value__c='Bill after BE'));
    	translations.add(new SAP_Translation__c(Code__c='E1KNA1M.KATR5.02',Value__c='Bill after FE & BE'));
    }
    
    private static void addKATR7(List<SAP_Translation__c> translations) {
    	translations.add(new SAP_Translation__c(Code__c='E1KNA1M.KATR7.',Value__c='Bill rejects w/ good'));
    	translations.add(new SAP_Translation__c(Code__c='E1KNA1M.KATR7.001',Value__c='Bill rejects seperate'));
    	translations.add(new SAP_Translation__c(Code__c='E1KNA1M.KATR7.002',Value__c='Do not bill rejects'));
    	translations.add(new SAP_Translation__c(Code__c='E1KNA1M.KATR7.003',Value__c='Bill Rej. Shipments'));
    }
    
    private static void addZZIKKATR11(List<SAP_Translation__c> translations) {
    	translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNA11.ZISKKATR.ZZIKATR11.',Value__c='Transactionally'));
    	translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNA11.ZISKKATR.ZZIKATR11.001',Value__c='Weekly'));
    	translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNA11.ZISKKATR.ZZIKATR11.002',Value__c='Monthly'));
    	translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNA11.ZISKKATR.ZZIKATR11.003',Value__c='Inclusive'));
    }
    
    private static void addZZIKKATR12(List<SAP_Translation__c> translations) {
    	translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNA11.ZISKKATR.ZZIKATR12.',Value__c='Transactionally'));
    	translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNA11.ZISKKATR.ZZIKATR12.001',Value__c='Weekly'));
    	translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNA11.ZISKKATR.ZZIKATR12.002',Value__c='Monthly'));
    	translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNA11.ZISKKATR.ZZIKATR12.003',Value__c='Inclusive'));
    }
    
    private static void addZZIKKATR13(List<SAP_Translation__c> translations) {
    	translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNA11.ZISKKATR.ZZIKATR13.',Value__c='Transactionally'));
    	translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNA11.ZISKKATR.ZZIKATR13.001',Value__c='Weekly'));
    	translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNA11.ZISKKATR.ZZIKATR13.002',Value__c='Monthly'));
    	translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNA11.ZISKKATR.ZZIKATR13.003',Value__c='Inclusive'));
    }
    
    private static void addZZIKKATR14(List<SAP_Translation__c> translations) {
    	translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNA11.ZISKKATR.ZZIKATR14.',Value__c='Transactionally'));
    	translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNA11.ZISKKATR.ZZIKATR14.001',Value__c='Weekly'));
    	translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNA11.ZISKKATR.ZZIKATR14.002',Value__c='Monthly'));
    	translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNA11.ZISKKATR.ZZIKATR14.003',Value__c='Inclusive'));
    }
    
    private static void addZZIKKATR15(List<SAP_Translation__c> translations) {
    	translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNA11.ZISKKATR.ZZIKATR15.',Value__c='Transactionally'));
    	translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNA11.ZISKKATR.ZZIKATR15.001',Value__c='Weekly'));
    	translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNA11.ZISKKATR.ZZIKATR15.002',Value__c='Monthly'));
    	translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNA11.ZISKKATR.ZZIKATR15.003',Value__c='Inclusive'));
    }
    
    private static void addZZIKKATR30(List<SAP_Translation__c> translations) {
    	translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNA11.ZISKKATR.ZZIKATR30.',Value__c='Bill Scrap'));
    	translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNA11.ZISKKATR.ZZIKATR30.001',Value__c='Do not bill scrap'));
    	translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNA11.ZISKKATR.ZZIKATR30.002',Value__c='Bill scrap shipment'));
    }
    
    private static void addE1KNVVMKDGRP(List<SAP_Translation__c> translations) {
    	translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.KDGRP.Z1',Value__c='ATK Local'));
    	translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.KDGRP.Z2',Value__c='ATI Corporate'));
    	translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.KDGRP.Z3',Value__c='Affliate'));
    	translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.KDGRP.Z4',Value__c='ATJ'));
    	translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.KDGRP.Z5',Value__c='ATSG'));
    	translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.KDGRP.Z6',Value__c='ATT'));
    	translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.KDGRP.Z7',Value__c='T5'));
    	translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.KDGRP.Z8',Value__c='ATC'));
    	translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.KDGRP.Z9',Value__c='AIC'));
    }
    
    private static void addE1KNVVMVKBUR(List<SAP_Translation__c> translations) {
    	translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.VKBUR.0001', Value__c='USA West 1'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.VKBUR.0002', Value__c='USA West 2'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.VKBUR.0003', Value__c='USA East'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.VKBUR.0004', Value__c='USA Southwest'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.VKBUR.0005', Value__c='USA East-Discontinue'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.VKBUR.0006', Value__c='Europe'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.VKBUR.0007', Value__c='Korea'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.VKBUR.0008', Value__c='Japan'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.VKBUR.0009', Value__c='China'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.VKBUR.0010', Value__c='Taiwan'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.VKBUR.0011', Value__c='Singapore'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.VKBUR.0012', Value__c='Emerging'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.VKBUR.0013', Value__c='US Fabless'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.VKBUR.0014', Value__c='US IDM'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.VKBUR.0015', Value__c='Asia'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.VKBUR.0016', Value__c='Intercompany'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.VKBUR.0017', Value__c='Royalty'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.VKBUR.0018', Value__c='FI Only'));
    }
    
    private static void addE1KNVVMINCO1(List<SAP_Translation__c> translations) {
    	translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.INCO1.BST', Value__c='Best Way'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.INCO1.CFR', Value__c='Costs and freight'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.INCO1.CIF', Value__c='Costs, insurance & freight'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.INCO1.CIP', Value__c='Carriage and insurance paid to'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.INCO1.CPT', Value__c='Carriage paid to'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.INCO1.DAF', Value__c='Delivered at frontier'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.INCO1.DAP', Value__c='Delivered at place'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.INCO1.DAT', Value__c='Delivered at terminal'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.INCO1.DDP', Value__c='Delivered Duty Paid'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.INCO1.DDU', Value__c='Delivered Duty Unpaid'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.INCO1.DEQ', Value__c='Delivered ex quay (duty paid)'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.INCO1.DES', Value__c='Delivered ex ship'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.INCO1.EXW', Value__c='Ex Works'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.INCO1.FAS', Value__c='Free Alongside Ship'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.INCO1.FCA', Value__c='Free Carrier'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.INCO1.FH', Value__c='Free house'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.INCO1.FOB', Value__c='Free on board'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.INCO1.UN', Value__c='Not Free'));
    }
    
    private static void addE1KNVPMPARVW(List<SAP_Translation__c> translations) {
    	translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVPM.PARVW.ZA', Value__c='Account Manager'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVPM.PARVW.ZC', Value__c='Collection Rep'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVPM.PARVW.ZD', Value__c='Executive VP Admin'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVPM.PARVW.ZE', Value__c='Executive VP'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVPM.PARVW.ZF', Value__c='Sales Administrator'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVPM.PARVW.ZG', Value__c='Regional VP CSM'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVPM.PARVW.ZH', Value__c='Regional VP Admin'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVPM.PARVW.ZI', Value__c='Secondary Cust Rep'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVPM.PARVW.ZJ', Value__c='Sec. Account Manage'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVPM.PARVW.ZK', Value__c='Customer Rep'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVPM.PARVW.ZL', Value__c='Central Quote Rep'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVPM.PARVW.ZN', Value__c='Mid-Level Manager'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVPM.PARVW.ZO', Value__c='Test Sales Super Us'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVPM.PARVW.ZP', Value__c='TPM/TTPM'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVPM.PARVW.ZR', Value__c='Regional VP'));
    }
    
    private static void addE1KNVVMZTERM(List<SAP_Translation__c> translations) {
    	
    	translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.ZTERM.0000', Value__c='Manual Due Date'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.ZTERM.0001', Value__c='Immediately Due Net'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.ZTERM.A001', Value__c='30 days after shipment'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.ZTERM.A002', Value__c='with certification'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.ZTERM.A120', Value__c='Net 120'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.ZTERM.A125', Value__c='Net 125'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.ZTERM.A150', Value__c='Net 150'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.ZTERM.AA00', Value__c='Immediately Due'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.ZTERM.AA07', Value__c='Net 7'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.ZTERM.AA15', Value__c='Net 15'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.ZTERM.AA30', Value__c='Net 30'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.ZTERM.AA45', Value__c='Net 45'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.ZTERM.AA60', Value__c='Net 60'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.ZTERM.AA90', Value__c='Due Net 90 days'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.ZTERM.AAA0', Value__c='Full Advanced Pmt'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.ZTERM.AAB0', Value__c='Partial Advanced Pmt'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.ZTERM.B001', Value__c='30 days after shipment'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.ZTERM.B002', Value__c='with certification'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.ZTERM.C001', Value__c='30 days after shipment'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.ZTERM.C002', Value__c='with certification'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.ZTERM.D001', Value__c='30 days after shipment'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.ZTERM.D002', Value__c='with certification'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.ZTERM.E001', Value__c='15 days aro'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.ZTERM.E002', Value__c='45 days aro'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.ZTERM.E003', Value__c='30 days after certification'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.ZTERM.F001', Value__c='before shipment'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.ZTERM.F002', Value__c='with certification'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.ZTERM.G001', Value__c='before shipment'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.ZTERM.G002', Value__c='with certification'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.ZTERM.H001', Value__c='before shipment'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.ZTERM.H002', Value__c='with certification'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.ZTERM.I001', Value__c='before shipment'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.ZTERM.I002', Value__c='with certification'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.ZTERM.KK30', Value__c='30%DP, 60%, 10% Retention'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.ZTERM.KK90', Value__c='90% Upon completion, 10% retention'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.ZTERM.M015', Value__c='15 Day After Month End'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.ZTERM.M030', Value__c='30 Day After Month End'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.ZTERM.M045', Value__c='45 Day After Month End'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.ZTERM.M060', Value__c='60 Day After Month End'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.ZTERM.M090', Value__c='90 Day After Month End'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.ZTERM.STAK', Value__c='90TS10TC'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.ZTERM.STBK', Value__c='85TS15TC'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.ZTERM.STCK', Value__c='80TS20TC'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.ZTERM.STCP', Value__c='80TD20TC'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.ZTERM.STDK', Value__c='70TS30TC'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.ZTERM.STKK', Value__c='90T30S10TC'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.ZTERM.STKP', Value__c='90% due imm,10%30D'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.ZTERM.STLK', Value__c='85T30S15TC'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.ZTERM.STMK', Value__c='80T30S20TC'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.ZTERM.STNK', Value__c='70T30S30TC'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.ZTERM.STVK', Value__c='60TA40T30C'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.ZTERM.T1CK', Value__c='100T30C'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.ZTERM.T1SK', Value__c='100T30S'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.ZTERM.T2CK', Value__c='100T60C'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.ZTERM.T2SK', Value__c='100T60S'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.ZTERM.T3CK', Value__c='100T90C'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.ZTERM.T3SK', Value__c='100T90S'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.ZTERM.T4CK', Value__c='100T120C'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.ZTERM.T4SK', Value__c='100T120S'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.ZTERM.T5CK', Value__c='100T150C'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.ZTERM.T5SK', Value__c='100T150S'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.ZTERM.T6CK', Value__c='100T180C'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.ZTERM.T6SK', Value__c='100T180S'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.ZTERM.T7CK', Value__c='100T210C'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.ZTERM.T7SK', Value__c='100T210S'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.ZTERM.TA30', Value__c='Net 30 Days, Cut Day Month-end'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.ZTERM.TA45', Value__c='Net 45 Days, Cut Day Month-end'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.ZTERM.TA60', Value__c='Net 60 Days, Cut Day Month-end'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.ZTERM.TA65', Value__c='Net 65 Days, Cut Day Month-end'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.ZTERM.TA70', Value__c='Net 70 Days, Cut Day Month-end'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.ZTERM.TA90', Value__c='Net 90 Days, Cut Day Month-end'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.ZTERM.TACK', Value__c='100T45C'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.ZTERM.TASK', Value__c='100T45S'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.ZTERM.TB60', Value__c='Net 60 Days, Cut Day 25th'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.ZTERM.TB70', Value__c='Net 70 Days, Cut Day 25th'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.ZTERM.TOCK', Value__c='100T365C'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.ZTERM.TOSK', Value__c='100T365S'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.ZTERM.TT00', Value__c='Net 0 days , Pay immediatly'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.ZTERM.TT30', Value__c='Net 30 days'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.ZTERM.TT45', Value__c='Net 45 days'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.ZTERM.TT60', Value__c='Net 60 days'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.ZTERM.Z105', Value__c='Net 105'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.ZTERM.Z15N', Value__c='15th of Next Mth'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.ZTERM.ZN30', Value__c='2%/10, Net 30'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.ZTERM.ZN45', Value__c='2%/10, Net 45'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.ZTERM.ZN60', Value__c='60 Days/Mth End'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.ZTERM.ZZ07', Value__c='Net 07'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.ZTERM.ZZ10', Value__c='Net 10'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.ZTERM.ZZ15', Value__c='Net 15'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.ZTERM.ZZ20', Value__c='Net 20'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.ZTERM.ZZ25', Value__c='Net 25'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.ZTERM.ZZ35', Value__c='Net 35'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.ZTERM.ZZ75', Value__c='Net 75'));
		translations.add(new SAP_Translation__c(Code__c='E1KNA1M.E1KNVVM.ZTERM.ZZPP', Value__c='Pre Payment'));
    
    }

}