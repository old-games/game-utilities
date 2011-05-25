#!/usr/bin/python
import BaseHTTPServer
import time,os,shutil
import webbrowser,json
import base64,zlib,struct,re
from xml.dom.minidom import parseString
try:
    from cStringIO import StringIO
except:
    from StringIO import StringIO
import Tkinter,tkFileDialog

xserver=None
instapi=None
varsapi=None
fileapi=None
resapi=None
wbcontrol=None
logger=None
locator=None
data_bin=None

#logger
class Logger:
    fl=None
    debug=False
    @staticmethod
    def getLogger():
        global logger
        if (logger==None):
            logger=Logger()
        return logger
    def free(self):
        if (self.fl!=None):
            self.fl.close()

    def setup(self,dbg,log):
        self.debug=dbg
        if (log):
            self.fl=open("./install.log","w")

    def dbg(self,s):
        if (not self.debug):
            return
        print "DBG:",s
        if (self.fl!=None):
            self.fl.write("DBG:"+s+"\n")

    def printf(self,s):
        print s
        if (self.fl!=None):
            self.fl.write(s+"\n")


#resourcers
class Decompressor:
    @staticmethod
    def decompress(data,rsz):
        return zlib.decompress(data)

class NoResourceEx(Exception):
    def __init__(self,resname):
        Exception.__init__(self,"No resource "+resname)

class ResReader:
    def hasResource(self,name):
        return False
    def getResource(self,name):
        raise NoResourceEx(name)
    def resSize(self,name):
        return 0

class ExternalResReader(ResReader):
    path="./"
    @staticmethod
    def valid():
        return os.path.isfile("install.cfg")
    def __init__(self):
        self.path=os.path.dirname(os.path.realpath(__file__))
    def hasResource(self,name):
        return (os.path.isfile(os.path.join(self.path,name)))
    def getResource(self,name):
        if not self.hasResource(name):
            raise NoResourceEx(name)
        f=open(os.path.join(self.path,name),'rb')
        r=f.read()
        f.close();
        return r
    def resSize(self,name):
        if not self.hasResource(name):
            raise NoResourceEx(name)
        st=os.stat(os.path.join(self.path,name))
        return st.st_size

class OneResReader(ResReader):
    data=None
    hdr=[]
    @staticmethod
    def valid():
        fname=os.path.join(os.path.dirname(os.path.realpath(__file__)),"data.bin")
        return os.path.isfile(fname)
    def __init__(self,data=None):
        if (data==None):
            fname=os.path.join(os.path.dirname(os.path.realpath(__file__)),"data.bin")
            f=open(fname,'rb')
            data=StringIO(f.read())
            f.close()
        self.processData(data)
    def processData(self,data):
        b=struct.unpack("<L",data.read(4))[0]
        for i in range(b):
            n,o,c,r=struct.unpack("<16sLLL",data.read(16+4*3))
            self.hdr+=[(n.strip('\0'),o,c,r)]
        self.data=StringIO(data.read())
        data.close()
    def hasResource(self,name):
        for x in self.hdr:
            if (x[0]==name):
                return True
        return False
    def getResource(self,name):
        for x in self.hdr:
            if (x[0]==name):
                self.data.seek(x[1])
                r=self.data.read(x[2])
                if (x[3]!=0):
                    r=Decompressor.decompress(r,x[3])
                return r
        raise NoResourceEx(name)
    def resSize(self,name):
        for x in self.hdr:
            if (x[0]==name):
                if (x[3]!=0):
                    return x[3]
                return x[2]
        raise NoResourceEx(name)

class InternalResReader(OneResReader):
    def __init__(self):
        global data_bin
        try:
            if (data_bin==None):
                raise NoResourceEx("internal")
        except NameError:
            raise NoResourceEx("internal")
        OneResReader.__init__(self,StringIO(base64.decodestring(data_bin)))

class ResourceLocator:
    @staticmethod
    def getReader():
        global locator
        if (locator==None):
            locator=ResourceLocator.locateResource()
        return locator
    @staticmethod
    def locateResource():
        global locator
        if (locator!=None):
            return locator
        if (ExternalResReader.valid()):
            return ExternalResReader()
        if (OneResReader.valid()):
            return OneResReader()
        return InternalResReader()
    @staticmethod
    def getXmlResource(name):
        return parseString(ResourceLocator.getReader().getResource(name))

#end_resourcers


