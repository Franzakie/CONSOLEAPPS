import System;
import System.Collections;
import System.Data;
import System.Globalization;
import System.Windows.Forms;
import System.Data.OracleClient;  // this will need System.Data..OracleClient.dll reference from %WINDIR%\Microsoft.NET\Framework64\<version>

//	INSTALLATION NOTE: Copy System.Data.OracleClient to C:\Program Files (x86)\OpenText\Scan\bin AND ADD TO REFERENCES TAB

/*
=====================================================================================================================================================
    Project Name:  Tender Office RFQ Scanning
    Created by:    Franz Siedel
    Created Date:  28 June 2016
    Modified by:   Franz Seidel
    Modified Date: 7 December 2016
	Version Number:Tender Office - V7.3.19.xml

   Change Log:
   Version	Author	Comments
   =======	======	========
   7.3.18	SK/KG	Added 14 to "SAP Update" field in CS
=====================================================================================================================================================
*/

function validateEmail(email) {
    var re = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
    return re.test(email);
}

function EvaluateChanges()
{
    var RFQType = "";
    var receivedDate = "";
    var ClosedeDate = "";
    var receivedTime;
    var ClosedeTime;
    var myFormat: DateTimeFormatInfo; 
    try
    {
        myFormat = System.Threading.Thread.CurrentThread.CurrentCulture.DateTimeFormat; 
        RFQType = Fields["7355322.17:Type of RFQ"].Value;
        receivedDate = Fields["7355322.17:Received Date"].Value;     
        ClosedeDate = Fields["7355322.17:Closing Date"].Value;       
        receivedTime = Fields["7355322.17:Received Time"].Value;     
        ClosedeTime = Fields["7355322.17:Closing Time"].Value;       
        receivedDate = receivedDate.ToString(myFormat.ShortDatePattern);
        //MessageBox.Show(receivedDate);
        ClosedeDate = ClosedeDate.ToString(myFormat.ShortDatePattern);
        //MessageBox.Show(ClosedeDate);
    
        //MessageBox.Show("Check time R =" + receivedDate + "Closing =" + ClosedeDate +"RFQType=" + RFQType +"einde");

        if(RFQType == "Standard" || RFQType == "Price Modification" || RFQType == "Breakdown")
        {
            if(receivedDate < ClosedeDate)
            {
                Fields["7355322.17:Status"].Value = "On-time";
                Fields["7355322.17:SAP Update"].Value = "3";
            }
            else
            {
                if(receivedDate == ClosedeDate)
                {
                    try
                    {
                        var receivedHour = int.Parse(receivedTime.Substring(0,2));
                        var ClosedHour = int.Parse(ClosedeTime.Substring(0,2));
                        //MessageBox.Show("Check time R =" + receivedHour + "Closing Time =" + ClosedHour +"einde");
                        if(receivedHour < ClosedHour)
                        {
                            Fields["7355322.17:Status"].Value = "On-time";
                            Fields["7355322.17:SAP Update"].Value = "3";
                        }
                        else
                        {
                            Fields["7355322.17:Status"].Value = "Late";
                            Fields["7355322.17:SAP Update"].Value = "4";
                        }
                    }
                    catch (Ex)
                    {
                        //Make it late in cause their is something wrong with the time
                        Fields["7355322.17:Status"].Value = "Late";
                        Fields["7355322.17:SAP Update"].Value = "4";
                    }
                }
                else
                {
                    Fields["7355322.17:Status"].Value = "Late";
                    Fields["7355322.17:SAP Update"].Value = "4";
                }
            }
        }

        if(RFQType == "Breakdown")
        {
            Fields["7355322.17:SAP Update"].Value = "14";
        }
	
        if(RFQType == "Recon")
        {
            Fields["7355322.17:Status"].Value = "On-time";
            Fields["7355322.17:SAP Update"].Value = "4";
        }

        if(RFQType == "Invalid")
        {
            Fields["7355322.17:Status"].Value = "";
            Fields["7355322.17:SAP Update"].Value = "9";
        }

        if(RFQType == "Correspondence" || RFQType == "Other Modification")
        {
            Fields["7355322.17:Status"].Value = "On-time";
            Fields["7355322.17:SAP Update"].Value = "5";
        }

        if(Fields["7355322.17:Send to Buyer"].Value == "Yes")
        {
            Fields["7355322.17:Status"].Value = "Review Required";
            Fields["7355322.17:SAP Update"].Value = "90";
        }

        Context["ReceivedDate"] = Fields["7355322.17:Received Date"].Value;
        Context["ReceivedTime"] = Fields["7355322.17:Received Time"].Value;
        Context["RFQType"] = Fields["7355322.17:Type of RFQ"].Value;
        Context["SendToBuyer"] = Fields["7355322.17:Send to Buyer"].Value;
        Context["UpdateInSap"] = Fields["7355322.17:SAP Update"].Value;
    }
    catch (Exception)
    {
        MessageBox.Show("An unexpected Error Occurred in the EvaluateChanges function. ");
    }
}

