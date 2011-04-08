using System;
using System.Drawing;
using System.Windows.Forms;

namespace Vlure
{
    public partial class ImgForm : Form
    {
        LureImage img = null;
        public ImgForm()
        {
            InitializeComponent();
        }

        public ImgForm(int fileid, int w, int h,string pal,string name)
        {
            InitializeComponent();
            if (pal == "")
                pal = "GRAYSCALE";
            if (name == "")
                name = "image" + fileid.ToString();
            for (int i = 0; i < LureConfig.get().palettes.Count; i++)
                cb_pal.Items.Add(LureConfig.get().palettes[i].name);
            nud_w.Value = w;
            nud_h.Value = h;
            if (pal != "")
                cb_pal.SelectedItem = pal;
            textBox1.Text = name;
                //cb_pal.SelectedText = pal;
            img = new LureImage(fileid, w, h, pal);
            //nud_w_ValueChanged(null, null);
        }

        private void pictureBox1_Paint(object sender, PaintEventArgs e)
        {
            try
            {
                l_err.Text = "";
                pictureBox1.Image=img.export((int)nud_w.Value, (int)nud_h.Value, cb_pal.Text);
                if (img.unused != 0)
                    l_err.Text = img.unused.ToString() + " left bytes";
            }
            catch (Exception ex)
            {
                l_err.Text = ex.Message;
            }

        }

        private void nud_w_ValueChanged(object sender, EventArgs e)
        {
            if (img == null)
                return;
            pictureBox1.Update();
        }

        private void ImgForm_Load(object sender, EventArgs e)
        {
            nud_w_ValueChanged(null, null);
        }

        private void button1_Click(object sender, EventArgs e)
        {
            LureConfig.get().saveImage(img.resnum, (int)nud_w.Value, (int)nud_h.Value, cb_pal.Text,textBox1.Text);
            Close();
        }

    }
}
