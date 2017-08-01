/*************************************************************************
* 
* PURPOSE:  Unit Tests for ForecastUtil
*         
* CLASS: ForecastUtil
* CREATED: 12/20/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Raghuveer Mandali
* 
**************************************************************************/
@isTest
private class ForecastUtilTest {
    
    private static testMethod void testDualForecast() {
        //Bhanu S 26 July 2016
        system.assert(ForecastUtil.getMaxMinForecast('Prototype', 'Dual Leadframe', 'SOIC 150mil Body').get('min') == 1);
        system.assert(ForecastUtil.getMaxMinForecast('Prototype', 'Dual Leadframe', 'SOIC 150mil Body').get('max') == 1);
    
        system.assert(ForecastUtil.getMaxMinForecast('< 50', 'Dual Leadframe', 'SOIC 150mil Body').get('min') == 1);
        system.assert(ForecastUtil.getMaxMinForecast('< 50', 'Dual Leadframe', 'SOIC 150mil Body').get('max') == 50);

        system.assert(ForecastUtil.getMaxMinForecast('50 - 250', 'Dual Leadframe', 'SOIC 150mil Body').get('min') == 50);
        system.assert(ForecastUtil.getMaxMinForecast('50 - 250', 'Dual Leadframe', 'SOIC 150mil Body').get('max') == 250);

        system.assert(ForecastUtil.getMaxMinForecast('250 - 1,000', 'Dual Leadframe', 'SOIC 150mil Body').get('min') == 250);
        system.assert(ForecastUtil.getMaxMinForecast('250 - 1,000', 'Dual Leadframe', 'SOIC 150mil Body').get('max') == 1000);

        system.assert(ForecastUtil.getMaxMinForecast('1,000 - 5,000', 'Dual Leadframe', 'SOIC 150mil Body').get('min') == 1000);
        system.assert(ForecastUtil.getMaxMinForecast('1,000 - 5,000', 'Dual Leadframe', 'SOIC 150mil Body').get('max') == 5000);

        system.assert(ForecastUtil.getMaxMinForecast('5,000 - 10,000', 'Dual Leadframe', 'SOIC 150mil Body').get('min') == 5000);
        system.assert(ForecastUtil.getMaxMinForecast('5,000 - 10,000', 'Dual Leadframe', 'SOIC 150mil Body').get('max') == 10000);

        system.assert(ForecastUtil.getMaxMinForecast('> 10,000', 'Dual Leadframe', 'SOIC 150mil Body').get('min') == 10001);
        system.assert(ForecastUtil.getMaxMinForecast('Engineering Builds', 'Dual Leadframe', 'SOIC 150mil Body').get('max') == 0);
        
    }

    private static testMethod void testSCSPForecast() {
        system.assert(ForecastUtil.getMaxMinForecast('0-5', 'SCSP', 'SCSP').get('min') == 0);
        system.assert(ForecastUtil.getMaxMinForecast('0-5', 'SCSP', 'SCSP').get('max') == 5);

        system.assert(ForecastUtil.getMaxMinForecast('50-100', 'SCSP', 'SCSP').get('min') == 50);
        system.assert(ForecastUtil.getMaxMinForecast('50-100', 'SCSP', 'SCSP').get('max') == 100);

        system.assert(ForecastUtil.getMaxMinForecast('400', 'SCSP', 'SCSP').get('min') == 400);
    }
    
