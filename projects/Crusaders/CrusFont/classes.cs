using System;
using System.Collections.Generic;
using System.IO;
using System.Drawing;

namespace CrusFont
{

    public class Section
    {
        public int sz;
        public int ofs;
        public int id;
        public Int16 cWidth;
        public Int16 cHeight;
        public Int16 cnt;
        public List<int[]> files = new List<int[]>();
        public byte[] data = null;
        int ho = 0;
        int minh = 0;
        int minw = 0;
        public Section(BinaryReader rd, int ofs, int sz, int id)
        {
            this.sz = sz;
            this.ofs = ofs;
            this.id = id;
            long pos = rd.BaseStream.Position;
            rd.BaseStream.Position = ofs;
            cWidth = rd.ReadInt16();
            cHeight = rd.ReadInt16();
            cnt = rd.ReadInt16();
            for (int i = 0; i < cnt; i++)
                files.Add(new int[] { rd.ReadInt32(), rd.ReadInt32() });
            data = new byte[sz];
            rd.BaseStream.Position = ofs;
            data = rd.ReadBytes(sz);
            rd.BaseStream.Position = pos;
        }
        public byte[] getFile(int id)
        {
            return getFile(files[id][0] & 0x7FFFFFFF, files[id][1]);
        }
        public byte[] getFile(int ofs, int sz)
        {
            byte[] res = new byte[sz];
            Array.Copy(data, ofs, res, 0, sz);
            return res;
        }

        public Bitmap image()
        {
            Bitmap bmp = new Bitmap(cWidth * 16 + 15, cHeight * 16 + 15);
            Graphics g = Graphics.FromImage(bmp);
            g.FillRectangle(new SolidBrush(Color.LightGray), 0, 0, bmp.Width, bmp.Height);
            Pen p = new Pen(Color.Gray);
            for (int i = 1; i < 16; i++)
            {
                g.DrawLine(p, (cWidth + 1) * i - 1, 0, (cWidth + 1) * i - 1, bmp.Height);
                g.DrawLine(p, 0, (cHeight + 1) * i - 1, bmp.Width, (cHeight + 1) * i - 1);
            }
            int xofs = 0;
            int yofs = -cHeight - 1;
            for (int i = 0; i < 256; i++)
            {
                if (i % 16 == 0)
                {
                    xofs = 0;
                    yofs += cHeight + 1;
                }
                if (i < cnt)
                {
                    Frame f = new Frame(getFile(i));
                    if (i == 0)
                    {
                        ho = f.ho;
                        minh = f.h;
                        minw = f.w;
                    }
                    else
                    {
                        if (ho != f.ho)
                            throw new Exception("Bad Font offset");
                        if (f.h != cHeight && f.h != 1)
                            throw new Exception(String.Format("Another height {0:d} vs {1:d}", f.h, cHeight));
                        if (f.h < minh) minh = f.h;
                        if (f.w < minw) minw = f.w;
                    }
                    Bitmap b = f.image();
                    g.DrawImage(b, xofs, yofs);
                }
                xofs += cWidth + 1;
            }
            return bmp;
        }

        public void import(Bitmap img)
        {
            Bitmap bo = image();
            if (bo.Width != img.Width || bo.Height != img.Height)
                throw new Exception("Wrong font bmp size");
            int hofs = -cHeight - 1;
            int wofs = 0;
            int last = 0;
            List<byte> xdata = new List<byte>();
            List<int[]> nfls = new List<int[]>();
            byte[] empty = null;
            for (int i = 0; i < 256; i++)
            {
                if (i % 16 == 0)
                {
                    hofs += cHeight + 1;
                    wofs = 0;
                }
                bool nwsp = false;
                int w = getW(img, wofs, hofs,ref nwsp);
                byte[] ldt = null;
                if (w > 0)
                    last = i;
                if (w >1 || nwsp)
                    ldt = importLetter(img, wofs, hofs, w);
                else
                {
                    if (empty == null)
                        empty = importEmpty();
                    ldt = empty;
                }
                nfls.Add(new int[] { xdata.Count, ldt.Length });
                foreach (byte b in ldt)
                    xdata.Add(b);
                wofs += cWidth + 1;
            }
            if (last < 255)
            {
                nfls.RemoveRange(last+1, nfls.Count - last-1);
                int lofs = nfls[last][0] + nfls[last][1];
                xdata.RemoveRange(lofs, xdata.Count - lofs);
            }
            cnt = (short)nfls.Count;
            BinaryWriter wr = new BinaryWriter(new MemoryStream());
            wr.Write(cWidth);
            wr.Write(cHeight);
            wr.Write(cnt);
            for (int i = 0; i < nfls.Count; i++)
            {
                nfls[i][0] += 6 + 8 * cnt;
                wr.Write(nfls[i][0]);
                wr.Write(nfls[i][1]);
            }
            wr.Write(xdata.ToArray());
            files = nfls;
            data = new byte[wr.BaseStream.Length];
            wr.BaseStream.Position = 0;
            wr.BaseStream.Read(data, 0,data.Length);
            wr.Close();
            sz = data.Length;
        }

