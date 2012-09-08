// OIv3Obj.cpp: implementation of the COIv3Obj class.
//
//////////////////////////////////////////////////////////////////////

#include "stdafx.h"
#include "OIv3Obj.h"
#include "ImageCodec.h"
#include "BMP.H"

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

COIv3Obj::COIv3Obj()
{
}

COIv3Obj::~COIv3Obj()
{
}

int COIv3Obj::Decode()
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

	WORD w,h;			//Габариты
	CImageCodec codec;	//Кодек
	CBMP *bmp;			//Картинка BMP
	WORD cnt=0;			//Кол-во картинок в объекте.
	WORD cnt2=0;		//Кол-во картинок в маске.
	WORD xPos=0;
	WORD yPos=0;
	CChunk oc;
	oc.m_has_valid_header = false;
	memcpy(oc.m_valid_chunk_type, "OCv3", 4);


    /*--OUT*/printf("\tfound object");

	//Определяем номер объекта, его габариты, кол-во картинок и количество слоев на картинку
	LPTSTR temp_num = strdup(strstr(m_parser->GetCurrentFilename(), "OIv3"));
	if(temp_num)*(temp_num+1)='C';
	
	//Грузим OC
	/*--OUT*/printf("\r\n\tLoadFile: %s\\%s",m_parser->GetSrcPath(),temp_num);
	int err= oc.Load(m_parser->GetSrcPath(), temp_num);
	if(err)return(err);

	w = oc.GetWidth();
	h = oc.GetHeight();
	codec.m_width = w;


	//Определяем положение объекта из файла OBCD
	/*xPos = oc.GetXPos();
	yPos = oc.GetYPos();*/

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

	LPTSTR tmp = (LPTSTR)malloc(50);
	sprintf(tmp, "%s.bmp", temp_num);
	*(tmp+1)='I';
	/*--OUT*/printf("\r\n\tCreate file: %s\\%s", m_parser->GetDstPath(), tmp);
	bmp->SaveBMP(m_parser->GetDstPath(), tmp, dst);

	m_instructions.AddIMName(tmp);

	free(tmp);
	delete[]offsets;
	free(dst);
	delete bmp;

	///////////////////////////////

	/*//Перемещаемся на маску
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
	sprintf(dstfile, "OIv3_%.4d_ZP.bmp", number);
	/*--OUT/printf("\r\n\tCreate file: %s\\%s", m_parser->GetDstPath(), dstfile);
	bmp = new CBMP(w, h);
	bmp->SetPalette(0, 255,255,255);
	bmp->SetPalette(1, 0,0,0);
	bmp->SaveBMP(m_parser->GetDstPath(), dstfile, dst);
	m_instructions.AddZPName(dstfile);
		
	free(dstfile);
	delete []offsets;
	free(dst);
	delete bmp;

	////////////*/

	tmp = (LPTSTR)malloc(50);
	sprintf(tmp, "%s.msk", temp_num);
	*(tmp+1)='I';
	/*--OUT*/printf("\r\n\tCreate mask: %s\\%s", m_parser->GetDstPath(), tmp);
	m_chunk->Save(m_parser->GetDstPath(), tmp);
	m_instructions.AddMaskName(tmp);
	free(tmp);

	//create OC
	tmp = (LPTSTR)malloc(50);
	sprintf(tmp, "%s.msk", temp_num);
	/*--OUT*/printf("\r\n\tCreate file: %s\\%s", m_parser->GetDstPath(), tmp);
	oc.Save(m_parser->GetDstPath(), tmp);
	m_instructions.AddMaskName(tmp);
	free(tmp);
	
	m_instructions.SetType("OIv3");
	m_instructions.SetXPos(xPos);
	m_instructions.SetYPos(yPos);

	tmp = (LPTSTR)malloc(50);
	sprintf(tmp, "%s.ins", temp_num);
	*(tmp+1)='I';
	m_instructions.Save(m_parser->GetDstPath(), tmp);
	

	return(0);
}