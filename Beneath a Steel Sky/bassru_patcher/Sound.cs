using System.IO;
using System;
using System.Text;

namespace bassru_patcher
{

    public class WavFile
    {
        public static bool loadFromStream(Stream stream,ref byte[] data)
        {
            BinaryReader br = new BinaryReader(stream);
            String s = new String(br.ReadChars(4));
            if (s != "RIFF") return false;
            int len = br.ReadInt32();
            s = new String(br.ReadChars(4));
            if (s != "WAVE") return false;
            s = new String(br.ReadChars(4));
            if (s != "fmt ") return false;
            int cl = br.ReadInt32();
            //if (cl != 18) return false;
            int compression = br.ReadInt16();
            int channels = br.ReadInt16();
            int smplerate = br.ReadInt32();
            int byteps = br.ReadInt32();
            int blkAlign = br.ReadInt16();
            int bps = br.ReadInt16();
            if (bps % 8 != 0)
                return false;
            if (channels != 1 || smplerate!=11025 || bps!=8)
                return false;
            br.ReadBytes(cl - 16);
            s = new String(br.ReadChars(4));
            try
            {
                while (s.ToLower() != "data")
                {
                    br.ReadBytes(br.ReadInt32());
                    s = new String(br.ReadChars(4));
                }
            }
            catch (Exception)
            {
                return false;
            }
            len = br.ReadInt32();
            data = br.ReadBytes(len);
            return true;
        }
    }

    class BSound:BSpeech
    {
        public BSound(uint fnum)
            : base(fnum)
        {
        }
    }

    class BSpeech : BResource
    {
        public BSpeech(uint fnum)
            : base(fnum)
        {
        }

        public override bool import(byte[] file)
        {
            byte[] data=null;
            if (!WavFile.loadFromStream(new MemoryStream(file),ref data))
                throw new Exception("bad wave format");
            data[0] = 0x81;
            data[1] = 0;
            return SkyDisk.get().importFile((int)filenum, data);
        }

    }
    
    /*
    class BMusic : BResource
    {
        public BMusic(uint fnum)
            : base(fnum, ResView.SoundView.get())
        {
        }
    }
     * */
}
