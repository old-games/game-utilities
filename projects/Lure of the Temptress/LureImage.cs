using System;
using System.Collections.Generic;
using System.Text;
using System.Drawing;
using System.Drawing.Imaging;

namespace Vlure
{
    class LureFont
    {
        public int resnum = -1;
        byte[] data;
        public LureFont(int resnum)
        {
            this.resnum = resnum;
            data = LureDisks.getResource(resnum);
        }

        public Bitmap export()
        {
            Bitmap bmp = new Bitmap(61*8,16);
            int cnt = 122;
            if (LureConfig.get().lang_id == 6)
                cnt = 115;
            for (int i=0;i<cnt;i++)
                for (int j=0;j<8;j++)
                {
                    byte ln = data[i * 8+j];
                    int xofs = i * 8-(i<61?0:61*8);
                    for (int k = 0; k < 8; k++)
                    {
                        bool bit = (((ln >> (8 - 1 - k)) & 1) == 1);
                        bmp.SetPixel(xofs+k,j+(i<61?0:8),bit?Color.Black:Color.White);
                    }
                }
            return bmp;
        }
        public void import(Bitmap bmp)
        {
            if (bmp.Width!=61*8 || bmp.Height!=16)
                throw new Exception("bad font bmp");
            for (int i=0;i<122;i++)
                for (int j=0;j<8;j++)
                {
                    byte ln = 0;
                    int xofs = i * 8-(i<61?0:61*8);
                    for (int k = 0; k < 8; k++)
                    {
                        Color cl=bmp.GetPixel(xofs+k,j+(i<61?0:8));
                        if (cl.ToArgb()==Color.Black.ToArgb())
                            ln|=(byte)(1<<(8-1-k));
                    }
                    data[i * 8+j]=ln;
                }
            LureDisks.setResource(resnum, data);
        }
    }

    class LureImage
    {
        byte[] xdata = null;
        public int resnum = -1;
        int width = 0, height = 0;
        string palette = "";
        public int unused = 0;
        public LureImage(int resnum,int w,int h,string pal)
        {
            this.resnum = resnum;
            width = w;
            height = h;
            palette = pal;
            //xdata = LureDisks.getResource(resnum);
            xdata = Decompressor.decompress(LureDisks.getResource(resnum));
            System.IO.FileStream f = new System.IO.FileStream("decoded.bin", System.IO.FileMode.Create);
            f.Write(xdata, 0, xdata.Length);
            f.Close();
        }

        public Bitmap export()
        {
            return export(width, height, palette);
        }
        public Bitmap export(int w, int h, string pal)
        {
            Bitmap bmp = new Bitmap(w, h, System.Drawing.Imaging.PixelFormat.Format8bppIndexed);
            ColorPalette tmppal = bmp.Palette;
            LureConfig.LurePalette p=LureConfig.get().getPalette(pal);
            for (int i = 0; i < 256; i++)
                tmppal.Entries[i] = p.cols[i];
            byte[] tdata = new byte[w * h];
            int xlen = xdata.Length;
            if (w * h < xlen)
                xlen = w * h;
            Array.Copy(xdata, 0, tdata, 0, xlen);
            unused = xdata.Length - xlen;
            while (xlen < tdata.Length)
                tdata[xlen++] = 0;
            bmp.Palette = tmppal;
            BitmapData bd = bmp.LockBits(new Rectangle(0, 0, w, h),
                ImageLockMode.WriteOnly, bmp.PixelFormat);
            for (int i = 0; i < bd.Height; i++)
                System.Runtime.InteropServices.Marshal.Copy(tdata, i * bd.Width, new IntPtr(bd.Scan0.ToInt64() + i * bd.Stride), bd.Width);
            bmp.UnlockBits(bd);
            return bmp;
        }
        public void import(Bitmap bmp)
        {
            if (bmp.Width != width || bmp.Height != height)
                throw new Exception(String.Format("Wrong bmp size {0}x{1} (need {2}x{3})",bmp.Width,bmp.Height,width,height));
            ColorPalette pal = bmp.Palette;
            LureConfig.LurePalette xpal = LureConfig.get().getPalette(palette);
            for (int i = 0; i < 256; i++)
                if (pal.Entries[i].ToArgb() != xpal.cols[i].ToArgb())
                    throw new Exception("Palette differs");
            byte[] res = new byte[width * height];
            BitmapData bd = bmp.LockBits(new Rectangle(0, 0, width, height),
                ImageLockMode.ReadWrite, bmp.PixelFormat);
            for (int i = 0; i < height; i++)
                System.Runtime.InteropServices.Marshal.Copy(new IntPtr(bd.Scan0.ToInt64() + i * bd.Stride), res, i * bd.Width, bd.Width);
            bmp.UnlockBits(bd);
            byte[] nr = Compressor.compress(res);
            LureDisks.setResource(resnum, nr);
        }
    }
}