function UpdateTables()
{
    var strIndex = "";
    var strFileName = "";
    var strUpdatedInSap = "";
    var rfqNo = "";
    var src = "";
    var sql = "";
    var strRFQPrice = "";
    var hasMultiLines = String(Context["ReceivedTime"]);
    var scanpc = System.Environment.MachineName;
    var conStr:String = "Data Source=(DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST =156.8.245.220)(PORT = 1521)))(CONNECT_DATA=(SERVER=DEDICATED)(SERVICE_NAME=OTCS)));User ID=otcs;Password=otcs;";
    var conn:OracleConnection = new OracleConnection(conStr);
    var cmd:OracleCommand = new OracleCommand();
    var cmdUpd:OracleCommand = new OracleCommand();
    var cmdUpd2:OracleCommand = new OracleCommand();
    try
    {
        var hasMultiLines = String(Context["HasMultiLines"]);
        strIndex = Document["Index"];
        strFileName = strIndex.substring(0, strIndex.indexOf("#"));
        strUpdatedInSap = String(Context["UpdateInSap"]);
        rfqNo = Document["Indexing:7355322.17:RFQ Number:0"];
        src = Document["Indexing:7355322.17:Source:0"];
        strRFQPrice = Document["Indexing:7355322.17:RFQ Amount:0"];
        conn.Open();
        cmd.Connection = conn;
        cmdUpd.Connection = conn;
        cmdUpd2.Connection = conn;

        cmdUpd2.CommandText = "Update AMSA_RFQ_FILES set RFQNO = '" + rfqNo + "' Where FILENAME = '" + strFileName + "'";

        sql = "Update AMSA_RFQ set UPDATEDINSAP = " + strUpdatedInSap +  ", SCANPC = '" + scanpc + "', SCANDATE = sysdate, PRICE = '" + strRFQPrice + "', HASMULTILINES = " + hasMultiLines + " WHERE RFQNO = " + "'" + rfqNo + "'" ;
        cmdUpd.CommandText = sql;
        //MessageBox.Show(sql);
        //MessageBox.Show(src);
        cmdUpd.ExecuteNonQuery();
        if(src != "E-Mail")
        {
            cmdUpd2.ExecuteNonQuery();
        }
    }
    catch (Exception)
    {
        MessageBox.Show("An unexpected Error Occurred in the UpdateTables function. ");
    }
}


//check receive time it is incorrect

