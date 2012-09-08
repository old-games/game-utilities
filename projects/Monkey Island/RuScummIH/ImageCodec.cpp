// ImageCodec.cpp: implementation of the CImageCodec class.
//
//////////////////////////////////////////////////////////////////////

#include "stdafx.h"
#include "ImageCodec.h"
#include <malloc.h>

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

CImageCodec::CImageCodec()
{

}

CImageCodec::~CImageCodec()
{

}


byte * CImageCodec::Encode(const byte *src, int type, int height, int colors)
{
 	switch(type){
		case LOOM_EGA_ENGINE:			return(encodeStripEGA(src, height));
		case INDY3_ENGINE:			return(unkCode11(src, height));
		case ATLANTIS_ENGINE:		return(unkCodeB(src, height));
		case ATLANTIS_ENGINE_MASK:	return(unkCodeBW_A(src, height));
		case ATLANTIS_ENGINE_COSTUME: return(unkCodeAtlantisCostume(src, m_width, height, colors));
		default:					return(unkCodeB(src, height));
	}
}


int CImageCodec::GetStrip(BYTE *dst, const BYTE *src, int numLinesToProcess)
{
	byte code = *src++;
	m_decomp_shr = (code % 10);
	m_decomp_mask = 0xFF >> (8 - m_decomp_shr);
				
	m_vertStripNextInc = numLinesToProcess * m_width - 1;
	
	switch (code) 
	{
		case 1:
			unkDecode7(dst, src, numLinesToProcess);
			break;
		
		case 2:
			unkDecode8(dst, src, numLinesToProcess);
			break;

		case 3:
			unkDecode9(dst, src, numLinesToProcess);
			break;
		
		case 4:
			unkDecode10(dst, src, numLinesToProcess);
			break;

		case 7:
			unkDecode11(dst, src, numLinesToProcess);
			break;

		case 10:
			decodeStripEGA(dst, src, numLinesToProcess);
			break;
		
		case 14:
		case 15:
		case 16:
		case 17:
		case 18:
		case 34:
		case 35:
		case 36:
		case 37:
		case 38:
			unkDecodeC(dst, src, numLinesToProcess);
			break;

		case 24:
		case 25:
		case 26:
		case 27:
		case 28:
		case 44:
		case 45:
		case 46:
		case 47:
		case 48:
			unkDecodeB(dst, src, numLinesToProcess);
			break;
		
		case 64:
		case 65:
		case 66:
		case 67:
		case 68:
		case 84:
		case 85:
		case 86:
		case 87:
		case 88:
		case 104:
		case 105:
		case 106:
		case 107:
		case 108:
		case 124:
		case 125:
		case 126:
		case 127:
		case 128:
			unkDecodeA(dst, src, numLinesToProcess);
			break;
		
		default:
	 		return(-1);
	}

	return(0);
}

int CImageCodec::GetStripBW(BYTE *dst, const BYTE *src, int numLinesToProcess)
{

	int z,m;
	unsigned char color,run,done;
	int y=0;
	done = 0;

		while(!done)
		{
			color=*src++;
			if(color<0x80)
			{
				run=color;
				if(run==0)
				{
					run=*src++;
				}
				for(z=0;z<run;z++)
				{
					color= *src++;
					for(m=0;m<8;m++)
					{        
						//lucas_pixel(b,x+m,y,((color>>(7-m))&1)<<n);
						*dst=(color>>(7-m))&1;
						dst++;
					}
					y++;
					if(y==numLinesToProcess)
					{
						done=1;
						break;
					}
					else
						dst+=(m_width-8);
				}
			}
			else
			{
				run=color&0x7f;
				if(run==0)
				{
					run= *src++;
				}
				color= *src++;
				for(z=0;z<run;z++)
				{
					for(m=0;m<8;m++)
					{
						//lucas_pixel(b,x+m,y,((color>>(7-m))&1)<<n);
						*dst=(color>>(7-m))&1;
						dst++;
					}
					y++;
					if(y==numLinesToProcess) 
					{
						done=1;
						break;
					}
					else
						dst+=(m_width-8);

				}
			}
		}
		y=0;

	return(0);
}


