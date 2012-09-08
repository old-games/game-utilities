// ObjectEnObj.cpp: implementation of the CObjectEnObj class.
//
//////////////////////////////////////////////////////////////////////

#include "stdafx.h"
#include "ObjectEnObj.h"
#include "ImageCodec.h"
#include "BMP.h"

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

CObjectEnObj::CObjectEnObj()
{

}

CObjectEnObj::~CObjectEnObj()
{

}

int CObjectEnObj::Encode()
{
	LPTSTR tmp;
	int err;
	CChunk mask;
	CChunk obcd;
	CChunk * obj;
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

	/*--OUT*/printf("\tfound object");

	//Грузим созраненные в маске блоки
	if(!m_instructions.GetMaskName(0))return (ERR_INS_FILE_CORRUPT);
	/*--OUT*/printf("\r\n\tLoadFile: %s\\%s",m_parser->GetSrcPath(), m_instructions.GetMaskName(0));
	err= mask.Load(m_parser->GetSrcPath(), m_instructions.GetMaskName(0));
	if(err)return(err);
	if(!m_instructions.GetMaskName(1))return (ERR_INS_FILE_CORRUPT);
	/*--OUT*/printf("\r\n\tLoadFile: %s\\%s",m_parser->GetSrcPath(), m_instructions.GetMaskName(1));
	err= obcd.Load(m_parser->GetSrcPath(), m_instructions.GetMaskName(1));
	if(err)return(err);

	//Определяем кол-во картинок
	obj= mask.Find("IMHD");
	if(!obj)return(ERR_NEEDED_BLOCK_NOT_FOUND);
	cnt= obj->GetIMCnt();
	//Запоминаем кол-во слоев в сnt2
	cnt2= obj->GetZPCnt();
	//Определяем номер объекта
	number= obj->GetID();

	for(int ijk=0; ijk<cnt; ijk++)
	{

		//Грузим картинку
		/*--OUT*/printf("\r\n\tLoad BMP: %s\\%s",m_parser->GetSrcPath(), m_instructions.GetIMName(ijk));
		err = bmp.LoadBMP(m_parser->GetSrcPath(), m_instructions.GetIMName(ijk), ATLANTIS_ENGINE);
		if(err)return(err);
		w =  bmp.GetWidth();
		h =  bmp.GetHeight();
		codec.m_width = w;
		//---codec.m_height = h;
		/*--OUT*/printf("\r\n\twidth: %d\theight: %d", w, h);

		//Проверяем габариты на кратность 8
		if((fmod((float)w,8)!=0)||(fmod((float)h,8)!=0))return(ERR_BAD_WIDTH_OR_HEIGHT);


		/*--OUT*/printf("\r\nEncode image");

		//Формируем блок OBIM, для этого берем за основу блок сохраненный в mask
		//Формируем тело и размер блока SMAP - собственно и есть кодирование
		char ttmp[10]="";
		sprintf(&ttmp[0], "IM%.2d", ijk+1);
		obj = mask.Find(&ttmp[0]);
		if(!obj)return(ERR_NEEDED_BLOCK_NOT_FOUND);
		obj = obj->Find("SMAP");
		if(!obj)return(ERR_NEEDED_BLOCK_NOT_FOUND);

		//Очищаем старую картинку в маске
		free(obj->m_header.body);

		int32 *offsets = new int32[w/8];
		byte* body = (byte*)malloc(1);
		offsets[0]= 4*(w/8)+8;

		for(int x=0; x<w/8; x++)
		{
			byte* dst = codec.Encode(bmp.GetSrc()+8*x, ATLANTIS_ENGINE, h);
			
			body = (byte*)realloc(body, offsets[x]-offsets[0] + _msize(dst));
			memcpy(body+offsets[x]-offsets[0], dst, _msize(dst));
			
			if(x<w/8-1)
				offsets[x+1]= offsets[x]+_msize(dst);
			obj->m_header.size+= _msize(dst);
			free(dst);
		}
		obj->m_header.size= (w/8*4)+_msize(body)+8;
		obj->m_header.body = (BYTE*)malloc(obj->m_header.size-8);
		memcpy(obj->m_header.body, offsets, w/8*4);
		memcpy(obj->m_header.body+ w/8*4, body, _msize(body));

		delete []offsets;
		free(body);

		//.........................Кодируем слои..............................
		if(m_parser->IsEncodeMask())
		{
			for(int i=0; i<cnt2; i++)
			{
				//Грузим BMP
				/*--OUT*/printf("\r\n\tLoad BMP: %s\\%s", m_parser->GetSrcPath(), m_instructions.GetZPName(i));
				err = bmp.LoadBMP(m_parser->GetSrcPath(), m_instructions.GetZPName(i), ATLANTIS_ENGINE);
				if(err)return(err);
				if((w!=bmp.GetWidth())||(h!=bmp.GetHeight()))return(ERR_BAD_WIDTH_OR_HEIGHT);
				/*--OUT*/printf("\r\n\tEncode image");
				

				//Формируем тело и размер блока ZP - собственно и есть кодирование
				tmp = (LPTSTR)malloc(15);
				sprintf(tmp, "ZP%.2d", i+1);
				obj =obj->Find(tmp);
				free(tmp);
				if(!obj)return(ERR_NEEDED_BLOCK_NOT_FOUND);

				//Очищаем оригинальную картинку
				free(obj->m_header.body);
				obj->m_header.size = 0;

				WORD *offsets = new WORD[w/8];
				byte* body = (byte*)malloc(1);
				offsets[0]= 2*(w/8)+8;

				for(int x=0; x<w/8; x++)
				{
					byte* dst = codec.Encode(bmp.GetSrc()+8*x,ATLANTIS_ENGINE_MASK, h);
					
					body = (byte*)realloc(body, offsets[x]-offsets[0] + _msize(dst));
					memcpy(body+offsets[x]-offsets[0], dst, _msize(dst));
					
					if(x<w/8-1)
						offsets[x+1]= offsets[x]+_msize(dst);
					free(dst);
				}
				obj->m_header.size= (w/8*2)+_msize(body)+8;
				obj->m_header.body = (BYTE*)malloc(obj->m_header.size-8);
				memcpy(obj->m_header.body, offsets, w/8*2);
				memcpy(obj->m_header.body+ w/8*2, body, _msize(body));

				delete[]offsets;
				free(body);
			}
		}
		else
		{
			// Если ключ -m не указан.
			obj = obcd.Find("CDHD");
			if(!obj)return(ERR_NEEDED_BLOCK_NOT_FOUND);
			if((w!=obj->GetWidth())||(h!=obj->GetHeight()))return(ERR_BAD_WIDTH_NOT_M_PRESENT);
		}
		//////////////////////////////////////////////////////////////////////
	}

	size=0;
	//Подсчитываем размер блока IMxx = сумме размеров ZP + размер SMAP + 8 байт
	for(int i=0; i<cnt; i++)
	{
		char _tmp[5]="";
		sprintf(&_tmp[0], "IM%.2d", i+1);
		obj = mask.Find(&_tmp[0]);
		if(!obj)return(ERR_NEEDED_BLOCK_NOT_FOUND);
		obj = obj->Find("SMAP");
		if(!obj)return(ERR_NEEDED_BLOCK_NOT_FOUND);
		size+= obj->m_header.size+8;

		for(int k=1;k<=cnt2;k++)
		{
			int iii = k;
			char _tmp[5]="";
			sprintf(&_tmp[0], "ZP%.2d", iii);
			obj = obj->Find(&_tmp[0], TRUE);
			if(!obj)return(ERR_NEEDED_BLOCK_NOT_FOUND);
			size+= obj->m_header.size;
		}
		
		obj= mask.Find(&_tmp[0]);
		if(!obj)return(ERR_NEEDED_BLOCK_NOT_FOUND);
		obj->m_header.size = size;
	}

	//Подсчитываем размер блока OBIM = сумме размеров IMxx, IMHD + 8 байт
	size =0;
	for(int i=0; i<cnt; i++)
	{
		char _tmp[5]="";
		sprintf(&_tmp[0], "IM%.2d", i+1);
		obj = mask.Find(&_tmp[0]);
		if(!obj)return(ERR_NEEDED_BLOCK_NOT_FOUND);
		size+= obj->m_header.size;
	}
		
	obj=mask.Find("IMHD");
	if(!obj)return(ERR_NEEDED_BLOCK_NOT_FOUND);
	size+= obj->m_header.size + 8;
	mask.m_header.size = size;


	//Запоминаем размер картинки в IMHD
	obj->SetWidth(w);
	obj->SetHeight(h);
	
	xPos=m_instructions.GetXPos();
	yPos=m_instructions.GetYPos();

	//Проверяем положение на кратность 8
	if((fmod((float)xPos,8)!=0)||(fmod((float)yPos,8)!=0))return(ERR_BAD_X_OR_Y);

	
	//Запоминаем положение объекта в IMHD
	if((xPos!= -1)&&yPos!= -1)
	{
		obj->SetXPos(xPos);
		obj->SetYPos(yPos);
	}
	
	//Запоминаем размер картинки в CDHD
	obj = obcd.Find("CDHD");
	if(!obj)return(ERR_NEEDED_BLOCK_NOT_FOUND);
	obj->SetWidth(w);
	obj->SetHeight(h);
	//Запоминаем положение объекта в CDHD
	if((xPos!= -1)&&yPos!= -1)
	{
		obj->SetXPos(xPos);
		obj->SetYPos(yPos);
	}


	//Формируем имя файла объекта и сохраняем
	tmp = (LPTSTR)malloc(20);
	sprintf(tmp, "OBIM_%.4d", number);
	/*--OUT*/printf("\r\n\tSaveFile: %s\\%s",m_parser->GetDstPath(), tmp);
	mask.Save(m_parser->GetDstPath(), tmp);

	//Формируем имя файла объекта и сохраняем
	sprintf(tmp, "OBCD_%.4d", number);
	/*--OUT*/printf("\r\n\tSaveFile: %s\\%s",m_parser->GetDstPath(), tmp);
	obcd .Save(m_parser->GetDstPath(), tmp);

	free(tmp);

	return(0);
}