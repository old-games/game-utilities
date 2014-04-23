using System;
using System.IO;

namespace bassru_patcher
{
    class Program
    {
        static void usage()
        {
            Console.WriteLine(@"
usage:
bassru_patcher make patch.xml [-o file] - make patch from external resources

bassru_patcher patch patch.xml [-f dskfile] [-o dskfile] [-i] - patch dsk.file with external resources

bassru_patcher [file.dsk] [-i] - patch dsk.file

bassru_patcher -h|help|--help|/?|? - help

i - make install pack
");
        }

        static void Main(string[] args)
        {
            Console.WriteLine("bassru_patcher v0.5 by bjfn @2011 4 OG proj");
            string cmd = "";
            string dskfile = "sky.dsk";
            if (args.Length > 0)
                switch (args[0])
                {
                    case "make":
                    case "patch":
                        cmd = args[0];
                        break;
                    case "-h":
                    case "--help":
                    case "help":
                    case "/?":
                    case "?":
                        usage();
                        return;
                    case "-i":
                        break;
                    default:
                        dskfile = args[0];
                        break;
                }
//            try{

            if (cmd == "")
            {
                if (!File.Exists(dskfile))
                    throw new Exception("DSK File not found "+dskfile);
                Patcher p = new Patcher(args, 0);
                p.patch();
            }
            else if (cmd == "make")
            {
                PatchMaker pm = new PatchMaker(args);
                pm.run();
            }
            else if (cmd == "patch")
            {
                Patcher p = new Patcher(args, 1);
                p.patch();
            }
            /*
            }catch(Exception ex)
            {
                Console.WriteLine("ERROR: "+ex.Message+ex.StackTrace);
                Console.WriteLine("press any key...");
                Console.ReadKey();
            }
             * */
        }
    }
}
