using System;

namespace bassru_patcher
{

    public class ByteHelper
    {
        public static UInt16 READ_UINT16_LE(byte[] buf, int pos)
        {
            return (UInt16)((buf[pos + 1] << 8) | buf[pos]);
        }
        public static UInt16 READ_UINT16_LE(byte[] buf)
        {
            return READ_UINT16_LE(buf, 0);
        }
        public static Int16 READ_INT16_LE(byte[] buf, int pos)
        {
            return (Int16)READ_UINT16_LE(buf, pos);
        }
        public static Int16 READ_INT16_LE(byte[] buf)
        {
            return (Int16)READ_UINT16_LE(buf, 0);
        }
        public static UInt16 READ_UINT16_BE(byte[] buf, int pos)
        {
            return (UInt16)((buf[pos] << 8) | buf[pos + 1]);
        }
        public static UInt16 READ_UINT16_BE(byte[] buf)
        {
            return READ_UINT16_BE(buf, 0);
        }
        public static Int16 READ_INT16_BE(byte[] buf, int pos)
        {
            return (Int16)READ_UINT16_BE(buf, pos);
        }
        public static Int16 READ_INT16_BE(byte[] buf)
        {
            return (Int16)READ_UINT16_BE(buf, 0);
        }

        public static UInt32 READ_UINT24_LE(byte[] buf, int pos)
        {
            return (UInt32)((buf[pos + 2] << 16) | (buf[pos + 1] << 8) | buf[pos]);
        }
        public static UInt32 READ_UINT24_LE(byte[] buf)
        {
            return READ_UINT24_LE(buf, 0);
        }
        public static Int32 READ_INT24_LE(byte[] buf, int pos)
        {
            return (Int32)READ_UINT24_LE(buf, pos);
        }
        public static Int32 READ_INT24_LE(byte[] buf)
        {
            return (Int32)READ_UINT24_LE(buf, 0);
        }
        public static UInt32 READ_UINT24_BE(byte[] buf, int pos)
        {
            return (UInt32)((buf[pos] << 16) | (buf[pos + 1] << 8) | buf[pos + 2]);
        }
        public static UInt32 READ_UINT24_BE(byte[] buf)
        {
            return READ_UINT24_BE(buf, 0);
        }
        public static Int32 READ_INT24_BE(byte[] buf, int pos)
        {
            return (Int32)READ_UINT24_BE(buf, pos);
        }
        public static Int32 READ_INT24_BE(byte[] buf)
        {
            return (Int32)READ_UINT24_BE(buf, 0);
        }

        public static UInt32 READ_UINT32_LE(byte[] buf, int pos)
        {
            return (UInt32)((buf[pos + 3] << 24) | (buf[pos + 2] << 16) | (buf[pos + 1] << 8) | buf[pos]);
        }
        public static UInt32 READ_UINT32_LE(byte[] buf)
        {
            return READ_UINT32_LE(buf, 0);
        }
        public static Int32 READ_INT32_LE(byte[] buf, int pos)
        {
            return (Int32)READ_UINT32_LE(buf, pos);
        }
        public static Int32 READ_INT32_LE(byte[] buf)
        {
            return (Int32)READ_UINT32_LE(buf, 0);
        }
        public static UInt32 READ_UINT32_BE(byte[] buf, int pos)
        {
            return (UInt32)((buf[pos] << 24) | (buf[pos + 1] << 16) | (buf[pos + 2] << 8) | buf[pos + 3]);
        }
        public static UInt32 READ_UINT32_BE(byte[] buf)
        {
            return READ_UINT32_BE(buf, 0);
        }
        public static Int32 READ_INT32_BE(byte[] buf, int pos)
        {
            return (Int32)READ_UINT32_BE(buf, pos);
        }
        public static Int32 READ_INT32_BE(byte[] buf)
        {
            return (Int32)READ_UINT32_BE(buf, 0);
        }

