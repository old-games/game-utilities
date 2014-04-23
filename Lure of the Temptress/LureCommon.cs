using System;
using System.Collections.Generic;
using System.Text;
using System.IO;
using System.Xml;

namespace Vlure
{
    class LureCommon
    {
        public static void dumpFile(byte[] data,string name)
        {
            FileStream fs=new FileStream(name,FileMode.Create);
            fs.Write(data,0,data.Length);
            fs.Close();
        }

        public static XmlDocument makeXml(string rootnode)
        {
            XmlDocument doc = new XmlDocument();
            doc.LoadXml("<?xml version=\"1.0\" encoding=\"utf-8\"?><"+rootnode+"/>");
            return doc;
        }

        public static XmlDocument loadXml(string file)
        {
            XmlDocument doc = new XmlDocument();
            doc.Load(file);
            return doc;
        }

        public static string revert(string s)
        {
            string res = "";
            for (int i = s.Length-1; i >=0; i--)
                res += s[i];
            return res;
        }

        public static int revert(int val, int len)
        {
            int res = 0;
            for (int i = 0; i < len; i++)
            {
                res <<= 1;
                res |= val & 1;
                val >>= 1;
            }
            return res;
        }

        public static int strToInt(string s)
        {
            if (s.Length > 1 && s.Substring(0, 2) == "0x")
                return int.Parse(s.Substring(2),System.Globalization.NumberStyles.AllowHexSpecifier);
            return int.Parse(s);
        }



        public static byte[] checkArrLength(byte[] arr, int len)
        {
            if (arr.Length < len)
            {
                byte[] newarr = new byte[len];
                Array.Copy(arr, newarr, arr.Length);
                arr = newarr;
            }
            return arr;
        }
        public static byte[] checkArrLength(byte[] arr, int ofs, int sz)
        {
            return checkArrLength(arr, ofs + sz);
        }

        public static XmlNode findNode(XmlNode parent, string name)
        {
            return findNode(parent, name, string.Empty, "");
        }
        public static XmlNode findNode(XmlNode parent,string name,string param,string value)
        {
            foreach(XmlNode nd in parent.ChildNodes)
                if (nd.NodeType==XmlNodeType.Element && nd.Name==name)
                {
                    if (param == string.Empty)
                        return nd;
                    if (nd.Attributes[param].Value == value)
                        return nd;
                }

            throw new Exception("node not found "+name+" "+value);
        }

        public static void checkFile(string filename)
        {
            if (!File.Exists(filename))
                throw new Exception("File not found "+filename);
        }
    }
}
