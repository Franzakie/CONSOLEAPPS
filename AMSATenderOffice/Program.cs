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
                if (String.IsNullOrEmpty(mylastRFQ.RfqNo))
                {
                    classSAP.GetRFQList(String.Empty);
                }
                else
                {
                    classSAP.GetRFQList(mylastRFQ.ToString()); 
                    mylastRFQ.GetLast600RangeRFQ();
                    classSAP.GetRFQList(mylastRFQ.ToString());
                    mylastRFQ.GetLast601RangeRFQ();
                    classSAP.GetRFQList(mylastRFQ.ToString());
                }
                //Update statuses for price updating
                mylastRFQ.UpdateRFQStatusForPriceConsideration();
                RFQList MyRFQList = new RFQList(); // Get a list where myRFQ.UpdatedInSap in (1,2); 
                foreach(RFQ myRfq in MyRFQList)
                {
                    if (!String.IsNullOrEmpty(myRfq.RfqAmount))
                    {
                        if (classSAP.AMSAUpdateRFQ(myRfq.RfqNo, myRfq.RfqAmount))
                        {
                            myRfq.Status = "IN SAP";
                            myRfq.UpdatedInSap = 5;  
                            myRfq.Save();
                            classStatic.AppendLog(myRfq.RfqNo + "\t Uploaded successfully for closing date \t" + myRfq.ClosingDate.ToString());
                            //}
                        }
                        else
                        {
                            myRfq.UpdatedInSap = 8;  // Indicator that indicates that the record has failed to update in SAP
                            myRfq.Status = "SAP UPDATE FAILED";
                            myRfq.Save();
                            classStatic.AppendLog(myRfq.RfqNo + "\t has failed for closing date \t" + myRfq.ClosingDate.ToString());
                        }
                    }
                }
                //Link documents to SAP.
                mylastRFQ.LinkDocToArchivelink();

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
