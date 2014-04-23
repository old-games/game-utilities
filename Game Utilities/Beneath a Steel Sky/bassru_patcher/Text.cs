using System;
using System.Collections.Generic;
using System.Drawing;
using System.Xml;

namespace bassru_patcher
{
    public class BCharset : BResource
    {
        int height = 1;
        int spc = 0;
        int fwidth = 0;
        int xlen = 0;
        public BCharset(uint fnum,int hgt,int spc)
            : base(fnum)
        {
            height = hgt;
            this.spc = spc;
            byte[] xdt = SkyDisk.get().readFile((int)filenum);
            fwidth = xdt[0];
            xlen = xdt.Length;
        }
        public override bool import(byte[] file)
        {
            byte[] xdata=new byte[xlen];
            for (int i = 0; i < xdata.Length; i++)
                xdata[i] = 0;
            for (int i = 0; i < 128; i++)
                xdata[i] = (byte)fwidth;
            Bitmap bmp = new Bitmap(new System.IO.MemoryStream(file));
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
                            if (dc.ToArgb()!=Color.White.ToArgb())// || mc.ToArgb()!=Color.White.ToArgb())
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
    }

    public class BText:BResource
    {
        List<UInt16> blocksizes = new List<UInt16>();
       // List<UInt16> skipBytes = new List<UInt16>();
        int [,] hftbl;
        int lastblksz = 0;
        XmlElement ruCharNode = null;
        public BText(uint fnum,XmlElement ruch)
            : base(fnum)
        {
            hftbl=HuffText.getHuffText();
            byte[] data = SkyDisk.get().readFile((int)fnum);
            ruCharNode = ruch;
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
//                    UInt16 b = data[ofs];
                    ofs++;
//                    if ((b & 0x80) != 0)
//                    {
//                        b &= 0x7F;
//                        b <<= 3;
 //                   }
  //                  skipBytes.Add(b);
                }
 
             
            }
        }

        public int blockCount { get {return blocksizes.Count+1; } }
        public int lastBlockSize { get { return lastblksz; } }
        uint getCharCode(char c,ref int bits)
        {
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
        public override bool import(byte[] file)
        {
            XmlDocument doc = xmlFromBytes(file);
            uint bitbuf = 0;
            int bitpos = 0;
            List<byte> txtdata = new List<byte>();
            List<UInt16> bs = new List<UInt16>();
            List<UInt16> skp = new List<UInt16>();
            bs.Add(0);
            for (int i = 0; i < 32; i++)
                skp.Add(0);
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
        string getRuCharInfo(string ch)
        {
            foreach (XmlElement e in ruCharNode)
                if (e.Attributes["r"].Value == ch)
                    return e.Attributes["e"].Value;
            return string.Empty;
        }

        private string fromRuConv(string s)
        {
            string res = "";
            for (int i = 0; i < s.Length; i++)
            {
                string es = getRuCharInfo(""+s[i]);
                if (es == string.Empty)
                    res += s[i];
                else
                    res += es;
            }
            return res;
        }

    }
}
