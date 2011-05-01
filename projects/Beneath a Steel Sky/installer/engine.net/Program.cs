using System;
using System.Windows.Forms;
using System.Xml;

namespace engine.net
{
    static class Program
    {
        /// <summary>
        /// Главная точка входа для приложения.
        /// </summary>
        [STAThread]
        static void Main()
        {
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);
            bool window = false;
            int w = 0;
            int h = 0;
            bool mx=false;
            bool sz=false;
            string nm="installer";
            bool dbg=false;
            bool con = false;
            bool log = false;
            try{
                ResourceLocator.locateReader();
                XmlDocument doc = ResourceLocator.readXmlResource("install.cfg", "icfg");
                XmlNode root = doc.DocumentElement;
                nm = root.Attributes["nm"].Value;
                window=(root.Attributes["w"]!=null);
                if (window)
                {
                    string ws = root.Attributes["w"].Value;
                    if (ws == "mx")
                        mx = true;
                    else
                    {
                        w = int.Parse(ws);
                        h = int.Parse(root.Attributes["h"].Value);
                    }
                    sz = (root.Attributes["sz"] != null);
                }
                if (root.Attributes["l"] != null)
                {
                    int lgs = int.Parse(root.Attributes["l"].Value);
                    dbg = (lgs & 1) != 0;
                    con = (lgs & 2) != 0;
                    log = (lgs & 4) != 0;
                }
                Logger.getLogger().setOptions(log, con, dbg);
            }catch(Exception ex)
            {
                MessageBox.Show("ERROR:"+ex.GetType().Name+"\r\n"+ex.Message);
                return;
            }
            Logger.getLogger().dbg("config loaded 4 app "+nm);
            Logger.getLogger().dbg("starting server");
            Server.getServer().start();
            if (window)
            {
                Application.Run(new Form1(w, h, mx, sz, nm));
            }
            else
                Application.Run(new BrowserController());
            Logger.getLogger().dbg("stopping server");
            Server.getServer().stop();
            Logger.getLogger().free();
        }
    }
}
