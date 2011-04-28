using System;
using System.IO;
using System.Runtime.InteropServices;
using System.Text;
using System.Xml;

namespace bassru_patcher
{
    class Patcher
    {
        [DllImport("kernel32.dll")]
        public static extern IntPtr FindResource(uint hModule, uint name, uint type);
        [DllImport("kernel32.dll")]
        public static extern IntPtr LoadResource(uint hModule, IntPtr hRes);
        [DllImport("kernel32.dll")]
        public static extern uint SizeofResource(uint hModule, IntPtr hRes);
        [DllImport("kernel32.dll")]
        public static extern IntPtr LockResource(IntPtr hLRes);


        string dskfile = "sky.dsk";
        string outfile = "sky.dsk";
        XmlDocument patchXml=null;
        byte[] patchData=null;
        bool install_pack = false;
        public Patcher(string[] args,int mode)
        {
            Console.WriteLine("configuring");
            if (mode == 0)
            {
                if (args.Length > 0)
                    outfile=dskfile = args[0];
                for (int i = 1; i < 3; i++)
                    if (args.Length > i)
                    {
                        if (args[i] == "-o")
                            outfile = args[2];
                        if (args[i] == "-i")
                            install_pack = true;
                    }
                patchData = getFromResource(114);
                if (patchData == null)
                    throw new Exception("Cant load binary resource");
                patchXml = new XmlDocument();
                byte[] bxml=getFromResource(113);
                if (bxml==null)
                    throw new Exception("Cant load xml resource");
                patchXml.LoadXml(new String(Encoding.Unicode.GetChars(
                    Encoding.Convert(Encoding.UTF8, Encoding.Unicode, bxml)
                    )));
            }
            else
            {
                string pconf = args[1];
                if (!File.Exists(pconf))
                    throw new Exception("File not exists "+pconf);
                int aid = 2;
                while (aid < args.Length)
                {
                    string x = args[aid];
                    aid++;
                    if (x == "-f")
                    {
                        if (outfile == dskfile)
                            outfile = dskfile = args[aid];
                        else
                            dskfile = args[aid];
                        aid++;
                    }
                    else if (x == "-o")
                    {
                        outfile = args[aid];
                        aid++;
                    }
                    else if (x == "-i")
                    {
                        install_pack = true;
                    }
                    else
                        throw new Exception("unknown param " + x);
                }
                patchXml = Common.getPatchXml(pconf);
                patchData = Common.getPatchData(patchXml);
            }
            if (!File.Exists(dskfile))
                throw new Exception("file not found "+dskfile);
        }

        public byte[] getFromResource(uint resid)
        {
            IntPtr r = FindResource(0, resid, 10);
            if (r == null)
                return null;
            int size=(int)SizeofResource(0,r);
            if (size==0)
                return null;
            IntPtr lr=LoadResource(0,r);
            if (lr==null)
                return null;
            IntPtr rdata = LockResource(lr);
            byte[] res=new byte[size];
            Marshal.Copy(rdata, res, 0, size);
            return res;
        }

        byte[] getRes(int id, XmlElement r)
        {
            foreach(XmlElement e in r.ChildNodes)
                if (int.Parse(e.Attributes["r"].Value) == id)
                {
                    int o = int.Parse(e.Attributes["o"].Value);
                    int s = int.Parse(e.Attributes["s"].Value);
                    byte[] res = new byte[s];
                    Array.Copy(patchData, o, res, 0, s);
                    return res;
                }
            return null;
        }

        public void patch()
        {
            SkyDisk.get().InstallPack = install_pack;
            Console.WriteLine("Patching");
            string pth = Path.GetDirectoryName(dskfile) + "\\";
            if (pth == "\\")
            {
                pth = Path.GetDirectoryName(System.Windows.Forms.Application.ExecutablePath) + "\\";
                if (outfile == dskfile)
                    outfile = pth + outfile;
                dskfile = pth + dskfile;
            }
            SkyDisk.get().path = pth;
            SkyDisk.get().readDinner();
            int resid = -1;
            byte[] res = null;
            XmlElement r = null;
            XmlElement c = null;
            XmlElement p = null;
            foreach (XmlElement n in patchXml.DocumentElement.ChildNodes)
                if (n.Name == "f")
                    p = n;
                else if (n.Name == "c")
                    c = n;
                else if (n.Name == "r")
                    r = n;
            foreach (XmlElement e in p.ChildNodes)
            {
                int rid = int.Parse(e.Attributes["r"].Value);
                Console.WriteLine(e.Attributes["f"].Value);
                BResource br = BResourceHelper.getResource(e, c);
                if (resid != rid)
                    res = getRes(rid, r);
                resid = rid;
                br.import(res);
            }
            Console.WriteLine("Saving");
            try
            {
                if (dskfile == outfile)
                {
                    File.Copy(SkyDisk.get().path + "sky.dsk", SkyDisk.get().path + "sky.backup.dsk");
                    File.Copy(SkyDisk.get().path + "sky.dnr", SkyDisk.get().path + "sky.backup.dnr");
                }
            }
            catch (Exception)
            {
            }

            SkyDisk.get().saveDiskAndDinner(outfile);
            Console.WriteLine("DONE");
        }
    }
}
