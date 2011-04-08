using System;
using System.Drawing;
using System.Xml;
using System.IO;
using System.Drawing.Imaging;
using System.Collections.Generic;

namespace bassru
{
    public class BResource
    {
        public const int GAME_SCREEN_HEIGHT = 192;
        ResView.BResourceControl cntr = null;
        uint fnum;
        protected int unused=0;
        byte[] xdata = null;
        public BResource(uint fnum,ResView.BResourceControl cntr)
        {
            this.fnum = fnum;
            this.cntr=cntr;
        }
        public BResource(uint fnum):this(fnum,null){}
        public uint filenum{get{return fnum;}}
        public byte[] getData()
        {
            if (xdata == null)
                xdata = SkyDisk.get().readFile((int)fnum);
            return xdata;
        }
        public int unusedBytes{get{return unused;}}
        public ResView.BResourceControl control { get { return cntr; } }
        public void initControl()
        {
            control.setObject(this);
        }
        public virtual bool export(string filename)
        {
            FileStream fs=new FileStream(filename,FileMode.Create);
            fs.Write(getData(),0,getData().Length);
            fs.Close();
            return true;
        }
        public virtual bool import(string filename)
        {
            FileStream fs=new FileStream(filename,FileMode.Open);
            if (fs.Length!=getData().Length)
            {
                fs.Close();
                return false;
            }
            byte[] data=new byte[fs.Length];
            fs.Read(data,0,data.Length);
            fs.Close();
            return SkyDisk.get().importFile((int)filenum, data);
        }
        public virtual string getFilter()
        {
            return "Binary File (*.bin)|*.bin";
        }
    }

    public class BPalette : BResource
    {
        public static string xmlFilter="Xml File (*.xml)|*.xml";
        public static BPalette gsp = null;
        public static BPalette GrayScalePalette()
        {
            if (gsp == null) gsp = new BPalette();
            return gsp;
        }

        const string gray = "GRAYSCALE";
        string nm="";
        byte[] data;
        Color[] pal;
        byte[] stdcol = new byte[16*3]{0, 0, 0, 	38, 38, 38, 	63, 63, 63,
	0, 0, 0,	0, 0, 0,	0, 0, 0,	0, 0, 0,	54, 54, 54, 	45, 47, 49,
	32, 31, 41, 	29, 23, 37, 	23, 18, 30, 	49, 11, 11, 	39, 5, 5,
	29, 1, 1,	63, 63, 63};
        public BPalette(uint fnum,string name)
            : base(fnum,ResView.ViewPalette.get())
        {
            nm = name;
            data = getData();
            unused = data.Length - 256 * 3;
            pal=loadPal(true, false, false);
        }
        public BPalette(XmlNode nd)
            : base(0)
        {
            nm="skycpt."+nd.Attributes["name"].Value;
            pal = new Color[256];
            for (int i = 0; i < 256; i++)
            {
                if (i<nd.ChildNodes.Count)
                {
                    byte r=byte.Parse(nd.ChildNodes[i].Attributes["r"].Value);
                    byte g = byte.Parse(nd.ChildNodes[i].Attributes["g"].Value);
                    byte b = byte.Parse(nd.ChildNodes[i].Attributes["b"].Value);
                    pal[i] = Color.FromArgb(r, g, b);
                }
                else
                    pal[i]=Color.Black;
            }
        }
        public BPalette():base(0)
        {

            nm = gray;
            pal = new Color[256];
            for (int i = 0; i < 256; i++)
                pal[i] = Color.FromArgb(i, i, i);
        }

        public string name { get { return nm; } }

        private Color[] loadPal(bool stdcolours,bool unconverted,bool halftone)
        {
            Color[] p=new Color[256];
            for (int i = 0; i < 256; i++)
            {
                byte r,g,b;
                r=data[i*3];g=data[i*3+1];b=data[i*3+2];
                if (stdcolours && i>=240)
                {r=stdcol[(i-240)*3];g=stdcol[(i-240)*3+1];b=stdcol[(i-240)*3+2];}
                if (!unconverted)
                {r=(byte)((r<<2)+(r>>4));g=(byte)((g<<2)+(g>>4));b=(byte)((b<<2)+(b>>4));}
                if (halftone)
                {r = (byte)(r >> 1);g = (byte)(g >> 1);b = (byte)(b >> 1);}
                p[i] = Color.FromArgb(r, g, b);
                //c=(c*4)+(c/8)
            }
            return p;
        }

