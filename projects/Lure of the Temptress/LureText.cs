using System;
using System.Collections.Generic;
using System.Text;
using System.Xml;
using System.IO;

namespace Vlure
{
    class TextDecoder
    {
        class Letter
        {
            public int value = 0;
            public int len = 0;
            public char chr;
            public Letter(string s,char c)
            {
                chr = c;
                len = s.Length;
                for (int i = 0; i < len; i++)
                {
                    if (s[i] == '1')
                        value |= (1 << i);
                }
            }
        }
        static TextDecoder obj;
        List<Letter> letters = new List<Letter>();
        public static TextDecoder get()
        {
            if (obj == null)
                obj = new TextDecoder();
            return obj;
        }
        public TextDecoder()
        {
            readDecoder(true);
        }
        byte[] olddec = null;
        public void readDecoder(bool old)
        {
            byte[] dec = null;
            if (old)
            {
                if (olddec == null)
                {
                    dec = LureConfig.get().DecodeTable;
                    olddec = new byte[dec.Length];
                    Array.Copy(dec, olddec, dec.Length);
                }
                else
                {
                    dec = new byte[olddec.Length];
                    Array.Copy(olddec, dec, dec.Length);
                }
            }else
                dec = LureConfig.get().DecodeTable;
            letters.Clear();
            int pos = 0;
            while (dec[pos] != 0xff)
            {
                char c = (char)dec[pos];
                pos++;
                string s = BinaryHelper.readZString(dec, pos);
                pos += s.Length + 1;
                letters.Add(new Letter(s,c));
            }
        }

        public static string replaceChar(char c)
        {
            if (c == '\\') return "\\";
            if (c == '\n') return "\\n";
            if (c == '\t') return "\\t";
            if (c == '\r') return "\\r";
            if (c == (char)0) return string.Empty;
            if (c > (char)122)
                return String.Format("\\x{0:X2}", (int)c);
            return "" + c;
        }
        public static char replaceString(string s)
        {
            if (s == string.Empty)
                return (char)0;
            if (s[0] == '\\')
            {
                if (s[1] == '\\') return '\\';
                if (s[1] == 'n') return '\n';
                if (s[1] == 't') return '\t';
                if (s[1] == 'r') return '\r';
                if (s[1] == '0') return (char)0;
                if (s[1] == 'x')
                    return (char)int.Parse(s.Substring(2, 2), System.Globalization.NumberStyles.AllowHexSpecifier);
            }
            return s[0];
        }

        public bool hasChar(int value,int len,ref char ch)
        {
            foreach(Letter l in letters)
                if (l.len == len && l.value == value)
                {
                    ch = l.chr;
                    return true;
                }
            return false;
        }
        public int getCharCode(char c, ref int len)
        {
            if (c == '/')
                c = (char)0x2F;
            foreach(Letter l in letters)
                if (l.chr == c)
                {
                    len = l.len;
                    return l.value;
                }
            throw new Exception("letter not found "+c);
        }

        void procNode(int code, int len, XmlNode nd, int maxlen)
        {
            if (len > maxlen)
                return;
            XmlNode n = nd.AppendChild(nd.OwnerDocument.CreateElement("node"));
            string bin = "";
            for (int i = 0; i < len; i++)
                bin = (((code >> i) & 1) == 1 ? "1" : "0") + bin;
            n.Attributes.Append(n.OwnerDocument.CreateAttribute("len")).Value = len.ToString();
            n.Attributes.Append(n.OwnerDocument.CreateAttribute("code")).Value = bin;
            char c=' ';
            if (hasChar(LureCommon.revert(code, len), len, ref c))
            {
                n.Attributes.Append(n.OwnerDocument.CreateAttribute("value")).Value = replaceChar(c);
                return;
            }
            procNode(code << 1, len + 1, n, maxlen);
            procNode((code << 1)|1, len + 1, n, maxlen);
        }

        public XmlDocument export()
        {
            XmlDocument doc = LureCommon.makeXml("lure-decoder");
            int maxlen = 0;
            foreach (Letter l in letters)
            {
                if (l.len > maxlen)
                    maxlen = l.len;
            }
            procNode(0, 1, doc.DocumentElement, maxlen);
            procNode(1, 1, doc.DocumentElement, maxlen);
            return doc;
        }

        public void impNode(XmlNode nd,ref byte[] dec,ref int pos)
        {
            if (nd.NodeType != XmlNodeType.Element || nd.Name != "node")
                return;
            if (nd.Attributes["value"] != null)
            {
                char c = replaceString(nd.Attributes["value"].Value);
                string cd = nd.Attributes["code"].Value;
                dec = LureCommon.checkArrLength(dec, pos + cd.Length + 2);
                dec[pos] = (byte)c;
                pos++;
                BinaryHelper.writeZString(dec, ref pos, cd);
                return;
            }
            foreach (XmlNode n in nd.ChildNodes)
                impNode(n, ref dec,ref pos);
        }

