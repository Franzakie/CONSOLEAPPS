using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Net;
using System.Net.Mail;
using System.Reflection;
using System.IO;


namespace COTBCMTOCRM
{
    class MailConstructor
    {
        public static void CreateGMail(String BodyMessage)
        {
            try
            {
                var fromAddress = new MailAddress("Franz.Seidel@EOH.co.za");
                var toAddress = new MailAddress("Gatiep.Morofe@CapeGraneries.co.za");
                string fromPassword = "";
                const string subject = "This is a test Subject";
                var smtp = new SmtpClient
                {
                    Host = "smtp.gmail.com",
                    Port = 587,
                    EnableSsl = false,
                    DeliveryMethod = SmtpDeliveryMethod.Network,
                    UseDefaultCredentials = false,
                    Credentials = new NetworkCredential(fromAddress.Address, fromPassword)
                };
                smtp.DeliveryMethod = SmtpDeliveryMethod.SpecifiedPickupDirectory;
                Attachment attachment = new Attachment(@"D:\TEST\xmlfile.xml");
                MailMessage message = new MailMessage(fromAddress, toAddress);
                message.Attachments.Add(attachment);
                message.Subject = subject;
                message.Body = BodyMessage;
                smtp.PickupDirectoryLocation = @"D:\TEST";
                smtp.Send(message);
            }
            catch (Exception err)
            {
                throw err;
            }
        }
    }
}
