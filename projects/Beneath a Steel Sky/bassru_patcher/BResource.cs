using System;
using System.Collections.Generic;
using System.Xml;
using System.Drawing;
using System.Drawing.Imaging;

namespace bassru_patcher
{
    public class BResource
    {
        public const int GAME_SCREEN_HEIGHT = 192;
        uint fnum;
        public BResource(uint fnum)
        {
            this.fnum = fnum;
        }
        public uint filenum{get{return fnum;}}
        public virtual bool import(byte[] data)
        {
            return SkyDisk.get().importFile((int)filenum, data);
        }
        public static XmlDocument xmlFromBytes(byte[] data)
        {
            XmlDocument doc = new XmlDocument();
            doc.Load(new System.IO.MemoryStream(data));
            return doc;
        }
    }

    public class BPalette : BResource
    {
        public BPalette(uint fnum)
            : base(fnum)
        {
        }
        public override bool import(byte[] file)
        {
            byte[] buf=new byte[256*3];
            XmlDocument doc = xmlFromBytes(file);
            if (doc.DocumentElement.Name!="bassru-palette")
                throw new ApplicationException("Bad palette file format");
            foreach (XmlNode nd in doc.DocumentElement.ChildNodes)
                if (nd.NodeType == XmlNodeType.Element && nd.Name == "color")
                {
                    int id = int.Parse(nd.Attributes["id"].Value);
                    byte c = byte.Parse(nd.Attributes["r"].Value);
                    buf[id * 3] = (byte)(((c << 4)&0x03) | (c >> 2));
                    c = byte.Parse(nd.Attributes["g"].Value);
                    buf[id * 3 + 1] = (byte)(((c << 4) & 0x03) | (c >> 2));
                    c = byte.Parse(nd.Attributes["b"].Value);
                    buf[id * 3 + 2] = (byte)(((c << 4) & 0x03) | (c >> 2));
                }
            return SkyDisk.get().importFile((int)filenum,buf);
        }
    }

    public class BImage : BResource
    {
        int w, h;
        int mode = 0;
        public BImage(uint fnum,int w,int h,int mode) : base(fnum) 
        {
            this.w = w;
            this.h = h;
            this.mode = mode;
        }
        public static byte[] switchMode0to1(byte[] data, int width, int height)
        {
            byte[] res = new byte[data.Length];
            int pos = 0;
            for (int i = 0; i < height; i++)
                for (int k = 0; k < 8; k++)
                    for (int j = 0; j < width; j++)
                    {
                        Array.Copy(data,pos,res, (i * width + j) * 8 * 16 + k * 16, 16);
                        pos += 16;
                    }
            return res;
        }
        public static byte[] import8bitBitmap(byte[] file,int width,int height,int mode)
        {
            int w = width;
            int h = height;
            if ((mode &1)== 1)
            {
                width *= 16;
                height *= 8;
            }
            Bitmap bmp = new Bitmap(new System.IO.MemoryStream(file));
            if (bmp.PixelFormat != PixelFormat.Format8bppIndexed)
                throw new ApplicationException("Bad bitmap pixel format");
            if (bmp.Width != width || bmp.Height != height)
                throw new ApplicationException("Bad Size");
            byte[] res = new byte[width * height];
            BitmapData bd = bmp.LockBits(new Rectangle(0, 0, width, height),
                ImageLockMode.ReadOnly, bmp.PixelFormat);
            for (int i = 0; i < height;i++ )
                System.Runtime.InteropServices.Marshal.Copy(new IntPtr(bd.Scan0.ToInt64()+i*bd.Stride), res, i*bd.Width, bd.Width);
            bmp.UnlockBits(bd);
            if (mode==1)
                res=switchMode0to1(res,w,h);
            return res;
        }

        public override bool import(byte[] file)
        {
            return SkyDisk.get().importFile((int)filenum, 
                import8bitBitmap(file, w, h, mode));
        }
    }

