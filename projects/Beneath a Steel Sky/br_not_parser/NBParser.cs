using System;
using System.IO;
using System.Net;
using System.Text;
using System.Xml;

namespace br_not_parser
{
    class NBParser
    {
        string user = "";
        string pswd="";
        string xfile = "eng.xml";
        string outfile = "ru.xml";
        string adr = "http://notabenoid.com/book/10919/";
        string notafile = "";
        public NBParser(string[] args,int mode)
        {
            int argid = 3;
            if (mode == 0)
            {
                xfile = args[1];
                if (!File.Exists(xfile))
                    throw new Exception("File not found " + xfile);
                adr = args[2];
                if (adr == "-f")
                {
                    notafile = args[3];
                    argid = 4;
                }
            }
            else
            {
                outfile = "notabenoid.xml";
                adr = args[1];
                argid = 2;
            }
            if (adr[adr.Length - 1] != '/')
                adr += "/";
            while (argid < args.Length)
            {
                string x = args[argid];
                argid++;
                if (x[0] != '-')
                    throw new Exception("unknown param "+x);
                string x1 = args[argid];
                argid++;
                if (x[1] == 'o')
                    outfile = x1;
                else if (x[1] == 'u')
                    user = x1;
                else if (x[1] == 'p')
                    pswd = x1;
                else
                    throw new Exception("unknown param " + x);
            }
            if (notafile != "" && !File.Exists(notafile))
                throw new Exception("File not found "+notafile);
            if (pswd != "" && user == "")
                throw new Exception("no user");
        }

        public XmlDocument getInFile()
        {
            XmlDocument doc = new XmlDocument();
            doc.Load(xfile);
            return doc;
        }

        public string getOutName()
        {
            return outfile;
        }

        private CookieContainer cooks = new CookieContainer();
        bool login()
        {
            Console.WriteLine("login");
            while(true)
            {
            if (user == "")
            {
                Console.Write("username:");
                user = Console.ReadLine();
            }
            if (pswd == "")
            {
                Console.Write("password:");
                pswd = Console.ReadLine();
            }
            HttpWebRequest rq = (HttpWebRequest)WebRequest.Create("http://notabenoid.com/register/login/");
            rq.AllowAutoRedirect = true;
            rq.CookieContainer=cooks;
            rq.KeepAlive = true;
            rq.Method = "POST";
            rq.ContentType = "application/x-www-form-urlencoded";
            byte[] data = Encoding.UTF8.GetBytes("login="+user+"&pass="+pswd+"&submit=+войти+&remember=checked");
            rq.ContentLength = data.Length;
            Stream rs = rq.GetRequestStream();
            rs.Write(data, 0, data.Length);
            rs.Close();
            HttpWebResponse r = (HttpWebResponse)rq.GetResponse();
            StreamReader sr = new StreamReader(r.GetResponseStream());
            string res = sr.ReadToEnd();
            if (res.Contains("Неверный логин или пароль."))
            {
                Console.Write("Auth error. Again?[Y/N]:");
                char c=Console.ReadKey(false).KeyChar;
                Console.WriteLine();
                if (c == 'n' || c == 'N')
                    return false;
                user = "";
                pswd = "";
            }else
                return true;
            }
        }

        String getPage(string adr)
        {
            while(true)
            try
            {
                HttpWebRequest rq = (HttpWebRequest)WebRequest.Create(adr);
                rq.AllowAutoRedirect = true;
                CookieCollection cc=new CookieCollection();
                cc.Add(cooks.GetCookies(new Uri("http://some.notabenoid.com/")));
                foreach (Cookie c in cc)
                    if (c.Domain[0] == '.')
                        c.Domain=c.Domain.Remove(0, 1);
                cooks.Add(cc);
                rq.CookieContainer = cooks;
                String res = "";
                HttpWebResponse r = (HttpWebResponse)rq.GetResponse();
                StreamReader rd = new StreamReader(r.GetResponseStream());
                res = rd.ReadToEnd();
                //Console.WriteLine(res);
                return res;
            }catch(WebException ex)
            {
                if (ex.Message.Contains("(403)"))
                {
                    if (!login())
                        throw;
                }
                else
                {
                    throw;
                }
            }
        }

        XmlDocument newXmlDoc(string rootNode)
        {
            XmlDocument doc = new XmlDocument();
            doc.LoadXml("<?xml version=\"1.0\" encoding=\"utf-8\"?><"+rootNode+"/>");
            return doc;
        }

