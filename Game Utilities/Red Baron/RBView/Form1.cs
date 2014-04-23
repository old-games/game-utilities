//#define FORMS_DBG

using System;
using System.IO;
using System.Text;
using System.Windows.Forms;
using System.Collections.Generic;
using System.Collections;

namespace RBView
{
    public partial class Form1 : Form
    {
        const string ST_EXT = "external";
        string file = "";
        string path = "";
        string[] knownTypes = new string[] {"pal","bmp","scr","fnt"};
        public static Form1 me = null;
        LISorter ls;
        public Form1()
        {
            InitializeComponent();
            me = this;
            ls = new LISorter(listView1);
        }

        private void button1_Click(object sender, EventArgs e)
        {
            if (ofd.ShowDialog() == DialogResult.OK)
            {
                label1.Text = ofd.FileName;
                file = ofd.FileName;
                path = Path.GetDirectoryName(file);
                process();
            }
        }

        private void findExternal()
        {
            string[] exts = new string[] {".bmp",".fnt",".dat",".pal",".ttm",".prf",".clg",".tbl",".ovl",".scr" };
            DirectoryInfo di = new DirectoryInfo(path);
            foreach (FileInfo f in di.GetFiles())
            {
                if (Array.IndexOf(exts,f.Extension.ToLower())>-1)
                {
                    ListViewItem li= listView1.Items.Add(ST_EXT);
                    li.SubItems.Add("");
                    li.SubItems.Add("");
                    li.SubItems.Add("");
                    li.SubItems.Add(f.Name);
                    li.SubItems.Add("");
                    li.SubItems.Add(String.Format("0x{0:X8}",f.Length));
                    li.SubItems.Add(String.Format("0x{0:X8}", listView1.Items.Count));
                }
            }
        }

        private void tracePalettes()
        {
            foreach (ListViewItem li in listView1.Items)
            {
                string[] fname = li.SubItems[4].Text.Split('.');
                if (fname.Length > 1 && fname[1].ToLower() == "pal")
                {
                    Palettes.get().AddPalette(getFile(li), fname[0], true);
                }
            }
        }

        private void process()
        {
            listView1.ListViewItemSorter = null;
            ls.clear();
            listView1.Items.Clear();
            BinaryReader rd=new BinaryReader(new FileStream(file, FileMode.Open),Encoding.ASCII);
            byte[] unk = rd.ReadBytes(6);
            while (true)
            {
                String nm = new String(rd.ReadChars(12));
                nm=nm.Replace("\0","");
                byte e2 = rd.ReadByte();
                int files = rd.ReadInt16();
                if (files==0)
                    break;
                BinaryReader rd2 = new BinaryReader(new FileStream(path + "/" + nm, FileMode.Open), Encoding.ASCII);
                for (int i = 0; i < files; i++)
                {
                    uint hz = rd.ReadUInt16();
                    string type = new string(rd.ReadChars(2));
                    uint ofs = rd.ReadUInt32();
                    rd2.BaseStream.Position = ofs;
                    string fname = new String(rd2.ReadChars(12));
                    int idx = fname.IndexOf('\0');
                    if (idx > -1)
                        fname = fname.Substring(0, idx);
                    byte hz2 = rd2.ReadByte();
                    uint sz = rd2.ReadUInt32();
                    ListViewItem it = listView1.Items.Add(nm);
                    it.SubItems.Add(String.Format("0x{0:X4}",hz));
                    it.SubItems.Add(type);
                    it.SubItems.Add(String.Format("0x{0:X8}",ofs));
                    it.SubItems.Add(fname);
                    it.SubItems.Add(String.Format("0x{0:X1}", hz2));
                    it.SubItems.Add(String.Format("0x{0:X8}", sz));
                    it.SubItems.Add(String.Format("0x{0:X8}", listView1.Items.Count));
                    string[] tp = fname.Split('.');
                }
                rd2.Close();
            }
            rd.Close();
            findExternal();
            tracePalettes();
            listView1.AutoResizeColumns(ColumnHeaderAutoResizeStyle.ColumnContent);
            listView1.ListViewItemSorter = ls;
        }

        private void listView1_SelectedIndexChanged(object sender, EventArgs e)
        {
            button2.Enabled = listView1.SelectedItems.Count != 0;
            button4.Enabled = listView1.SelectedItems.Count == 1;
            button5.Enabled=false;
            if (button4.Enabled)
            {
                string[] fname = listView1.SelectedItems[0].SubItems[4].Text.Split('.');
                if (fname.Length > 1 && Array.IndexOf(knownTypes, fname[1].ToLower()) > -1)
                    button5.Enabled = true;
            }
        }