    private static testMethod void testQuadForecast() {
        system.assert(ForecastUtil.getMaxMinForecast('< 50', 'Quad Leadframe', 'TQFP').get('min') == 1);
        system.assert(ForecastUtil.getMaxMinForecast('< 50', 'Quad Leadframe', 'TQFP').get('max') == 50);

        system.assert(ForecastUtil.getMaxMinForecast('< 100', 'Quad Leadframe', 'TQFP').get('min') == 50);
        system.assert(ForecastUtil.getMaxMinForecast('< 100', 'Quad Leadframe', 'TQFP').get('max') == 100);

        system.assert(ForecastUtil.getMaxMinForecast('< 250', 'Quad Leadframe', 'TQFP').get('min') == 100);
        system.assert(ForecastUtil.getMaxMinForecast('< 250', 'Quad Leadframe', 'TQFP').get('max') == 250);

        system.assert(ForecastUtil.getMaxMinForecast('< 500', 'Quad Leadframe', 'TQFP').get('min') == 250);
        system.assert(ForecastUtil.getMaxMinForecast('< 500', 'Quad Leadframe', 'TQFP').get('max') == 500);

        system.assert(ForecastUtil.getMaxMinForecast('< 1,000', 'Quad Leadframe', 'TQFP').get('min') == 500);
        system.assert(ForecastUtil.getMaxMinForecast('< 1,000', 'Quad Leadframe', 'TQFP').get('max') == 1000);

        system.assert(ForecastUtil.getMaxMinForecast('> 1,000', 'Quad Leadframe', 'TQFP').get('min') == 1000);
    }

    private static testMethod void testPBGAForecast() {
        system.assert(ForecastUtil.getMaxMinForecast('<5', 'PBGA', 'PBGA').get('min') == 1);
        system.assert(ForecastUtil.getMaxMinForecast('<5', 'PBGA', 'PBGA').get('max') == 5);

        system.assert(ForecastUtil.getMaxMinForecast('<50', 'PBGA', 'PBGA').get('min') == 5);
        system.assert(ForecastUtil.getMaxMinForecast('<50', 'PBGA', 'PBGA').get('max') == 50);

        system.assert(ForecastUtil.getMaxMinForecast('>50', 'PBGA', 'PBGA').get('min') == 50);
        system.assert(ForecastUtil.getMaxMinForecast('>50', 'PBGA', 'PBGA').get('max') == 100);

        system.assert(ForecastUtil.getMaxMinForecast('>100', 'PBGA', 'PBGA').get('min') == 100);
    }

    private static testMethod void testMLFForecast() {
        //Bhanu S 26 July 2016
        system.assert(ForecastUtil.getMaxMinForecast('0 - 9', 'MLF', 'Saw Dual Row MLF').get('min') == 0);
        system.assert(ForecastUtil.getMaxMinForecast('0 - 9', 'MLF', 'Saw Dual Row MLF').get('max') == 9);
        
        system.assert(ForecastUtil.getMaxMinForecast('10 - 49', 'MLF', 'Saw Dual Row MLF').get('min') == 10);
        system.assert(ForecastUtil.getMaxMinForecast('10 - 49', 'MLF', 'Saw Dual Row MLF').get('max') == 49);
        
        system.assert(ForecastUtil.getMaxMinForecast('50 - 99', 'MLF', 'Saw Dual Row MLF').get('min') == 50);
        system.assert(ForecastUtil.getMaxMinForecast('50 - 99', 'MLF', 'Saw Dual Row MLF').get('max') == 99);
        
        system.assert(ForecastUtil.getMaxMinForecast('100 - 199', 'MLF', 'Saw Dual Row MLF').get('min') == 100);
        system.assert(ForecastUtil.getMaxMinForecast('100 - 199', 'MLF', 'Saw Dual Row MLF').get('max') == 199);
    
        system.assert(ForecastUtil.getMaxMinForecast('1 - 199', 'MLF', 'Saw Dual Row MLF').get('min') == 1);
        system.assert(ForecastUtil.getMaxMinForecast('1 - 199', 'MLF', 'Saw Dual Row MLF').get('max') == 199);

        system.assert(ForecastUtil.getMaxMinForecast('200 - 499', 'MLF', 'Saw Dual Row MLF').get('min') == 200);
        system.assert(ForecastUtil.getMaxMinForecast('200 - 499', 'MLF', 'Saw Dual Row MLF').get('max') == 499);

        system.assert(ForecastUtil.getMaxMinForecast('500 - 749', 'MLF', 'Saw Dual Row MLF').get('min') == 500);
        system.assert(ForecastUtil.getMaxMinForecast('500 - 749', 'MLF', 'Saw Dual Row MLF').get('max') == 749);

        system.assert(ForecastUtil.getMaxMinForecast('750 - 1000', 'MLF', 'Saw Dual Row MLF').get('min') == 750);
        system.assert(ForecastUtil.getMaxMinForecast('750 - 1000', 'MLF', 'Saw Dual Row MLF').get('max') == 1000);

        system.assert(ForecastUtil.getMaxMinForecast('> 1000', 'MLF', 'Saw Dual Row MLF').get('min') == 1001);
    }

