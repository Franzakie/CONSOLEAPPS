function fetchRfQ(rfqNo, src)
{
    /*
    ===========================
     Declare and Set Variables
    ===========================
    */

    var pagecount:int
    var currentFormat : DateTimeFormatInfo = System.Globalization.CultureInfo.CurrentCulture.DateTimeFormat
    var scanpc = System.Environment.MachineName;
    var scandate = TimeZone.CurrentTimeZone.ToLocalTime(DateTime.Now);
    var materialnumber = "";
    var result:Hashtable = Document["FAXDetails"];
    var dateTime1 : DateTime;
    var RFQType = "Standard";
    var received = "";
    var strIndex = "";
    var strCreatedDate = "";
    var strCreatedTime = "";
    var frmReceivedDate = "";
    var strFileName = "";
    var strRFQPrice = "";
    var strScannedAlready = "No";
    var strTblScanPC = "";
    var strCanUpdate = "No";
    var strContScan = "Yes";
    var strSetDate = "True";
    var strInformation = "";
    var strFirstRun = "Yes";
    
    if(Fields["FirstRun"].Value == "No" )
    {
        strFirstRun = "No";
    }

    /*
    =====================================
     Clear Field Values and set defaults
    =====================================
    */
	Fields["7355322.15:Collective Number"].Value = "";
	Fields["7355322.15:Location No"].Value = "";
	Fields["7355322.15:Location"].Value = "";
	Fields["7355322.15:Closing Date"].Value = "";
	Fields["7355322.15:Closing Time"].Value = "";
	Fields["7355322.15:Vendor Number"].Value = "";
	Fields["7355322.15:Vendor Name"].Value = "";
	Fields["7355322.15:Source Detail"].Value = "";
	Fields["7355322.15:Buyer No"].Value = "";
	Fields["7355322.15:Buyer Name"].Value = "";
	Fields["7355322.15:Send to Buyer"].Value = "No";
	Fields["7355322.15:Scan Date"].Value = scandate;
	Fields["7355322.15:Scan Pc"].Value = scanpc;
	Fields["7355322.15:SAP Update"].Value = "0";

    /*
    ====================================
    Check invalid RFQ
    ====================================
    */
        
    if (rfqNo == "00")
    {
        Fields["7355322.15:Collective Number"].Value = "0000000000";
        Fields["7355322.15:RFQ Number"].Value = "0000000000";
        Fields["7355322.15:RFQ Amount"].Value = "0.00";
        Fields["7355322.15:Received Date"].Value = TimeZone.CurrentTimeZone.ToLocalTime(DateTime.Now);
        Fields["7355322.15:Received Time"].Value = TimeZone.CurrentTimeZone.ToLocalTime(DateTime.Now).ToString("HH:mm");
        Fields["7355322.15:Location No"].Value = "IG01";
        Fields["7355322.15:Location"].Value = "Corporate Office";
        Fields["7355322.15:Closing Date"].Value = TimeZone.CurrentTimeZone.ToLocalTime(DateTime.Now);
        Fields["7355322.15:Closing Time"].Value = TimeZone.CurrentTimeZone.ToLocalTime(DateTime.Now).ToString("HH:mm");
        Fields["7355322.15:Type of RFQ"].Value = "Invalid";
        Fields["7355322.15:Status"].Value = "Review Required";
        Fields["7355322.15:SAP Update"].Value = "9";
        Fields["7355322.15:Send to Buyer"].Value = "Yes";
        Fields["7355322.15:Scan Date"].Value = scandate;
        Fields["7355322.15:Scan Pc"].Value = scanpc;
        Fields["7355322.15:SAP Update"].Value = "0";
        strFirstRun = "No";

        MessageBox.Show("This RFQ Response has been marked as Invalid.","Invalid RFQ Response")
    }
    else
    {

        /*
        ==============================================================
        Check source and set the dates
        ==============================================================
        */

        if(src == "Fax")
        {
            strIndex = Document["Index"];
            strCreatedDate = strIndex.substring(strIndex.indexOf("#") + 1);
            strCreatedDate = strCreatedDate.substring(0, strCreatedDate.indexOf("."));
            strCreatedDate = strCreatedDate.replace("_", ":");
            strCreatedTime = strCreatedDate.substring(strCreatedDate.indexOf(" ") + 1);
            strFileName = strIndex.substring(0, strIndex.indexOf("#"));
            frmReceivedDate = Fields["7355322.15:Received Date"].Value;

            if(strCreatedDate != "")
            {
                Fields["7355322.15:Created Date"].Value = strCreatedDate;
                Fields["7355322.15:Created Date"].ReadOnly = true;

                if(strCreatedDate == "")
                {
                    MessageBox.Show("No Date Detected","Info");
                    strSetDate = "False";
                }
                else
                {
                    Fields["7355322.15:Received Date"].Value = strCreatedDate;
                    Fields["7355322.15:Received Time"] = strCreatedTime;
                }
            }
        }

        if(src == "E-Mail")
        {
            received = result["FAXReceived"];
            var seconds:Int32 = Convert.ToInt32(received);

            dateTime1 = new DateTime(1970, 1, 1) + new TimeSpan(0, 0, seconds);
            dateTime1 = TimeZone.CurrentTimeZone.ToLocalTime(dateTime1);

            Fields["7355322.15:Created Date"].Value = dateTime1;
            Fields["7355322.15:Created Date"].ReadOnly = true;

            Fields["7355322.15:Received Date"].Value = dateTime1;
            Fields["7355322.15:Received Time"] = dateTime1.ToString("HH:mm");
        }

        if(src == "Hand Delivery")
        {
            Fields["7355322.15:Received Date"].Value = "";
            Fields["7355322.15:Received Time"] = "";
        }

        /*
        ====================================
         Connect to Oracle and set commands
        ====================================
        */

        var conStr:String = "Data Source=(DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST =156.8.245.220)(PORT = 1521)))(CONNECT_DATA=(SERVER=DEDICATED)(SERVICE_NAME=OTCS)));User ID=otcs;Password=otcs;"

        var conn:OracleConnection = new OracleConnection(conStr)
        conn.Open()

        var cmd:OracleCommand = new OracleCommand()
        var cmdUpd:OracleCommand = new OracleCommand()
        var cmdUpd2:OracleCommand = new OracleCommand()

        cmd.Connection = conn
        cmdUpd.Connection = conn
        cmdUpd2.Connection = conn

        cmd.CommandText = "select ID, RFQ_GROUPNO, LOCATIONNO, LOCATION, CLOSINGDATE, OURREF, VENDORNO, VENDORNAME, BUYERNO, BUYERNAME, UPDATEDINSAP, MATERIALNO, RETFAXNO, BUYEREMAIL, PRICE, SCANPC from AMSA_RFQ WHERE RFQNO = " + "'" + rfqNo + "'";

        cmdUpd.CommandText = "Update AMSA_RFQ set UPDATEDINSAP = 3, SCANPC = '" + scanpc + "', SCANDATE = sysdate WHERE RFQNO = " + "'" + rfqNo + "'";
        cmdUpd2.CommandText = "Update AMSA_RFQ_FILES set RFQNO = '" + rfqNo + "' Where FILENAME = '" + strFileName + "'";

        /* 
        ============================================================================== 
         Set fields from select script and perform additional check and field updates
        ==============================================================================
        */

        var dr:OracleDataReader = cmd.ExecuteReader()

        if (dr.Read())
        {
            if(dr["RFQ_GROUPNO"] != null){Fields["7355322.15:Collective Number"].Value = dr["RFQ_GROUPNO"];}
            if(dr["LOCATIONNO"] != null){Fields["7355322.15:Location No"].Value = dr["LOCATIONNO"];}
            if(dr["LOCATION"] != null){Fields["7355322.15:Location"].Value = dr["LOCATION"];}
            if(dr["CLOSINGDATE"] != null){Fields["7355322.15:Closing Date"].Value = dr["CLOSINGDATE"];}
            if(dr["OURREF"] != null){Fields["7355322.15:Closing Time"].Value = dr["OURREF"];}
            if(dr["VENDORNO"] != null){Fields["7355322.15:Vendor Number"].Value = dr["VENDORNO"];}
            if(dr["VENDORNAME"] != null){Fields["7355322.15:Vendor Name"].Value = dr["VENDORNAME"];}
            if(dr["BUYERNO"] != null){Fields["7355322.15:Buyer No"].Value = dr["BUYERNO"];}
            if(dr["BUYERNAME"] != null){Fields["7355322.15:Buyer Name"].Value = dr["BUYERNAME"];}
            if(dr["BUYEREMAIL"] != null){Fields["7355322.15:Buyer e-mail"].Value = dr["BUYEREMAIL"];}
            if(dr["PRICE"] != null && Fields["Rescan"].Value != "Yes"){Fields["7355322.15:RFQ Amount"].Value = dr["PRICE"];}
            if(dr["UPDATEDINSAP"] != null){Fields["7355322.15:SAP Update"].Value = dr["UPDATEDINSAP"];}
        
            Fields["Rescan"].ReadOnly = false;

            if(dr["SCANPC"] != null)
            {
                strTblScanPC = dr["SCANPC"]; 
                strScannedAlready = "Yes";
            }
            Fields["Rescan"].Value = strContScan;
            if(strScannedAlready == "Yes")
            {
                strInformation = strInformation + "ScanPC=" + strTblScanPC + " | "
                if(MessageBox.Show("This has already been scanned, must it be rescanned?", "Scanned Already", MessageBoxButtons.YesNo)==DialogResult.No)
                {
                    strContScan = "No";
                    strCanUpdate = "No";
                    Fields["Rescan"].Value = "";
                    strInformation = strInformation + "Continue Scanning=No | ";
                }
                else
                {

                    strContScan = "Yes";
                    strCanUpdate = "Yes";
                    Fields["Rescan"].Value = "Yes";
                    strInformation = strInformation + "Continue Scanning=Yes | ";
                }
            }
            Fields["Rescan"].ReadOnly = true;

            if(strContScan == "Yes")
            {
                if(src == "Fax")
                {
                    if(dr["RETFAXNO"] != null){Fields["7355322.15:Source Detail"].Value = dr["RETFAXNO"];}
                }

                if(src == "E-Mail")
                {
                    var FAXLineGet = result["FAXLine"];
                    FAXLineGet = FAXLineGet.split('_')[1];
                    Fields["7355322.15:Source Detail"].Value = FAXLineGet;
                }

                Fields["7355322.15:Type of RFQ"].Value = "Standard";

                /*
                ===========================================
                 Check if RFQ a Breakdown RFQ set RFQ Type
                ===========================================
                */

                if(dr["OURREF"] == "11:00" && strFirstRun == "No")
                {
                    if(MessageBox.Show("Is this a breakdown RFQ?", "Breakdown Check", MessageBoxButtons.YesNo)==DialogResult.Yes)
                    {
                        Fields["7355322.15:Type of RFQ"].Value = "Breakdown";
                        Fields["7355322.15:Status"].Value = "On-time";
                        RFQType = "Breakdown";
                    }
                    else
                    {
                        Fields["7355322.15:Type of RFQ"].Value = "Standard";
                        RFQType = "Standard";
                    }
                }

                /*
                =======================================
                 Check if RFQ a Recon and Set RFQ Type
                =======================================
                */

                if(dr["MATERIALNO"] != null)
                {
                    materialnumber = dr["MATERIALNO"];
                    Fields["7355322.15:Material Number"].Value = materialnumber;
			
                    if(RFQType != "Breakdown")
                    {
                        if(materialnumber.substring(0,1) == "R" || materialnumber.substring(0,1) == "L" && strFirstRun == "No")
                        {
                            if(MessageBox.Show("Is this a Recon?", "Recon Check", MessageBoxButtons.YesNo)==DialogResult.Yes)
                            {
                                Fields["7355322.15:Type of RFQ"].Value = "Recon";
                                Fields["7355322.15:Status"].Value = "On-time";
                                RFQType = "Recon";
                            }
                            else
                            {
                                Fields["7355322.15:Type of RFQ"].Value = "Standard";
                                RFQType = "Standard";
                            }
                        }
                    }
                }

                /*
                ========================================================================
                 Compare received date and time to closing date and time and set status
                ========================================================================
                */

                strRFQPrice = Fields["7355322.15:RFQ Amount"].Value;

                if(strRFQPrice == "")
                {strCanUpdate = "No"; strInformation = strInformation = "CanUpdate=" + strCanUpdate;}
                else
                {strCanUpdate = "Yes"; strInformation = strInformation = "CanUpdate=" + strCanUpdate;}

                var strCloseDateTime = dr["CLOSINGDATE"].ToString(currentFormat.ShortDatePattern) + " " + dr["OURREF"];

                if(RFQType == "Standard")
                {
                    if(dateTime1 <= strCloseDateTime)
                    {
                        Fields["7355322.15:Status"].Value = "On-time";
                        Fields["7355322.15:SAP Update"].Value = "3";
                        cmdUpd.CommandText = "Update AMSA_RFQ set UPDATEDINSAP = 3, SCANPC = '" + scanpc + "', SCANDATE = sysdate, PRICE = '" + strRFQPrice + "' WHERE RFQNO = " + "'" + rfqNo + "'";
                    }
                    else
                    {
                        Fields["7355322.15:Status"].Value = "Late";
                        Fields["7355322.15:SAP Update"].Value = "4";
                        cmdUpd.CommandText = "Update AMSA_RFQ set UPDATEDINSAP = 4, SCANPC = '" + scanpc + "', SCANDATE = sysdate, PRICE = '" + strRFQPrice + "' WHERE RFQNO = " + "'" + rfqNo + "'";
                    }
                }

                if(RFQType == "Breakdown")
                {
                    Fields["7355322.15:Status"].Value = "On-time";
                    Fields["7355322.15:SAP Update"].Value = "4";
                    cmdUpd.CommandText = "Update AMSA_RFQ set UPDATEDINSAP = 4, SCANPC = '" + scanpc + "', SCANDATE = sysdate, PRICE = '" + strRFQPrice + "' WHERE RFQNO = " + "'" + rfqNo + "'";
                }
	
                if(RFQType == "Recon")
                {
                    Fields["7355322.15:Status"].Value = "On-time";
                    Fields["7355322.15:SAP Update"].Value = "4";
                    cmdUpd.CommandText = "Update AMSA_RFQ set UPDATEDINSAP = 4, SCANPC = '" + scanpc + "', SCANDATE = sysdate, PRICE = '" + strRFQPrice + "' WHERE RFQNO = " + "'" + rfqNo + "'";
                }

                if(RFQType != "Standard" && RFQType != "Recon" && RFQType != "Breakdown")
                {
                    Fields["7355322.15:Status"].Value = "On-time";
                    Fields["7355322.15:SAP Update"].Value = "4";
                    cmdUpd.CommandText = "Update AMSA_RFQ set UPDATEDINSAP = 4, SCANPC = '" + scanpc + "', SCANDATE = sysdate, PRICE = '" + strRFQPrice + "' WHERE RFQNO = " + "'" + rfqNo + "'";
                }
            }

            Fields["Information"].Value = strInformation;

            /*
            ============================================
            Run Update script to update AMSA_RFQ table
            ============================================
            */

            if(rfqNo != "" && strFirstRun == "No" && strCanUpdate == "Yes")
            {
                if (MessageBox.Show("Would you like to send this to the buyer for review", "Send For Review", MessageBoxButtons.YesNo) == DialogResult.Yes) {
                    Fields["7355322.15:Status"].Value = "Review Required";
                    Fields["7355322.15:Send to Buyer"].Value = "Yes";
                    strInformation = strInformation + "SendToBuyer=Yes | ";
                }
                else
                {
                    Fields["7355322.15:Send to Buyer"].Value = "No";
                    strInformation = strInformation + "SendToBuyer=No | ";
                }

                cmdUpd.CommandText = "Update AMSA_RFQ set UPDATEDINSAP = " + Fields["7355322.15:SAP Update"].Value + ", SCANPC = '" + scanpc + "', SCANDATE = sysdate, PRICE = '" + Fields["7355322.15:RFQ Amount"].Value + "' WHERE RFQNO = " + "'" + rfqNo + "'";
                cmdUpd.ExecuteNonQuery();

                if(src == "Fax")
                {
                    cmdUpd2.ExecuteNonQuery();
                }
                if(src == "Hand Delivery")
                {
                    cmdUpd2.ExecuteNonQuery();
                }
            }
            strFirstRun = "No";
            
        }
        /*
        ================================
        Return command to end function
        ================================
        */

        conn.Close();

        Fields["FirstRun"] = strFirstRun;

        return;
    }
}