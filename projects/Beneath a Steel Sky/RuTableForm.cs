using System;
using System.Data;
using System.Windows.Forms;

namespace bassru
{
    public partial class RuTableForm : Form
    {
        DataTable tb = new DataTable();
        public RuTableForm()
        {
            InitializeComponent();
            tb.Columns.Add("EN", typeof(string));
            tb.Columns.Add("RU", typeof(string));
            tb.Columns.Add("comment", typeof(string));
            dataGridView1.DataSource=tb;
            dataGridView1.Columns[0].ReadOnly = true;
            fillTable();
        }

        public void fillTable()
        {
            tb.Rows.Clear();
            int[,] huff=HuffText.getHuffText();
            for (int i = 0; i < huff.Length/3; i++)
                if (huff[i,0] == 0 && huff[i,1] == 0 && huff[i,2]!=0)
                {
                    string en=HuffText.replaceChar((char)huff[i,2]);
                    string comment="";
                    string ru=Config.get().getCharInfo(en,ref comment);
                    tb.Rows.Add(new object[]{en,ru,comment});
                }
        }

        private void button1_Click(object sender, EventArgs e)
        {
            foreach (DataRow rw in tb.Rows)
            {
                if (((rw.ItemArray[1] as string) != "") || ((rw.ItemArray[2] as string) != ""))
                {
                    string en = (rw.ItemArray[0] as string);
                    string ru = string.Empty;
                    if ((rw.ItemArray[1] as string) != null)
                    {
                        ru = (rw.ItemArray[1] as string);
                    }
                    string comment = (rw.ItemArray[2] as string);
                    Config.get().setCharInfo(en,ru,comment);
                }
            }
        }

    }
}
