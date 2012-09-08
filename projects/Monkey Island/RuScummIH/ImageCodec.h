// ImageCodec.h: interface for the CImageCodec class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_ImageCodec_H__927EFA69_C57F_4FEF_8F59_0F4A432F1E49__INCLUDED_)
#define AFX_ImageCodec_H__927EFA69_C57F_4FEF_8F59_0F4A432F1E49__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include <windows.h>
#include "scummsys.h"


#define READ_BIT (cl--, bit = bits&1, bits>>=1,bit)
#define FILL_BITS do {												\
										if (cl <= 8) {						\
											bits |= (*src++ << cl);	\
											cl += 8;								\
										}													\
									} while (0)


#define READ_256BIT                        \
		do {                               \
			if ((mask <<= 1) == 256) {     \
				buffer = *src++;           \
				mask = 1;                  \
			}                              \
			bits = ((buffer & mask) != 0); \
		} while (0)

#define NEXT_ROW                           \
		do {                               \
			dst += m_width;      \
			if (--h == 0) {                \
				if (!--x)                  \
					return;                \
				dst -= m_vertStripNextInc;  \
				h = height;                \
			}                              \
		} while (0)

#define OVERFLOWBITS								\
			do{										\
				int32 sz = _msize(_dst);			\
				_dst= (byte*)realloc(_dst, sz+1);	\
				*(_dst+sz)=code;					\
				code=0;								\
				pos_in_code-=8;						\
			}while(pos_in_code>7);



class CImageCodec  
{
public:
	RGBQUAD pal[256];

	CImageCodec();
	virtual ~CImageCodec();

	void decodeStripEGA(BYTE *dst, const BYTE *src, int height);
	int GetStrip(BYTE *dst, const BYTE *src, int numLinesToProcess);
	int GetStripBW(BYTE *dst, const BYTE *src, int numLinesToProcess);
	int DecodeCostume(BYTE *dst, const BYTE *src, int colors, int height, int type);
	byte *Encode(const byte *src, int type, int height, int colors=16 /*Это только для костюмов*/);

	WORD m_width;
private:
	void unkDecodeA(BYTE *dst, const BYTE *src, int height);
	void unkDecodeB(BYTE *dst, const BYTE *src, int height);
	void unkDecodeC(BYTE *dst, const BYTE *src, int height);
	void unkDecode11(BYTE *dst, const BYTE *src, int height);
	void unkDecode10(BYTE *dst, const BYTE *src, int height);
	void unkDecode9(BYTE *dst, const BYTE *src, int height);
	void unkDecode8(BYTE *dst, const BYTE *src, int height);
	void unkDecode7(BYTE *dst, const BYTE *src, int height);

	void unkDecodeMask1(BYTE *dst, const BYTE *src, int height);
	void unkDecodeMask2(BYTE *dst, const BYTE *src, int height);

	byte* unkCode11(const byte *src, int height);
	byte* unkCodeB(const byte *src, int height);
	
	byte* encodeStripEGA(const byte *src, int height);
	byte* unkCodeBW_A(const byte *src, int height);
	byte *unkCodeAtlantisCostume(const byte* src, int width, int height, int colors);

	BYTE m_decomp_shr;
	BYTE m_decomp_mask;
	int m_vertStripNextInc;

};

#endif // !defined(AFX_ImageCodec_H__927EFA69_C57F_4FEF_8F59_0F4A432F1E49__INCLUDED_)