#webcontrol
class WebControl:
    @staticmethod
    def getControl():
        global wbcontrol
        if (wbcontrol==None):
            wbcontrol=WebControl()
        return wbcontrol
    def startBrowser(self,pg):
        webbrowser.open(pg)

    def restartBrowser(self,pg):
        self.startBrowser(pg)

    def run(self):
        self.startBrowser(JServer.getServer().start_page)
#server

class JHandler(BaseHTTPServer.BaseHTTPRequestHandler):
    def log_request(self,code,msg=None):
        pass
    def do_GET(self):
        JServer.getServer().lasttime=time.time()
        path=self.path
        s=""
        tp=""
        cache=False
        if (path[:5]=="/api/"):
            tp="application/json"
            path=path[5:]
            if (path=="hb"):
                s='{r:0}'
            else:
                s=InstApi.getAPI().process(path)
            cache=True
        else:
            if (path=="/"):
                path="/index.html"
            path=path[1:]
            Logger.getLogger().dbg("request "+path)
            try:
                s=ResourceLocator.getReader().getResource(path)
            except:
                self.send_response(404,"resource not found "+path)
                return
            (r,ext)=os.path.splitext(path)
            if (ext=="html" or ext=="xml" or ext=="css"):
                tp="text/"+ext
            elif (ext=="jpg"):
                tp="image/jpeg"
            elif (ext=="bmp" or ext=="png"):
                tp="image/"+ext
            elif (ext=="js"):
                tp="application/javascript"
            elif (ext=="mid"):
                tp="audio/midi"
            elif (ext=="wav"):
                tp="audio/x-wav"
        self.send_response(200)
        self.send_header('Content-Type','text/html')
        self.send_header('Content-Length',str(len(s)))
        if (cache):
            self.send_header('Expires',"Mon, 26 Jul 1997 05:00:00 GMT")
            self.send_header('Cache-Control',"no-cache, no-store, must-revalidate")
            self.send_header('Pragma',"no-cache")
        self.end_headers()
        self.wfile.write(s)
        JServer.getServer().lasttime=time.time()

class JServer:
    m_stop=False
    svr=None
    canstop=True
    start_page="http://localhost:34567/"
    current_page=start_page
    lasttime=False
    @staticmethod
    def getServer():
        global xserver
        if (xserver==None):
            xserver=JServer()
        return xserver
    def __init__(self):
        self.svr=BaseHTTPServer.HTTPServer(('127.0.0.1',34567),JHandler)
    def stop(self):
        self.m_stop=True
    def run(self):
        self.lasttime=time.time()
        while not self.m_stop:
            self.svr.timeout=1
            self.svr.handle_request()
            if (int(time.time()-self.lasttime)>5):
                self.lasttime=time.time()
                if self.canstop:
                    Logger.getLogger().dbg("Browser Timeout. Stopping server")
                    self.m_stop=True
                else:
                    Logger.getLogger().dbg("Browser Timeout. Restarting Browser")
                    WebControl.getControl().restartBrowser(self.current_page)

#api
class ErrException(Exception):
    code=0
    descr=""
    def __init__(self,c,d):
        self.code=c
        self.descr=d
        Exception.__init__(self,'{r:'+str(c)+', d:"'+d+'"}')
class BadApiException(ErrException):
    def __init__(self,path):
        ErrException.__init__(self,-1,"BAD API call "+path)
class NoParamException(ErrException):
    def __init__(self,param):
        ErrException.__init__(self,2,"parameter expected "+param)
class BadParamException(ErrException):
    def __init__(self,param,val):
        ErrException.__init__(self,3,"Bad parameter "+param+" value:"+val)