    private static testMethod void testFlipChipForecast() {
        system.assert(ForecastUtil.getMaxMinForecast('<01', 'Flip Chip', 'FC BGA').get('min') == 1);

        system.assert(ForecastUtil.getMaxMinForecast('<10', 'Flip Chip', 'FC BGA').get('min') == 1);
        system.assert(ForecastUtil.getMaxMinForecast('<10', 'Flip Chip', 'FC BGA').get('max') == 10);

        system.assert(ForecastUtil.getMaxMinForecast('<25', 'Flip Chip', 'FC BGA').get('min') == 10);
        system.assert(ForecastUtil.getMaxMinForecast('<25', 'Flip Chip', 'FC BGA').get('max') == 25);

        system.assert(ForecastUtil.getMaxMinForecast('<75', 'Flip Chip', 'FC BGA').get('min') == 25);
        system.assert(ForecastUtil.getMaxMinForecast('<75', 'Flip Chip', 'FC BGA').get('max') == 75);

        system.assert(ForecastUtil.getMaxMinForecast('<150', 'Flip Chip', 'FC BGA').get('min') == 75);
        system.assert(ForecastUtil.getMaxMinForecast('<150', 'Flip Chip', 'FC BGA').get('max') == 150);

        system.assert(ForecastUtil.getMaxMinForecast('<250', 'Flip Chip', 'FC BGA').get('min') == 150);
        system.assert(ForecastUtil.getMaxMinForecast('<250', 'Flip Chip', 'FC BGA').get('max') == 250);

        system.assert(ForecastUtil.getMaxMinForecast('<500', 'Flip Chip', 'FC BGA').get('min') == 250);
        system.assert(ForecastUtil.getMaxMinForecast('<500', 'Flip Chip', 'FC BGA').get('max') == 500);

        system.assert(ForecastUtil.getMaxMinForecast('>500', 'Flip Chip', 'FC BGA').get('max') == 500);

        system.assert(ForecastUtil.getMaxMinForecast('<25', 'Flip Chip', 'FC CSP').get('min') == 1);
        system.assert(ForecastUtil.getMaxMinForecast('<25', 'Flip Chip', 'FC CSP').get('max') == 25);

        system.assert(ForecastUtil.getMaxMinForecast('<100', 'Flip Chip', 'FC CSP').get('min') == 25);
        system.assert(ForecastUtil.getMaxMinForecast('<100', 'Flip Chip', 'FC CSP').get('max') == 100);

        system.assert(ForecastUtil.getMaxMinForecast('<500', 'Flip Chip', 'FC CSP').get('min') == 100);
        system.assert(ForecastUtil.getMaxMinForecast('<500', 'Flip Chip', 'FC CSP').get('max') == 500);

        system.assert(ForecastUtil.getMaxMinForecast('<1000', 'Flip Chip', 'FC CSP').get('min') == 500);
        system.assert(ForecastUtil.getMaxMinForecast('<1000', 'Flip Chip', 'FC CSP').get('max') == 1000);

        system.assert(ForecastUtil.getMaxMinForecast('>1000', 'Flip Chip', 'FC CSP').get('max') == 1000);
    }