        private void button2_Click(object sender, EventArgs e)
        {
            foreach (ListViewItem l in listView1.SelectedItems)
                export(l);
        }

        private void export(ListViewItem l)
        {
            if (l.SubItems[0].Text == ST_EXT)
                return;
            string dir = l.SubItems[0].Text;
            string file = l.SubItems[4].Text;
            uint ofs = uint.Parse(l.SubItems[3].Text.Substring(2), System.Globalization.NumberStyles.AllowHexSpecifier);
            ofs += 17;
            uint sz = uint.Parse(l.SubItems[6].Text.Substring(2), System.Globalization.NumberStyles.AllowHexSpecifier);
            Directory.CreateDirectory(path + "/" + dir+"_");
            FileStream fs = new FileStream(path + "/" + dir, FileMode.Open);
            FileStream fd = new FileStream(path + "/" + dir + "_/" + file, FileMode.Create);
            fs.Position = ofs;
            byte[] data = new byte[sz];
            fs.Read(data, 0, (int)sz);
            fd.Write(data, 0, (int)sz);
            fd.Close();
            fs.Close();
        }

        private void button3_Click(object sender, EventArgs e)
        {
            foreach (ListViewItem l in listView1.Items)
                export(l);
        }

        private byte[] getFile(ListViewItem l)
        {
            FileStream fs = null;
            if (l.SubItems[0].Text == ST_EXT)
            {
                fs = new FileStream(path + "/" + l.SubItems[4].Text,FileMode.Open);
                byte[] res = new byte[(int)fs.Length];
                fs.Read(res, 0, res.Length);
                fs.Close();
                return res;
            }
            string dir = l.SubItems[0].Text;
            fs = new FileStream(path + "/" + dir, FileMode.Open);
            uint ofs = uint.Parse(l.SubItems[3].Text.Substring(2), System.Globalization.NumberStyles.AllowHexSpecifier);
            ofs += 17;
            uint sz = uint.Parse(l.SubItems[6].Text.Substring(2), System.Globalization.NumberStyles.AllowHexSpecifier);
            fs.Position = ofs;
            byte[] data = new byte[sz];
            fs.Read(data, 0, (int)sz);
            fs.Close();
            return data;
        }

        private void button4_Click(object sender, EventArgs e)
        {
            if (listView1.SelectedItems.Count != 1) return;
            new resView(
                getFile(listView1.SelectedItems[0]), 
                listView1.SelectedItems[0].SubItems[4].Text
                ).ShowDialog();
        }

