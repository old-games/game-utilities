using System;
using System.Collections.Generic;
using System.Drawing;
using System.Windows.Forms;

namespace bassru.ResView
{
    public partial class CharsetView : BResourceControl
    {
        public static CharsetView obj = null;
        public static CharsetView get()
        {
            if (obj == null)
                obj = new CharsetView();
            return obj;
        }

        public CharsetView()
        {
            InitializeComponent();
        }

        BCharset cs { get { return resource as BCharset; } }
        bool auto = false;
        public override void setObject(BResource res)
        {
            base.setObject(res);
            auto = true;
            numericUpDown1.Value = cs.height;
            auto = false;
            pictureBox1.Refresh();
        }

        public override void saveConfig(string comment)
        {
            Dictionary<string, string> res = makeConfig("charset", comment);
            res["height"] = numericUpDown1.Value.ToString();
            Config.get().updateConfig(cs.filenum, res);
        }

        private void button1_Click(object sender, EventArgs e)
        {
            colorDialog1.Color = button1.ForeColor;
            if (colorDialog1.ShowDialog() == DialogResult.OK)
            {
                button1.ForeColor = button2.ForeColor = button3.ForeColor=colorDialog1.Color;
                pictureBox1.Refresh();
            }
        }

        private void button2_Click(object sender, EventArgs e)
        {
            colorDialog1.Color = button2.BackColor;
            if (colorDialog1.ShowDialog() == DialogResult.OK)
            {
                button1.BackColor = button2.BackColor = colorDialog1.Color;
                pictureBox1.Refresh();
            }
        }

        private void pictureBox1_Paint(object sender, PaintEventArgs e)
        {
            if (auto) return;
            auto = true;
            try
            {
                cs.height = (int)numericUpDown1.Value;
                Bitmap bmp = cs.makeBitmap(checkBox1.Checked, button1.BackColor, button1.ForeColor, button3.BackColor);
                pictureBox1.Width = bmp.Width;
                pictureBox1.Height = bmp.Height;
                e.Graphics.DrawImage(bmp, 0, 0);
            }
            catch (Exception ex)
            {
                MainForm.clearResource(ex);
            }
            auto = false;
        }

        private void checkBox1_CheckedChanged(object sender, EventArgs e)
        {
            pictureBox1.Refresh();
        }

        private void button3_Click(object sender, EventArgs e)
        {
            colorDialog1.Color = button3.BackColor;
            if (colorDialog1.ShowDialog() == DialogResult.OK)
            {
                button3.BackColor = colorDialog1.Color;
                pictureBox1.Refresh();
            }
        }


    }
}
