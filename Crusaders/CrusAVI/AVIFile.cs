using System;
using System.Collections.Generic;
using Microsoft.DirectX.DirectSound;
using System.Text;
using System.IO;

namespace CrusAVI
{
    class AVIFile
    {
        static WaveFormat wf;
        List<UInt32[]> waveMap = new List<UInt32[]>();
        MemoryStream data = new MemoryStream();
        public AVIFile(string fname)
        {
            FileStream fs = new FileStream(fname,FileMode.Open);
            byte[] bts = new byte[fs.Length];
            fs.Read(bts, 0, bts.Length);
            fs.Close();
            data.Write(bts, 0, bts.Length);
            process();
        }

        public void close()
        {
            data.Close();
        }

        public void save(string fname)
        {
            byte[] bts = new byte[data.Length];
            data.Position = 0;
            data.Read(bts, 0, bts.Length);
            FileStream fs = new FileStream(fname, FileMode.Create);
            fs.Write(bts, 0, bts.Length);
            fs.Close();
        }

        public WavFile getWave()
        {
            byte[] bts = new byte[wavelen()];
            UInt32 bpos = 0;
            foreach (UInt32[] x in waveMap)
            {
                byte[] chunk = new byte[x[1]];
                data.Position = x[0];
                data.Read(chunk, 0, (int)x[1]);
                Array.Copy(chunk, 0, bts, bpos, x[1]);
                bpos += x[1];
            }
            return new WavFile(wf, bts);
        }

        public void setWave(WavFile wave)
        {
            if (!wave.checkFormat(wf))
                throw new Exception("Wrong import wave format");
            byte[] bts=wave.rawBytes();
            if (bts.Length != wavelen())
                throw new Exception("Bad import wave length");
            UInt32 bpos=0;
            foreach (UInt32[] x in waveMap)
            {
                byte[] chunk = new byte[x[1]];
                Array.Copy(bts, bpos, chunk, 0, x[1]);
                bpos += x[1];
                data.Position = x[0];
                data.Write(chunk, 0, (int)x[1]);
            }
        }

        public UInt32 wavelen()
        {
            UInt32 res = 0;
            foreach(UInt32[] x in waveMap)
                res += x[1];
            return res;
        }

        public UInt32 findChunk(bool list,string cname,long epos,BinaryReader br)
        {
            while (br.BaseStream.Position < epos)
            {
                string s=new String(br.ReadChars(4));
                UInt32 size = br.ReadUInt32();
                if (s == "LIST")
                {
                    s = new String(br.ReadChars(4));
                    size -= 4;
                    if (list && s == cname)
                        return size;
                }else 
                if (!list && s == cname)
                    return size;
                br.BaseStream.Position += size;
            }
            return 0;
        }

        public int getWafeFormat(BinaryReader br)
        {
            UInt32 sz = findChunk(true, "hdrl", br.BaseStream.Length, br);
            if (sz ==0)
                throw new Exception("AVI header not found");
            int res = -1;
            int cstream = 0;
            long epos=br.BaseStream.Position+sz;
            while(br.BaseStream.Position<epos && res==-1)
            {
                string s = new String(br.ReadChars(4));
                sz = br.ReadUInt32();
                long x=br.BaseStream.Position+sz;
                if (s == "LIST")
                {
                    s = new String(br.ReadChars(4));
                    if (s == "strl")
                    {
                        long xx = br.BaseStream.Position;
                        UInt32 xsz = findChunk(false, "strh", br.BaseStream.Position + sz, br);
                        if (xsz >0)
                        {
                            s = new string(br.ReadChars(4));
                            if (s == "auds")
                            {
                                br.BaseStream.Position = xx;
                                xsz = findChunk(false, "strf", br.BaseStream.Position + sz, br);
                                if (xsz==16)
                                {
                                    UInt16 fmt=br.ReadUInt16();
                                    if (fmt != 1)
                                        throw new Exception("Unknown wave format");
                                    wf.FormatTag = WaveFormatTag.Pcm;
                                    wf.Channels = br.ReadInt16();
                                    wf.SamplesPerSecond = br.ReadInt32();
                                    wf.AverageBytesPerSecond = br.ReadInt32();
                                    wf.BlockAlign = br.ReadInt16();
                                    wf.BitsPerSample = br.ReadInt16();
                                    res = cstream;
                                }
                            }
                        }
                        cstream++;
                    }
                }
                br.BaseStream.Position = x;
            }
            return res;
        }

        public bool getWaveMap(BinaryReader br,int wavestreamid)
        {
            string cname = String.Format("{0:D2}wb", wavestreamid);
            bool res = false;
            UInt32 sz = findChunk(true, "movi", br.BaseStream.Length, br);
            if (sz > 0)
            {
                long epos = br.BaseStream.Position + sz;
                while (br.BaseStream.Position < epos)
                {
                    string s = new String(br.ReadChars(4));
                    sz = br.ReadUInt32();
                    if (s == "LIST")
                    {
                        s = new String(br.ReadChars(4));
                    }
                    else if (s==cname)
                    {
                        res = true;
                        waveMap.Add(new UInt32[] {(UInt32)br.BaseStream.Position,sz});
                    }
                    br.BaseStream.Position += sz;
                }
            }
            return res;
        }

        public void process()
        {
            data.Position = 0;
            BinaryReader br = new BinaryReader(data);
            String s = new String(br.ReadChars(4));
            if (s != "RIFF")
                throw new Exception("NOT RIFF file");
            UInt32 size = br.ReadUInt32();
            s = new String(br.ReadChars(4));
            if (s != "AVI ")
                throw new Exception("NOT AVI File");
            long x = data.Position;
            int wid = getWafeFormat(br);
            if (wid < 0)
                throw new Exception("No audio stream in avi");
           data.Position=x;
           if (!getWaveMap(br,wid))
               throw new Exception("Audio data not found");
        }
    }
}