void CImageCodec::decodeStripEGA(byte *dst, const byte *src, int height) 
{
	byte color = 0;
	int run = 0, x = 0, y = 0, z;

	while (x < 8) {
		color = *src++;
		
		if (color & 0x80) {
			run = color & 0x3f;

			if (color & 0x40) {
				color = *src++;

				if (run == 0) {
					run = *src++;
				}
				for (z = 0; z < run; z++) {
					*(dst + y * m_width + x) = (z&1) ? color & 0xf : color >> 4;

					y++;
					if (y >= height) {
						y = 0;
						x++;
					}
				}
			} else {
				if (run == 0) {
					run = *src++;
				}

				for (z = 0; z < run; z++) {
					*(dst + y * m_width + x) = *(dst + y * m_width + x - 1);

					y++;
					if (y >= height) {
						y = 0;
						x++;
					}
				}
			}
		} else {
			run = color >> 4;
			if (run == 0) {
				run = *src++;
			}
			
			for (z = 0; z < run; z++) {
				*(dst + y * m_width + x) = color & 0xf;

				y++;
				if (y >= height) {
					y = 0;
					x++;
				}
			}
		}
	}
}

int CImageCodec::DecodeCostume(BYTE *dst, const BYTE *src, int colors, int h, int type)
{
	int xx= 0;
	int yy=0;

	switch(type){
		case ATLANTIS_ENGINE_COSTUME:
		{
			int x=0;
			const int bodge_buffer=0;//4096;
			int unpacked_size=m_width*h;
			BYTE *r=dst;

			int written=0;

			/*int xx=0;
			int yy=0;*/

			while(written<unpacked_size)
			{
				int color=*src/(colors==32?8:16);
				int run=*src%(colors==32?8:16);
				int longrun=run==0;

				src++;
				if (longrun) run=*src++;

				for(int j=0;j<run;j++)
					{
						*r=color;

			/*HDC hdc = GetDC(NULL);
			HBRUSH hobr, hbr= CreateSolidBrush(RGB(pal[*r].rgbRed, pal[*r].rgbGreen, pal[*r].rgbBlue));
			hobr = (HBRUSH)SelectObject(hdc, hbr);
			Rectangle(hdc, xx, yy, xx+8, yy+8);
			SelectObject(hdc, hobr);
			DeleteObject(hbr);
			ReleaseDC(NULL, hdc);
			yy+=8;*/


						x++;
						r+=m_width;
						if (x==h)
						{
							r-=m_width*h-1;
							x=0;
							
							/*yy=0;
							xx+=8;*/
						}
					}
				written+=run;
			}
		}
	}
	//Sleep(5000);
	return(0);
}

void CImageCodec::unkDecodeA(byte *dst, const byte *src, int height)
{
	byte color = *src++;
	uint bits = *src++;
	byte cl = 8;
	byte bit;
	byte incm, reps;

	do {
		int x = 8;
		do {
			FILL_BITS;
			*dst++ = color;

		againPos:
			if (!READ_BIT) {
			} else if (!READ_BIT) {
				FILL_BITS;
				color = bits & m_decomp_mask;
				bits >>= m_decomp_shr;
				cl -= m_decomp_shr;
			} else {
				incm = (bits & 7) - 4;
				cl -= 3;
				bits >>= 3;
				if (incm) {
					color = (byte)((color+incm)&0xFF);
				} else {
					FILL_BITS;
					reps = bits & 0xFF;
					do {
						if (!--x) {
							x = 8;
							dst += m_width - 8;
							if (!--height)
								return;
						}
						*dst++ = color;
					} while (--reps);
					bits >>= 8;
					bits |= (*src++) << (cl - 8);
					goto againPos;
				}
			}
		} while (--x);
		dst += m_width - 8;
	} while (--height);
}