        void procMain(XmlDocument doc, String s)
        {
            int strt = s.IndexOf("<table id='ChapList'");
            int e = s.IndexOf("</table>", strt);
            s=s.Substring(strt,e+8-strt);
            int pos=0;
            const string src="<tr id='r";
            strt = s.IndexOf(src);
            while (strt > -1)
            {
                pos = strt;
                e = s.IndexOf("<a href=",pos);
                strt=s.IndexOf(">",e);
                string adr = s.Substring(e + 9, strt-e-10);
                e = s.IndexOf("<",strt);
                pos = e;
                string name = s.Substring(strt+1,e-strt-1);
                XmlElement prt = (XmlElement)doc.DocumentElement.AppendChild(doc.CreateElement("part"));
                prt.Attributes.Append(doc.CreateAttribute("name")).Value = name;
                prt.Attributes.Append(doc.CreateAttribute("address")).Value = adr;
                strt = s.IndexOf(src, pos);
            }
        }

        string procEn(string en)
        {
            int p = en.IndexOf(':');
            if (p == -1)
                return en;
            bool match=true;
            for (int i = 0; i < p; i++)
                if (en[i] == ' ')
                    match = false;
            if (!match)
                return en;
            en=en.Remove(0, p+1);
            while (en[0] == ' ' || en[0] == '\t')
                en=en.Remove(0, 1);
            return en;
        }

        void procPart(XmlNode nd, String s)
        {
            int st = s.IndexOf("<table id='Translator'");
            const string sv="<tr id='v";
            int v = s.IndexOf(sv,st);
            while (v > -1)
            {
                int ev = s.IndexOf("'>", v);
                string id = s.Substring(v + 9, ev - v - 8);
                int o = s.IndexOf("<td class='o'>",v);
                int eo = s.IndexOf("</td>",o);
                string en = s.Substring(o+14,eo-o-14);
                en = procEn(en);
                o = s.IndexOf("<td class='t'>", eo);
                o = s.IndexOf("<table>", o);
                eo = s.IndexOf("</table>", eo);
                st = eo;
                string p = s.Substring(o, eo - o);
                //Console.WriteLine("found "+id+"-"+en);
                XmlElement trans = nd.OwnerDocument.CreateElement("line");
                nd.AppendChild(trans);
                trans.Attributes.Append(nd.OwnerDocument.CreateAttribute("id")).Value = id;
                trans.Attributes.Append(nd.OwnerDocument.CreateAttribute("en")).Value = en;
                int tpos = 0;
                int ts = p.IndexOf("<tr>");
                while (ts > -1)
                {
                    tpos = p.IndexOf("</tr>", ts);
                    int rpos = p.IndexOf("<span>", ts);
                    int spos = p.IndexOf("</span>", rpos);
                    en = p.Substring(rpos + 6, spos - rpos - 6);
                    rpos = p.IndexOf("<em id=",spos);
                    rpos = p.IndexOf(">", rpos);
                    spos = p.IndexOf("</em>",rpos);
                    id = p.Substring(rpos+1,spos-rpos-1);
                    //Console.WriteLine("RU:"+en+" - "+id);
                    XmlElement tru = trans.OwnerDocument.CreateElement("ru");
                    trans.AppendChild(tru);
                    tru.Attributes.Append(trans.OwnerDocument.CreateAttribute("rank")).Value = id;
                    tru.AppendChild(tru.OwnerDocument.CreateTextNode(en));
                    ts = p.IndexOf("<tr>", tpos);
                }
                v = s.IndexOf(sv, st);
            }
        }

        string getFile(string fn)
        {
            StreamReader sr = new StreamReader(new FileStream(fn, FileMode.Open));
            string r = sr.ReadToEnd();
            sr.Close();
            return r;
        }
        void setFile(string fn,string data)
        {
            StreamWriter sw = new StreamWriter(new FileStream(fn, FileMode.Create));
            sw.Write(data);
            sw.Close();
        }


        XmlDocument dumpNotabenoid()
        {
            String s = getPage(adr);
            //String s = getFile("main2.html");
            XmlDocument doc = newXmlDoc("notabenoid");
            procMain(doc, s);
            foreach (XmlNode nd in doc.DocumentElement)
            {
                string ad="http://notabenoid.com"+nd.Attributes["address"].Value;
                Console.Write("download "+nd.Attributes["name"].Value+" from "+ad);
                s = getPage(ad);
                //s = getFile(nd.Attributes["name"].Value + ".html");
                int pgs = 1;
                while (s.IndexOf(string.Format("<a href='?page={0:d}'>{1:d}</a>", pgs,pgs+1))>-1)
                    pgs++;
                int cp = 0;
                do
                {
                  procPart(nd, s);
                  cp++;
                  if (cp<pgs)
                  {
                      Console.Write(" "+(cp+1).ToString());
                      s = getPage(ad + "?page=" + cp.ToString());
                      //s = getFile(nd.Attributes["name"].Value + "p" + cp.ToString() + ".html");
                  }
                } while (cp<pgs);
                Console.WriteLine();
            }
            return doc;
        }

        public XmlDocument run()
        {
            XmlDocument doc;
            if (notafile != "")
            {
                doc = new XmlDocument();
                doc.Load(notafile);
                return doc;
            }
            doc = dumpNotabenoid();
            return doc;
        }

        public void dump()
        {
            dumpNotabenoid().Save(outfile);
        }
    }
}
