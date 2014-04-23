using System;
using System.Collections.Generic;
using System.Drawing;
using System.IO;
using System.Text;
using System.Windows.Forms;

namespace RBView
{
    public class Palette
    {
        public Color[] cls = new Color[256];
        public string name = "";
        public Palette(byte[] data, string name, bool isFile)
        {
            if (data == null)
            {
                this.name = "GRAYSCALE";
                for (int i = 0; i < 256; i++)
                    cls[i] = Color.FromArgb(i, i, i);
                return;
            }
            this.name = name;
            if (isFile)
            {
                processData(Common.getSection(data,"PAL:VGA:"));
            }else
                processData(data);
        }
        public void processData(byte[] data)
        {
            for (int i = 0; i < 256; i++)
            {
                byte r = data[i * 3];
                byte g = data[i * 3 + 1];
                byte b = data[i * 3 + 2];
                r = (byte)((r << 2) + (r >> 4));
                g = (byte)((g << 2) + (g >> 4));
                b = (byte)((b << 2) + (b >> 4));
                cls[i] = Color.FromArgb(r, g, b);
            }
        }
    }

    public class Palettes
    {
        public static Palettes obj = null;
        public static Palettes get()
        {
            if (obj == null)
            {
                obj = new Palettes();
                obj.addPalette(new Palette(null,"",false));
            }
            return obj;
        }

        public List<Palette> pls = new List<Palette>();
        public void addPalette(Palette p)
        {
            pls.Add(p);
        }
        public void AddPalette(byte[] data, string nm, bool isFile)
        {
            pls.Add(new Palette(data,nm,isFile));
        }
        public Palette getPalette(string name)
        {
            for (int i = 0; i < pls.Count; i++)
                if (pls[i].name.ToLower() == name.ToLower())
                    return pls[i];
            return pls[0];
        }
    }

    class PartNotFoundException:Exception
    {
        public PartNotFoundException(string name)
            : base("Part not found " + name)
        {
        }
    }

    class Common
    {
        private static byte[] readSec(BinaryReader rd, string sname,int ofs)
        {
            string curn=sname.Substring(0,4);
            string othn=sname.Substring(4);
            while(ofs<rd.BaseStream.Length)
            {
                rd.BaseStream.Position = ofs;
                string s = new string(rd.ReadChars(4));
                if (s.Length==4 && s[3] == ':' && s[0] >= '0' && s[0] <= 'z' && s[1] >= '0' && s[1] <= 'z' && s[2] >= '0' && s[2] <= 'z')
                {
                    int sz = rd.ReadInt32();
                    if (s == curn)
                    {
                        if (othn == "")
                            return rd.ReadBytes(sz);
                        else
                            return readSec(rd, othn, ofs + 8);
                    }
                    else
                        ofs += sz+8;
                }
                else
                    throw new PartNotFoundException(sname);
            }
            throw new PartNotFoundException(sname);
        }

        public static byte[] getSection(byte[] data,string sec)
        {
            BinaryReader rd = new BinaryReader(new MemoryStream(data),Encoding.ASCII);
            byte[] res = readSec(rd, sec, 0);
            rd.Close();
            return res;
        }

        public static byte[] makeSections(byte[][] datas, string[] names,bool flag=false)
        {
            BinaryWriter wr = new BinaryWriter(new MemoryStream(),Encoding.ASCII);
            for (int i=0;i<datas.Length;i++)
            {
                wr.Write(names[i].ToCharArray());
                wr.Write((int)(datas[i].Length|(flag?(1<<31):0)));
                wr.Write(datas[i]);
            }
            byte[] res=new byte[wr.BaseStream.Length];
            wr.BaseStream.Position=0;
            wr.BaseStream.Read(res,0,res.Length);
            wr.Close();
            return res;
        }