function InitialiseRfQ(rfqNo, src)
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
    var Err = "";
    var myFormat: DateTimeFormatInfo; 
    try
    {
        /*
        =====================================
         Clear Field Values and set defaults
        =====================================
        */
        Err = "Clear fields"
        Fields["7355322.17:Collective Number"].Value = "";
        Fields["7355322.17:Location No"].Value = "";
        Fields["7355322.17:Location"].Value = "";
        Fields["7355322.17:Closing Date"].Value = "";
        Fields["7355322.17:Closing Time"].Value = "";
        Fields["7355322.17:Vendor Number"].Value = "";
        Fields["7355322.17:Vendor Name"].Value = "";
        Fields["7355322.17:Source Detail"].Value = "";
        Fields["7355322.17:Buyer No"].Value = "";
        Fields["7355322.17:Buyer Name"].Value = "";
        Fields["7355322.17:Send to Buyer"].Value = "No";
        Fields["7355322.17:Scan Date"].Value = scandate;
        Fields["7355322.17:Scan Pc"].Value = scanpc;
        Fields["7355322.17:SAP Update"].Value = "0";
        Fields["HasMultiLines"].Value = false;
        Context["HasMultiLines"] = "0";
        /*
        =====================================
         Set Information Fields Readonly
        =====================================
        */
        Err = "Set information fields readonly"
        Fields["7355322.17:Collective Number"].ReadOnly = true;
        Fields["7355322.17:Material Number"].ReadOnly = true;
        Fields["7355322.17:Location No"].ReadOnly = true;
        Fields["7355322.17:Location"].ReadOnly = true;
        Fields["7355322.17:Closing Date"].ReadOnly = true;
        Fields["7355322.17:Closing Time"].ReadOnly = true;
        Fields["7355322.17:Vendor Number"].ReadOnly = true;
        Fields["7355322.17:Vendor Name"].ReadOnly = true;
        //Fields["7355322.17:Source"].ReadOnly = true;
        Fields["7355322.17:Buyer No"].ReadOnly = true;
        Fields["7355322.17:Buyer Name"].ReadOnly = true;
        //Fields["7355322.17:Buyer e-mail"].ReadOnly = true;
        Fields["7355322.17:Scan Pc"].ReadOnly = true;
        Fields["7355322.17:Scan Date"].ReadOnly = true;
        Fields["7355322.17:SAP Update"].ReadOnly = true;
        Fields["7355322.17:Created Date"].ReadOnly = true;
        Fields["Information"].ReadOnly = true;
        //Fields["7355322.17:Status"].ReadOnly = true;
        /*
        =====================================
         Set Information Fields Readonly
        =====================================
        */
        Fields["RFQNO"].Visible = false;
        /*
        ====================================
        Check invalid RFQ
        ====================================
        */
        
        if (rfqNo == "00")
        {
            Err = "Invalid RFQ"
            Fields["7355322.17:Collective Number"].Value = "0000000000";
            Fields["7355322.17:RFQ Number"].Value = "0000000000";
            Fields["7355322.17:RFQ Amount"].Value = "0.00";
            Fields["7355322.17:Received Date"].Value = TimeZone.CurrentTimeZone.ToLocalTime(DateTime.Now);
            Fields["7355322.17:Received Time"].Value = TimeZone.CurrentTimeZone.ToLocalTime(DateTime.Now).ToString("HH:mm");
            Fields["7355322.17:Location No"].Value = "IG01";
            Fields["7355322.17:Location"].Value = "Corporate Office";
            Fields["7355322.17:Closing Date"].Value = TimeZone.CurrentTimeZone.ToLocalTime(DateTime.Now);
            Fields["7355322.17:Closing Time"].Value = TimeZone.CurrentTimeZone.ToLocalTime(DateTime.Now).ToString("HH:mm");
            Fields["7355322.17:Type of RFQ"].Value = "Invalid";
            Fields["7355322.17:Status"].Value = "Review Required";
            Fields["7355322.17:SAP Update"].Value = "9";
            Fields["7355322.17:Send to Buyer"].Value = "Yes";
            Fields["7355322.17:Scan Date"].Value = scandate;
            Fields["7355322.17:Scan Pc"].Value = scanpc;
            //Fields["7355322.17:SAP Update"].Value = "0";

            MessageBox.Show("This RFQ Response has been marked as Invalid.","Invalid RFQ Response")
        }
        else
        {
            Err = "Valid RFQ"
            /*
            ==============================================================
            Check source and set the dates
            ==============================================================
            */
            Err = "1"

            if(src == "Fax")
            {
                //strIndex = Document["Index"];
                //strCreatedDate = strIndex.substring(strIndex.indexOf("#") + 1);
                ////MessageBox.Show(strCreatedDate);
                //strCreatedDate = strCreatedDate.substring(0, strCreatedDate.indexOf("."));
                //strCreatedDate = strCreatedDate.replace("_", ":");
                //strCreatedTime = strCreatedDate.substring(strCreatedDate.indexOf(" ") + 1);
                //strFileName = strIndex.substring(0, strIndex.indexOf("#"));
                //frmReceivedDate = Fields["7355322.17:Received Date"].Value;

                //if(strCreatedDate != "")
                //{
                //    Fields["7355322.17:Created Date"].Value = strCreatedDate;
                //    Fields["7355322.17:Created Date"].ReadOnly = true;

                //    if(strCreatedDate == "")
                //    {
                //        MessageBox.Show("No Date Detected","Info");
                //        strSetDate = "False";
                //    }
                //    else
                //    {
                //        Fields["7355322.17:Received Date"].Value = strCreatedDate;
                //        Fields["7355322.17:Received Time"] = strCreatedTime;
                //    }
                //}

                Fields["7355322.17:Created Date"].Value = scandate;
                Fields["7355322.17:Created Date"].ReadOnly = true;

                Fields["7355322.17:Received Date"].Value = scandate;
                Fields["7355322.17:Received Time"] = scandate.ToString("HH:mm");
            }
            Err = "2"

            if(src == "E-Mail")
            {
                received = result["FAXReceived"];
                var seconds:Int32 = Convert.ToInt32(received);

                dateTime1 = new DateTime(1970, 1, 1) + new TimeSpan(0, 0, seconds);
                dateTime1 = TimeZone.CurrentTimeZone.ToLocalTime(dateTime1);

                Fields["7355322.17:Created Date"].Value = dateTime1;
                Fields["7355322.17:Created Date"].ReadOnly = true;

                Fields["7355322.17:Received Date"].Value = dateTime1;
                Fields["7355322.17:Received Time"] = dateTime1.ToString("HH:mm");
            }

            Err = "3"
            if(src == "Hand Delivery")
            {
                //Fields["7355322.17:Received Date"].Value = "";
                //Fields["7355322.17:Received Time"] = "";
                Fields["7355322.17:Created Date"].Value = scandate;
                Fields["7355322.17:Created Date"].ReadOnly = true;

                Fields["7355322.17:Received Date"].Value = scandate;
                Fields["7355322.17:Received Time"] = scandate.ToString("HH:mm");
            }
            Err = "4"

            /*
            ====================================
             Connect to Oracle and set commands
            ====================================
            */
            Err = "5"
            var conStr:String = "Data Source=(DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST =156.8.245.220)(PORT = 1521)))(CONNECT_DATA=(SERVER=DEDICATED)(SERVICE_NAME=OTCS)));User ID=otcs;Password=otcs;"
            var conn:OracleConnection = new OracleConnection(conStr)
            Err = ""
            conn.Open()
            var cmd:OracleCommand = new OracleCommand()
            cmd.Connection = conn
            Err = "6"
            if(rfqNo.Length > 0)
            {
                cmd.CommandText = "select ID, RFQ_GROUPNO, LOCATIONNO, LOCATION, CLOSINGDATE, OURREF, VENDORNO, VENDORNAME, BUYERNO, BUYERNAME, UPDATEDINSAP, MATERIALNO, RETFAXNO, BUYEREMAIL, PRICE, SCANPC from AMSA_RFQ WHERE RFQNO = " + "'" + rfqNo + "'";
                Err = "7"
                /* 
                ============================================================================== 
                 Set fields from select script and perform additional check and field updates
                ==============================================================================
                */
                Err = "8"
                var dr:OracleDataReader = cmd.ExecuteReader()
                Err = "9"
                if (dr.Read())
                {
                    Err = "10"
                    if(dr["RFQ_GROUPNO"] != null){Fields["7355322.17:Collective Number"].Value = dr["RFQ_GROUPNO"];}
                    if(dr["LOCATIONNO"] != null){Fields["7355322.17:Location No"].Value = dr["LOCATIONNO"];}
                    if(dr["LOCATION"] != null){Fields["7355322.17:Location"].Value = dr["LOCATION"];}
                    if(dr["CLOSINGDATE"] != null){Fields["7355322.17:Closing Date"].Value = dr["CLOSINGDATE"];}
                    if(dr["OURREF"] != null){Fields["7355322.17:Closing Time"].Value = dr["OURREF"];}
                    if(dr["VENDORNO"] != null){Fields["7355322.17:Vendor Number"].Value = dr["VENDORNO"];}
                    if(dr["VENDORNAME"] != null){Fields["7355322.17:Vendor Name"].Value = dr["VENDORNAME"];}
                    if(dr["BUYERNO"] != null){Fields["7355322.17:Buyer No"].Value = dr["BUYERNO"];}
                    if(dr["BUYERNAME"] != null){Fields["7355322.17:Buyer Name"].Value = dr["BUYERNAME"];}
                    if(dr["BUYEREMAIL"] != null){Fields["7355322.17:Buyer e-mail"].Value = dr["BUYEREMAIL"];}
                    if(dr["PRICE"] != null && Fields["Rescan"].Value != "Yes"){Fields["7355322.17:RFQ Amount"].Value = dr["PRICE"];}
                    if(dr["UPDATEDINSAP"] != null){Fields["7355322.17:SAP Update"].Value = dr["UPDATEDINSAP"];}
				
                    Err = "11"
				
                    myFormat = System.Threading.Thread.CurrentThread.CurrentCulture.DateTimeFormat; 
                    var myDate	= Fields["7355322.17:Closing Date"].Value;
                    myDate = myDate.ToString(myFormat.ShortDatePattern);
                    Err = "11.1"
                    myDate = myDate.replace(/\//g, "-");
                    myDate = myDate.replace(/\./g, "-");
                    Err = "11.3"
                    //MessageBox.Show("myDate = " + myDate);
                    var arr		= myDate.split("-");
                    Err = "11.4"
                    var year	= arr[0];
                    var strMonth = "";

                    Err = "12"


                    if (arr[1] == "01" )
                    {
                        arr[1] = "01 - January";
                    }
                    else
                    {
                        if (arr[1] == "02" )
                        {
                            arr[1] = "02 - February";
                        }
                        else
                        {
                            if (arr[1] == "03" )
                            {
                                arr[1] = "03 - March";
                            }
                            else
                            {
                                if (arr[1] == "04" )
                                {
                                    arr[1] = "04 April";
                                }
                                else
                                {
                                    if (arr[1] == "05" )
                                    {
                                        arr[1] = "05 - May";
                                    }
                                    else
                                    {
                                        if (arr[1] == "06" )
                                        {
                                            arr[1] = "06 - June";
                                        }
                                        else
                                        {
                                            if (arr[1] == "07" )
                                            {
                                                arr[1] = "07 - July";
                                            }
                                            else
                                            {
                                                if (arr[1] == "08" )
                                                {
                                                    arr[1] = "08 - August";
                                                }
                                                else
                                                {
                                                    if (arr[1] == "09" )
                                                    {
                                                        arr[1] = "09 - September";
                                                    }
                                                    else
                                                    {
                                                        if (arr[1] == "10" )
                                                        {
                                                            arr[1] = "10 - October";
                                                        }
                                                        else
                                                        {
                                                            if (arr[1] == "11" )
                                                            {
                                                                arr[1] = "11 - November";
                                                            }
                                                            else
                                                            {
                                                                if (arr[1] == "12" )
                                                                {
                                                                    arr[1] = "12 - December";
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }										
                    }
                    Err = "13"
                    if(dr["SCANPC"] != null)
                    {
                        strTblScanPC = dr["SCANPC"]; 
                        strScannedAlready = "Yes";
                    }
                    Fields["Rescan"].Value = strContScan;
                    Err = "14"
                    if(strScannedAlready == "Yes")
                    {
                        strInformation = strInformation + "ScanPC=" + strTblScanPC + " | "
                        if(MessageBox.Show("This has already been scanned, must it be rescanned?", "Scanned Already", MessageBoxButtons.YesNo)==DialogResult.No)
                        {
                            Fields["Rescan"].Value = "No";
                        }
                        else
                        {
                            Fields["Rescan"].Value = "Yes";
                        }
                    }
                    Err = "15"
                    //strInformation = "Closing Date: " + year + ":" + arr[1]  + " | " + strInformation + "Continue Scanning=No | ";
                    strInformation = year + ":" + arr[1] + ":" + arr[2] + ":" + Fields["7355322.17:Collective Number"].Value;
                    if(src == "Fax")
                    {
                        if(dr["RETFAXNO"] != null){Fields["7355322.17:Source Detail"].Value = dr["RETFAXNO"];}
                    }
                    Err = "16"
                    if(src == "E-Mail")
                    {
                        var FAXLineGet = result["FAXLine"];
                        FAXLineGet = FAXLineGet.split('_')[1];
                        Fields["7355322.17:Source Detail"].Value = FAXLineGet;
                    }
                    Err = "17"
                    Fields["7355322.17:Type of RFQ"].Value = "Standard";

                    /*
                    ===========================================
                        Check if RFQ a Breakdown RFQ set RFQ Type
                    ===========================================
                    */
                    Err = "18"
                    if(dr["OURREF"] == "11:00")
                    {
                        if(MessageBox.Show("Is this a breakdown RFQ?", "Breakdown Check", MessageBoxButtons.YesNo)==DialogResult.Yes)
                        {
                            Fields["7355322.17:Type of RFQ"].Value = "Breakdown";
                            Fields["7355322.17:Status"].Value = "On-time";
                            RFQType = "Breakdown";
                        }
                        else
                        {
                            Fields["7355322.17:Type of RFQ"].Value = "Standard";
                            RFQType = "Standard";
                        }
                    }
                    /*
                    =======================================
                        Check if RFQ a Recon and Set RFQ Type
                    =======================================
                    */
                    Err = "19"
                    if(dr["MATERIALNO"] != null)
                    {
                        materialnumber = dr["MATERIALNO"];
                        Fields["7355322.17:Material Number"].Value = materialnumber;
			
                        if(RFQType != "Breakdown")
                        {
                            if(materialnumber.substring(0,1) == "R" || materialnumber.substring(0,1) == "L")
                            {
                                if(MessageBox.Show("Is this a Recon?", "Recon Check", MessageBoxButtons.YesNo)==DialogResult.Yes)
                                {
                                    Fields["7355322.17:Type of RFQ"].Value = "Recon";
                                    Fields["7355322.17:Status"].Value = "On-time";
                                }
                            }
                        }
                    }
                    Fields["Information"].Value = strInformation;
                    Err = "20"
                }
                Err = "21"
                conn.Close();
                return;
            }
        }
    }
    catch (Exception)
    {
        MessageBox.Show("An unexpected Error Occurred in the InitialiseRfQ function. Just after " + Err);
    }
}