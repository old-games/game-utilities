using System;

namespace BJFN.rnc
{


    class ByteHelper
    {
        // Methods
        public static uint READ_BE(byte[] data, int pos, int sz)
        {
            uint num = 0;
            for (int i = 0; i < sz; i++)
            {
                num = num << 8;
                num |= data[pos + i];
            }
            return num;
        }

        public static uint READ_LE(byte[] data, int pos, int sz)
        {
            uint num = 0;
            for (int i = 0; i < sz; i++)
            {
                num = num << 8;
                num |= data[((pos + sz) - 1) - i];
            }
            return num;
        }

        public static ushort Read16_be(byte[] data, int pos)
        {
            return (ushort)READ_BE(data, pos, 2);
        }

        public static ushort Read16_le(byte[] data, int pos)
        {
            return (ushort)READ_LE(data, pos, 2);
        }

        public static uint Read32_be(byte[] data, int pos)
        {
            return READ_BE(data, pos, 4);
        }

        public static uint Read32_le(byte[] data, int pos)
        {
            return READ_LE(data, pos, 4);
        }

        public static void Write_be(ushort value, byte[] data, int pos)
        {
            WRITE_BE(value, data, pos, 2);
        }

        public static void Write_be(uint value, byte[] data, int pos)
        {
            WRITE_BE(value, data, pos, 4);
        }

        public static void WRITE_BE(uint value, byte[] data, int pos, int sz)
        {
            for (int i = 0; i < sz; i++)
            {
                byte num2 = (byte)(value >> (((sz - i) - 1) * 8));
                data[pos + i] = num2;
            }
        }

        public static void Write_le(ushort value, byte[] data, int pos)
        {
            WRITE_LE(value, data, pos, 2);
        }

        public static void Write_le(uint value, byte[] data, int pos)
        {
            WRITE_LE(value, data, pos, 4);
        }

        public static void WRITE_LE(uint value, byte[] data, int pos, int sz)
        {
            for (int i = 0; i < sz; i++)
            {
                byte num2 = (byte)(value >> (((sz - i) - 1) * 8));
                data[((pos + sz) - i) - 1] = num2;
            }
        }
    }


    class BitBuffer
    {
        // Fields
        private int advsize = 2;
        private uint bitbuf;
        private int bitpos;
        private byte[] buf;
        private int pos;

        // Methods
        public BitBuffer(byte[] data, int pos)
        {
            this.buf = data;
            this.pos = pos;
            this.bitbuf = 0;
            this.bitpos = 0;
        }

        private void clearBuf(byte bits)
        {
            this.bitbuf = this.bitbuf >> bits;
            this.bitpos -= bits;
        }

        public byte[] getBytes(int length)
        {
            byte[] destinationArray = new byte[length];
            if (this.bitpos >= 0x10)
            {
                this.bitpos -= 0x10;
                this.bitbuf &= (uint)((((int)1) << this.bitpos) - 1);
                this.pos -= 2;
            }
            Array.Copy(this.buf, this.pos, destinationArray, 0, length);
            this.pos += length;
            return destinationArray;
        }

        private void normalizeBuf(byte bits)
        {
            while (bits > this.bitpos)
            {
                ushort num = 0;
                if ((this.pos + 1) == this.buf.Length)
                {
                    num = this.buf[this.buf.Length - 1];
                }
                else if (this.pos < this.buf.Length)
                {
                    num = ByteHelper.Read16_le(this.buf, this.pos);
                }
                this.pos += 2;
                this.bitbuf |= (uint)(num << this.bitpos);
                this.bitpos += 0x10;
            }
        }

        public uint peekBits(byte bits)
        {
            this.normalizeBuf(bits);
            return (this.bitbuf & ((uint)((((int)1) << bits) - 1)));
        }

        public uint readBits(byte bits)
        {
            uint num = this.peekBits(bits);
            this.clearBuf(bits);
            return num;
        }

        public void writeBits(uint value, byte bits)
        {
            this.bitbuf |= (uint)((value & ((1 << (bits & 0x1f)) - 1)) << (this.bitpos & 0x1f));
            this.bitpos += bits;
            while (this.bitpos >= 0x10)
            {
                ushort num = (ushort)(this.bitbuf & 0xffff);
                this.bitpos -= 0x10;
                this.bitbuf = this.bitbuf >> 0x10;
                ByteHelper.Write_le(num, this.buf, this.pos);
                this.pos += this.advsize;
                this.advsize = 2;
            }
        }

        public void writeBytes(byte[] data)
        {
            if (this.bitpos == 0)
            {
                Array.Copy(data, 0, this.buf, this.pos, data.Length);
                this.pos += data.Length;
            }
            else
            {
                Array.Copy(data, 0, this.buf, this.pos + this.advsize, data.Length);
                this.advsize += data.Length;
            }
        }

        public void writeEnd()
        {
            if (this.bitpos > 0)
            {
                this.writeBits(0, (byte)(0x10 - this.bitpos));
            }
        }

        // Properties
        public int position
        {
            get
            {
                return this.pos;
            }
        }
    }

    class RNCCommon
    {
        // Fields
        public const uint RNC_SIGNATURE = 0x524e4301;

        // Methods
        public static ushort crc(byte[] data, int pos, int size)
        {
            ushort num;
            ushort[] numArray = new ushort[0x100];
            for (ushort i = 0; i < 0x100; i = (ushort)(i + 1))
            {
                num = i;
                for (int k = 0; k < 8; k++)
                {
                    if ((num & 1) != 0)
                    {
                        num = (ushort)((num >> 1) ^ 0xa001);
                    }
                    else
                    {
                        num = (ushort)(num >> 1);
                    }
                }
                numArray[i] = num;
            }
            num = 0;
            for (int j = 0; j < size; j++)
            {
                num = (ushort)(num ^ data[pos + j]);
                num = (ushort)((num >> 8) ^ numArray[num & 0xff]);
            }
            return num;
        }

        public struct Huff
        {
            public byte len;
            public ushort code;
            public ushort value;
            public Huff(byte len, ushort code, ushort value)
            {
                this.len = len;
                this.code = code;
                this.value = value;
            }
        }
    }

}