        public Color[] getPal(bool stdcolours,bool unconverted,bool halftone)
        {
            if (nm == gray) return pal;
            if (stdcolours && !unconverted && !halftone)
                return pal;
            return loadPal(stdcolours, unconverted, halftone);
        }

        public Color[] getPal()
        {
            return pal;
        }

        public static XmlDocument getXmlDoc(string root)
        {
            XmlDocument doc = new XmlDocument();
            doc.LoadXml("<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<"+root+"/>");
            return doc;
        }

        public override bool export(string filename)
        {
            XmlDocument doc = getXmlDoc("bassru-palette");
            Color[] pl = getPal(false, false, false);
            for (int i = 0; i < 256; i++)
            {
                XmlElement el = (XmlElement)doc.DocumentElement.AppendChild(doc.CreateElement("color"));
                el.Attributes.Append(doc.CreateAttribute("id")).Value = i.ToString();
                el.Attributes.Append(doc.CreateAttribute("r")).Value = pl[i].R.ToString();
                el.Attributes.Append(doc.CreateAttribute("g")).Value = pl[i].G.ToString();
                el.Attributes.Append(doc.CreateAttribute("b")).Value = pl[i].B.ToString();
            }
            doc.Save(filename);
            return true;
        }

        public override bool import(string filename)
        {
            byte[] buf=new byte[256*3];
            Array.Copy(data,buf,256*3);
            XmlDocument doc = new XmlDocument();
            doc.Load(filename);
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
        public override string getFilter()
        {
            return xmlFilter;
        }
    }

