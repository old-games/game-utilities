using System;
using System.Collections.Generic;

namespace bassru_patcher
{
    public class RNCCompressor
    {
        // Fields
        private BitBuffer bf;
        private const int BLOCK_SIZE = 0x1000;
        private int cpos;
        private byte[] ibuf;
        private int ipos;
        private const int MAX_OFS = 0x7fff;
        private const int MAX_TUPLES = 0x1000;
        private int tid;
        private List<Tuple> tup;
        private const int WIN_SIZE = 0x3000;

        // Methods
        private ushort bitLen(uint value)
        {
            ushort num = 0;
            while (value != 0)
            {
                value = value >> 1;
                num = (ushort)(num + 1);
            }
            return num;
        }

        public static byte[] compress(byte[] data)
        {
            return new RNCCompressor().doCompress(data);
        }

        public byte[] doCompress(byte[] data)
        {
            byte[] buffer = new byte[data.Length];
            ByteHelper.WRITE_BE((uint)0x524e4301, buffer, 0);
            ByteHelper.WRITE_BE((uint)data.Length, buffer, 4);
            ByteHelper.WRITE_BE(RNCCommon.crc(data, 0, data.Length), buffer, 12);
            this.bf = new BitBuffer(buffer, 0x12);
            byte num = 0;
            this.bf.writeBits(0, 2);
            this.ibuf = data;
            this.ipos = 0;
            while (this.ipos < this.ibuf.Length)
            {
                Tuple[] block = this.makeBlock();
                this.writeBlock(block);
                num = (byte)(num + 1);
            }
            this.bf.writeEnd();
            Array.Resize<byte>(ref buffer, this.bf.position);
            ByteHelper.WRITE_BE((uint)(buffer.Length - 0x12), buffer, 8);
            ByteHelper.WRITE_BE(RNCCommon.crc(buffer, 0x12, buffer.Length - 0x12), buffer, 14);
            buffer[0x10] = 0;
            buffer[0x11] = num;
            return buffer;
        }

        private void emit_pair(int ofs, int len)
        {
            Tuple tuple = this.getTuple(this.tup, this.tid);
            tuple.ofs = (ushort)ofs;
            tuple.len = (ushort)len;
            this.tup[this.tid] = tuple;
            this.tid++;
            this.cpos += len;
            this.getTuple(this.tup, this.tid);
        }

        private void emit_raw(int len)
        {
            Tuple tuple = this.getTuple(this.tup, this.tid);
            byte[] rawdata = tuple.rawdata;
            tuple.rawdata = new byte[len + rawdata.Length];
            Array.Copy(rawdata, tuple.rawdata, rawdata.Length);
            Array.Copy(this.ibuf, this.cpos, tuple.rawdata, rawdata.Length, len);
            this.tup[this.tid] = tuple;
            this.cpos += len;
        }

        private int findSequence(int pos, ref int length, int maxpos)
        {
            if (pos == 0)
            {
                return 0;
            }
            int num = pos - 0x7fff;
            if (num < 0)
            {
                num = 0;
            }
            int num2 = 2;
            int num3 = 0;
            int num4 = 1;
            int num5 = 0;
            while (((pos - num4) >= num) && (num2 < 0x1000))
            {
                num5 = 0;
                int index = pos;
                int num7 = index - num4;
                while (((index < maxpos) && (this.ibuf[index] == this.ibuf[num7])) && (num5 < 0x1000))
                {
                    index++;
                    num7++;
                    num5++;
                }
                if (num5 > num2)
                {
                    num2 = num5;
                    num3 = num4;
                }
                num4++;
            }
            length = num2;
            return num3;
        }

        private Tuple getTuple(List<Tuple> tup, int tid)
        {
            while ((tup.Count - 1) < tid)
            {
                Tuple item = new Tuple();
                item.rawdata = new byte[0];
                item.len = (ushort)(item.ofs = 0);
                tup.Add(item);
            }
            return tup[tid];
        }