class ApiPart:
    def __init__(self):
        self.wrps={}
    def addWrapper(self,w,p):
        self.wrps[w]=p
    def proc(self,path,prms):
        try:
            if (len(path)==0):
                raise BadApiException("empty_path")
            if (path[0] in self.wrps):
                return self.wrps[path[0]](path[1:],prms)
            else:
                raise BadApiException(path[0])
        except ErrException, ex:
            Logger.getLogger().dbg("API ERROR:"+str(ex.code)+":"+ex.descr)
            return str(ex)
        except Exception, ex:
            Logger.getLogger().dbg("external ERROR:"+str(ex))
            return '{r:-1; d:"'+str(ex)+'"}'

    def hasParam(self,prms,p):
        return (p in prms)
    def getParam(self,prms,p):
        if (not self.hasParam(prms,p)):
            raise NoParamException(p)
        return prms[p]
    def getParamFile(self,prms,p):
        fl=self.getParam(prms,p)
        if not os.path.isfile(fl):
            raise ErrException(1,"file not found "+fl)
        return fl
    def getParamInt(self,prms,p):
        x=self.getParam(prms,p)
        i=0
        try:
            i=int(x)
        except:
            raise BadParamException(p,x)
        return i
    def retOK(self):
        return '{r:0}'
    def retOKmany(self,data):
        data['r']=0;
        return json.dumps(data)
    def retOKres(self,res):
        return self.retOKmany({'result':res})
    def escape(self,s):
        s=s.replace('|','||').replace('"','|!')
        s=s.replace('\n','|n').replace('\r','|r').replace('\t','|t')
        return s
    def rotateBytes(self,bts):
        rb=[]
        for x in bts:
            rb=[x]+rb
        return rb
    def byte2str(self,bts):
        s=''
        for x in bts:
            s+="%02X"%x
        return s
    def str2byte(self,st):
        bts=[]
        for i in range(len(st)/2):
            x=eval('0x'+st[i*2:i*2+2])
            bts+=[x]
        return bts


class SystemApi(ApiPart):
    lastpath="/"
    def __init__(self):
        ApiPart.__init__(self)
        self.addWrapper("userdir",self.userdir)
        self.addWrapper("hasfile",self.hasfile)
        self.addWrapper("getfile",self.getfile)
        self.addWrapper("matchfile",self.matchfile)
        self.addWrapper("backup",self.backup)
        self.addWrapper("restore",self.restore)
        self.addWrapper("copy",self.copy)
        self.addWrapper("move",self.move)
        self.addWrapper("remove",self.remove)
        self.addWrapper("selectdir",self.selectdir)
    def userdir(self,pth,prms):
        return self.retOKres(os.path.expanduser("~"));
    def hasfile(self,pth,prms):
        return self.retOKres(os.path.isfile(self.getParam(prms,"fl")))
    def getfile(self,pth,prms):
        f=open(self.getParamFile(prms,"fl"),'r')
        s=f.read()
        f.close()
        return self.retOKres(self.escape(s))
    def matchfile(self,pth,prms):
        raise ErrException(-2,"Not implemented")
    def backup(self,pth,prms):
        fl=self.getParamFile(prms,"fl")
        fl2=fl+".bak"
        Logger.getLogger().dbg("backup "+fl);
        if not os.path.isfile(fl2):
            shutil.copy(fl,fl2)
        return self.retOK()
    def restore(self,pth,prms):
        fl=self.getParam(prms,"fl")
        fl2=fl+".bak"
        if not os.path.exists(fl2):
            raise ErrException(1,"backup not found "+fl2)
        shutil.copy(fl2,fl)
        return self.retOK()
    def copy(self,p,prms):
        fl=self.getParamFile(prms,"fl")
        fl2=self.getParam(prms,"new")
        Logger.getLogger().dbg("copy "+fl+" to "+fl2)
        shutil.copy(fl,fl2)
        return self.retOK()
    def move(self,p,prms):
        fl=self.getParamFile(prms,"fl")
        fl2=self.getParam(prms,"new")
        if os.path.isfile(fl2):
            os.remove(fl2)
        Logger.getLogger().dbg("move "+fl+" to "+fl2)
        shutil.move(fl,fl2)
        return self.retOK()
    def remove(self,p,prms):
        fl=self.getParam(prms,"fl")
        Logger.getLogger().dbg("remove "+fl)
        if os.path.isfile(fl):
            os.remove(fl)
        return self.retOK()
    def selectdir(self,p,prms):
        root=Tkinter.Tk()
        root.wm_attributes("-topmost",1)
        root.withdraw()
        self.lastpath=tkFileDialog.askdirectory(parent=root,initialdir=self.lastpath)
        root.quit()
        root.destroy()
        return self.retOKres(self.lastpath)

class VarsApi(ApiPart):
    vrs={}
    def __init__(self):
        ApiPart.__init__(self)
        self.addWrapper("setvar",self.setvar)
        self.addWrapper("getvar",self.getvar)
        self.addWrapper("hasvar",self.hasvar)
        self.addWrapper("remvar",self.remvar)
    def setvar(self,p,prms):
        vr=self.getParam(prms,"vr")
        vl=self.getParam(prms,"vl")
        Logger.getLogger().dbg("var "+vr+"="+vl)
        self.vrs[vr]=vl
        return self.retOKres(vl)
    def getvar(self,p,prms):
        vr=self.getParam(prms,"vr")
        if not self.vrs.has_key(vr):
            raise ErrException(2,"No variable "+vr)
        return self.retOKres(self.vrs[vr])
    def hasvar(self,p,prms):
        return self.retOKres(self.vrs.has_key(self.getParam(prms,"vr")))
    def remvar(self,p,prms):
        vr=self.getParam(prms,"vr")
        if self.vrs.has_key(vr):
            del self.vrs[vr]
        return self.retOK()

