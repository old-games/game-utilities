#if !NO_EXPLORER
using System.Windows.Forms;
using System;
using System.IO;

namespace engine.net
{
    public partial class Form1 : Form
    {
        public static Form1 obj = null;
        public delegate void stopBro();
        FolderBrowserDialog fd = new FolderBrowserDialog();
        public Form1(int w, int h, bool mx, bool sz, string nm)
        {
            InitializeComponent();
            try
            {
                byte[] ic = ResourceLocator.getResources().getResource("favicon.ico");
                MemoryStream ms=new MemoryStream(ic);
                this.Icon = new System.Drawing.Icon(ms);
                ms.Close();
            }
            catch (Exception)
            {
                this.Icon = System.Drawing.Icon.ExtractAssociatedIcon(Application.ExecutablePath);
            }
            Text = nm;
            if (!sz)
            {
                FormBorderStyle = FormBorderStyle.FixedSingle;
                MaximizeBox = false;
            }
            if (mx)
                WindowState = FormWindowState.Maximized;
            else
            {
                Width = w;
                Height = h;
            }
            webBrowser1.Navigate("http://localhost:34567/");
            obj = this;
        }

        public void stopBrowser()
        {
            if (obj.InvokeRequired)
            {
                stopBro d=new stopBro(stopBrowser);
                obj.Invoke(d,null);
            }
            else
                Close();
        }

        delegate string SelDlg();
        public string getFld()
        {
            if (obj.InvokeRequired)
            {
                SelDlg d = new SelDlg(getFld);
                return (string)obj.Invoke(d,null);
            }
            else
            {
                if (fd.ShowDialog() == DialogResult.OK)
                    return fd.SelectedPath;
                return "";
            }
        }

        private void Form1_FormClosing(object sender, FormClosingEventArgs e)
        {
            e.Cancel = !Server.getServer().canstop;
        }

    }
}
#endif