        public int getW(Bitmap bmp, int wofs, int hofs,ref bool nwsp)
        {
            int w = 0;
            for (int i = 0; i < cHeight; i++)
                for (int j = 0; j < cWidth; j++)
                {
                    Color c = bmp.GetPixel(wofs + j, hofs + i);
                    if (c.ToArgb() == Color.White.ToArgb() || c.R == 0)
                    {
                        if (c.ToArgb() != Color.White.ToArgb())
                            nwsp = true;
                        if (w < j + 1)
                            w = j + 1;
                    }
                }
            return w;
        }

        byte[] makeLetter(List<int> hofs, byte[] dt, int w, int h, bool comp)
        {
            BinaryWriter wr = new BinaryWriter(new MemoryStream());
            wr.Write((int)(comp ? 1 : 0));
            wr.Write(w);
            wr.Write(h);
            wr.Write((int)0);
            wr.Write(ho);
            for (int i = 0; i < h; i++)
                wr.Write(hofs[i]);
            wr.Write(dt);
            byte[] res = new byte[wr.BaseStream.Length];
            wr.BaseStream.Position = 0;
            wr.BaseStream.Read(res, 0, res.Length);
            wr.Close();
            return res;
        }

        byte[] compress(byte[] dt)
        {
            List<byte> res = new List<byte>();
            res.Add(0);
            int szofs = 0;
            int pos = 0;
            int ncomp=0;
            while (pos < dt.Length)
            {
                int cnt = 1;
                int xpos = pos+1;
                int last = 2;
                while (xpos < dt.Length && dt[pos] == dt[xpos++])
                    cnt++;
                if (xpos == dt.Length)
                    if (dt[xpos-1]==dt[pos])
                        last = 0;
                if (cnt > 1 + ncomp + last)
                {
                    if (ncomp != 0)
                    {
                        res.Add(0);
                        res.Add((byte)((cnt<<1)|1));
                        ncomp = 0;
                    }
                    else
                        res[szofs] = ((byte)((cnt << 1) | 1));
                    res.Add(dt[pos]);
                    pos += cnt;
                    if (last!=0)
                    {
                        res.Add(0);
                        res.Add(0);
                        szofs = res.Count - 1;
                    }
                }
                else
                {
                    ncomp = 2;
                    res[szofs]+=2;
                    res.Add(dt[pos]);
                    pos++;
                }
            }
            return res.ToArray();
        }

        void makeLine(byte[] data, int w, List<byte> ucmp, List<byte> cmp)
        {
            int xpos = 0;
            byte of = 0;
            while (xpos < w)
            {
                of = 0;
                while (xpos < w && data[xpos] == 0xFF)
                {
                    of++;
                    xpos++;
                }
                ucmp.Add(of);
                cmp.Add(of);
                of = 0;
                List<byte> xdata = new List<byte>();
                while (xpos < w && data[xpos] != 0xFF)
                {
                    xdata.Add(data[xpos]);
                    of++;
                    xpos++;
                }
                if (xdata.Count > 0)
                {
                    foreach (byte b in compress(xdata.ToArray()))
                        cmp.Add(b);
                    ucmp.Add(of);
                    foreach (byte b in xdata)
                        ucmp.Add(b);
                }
            }
        }

