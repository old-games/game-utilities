using System;
using System.Collections.Generic;
using System.Drawing;
using System.Windows.Forms;

namespace bassru.ResView
{
    public partial class SpritesView : BResourceControl
    {
        public static SpritesView obj = null;
        public static SpritesView get()
        {
            if (obj == null) obj = new SpritesView();
            return obj;
        }
        public SpritesView()
        {
            InitializeComponent();
        }

        public BSprites spr { get { return resource as BSprites; } }
        int curspr = 0;
        int sprs = 0;
        Bitmap bmp = null;
        public override void setObject(BResource res)
        {
            bmp = null;
            numericUpDown1.Value = 50;
            timer1.Enabled = false;
            timer1.Interval = 500;
            curspr = 0;
            base.setObject(res);
            try
            {
                sprs = spr.header.n_sprites;
                setPaletteCombo(comboBox1, spr.palette);
                label1.Text = string.Format("{0:d} sprites {1:d}x{2:d}", spr.header.n_sprites, spr.header.width, spr.header.height);
                pictureBox1.Width = spr.header.width;
                pictureBox1.Height = spr.header.height;
                bmp = new Bitmap(spr.header.width, spr.header.height);
            }
            catch (Exception ex)
            {
                MainForm.clearResource(ex);
            }
            drawSprite();
        }

        public void drawSprite()
        {
            if (bmp == null) return;
            try
            {
                label4.Text = String.Format("sprite {0:d} of {1:d}", curspr, spr.header.n_sprites);
                byte[] data = spr.frame(curspr);
                BPalette pal = getSelectedPalette(comboBox1);
                for (int i = 0; i < spr.header.height; i++)
                    for (int j = 0; j < spr.header.width; j++)
                    {
                        int idx = i * spr.header.width + j;
                        Color cl;
                        if (idx < data.Length)
                            cl = pal.getPal()[data[idx]];
                        else
                            cl = Color.Red;
                        bmp.SetPixel(j, i, cl);
                    }
            }
            catch (Exception ex)
            {
                MainForm.clearResource(ex);
            }
            pictureBox1.Refresh();
        }

        private void pictureBox1_Paint(object sender, PaintEventArgs e)
        {
            if (bmp != null)
                e.Graphics.DrawImage(bmp, 0, 0);
        }

        private void button2_Click(object sender, EventArgs e)
        {
            curspr = 0;
            drawSprite();
        }

        private void button4_Click(object sender, EventArgs e)
        {
            curspr--;
            if (curspr < 0)
                curspr = spr.header.n_sprites - 1;
            drawSprite();
        }

        private void button3_Click(object sender, EventArgs e)
        {
            curspr++;
            if (curspr >= spr.header.n_sprites)
            {
                if (timer1.Enabled)
                    button1.PerformClick();
                curspr = 0;
            }
            drawSprite();
        }

        private void timer1_Tick(object sender, EventArgs e)
        {
            button3.PerformClick();
        }

        private void button1_Click(object sender, EventArgs e)
        {
            if (button1.Text == "play")
            {
                button1.Text = "stop";
                timer1.Enabled = true;
            }
            else
            {
                button1.Text = "play";
                timer1.Enabled = false;
            }
        }

        public override void saveConfig(string comment)
        {
            Dictionary<string, string> res = makeConfig("sprites", comment);
            if (comboBox1.SelectedIndex > 0)
                res["palette"] = comboBox1.Text;
            Config.get().updateConfig(spr.filenum,res);
        }

        private void comboBox1_SelectedIndexChanged(object sender, EventArgs e)
        {
            drawSprite();
        }
    }
}
