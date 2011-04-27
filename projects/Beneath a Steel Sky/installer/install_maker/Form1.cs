using System.IO;
using System.Windows.Forms;
using System.Xml;
using System;

namespace install_maker
{
    public partial class Form1 : Form
    {
        string docname="untitled";
        string docpath = "";
        string icon = "";
        bool saved=false;
        const string INSTALL_CONF = "install.cfg";
        const string INSTALL_CONF_TAG = "INSTALL_CONF";
        string INST_API_FILE = Builder.INST_API_FILE;
        string INST_API_TAG = Builder.INST_API_TAG;
        const string ADD_API = "Add inst_api.js";
        const string REM_API = "Remove inst_api.js";
        const string XML_FILTER = "XML files (*.xml)|*.xml";
        const string ALL_FILTER = "ALL files (*.*)|*.*";
        const string CONFIG_ROOT = "install_maker_config";

        public Form1()
        {
            InitializeComponent();
            newToolStripMenuItem.PerformClick();
        }

        private void newToolStripMenuItem_Click(object sender, System.EventArgs e)
        {
            clear();
        }

        void makeChanges() { makeChanges(false); }
        void makeChanges(bool save)
        {
            saved = save;
            Text = "Install Maker - " + docname +(saved ? "" : "*");
        }

        void clear()
        {
            cbInternal.Checked = true;
            cbSizeable.Checked = cbMaximized.Checked = false;
            domainUpDown1.SelectedItem = "640";
            cbPackType.SelectedIndex = 0;
            docname = "untitled";
            listView1.Items.Clear();
            ListViewItem li = listView1.Items.Add(INSTALL_CONF);
            li.Tag = INSTALL_CONF_TAG;
            icon = "";
            tbAppName.Text = "";
            pictureBox1.Image = null;
            cbCompress.Checked = true;
            cbConsole.Checked = cbDebug.Checked = cbLogfile.Checked = false;
            makeChanges(true);
        }

        private void checkBox1_CheckedChanged(object sender, System.EventArgs e)
        {
            groupBox2.Enabled = cbInternal.Checked;
            makeChanges();
        }

        private void checkBox8_CheckedChanged(object sender, System.EventArgs e)
        {
            tbWidth.Enabled = tbHeight.Enabled = domainUpDown1.Enabled= !cbMaximized.Checked;
            makeChanges();
        }

        private void some_CheckedChanged(object sender, System.EventArgs e)
        {
            makeChanges();
        }

        private void domainUpDown1_SelectedItemChanged(object sender, System.EventArgs e)
        {
            tbWidth.Text = (string)domainUpDown1.SelectedItem;
            switch (int.Parse(tbWidth.Text))
            {
                case 320: tbHeight.Text = "200"; break;
                case 640: tbHeight.Text = "480"; break;
                case 800: tbHeight.Text = "600"; break;
                case 1024: tbHeight.Text = "768"; break;
                case 2048: tbHeight.Text = "1024"; break;
            }
        }

        private void checkBox3_CheckedChanged(object sender, System.EventArgs e)
        {
            if (cbDebug.Checked)
                cbConsole.Checked = true;
            cbConsole.Enabled = !cbDebug.Checked;
            makeChanges();
        }

        private void addFilesToolStripMenuItem_Click(object sender, System.EventArgs e)
        {
            OpenFileDialog od = new OpenFileDialog();
            od.Multiselect = true;
            if (od.ShowDialog() == DialogResult.OK)
            {
                addFiles(od.FileNames);
            }
        }

        void addFiles(string[] filelist)
        {
            int added = 0;
            foreach (string f in filelist)
            {
                string fn=Path.GetFileName(f);
                if (fn == INSTALL_CONF)
                {
                    MessageBox.Show("Can't add "+INSTALL_CONF);
                }
                else
                {
                    if (fn.Length > 16)
                    {
                        MessageBox.Show("Name of " + fn + " truncated to "+fn.Substring(0,16));
                        fn = fn.Substring(0, 16);
                    }
                    bool found = false;
                    foreach(ListViewItem li in listView1.Items)
                        if (li.Text == fn)
                        {
                            found = true;
                            MessageBox.Show("File "+fn+" already exists");
                        }
                    if (!found)
                    {
                        ListViewItem li = listView1.Items.Add(fn);
                        li.Tag = f;
                        if (fn == INST_API_FILE)
                        {
                            li.Tag = INST_API_TAG;
                            btnAddAPI.Text = REM_API;
                        }
                        added++;
                    }
                }
            }
            if (added > 0)
                makeChanges();
        }

