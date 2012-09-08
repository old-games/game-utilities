// BMObj.cpp: implementation of the CBMObj class.
//
//////////////////////////////////////////////////////////////////////

#include "stdafx.h"
#include "BMObj.h"
#include "ImageCodec.h"
#include "bmp.h"

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

CBMObj::CBMObj()
{
}

CBMObj::~CBMObj()
{
}

int CBMObj::Decode()
{
	CChunk clut;		//Палитра
	CChunk hd;
	CChunk rmhd;		//Заголовок комнаты
	int err;			//Индикатор ошибки
	//CChunk * obj;		//Вспомогательный объект
	WORD w,h;			//Габариты
	CImageCodec codec;	//Кодек
	CBMP *bmp;			//Картинка BMP
	WORD xPos=0;
	WORD yPos=0;


    /*--OUT*/printf("\tfound object");

	//Грузим палитру
	/*--OUT*/printf("\r\n\tLoadFile: %s\\PA",m_parser->GetSrcPath());
	err= clut.Load(m_parser->GetSrcPath(), "PA");
	if(err)return(err);

	
	//Грузим HD
	/*--OUT*/printf("\r\n\tLoadFile: %s\\HD",m_parser->GetSrcPath());
	err= hd.Load(m_parser->GetSrcPath(), "HD");
	if(err)return(err);

	w = hd.GetWidth();
	h = hd.GetHeight();
	codec.m_width = w;


	//Определяем положение объекта из файла OBCD
	/*xPos = hd.GetXPos();
	yPos = hd.GetYPos();*/

	//...........................Начинаем декодирование.........................
	/*--OUT*/printf("\r\nDecode image");

	//construct offsets
	uint *offsets = new UINT [w/8];
	BYTE *src = m_chunk->m_header.body;
	int x;
	for (x = 0; x < w/8; x++) {
		src+=4;
		WORD a= MAKEWORD(*(src+0),*(src+1));
		WORD b= MAKEWORD(*(src+2),*(src+3));
		DWORD c = MAKEWPARAM(a,b);
		offsets[x]= c;
	}

	//prepare dst and src
	BYTE *dst = (BYTE *)malloc(w * h);
	src = m_chunk->m_header.body;
		
	//decode
	for (x = 0; x < w/8; x++) {
		codec.GetStrip(dst + (8	* x), src + offsets[x], h);
	}

	//create bmp
	bmp = new CBMP(w, h);
	for(int i=0; i<256; i++)
		bmp->SetPalette(i, clut.GetRVal(i), clut.GetGVal(i), clut.GetBVal(i));

	/*--OUT*/printf("\r\n\tCreate file: %s\\BM.bmp", m_parser->GetDstPath());
	bmp->SaveBMP(m_parser->GetDstPath(), "BM.bmp", dst);

	m_instructions.AddIMName("BM.bmp");

	delete[]offsets;
	free(dst);
	delete bmp;

	///////////////////////////////

	//Перемещаемся на маску
	DWORD unk = m_chunk->GetOffsetMask();
	unk=unk;
	if((m_chunk->m_header.size - unk)>=(DWORD)w/8*2)
	{
		offsets = new UINT [w/8];
		src = m_chunk->m_header.body+unk+4;
		for (int x = 0; x < w/8; x++) {
			WORD a= MAKEWORD(*(src+0),*(src+1));
			offsets[x]= a;
			src+=2;
		}

		dst= (BYTE *)malloc(w * h);
		ZeroMemory(dst, w*h);
		src = m_chunk->m_header.body;
		for (int x = 0; x < w/8; x++) {
			if(offsets[x]!=0)
			{
			codec.GetStripBW(dst + (8	* x), src+offsets[x]+unk, h);
			}
			else
				ZeroMemory(dst+(8*x), 8*h);
		}

		/*--OUT*/printf("\r\n\tCreate file: %s\\BM_ZP.bmp", m_parser->GetDstPath());
		bmp = new CBMP(w, h);
		bmp->SetPalette(0, 255,255,255);
		bmp->SetPalette(1, 0,0,0);
		bmp->SaveBMP(m_parser->GetDstPath(), "BM_ZP.bmp", dst);
		m_instructions.AddZPName("BM_ZP.dst");
			
		delete []offsets;
		free(dst);
		delete bmp;
	}
	////////////

	//create mask
	/*--OUT*/printf("\r\n\tCreate mask: %s\\BM.msk", m_parser->GetDstPath());
	m_chunk->Save(m_parser->GetDstPath(), "BM.msk");
	m_instructions.AddMaskName("BM.msk");

	//create OC
	/*--OUT*/printf("\r\n\tCreate file: %s\\HD.msk", m_parser->GetDstPath());
	hd.Save(m_parser->GetDstPath(), "HD.msk");
	m_instructions.AddMaskName("HD.msk");
	
	m_instructions.SetType("BM");
	m_instructions.SetXPos(xPos);
	m_instructions.SetYPos(yPos);

	m_instructions.Save(m_parser->GetDstPath(), "BM.ins");
	

	return(0);




//----------------------------
	/*CBMP * bmp;
	CChunk pa;
	CChunk hd;
	WORD w, h;
	CImageCodec codec;
	CChunk *obj;


	/*--OUT*printf("\tFound Background");

	/*--OUT*printf("\r\n\tLoad file: %s\\HD", m_parser->GetSrcPath());
	hd.Load(m_parser->GetSrcPath(), "HD");
	//Определяем габариты
	memcpy(&w, (hd.m_header.body), 2);
	memcpy(&h, (hd.m_header.body+2), 2);
	codec.m_width = w;
	//--codec.m_height = h;
	/*--OUT*printf("\r\n\twidth: %d\theight: %d", w, h);

	//Грузим палитру
	/*--OUT*printf("\r\n\tLoad file: %s\\PA", m_parser->GetSrcPath());
	pa.Load(m_parser->GetSrcPath(), "PA");

	/*--OUT*printf("\r\nDecode image");

	obj= m_chunk;
	if(!obj)return(ERR_NEEDED_BLOCK_NOT_FOUND);

	uint *offsets = new UINT [w/8];
	BYTE *src = obj->m_header.body;
	int x;
	for (x = 0; x < w/8; x++) {
		src+=4;
		WORD a= MAKEWORD(*(src+0),*(src+1));
		WORD b= MAKEWORD(*(src+2),*(src+3));
		DWORD c = MAKEWPARAM(a,b);
		offsets[x]= c;
	}

	BYTE *dst = (BYTE *)malloc(w * w);
	src = obj->m_header.body;
	
	for (x = 0; x < w/8; x++) {
		codec.GetStrip(dst + (8	* x), src + offsets[x], h);
	}

	//create bmp
	bmp = new CBMP(w, h);
	for(int i=0; i<256; i++)
	{
		bmp->SetPalette(i,
			*(pa.m_header.body+0+(i*3)+2),
			*(pa.m_header.body+1+(i*3)+2),
			*(pa.m_header.body+2+(i*3)+2));
	}
	/*--OUT*printf("\r\n\tCreate file: %s\\BM.bmp", m_parser->GetDstPath());
	bmp->SaveBMP(m_parser->GetDstPath(), "BM.bmp", dst);

	/*--OUT*printf("\r\n\tCreate file: %s\\BM.msk", m_parser->GetDstPath());

	LPTSTR dstfile = (LPTSTR)malloc(strlen(m_parser->GetDstPath())+15);
	sprintf(dstfile, "%s\\BM.msk", m_parser->GetDstPath());
	HANDLE hFile= CreateFile(dstfile, GENERIC_READ|GENERIC_WRITE, 0, NULL, CREATE_ALWAYS, 0, NULL);
	DWORD sz;
	DWORD size;
	int32 unk;
	memcpy(&unk, src, 4);
	size = _msize(src)-unk;
	WriteFile(hFile, src+unk, size, &sz, NULL);
	CloseHandle(hFile);
	
	free(dstfile);
	delete[]offsets;
	free(dst);
	delete bmp;*/


	return(0);
}