        public void import(XmlDocument doc)
        {
            if (doc.DocumentElement.Name != "lure-decoder")
                throw new Exception("bad decoder xml");
            byte[] dec = new byte[1];
            int pos=0;
            foreach (XmlNode nd in doc.DocumentElement.ChildNodes)
                impNode(nd,ref dec,ref pos);
            dec=LureCommon.checkArrLength(dec, pos + 1);
            dec[pos] = 0xff;
            pos++;
            LureDisks.setResource(LureConfig.get().decode_tbl, dec);
            //readDecoder();
        }
    }

    class LureNames
    {
        static LureNames obj = null;
        public static LureNames get()
        {
            if (obj == null)
                obj = new LureNames();
            return obj;
        }
        byte[] data = null;
        public LureNames()
        {
            data = LureConfig.get().Names;
        }
        public string getName(int index)
        {
            int nmStart = BinaryHelper.readU16_LE(data, index*2);
            return BinaryHelper.readZString(data, nmStart);
        }
        public string processNames(string s)
        {
            string res = s;
            int cnt=BinaryHelper.readU16_LE(data,0)/2;
            for (int i = 1; i < cnt; i++)
            {
                int strt=BinaryHelper.readU16_LE(data, i*2);
                string nm = BinaryHelper.readZString(data, strt);
                char code=(char)(i+0xA0);
                res.Replace(nm,""+code);
            }
            return res;
        }
    }

    class LureText
    {
        byte[] data = null;
        int resnum = -1;
        public LureText(int resnum)
        {
            this.resnum = resnum;
            data = LureDisks.getResource(resnum);
        }

        bool getBit(ref int ofs, ref int bit)
        {
            bool res = (data[ofs] & bit) != 0;
            bit >>= 1;
            if (bit == 0)
            {
                ofs++;
                bit = 0x80;
            }
            return res;
        }

        string getChar(ref int ofs,ref int bit)
        {
            int val=0;
            char ch='\0';
            for (int bts=1;bts<=18;++bts)
            {
                if (getBit(ref ofs,ref bit))
                    val|=1<<(bts-1);
                if (TextDecoder.get().hasChar(val, bts, ref ch))
                {
                    if (ch >= 0xA0 && ch!='%')
                        return LureNames.get().getName(ch - 0xa0);
                    return TextDecoder.replaceChar(ch);
                }
            }
            return null;
        }

        public void readString(XmlElement tNode, int ofs, int bit)
        {
            string r = "";
            string c;
            while ((c = getChar(ref ofs, ref bit)) != string.Empty)
                r += c;
            tNode.AppendChild(tNode.OwnerDocument.CreateTextNode(r));
        }

        public XmlDocument export()
        {
            return export(false);
        }
        public XmlDocument export(bool arts)
        {
            XmlDocument res = LureCommon.makeXml("lure-text");
            ushort skipTblOfs = BinaryHelper.readU16_LE(data, 0);
            ushort textData = BinaryHelper.readU16_LE(data, 2);
            int ofs = 4;
            int bglob = 0;
            int blkid = 0;
            while (ofs <= skipTblOfs)
            {
                XmlElement bNode = (XmlElement)res.DocumentElement.AppendChild(res.CreateElement("block"));
                bNode.Attributes.Append(res.CreateAttribute("id")).Value = blkid.ToString();
                int tid = 0;
                int tofs=skipTblOfs+32*blkid;
                int tglob = 0;
                while (tid < 32 && tofs<textData)
                {
                    XmlElement tNode = (XmlElement)bNode.AppendChild(res.CreateElement("text"));
                    tNode.Attributes.Append(res.CreateAttribute("id")).Value = tid.ToString();
                    int glob = bglob + tglob;
                    int bit = glob & 3;
                    if ((bit & 3) != 0)
                        bit = 0x80 >> (bit * 2);
                    else
                        bit = 0x80;
                    glob >>= 2;
                    glob += textData;
                    //final pos
                    while (getBit(ref glob, ref bit)) 
                        glob += 2;
                    //bool b1 = getBit(ref ofs, ref bit);
                    bool art = getBit(ref glob, ref bit);
                    if (arts)
                        tNode.Attributes.Append(res.CreateAttribute("art")).Value = art?"1":"0";
                    readString(tNode, glob, bit);
                    if ((data[tofs] & 0x80) == 0)
                        tglob += data[tofs];
                    else
                        tglob += (data[tofs] & 0x7f) << 3;
                    tofs++;
                    tid++;
                }
                blkid++;
                bglob += BinaryHelper.readU16_LE(data, ofs);
                ofs += 2;
            }
            return res;
        }

