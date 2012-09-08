// OIEnObj.cpp: implementation of the COIEnObj class.
//
//////////////////////////////////////////////////////////////////////

#include "stdafx.h"
#include "OIEnObj.h"
#include "ImageCodec.h"
#include "BMP.h"

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

COIEnObj::COIEnObj()
{

}

COIEnObj::~COIEnObj()
{

}

int COIEnObj::Encode()
{
//	LPTSTR tmp;
	int err;
	CChunk mask;
	CChunk OI;
	CChunk obcd;
//	CChunk * obj;
	WORD cnt=0;
	WORD cnt2=0;
	DWORD size = 0;
	WORD number=0;
	int w = 0;
	int h = 0;
	CImageCodec codec;
	CBMP bmp(0,0);
	WORD xPos=0;
	WORD yPos=0;

	//Грузим файл инструкций
	err = m_instructions.Load(m_parser->GetSrcPath(), m_parser->GetCurrentFilename());
	if(err)return(err);

	/*--OUT*/printf("\tfound OI");

	//Грузим созраненные в маске блоки
	if(!m_instructions.GetMaskName(0))return (ERR_INS_FILE_CORRUPT);
	/*--OUT*/printf("\r\n\tLoadFile: %s\\%s",m_parser->GetSrcPath(), m_instructions.GetMaskName(0));
	err= mask.Load(m_parser->GetSrcPath(), m_instructions.GetMaskName(0));
	if(err)return(err);
	err= OI.Load(m_parser->GetSrcPath(), m_instructions.GetMaskName(0));
	if(err)return(err);
	if(!m_instructions.GetMaskName(1))return (ERR_INS_FILE_CORRUPT);
	/*--OUT*/printf("\r\n\tLoadFile: %s\\%s",m_parser->GetSrcPath(), m_instructions.GetMaskName(1));
	err= obcd.Load(m_parser->GetSrcPath(), m_instructions.GetMaskName(1));
	if(err)return(err);

	//Определяем кол-во картинок
	//cnt= obcd.GetIMCnt();
	//Запоминаем кол-во слоев в сnt2
	//cnt2= obj->GetZPCnt();
	//Определяем номер объекта
	number= mask.GetID();

	//Грузим картинку
	/*--OUT*/printf("\r\n\tLoad BMP: %s\\%s",m_parser->GetSrcPath(), m_instructions.GetIMName(0));
	err = bmp.LoadBMP(m_parser->GetSrcPath(), m_instructions.GetIMName(0), INDY3_ENGINE);
	if(err)return(err);
	w =  bmp.GetWidth();
	h =  bmp.GetHeight();
	codec.m_width = w;
	/*--OUT*/printf("\r\n\twidth: %d\theight: %d", w, h);

	//Проверяем габариты на кратность 8
	if((fmod((float)w,8)!=0)||(fmod((float)h,8)!=0))return(ERR_BAD_WIDTH_OR_HEIGHT);


	/*--OUT*/printf("\r\nEncode image");

	//начинаем кодирование
	int32 *offsets_pic = new int32[w/8];
	byte* body_pic = (byte*)malloc(1);
	offsets_pic[0]= 6+2+4+4*(w/8)-8;

	for(int x=0; x<w/8; x++)
	{
		byte* dst = codec.Encode(bmp.GetSrc()+8*h*x,INDY3_ENGINE, h);
		
		body_pic = (byte*)realloc(body_pic, offsets_pic[x]-offsets_pic[0] + _msize(dst));
		memcpy(body_pic+offsets_pic[x]-offsets_pic[0], dst, _msize(dst));
		
		if(x<w/8-1)
			offsets_pic[x+1]= offsets_pic[x]+_msize(dst);//-6;

		free(dst);
	}

	//Начинаем кодировать маску
	WORD *offsets_mask;
	byte* body_mask;

	if(m_parser->IsEncodeMask())
	{
		//Грузим BMP
		/*--OUT*/printf("\r\n\tLoad BMP: %s\\%s", m_parser->GetSrcPath(), m_instructions.GetZPName(0));
		err = bmp.LoadBMP(m_parser->GetSrcPath(), m_instructions.GetZPName(0), ATLANTIS_ENGINE);
		if(err)return(err);
		if((w!=bmp.GetWidth())||(h!=bmp.GetHeight()))return(ERR_BAD_WIDTH_OR_HEIGHT);
		/*--OUT*/printf("\r\n\tEncode image");
				

		offsets_mask = new WORD[w/8];
		body_mask = (byte*)malloc(1);
		offsets_mask[0]= 2*(w/8)+4;

		for(int x=0; x<w/8; x++)
		{
			byte* dst = codec.Encode(bmp.GetSrc()+8*x,ATLANTIS_ENGINE_MASK, h);
					
			body_mask = (byte*)realloc(body_mask, offsets_mask[x]-offsets_mask[0] + _msize(dst));
			memcpy(body_mask+offsets_mask[x]-offsets_mask[0], dst, _msize(dst));
					
			if(x<w/8-1)
				offsets_mask[x+1]= offsets_mask[x]+_msize(dst);
			free(dst);
		}

		//Теперь собственно пытаемся сконструировать валидный OI OBJECT;
		free(OI.m_header.body);

		//Выделяем необходимую память
		OI.m_header.body = (BYTE*)malloc(2+4+w/8*4+_msize(body_pic)
			+w/8*2+_msize(body_mask));
		//Устанавливаем размер
		OI.m_header.size= 6+2+4+w/8*4+_msize(body_pic)+w/8*2+_msize(body_mask);

		//Устанавливаем номер объекта
		OI.SetID(number);
		//Копируем смещения на картинку картинки
		memcpy(OI.m_header.body+6, offsets_pic, w/8*4);
		//Копируем саму картинку
		memcpy(OI.m_header.body+6+w/8*4, body_pic, _msize(body_pic));
		
		//Копируем смещения на картинку маски
		memcpy(OI.m_header.body+6+w/8*4+_msize(body_pic), offsets_mask, w/8*2);
		//Копируем саму картинку маски
		memcpy(OI.m_header.body+6+w/8*4+_msize(body_pic)+w/8*2, body_mask, _msize(body_mask));

		//Устанавливаем смещение на маску
		OI.SetOffsetMask(w/8*4+_msize(body_pic));

	}
	else
	{
		DWORD unk = mask.GetOffsetMask();

		DWORD size;
		size = _msize(mask.m_header.body)-unk-2;
		
		
		// Если ключ -m не указан.
		if((w!=obcd.GetWidth())||(h!=obcd.GetHeight()))return(ERR_BAD_WIDTH_NOT_M_PRESENT);

		//Теперь собственно пытаемся сконструировать валидный OI OBJECT;
		free(OI.m_header.body);

		//Выделяем необходимую память
		OI.m_header.body = (BYTE*)malloc(2+4+w/8*4+_msize(body_pic)+size);
		//Устанавливаем размер
		OI.m_header.size= 6+2+4+w/8*4+_msize(body_pic)+size;

		//Устанавливаем номер объекта
		OI.SetID(number);
		//Копируем смещения на картинку картинки
		memcpy(OI.m_header.body+6, offsets_pic, w/8*4);
		//Копируем саму картинку
		memcpy(OI.m_header.body+6+w/8*4, body_pic, _msize(body_pic));
		
		//Устанавливаем смещение на маску
		OI.SetOffsetMask(w/8*4+_msize(body_pic));

		//Вычисляем разницу между новой и старой маской
		LONG new_unk = OI.GetOffsetMask()- unk;

		//Обновляем значения старой маски
		for(int ii=0; ii<w/8; ii++)
		{
			LONG dw = 0;
			memcpy(&dw, mask.m_header.body+mask.GetOffsetMask()+6+ii*2, 2);
			dw+= new_unk;
			//memcpy(mask.m_header.body+mask.GetOffsetMask()+6+ii*2, &dw, 2);
		}

		//Копируем старую маску
		memcpy(OI.m_header.body+6+w/8*4+_msize(body_pic), 
			mask.m_header.body+mask.GetOffsetMask()+6,
			size);

	}
	//////////////////////////////////////////////////////////////////////

	//Сохраняем объект OI
	char ttmp[50]="";
	sprintf(&ttmp[0],"OI_%.4d",number);
	/*--OUT*/printf("\r\n\tSave OI: %s\\OI_%.4d", m_parser->GetDstPath(), number);
	OI.Save(m_parser->GetDstPath(), &ttmp[0]);

	//Пишем габариты!
	obcd.SetWidth(w);
	obcd.SetHeight(h);
	sprintf(&ttmp[0],"OC_%.4d",number);
	/*--OUT*/printf("\r\n\tSave OC: %s\\OC_%.4d", m_parser->GetDstPath(), number);
	obcd.Save(m_parser->GetDstPath(), &ttmp[0]);

	return(0);
}