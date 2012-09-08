// IMv3Obj.cpp: implementation of the CIMv3Obj class.
//
//////////////////////////////////////////////////////////////////////

#include "stdafx.h"
#include "IMv3Obj.h"
#include "ImageCodec.h"
#include "bmp.h"

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

CIMv3Obj::CIMv3Obj()
{
}

CIMv3Obj::~CIMv3Obj()
{
}

int CIMv3Obj::Decode()
{
	typedef struct tagRGB { 
	BYTE r;
	BYTE g;
	BYTE b;
	} RGB;
	static RGB ega_pal[32] = {
	{0,0,0}, {0,0,42}, {0,42,0}, {0,42,42}, {42,0,0}, {42,0,42}, {42,21,0},
	{42,42,42}, {21,21,21}, {21,21,63}, {21,63,21}, {21,63,63}, {63,21,21},
	{63,21,63}, {63,63,21}, {63,63,63},

	{0,0,0}, {63,63,63}, {51,0,0}, {0,63,51}, {63,0,63}, {0,51,0}, {0,0,51},
	{63,63,0}, {63,34,0}, {34,17,0}, {63, 34, 34}, {17,17,17}, {34,34,34},
	{34,63,34}, {34,34,63}, {51,51,51}};	

	CChunk hd;
	CChunk msk;
	int err;			//Индикатор ошибки
	//CChunk * obj;		//Вспомогательный объект
	WORD w,h;			//Габариты
	CImageCodec codec;	//Кодек
	CBMP *bmp;			//Картинка BMP


    /*--OUT*/printf("\tfound object");

	//Грузим палитру
	/*--OUT*///printf("\r\n\tLoadFile: %s\\PA",m_parser->GetSrcPath());
	//err= clut.Load(m_parser->GetSrcPath(), "PA");
	//if(err)return(err);

	
	//Грузим HD
	/*--OUT*/printf("\r\n\tLoadFile: %s\\HDv3",m_parser->GetSrcPath());
	hd.m_has_valid_header = false;
	memcpy(hd.m_valid_chunk_type, "HDv3", 4);
	err= hd.Load(m_parser->GetSrcPath(), "HDv3");
	if(err)return(err);

	w = hd.GetWidth();
	h = hd.GetHeight();
	codec.m_width = w;


	//...........................Начинаем декодирование.........................
	/*--OUT*/printf("\r\nDecode image");

	//construct offsets
	uint *offsets = new UINT [w/8];
	BYTE *src = m_chunk->m_header.body;
	//offsets[0] = 124;
	int x;
	for (x = 0; x < w/8; x++) {
		//WORD a= MAKEWORD(*(src+0),*(src+1));
		//WORD b= MAKEWORD(*(src+2),*(src+3));
		//DWORD c = MAKEWPARAM(a,b);
		offsets[x]= MAKEWORD(*(src+0),*(src+1))-2;
		src+=2;
	}

	//prepare dst and src
	BYTE *dst = (BYTE *)malloc(w * h);
	src = m_chunk->m_header.body;
		
	//decode
	for (x = 0; x < w/8; x++) {
		codec.decodeStripEGA(dst + (8	* x), src + offsets[x], h);
	}

	//create bmp
	bmp = new CBMP(w, h);
	for(int i=0; i<32; i++)
		bmp->SetPalette(i, ega_pal[i].r*4, ega_pal[i].g*4, ega_pal[i].b*4);

	/*--OUT*/printf("\r\n\tCreate file: %s\\IMv3.bmp", m_parser->GetDstPath());
	bmp->SaveBMP(m_parser->GetDstPath(), "IMv3.bmp", dst);

	m_instructions.AddIMName("IMv3.bmp");


	delete[]offsets;
	free(dst);
	delete bmp;

	/*--OUT*/printf("\r\n\tLoad mask: %s\\MAv3", m_parser->GetSrcPath());
	msk.m_has_valid_header = false;
	memcpy(msk.m_valid_chunk_type,"MAv3",4);
	msk.Load(m_parser->GetSrcPath(), "MAv3");

	offsets = new UINT [w/8];
	src = msk.m_header.body;
	for (int x = 0; x < w/8; x++) {
		WORD a= MAKEWORD(*(src+0),*(src+1));
		offsets[x]= a;
		src+=2;
	}

	int ijk=0;
	dst= (BYTE *)malloc(w * h);
	ZeroMemory(dst, w*h);
	src = msk.m_header.body;
	for (int x = 0; x < w/8; x++) 
	{
		if(offsets[x]!=0)
		{
			codec.GetStripBW(dst + (8	* x), src+offsets[x], h);
		}
		else
			ZeroMemory(dst+(8*x), 8*h);
	}
		
		/*--OUT*/printf("\r\n\tCreate file: %s\\MAv3.bmp", m_parser->GetDstPath());
		bmp = new CBMP(w, h);
		bmp->SetPalette(0, 255,255,255);
		bmp->SetPalette(1, 0,0,0);
		bmp->SaveBMP(m_parser->GetDstPath(), "MAv3.bmp", dst);
		m_instructions.AddZPName("MAv3.bmp");

		//create mask 1
		/*--OUT*/printf("\r\n\tCreate file: %s\\HDv3.msk", m_parser->GetDstPath());
		hd.Save(m_parser->GetDstPath(), "HDv3.msk");

		m_instructions.AddMaskName("HDv3.msk");

		

			
		delete []offsets;
		free(dst);
		delete bmp;

	///////////////////////////////


	m_instructions.SetType("IMv3");
	m_instructions.Save(m_parser->GetDstPath(), "IMv3.ins");


	return(0);
}