        private void button5_Click(object sender, EventArgs e)
        {
            if (listView1.SelectedItems.Count != 1) return;
            ListViewItem lv=listView1.SelectedItems[0];
            string[] fname = lv.SubItems[4].Text.Split('.');
            if (fname.Length < 2) return;
#if !FORMS_DBG
            try
            {
#endif
                switch (fname[1].ToLower())
                {
                    case "pal":
                        new PalView(getFile(lv), fname[0]).ShowDialog();
                        break;
                    case "bmp":
                        new BmpView(getFile(lv), fname[0],false).ShowDialog();
                        break;
                    case "scr":
                        new BmpView(getFile(lv), fname[0],true).ShowDialog();
                        break;
                    case "fnt":
                        new FontView(getFile(lv), fname[0]).ShowDialog();
                        break;
                    default:
                        throw new Exception("Unknown type "+fname[1]);
                }
#if !FORMS_DBG
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
#endif
        }

        private void button6_Click(object sender, EventArgs e)
        {
            ls.initial(7);
            try
            {
                Directory.CreateDirectory(path + "/new");
                string prevvol = "";
                BinaryWriter wr = new BinaryWriter(new FileStream(path + "/new/volume.rmf", FileMode.Create), Encoding.ASCII);
                wr.Write((int)0x07050100);
                wr.Write((Int16)0x0008);
                BinaryWriter wr2 = null;
                Int16 fls=0;
                int flofs = 0;
                foreach (ListViewItem li in listView1.Items)
                {
                    string dir = li.SubItems[0].Text;
                    string fname = li.SubItems[4].Text;
                    char[] nm = new char[13];
                    if (dir != prevvol)
                    {
                        prevvol = dir;
                        nm[12] = '.';
                        if (dir == ST_EXT)
                        {
                            Array.Copy("VOLUME.008".ToCharArray(), nm, 10);
                            nm[10] = '\0';
                        }
                        else
                        {
                            Array.Copy(dir.ToCharArray(), nm, dir.Length);
                            nm[dir.Length] = '\0';
                        }
                        wr.Write(nm);
                        if (wr2 != null)
                        {
                            int opos = (int)wr.BaseStream.Position;
                            wr.BaseStream.Position = flofs;
                            wr.Write(fls);
                            wr.BaseStream.Position = opos;
                            wr2.Close();
                            wr2 = null;
                        }
                        flofs = (int)wr.BaseStream.Position;
                        fls = 0;
                        wr.Write(fls);
                        if (dir == ST_EXT) break;
                        wr2 = new BinaryWriter(new FileStream(path + "/new/" + dir, FileMode.Create), Encoding.ASCII);
                    }
                    fls++;
                    Int16 hz = Int16.Parse(li.SubItems[1].Text.Substring(2), System.Globalization.NumberStyles.AllowHexSpecifier);
                    string tp = li.SubItems[2].Text;
                    wr.Write(hz);
                    wr.Write(tp.ToCharArray());
                    int ofs = (int)wr2.BaseStream.Position;
                    wr.Write(ofs);
                    Array.Copy(fname.ToCharArray(),nm,fname.Length);
                    nm[fname.Length] = '\0';
                    wr2.Write(nm);
                    FileStream fs = new FileStream(path+"/"+dir+"_/"+fname, FileMode.Open);
                    int sz = (int)fs.Length;
                    byte[] data = new byte[sz];
                    fs.Read(data, 0, sz);
                    fs.Close();
                    wr2.Write(sz);
                    wr2.Write(data);
                }
                wr.Close();
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
        }

    }

    class LISorter : IComparer
    {
        int curcol = -1;
        SortOrder ord = SortOrder.None;
        ListView lv;
        bool ext = false;
        public LISorter(ListView lv)
        {
            this.lv = lv;
            lv.ColumnClick += new ColumnClickEventHandler(li_ColumnClick);
        }

        public void clear()
        {
            curcol = -1;
            ord = SortOrder.None;
            ext = false;
        }


        public void initial(int column)
        {
            curcol = column;
            ord = SortOrder.Ascending;
            lv.Sort();
        }

        public void li_ColumnClick(object sender, ColumnClickEventArgs e)
        {
            if (curcol == e.Column)
            {
                if (ord == SortOrder.Ascending)
                {
                    if (curcol == 4 && !ext)
                        ext = true;
                    else
                    {
                        ext = false;
                        ord = SortOrder.Descending;
                    }
                }
                else 
                if (ord == SortOrder.Descending)
                {
                    if (curcol==4 && !ext)
                    {
                        ext=true;
                    }else
                    {
                        ext=false;
                        initial(7);
                    }
                }
                    //ord = SortOrder.Ascending;
            }
            else
            {
                curcol = e.Column;
                ord = SortOrder.Ascending;
            }
            //lv.Sorting = ord;
            lv.Sort();
        }


        public int Compare(object x, object y)
        {
            if (curcol < 0) return 0;
            string li1 = (x as ListViewItem).SubItems[curcol].Text;
            string li2 = (y as ListViewItem).SubItems[curcol].Text;
            if (curcol == 3 || curcol == 6 || curcol==7)
            {
                if (li1 == "")
                    li1 = "0x0";
                if (li2 == "")
                    li2 = "0x0";
                int i1 = int.Parse(li1.Substring(2),System.Globalization.NumberStyles.HexNumber);
                int i2 = int.Parse(li2.Substring(2),System.Globalization.NumberStyles.HexNumber);
                int res = 0;
                if (i1 > i2) res = 1;
                if (i2 > i1) res = -1;
                return res * (ord == SortOrder.Descending ? -1 : 1);
            }
            else
            {
                if (curcol == 4 && ext)
                {
                    string[] se1 = li1.Split('.');
                    string[] se2 = li2.Split('.');
                    string e1 = se1.Length > 1 ? se1[1] : "";
                    string e2 = se1.Length > 1 ? se2[1] : "";
                    int res = string.Compare(e1, e2) * (ord == SortOrder.Descending ? -1 : 1);
                    if (res != 0)
                        return res;
                }
                return string.Compare(li1, li2) * (ord == SortOrder.Descending ? -1 : 1);
            }
        }
    }

}
