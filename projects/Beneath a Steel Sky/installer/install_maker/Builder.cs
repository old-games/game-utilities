using System;
using System.Collections.Generic;
using System.IO;
using System.Runtime.InteropServices;
using System.Text;
using System.Windows.Forms;
using System.Xml;

namespace install_maker
{
    class Builder
    {
        [DllImport("kernel32.dll")]
        public static extern IntPtr BeginUpdateResource(string pFileName, [MarshalAs(UnmanagedType.Bool)]bool bDeleteExistingResources);
        [DllImport("kernel32.dll")]
        public static extern bool UpdateResource(IntPtr hUpdate, uint lpType, uint lpName, ushort wLang, byte[] lpData, uint cbData);
        [DllImport("kernel32.dll")]
        public static extern bool EndUpdateResource(IntPtr hUpdate, bool fDiscard);

        public const string INST_API_TAG = "INST_API_JS";
        public const string INST_API_FILE = "inst_api.js";
        string NET_INSTALLER = Path.Combine(Path.GetDirectoryName(Application.ExecutablePath), "engine.net.exe");
        const string OUT_NET_INSTALLER = "install.exe";
        string INST_API_PATH = Path.Combine(Path.Combine(Path.GetDirectoryName(Application.ExecutablePath), "api"), INST_API_FILE);
        public static Builder obj = null;
        public static Builder getBuilder()
        {
            if (obj == null)
                obj = new Builder();
            return obj;
        }

        public string build_path = "";
        bool compress=true;
        string icon = "";
        int type = 0;
        string name = "install";
        bool intBro = true;
        bool sz = false;
        bool mx = false;
        int w = 640;
        int h = 480;
        bool dbg = false;
        bool con = false;
        bool log = false;
        List<string> aliases = new List<string>();
        List<string> fnames = new List<string>();
        UInt32 cnt = 0;
        BinaryWriter fdata=null;
        BinaryWriter fhead = null;
        bool hasindex = false;
        public Builder()
        {
        }

        public void clear()
        {
            aliases.Clear();
            fnames.Clear();
            hasindex = false;
        }

        public void setParams(string name,int type,bool compressed,string icon)
        {
            this.compress = compressed;
            this.icon = icon;
            this.type = type;
            this.name = name;
        }
        public void setBrowser(bool intern, bool sizeable, bool maximized, int width, int height)
        {
            intBro = intern;
            sz = sizeable;
            mx = maximized;
            w = width;
            h = height;
        }
        public void setFlags(bool debug, bool console, bool logfile)
        {
            dbg = debug;
            con = console;
            log = logfile;
        }

        public void addFile(string name,string path)
        {
            aliases.Add(name);
            if (path == INST_API_TAG)
                path = INST_API_PATH;
            fnames.Add(path);
            if (name == "index.html")
                hasindex = true;
        }

        public string preparePath(string path)
        {
            string res=Path.Combine(path,"out");
            if (Directory.Exists(res))
                Directory.Delete(res,true);
            Directory.CreateDirectory(res);
            File.Copy(NET_INSTALLER, Path.Combine(res, OUT_NET_INSTALLER));
            return res;
        }

        public byte[] makeconfig()
        {
            XmlDocument doc = new XmlDocument();
            XmlNode root = doc.AppendChild(doc.CreateElement("icfg"));
            root.Attributes.Append(doc.CreateAttribute("nm")).Value = name;
            if (intBro)
            {
                root.Attributes.Append(doc.CreateAttribute("w")).Value = mx?"mx":w.ToString();
                if (!mx)
                    root.Attributes.Append(doc.CreateAttribute("h")).Value = h.ToString();
                if (sz)
                    root.Attributes.Append(doc.CreateAttribute("sz")).Value = "1";
            }
            int flg = 0;
            if (dbg)
                flg |= 1;
            if (con)
                flg |= 2;
            if (log)
                flg |= 4;
            if (flg != 0)
                root.Attributes.Append(doc.CreateAttribute("l")).Value = flg.ToString();
            return Encoding.Convert(Encoding.Unicode, Encoding.UTF8, Encoding.Unicode.GetBytes(doc.OuterXml));
        }

        void prepareFiles(string outpath)
        {
            if (type > 1)
                return;
            cnt = 0;
            fdata = new BinaryWriter(new MemoryStream());
            fhead = new BinaryWriter(new MemoryStream());
            fhead.Write((UInt32)0);
        }
        void commitFiles(string outpath)
        {
            if (type >1)
                return;
            byte[] alldata = new byte[fdata.BaseStream.Length + fhead.BaseStream.Length];
            fhead.BaseStream.Position = 0;
            fhead.Write(cnt);
            fhead.BaseStream.Position = 0;
            fhead.BaseStream.Read(alldata, 0, (int)fhead.BaseStream.Length);
            fdata.BaseStream.Position = 0;
            fdata.BaseStream.Read(alldata, (int)fhead.BaseStream.Length, (int)fdata.BaseStream.Length);
            fhead.Close();
            fdata.Close();
            if (type == 1)
            {
                FileStream fs = new FileStream(Path.Combine(outpath, "data.bin"),FileMode.Create);
                fs.Write(alldata, 0, alldata.Length);
                fs.Close();
            }
            else
            {
                IntPtr p = BeginUpdateResource(Path.Combine(outpath,OUT_NET_INSTALLER), false);
                if (p == null)
                    throw new Exception("Can't file installer resources");
                if (UpdateResource(p, 10, 113, (1 << 10), alldata, (uint)alldata.Length))
                {
                    EndUpdateResource(p, false);
                    return;
                }
                throw new Exception("Can't update resource");
            }
        }
        void addFile(string infile,string fname,string outpath)
        {
            FileStream fs = new FileStream(infile, FileMode.Open);
            byte[] data = new byte[fs.Length];
            fs.Read(data, 0, data.Length);
            fs.Close();
            if (Path.GetExtension(infile) == ".js")
                data = JSObfuscator.obfuscate(data);
            addFile(data, fname, outpath);
        }
        void addFile(byte[] data, string fname, string outpath)
        {
            if (type == 2)
            {
                FileStream fs = new FileStream(Path.Combine(outpath, fname), FileMode.Create);
                fs.Write(data, 0, data.Length);
                fs.Close();
                return;
            }
            UInt32 csz = (UInt32)data.Length;
            UInt32 rsz = 0;
            if (compress)
            {
                byte[] rdata = Compressor.compress(data);
                if (rdata.Length < csz)
                {
                    rsz = csz;
                    data = rdata;
                    csz = (UInt32)data.Length;
                }
            }
            byte[] arr = Encoding.Convert(Encoding.Unicode, Encoding.UTF8, Encoding.Unicode.GetBytes(fname));
            byte[] nm = new byte[16];
            int i = 0;
            for (; i < arr.Length; i++)
                nm[i] = arr[i];
            for (; i < 16; i++)
                nm[i] = 0;
            cnt++;
            fhead.Write(nm);
            fhead.Write((UInt32)fdata.BaseStream.Position);
            fhead.Write(csz);
            fhead.Write(rsz);
            fdata.Write(data);
        }

        public void build(string path)
        {
            if (!hasindex)
                throw new Exception("No index.html file");
            build_path = path;
            string dir = preparePath(path);
            prepareFiles(dir);
            byte[] data=makeconfig();
            addFile(data, "install.cfg", dir);
            for (int i = 0; i < aliases.Count; i++)
                addFile(fnames[i], aliases[i], dir);
            commitFiles(dir);
        }
    }
}