void CImageCodec::unkDecodeC(byte *dst, const byte *src, int height)
{
	byte color = *src++;
	uint bits = *src++;
	byte cl = 8;
	byte bit;
	signed char inc = -1;

	int x = 8;
	do {
		int h = height;
		do {
  		    
			if (cl <= 8)
			{
				bits |= (*src++ << cl);
				cl += 8;
			}

			*dst = color;
			dst += m_width;

			if (!(cl--, bit = bits&1, bits>>=1,bit)) {
			} else if (!(cl--, bit = bits&1, bits>>=1,bit)) {
				if (cl <= 8)
				{
					bits |= (*src++ << cl);
					cl += 8;
				}
				color = bits & m_decomp_mask;
				bits >>= m_decomp_shr;
				cl -= m_decomp_shr;
				inc = -1;
			} else if (!(cl--, bit = bits&1, bits>>=1,bit)) {
				color += inc;
			} else {
				inc = -inc;
				color += inc;
			}
		} while (--h);
		dst -= m_vertStripNextInc;
	} while (--x);
}

void CImageCodec::unkDecode7(byte *dst, const byte *src, int height) 
{
	uint h = height;

	//if (_vm->_features & GF_OLD256) {
		int x = 8;
		for (;;) {
			*dst = *src++;
			NEXT_ROW;
		}
		return;
	//}

	do {
#if defined(SCUMM_NEED_ALIGNMENT)
		memcpy(dst, src, 8);
#else
		((uint32 *)dst)[0] = ((const uint32 *)src)[0];
		((uint32 *)dst)[1] = ((const uint32 *)src)[1];
#endif
		dst += m_width;
		src += 8;
	} while (--height);
}

void CImageCodec::unkDecode8(byte *dst, const byte *src, int height)
{
	uint h = height;

	int x = 8;
	for (;;) {
		uint run = (*src++) + 1;
		byte color = *src++;

		do {
			*dst = color;
			NEXT_ROW;
		} while (--run);
	}
}

void CImageCodec::unkDecode9(byte *dst, const byte *src, int height)
{
	unsigned char c, bits, color, run;
	int i, j;
	uint buffer = 0, mask = 128;
	int h = height;
	i = j = run = 0;

	int x = 8;
	for (;;) {
		c = 0;
		for (i = 0; i < 4; i++) {
			READ_256BIT;
			c += (bits << i);
		}

		switch (c >> 2) {
		case 0:
			color = 0;
			for (i = 0; i < 4; i++) {
				READ_256BIT;
				color += bits << i;
			}
			for (i = 0; i < ((c & 3) + 2); i++) {
				*dst = (run * 16 + color);
				NEXT_ROW;
			}
			break;

		case 1:
			for (i = 0; i < ((c & 3) + 1); i++) {
				color = 0;
				for (j = 0; j < 4; j++) {
					READ_256BIT;
					color += bits << j;
				}
				*dst = (run * 16 + color);
				NEXT_ROW;
			}
			break;

		case 2:
			run = 0;
			for (i = 0; i < 4; i++) {
				READ_256BIT;
				run += bits << i;
			}
			break;
		}
	}
}

void CImageCodec::unkDecode10(byte *dst, const byte *src, int height)
{
	int i;
	unsigned char local_palette[256], numcolors = *src++;
	uint h = height;

	for (i = 0; i < numcolors; i++)
		local_palette[i] = *src++;

	int x = 8;

	for (;;) {
		byte color = *src++;
		if (color < numcolors) {
			*dst = local_palette[color];
			NEXT_ROW;
		} else {
			uint run = color - numcolors + 1;
			color = *src++;
			do {
				*dst = color;
				NEXT_ROW;
			} while (--run);
		}
	}
}

void CImageCodec::unkDecode11(byte *dst, const byte *src, int height) 
{
	byte* begsrc = (byte*)src;

	int bits, i;
	uint buffer = 0, mask = 128;
	unsigned char inc = 1, color = *src++;
	int x = 8;
	do {
		int h = height;
		do {
			*dst = color;
			dst += m_width;
			for (i = 0; i < 3; i++) {
				READ_256BIT;
				if (!bits)
					break;
			}
			switch (i) {
			case 1:
				inc = -inc;
				color -= inc;
				break;

			case 2:
				color -= inc;
				break;

			case 3:
				color = 0;
				inc = 1;
				for (i = 0; i < 8; i++) {
					READ_256BIT;
					color += bits << i;
				}
				break;
			}
		} while (--h);
		dst -= m_vertStripNextInc;
	} while (--x);
}

