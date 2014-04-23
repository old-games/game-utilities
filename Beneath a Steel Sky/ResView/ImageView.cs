using System;
using System.Collections.Generic;
using System.Drawing;
using System.Windows.Forms;

namespace bassru.ResView
{
    public partial class ImageView : BResourceControl
    {
        public static ImageView obj=null;
        public static ImageView get()
        {
            if (obj == null) obj = new ImageView();
            return obj;
        }

        public BImage img { get { return resource as BImage; } }
        bool auto = false;
        public ImageView()
        {
            InitializeComponent();
        }

        public override void setObject(BResource res)
        {
            base.setObject(res);
            auto = true;
            int w = img.width;
            int h = img.height;
            /*
            if (img.imgMode != 0)
            {
                w *= 16;
                h *= 8;
            }
             * */
            numericUpDown1.Value = w;
            numericUpDown2.Value = h;
            checkBox1.Checked = (img.imgMode&1) != 0;
            checkBox2.Checked = (img.imgMode & 2) != 0;
            setPaletteCombo(comboBox1, img.palette);
            auto = false;
            repaint();
        }

        private void numericUpDown1_ValueChanged(object sender, EventArgs e)
        {
            if (auto)
                return;
            repaint();
        }

        private void repaint()
        {
            try
            {
                Bitmap bmp=img.getBmp((int)numericUpDown1.Value, (int)numericUpDown2.Value, 
                    getSelectedPalette(comboBox1), (checkBox1.Checked ? 1 : 0)+(checkBox2.Checked?2:0));

                pictureBox1.Image = bmp;
                pictureBox1.Width = bmp.Width;
                pictureBox1.Height = bmp.Height;
            }
            catch (Exception ex)
            {
                MainForm.clearResource(ex);
            }
        }

        public override void saveConfig(string comment)
        {
            Dictionary<string, string> prms = makeConfig("image", comment);
            prms["width"] = numericUpDown1.Value.ToString();
            prms["height"] = numericUpDown2.Value.ToString();
            if (comboBox1.SelectedIndex >0)
                prms["palette"] = comboBox1.Text;
            if (checkBox1.Checked)
                prms["imgmode"] = "16x8";
            Config.get().updateConfig(img.filenum, prms);
        }

        private void checkBox1_CheckedChanged(object sender, EventArgs e)
        {
            if (auto)
                return;
            auto = true;
            if (checkBox1.Checked)
            {
                numericUpDown1.Value = (int)(numericUpDown1.Value/16);
                numericUpDown2.Value = (int)(numericUpDown2.Value/8);
            }
            else
            {
                numericUpDown1.Value *= 16;
                numericUpDown2.Value *= 8;
            }
            auto = false;
            repaint();
        }

    }
}
