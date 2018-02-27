using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using BusinessClass;
using BusinessClass.AMSA;
using BusinessClass.AMSA.List;
using BusinessClass.SAP;
using BusinessClass.Static;
using System.Diagnostics;
using System.Configuration;
using BusinessClass.SAP.List;

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
            RFQ mylastRFQ = new RFQ();
            try
            {
                //Update statuses for price updating
                Double dblTemp;
                String resultString = "";
                mylastRFQ.UpdateRFQStatusForPriceConsideration();
                RFQList MyRFQList = RFQList.GetRFQList(); // Get a list where myRFQ.UpdatedInSap in (1,2); 
                foreach(RFQ myRfq in MyRFQList)
                {
                    if ((!String.IsNullOrEmpty(myRfq.RfqAmount)) || (!String.IsNullOrEmpty(myRfq.LineAmount)))
                    {
                        if ((Double.TryParse(myRfq.RfqAmount, out dblTemp)) || (Double.TryParse(myRfq.LineAmount, out dblTemp)))
                        {
                            resultString = classSAP.AMSAUpdateRFQ(myRfq);
                            if (!resultString.Equals("X"))  //No valid price was actully updated inSAP
                            {
                                if (String.IsNullOrEmpty(resultString))
                                {
                                    myRfq.Status = "IN SAP";
                                    myRfq.UpdatedInSap = 5;
                                    myRfq.SaveSAPStatus();
                                    classStatic.AppendLog(myRfq.RfqNo + "\t Uploaded successfully for closing date \t" + myRfq.ClosingDate.ToString());
                                    //}
                                }
                                else
                                {
                                    if (resultString.Equals("FAILED"))
                                    {
                                        myRfq.UpdatedInSap = 8;  // Indicator that indicates that the record has failed to update in SAP
                                        myRfq.Status = "SAP UPDATE FAILED";
                                        myRfq.SaveSAPStatus();
                                        classStatic.AppendLog(myRfq.RfqNo + "\t has failed to update price in SAP for closing date \t" + myRfq.ClosingDate.ToString());
                                    }
                                    else
                                    {
                                        classStatic.AppendLog(myRfq.RfqNo + "\t has thrown some unexpected exception. \t" + myRfq.ClosingDate.ToString());
                                    }
                                }
                            }
                        }
                    }
                }
                classStatic.AppendLog("Finished updating prices in sap on :" + DateTime.Now.ToString());
            }
            catch (Exception err)
            {
                String errorMessage = "An unexpected error occurred when Updating prices in SAP: " + err.Message;
                Console.WriteLine(errorMessage);
                classStatic.AppendLog(errorMessage);
            }
            try
            {
                //Prepare documents to be linked to SAP.
                mylastRFQ.LinkDocToArchivelink();
                //Get list of documents to be linked to SAP
                ArchiveLinkList myArcList = ArchiveLinkList.GetArchiveLinkList();
                String returnCode = "";
                foreach(ArchiveLink myArcObj in myArcList)
                {
                    returnCode = myArcObj.LinkDocumentToSAP();
                    if(String.IsNullOrEmpty(returnCode))
                    {
                        mylastRFQ.LinkDocToArchivelinkUpdateStatus(myArcObj.RecId, myArcObj.ArchDocId);
                        classStatic.AppendLog("A document for RFQ \t" + myArcObj.ObjId + "\t was successfully linked to SAP \t" );
                    }
                    else
                    {
                        classStatic.AppendLog("A document for RFQ \t" + myArcObj.ObjId + "\t has failed to link to SAP. Message received:\t" + returnCode);
                        // Mark with a status to stop it from perpetually retrying an item in error.
                    }
                }
                classStatic.AppendLog("Finished linking documents in sap on :" + DateTime.Now.ToString());
            }
            catch (Exception err)
            {
                String errorMessage = "An unexpected error occurred when linking documents to SAP through Archive Link: " + err.Message;
                Console.WriteLine(errorMessage);
                classStatic.AppendLog(errorMessage);
            }
            try
            {
                //Download new RFQ numbers with the RFQ information from SAP
                mylastRFQ.GetLastRFQ();
                if (String.IsNullOrEmpty(mylastRFQ.RfqNo))
                {
                    classSAP.GetRFQList(String.Empty);
                }
                else
                {
                    Int32 nrOfRetrievedRecords = 0;
                    nrOfRetrievedRecords = classSAP.GetRFQList(mylastRFQ.ToString());
                    classStatic.AppendLog("Number of RFQs retrieved from Sap greater than the current Max number :" + nrOfRetrievedRecords + ". Finished at " + DateTime.Now.ToString());
                    mylastRFQ.GetLast600RangeRFQ();
                    nrOfRetrievedRecords = classSAP.GetRFQList(mylastRFQ.ToString());
                    classStatic.AppendLog("Number of RFQs retrieved from Sap for 600 number range :" + nrOfRetrievedRecords + ". Finished at " + DateTime.Now.ToString());
                    mylastRFQ.GetLast601RangeRFQ();
                    nrOfRetrievedRecords = classSAP.GetRFQList(mylastRFQ.ToString());
                    classStatic.AppendLog("Number of RFQs retrieved from Sap for 601 number range :" + nrOfRetrievedRecords + ". Finished at " + DateTime.Now.ToString());
                }
                classStatic.AppendLog("Finished retrieving new RFQs from sap on :" + DateTime.Now.ToString());
            }
            catch (Exception err)
            {
                String errorMessage = "An unexpected error occurred when searching for new RFQs: " + err.Message;
                Console.WriteLine(errorMessage);
                classStatic.AppendLog(errorMessage);
            }
            classStatic.AppendLog("Application Ended on :" + DateTime.Now.ToString());
        }
    }
}
