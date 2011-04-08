using System;
using System.Collections.Generic;
using System.Drawing;
using System.Drawing.Imaging;
using System.Xml;
using System.IO;

namespace bassru
{
    public class BCharset : BResource
    {
        int[] widths = new int[128];
        int hgt = 1;
        int spc = 0;
        byte[] csdata;
        public BCharset(uint fnum,int hgt,int spc)
            : base(fnum, ResView.CharsetView.get())
        {
            this.hgt = hgt;
            this.spc = spc;
            byte[] data = getData();
            for (int i = 0; i < 128; i++)
                widths[i] = data[i];
            csdata = new byte[data.Length - 128];
            Array.Copy(data, 128, csdata, 0, csdata.Length);
        }
        public int height { get { return hgt; } set { hgt = value; } }
        public int spacing { get { return spc; } }
        public int charWidth(int i)
        {
            return widths[i];
        }
        public UInt16[] charData(int c,int chgt,int cspc,ref int width)
        {
            width = widths[c] + 1 - cspc;
            int idx = c * chgt * 4;
            UInt16[] res = new UInt16[chgt * 2];
            for (int i = 0; i < res.Length; i++)
            {
                if (csdata.Length <= idx)
                    res[i] = 0;
                else
                    res[i] = ByteHelper.READ_UINT16_BE(csdata,idx);
                idx += 2;
            }
            return res;
        }

        public Bitmap makeBitmap(bool masks,Color back,Color fore,Color frame)
        {
            Bitmap bmp = new Bitmap(16 * (masks ? 16 : 8), height * 16);
            Graphics g = Graphics.FromImage(bmp);
            for (int i = 0; i < 16; i++)
                for (int j = 0; j < 8; j++)
                {
                    int idx = i * 8 + j;
                    Rectangle rct = new Rectangle(j * (masks ? 32 : 16), i * height, (masks ? 32 : 16), height);
                    g.FillRectangle(new SolidBrush(back), rct);
                    int width = 0;
                    UInt16[] cdata = charData(idx, height, spacing, ref width);
                    for (int k = 0; k < height; k++)
                    {
                        UInt16 data = cdata[k * 2];
                        UInt16 mask = cdata[k * 2 + 1];
                        for (int m = 0; m < 16; m++)
                        {
                            bool dt = (data & 0x8000) != 0;
                            data <<= 1;
                            bool ms = (mask & 0x8000) != 0;
                            mask <<= 1;
                            if (masks)
                            {
                                if (dt)
                                    bmp.SetPixel(rct.X + m, rct.Y + k, fore);
                                if (ms)
                                    bmp.SetPixel(rct.X + 16 + m, rct.Y + k, fore);
                            }
                            else
                            {
                                if (ms)
                                {
                                    if (dt)
                                        bmp.SetPixel(rct.X + m, rct.Y + k, fore);
                                    else
                                        bmp.SetPixel(rct.X + m, rct.Y + k, frame);
                                }
                            }
                        }
                    }

                }
            return bmp;
        }

        public override bool export(string filename)
        {
            makeBitmap(true, Color.White, Color.Black, Color.Red).Save(filename,ImageFormat.Bmp);
            return true;
        }

        public override bool import(string filename)
        {
            byte[] xdata=new byte[csdata.Length+128];
            for (int i = 0; i < xdata.Length; i++)
                xdata[i] = 0;
            for (int i = 0; i < 128; i++)
                xdata[i] = (byte)widths[i];
            Bitmap bmp = new Bitmap(filename);
            Bitmap b2 = makeBitmap(true, Color.Black, Color.White, Color.Red);
            if (bmp.Width != b2.Width || bmp.Height != b2.Height)
                throw new ApplicationException("Bad charset bitmap size");
            for (int i=0; i < 16; i++)
                for (int j=0; j < 8; j++)
                {
                    int idx = i * 8 + j;
                    Rectangle rct = new Rectangle(j * 32, i * height, 32, height);
                    byte wdh = 0;
                    for (int k = 0; k < height; k++)
                    {
                        UInt16 data = 0;
                        UInt16 mask = 0;
                        for (int m = 0; m < 16; m++)
                        {
                            Color dc = bmp.GetPixel(rct.X + m, rct.Y + k);
                            Color mc = bmp.GetPixel(rct.X + 16 + m, rct.Y + k);
                            if (dc.ToArgb()!=Color.White.ToArgb())
                                if (wdh < m+1) wdh = (byte)(m+1);
                            data<<=1;
                            mask<<=1;
                            if (dc.ToArgb()!=Color.White.ToArgb())
                                data |= 1;
                            if (mc.ToArgb()!=Color.White.ToArgb())
                                mask |= 1;
                        }
                        if (data != 0 || mask != 0)
                        {
                            ByteHelper.WRITE_BE(data, xdata, 128 + idx * height * 4+(k*4));
                            ByteHelper.WRITE_BE(mask, xdata, 130 + idx * height * 4+(k*4));
                        }
                    }
                    if (wdh != 0)
                        xdata[idx] = wdh;
                }
            return SkyDisk.get().importFile((int)filenum, xdata);
        }
        public override string getFilter()
        {
            return BImage.bmpFilter;
        }
    }

