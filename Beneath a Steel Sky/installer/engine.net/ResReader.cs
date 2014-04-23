using System;
using System.IO;
using System.Runtime.InteropServices;
using System.Windows.Forms;
using System.Collections.Generic;
using System.Xml;
using System.Text;

namespace engine.net
{

    public class ResourceNotFoundException : Exception
    {
        public ResourceNotFoundException() : base("Resource not found") { }
        public ResourceNotFoundException(string name) : base("Resource not found: "+name) { }
    }

    public class ResReader
    {
        public ResReader()
        {
        }
        public virtual bool hasResource(string name)
        {
            return false;
        }
        public virtual byte[] getResource(string name)
        {
            return null;
        }
        public virtual uint resSize(string name)
        {
            return 0;
        }
    }

#if !NO_EXTERNAL
    public class ExternalResReader : ResReader
    {
        string path="";

        public static bool valid()
        {
            return File.Exists(Path.Combine(Path.GetDirectoryName(Application.ExecutablePath),"install.cfg"));
        }
        public ExternalResReader()
        {
            path=Path.GetDirectoryName(Application.ExecutablePath);
        }
        public override bool  hasResource(string name)
        {
 	        return File.Exists(Path.Combine(path,name));
        }
        public override byte[]  getResource(string name)
        {
            if (!File.Exists(Path.Combine(path, name)))
                throw new ResourceNotFoundException(name);
 	        FileStream fs=new FileStream(Path.Combine(path,name),FileMode.Open);
            byte[] res=new byte[fs.Length];
            fs.Read(res,0,res.Length);
            fs.Close();
            return res;
        }
        public override uint resSize(string name)
        {
            if (!File.Exists(Path.Combine(path, name)))
                throw new ResourceNotFoundException(name);
            FileInfo f = new FileInfo(Path.Combine(path, name));
            return (uint)f.Length;
        }
    }
#endif

    public class OneFileResReader : ResReader
    {
        MemoryStream alldata=null;
        public class FileEntry
        {
            public string name;
            public UInt32 ofs;
            public UInt32 rsize;
            public UInt32 csize;
            public FileEntry(BinaryReader rd)
            {
                name = new String(rd.ReadChars(16));
                name=name.Replace("\0", "");
                ofs = rd.ReadUInt32();
                csize = rd.ReadUInt32();
                rsize = rd.ReadUInt32();
            }
        };
        public List<FileEntry> entries = new List<FileEntry>();
        public OneFileResReader(bool none) { }
        public OneFileResReader()
        {
            FileStream fs = new FileStream(Path.Combine(Path.GetDirectoryName(Application.ExecutablePath), "data.bin"), FileMode.Open);
            byte[] data = new byte[fs.Length];
            fs.Read(data, 0, data.Length);
            fs.Close();
            setBytes(data);
        }

        public void setBytes(byte[] data)
        {
            BinaryReader rd = new BinaryReader(new MemoryStream(data),Encoding.UTF8);
            entries.Clear();
            UInt32 cnt=rd.ReadUInt32();
            for (UInt32 i = 0; i < cnt; i++)
                entries.Add(new FileEntry(rd));
            if (alldata!=null)
                alldata.Dispose();
            alldata = new MemoryStream(data, (int)rd.BaseStream.Position, (int)(rd.BaseStream.Length - rd.BaseStream.Position));
            alldata.Write(rd.ReadBytes((int)alldata.Length), 0, (int)alldata.Length);
            rd.Close();
        }
        public static bool valid()
        {
 	        return File.Exists(Path.Combine(Path.GetDirectoryName(Application.ExecutablePath),"data.bin"));
        }
        public override bool hasResource(string name)
        {
            foreach (FileEntry e in entries)
                if (e.name == name)
                    return true;
            return false;
        }

        public override byte[] getResource(string name)
        {
            foreach(FileEntry e in entries)
                if (e.name == name)
                {
                    alldata.Position = e.ofs;
                    byte[] res = new byte[e.csize];
                    alldata.Read(res, 0, (int)e.csize);
                    if (e.rsize != 0)
                        res = Decompressor.decompress(res, e.rsize);
                    return res;
                }
            throw new ResourceNotFoundException(name);
        }
        public override uint resSize(string name)
        {
            foreach(FileEntry e in entries)
                if (e.name == name)
                {
                    if (e.rsize != 0)
                        return e.rsize;
                    return e.csize;
                }
            throw new ResourceNotFoundException(name);
        }
    }

    public class InternalResReader : OneFileResReader
    {
        [DllImport("kernel32.dll")]
        public static extern IntPtr FindResource(uint hModule, uint name, uint type);
        [DllImport("kernel32.dll")]
        public static extern IntPtr LoadResource(uint hModule, IntPtr hRes);
        [DllImport("kernel32.dll")]
        public static extern uint SizeofResource(uint hModule, IntPtr hRes);
        [DllImport("kernel32.dll")]
        public static extern IntPtr LockResource(IntPtr hLRes);

        public InternalResReader():base(true)
        {
            IntPtr r = FindResource(0, 113, 10);
            if (r == null)
                throw new ResourceNotFoundException();
            int size = (int)SizeofResource(0, r);
            if (size == 0)
                throw new ResourceNotFoundException();
            IntPtr lr = LoadResource(0, r);
            if (lr == null)
                throw new ResourceNotFoundException();
            IntPtr rdata = LockResource(lr);
            byte[] res = new byte[size];
            Marshal.Copy(rdata, res, 0, size);
            setBytes(res);
        }
    }

    public class ResourceLocator
    {
        public static ResReader obj = null;
        public static ResReader getResources()
        {
            if (obj == null)
                obj = locateReader();
            return obj;
        }

        public static ResReader locateReader()
        {
            if (obj != null)
                return obj;
#if !NO_EXTERNAL
            if (ExternalResReader.valid())
                return new ExternalResReader();
#endif
            if (OneFileResReader.valid())
                return new OneFileResReader();
            return new InternalResReader();
        }

        public static XmlDocument readXmlResource(string name,string checkRoot)
        {
            byte[] data = getResources().getResource(name);
            MemoryStream ms = new MemoryStream(data);
            XmlDocument doc = new XmlDocument();
            doc.Load(ms);
            ms.Close();
            if (checkRoot != null && checkRoot != "")
                if (doc.DocumentElement.Name != checkRoot)
                    throw new ResourceNotFoundException(name);
            return doc;
        }
    }
}