    public class BSequence : BResource
    {
        int frames = 0;
        public Color bgColor;
        public BSequence(uint fnum, string color)
            : base(fnum)
        {
            if (color[0] == '#')
                bgColor = Color.FromArgb(int.Parse(color.Substring(1), System.Globalization.NumberStyles.AllowHexSpecifier));
            else
                bgColor = Color.FromName(color);
        }
        byte[] pixels = new byte[320];
        public override bool import(byte[] file)
        {
            Bitmap bmp = new Bitmap(new System.IO.MemoryStream(file));
            if (bmp.PixelFormat != PixelFormat.Format8bppIndexed)
                throw new ApplicationException("Bad bitmap pixel format");
            if (bmp.Width != 320 || bmp.Height % GAME_SCREEN_HEIGHT != 0)
                throw new ApplicationException("Bad bmp size");
            frames = bmp.Height / GAME_SCREEN_HEIGHT;
            List<byte> data = new List<byte>();
            data.Add((byte)frames);
            ColorPalette p = bmp.Palette;
            int ucol = -1;
            for (int i = 255; i >= 0 && ucol == -1; i--)
                if (p.Entries[i].ToArgb() == bgColor.ToArgb())
                    ucol = i;
            if (ucol == -1)
                throw new ApplicationException("Transparent color not found");
            BitmapData bd = bmp.LockBits(new Rectangle(0, 0, 320, bmp.Height),
                ImageLockMode.ReadWrite, bmp.PixelFormat);
            for (int i = 0; i < frames; i++)
            {
                bool empty = true;
                byte cnt = 0;
                int cntpos = 0;
                for (int j = 0; j < GAME_SCREEN_HEIGHT; j++)
                {
                    System.Runtime.InteropServices.Marshal.Copy(new IntPtr(bd.Scan0.ToInt64() + (j + i * GAME_SCREEN_HEIGHT) * bd.Stride), pixels, 0, bd.Width);
                    for (int k = 0; k < 320; k++)
                    {
                        byte c = pixels[k];
                        if (empty)
                        {
                            if (c == ucol)
                            {
                                cnt++;
                                if (cnt == 0xFF)
                                {
                                    data.Add(cnt);
                                    cnt = 0;
                                }
                            }
                            else
                            {
                                data.Add(cnt);
                                cnt = 1;
                                cntpos = data.Count;
                                data.Add(cnt);
                                data.Add(c);
                                empty = false;
                            }
                        }
                        else
                        {
                            if (c != ucol)
                            {
                                cnt++;
                                data.Add(c);
                                if (cnt == 0xFF)
                                {
                                    data[cntpos] = cnt;
                                    cnt = 0;
                                    cntpos = data.Count;
                                    data.Add(cnt);
                                }
                            }
                            else
                            {
                                data[cntpos] = cnt;
                                cnt = 1;
                                empty = true;
                            }
                        }
                    }
                }
                if (empty)
                {
                    data.Add(cnt);
                    data.Add(0);
                }
                else
                {
                    data[cntpos] = cnt;
                }
            }
            bmp.UnlockBits(bd);
            return SkyDisk.get().importFile((int)filenum, data.ToArray());
        }
    }

    public class BSprites : BResource
    {
        SkyDisk.FileHeader hdr;
        public BSprites(uint fnum)
            : base(fnum)
        {
            SkyDisk.DinnerEntry e=SkyDisk.get().fileInfo((int)fnum, false);
            hdr = SkyDisk.get().readHeader(fnum);
        }
        public override bool import(byte[] file)
        {
            byte[] img = BImage.import8bitBitmap(file, hdr.width, 
                hdr.height * hdr.n_sprites,0);
            byte[] data = new byte[img.Length + SkyDisk.FileHeader.size];
            Array.Copy(hdr.buf,data, SkyDisk.FileHeader.size);
            Array.Copy(img,0,data, SkyDisk.FileHeader.size,img.Length);
            return SkyDisk.get().importFile((int)filenum, data);
        }
    }


    public class BResourceHelper
    {
        public static string getAttr(XmlElement node, String attrName)
        {
            return getAttr(node, attrName, "");
        }
        public static string getAttr(XmlElement node, String attrName, String defValue)
        {
            if (node.Attributes[attrName] == null)
                return defValue;
            return node.Attributes[attrName].Value;
        }

        public static BResource getResource(XmlElement node,XmlElement ruCharNode)
        {
            uint fid = uint.Parse(node.Attributes["f"].Value);
            switch(node.Attributes["t"].Value)
            {
                case "palette":
                    return new BPalette(fid);
                case "image":
                    return new BImage(fid,int.Parse(getAttr(node,"w","0")),int.Parse(getAttr(node,"h","0")),
                        (getAttr(node, "m", "0") == "16x8" ? 1 : 0));
                case "sequence":
                    return new BSequence(fid, getAttr(node, "b", "aqua"));
                case "sprites":
                    return new BSprites(fid);
                case "charset":
                    return new BCharset(fid, int.Parse(getAttr(node, "h", "1")), 
                        int.Parse(getAttr(node, "s", "0")));
                case "text":
                    return new BText(fid,ruCharNode);
                    /*
                case "script":
                    return new BScripts(fid);
                case "music":
                    return new BMusic(fid);
                     */
                case "sound":
                    return new BSound(fid);
                case "speech":
                    return new BSpeech(fid);
                default:
                    return new BResource(fid);
            }
        }
    }
}