        private void removeSelectedToolStripMenuItem_Click(object sender, System.EventArgs e)
        {
            if (listView1.SelectedItems.Count < 1)
                return;
            foreach (ListViewItem li in listView1.SelectedItems)
            {
                string nm=(string)li.Tag;
                if (nm != INSTALL_CONF_TAG)
                {
                    listView1.Items.Remove(li);
                    makeChanges();
                    if (nm == INST_API_TAG)
                        btnAddAPI.Text = ADD_API;
                }
            }
        }

        private void button4_Click(object sender, System.EventArgs e)
        {
            OpenFileDialog od = new OpenFileDialog();
            od.Filter = "Icon files (*.ico)|*.ico";
            if (od.ShowDialog() == DialogResult.OK)
            {
                System.Drawing.Icon ic=new System.Drawing.Icon(od.FileName);
                pictureBox1.Image = ic.ToBitmap();
                icon = od.FileName;
                makeChanges();
            }
        }

        private void listView1_KeyUp(object sender, KeyEventArgs e)
        {
            if (e.KeyCode == Keys.Insert)
                addFilesToolStripMenuItem.PerformClick();
            if (e.KeyCode == Keys.Delete)
                removeSelectedToolStripMenuItem.PerformClick();
        }

        private void listView1_DragDrop(object sender, DragEventArgs e)
        {
            string[] s = (string[])e.Data.GetData(DataFormats.FileDrop, false);
            addFiles(s);
        }

        private void listView1_DragEnter(object sender, DragEventArgs e)
        {
            if (e.Data.GetDataPresent(DataFormats.FileDrop))
                e.Effect = DragDropEffects.Copy;
            else
                e.Effect = DragDropEffects.None;
        }

        private void button3_Click(object sender, System.EventArgs e)
        {
            bool add=true;
            foreach (ListViewItem li in listView1.Items)
            {
                if ((string)li.Tag == INST_API_TAG)
                {
                    add = false;
                    listView1.Items.Remove(li);
                    btnAddAPI.Text = ADD_API;
                }
            }
            if (add)
            {
                listView1.Items.Add(INST_API_FILE).Tag=INST_API_TAG;
                btnAddAPI.Text = REM_API;
            }
            makeChanges();
        }

        private void save(string fname)
        {
            XmlDocument doc = new XmlDocument();
            XmlNode root=doc.AppendChild(doc.CreateElement(CONFIG_ROOT));
            XmlNode ops = root.AppendChild(doc.CreateElement("options"));
            XmlNode op=ops.AppendChild(doc.CreateElement("app"));
            op.Attributes.Append(doc.CreateAttribute("name")).Value = tbAppName.Text;
            if (icon!="")
                op.Attributes.Append(doc.CreateAttribute("icon")).Value = icon;
            op = ops.AppendChild(doc.CreateElement("browser"));
            op.Attributes.Append(doc.CreateAttribute("internal")).Value = cbInternal.Checked?"yes":"no";
            if (cbInternal.Checked)
            {
                op.Attributes.Append(doc.CreateAttribute("sizeable")).Value = cbSizeable.Checked ? "yes" : "no";
                op.Attributes.Append(doc.CreateAttribute("maximized")).Value = cbMaximized.Checked ? "yes" : "no";
                if (!cbMaximized.Checked)
                {
                    op.Attributes.Append(doc.CreateAttribute("width")).Value = tbWidth.Text;
                    op.Attributes.Append(doc.CreateAttribute("height")).Value = tbHeight.Text;
                }
            }
            op = ops.AppendChild(doc.CreateElement("pack"));
            op.Attributes.Append(doc.CreateAttribute("type")).Value = cbPackType.SelectedIndex.ToString();
            op.Attributes.Append(doc.CreateAttribute("compressed")).Value = cbCompress.Checked ? "yes" : "no";
            op = ops.AppendChild(doc.CreateElement("flags"));
            op.Attributes.Append(doc.CreateAttribute("debug")).Value = cbDebug.Checked?"yes":"no";
            op.Attributes.Append(doc.CreateAttribute("console")).Value = cbConsole.Checked ? "yes" : "no";
            op.Attributes.Append(doc.CreateAttribute("logfile")).Value = cbLogfile.Checked ? "yes" : "no";
            XmlNode fls = root.AppendChild(doc.CreateElement("files"));
            foreach (ListViewItem li in listView1.Items)
            {
                if ((li.Tag as string) != INSTALL_CONF_TAG)
                {
                    XmlNode f = fls.AppendChild(doc.CreateElement("file"));
                    f.Attributes.Append(doc.CreateAttribute("name")).Value = (string)li.Tag;
                    if (li.Text != Path.GetFileName((string)li.Tag))
                        f.Attributes.Append(doc.CreateAttribute("alias")).Value = li.Text;
                }
            }
            doc.Save(fname);
            docpath = Path.GetDirectoryName(fname);
            docname = Path.GetFileNameWithoutExtension(fname);
            makeChanges(true);
        }

