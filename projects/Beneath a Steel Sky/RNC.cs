using BJFN.rnc;
//using System.Windows.Forms;

namespace bassru
{
    class RNC
    {
        public static byte[] compress(byte[] input)
        {
            return RNCCompressor.compress(input);
        }

        public static byte[] decompress(byte[] input)
        {
            //FileStream fs = new FileStream("d:\\temp\\rnc.tmp", FileMode.Create);
            //fs.Write(input, 0, input.Length);
            //fs.Close();
            //byte[] udata = RNCDecompressor.decompress(input);
            //byte[] pdata = RNCCompressor.compress(udata);
            //MessageBox.Show(string.Format("{0:s}: {1:d}",input.Length>pdata.Length?"better":"WORSE",input.Length-pdata.Length));
            //return udata;
            return RNCDecompressor.decompress(input);
        }
    }
}
