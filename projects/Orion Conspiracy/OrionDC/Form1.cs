using System;
using System.Windows.Forms;
using System.IO;
using System.Xml;

namespace OrionDC
{
    public partial class Form1 : Form
    {
        string prefix;
        string path;
        MainDat main = null;
        ProgDat progs = null;
        public Form1()
        {
            InitializeComponent();
        }

        private void button1_Click(object sender, EventArgs e)
        {
            FolderBrowserDialog fd = new FolderBrowserDialog();
            if (fd.ShowDialog() == DialogResult.OK)
            {
                string pref=MainDat.search(fd.SelectedPath);
                if (pref!="")
                {
                    path = fd.SelectedPath;
                    prefix = pref;
                    textBox1.Text = path;
                    process();
                }
            }
        }

        void process()
        {
            main = new MainDat(path,prefix);
            string s=main.entry.ToString("X");
            main.dump(Path.GetDirectoryName(Application.ExecutablePath));
            textBox3.Text = s;
            progs = new ProgDat(path, prefix, main);
            progs.dump(Path.GetDirectoryName(Application.ExecutablePath));
            comboBox1.Items.Clear();
            for (int i = 0; i < progs.progs.Count; i++)
                comboBox1.Items.Add(i);
            
        }

        private void comboBox1_SelectedIndexChanged(object sender, EventArgs e)
        {
            int id = (int)comboBox1.SelectedItem;
            OProg p = progs.progs[id];
            string s = String.Format("--{0:X4}--\r\n",p.data.Length);
            s += String.Format("u0:{0:X4}\r\nexitCnt:{1:X4}\r\n", p.u0,p.exitsCnt);
            s += String.Format("actorsCnt:{0:X4}\r\nu6:{1:X4}\r\n", p.actorsCnt, p.u6);
            s += String.Format("exits:{0:X4}\r\nactors:{1:X4}\r\n", p.exits, p.actors);
            s += String.Format("sprites:{0:X4}\r\nentry:{1:X4}\r\n", p.sprites, p.entry);
            textBox2.Text = s;
            textBox4.Text = "";
            foreach (OProg.OString ss in p.strings)
                textBox4.Text += String.Format("{0:d}:{1:X4}:{2:s}\r\n", ss.id, ss.ofs, ss.data);
            //textBox3.Text = Decompiler.decompile(p, "\r\n");

        }

        private void button2_Click(object sender, EventArgs e)
        {
            textBox3.Text = String.Format("entry:{0:X4}\r\ncharmap:{1:X4}",main.entry,main.charmap);
        }

        private void button3_Click(object sender, EventArgs e)
        {
            XmlDocument doc = new XmlDocument();
            XmlNode root=doc.AppendChild(doc.CreateElement("orion_text"));
            XmlNode prog = root.AppendChild(doc.CreateElement("main"));
            foreach (MainDat.StringBlock blk in main.strings)
            {
                XmlNode bl = prog.AppendChild(doc.CreateElement("block"));
                bl.Attributes.Append(doc.CreateAttribute("id")).Value = blk.id.ToString();
                foreach (OProg.OString s in blk.strings)
                {
                    XmlNode st = bl.AppendChild(doc.CreateElement("string"));
                    st.Attributes.Append(doc.CreateAttribute("id")).Value = s.id.ToString();
                    st.Attributes.Append(doc.CreateAttribute("orig")).Value = s.data;
                    st.AppendChild(doc.CreateTextNode(s.data));
                }
            }
            prog = root.AppendChild(doc.CreateElement("prog"));
            int id=0;
            foreach (OProg p in progs.progs)
            {
                XmlNode pr = prog.AppendChild(doc.CreateElement("prog"));
                pr.Attributes.Append(doc.CreateAttribute("id")).Value = id.ToString();
                foreach (OProg.OString s in p.strings)
                {
                    XmlNode st = pr.AppendChild(doc.CreateElement("string"));
                    st.Attributes.Append(doc.CreateAttribute("id")).Value = s.id.ToString();
                    st.Attributes.Append(doc.CreateAttribute("orig")).Value = s.data;
                    st.AppendChild(doc.CreateTextNode(s.data));
                }
                id++;
            }
            doc.Save(Path.Combine(Path.GetDirectoryName(Application.ExecutablePath),"orion_dc.xml"));
        }
    }
}