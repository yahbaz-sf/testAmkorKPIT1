<STYLE>
  .rptHeader1 { font-family: Verdana, Arial, Helvetica; font-size: 24px; font-weight: bold; color: #0066cc; text-align: center; width: 100%; }
  .rptHeader2 { font-family: Verdana, Arial, Helvetica; font-size: 16px; font-weight: bold; color: black; text-align: center; width: 100%; }
  .rptHeader3 { font-family: Verdana, Arial, Helvetica; font-size: 12px; font-weight: normal; color: black; text-align: center; width: 100%; }
  .rptSection { font-family: Verdana, Arial, Helvetica; font-size: 18px; font-weight: bold; color: #0066cc; border: 1px solid #00A040; text-align: left; }
  .rptCount   { font-family: Verdana, Arial, Helvetica; font-size: 12px; font-weight: bold; color: black; text-align: right; padding-right: 10px; width: 50px}
  .rptMetric  { font-family: Verdana, Arial, Helvetica; font-size: 12px; font-weight: normal; color: black; text-align: left; }
</STYLE>

<HTML>
<HEAD>
     <BASE href="Task Group Summary">
</HEAD>
<BODY>

<TABLE width="100%" class="rptMetric" >
	<tr>
		<td class="rptHeader1" >
			Task Group Summary   
		</td>
	</tr>
	<tr>
		<td class="rptHeader2" >
			{!GroupName}   
		</td>
	</tr>
	<tr>
		<td class="rptHeader3" >
			{!ReportDate}   
		</td>
	</tr>
	<tr>
		<td height="20px">&nbsp;</td>
	</tr> 
	<tr>
		<td class="rptSection" >
			&nbsp;Open Tasks
		</td>	
	</tr>    
	<tr>
		<td>
			<table>
				<tr>
					<td class="rptCount" >
						{!NumberUnclaimed}
					</td>
					<td class="rptMetric" >
						Unclaimed
					</td>
				</tr>
				{!OpenByIndividual}
			</table>
		</td>
	</tr>
	<tr>
		<td height="75px">&nbsp;
		</td>
	</tr>
	<tr>
		<td class="rptSection" >
			&nbsp;Completed Tasks
		</td>	
	</tr>    
	<tr>
		<td>
			<table>
				<tr>
					<td class="rptCount" >
						{!NumberCompleted}
					</td>
					<td class="rptMetric" >
						Total Completed in the Last {!NumberRecentDays} Days
					</td>
				</tr>
				{!CompletedByIndividual}
				<tr>
					<td height="40px">&nbsp;
					</td>
					<td>
					</td>
				</tr>
				<tr>
					<td class="rptCount" >
						{!AvgDaysToClaim}
					</td>
					<td class="rptMetric" >
						Average Days to Claim
					</td>
				</tr>
				<tr>
					<td class="rptCount" >
						{!AvgWorkDaysToComplete}
					</td>
					<td class="rptMetric" >
						Average Work Days to Complete
					</td>
				</tr>
				<tr>
					<td class="rptCount" >
						{!AvgCalDaysToComplete}
					</td>
					<td class="rptMetric" >
						Average Calendar Days to Complete
					</td>
				</tr>
				<tr>
					<td class="rptCount" >
						{!AvgDaysBeforeDue}
					</td>
					<td class="rptMetric" >
						Average Days Completed Before Due
					</td>
				</tr>
	
			</table>
		</td>
	</tr>
</TABLE>
</BODY>
</HTML>