        byte[] importEmpty()
        {
            List<int> hofs = new List<int>();
            for (int i = 0; i < minh; i++)
                hofs.Add((minh - i) * 4);
            return makeLetter(hofs, new byte[] { 1 }, 1, minh, false);
        }

        bool match(byte[] a, byte[] b, int w)
        {
            bool match = true;
            for (int i = 0; i < w && match; i++)
                if (a[i] != b[i])
                    match = false;
            return match;
        }

        byte[] importLetter(Bitmap img, int wofs, int hofs, int w)
        {
            List<byte> ucmp = new List<byte>();
            List<byte> cmp = new List<byte>();
            List<byte[]> lines = new List<byte[]>();
            List<int> lines_ofsc = new List<int>();
            List<int> lines_ofsuc = new List<int>();
            List<int> hofsuc = new List<int>();
            List<int> hofsc = new List<int>();
            byte[] data = new byte[w];
            for (int i = 0; i < cHeight; i++)
            {
                for (int j = 0; j < w; j++)
                {
                    Color col = img.GetPixel(wofs + j, hofs + i);
                    byte b = 0;
                    if (col.ToArgb() == Color.White.ToArgb() || col.R != 0)
                        b = 0xFF;
                    else
                    {
                        b = (byte)((col.B & 0xF0) | ((col.G & 0xF0) >> 4));
                        if (b == 0xFF)
                            b = 0xFE;
                    }
                    data[j] = b;
                }
                int lid = -1;
                for (int j = 0; j < lines.Count && lid == -1; j++)
                    if (match(lines[j], data, w))
                        lid = j;
                if (lid == -1)
                {
                    byte[] line = new byte[w];
                    Array.Copy(data,line,w);
                    lines.Add(line);
                    lines_ofsc.Add(cmp.Count);
                    lines_ofsuc.Add(ucmp.Count);
                    lid = lines.Count - 1;
                    makeLine(data, w, ucmp, cmp);
                }
                hofsc.Add(lines_ofsc[lid] + (cHeight - i) * 4);
                hofsuc.Add(lines_ofsuc[lid] + (cHeight - i) * 4);
            }
            if (cmp.Count < ucmp.Count)
                return makeLetter(hofsc, cmp.ToArray(), w, cHeight, true);
            return makeLetter(hofsuc, ucmp.ToArray(), w, cHeight, false);
        }

    }

    public class Frame
    {
        List<int> ofs = new List<int>();
        public int w = 0;
        public int h = 0;
        public int wo = 0;
        public int ho = 0;
        public int comp = 0;
        byte[] imgdata;
        public Frame(byte[] data)
        {
            BinaryReader rd = new BinaryReader(new MemoryStream(data));
            comp = rd.ReadInt32();
            w = rd.ReadInt32();
            h = rd.ReadInt32();
            wo = rd.ReadInt32();
            ho = rd.ReadInt32();
            for (int i = 0; i < h; i++)
            {
                ofs.Add(rd.ReadInt32() - (h - i) * 4);
            }
            imgdata = new byte[data.Length - rd.BaseStream.Position];
            Array.Copy(data, data.Length - imgdata.Length, imgdata, 0, imgdata.Length);
            rd.Close();
        }

        public Bitmap image()
        {
            Bitmap res = new Bitmap(w, h);
            for (int i = 0; i < h; i++)
                for (int j = 0; j < w; j++)
                {
                    int col = getCol(j, i);
                    res.SetPixel(j, i, col == 0xFF ? Color.White : Color.FromArgb(0, (col << 4) & 0xF0, col & 0xF0));
                }
            return res;
        }

        public byte getCol(int x, int y)
        {
            if (x < 0 || x >= w || y < 0 || y >= h)
                return 0xFF;
            int spos = ofs[y];
            int xpos = 0;
            do
            {
                xpos += imgdata[spos++];
                if (xpos == w || xpos > x) break;
                int dlen = imgdata[spos++];
                int type = 0;

                if (comp != 0)
                {
                    type = dlen & 1;
                    dlen >>= 1;
                }

                if (x >= xpos && x < xpos + dlen)
                {
                    if (type == 0)
                        spos += x - xpos;
                    return imgdata[spos];
                }

                xpos += dlen;
                if (type == 0)
                    spos += dlen;
                else
                    spos++;
            } while (xpos < w);
            return 0xFF;
        }

    }

}