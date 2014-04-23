using System;
using System.Collections.Generic;
using Microsoft.DirectX.DirectSound;
using System.Text;
using System.IO;

namespace CrusAVI
{
    public class WavFile
    {
        public const string WAV_FILTER = "Wave File (*.wav)|*.wav";
        static WaveFormat wf;
        MemoryStream data = new MemoryStream();

        public WavFile()
        {
        }

        public WavFile(WaveFormat fmt,byte[] dt)
        {
            setFormat(fmt);
            data.Write(dt, 0, dt.Length);
        }

        public WavFile(Stream stream)
        {
            loadFromStream(stream);
        }

        public byte[] saveToBytes()
        {
            MemoryStream ms = new MemoryStream();
            saveToStream(ms);
            byte[] res = new byte[ms.Length];
            ms.Position = 0;
            ms.Read(res, 0, res.Length);
            ms.Dispose();
            return res;
        }

        public byte[] rawBytes()
        {
            byte[] res = new byte[data.Length];
            data.Position = 0;
            data.Read(res, 0, res.Length);
            return res;
        }

        public static WaveFormat getFormat()
        {
            wf.FormatTag = WaveFormatTag.Pcm;
            wf.Channels = 1;
            wf.SamplesPerSecond = 11025;
            wf.BlockAlign = 1;
            wf.AverageBytesPerSecond = 11025;
            wf.BitsPerSample = 8;
            return wf;
        }

        public void setFormat(WaveFormat fmt)
        {
            wf.FormatTag = WaveFormatTag.Pcm;
            wf.Channels = fmt.Channels;
            wf.SamplesPerSecond = fmt.SamplesPerSecond;
            wf.BlockAlign = fmt.BlockAlign;
            wf.AverageBytesPerSecond = fmt.AverageBytesPerSecond;
            wf.BitsPerSample = fmt.BitsPerSample;
        }

        public double length()
        {
            return data.Length * 1.0 / wf.AverageBytesPerSecond;
        }
        public string length_s()
        {
            return String.Format("{0:F3}", length());
        }

        public bool loadFromStream(Stream stream)
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
            data.Capacity = len;
            byte[] bs = br.ReadBytes(len);
            data.Write(bs, 0, len);
            wf.FormatTag = WaveFormatTag.Pcm;
            wf.AverageBytesPerSecond = byteps;
            wf.BitsPerSample = (short)bps;
            wf.BlockAlign = (short)blkAlign;
            wf.Channels = (short)channels;
            wf.SamplesPerSecond = smplerate;
            return true;
        }
        public void saveToStream(Stream stream)
        {
            BinaryWriter br = new BinaryWriter(stream, Encoding.ASCII);
            br.Write("RIFF".ToCharArray());
            int len = 0;
            br.Write(len);
            br.Write("WAVE".ToCharArray());
            br.Write("fmt ".ToCharArray());
            int i = 16; br.Write(i);
            short c = 1;
            br.Write(c);
            br.Write(wf.Channels);
            br.Write(wf.SamplesPerSecond);
            br.Write(wf.AverageBytesPerSecond);
            br.Write(wf.BlockAlign);
            br.Write(wf.BitsPerSample);
            br.Write("data".ToCharArray());
            i = (int)data.Capacity;
            br.Write(i);
            data.WriteTo(br.BaseStream);
            len = (int)stream.Length;
            stream.Position = 4;
            br = new BinaryWriter(stream);
            br.Write(len);
        }

        public bool checkFormat(WaveFormat f)
        {
            return (f.BitsPerSample == wf.BitsPerSample && f.Channels == wf.Channels && f.FormatTag == wf.FormatTag &&
                f.SamplesPerSecond == wf.SamplesPerSecond);
        }
    }
}
