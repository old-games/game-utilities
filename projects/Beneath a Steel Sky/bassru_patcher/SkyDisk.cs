using System;
using System.IO;

namespace bassru_patcher
{

    public class SkyDisk
    {
        const string dinner_file = "sky.dnr";
        const string disk_file = "sky.dsk";
        public static SkyDisk obj = null;
        int version=0;
        public static SkyDisk get()
        {
            if (obj==null) obj=new SkyDisk();
            return obj;
        }

        public struct FileHeader
        {
            public const int size = 22;
            public UInt16 flags;
            public UInt16 x;
            public UInt16 y;
            public UInt16 width;
            public UInt16 height;
            public UInt16 sp_size;
            public UInt16 tot_size;
            public UInt16 n_sprites;
            public UInt16 offset_x;
            public UInt16 offset_y;
            public UInt16 compressed_size;
            public byte[] buf;
            public FileHeader(byte[] bts)
            {
                buf = new byte[22];
                Array.Copy(bts, buf, 22);
                flags = ByteHelper.READ_UINT16_LE(bts);
                x = ByteHelper.READ_UINT16_LE(bts,2);
                y = ByteHelper.READ_UINT16_LE(bts,4);
                width = ByteHelper.READ_UINT16_LE(bts,6);
                height = ByteHelper.READ_UINT16_LE(bts,8);
                sp_size = ByteHelper.READ_UINT16_LE(bts,10);
                tot_size = ByteHelper.READ_UINT16_LE(bts,12);
                n_sprites = ByteHelper.READ_UINT16_LE(bts,14);
                offset_x = ByteHelper.READ_UINT16_LE(bts,16);
                offset_y = ByteHelper.READ_UINT16_LE(bts,18);
                compressed_size = ByteHelper.READ_UINT16_LE(bts, 20);
            }
            public void setSize(UInt32 size)
            {
                flags = (UInt16)(((size & 0xFF0000) >> 8) | (UInt16)(flags & 0x00FF));
                tot_size = (UInt16)(size & 0xFFFF);
                ByteHelper.WRITE_LE(flags, buf);
                ByteHelper.WRITE_LE(tot_size, buf,12);
            }
            public uint totalsize { get { return ((uint)(flags & 0xFF00) << 8) | (tot_size); } }
            public byte flagbyte { get { return (byte)(flags & 0xFF); } }
            public bool compressed { get { return ((flags >> 7) & 1) == 1; } }
        };

        public struct DinnerEntry
        {
            public UInt16 id;
            public UInt32 offset;
            public UInt32 old_offset;
            public bool resized;
            public UInt32 size;
            public byte flags;
            public DinnerEntry(BinaryReader br,int version)
            {
                resized = false;
                old_offset = 0;
                if (br == null)
                {
                    offset = size =id= 0;
                    flags = 0;
                    return;
                }
                id=br.ReadUInt16();
                byte[] bts=br.ReadBytes(3);
                offset=ByteHelper.READ_UINT24_LE(bts)&0x7FFFFF;
                if ((bts[2]&0x80)!=0)
                {
                    if (version==331) offset<<=3; else offset<<=4;
                }
                bts=br.ReadBytes(3);
                flags=(byte)(bts[2]&0xC0);
                size = ByteHelper.READ_UINT24_LE(bts)& 0x3FFFFF;
            }
            public void write(BinaryWriter wr,int version)
            {
                wr.Write(id);
                byte[] bts = new byte[3];
                uint ofs = offset;
                if (ofs > 0x7FFFFF)
                {
                    if (version == 331)
                        ofs = 0x800000 | ofs >> 3;
                    else
                        ofs = 0x800000 | ofs >> 4;
                }
                ByteHelper.WRITE24_LE(ofs, bts);
                wr.Write(bts);
                ByteHelper.WRITE24_LE(size, bts);
                bts[2] |= flags;
                wr.Write(bts);
            }
            public bool isEmpty()
            {
                return (size == 0 && id==0);
            }
            public bool compressed {get{return ((flags&0x80)==0);}}
            public bool header { get { return ((flags & 0x40) == 0); } }
            public static DinnerEntry Empty = new DinnerEntry(null, 0);

        };

        string pth = "";
        byte[] diskbuf=null;
        public SkyDisk()
        {
        }

        bool ipack=false;
        public bool InstallPack { get { return ipack; } set { ipack = value; } }

        public string path {get{return pth;} set{pth=value;} }
        public uint dinnerSize=0;
        public DinnerEntry[] dinners;

        public int getVersion()
        {
            switch (dinnerSize)
            {
                case 232:return 272;
                case 243:return 109;
                case 247:return 267;
                case 1404:return 288;
                case 1413:return 303;
                case 1445:if (diskbuf.Length == 8830435) return 348; else return 331;
                case 1711:return 365;
                case 5099:return 368;
                case 5097:return 372;
                default: throw new ApplicationException("Unknown version");
            }
        }

        public bool readDinner()
        {
            FileStream fs = new FileStream(path + disk_file, FileMode.Open);
            diskbuf=new byte[fs.Length];
            fs.Read(diskbuf,0,(int)fs.Length);
            fs.Close();
            BinaryReader br=new BinaryReader(new FileStream(path+dinner_file,FileMode.Open));
            dinnerSize=br.ReadUInt32();
            version = getVersion();
            dinners = new DinnerEntry[dinnerSize];
            for (uint i=0;i<dinnerSize;i++)
                dinners[i]=new DinnerEntry(br,version);
            br.Close();
            return true;
        }

        public DinnerEntry fileInfo(int fnum, bool isid)
        {
            if (isid)
                return dinners[fnum];
            foreach (DinnerEntry e in dinners)
                if (e.id == fnum) return e;
            throw new ApplicationException("Unknown dinner entry");
        }

