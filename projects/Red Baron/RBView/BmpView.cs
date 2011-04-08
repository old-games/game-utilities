using System;
using System.Drawing;
using System.Drawing.Imaging;
using System.IO;
using System.Windows.Forms;

namespace RBView
{
    public partial class BmpView : Form
    {
        int cnt=0;
        int[] sizes;
        byte[] vga = null;
        bool scr = false;
        bool amg = false;
        public BmpView()
        {
            InitializeComponent();
            for (int i = 0; i < Palettes.get().pls.Count; i++)
            {
                comboBox2.Items.Add(Palettes.get().pls[i].name);
            }
        }

        public BmpView(byte[] data, string name,bool scr):this()
        {
            this.scr = scr;
            Text = (scr?"SCR ":"BMP ") + name;
            byte[] vdt;
            if (scr)
            {
                cnt = 1;
                sizes=new int[2]{320,200};
                comboBox1.Items.Add(0);
                try
                {
                    vdt = Common.getSection(data, "SCR:VGA:");
                }
                catch (PartNotFoundException)
                {
                    amg = true;
                    vdt = Common.getSection(data, "SCR:AMG:");
                }
                vga = Common.mixData(RBCompress.Decompressor.decompress(Common.getSection(data,"SCR:BIN:")),
                    RBCompress.Decompressor.decompress(vdt),amg);
            }
            else
            {
                byte[] inf = Common.getSection(data, "BMP:INF:");
                cnt = Common.readInt16(inf, 0);
                sizes = new int[cnt * 2];
                for (int i = 0; i < cnt; i++)
                {
                    sizes[i * 2] = Common.readInt16(inf, i * 2 + 2);
                    sizes[i * 2 + 1] = Common.readInt16(inf, cnt * 2 + 2 + i * 2);
                    comboBox1.Items.Add(i);
                }
                try
                {
                    vdt = Common.getSection(data, "BMP:VGA:");
                }
                catch (PartNotFoundException)
                {
                    amg = true;
                    vdt = Common.getSection(data, "BMP:AMG:");
                }
                vga = Common.mixData(RBCompress.Decompressor.decompress(Common.getSection(data, "BMP:BIN:")),
                    RBCompress.Decompressor.decompress(vdt),amg);
            }
            Palette pl = Palettes.get().getPalette(name);
            comboBox2.SelectedItem = pl.name;
            comboBox1.SelectedIndex = 0;
            if (scr)
                comboBox1.Enabled = false;
        }

        public Bitmap getImg(int index)
        {
            int ofs = 0;
            for (int i = 0; i < index; i++)
                ofs += sizes[i * 2] * sizes[i * 2 + 1];
            int w=sizes[index*2];
            int h=sizes[index*2+1];
            Bitmap bmp = new Bitmap(w,h,System.Drawing.Imaging.PixelFormat.Format8bppIndexed);
            System.Drawing.Imaging.ColorPalette pal = bmp.Palette;
            Palette pl = Palettes.get().getPalette(comboBox2.Text);
            for (int i = 0; i < 256; i++)
                pal.Entries[i] = pl.cls[i];
            bmp.Palette = pal;
            byte[] data = new byte[w * h];
            Array.Copy(vga,ofs,data,0,w*h);
            BitmapData bd = bmp.LockBits(new Rectangle(0, 0, w, h),
    ImageLockMode.WriteOnly, bmp.PixelFormat);
            for (int i = 0; i < bd.Height; i++)
                System.Runtime.InteropServices.Marshal.Copy(data, (i * bd.Width), new IntPtr(bd.Scan0.ToInt64() + i * bd.Stride), bd.Width);
            bmp.UnlockBits(bd);
            return bmp;
        }

        private void comboBox1_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (comboBox1.SelectedIndex < 0)
                return;
            if (vga == null)
                return;
            pictureBox1.Image = getImg(comboBox1.SelectedIndex);
        }

        private void button1_Click(object sender, EventArgs e)
        {
            string fn = Common.getSaveName("bmp");
            if (fn != "")
                getImg(comboBox1.SelectedIndex).Save(fn,ImageFormat.Bmp);
        }

        void setImage(int index,Bitmap bmp)
        {
            int ofs = 0;
            for (int i = 0; i < index; i++)
                ofs += sizes[i * 2] * sizes[i * 2 + 1];
            int w = sizes[index * 2];
            int h = sizes[index * 2 + 1];
            byte[] data = new byte[w * h];
            BitmapData bd = bmp.LockBits(new Rectangle(0, 0, w, h),
    ImageLockMode.ReadWrite, bmp.PixelFormat);
            for (int i = 0; i < h; i++)
                System.Runtime.InteropServices.Marshal.Copy(new IntPtr(bd.Scan0.ToInt64() + i * bd.Stride), data, i * bd.Width, bd.Width);
            bmp.UnlockBits(bd);
            Array.Copy(data,0,vga,ofs,w*h);
            button3.Enabled = true;
        }

        private void button2_Click(object sender, EventArgs e)
        {
            OpenFileDialog ofd = new OpenFileDialog();
            ofd.Filter = "Bitmap file(*.bmp)|*.bmp";
            ofd.FilterIndex = 0;
            if (ofd.ShowDialog() == DialogResult.OK)
            {
                Bitmap bmp = new Bitmap(ofd.FileName);
                Bitmap bo = getImg(comboBox1.SelectedIndex);
                if (bo.Width != bmp.Width || bo.Height != bmp.Height)
                {
                    MessageBox.Show("Wrong bmp size");
                    return;
                }
                for (int i = 0; i < 256; i++)
                {
                    if (bmp.Palette.Entries[i] != bo.Palette.Entries[i])
                        if (MessageBox.Show("Palettes differ! Continue?", "warning", MessageBoxButtons.YesNoCancel) == DialogResult.Yes)
                            break;
                        else
                            return;
                }
                setImage(comboBox1.SelectedIndex, bmp);
                comboBox1_SelectedIndexChanged(null, null);
            }
        }

        private void save()
        {
            string fname = Common.getSaveName(scr ? "scr" : "bmp");
            if (fname == "")
                return;
            byte[] bin=null;
            byte[] vg=null;
            Common.splitData(vga,ref bin,ref vg,amg);
            bin = RBCompress.Compressor.compress(bin);
            vg = RBCompress.Compressor.compress(vg);
            byte[] dt;
            if (scr)
                dt=Common.makeSections(new byte[][]{bin,vg},new string[]{"BIN:",(amg?"AMG:":"VGA:")});
            else
            {
                byte[] inf=new byte[cnt*4+2];
                Common.writeInt16(inf, 0, cnt);
                for (int i = 0; i < cnt; i++)
                {
                    Common.writeInt16(inf, 2 + i * 2, sizes[i*2]);
                    Common.writeInt16(inf, cnt*2+2 + i * 2, sizes[i * 2+1]);
                }
                dt = Common.makeSections(new byte[][] { inf, bin, vg }, new string[] { "INF:", "BIN:", (amg?"AMG:":"VGA:") });
            }
            byte[] res = Common.makeSections(new byte[][]{dt}, new string[] {(scr?"SCR:":"BMP:")},true);
            FileStream fs = new FileStream(fname, FileMode.Create);
            fs.Write(res, 0, res.Length);
            fs.Close();
        }

        private void button3_Click(object sender, EventArgs e)
        {
            save();
        }
    }
}
