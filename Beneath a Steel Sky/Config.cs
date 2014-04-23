using System;
using System.Collections.Generic;
using System.IO;
using System.Windows.Forms;
using System.Xml;

namespace bassru
{
    class Config
    {
        XmlDocument doc=new XmlDocument();
        XmlElement fileroot = null;
        XmlElement rtroot = null;
        XmlElement trroot = null;
        MemoryStream engTxtData = null;

        public struct PaletteInfo
        {
            public uint fid;
            public string name;
            public BPalette pal;
            public PaletteInfo(XmlElement node,int mode)
            {
                if (node == null)
                {
                    pal = BPalette.GrayScalePalette();
                    name = pal.name;
                    fid = 0;
                    return;
                }
                if (mode == 0)
                {
                    pal = (BPalette)BResourceHelper.getResource(node);
                    name = pal.name;
                    fid = pal.filenum;
                }
                else
                {
                    pal = new BPalette(node);
                    name = pal.name;
                    fid = 0;
                }
            }
        };

        public struct FileInfo
        {
            public uint fid;
            public string type;
            public string comment;
            public XmlElement node;
            public FileInfo(XmlElement el)
            {
                if (el == null)
                {
                    fid = 0; type = comment = ""; node = null;
                    return;
                }
                node=el;
                fid = uint.Parse(el.Attributes["id"].Value);
                type = el.Attributes["type"].Value;
                comment = el.Attributes["comment"].Value;
            }
        };

        public struct RuCharInfo
        {
            public string en;
            public string ru;
            public string comment;
            public XmlElement node;
            public RuCharInfo(XmlElement el)
            {
                node = el;
                en = el.Attributes["en"].Value;
                ru = el.Attributes["ru"].Value;
                comment = el.Attributes["comment"].Value;
            }
        };

        public struct TextInfo
        {
            public bool ru;
            public uint fileId;
            public uint block;
            public uint N;
            public string comment;
            public XmlElement node;
            public TextInfo(XmlElement el)
            {
                node = el;
                fileId = uint.Parse(el.Attributes["file"].Value);
                block = uint.Parse(el.Attributes["block"].Value);
                N = uint.Parse(el.Attributes["N"].Value);
                comment = el.Attributes["comment"].Value;
                ru = (el.Attributes["mode"].Value == "ru");
            }
        };

        public static FileInfo NullFileInfo = new FileInfo(null);
        public static Config obj = null;
        public static Config get()
        {
            if (obj == null) obj = new Config();
            return obj;
        }

        List<FileInfo> files = new List<FileInfo>();
        List<PaletteInfo> palettes = new List<PaletteInfo>();
        List<RuCharInfo> ruchars = new List<RuCharInfo>();
        List<TextInfo> texts = new List<TextInfo>();
        BText[] engtxt = new BText[8];
        string filename = "";
        string engtxtfile;
        public Config()
        {
            for (int i = 0; i < 8; i++)
                engtxt[i] = null;
            filename = Path.GetDirectoryName(Application.ExecutablePath) + "\\bassru.xml";
            engtxtfile = Path.GetDirectoryName(Application.ExecutablePath) + "\\engtxt.bin";
            doc.Load(filename);
            reload();
        }

        void addPalette(XmlElement node)
        {
            if (palettes.Count > 1)
            {
                for (int i = 1; i < palettes.Count; i++)
                {
                    String nm=node.Attributes["name"]!=null?node.Attributes["name"].Value:"unnamed";
                    if (String.Compare(nm, palettes[i].name) <0)
                    {
                        palettes.Insert(i, new PaletteInfo(node,0));
                        return;
                    }
                }
            }
            palettes.Add(new PaletteInfo(node,0));
        }

        public void reload()
        {
            files.Clear();
            ruchars.Clear();
            texts.Clear();
            palettes.Clear();
            palettes.Add(new PaletteInfo(null,0));
            if (doc.DocumentElement.Name != "bassru")
                throw new ApplicationException("Bad Config Root Node");
            foreach (XmlElement e in doc.DocumentElement.ChildNodes)
                if (e.Name == "files")
                {
                    fileroot = e;
                    foreach (XmlElement f in e.ChildNodes)
                        if (f.Name == "file")
                        {
                            files.Add(new FileInfo(f));
                            if (files[files.Count - 1].type == "palette")
                                addPalette(f);
                        }
                }
                else if (e.Name == "rutable")
                {
                    rtroot = e;
                    foreach(XmlElement r in e.ChildNodes)
                        if (r.Name == "char")
                            ruchars.Add(new RuCharInfo(r));
                }
                else if (e.Name == "textres")
                {
                    trroot = e;
                    foreach(XmlElement t in e.ChildNodes)
                        if (t.Name == "text")
                            texts.Add(new TextInfo(t));
                }
            readEngTxtData();
            string cptfl = Path.GetDirectoryName(Application.ExecutablePath) + "\\skycpt.xml";
            if (File.Exists(cptfl))
            {
                XmlDocument cpt = new XmlDocument();
                cpt.Load(cptfl);
                foreach(XmlNode n in cpt.DocumentElement)
                    if (n.NodeType == XmlNodeType.Element)
                    {
                        if (n.Name == "palettes")
                            foreach(XmlNode pn in n.ChildNodes)
                                if (pn.NodeType==XmlNodeType.Element && pn.Name=="pal")
                                {
                                    palettes.Add(new PaletteInfo((XmlElement)pn, 1));
                                }
                    }
            }
        }