class NoFileException(ErrException):
    def __init__(self,id):
        ErrException.__init__(self,4,"No file with id "+str(id))

class FileApi(ApiPart):
    xfiles={}
    def __init__(self):
        ApiPart.__init__(self)
        self.addWrapper("open",self.fopen)
        self.addWrapper("create",self.fcreate)
        self.addWrapper("resopen",self.resopen)
        self.addWrapper("close",self.fclose)
        self.addWrapper("read",self.fread)
        self.addWrapper("seek",self.fseek)
        self.addWrapper("write",self.fwrite)
        self.addWrapper("flush",self.fflush)
    def flen(self,f):
        p=f.tell()
        f.seek(0,os.SEEK_END)
        r=f.tell()
        f.seek(p,os.SEEK_SET)
        return r
    def getId(self):
        i=1
        while (self.xfiles.has_key(i)):
            i+=1
        return i
    def getFile(self,prms):
        i=self.getParamInt(prms,"fid")
        if not self.xfiles.has_key(i):
            raise NoFileException(i)
        return i
    def retIdSize(self,id,sz):
        return self.retOKmany({"result":id,"size":sz})
    def fcreate(self,p,prms):
        fl=self.getParam(prms,"fl")
        i=self.getId()
        self.xfiles[i]=(fl,StringIO())
        return self.retOKres(i)
    def fopen(self,p,prms):
        fl=self.getParamFile(prms,"fl")
        i=self.getId()
        f=open(fl,'rb')
        self.xfiles[i]=(fl,StringIO())
        self.xfiles[i][1].write(f.read())
        self.xfiles[i][1].seek(0)
        f.close()
        return self.retIdSize(i,self.flen(self.xfiles[i][1]))
    def resopen(self,p,prms):
        fl=self.getParam(prms,"res")
        i=self.getId()
        self.xfiles[i]=('',StringIO())
        self.xfiles[i][1].write(ResourceLocator.getReader().getResource(fl))
        self.xfiles[i][1].seek(0)
        return self.retIdSize(i,self.flen(self.xfiles[i][1]))
    def fclose(self,p,prms):
        fid=self.getFile(prms)
        self.xfiles[fid][1].close()
        del self.xfiles[fid]
        return self.retOK()
    def fflush(self,p,prms):
        fid=self.getFile(prms)
        if (self.xfiles[fid][0]==''):
            raise ErrException(8,"Cant flush resource")
        pos=self.xfiles[fid][1].tell()
        f=open(self.xfiles[fid][0],'wb')
        f.write(self.xfiles[fid][1].getvalue())
        f.close()
        #Logger.getLogger().dbg("FILE "+self.xfiles[fid][0]+" FLUSH STUB");
        self.xfiles[fid][1].seek(pos,os.SEEK_SET)
        return self.retOK()
    def fseek(self,p,prms):
        fid=self.getFile(prms)
        pos=self.getParamInt(prms,"pos")
        ofs=os.SEEK_SET
        if (self.hasParam(prms,"ofs")):
            o=self.getParamInt(prms,"ofs")
            if (o==1):
                ofs=os.SEEK_CUR
            if (o==2):
                ofs=os.SEEK_END
        self.xfiles[fid][1].seek(pos,ofs)
        ps=self.xfiles[fid][1].tell()
        Logger.getLogger().dbg("file "+str(fid)+" seek on "+str(pos)+" to "+str(ps));
        return self.retOK()
    def fread(self,p,prms):
        fid=self.getFile(prms)
        sz=self.getParamInt(prms,"sz")
        bts=struct.unpack(str(sz)+'B',self.xfiles[fid][1].read(sz))
        if (not self.hasParam(prms,"be")) or self.getParam(prms,"be")==0:
            bts=self.rotateBytes(bts)
        Logger.getLogger().dbg("file " + str(fid) + " readed " + str(sz)+" bytes");
        return self.retOKres(self.byte2str(bts))
    def fwrite(self,p,prms):
        fid=self.getFile(prms)
        bts=self.str2byte(self.getParam(prms,"val"))
        if (not self.hasParam(prms,"be")) or self.getParam(prms,"be")==0:
            bts=self.rotateBytes(bts)
        self.xfiles[fid][1].write(struct.pack(str(len(bts))+'B',*bts))
        Logger.getLogger().dbg("file " + str(fid) + " written " + str(len(bts))+" bytes");
        return self.retOK()