    public class BText:BResource
    {
        List<UInt16> blocksizes = new List<UInt16>();
        List<UInt16> skipBytes = new List<UInt16>();
        byte[] tdata;
        int [,] hftbl;
        int lastblksz = 0;
        public BText(byte[] data):base(0,null)
        {
            hftbl = HuffText.getHuffText();
            prepare(data);
        }
        public BText(uint fnum)
            : base(fnum, ResView.TextViewcs.get())
        {
            hftbl=HuffText.getHuffText();
            byte[] data = getData();
            prepare(data);
        }

        public void prepare(byte[] data)
        {
            UInt16 skipTbl = ByteHelper.READ_UINT16_LE(data);
            UInt16 txtData = ByteHelper.READ_UINT16_LE(data, 2);
            int ofs = 4;
            while (ofs < skipTbl)
            {
                blocksizes.Add(ByteHelper.READ_UINT16_LE(data, ofs));
                ofs += 2;
            }
            ofs = skipTbl;
            for (int i = 0; i < blocksizes.Count + 1; i++)
            {
                int bc = 32;
                if (i==blocksizes.Count)
                {
                    lastblksz=txtData-ofs;
                    bc = lastblksz;
                }
                for (int j = 0; j < bc; j++)
                {
                    UInt16 b = data[ofs];
                    ofs++;
                    if ((b & 0x80) != 0)
                    {
                        b &= 0x7F;
                        b <<= 3;
                    }
                    skipBytes.Add(b);
                }
            }
            tdata = new byte[data.Length - txtData];
            Array.Copy(data, txtData, tdata, 0, tdata.Length);
        }

        public int blockCount { get {return blocksizes.Count+1; } }
        public int lastBlockSize { get { return lastblksz; } }
        private bool getBit(ref int ofs, ref int bit)
        {
            if (bit == 0)
            {
                ofs++;
                bit = 7;
            }
            else bit--;
            return (((tdata[ofs] >> bit)&0x01) != 0);

        }
        private string getChar(ref int ofs,ref int bit)
        {
            int pos = 0;
            while (true)
            {
                if (getBit(ref ofs, ref bit))
                    pos = hftbl[pos, 1];
                else
                    pos = hftbl[pos, 0];
                if (hftbl[pos, 0] == 0 && hftbl[pos, 1] == 0)
                    return HuffText.replaceChar((char)hftbl[pos, 2]);
            }
        }

        public string getText(int block, int N,bool isRu)
        {
            string res = "";
            int ofs = 0;
            for (int i = 0; i < block; i++)
                ofs += blocksizes[i];
            for (int i = 0; i < N;i++ )
                ofs+=skipBytes[block*32+i];
            int bit = ofs & 3;
            ofs >>= 2;
            bit ^= 3;
            bit++;
            bit <<= 1;
            string c ;
            while ((c=getChar(ref ofs,ref bit)) != string.Empty)
                res += c;
            if (isRu)
                res = makeRuString(res);
            return res;
        }

        uint getCharCode(char c,ref int bits)
        {
            /*
            int cnt = 0;
            for (int i = 0; i < hftbl.Length / 3; i++)
                if (hftbl[i, 2] == c && hftbl[i, 0] == 0 && hftbl[i, 1] == 0)
                    cnt++;
            if (cnt != 1)
                System.Windows.Forms.MessageBox.Show(String.Format("char {2:s}(0x{0:X}) found {1:d} times",(int)c,cnt,""+c));
             * */
            for (int i = 0; i < hftbl.Length / 3; i++)
                if (hftbl[i, 2] == c && hftbl[i, 0] == 0 && hftbl[i, 1] == 0)
                {
                    int pos = i;
                    uint res=0;
                    bits=0;
                    while (pos != 0)
                    {
                        bool fnd = false;
                        for(int j=0;j<hftbl.Length/3 && !fnd;j++)
                            if (hftbl[j, 0] == pos || hftbl[j,1]==pos)
                            {
                                fnd = true;
                                uint val=(uint)(hftbl[j, 1] == pos ? 1 : 0);
                                if (val == 1)
                                    res |= ((uint)1<<bits);
                                bits++;
                                pos = j;
                            }
                    }
                    return res;
                }
            throw new ApplicationException(string.Format("Char not found:  "+c+" (\\x{0:X2})",(int)c));
        }

