using System;
using System.Collections.Generic;

namespace bassru.ResView
{
    public partial class TextViewcs : BResourceControl
    {
        public static TextViewcs obj = null;
        private bool ruchecked = false;
        public static TextViewcs get()
        {
            if (obj == null)
                obj = new TextViewcs();
            return obj;
        }
        public TextViewcs()
        {
            InitializeComponent();
            fillC2(32);
            button3.Enabled = !Config.get().hasEngFile();
        }

        BText txt { get { return resource as BText; } }
        public override void setObject(BResource res)
        {
            base.setObject(res);
            comboBox1.SelectedIndex = -1;
            comboBox1.Items.Clear();
            comboBox2.SelectedIndex=-1;
            for (int i = 0; i < txt.blockCount; i++)
                comboBox1.Items.Add(i.ToString());
            textBox1.Text = "";
        }

        public override void saveConfig(string comment)
        {
            Dictionary<string, string> res = makeConfig("text", comment);
            Config.get().updateConfig(txt.filenum, res);
        }

        private void fillC2(int cnt)
        {
            int pc = comboBox2.SelectedIndex;
            comboBox2.Items.Clear();
            for (int i = 0; i < cnt; i++)
                comboBox2.Items.Add(i.ToString());
            if (comboBox2.Items.Count > pc)
                comboBox2.SelectedIndex = pc;
            else
            {
                comboBox2.Text = "";
                comboBox2.SelectedIndex = -1;
            }
        }

        private void comboBox1_SelectedIndexChanged(object sender, EventArgs e)
        {
            textBox1.Text = "";
            textBox2.Text = textBox3.Text = "";
            if (comboBox1.SelectedIndex < 0) return;
            int blk = int.Parse(comboBox1.Text);
            if (sender == comboBox1)
                fillC2(blk == txt.blockCount - 1 ? txt.lastBlockSize : 32);
            if (comboBox2.SelectedIndex < 0)
                return;
            int N = int.Parse(comboBox2.Text);
            string cmt = "";
            try
            {
                if (!ruchecked)
                    checkBox1.Checked = Config.get().isTextRu(txt.filenum, blk, N, ref cmt);
                else
                    ruchecked = false;
                textBox1.Text = txt.getText(blk, N, checkBox1.Checked);
                textBox2.Text = "";
                if (Config.get().hasEngFile())
                    textBox2.Text = Config.get().engText(txt.filenum,blk,N);
                textBox3.Text = cmt;
            }
            catch (Exception ex)
            {
                MainForm.clearResource(ex);
            }
        }

        private void button2_Click(object sender, EventArgs e)
        {
            new RuTableForm().ShowDialog();
        }

        private void button1_Click(object sender, EventArgs e)
        {
            if (comboBox1.SelectedIndex<0) return;
            if (comboBox2.SelectedIndex<0) return;
            Config.get().setTextInfo(txt.filenum, uint.Parse(comboBox1.Text), uint.Parse(comboBox2.Text),
                checkBox1.Checked, textBox3.Text);
        }

        private void button3_Click(object sender, EventArgs e)
        {
            Config.get().saveEngTextFile();
            button3.Enabled = false;
        }

        private void checkBox1_CheckedChanged(object sender, EventArgs e)
        {
            ruchecked = true;
            comboBox1_SelectedIndexChanged(null, null);
        }

    }
}