class NoMapException(ErrException):
    def __init__(self,mid):
        ErrException.__init__(self,7, "No map with id " + str(mid))
class NoResException(ErrException):
    def __init__(self,rid):
        ErrException.__init__(self,6, "No resource with id " + rid)
class ResourceApi(ApiPart):
    maps={}
    def __init__(self):
        ApiPart.__init__(self)
        self.addWrapper("ressize",self.ressize);
        self.addWrapper("hasres",self.hasres);
        self.addWrapper("insertres", self.insertres);
        self.addWrapper("insertval", self.insertval);
        self.addWrapper("makemap", self.makemap);
        self.addWrapper("mapres", self.mapres);
        self.addWrapper("mapval", self.mapval);
        self.addWrapper("mapfile", self.mapfile);
        self.addWrapper("applymap", self.applymap);
        self.addWrapper("applymaps", self.applymaps);
        self.addWrapper("clearmap", self.clearmap);
        self.addWrapper("clearmaps", self.clearmaps);
    def getResName(self,prms):
        nm=self.getParam(prms,"res")
        if not ResourceLocator.getReader().hasResource(nm):
            raise NoResException(nm)
        return nm
    def getval(self,prms):
        bts=self.str2byte(self.getParam(prms,"val"))
        if (not self.hasParam(prms,"be"))or(self.getParam(prms,"be")==0):
            bts=self.rotateBytes(bts)
        return struct.pack(str(len(bts))+"B",*bts)
    def getOfsSz(self,prms):
        return (self.getParamInt(prms,"ofs"),self.getParamInt(prms,"osz"))
    def getRes(self,prms):
        return ResourceLocator.getReader().getResource(self.getResName(prms))
    def retDelta(self,sz,o):
        return self.retOKmany({"result":sz,"delta":sz-o[1]})
    def getMap(self,prms):
        i=self.getParamInt(prms,"mid")
        if not self.maps.has_key(i):
            raise NoMapException(i)
        return i
    def insertData(f,ofs,osz,val):
        fin=open(f,"rb")
        fout=open(f+".tmp","wb")
        fout.write(fin.read(ofs))
        fin.seek(osz,os.SEEK_CUR)
        fout.write(val)
        fout.write(fin.read())
        fin.close()
        fout.close()
        os.remove(f)
        shutil.move(f+".tmp",f)
    def hasres(self,p,prms):
        return self.retOKres(ResourceLocator.getReader().hasResource(self.getParam("res")))
    def ressize(self,p,prms):
        return self.retOKres(ResourceLocator.getReader().resSize(self.getResName(prms)))
    def insertres(self,p,prms):
        fl=self.getParamFile(prms,"fl")
        o=self.getOfsSz(prms)
        r=self.getRes(prms)
        self.insertData(fl,o[0],o[1],r)
        return self.retDelta(len(r),o)
    def insertval(self,p,prms):
        fl=self.getParamFile(prms,"fl")
        o=self.getOfsSz(prms)
        b=self.getval(prms)
        self.insertData(fl,o[0],o[1],b)
        return self.retDelta(len(r),o)
    def makemap(self,p,prms):
        fl=self.getParamFile(prms,"fl")
        i=1
        while (self.maps.has_key(i)):
            i+=1
        self.maps[i]=[fl,[]]
        Logger.getLogger().dbg("made map "+str(i)+" on "+fl)
        return self.retOKres(i)
    def mapres(self,p,prms):
        m=self.getMap(prms)
        o=self.getOfsSz(prms)
        rn=self.getResName(prms)
        self.maps[m][1]+=[('R',rn,o)]
        sz=ResourceLocator.getReader().resSize(rn)
        Logger.getLogger().dbg("map "+str(m)+" res "+rn+(" ofs=0x%X" % o[0]));
        return self.retDelta(sz,o)
    def mapval(self,p,prms):
        m=self.getMap(prms)
        o=self.getOfsSz(prms)
        vl=self.getval(prms)
        self.maps[m][1]+=[('V',vl,o)]
        Logger.getLogger().dbg("map "+str(m)+" val "+str(len(vl))+(" bytes ofs=0x%X" % o[0]));
        return self.retDelta(len(vl),o)
    def mapfile(self,p,prms):
        m=self.getMap(prms)
        o=self.getOfsSz(prms)
        fl=self.getParamFile(prms,"fl")
        self.maps[m][1]+=[('F',fl,o)]
        st=os.stat(fl)
        Logger.getLogger().dbg("map "+str(m)+" file "+fl+(" bytes ofs=0x%X" % o[0]));
        return self.retDelta(st.st_size,o)
    def applymap(self,p,prms):
        m=self.getMap(prms)
        self.domap(m)
        del self.maps[m]
        return self.retOK()
    def applymaps(self,p,prms):
        for x in self.maps.keys():
            self.domap(x)
        self.maps={}
        return self.retOK()
    def clearmap(self,p,prms):
        m=self.getMap(prms)
        del self.maps[m]
        return self.retOK();
    def clearmaps(self,p,prms):
        self.maps={}
        return self.retOK();
    def domap(self,mid):
        fl=self.maps[mid][0]
        fin=open(fl,'rb')
        fout=open(fl+".tmp",'wb')
        pos=0
        for c in self.maps[mid][1]:
            fout.write(fin.read(c[2][0]-fin.tell()))
            fin.seek(c[2][1],os.SEEK_CUR)
            if (c[0]=='R'):
                fout.write(ResourceLocator.getReader().getResource(c[1]))
            elif (c[0]=='V'):
                fout.write(c[1])
            elif (c[0]=='F'):
                f=open(c[1],'rb')
                fout.write(f.read())
                f.close()
            else:
                raise ErrException(10,"Bad cmd")
        fout.write(fin.read())
        fin.close()
        fout.close()
        os.remove(fl)
        shutil.move(fl+".tmp",fl)


