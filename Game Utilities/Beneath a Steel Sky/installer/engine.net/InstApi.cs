using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using System.Text.RegularExpressions;

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
            public NoParamException(string param):base(2,"expected parameter "+param){}
        }
        public class BadParamException : ErrException
        {
            public BadParamException(string param,string value) : base(3, "Bad parameter " + param+" value:"+value) { }
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
        public string getParamFile(Parameters prms, string name)
        {
            string fl = getParam(prms, name);
            if (!File.Exists(fl))
                throw new ErrException(1, "file not found " + fl);
            return fl;
        }
        public Int64 getParamInt(Parameters prms, string name)
        {
            string s = getParam(prms,name);
            Int64 i=0;
            try
            {
                i=Int64.Parse(s);
            }
            catch (Exception)
            {
                throw new BadParamException(name, s);
            }
            return i;
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
        public string byte2str(byte[] data)
        {
            string res = "";
            foreach (byte b in data)
            {
                res += b.ToString("X2");
            }
            return res;
        }
        public byte[] str2byte(string str)
        {
            if (str.Length % 2 != 0)
                throw new BadParamException("bytes", str);
            List<byte> bts = new List<byte>();
            for (int i = 0; i < str.Length / 2; i++)
            {
                try
                {
                    byte b = byte.Parse("" + str[i * 2] + str[i * 2 + 1], System.Globalization.NumberStyles.AllowHexSpecifier);
                    bts.Add(b);
                }
                catch (Exception)
                {
                    throw new BadParamException("bytes",str);
                }
            }
            return bts.ToArray();
        }
        public void rotateBytes(ref byte[] data)
        {
            for (int i = 0; i < data.Length/2; i++)
            {
                int j = data.Length - i - 1;
                data[i] ^= data[j];
                data[j] ^= data[i];
                data[i] ^= data[j];
            }
        }
    }

    class InstApi:ApiPart
    {

        public static ApiPart obj = null;
        public static InstApi getApi()
        {
            if (obj == null)
                obj = new InstApi();
            return (InstApi)obj;
        }

        public InstApi()
        {
            addWrapper("log", this.log);
            addWrapper("close", this.close);
            addWrapper("cantstop", this.cantstop);
            addWrapper("canstop", this.canstop);
            addWrapper("system", SystemApi.API.proc);
            addWrapper("vars", VarsApi.API.proc);
            addWrapper("file", FileApi.API.proc);
            addWrapper("resource", ResourceApi.API.proc);
        }

        public static string urldecode(string s)
        {
            //return Uri.UnescapeDataString(s);
            
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
            //Logger.getLogger().dbg("API call "+loc);
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
#if !NO_EXPLORER
            if (Form1.obj != null)
                Form1.obj.stopBrowser();
#endif
            return retOK();
        }
        string cantstop(Paths cmd, Parameters prms)
        {
            Server.getServer().current_page = Server.getServer().home_page+getParam(prms, "pg");
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
        public static ApiPart obj = null;
        public static ApiPart API { get { if (obj == null) obj = new SystemApi(); return obj; } }
        public SystemApi()
        {
            addWrapper("userdir", this.userdir);
            addWrapper("hasfile", this.fileexists);
            addWrapper("matchfile", this.matchfile);
            addWrapper("getfile", this.getfile);
            addWrapper("backup", this.backup);
            addWrapper("restore", this.restore);
            addWrapper("copy", this.copy);
            addWrapper("move", this.move);
            addWrapper("remove", this.move);
            addWrapper("selectdir", this.selectdir);
        }
        public string userdir(Paths pth, Parameters prms)
        {
            string p = Path.GetDirectoryName(Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments));
            return retOK(p);
        }
        public string fileexists(Paths pth, Parameters prms)
        {
            string fl=getParam(prms, "fl");
            Logger.getLogger().dbg("Has File " + fl + "=" + File.Exists(fl).ToString());
            return retOK(File.Exists(fl));
        }
        public string matchfile(Paths pth, Parameters prms)
        {
            string fl = getParamFile(prms, "fl");
            string rx = getParam(prms, "rx");
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
            string fl = getParamFile(prms, "fl");
            StreamReader sr = new StreamReader(new FileStream(fl, FileMode.Open), Encoding.GetEncoding(1251));
            string s = sr.ReadToEnd();
            sr.Close();
            return retOK(escape(s));
        }
        public string backup(Paths pth, Parameters prms)
        {
            string fl = getParamFile(prms, "fl");
            string fl2 = fl + ".bak";
            Logger.getLogger().dbg("Backup " + fl);
            if (!File.Exists(fl2))
                File.Copy(fl, fl2);
            return retOK();
        }
        public string restore(Paths pth, Parameters prms)
        {
            string fl = getParam(prms, "fl");
            string fl2 = fl + ".bak";
            if (!File.Exists(fl2))
                throw new ErrException(1, "backup not found " + fl2);
            File.Copy(fl, fl2, true);
            return retOK();
        }
        public string copy(Paths pth, Parameters prms)
        {
            string fl = getParamFile(prms, "fl");
            string fl2 = getParam(prms, "new");
            Logger.getLogger().dbg("Copy "+fl+" to "+fl2);
            File.Copy(fl, fl2, true);
            return retOK();
        }
        public string move(Paths pth, Parameters prms)
        {
            string fl = getParamFile(prms, "fl");
            string fl2 = getParam(prms, "new");
            if (File.Exists(fl2))
                File.Delete(fl2);
            Logger.getLogger().dbg("Move " + fl + " to " + fl2);
            File.Move(fl, fl2);
            return retOK();
        }
        public string remove(Paths pth, Parameters prms)
        {
            string fl = getParam(prms, "fl");
            Logger.getLogger().dbg("Remove " + fl);
            if (File.Exists(fl))
                File.Delete(fl);
            return retOK();
        }
        public string selectdir(Paths pth, Parameters prms)
        {
            string res = "";
#if !NO_EXPLORER
            if (Form1.obj != null)
                res = Form1.obj.getFld();
            else
#endif
            if (BrowserController.obj != null)
                res = BrowserController.obj.getFld();
            return retOK(res);
        }
    }

    class VarsApi : ApiPart
    {
        public static ApiPart obj = null;
        public static ApiPart API { get { if (obj == null) obj = new VarsApi(); return obj; } }
        Parameters vars=new Parameters();
        public VarsApi()
        {
            addWrapper("setvar", this.setvar);
            addWrapper("getvar", this.getvar);
            addWrapper("hasvar", this.hasvar);
            addWrapper("remvar", this.remvar);
        }
        public string setvar(Paths s, Parameters prms)
        {
            string v=getParam(prms, "vr");
            string vl=getParam(prms,"vl");
            if (vars.ContainsKey(v))
                vars[v] = vl;
            else
                vars.Add(v, vl);
            Logger.getLogger().dbg("Var " + v + "=" + vl);
            return retOK(vl);
        }
        public string getvar(Paths s, Parameters prms)
        {
            string v = getParam(prms, "vr");
            if (!vars.ContainsKey(v))
                throw new ErrException(2, "No variable " + v);
            return retOK(vars[v]);
        }
        public string hasvar(Paths s, Parameters prms)
        {
            return retOK(vars.ContainsKey(getParam(prms, "vr")));
        }
        public string remvar(Paths s, Parameters prms)
        {
            string v = getParam(prms, "vr");
            if (vars.ContainsKey(v))
                vars.Remove(v);
            return retOK();
        }

    }

    class FileApi : ApiPart
    {
        public static ApiPart obj = null;
        class FileDescr
        {
            public string name;
            public MemoryStream ms;
            public FileDescr(string nm, bool empty)
            {
                name = nm;
                ms = new MemoryStream();
            }
            public FileDescr(byte[] data)
            {
                name = "";
                ms = new MemoryStream(data);
            }
            public FileDescr(string nm)
            {
                name = nm;
                FileStream fs = new FileStream(nm,FileMode.Open);
                byte[] data = new byte[fs.Length];
                fs.Read(data, 0, data.Length);
                fs.Close();
                ms = new MemoryStream(data);
            }
        }
        public class NoFileException:ErrException
        {
            public NoFileException(int fid) : base(4, "No file with id " + fid.ToString()) { }
        }
        class XFiles : Dictionary<int, FileDescr> { }
        public static ApiPart API { get { if (obj == null) obj = new FileApi(); return obj; } }
        XFiles xfiles = new XFiles();
        public FileApi()
        {
            addWrapper("open", this.open);
            addWrapper("resopen", this.resopen);
            addWrapper("create", this.create);
            addWrapper("close", this.close);
            addWrapper("read", this.read);
            addWrapper("seek", this.seek);
            addWrapper("write", this.write);
            addWrapper("flush", this.flush);
        }
        int getId()
        {
            int i = 1;
            while (xfiles.ContainsKey(i)) i++;
            return i;
        }
        public int getFile(Parameters prms)
        {
            int id=(int)getParamInt(prms,"fid");
            if (!xfiles.ContainsKey(id))
                throw new NoFileException(id);
            return id;
        }
        public string create(Paths p, Parameters prms)
        {
            string fn = getParamFile(prms, "fl");
            int i = getId();
            xfiles.Add(i, new FileDescr(fn,true));
            return retOK(i);
        }
        public string retIdSize(int id,int size)
        {
            return retOK(new string[]{"result",id.ToString(),"size",size.ToString()});
        }
        public string open(Paths p, Parameters prms)
        {
            string fn = getParamFile(prms, "fl");
            int i = getId();
            xfiles.Add(i, new FileDescr(fn));
            return retIdSize(i,(int)xfiles[i].ms.Length);
        }
        public string resopen(Paths p, Parameters prms)
        {
            string fn = getParam(prms, "res");
            int i = getId();
            xfiles.Add(i, new FileDescr(ResourceLocator.getResources().getResource(fn)));
            return retIdSize(i, (int)xfiles[i].ms.Length);
        }
        public string close(Paths p, Parameters prms)
        {
            int id = getFile(prms);
            xfiles[id].ms.Close();
            xfiles.Remove(id);
            return retOK();
        }
        public string flush(Paths p, Parameters prms)
        {
            int id = getFile(prms);
            if (xfiles[id].name == "")
                throw new ErrException(8, "Cant flush resource");
            FileStream f = new FileStream(xfiles[id].name, FileMode.Create);
            long ppos=xfiles[id].ms.Position;
            xfiles[id].ms.Position = 0;
            xfiles[id].ms.WriteTo(f);
            f.Close();
            xfiles[id].ms.Position=ppos;
            return retOK();
        }
        public string seek(Paths p, Parameters prms)
        {
            int id = getFile(prms);
            Int64 pos = getParamInt(prms, "pos");
            Int64 ofs=0;
            if (hasParam(prms,"ofs"))
                ofs = getParamInt(prms, "ofs");
            long ps = pos;
            if (ofs == 1)
                ps = xfiles[id].ms.Position+pos;
            if (ofs == 2)
                ps = xfiles[id].ms.Length - pos;
            xfiles[id].ms.Position = ps;
            Logger.getLogger().dbg("file "+id.ToString()+" seek on "+pos.ToString()+" to "+ps.ToString());
            return retOK();
        }
        public string read(Paths p, Parameters prms)
        {
            int id = getFile(prms);
            int sz = (int)getParamInt(prms, "sz");
            byte[] data = new byte[sz];
            xfiles[id].ms.Read(data, 0, sz);
            if (!hasParam(prms, "be") || getParamInt(prms, "be") == 0)
                rotateBytes(ref data);
            Logger.getLogger().dbg("file " + id.ToString() + " readed " + sz.ToString()+" bytes");
            return retOK(byte2str(data));
        }
        public string write(Paths p, Parameters prms)
        {
            int id = getFile(prms);
            byte[] data = str2byte(getParam(prms,"val"));
            if (!hasParam(prms, "be") || getParamInt(prms, "be") == 0)
                rotateBytes(ref data);
            xfiles[id].ms.Write(data, 0, data.Length);
            Logger.getLogger().dbg("file " + id.ToString() + " written " + data.Length.ToString() + " bytes");
            return retOK();
        }
    }


    class ResourceApi : ApiPart
    {
        public class NoMapException : ErrException
        {
            public NoMapException(int mid) : base(7, "No map with id " + mid.ToString()) { }
        }
        public class NoResException : ErrException
        {
            public NoResException(string rid) : base(6, "No resource with id " + rid) { }
        }
        class MapCmd
        {
            public enum Cmd{INSERT_RES,INSERT_VALUE,INSERT_FILE};
            public Cmd cmd;
            public int ofs;
            public int oldsz;
            public string sdata;
            public byte[] bdata;
            public MapCmd(Cmd cmd,int ofs,int oldsz)
            {
                this.cmd=cmd;
                this.ofs=ofs;
                this.oldsz=oldsz;
            }
            public MapCmd(Cmd cmd,int ofs,int oldsz,string data):this(cmd,ofs,oldsz)
            {
                sdata=data;
            }
            public MapCmd(Cmd cmd,int ofs,int oldsz,byte[] data):this(cmd,ofs,oldsz)
            {
                bdata=data;
            }
        }
        class Map
        {
            public string fname;
            public List<MapCmd> cmds=new List<MapCmd>();
            public Map(string fname)
            {
                this.fname=fname;
            }
        }
        public static ApiPart obj = null;
        public static ApiPart API { get { if (obj == null) obj = new ResourceApi(); return obj; } }
        Dictionary<int, Map> maps = new Dictionary<int, Map>();
        public ResourceApi()
        {
            addWrapper("ressize",this.getsize);
            addWrapper("hasres",this.hasres);
            addWrapper("insertres", this.insertres);
            addWrapper("insertval", this.insertval);
            addWrapper("makemap", this.makemap);
            addWrapper("mapres", this.mapres);
            addWrapper("mapval", this.mapval);
            addWrapper("mapfile", this.mapfile);
            addWrapper("applymap", this.applymap);
            addWrapper("applymaps", this.applymaps);
            addWrapper("clearmap", this.clearmap);
            addWrapper("clearmaps", this.clearmaps);
        }
        public string hasres(Paths p, Parameters prms)
        {
            return retOK(ResourceLocator.getResources().hasResource(getParam(prms,"res")));
        }
        public string getResName(Parameters prms)
        {
            string nm = getParam(prms, "res");
            if (!ResourceLocator.getResources().hasResource(nm))
                throw new NoResException(nm);
            return nm;
        }
        public byte[] getRes(Parameters prms)
        {
            return ResourceLocator.getResources().getResource(getResName(prms));
        }
        public string getsize(Paths p, Parameters prms)
        {
            return retOK((int)ResourceLocator.getResources().resSize(getResName(prms)));
        }
        public void StreamCopy(Stream from,Stream to,int sz)
        {
            if (sz == 0)
                return;
            byte[] buf = new byte[8192];
            int rd = 0;
            int total=0;
            while(true)
            {
                rd = from.Read(buf, 0, (sz - total > 8192 ? 8192 : (sz - total)));
                to.Write(buf, 0, rd);
                total += rd;
                if (total == sz)
                    break;
            }
        }
        public void insertData(string fl, byte[] data, int ofs, int oldsz)
        {
            string tmp = fl + ".tmp";
            FileStream fs = new FileStream(fl, FileMode.Open);
            FileStream o=new FileStream(tmp,FileMode.Create);
            StreamCopy(fs, o, ofs);
            fs.Position += oldsz;
            o.Write(data, 0, data.Length);
            StreamCopy(fs, o, (int)(fs.Length-fs.Position));
            fs.Close();
            o.Close();
            File.Delete(fl);
            File.Move(tmp, fl);
        }
        int[] getOfsOsz(Parameters prms)
        {
            return new int[] { (int)getParamInt(prms, "ofs"), (int)getParamInt(prms, "osz") };
        }
        string retDelta(int nsz, int[] os)
        {
            return retOK(new string[] { "result", nsz.ToString(), "delta", (nsz - os[1]).ToString() });
        }
        public string insertres(Paths p, Parameters prms)
        {
            string fl = getParamFile(prms, "fl");
            int[] os = getOfsOsz(prms);
            byte[] data = getRes(prms);
            insertData(fl, data, os[0], os[1]);
            return retDelta(data.Length,os);
        }
        public byte[] getVal(Parameters prms)
        {
            byte[] data = str2byte(getParam(prms, "val"));
            if (!hasParam(prms, "be") || getParamInt(prms, "be") == 0)
                rotateBytes(ref data);
            return data;
        }
        public string insertval(Paths p, Parameters prms)
        {
            string fl = getParamFile(prms, "fl");
            int[] os = getOfsOsz(prms);
            byte[] data = getVal(prms);
            insertData(fl, data, os[0], os[1]);
            return retDelta(data.Length, os);
        }
        public int getMap(Parameters prms)
        {
            int id = (int)getParamInt(prms, "mid");
            if (!maps.ContainsKey(id))
                throw new NoMapException(id);
            return id;
        }
        public string makemap(Paths p, Parameters prms)
        {
            string fn = getParamFile(prms, "fl");
            int i = 1;
            while (maps.ContainsKey(i)) i++;
            maps.Add(i, new Map(fn));
            Logger.getLogger().dbg("made map "+i.ToString()+" on "+fn);
            return retOK(i);
        }
        public string mapres(Paths p, Parameters prms)
        {
            int m = getMap(prms);
            string rname=getResName(prms);
            int[] os = getOfsOsz(prms);
            maps[m].cmds.Add(new MapCmd(MapCmd.Cmd.INSERT_RES,os[0],os[1],rname));
            uint rsize = ResourceLocator.getResources().resSize(rname);
            Logger.getLogger().dbg("map "+m.ToString()+" res "+rname+" ofs=0x"+os[0].ToString("X"));
            return retDelta((int)rsize,os);
        }
        public string mapfile(Paths p, Parameters prms)
        {
            int m = getMap(prms);
            int[] os = getOfsOsz(prms);
            string fl = getParamFile(prms, "fl");
            maps[m].cmds.Add(new MapCmd(MapCmd.Cmd.INSERT_FILE, os[0], os[1], fl));
            FileInfo fi=new FileInfo(fl);
            Logger.getLogger().dbg("map " + m.ToString() + " file " + fl + " ofs=0x" + os[0].ToString("X"));
            return retDelta((int)fi.Length,os);
        }
        public string mapval(Paths p, Parameters prms)
        {
            int m = getMap(prms);
            byte[] data = getVal(prms);
            int[] os = getOfsOsz(prms);
            maps[m].cmds.Add(new MapCmd(MapCmd.Cmd.INSERT_VALUE, os[0], os[1], data));
            Logger.getLogger().dbg("map " + m.ToString() + " val "+data.Length.ToString()+" bytes ofs=0x" + os[0].ToString("X"));
            return retDelta(data.Length, os);
        }
        public void applymap(int m)
        {
            string fl = maps[m].fname;
            FileStream fin = new FileStream(fl, FileMode.Open);
            FileStream fout = new FileStream(fl+".tmp", FileMode.Create);
            foreach (MapCmd c in maps[m].cmds)
            {
                StreamCopy(fin,fout,c.ofs-(int)fin.Position);
                fin.Position += c.oldsz;
                switch (c.cmd)
                {
                    case MapCmd.Cmd.INSERT_RES:
                        byte[] data = ResourceLocator.getResources().getResource(c.sdata);
                        fout.Write(data, 0, data.Length);
                        break;
                    case MapCmd.Cmd.INSERT_VALUE:
                        fout.Write(c.bdata, 0, c.bdata.Length);
                        break;
                    case MapCmd.Cmd.INSERT_FILE:
                        FileStream fs = new FileStream(c.sdata, FileMode.Open);
                        StreamCopy(fs, fout, (int)fs.Length);
                        fs.Close();
                        break;
                }
            }
            StreamCopy(fin, fout, (int)(fin.Length - fin.Position));
            fin.Close();
            fout.Close();
            File.Delete(fl);
            File.Move(fl + ".tmp", fl);
        }
        public string applymap(Paths p, Parameters prms)
        {
            int m=getMap(prms);
            applymap(m);
            maps.Remove(m);
            return retOK();
        }
        public string applymaps(Paths p, Parameters prms)
        {
            foreach(int k in maps.Keys)
            {
                applymap(k);
            }
            maps.Clear();
            return retOK();
        }
        public string clearmap(Paths p, Parameters prms)
        {
            maps.Remove(getMap(prms));
            return retOK();
        }
        public string clearmaps(Paths p, Parameters prms)
        {
            maps.Clear();
            return retOK();
        }
    }
}