        public override bool export(string filename)
        {
            XmlDocument doc = BPalette.getXmlDoc("bassru-text");
            for (int i = 0; i < blockCount; i++)
            {
                XmlElement blk = (XmlElement)doc.DocumentElement.AppendChild(doc.CreateElement("block"));
                blk.Attributes.Append(doc.CreateAttribute("id")).Value = i.ToString();
                for (int j = 0; j < (i==blockCount-1?lastblksz:32); j++)
                {
                    XmlElement t = (XmlElement)blk.AppendChild(doc.CreateElement("text"));
                    t.Attributes.Append(doc.CreateAttribute("id")).Value = j.ToString();
                    string cmt = "";
                    bool isRu=Config.get().isTextRu(filenum, i, j, ref cmt);
                    if (cmt != "" || isRu)
                    {
                        t.Attributes.Append(doc.CreateAttribute("comment")).Value = cmt;
                        t.Attributes.Append(doc.CreateAttribute("mode")).Value = isRu ? "ru" : "en";
                    }
                    t.AppendChild(doc.CreateTextNode(getText(i, j,isRu)));
                }
            }
            doc.Save(filename);
            return true;
        }

        void addBits(ref List<byte> txtdata,ref uint bitbuf, ref int bitpos, uint value, int bits)
        {
            bitbuf <<= bits;
            bitbuf |= (uint)(value & (((uint)1 << bits) - 1));
            bitpos += bits;
            while (bitpos >= 8)
            {
                int bpp = 0;
                while (bitpos - bpp > 8) bpp++;
                byte sub = (byte)(bitbuf >> (bpp));
                bitpos -= 8;
                txtdata.Add(sub);
                bitbuf &= (((uint)1 << bitpos) - 1);
            }
        }

        int subOfs(int ppos,int pbuf,int pos,int buf,bool block)
        {
            if (!block)
            {
                ppos <<= 2;
                ppos |= ((pbuf / 2) & 0x03);
            }
            pos <<= 2;
            pos |= ((buf / 2) & 0x03);
            return pos - ppos;
        }

        void appendText(ref List<UInt16> bs, ref List<UInt16> skp, ref List<byte> txtdata, ref uint bitbuf, ref int bitpos, int blk, int N, string val)
        {
            int ppos = txtdata.Count;
            int pbit = bitpos;
            char c=(char)0;
            do
            {
                c = HuffText.nextChar(ref val);
                int bits=0;
                uint code = getCharCode(c, ref bits);
                addBits(ref txtdata, ref bitbuf, ref bitpos, code, bits);
            } while (c != (char)0);
            if (bitpos % 2 != 0) addBits(ref txtdata, ref bitbuf, ref bitpos, 0, 1);
            if (N == 31)
            {
                int bppos = 0;
                int pblk = blk - 1;
                while (pblk >= 0)
                {
                    bppos += bs[pblk];
                    pblk--;
                }
                bs[blk] = (ushort)subOfs(bppos, 0, txtdata.Count, bitpos, true);
                bs.Add(0);
                for (int i = 0; i < 32; i++)
                    skp.Add(0);
            }
            else
            {
                ushort sofs=(ushort)subOfs(ppos,pbit,txtdata.Count,bitpos,false);
                if (sofs > 0x7F)
                    while ((sofs & 0x07) != 0)
                    {
                        addBits(ref txtdata, ref bitbuf, ref bitpos, 0, 2);
                        sofs = (ushort)subOfs(ppos, pbit, txtdata.Count, bitpos, false);
                    }
                skp[blk * 32 + N] = sofs;
            }
        }