class InstApi(ApiPart):
    @staticmethod
    def getAPI():
        global instapi
        if (instapi==None):
            instapi=InstApi()
        return instapi
    system_api=SystemApi()
    vars_api=VarsApi()
    file_api=FileApi()
    res_api=ResourceApi()
    def __init__(self):
        ApiPart.__init__(self)
        self.addWrapper("log",self.log)
        self.addWrapper("close",self.close)
        self.addWrapper("cantstop",self.cantstop)
        self.addWrapper("canstop",self.canstop)
        self.addWrapper("system",self.system_api.proc)
        self.addWrapper("vars",self.vars_api.proc)
        self.addWrapper("file",self.file_api.proc)
        self.addWrapper("resource",self.res_api.proc)
    @staticmethod
    def htc(m):
        return chr(int(m.group(1),16))
    def urldecode(self,url):
        rex=re.compile('%([0-9a-hA-H][0-9a-hA-H])',re.M)
        return rex.sub(InstApi.htc,url)
    def process(self,loc):
        prms={}
        pth=[]
        #Logger.getLogger().dbg("API call "+loc)
        if (loc.find('?')>-1):
            (l,p)=loc.split('?',2)
            pth=l.split('/')
            for x in p.split('&'):
                pr=x.split('=')
                prms[self.urldecode(pr[0])]=self.urldecode(pr[1])
        else:
            pth=loc.split('/')
        return self.proc(pth,prms)
    def log(self,p,prms):
        s=self.getParam(prms,"s")
        Logger.getLogger().printf(s)
        return self.retOK()
    def close(self,p,prms):
        JServer.getServer().stop()
        return self.retOK()
    def cantstop(self,p,prms):
        JServer.getServer().current_page=JServer.getServer().start_page+self.getParam(prms,"pg")
        JServer.getServer().canstop=False
        return self.retOK()
    def canstop(self,p,prms):
        JServer.getServer().canstop=True
        return self.retOK()

#api_end

#MAIN
def main():
    try:
        ResourceLocator.locateResource()
        cfg=ResourceLocator.getXmlResource("install.cfg")
        root=cfg.documentElement
        nm=root.getAttribute('nm')
        l=root.getAttribute('l')
        dbg=False
        log=False
        if l!="":
            l=int(l)
            dbg=(l&1)!=0
            log=(l&4)!=0
        Logger.getLogger().setup(dbg,log)
        Logger.getLogger().dbg("config loaded 4 app "+nm)
    except Exception, e:
        print "ERROR: cant read config ",str(e)
        raise
        return
    Logger.getLogger().dbg("starting server")
    svr=JServer.getServer()
    WebControl.getControl().run()
    svr.run()
    Logger.getLogger().free()

#data_bin="base64"

if __name__ == '__main__':
    main()
