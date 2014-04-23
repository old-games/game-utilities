#define NO_CATCH

using System;
using System.IO;
using System.Windows.Forms;
using System.Drawing.Imaging;

namespace Vlure
{
    class Program
    {
        const string VERSION = "0.4";

        static void usage()
        {
            Console.WriteLine(@"
Usage: vlure.exe [-p paths][params] command [params]

commands:
\t
help - show usage
list [known][disk diskId] - list [known] resources [from disk diskId]
dump fileId [-c] [-o file]- dump birary file
export fileId [-o file] - export resource by id
export all [-d dir] [-f textformat] - export all known resources
import fileId [-i file] - import resource by id
import all [-d dir] [-f textformat] - import known resources
img fileId [w h] - view resource as image [W x H]

args:
-h - show usage
-p path[;path] - paths to diskx.vga & lure.dat
-P path[;path] - override config paths
-l lang_id - set resources language (3-en 6-fr)
-d dir - resources directory
-o file - outfile
-i file - infile
-f xml|txt - output/input text format
-c - decompress
");
        }

        static void list(string[] argv)
        {
            bool known=false;
            int dsk = -1;
            int aid=1;
            while(aid<argv.Length)
            {
                string s=argv[aid];
                aid++;
                switch(s)
                {
                    case "known":
                        known=true;
                        break;
                    case "disk":
                        dsk=LureCommon.strToInt(argv[aid]);
                        aid++;
                        break;
                    default:
                        throw new Exception("unknown param "+s);
                }
            }
            Console.WriteLine("  id     offset      size       type");
            for (int i = 0; i < 5; i++)
            if (dsk==-1 || dsk==i)
            {
                Console.WriteLine("-=DISK "+i.ToString()+"=-");
                foreach (LureDisk.FileEntry f in LureDisks.get(i).entries)
                {
                    if (f.id == 0xFFFF)
                        break;
                    LureConfig.LureFile lf = LureConfig.get().findFile(f.id);
                    if (!known || lf != null)
                    {
                        Console.WriteLine(string.Format("{0,5:D}{1,12:X8}{2,12:X8}{3,20:s}",f.id,f.realOfs,f.realSize,(lf==null?"":lf.type)));
                    }
                }
            }
        }

        static void dump(int id)
        {
            string of=LureConfig.get().outputFile(id.ToString()+".bin");
            Console.WriteLine("dumping "+id.ToString()+" to "+of);
			byte[] data=LureDisks.getResource(id);
			if (LureConfig.get ().compress){
				data=Decompressor.decompress(data);
			}
            LureCommon.dumpFile(data,of);
        }

        static void export(int id)
        {
            if (id == -1)
            {
                Console.WriteLine("export all");
                int mode = LureConfig.get().textfmt;
                string ext = ".xml";
                if (mode == 1)
                    ext = ".txt";
                string d = LureConfig.get().direcroty("./");
                if (!Directory.Exists(d))
                    Directory.CreateDirectory(d);
                if (d[d.Length-1]!='\\' && d[d.Length-1]!='/') d+="/";
                foreach (LureConfig.LureFile f in LureConfig.get().lureFiles)
                {
                    switch(f.type)
                    {
                        case "font":
							new LureFont(f.id).export().Save(d+"lure_font.bmp",ImageFormat.Bmp);
                            break;
                        case "text_decode_table":
                            TextDecoder.get().export().Save(d+"decoder.xml");
                            break;
                        case "image":
                            int w=LureCommon.strToInt(f.node.Attributes["width"].Value);
                            int h=LureCommon.strToInt(f.node.Attributes["height"].Value);
                            string  pal=f.node.Attributes["palette"].Value;
                            string nm="image"+f.id.ToString();
                            if (f.node.Attributes["name"]!=null)
                                nm=f.node.Attributes["name"].Value;
                            new LureImage(f.id, w, h, pal).export().Save(d + nm+".bmp",ImageFormat.Bmp);
                            break;
						case "anim":
							string apal=f.node.Attributes["palette"].Value;
							string anm="anim"+f.id.ToString();
							if (f.node.Attributes["name"]!=null)
								anm=f.node.Attributes["name"].Value;
							new LureAnim(f.id, apal).export().Save(d + anm+".bmp",ImageFormat.Bmp);
							break;
					}
                }
                LureTexts.getAllTexts().save(d+"lure_text"+ext,mode);
            }
            else
            {
                Console.WriteLine("export " + id.ToString());
                exportResource(id);
            }
        }

        static void import(int id)
        {
            if (id == -1)
            {
                Console.WriteLine("import all");
                int mode = LureConfig.get().textfmt;
                string ext = ".xml";
                if (mode == 1)
                    ext = ".txt";
                string d = LureConfig.get().direcroty("./");
                if (!Directory.Exists(d))
                    Directory.CreateDirectory(d);
                if (d[d.Length - 1] != '\\' && d[d.Length - 1] != '/') d += "/";
                foreach (LureConfig.LureFile f in LureConfig.get().lureFiles)
                {
                    switch (f.type)
                    {
                        case "font":
                            new LureFont(f.id).import(new System.Drawing.Bitmap(d + "lure_font.bmp"));
                            break;
                        case "text_decode_table":
                            TextDecoder.get().import(LureCommon.loadXml(d+"decoder.xml"));
                            break;
                        case "image":
                            int w = LureCommon.strToInt(f.node.Attributes["width"].Value);
                            int h = LureCommon.strToInt(f.node.Attributes["height"].Value);
                            string pal = f.node.Attributes["palette"].Value;
                            string nm = "image" + f.id.ToString();
                            if (f.node.Attributes["name"] != null)
                                nm = f.node.Attributes["name"].Value;
                            new LureImage(f.id, w, h, pal).import(new System.Drawing.Bitmap(d + nm + ".bmp"));
                            break;
						case "anim":
							string apal = f.node.Attributes["palette"].Value;
							string anm = "anim" + f.id.ToString();
							if (f.node.Attributes["name"] != null)
								anm = f.node.Attributes["name"].Value;
							new LureAnim(f.id, apal).import(new System.Drawing.Bitmap(d + anm + ".bmp"));
							break;
                    }
                }
                LureTexts.getAllTexts().load(d + "lure_text" + ext, mode);
            }
            else
            {
                Console.WriteLine("import " + id.ToString());
                importResource(id);
            }
            LureDisks.saveAll();
        }

        public static void exportResource(int id)
        {
            LureConfig.LureFile f = LureConfig.get().findFile(id);
            if (f == null)
                throw new Exception("File not found in config " + id.ToString());
            string outfile = "";
            switch (f.type)
            {
                case "text":
                case "string_list":
                case "text_decode_table":
                    outfile = LureConfig.get().outputFile(id.ToString() + ".xml");
                    if (f.type == "text")
                        new LureText(f.id).export().Save(outfile);
                    else if (f.type == "text_decode_table")
                        TextDecoder.get().export().Save(outfile);
                    else
                        new LureStringList(f.id).export().Save(outfile);
                    break;
                case "font":
                    outfile = LureConfig.get().outputFile(id.ToString() + ".bmp");
					new LureFont(f.id).export().Save(outfile,ImageFormat.Bmp);
                    break;
                case "image":
                    int w = LureCommon.strToInt(f.node.Attributes["width"].Value);
                    int h = LureCommon.strToInt(f.node.Attributes["height"].Value);
                    string pal = f.node.Attributes["palette"].Value;
                    string nm = "image" + f.id.ToString();
                    if (f.node.Attributes["name"] != null)
                        nm = f.node.Attributes["name"].Value;
                    outfile = LureConfig.get().outputFile(nm + ".bmp");
					new LureImage(f.id, w, h, pal).export().Save(outfile,ImageFormat.Bmp);
                    break;
				case "anim":
					string apal = f.node.Attributes["palette"].Value;
					string anm = "image" + f.id.ToString();
					if (f.node.Attributes["name"] != null)
						anm = f.node.Attributes["name"].Value;
					outfile = LureConfig.get().outputFile(anm + ".bmp");
					new LureAnim(f.id, apal).export().Save(outfile,ImageFormat.Bmp);
					break;
			default:
                    throw new Exception("dont know how to export " + f.type);
            }
        }

        public static void importResource(int id)
        {
            LureConfig.LureFile f = LureConfig.get().findFile(id);
            if (f == null)
                throw new Exception("File not found in config " + id.ToString());
            string infile = "";
            switch (f.type)
            {
                case "text":
                case "string_list":
                case "text_decode_table":
                    infile = LureConfig.get().inputFile(id.ToString() + ".xml");
                    LureCommon.checkFile(infile);
                    System.Xml.XmlDocument doc=new System.Xml.XmlDocument();
                    doc.Load(infile);
                    if (f.type == "text")
                        new LureText(f.id).import(doc);
                    else if (f.type == "text_decode_table")
                        TextDecoder.get().import(doc);
                    else
                        new LureStringList(f.id).import(doc);
                    break;
                case "font":
                    infile = LureConfig.get().inputFile(id.ToString() + ".bmp");
                    LureCommon.checkFile(infile);
                    System.Drawing.Bitmap bmp = new System.Drawing.Bitmap(infile);
                    new LureFont(f.id).import(bmp);
                    break;
                case "image":
                    int w = LureCommon.strToInt(f.node.Attributes["width"].Value);
                    int h = LureCommon.strToInt(f.node.Attributes["height"].Value);
                    string pal = f.node.Attributes["palette"].Value;
                    string nm = "image" + f.id.ToString();
                    if (f.node.Attributes["name"] != null)
                        nm = f.node.Attributes["name"].Value;
                    infile = LureConfig.get().outputFile(nm + ".bmp");
                    new LureImage(f.id, w, h, pal).import(new System.Drawing.Bitmap(infile));
                    break;
				case "anim":
					string apal = f.node.Attributes["palette"].Value;
					string anm = "image" + f.id.ToString();
					if (f.node.Attributes["name"] != null)
						anm = f.node.Attributes["name"].Value;
					infile = LureConfig.get().outputFile(anm + ".bmp");
					new LureAnim(f.id, apal).import(new System.Drawing.Bitmap(infile));
					break;
                default:
                    throw new Exception("dont know how to import " + f.type);
            }
        }

        static string getarg(string[] args,int id)
        {
            if (args.Length > id)
                return args[id];
            throw new Exception("no argument");
        }

        static Form viewImage(int fileid,int w,int h)
        {
            LureConfig.LureFile f = LureConfig.get().findFile(fileid);
            string pal = "";
            string nm = "";
            if (f != null)
            {
                pal = f.node.Attributes["palette"].Value;
                if (f.node.Attributes["name"]!=null)
                    nm = f.node.Attributes["name"].Value;
                if (w == 0) w = LureCommon.strToInt(f.node.Attributes["width"].Value);
                if (h == 0) h = LureCommon.strToInt(f.node.Attributes["height"].Value);
            }
            if (w == 0) w = 320;
            if (h == 0) h = 200;
            return new ImgForm(fileid, w, h, pal,nm);
        }

        [STAThread]
        static void Main(string[] args)
        {
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);
            Console.WriteLine("vlure v" + VERSION + " by Br. John Fn None");
#if !NO_CATCH
            try
#endif
            {
                string[] argv = LureConfig.get().setParams(args);
                if (LureConfig.get().help || argv.Length == 0 || argv[0] == "help")
                {
                    usage();
                    return;
                }
                switch (argv[0])
                {
                    case "list":
                        list(argv);
                        return;
                    case "dump":
                        dump(LureCommon.strToInt(getarg(argv,1)));
                        return;
                    case "export":
                        export(getarg(argv,1)=="all"?-1:LureCommon.strToInt(argv[1]));
                        return;
                    case "import":
                        import(getarg(argv,1) == "all" ? -1 : LureCommon.strToInt(argv[1]));
                        return;
                    case "img":
                        int w = 0;
                        int h = 0;
                        try
                        {
                            w=LureCommon.strToInt(argv[2]);
                            h=LureCommon.strToInt(argv[3]);
                        }catch{}
                        Application.Run(viewImage(LureCommon.strToInt(argv[1]),w,h));
                        return;
                    case "test":
                        test(argv);
                        return;
                    default:
                        throw new Exception("unknown command "+argv[0]);
                }
            }
#if !NO_CATCH
            catch (Exception ex)
            {
                Console.WriteLine("ERROR: "+ex.Message+"\n"+ex.StackTrace);
                Console.ReadKey();
            }
#endif
        }