void CImageCodec::unkDecodeB(byte *dst, const byte *src, int height)
{
	//Работаю с этим.
	byte color = *src++;
	uint bits = *src++;
	byte cl = 8;
	byte bit;
	int8 inc = -1;

	byte ddst[1600];

	int cnt =0;

	do {
		int x = 8;
		do {
			//FILLBITS
			if(cl <= 8)
			{
				bits |= (*src++ << cl);
				cl += 8;
			}	
			//========
			*dst++ = color;
			ddst[cnt]= *(dst-1);
			if(cnt==264)
				int ijk=0;
			if (!(cl--, bit = bits&1, bits>>=1,bit)) 
			{
				/*1*///Если бит 0
				int ihjk=0;
			} 
			else if (!(cl--, bit = bits&1, bits>>=1,bit)) 
			{
				/*2*///Если бит 0
				//FILLBITS
				if(cl <= 8)
				{
					bits |= (*src++ << cl);
					cl += 8;
				}	
				//========
				color = bits & m_decomp_mask;
				bits >>= m_decomp_shr;
				cl -= m_decomp_shr;
				inc = -1;
			} 
			else if (!(cl--, bit = bits&1, bits>>=1,bit)) 
			{
				/*3*///Если бит 0
				color += inc;
			} 
			else 
			{
				/*4*///Если бит 1
				inc = -inc;
				color += inc;
			}
			cnt++;
		} while (--x);
		

		dst += m_width-8;
	} while (--height);
	int ijk=0;
}

void CImageCodec::unkDecodeMask1(byte *dst, const byte *src, int height)
{
	int ijk = 0;
}

void CImageCodec::unkDecodeMask2(byte *dst, const byte *src, int height)
{
	int ijk = 1;
}

////////////////////
byte* CImageCodec::unkCodeB(const byte *src, int height)
{
	int x=1;
	int y=0;
	uint bits=0;
	int inc=-1;
	int cl=0;
	byte color = *src+0;

	byte * dst = (byte*)malloc(2);
	*(dst+0)=48;
	*(dst+1)=color;
	int pos=2;

	while(y<height){
		while(x<8){
			
			byte col = *(src+x+y*m_width);

			if(color==col)
			{
				if(cl>=16)
				{
					dst= (byte*)realloc(dst, pos+2);
					*(dst+pos++)=LOBYTE(bits);
					*(dst+pos++)=HIBYTE(bits);
					bits=0;
					cl=0;
				}
				if(cl<16)bits>>=1;
				cl++;
			}
			else if(color+inc==col)
			{
				if(cl>=16)
				{
					dst= (byte*)realloc(dst, pos+2);
					*(dst+pos++)=LOBYTE(bits);
					*(dst+pos++)=HIBYTE(bits);
					bits=0;
					cl=0;
				}
				if(cl<16)
				{
					bits>>=1;
					bits|=32768;
				}
				cl++;

				if(cl>=16)
				{
					dst= (byte*)realloc(dst, pos+2);
					*(dst+pos++)=LOBYTE(bits);
					*(dst+pos++)=HIBYTE(bits);
					bits=0;
					cl=0;
				}
				if(cl<16)
				{
					bits>>=1;
					bits|=32768;
				}
				cl++;
	
				if(cl>=16)
				{
					dst= (byte*)realloc(dst, pos+2);
					*(dst+pos++)=LOBYTE(bits);
					*(dst+pos++)=HIBYTE(bits);
					bits=0;
					cl=0;
				}
				if(cl<16)bits>>=1;
				cl++;

				color+=inc;
			}
			else if(color+inc==col)
			{
				for(int i=0; i<3; i++)
				{
					if(cl>=16)
					{
						dst= (byte*)realloc(dst, pos+2);
						*(dst+pos++)=LOBYTE(bits);
						*(dst+pos++)=HIBYTE(bits);
						bits=0;
						cl=0;
					}
					if(cl<16)
					{
						bits>>=1;
						bits|=32768;
					}
					cl++;
				}

				color+=inc;
				inc=-inc;
			}
			else
			{
				if(cl>=16)
				{
					dst= (byte*)realloc(dst, pos+2);
					*(dst+pos++)=LOBYTE(bits);
					*(dst+pos++)=HIBYTE(bits);
					bits=0;
					cl=0;
				}
				if(cl<16)
				{
					bits>>=1;
					bits|=32768;
				}
				cl++;

				if(cl>=16)
				{
					dst= (byte*)realloc(dst, pos+2);
					*(dst+pos++)=LOBYTE(bits);
					*(dst+pos++)=HIBYTE(bits);
					bits=0;
					cl=0;
				}
				if(cl<16)bits>>=1;
				cl++;

				for(int i=0; i<8; i++)
				{
					//-----------
					if(cl>=16)
					{
						dst= (byte*)realloc(dst, pos+2);
						*(dst+pos++)=LOBYTE(bits);
						*(dst+pos++)=HIBYTE(bits);
						bits=0;
						cl=0;
					}
					if(cl<16)
					{
						bits>>=1;
						byte d = col<<(7-i);
						d&=128;
						uint c = d<<8;
						bits|=c;
					}
					cl++;
				}
				color=col;
				//inc=-inc;

			}
			x++;
		}
		x=0;
		y++;
	}

	/*if(cl<8)
	{
		bits>>=cl;
		dst= (byte*)realloc(dst, pos+1);
		*(dst+pos++)=LOBYTE(bits);
	}
	else */
	{
		bits>>=16-cl;
		dst= (byte*)realloc(dst, pos+2);
		*(dst+pos++)=LOBYTE(bits);
		*(dst+pos++)=HIBYTE(bits);
	}

	/*bits>>=16-cl;
	dst= (byte*)realloc(dst, pos+2);
	*(dst+pos++)=LOBYTE(bits);
	*(dst+pos++)=HIBYTE(bits);*/
	
	byte ddst[1700];
	memcpy(&ddst[0],dst,_msize(dst));

	return(dst);
}

