using System.Collections.Generic;
using Microsoft.DirectX.DirectSound;

namespace bassru.ResView
{
    public partial class SoundView : BResourceControl
    {
        public static Device dev = null;
        public static Device getDev()
        {
            if (dev == null)
            {
                dev = new Device();
                dev.SetCooperativeLevel(MainForm.me, CooperativeLevel.Priority);
            }
            return dev;
        }
        public static SoundView obj = null;
        public static SoundView get()
        {
            if (obj == null)
                obj = new SoundView();
            return obj;
        }
        public SoundView()
        {
            InitializeComponent();
        }

        BSound snd = null;
        BMusic mus = null;
        BSpeech spc = null;
        public override void setObject(BResource res)
        {
            base.setObject(res);
            snd = null;spc = null;mus = null;
            if (res.GetType().Name == "BSound")
            {
                snd = res as BSound;
                label1.Text = "PCM 11025 8bit mono : " + snd.getWave().length_s() + " sec";
            }
            if (res.GetType().Name == "BMusic")
                mus = res as BMusic;
            if (res.GetType().Name == "BSpeech")
            {
                spc = res as BSpeech;
                label1.Text = "PCM 11025 8bit mono : " + spc.getWave().length_s()+" sec";
            }
        }

        public override void saveConfig(string comment)
        {
            string tp="sound";
            if (spc!=null)
                tp="speech";
            if (mus!=null)
                tp="music";
            Dictionary<string,string> res=makeConfig(tp,comment);
            Config.get().updateConfig(resource.filenum, res);
        }

        private void button1_Click(object sender, System.EventArgs e)
        {
            if (spc != null || snd!=null)
            {
                Device dev = getDev();
                BufferDescription desc = new BufferDescription(WavFile.getFormat());
                desc.ControlVolume = true;
                desc.Flags = BufferDescriptionFlags.ControlVolume;
                byte[] raw = snd==null?spc.getWave().rawBytes():snd.getWave().rawBytes();
                desc.BufferBytes = raw.Length;
                SecondaryBuffer buf = new SecondaryBuffer(desc, dev);
                buf.Write(0, raw, LockFlag.EntireBuffer);
                buf.SetCurrentPosition(0);
                buf.Volume = 0;
                buf.Play(0, BufferPlayFlags.Default);
            }
        }


    }
}
