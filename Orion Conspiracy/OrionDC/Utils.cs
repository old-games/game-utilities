using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace OrionDC
{
    class BinHelper
    {
        public static UInt64 read_LE(byte[] data,int ofs,int sz){
            UInt64 res=0;
            for (int i=0;i<sz;i++){
                byte b = data[ofs + i];
                res |= (ulong)((ulong)b << (i * 8));
            }
            return res;
        }
        public static uint read_U32LE(byte[] data, int ofs)
        {
            return (uint)read_LE(data, ofs, 4);
        }

        public static UInt16 read_U16LE(byte[] data,int ofs)
        {
            return (UInt16)read_LE(data,ofs,2);
        }
    }

    class StringHelper
    {
        public static string ascii2uni(byte[] data,ref int ofs)
        {
            List<byte> st = new List<byte>();
            while (data[ofs] != 0)
                st.Add(data[ofs++]);
            ofs++;
            return new String(Encoding.Unicode.GetChars(
                Encoding.Convert(Encoding.GetEncoding(866),Encoding.Unicode,st.ToArray())
                ));
        }

        public static byte[] uni2ascii(string data)
        {
            return Encoding.Convert(Encoding.Unicode,Encoding.GetEncoding(866),
                Encoding.Unicode.GetBytes(data));
        }
    }
}
