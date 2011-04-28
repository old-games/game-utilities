#!/usr/bin/python
import BaseHTTPServer
import time
import os
import webbrowser
import base64
from xml.dom.minidom import parseString
try:
    from cStringIO import StringIO
except:
    from StringIO import StringIO
import struct
import zlib
import re
import json

xserver=None
instapi=None
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
            self.send_header('Cache-Control',"no-cache")
            self.send_header('Cache-Control',"no-store")
            self.send_header('Cache-Control',"must-revalidate")
            self.send_header('Expires',"0")
        self.end_headers()
        self.wfile.write(s)

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
        ErrException.__init__(self,-2,"parameter expected "+param)

class ApiPart:
    wrps={}
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


class SystemApi(ApiPart):
    def __init__(self):
        self.addWrapper("userdir",self.userdir)
        self.addWrapper("hasfile",self.hasfile)
        self.addWrapper("getfile",self.getfile)
        #self.addWrapper("matchfile",self.matchfile)
    def userdir(self,pth,prms):
        return self.retOKres(os.path.expanduser("~"));
    def hasfile(self,pth,prms):
        return self.retOKres(os.path.isfile(self.getParam(prms,"fl")))
    def getfile(self,pth,prms):
        f=open(self.getParam(prms,"fl"),'r')
        s=f.read()
        f.close()
        return self.retOKres(self.escape(s))

class InstApi(ApiPart):
    @staticmethod
    def getAPI():
        global instapi
        if (instapi==None):
            instapi=InstApi()
        return instapi
    system_api=SystemApi()
    def __init__(self):
        self.addWrapper("log",self.log)
        self.addWrapper("close",self.close)
        self.addWrapper("cantstop",self.cantstop)
        self.addWrapper("canstop",self.canstop)
        self.addWrapper("system",self.system_api.proc)
    @staticmethod
    def htc(m):
        return chr(int(m.group(1),16))
    def urldecode(self,url):
        rex=re.compile('%([0-9a-hA-H][0-9a-hA-H])',re.M)
        return rex.sub(InstApi.htc,url)
    def process(self,loc):
        prms={}
        pth=[]
        Logger.getLogger().dbg("API call "+loc)
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
        JServer.getServer().current_page=self.getParam(prms,"pg")
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
