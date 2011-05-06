using System;
using System.Collections.Generic;
using System.Text;
using Yahoo.Yui.Compressor;

namespace install_maker
{
    class JSObfuscator
    {
        public static byte[] obfuscate(byte[] data)
        {
            try
            {
                string str = new String(Encoding.Unicode.GetChars(Encoding.Convert(Encoding.UTF8, Encoding.Unicode, data)));
                return Encoding.Convert(Encoding.Unicode, Encoding.UTF8, Encoding.Unicode.GetBytes(JavaScriptCompressor.Compress(str)));
            }
            catch (Exception)
            {
                return data;
            }
        }
    }
}
