using System.IO;
using System.Collections.Generic;
using System;
using System.Text;

namespace OrionDC
{
    public class OProg
    {
        public class OString
        {
            const byte COUNT_SP_TERM = 2;
            const byte STRING_MOVE = 3;
            const byte STRING_MENU_OPTION = 5;
            const byte GLOBAL_WORD = 6;
            const byte SET_COLOUR = 7;
            const byte DEF_COLOUR = 8;
            const byte ADVANCE = 9;
            const byte COUNT_SP0 = 0x0a;
            const byte COUNT_SP1 = 0x0b;
            const byte CENTER = 12;
            const byte SLASH = 0x5C;
            const byte RETURN = 0x0D;
            const byte WAIT = 0x0F;
            const byte SHARP = 0x23;

            public int id = 0;
            public string data = "";
            public int state = 0;
            public UInt16 ofs=0;
            public int length = 0;
            public OString(int id,byte[] data,UInt16 ofs)
            {
                this.id = id;
                this.ofs = ofs;
                int len = 0;
                byte b = 0;
                string s="";
                while ((b=data[ofs + len]) != 0)
                {
                    len++;
                    switch (b)
                    {
                        case RETURN:
                            s += "\\r";
                            break;
                        case SLASH:
                            s+="\\\\";
                            break;
                        case COUNT_SP_TERM:
                            s+="\\[t]";
                            break;
                        case STRING_MOVE:
                            UInt16 p1=BinHelper.read_U16LE(data,ofs+len);
                            UInt16 p2=BinHelper.read_U16LE(data,ofs+len+2);
                            len+=4;
                            s+=String.Format("\\[r{0:X4},{1:X4}]",p1,p2);
                            break;
                        case STRING_MENU_OPTION:
                            List<byte> nm = new List<byte>();
                            while (data[ofs + len] != 0)
                            {
                                nm.Add(data[ofs + len]);
                                len++;
                            }
                            UInt16 p4=BinHelper.read_U16LE(data,ofs+len);
                            len+=2;
                            s+=String.Format("\\[o{0:s},{1:X4}]",new String(Encoding.Unicode.GetChars(
                                Encoding.Convert(Encoding.GetEncoding(866),Encoding.Unicode,nm.ToArray())
                                )),p4);
                            break;
                        case COUNT_SP0:
                            s += "\\[n]";
                            break;
                        case COUNT_SP1:
                            s += "\\[s]";
                            break;
                        case CENTER:
                            s += "\\[m]";
                            break;
                        case WAIT:
                            s += "\\[w]";
                            break;
                        case SHARP:
                            s += "!";
                            break;
                        case ADVANCE:
                            s += String.Format("\\[c{0:X2}]",data[ofs+len]);
                            len++;
                            break;
                        case DEF_COLOUR:
                            s += "\\[d]";
                            break;
                        case SET_COLOUR:
                            s += String.Format("\\[c{0:X2}]",data[ofs+len]);
                            len++;
                            break;
                        case GLOBAL_WORD:
                            UInt16 p3 = BinHelper.read_U16LE(data, ofs + len);
                            len += 2;
                            s += String.Format("\\[g{0:X4}]",p3);
                            break;
                        default:
                            if (b < 0x20 || (b>0xAF  && (b<0xE0 || b>0xF1)))
                                s += String.Format("\\[x{0:X2}]", b);
                            else
                                s += new String(Encoding.Unicode.GetChars(
                                    Encoding.Convert(Encoding.GetEncoding(866), Encoding.Unicode, new byte[] { b })
                                    ));
                            break;
                    }
                }
                this.data=s;
                length = len;
            }
        }
        public byte[] data=null;
        public byte[] footer=null;
        int id=0;
        public int type=0;
        public UInt16 u0 = 0;
        public UInt16 exitsCnt = 0;
        public UInt16 actorsCnt = 0;
        public UInt16 u6 = 0;
        public UInt16 exits = 0;
        public UInt16 actors = 0;
        public UInt16 sprites = 0;
        public UInt16 entry = 0;
        public byte[] code = null;
        public byte[] sprite_data = null;
        public byte[] actor_data = null;
        public byte[] exit_data = null;
        public UInt16[] rooms = null;
        public List<OString> strings = new List<OString>();

