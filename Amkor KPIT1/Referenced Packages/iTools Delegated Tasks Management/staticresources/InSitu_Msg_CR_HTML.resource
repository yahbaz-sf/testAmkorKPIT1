<STYLE>
  .summary { font-family: Verdana, Arial, Helvetica; font-weight: bold; font-size: 18px; color: #0066cc; }
  .main { font-family: Verdana, Arial, Helvetica; font-weight: normal; font-size: 12px; line-height: 18px; color: black; }
</STYLE>

<HTML>
<HEAD>
     <BASE href="Task Completion Confirmation">
</HEAD>
<BODY>

<TABLE cellSpacing=0 cellPadding=0 bgcolor=#FFFFFF border=0  WIDTH="100%">
     <TR><TD WIDTH="100%">
     <TABLE cellSpacing=0 cellPadding=10 border=0  WIDTH="100%">
              <TR><TD BGCOLOR="#FFFFFF">
               <TABLE cellSpacing=0 cellPadding=0 border=0>
                       <TD class="summary">Task Completion Confirmation</TD></TR>
                </TABLE>
                </TR></TD>
      </TABLE>
      </TD></TR>
      <TR><TD height="5"></TD></TR>
      <TR><TD STYLE="padding:0 10 0 10px;"><P CLASS="main">
        This message confirms that you have successfully completed the following task:<br><br>
        Subject: {!Subject}<br>
        Due Date: {!ActivityDate}<br>
        Priority: {!Priority}<br>
        Comments: {!Description}<br><br>
        If for some reason this task is not complete, please contact {!CreatedBy.Name} at {!CreatedBy.Email}. 
        </P>
        </TD></TR>
</TABLE>
</BODY>
</HTML>
