using System;
using System.Collections.Generic;
using System.Text;
using System.Xml;

namespace br_not_parser
{
    class Translator
    {
        XmlDocument src;
        XmlDocument nb;
        public Translator(XmlDocument source,XmlDocument notab)
        {
            src = source;
            nb = notab;
        }

        XmlNode searchByEn(string en)
        {
            foreach(XmlNode n in src.DocumentElement.ChildNodes)
                if (n.Name=="file")
                    foreach(XmlNode b in n.ChildNodes)
                        if (b.Name=="block")
                            foreach(XmlNode t in b.ChildNodes)
                                if (t.Name == "text")
                                {
                                    if (en == t.ChildNodes[0].Value)
                                        return t;
                                }
            return null;
        }

        public void processLine(XmlNode l,string partnm)
        {
            string s = l.Attributes["en"].Value;
            XmlNode n = searchByEn(s);
            if (n == null)
                Console.WriteLine(string.Format("WARNING: not found in text {0:s}:{1:s} - {2:s}", partnm, l.Attributes["id"].Value, s));
            else
            {
                int maxRank = int.MinValue;
                XmlNode curt=null;
                foreach (XmlNode t in l.ChildNodes)
                    if (t.Name=="ru")
                {
                    int rank = int.Parse(t.Attributes["rank"].Value);
                    if (rank > maxRank)
                    {
                        rank = maxRank;
                        curt = t;
                    }
                }
                if (curt != null)
                    n.ChildNodes[0].Value = curt.ChildNodes[0].Value;
                else
                    Console.WriteLine(string.Format("WARNING: no translation for {0:s}:{1:s} - {2:s}", partnm, l.Attributes["id"].Value, s));
            }
        }

        public XmlDocument run()
        {
            foreach (XmlNode nd in nb.DocumentElement.ChildNodes)
                if (nd.Name == "part")
                    foreach (XmlNode l in nd.ChildNodes)
                        if (l.Name == "line")
                            processLine(l,nd.Attributes["name"].Value);
            return src;
        }
    }
}
