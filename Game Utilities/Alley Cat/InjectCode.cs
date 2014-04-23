using System;
using System.Collections.Generic;
using System.Text;

namespace AlleyCatFont
{
    class InjectCode
    {
        public const String code = "e9 9a 00 01 81 fb a2 28 74 0d 81 fb a4 28 74 27 8b 37 81 fe ff ff c3 9c 60 06 1e 8c d8 8e c0 8c c8 8e d8 bb 7e 63 8b 37 81 c3 04 00 89 1e 7c 63 81 eb 02 00 e9 1e 00 9c 60 06 1e 8c d8 8e c0 8c c8 8e d8 8b 1e 7c 63 8b 37 81 c3 04 00 89 1e 7c 63 81 eb 02 00 81 fe ff ff 75 03 e9 1e 00 8b 07 bf a2 28 ab 81 fe a0 28 77 03 e9 0f 00 b8 b0 28 89 c7 b9 08 00 a5 49 75 fc be b0 28 89 f0 bf a4 28 ab 1f 07 61 9d bb a0 28 8b 77 04 81 fe ff ff c3 00 00";

        public static byte[] getCode()
        {
            return bytesFromString(code);
        }

        public static byte[] getRUnCOde()
        {
            return bytesFromString("E80000909090");
        }

        public static byte[] bytesFromString(string str)
        {
            string c = str.Replace(" ", "");
            byte[] res = new byte[c.Length / 2];
            for (int i = 0; i < res.Length; i++)
                res[i] = byte.Parse(c.Substring(i * 2, 2), System.Globalization.NumberStyles.AllowHexSpecifier);
            return res;
        }
    }
}
