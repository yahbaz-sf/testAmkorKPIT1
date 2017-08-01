<STYLE>
  .summary { font-family: Verdana, Arial, Helvetica; font-weight: bold; font-size: 18px; color: #0066cc; }
  .main { font-family: Verdana, Arial, Helvetica; font-weight: normal; font-size: 12px; line-height: 18px; color: black; }
</STYLE>

<HTML>
<HEAD>
     <BASE href="Event Notification">
</HEAD>
<BODY>

<TABLE cellSpacing=0 cellPadding=0 bgcolor=#FFFFFF border=0  WIDTH="100%">
     <TR><TD WIDTH="100%">
     <TABLE cellSpacing=0 cellPadding=10 border=0  WIDTH="100%">
              <TR><TD BGCOLOR="#FFFFFF">
               <TABLE cellSpacing=0 cellPadding=0 border=0>
                       <TD class="summary">New Event</TD></TR>
                </TABLE>
                </TR></TD>
      </TABLE>
      </TD></TR>
      <TR><TD height="5"></TD></TR>
      <TR><TD STYLE="padding:0 10 0 10px;"><P CLASS="main">
        {!CreatedBy.Name} has assigned you the following new event:<br><br>
        When: {!When}<br>
        Where: {!Location}<br>
        Subject: {!Subject}<br>
        Name: {!Who.Name}<br>
        Related To: {!What.Name}<br>
        Comments: {!Description}<br><br>
        For more details, click the following link:<br><br>
        <A HREF="{!SFDCURL}{!Id}" TARGET="_BLANK">{!SFDCURL}{!Id}</A>
        </P>
        </TD></TR>
</TABLE>
</BODY>
</HTML>