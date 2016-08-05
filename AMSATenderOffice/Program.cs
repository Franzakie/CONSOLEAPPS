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
                RFQ myRFQ = new RFQ();
                myRFQ.GetLastRFQ();
                classSAP.GetRFQList(myRFQ.ToString());
                RFQList MyRFQList = new RFQList(); // Get a list where myRFQ.UpdatedInSap = 0; 
                foreach(RFQ myRfq in MyRFQList)
                {
                    myRFQ.GetReturnInfo(Properties.Settings.Default.CategoryName, Properties.Settings.Default.AttribName1, Properties.Settings.Default.AttribName2, Properties.Settings.Default.AttribName3, Properties.Settings.Default.AttribName4);
                    if(!String.IsNullOrEmpty(myRFQ.RfqAmount))
                    {
                        myRFQ.Status = "PreSAP";
                        myRFQ.Save();
                        if (classSAP.AMSAUpdateRFQ(myRFQ.RfqNo, myRFQ.RfqAmount))
                        {
                            myRFQ.Status = "IN SAP";
                            myRFQ.Save();
                            if (myRFQ.UpdateRFQInContentServer(Properties.Settings.Default.CategoryName, Properties.Settings.Default.AttribName1, myRFQ.RfqAmount))
                            {
                                if (myRFQ.UpdateRFQInContentServer(Properties.Settings.Default.CategoryName, Properties.Settings.Default.AttribName2, "5"))
                                {
                                    myRFQ.UpdatedInSap = 1; 
                                    myRFQ.Status = "IN CS";
                                    myRFQ.Save();
                                }
                            }
                        }
                    }
                }
                //sort list with returned info
                var queryReturnedRFQs = from rfq in MyRFQList
                                        where rfq.Status != ""
                                        select rfq;
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
