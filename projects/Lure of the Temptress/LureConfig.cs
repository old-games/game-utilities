using System.Collections.Generic;
using System.IO;
using System.Windows.Forms;
using System.Xml;
using System;
using System.Drawing;

namespace Vlure
{
    public class LureConfig
    {
        public class LureFile
        {
            public int id;
            public string type;
            public XmlNode node;
            public LureFile(XmlNode nd)
            {
                id = LureCommon.strToInt(nd.Attributes["id"].Value);
                type = nd.Attributes["type"].Value;
                node = nd;
            }
            public byte[] data { get { return LureDisks.getResource(id); } }
        }

        public class LurePalette
        {
            public Color[] cols=new Color[256];
            public string name;
            public LureFile file;
            public int palette_id;
            public LurePalette(LureFile f,int id)
            {
                if (f == null)
                {
                    name = "GRAYSCALE";
                    for (int i = 0; i < 256; i++)
                        cols[i] = Color.FromArgb(i, i, i);
                    file = null;
                }
                else
                {
                    palette_id = id;
                    file = f;
                    name=f.node.Attributes["name"].Value+(id==0?"":"["+id.ToString()+"]");
                    int ncol = (f.data.Length / 3);
                    int psize=64*3;
                    if (id != 0)
                    {
                        id -= 1;
                        ncol = 64;
                    }
                    for (int i = 0; i < 256; i++)
                    {
                        if (i >= ncol)
                            cols[i] = Color.Black;
                        else
                        {
                            byte r = f.data[i * 3+id*psize];
                            byte g = f.data[i * 3 + 1 + id * psize];
                            byte b = f.data[i * 3 + 2 + id * psize];
                            r = (byte)((r << 2) + (r >> 4));
                            g = (byte)((g << 2) + (g >> 4));
                            b = (byte)((b << 2) + (b >> 4));
                            cols[i] = Color.FromArgb(r, g, b);
                        }
                    }
                }
            }
        }

        static LureConfig obj = null;
        public static LureConfig get()
        {
            if (obj == null)
            {
                obj = new LureConfig();
                foreach (LureFile f in obj.files)
                    if (f.type == "palette")
                        obj.palettes.Add(new LurePalette(f,0));
                    else if (f.type == "palettes")
                    {
                        int palscnt = f.data.Length / (64 * 3);
                        for (int i = 0; i < palscnt; i++)
                            obj.palettes.Add(new LurePalette(f, i + 1));
                    }
            }
            return obj;
        }

        string cpath;
        public int decode_tbl;
        public int names;
        string lpath;
        List<LureFile> files = new List<LureFile>();
        public List<LurePalette> palettes = new List<LurePalette>();
        XmlDocument conf = new XmlDocument();
        public string curPath { get { return cpath; } }
        public string path { get { return lpath; } }

        public bool help = false;
        public string outfile = "";
        public string infile = "";
        public string dir = "";
        public int textfmt = 0;
        public int lang_id = 3;
        XmlNode txtConf = null;
        XmlNode fileConf = null;
        public LureConfig()
        {
            cpath = Path.GetDirectoryName(Application.ExecutablePath);
            conf.Load(cpath+"\\vlure.xml");
            palettes.Add(new LurePalette(null,0));
            foreach (XmlNode nd in conf.DocumentElement.ChildNodes)
                if (nd.NodeType==XmlNodeType.Element)
                {
                    if (nd.Name=="path")
                        lpath=nd.ChildNodes[0].Value;
                    if (nd.Name == "files")
                    {
                        fileConf=nd;
                        foreach (XmlNode nn in nd.ChildNodes)
                            if (nn.NodeType == XmlNodeType.Element && nn.Name == "file")
                            {
                                LureFile lf = new LureFile(nn);
                                files.Add(lf);
                                if (lf.type == "text_decode_table")
                                    decode_tbl = lf.id;
                                if (lf.type == "names")
                                    names = lf.id;
                            }
                    }
                    if (nd.Name == "ruchars")
                        txtConf = nd;
                }
        }
        public string[] setParams(string[] argv)
        {
            int carg = 0;
            List<string> res = new List<string>();
            while (carg < argv.Length)
            {
                string x = argv[carg];
                carg++;
                if (x[0] == '-' || x[0] == '/')
                {
                    string x2 = argv[carg];
                    carg++;
                    switch (x[1])
                    {
                        case 'p':
                            lpath += ";" + x2;
                            break;
                        case 'P':
                            lpath = x2;
                            break;
                        case 'l':
                            lang_id = int.Parse(x2);
                            break;
                        case 'h':
                            help = true;
                            break;
                        case 'o':
                            outfile = x2;
                            break;
                        case 'i':
                            infile = x2;
                            break;
                        case 'd':
                            dir = x2;
                            break;
                        case 'f':
                            if (x2 == "txt")
                                textfmt = 1;
                            else if (x2 == "xml")
                                textfmt = 0;
                            else throw new Exception("unknown text format "+x2);
                            break;
                        default:
                            throw new Exception("Unknown param "+x);
                    }
                }
                else
                    res.Add(x);
            }
            return res.ToArray();
        }