        public FileInfo findFile(uint id)
        {
            foreach (FileInfo fi in files)
                if (fi.fid == id) return fi;
            return NullFileInfo;
        }

        public bool hasFile(uint id)
        {
            foreach (FileInfo fi in files)
                if (fi.fid == id) return true;
            return false;
        }

        public BPalette findPalette(String name)
        {
            return findPalette(name, true);
        }
        public BPalette findPalette(String name,bool def)
        {
            foreach (PaletteInfo p in palettes)
                if (p.name == name) return p.pal;
            if (def)
                return BPalette.GrayScalePalette();
            return null;
        }

        public string[] paletteNames()
        {
            List<string> nms = new List<string>();
            foreach (PaletteInfo p in palettes)
                nms.Add(p.name);
            return nms.ToArray();
        }

        public void updateConfig(uint fid,Dictionary<string,string> prms)
        {
            XmlElement foundXml = null;
            foreach (XmlElement f in fileroot.ChildNodes)
                if (f.Name == "file" && uint.Parse(f.Attributes["id"].Value) == fid)
                    foundXml = f;
            XmlElement nuelem = doc.CreateElement("file");
            nuelem.Attributes.Append(doc.CreateAttribute("id")).Value = fid.ToString();
            foreach (string atr in prms.Keys)
                nuelem.Attributes.Append(doc.CreateAttribute(atr)).Value = prms[atr];
            if (foundXml == null)
                fileroot.AppendChild(nuelem);
            else
                fileroot.ReplaceChild(nuelem, foundXml);
            doc.Save(filename);
            reload();
        }

        public string getCharInfo(string en, ref string comment)
        {
            foreach(RuCharInfo rc in ruchars)
                if (rc.en == en)
                {
                    comment = rc.comment;
                    return rc.ru;
                }
            comment = "";
            return string.Empty;
        }

        public string getRuCharInfo(string ru)
        {
            foreach (RuCharInfo rc in ruchars)
                if (rc.ru == ru)
                    return rc.en;
            return string.Empty;
        }

        public bool isTextRu(uint file,int block,int num,ref string comment)
        {
            foreach(TextInfo t in texts)
                if (t.block == block && t.fileId == file && t.N == num)
                {
                    comment = t.comment;
                    return t.ru;
                }
            comment = "";
            return false;
        }

        public void setCharInfo(string en,string ru,string comment)
        {
            XmlElement old=null;
            foreach(XmlElement e in rtroot)
                if (e.Attributes["en"].Value==""+en)
                    old=e;
            if (ru == string.Empty && old != null)
            {
                rtroot.RemoveChild(old);
                doc.Save(filename);
                reload();
                return;
            }
            XmlNode nd=doc.CreateElement("char");
            nd.Attributes.Append(doc.CreateAttribute("en")).Value=en;
            nd.Attributes.Append(doc.CreateAttribute("ru")).Value=ru;
            nd.Attributes.Append(doc.CreateAttribute("comment")).Value=comment;
            bool saved = true;
            if (old == null)
                rtroot.AppendChild(nd);
            else if (ru != old.Attributes["ru"].Value || comment != old.Attributes["comment"].Value)
                rtroot.ReplaceChild(nd, old);
            else saved = false;
            if (saved)
            {
                doc.Save(filename);
                reload();
            }
        }

        public void setTextInfo(uint file, uint block, uint num, bool ru, string comment)
        {
            XmlElement old = null;
            foreach (XmlElement e in trroot)
                if (e.Attributes["file"].Value == file.ToString() &&
                    e.Attributes["block"].Value == block.ToString() &&
                    e.Attributes["N"].Value == num.ToString())
                    old = e;
            XmlElement nd=doc.CreateElement("text");
            nd.Attributes.Append(doc.CreateAttribute("file")).Value = file.ToString();
            nd.Attributes.Append(doc.CreateAttribute("block")).Value = block.ToString();
            nd.Attributes.Append(doc.CreateAttribute("N")).Value = num.ToString();
            nd.Attributes.Append(doc.CreateAttribute("mode")).Value = ru ? "ru" : "en";
            nd.Attributes.Append(doc.CreateAttribute("comment")).Value = comment;
            bool saved = true;
            if (old == null)
                trroot.AppendChild(nd);
            else if (((old.Attributes["mode"].Value != "ru" && ru) ||
                (old.Attributes["mode"].Value == "ru" && !ru)) || old.Attributes["comment"].Value != comment)
                trroot.ReplaceChild(nd, old);
            else saved = false;
            if (saved)
            {
                doc.Save(filename);
                reload();
            }
        }

