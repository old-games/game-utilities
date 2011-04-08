using System.Windows.Forms;
using System.IO;
using System;
using System.Collections.Generic;
using System.Drawing;

namespace AlleyCatFont
{
    public partial class Form1 : Form
    {
        string catfile = "";
        const string EXE_FILTER = "exe file (*.exe)|*.exe";
        const string XML_FILTER = "Xml files (*.xml)|*.xml";
        const string BMP_FILTER = "Bitmap file (*.bmp)|*.bmp";
        Config conf = new Config();
        
        public Form1()
        {
            InitializeComponent();
        }

        public void setInt16(byte[] data, int ofs, Int16 val)
        {
            data[ofs] = (byte)(val & 0xFF);
            data[ofs+1] = (byte)((val>>8) & 0xFF);
        }

        byte[] getRUles(UInt16 ofs)
        {
            List<byte> data = new List<byte>();
            int lofs = ofs + conf.rules.Count * 4 + 2;
            foreach (Config.Rule r in conf.rules)
            {
                Int16 ltr=(Int16)r.letter;
                if (ltr < 0x2720)
                    ltr = (Int16)(lofs + ltr * 16);
                data.Add((byte)(ltr&0xFF));
                data.Add((byte)((ltr>>8)&0xFF));
                ltr=r.getAddress();
                data.Add((byte)(ltr&0xFF));
                data.Add((byte)((ltr>>8)&0xFF));
            }
            data.Add(0xFF);
            data.Add(0xFF);
            foreach (UInt16[] fdata in conf.myLetters.letters)
                foreach (UInt16 u in fdata)
                {
                    data.Add((byte)((u >> 8) & 0xFF));
                    data.Add((byte)(u & 0xFF));
                }
            return data.ToArray();
        }

        public void inject(string fname)
        {
            Int16 ofs = 0x7430;
            Int16 myOfs = 0x62EB;
            //Int16 fofs = 0x1B;
            //Int16[] replaces = new Int16[] { 0x27DF };//0x26d6,0x2763
            FileStream fs = new FileStream(catfile, FileMode.Open);
            byte[] data = new byte[fs.Length];
            fs.Read(data, 0, data.Length);
            fs.Close();
            byte[] icod = InjectCode.getCode();
            byte[] rules = getRUles((UInt16)(0x62EB+icod.Length));
            Int16 addpar = (Int16)((icod.Length+rules.Length) / 512 + 1);
            byte[] ndata = new byte[data.Length + addpar * 512];
            Array.Copy(data, ndata, data.Length);
            addpar += 0x6C;
            setInt16(ndata, 4, addpar);

            byte[] xres = InjectCode.getRUnCOde();
            setInt16(xres, 1, (Int16)((myOfs+1) - 0x2B30));

            Array.Copy(xres, 0, ndata, 0x2B30+ofs, xres.Length);

            //foreach (Int16 i in replaces)
            //    setInt16(ndata, ofs + i + 1, (Int16)((myOfs + 1) - i));

            //Int16 xofs = (Int16)(0x2D9D - (myOfs + fofs+1));
            //setInt16(icod, fofs, xofs);
            Array.Copy(icod, 0, ndata, data.Length, icod.Length);
            Array.Copy(rules, 0, ndata, data.Length+icod.Length, rules.Length);
            fs = new FileStream(fname, FileMode.Create);
            fs.Write(ndata, 0, ndata.Length);
            fs.Close();
        }

        private void button3_Click(object sender, System.EventArgs e)
        {
            OpenFileDialog ofd = new OpenFileDialog();
            ofd.Filter = EXE_FILTER;
            if (ofd.ShowDialog() == DialogResult.OK)
            {
                textBox1.Text = ofd.FileName;
                catfile = textBox1.Text;
                process();
            }
        }

        void process()
        {
            conf.theirLetters.letters.Clear();
            conf.theirLetters.images.Clear();
            FileStream fs = new FileStream(catfile, FileMode.Open);
            fs.Position = 0x2A20;
            byte[] dt = new byte[16];
            for (int i = 0; i < 24; i++)
            {
                fs.Read(dt, 0, 16);
                conf.theirLetters.AddLetter(dt);
            }
            fs.Close();
            reread();
        }

