using System;
using System.Collections.Generic;

namespace bassru.ResView
{
    public partial class ScriptView : BResourceControl
    {
        public static ScriptView obj = null;
        public static ScriptView get()
        {
            if (obj == null)
                obj = new ScriptView();
            return obj;
        }
        public ScriptView()
        {
            InitializeComponent();
        }

        BScripts scr { get { return resource as BScripts; } }
        public override void setObject(BResource res)
        {
            base.setObject(res);
            comboBox1.SelectedIndex = -1;
            comboBox1.Items.Clear();
            for (int i = 0; i < scr.scriptCount; i++)
                comboBox1.Items.Add(i.ToString());
        }

        public override void saveConfig(string comment)
        {
            Dictionary<string,string> res=makeConfig("script",comment);
            Config.get().updateConfig(scr.filenum,res);
        }

        private void comboBox1_SelectedIndexChanged(object sender, System.EventArgs e)
        {
            textBox1.Text = "";
            if (comboBox1.SelectedIndex < 0) return;
            try
            {
                textBox1.Text = scr.getScript(comboBox1.SelectedIndex);
            }
            catch (Exception ex)
            {
                MainForm.clearResource(ex);
            }
        }
    }
}
