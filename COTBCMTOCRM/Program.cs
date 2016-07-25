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
//            MailConstructor.CreateGMail("This is some obscure message in the body");

            classStatic.CreateLog("Application Started on :" + DateTime.Now.ToString());
            try
            {
                CallList myCalls = new CallList();
                foreach (Call myCall in myCalls)
                {
                    myCall.BCMStatus = "IARECFOUND";
                    classSAP.GetCotIARecord(myCall);
                }
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