        public void saveEngTextFile()
        {
            if (File.Exists(engtxtfile))
                return;
            BinaryWriter br=new BinaryWriter(new FileStream(engtxtfile, FileMode.CreateNew));
            uint ofs = 0;
            for (int i = 0; i < 16; i++)
                br.Write(ofs);
            for (int i = 0; i < 8; i++)
            {
                byte[] data = SkyDisk.get().readFile(60600 + i);
                ofs = (uint)br.BaseStream.Position;
                uint sz = (uint)data.Length;
                br.BaseStream.Position = (i * 8);
                br.Write(ofs);
                br.Write(sz);
                br.BaseStream.Position = ofs;
                br.Write(data);
            }
            br.Close();
            reload();
        }

        public bool hasEngFile()
        {
            return File.Exists(engtxtfile);
        }

        public void readEngTxtData()
        {
            if (!hasEngFile()) return;
            if (engTxtData != null) engTxtData.Dispose();
            FileStream fs=new FileStream(engtxtfile,FileMode.Open);
            byte[] data=new byte[fs.Length];
            fs.Read(data,0,data.Length);
            fs.Close();
            engTxtData = new MemoryStream(data);
        }

        public byte[] getEngTextFile(uint fid)
        {
            if (!hasEngFile()) return null;
            uint id =(fid - 60600)% 8;
            BinaryReader rd=new BinaryReader(engTxtData);
            rd.BaseStream.Position = id * 8;
            uint ofs = rd.ReadUInt32();
            uint sz = rd.ReadUInt32(); ;
            byte[] res=new byte[sz];
            rd.BaseStream.Position = ofs;
            rd.BaseStream.Read(res, 0, (int)sz);
            return res;
        }

        public string engText(uint filenum, int block, int num)
        {
            uint id = (filenum - 60600) % 8;
            if (engtxt[id] == null)
                engtxt[id] = new BText(getEngTextFile(filenum));
            return engtxt[id].getText(block, num,false);
        }

        XmlElement findNode(XmlElement root, string nd, string attrs,string vls)
        {
            string[] atr = attrs.Split('|');
            string[] vl = vls.Split('|');
            foreach (XmlElement e in root)
                if (e.Name==nd)
                {
                    bool found = true;
                    for (int i = 0; i < atr.Length; i++)
                        if (e.Attributes[atr[i]]==null || e.Attributes[atr[i]].Value != vl[i])
                            found = false;
                    if (found)
                        return e;
                }
            return null;
        }
        
        void mergeNodes(XmlElement oldroot,XmlElement newroot,string nd,string idattr)
        {
            string[] atr = idattr.Split('|');
            foreach (XmlElement e in newroot)
                if (e.Name == nd)
                {
                    string vl = "";
                    for (int i=0;i<atr.Length;i++)
                    {
                        if (i != 0) vl += "|";
                        vl += e.Attributes[atr[i]].Value;
                    }
                    XmlElement e2 = findNode(oldroot, nd, idattr, vl);
                    if (e2 == null)
                        oldroot.AppendChild(doc.ImportNode(e,true));
                    else
                    {
                        bool same = true;
                        if (e2.Attributes.Count != e.Attributes.Count)
                            same = false;
                        else
                            for (int i = 0; i < e2.Attributes.Count;i++ )
                            {
                                string nm = e2.Attributes[i].Name;
                                if (e.Attributes[nm] == null || e.Attributes[nm].Value != e2.Attributes[nm].Value)
                                    same = false;
                            }
                        if (!same)
                        {
                            if (new MergeChanges(e2,e).ShowDialog() == DialogResult.OK)
                                oldroot.ReplaceChild(doc.ImportNode(e,true), e2);
                        }
                    }
                }
        }

        public void mergeConfig(string filen)
        {
            try{
            XmlDocument ndoc = new XmlDocument();
            ndoc.Load(filen);
            if (ndoc.DocumentElement.Name != "bassru")
                throw new ApplicationException("Bad Config root node");
            foreach (XmlElement nd in ndoc.DocumentElement.ChildNodes)
            {
                if (nd.Name == "files")
                    mergeNodes(fileroot, nd, "file", "id");
                if (nd.Name == "rutable")
                    mergeNodes(rtroot, nd, "char", "en");
                if (nd.Name == "textres")
                    mergeNodes(trroot, nd, "text", "file|block|N");
            }
            doc.Save(filename);
            reload();
            }catch(Exception ex)
            {
                MessageBox.Show("Error while merging:"+ex.Message);
            }
        }

    }
}
