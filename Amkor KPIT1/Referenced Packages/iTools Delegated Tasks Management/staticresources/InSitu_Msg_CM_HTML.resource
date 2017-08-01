<STYLE>
  .summary { font-family: Verdana, Arial, Helvetica; font-weight: bold; font-size: 18px; color: #0066cc; }
  .main { font-family: Verdana, Arial, Helvetica; font-weight: normal; font-size: 12px; line-height: 18px; color: black; }
</STYLE>

<HTML>
<HEAD>
     <BASE href="Task Reminder">
</HEAD>
<BODY>

<TABLE cellSpacing=0 cellPadding=0 bgcolor=#FFFFFF border=0  WIDTH="100%">
     <TR><TD WIDTH="100%">
     <TABLE cellSpacing=0 cellPadding=10 border=0  WIDTH="100%">
              <TR><TD BGCOLOR="#FFFFFF">
               <TABLE cellSpacing=0 cellPadding=0 border=0>
                       <TD class="summary">Task Reminder</TD></TR>
                </TABLE>
                </TR></TD>
      </TABLE>
      </TD></TR>
      <TR><TD height="5"></TD></TR>
      <TR><TD STYLE="padding:0 10 0 10px;"><P CLASS="main">
        The following task assigned to you by {!CreatedBy.Name} of {!CreatedBy.CompanyName} is due on {!ActivityDate}:<br><br>
        Subject: {!Subject}<br>
        Priority: {!Priority}<br>
        Comments: {!Description}<br>

<!-- ***** START: Completion Instructions, Email method *****-->
<br>
If this task is complete, please <a HREF="mailto:{!TaskCompleteEmailAddress}?subject=Task Complete ref:{!ContactTaskId}:ref">Click Here<a/> to send an email to notify our system.  The body of the message you send will be added to the comments field on the task.
<br>

<br>
If this task is not complete but you would like to update the task, please <a HREF="mailto:{!TaskCompleteEmailAddress}?subject=Task Update ref:{!ContactTaskId}:ref">Click Here<a/> to send an email to notify our system.  The body of the message you send will be added to the comments field on the task.
<br>
<!-- ***** END: Completion Instructions, Email method *****-->

<!-- ***** START: Completion Instructions, Sites Pages method *****-->
<br>
If this task is complete, <a href={!TaskCompleteURL}>Click Here</a> to access the task completion web page.  To view a list of all of your open or recently completed tasks, use <a href={!TaskListURL}>This Page</a>.
<br>
<!-- ***** END: Completion Instructions, Sites Pages method *****-->
 
        </P>
        </TD></TR>
</TABLE>
</BODY>
</HTML>
