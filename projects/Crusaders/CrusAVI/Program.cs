using System;
using System.IO;

namespace CrusAVI
{
    static class Program
    {

        static void usage()
        {
            Console.WriteLine(@"usage: 
CrusAVI.exe export infile.avi outfile.wav - export wave from avi
CrusAVI.exe import infile.avi infile.wav outfile.avi - import wave into avi");
        }

        /// <summary>
        /// Главная точка входа для приложения.
        /// </summary>
        [STAThread]
        static void Main(string[] args)
        {
            Console.WriteLine("CrusAVI v0.1");
            if (args.Length < 3 || (args[0] != "export" && args[0] != "import") || (args[0]=="import" && args.Length<4))
            {
                usage();
                return;
            }
            try
            {
                string inavi = args[1];
                string wav = args[2];
                AVIFile avi = new AVIFile(inavi);
                if (args[0] == "export")
                {
                    WavFile wave = avi.getWave();
                    FileStream fs = new FileStream(wav, FileMode.Create);
                    wave.saveToStream(fs);
                    fs.Close();
                }
                else
                {
                    string outavi = args[3];
                    FileStream fs=new FileStream(wav,FileMode.Open);
                    WavFile wave = new WavFile(fs);
                    fs.Close();
                    avi.setWave(wave);
                    avi.save(outavi);
                }
                avi.close();
            }
            catch (Exception ex)
            {
                Console.WriteLine("ERROR:"+ex.Message);
            }
        }
    }
}
