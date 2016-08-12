using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using BusinessClass;
using BusinessClass.List;
using BusinessClass.SAP;
using BusinessClass.Static;
using System.Diagnostics;
using System.Configuration;
using BusinessClass.List;

//Tender Office
//Franz Seidel
//2016-06-22
namespace AMSATenderOffice
{
    class Program
    {
        static void Main(string[] args)
        {
            classStatic.CreateLog("Application Started on :" + DateTime.Now.ToString());
            try
            {
                RFQ mylastRFQ = new RFQ();
                mylastRFQ.GetLastRFQ();
                classSAP.GetRFQList(mylastRFQ.ToString());
                RFQList MyRFQList = new RFQList(); // Get a list where myRFQ.UpdatedInSap = 0; 
                foreach(RFQ myRfq in MyRFQList)
                {
                    myRfq.GetReturnInfo(Properties.Settings.Default.CategoryName, Properties.Settings.Default.AttribName1, Properties.Settings.Default.AttribName2, Properties.Settings.Default.AttribName3, Properties.Settings.Default.AttribName4);
                    if (!String.IsNullOrEmpty(myRfq.RfqAmount))
                    {
                        myRfq.Status = "PreSAP";
                        myRfq.Save();
                        if (classSAP.AMSAUpdateRFQ(myRfq.RfqNo, myRfq.RfqAmount))
                        {
                            myRfq.Status = "IN SAP";
                            myRfq.Save();
                            //if (myRfq.UpdateRFQInContentServer(Properties.Settings.Default.CategoryName, Properties.Settings.Default.AttribName1, myRfq.RfqAmount))
                            //{
                            if (myRfq.UpdateRFQInContentServer(Properties.Settings.Default.CategoryName, Properties.Settings.Default.AttribName2, 5))
                            {
                                myRfq.UpdatedInSap = 5;  // Indicator that indicates that the record has successfully been updated in SAP
                                myRfq.Status = "IN CS";
                                myRfq.Save();
                            }
                            //}
                        }
                    }
                }
                //var queryReturnedRFQs = from rfq in MyRFQList
                //                        where rfq.Status != ""
                //                        select rfq;
                //classSAP.RFQUpdate((RFQList)queryReturnedRFQs);
            }
            catch (Exception err)
            {
                String errorMessage = "An unexpected error occurred: " + err.Message;
                Console.WriteLine(errorMessage);
                classStatic.AppendLog(errorMessage);
            }
            classStatic.AppendLog("Application Ended on :" + DateTime.Now.ToString());
        }
    }
}