    public class BImage : BResource
    {
        int w, h;
        string pal;
        byte[] imgData;
        int mode = 0;
        public static string bmpFilter = "Bitmap File (*.bmp)|*.bmp";
        public BImage(uint fnum,int w,int h,string pal,int mode) : base(fnum, ResView.ImageView.get()) 
        {
            this.w = w;
            this.h = h;
            this.pal = pal;
            imgData = getData();
            unused = imgData.Length - w * h;
            if ((mode&1)!=0)
                unused = imgData.Length - w * h*8*16;
            this.mode = mode;
        }
        public int width { get { return w; } set { w = value; } }
        public int height { get { return h; } set { h = value; } }
        public string palette { get { return pal; } set { pal = value; } }
        public int imgMode { get { return mode; } set { mode = value; } }
        public byte[] imagedata { get { return imgData; } }
        public static Bitmap get32bitBitmap(int width, int height, BPalette palette, byte[] data, int mode)
        {
            width*=(mode==0?1:16);
            height*=(mode==0?1:8);
            Bitmap bmp = new Bitmap(width, height);
            Graphics g = Graphics.FromImage(bmp);
            Color[] cls = palette.getPal(true, false, ((mode & 2) != 0));
            g.FillRectangle(new SolidBrush(Color.Red), new Rectangle(0, 0, width, height));
            if ((mode&1) != 1)
            {
                for (int i=0;i<height;i++)
                    for (int j = 0; j < width; j++)
                    {
                        int idx = i * width + j;
                        if (data.Length > idx)
                            bmp.SetPixel(j, i, cls[data[idx]]);
                    }
            }
            else
            {
                for (int k = 0; k < height/8; k++)
                {
                    for (int m = 0; m < width/16; m++)
                    {
                        for(int i=0;i<8;i++)
                            for (int j = 0; j < 16; j++)
                            {
                                int idx = (k * width/16 + m) * 8*16 + i * 16 + j;
                                if (data.Length > idx)
                                    bmp.SetPixel(m*16+j,k*8+i,cls[data[idx]]);
                            }
                    }
                }
            }
            return bmp;
        }
        public static byte[] switchMode1to0(byte[] data,ref int width,ref int height)
        {
            byte[] res = new byte[data.Length];
            int w = width * 16;
            int h = height * 8;
            int pos = 0;
            for (int i = 0; i < height; i++)
                for (int k = 0; k < 8; k++)
                    for (int j = 0; j < width; j++)
                    {
                        Array.Copy(data, (i * width + j) * 8 * 16 + k * 16, res, pos, 16);
                        pos += 16;
                    }

            width = w;
            height = h;
            return res;
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
        public static Bitmap get8bitBitmap(int width, int height, BPalette palette, byte[] data, int mode)
        {
            if ((mode & 1) == 1)
                data = switchMode1to0(data, ref width, ref height);
            Bitmap bmp = new Bitmap(width, height, PixelFormat.Format8bppIndexed);
            ColorPalette tmppal = bmp.Palette;
            Color[] cls = palette.getPal(true, false, ((mode & 2) != 0));
            for (int i = 0; i < 256; i++)
                tmppal.Entries[i] = cls[i];
            bmp.Palette = tmppal;
            BitmapData bd = bmp.LockBits(new Rectangle(0, 0, width, height),
                ImageLockMode.WriteOnly, bmp.PixelFormat);
            for (int i = 0; i < height; i++)
                System.Runtime.InteropServices.Marshal.Copy(data, i*bd.Width, new IntPtr(bd.Scan0.ToInt64()+i*bd.Stride), bd.Width);
            bmp.UnlockBits(bd);
            return bmp;
        }
        public static byte[] import8bitBitmap(string filename,int width,int height,BPalette palette,int mode)
        {
            int w = width;
            int h = height;
            if ((mode &1)== 1)
            {
                width *= 16;
                height *= 8;
            }
            Bitmap bmp = new Bitmap(filename);
            if (bmp.PixelFormat != PixelFormat.Format8bppIndexed)
                throw new ApplicationException("Bad bitmap pixel format");
            if (bmp.Width != width || bmp.Height != height)
                throw new ApplicationException("Bad Size");
            int md=0;
            Color[] cls = palette.getPal(true, false, ((mode & 2) != 0));
            for (int i = 0; i < 256 && md == 0; i++)
                if (bmp.Palette.Entries[i] != cls[i])
                    md = ResView.BResourceControl.askForBadPal();
            byte[] res = new byte[width * height];
            BitmapData bd = bmp.LockBits(new Rectangle(0, 0, width, height),
                ImageLockMode.ReadWrite, bmp.PixelFormat);
            for (int i = 0; i < height; i++)
                System.Runtime.InteropServices.Marshal.Copy(new IntPtr(bd.Scan0.ToInt64()+i*bd.Stride), res, i * bd.Width, bd.Width);
            bmp.UnlockBits(bd);
            if (mode==1)
                res=switchMode0to1(res,w,h);
            return res;
        }

        public override bool export(string filename)
        {
            get8bitBitmap(w, h, Config.get().findPalette(pal), imagedata,mode).Save(filename, ImageFormat.Bmp);
            return true;
        }
        public override bool import(string filename)
        {
            return SkyDisk.get().importFile((int)filenum, 
                import8bitBitmap(filename, w, h, Config.get().findPalette(pal),mode));
        }
        public override string getFilter()
        {
            return bmpFilter;
        }
        public Bitmap getBmp()
        {
            return getBmp(w, h, pal,mode);
        }
        public Bitmap getBmp(int width,int height,string palette,int mode)
        {
            return get32bitBitmap(width, height, Config.get().findPalette(pal), imagedata,mode);
        }
        public Bitmap getBmp(int width, int height, BPalette palette, int mode)
        {
            return get32bitBitmap(width, height, palette, imagedata, mode);
        }
    }

