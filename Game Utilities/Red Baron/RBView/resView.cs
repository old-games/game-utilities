//#define DECOMPRESS_DBG

using System;
using System.IO;
using System.Text;
using System.Windows.Forms;


namespace RBView
{
    public partial class resView : Form
    {

        byte[] data = null;
        byte[] rdata = null;
        public resView()
        {
            InitializeComponent();
        }

        public void makeTree(BinaryReader rd,int ofs,TreeNode p)
        {
            int nofs = ofs;
            while (nofs+3<data.Length && data[nofs + 3] == 0x3A)
            {
                rd.BaseStream.Position = nofs;
                char[] nm = rd.ReadChars(3);
                if (nm[0] >= '0' && nm[0] <= 'z' && nm[1] >= '0' && nm[1] <= 'z' && nm[2] >= '0' && nm[2] <= 'z')
                {
                    rd.ReadChar();
                    int sz = rd.ReadInt32();
                    bool fl = (sz & 0x80000000) != 0;
                    sz &= 0x7FFFFFFF;
                    TreeNode tnd = p.Nodes.Add(String.Format("{0:S}:{1:D}(0x{1:X}){2:S}",new String(nm),sz,(fl ? "*" : "")));
                    tnd.Tag = String.Format("{0:d}:{1:d}",nofs+8,sz);
                    makeTree(rd, nofs + 8, tnd);
                    nofs += 8 + sz;
                }
                else
                    nofs=data.Length;
            }
        }

        public resView(byte[] data,String name):this()
        {
            this.data = data;
            treeView1.Nodes.Clear();
            TreeNode n=treeView1.Nodes.Add(String.Format("{1:S}:{0:D}(0x{0:X})",data.Length,name));
            n.Tag = "0:" + data.Length.ToString();
            BinaryReader rd = new BinaryReader(new MemoryStream(data), Encoding.ASCII);
            makeTree(rd,0, n);
            rd.Close();
            treeView1.SelectedNode = n;
            n.ExpandAll();
        }

        public void setData(byte[] data)
        {
            this.rdata = data;
            button2.Enabled = rdata[0] == 2;
            textBox1.Text = "";
            //textBox1.Hide();
            int pos = 0;
            string txt = "";
            while (pos < data.Length)
            {
                byte[] ln = new byte[16];
                int cnt = 16;
                if (pos + 16 >= data.Length)
                    cnt = data.Length - pos;
                Array.Copy(data, pos, ln, 0, cnt);
                string dt = String.Format("{0:X8}: ", pos);
                string hx = "";
                string ch = "";
                for (int i = 0; i < cnt; i++)
                {
                    hx += String.Format("{0:X2} ", ln[i]);
                    byte c = ln[i];
                    if (c < 0x20 || c > 0x80) c = 0x2E;
                    ch += new String(Encoding.Unicode.GetChars(Encoding.Convert(Encoding.ASCII,Encoding.Unicode,Encoding.ASCII.GetBytes(""+(char)c))));
                }
                while (hx.Length < 48)
                    hx += ' ';
                dt += String.Format("{0:S} | {1:s}\r\n",hx,ch);
                txt += dt;
                pos += 16;
            }
            textBox1.Text = txt;
            //textBox1.Show();
        }

        private void button1_Click(object sender, EventArgs e)
        {
            Close();
        }

        private void treeView1_AfterSelect(object sender, TreeViewEventArgs e)
        {
            if (e.Node == null)
                return;
            string[] pl = (e.Node.Tag as string).Split(':');
            int sz=int.Parse(pl[1]);
            byte[] res = new byte[sz];
            Array.Copy(data, int.Parse(pl[0]), res, 0, sz);
            setData(res);
        }

        public string getName(TreeNode nd)
        {
            return String.Format("{0:s}:{1:s}", nd.Parent != null ? getName(nd.Parent) : "", nd.Text.Split(':')[0]);
        }

        private void button2_Click(object sender, EventArgs e)
        {
#if !DECOMPRESS_DBG
            try
            {
#endif
                byte[] ndata = RBCompress.Decompressor.decompress(rdata);
                new resView(ndata, getName(treeView1.SelectedNode)).ShowDialog();
#if !DECOMPRESS_DBG
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
#endif
        }

        private void button3_Click(object sender, EventArgs e)
        {
            byte[] cdata = RBCompress.Compressor.compress(rdata);
            byte[] chk = RBCompress.Decompressor.decompress(cdata);
            for (int i = 0; i < rdata.Length; i++)
            {
                if (rdata[i] != chk[i])
                {
                    MessageBox.Show("Not match at "+i.ToString("X"));
                    break;
                }
            }
            new resView(cdata, "CompressTest").ShowDialog();
        }
    }
}
