using System;
using System.Collections.Generic;
using System.Text;
using System.Xml;
using System.Drawing;

namespace AlleyCatFont
{
    public class Config
    {
        public static int str2Int(string str)
        {
            if (str.StartsWith("0x"))
                return int.Parse(str.Substring(2), System.Globalization.NumberStyles.AllowHexSpecifier);
            return int.Parse(str);
        }

        public class Rule
        {
            public int x;
            public int y;
            public int letter;
            public Rule(int x,int y,int letter)
            {
                this.x = x;
                this.y = y;
                this.letter = letter;
            }
            public Rule(Int16 ofs, int letter)
            {
                processAddress(ofs);
                this.letter = letter;
            }
            public Rule(XmlNode nd)
            {
                Load(nd);
            }
            public Int16 getAddress()
            {
                return (Int16)((y%2*0x2000)+((y/2)*80)+x/4);
            }
            public void processAddress(Int16 ofs)
            {
                int yofs = 0;
                if (ofs > 0x2000)
                {
                    yofs = 1;
                    ofs -= 0x2000;
                }
                y = (ofs / 80)*2+yofs;
                x = (ofs % 80)*4;
            }
            public void Save(XmlNode node)
            {
                XmlNode nd = node.AppendChild(node.OwnerDocument.CreateElement("rule"));
                nd.Attributes.Append(nd.OwnerDocument.CreateAttribute("x")).Value = x.ToString();
                nd.Attributes.Append(nd.OwnerDocument.CreateAttribute("y")).Value = y.ToString();
                nd.Attributes.Append(nd.OwnerDocument.CreateAttribute("letter")).Value = letter.ToString();
            }
            public void Load(XmlNode node)
            {
                if (node.Attributes["pos"] == null)
                {
                    x = str2Int(node.Attributes["x"].Value);
                    y = str2Int(node.Attributes["y"].Value);
                }
                else
                {
                    processAddress((Int16)str2Int(node.Attributes["pos"].Value));
                }
                letter=str2Int(node.Attributes["letter"].Value);
            }
        }

        public class Letters
        {
            public List<UInt16[]> letters = new List<UInt16[]>();
            public List<Bitmap> images = new List<Bitmap>();
            public Letters()
            {
            }
            public void AddLetter(byte[] data)
            {
                List<UInt16> lst=new List<ushort>();
                for (int i = 0; i < 8; i++)
                    lst.Add((UInt16)((data[i*2]<<8)|(data[i*2+1])));
                letters.Add(lst.ToArray());
                makeBitmap(lst.ToArray());
            }
            public void AddLetter(Bitmap bmp)
            {
                if (bmp.Width != 8 || bmp.Height != 8)
                    throw new Exception("Bitmap 8x8 wanted");
                List<UInt16> data = new List<ushort>();
                for (int i=0;i<8;i++)
                {
                    UInt16 dt = 0;
                    for (int j = 0; j < 8; j++)
                    {
                        dt <<= 2;
                        Color cl = bmp.GetPixel(j, i);
                        if (cl.ToArgb() == Color.FromArgb(255, 0, 255).ToArgb())
                            dt |= 2;
                        else if (cl.ToArgb() == Color.FromArgb(85, 255, 255).ToArgb())
                            dt |= 1;
                        else if (cl.ToArgb() != Color.Black.ToArgb())
                            throw new Exception("Unknown color");
                    }
                    //dt |= 2;
                    data.Add(dt);
                }
                letters.Add(data.ToArray());
                makeBitmap(data.ToArray());
                bmp.Dispose();
            }
            public void AddLetter(string str)
            {
                AddLetter(InjectCode.bytesFromString(str.Substring(2)));   
            }
            private void makeBitmap(UInt16[] data)
            {
                Bitmap bmp = new Bitmap(16, 16);
                for (int i = 0; i < 8; i++)
                {
                    for (int j = 0; j < 8; j++)
                    {
                        int id = (data[i] >> (2 * (7 - j)))&3;
                        Color cl=Color.Black;
                        if (id == 1)
                            cl=Color.Aqua;
                        else if (id == 2)
                            cl=Color.Fuchsia;
                        bmp.SetPixel(j*2, i*2, cl);
                        bmp.SetPixel(j * 2+1, i * 2, cl);
                        bmp.SetPixel(j * 2, i * 2+1, cl);
                        bmp.SetPixel(j * 2+1, i * 2+1, cl);
                    }
                }
                bmp.Tag = letters[images.Count];
                images.Add(bmp);
            }
            public void save(XmlNode nd)
            {
                foreach(UInt16[] l in letters)
                {
                    XmlNode n = nd.AppendChild(nd.OwnerDocument.CreateElement("letter"));
                    string data = "0x";
                    foreach (UInt16 u in l)
                        data += String.Format("{0:X4}",u);
                    n.Attributes.Append(n.OwnerDocument.CreateAttribute("data")).Value=data;
                }
            }
            public void load(XmlNode nd)
            {
                letters.Clear();
                images.Clear();
                foreach (XmlNode n in nd.ChildNodes)
                    if (n.NodeType == XmlNodeType.Element && n.Name == "letter")
                        AddLetter(n.Attributes["data"].Value);
            }
        }

