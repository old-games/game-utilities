using System;
using System.IO;
using System.Text;
using System.Collections.Generic;

namespace OrionDC
{
    public class MainDat
    {
        public class SomeFile
        {
            public int id;
            public byte pref;
            public byte room;
            public string filename = "";
            public SomeFile(int id,byte[] data,ref int ofs)
            {
                this.id = id;
                pref = data[ofs];
                room = data[ofs + 1];
                ofs += 2;
                filename = StringHelper.ascii2uni(data, ref ofs);
            }
        }
        public class MainPart
        {
            public UInt16 ofs;
            public UInt16 count;
            public int length;
        }

        public class StringBlock
        {
            public List<OProg.OString> strings=new List<OProg.OString>();
            public int id = 0;
            public int offset;
            public StringBlock(int id,int ofs,int endofs,byte[] data)
            {
                this.id = id;
                int sid=0;
                offset = ofs;
                while (ofs < endofs)
                {
                    strings.Add(new OProg.OString(sid++,data,(ushort)ofs));
                    ofs+=strings[strings.Count-1].length+1;
                }
            }
        }

        string filename = "";
        string pref = "";
        public byte[] data;
        byte[] footer;
        public int[] progcnt=new int[2]{0,0};
        public UInt16 progmap=0;
        public MainPart actorsPart = new MainPart();
        public MainPart graphsPart = new MainPart();
        public MainPart musPart = new MainPart();
        public UInt16 charmap = 0;
        public UInt16 entry = 0;
        public List<SomeFile> graphs = new List<SomeFile>();
        public List<SomeFile> mus = new List<SomeFile>();
        public List<StringBlock> strings = new List<StringBlock>();

        public MainDat(string path,string pref)
        {
            this.filename = path + "/" + pref + "_main.dat";
            if (!File.Exists(filename))
                filename=path + "/" + pref + "_main.eng";
            if (!File.Exists(filename))
                throw new Exception("Main not found");
            this.pref = pref.ToLower();
            process();
        }

        public static string search(string path){
            DirectoryInfo di = new DirectoryInfo(path);
            foreach (FileInfo f in di.GetFiles())
            {
                string fn=f.Name.Substring(3).ToLower();
                if ( fn == "_main.dat" || fn=="_main.eng" )
                {
                    return f.Name.Substring(0, 3);
                }
            }
            return "";
        }

        public static void descramble(byte[] data, int ofs)
        {
            descramble(data, ofs, 0);
        }
        public static void descramble(byte[] data, int ofs, int len)
        {
            if (len == 0)
                len = data.Length - ofs;
            for (int i = ofs; i < ofs + len; i++)
                data[i] ^= 0x6F;
        }

        void process()
        {
            BinaryReader rd = new BinaryReader(new FileStream(filename, FileMode.Open, FileAccess.Read));
            int len = rd.ReadUInt16();
            rd.BaseStream.Position = 0;
            data = rd.ReadBytes(len);
            footer = rd.ReadBytes((int)(rd.BaseStream.Length - rd.BaseStream.Position));
            rd.Close();
            descramble(data, 2);
            progcnt[0] = BinHelper.read_U16LE(footer, 0x06);
            progcnt[1] = BinHelper.read_U16LE(footer, 0x08);
            progmap = BinHelper.read_U16LE(footer, 0x0A);
            actorsPart.count = BinHelper.read_U16LE(footer, 0x10);
            actorsPart.ofs = BinHelper.read_U16LE(footer, 0x12);
            entry = BinHelper.read_U16LE(footer, 0x42);
            charmap = BinHelper.read_U16LE(footer, 0x48);
            graphsPart.count = BinHelper.read_U16LE(footer, 0x20);
            graphsPart.ofs = BinHelper.read_U16LE(footer, 0x22);
            if (pref=="cer")
                proc_cer();
            parse();
        }

        void proc_cer()
        {
            musPart.count = BinHelper.read_U16LE(footer, 0x34);
            musPart.ofs = BinHelper.read_U16LE(footer, 0x36);
            int bid=0;
            strings.Add(new StringBlock(bid++,0x72C9,0x7353,data));
            strings.Add(new StringBlock(bid++, 0xC100, 0xC26E, data));
            strings.Add(new StringBlock(bid++, 0xC4DD, 0xD55C, data));
        }

        void parse()
        {
            int ofs = graphsPart.ofs;
            for (UInt16 i = 0; i < graphsPart.count; i++)
                graphs.Add(new SomeFile(i,data,ref ofs));
            graphsPart.length = ofs - graphsPart.ofs;
            ofs = musPart.ofs;
            for (UInt16 i = 0; i < musPart.count; i++)
                mus.Add(new SomeFile(i, data, ref ofs));
            musPart.length = ofs - musPart.ofs;
        }

        public void dump(string path)
        {
            string fname=Path.Combine(path,Path.GetFileName(filename));
            FileStream fs=new FileStream(fname,FileMode.Create);
            fs.Write(data,0,data.Length);
            fs.Write(footer,0,footer.Length);
            fs.Close();
        }
    }
}