        public int decodeTableId { get { return decode_tbl; } }
        public int namesId { get { return names; } }
        public List<LureFile> lureFiles { get { return files; } }
        public byte[] DecodeTable { get { return LureDisks.getResource(decode_tbl); } }
        public byte[] Names { get { return LureDisks.getResource(names); } }
        public LureFile findFile(int id)
        {
            foreach (LureFile f in files)
                if (f.id == id)
                    return f;
            return null;
        }
        public string outputFile(string def)
        {
            if (outfile == "")
                return def;
            return outfile;
        }
        public string inputFile(string def)
        {
            if (infile == "")
                return def;
            return infile;
        }
        public string direcroty(string def)
        {
            if (dir== "")
                return def;
            return dir;
        }

        public string convert(string str)
        {
            if (txtConf==null)
                throw new Exception("no ruchars config");
            string res = "";
            for (int i = 0; i < str.Length; i++)
            {
                XmlNode found = null;
                string s = ""+str[i];
                if (s=="\\")
                {
                    s+=str[i+1];
                    if (s=="\\x")
                        s+=""+str[i+2]+""+str[i+3];
                    i+=s.Length-1;
                }
                foreach(XmlNode n in txtConf.ChildNodes)
                    if (found==null)
                    if (n.NodeType == XmlNodeType.Element && n.Name == "char")
                    {
                        if ( ""+str[i] == n.Attributes["ru"].Value)
                            found = n;
                    }
                if (found == null)
                {
                    char c=TextDecoder.replaceString(s);
                    if (c < ' ' || c > (char)0xA0)
                        throw new Exception("character not found " + c);
                    res += c;
                }
                else
                    res += TextDecoder.replaceString(found.Attributes["en"].Value);
            }
            return res;
        }

        public LurePalette getPalette(string name)
        {
            for (int i=0; i < palettes.Count; i++)
                if (palettes[i].name == name)
                    return palettes[i];
            return palettes[0];
        }

        public void saveImage(int fileid, int w, int h, string pal,string name)
        {
            foreach (XmlNode nd in fileConf.ChildNodes)
            {
                if (nd.NodeType == XmlNodeType.Element && nd.Name == "file")
                    if (nd.Attributes["type"].Value == "image" && LureCommon.strToInt(nd.Attributes["id"].Value) == fileid)
                        nd.ParentNode.RemoveChild(nd);
            }
            XmlNode fl=fileConf.AppendChild(conf.CreateElement("file"));
            fl.Attributes.Append(conf.CreateAttribute("id")).Value = fileid.ToString();
            fl.Attributes.Append(conf.CreateAttribute("type")).Value = "image";
            fl.Attributes.Append(conf.CreateAttribute("width")).Value = w.ToString();
            fl.Attributes.Append(conf.CreateAttribute("height")).Value = h.ToString();
            fl.Attributes.Append(conf.CreateAttribute("palette")).Value = pal;
            if (name!="image"+fileid.ToString())
                fl.Attributes.Append(conf.CreateAttribute("name")).Value = name;
            conf.Save(cpath + "\\vlure.xml");
        }
    }
}