        private bool isbetter(int nl, int no, int l, int o)
        {
            if (nl < l)
            {
                return false;
            }
            return (((nl > l) && ((no - 0x800) < o)) || (((nl > (l + 1)) && ((no - 0x1000) < o)) || (nl > (l + 2))));
        }

        private Tuple[] makeBlock()
        {
            this.tup = new List<Tuple>();
            this.tid = 0;
            this.cpos = this.ipos;
            int no = 0;
            int length = 0;
            int len = 0;
            int l = 0;
            int o = 0;
            int maxpos = this.ipos + 0x3000;
            if (maxpos > this.ibuf.Length)
            {
                maxpos = this.ibuf.Length;
            }
            while ((this.cpos < maxpos) && (this.tid < 0xfff))
            {
                if ((maxpos - this.cpos) < 3)
                {
                    this.emit_raw(maxpos - this.cpos);
                }
                else
                {
                    no = this.findSequence(this.cpos + len, ref length, maxpos);
                    if (len > 0)
                    {
                        if ((no > 0) && this.isbetter(length, no, l, o))
                        {
                            this.emit_raw(len);
                            len = 1;
                            o = no;
                            l = length;
                        }
                        else if ((this.cpos + l) >= (this.ipos + 0x3000))
                        {
                            maxpos = this.cpos;
                        }
                        else
                        {
                            this.emit_pair(o, l);
                            len = o = l = 0;
                        }
                        continue;
                    }
                    if (length > 2)
                    {
                        len = 1;
                        l = length;
                        o = no;
                    }
                    else
                    {
                        this.emit_raw(1);
                    }
                }
            }
            this.ipos = this.cpos;
            return this.tup.ToArray();
        }

        private RNCCommon.Huff[] makeHuffTable(ushort[] freq)
        {
            huffNode[] nodeArray = new huffNode[0x20];
            List<RNCCommon.Huff> list = new List<RNCCommon.Huff>();
            int index = 0;
            for (int i = 0; i < 0x10; i++)
            {
                if (freq[i] > 0)
                {
                    nodeArray[index].freq = freq[i];
                    nodeArray[index].parent = nodeArray[index].lchild = -1;
                    nodeArray[index].rchild = i;
                    index++;
                }
            }
            int num3 = index;
            if (num3 == 1)
            {
                num3 = 2;
            }
            while (num3 > 1)
            {
                int num4 = 0x7ffffffe;
                int num5 = 0x7fffffff;
                int num6 = 0;
                int num7 = 0;
                for (int num8 = 0; num8 < index; num8++)
                {
                    if (nodeArray[num8].parent == -1)
                    {
                        if (num4 > nodeArray[num8].freq)
                        {
                            num5 = num4;
                            num7 = num6;
                            num4 = nodeArray[num8].freq;
                            num6 = num8;
                        }
                        else if (num5 > nodeArray[num8].freq)
                        {
                            num5 = nodeArray[num8].freq;
                            num7 = num8;
                        }
                    }
                }
                nodeArray[index].freq = num4 + num5;
                nodeArray[index].parent = -1;
                nodeArray[index].lchild = num6;
                nodeArray[index].rchild = num7;
                nodeArray[num6].parent = nodeArray[num7].parent = index;
                index++;
                num3--;
            }
            int num9 = 0;
            for (int j = 0; j < 0x10; j++)
            {
                list.Add(new RNCCommon.Huff(0, 0, 0));
            }
            for (int k = 0; k < index; k++)
            {
                if (nodeArray[k].lchild == -1)
                {
                    int num12 = 0;
                    for (num3 = k; nodeArray[num3].parent != -1; num3 = nodeArray[num3].parent)
                    {
                        num12++;
                    }
                    RNCCommon.Huff huff = list[nodeArray[k].rchild];
                    huff.value = (ushort)nodeArray[k].rchild;
                    huff.len = (byte)num12;
                    list[nodeArray[k].rchild] = huff;
                    if (num9 < num12)
                    {
                        num9 = num12;
                    }
                }
            }
            ushort num13 = 0;
            for (int m = 1; m <= num9; m++)
            {
                for (index = 0; index < 0x10; index++)
                {
                    if (list[index].len == m)
                    {
                        ushort num15 = (ushort)(num13 >> (0x10 - m));
                        ushort num16 = 0;
                        for (int num17 = 0; num17 < m; num17++)
                        {
                            num16 = (ushort)(num16 | ((ushort)(((num15 >> (num17 & 0x1f)) & 1) << ((m - num17) - 1))));
                        }
                        RNCCommon.Huff huff2 = list[index];
                        huff2.code = num16;
                        list[index] = huff2;
                        num13 = (ushort)(num13 + ((ushort)(((int)1) << (0x10 - m))));
                    }
                }
            }
            for (int n = list.Count - 1; (list[n].len == 0) && (list.Count > 1); n--)
            {
                list.RemoveAt(n);
            }
            return list.ToArray();
        }

