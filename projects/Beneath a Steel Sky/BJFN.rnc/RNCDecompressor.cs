using System;
using System.Collections.Generic;
using System.Text;

namespace BJFN.rnc
{
    public class RNCDecompressor
    {
        // Fields
        private BitBuffer bf;

        // Methods
        public static byte[] decompress(byte[] data)
        {
            return new RNCDecompressor().doDecompress(data);
        }

        public byte[] doDecompress(byte[] data)
        {
            if (ByteHelper.Read32_be(data, 0) != 0x524e4301)
            {
                throw new ExBadFormat("signature");
            }
            uint num2 = ByteHelper.Read32_be(data, 4);
            uint num3 = ByteHelper.Read32_be(data, 8);
            ushort num4 = ByteHelper.Read16_be(data, 12);
            ushort num5 = ByteHelper.Read16_be(data, 14);
            byte num6 = data[0x11];
            if (RNCCommon.crc(data, 0x12, (int)num3) != num5)
            {
                throw new ExBadCRC("packed");
            }
            this.bf = new BitBuffer(data, 0x12);
            byte[] destinationArray = new byte[num2];
            int index = 0;
            this.bf.readBits(2);
            do
            {
                RNCCommon.Huff[] table = this.makeHuffTable();
                RNCCommon.Huff[] huffArray2 = this.makeHuffTable();
                RNCCommon.Huff[] huffArray3 = this.makeHuffTable();
                ushort num8 = (ushort)this.bf.readBits(0x10);
                do
                {
                    uint num9 = this.inputValue(table);
                    if (num9 > 0)
                    {
                        Array.Copy(this.bf.getBytes((int)num9), 0L, destinationArray, (long)index, (long)num9);
                        index += (int)num9;
                    }
                    if (num8 > 1)
                    {
                        uint num10 = (uint)(this.inputValue(huffArray2) + 1);
                        num9 = (uint)(this.inputValue(huffArray3) + 2);
                        while (num9-- > 0)
                        {
                            destinationArray[index] = destinationArray[(int)((IntPtr)(index - num10))];
                            index++;
                        }
                    }
                }
                while ((num8 = (ushort)(num8 - 1)) != 0);
                if (num6 > 0)
                {
                    num6 = (byte)(num6 - 1);
                }
            }
            while (num6 > 0);
            if (RNCCommon.crc(destinationArray, 0, destinationArray.Length) != num4)
            {
                throw new ExBadCRC("unpacked");
            }
            return destinationArray;
        }

        private ushort inputValue(RNCCommon.Huff[] table)
        {
            int index = 0;
            while (table[index].code != this.bf.peekBits(table[index].len))
            {
                index++;
            }
            this.bf.readBits(table[index].len);
            ushort num2 = table[index].value;
            if (num2 >= 2)
            {
                num2 = (ushort)(num2 - 1);
                ushort num = (ushort)this.bf.readBits((byte)num2);
                num = (ushort)(num | ((ushort)(((int)1) << num2)));
                num2 = num;
            }
            return num2;
        }

        private RNCCommon.Huff[] makeHuffTable()
        {
            List<RNCCommon.Huff> list = new List<RNCCommon.Huff>();
            ushort num = (ushort)this.bf.readBits(5);
            if (num == 0)
            {
                throw new ExBadFormat("Huff table");
            }
            byte[] buffer = new byte[0x10];
            for (int i = 0; i < num; i++)
            {
                buffer[i] = (byte)this.bf.readBits(4);
            }
            ushort num3 = 0;
            for (ushort j = 1; j < 0x11; j = (ushort)(j + 1))
            {
                for (ushort k = 0; k < num; k = (ushort)(k + 1))
                {
                    if (buffer[k] == j)
                    {
                        byte len = (byte)j;
                        ushort num7 = (ushort)(num3 >> (0x10 - j));
                        ushort code = 0;
                        for (int m = 0; m < j; m++)
                        {
                            code = (ushort)(code | ((ushort)(((num7 >> (m & 0x1f)) & 1) << ((j - m) - 1))));
                        }
                        ushort num10 = (ushort)(k & 0xff);
                        num3 = (ushort)(num3 + ((ushort)(((int)1) << (0x10 - j))));
                        list.Add(new RNCCommon.Huff(len, code, num10));
                    }
                }
            }
            return list.ToArray();
        }

        // Nested Types
        public class ExBadCRC : ApplicationException
        {
            // Methods
            public ExBadCRC(string where)
                : base("Bad CRC at " + where)
            {
            }
        }

        public class ExBadFormat : ApplicationException
        {
            // Methods
            public ExBadFormat(string where)
                : base("Bad RNC Format at " + where)
            {
            }
        }
    }

}
