using System;
using System.Collections.Generic;
using System.Text;
using ComponentAce.Compression.Libs.zlib;
using System.IO;

namespace engine.net
{
    class Decompressor
    {
        static void CopyStream(Stream src, Stream dest)
        {
            byte[] buffer = new byte[2000];
            int len = src.Read(buffer, 0, buffer.Length);
            while (len > 0)
            {
                dest.Write(buffer, 0, len);
                len = src.Read(buffer, 0, buffer.Length);
            }
            dest.Flush();
        }

        public static byte[] decompress(byte[] data,UInt32 realsize)
        {
            MemoryStream o=new MemoryStream();
            ZOutputStream z = new ZOutputStream(o);
            MemoryStream i = new MemoryStream(data);
            CopyStream(i, z);
            byte[] res = o.ToArray();
            i.Close();
            z.Close();
            o.Close();
            return res;
        }
    }
}
