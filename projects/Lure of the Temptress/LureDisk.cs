using System;
using System.IO;
using System.Text;

namespace Vlure
{
    class BinaryHelper
    {
        public static UInt64 read_LE(byte[] data, int ofs, int size)
        {
            UInt64 res=0;
            for (int i = 0; i < size; i++)
                res+=(UInt64)(((data[ofs+i])<<(i*8)));
            return res;
        }
        public static UInt64 read_BE(byte[] data, int ofs, int size)
        {
            UInt64 res = 0;
            for (int i = 0; i < size; i++)
                res |= (byte)(((data[ofs + i]) << ((size-i-1) * 8)) & 0xFF);
            return res;
        }
        public static void write_LE(byte[] data,int ofs,UInt64 value,int size)
        {
            for (int i = 0; i < size; i++)
            {
                byte val = (byte)((value >> (i * 8)) & 0xFF);
                data[ofs + i] = val;
            }
        }
        public static void write_BE(byte[] data, int ofs, UInt64 value, int size)
        {
            for (int i = 0; i < size; i++)
            {
                byte val = (byte)((value >> ((size-i-1) * 8)) & 0xFF);
                data[ofs + i] = val;
            }
        }
        public static void write_LE(byte[] data,int ofs,ushort value)
        {
            write_LE(data,ofs,value,2);
        }
        public static void write_LE(byte[] data, int ofs, uint value)
        {
            write_LE(data, ofs, value, 4);
        }
        public static ushort readU16_LE(byte[] data, int ofs)
        {
            return (ushort)(read_LE(data,ofs,2)&0xFFFF);
        }
        public static uint readU32_LE(byte[] data, int ofs)
        {
            return (uint)(read_LE(data, ofs, 4) & 0xFFFFFFFF);
        }
        public static ushort readU16_BE(byte[] data, int ofs)
        {
            return (ushort)(read_BE(data, ofs, 2) & 0xFFFF);
        }

        public static string readString(byte[] data, int ofs,int len)
        {
            if (len==0)
                return "";
            byte[] str=new byte[len];
            Array.Copy(data,ofs,str,0,len);
            return new String(Encoding.Unicode.GetChars(Encoding.Convert(Encoding.ASCII, Encoding.Unicode, str)));
        }

        public static string readZString(byte[] data, int ofs)
        {
            int len = 0;
            while (data[ofs + len] != 0) len++;
            return readString(data, ofs, len);
        }

        public static void writeString(byte[] data,ref int ofs,string value)
        {
            if (value == "")
                return;
            byte[] str=Encoding.Convert(Encoding.Unicode,Encoding.ASCII,Encoding.Unicode.GetBytes(value));
            Array.Copy(str,0,data,ofs,str.Length);
            ofs += str.Length;
        }
        public static void writeZString(byte[] data,ref int ofs, string value)
        {
            writeString(data, ref ofs, value);
            data[ofs] = 0;
            ofs++;
        }
    }


