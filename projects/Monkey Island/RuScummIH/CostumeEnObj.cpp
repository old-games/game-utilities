// CostumeEnObj.cpp: implementation of the CCostumeEnObj class.
//
//////////////////////////////////////////////////////////////////////

#include "stdafx.h"
#include "CostumeEnObj.h"
#include "ImageCodec.h"
#include "BMP.h"
//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

CCostumeEnObj::CCostumeEnObj()
{

}

CCostumeEnObj::~CCostumeEnObj()
{

}

int CCostumeEnObj::Encode()
{
	CChunk mask;		//Маска
	CChunk obj;		//Вспомогательный объект
	WORD cnt=0;			//Количество картинок
	LPTSTR tmp;			//Временная переменная
	DWORD size = 0;		
	CImageCodec codec;	//Кодек
	int w =0;
	int h =0;			//Габариты
	int err;			//Индикатор ошибки
	CBMP bmp(0,0);		//Картинка

	//Выводим сообщение о типе объекта
	/*--OUT*/printf("\tfound costume");

	//Грузим файл инструкций
	err = m_instructions.Load(m_parser->GetSrcPath(), m_parser->GetCurrentFilename());
	if(err)return(err);

	//Загружаем файл маски 0 (сам объект)
	if(!m_instructions.GetMaskName(0))return (ERR_INS_FILE_CORRUPT);
	/*--OUT*/printf("\r\n\tLoadFile: %s\\%s",m_parser->GetSrcPath(), m_instructions.GetMaskName(0));
	err= mask.Load(m_parser->GetSrcPath(), m_instructions.GetMaskName(0));
	if(err)return(err);

	//Загружаем файл маски еще раз (в этом объекте будем проводить изменения и его потом запишем)
	if(!m_instructions.GetMaskName(0))return (ERR_INS_FILE_CORRUPT);
	err= obj.Load(m_parser->GetSrcPath(), m_instructions.GetMaskName(0));
	if(err)return(err);

	//Запоминаем кол-во картинок в сnt
	cnt = mask.GetIMCnt();

	//Проверяем соответствует ли действительности то, что в INS и в маске

	//Создаем переменные, в которую запишем кодированные данные.
	BYTE **data = new BYTE*[cnt];
	WORD *dataSz = new WORD[cnt];
	for(int iii = 0; iii < cnt; iii++)
	{
		//Грузим BMP
		/*--OUT*/printf("\r\n\tLoad BMP: %s\\%s", m_parser->GetSrcPath(), m_instructions.GetIMName(iii));
		err = bmp.LoadBMP(m_parser->GetSrcPath(), m_instructions.GetIMName(iii), ATLANTIS_ENGINE);
		if(err)return(err);

		//Запоминаем размер bmp в локальных переменных и в кодеке
		w =  bmp.GetWidth();
		h =  bmp.GetHeight();
		codec.m_width =w;

		//Выводим размер на экран
		/*--OUT*/printf("\r\n\twidth: %d\theight: %d", w, h);

		//Выводим сообщение о начале кодирования
		/*--OUT*/printf("\r\nEncode image");

		//Пишем новые габариты в структуру картинки.

		data[iii] = codec.Encode(bmp.GetSrc(), ATLANTIS_ENGINE_COSTUME, h, mask.GetNumColors());
		dataSz[iii] = _msize(data[iii]);
	}

    //Высчитыаем новый размер кодированных областей с учетом заголовка фрэйма
	DWORD sz =0;
	for(int i=0; i<cnt; i++)
	{
		sz+= dataSz[i];
		sz+=12;
	}
	//Определяем размер до первой картинки в старом файле
	//и копируем в новый объект
	DWORD szTmp = (mask.GetFrame(0)-12)-mask.m_header.body;
	free(obj.m_header.body);
	obj.m_header.size =szTmp+sz;
	obj.m_header.body = (BYTE*)malloc(szTmp+sz);

	//Копируем все до начала картинок в новое тело
	memcpy(obj.m_header.body, mask.m_header.body, szTmp);
	
	//Далее начинаем копировать заголовки и картинки
	DWORD curSz = szTmp;
	for(int i=0; i<cnt; i++)
	{
		memcpy((obj.m_header.body+curSz), (mask.GetFrame(i)-12), 12);
		curSz+=12;
		memcpy((obj.m_header.body+curSz), data[i], dataSz[i]);
		curSz+=dataSz[i];

		//Получаем старое смещение, старый размер и изменение размера
		if(i>0)
		{
			DWORD ooofff = obj.GetOffsetFrame(i-1)+dataSz[i-1]+12;
			obj.SetOffsetFrame(i, obj.GetOffsetFrame(i-1)+dataSz[i-1]+12);
			ooofff = obj.GetOffsetFrame(i);
			int ijk=0;
		}

	}
	obj.m_header.size+= 8;

	//Формируем имя файла костюма и сохраняем
	
	tmp = strdup(m_parser->GetCurrentFilename());
	char *pt = strrchr(tmp, '.');
	*pt=0;
	/*--OUT*/printf("\r\n\tSaveFile: %s\\%s",m_parser->GetDstPath(), tmp);
	obj.Save(m_parser->GetDstPath(), tmp);
	free(tmp);

	return(0);
}