        public XmlNode findBlock(XmlNode parent,int blkid)
        {
            foreach (XmlNode n in parent.ChildNodes)
                if (n.NodeType == XmlNodeType.Element && n.Name == "block")
                {
                    int bid = int.Parse(n.Attributes["id"].Value);
                    if (bid == blkid)
                        return n;
                }
            throw new ApplicationException(String.Format("Block not found {0:d}.", blkid));
        }
        public XmlNode findText(XmlNode parent, int txtid)
        {
            foreach (XmlNode n in parent.ChildNodes)
                if (n.NodeType==XmlNodeType.Element && n.Name=="text")
                {
                    int tid = int.Parse(n.Attributes["id"].Value);
                    if (tid == txtid)
                        return n;
                }
            throw new ApplicationException(String.Format("Text not found {0:d} in block {1:s}.", txtid,parent.Attributes["id"].Value));
        }
        public XmlNode findFile(XmlNode parent, int id)
        {
            foreach (XmlNode n in parent.ChildNodes)
                if (n.NodeType == XmlNodeType.Element && n.Name == "file")
                {
                    int fid = int.Parse(n.Attributes["id"].Value);
                    if (fid == id)
                        return n;
                }
            throw new ApplicationException(String.Format("File not found {0:d}.", id));
        }
        public override bool import(string filename)
        {
            XmlDocument doc = new XmlDocument();
            uint bitbuf = 0;
            int bitpos = 0;
            List<byte> txtdata = new List<byte>();
            List<UInt16> bs = new List<UInt16>();
            List<UInt16> skp = new List<UInt16>();
            bs.Add(0);
            for (int i = 0; i < 32; i++)
                skp.Add(0);
            doc.Load(filename);
            if (doc.DocumentElement.Name != "bassru-text" && doc.DocumentElement.Name!="bassru-text-all")
                throw new ApplicationException("Bad BassRu Text XML - bad root node name");
            XmlNode blockroot = doc.DocumentElement;
            if (doc.DocumentElement.Name == "bassru-text-all")
                blockroot = findFile(doc.DocumentElement, (int)filenum);
            for (int i = 0; i < blockCount; i++)
            {
                XmlNode n = findBlock(blockroot, i);
                int bc = 32;
                if (i == blockCount - 1)
                    bc = lastblksz;
                for (int N = 0; N < bc; N++)
                {
                    XmlNode t = findText(n, N);
                    string cmt = "", md = "";
                    if (t.Attributes["comment"] != null)
                        cmt = t.Attributes["comment"].Value;
                    if (t.Attributes["mode"] != null)
                        md = t.Attributes["mode"].Value;
                    if (cmt != "" || md != "")
                    {
                        string cm = "";
                        bool isru = Config.get().isTextRu(filenum, i, N, ref cm);
                        if (cm != cmt || (isru && md == "en") || (!isru && md == "ru"))
                        {
                            if (md == "ru") isru = true;
                            if (md == "en") isru = false;
                            Config.get().setTextInfo(filenum, (uint)i, (uint)N, isru, cmt);
                        }
                    }
                    string val = "";
                    foreach (XmlNode x in t.ChildNodes)
                        if (x.NodeType == XmlNodeType.Text)
                            val = x.Value;
                    val = fromRuConv(val);
                    appendText(ref bs, ref skp, ref txtdata, ref bitbuf, ref bitpos, i, N, val);
                }
            }
            if (bitpos > 0)
                addBits(ref txtdata, ref bitbuf, ref bitpos, 0, 8 - bitpos);
            byte[] res = new byte[4 + txtdata.Count + (bs.Count * 2) + skp.Count];
            ushort ofs = 4;
            for (int i = 0; i < blockCount-1;i++ )
            {
                ByteHelper.WRITE_LE(bs[i], res, ofs);
                ofs += 2;
            }
            ByteHelper.WRITE_LE(ofs, res);
            for (int j = 0; j < 32 * blockCount - 32 + lastblksz;j++ )
            {
                UInt16 r = skp[j];
                if (r > 0x7F)
                {
                    r >>= 3;
                    r |= 0x80;
                }
                res[ofs] = (byte)r;
                ofs++;
            }
            ByteHelper.WRITE_LE(ofs, res, 2);
            Array.Copy(txtdata.ToArray(), 0, res, ofs, txtdata.Count);
            return SkyDisk.get().importFile((int)filenum, res);
        }
        public override string getFilter()
        {
            return BPalette.xmlFilter;
        }

        private string makeRuString(string s)
        {
            string res = "";
            string cs="";
            string cmt="";
            while ((cs = HuffText.replaceChar(HuffText.nextChar(ref s))) != string.Empty)
            {
                string st=Config.get().getCharInfo(cs, ref cmt);
                if (st == string.Empty)
                    res += cs;
                else res += st;
            }
            return res;
        }

        private string fromRuConv(string s)
        {
            string res = "";
            for (int i = 0; i < s.Length; i++)
            {
                string es = Config.get().getRuCharInfo(""+s[i]);
                if (es == string.Empty)
                    res += s[i];
                else
                    res += es;
            }
            return res;
        }

    }
}