        public static void WRITE_LE(UInt32 value, int size, byte[] buf, int pos)
        {
            for (int i = 0; i < size; i++)
            {
                buf[pos + i] = (byte)(value & 0xFF);
                value >>= 8;
            }
        }
        public static void WRITE_BE(UInt32 value, int size, byte[] buf, int pos)
        {
            for (int i = 0; i < size; i++)
            {
                buf[pos + size - 1 - i] = (byte)(value & 0xFF);
                value >>= 8;
            }
        }

        public static void WRITE_LE(UInt16 value, byte[] buf, int pos)
        {
            WRITE_LE(value, 2, buf, pos);
        }
        public static void WRITE_LE(UInt16 value, byte[] buf)
        {
            WRITE_LE(value, buf, 0);
        }
        public static void WRITE_LE(Int16 value, byte[] buf, int pos)
        {
            WRITE_LE((UInt16)value, buf, pos);
        }
        public static void WRITE_LE(Int16 value, byte[] buf)
        {
            WRITE_LE((UInt16)value, buf, 0);
        }
        public static void WRITE_LE(UInt32 value, byte[] buf, int pos)
        {
            WRITE_LE(value, 4, buf, pos);
        }
        public static void WRITE_LE(UInt32 value, byte[] buf)
        {
            WRITE_LE(value, buf, 0);
        }
        public static void WRITE_LE(Int32 value, byte[] buf, int pos)
        {
            WRITE_LE((UInt32)value, buf, pos);
        }
        public static void WRITE_LE(Int32 value, byte[] buf)
        {
            WRITE_LE((UInt32)value, buf, 0);
        }
        public static void WRITE24_LE(UInt32 value, byte[] buf, int pos)
        {
            WRITE_LE(value, 3, buf, pos);
        }
        public static void WRITE24_LE(UInt32 value, byte[] buf)
        {
            WRITE24_LE(value, buf, 0);
        }
        public static void WRITE24_LE(Int32 value, byte[] buf, int pos)
        {
            WRITE24_LE((UInt32)value, buf, pos);
        }
        public static void WRITE24_LE(Int32 value, byte[] buf)
        {
            WRITE24_LE((UInt32)value, buf, 0);
        }

        public static void WRITE_BE(UInt16 value, byte[] buf, int pos)
        {
            WRITE_BE(value, 2, buf, pos);
        }
        public static void WRITE_BE(UInt16 value, byte[] buf)
        {
            WRITE_BE(value, buf, 0);
        }
        public static void WRITE_BE(Int16 value, byte[] buf, int pos)
        {
            WRITE_BE((UInt16)value, buf, pos);
        }
        public static void WRITE_BE(Int16 value, byte[] buf)
        {
            WRITE_BE((UInt16)value, buf, 0);
        }
        public static void WRITE_BE(UInt32 value, byte[] buf, int pos)
        {
            WRITE_BE(value, 4, buf, pos);
        }
        public static void WRITE_BE(UInt32 value, byte[] buf)
        {
            WRITE_BE(value, buf, 0);
        }
        public static void WRITE_BE(Int32 value, byte[] buf, int pos)
        {
            WRITE_BE((UInt32)value, buf, pos);
        }
        public static void WRITE_BE(Int32 value, byte[] buf)
        {
            WRITE_BE((UInt32)value, buf, 0);
        }
        public static void WRITE24_BE(UInt32 value, byte[] buf, int pos)
        {
            WRITE_BE(value, 3, buf, pos);
        }
        public static void WRITE24_BE(UInt32 value, byte[] buf)
        {
            WRITE24_BE(value, buf, 0);
        }
        public static void WRITE24_BE(Int32 value, byte[] buf, int pos)
        {
            WRITE24_BE((UInt32)value, buf, pos);
        }
        public static void WRITE24_BE(Int32 value, byte[] buf)
        {
            WRITE24_BE((UInt32)value, buf, 0);
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
                    num = ByteHelper.READ_UINT16_LE(this.buf, this.pos);
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
                ByteHelper.WRITE_LE(num, this.buf, this.pos);
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