byte* CImageCodec::unkCode11(const byte *src, int height)
{
	byte *_dst= (byte*)malloc(2);

	*(_dst+0) = 7;				//value for decoder
	*(_dst+1) = *src++;
	
	byte code = 0;				//code;
	byte pos_in_code = 0;		//current pos of bit for fill in code
	byte color = *(_dst+1);		//current color;

	int inc=1;

	byte * end = (byte*)src+8*height-1;
	
	do{
		
		if(*src==color)
		{
			if(++pos_in_code>7)OVERFLOWBITS
		}
		else if(*src+inc==color)
		{//пишу 2 бита
			for(int i=0; i<2; i++)
			{
				if(pos_in_code>7)OVERFLOWBITS
				code+=1<<pos_in_code++;
			}
			pos_in_code++;
		}
		else if(*src-inc==color)
		{//пишу 1 бит
			if(pos_in_code>7)OVERFLOWBITS
			code+=1<<pos_in_code++;
			inc = -inc;
			pos_in_code++;
		}
		else
		{//пишу три бита
			for(int i=0; i<3; i++)
			{
				if(pos_in_code>7)OVERFLOWBITS
				code+=1<<pos_in_code++;
			}
			//пишу новый цвет
			int mask=1;
			for(int i=0; i<8; i++) 
			{
				if(pos_in_code>7)OVERFLOWBITS
				int bits= (*src&mask)!=0;
				code+=bits<<pos_in_code++;
				mask<<=1;
			}
			inc =1;
		}
		color = *src;
		src++;
	}while(src<end);
	
	if(pos_in_code!=0)
	{
		if(pos_in_code>7)OVERFLOWBITS;
		if(pos_in_code!=0)

		{
			int32 sz = _msize(_dst);
			_dst= (byte*)realloc(_dst, sz+1);
			*(_dst+sz)=code;
		}
	}
	return(_dst);
}

byte* CImageCodec::unkCodeBW_A(const byte *src, int height)
{
	byte *_dst= (byte*)malloc(1);

	int pos =0;
	
	for(int y=0; y<height; y++)
	{
		*(_dst+pos++) = 1;
		_dst = (byte*)realloc(_dst, pos+1);
		BYTE val =0;
		for(int x=0; x<8; x++)
		{
			BYTE col = *(src+x+y*m_width)&1;
			val<<=1;
			val|=col;
		}
		*(_dst+pos++) = val;
		_dst = (byte*)realloc(_dst, pos+1);
	}



	return(_dst);
}

