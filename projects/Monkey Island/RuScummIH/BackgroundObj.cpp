// BackgroundObj.cpp: implementation of the CBackgroundObj class.
//
//////////////////////////////////////////////////////////////////////

#include "stdafx.h"
#include "BackgroundObj.h"
#include "ImageCodec.h"
#include "BMP.h"

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

CBackgroundObj::CBackgroundObj()
{
}

CBackgroundObj::~CBackgroundObj()
{
}

int CBackgroundObj::Decode()
{
	CChunk clut;		//Палитра
	CChunk rmhd;		//Заголовок комнаты
	int err;			//Индикатор ошибки
	CChunk * obj;		//Вспомогательный объект
	WORD w,h;			//Габариты
	CImageCodec codec;	//Кодек
	CBMP *bmp;			//Картинка BMP
	LPTSTR tmp;
	WORD cnt;			//Кол-во Z буфферов


	/*--OUT*/printf("\tfound background");

	//Гркзим RMHD
	/*--OUT*/printf("\r\n\tLoadFile: %s\\RMHD",m_parser->GetSrcPath());
	err= rmhd.Load(m_parser->GetSrcPath(), "RMHD");
	if(err)return(err);

	//Определяем габариты
	w= rmhd.GetWidth();
	h= rmhd.GetHeight();
	codec.m_width = w;
	/*--OUT*/printf("\r\n\twidth: %d\theight: %d", w, h);

	//Грузим палитру
	/*--OUT*/printf("\r\n\tLoadFile: %s\\CLUT",m_parser->GetSrcPath());
	err= clut.Load(m_parser->GetSrcPath(), "CLUT");
	if(err)return(err);
	
	//...........................Начинаем декодирование.........................
	/*--OUT*/printf("\r\nDecode image");
	
	//search for SMAP object
	obj= m_chunk->Find("SMAP");
	if(!obj)return(ERR_NEEDED_BLOCK_NOT_FOUND);

	//construct offsets
	uint *offsets = new UINT [w/8];
	BYTE *src= obj->m_header.body;
	int x;
	for (x = 0; x < w/8; x++) {
		WORD a= MAKEWORD(*(src+0),*(src+1));
		WORD b= MAKEWORD(*(src+2),*(src+3));
		DWORD c = MAKEWPARAM(a,b);
		offsets[x]= c-8;
		src+=4;
	}

	//prepare dst and src
	BYTE *dst= (BYTE *)malloc(w * h);
	src= obj->m_header.body;
	
	//decode
	for (x = 0; x < w/8; x++) {
		codec.GetStrip(dst + (8	* x), src + offsets[x], h);
	}
	//..........................................................................

	//Создаем bmp
	bmp = new CBMP(w, h);
	//Формируем палитру
	for(int i=0; i<256; i++)
		bmp->SetPalette(i, clut.GetRVal(i), clut.GetGVal(i), clut.GetBVal(i));
	//Сохраняем файл
	/*--OUT*/printf("\r\n\tCreate file: %s\\RMIM.bmp", m_parser->GetDstPath());
	bmp->SaveBMP(m_parser->GetDstPath(), "RMIM.bmp", dst);
	
	delete []offsets;
	free(dst);
	delete bmp;

	//Начинаем работать чс масками
	
	//search for RMIH
	obj = m_chunk->Find("RMIH");
	if(!obj)return(ERR_NEEDED_BLOCK_NOT_FOUND);
	//Запоминаем количество Z buffer в cnt
	cnt = obj->GetZPCnt();

	tmp = (LPTSTR)malloc(5);
	for(int i=0; i< cnt; i++)
	{
		sprintf(tmp, "ZP%.2d", i+1);	

		obj = m_chunk->Find(tmp);
		if(!obj)return(ERR_NEEDED_BLOCK_NOT_FOUND);

		offsets = new UINT [w/8];
		src = obj->m_header.body;
		for (x = 0; x < w/8; x++) {
			WORD a= MAKEWORD(*(src+0),*(src+1));
			offsets[x]= a-8;
			src+=2;
		}

		dst= (BYTE *)malloc(w * h);
		ZeroMemory(dst, w*h);
		src = obj->m_header.body;
		for (x = 0; x < w/8; x++) {
			codec.GetStripBW(dst + (8	* x), src + offsets[x], h);
		}

		LPTSTR dstfile = (LPTSTR)malloc(15);
		sprintf(dstfile, "RMIM_%s.bmp", tmp);
		/*--OUT*/printf("\r\n\tCreate file: %s\\%s", m_parser->GetDstPath(), dstfile);
		bmp = new CBMP(w, h);
		bmp->SetPalette(0, 255,255,255);
		bmp->SetPalette(1, 0,0,0);
		bmp->SaveBMP(m_parser->GetDstPath(), dstfile, dst);

		//Сохраняем имя слоя
		m_instructions.AddZPName(dstfile);
		
		free(dstfile);
		delete []offsets;
		free(dst);
		delete bmp;
	}
	free(tmp);

	//create mask 0
	/*--OUT*/printf("\r\n\tCreate file: %s\\RMIM.msk", m_parser->GetDstPath());
	m_chunk->Save(m_parser->GetDstPath(), "RMIM.msk");

	//create mask 1
	/*--OUT*/printf("\r\n\tCreate file: %s\\RMHD.msk", m_parser->GetDstPath());
	rmhd.Save(m_parser->GetDstPath(), "RMHD.msk");

	m_instructions.AddIMName("RMIM.bmp");
	m_instructions.AddMaskName("RMIM.msk");
	m_instructions.AddMaskName("RMHD.msk");
	m_instructions.SetType("RMIM");
	m_instructions.Save(m_parser->GetDstPath(), "RMIM.ins");

	return(0);
}