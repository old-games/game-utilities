// ObjectObj.cpp: implementation of the CObjectObj class.
//
//////////////////////////////////////////////////////////////////////

#include "stdafx.h"
#include "ObjectObj.h"
#include "ImageCodec.h"
#include "BMP.h"

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

CObjectObj::CObjectObj()
{
}

CObjectObj::~CObjectObj()
{
}

int CObjectObj::Decode()
{
	CChunk clut;		//Палитра
	CChunk obcd;
	CChunk rmhd;		//Заголовок комнаты
	int err;			//Индикатор ошибки
	CChunk * obj;		//Вспомогательный объект
	WORD w,h;			//Габариты
	WORD number=0;		//Номер объекта
	CImageCodec codec;	//Кодек
	CBMP *bmp;			//Картинка BMP
	WORD cnt=0;			//Кол-во картинок в объекте.
	WORD cnt2=0;		//Кол-во картинок в маске.
	WORD xPos=0;
	WORD yPos=0;


    /*--OUT*/printf("\tfound object");

	//Грузим палитру
	/*--OUT*/printf("\r\n\tLoadFile: %s\\CLUT",m_parser->GetSrcPath());
	err= clut.Load(m_parser->GetSrcPath(), "CLUT");
	if(err)return(err);

	//Ищем IMHD
	obj = m_chunk->Find("IMHD");
	if(!obj)return(ERR_NEEDED_BLOCK_NOT_FOUND);
	
	//Определяем номер объекта, его габариты, кол-во картинок и количество слоев на картинку
	number = obj->GetID();
	w = obj->GetWidth();
	h = obj->GetHeight();
	codec.m_width = w;
	cnt = obj->GetIMCnt();
	cnt2= obj->GetZPCnt();

	//Грузим OBCD
	LPTSTR tmp = (LPTSTR)malloc(20);
	sprintf(tmp, "OBCD_%.4d", number);
	/*--OUT*/printf("\r\n\tLoadFile: %s\\%s",m_parser->GetSrcPath(),tmp);
	err= obcd.Load(m_parser->GetSrcPath(), tmp);
	free(tmp);
	if(err)return(err);

	//Определяем положение объекта из файла OBCD
	obj= obcd.Find("CDHD");
	if(!obj)return(ERR_NEEDED_BLOCK_NOT_FOUND);
	xPos = obj->GetXPos();
	yPos = obj->GetYPos();

	//По количеству картинок
	for(int ijk=1; ijk<=cnt; ijk++)
	{
		//...........................Начинаем декодирование.........................
		/*--OUT*/printf("\r\nDecode image");

		char ttmp[10]="";
		sprintf(&ttmp[0], "IM%.2d", ijk);
		obj= m_chunk->Find(&ttmp[0]);
		if(!obj)return(ERR_NEEDED_BLOCK_NOT_FOUND);
		//search for SMAP object
		obj= obj->Find("SMAP");
		if(!obj)return(ERR_NEEDED_BLOCK_NOT_FOUND);

		//construct offsets
		uint *offsets = new UINT [w/8];
		BYTE *src = obj->m_header.body;
		int x;
		for (x = 0; x < w/8; x++) {
			WORD a= MAKEWORD(*(src+0),*(src+1));
			WORD b= MAKEWORD(*(src+2),*(src+3));
			DWORD c = MAKEWPARAM(a,b);
			offsets[x]= c-8;
			src+=4;
		}

		//prepare dst and src
		BYTE *dst = (BYTE *)malloc(w * h);
		src = obj->m_header.body;
		
		//decode
		for (x = 0; x < w/8; x++) {
			codec.GetStrip(dst + (8	* x), src + offsets[x], h);
		}

		//create bmp
		bmp = new CBMP(w, h);
		for(int i=0; i<256; i++)
			bmp->SetPalette(i, clut.GetRVal(i), clut.GetGVal(i), clut.GetBVal(i));

		LPTSTR dstfile = (LPTSTR)malloc(20);
		sprintf(dstfile, "OBIM_%.4d_IM%.2d.bmp", number,ijk);
		/*--OUT*/printf("\r\n\tCreate file: %s\\%s", m_parser->GetDstPath(), dstfile);
		bmp->SaveBMP(m_parser->GetDstPath(), dstfile, dst);

		m_instructions.AddIMName(dstfile);

		free(dstfile);
		delete[]offsets;
		free(dst);
		delete bmp;

		///////////////////////////////
		LPTSTR tmp = (LPTSTR)malloc(5);
		
		//По кол-ву слоев
		for(int i=0; i< cnt2; i++)
		{
			sprintf(tmp, "ZP%.2d", i+1);	

			obj= m_chunk->Find(&ttmp[0]);
			if(!obj)return(ERR_NEEDED_BLOCK_NOT_FOUND);
			obj = obj->Find(tmp);
			if(!obj)return(ERR_NEEDED_BLOCK_NOT_FOUND);

			uint *offsets = new UINT [w/8];
			BYTE *src = obj->m_header.body;
			for (int x = 0; x < w/8; x++) {
				WORD a= MAKEWORD(*(src+0),*(src+1));
				offsets[x]= a-8;
				src+=2;
			}

			BYTE *dst= (BYTE *)malloc(w * h);
			ZeroMemory(dst, w*h);
			src = obj->m_header.body;
			for (int x = 0; x < w/8; x++) {
				codec.GetStripBW(dst + (8	* x), src + offsets[x], h);
			}

			LPTSTR dstfile = (LPTSTR)malloc(strlen(m_parser->GetDstPath())+25);
			sprintf(dstfile, "OBIM_%.4d_IM%.2d_%s.bmp", number, ijk, tmp);
			/*--OUT*/printf("\r\n\tCreate file: %s\\%s", m_parser->GetDstPath(), dstfile);
			bmp = new CBMP(w, h);
			bmp->SetPalette(0, 255,255,255);
			bmp->SetPalette(1, 0,0,0);
			bmp->SaveBMP(m_parser->GetDstPath(), dstfile, dst);
			m_instructions.AddZPName(dstfile);
		
			free(dstfile);
			delete []offsets;
			free(dst);
			delete bmp;
		}
		free(tmp);

	}

	char ttmp[60]="";

	//create mask
	sprintf(&ttmp[0], "OBIM_%.4d.msk", number);
	/*--OUT*/printf("\r\n\tCreate mask: %s\\%s", m_parser->GetDstPath(), &ttmp[0]);
	m_chunk->Save(m_parser->GetDstPath(), &ttmp[0]);
	m_instructions.AddMaskName(&ttmp[0]);

	//create OBCD
	sprintf(&ttmp[0], "OBCD_%.4d.msk", number);
	/*--OUT*/printf("\r\n\tCreate file: %s\\%s", m_parser->GetDstPath(), &ttmp[0]);
	obcd.Save(m_parser->GetDstPath(), &ttmp[0]);
	m_instructions.AddMaskName(&ttmp[0]);
	
	m_instructions.SetType("OBIM");
	m_instructions.SetXPos(xPos);
	m_instructions.SetYPos(yPos);


	sprintf(&ttmp[0], "OBIM_%.4d.ins", number);
	m_instructions.Save(m_parser->GetDstPath(), &ttmp[0]);


	return(0);
}