    private static testMethod void testCABGAForecast() {
        system.assert(ForecastUtil.getMaxMinForecast('0-5', 'CABGA', 'CABGA').get('min') == 0);
        system.assert(ForecastUtil.getMaxMinForecast('0-5', 'CABGA', 'CABGA').get('max') == 5);

        system.assert(ForecastUtil.getMaxMinForecast('5-50', 'CABGA', 'CABGA').get('min') == 5);
        system.assert(ForecastUtil.getMaxMinForecast('5-50', 'CABGA', 'CABGA').get('max') == 50);

        system.assert(ForecastUtil.getMaxMinForecast('50 - 100', 'CABGA', 'CABGA').get('min') == 50);
        system.assert(ForecastUtil.getMaxMinForecast('50 - 100', 'CABGA', 'CABGA').get('max') == 100);

        system.assert(ForecastUtil.getMaxMinForecast('100-200', 'CABGA', 'CABGA').get('min') == 100);
        system.assert(ForecastUtil.getMaxMinForecast('100-200', 'CABGA', 'CABGA').get('max') == 200);

        system.assert(ForecastUtil.getMaxMinForecast('200-500', 'CABGA', 'CABGA').get('min') == 200);
        system.assert(ForecastUtil.getMaxMinForecast('200-500', 'CABGA', 'CABGA').get('max') == 500);

        system.assert(ForecastUtil.getMaxMinForecast('500-1000', 'CABGA', 'CABGA').get('min') == 500);
        system.assert(ForecastUtil.getMaxMinForecast('500-1000', 'CABGA', 'CABGA').get('max') == 1000);

        system.assert(ForecastUtil.getMaxMinForecast('1000-2000', 'CABGA', 'CABGA').get('min') == 1000);
        system.assert(ForecastUtil.getMaxMinForecast('1000-2000', 'CABGA', 'CABGA').get('max') == 2000);

        system.assert(ForecastUtil.getMaxMinForecast('>2000', 'CABGA', 'CABGA').get('max') == 2000);
    }