        void reread()
        {
            comboBox1.Items.Clear();
            listView1.Items.Clear();
            listView1.SmallImageList.Images.Clear();
            foreach (Bitmap bmp in conf.theirLetters.images)
                comboBox1.Items.Add(bmp);
            foreach (Bitmap bmp in conf.myLetters.images)
            {
                comboBox1.Items.Add(bmp);
                listView1.SmallImageList.Images.Add(bmp);
                ListViewItem li=listView1.Items.Add("", listView1.SmallImageList.Images.Count - 1);
                li.Tag = bmp;
            }
            listView2.Clear();
            listView2.SmallImageList.Images.Clear();
            foreach (Config.Rule r in conf.rules)
            {
                listView2.SmallImageList.Images.Add(conf.imageForLetter(r.letter));
                ListViewItem li=listView2.Items.Add(String.Format("({0:d},{1:d})", r.x, r.y),
                    listView2.SmallImageList.Images.Count-1);
                li.Tag = r;
            }
            textBox2.Text = textBox3.Text = "";
            button8.Text = "Add";
        }

        private void button5_Click(object sender, System.EventArgs e)
        {
            SaveFileDialog sfd = new SaveFileDialog();
            sfd.Filter = EXE_FILTER;
            if (sfd.ShowDialog() == DialogResult.OK)
            {
                inject(sfd.FileName);
            }
        }

        private void button8_Click(object sender, EventArgs e)
        {
            try
            {
                if (textBox2.Text == "") throw new Exception("Input x");
                if (textBox3.Text == "") throw new Exception("Input y");
                int x = int.Parse(textBox2.Text);
                x = x / 4 * 4;
                int y = int.Parse(textBox3.Text);
                if (listView2.SelectedItems.Count == 1)
                {
                    Config.Rule r = (Config.Rule)listView2.SelectedItems[0].Tag;
                    r.x = x;
                    r.y = y;
                    reread();
                    return;
                }
                if (comboBox1.SelectedIndex < 0) throw new Exception("Select letter");
                int letter = conf.letterByImage((Bitmap)comboBox1.Items[comboBox1.SelectedIndex]);
                conf.rules.Add(new Config.Rule(x,y,letter));
                reread();
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
        }

        private void button2_Click(object sender, EventArgs e)
        {
            SaveFileDialog dlg = new SaveFileDialog();
            dlg.Filter = XML_FILTER;
            if (dlg.ShowDialog()==DialogResult.OK)
            {
                try
                {
                    conf.save(dlg.FileName,catfile);
                }
                catch (Exception ex)
                {
                    MessageBox.Show(ex.Message);
                }
            }
        }

        private void button1_Click(object sender, EventArgs e)
        {
            OpenFileDialog dlg = new OpenFileDialog();
            dlg.Filter = XML_FILTER;
            if (dlg.ShowDialog() == DialogResult.OK)
            {
                try
                {
                    catfile=conf.load(dlg.FileName);
                    textBox1.Text = catfile;
                    process();
                }
                catch (Exception ex)
                {
                    MessageBox.Show(ex.Message);
                }
            }
        }

        private void button6_Click(object sender, EventArgs e)
        {
            OpenFileDialog ofd = new OpenFileDialog();
            ofd.Filter = BMP_FILTER;
            if (ofd.ShowDialog() == DialogResult.OK)
            {
                try{
                    Bitmap bmp = new Bitmap(ofd.FileName);
                    conf.myLetters.AddLetter(bmp);
                    reread();
                    bmp.Dispose();
                }catch(Exception ex)
                {
                    MessageBox.Show(ex.Message);
                }
            }
        }

        private void button7_Click(object sender, EventArgs e)
        {
            foreach(ListViewItem it in listView1.SelectedItems)
                conf.removeLetter((Bitmap)it.Tag);
            reread();
        }

        private void button4_Click(object sender, EventArgs e)
        {
            foreach (ListViewItem li in listView2.SelectedItems)
                conf.rules.Remove((Config.Rule)li.Tag);
            reread();
        }

        private void comboBox1_DrawItem(object sender, DrawItemEventArgs e)
        {
            e.Graphics.FillRectangle(new SolidBrush(e.BackColor),e.Bounds);
            if (e.Index == -1)
                return;
            e.Graphics.DrawImage((Bitmap)comboBox1.Items[e.Index],e.Bounds.Left,e.Bounds.Top);
        }

        private void listView2_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (listView2.SelectedItems.Count == 1)
            {
                comboBox1.Enabled=false;
                Config.Rule r = (Config.Rule)listView2.SelectedItems[0].Tag;
                textBox2.Text=r.x.ToString();
                textBox3.Text=r.y.ToString();
                button8.Text = "Apply";
            }
            else
            {
                comboBox1.Enabled=true;
                textBox2.Text=textBox3.Text="";
                button8.Text="Add";
            }
        }
    }
}