        public FileHeader readHeader(uint fnum)
        {
            return readHeader((int)fnum, false);
        }
        public FileHeader readHeader(int fnum,bool isid)
        {
            DinnerEntry e = fileInfo(fnum, isid);
            byte[] finfo = new byte[FileHeader.size];
            Array.Copy(diskbuf, e.offset, finfo, 0, FileHeader.size);
            return new FileHeader(finfo);
        }

        public byte[] readFile(int fnum)
        {
            return readFile(fnum, false);
        }
        public byte[] readFile(int fnum, bool isid)
        {
            DinnerEntry e = fileInfo(fnum, isid);
            FileHeader hdr = readHeader(fnum, isid);
            byte[] res = null;
            if (e.compressed && hdr.compressed && hdr.tot_size != e.size)
            {
                throw new Exception("Cant get compressed file");
            }
            else
            {
                res = new byte[e.size];
                Array.Copy(diskbuf, e.offset, res, 0, e.size);
            }
            return res;
        }

        public bool importFile(int fnum, byte[] data)
        {
            return importFile(fnum, false, data);
        }
        public bool importFile(int fnum,bool isid,byte[] data)
        {
            DinnerEntry e = fileInfo(fnum, isid);
            FileHeader hdr = readHeader(fnum, isid);
            byte[] fl;
            if (e.compressed && hdr.compressed && hdr.tot_size != e.size)
            {
                UInt32 decompsz = (uint)data.Length;
                if (e.header)
                {
                    hdr = new FileHeader(data);
                    fl = data;
                    data = new byte[fl.Length - FileHeader.size];
                    Array.Copy(fl, FileHeader.size, data, 0, data.Length);
                    hdr.setSize(decompsz);
                }
                else
                    hdr.setSize(decompsz);
                byte[] cmpr = RNCCompressor.compress(data);
                data=new byte[cmpr.Length+FileHeader.size];
                Array.Copy(hdr.buf, 0, data, 0, FileHeader.size);
                Array.Copy(cmpr, 0, data, FileHeader.size, cmpr.Length);
            }
            int resize = data.Length - (int)e.size;
            if (resize != 0)
                resizeDisk(resize,ref e);
            if (InstallPack)
            {
                FileStream f = new FileStream(Path.Combine(path,fnum.ToString()+".bin"), FileMode.Create);
                f.Write(data, 0, data.Length);
                f.Close();
            }
            Array.Copy(data, 0, diskbuf, e.offset, data.Length);
            return true;
        }

        public void saveDiskAndDinner(string filename)
        {
            String fn = Path.GetDirectoryName(filename)+"\\"+Path.GetFileNameWithoutExtension(filename);
            FileStream fs = new FileStream(fn + ".dsk", FileMode.Create);
            fs.Write(diskbuf, 0, diskbuf.Length);
            fs.Close();
            BinaryWriter wr = new BinaryWriter(new FileStream(fn + ".dnr", FileMode.Create));
            wr.Write(dinnerSize);
            for (int i = 0; i < dinnerSize; i++)
                dinners[i].write(wr, version);
            wr.Close();
        }

        public DinnerEntry findDinnerByOffset(uint ofs)
        {
            foreach (DinnerEntry e in dinners)
                if (e.offset == ofs && !e.resized) return e;
            return DinnerEntry.Empty;
        }

        public uint normpos(uint pos)
        {
            normpos(ref pos);
            return pos;
        }
        public void normpos(ref uint pos)
        {
            if (pos > 0x7FFFFF)
                while ((byte)(pos & 0x0F) != 0) pos++;
        }

        public void setDinner(DinnerEntry e)
        {
            for (int i=0;i<dinners.Length;i++)
                if (dinners[i].id == e.id)
                {
                    dinners[i] = e;
                    dinners[i].resized = true;
                    return;
                }
        }

        public void resizeDisk(int resize,ref DinnerEntry e)
        {
            for (int i = 0; i < dinners.Length; i++)
                dinners[i].resized = false;
            uint prevsz = e.size;
            e.size = (uint)((int)e.size+resize);
            uint curpos = normpos(e.offset + prevsz);
            uint newpos = normpos(e.offset + e.size);
            setDinner(e);
            if (curpos == newpos) return;
            DinnerEntry ce;
            while (!(ce = findDinnerByOffset(curpos)).isEmpty())
            {
                ce.old_offset = ce.offset;
                ce.offset = newpos;
//                Console.WriteLine(String.Format("found {0:d} @{1:X8}->@{2:X8} size={3:X4}", ce.id,ce.old_offset,ce.offset, ce.size));
                setDinner(ce);
                curpos += ce.size;
                newpos += ce.size;
                normpos(ref curpos);
                normpos(ref newpos);
            }
            for (int i = 0; i < dinners.Length; i++)
                dinners[i].resized = false;
//            if (newpos != diskbuf.Length)
            {
                byte[] prevbuf = diskbuf;
                diskbuf=new byte[newpos];
                Array.Copy(prevbuf, diskbuf, e.offset);
                curpos = normpos(e.offset + e.size);
                while (!(ce = findDinnerByOffset(curpos)).isEmpty())
                {
 //                   Console.WriteLine(String.Format("moveing {0:d} {1:X8}->{2:X8} {3:X4}",ce.id,ce.old_offset,ce.offset,ce.size));
                    Array.Copy(prevbuf, ce.old_offset, diskbuf, ce.offset, ce.size);
                    curpos += ce.size;
                    normpos(ref curpos);
                    setDinner(ce);
                }
            }
        }
    }
}