    public class LureDisk
    {
        public class FileEntry
        {
            public ushort id;
            public byte unused=0xFF;
            public byte sizeEx;
            public ushort size;
            public ushort offset;
            public int realOfs;
            public int realSize;
            public int tmp = 0;
            public FileEntry(byte[] data,int ofs)
            {
                id = BinaryHelper.readU16_LE(data, ofs);
                unused = data[ofs+2];
                sizeEx = data[ofs+3];
                size = BinaryHelper.readU16_LE(data, ofs+4);
                offset = BinaryHelper.readU16_LE(data, ofs+6);
                realSize = size + (sizeEx != 0 ? 0x10000 : 0);
                realOfs = offset * 0x20;
            }
            public void setNewOfs(int ofs)
            {
                realOfs=ofs;
                offset=(ushort)(ofs/0x20);
            }
            public void setNewSize(int sz)
            {
                sizeEx = sz > 0xFFFF ? (byte)1 : (byte)0;
                size = (ushort)(sz&0xFFFF);
                realSize = sz;
            }
            public void save(byte[] data,int ofs)
            {
                BinaryHelper.write_LE(data, ofs, id);
                data[ofs + 2] = unused;
                data[ofs + 3] = sizeEx;
                BinaryHelper.write_LE(data, ofs+4, size);
                BinaryHelper.write_LE(data, ofs+6, offset);
            }
        }
        const int LANG_ID=3;
        int dskid=-1;
        string file="";
        public FileEntry[] entries=new FileEntry[191];
        byte[] diskData = null;
        public bool changed = false;
        public LureDisk(int id,string paths)
        {
            dskid = id;
            string[] pts = paths.Split(';');
            file="lure.dat";
            if (id>0)
                file="disk"+id.ToString()+".vga";
            if (!File.Exists(file))
                foreach(string p in pts)
                {
                    string s = p;
                    if (s[s.Length-1]!='\\') s+="\\";
                    if (File.Exists(s+file))
                    {
                        file=s+file;
                        break;
                    }
                }
            if (!File.Exists(file))
                throw new Exception("Disk not found "+file);
            string xfile = file;
            if (File.Exists(xfile + ".bak"))
                xfile += ".bak";
            FileStream fs=new FileStream(xfile,FileMode.Open);
            diskData=new byte[fs.Length];
            fs.Read(diskData, 0, diskData.Length);
            fs.Close();
            if (id == 0)
            {
                if (BinaryHelper.readString(diskData, 0, 4) != "lure")
                    throw new Exception("bad lure.dat");
                int b = 6;
                while (diskData[b] != LureConfig.get().lang_id)
                {
                    b += 5;
                    if (diskData[b] == 0xff)
                        throw new Exception("lure.dat language "+LureConfig.get().lang_id.ToString()+" not found");
                }
                int dofs = (int)BinaryHelper.readU32_LE(diskData, b + 1);
                b=6;
                int dsz = int.MaxValue;
                while(diskData[b]!=0xFF)
                {
                    int sofs = (int)BinaryHelper.readU32_LE(diskData, b + 1);
                    b += 5;
                    if (sofs > dofs)
                    {
                        if (sofs - dofs < dsz)
                            dsz = sofs - dofs;
                    }
                }
                byte[] newdisk = new byte[dsz];
                Array.Copy(diskData, dofs, newdisk, 0, dsz);
                diskData = newdisk;
            }
            readEntries();
        }
        public void readEntries()
        {
            if (BinaryHelper.readString(diskData, 0, 6) != "heywow")
                throw new Exception("Bad file header format "+file);
            if (BinaryHelper.readU16_BE(diskData,6)!=dskid)
                throw new Exception("Bad file id format " + file);
            for (int i = 0; i < 191; i++)
                entries[i] = new FileEntry(diskData, 8+i*8);
        }
        public int indexById(int id)
        {
            for (int i = 0; i < 191; i++)
                if (entries[i].id == id)
                    return i;
            throw new Exception("File not found id="+id.ToString());
        }
        public byte[] objById(int id)
        {
            return objByIndex(indexById(id));
        }
        public byte[] objByIndex(int index)
        {
            byte[] data = new byte[entries[index].realSize];
            Array.Copy(diskData,entries[index].realOfs,data,0,entries[index].realSize);
            return data;
        }
        public void setObject(int id,byte[] data)
        {
            if (data.Length > 0x1FFFF)
                throw new Exception("File "+id.ToString()+" too long "+data.Length.ToString()+" - max size "+(0x1FFFF).ToString());
            int idx=indexById(id);
            //byte[] obj = objByIndex(idx);
            FileEntry e=entries[idx];
            if (e.realSize != data.Length)
                reBuildDisk(idx,data.Length-e.realSize);
            Array.Copy(data,0,diskData,e.realOfs,data.Length);
            changed = true;
        }
        public void reBuildDisk(int idx,int delta)
        {
            for (int i=0;i<entries.Length;i++)
                entries[i].tmp=0;
            FileEntry e=entries[idx];
            e.tmp=-e.realSize;
            e.setNewSize(e.realSize+delta);
            int curofs = e.realOfs + e.realSize;
            while (curofs % 0x20 != 0) curofs++;
            for (int i = idx+1; i < entries.Length && entries[i].id!=0xFFFF; i++)
            {
                e = entries[i];
                e.tmp = e.realOfs;
                e.setNewOfs(curofs);
                curofs += e.realSize;
                while (curofs % 0x20 != 0) curofs++;
            }
            byte[] newdisk = new byte[curofs];
            e = entries[idx];
            Array.Copy(diskData,newdisk,e.realOfs);
            for (int i = idx+1; i < entries.Length && entries[i].id!=0xFFFF; i++)
            {
                e = entries[i];
                Array.Copy(diskData, e.tmp, newdisk, e.realOfs, e.realSize);
            }
            diskData = newdisk;
        }

