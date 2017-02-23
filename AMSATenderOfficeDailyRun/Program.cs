using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using BusinessClass.AMSA;
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
                string reLoad = Properties.Settings.Default.ReloadAll;
                if (reLoad.ToUpper().Equals("YES"))
                {
                    classSAP.GetMissingRFQList(String.Empty);
                }
                else
                {
                    RFQ mylastRFQ = new RFQ();
                    mylastRFQ.GetLastRFQ();
                    long NewNumber = long.Parse(mylastRFQ.ToString());
                    NewNumber = NewNumber - 3000;
                    classSAP.GetMissingRFQList(NewNumber.ToString());
                    mylastRFQ.GetLast600RangeRFQ();
                    NewNumber = long.Parse(mylastRFQ.ToString());
                    NewNumber = NewNumber - 3000;
                    classSAP.GetMissingRFQList(NewNumber.ToString());
                    mylastRFQ.GetLast601RangeRFQ();
                    NewNumber = long.Parse(mylastRFQ.ToString());
                    NewNumber = NewNumber - 3000;
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
