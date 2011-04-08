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

bassru_patcher patch patch.xml [-f dskfile] [-o dskfile] - patch dsk.file with external resources

bassru_patcher [file.dsk] - patch dsk.file

bassru_patcher -h|help|--help|/?|? - help
");
        }

        static void Main(string[] args)
        {
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
