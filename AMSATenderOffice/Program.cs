﻿using System;
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
                RFQList MyRFQList = new RFQList();
                foreach(RFQ myRfq in MyRFQList)
                {
                    myRFQ.GetReturnInfo(Properties.Settings.Default.CategoryName, Properties.Settings.Default.AttribName1, Properties.Settings.Default.AttribName2, Properties.Settings.Default.AttribName3, Properties.Settings.Default.AttribName4);
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
