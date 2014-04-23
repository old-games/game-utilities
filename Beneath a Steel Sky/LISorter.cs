using System;
using System.Windows.Forms;
using System.Collections;

namespace bassru
{
    class LISorter:IComparer
    {
        int curcol = -1;
        SortOrder ord = SortOrder.None;
        ListView lv;
        public LISorter(ListView lv)
        {
            this.lv = lv;
            lv.ColumnClick+=new ColumnClickEventHandler(li_ColumnClick);
        }

        public void clear()
        {
            curcol = -1;
            ord = SortOrder.None;
        }


        public void li_ColumnClick(object sender, ColumnClickEventArgs e)
        {
            if (curcol == e.Column)
            {
                if (ord == SortOrder.Ascending)
                    ord = SortOrder.Descending;
                else
                    ord = SortOrder.Ascending;
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
            if (curcol == 0 || curcol == 1 || curcol == 2)
            {
                int i1=int.Parse(li1,(curcol==0?System.Globalization.NumberStyles.Integer:System.Globalization.NumberStyles.HexNumber));
                int i2=int.Parse(li2,(curcol==0?System.Globalization.NumberStyles.Integer:System.Globalization.NumberStyles.HexNumber));
                int res = 0;
                if (i1 > i2) res = 1;
                if (i2 > i1) res = -1;
                return res * (ord == SortOrder.Descending ? -1 : 1);
            }
            else
            {
                return string.Compare(li1, li2)*(ord==SortOrder.Descending?-1:1);
            }
        }
    }
}