        public void saveDisk()
        {
            if (!File.Exists(file+".bak"))
                File.Copy(file, file + ".bak", false);
            for (int i = 0; i < 191; i++)
                entries[i].save(diskData, 8 + 8 * i);
            byte[] data = diskData;
            if (dskid == 0)
            {
                FileStream f = new FileStream(file, FileMode.Open);
                byte[] oldd = new byte[f.Length];
                f.Read(oldd,0,oldd.Length);
                f.Close();
                int[] mods = new int[100];
                int[] ofs = new int[100];
                int cnt=0;
                int b = 6;
                int cofs=0;
                int nextofs=0;
                while (oldd[b] != 0xFF)
                {
                    mods[cnt] = oldd[b];
                    ofs[cnt] = (int)BinaryHelper.readU32_LE(oldd, b + 1);
                    if (mods[cnt]==LANG_ID)
                        cofs=ofs[cnt];
                    cnt++;
                    b += 5;
                }
                int delta=0;
                for (int i = 0; i < cnt; i++)
                {
                    if (cofs < ofs[i] && cofs + data.Length > ofs[i])
                    {
                        nextofs=ofs[i];
                        delta = cofs + data.Length - ofs[i];
                    }
                }
                if (delta != 0)
                {
                    while (delta % 16 != 0) delta++;
                    byte[] newd = new byte[oldd.Length + delta];
                    Array.Copy(oldd, newd, cofs);
                    Array.Copy(oldd, nextofs, newd, nextofs + delta, oldd.Length - nextofs);
                    for (int i = 0; i < cnt; i++)
                        if (ofs[i] > cofs)
                        {
                            ofs[i] += delta;
                            BinaryHelper.write_LE(newd, 6 + i * 5 + 1, (uint)ofs[i]);
                        }
                    oldd = newd;
                }
                Array.Copy(data,0,oldd,cofs,data.Length);
                data = oldd;
            }
            FileStream fs = new FileStream(file, FileMode.Create);
            fs.Write(data, 0, data.Length);
            fs.Close();
        }
    }

    class LureDisks
    {
        public static LureDisks obj;
        public static LureDisks getDisks()
        {
            if (obj==null)
                obj=new LureDisks();
            return obj;
        }
        public static LureDisk get(int id)
        {
            return getDisks().getDisk(id);
        }
        public static byte[] getResource(int r)
        {
            if (r >> 8 == 0x3F)
                return get(0).objById(r);
            int id = ((r >> 14) & 3)+1;
            return get(id).objById(r);
        }

        LureDisk[] dsk=new LureDisk[5];
        public LureDisks()
        {
            for (int i=0;i<5;i++)
                dsk[i]=null;
        }
        public LureDisk getDisk(int id)
        {
            if (id > 4)
                throw new Exception("Bad Disk ID "+id.ToString());
            if (dsk[id]==null)
                dsk[id]=new LureDisk(id,LureConfig.get().path);
            return dsk[id];
        }
        public static void setResource(int r,byte[] data)
        {
            if (r >> 8 == 0x3F)
            {
                get(0).setObject(r, data);
                return;
            }
            int id = ((r >> 14) & 3) + 1;
            get(id).setObject(r,data);
        }
        public static void saveAll()
        {
            for (int i = 0; i < 5; i++)
                if (get(i).changed)
                    get(i).saveDisk();
        }
    }
}