        private void saveAsToolStripMenuItem_Click(object sender, System.EventArgs e)
        {
            SaveFileDialog sd=new SaveFileDialog();
            sd.Filter=XML_FILTER;
            sd.AddExtension=true;
            sd.DefaultExt=".xml";
            if (sd.ShowDialog() == DialogResult.OK)
                save(sd.FileName);
        }

        private void saveToolStripMenuItem_Click(object sender, System.EventArgs e)
        {
            if (docpath == "")
                saveAsToolStripMenuItem.PerformClick();
            else
                save(Path.Combine(docpath, docname+".xml"));
        }

        private void exitToolStripMenuItem_Click(object sender, System.EventArgs e)
        {
            Close();
        }

        private void Form1_FormClosing(object sender, FormClosingEventArgs e)
        {
            if (!saved)
            {
                DialogResult r = MessageBox.Show("Save changes on exit?", "Document not saved", MessageBoxButtons.YesNoCancel);
                switch (r)
                {
                    case DialogResult.Cancel: e.Cancel=true;break;
                    case DialogResult.Yes: saveToolStripMenuItem.PerformClick(); break;
                }
            }
        }

        private void textBox1_Leave(object sender, System.EventArgs e)
        {
            TextBox tb = (sender as TextBox);
            int res=0;
            if (!int.TryParse(tb.Text, out res))
            {
                MessageBox.Show("Bad integer format: "+tb.Text);
                tb.SelectAll();
                tb.Focus();
            }
        }

        void setcheck(CheckBox cb,XmlAttribute atr)
        {
            if (atr == null)
                return;
            cb.Checked = (atr.Value == "yes");
        }

