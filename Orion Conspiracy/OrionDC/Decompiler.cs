
using System;
namespace OrionDC
{
    class Decompiler
    {
        const byte ARG_IMM=1;
        const byte ARG_WORD=2;
        const byte ARG_BYTE=3;
        const byte ARG_STR=7;
        const byte ARG_CODE=9;
        public static string getParam(byte tp,UInt16 vl,OProg prog)
        {
            if (tp == ARG_STR)
            {
                foreach (OProg.OString s in prog.strings)
                    if (s.ofs == vl)
                        return "s" + s.id.ToString();
                throw new Exception("String Not Found "+vl.ToString("X4"));
            }
            string res = "";
            switch (tp)
            {
                case ARG_IMM: res = "i"; break;
                case ARG_WORD: res = "w"; break;
                case ARG_BYTE: res = "b"; break;
                case ARG_CODE: res = "c"; break;
                default:
                    throw new Exception("Anknown arg type " + tp.ToString());
            }
            res += vl.ToString("X4");
            return res;
        }

        public static string decompile(OProg prog,string eol)
        {
            foreach(OProg.OString s in prog.strings)
                s.state=0;
            int pos = 0;
            byte[] data=prog.code;
            string res = "";
            while (pos < data.Length)
            {
                byte op = data[pos++];
                if (op >= Opcodes.OPCODE_SIZE)
                    throw new Exception(string.Format("Bad Opcode {0:X2} @ {1:X4}",op,pos));
                foreach (Opcodes.opcode b in Opcodes.opcodes)
                {
                    if (b.op == op)
                    {
                        string s=b.name+"(";
                        for (int i=0;i<b.prms;i++)
                        {
                            byte ptp=data[pos++];
                            s+=getParam(ptp,BinHelper.read_U16LE(data,pos),prog);
                            pos+=2;
                            if (i < b.prms - 1)
                                s += ",";
                        }
                        s+=")"+eol;
                        res += s;
                        break;
                    }
                }
            }
            return res;
        }
    }
}
