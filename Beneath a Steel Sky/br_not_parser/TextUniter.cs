using System;
using System.Collections.Generic;
using System.IO;
using System.Xml;

namespace br_not_parser
{
    class TextUniter
    {
        string outfile = "eng.txt";
        List<string> infiles = new List<string>();
        List<int> inids = new List<int>();
        public TextUniter(string[] args)
        {
            int argid = 2;
            outfile = args[1];
            while (argid < args.Length)
            {
                string f=args[argid];
                int fid=int.Parse(args[argid+1]);
                if (!File.Exists(f))
                    throw new Exception("File not found "+f);
                argid+=2;
                infiles.Add(f);
                inids.Add(fid);
            }
            if (infiles.Count != inids.Count)
                throw new Exception("Wrong name id pairs");
            if (infiles.Count == 0)
                throw new Exception("No input files");
        }

        private void append(XmlDocument doc,string filename,int fid)
        {
            XmlElement fnode = doc.CreateElement("file");
            fnode.Attributes.Append(doc.CreateAttribute("id")).Value = fid.ToString();
            XmlDocument src = new XmlDocument();
            src.Load(filename);
            Console.WriteLine("adding " + filename);
            if (src.DocumentElement.Name != "bassru-text")
                throw new Exception("Bad file type " + filename);
            foreach (XmlNode nd in src.DocumentElement)
                if (nd.NodeType == XmlNodeType.Element)
                    fnode.AppendChild(doc.ImportNode(nd, true));
            XmlNode repl = null;
            foreach (XmlNode nd in doc.DocumentElement.ChildNodes) 
                if (nd.NodeType==XmlNodeType.Element)
                {
                if (nd.Name == "file" && nd.Attributes["id"].Value == fid.ToString())
                    repl = nd;
                }
            if (repl == null)
                doc.DocumentElement.AppendChild(fnode);
            else
                doc.DocumentElement.ReplaceChild(fnode, repl);
        }

        public void run()
        {
            XmlDocument doc=new XmlDocument();
            if (!File.Exists(outfile))
                doc.LoadXml("<?xml version=\"1.0\" encoding=\"utf-8\"?><bassru-text-all/>");
            else
                doc.Load(outfile);
            for (int i = 0; i < infiles.Count; i++)
                append(doc, infiles[i], inids[i]);
            doc.Save(outfile);
        }
    }
}