    public class BSequence : BResource
    {
        string pal;
        public byte[] seqdata;
        int frames = 0;
        int screens=0;
        public Color bgColor;
        int ucolor=-1;
        public BSequence(uint fnum,string pal,string color)
            : base(fnum, ResView.SequenceView.get())
        {
            this.pal = pal;
            seqdata = getData();
            frames = seqdata[0];
            process();
            if (color[0] == '#')
                bgColor = Color.FromArgb(int.Parse(color.Substring(1), System.Globalization.NumberStyles.AllowHexSpecifier));
            else
                bgColor = Color.FromName(color);
        }

        public int frameCnt { get { return frames; } }
        public int screenCnt { get { return screens; } }
        void process()
        {
            bool[] ucolors = new bool[256];
            for (int i = 0; i < 256; i++)
                ucolors[i] = false;
            int pos = 1;
            int scrpos = 0;
            int scrsz = 320 * GAME_SCREEN_HEIGHT;
            screens = 0;
            while(pos<seqdata.Length)
            {
                while (scrpos < scrsz && pos<seqdata.Length)
                {
                    byte skp = 0;
                    do
                    {
                        skp = seqdata[pos++];
                        scrpos += skp;
                    } while (skp == 0xFF);
                    do
                    {
                        skp = seqdata[pos++];
                        for (int i = 0; i < skp; i++)
                            ucolors[seqdata[pos++]] = true;
                        scrpos += skp;
                    } while (skp == 0xFF);
                    if (scrpos >= scrsz)
                    {
                        screens++;
                        scrpos = 0;
                    }
                }
            }
            for (int i = 255; i>=0 && ucolor==-1; i--)
            {
                if (!ucolors[i])
                    ucolor = i;
            }
            unused = scrpos;
            if (ucolor == -1)
                throw new ApplicationException("No unused color");
        }

        byte[] pixels = new byte[320];
        public void putPixel(int screen, int pos, BitmapData bd, byte cl)
        {
            int y = screen * GAME_SCREEN_HEIGHT;
            y += pos / 320;
            int x = pos % 320;
            pixels[x] = cl;
            if (x == 319)
            {
                System.Runtime.InteropServices.Marshal.Copy(pixels, 0, new IntPtr(bd.Scan0.ToInt64() + y * bd.Stride), bd.Width);
            }
        }

        public Bitmap makeBitmap(Color bgColor, BPalette pal)
        {
            if (ucolor == -1)
                throw new ApplicationException("No unused color");
            Bitmap bmp = new Bitmap(320, GAME_SCREEN_HEIGHT * screenCnt,PixelFormat.Format8bppIndexed);
            ColorPalette p = bmp.Palette;
            for (int i = 0; i < 256; i++)
                if (i == ucolor)
                    p.Entries[i] = bgColor;
                else
                    p.Entries[i] = pal.getPal()[i];
            bmp.Palette = p;
            int pos = 1;
            int scrpos = 0;
            int scrsz = 320 * GAME_SCREEN_HEIGHT;
            int curscr = 0;
            BitmapData bd = bmp.LockBits(new Rectangle(0, 0, bmp.Width, bmp.Height),
                            ImageLockMode.WriteOnly, bmp.PixelFormat);
            while (pos < seqdata.Length)
            {
                while (scrpos < scrsz && pos < seqdata.Length)
                {
                    byte skp = 0;
                    do
                    {
                        skp = seqdata[pos++];
                        for (int i = 0; i < skp; i++)
                            putPixel(curscr, scrpos+i, bd, (byte)ucolor);
                        scrpos += skp;
                    } while (skp == 0xFF);
                    do
                    {
                        skp = seqdata[pos++];
                        for (int i = 0; i < skp; i++)
                            putPixel(curscr, scrpos + i, bd,seqdata[pos++]);
                        scrpos += skp;
                    } while (skp == 0xFF);
                    if (scrpos >= scrsz)
                    {
                        curscr++;
                        scrpos = 0;
                    }
                }
            }
            bmp.UnlockBits(bd);
            return bmp;
        }

        public string palette { get { return pal; } }
        public byte[] sequenceData { get { return seqdata; } }
        public override bool export(string filename)
        {
            makeBitmap(bgColor, Config.get().findPalette(pal)).Save(filename, ImageFormat.Bmp);
            return true;
        }