        public static int readInt16(byte[] data,int ofs)
        {
            int res = 0;
            res = data[ofs] | (data[ofs + 1] << 8);
            return res;
        }
        public static void writeInt16(byte[] data, int ofs,int val)
        {
            data[ofs] = (byte)(val & 0xFF);
            data[ofs+1] = (byte)((val>>8) & 0xFF);
        }
        public static void writeInt32(byte[] data, int ofs, int val)
        {
            data[ofs] = (byte)(val & 0xFF);
            data[ofs + 1] = (byte)((val >> 8) & 0xFF);
            data[ofs + 2] = (byte)((val >> 16) & 0xFF);
            data[ofs + 3] = (byte)((val >> 24) & 0xFF);
        }

        static byte[] amg2vga(byte[] amg)
        {
            byte[] res = new byte[amg.Length * 4];
            for (int i = 0; i < amg.Length; i++)
            {
                byte b = amg[i];
                res[i * 4] = (byte)((((b>>7)&1)<<4)|((b>>6)&1));
                res[i * 4 + 1] = (byte)((((b >> 5) & 1) << 4) | ((b >> 4) & 1));
                res[i * 4 + 2] = (byte)((((b >> 3) & 1) << 4) | ((b >> 2) & 1));
                res[i * 4 + 3] = (byte)((((b >> 1) & 1) << 4) | ((b >> 0) & 1));
            }
            return res;
        }

        static byte[] vga2amg(byte[] vga)
        {
            if (vga.Length % 4 != 0)
                throw new Exception("Bad AMG length");
            byte[] res = new byte[vga.Length / 4];
            for (int i = 0; i < res.Length; i++)
            {
                byte b=0;
                for (int j = 0; j < 4; j++)
                {
                    b <<= 2;
                    b|=(byte)(((vga[i*4+j]>>3)&2)|(vga[i*4+j]&1));
                }
                res[i] = b;
            }
            return res;
        }

        public static byte[] mixData(byte[] bin, byte[] vga,bool amg)
        {
            if (amg)
                vga = amg2vga(vga);
            if (bin.Length != vga.Length)
                throw new Exception("Wrong array sizes in mix");
            byte[] res = new byte[bin.Length * 2];
            for (int i = 0; i < bin.Length; i++)
            {
                res[i * 2] = (byte)(((bin[i] & 0xF0) >> 4) | (vga[i] & 0xF0));
                res[i * 2+1] = (byte)((bin[i] & 0x0F) | ((vga[i] & 0x0F) << 4));
            }
            return res;
        }

        public static void splitData(byte[] data, ref byte[] bin, ref byte[] vga,bool amg)
        {
            if (data.Length % 2 == 1)
                throw new Exception("bad split data length");
            bin = new byte[data.Length / 2];
            vga = new byte[data.Length / 2];
            for (int i = 0; i < data.Length / 2; i++)
            {
                bin[i]=(byte)(((data[i*2]&0x0F)<<4) | (data[i*2+1]&0x0F));
                vga[i]=(byte)((data[i * 2] & 0xF0) | ((data[i * 2 + 1] & 0xF0)>>4));
            }
            if (amg)
                vga = vga2amg(vga);
        }

        public static string getSaveName(string filter)
        {
            SaveFileDialog sfd = new SaveFileDialog();
            switch (filter)
            {
                case "bmp":
                    sfd.DefaultExt = "bmp";
                    sfd.Filter = "Bitmap file(*.bmp)|*.bmp";
                    break;
                case "scr":
                    sfd.DefaultExt = "scr";
                    sfd.Filter = "Screen file(*.scr)|*.scr";
                    break;
                case "fnt":
                    sfd.DefaultExt = "fnt";
                    sfd.Filter = "Font file(*.fnt)|*.fnt";
                    break;
                
            }
            if (sfd.DefaultExt != "")
                sfd.AddExtension = true;
            if (sfd.Filter != "")
                sfd.FilterIndex = 0;
            if (sfd.ShowDialog() != DialogResult.OK)
                return "";
            return sfd.FileName;
        }

    }
}
