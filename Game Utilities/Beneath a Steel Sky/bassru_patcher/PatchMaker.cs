using System;
using System.IO;
using System.Runtime.InteropServices;
using System.Text;
using System.Xml;

namespace bassru_patcher
{
    class PatchMaker
    {

        [DllImport("kernel32.dll")]
        public static extern IntPtr BeginUpdateResource(string pFileName, [MarshalAs(UnmanagedType.Bool)]bool bDeleteExistingResources);
        [DllImport("kernel32.dll")]
        public static extern bool UpdateResource(IntPtr hUpdate, uint lpType, uint lpName, ushort wLang, byte[] lpData, uint cbData);
        [DllImport("kernel32.dll")]
        public static extern bool EndUpdateResource(IntPtr hUpdate,bool fDiscard);


        string outfile = "";
        string patchconf = "patch.xml";
        public PatchMaker(string[] args)
        {
            outfile = "bassru_patch_"+DateTime.Now.ToShortDateString()+"_"+DateTime.Now.ToShortTimeString().Replace(":","")+".exe";
            patchconf = args[1];
            int curarg = 2;
            while (curarg < args.Length)
            {
                string x = args[curarg];
                curarg++;
                if (x == "-o")
                {
                    outfile = args[curarg];
                    curarg++;
                }
                else
                    throw new Exception("unknown param "+x);
            }
            if (!File.Exists(patchconf))
                throw new Exception("File not found " + patchconf);
                
        }

        public bool insertResource(string fname, uint id,byte[] data)
        {
            IntPtr p=BeginUpdateResource(fname, false);
            if (p == null)
                return false;
            if (UpdateResource(p, 10, id, (1 << 10), data, (uint)data.Length))
            {
                EndUpdateResource(p, false);
                return true;
            }
            return false;
        }

        public void run()
        {
            try
            {
                Console.WriteLine("Making patch "+outfile);
                File.Copy(System.Windows.Forms.Application.ExecutablePath, outfile, true);
                XmlDocument patchXml = Common.getPatchXml(patchconf);
                byte[] patchData = Common.getPatchData(patchXml);
                byte[] pxml = Encoding.Convert(Encoding.Unicode, Encoding.UTF8, Encoding.Unicode.GetBytes(patchXml.InnerXml));
                if (!insertResource(outfile, 113, pxml))
                    throw new Exception("cant embed xml resource");
                if (!insertResource(outfile, 114, patchData))
                    throw new Exception("cant embed binary resource");
                Console.WriteLine("DONE");
            }
            catch (Exception)
            {
                File.Delete(outfile);
                throw;
            }
        }
    }
}
