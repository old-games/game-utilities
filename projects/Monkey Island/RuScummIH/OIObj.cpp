// OIObj.cpp: implementation of the COIObj class.
//
//////////////////////////////////////////////////////////////////////

#include "stdafx.h"
#include "OIObj.h"
#include "ImageCodec.h"
#include "BMP.H"

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

COIObj::COIObj()
{
}

COIObj::~COIObj()
{
}

int COIObj::Decode()
{
	CChunk clut;		//Палитра
	CChunk obcd;
	CChunk rmhd;		//Заголовок комнаты
	int err;			//Индикатор ошибки
	//CChunk * obj;		//Вспомогательный объект
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
	/*--OUT*/printf("\r\n\tLoadFile: %s\\PA",m_parser->GetSrcPath());
	err= clut.Load(m_parser->GetSrcPath(), "PA");
	if(err)return(err);

	//Определяем номер объекта, его габариты, кол-во картинок и количество слоев на картинку
	number = m_chunk->GetID();
	
	//Грузим OC
	LPTSTR tmp = (LPTSTR)malloc(20);
	sprintf(tmp, "OC_%.4d", number);
	/*--OUT*/printf("\r\n\tLoadFile: %s\\%s",m_parser->GetSrcPath(),tmp);
	err= obcd.Load(m_parser->GetSrcPath(), tmp);
	free(tmp);
	if(err)return(err);

	w = obcd.GetWidth();
	h = obcd.GetHeight();
	codec.m_width = w;
	//cnt = obj->GetIMCnt();
	//cnt2= obj->GetZPCnt();


	//Определяем положение объекта из файла OBCD
	/*xPos = obcd.GetXPos();
	yPos = obcd.GetYPos();*/

	//...........................Начинаем декодирование.........................
	/*--OUT*/printf("\r\nDecode image");

	//construct offsets
	uint *offsets = new UINT [w/8];
	BYTE *src = m_chunk->m_header.body;
	int x;
	src+=2;
	for (x = 0; x < w/8; x++) {
		src+=4;
		WORD a= MAKEWORD(*(src+0),*(src+1));
		offsets[x]= a+2;
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

	LPTSTR dstfile = (LPTSTR)malloc(20);
	sprintf(dstfile, "OI_%.4d.bmp", number);
	/*--OUT*/printf("\r\n\tCreate file: %s\\%s", m_parser->GetDstPath(), dstfile);
	bmp->SaveBMP(m_parser->GetDstPath(), dstfile, dst);

	m_instructions.AddIMName(dstfile);

	free(dstfile);
	delete[]offsets;
	free(dst);
	delete bmp;

	///////////////////////////////

	//Перемещаемся на маску
	int32 unk;
	memcpy(&unk, src+2, 4);
	unk=unk+6;
	
	offsets = new UINT [w/8];
	src = m_chunk->m_header.body;
	for (int x = 0; x < w/8; x++) {
		WORD a= MAKEWORD(*(src+unk+0),*(src+unk+1));
		offsets[x]= unk+a-4;
		src+=2;
	}

	dst= (BYTE *)malloc(w * h);
	ZeroMemory(dst, w*h);
	src = m_chunk->m_header.body;
	for (int x = 0; x < w/8; x++) {
		if(offsets[x]+4-unk!=0)
		{
			codec.GetStripBW(dst + (8	* x), src+offsets[x], h);
		}
		else
			ZeroMemory(dst+(8*x), 8*h);

	}

	dstfile = (LPTSTR)malloc(strlen(m_parser->GetDstPath())+25);
	sprintf(dstfile, "OI_%.4d_ZP.bmp", number);
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

	////////////

	char ttmp[60]="";

	//create mask
	sprintf(&ttmp[0], "OI_%.4d.msk", number);
	/*--OUT*/printf("\r\n\tCreate mask: %s\\%s", m_parser->GetDstPath(), &ttmp[0]);
	m_chunk->Save(m_parser->GetDstPath(), &ttmp[0]);
	m_instructions.AddMaskName(&ttmp[0]);

	//create OC
	sprintf(&ttmp[0], "OC_%.4d.msk", number);
	/*--OUT*/printf("\r\n\tCreate file: %s\\%s", m_parser->GetDstPath(), &ttmp[0]);
	obcd.Save(m_parser->GetDstPath(), &ttmp[0]);
	m_instructions.AddMaskName(&ttmp[0]);
	
	m_instructions.SetType("OI");
	m_instructions.SetXPos(xPos);
	m_instructions.SetYPos(yPos);

	sprintf(&ttmp[0], "OI_%.4d.ins", number);
	m_instructions.Save(m_parser->GetDstPath(), &ttmp[0]);
	

	return(0);
}