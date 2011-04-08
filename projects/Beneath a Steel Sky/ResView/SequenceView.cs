using System;
using System.Collections.Generic;
using System.Drawing;
using System.Windows.Forms;

namespace bassru.ResView
{
    public partial class SequenceView : BResourceControl
    {
        public static SequenceView obj = null;
        public static SequenceView get()
        {
            if (obj == null) obj = new SequenceView();
            return obj;
        }
        Bitmap sbmp = null;
        Bitmap rbmp = null;
        public BSequence seq { get { return resource as BSequence; } }
        int frm = 0;
        public SequenceView()
        {
            InitializeComponent();
        }

        public override void setObject(BResource res)
        {
            base.setObject(res);
            button2.BackColor = seq.bgColor;
            timer1.Enabled = false;
            setPaletteCombo(comboBox1, seq.palette);
            label2.Text = String.Format("rep:{0:d} screens:{1:d}", seq.frameCnt, seq.screenCnt);
            numericUpDown1.Value = 50;
            timer1.Interval = 500;
            rbmp = seq.makeBitmap(seq.bgColor, getSelectedPalette(comboBox1));
            frm = 0;
            makeBitmap(true);
        }

        private void readWaitDraw(ref int pos, ref byte draw, ref byte wait,ref bool nxtdraw,bool isdraw)
        {
            if (isdraw)
            {
                draw = seq.seqdata[pos++];nxtdraw = draw == 0xFF;
            }
            else
            {
                wait = seq.seqdata[pos++];nxtdraw = wait != 0xFF;
                if (wait == 0)
                {
                    draw = seq.seqdata[pos++];nxtdraw = draw == 0xFF;
                }
            }
        }

        private void pictureBox1_Paint(object sender, PaintEventArgs e)
        {
            if (sbmp == null) return;
            e.Graphics.DrawImage(sbmp,0,0);
        }

        private void comboBox1_SelectedIndexChanged(object sender, EventArgs e)
        {
            frm = 0;
            rbmp = seq.makeBitmap(button2.BackColor, getSelectedPalette(comboBox1));
            makeBitmap(true);
        }

        private int makeBitmap(bool draw)
        {
            label3.Text = String.Format("frame {0:d} of {1:d}",frm,seq.frameCnt);
            try
            {
                
                sbmp = new Bitmap(320,BResource.GAME_SCREEN_HEIGHT);
                Graphics g = Graphics.FromImage(sbmp);
                g.DrawImage(rbmp, new Rectangle(0, 0, 320, BResource.GAME_SCREEN_HEIGHT), 0, BResource.GAME_SCREEN_HEIGHT * frm,
                    320, BResource.GAME_SCREEN_HEIGHT, GraphicsUnit.Pixel);
            }catch (Exception ex)
            {
                MainForm.clearResource(ex);
            }
            if (draw) pictureBox1.Refresh();
            return 0;
        }

        private void button4_Click(object sender, EventArgs e)
        {
            frm = 0;
            makeBitmap(true);
        }

        private void button3_Click(object sender, EventArgs e)
        {
            makeBitmap(false);
            frm++;
            if (frm >= seq.frameCnt)
            {
                if (timer1.Enabled)
                    button1.PerformClick();
                frm = 0;
            }
            makeBitmap(true);
        }

        private void numericUpDown1_ValueChanged(object sender, EventArgs e)
        {
            timer1.Interval=((101-(int)numericUpDown1.Value)*10);
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

        private void timer1_Tick(object sender, EventArgs e)
        {
            button3.PerformClick();
        }

        public override void saveConfig(string comment)
        {
            Dictionary<string, string> res = makeConfig("sequence", comment);
            if (comboBox1.SelectedIndex > 0)
                res["palette"] = comboBox1.Text;
            Color c=button2.BackColor;
            res["bg"] = c.IsKnownColor ? c.Name : "#" + c.Name;
            Config.get().updateConfig(seq.filenum,res);
        }

        private void button2_Click(object sender, EventArgs e)
        {
            ColorDialog dlg = new ColorDialog();
            dlg.Color = button2.BackColor;
            if (dlg.ShowDialog() == DialogResult.OK)
            {
                button2.BackColor = dlg.Color;
                rbmp = seq.makeBitmap(dlg.Color, getSelectedPalette(comboBox1));
            }
            button4.PerformClick();
        }
    }
}
