// CostumeObj.cpp: implementation of the CCostumeObj class.
//
//////////////////////////////////////////////////////////////////////

#include "stdafx.h"
#include "CostumeObj.h"
#include "ImageCodec.h"
#include "BMP.h"

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

CCostumeObj::CCostumeObj()
{
}

CCostumeObj::~CCostumeObj()
{
}

int CCostumeObj::Decode()
{
	CChunk clut;			//Палитра
	CChunk clut_for_save;	//Палитра для записи в BMP
	int err;			//Индикатор ошибки
//	WORD w,h;			//Габариты текущего кадра
	WORD number=0;		//Номер костюма
	CImageCodec codec;	//Кодек
	CBMP *bmp;			//Картинка BMP
	WORD cnt=0;			//Кол-во картинок в объекте.
	WORD colors=0;		//Кол-во цветов в костюме

    /*--OUT*/printf("\tfound costume");
	justCO=!strcmp(m_chunk->m_header.sign,"CO");
	//Грузим палитру
	if (justCO){
		/*--OUT*/printf("\r\n\tLoadFile: %s\\RO\\PA",m_parser->GetSrcPath());
		err= clut.Load(m_parser->GetSrcPath(), "RO\\PA");
		if (err){
			err= clut.Load(m_parser->GetSrcPath(), "PA");
			if(err)return(err);
			err= clut_for_save.Load(m_parser->GetSrcPath(), "PA");
			if(err)return(err);
		}else{
			err= clut_for_save.Load(m_parser->GetSrcPath(), "RO\\PA");
			if(err)return(err);
		}
	}else{
		/*--OUT*/printf("\r\n\tLoadFile: %s\\CLUT",m_parser->GetSrcPath());
		err= clut.Load(m_parser->GetSrcPath(), "CLUT");
		if(err)return(err);

		err= clut_for_save.Load(m_parser->GetSrcPath(), "CLUT");
		if(err)return(err);
	}
	//Определяем кол-во цветов
	colors = m_chunk->GetNumColors();

	//подсчитываем кол-во картинок
	cnt = m_chunk->GetIMCnt();

	struct image_header
	{
		short width,height; 
		short xo,yo; 
		char something[4];
	};
    image_header *hdr = new image_header[cnt];
	
	for(int i=0; i<cnt; i++)
	{
		int sz = sizeof(image_header);
		memcpy(&hdr[i], m_chunk->GetFrame(i)-12, 12);

		//prepare dst and src
		BYTE *dst= (BYTE *)malloc(hdr[i].width * hdr[i].height);
		BYTE *src= m_chunk->GetFrame(i);
		

		//Формируем палитру для BMP
		for(int iii=0; iii<=colors; iii++)
		{
			clut_for_save.SetRVal(iii, clut.GetRVal(m_chunk->GetPalIndex(iii)));
			clut_for_save.SetGVal(iii, clut.GetGVal(m_chunk->GetPalIndex(iii)));
			clut_for_save.SetBVal(iii, clut.GetBVal(m_chunk->GetPalIndex(iii)));

			codec.pal[iii].rgbRed = clut_for_save.GetRVal(iii);
			codec.pal[iii].rgbGreen = clut_for_save.GetGVal(iii);
			codec.pal[iii].rgbBlue = clut_for_save.GetBVal(iii);
		}


		codec.m_width = hdr[i].width;
		codec.DecodeCostume(dst, src, colors, hdr[i].height, ATLANTIS_ENGINE_COSTUME);

			/*BYTE *pRow = dst;
			HDC hdc = GetDC(NULL);
			Rectangle(hdc, 0,0, hdr[i].width*4+8, hdr[i].height*4+8);
			for(int y=4; y<hdr[i].height*4+4; y+=4)
			for(int x=4; x<hdr[i].width*4+4; x+=4)
			{	
				HBRUSH hobr, hbr= CreateSolidBrush(RGB(clut.GetRVal(*pRow), clut.GetGVal(*pRow), clut.GetBVal(*pRow)));
				hobr = (HBRUSH)SelectObject(hdc, hbr);
				Rectangle(hdc, x, y, x+4, y+4);
				SelectObject(hdc, hobr);
				DeleteObject(hbr);
				pRow++;
			}
			ReleaseDC(NULL, hdc);
			Sleep(5000);*/

		//Создаем bmp
		bmp = new CBMP(hdr[i].width, hdr[i].height);
		//Формируем палитру
		for(int j=0; j<256; j++)
			bmp->SetPalette(j, clut_for_save.GetRVal(j), clut_for_save.GetGVal(j), clut_for_save.GetBVal(j));
		//Сохраняем файл
		char buuf[50]="";
		sprintf(&buuf[0], "%s_IM%.3d.bmp", m_parser->GetCurrentFilename(), i);
		/*--OUT*/printf("\r\n\tCreate file: %s\\%s", m_parser->GetDstPath(), &buuf[0]);
		bmp->SaveBMP(m_parser->GetDstPath(), &buuf[0], dst);
		delete bmp;

		free(dst);
		m_instructions.AddIMName(&buuf[0]);
	}
	
	//create mask
	char ttmp[MAX_PATH]="";
	sprintf(&ttmp[0], "%s.msk", m_parser->GetCurrentFilename());
	/*--OUT*/printf("\r\n\tCreate mask: %s\\%s", m_parser->GetDstPath(), &ttmp[0]);
	m_chunk->Save(m_parser->GetDstPath(), &ttmp[0]);

	m_instructions.AddMaskName(&ttmp[0]);
	m_instructions.SetType(justCO?"CO":"COST");

	sprintf(&ttmp[0], "%s.ins", m_parser->GetCurrentFilename());
	m_instructions.Save(m_parser->GetDstPath(), &ttmp[0]);

	return(0);
}