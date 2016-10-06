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

namespace AMSATenderOfficeDailyRun
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
                    classSAP.GetMissingRFQList(String.Empty);
                }
                else
                {
                    long NewNumber = long.Parse(mylastRFQ.ToString());
                    NewNumber = NewNumber - 3000;
                    classSAP.GetMissingRFQList(NewNumber.ToString());
                    mylastRFQ.GetLast600RangeRFQ();
                    NewNumber = long.Parse(mylastRFQ.ToString());
                    NewNumber = NewNumber - 3000;
                    classSAP.GetMissingRFQList(NewNumber.ToString());
                    mylastRFQ.GetLast601RangeRFQ();
                    NewNumber = long.Parse(mylastRFQ.ToString());
                    NewNumber = NewNumber - 3500;
                    classSAP.GetMissingRFQList(NewNumber.ToString());
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
