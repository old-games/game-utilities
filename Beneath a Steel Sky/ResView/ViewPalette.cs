using System;
using System.Collections.Generic;
using System.Drawing;
using System.Windows.Forms;

namespace bassru.ResView
{
    public partial class ViewPalette : BResourceControl
    {
        public BPalette pal { get { return resource as BPalette; } }
        public static ViewPalette obj = null;
        public static ViewPalette  get()
        {
            if (obj == null) obj = new ViewPalette();
            return obj;
        }

        public ViewPalette()
        {
            InitializeComponent();
        }


        public override void setObject(BResource res)
        {
            base.setObject(res);
            textBox1.Text = pal.name;
            pictureBox1.Refresh();
        }

        private void checkBox1_CheckedChanged(object sender, EventArgs e)
        {
            pictureBox1.Refresh();
        }

        private void pictureBox1_Paint(object sender, PaintEventArgs e)
        {
            Color[] cols = null;
            try
            {
                if (pal != null)
                    cols = pal.getPal(checkBox1.Checked, checkBox2.Checked, checkBox3.Checked);
                e.Graphics.FillRectangle(new SolidBrush(Color.Black), e.ClipRectangle);
                int minrect = e.ClipRectangle.Width / 16;
                if (e.ClipRectangle.Height / 16 < minrect)
                    minrect = e.ClipRectangle.Height / 16;
                Rectangle rct = new Rectangle(0, 0, minrect, minrect);
                for (int i = 0; i < 16; i++)
                {
                    for (int j = 0; j < 16; j++)
                    {
                        Color c = pal == null ? Color.Black : cols[i * 16 + j];
                        e.Graphics.FillRectangle(new SolidBrush(c), rct);
                        rct.Offset(minrect, 0);
                    }
                    rct.Offset(-rct.X, minrect);
                }
            }
            catch (Exception ex)
            {
                MainForm.clearResource(ex);
            }
        }

        public override void saveConfig(string comment)
        {
            Dictionary<string, string> prms = makeConfig("palette", comment);
            if (textBox1.Text != "")
                prms["name"] = textBox1.Text;
            Config.get().updateConfig(pal.filenum, prms);
        }
    }
}
