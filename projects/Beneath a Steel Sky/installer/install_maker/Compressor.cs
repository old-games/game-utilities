using System;
using System.Collections.Generic;
using System.Text;
using zlib;
using System.IO;

namespace install_maker
{
    class Compressor
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

        public static byte[] compress(byte[] data)
        {
            for (int l = zlib.zlibConst.Z_BEST_COMPRESSION; l > 0; l--)
            {
                MemoryStream o = new MemoryStream();
                ZOutputStream z = new ZOutputStream(o, l);
                MemoryStream i = new MemoryStream(data);
                CopyStream(i, z);
                z.finish();
                o.Position = 0;
                byte[] res = o.ToArray();
                i.Close();
                z.Close();
                o.Close();
                if (res.Length > 2)
                    return res;
            }
            return data;
        }
    }
}
