using System;

namespace br_not_parser
{
    class Program
    {
        static void usage()
        {
            Console.Write(@"
usage:
br_nb_parser union eng0.xml 60600 [eng2.xml 60601 [...[eng7.xml 60607]]]

br_nb_parser dump http://notabenoid.com/book/10919 [-o notabenoid.xml] [-u username [-p password]]

br_nb_parser parse eng.xml http://notabenoid.com/book/10919 [-o ru.xml] [-u username [-p password]] 

br_nb_parser parse eng.xml -f notabenoid.xml [-o ru.xml]
");
        }

        static void Main(string[] args)
        {
            if (args.Length < 1)
            {
                usage();
                return;
            }
            try
                {
                if (args[0] == "union")
                {
                    TextUniter uni = new TextUniter(args);
                    uni.run();
                }
                else if (args[0] == "parse")
                {
                    NBParser p = new NBParser(args,0);
                    System.Xml.XmlDocument inf=p.getInFile();
                    Translator t = new Translator(inf, p.run());
                    inf = t.run();
                    inf.Save(p.getOutName());
                }
                else if (args[0] == "dump")
                {
                    NBParser p = new NBParser(args,1);
                    p.dump();
                }
                else
                {
                    Console.WriteLine("unknown command " + args[0]);
                    usage();
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine("ERROR: "+ex.Message);
                //Console.ReadKey();
            }
        }
    }
}
