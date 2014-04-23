using System;
using System.Drawing;
using System.Windows.Forms;

namespace RBView
{
    public partial class PalView : Form
    {
        Palette pal = null;
        public PalView()
        {
            InitializeComponent();
        }

        public PalView(byte[] data, string name):this()
        {
            Text = "Palette " + name;
            this.pal = Palettes.get().getPalette(name);
            pictureBox1.Update();
        }

        private void pictureBox1_Paint(object sender, PaintEventArgs e)
        {
            if (pal == null)
                return;
            for (int i=0;i<256;i++)
            {
                Rectangle rect=new Rectangle((i%16)*16,(i/16)*16,16,16);
                e.Graphics.FillRectangle(new SolidBrush(pal.cls[i]), rect);
            }
        }

        private void button1_Click(object sender, EventArgs e)
        {
            Close();
        }
    }
}
