using System;
using System.Collections.Generic;
using System.Text;
using System.Diagnostics;
using System.Windows.Forms;

namespace engine.net
{
    class BrowserController
    {
        public static BrowserController obj = null;
        bool m_stop = false;
        public BrowserController()
        {
            obj = this;
        }

        void startBrowser(string page)
        {
            try
            {
                ProcessStartInfo pi = new ProcessStartInfo();
                pi.FileName = page;
                Process.Start(pi);
            }
            catch (Exception) { }
        }

        public void stopBrowser()
        {
            lock (this)
            {
                m_stop = true;
            }
        }

        public void restartBrowser(string page)
        {
            startBrowser(page);
        }

        public void mainLoop()
        {
            startBrowser("http://localhost:34567/");
            while (!m_stop)
            {
                Application.DoEvents();
            }
        }
    }
}
