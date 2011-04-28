using System;
using System.Collections.Generic;
using System.Text;
using System.Text.RegularExpressions;
using System.IO;

namespace engine.net
{
    class ApiPart
    {
        public class ErrException:Exception
        {
            public int code;
            public string descr;
            public ErrException(int code, string descr)
                : base(String.Format("{{r:{0:d}, d:\"{1:s}\" }}", code, descr))
            {
                this.code=code;
                this.descr=descr;
            }
        }
        public class BadApiException:ErrException
        {
            public BadApiException(string path):base(-1,"Bad API call "+path){}
        }
        public class NoParamException:ErrException
        {
            public NoParamException(string param):base(-2,"expected parameter "+param){}
        }

        public class Parameters:Dictionary<string,string>{}
        public class Paths : List<string> { }

        public delegate string doproc(Paths path,Parameters prms);

        Dictionary<string, doproc> wrappers = new Dictionary<string, doproc>();

        public ApiPart()
        {
        }

        public void addWrapper(string cmd,doproc p)
        {
            wrappers.Add(cmd, p);
        }

        public virtual string proc(Paths path, Parameters prms)
        {
            try{
                if (path.Count==0)
                    throw new BadApiException("empty_path");
                if (wrappers.ContainsKey(path[0]))
                {
                    string x=path[0];
                    path.RemoveAt(0);
                    return wrappers[x](path, prms);
                }
                else
                    throw new BadApiException(path[0]);
            }catch(ErrException ex)
            {
                Logger.getLogger().dbg("API ERROR:"+ex.code.ToString()+":"+ex.descr);
                return ex.Message;
            }catch(Exception ex)
            {
                Logger.getLogger().dbg("external ERROR:"+ex.Message);
                return "{r:-1, d:\"external exception " + ex.Message + "\"}";
            }
        }

        public bool hasParam(Parameters prms,string name)
        {
            return (prms.ContainsKey(name));
        }
        public string getParam(Parameters prms, string name)
        {
            if (!hasParam(prms, name))
                throw new NoParamException(name);
            return prms[name];
        }
        public string retOK()
        {
            return "{r:0}";
        }
        public string retOK(string[] prms)
        {
            string s = "r:0";
            for (int i = 0; i < prms.Length / 2; i++)
                s += ", " + prms[i * 2] + ":"+prms[i*2+1]+"";
            return "{"+s+"}";
        }
        public string retOK(string result)
        {
            return retOK(new string[] { "result", "\""+result+"\"" });
        }
        public string retOK(bool result)
        {
            return retOK(new string[] { "result", result?"true":"false" });
        }
        public string retOK(int result)
        {
            return retOK(new string[] { "result", result.ToString()});
        }
        public string escape(string s)
        {
            s=s.Replace("|", "||").Replace("\"", "|!");
            s=s.Replace("\n", "|n").Replace("\r", "|r").Replace("\t","|t");
            return s;
        }
    }

    class InstApi:ApiPart
    {

        public static InstApi obj = null;
        public static InstApi getApi()
        {
            if (obj == null)
                obj = new InstApi();
            return obj;
        }

        public InstApi()
        {
            addWrapper("log", this.log);
            addWrapper("close", this.close);
            addWrapper("cantstop", this.cantstop);
            addWrapper("canstop", this.canstop);
            addWrapper("system", SystemApi.API.proc);
        }

        public static string urldecode(string s)
        {
            byte[] data = Encoding.Convert(Encoding.Unicode, Encoding.UTF8, Encoding.Unicode.GetBytes(s));
            List<byte> res=new List<byte>();
            int i = 0;
            while (i < data.Length)
            {
                if (data[i] == 0x25)
                {
                    char h1 = (char)data[i + 1];
                    char h2 = (char)data[i + 2];
                    i += 2;
                    res.Add(byte.Parse(""+h1+h2,System.Globalization.NumberStyles.AllowHexSpecifier));
                }
                else
                    res.Add(data[i]);
                i++;
            }
            return new String(Encoding.Unicode.GetChars(Encoding.Convert(Encoding.UTF8,Encoding.Unicode,res.ToArray())));
        }

        public byte[] process(string loc)
        {
            Parameters prms = new Parameters();
            Paths path = new Paths();
            Logger.getLogger().dbg("API call "+loc);
            if (loc.Contains("?"))
            {
                string[] prt = loc.Split(new char[]{'?'},2);
                foreach (string s in prt[0].Split('/'))
                    path.Add(s);
                prt = prt[1].Split('&');
                foreach (string s in prt)
                {
                    string[] p = s.Split(new char[]{'='},2);
                    prms.Add(urldecode(p[0]), urldecode(p[1]));
                }
            }else
                 foreach (string s in loc.Split('/'))
                    path.Add(s);
            return Encoding.Convert(Encoding.Unicode,Encoding.UTF8,Encoding.Unicode.GetBytes(proc(path,prms)));
        }

        string log(Paths cmd,Parameters prms)
        {
            string s=getParam(prms,"s");
            Logger.getLogger().print(s);
            return retOK();
        }
        string close(Paths cmd, Parameters prms)
        {
            if (BrowserController.obj != null)
                BrowserController.obj.stopBrowser();
            if (Form1.obj != null)
                Form1.obj.stopBrowser();
            return retOK();
        }
        string cantstop(Paths cmd, Parameters prms)
        {
            Server.getServer().current_page = getParam(prms, "pg");
            Server.getServer().canstop = false;
            return retOK();
        }
        string canstop(Paths cmd, Parameters prms)
        {
            Server.getServer().canstop = true;
            return retOK();
        }

    }

    class SystemApi : ApiPart
    {
        public static SystemApi obj = null;
        public static SystemApi API { get { if (obj == null) obj = new SystemApi(); return obj; } }
        public SystemApi()
        {
            addWrapper("userdir", this.userdir);
            addWrapper("hasfile", this.fileexists);
            addWrapper("matchfile", this.matchfile);
            addWrapper("getfile", this.getfile);
        }
        public string userdir(Paths pth, Parameters prms)
        {
            string p = Path.GetDirectoryName(Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments));
            return retOK(p);
        }
        public string fileexists(Paths pth, Parameters prms)
        {
            string fl=getParam(prms, "fl");
            return retOK(File.Exists(fl));
        }
        public string matchfile(Paths pth, Parameters prms)
        {
            string fl = getParam(prms, "fl");
            string rx = getParam(prms, "rx");
            if (!File.Exists(fl))
                throw new ErrException(1, "file not found "+fl);
            StreamReader sr = new StreamReader(new FileStream(fl,FileMode.Open),true);
            string s = sr.ReadToEnd();
            sr.Close();
            List<string> r=new List<string>();
            string res = "[";
            foreach (Match m in Regex.Matches(s, rx))
                res+=m.Value+",";
            if (res[res.Length - 1] == ',')
                res=res.Remove(res.Length - 1);
            res += "]";
            return retOK(res);
        }
        public string getfile(Paths pth, Parameters prms)
        {
            string fl = getParam(prms, "fl");
            if (!File.Exists(fl))
                throw new ErrException(1, "file not found " + fl);
            StreamReader sr = new StreamReader(new FileStream(fl, FileMode.Open), true);
            string s = sr.ReadToEnd();
            sr.Close();
            return retOK(escape(s));
        }
    }

}
