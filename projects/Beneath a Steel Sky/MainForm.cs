using System;
using System.Windows.Forms;
using System.IO;
using System.Xml;

namespace bassru
{
    public partial class MainForm : Form
    {
        string path = "D:\\Games\\ScummVM\\bass-cd-1.22\\";
        ResView.BResourceControl cntrl=null;
        LISorter srt;
        public static MainForm me=null;
        public MainForm()
        {
            InitializeComponent();
            me = this;
            srt = new LISorter(listView1);

        }

        public void clearRes()
        {
            panel1.Controls.Clear();
            cntrl = null;
            textBox2.Text = "";
            label2.Text = "";
        }

        public static void clearResource(Exception ex)
        {
            me.clearRes();
            MessageBox.Show("Error reading resource.\n"+ex.GetType().Name+":\n"+ex.Message);
        }

        public void load()
        {
            listView1.ListViewItemSorter = null;
            listView1.Items.Clear();
            srt.clear();
            foreach (SkyDisk.DinnerEntry e in SkyDisk.get().dinners)
            {
                ListViewItem li = listView1.Items.Add(e.id.ToString());
                li.SubItems.Add(String.Format("{0:X}", e.offset));
                li.SubItems.Add(String.Format("{0:X}", e.size));
                //li.SubItems.Add(String.Format("{0:X}", e.flags));
                li.SubItems.Add(String.Format("{0:s}", e.compressed ? "yes" : "no"));
                li.SubItems.Add(String.Format("{0:s}", e.header ? "yes" : "no"));
                Config.FileInfo fi = Config.get().findFile(e.id);
                li.SubItems.Add(fi.type);
                li.SubItems.Add(fi.comment);
            }
            listView1.AutoResizeColumns(ColumnHeaderAutoResizeStyle.ColumnContent);
            listView1.ListViewItemSorter = srt;
        }

        private void button1_Click(object sender, EventArgs e)
        {
            while (!File.Exists(path+"sky.dsk") || !File.Exists(path+"sky.dnr"))
            {
                openFileDialog1.Filter = "Sky disk file (*.dsk)|*.dsk";
                openFileDialog1.FilterIndex = 1;
                openFileDialog1.FileName = "";
                if (openFileDialog1.ShowDialog() == DialogResult.Cancel)
                    return;
                path = Path.GetDirectoryName(openFileDialog1.FileName) + "\\";
            }
            SkyDisk.get().path = path;
            SkyDisk.get().readDinner();
            load();
            button2.Enabled = button6.Enabled = button7.Enabled = button8.Enabled = true;
        }

        private void listView1_SelectedIndexChanged(object sender, EventArgs e)
        {
            textBox1.Text = "";
            if (listView1.SelectedItems.Count != 1) return;
            uint fnum = uint.Parse(listView1.SelectedItems[0].SubItems[0].Text);
            SkyDisk.FileHeader fh = SkyDisk.get().readHeader(fnum);
            String s = String.Format(@"flags=0x{0:X}
x={1:d} (0x{1:X})
y={2:d} (0x{2:X})
width={3:d} (0x{3:X})
height={4:d} (0x{4:X})
sp_size=0x{5:X}
tot_size=0x{6:X}
n_sprites={7:d} (0x{7:X})
offset_x={8:d} (0x{8:X})
offset_y={9:d} (0x{9:X})
compressed_size=0x{10:X}
-------
total_size=0x{11:X}
flags_byte=0x{12:X}
"
                , fh.flags,fh.x,fh.y,fh.width,fh.height,fh.sp_size,fh.tot_size,
                fh.n_sprites,fh.offset_x,fh.offset_y,fh.compressed_size,fh.totalsize,fh.flagbyte
                );
            textBox1.Text = s;
            clearRes();
            Config.FileInfo fi = Config.get().findFile(fnum);
            if (fi.fid != 0)
            {
                BResource res = BResourceHelper.getResource(fi.node);
                if (res.control != null)
                {
                    cntrl = res.control;
                    panel1.Controls.Add(cntrl);
                    res.initControl();
                }
                textBox2.Text = fi.comment;
                label2.Text = String.Format("{0:d} unused bytes",res.unusedBytes);
            }

        }

        private void button2_Click(object sender, EventArgs e)
        {
            if (listView1.SelectedItems.Count != 1) return;
            saveFileDialog1.Filter = "Binary file(*.bin)|*.bin|All Files(*.*)|*.*";
            saveFileDialog1.FilterIndex = 0;
            if (saveFileDialog1.ShowDialog() == DialogResult.OK)
            {
                int file=int.Parse(listView1.SelectedItems[0].SubItems[0].Text);
                SkyDisk.get().saveFile(file, false, saveFileDialog1.FileName);
            }
        }

        private void button3_Click(object sender, EventArgs e)
        {
            if (listView1.SelectedItems.Count != 1) return;
            if (cntrl != null)
                cntrl.saveConfig(textBox2.Text);
            uint fid = uint.Parse(listView1.SelectedItems[0].SubItems[0].Text);
            Config.FileInfo fi = Config.get().findFile(fid);
            listView1.SelectedItems[0].SubItems[5].Text = fi.type;
            listView1.SelectedItems[0].SubItems[6].Text = fi.comment;
            ListViewItem li=listView1.SelectedItems[0];
            li.Selected = false;
            li.Selected = true;
        }

