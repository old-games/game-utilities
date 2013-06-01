using System;
using System.Collections.Generic;
using System.Text;
using System.Drawing;
using System.Drawing.Imaging;

namespace Vlure
{
	class LureAnim
	{
		byte[] xdata = null;
		byte[] cdata=null;
		public int resnum = -1;
		string palette = "";
		public int unused = 0;

		private const int xlen=320*200;
		public LureAnim(int resnum,string pal)
		{
			this.resnum = resnum;
			palette = pal;
			xdata = Decompressor.decompress(LureDisks.getResource(resnum));
			cdata=LureDisks.getResource(resnum+1);
		}
		
		public Bitmap export()
		{
			return export(palette);
		}

		public Bitmap export(string pal)
		{
			byte[] tdata = new byte[xlen];
			int iOfs=xlen;
			Array.Copy(xdata, 0, tdata, 0, xlen);
			List<byte[]> imgs=new List<byte[]>();
			imgs.Add((byte[])tdata.Clone());
			int cOfs=0;
			while(cOfs<cdata.Length && iOfs<xdata.Length){
				int sOfs=0;
				while(sOfs<xlen){
					UInt16 len=cdata[cOfs++];
					if (len==0){
						len=BinaryHelper.readU16_LE(cdata,cOfs);
						cOfs+=2;
					}
					if (len>0){
						Array.Copy(xdata, iOfs, tdata, sOfs, len);
						iOfs+=len;
						sOfs+=len;
					}
					len=cdata[cOfs++];
					if (len==0){
						len=BinaryHelper.readU16_LE(cdata,cOfs);
						cOfs+=2;
					}
					sOfs+=len;
				}
				//next screen
				imgs.Add((byte[])tdata.Clone());
			}
			Bitmap bmp = new Bitmap(320, 200*imgs.Count, System.Drawing.Imaging.PixelFormat.Format8bppIndexed);
			ColorPalette tmppal = bmp.Palette;
			LureConfig.LurePalette p=LureConfig.get().getPalette(pal);
			for (int i = 0; i < 256; i++)
				tmppal.Entries[i] = p.cols[i];
			bmp.Palette = tmppal;
			BitmapData bd = bmp.LockBits(new Rectangle(0, 0, 320, 200*imgs.Count),
			                             ImageLockMode.WriteOnly, bmp.PixelFormat);
			for (int i = 0; i < bd.Height; i++){
				System.Runtime.InteropServices.Marshal.Copy(imgs[i/200], (i%200) * bd.Width, new IntPtr(bd.Scan0.ToInt64() + i * bd.Stride), bd.Width);
			}
			bmp.UnlockBits(bd);
			return bmp;
		}


		private void getLens(byte[] data,int ofs,int eofs,ref int df,out int eq){
			int xdf=df;
			int xeq=0;
			int df2=0;
			while(ofs<eofs){
				xeq=df2=0;
				while(ofs<eofs && data[ofs]!=data[ofs-xlen]){
					xdf++;
					ofs++;
				}
				while(ofs<eofs && data[ofs]==data[ofs-xlen]){
					xeq++;
					ofs++;
				}
				while(ofs<eofs && data[ofs]!=data[ofs-xlen]){
					df2++;
					ofs++;
				}
				int l1=(xdf>255?3:1)+xdf +(xeq>255?3:1)+ (df2>255?3:1)+df2;
				int l2=(((xdf+xeq+df2)>255)?3:1)+xdf+xeq+df2;
				if (l2>l1){
					break;
				}
				xdf+=xeq+df2;
			}
			df=xdf;
			eq=xeq;
		}

		private void compressScreen(byte[] data,int screen,out byte[] pix,out byte[] code){
			int dOfs=screen*xlen;
			int eOfs=dOfs+xlen;
			int[] lens=new int[2];
			lens[0]=1;
			code=new byte[0];
			pix=new byte[0];
			while(dOfs<eOfs){
				getLens(data,dOfs+lens[0],eOfs,ref lens[0],out lens[1]);
				int cps=code.Length;
				Array.Resize<byte>(ref code, code.Length+(lens[0]>255?3:1)+(lens[1]>255?3:1));
				for (int i=0;i<2;i++){
					if (lens[i]>255 || lens[i]==0){
						code[cps++]=0;
						UInt16 sz=(UInt16)lens[i];
						BinaryHelper.write_LE(code,cps,sz);
						cps += 2;
					}else{
						code[cps++]=(byte)(lens[i]&0xFF);
					}
				}
				int pps=pix.Length;
				Array.Resize<byte>(ref pix,pix.Length+lens[0]);
				Array.Copy(data,dOfs,pix,pps,lens[0]);
				dOfs += lens [0] + lens [1];
				lens[0]=0;
			}
		}

		public void import(Bitmap bmp)
		{
			if (bmp.Width != 320 || bmp.Height%200!=0)
				throw new Exception(String.Format("Wrong bmp size {0}x{1} (need 320x200n)",bmp.Width,bmp.Height));
			ColorPalette pal = bmp.Palette;
			LureConfig.LurePalette xpal = LureConfig.get().getPalette(palette);
			for (int i = 0; i < 256; i++)
				if (pal.Entries[i].ToArgb() != xpal.cols[i].ToArgb())
					throw new Exception("Palette differs");
			byte[] data = new byte[320 * bmp.Height];

			BitmapData bd = bmp.LockBits(new Rectangle(0, 0, 320, bmp.Height),
			                             ImageLockMode.ReadWrite, bmp.PixelFormat);
			for (int i = 0; i < bmp.Height; i++)
				System.Runtime.InteropServices.Marshal.Copy(new IntPtr(bd.Scan0.ToInt64() + i * bd.Stride), data, i * bd.Width, bd.Width);
			bmp.UnlockBits(bd);

			int screens=bmp.Height/200;

			byte[] dt2=new byte[xlen];
			byte[] cmd=new byte[0];
			int rOfs=xlen;
			int cOfs=0;
			Array.Copy(data,dt2,xlen);

			for (int i=1;i<screens;i++){
				byte[] pix;
				byte[] code;
				compressScreen(data,i,out pix,out code);
				Array.Resize<byte>(ref dt2,dt2.Length+pix.Length);
				Array.Copy(pix,0,dt2,rOfs,pix.Length);
				rOfs+=pix.Length;
				Array.Resize<byte>(ref cmd,cmd.Length+code.Length);
				Array.Copy(code,0,cmd,cOfs,code.Length);
				cOfs+=code.Length;
			}
			data=null;

			byte[] nr = Compressor.compress(dt2);

			LureDisks.setResource(resnum, nr);
			LureDisks.setResource(resnum+1, cmd);
		}
	}
}

