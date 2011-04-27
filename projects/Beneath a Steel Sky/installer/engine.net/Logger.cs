using System;
using System.Collections.Generic;
using System.Text;
using System.Runtime.InteropServices;
using System.IO;
using System.Windows.Forms;

namespace engine.net
{
    class Logger
    {
        [DllImport("kernel32.dll")]
        public static extern Int32 AllocConsole();
        [DllImport("kernel32.dll")]
        public static extern Int32 FreeConsole();

        bool console=false;
        bool file=false;
        bool debug = false;
        TextWriter wr = null;
        public static Logger obj = null;
        public static Logger getLogger()
        {
            if (obj==null)
                obj=new Logger();
            return obj;
        }
        public Logger()
        {
        }
        public void free()
        {
            if (console)
                FreeConsole();
            if (file)
                wr.Close();
        }

        public void setOptions(bool file,bool console,bool debug)
        {
            this.console=console;
            this.file=file;
            this.debug = debug;
            if (console)
                if (AllocConsole() == 0)
                    this.console = false;
            if (file)
                wr=new StreamWriter(new FileStream(Path.Combine(Path.GetDirectoryName(Application.ExecutablePath),"install.log"),FileMode.Create),Encoding.ASCII);
        }

        public void dbg(string data)
        {
            if (!debug)
                return;
            lock (this)
            {
                if (console)
                    Console.WriteLine("LOG:" + data);
                if (file)
                    wr.WriteLine("LOG:" + data);
            }
        }

        public void print(string data)
        {
            lock (this)
            {
                if (console)
                    Console.WriteLine(data);
                if (file)
                    wr.WriteLine(data);
            }
        }
    }
}
