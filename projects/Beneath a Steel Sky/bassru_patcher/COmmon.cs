using System;
using System.IO;
using System.Xml;

namespace bassru_patcher
{
    class Common
    {
        const string brconf = "bassru.xml";
        public static XmlNode findFile(int id,XmlDocument bc)
        {
            foreach(XmlNode n in bc.DocumentElement.ChildNodes)
                if (n.NodeType==XmlNodeType.Element && n.Name=="files")
                    foreach(XmlNode f in n.ChildNodes)
                        if (f.NodeType==XmlNodeType.Element && f.Name=="file")
                        {
                            if (int.Parse(f.Attributes["id"].Value)==id)
                                return f;
                        }
            throw new Exception("File "+id.ToString()+" not found in "+brconf);
        }

        public static void appendConvTable(XmlElement to, XmlDocument from)
        {
            foreach(XmlNode b in from.DocumentElement.ChildNodes)
                if (b.NodeType==XmlNodeType.Element && b.Name=="rutable")
                    foreach (XmlNode nd in b.ChildNodes)
                        if (nd.NodeType==XmlNodeType.Element && nd.Name=="char")
                        {
                            XmlElement e = (XmlElement)to.AppendChild(to.OwnerDocument.CreateElement("i"));
                            e.Attributes.Append(to.OwnerDocument.CreateAttribute("e")).Value = nd.Attributes["en"].Value;
                            e.Attributes.Append(to.OwnerDocument.CreateAttribute("r")).Value = nd.Attributes["ru"].Value;
                        }
        }

        public static int appendResource(string name, XmlElement rr)
        {
            int maxr = 0;
            foreach (XmlElement e in rr.ChildNodes)
            {
                int cid = int.Parse(e.Attributes["r"].Value);
                if (cid > maxr)
                    maxr = cid;
                if (e.Attributes["name"].Value == name)
                    return cid;
            }
            maxr++;
            XmlElement r = rr.OwnerDocument.CreateElement("i");
            rr.AppendChild(r);
            r.Attributes.Append(rr.OwnerDocument.CreateAttribute("name")).Value=name;
            r.Attributes.Append(rr.OwnerDocument.CreateAttribute("r")).Value = maxr.ToString();
            return maxr;
        }

        public static XmlDocument getPatchXml(string configFile)
        {
            XmlDocument conf=new XmlDocument();
            conf.Load(configFile);
            if (conf.DocumentElement.Name != "bassru-patch")
                throw new Exception("bad patch config xml");
            XmlDocument bconf = new XmlDocument();
            if (!File.Exists(brconf))
                throw new Exception("File not found "+brconf);
            bconf.Load(brconf);
            XmlDocument doc = new XmlDocument();
            doc.LoadXml("<?xml version=\"1.0\" encoding=\"utf-8\"?><p/>");
            XmlElement fls=doc.CreateElement("f");
            XmlElement rs=doc.CreateElement("r");
            XmlElement ch = doc.CreateElement("c");
            doc.DocumentElement.AppendChild(fls);
            doc.DocumentElement.AppendChild(rs);
            doc.DocumentElement.AppendChild(ch);
            foreach (XmlNode nd in conf.DocumentElement.ChildNodes)
                if (nd.NodeType==XmlNodeType.Element && nd.Name=="import")
                {
                    XmlElement nf = doc.CreateElement("i");
                    fls.AppendChild(nf);
                    int rid = appendResource(nd.Attributes["file"].Value,rs);
                    int fid = int.Parse(nd.Attributes["id"].Value);
                    XmlNode d = findFile(fid, bconf);
                    nf.Attributes.Append(doc.CreateAttribute("r")).Value = rid.ToString();
                    nf.Attributes.Append(doc.CreateAttribute("f")).Value = fid.ToString();
                    string tp=d.Attributes["type"].Value;
                    nf.Attributes.Append(doc.CreateAttribute("t")).Value = tp;
                    if (tp == "image")
                    {
                        nf.Attributes.Append(doc.CreateAttribute("w")).Value=d.Attributes["width"].Value;
                        nf.Attributes.Append(doc.CreateAttribute("h")).Value = d.Attributes["height"].Value;
                        if (d.Attributes["imgmode"] != null) 
                            nf.Attributes.Append(doc.CreateAttribute("m")).Value = d.Attributes["imgmode"].Value;
                    }
                    if (tp == "charset")
                    {
                        nf.Attributes.Append(doc.CreateAttribute("h")).Value = d.Attributes["height"].Value;
                        if (d.Attributes["spacing"]!=null)
                            nf.Attributes.Append(doc.CreateAttribute("s")).Value = d.Attributes["spacing"].Value;
                    }
                    if (tp == "sequence")
                    {
                        string clname = (d.Attributes["bg"] == null) ? "aqua" : d.Attributes["bg"].Value;
                        nf.Attributes.Append(doc.CreateAttribute("b")).Value = clname;
                    }
                }
            appendConvTable(ch, bconf);
            return doc;
        }

        public static byte[] getPatchData(XmlDocument patchXml)
        {
            MemoryStream ms = new MemoryStream();
            foreach(XmlElement e in patchXml.DocumentElement.ChildNodes)
                if (e.Name=="r")
                    foreach (XmlElement r in e.ChildNodes)
                    {
                        string fl = r.Attributes["name"].Value;
                        int o = 0;
                        int s = 0;
                        BinaryReader rd = new BinaryReader(new FileStream(fl, FileMode.Open));
                        s = (int)rd.BaseStream.Length;
                        ms.Capacity += s;
                        o = (int)ms.Position;
                        byte[] buf = rd.ReadBytes(s);
                        rd.Close();
                        ms.Write(buf, 0, s);
                        r.Attributes.Remove(r.Attributes["name"]);
                        r.Attributes.Append(r.OwnerDocument.CreateAttribute("o")).Value = o.ToString();
                        r.Attributes.Append(r.OwnerDocument.CreateAttribute("s")).Value = s.ToString();
                    }
            byte[] data=new byte[ms.Length];
            ms.Position=0;
            ms.Read(data, 0, (int)ms.Length);
            ms.Close();
            return data;
        }
    }
}
