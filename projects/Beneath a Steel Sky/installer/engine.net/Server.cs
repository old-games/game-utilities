using System;
using System.Collections.Generic;
using System.Text;
using System.Net;
using System.Threading;
using System.IO;

namespace engine.net
{
    class Server
    {
        bool m_stop = false;
        HttpListener svr;
        public static DateTime lastcon;
        public string current_page = "http://localhost:34567/";
        bool cs=true;
        public bool canstop { get { return cs; } set { lock (this) { cs = value; } } }
        public static Server obj = null;
        public static Server getServer()
        {
            if (obj == null)
                obj = new Server();
            return obj;
        }

        public Server()
        {
            svr= new HttpListener();
            svr.Prefixes.Add("http://localhost:34567/");
        }

        ~Server()
        {
            stop();
        }

        public void process()
        {
            lock (this)
            {
                m_stop = false;
            }
            svr.Start();
            lastcon = DateTime.Now;
            while (!m_stop)
            {
                svr.BeginGetContext(new AsyncCallback(OnRequests), svr).AsyncWaitHandle.WaitOne(1000);
                double sec = (DateTime.Now - lastcon).TotalSeconds;
                if (sec > 25)
                {
                    lastcon = DateTime.Now;
                    if (canstop)
                    {
                        Logger.getLogger().dbg("Webbrowser timeout. Stopping engine");
                        InstApi.getApi().process("close");
                    }
                    else
                    {
                        Logger.getLogger().dbg("Webbrowser timeout. Restarting browser");
                        if (BrowserController.obj != null)
                        {
                            BrowserController.obj.restartBrowser(current_page);
                        }
                        else
                        {
                            Logger.getLogger().dbg("No browser controller object. Stopping server");
                            InstApi.getApi().process("close");
                        }
                    }
                }
            }
            //svr.Stop();
        }

        public void start()
        {
            svr.Start();
            Thread t = new Thread((ThreadStart)process);
            t.Start();
        }

        public void stop()
        {
            lock (this)
            {
                m_stop = true;
            }
        }

        public static void OnRequests(IAsyncResult res)
        {
            HttpListenerContext con = null;
            try
            {
                con = ((HttpListener)res.AsyncState).EndGetContext(res);
            }
            catch (Exception ex)
            {
                Logger.getLogger().dbg("SVR ERROR:" + ex.Message);
                return;
            }
            lastcon = DateTime.Now;
            String what = con.Request.RawUrl;
            if (what == "/")
                what = "/index.html";
            byte[] buffer=null;
            string tp="";
            if (what.StartsWith("/api/"))
            {
                tp="application/json";
                what = what.Remove(0, 5);
                if (what!="hb")
                {
                    buffer = InstApi.getApi().process(what);
                }else
                    buffer = Encoding.UTF8.GetBytes("{r:0}");
                con.Response.AddHeader("Cache-Control", "no-cache");
                con.Response.AddHeader("Cache-Control", "no-store");
                con.Response.AddHeader("Cache-Control", "must-revalidate");
                con.Response.AddHeader("Expires", "0");
            }
            else
            {
                what=what.Remove(0,1);
                Logger.getLogger().dbg("request " + what);
                try
                {
                    buffer = ResourceLocator.getResources().getResource(what);
                }
                catch (Exception)
                {
                    con.Response.StatusCode = 404;
                    con.Response.Close();
                    return;
                }
                string ext = Path.GetExtension(what).Remove(0,1);
                switch(ext)
                {
                    case "html":
                    case "xml":
                    case "css":
                        tp = "text/" + ext+"; charset=UTF-8";
                        break;
                    case "jpg":
                        tp="image/jpeg";
                        break;
                    case "bmp":
                    case "png":
                        tp = "image/" + ext;
                        break;
                    case "js":
                        tp = "application/javascript";
                        break;
                    case "mid":
                        tp = "audio/midi";
                        break;
                    case "wav":
                        tp = "audio/x-wav";
                        break;
                }
            }
            con.Response.ContentType = tp;
            con.Response.ContentLength64 = buffer.Length;
            con.Response.OutputStream.Write(buffer, 0, buffer.Length);
            con.Response.OutputStream.Close();
            con.Response.Close();
        }
    }
}