byte *CImageCodec::unkCodeAtlantisCostume(const byte*src, int width, int height, int colors)
{
	//Работаем из расчета что у нас 16 цветов в картинке.
	const byte *s = src;

	byte *dst = (byte*)malloc(1);
	long cpos = 0;

	int color = *s;
	int run = 0;
	int ii=0;
	int x=0;

	while(ii<width*height)
	{
			if(*s== color)
			{
				run++;
				x++;
				s+=width;
				if (x==height)
				{
					s-=width*height-1;
					x=0;
				}
			}
			else
			{
				byte dat1 =0;
				byte dat2 =0;
				if(colors==16)
				{
					if((color<=15)&&(run<=15))
						dat1 = color*16+run;
					else if((color<=15)&&(run>=16))
					{
						dat1 = color*16;
						dat2 = run;
					}
				}
				else
				{
					if((color<=31)&&(run<=7))
						dat1 = color*8+run;
					else if((color<=31)&&(run>=8))
					{
						dat1 = color*8;
						dat2 = run;
					}
				}

				color = *s;
				x++;
				s+=width;
				if (x==height)
				{
					s-=width*height-1;
					x=0;
				}
				run=1;

				dst = (byte*)realloc(dst, cpos+1);
				*(dst+cpos)=dat1;
				cpos++;

				if(dat2)
				{
					dst = (byte*)realloc(dst, cpos+1);
					*(dst+cpos)=dat2;
					cpos++;
				}
			
			}
		ii++;
	}
	if(run)
	{
				byte dat1 =0;
				byte dat2 =0;
				if(colors==16)
				{
					if((color<=15)&&(run<=15))
						dat1 = color*16+run;
					else if((color<=15)&&(run>=16))
					{
						dat1 = color*16;
						dat2 = run;
					}
				}
				else
				{
					if((color<=31)&&(run<=7))
						dat1 = color*8+run;
					else if((color<=31)&&(run>=8))
					{
						dat1 = color*8;
						dat2 = run;
					}
				}

				dst = (byte*)realloc(dst, cpos+1);
				*(dst+cpos)=dat1;
				cpos++;

				if(dat2)
				{
					dst = (byte*)realloc(dst, cpos+1);
					*(dst+cpos)=dat2;
					cpos++;
				}
	}

	return(dst);
}

byte* CImageCodec::encodeStripEGA(const byte *src, int height) 
{
	byte *dst = (byte*)malloc(1);
	int pos=0;

//	byte * end = src+8*height-1;

	//берем цвет
	int x=0;
	int y=0;
	int k=0;
	do 
	{
		byte color = *(src+y*m_width+x);
		byte run = 1;
		//подсчитываем кол-во повторений
		bool breaked=false;
		for(run=0; run<=7; run++)
		{
			if(*(src+y*m_width+x) != color)
			{
				breaked = true;
				break;
			}

			y++;
			k++;
			if (y >= height) {
				y = 0;
				if(x<7)
					x++;
				else
				{
					break;
				}
			}
		}
		if(run>7)run=7;
		if(!breaked)
			if(y>0)
				y--;
			else
			{
				y=height;
				x--;
			}
		dst = (byte*)realloc(dst, pos+1);
		*(dst+pos) = run<<4;
		*(dst+pos) = *(dst+pos)|(color&0xf);
		pos++;
	}while(k<1152);
	
	int ijk=0;


/*	byte color = 0;
	int run = 0, x = 0, y = 0, z;

	while (x < 8) 
	{
		color = *src++;
		
		run = color >> 4;
		if (run == 0) 
		{
			run = *src++;
		}
			
		for (z = 0; z < run; z++) 
		{
			*(dst + y * m_width + x) = color & 0xf;

			y++;
			if (y >= height) 
			{
				y = 0;
				x++;
			}
		}
	}*/

	return(dst);
}
