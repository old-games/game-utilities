// IMv3EnObj.cpp: implementation of the CIMv3EnObj class.
//
//////////////////////////////////////////////////////////////////////

#include "stdafx.h"
#include "IMv3EnObj.h"
#include "ImageCodec.h"
#include "BMP.h"
//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

CIMv3EnObj::CIMv3EnObj()
{

}

CIMv3EnObj::~CIMv3EnObj()
{

}

int CIMv3EnObj::Encode()
{
	CChunk mask;		//Маска
	CChunk hd;			//Прочая инфа о комнате
	CChunk obj;			//Вспомогательный объект
	//LPTSTR tmp;			//Временная переменная
	DWORD size = 0;		
	CImageCodec codec;	//Кодек
	int w =0;
	int h =0;			//Габариты
	int err;			//Индикатор ошибки
	CBMP bmp(0,0);		//Картинка

	//Выводим сообщение о типе объекта
	/*--OUT*/printf("\tfound background (IMv3)");

	//Грузим файл инструкций
	err = m_instructions.Load(m_parser->GetSrcPath(), m_parser->GetCurrentFilename());
	if(err)return(err);

	/*--OUT*/printf("\r\n\tLoadFile: %s\\%s",m_parser->GetSrcPath(), m_instructions.GetMaskName(0));
	hd.m_has_valid_header = false;
	memcpy(hd.m_valid_chunk_type, "HDv3", 4);
	err= hd.Load(m_parser->GetSrcPath(), m_instructions.GetMaskName(0));
	if(err)return(err);


	//Грузим BMP
	/*--OUT*/printf("\r\n\tLoad BMP: %s\\%s", m_parser->GetSrcPath(), m_instructions.GetIMName(0));
	err = bmp.LoadBMP(m_parser->GetSrcPath(), m_instructions.GetIMName(0), ATLANTIS_ENGINE);
	if(err)return(err);

	//Запоминаем размер bmp в локальных переменных и в кодеке
	w =  bmp.GetWidth();
	h =  bmp.GetHeight();
	codec.m_width =w;

	//Выводим размер на экран
	/*--OUT*/printf("\r\n\twidth: %d\theight: %d", w, h);

	//Проверяем на кратность 8
	if(fmod((float)w,8)!=0)return(ERR_BAD_WIDTH_OR_HEIGHT);

	
	//Выводим сообщение о начале кодирования
	/*--OUT*/printf("\r\nEncode image");

	free(obj.m_header.body);
	obj.m_header.size = 0;
	obj.m_header.type=LOOM_EGA_ENGINE;

	//.........................Кодируем картинку..............................
	WORD *offsets = new WORD[w/8];
	byte* body = (byte*)malloc(1);
	offsets[0]= 2*(w/8)+2;

	int k=0;
	for(int y=0; y<h; y++)
	for(int x=0; x<w; x++)
		{

			BYTE idx = *(bmp.GetSrc()+k);

			RGBQUAD c=*(bmp.GetPalette()+idx);

			HDC hdc = GetDC(HWND_DESKTOP);
			SetPixel(hdc, x, y, RGB(c.rgbRed, c.rgbGreen, c.rgbBlue));
			ReleaseDC(HWND_DESKTOP, hdc);
			k++;
		}

	for(int x=0; x<w/8; x++)
	{
		byte* dst = codec.Encode(bmp.GetSrc()+8*x,LOOM_EGA_ENGINE, h);
		
		body = (byte*)realloc(body, offsets[x]-offsets[0] + _msize(dst));
		memcpy(body+offsets[x]-offsets[0], dst, _msize(dst));
		
		if(x<w/8-1)
			offsets[x+1]= offsets[x]+_msize(dst);
		free(dst);
	}
	obj.m_header.size= (w/8*2)+_msize(body)+2;
	obj.m_header.body = (BYTE*)malloc(obj.m_header.size-2);
	memcpy(obj.m_header.body, offsets, w/8*2);
	memcpy(obj.m_header.body+ w/8*2, body, _msize(body));

	/*--OUT*/printf("\r\n\tSaveFile: %s\\IMv3",m_parser->GetDstPath());
	obj.Save(m_parser->GetDstPath(), "IMv3");


	delete[]offsets;
	free(body);

	//.........................Кодируем маску..............................
	if(m_parser->IsEncodeMask())
	{
		mask.m_has_valid_header = false;
		memcpy(mask.m_valid_chunk_type, "MAv3",4);
		mask.m_header.type = LOOM_EGA_ENGINE;

		/*--OUT*/printf("\r\n\tLoad BMP: %s\\%s", m_parser->GetSrcPath(), m_instructions.GetMaskName(0));
		err = bmp.LoadBMP(m_parser->GetSrcPath(), m_instructions.GetZPName(0), ATLANTIS_ENGINE);
		if(err)return(err);
		if((w!=bmp.GetWidth())||(h!=bmp.GetHeight()))return(ERR_BAD_WIDTH_OR_HEIGHT);
		/*--OUT*/printf("\r\n\tEncode image");
			

		//Формируем тело и размер блока ZP - собственно и есть кодирование
		//Очищаем оригинальную картинку
		free(mask.m_header.body);
		mask.m_header.size = 0;

		WORD *offsets = new WORD[w/8];
		byte* body = (byte*)malloc(1);
		offsets[0]= 2*(w/8);

		for(int x=0; x<w/8; x++)
		{
			byte* dst = codec.Encode(bmp.GetSrc()+8*x,ATLANTIS_ENGINE_MASK, h);
				
			body = (byte*)realloc(body, offsets[x]-offsets[0] + _msize(dst));
			memcpy(body+offsets[x]-offsets[0], dst, _msize(dst));
				
			if(x<w/8-1)
				offsets[x+1]= offsets[x]+_msize(dst);
			free(dst);
		}
		mask.m_header.size= (w/8*2)+_msize(body)+8;
		mask.m_header.body = (BYTE*)malloc(mask.m_header.size-8);
		memcpy(mask.m_header.body, offsets, w/8*2);
		memcpy(mask.m_header.body+ w/8*2, body, _msize(body));

		delete[]offsets;
		free(body);
	}
	else
	{
		// Если ключ -m не указан.
		if((w!=hd.GetWidth())||(h!=hd.GetHeight()))return(ERR_BAD_WIDTH_NOT_M_PRESENT);
	}
	//////////////////////////////////////////////////////////////////////

	if(m_parser->IsEncodeMask())
	{
		/*--OUT*/printf("\r\n\tSaveFile: %s\\MAv3",m_parser->GetDstPath());
		mask.Save(m_parser->GetDstPath(), "MAv3");
	}

	//Запоминаем габариты
	hd.SetWidth(w);
	hd.SetHeight(h);

	/*--OUT*/printf("\r\n\tSaveFile: %s\\HDv3",m_parser->GetDstPath());
	hd.Save(m_parser->GetDstPath(), "HDv3");

	return(0);
}