        static void test(string[] args)
        {
            Console.WriteLine("running test");
            int[] imgs=new int[]{5,0x18,0x1A,0x1C,0x1E,0x40,0x42,0x44,0x46,0x24};
            for (int i = 0; i < imgs.Length; i++)
            {
                Console.WriteLine(String.Format("----test compression res {0:D}(0x{0:X})",imgs[i]));
                byte[] data = LureDisks.getResource(imgs[i]);
                byte[] real = Decompressor.decompress(data);
                byte[] udata = Compressor.compress(real);
                byte[] xdata = Decompressor.decompress(udata);
                bool eq = true;
                if (xdata.Length != real.Length)
                    eq = false;
                else
                    for (int j = 0; j < xdata.Length && eq; j++)
                        if (xdata[j] != real[j])
                            eq = false;
                Console.WriteLine("decompress test "+(eq?"OK":"FAILED"));
                Console.WriteLine(String.Format("res {0:d} compress real={1:d} our={2:d}", imgs[i], data.Length, udata.Length));
                eq=true;
                if (data.Length==udata.Length)
                {
                    for (int j=0;j<data.Length;j++)
                        if (data[j]!=udata[j])
                            eq=false;
                }else
                    eq=false;
                Console.WriteLine("res "+imgs[i].ToString()+" "+(eq?"EQUAL":"not equal"));
                if (!eq)
                {
                    FileStream fs=new FileStream("res"+imgs[i].ToString()+"real.bin",FileMode.Create);
                    fs.Write(data,0,data.Length);
                    fs.Close();
                    fs=new FileStream("res"+imgs[i].ToString()+"our.bin",FileMode.Create);
                    fs.Write(udata,0,udata.Length);
                    fs.Close();
                    fs = new FileStream("res" + imgs[i].ToString() + "unpacked.bin", FileMode.Create);
                    fs.Write(real, 0, real.Length);
                    fs.Close();
                }
            }
            Console.ReadKey();
        }
    }
}
