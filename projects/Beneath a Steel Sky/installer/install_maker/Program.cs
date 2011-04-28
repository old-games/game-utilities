using System;
using System.IO;
using System.Runtime.InteropServices;
using System.Windows.Forms;
using System.Xml;

namespace install_maker
{
    static class Program
    {
        [DllImport("kernel32.dll")]
        public static extern Int32 AllocConsole();
        [DllImport("kernel32.dll")]
        public static extern Int32 FreeConsole();

        static void usage()
        {
            Console.WriteLine(@"Usage:
install_maker config.xml outpath - make install");
        }

        /// <summary>
        /// Главная точка входа для приложения.
        /// </summary>
        [STAThread]
        static void Main(string[] args)
        {
            if (args.Length == 0)
            {
                Application.EnableVisualStyles();
                Application.SetCompatibleTextRenderingDefault(false);
                Application.Run(new Form1());
            }
            else
            {
                AllocConsole();
                Environment.ExitCode = 0;
                Console.WriteLine("install maker v1.0 by bjfn @ 2011 4 og");
                try
                {
                    if (!File.Exists(args[0]) || args.Length<2 || !Directory.Exists(args[1]))
                    {
                        usage();
                        throw new Exception("");
                    }
                    XmlDocument doc = new XmlDocument();
                    Console.WriteLine("reading config");
                    doc.Load(args[0]);
                    if (doc.DocumentElement.Name != "install_maker_config")
                        throw new Exception("Bad config root");
                    buildAll(doc, args[1]);
                }
                catch (Exception ex)
                {
                    Console.WriteLine(ex.Message);
                    Environment.ExitCode = 1;
                    Console.ReadKey();
                }
                FreeConsole();
            }
        }

        static bool getcheck(XmlAttribute atr,bool defvalue)
        {
            if (atr==null)
                return defvalue;
            return (atr.Value == "yes");
        }

        static void buildAll(XmlDocument doc,string outpath)
        {
            Builder b = Builder.getBuilder();
            b.clear();
            foreach (XmlNode nd in doc.DocumentElement.ChildNodes)
                if (nd.NodeType==XmlNodeType.Element)
                    if (nd.Name == "options")
                    {
                        string app="";
                        string icon="";
                        int pack=0;
                        bool comp = true;
                        foreach(XmlNode n in nd.ChildNodes)
                        if (n.NodeType==XmlNodeType.Element)
                            switch (n.Name)
                            {
                                case "app":
                                    app = n.Attributes["name"].Value;
                                    if (n.Attributes["icon"] != null)
                                        icon = n.Attributes["icon"].Value;
                                    break;
                                case "browser":
                                    bool inter = getcheck(n.Attributes["internal"], true);
                                    bool sz=false;
                                    bool mx=false;
                                    int w=640;
                                    int h=480;
                                    if (inter)
                                    {
                                        sz = getcheck(n.Attributes["sizeable"], false);
                                        mx = getcheck(n.Attributes["maximized"], false);
                                        if (!mx)
                                        {
                                            w = int.Parse(n.Attributes["width"].Value);
                                            h = int.Parse(n.Attributes["height"].Value);
                                        }
                                    }
                                    b.setBrowser(inter,sz,mx,w,h);
                                    break;
                                case "pack":
                                    pack = int.Parse(n.Attributes["type"].Value);
                                    comp = getcheck(n.Attributes["compressed"], true);
                                    break;
                                case "flags": 
                                    bool dbg=getcheck(n.Attributes["debug"],false);
                                    b.setFlags(dbg,
                                        getcheck(n.Attributes["console"],dbg),
                                        getcheck(n.Attributes["logfile"],false));
                                    break;
                            }
                        b.setParams(app,pack,comp,icon);
                    }
                    else if (nd.Name=="files")
                    {
                        foreach(XmlNode n in nd.ChildNodes)
                            if (n.NodeType == XmlNodeType.Element && n.Name == "file")
                            {
                                string s = n.Attributes["name"].Value;
                                string a = (s == Builder.INST_API_TAG)?(Builder.INST_API_FILE):(Path.GetFileName(s));
                                if (n.Attributes["alias"] != null)
                                    a = n.Attributes["alias"].Value;
                                b.addFile(a, s);
                            }
                    }
            Console.WriteLine("building...");
            b.build(outpath);
        }
    }
}