        private void writeBlock(Tuple[] block)
        {
            ushort[] freq = new ushort[0x10];
            for (int i = 0; i < 0x10; i++)
            {
                freq[i] = 0;
            }
            for (int j = 0; j < block.Length; j++)
            {
                freq[this.bitLen((ushort)block[j].rawdata.Length)] = (ushort)(freq[this.bitLen((ushort)block[j].rawdata.Length)] + 1);
            }
            RNCCommon.Huff[] table = this.makeHuffTable(freq);
            this.writeHuff(table);
            for (int k = 0; k < 0x10; k++)
            {
                freq[k] = 0;
            }
            for (int m = 0; m < (block.Length - 1); m++)
            {
                freq[this.bitLen((ushort)(block[m].ofs - 1))] = (ushort)(freq[this.bitLen((ushort)(block[m].ofs - 1))] + 1);
            }
            RNCCommon.Huff[] huffArray2 = this.makeHuffTable(freq);
            this.writeHuff(huffArray2);
            for (int n = 0; n < 0x10; n++)
            {
                freq[n] = 0;
            }
            for (int num6 = 0; num6 < (block.Length - 1); num6++)
            {
                freq[this.bitLen((ushort)(block[num6].len - 2))] = (ushort)(freq[this.bitLen((ushort)(block[num6].len - 2))] + 1);
            }
            RNCCommon.Huff[] huffArray3 = this.makeHuffTable(freq);
            this.writeHuff(huffArray3);
            this.bf.writeBits((uint)block.Length, 0x10);
            for (int num7 = 0; num7 < block.Length; num7++)
            {
                this.writeHuffValue(table, (ushort)block[num7].rawdata.Length);
                if (block[num7].rawdata.Length > 0)
                {
                    this.bf.writeBytes(block[num7].rawdata);
                }
                if (num7 < (block.Length - 1))
                {
                    this.writeHuffValue(huffArray2, (ushort)(block[num7].ofs - 1));
                    this.writeHuffValue(huffArray3, (ushort)(block[num7].len - 2));
                }
            }
        }

        private void writeHuff(RNCCommon.Huff[] table)
        {
            this.bf.writeBits((uint)table.Length, 5);
            for (int i = 0; i < table.Length; i++)
            {
                this.bf.writeBits(table[i].len, 4);
            }
        }

        private void writeHuffValue(RNCCommon.Huff[] table, ushort value)
        {
            int index = this.bitLen(value);
            this.bf.writeBits(table[index].code, table[index].len);
            if (index > 1)
            {
                this.bf.writeBits(value, (byte)(index - 1));
            }
        }

        // Nested Types
        public class ExBadData : ApplicationException
        {
            // Methods
            public ExBadData(string where)
                : base("BAD DATA AT " + where)
            {
            }
        }

        private struct huffNode
        {
            public int freq;
            public int parent;
            public int lchild;
            public int rchild;
        }

        private struct Tuple
        {
            public byte[] rawdata;
            public ushort ofs;
            public ushort len;
        }
    }

}
