using System;
using System.Collections.Generic;
using System.Text;
using System.Diagnostics;
using System.Windows.Forms;
using System.Threading;
using System.Runtime.InteropServices;

namespace engine.net
{
    class ForegroundWindow : IWin32Window
    {
        [DllImport("user32.dll")]
        public static extern IntPtr GetForegroundWindow();
        static ForegroundWindow obj = null;
        public static ForegroundWindow CurrentWindow { get { if (obj == null) obj = new ForegroundWindow(); return obj; } }
        public IntPtr Handle
        {
            get { return GetForegroundWindow(); }
        }
    }

    class BrowserController : ApplicationContext
    {
        public static BrowserController obj = null;
        readonly WindowsFormsSynchronizationContext sc;
        Form c = new Form();
        FolderBrowserDialog fd;
        public BrowserController()
        {
            obj = this;
            sc = new WindowsFormsSynchronizationContext();
            fd = new FolderBrowserDialog();
            startBrowser(Server.getServer().current_page);
        }

        void Invoke(SendOrPostCallback d, object state, bool sync)
        {
            if (sync)
                sc.Send(d,state);
            else
                sc.Post(d, state);
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

        public void rstop(object state)
        {
            ExitThread();
        }
        public void stopBrowser()
        {
            Invoke(new SendOrPostCallback(rstop),null,false);
        }

        public void rstart(object state)
        {
            startBrowser(Server.getServer().current_page);
        }
        public void restartBrowser()
        {
            Invoke(new SendOrPostCallback(rstart),null,false);
        }

        public void rGetFld(object state)
        {
            List<string> s=(List<string>)state;
            if (fd.ShowDialog(ForegroundWindow.CurrentWindow) == DialogResult.OK)
                s.Add(fd.SelectedPath);
            s.Add("");
        }
        public string getFld()
        {
            List<string> val=new List<string>();
            Invoke(new SendOrPostCallback(rGetFld),val,true);
            return val[0];
        }
    }
}
