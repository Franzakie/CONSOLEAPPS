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

namespace CokeAndChemicals
{
    class Program
    {
        static void Main(string[] args)
        {
            classStatic.CreateLog("Application Started on :" + DateTime.Now.ToString());
            //String sMode = "";
            //if (args.Length < 1)
            //{
            //    Console.WriteLine("Usage: AMSAEncrypt e <password>");
            //    return;
            //}
            //sMode = args[0];
            //if (sMode == "Run")
            //{
            try
            {
                CokeAndCOrder saveThisCokeOrder;
                CokeAndChemicalsList myList = new CokeAndChemicalsList();
                foreach (CokeAndCOrder myCokeOrder in myList)
                {
                    saveThisCokeOrder = classSAP.GetCokeAndCOrderInfo(myCokeOrder);
                    myCokeOrder.IsDirty = true;
                    saveThisCokeOrder.Save();
                    classStatic.AppendLog("Sap Order Number: " + myCokeOrder.DeliveryNo + ", Trailer Number: " + myCokeOrder.TrailerNr);
                }
            }
            catch(Exception err)
            {
                String errorMessage = "An unexpected error occurred: " + err.Message;
                Console.WriteLine(errorMessage);
                classStatic.AppendLog(errorMessage);
            }
            classStatic.AppendLog("Application Ended on :" + DateTime.Now.ToString());
        }
        //}
    }
}
