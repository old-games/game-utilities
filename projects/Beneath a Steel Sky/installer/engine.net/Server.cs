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
        public string home_page = "http://localhost:34567/";
        bool cs = true;
        public bool canstop { get { 
            return cs; } 
            set { 
                lock (this) { 
                    cs = value; } } }
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
            svr.Prefixes.Add(home_page);
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
                svr.BeginGetContext(new AsyncCallback(OnRequests), svr).AsyncWaitHandle.WaitOne(3000);
                double sec = (DateTime.Now - lastcon).TotalSeconds;
                if (sec > 5)
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
                            BrowserController.obj.restartBrowser();
                        }
#if !NO_EXPLORER
                        else if (Form1.obj==null)
                        {
                            Logger.getLogger().dbg("No browser controller object. Stopping server");
                            InstApi.getApi().process("close");
                        }
#endif
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
                con.Response.AddHeader("Expires","Mon, 26 Jul 1997 05:00:00 GMT");
                con.Response.AddHeader("Cache-Control", "no-store, no-cache, must-revalidate");
                //con.Response.AddHeader("Expires", "-1");
                con.Response.AddHeader("Pragma", "no-cache");
            }
            else
            {
                what=what.Split('?')[0].Remove(0,1);
                Logger.getLogger().dbg("request " + what);
                try
                {
                    buffer = ResourceLocator.getResources().getResource(what);
                }
                catch (Exception)
                {
                    try
                    {
                        con.Response.StatusCode = 404;
                        con.Response.Close();
                    }
                    catch (Exception)
                    {
                    }
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
                        tp = "application/javascript; charset=UTF-8";
                        break;
                    case "mid":
                        tp = "audio/midi";
                        break;
                    case "wav":
                        tp = "audio/x-wav";
                        break;
                }
            }
            try
            {
                con.Response.ContentType = tp;
                con.Response.ContentLength64 = buffer.Length;
                con.Response.OutputStream.Write(buffer, 0, buffer.Length);
                con.Response.OutputStream.Close();
                con.Response.Close();
            }
            catch (Exception)
            {
                try
                {
                    con.Response.Close();
                }
                catch (Exception)
                {
                }
            }
        }
    }
}
