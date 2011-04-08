using System;
using System.Collections.Generic;
using System.Text;

namespace Vlure
{
    class Compressor
    {
        int bitcnt = 0;
        byte bits = 0;
        List<byte> bitbuf = new List<byte>();
        byte[] xbuf = new byte[0x400];
        List<byte> xr = new List<byte>();

        const int MIN_REP=3;

        void preparexbuf(byte[] data)
        {
            for (int i = 0; i < 0x400; i++)
                xbuf[i] = 0;
            int[,] cnts = new int[256, 256];
            byte al = data[0];
            int cnt = 0;
            for (int i = 1; i < data.Length; i++)
                if (al != data[i])
                {
                    if (cnt < MIN_REP)
                        cnts[al, al]++;
                    cnts[al, data[i]]++;
                    al = data[i];
                    cnt = 0;
                }
                else
                    cnt++;
            for (int i = 0; i < 256; i++)
            {
                int xmx = int.MaxValue;
                int xcnt = 0;
                for (int j = 0; j < 4 && xmx > 0; j++)
                {
                    int fcnt = xcnt;
                    int mx=0;
                    int idx=-1;
                    for (int k=0;k<256;k++)
                    {
                        int val=cnts[i,k];
                        if (val > mx && (val < xmx || (val == xmx && fcnt == 0)))
                        {
                            idx = k;
                            mx = val;
                        }
                        else if (val == xmx && fcnt > 0)
                            fcnt--;
                    }
                    if (mx == xmx)
                        xcnt++;
                    else
                        xcnt = 1;
                    xmx = mx;
                    if (idx>-1)
                        xbuf[(i << 2) + j] = (byte)idx;
                }
            }
        }

        void addbit(bool bit)
        {
            bits <<= 1;
            if (bit)
                bits |= 1;
            bitcnt ++;
            if (bitcnt == 8)
            {
                bitcnt = 0;
                bitbuf.Add(bits);
                bits = 0;
            }
        }

        void addbits(int bits, int len)
        {
            for (int i=0;i<len;i++)
                addbit(((bits>>i)&1)!=0);
        }

        void repeat(byte cnt)
        {
            addbits(2,2);
            xr.Add(cnt);
        }

        void slide(int bs,int ofs)
        {
            if (ofs == 0)
                addbits(0, 2);
            if (ofs == 1)
                addbits(1, 3);
            if (ofs == 2)
                addbits(5, 3);
            if (ofs == 3)
                addbits(3, 3);
        }

        void inplace(byte data)
        {
            addbits(7, 3);
            xr.Add(data);
        }

        void newbt(byte old, byte nw)
        {
            int bs = old << 2;
            bool done=false;
            for (int i=0;i<4 && !done;i++)
                if (xbuf[bs + i] == nw)
                {
                    done = true;
                    slide(bs, i);
                }
            if (!done)
                inplace(nw);
        }

        public byte[] runVGA(byte[] data)
        {
            preparexbuf(data);
            byte al = data[0];
            xr.Add(al);
            int c = 1;
            while (c < data.Length)
            {
                bool rep = data[c] == al;
                if (rep)
                    for (int i = 1; i < MIN_REP; i++)
                    {
                        if (c + i >= data.Length || data[c + i] != al)
                            rep = false;
                    }
                if (rep)
                {
                    int cnt = 0;
                    while (c < data.Length && data[c] == al && cnt < 255)
                    {
                        c++;
                        cnt++;
                    }
                    repeat((byte)cnt);
                }
                else
                {
                    newbt(al, data[c]);
                    al = data[c];
                    c++;
                }
            }
            repeat(0);
            xr.Add(0);
            while (bitcnt != 0)
                addbit(false);
            byte[] res = new byte[0x400 + 4 + bitbuf.Count + xr.Count];
            Array.Copy(xbuf, 0,res,0,0x400);
            bitbuf.CopyTo(res,0x404);
            int ofs = 0x404 + bitbuf.Count;
            xr.CopyTo(res, ofs);
            BinaryHelper.write_LE(res, 0x400, (uint)ofs);
            return res;
        }

        public byte[] run(byte[] data)
        {
            return runVGA(data);
        }

        public static byte[] compress(byte[] data)
        {
            return (new Compressor()).run(data);
        }
    }

    class Decompressor
    {
        byte[] xdata = null;
        List<byte> r = new List<byte>();
        uint d1 = 0;
        int btpos = 0;
        int btofs = 0x404;
        byte bitbuf=0;

        byte dssi() { return dssi(true); }
        byte dssi(bool incr)
        {
            if (d1 == xdata.Length)
            {
                if (incr) d1++;
                return 0;
            }
            byte res = xdata[d1];
            if (incr) d1++;
            return res;
        }

        void setBytes(byte val, int cnt)
        {
            for (int i = 0; i < cnt; i++)
                r.Add(val);
        }

        bool nextBt()
        {
            if (btpos == 0)
            {
                bitbuf = xdata[btofs];
                btofs++;
                btpos = 8;
            }
            btpos--;
            bool res=(bitbuf & 0x80) != 0;
            bitbuf<<=1;
            return res;
        }

        public byte[] run(byte[] data)
        {
            UInt16 v = BinaryHelper.readU16_BE(data,0);
            if ((v & 0xFFFE) == 0x140)
                return runEGA(data);
            else
                return runVGA(data);
        }

        public byte[] runEGA(byte[] data)
        {
            throw new NotImplementedException();
        }

        public byte[] runVGA(byte[] data)
        {
            xdata = data;
            d1 = BinaryHelper.readU32_LE(data, 0x400);

            byte al = dssi();
            r.Add(al);
            Int16 bp = (Int16)(al << 2);
            while (true)
            {
                int l = 0;
                bool nbp = true;
                if (nextBt())
                {
                    if (nextBt())
                    {
                        if (nextBt())
                        {
                            al = dssi();
                            r.Add(al);
                            bp = (Int16)(al << 2);
                            nbp = false;
                        }
                        else
                            l = 3;
                    }else if (nextBt())
                        l = 2;
                    else
                        l = 1;
                }else
                if (nextBt())
                {
                    al = (byte)(bp >> 2);
                    byte ah=dssi();
                    if (ah==0)
                    {
                        al=dssi();
                        if (al==0)
                            return r.ToArray();
                    }else{
                        setBytes(al,ah);
                    }
                    nbp = false;
                }
                if (nbp)
                {
                    al=xdata[bp+l];
                    r.Add(al);
                    bp=(Int16)(al << 2);
                }
            }
            throw new Exception("cant be here");
            //return r.ToArray();
        }

        public static byte[] decompress(byte[] data)
        {
            return (new Decompressor().run(data));
        }
    }
}
