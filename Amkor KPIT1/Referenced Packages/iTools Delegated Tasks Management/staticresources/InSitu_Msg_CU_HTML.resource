<STYLE>
  .summary { font-family: Verdana, Arial, Helvetica; font-weight: bold; font-size: 18px; color: #0066cc; }
  .main { font-family: Verdana, Arial, Helvetica; font-weight: normal; font-size: 12px; line-height: 18px; color: black; }
</STYLE>

<HTML>
<HEAD>
     <BASE href="Contact Task Update Notification">
</HEAD>
<BODY>

<TABLE cellSpacing=0 cellPadding=0 bgcolor=#FFFFFF border=0  WIDTH="100%">
     <TR><TD WIDTH="100%">
     <TABLE cellSpacing=0 cellPadding=10 border=0  WIDTH="100%">
              <TR><TD BGCOLOR="#FFFFFF">
               <TABLE cellSpacing=0 cellPadding=0 border=0>
                       <TD class="summary">Updated Task</TD></TR>
                </TABLE>
                </TR></TD>
      </TABLE>
      </TD></TR>
      <TR><TD height="5"></TD></TR>
      <TR><TD STYLE="padding:0 10 0 10px;"><P CLASS="main">
        The following Contact Task has been updated by the contact:<br><br>
        Subject: {!Subject}<br>
        Name: {!Who.Name}<br>
        Related To: {!What.Name}<br>
        Due Date: {!ActivityDate}<br>
        Priority: {!Priority}<br>
        Comments: {!Description}<br><br>
        For more details, click the following link:<br><br>
        <A HREF="{!SFDCURL}{!Id}" TARGET="_BLANK">{!SFDCURL}{!Id}</A>
        </P>
        </TD></TR>
</TABLE>
</BODY>
</HTML>