        public void addbit(bool bit,List<byte> txtdata,ref uint bitbuf,ref int bitpos)
        {
            bitbuf <<= 1;
            if (bit)
                bitbuf|=1;
            bitpos++;
            if (bitpos == 8)
            {
                txtdata.Add((byte)(bitbuf & 0xFF));
                bitpos = 0;
                bitbuf = 0;
            }
        }

        public void addText(string txt,List<byte> txtdata,ref uint bitbuf,ref int bitpos,bool art)
        {
            addbit(false, txtdata, ref bitbuf, ref bitpos);
            addbit(art, txtdata, ref bitbuf, ref bitpos);
            for (int i = 0; i < txt.Length + 1; i++)
            {
                char c = (char)0;
                if (i < txt.Length)
                    c = txt[i];
                int len = 0;
                int code = TextDecoder.get().getCharCode(c, ref len);
                for (int j = 0; j < len; j++)
                {
                    bool bit = (code >> (j) & 1) != 0;
                    addbit(bit, txtdata, ref bitbuf, ref bitpos);
                }
            }
        }

        public void import(XmlDocument xml)
        {
            XmlNode blkhld=null;
            if (xml.DocumentElement.Name == "lure-text")
                blkhld = xml.DocumentElement;
            else if (xml.DocumentElement.Name == "lure-texts")
                blkhld = LureCommon.findNode(xml.DocumentElement, "file", "id", resnum.ToString());
            else throw new Exception("Bad text xml");
            TextDecoder.get().readDecoder(true);
            XmlDocument prev = export(true);
            TextDecoder.get().readDecoder(false);
            uint bitbuf = 0;
            int bitpos = 0;
            List<byte> txtdata = new List<byte>();
            List<UInt16> bs = new List<UInt16>();
            List<byte> skp = new List<byte>();
            int prevblk=0;
            foreach(XmlNode nd in prev.DocumentElement.ChildNodes)
            {
                XmlNode blk = LureCommon.findNode(blkhld, "block", "id", nd.Attributes["id"].Value);
                int prevtxt=prevblk;
                foreach (XmlNode tnd in nd.ChildNodes)
                {
                    //bool art = tnd.Attributes["art"].Value == "1";
                    XmlNode txt = LureCommon.findNode(blk, "text", "id", tnd.Attributes["id"].Value);
                    string val="";
                    if (txt.ChildNodes.Count>0)
                        val = txt.ChildNodes[0].Value;
                    val=LureNames.get().processNames(LureConfig.get().convert(val));
                    addText(val, txtdata, ref bitbuf, ref bitpos, tnd.Attributes["art"].Value == "1");
                    if (bitpos % 2 == 1 )
                        addbit(false, txtdata, ref bitbuf, ref bitpos);
                   // if (tnd != nd.LastChild)
                    {
                        int ofs = (txtdata.Count<<2)+bitpos/2;
                        int d = ofs - prevtxt;
                        if (d > 0x7F)
                        {
                            while ((d & 7) != 0)
                            {
                                addbit(false, txtdata, ref bitbuf, ref bitpos);
                                ofs = (txtdata.Count << 2) + bitpos / 2;
                                d = ofs - prevtxt;
                            }
                            d = (d >> 3) | 0x80;
                        }
                        skp.Add((byte)d);
                        prevtxt = ofs;
                    }
                }
                if (nd != prev.DocumentElement.LastChild)
                {
                    int offset = (txtdata.Count << 2) + bitpos / 2;
                    bs.Add((UInt16)(offset - prevblk));
                    prevblk = offset;
                }
            }
            while (bitpos != 0)
                addbit(false, txtdata, ref bitbuf, ref bitpos);
            data = new byte[4 + bs.Count * 2 + skp.Count + txtdata.Count];
            int o=4;
            for (int i=0;i<bs.Count;i++)
            {
                BinaryHelper.write_LE(data, o, bs[i]);
                o += 2;
            }
            BinaryHelper.write_LE(data, 0, (UInt16)o);
            for (int i = 0; i < skp.Count; i++)
                data[o++] = skp[i];
            BinaryHelper.write_LE(data,2,(UInt16)o);
            for (int i = 0; i < txtdata.Count; i++)
                data[o++] = txtdata[i];
            LureDisks.setResource(resnum, data);
        }

    }