        private void paletteToolStripMenuItem_Click(object sender, EventArgs e)
        {
            if (listView1.SelectedItems.Count!=1) return;
            uint fid = uint.Parse(listView1.SelectedItems[0].SubItems[0].Text);
            String men = (sender as ToolStripMenuItem).Text;
            BResource bres = null;
            try
            {
                switch (men)
                {
                    case "Palette": bres = new BPalette(fid, ""); break;
                    case "Image": bres = new BImage(fid, 320, 200, "",0); break;
                    case "Sequence": bres = new BSequence(fid, "", "aqua"); break;
                    case "Sprites": bres = new BSprites(fid, ""); break;
                    case "Charset": bres = new BCharset(fid, 8, 0); break;
                    case "Text": bres = new BText(fid); break;
                    case "Script": bres = new BScripts(fid); break;
                    case "Speech": bres = new BSpeech(fid); break;
                    case "Sound": bres = new BSound(fid); break;
                }
            }
            catch(Exception ex)
            {
                bres = null;
                MessageBox.Show("Error creating resource.\n"+ex.GetType().Name+":\n"+ex.Message);
            }
            if (bres != null)
            {
                clearRes();
                cntrl = bres.control;
                if (cntrl!=null)
                {
                    panel1.Controls.Add(cntrl);
                    bres.initControl();
                }
            }
        }

        private void button4_Click(object sender, EventArgs e)
        {
            if (listView1.SelectedItems.Count != 1) return;
            if (cntrl != null)
                try
                {
                    if (!cntrl.exportResource())
                        throw new ApplicationException("Not exported");
                }
                catch (Exception ex)
                {
                        MessageBox.Show("Export error.\n"+ex.GetType().Name+":\n"+ex.Message);
                }
        }

        private void button5_Click(object sender, EventArgs e)
        {
            if (listView1.SelectedItems.Count != 1) return;
            if (cntrl != null)
                try{
                    if (!cntrl.importResource())
                        throw new ApplicationException("Not Imported");
                    clearRes();
                    load();
                }
                catch (Exception ex)
                {
                    MessageBox.Show("Import error.\n" + ex.GetType().Name + ":\n" + ex.Message);
                }
        }

        private void button6_Click(object sender, EventArgs e)
        {
            saveFileDialog1.Filter = "Sky Disk File (*.dsk)|*.dsk|Sky Dinner File(*.dnr)|*.dnr";
            saveFileDialog1.FilterIndex = 0;
            if (saveFileDialog1.ShowDialog() == DialogResult.OK)
            {
                SkyDisk.get().saveDiskAndDinner(saveFileDialog1.FileName);
            }
        }

        private void button7_Click(object sender, EventArgs e)
        {
            openFileDialog1.Filter = "Bass Ru Config (*.xml)|*.xml";
            openFileDialog1.FilterIndex = 0;
            openFileDialog1.Multiselect = false;
            if (openFileDialog1.ShowDialog() == DialogResult.OK)
            {
                Config.get().mergeConfig(openFileDialog1.FileName);
                load();
            }
        }

        private void button8_Click(object sender, EventArgs e)
        {
            openFileDialog1.Filter = "Bass Ru Script (*.xml)|*.xml";
            openFileDialog1.FilterIndex = 0;
            openFileDialog1.Multiselect = false;
            if (openFileDialog1.ShowDialog() == DialogResult.OK)
                try
                {
                    XmlDocument doc = new XmlDocument();
                    doc.Load(openFileDialog1.FileName);
                    if (doc.DocumentElement.Name != "bassru-script")
                        throw new ApplicationException("Bad script root node");
                    int max = 0;
                    foreach (XmlNode nd in doc.DocumentElement.ChildNodes)
                        if (nd.NodeType == XmlNodeType.Element)
                            if (nd.Name == "load" || nd.Name == "import" || nd.Name == "export" || nd.Name == "save")
                                max++;
                    ScriptProgressForm.get().init(max);
                    foreach (XmlNode nd in doc.DocumentElement.ChildNodes)
                        if (nd.NodeType == XmlNodeType.Element)
                        {
                            string cd = Directory.GetCurrentDirectory();
                            uint id = 0;
                            string fl = "";
                            Config.FileInfo fi;
                            BResource res=null;
                            switch (nd.Name)
                            {
                                case "load":
                                    path = nd.Attributes["path"].Value;
                                    if (path[path.Length - 1] != '\\')
                                        path += "\\";
                                    ScriptProgressForm.get().progress("load from "+path);
                                    button1.PerformClick();
                                    Directory.SetCurrentDirectory(cd);
                                    break;
                                case "import":
                                case "export":
                                    id = uint.Parse(nd.Attributes["id"].Value);
                                    fl = nd.Attributes["file"].Value;
                                    ScriptProgressForm.get().progress(nd.Name+" "+id.ToString()+(nd.Name=="import"?" from ":" to ")+fl);
                                    fi = Config.get().findFile(id);
                                    if (fi.fid == 0)
                                        throw new ApplicationException("Unknown file type "+id.ToString());
                                    res = BResourceHelper.getResource(fi.node);
                                    if (nd.Name == "import")
                                        res.import(fl);
                                    else
                                        res.export(fl);
                                    break;
                                case "save":
                                    string pth = nd.Attributes["path"].Value;
                                    if (pth[pth.Length - 1] != '\\')
                                        pth += "\\";
                                    ScriptProgressForm.get().progress("save to " + pth);
                                    SkyDisk.get().saveDiskAndDinner(pth + "sky.dsk");
                                    Directory.SetCurrentDirectory(cd);
                                    break;
                            }

                        }
                    ScriptProgressForm.get().fini();
                    load();
                }
                catch (Exception ex)
                {
                    ScriptProgressForm.get().fini();
                    MessageBox.Show("Error while script run:"+ex.Message);
                    load();
                    //throw;
                }
        }
    }
}