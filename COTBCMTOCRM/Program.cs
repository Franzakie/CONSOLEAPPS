﻿// The COTBCMTOCRM Console application
/*
 * Created by : EOH
 * Author: Franz Seidel
 * Description
 * This application exclusively finds Interaction Record numbers from CRM SAP for given Call Ids received in a special custom table called COT_RM_BCM.
*/
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

namespace COTBCMTOCRM
{
    class Program
    {
        static void Main(string[] args)
        {
            //Write a log file to the same directory in which the code is excecuted from
            classStatic.CreateLog("Application Started on :" + DateTime.Now.ToString());
            try
            {
                //Get a list of all CallId's for which an interaction number needs to be retrieved.
                CallList myCalls = new CallList();
                foreach (Call myCall in myCalls)
                {
                    // For each of the call Id's in the list do a query to  SAP to get the Interaction Number.
                    myCall.BCMStatus = "IARECFOUND";
                    classSAP.GetCotIARecord(myCall);
                }
            }
            catch (Exception err)
            {
                //Write any Exceptions that may occur to the Log file
                String errorMessage = "An unexpected error occurred: " + err.Message;
                Console.WriteLine(errorMessage);
                classStatic.AppendLog(errorMessage);
            }
            try
            {
                //Get a list of all Guids for Service Requests that are not yet linked to ECC
                CallList myCalls = new CallList(true);
                foreach (Call myCall in myCalls)
                {
                    myCall.BCMStatus = "Completed - ECC Connected";
                    classSAP.CallCOTAttachECC(myCall);
                }
            }
            catch (Exception err)
            {
                //Write any Exceptions that may occur to the Log file
                String errorMessage = "An unexpected error occurred: " + err.Message;
                Console.WriteLine(errorMessage);
                classStatic.AppendLog(errorMessage);
            }
            classStatic.AppendLog("Application Ended on :" + DateTime.Now.ToString());
        }
    }
}