    private static testMethod void testStandaloneServiceForecast() {
        //Bhanu S 26 July 2016
        system.assert(ForecastUtil.getMaxMinForecast('<10K/wk', 'Standalone Services', 'Die Sales').get('min') == 1);
        system.assert(ForecastUtil.getMaxMinForecast('<10K/wk', 'Standalone Services', 'Die Sales').get('max') == 10);
        
        system.assert(ForecastUtil.getMaxMinForecast('<100', 'Standalone Services', 'Die Sales').get('min') == 10);
        system.assert(ForecastUtil.getMaxMinForecast('<100', 'Standalone Services', 'Die Sales').get('max') == 100);
        
        system.assert(ForecastUtil.getMaxMinForecast('<250', 'Standalone Services', 'Die Sales').get('min') == 100);
        system.assert(ForecastUtil.getMaxMinForecast('<250', 'Standalone Services', 'Die Sales').get('max') == 250);
        
        system.assert(ForecastUtil.getMaxMinForecast('<500', 'Standalone Services', 'Die Sales').get('min') == 250);
        system.assert(ForecastUtil.getMaxMinForecast('<500', 'Standalone Services', 'Die Sales').get('max') == 500);
        
        system.assert(ForecastUtil.getMaxMinForecast('<1000', 'Standalone Services', 'Die Sales').get('min') == 500);
        system.assert(ForecastUtil.getMaxMinForecast('<1000', 'Standalone Services', 'Die Sales').get('max') == 1000);
        
        system.assert(ForecastUtil.getMaxMinForecast('>1000', 'Standalone Services', 'Die Sales').get('min') == 1000);
        system.assert(ForecastUtil.getMaxMinForecast('>1000', 'Standalone Services', 'Die Sales').get('max') == 1000);
        
        system.assert(ForecastUtil.getMaxMinForecast('<1M', 'Standalone Services', 'Die Sales').get('min') == 1);
        system.assert(ForecastUtil.getMaxMinForecast('<1M', 'Standalone Services', 'Die Sales').get('max') == 231);

        system.assert(ForecastUtil.getMaxMinForecast('1M - 5M', 'Standalone Services', 'Die Sales').get('min') == 231);
        system.assert(ForecastUtil.getMaxMinForecast('1M - 5M', 'Standalone Services', 'Die Sales').get('max') == 1154);

        system.assert(ForecastUtil.getMaxMinForecast('5M - 10M', 'Standalone Services', 'Die Sales').get('min') == 1154);
        system.assert(ForecastUtil.getMaxMinForecast('5M - 10M', 'Standalone Services', 'Die Sales').get('max') == 2308);

        system.assert(ForecastUtil.getMaxMinForecast('10M - 20M', 'Standalone Services', 'Die Sales').get('min') == 2308);
        system.assert(ForecastUtil.getMaxMinForecast('10M - 20M', 'Standalone Services', 'Die Sales').get('max') == 4615);

        system.assert(ForecastUtil.getMaxMinForecast('20M', 'Standalone Services', 'Die Sales').get('max') == 4616);

        system.assert(ForecastUtil.getMaxMinForecast('<0.125', 'Standalone Services', AMKVARS.PF_BUMP).get('min') == 0.001);
        system.assert(ForecastUtil.getMaxMinForecast('<0.125', 'Standalone Services', AMKVARS.PF_BUMP).get('max') == 0.125);

        system.assert(ForecastUtil.getMaxMinForecast('<0.350', 'Standalone Services', AMKVARS.PF_BUMP).get('min') == 0.125);
        system.assert(ForecastUtil.getMaxMinForecast('<0.350', 'Standalone Services', AMKVARS.PF_BUMP).get('max') == 0.350);

        system.assert(ForecastUtil.getMaxMinForecast('<0.600', 'Standalone Services', AMKVARS.PF_BUMP).get('min') == 0.350);
        system.assert(ForecastUtil.getMaxMinForecast('<0.600', 'Standalone Services', AMKVARS.PF_BUMP).get('max') == 0.600);

        system.assert(ForecastUtil.getMaxMinForecast('<1.200', 'Standalone Services', AMKVARS.PF_BUMP).get('min') == 0.600);
        system.assert(ForecastUtil.getMaxMinForecast('<1.200', 'Standalone Services', AMKVARS.PF_BUMP).get('max') == 1.200);

        system.assert(ForecastUtil.getMaxMinForecast('<2.500', 'Standalone Services', AMKVARS.PF_BUMP).get('min') == 1.200);
        system.assert(ForecastUtil.getMaxMinForecast('<2.500', 'Standalone Services', AMKVARS.PF_BUMP).get('max') == 2.500);

        system.assert(ForecastUtil.getMaxMinForecast('>2.500', 'Standalone Services', AMKVARS.PF_BUMP).get('max') == 2.500);

        system.assert(ForecastUtil.getMaxMinForecast('<225', 'Standalone Services', AMKVARS.PF_WLCSP).get('min') == 1);
        system.assert(ForecastUtil.getMaxMinForecast('<225', 'Standalone Services', AMKVARS.PF_WLCSP).get('max') == 225);

        system.assert(ForecastUtil.getMaxMinForecast('225-1250', 'Standalone Services', AMKVARS.PF_WLCSP).get('min') == 225);
        system.assert(ForecastUtil.getMaxMinForecast('225-1250', 'Standalone Services', AMKVARS.PF_WLCSP).get('max') == 1250);

        system.assert(ForecastUtil.getMaxMinForecast('1250-2250', 'Standalone Services', AMKVARS.PF_WLCSP).get('min') == 1250);
        system.assert(ForecastUtil.getMaxMinForecast('1250-2250', 'Standalone Services', AMKVARS.PF_WLCSP).get('max') == 2250);

        system.assert(ForecastUtil.getMaxMinForecast('2250-4500', 'Standalone Services', AMKVARS.PF_WLCSP).get('min') == 2250);
        system.assert(ForecastUtil.getMaxMinForecast('2250-4500', 'Standalone Services', AMKVARS.PF_WLCSP).get('max') == 4500);

        system.assert(ForecastUtil.getMaxMinForecast('>4500', 'Standalone Services', AMKVARS.PF_WLCSP).get('max') == 4500);

        system.assert(ForecastUtil.getMaxMinForecast('<500', 'Standalone Services', 'WAFER BACKGRIND').get('min') == 1);
        system.assert(ForecastUtil.getMaxMinForecast('<500', 'Standalone Services', 'WAFER BACKGRIND').get('max') == 500);

        system.assert(ForecastUtil.getMaxMinForecast('<1,500', 'Standalone Services', 'WAFER BACKGRIND').get('min') == 500);
        system.assert(ForecastUtil.getMaxMinForecast('<1,500', 'Standalone Services', 'WAFER BACKGRIND').get('max') == 1500);

        system.assert(ForecastUtil.getMaxMinForecast('<2,500', 'Standalone Services', 'WAFER BACKGRIND').get('min') == 1500);
        system.assert(ForecastUtil.getMaxMinForecast('<2,500', 'Standalone Services', 'WAFER BACKGRIND').get('max') == 2500);

        system.assert(ForecastUtil.getMaxMinForecast('<5,000', 'Standalone Services', 'WAFER BACKGRIND').get('min') == 2500);
        system.assert(ForecastUtil.getMaxMinForecast('<5,000', 'Standalone Services', 'WAFER BACKGRIND').get('max') == 5000);

        system.assert(ForecastUtil.getMaxMinForecast('<10,000', 'Standalone Services', 'WAFER BACKGRIND').get('min') == 5000);
        system.assert(ForecastUtil.getMaxMinForecast('<10,000', 'Standalone Services', 'WAFER BACKGRIND').get('max') == 10000);

        system.assert(ForecastUtil.getMaxMinForecast('>10,000', 'Standalone Services', 'WAFER BACKGRIND').get('max') == 10000);

        system.assert(ForecastUtil.getMaxMinForecast('<1kk/mo', 'Standalone Services', 'Final Test').get('min') == 1);
        system.assert(ForecastUtil.getMaxMinForecast('<1kk/mo', 'Standalone Services', 'Final Test').get('max') == 231);

        system.assert(ForecastUtil.getMaxMinForecast('>1kk/mo', 'Standalone Services', 'Final Test').get('max') == 231);
        
        //Bhanu S 26 July 2016
        system.assert(ForecastUtil.getMaxMinForecast('<250', 'Standalone Services', 'Die Processing Service').get('min') == 1);
        system.assert(ForecastUtil.getMaxMinForecast('<250', 'Standalone Services', 'Die Processing Service').get('max') == 250);
        
        system.assert(ForecastUtil.getMaxMinForecast('<1250', 'Standalone Services', 'Die Processing Service').get('min') == 250);
        system.assert(ForecastUtil.getMaxMinForecast('<1250', 'Standalone Services', 'Die Processing Service').get('max') == 1250);
        
        system.assert(ForecastUtil.getMaxMinForecast('<2500', 'Standalone Services', 'Die Processing Service').get('min') == 1250);
        system.assert(ForecastUtil.getMaxMinForecast('<2500', 'Standalone Services', 'Die Processing Service').get('max') == 2500);
        
        system.assert(ForecastUtil.getMaxMinForecast('<5000', 'Standalone Services', 'Die Processing Service').get('min') == 2500);
        system.assert(ForecastUtil.getMaxMinForecast('<5000', 'Standalone Services', 'Die Processing Service').get('max') == 5000);
        
        system.assert(ForecastUtil.getMaxMinForecast('>5000', 'Standalone Services', 'Die Processing Service').get('min') == 5000);
        system.assert(ForecastUtil.getMaxMinForecast('>5000', 'Standalone Services', 'Die Processing Service').get('max') == 5000);
        
        system.assert(ForecastUtil.getMaxMinForecast('<250', 'Standalone Services', 'Die Processing Service (WLCSP)').get('min') == 1);
        system.assert(ForecastUtil.getMaxMinForecast('<250', 'Standalone Services', 'Die Processing Service (WLCSP)').get('max') == 250);
        
        system.assert(ForecastUtil.getMaxMinForecast('<1250', 'Standalone Services', 'Die Processing Service (WLCSP)').get('min') == 250);
        system.assert(ForecastUtil.getMaxMinForecast('<1250', 'Standalone Services', 'Die Processing Service (WLCSP)').get('max') == 1250);
        
        system.assert(ForecastUtil.getMaxMinForecast('<2500', 'Standalone Services', 'Die Processing Service (WLCSP)').get('min') == 1250);
        system.assert(ForecastUtil.getMaxMinForecast('<2500', 'Standalone Services', 'Die Processing Service (WLCSP)').get('max') == 2500);
        
        system.assert(ForecastUtil.getMaxMinForecast('<5000', 'Standalone Services', 'Die Processing Service (WLCSP)').get('min') == 2500);
        system.assert(ForecastUtil.getMaxMinForecast('<5000', 'Standalone Services', 'Die Processing Service (WLCSP)').get('max') == 5000);
        
        system.assert(ForecastUtil.getMaxMinForecast('>5000', 'Standalone Services', 'Die Processing Service (WLCSP)').get('min') == 5000);
        system.assert(ForecastUtil.getMaxMinForecast('>5000', 'Standalone Services', 'Die Processing Service (WLCSP)').get('max') == 5000);
    
        
        system.assert(ForecastUtil.getMaxMinForecast('<500', 'Standalone Services', 'WLCSP').get('min') == 1);
        system.assert(ForecastUtil.getMaxMinForecast('<500', 'Standalone Services', 'WLCSP').get('max') == 115);

        system.assert(ForecastUtil.getMaxMinForecast('<1,500', 'Standalone Services', 'WLCSP').get('min') == 116);
        system.assert(ForecastUtil.getMaxMinForecast('<1,500', 'Standalone Services', 'WLCSP').get('max') == 346);

        system.assert(ForecastUtil.getMaxMinForecast('<2,500', 'Standalone Services', 'WLCSP').get('min') == 347);
        system.assert(ForecastUtil.getMaxMinForecast('<2,500', 'Standalone Services', 'WLCSP').get('max') == 577);
        
        system.assert(ForecastUtil.getMaxMinForecast('<5,000', 'Standalone Services', 'WLCSP').get('min') == 578);
        system.assert(ForecastUtil.getMaxMinForecast('<5,000', 'Standalone Services', 'WLCSP').get('max') == 1154);

        system.assert(ForecastUtil.getMaxMinForecast('<10,000', 'Standalone Services', 'WLCSP').get('min') == 1155);
        system.assert(ForecastUtil.getMaxMinForecast('<10,000', 'Standalone Services', 'WLCSP').get('max') == 2307);

        system.assert(ForecastUtil.getMaxMinForecast('>10,000', 'Standalone Services', 'WLCSP').get('min') == 2308);
        system.assert(ForecastUtil.getMaxMinForecast('>10,000', 'Standalone Services', 'WLCSP').get('max') == 2308);
    }
    
    private static testMethod void testPG_ATM() {
        //Bhanu S 26 July 2016
        system.assert(ForecastUtil.getMaxMinForecast('< 500', 'Power Discrete', 'SOD128FL').get('min') == 1);
        system.assert(ForecastUtil.getMaxMinForecast('< 500', 'Power Discrete', 'SOD128FL').get('max') == 500);
        
        system.assert(ForecastUtil.getMaxMinForecast('500-1500', 'Power Discrete', 'SOD128FL').get('min') == 500);
        system.assert(ForecastUtil.getMaxMinForecast('500-1500', 'Power Discrete', 'SOD128FL').get('max') == 1500);
        
        system.assert(ForecastUtil.getMaxMinForecast('> 1500', 'Power Discrete', 'SOD128FL').get('min') == 1500);
        system.assert(ForecastUtil.getMaxMinForecast('> 1500', 'Power Discrete', 'SOD128FL').get('max') == 1500);

    }
    
}