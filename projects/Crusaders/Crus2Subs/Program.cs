using System;
using System.IO;
using System.Collections.Generic;
using System.Text;

namespace Crus2Subs
{
    class Program
    {
        static void usage()
        {
            Console.WriteLine(@"usage:
crus2subs.exe file.iff [out.txt] - convert .iff to .txt
crus2subs.exe *.iff - convert all *.iff to *.txt (in .iff directory)
crus2subs.exe file.txt [out.iff] - convert .txt to .iff
crus2subs.exe *.txt - convert all *.txt to *.iff (in *.txt directory)
");
        }

        static int reverse(int v)
        {
            return ((v >> 24) & 0xFF) | (((v >> 16) & 0xFF) << 8) | (((v >> 8) & 0xFF) << 16) | ((v & 0xFF) << 24);
        }

        const short EL=0x0A0D;
        const int FORM = 0x4d524f46;

        static void export(string fname,string outname)
        {
            Console.WriteLine("export " + fname + " to " + outname);
            BinaryReader rd = new BinaryReader(new FileStream(fname, FileMode.Open));
            BinaryWriter wr=new BinaryWriter(new FileStream(outname,FileMode.Create),Encoding.ASCII);
            if (rd.ReadInt32()!=FORM)
                throw new Exception("Bad IFF file format");
            wr.Write(reverse(FORM));
            wr.Write(EL);
            int xlen = reverse(rd.ReadInt32());
            if (rd.BaseStream.Length != xlen + 8)
                throw new Exception("Bad IFF file length");
            while (rd.BaseStream.Position<xlen+8)
            {
                if (rd.BaseStream.Position % 2 != 0)
                    rd.BaseStream.Position++;
                if (rd.BaseStream.Position == rd.BaseStream.Length)
                    break;
                int lname = rd.ReadInt32();
                wr.Write(lname);
                int len = rd.ReadInt32();
                if ((len & 0xFF) != 0)
                {
                    wr.Write(len);
                    len = rd.ReadInt32();
                }
                wr.Write(EL);
                len = reverse(len);
                if (len + rd.BaseStream.Position > rd.BaseStream.Length)
                    throw new Exception("Corrupted IFF file");
                long cpos=len+rd.BaseStream.Position;
                len = rd.ReadInt32();
                foreach (char c in String.Format("{0:D}:", len))
                    wr.Write(c);
                while (rd.BaseStream.Position < cpos)
                {
                    byte sl = rd.ReadByte();
                    for (int i = 0; i < sl-1; i++)
                    {
                        byte b = rd.ReadByte();
                        if (b == 0)
                            throw new Exception("Bad IFF Zstring format");
                        wr.Write(b);
                    }
                    byte bb = rd.ReadByte();
                    if (bb != 0)
                        throw new Exception("Bad IFF string format");
                    wr.Write(EL);
                    if (rd.BaseStream.Position < cpos)
                    {
                        len = rd.ReadInt32();
                        foreach (char c in String.Format("{0:D}:", len))
                            wr.Write(c);
                    }
                }
            }
            rd.Close();
            wr.Close();
            Console.WriteLine("exported");
        }

        static void doAll(string path,bool isexport)
        {
            if (path == "") path = "./";
            DirectoryInfo di = new DirectoryInfo(path);
            foreach (FileInfo fi in di.GetFiles())
            {
                if (isexport && fi.Extension.ToLower()==".iff")
                {
                    string outname=Path.GetFileNameWithoutExtension(fi.FullName)+".txt";
                    export(fi.FullName, outname);
                }
                if (!isexport && fi.Extension.ToLower() == ".txt")
                {
                    string outname = Path.GetFileNameWithoutExtension(fi.FullName) + ".iff";
                    import(fi.FullName, outname);
                }
            }
        }

        static byte[] makeLang(byte[] lang,byte[] data)
        {
            byte[] res = new byte[data.Length + 4 + lang.Length];
            int pos = 0;
            foreach (byte b in lang)
                res[pos++] = b;
            res[pos++] = (byte)((data.Length >> 24) & 0xFF);
            res[pos++] = (byte)((data.Length >> 16) & 0xFF);
            res[pos++] = (byte)((data.Length >> 8) & 0xFF);
            res[pos++] = (byte)(data.Length & 0xFF);
            Array.Copy(data, 0, res, pos, data.Length);
            return res;
        }

        static byte[] readLine(BinaryReader rd,ref int id,ref bool text)
        {
            id = 0;
            text = false;
            List<byte> res = new List<byte>();
            if (rd.BaseStream.Position == rd.BaseStream.Length)
                return res.ToArray();
            byte b = rd.ReadByte();
            bool hasd=false;
            bool dig = true;
            while (!hasd || b != 0x0A)
            {
                if (b == 0x0D)
                    hasd = true;
                else
                {
                    if (hasd)
                        res.Add(0x0D);
                    hasd = false;
                    if (b == 0x3A && dig)
                    {
                        text = true;
                        string sid=new String(Encoding.Unicode.GetChars(Encoding.Convert(Encoding.ASCII, Encoding.Unicode, res.ToArray())));
                        id = int.Parse(sid);
                        res.Clear();
                    } else
                        res.Add(b);
                    if (b < 0x30 || b > 0x39)
                        dig = false;
                }
                if (rd.BaseStream.Position == rd.BaseStream.Length)
                    return res.ToArray();
                b = rd.ReadByte();
            }
            return res.ToArray();
        }

        static void import(string fname, string outname)
        {
            Console.WriteLine("import " + fname + " to " + outname);
            BinaryReader rd = new BinaryReader(new FileStream(fname, FileMode.Open), Encoding.ASCII);
            if (rd.ReadInt32() != reverse(FORM) || rd.ReadInt16()!=EL)
                throw new Exception("Bad text file format");
            bool istext = false;
            int id = 0;
            byte[] curlang = readLine(rd,ref id,ref istext);
            List<byte[]> alldata = new List<byte[]>();
            List<byte> data = new List<byte>();
            while (curlang.Length>0)
            {
                byte[] s = readLine(rd, ref id, ref istext);
                if (istext)
                {
                    data.Add((byte)(id&0xFF));
                    data.Add((byte)((id>>8) & 0xFF));
                    data.Add((byte)((id >> 16) & 0xFF));
                    data.Add((byte)((id >> 24) & 0xFF));
                    data.Add((byte)(s.Length + 1));
                    foreach (byte b in s)
                        data.Add(b);
                    data.Add(0);
                }
                else
                {
                        alldata.Add(makeLang(curlang, data.ToArray()));
                        data.Clear();
                        curlang = s;
                }
            }
            rd.Close();
            int cnt = 0;
            foreach (byte[] x in alldata)
            {
                cnt += x.Length;
                if (x.Length % 2 != 0)
                    cnt += 1;
            }
            byte[] res = new byte[cnt+8];
            byte[] form = Encoding.Convert(Encoding.Unicode, Encoding.ASCII, Encoding.Unicode.GetBytes("FORM"));
            int pos = 0;
            foreach (byte b in form)
                res[pos++] = b;
            res[pos++] = (byte)((cnt >> 24) & 0xFF);
            res[pos++] = (byte)((cnt >> 16) & 0xFF);
            res[pos++] = (byte)((cnt >> 8) & 0xFF);
            res[pos++] = (byte)(cnt & 0xFF);
            foreach (byte[] x in alldata)
            {
                Array.Copy(x, 0, res, pos, x.Length);
                pos += x.Length;
                if (x.Length % 2 != 0)
                    res[pos++] = 0;
            }
            FileStream wr = new FileStream(outname, FileMode.Create);
            wr.Write(res, 0, res.Length);
            wr.Close();
            Console.WriteLine("imported");
        }

        static void exportAll(string path)
        {
            if (path == "") path = "./";
            DirectoryInfo di = new DirectoryInfo(path);
            foreach (FileInfo fi in di.GetFiles())
            {
                if (fi.Extension.ToLower() == ".iff")
                {
                    string outname = Path.GetFileNameWithoutExtension(fi.FullName) + ".txt";
                    export(fi.FullName, outname);
                }
            }
        }

        static void Main(string[] args)
        {
            Console.WriteLine("Crus2Subs v0.2 by bjfn @2011 4 OG proj");
            if (args.Length < 1)
            {
                usage();
                return;
            }
            try
            {
                string fname = args[0];
                if (Path.GetExtension(fname).ToLower() == ".iff")
                {
                    if (fname.ToLower().EndsWith("*.iff"))
                        doAll(Path.GetDirectoryName(fname),true);
                    else
                    {
                        string outname = Path.GetFileNameWithoutExtension(fname) + ".txt";
                        if (args.Length > 1) outname = args[1];
                        export(fname, outname);
                    }
                }
                else if (Path.GetExtension(fname).ToLower() == ".txt")
                {
                    if (fname.ToLower().EndsWith("*.txt"))
                        doAll(Path.GetDirectoryName(fname),false);
                    else
                    {
                        string outname = Path.GetFileNameWithoutExtension(fname) + ".iff";
                        if (args.Length > 1) outname = args[1];
                        import(fname, outname);
                    }
                }
                else throw new Exception("unknown file type "+fname);
            }catch(Exception ex)
            {
                Console.WriteLine("ERROR: "+ex.Message);
                Console.ReadKey();
            }
            Console.ReadKey();
        }
    }
}
