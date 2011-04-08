using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.Windows.Forms;

namespace bassru
{
    public partial class ScriptProgressForm : Form
    {
        public static ScriptProgressForm obj = null;
        public static ScriptProgressForm get()
        {
            if (obj == null) obj = new ScriptProgressForm();
            return obj;
        }

        public ScriptProgressForm()
        {
            InitializeComponent();
        }

        public void init(int max)
        {
            label1.Text = "";
            progressBar1.Value = 0;
            progressBar1.Maximum=max;
            Show();
            BringToFront();
        }

        public void fini()
        {
            Hide();
        }

        public void progress(string what)
        {
            label1.Text=what;
            label1.Refresh();
            progressBar1.Value++;
        }
    }
}