        public Letters myLetters = new Letters();
        public Letters theirLetters = new Letters();
        public List<Rule> rules = new List<Rule>();
        public Config()
        {
        }

        public void save(string filename,string xfile)
        {
            XmlDocument doc = new XmlDocument();
            XmlNode root=doc.AppendChild(doc.CreateElement("ac_config"));
            root.Attributes.Append(doc.CreateAttribute("file")).Value = xfile;
            myLetters.save(root.AppendChild(doc.CreateElement("letters")));
            XmlNode rls = root.AppendChild(doc.CreateElement("rules"));
            foreach(Rule r in rules)
                r.Save(rls);
            doc.Save(filename);
        }

        public string load(string filename)
        {
            string xfile = "";
            rules.Clear();
            XmlDocument doc = new XmlDocument();
            doc.Load(filename);
            if (doc.DocumentElement.Name != "ac_config")
                throw new Exception("Bad Config");
            xfile = doc.DocumentElement.Attributes["file"].Value;
            foreach(XmlNode nd in doc.DocumentElement)
                if (nd.NodeType == XmlNodeType.Element)
                {
                    if (nd.Name == "letters")
                        myLetters.load(nd);
                    if (nd.Name=="rules")
                        foreach(XmlNode r in nd.ChildNodes)
                            if (r.NodeType == XmlNodeType.Element && r.Name == "rule")
                            {
                                rules.Add(new Rule(r));
                            }
                }
            return xfile;
        }

        public Bitmap imageForLetter(int id)
        {
            if (id >= 0x2720)
            {
                return theirLetters.images[(id - 0x2720) / 16];
            }
            else
            {
                return myLetters.images[id];
            }
        }

        public void removeLetter(Bitmap img)
        {
            foreach (Bitmap im in myLetters.images)
                if (img==im)
                {
                    int lt = letterByImage(img);
                    int i = 0;
                    while (i < rules.Count)
                    {
                        if (rules[i].letter == lt)
                            rules.RemoveAt(i);
                        else
                            i++;
                    }
                    myLetters.letters.Remove(im.Tag as UInt16[]);
                    myLetters.images.Remove(im);
                    break;
                }
        }

        public int letterByImage(Bitmap img)
        {
            for (int i = 0; i < myLetters.letters.Count; i++)
                if (img == myLetters.images[i])
                    return i;
            for (int i = 0; i < theirLetters.letters.Count; i++)
                if (img == theirLetters.images[i])
                    return 0x2720 + i * 16;
            throw new Exception("letter not found");
        }
    }
}
