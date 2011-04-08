using System;
using System.Collections.Generic;
using System.IO;
using System.Windows.Forms;
using System.Drawing;

namespace CrusFont
{
    public partial class Form1 : Form
    {
        List<Section> sex = new List<Section>();
        byte[] header;
        Int16 cnt=0;
        public Form1()
        {
            InitializeComponent();
        }

        private void button1_Click(object sender, EventArgs e)
        {
            if (ofd.ShowDialog() == DialogResult.OK)
            {
                label1.Text = ofd.FileName;
                process();
            }
        }

        void process()
        {
            listView1.Items.Clear();
            sex.Clear();
            string fn = label1.Text;
            BinaryReader rd = new BinaryReader(new FileStream(fn, FileMode.Open));
            header = rd.ReadBytes(0x80);
            rd.BaseStream.Position = 0x55;
            cnt = rd.ReadInt16();
            rd.BaseStream.Position = 0x80;
            List<int> ofs = new List<int>();
            for (int i = 0; i < cnt * 256; i++)
            {
                int o = rd.ReadInt32();
                int sz = rd.ReadInt32();
                if (o != 0)
                {
                    sex.Add(new Section(rd, o, sz, i));
                }
            }
            rd.Close();
            foreach (Section s in sex)
            {
                ListViewItem li = listView1.Items.Add(s.id.ToString("X"));
                li.SubItems.Add(String.Format("{0:d}", s.cWidth));
                li.SubItems.Add(String.Format("{0:d}", s.cHeight));
                li.SubItems.Add(String.Format("{0:d}", s.files.Count));
                li.Tag = s;
            }
        }

        private void listView1_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (listView1.SelectedItems.Count != 1)
                return;
            Section s = listView1.SelectedItems[0].Tag as Section;
            button2.Enabled = button3.Enabled = false;
            try
            {
                pictureBox1.Image = s.image();
                button2.Enabled = button3.Enabled = true;
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
        }

        private void button2_Click(object sender, EventArgs e)
        {
            if (listView1.SelectedItems.Count != 1)
                return;
            Section s = listView1.SelectedItems[0].Tag as Section;
            SaveFileDialog sd = new SaveFileDialog();
            sd.Filter = "Bitmap file (*.bmp)|*.bmp";
            sd.FilterIndex = 0;
            sd.DefaultExt = ".bmp";
            sd.AddExtension = true;
            if (sd.ShowDialog() == DialogResult.OK)
            {
                s.image().Save(sd.FileName, System.Drawing.Imaging.ImageFormat.Bmp);
            }
        }

        private void button3_Click(object sender, EventArgs e)
        {
            if (listView1.SelectedItems.Count != 1)
                return;
            OpenFileDialog od = new OpenFileDialog();
            od.Filter = "Bitmap file (*.bmp)|*.bmp";
            od.FilterIndex = 0;
            if (od.ShowDialog() == DialogResult.OK)
            {
                Section s = listView1.SelectedItems[0].Tag as Section;
                try
                {
                    Bitmap bmp = new Bitmap(od.FileName);
                    s.import(bmp);
                    bmp.Dispose();
                    pictureBox1.Image = s.image();
                    listView1.SelectedItems[0].SubItems[3].Text = s.cnt.ToString();
                    button4.Enabled = true;
                }
                catch (Exception ex)
                {
                    MessageBox.Show(ex.Message);
                }
            }
        }

        private void button4_Click(object sender, EventArgs e)
        {
            SaveFileDialog sd = new SaveFileDialog();
            sd.Filter = "FlexFile (*.flx)|*.flx";
            sd.FilterIndex = 0;
            sd.DefaultExt = ".flx";
            sd.AddExtension = true;
            if (sd.ShowDialog() == DialogResult.OK)
            {
                BinaryWriter wr = new BinaryWriter(new FileStream(sd.FileName, FileMode.Create));
                wr.Write(header);
                for (int i = 0; i < cnt * 256; i++)
                {
                    wr.Write((int)0);
                    wr.Write((int)0);
                }
                foreach (Section s in sex)
                {
                    int ofs = (int)wr.BaseStream.Position;
                    int sz = s.data.Length;
                    wr.BaseStream.Position = 0x80 + 8 * s.id;
                    wr.Write(ofs);
                    wr.Write(sz);
                    wr.BaseStream.Position = ofs;
                    wr.Write(s.data);
                }
                wr.Close();
            }
        }

    }

}
