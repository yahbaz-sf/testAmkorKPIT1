trigger FCBGABallCountFormula on RFQI_fcBGA__c (before insert, before update) {

	for (RFQI_fcBGA__c row : Trigger.new)
	{
		String ballPitch = row.Ball_Pitch__c;
		Decimal bodyX = row.Body_X__c;

		if (bodyX != null)
		{
			if (ballPitch == '1.0')
			{
		        if      (bodyX == 10)   row.Ball_Count_fml_2__c = 86;
		        else if (bodyX == 11)   row.Ball_Count_fml_2__c = 104;
		        else if (bodyX == 12)   row.Ball_Count_fml_2__c = 125;
		        else if (bodyX == 13)   row.Ball_Count_fml_2__c = 148;
		        else if (bodyX == 14)   row.Ball_Count_fml_2__c = 172;
		        else if (bodyX == 15)   row.Ball_Count_fml_2__c = 196;
		        else if (bodyX == 17)   row.Ball_Count_fml_2__c = 256;
		        else if (bodyX == 19)   row.Ball_Count_fml_2__c = 324;
		        else if (bodyX == 21)   row.Ball_Count_fml_2__c = 400;
		        else if (bodyX == 23)   row.Ball_Count_fml_2__c = 484;
		        else if (bodyX == 25)   row.Ball_Count_fml_2__c = 576;
		        else if (bodyX == 27)   row.Ball_Count_fml_2__c = 676;
		        else if (bodyX == 29)   row.Ball_Count_fml_2__c = 784;
		        else if (bodyX == 31)   row.Ball_Count_fml_2__c = 900;
		        else if (bodyX == 33)   row.Ball_Count_fml_2__c = 1024;
		        else if (bodyX == 35)   row.Ball_Count_fml_2__c = 1156;
		        else if (bodyX == 37.5) row.Ball_Count_fml_2__c = 1296;
		        else if (bodyX == 40)   row.Ball_Count_fml_2__c = 1521;
		        else if (bodyX == 42.5) row.Ball_Count_fml_2__c = 1764;
		        else if (bodyX == 45)   row.Ball_Count_fml_2__c = 1936;
		        else if (bodyX == 47.5) row.Ball_Count_fml_2__c = 2209;
		        else if (bodyX == 50)   row.Ball_Count_fml_2__c = 2401;
		        else if (bodyX == 52.5) row.Ball_Count_fml_2__c = 2601;
		        else if (bodyX == 55)   row.Ball_Count_fml_2__c = 2916;
		        else row.Ball_Count_fml_2__c = (0.7224 * Math.pow(Double.valueOf(bodyX.setScale(0)), Double.valueOf(2.0739))).setScale(0);
	    	}

			else if (ballPitch == '0.8')
			{
		        if      (bodyX == 10)   row.Ball_Count_fml_2__c = 124;
		        else if (bodyX == 11)   row.Ball_Count_fml_2__c = 152;
		        else if (bodyX == 12)   row.Ball_Count_fml_2__c = 183;
		        else if (bodyX == 13)   row.Ball_Count_fml_2__c = 218;
		        else if (bodyX == 14)   row.Ball_Count_fml_2__c = 255;
		        else if (bodyX == 15)   row.Ball_Count_fml_2__c = 296;
		        else if (bodyX == 17)   row.Ball_Count_fml_2__c = 400;
		        else if (bodyX == 19)   row.Ball_Count_fml_2__c = 484;
		        else if (bodyX == 21)   row.Ball_Count_fml_2__c = 625;
		        else if (bodyX == 23)   row.Ball_Count_fml_2__c = 729;
		        else if (bodyX == 25)   row.Ball_Count_fml_2__c = 900;
		        else if (bodyX == 27)   row.Ball_Count_fml_2__c = 1024;
		        else if (bodyX == 29)   row.Ball_Count_fml_2__c = 1225;
		        else row.Ball_Count_fml_2__c = (0.9497 * Math.pow(Double.valueOf(bodyX.setScale(0)), Double.valueOf(2.1246))).setScale(0);
	    	}

			else if (ballPitch == '0.65')
			{
		        if      (bodyX == 10)   row.Ball_Count_fml_2__c = 196;
		        else if (bodyX == 11)   row.Ball_Count_fml_2__c = 256;
		        else if (bodyX == 12)   row.Ball_Count_fml_2__c = 289;
		        else if (bodyX == 13)   row.Ball_Count_fml_2__c = 361;
		        else if (bodyX == 14)   row.Ball_Count_fml_2__c = 400;
		        else if (bodyX == 15)   row.Ball_Count_fml_2__c = 484;
		        else if (bodyX == 17)   row.Ball_Count_fml_2__c = 625;
		        else if (bodyX == 19)   row.Ball_Count_fml_2__c = 784;
		        else if (bodyX == 21)   row.Ball_Count_fml_2__c = 961;
		        else if (bodyX == 23)   row.Ball_Count_fml_2__c = 1156;
		        else if (bodyX == 25)   row.Ball_Count_fml_2__c = 1369;
		        else if (bodyX == 27)   row.Ball_Count_fml_2__c = 1600;
		        else if (bodyX == 29)   row.Ball_Count_fml_2__c = 1849;
		        else if (bodyX == 31)   row.Ball_Count_fml_2__c = 2116;
		        else if (bodyX == 33)   row.Ball_Count_fml_2__c = 2500;
		        else if (bodyX == 35)   row.Ball_Count_fml_2__c = 2809;
		        else if (bodyX == 37.5) row.Ball_Count_fml_2__c = 3136;
		        else if (bodyX == 40)   row.Ball_Count_fml_2__c = 3600;
		        else if (bodyX == 42.5) row.Ball_Count_fml_2__c = 4096;
		        else if (bodyX == 45)   row.Ball_Count_fml_2__c = 4624;
		        else if (bodyX == 47.5) row.Ball_Count_fml_2__c = 5184;
		        else if (bodyX == 50)   row.Ball_Count_fml_2__c = 5776;
		        else if (bodyX == 52.5) row.Ball_Count_fml_2__c = 6400;
		        else if (bodyX == 55)   row.Ball_Count_fml_2__c = 6889;
		        else row.Ball_Count_fml_2__c = (1.7168 * Math.pow(Double.valueOf(bodyX.setScale(0)), Double.valueOf(2.0755))).setScale(0);
	   	 	}

			else if (ballPitch == '0.50')
			{
		        if      (bodyX == 10)   row.Ball_Count_fml_2__c = 361;
		        else if (bodyX == 11)   row.Ball_Count_fml_2__c = 441;
		        else if (bodyX == 12)   row.Ball_Count_fml_2__c = 529;
		        else if (bodyX == 13)   row.Ball_Count_fml_2__c = 625;
		        else if (bodyX == 14)   row.Ball_Count_fml_2__c = 729;
		        else if (bodyX == 15)   row.Ball_Count_fml_2__c = 841;
		        else if (bodyX == 17)   row.Ball_Count_fml_2__c = 1089;
		        else if (bodyX == 19)   row.Ball_Count_fml_2__c = 1369;
		        else if (bodyX == 21)   row.Ball_Count_fml_2__c = 1681;
		        else if (bodyX == 23)   row.Ball_Count_fml_2__c = 2025;
		        else if (bodyX == 25)   row.Ball_Count_fml_2__c = 2401;
		        else if (bodyX == 27)   row.Ball_Count_fml_2__c = 2809;
		        else if (bodyX == 29)   row.Ball_Count_fml_2__c = 3249;
		        else if (bodyX == 31)   row.Ball_Count_fml_2__c = 3721;
		        else if (bodyX == 33)   row.Ball_Count_fml_2__c = 4225;
		        else if (bodyX == 35)   row.Ball_Count_fml_2__c = 4761;
		        else if (bodyX == 37.5) row.Ball_Count_fml_2__c = 5476;
		        else if (bodyX == 40)   row.Ball_Count_fml_2__c = 6241;
		        else if (bodyX == 42.5) row.Ball_Count_fml_2__c = 7056;
		        else if (bodyX == 45)   row.Ball_Count_fml_2__c = 7921;
		        else if (bodyX == 47.5) row.Ball_Count_fml_2__c = 8836;
		        else if (bodyX == 50)   row.Ball_Count_fml_2__c = 9801;
		        else if (bodyX == 52.5) row.Ball_Count_fml_2__c = 1081;
		        else if (bodyX == 55)   row.Ball_Count_fml_2__c = 1188;
		        else row.Ball_Count_fml_2__c = (3.2885 * Math.pow(Double.valueOf(bodyX.setScale(0)), Double.valueOf(2.0463))).setScale(0);
	    	}
	    	else row.Ball_Count_fml_2__c = 0;
    	}
    	else row.Ball_Count_fml_2__c = 0;

	}
}