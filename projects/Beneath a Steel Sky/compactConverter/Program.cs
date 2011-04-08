using System.Xml;
using System.IO;

namespace compactConverter
{
    class Program
    {
        static string getend(string s)
        {
            string[] vls = s.Split(':');
            return vls[vls.Length - 1];
        }

        static void addColor(string col, XmlElement pal)
        {
            while (col.Length >= 6)
            {
                int x = int.Parse(col.Substring(0, 6), System.Globalization.NumberStyles.AllowHexSpecifier);
                byte r = (byte)((x >> 16) & 0xFF);
                byte g = (byte)((x >> 8) & 0xFF);
                byte b = (byte)(x & 0xFF);
                XmlElement c = (XmlElement)pal.AppendChild(pal.OwnerDocument.CreateElement("c"));
                r = (byte)((r << 2) + (r >> 4)); 
                g = (byte)((g << 2) + (g >> 4)); 
                b = (byte)((b << 2) + (b >> 4));
                c.Attributes.Append(c.OwnerDocument.CreateAttribute("r")).Value=r.ToString();
                c.Attributes.Append(c.OwnerDocument.CreateAttribute("g")).Value = g.ToString();
                c.Attributes.Append(c.OwnerDocument.CreateAttribute("b")).Value = b.ToString();
                col = col.Substring(6);
            }
        }

        static void Main(string[] args)
        {
            XmlDocument doc = new XmlDocument();
            doc.LoadXml("<?xml version=\"1.0\" encoding=\"utf-8\"?><skycpt/>");
            XmlElement pal = (XmlElement)doc.DocumentElement.AppendChild(doc.CreateElement("palettes"));
            StreamReader rd = new StreamReader(new FileStream("COMPACT.TXT", FileMode.Open));
            while (!rd.EndOfStream)
            {
                string s = rd.ReadLine();
                while (s[0] == '\t' || s[0] == ' ') s = s.Remove(0, 1);
                if ((s.EndsWith("_pal")||s.EndsWith("_palette")) && s.Substring(0,7)=="MISCBIN")
                {
                    XmlElement p = (XmlElement)pal.AppendChild(doc.CreateElement("pal"));
                    string nm = getend(s);
                    p.Attributes.Append(doc.CreateAttribute("name")).Value=nm;
                    s=rd.ReadLine();
                    string ps = "";
                    do
                    {
                        while (s[0] == ' ' || s[0] == '\t')
                            s = s.Remove(0, 1);
                        ps += s.Substring(2,2)+s.Substring(0, 2);
                        if (ps.Length == 12)
                        {
                            addColor(ps, p);
                            ps = "";
                        }
                        s = rd.ReadLine();
                    } while (getend(s) != "ENDS");
                    if (ps.Length > 0)
                        addColor(ps, p);
                }
            }
            rd.Close();
            doc.Save("skycpt.xml");
        }
    }
}