        public override bool import(string filename)
        {
            Bitmap bmp = new Bitmap(filename);
            if (bmp.Width != 320 || bmp.Height != GAME_SCREEN_HEIGHT * screenCnt)
                throw new ApplicationException("Bad bmp size");
            List<byte> data = new List<byte>();
            data.Add((byte)screenCnt);
            ColorPalette p = bmp.Palette;
            int ucol = -1;
            for (int i = 255; i >= 0 && ucol == -1; i--)
                if (p.Entries[i].ToArgb() == bgColor.ToArgb())
                    ucol = i;
            if (ucol == -1)
                throw new ApplicationException("Transparent color not found");
            BitmapData bd = bmp.LockBits(new Rectangle(0, 0, 320, bmp.Height),
                ImageLockMode.ReadWrite, bmp.PixelFormat);
            for (int i = 0; i < screenCnt; i++)
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
        public override string getFilter()
        {
            return BImage.bmpFilter;
        }
    }

    public class BSprites : BResource
    {
        string pal;
        SkyDisk.FileHeader hdr;
        byte[] sprdata;
        public BSprites(uint fnum, string pal)
            : base(fnum, ResView.SpritesView.get())
        {
            this.pal = pal;
            byte[] data = getData();
            SkyDisk.DinnerEntry e=SkyDisk.get().fileInfo((int)fnum, false);
            hdr = new SkyDisk.FileHeader(data);
            sprdata = new byte[data.Length - SkyDisk.FileHeader.size];
            Array.Copy(data, SkyDisk.FileHeader.size, sprdata, 0, sprdata.Length);
            unused = sprdata.Length - (hdr.width * hdr.height*hdr.n_sprites);
        }
        public string palette { get { return pal; } }
        public SkyDisk.FileHeader header { get { return hdr; } }
        public byte[] spriteData { get { return sprdata; } }
        public byte[] frame(int id)
        {
            byte[] frm =new byte[hdr.width * hdr.height];
            int pos = id * frm.Length;
            Array.Copy(sprdata, pos, frm, 0, frm.Length);
            return frm;
        }

        public override bool export(string filename)
        {
            BImage.get8bitBitmap(hdr.width, hdr.height * hdr.n_sprites,
                Config.get().findPalette(pal), sprdata,0).Save(filename, ImageFormat.Bmp);
            return true;
        }

        public override bool import(string filename)
        {
            byte[] img = BImage.import8bitBitmap(filename, hdr.width, 
                hdr.height * hdr.n_sprites, Config.get().findPalette(pal),0);
            byte[] data = new byte[img.Length + SkyDisk.FileHeader.size];
            Array.Copy(hdr.buf,data, SkyDisk.FileHeader.size);
            Array.Copy(img,0,data, SkyDisk.FileHeader.size,img.Length);
            return SkyDisk.get().importFile((int)filenum, data);
        }

        public override string getFilter()
        {
            return BImage.bmpFilter;
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

        public static BResource getResource(XmlElement node)
        {
            uint fid = uint.Parse(node.Attributes["id"].Value);
            switch(node.Attributes["type"].Value)
            {
                case "palette":
                    return new BPalette(fid, getAttr(node,"name","unnamed"));
                case "image":
                    return new BImage(fid,int.Parse(getAttr(node,"width","0")),int.Parse(getAttr(node,"height","0")),
                        getAttr(node,"palette"),
                        (getAttr(node, "imgmode", "0") == "16x8" ? 1 : 0) + (getAttr(node, "halftone", "0")=="1"?2:0));
                case "sequence":
                    return new BSequence(fid,getAttr(node, "palette"),getAttr(node,"bg","aqua"));
                case "sprites":
                    return new BSprites(fid, getAttr(node, "palette"));
                case "charset":
                    return new BCharset(fid, int.Parse(getAttr(node, "height", "1")), 
                        int.Parse(getAttr(node, "spacing", "0")));
                case "text":
                    return new BText(fid);
                case "script":
                    return new BScripts(fid);
                case "music":
                    return new BMusic(fid);
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
