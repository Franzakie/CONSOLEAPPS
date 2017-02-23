using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using BusinessClass.AMSA;
using BusinessClass.AMSA.List;
using BusinessClass.SAP;
using BusinessClass.Static;
using System.Diagnostics;
using System.Configuration;

namespace AMSAVendorManagement
{
    class Program
    {
        static void Main(string[] args)
        {
            classStatic.CreateLog("Application Started on :" + DateTime.Now.ToString());
            try
            {
                Boolean updatedInSap = false;
                classStatic.CreateLog("Find Records to Update in SAP :" + DateTime.Now.ToString());
                AMSAVendorCertificateList myList = new AMSAVendorCertificateList();
                foreach (AMSAVendorCertificate myVendorCert in myList)
                {
                    updatedInSap = classSAP.AMSAUpdateVendorCertExpDate(myVendorCert);
                    myVendorCert.SaveWorkflowStatus(updatedInSap);
                }
                classStatic.CreateLog("Download new Certificates :" + DateTime.Now.ToString());
                classSAP.AMSAStoreVendorCert(); //Ask Barry to create a record by record deletion function
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
