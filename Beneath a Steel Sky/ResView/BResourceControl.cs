using System;
using System.Collections.Generic;
using System.Windows.Forms;

namespace bassru.ResView
{
    public partial class BResourceControl : UserControl
    {
        public BResourceControl()
        {
            InitializeComponent();
        }

        protected BResource resource = null;

        public virtual void setObject(BResource res)
        {
            resource = res;
        }

        protected Dictionary<string, string> makeConfig(string type,string comment)
        {
            Dictionary<string, string> res = new Dictionary<string, string>();
            res["type"] = type;
            res["comment"] = comment;
            return res;
        }

        public virtual void saveConfig(string comment)
        {
        }

        protected void setPaletteCombo(ComboBox box,string selected)
        {
            box.Items.Clear();
            foreach (String s in Config.get().paletteNames())
            {
                int idx=box.Items.Add(s);
                if (s == selected)
                    box.SelectedIndex = idx;
            }
            box.DropDownStyle = ComboBoxStyle.DropDownList;
        }

        protected BPalette getSelectedPalette(ComboBox box)
        {
            if (box.SelectedIndex < 0)
                return BPalette.GrayScalePalette();
            else
                return Config.get().findPalette(box.Text);
        }

        public bool exportResource()
        {
            SaveFileDialog sfd = new SaveFileDialog();
            sfd.Filter = resource.getFilter();
            sfd.FilterIndex = 0;
            sfd.AddExtension = true;
            if (sfd.ShowDialog() == DialogResult.OK)
            {
                return resource.export(sfd.FileName);
            }
            return true;
        }

        public bool importResource()
        {
            OpenFileDialog ofd = new OpenFileDialog();
            ofd.Filter = resource.getFilter();
            ofd.FilterIndex = 0;
            ofd.Multiselect = false;
            if (ofd.ShowDialog() == DialogResult.OK)
            {
                return resource.import(ofd.FileName);
            }
            return true;
        }

        public static int askForBadPal()
        {
            if (MessageBox.Show("Palettes not equal.\nDo you want to stop importing?",
                "Bad Palette", MessageBoxButtons.YesNoCancel) != DialogResult.No)
                throw new ApplicationException("Import stopped");
            return 1;
        }
    }
}
