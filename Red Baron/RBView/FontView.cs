using System;
using System.Collections.Generic;
using System.Drawing;
using System.IO;
using System.Windows.Forms;

namespace RBView
{
    public partial class FontView : Form
    {
        byte[] fdata = null;
        byte lcount = 0;
        byte tp = 0;
        byte fromletter;
        byte height = 0;
        byte width = 0;
        int sz = 0;
        byte hz = 0;
        byte[] fhelp = new byte[2];
        List<byte> widths = new List<byte>();
        List<int> ofs = new List<int>();
        public FontView()
        {
            InitializeComponent();
        }

        public FontView(byte[] data,string name): this()
        {
            Text = "FONT "+name;
            byte[] xdata = Common.getSection(data, "FNT:");
            data = new byte[xdata.Length - 8];
            tp = xdata[0];
            sz = Common.readInt16(xdata, 6);
            lcount = xdata[5];
            fromletter=xdata[4];
            height = xdata[2];
            width = xdata[1];
            hz = xdata[3];
            Array.Copy(xdata,8,data,0,data.Length);
            xdata = RBCompress.Decompressor.decompress(data);
            fdata = new byte[xdata.Length - lcount * 3];
            Array.Copy(xdata,lcount*3,fdata,0,fdata.Length);
            for (int i = 0; i < lcount; i++)
            {
                ofs.Add(Common.readInt16(xdata,i*2));
                widths.Add(xdata[lcount*2+i]);
            }
            label1.Text=String.Format("width={0:d} height={1:d} hz=0x{2:X2}",width,height,hz);
            label2.Text = String.Format("letters={0:d} from={1:d}",lcount,fromletter);
            pictureBox1.Image = mkBitmap();
        }

        Bitmap mkBitmap()
        {
            int w = width;
            int h = height;
            int hofs = -h-1;
            int wofs = 0;
            int of = 0;
            Bitmap bmp = new Bitmap((w+1)*16-1, (h+1)*16-1);
            Graphics g = Graphics.FromImage(bmp);
            g.FillRectangle(new SolidBrush(Color.LightGray),g.ClipBounds);
            for (int i = 1; i < 16; i++)
            {
                Pen p=new Pen(Color.Gray);
                g.DrawLine(p, (w + 1) * i-1, 0, (w + 1) * i-1,bmp.Height-1);
                g.DrawLine(p,0, (h + 1) * i-1, bmp.Width, (h + 1) *i-1);
            }
            for (int i = 0; i < 255; i++)
            {
                if (i % 16 == 0)
                {
                    hofs += h+1;
                    wofs = 0;
                }
                if (i >= fromletter && i < fromletter + lcount)
                {
                    of = ofs[i - fromletter];
                    int wd = widths[i - fromletter];
                    for (int k = 0; k < h; k++)
                    {
                        int f = 0;
                        int bts = (wd / 8) + (wd % 8 == 0 ? 0 : 1);
                        for (int p = 0; p < bts; p++)
                        {
                            f <<= 8;
                            f |= fdata[of++];
                        }
                        bts = bts * 8-1;
                        for (int j = 0; j < wd; j++)
                        {
                            bmp.SetPixel(wofs + j, hofs + k, ((f >> (bts-j)) & 1) == 0 ? Color.White : Color.Black);
                        }
                    }
                }
                wofs += w + 1;
            }
            return bmp;
        }


        private void button1_Click(object sender, EventArgs e)
        {
            string fn = Common.getSaveName("bmp");
            if (fn != "")
                mkBitmap().Save(fn,System.Drawing.Imaging.ImageFormat.Bmp);
        }

        int getWidth(Bitmap bmp, int xofs, int yofs, int w, int h)
        {
            int wd=0;
            for (int i = 0; i < h; i++)
                for (int j = 0; j < w; j++)
                {
                    Color cl=bmp.GetPixel(xofs+j,yofs+i);
                    if (cl.ToArgb() == Color.White.ToArgb() || cl.ToArgb() == Color.Black.ToArgb())
                        if (j+1 > wd)
                            wd = j + 1;
                }
            return wd;
        }

        private void setFont(Bitmap bmp)
        {
            int started = -1;
            int last = 0;
            int wofs=0;
            int hofs=-height-1;
            List<byte> data = new List<byte>();
            List<byte> wdh = new List<byte>();
            List<int> of = new List<int>();
            for (int i = 0; i < 255; i++)
            {
                if (i % 16 == 0)
                {
                    hofs += height + 1;
                    wofs = 0;
                }
                int w = getWidth(bmp, wofs, hofs, width, height);
                if (w != 0)
                {
                    if (started == -1)
                        started = i;
                    last = i;
                }
                if (started>-1)
                {
                    wdh.Add((byte)(w == 0 ? 1 : w));
                    of.Add(data.Count);
                    int bts = (w / 8) + (w % 8 == 0 ? 0 : 1);
                    if (bts == 0)
                        bts = 1;
                    for (int k = 0; k < height; k++)
                    {
                        int f = 0;
                        for (int j = 0; j < w; j++)
                        {
                            Color c = bmp.GetPixel(wofs + j, hofs + k);
                            f <<= 1;
                            if (c.ToArgb() == Color.Black.ToArgb())
                                f |= 1;
                        }
                        f <<= bts * 8 - w;
                        for (int c = bts - 1; c >= 0; c--)
                            data.Add((byte)((f >> (c * 8)) & 0xFF));
                    }
                }
                wofs += width + 1;
            }
            fromletter = (byte)started;
            lcount = (byte)(last - fromletter+1);
            data.RemoveRange(of[lcount],data.Count-of[lcount]);
            of.RemoveRange(lcount, of.Count - lcount);
            wdh.RemoveRange(lcount, wdh.Count - lcount);
            fdata = data.ToArray();
            widths = wdh;
            ofs = of;
            pictureBox1.Image = mkBitmap();
            label2.Text = String.Format("letters={0:d} from={1:d}", lcount, fromletter);
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
                Bitmap bo = mkBitmap();
                if (bmp.Width == bo.Width && bmp.Height == bo.Height)
                {
                    setFont(bmp);
                }
                else
                    MessageBox.Show("Bad font bmp size");
            }
        }

        private void button3_Click(object sender, EventArgs e)
        {
            string fname = Common.getSaveName("fnt");
            if (fname == "")
                return;
            byte[] data = new byte[fdata.Length + lcount * 3];
            for (int i = 0; i < lcount; i++)
            {
                Common.writeInt16(data, i * 2, ofs[i]);
                data[lcount*2+i] = widths[i];
            }
            Array.Copy(fdata, 0, data, lcount * 3, fdata.Length);
            data = RBCompress.Compressor.compress(data);
            byte[] res = new byte[data.Length + 8];
            res[0] = 0xFF;
            res[1]=width;
            res[2]=height;
            res[3]=hz;
            res[4]=fromletter;
            res[5]=lcount;
            Common.writeInt16(res, 6, data.Length);
            Array.Copy(data, 0, res, 8, data.Length);
            data = Common.makeSections(new byte[][] { res }, new string[] { "FNT:" });
            FileStream fs = new FileStream(fname, FileMode.Create);
            fs.Write(data,0,data.Length);
            fs.Close();
        }
    }
}