    class LureStringList
    {
        public int resnum;
        public byte[] data;
        public LureStringList(int id)
        {
            resnum = id;
            data = LureDisks.getResource(id);
        }
        public XmlDocument export()
        {
            XmlDocument res = LureCommon.makeXml("lure-strings");
            XmlNode blk = res.DocumentElement.AppendChild(res.CreateElement("block"));
            ushort count = BinaryHelper.readU16_LE(data, 0);
            int ofs=2;
            for (int i = 0; i < count; i++)
            {
                string str = BinaryHelper.readZString(data, ofs);
                ofs += str.Length + 1;
                XmlNode txt = blk.AppendChild(res.CreateElement("text"));
                txt.Attributes.Append(res.CreateAttribute("id")).Value=i.ToString();
                if (str!="")
                    txt.AppendChild(res.CreateTextNode(str));
            }
            return res;
        }
        public void import(XmlDocument doc)
        {
            XmlNode blk=null;
            if (doc.DocumentElement.Name == "lure-strings")
                blk=LureCommon.findNode(doc.DocumentElement,"block");
            else if (doc.DocumentElement.Name == "lure-texts")
                blk=LureCommon.findNode(LureCommon.findNode(doc.DocumentElement,"file","id",resnum.ToString()),"block");
            else
                throw new Exception("bad strings xml");
            ushort count = BinaryHelper.readU16_LE(data, 0);
            int curofs = 2;
            for (int i = 0; i < count; i++)
            {
                XmlNode nd = LureCommon.findNode(blk, "text", "id", i.ToString());
                string val = "";
                if (nd.ChildNodes.Count > 0)
                    val = LureConfig.get().convert(nd.ChildNodes[0].Value);
                data = LureCommon.checkArrLength(data, curofs + val.Length + 1);
                BinaryHelper.writeZString(data, ref curofs, val);
            }
            LureDisks.setResource(resnum, data);
        }
    }

    class LureTexts
    {
        static LureTexts obj = null;
        public static LureTexts get()
        {
            if (obj == null)
                obj = new LureTexts();
            return obj;
        }
        public static LureTexts getAllTexts()
        {
            get().xml.DocumentElement.RemoveAll();
            foreach (LureConfig.LureFile f in LureConfig.get().lureFiles)
                if (f.type == "text")
                    get().addText(new LureText(f.id).export(),f.id);
                else if (f.type == "string_list")
                    get().addText(new LureStringList(f.id).export(),f.id);
            return get();
        }
        public void setAllTexts(XmlDocument xml)
        {
            foreach (LureConfig.LureFile f in LureConfig.get().lureFiles)
                if (f.type == "text")
                    new LureText(f.id).import(xml);
                else if (f.type == "string_list")
                    new LureStringList(f.id).import(xml);
        }
        XmlDocument texts;
        public LureTexts()
        {
            texts = LureCommon.makeXml("lure-texts");
        }
        public void addText(XmlDocument doc,int id)
        {
            XmlNode nd=texts.DocumentElement.AppendChild(texts.CreateElement("file"));
            nd.Attributes.Append(texts.CreateAttribute("id")).Value = id.ToString();
            foreach (XmlNode tb in doc.DocumentElement.ChildNodes)
                nd.AppendChild(texts.ImportNode(tb, true));
        }
        public XmlDocument xml { get { return texts; } }
        public void save(string filename,int mode)
        {
            if (mode == 0)
            {
                texts.Save(filename);
                return;
            }
            StreamWriter wr=new StreamWriter(new FileStream(filename,FileMode.Create));
            foreach (XmlNode nd in texts.DocumentElement.ChildNodes)
                foreach (XmlNode bn in nd.ChildNodes)
                    foreach (XmlNode tn in bn.ChildNodes)
                        if (tn.ChildNodes.Count>0)
                            wr.WriteLine(tn.ChildNodes[0].Value);
                        else
                            wr.WriteLine();
            wr.Close();
        }
        public void load(string filename, int mode)
        {
            XmlDocument doc=new XmlDocument();
            if (mode==0)
            {
                doc.Load(filename);
                setAllTexts(doc);
                return;
            }
            StreamReader rd = new StreamReader(new FileStream(filename, FileMode.Open));
            getAllTexts();
            doc = xml;
            foreach (XmlNode nd in texts.DocumentElement.ChildNodes)
                foreach (XmlNode bn in nd.ChildNodes)
                    foreach (XmlNode tn in bn.ChildNodes)
                    {
                        foreach (XmlNode n in tn.ChildNodes)
                            tn.RemoveChild(n);
                        string s = rd.ReadLine();
                        if (s != "")
                            tn.AppendChild(doc.CreateTextNode(s));
                    }
            rd.Close();
            setAllTexts(doc);
        }
    }
}
