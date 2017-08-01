/*************************************************************************
* 
* PURPOSE:  Utility class for determining Forecast Min/Max/Median
*         
* CLASS: ForecastUtil
* CREATED: 12/20/2013 Ethos Solutions - www.ethos.com
* AUTHOR: Raghuveer Mandali
* 
**************************************************************************/
public class ForecastUtil {

    public static final Decimal ADDSERVICE_HIGHEST_VOL_FACTOR = 1.25;

	public static Map<String, Decimal> getMaxMinForecast(String forecast, String pg, String pf) {
        Map<String, Decimal> vals = new Map<String, Decimal>();
        if(forecast == 'Prototype') {
            vals.put('max', 1);
            vals.put('min', 1);
        }
        if(pg == 'Unlisted' || pg == 'MEMS' || pg == 'Dual Leadframe') {
            if(forecast == '< 50') {
                vals.put('max', 50);
                vals.put('min', 1);
            }
            else if(forecast == '50 - 250') {
                vals.put('max', 250);
                vals.put('min', 50);
            }
            else if(forecast == '250 - 1,000') {
                vals.put('max', 1000);
                vals.put('min', 250);
            }
            else if(forecast == '1,000 - 5,000') {
                vals.put('max', 5000);
                vals.put('min', 1000);
            }
            else if(forecast == '5,000 - 10,000') {
                vals.put('max', 10000);
                vals.put('min', 5000);
            }
            else if(forecast == '> 10,000') {
                vals.put('max', 10001);
                vals.put('min', 10001);
                vals.put('test', 10000 * ADDSERVICE_HIGHEST_VOL_FACTOR);
            }
            else if(forecast == 'Engineering Builds') {
                vals.put('max', 0);
                vals.put('min', 0);
            }
        }
        else if(pg == 'SCSP') {
            if(forecast == '0-5') {
                vals.put('max', 5);
                vals.put('min', 0);
            }
            else if(forecast == '50-100') {
                vals.put('max', 100);
                vals.put('min', 50);
            }
            else {
                //AMK-2279 - do not multiply the higest value by 1.25 since they are not ranges,
                //they are just numbers
                vals.put('max', Decimal.valueOf(forecast));
                vals.put('min', Decimal.valueOf(forecast));
                vals.put('test', Decimal.valueOf(forecast));
            }
        }
        else if(pg == 'Quad Leadframe') {
            if(forecast == '< 50') {
                vals.put('max', 50);
                vals.put('min', 1);
            }
            else if(forecast == '< 100') {
                vals.put('max', 100);
                vals.put('min', 50);
            }
            else if(forecast == '< 250') {
                vals.put('max', 250);
                vals.put('min', 100);
            }
            else if(forecast == '< 500') {
                vals.put('max', 500);
                vals.put('min', 250);
            }
            else if(forecast == '< 1,000') {
                vals.put('max', 1000);
                vals.put('min', 500);
            }
            else if(forecast == '> 1,000') {
                vals.put('max', 1000);
                vals.put('min', 1000);
                vals.put('test', 1000 * ADDSERVICE_HIGHEST_VOL_FACTOR);
            }
        }
        else if(pg == 'PBGA'){
            if(forecast == '<5') {
                vals.put('max', 5);
                vals.put('min', 1);
            }
            else if(forecast == '<50') {
                vals.put('max', 50);
                vals.put('min', 5);
            }
            else if(forecast == '>50') {
                vals.put('max', 100);
                vals.put('min', 50);
            }
            else if(forecast == '>100') {
                vals.put('max', 100);
                vals.put('min', 100);
                vals.put('test', 100 * ADDSERVICE_HIGHEST_VOL_FACTOR);
            }
        }
        else if(pg == 'MLF'){
            if (forecast == '0 - 9')
            {
                vals.put('max', 9);
                vals.put('min', 0);

            }
            else if (forecast == '10 - 49')
            {
                vals.put('max', 49);
                vals.put('min', 10);

            }
            else if (forecast == '50 - 99')
            {
                vals.put('max', 99);
                vals.put('min', 50);

            }
            else if (forecast == '100 - 199')
            {
                vals.put('max', 199);
                vals.put('min', 100);

            }
            else if (forecast == '1 - 199')
            {
                vals.put('max', 199);
                vals.put('min', 1);

            }
            else if (forecast == '200 - 499')
            {
                vals.put('max', 499);
                vals.put('min', 200);

            }
            else if (forecast == '500 - 749')
            {
                vals.put('max', 749);
                vals.put('min', 500);

            }
            else if (forecast == '750 - 1000')
            {
                vals.put('max', 1000);
                vals.put('min', 750);

            }
            else if (forecast == '> 1000')
            {
                vals.put('max', 1001);
                vals.put('min', 1001);
                vals.put('test', 1000 * ADDSERVICE_HIGHEST_VOL_FACTOR);
            }
            
        }
        else if(pg == 'Flip Chip'){
            if(pf == 'FC BGA') {
                if(forecast == '<01') {
                    vals.put('min', 1);
                    vals.put('max', 1);
                }
                else if(forecast == '<10') {
                    vals.put('max', 10);
                    vals.put('min', 1);
                }
                else if(forecast == '<25') {
                    vals.put('max', 25);
                    vals.put('min', 10);
                }
                else if(forecast == '<75') {
                    vals.put('max', 75);
                    vals.put('min', 25);
                }
                else if(forecast == '<150') {
                    vals.put('max', 150);
                    vals.put('min', 75);
                }
                else if(forecast == '<250') {
                    vals.put('max', 250);
                    vals.put('min', 150);
                }
                else if(forecast == '<500') {
                    vals.put('max', 500);
                    vals.put('min', 250);
                }
                else if(forecast == '>500') {
                    vals.put('max', 500);
                    vals.put('min', 500);
                vals.put('test', 500 * ADDSERVICE_HIGHEST_VOL_FACTOR);
                }
            }
            else {
                if(forecast == '<25') {
                    vals.put('max', 25);
                    vals.put('min', 1);
                }
                else if(forecast == '<100') {
                    vals.put('max', 100);
                    vals.put('min', 25);
                }
                else if(forecast == '<500') {
                    vals.put('max', 500);
                    vals.put('min', 100);
                } 
                else if(forecast == '<1000') {
                    vals.put('max', 1000);
                    vals.put('min', 500);
                }
                else if(forecast == '>1000') {
                    vals.put('max', 1000);
                    vals.put('min', 1000);
                vals.put('test', 1000 * ADDSERVICE_HIGHEST_VOL_FACTOR);
                }
            }
        }
        else if(pg == 'CABGA') {
            if(forecast == '0-5') {
                vals.put('max', 5);
                vals.put('min', 0);
            }
            else if(forecast == '5-50') {
                vals.put('max', 50);
                vals.put('min', 5);
            }
            else if(forecast == '50 - 100') {
                vals.put('max', 100);
                vals.put('min', 50);
            }
            else if(forecast == '100-200') {
                vals.put('max', 200);
                vals.put('min', 100);
            } 
            else if(forecast == '200-500') {
                vals.put('max', 500);
                vals.put('min', 200);
            }
            else if(forecast == '500-1000') {
                vals.put('max', 1000);
                vals.put('min', 500);
            }
            else if(forecast == '1000-2000') {
                vals.put('max', 2000);
                vals.put('min', 1000);
            }
            else if(forecast == '>2000') {
                vals.put('max', 2000);
                vals.put('min', 2000);
                vals.put('test', 2000 * ADDSERVICE_HIGHEST_VOL_FACTOR);
            }
        }
        else if(pg == 'Standalone Services' && pf != AMKVARS.PF_TEST) {
            if(pf == 'Die Sales' || pf == AMKVARS.PF_WLCSP) {
                if(forecast == '<10K/wk'){
                    vals.put('max', 10);
                    vals.put('min', 1);
                }
                else if(forecast == '<100'){
                    vals.put('max', 100);
                    vals.put('min', 10);
                }
                else if(forecast == '<250'){
                    vals.put('max', 250);
                    vals.put('min', 100);
                }
                else if(forecast == '<500'){
                    vals.put('max', 500);
                    vals.put('min', 250);
                }
                else if(forecast == '<1000'){
                    vals.put('max', 1000);
                    vals.put('min', 500);
                }
                else if(forecast == '>1000') {
                    vals.put('max', 1000);
                    vals.put('min', 1000);
                    vals.put('test', 1000 * ADDSERVICE_HIGHEST_VOL_FACTOR);
                }
                else if(forecast == '<225'){
                    vals.put('max', 225);
                    vals.put('min', 1);
                }
                else if(forecast == '225-1250'){
                    vals.put('max', 1250);
                    vals.put('min', 225);
                }
                else if(forecast == '1250-2250'){
                    vals.put('max', 2250);
                    vals.put('min', 1250);
                }
                else if(forecast == '2250-4500'){
                    vals.put('max', 4500);
                    vals.put('min', 2250);
                }
                else if(forecast == '>4500') {
                    vals.put('max', 4500);
                    vals.put('min', 4500);
                    vals.put('test', 4500 * ADDSERVICE_HIGHEST_VOL_FACTOR);
                }
                else if(forecast == '<1M') {
                    vals.put('max', 231);
                    vals.put('min', 1);
                }
                else if(forecast == '1M - 5M') {
                    vals.put('max', 1154);
                    vals.put('min', 231);
                }
                else if(forecast == '5M - 10M') {
                    vals.put('max', 2308);
                    vals.put('min', 1154);
                }
                else if(forecast == '10M - 20M') {
                    vals.put('max', 4615);
                    vals.put('min', 2308);
                }
                else if(forecast == '20M' || forecast == '>20M') {
                    vals.put('max', 4616);
                    vals.put('min', 4616);
                    vals.put('test', 4616 * ADDSERVICE_HIGHEST_VOL_FACTOR);
                }
            }
            else if(pf == 'Die Processing Service' || pf == 'Die Processing Service (WLCSP)'){
                if(forecast == '<250'){
                    vals.put('max', 250);
                    vals.put('min', 1);
                }
                else if(forecast == '<1250'){
                    vals.put('max', 1250);
                    vals.put('min', 250);
                }
                else if(forecast == '<2500'){
                    vals.put('max', 2500);
                    vals.put('min', 1250);
                }
                else if(forecast == '<5000'){
                    vals.put('max', 5000);
                    vals.put('min', 2500);
                }
                else if(forecast == '>5000'){
                    vals.put('max', 5000);
                    vals.put('min', 5000);
                    vals.put('test', 5000 * ADDSERVICE_HIGHEST_VOL_FACTOR);
                }
            }
            else if(pf == 'WLCSP') {
                if(forecast == '<500') {
                    vals.put('max', 115);
                    vals.put('min', 1);
                }
                else if(forecast == '<1,500') {
                    vals.put('max', 346);
                    vals.put('min', 116);
                }
                else if(forecast == '<2,500') {
                    vals.put('max', 577);
                    vals.put('min', 347);
                }
                else if(forecast == '<5,000') {
                    vals.put('max', 1154);
                    vals.put('min', 578);
                }
                else if(forecast == '<10,000') {
                    vals.put('max', 2307);
                    vals.put('min', 1155);
                }
                else if(forecast == '>10,000') {
                    vals.put('max', 2308);
                    vals.put('min', 2308);
                    vals.put('test', 2308 * ADDSERVICE_HIGHEST_VOL_FACTOR);
                }
            }
            else if(pf == AMKVARS.PF_BUMP) {
                if(forecast == '<0.125') {
                    vals.put('max', 0.125);
                    vals.put('min', 0.001);
                }
                else if(forecast == '<0.350') {
                    vals.put('max', 0.350);
                    vals.put('min', 0.125);
                }
                else if(forecast == '<0.600') {
                    vals.put('max', 0.600);
                    vals.put('min', 0.350);
                }
                else if(forecast == '<1.200') {
                    vals.put('max', 1.200);
                    vals.put('min', 0.600);
                }
                else if(forecast == '<2.500') {
                    vals.put('max', 2.500);
                    vals.put('min', 1.200);
                }
                else if(forecast == '>2.500') {
                    vals.put('max', 2.500);
                    vals.put('min', 2.500);
                    vals.put('test', 2.500 * ADDSERVICE_HIGHEST_VOL_FACTOR);
                }
            }
            else if(pf == 'LEAD FINISH' || pf == 'WAFER BACKGRIND') {
                if(forecast == '<500') {
                    vals.put('max', 500);
                    vals.put('min', 1);
                }
                else if(forecast == '<1,500') {
                    vals.put('max', 1500);
                    vals.put('min', 500);
                }
                else if(forecast == '<2,500') {
                    vals.put('max', 2500);
                    vals.put('min', 1500);
                }
                else if(forecast == '<5,000') {
                    vals.put('max', 5000);
                    vals.put('min', 2500);
                }
                else if(forecast == '<10,000') {
                    vals.put('max', 10000);
                    vals.put('min', 5000);
                }
                else if(forecast == '>10,000') {
                    vals.put('max', 10000);
                    vals.put('min', 10000);
                    vals.put('test', 10000 * ADDSERVICE_HIGHEST_VOL_FACTOR);
                }
            }
            else {
                if(forecast == '<1kk/mo') {
                    vals.put('max', 231);
                    vals.put('min', 1);
                }
                else if(forecast == '>1kk/mo') {
                    vals.put('max', 231);
                    vals.put('min', 231);
                    vals.put('test', 231 * ADDSERVICE_HIGHEST_VOL_FACTOR);
                }
            }
        }
        else if(pg == 'Advanced Product Development' || pf == AMKVARS.PF_TEST) {
            vals.put('max', Decimal.valueOf(forecast));
            vals.put('min',  Decimal.valueOf(forecast));
        }
        else if(pg == AMKVARS.PG_ATM) {
            if(forecast == '< 500') {
                vals.put('max', 500);
                vals.put('min', 1);
            }
            else if(forecast == '500-1500') {
                vals.put('max', 1500);
                vals.put('min', 500);
            }
            else if(forecast == '> 1500') {
                vals.put('max', 1500);
                vals.put('min', 1500);
                vals.put('test', 231 * ADDSERVICE_HIGHEST_VOL_FACTOR);
            }
        }
        //if test value was not specified, default to max volume
        if (!vals.keySet().contains('test')) vals.put('test', vals.get('max'));

        return vals;
    }
}