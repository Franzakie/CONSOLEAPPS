﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using BusinessClass;
using BusinessClass.List;
using BusinessClass.SAP;
using BusinessClass.Static;

namespace COTEFM
{
    class Program
    {
        static void Main(string[] args)
        {
            classStatic.CreateLog("Application Started on :" + DateTime.Now.ToString());
            try
            {
                classSAP.GetCOTEMPLOYEEList();
                //Process.Start("http://www.google.com");
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