        private void openToolStripMenuItem_Click(object sender, System.EventArgs e)
        {
            OpenFileDialog od = new OpenFileDialog();
            od.Filter = XML_FILTER + "|" + ALL_FILTER;
            od.FilterIndex = 0;
            od.Multiselect = false;
            if (od.ShowDialog() == DialogResult.OK)
            {
                bool goodold=true;
                try{
                    string fname = od.FileName;
                    XmlDocument doc = new XmlDocument();
                    doc.Load(fname);
                    if (doc.DocumentElement.Name != CONFIG_ROOT)
                        throw new Exception("Bad document format");
                    clear();
                    goodold = false;
                    foreach(XmlNode nd in doc.DocumentElement.ChildNodes)
                        if (nd.NodeType==XmlNodeType.Element)
                    {
                        if (nd.Name == "options")
                        {
                            foreach(XmlNode n in nd.ChildNodes)
                                if (n.NodeType==XmlNodeType.Element)
                                    switch (n.Name)
                                    {
                                        case "app":
                                            tbAppName.Text=n.Attributes["name"].Value;
                                            if (n.Attributes["icon"] != null)
                                            {
                                                icon = n.Attributes["icon"].Value;
                                                pictureBox1.Image = (new System.Drawing.Icon(icon)).ToBitmap();
                                            }
                                            break;
                                        case "browser":
                                            setcheck(cbInternal,n.Attributes["internal"]);
                                            if (cbInternal.Checked)
                                            {
                                                setcheck(cbSizeable, n.Attributes["sizeable"]);
                                                setcheck(cbMaximized, n.Attributes["maximized"]);
                                                if (!cbMaximized.Checked)
                                                {
                                                    tbWidth.Text = n.Attributes["width"].Value;
                                                    tbHeight.Text = n.Attributes["height"].Value;
                                                }
                                            }
                                            break;
                                        case "pack":
                                            setcheck(cbCompress,n.Attributes["compressed"]);
                                            cbPackType.SelectedIndex = int.Parse(n.Attributes["type"].Value);
                                            break;
                                        case "flags":
                                            setcheck(cbConsole, n.Attributes["console"]);
                                            setcheck(cbDebug, n.Attributes["debug"]);
                                            setcheck(cbLogfile, n.Attributes["logfile"]);
                                            break;
                                    }
                        }
                        else if (nd.Name == "files")
                        {
                            foreach(XmlNode n in nd.ChildNodes)
                                if (n.NodeType == XmlNodeType.Element && n.Name == "file")
                                {
                                    string s = n.Attributes["name"].Value;
                                    string a = (s == INST_API_TAG)?(INST_API_FILE):(Path.GetFileName(s));
                                    if (n.Attributes["alias"] != null)
                                        a = n.Attributes["alias"].Value;
                                    if (s == INST_API_TAG)
                                    {
                                        listView1.Items.Add(a).Tag=INST_API_TAG;
                                        btnAddAPI.Text = REM_API;
                                    }
                                    else
                                    {
                                        if (!File.Exists(s))
                                            MessageBox.Show("File " + s + " no more exists.");
                                        else
                                            listView1.Items.Add(a).Tag = s;
                                    }
                                }
                        }
                    }
                    docpath = Path.GetDirectoryName(fname);
                    docname = Path.GetFileNameWithoutExtension(fname);
                    makeChanges(true);
                }catch(Exception ex)
                {
                    MessageBox.Show(ex.Message);
                    if (!goodold)
                        clear();
                }
            }
        }

        private void listView1_BeforeLabelEdit(object sender, LabelEditEventArgs e)
        {
            if ((string)listView1.Items[e.Item].Tag == INSTALL_CONF_TAG)
                e.CancelEdit = true;
        }

        private void buildToolStripMenuItem1_Click(object sender, EventArgs e)
        {
            try
            {
                Builder b = Builder.getBuilder();
                b.clear();
                string bp=b.build_path;
                if (bp=="")
                {
                    FolderBrowserDialog fb = new FolderBrowserDialog();
                    if (fb.ShowDialog() != DialogResult.OK)
                        return;
                    bp = fb.SelectedPath;
                }
                b.setParams(tbAppName.Text, cbPackType.SelectedIndex, cbCompress.Checked, icon);
                b.setBrowser(cbInternal.Checked, cbSizeable.Checked, cbMaximized.Checked, int.Parse(tbWidth.Text), int.Parse(tbHeight.Text));
                b.setFlags(cbDebug.Checked, cbConsole.Checked, cbLogfile.Checked);
                foreach (ListViewItem li in listView1.Items)
                    if ((string)li.Tag != INSTALL_CONF_TAG)
                        b.addFile(li.Text, (string)li.Tag);
                b.build(bp);
            }
            catch (Exception ex)
            {
                MessageBox.Show("ERROR: "+ex.GetType().Name+"\r\n"+ex.Message);
            }
        }

        private void listView1_AfterLabelEdit(object sender, LabelEditEventArgs e)
        {
            if (e.Label != null || e.Label != "")
            {
                e.CancelEdit = true;
                return;
            }
            for (int i = 0; i < listView1.Items.Count;i++ )
                if (i != e.Item && e.Label == listView1.Items[i].Text)
                {
                    e.CancelEdit = true;
                    return;
                }
            makeChanges();
        }

    }
}
