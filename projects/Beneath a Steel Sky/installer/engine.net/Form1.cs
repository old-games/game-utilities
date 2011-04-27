using System.Windows.Forms;

namespace engine.net
{
    public partial class Form1 : Form
    {
        public static Form1 obj = null;
        public delegate void stopBro();
        public Form1(int w,int h,bool mx,bool sz,string nm)
        {
            InitializeComponent();
            this.Icon = System.Drawing.Icon.ExtractAssociatedIcon(Application.ExecutablePath);
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
    }
}
