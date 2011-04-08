using System;
using System.Collections.Generic;

namespace RBCompress
{

    public class BinHelper
    {
        public static UInt32 readUInt32(byte[] data, int pos)
        {
            UInt32 res = 0;
            res = (UInt32)(data[pos] + (data[pos + 1] << 8) + (data[pos + 3] << 16) + (data[pos + 2] << 24));
            return res;
        }
        public static void writeUint32(byte[] data, int ofs, UInt32 val)
        {
            data[ofs] = (byte)(val & 0xFF);
            data[ofs+1] = (byte)((val>>8) & 0xFF);
            data[ofs + 2] = (byte)((val >> 16) & 0xFF);
            data[ofs + 3] = (byte)((val >> 24) & 0xFF);
        }
        public static void writeUint32(List<byte> data, UInt32 val)
        {
            data.Add((byte)(val & 0xFF));
            data.Add((byte)((val >> 8) & 0xFF));
            data.Add((byte)((val >> 16) & 0xFF));
            data.Add((byte)((val >> 24) & 0xFF));
        }
    }

    public class Compressor
    {
        struct Match
        {
            public Match(int sz, byte[] dt, int ofs)
            {
                size = sz;
                data = new byte[sz];
                Array.Copy(dt, ofs, data, 0, sz);
            }
            public int size;
            public byte[] data;
        }

        List<byte> res;
        int bitbuf=0;
        int bpos=0;
        int bits = 0;
        int exc = 0;
        List<Match> matches = new List<Match>();

        public void addMatch(byte[] data,int ofs,int sz)
        {
            if (data.Length <= ofs + sz)
                return;
            if (matches.Count < 0xEFE)
            {
                matches.Add(new Match(sz, data, ofs));
                if (matches.Count == 0x100 || matches.Count==0x100*3 || matches.Count==0x100*7)
                    bits++;
            }
        }

        public void clear()
        {
            writeBits(0x100);
            if (bpos != 0)
                writeBits(0, 8 - bpos);
            while (exc != 0)
                writeBits(0,8);
            bitbuf = 0;
            bits = 9;
            matches.Clear();
            exc = 0;
        }

        public int findMatch(byte[] data,int ofs)
        {
            int bestid = -1;
            int bestsz = 1;
            //search
            for (int i = 0; i < matches.Count; i++)
            {
                if (matches[i].size >= bestsz && matches[i].size<=data.Length-ofs)
                {
                    bool m=true;
                    for (int j = 0; j < matches[i].size && m && data.Length>ofs+j; j++)
                        if (matches[i].data[j] != data[ofs + j])
                            m = false;
                    if (m)
                    {
                        bestid = i;
                        bestsz = matches[i].size;
                    }
                }
            }
            if (bestid == -1)
            {
                writeBits(data[ofs]);
                addMatch(data, ofs, 2);
                return 1;
            }
            writeBits(0x100 + 1 + bestid);
            addMatch(data, ofs, bestsz + 1);
            return bestsz;
        }

        public void writeBits(int val,int bts=0)
        {
            if (bts == 0)
                bts = bits;
            bitbuf |= (val & ((1 << bts) - 1))<<bpos;
            bpos += bts;
            while (bpos >= 8)
            {
                res.Add((byte)(bitbuf&0xFF));
                exc++;
                if (exc == bits)
                    exc = 0;
                bitbuf >>= 8;
                bpos -= 8;
            }
        }

        public byte[] run(byte[] data)
        {
            res = new List<byte>();
            res.Add(2);
            BinHelper.writeUint32(res, (uint)data.Length);
            bits = 9;
            int dpos = 0;
            writeBits(data[dpos++]);
            addMatch(data, 0, 2);
            int nmatch = 0;
            while (dpos < data.Length)
            {
                int sz=findMatch(data, dpos);
                dpos += sz;
                if (matches.Count == 0xEFE)
                {
                    if (sz < 2)
                        nmatch++;
                    else
                        nmatch = 0;
                    if (exc == bits - 3 || exc==bits-4 && nmatch>5)
                    {
                        clear();
                        nmatch = 0;
                    }
                }
            }
            if (bpos!=0)
                writeBits(0, 8-bpos);
            return res.ToArray();
        }

        public static byte[] compress(byte[] data)
        {
            return new Compressor().run(data);
        }
    }

    public class Decompressor
    {

        int dpos=0;
        int bpos = 0;
        int bitbuf = 0;
        int exc = 0;

        byte[] data = null;

        public int readBits(int bits)
        {
            while (bpos < bits)
            {
                if (dpos>data.Length)
                    throw new Exception("Not enought data");
                if (data.Length != dpos)
                {
                    bitbuf |= data[dpos++] << bpos;
                    exc++;
                    if (exc == bits)
                        exc = 0;
                }
                bpos += 8;
            }
            int msk = (1 << bits) - 1;
            int res = bitbuf & msk;
            bitbuf >>= bits;
            bpos -= bits;
            return res;
        }

        public byte[] run(byte[] data)
        {
            this.data = data;
            if (data[0] != 2)
                throw new Exception("Unknown compression type");
            UInt32 sz = BinHelper.readUInt32(data, 1);
            byte[] res = new byte[sz];
            dpos = 5;
            int rpos = 0;
            List<int> ofs = new List<int>();
            List<int> cnt = new List<int>();
            int bits = 9;
            int ocnt = 1;
            while (rpos < sz)
            {
                int r = readBits(bits);
                if (r < 0x100)
                {
                    if (ofs.Count < 0x1000)
                    {
                        ofs.Add(rpos);
                        cnt.Add(2);
                    }
                    res[rpos++] = (byte)r;
                }
                else if (r > 0x100)
                {
                    if (r <= 0x100+ofs.Count)
                    {
                        int ps = ofs[r - 0x100 - 1];
                        int c = cnt[r - 0x100 - 1];
                        if (ofs.Count<0x1000)
                        {
                            ofs.Add(rpos);
                            cnt.Add(c + 1);
                        }
                        for (int i = 0; i < c; i++)
                        {
                            res[rpos++] = res[ps++];
                            if (rpos == res.Length)
                                break;
                        }
                    }
                    else
                        throw new NotImplementedException();
                }
                else
                {
                    dpos += bits - exc;
                    bits = 9;
                    ocnt = 1;
                    ofs.Clear();
                    cnt.Clear();
                    bitbuf = 0;
                    bpos = 0;
                    exc = 0;
                }
                if (ofs.Count >= ocnt*0x100 && ocnt<0x0F)
                {
                    bits++;
                    ocnt <<= 1;
                    ocnt++;
                }
            }
            return res;
        }

        public static byte[] decompress(byte[] data)
        {
            return new Decompressor().run(data);
        }
    }
}