        public OProg(byte[] data, byte[] footer, int id,int type)
        {
            this.type = type;
            this.data = data;
            this.footer = footer;
            this.id = id;
            return;
            u0=BinHelper.read_U16LE(footer, 0);
            exitsCnt=BinHelper.read_U16LE(footer, 2);
            if (type == 1)
            {
                entry=exitsCnt;
                exitsCnt = 0;
                unpack();
                return;
            }
            actorsCnt=BinHelper.read_U16LE(footer, 4);
            u6=BinHelper.read_U16LE(footer, 6);
            exits=BinHelper.read_U16LE(footer, 8);
            actors=BinHelper.read_U16LE(footer, 0x0A);
            sprites=BinHelper.read_U16LE(footer, 0x0C);
            entry=BinHelper.read_U16LE(footer, 0x0E);
            if (u0 != 0 || u6 != exits)
                throw new Exception("Unknown prog values");
            unpack();
        }
        void unpack()
        {
            int spos=2;
            int slen = data.Length - spos;
            if (type == 0)
            {
                List<UInt16> rms = new List<UInt16>();
                UInt16 rm = 0;
                while (rm != 0xFFFF)
                {
                    rm = BinHelper.read_U16LE(data, spos);
                    spos += 2;
                    rms.Add(rm);
                }
                rooms = rms.ToArray();
                slen = exits - spos;
                if (actors-exits>0)
                {
                    exit_data = new byte[actors - exits];
                    Array.Copy(data, exits, exit_data, 0, exit_data.Length);
                }
                if (sprites - actors > 0)
                {
                    actor_data = new byte[sprites - actors];
                    Array.Copy(data, actors, actor_data, 0, actor_data.Length);
                }
                if (entry - sprites > 0)
                {
                    sprite_data = new byte[entry - sprites];
                    Array.Copy(data, sprites, sprite_data, 0, sprite_data.Length);
                }
            }
            else
                slen = entry - spos;
            code = new byte[data.Length - entry];
            Array.Copy(data, entry, code, 0, code.Length);
            int enda=spos+slen;
            int sid=0;
            while (spos < enda)
            {
                strings.Add(new OString(sid++, data, (UInt16)spos));
                spos += strings[strings.Count - 1].length + 1;
            }
        }
        public void dump(string filename)
        {
            FileStream fs = new FileStream(filename, FileMode.Create);
            fs.Write(data,0, data.Length);
            fs.Write(footer, 0, footer.Length);
            fs.Close();
        }
    }

    public class ProgDat
    {
        string filename="";
        uint[] ofs = null;
        public List<OProg> progs = new List<OProg>();
        MainDat main;
        public ProgDat(string path,string pref,MainDat main)
        {
           this.filename = path + "/" + pref + "_prog.dat";
            if (!File.Exists(filename))
                filename = path + "/" + pref + "_prog.eng";
            if (!File.Exists(filename))
                throw new Exception("prog not found");
           this.main = main;
           process();
        }

        void process()
        {
            ofs = new uint[main.progcnt[0] + main.progcnt[1]];
            BinaryReader rd = new BinaryReader(new FileStream(filename, FileMode.Open, FileAccess.Read));
            int t1 = main.progcnt[1];
            for (int i = 0; i < ofs.Length; i++)
            {
                ofs[i] = rd.ReadUInt32();
                long pofs = rd.BaseStream.Position;
                rd.BaseStream.Position = ofs[i];
                int len = rd.ReadInt16();
                if (len > 25000)
                    throw new ApplicationException("Too large program "+len.ToString());
                rd.BaseStream.Position -= 2;
                byte[] data = rd.ReadBytes(len);
                MainDat.descramble(data, 2);
                progs.Add(new OProg(data,rd.ReadBytes(0x10),i,(i<t1?0:1)));
                rd.BaseStream.Position = pofs;
            }
            rd.Close();
        }

        public void dump(string path)
        {
            for (int i = 0; i < progs.Count; i++)
            {
                progs[i].dump(path + "/prog" + i.ToString() + ".bin");
            }
        }
    }
}
