using System.Windows.Forms;
using System.Xml;

namespace bassru
{
    public partial class MergeChanges : Form
    {
        public MergeChanges()
        {
            InitializeComponent();
        }

        public MergeChanges(XmlElement e, XmlElement e2):this()
        {
            textBox1.Text = e.OuterXml;
            textBox2.Text = e2.OuterXml;
        }
    }
}
