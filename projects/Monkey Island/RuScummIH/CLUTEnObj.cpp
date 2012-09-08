// CLUTEnObj.cpp: implementation of the CCLUTEnObj class.
//
//////////////////////////////////////////////////////////////////////

#include "stdafx.h"
#include "CLUTEnObj.h"
#include "ImageCodec.h"
#include "BMP.h"
//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

CCLUTEnObj::CCLUTEnObj()
{

}

CCLUTEnObj::~CCLUTEnObj()
{

}

int CCLUTEnObj::Encode()
{
	CChunk mask;		//Маска
	LPTSTR tmp;			//Временная переменная
	int err;			//Индикатор ошибки

	//Выводим сообщение о типе объекта
	/*--OUT*/printf("\tfound palette object");

	//Грузим файл инструкций
	err = m_instructions.Load(m_parser->GetSrcPath(), m_parser->GetCurrentFilename());
	if(err)return(err);

	//Загружаем файл маски 0 (сам объект)
	if(!m_instructions.GetMaskName(0))return (ERR_INS_FILE_CORRUPT);
	/*--OUT*/printf("\r\n\tLoadFile: %s\\%s",m_parser->GetSrcPath(), m_instructions.GetMaskName(0));
	err= mask.Load(m_parser->GetSrcPath(), m_instructions.GetMaskName(0));
	if(err)return(err);

	//Выводим сообщение о загрузке файла

	char ttmp[5000]="";
	sprintf(&ttmp[0], "%s\\%s", m_parser->GetSrcPath(), m_instructions.GetIMName(0));

	/*--OUT*/printf("\r\n\tLoad file: %s", &ttmp[0]);

	//Грузим файл 
	HANDLE hFile= CreateFile(&ttmp[0], GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING, 0, NULL);
	if(hFile==INVALID_HANDLE_VALUE)
		return(ERR_UNABLE_LOAD_FILE);

	tmp=(LPTSTR)malloc(GetFileSize(hFile, NULL));

	DWORD sz;
	ReadFile(hFile, tmp, GetFileSize(hFile, NULL), &sz, NULL);
	CloseHandle(hFile);

	//Выводим сообщение о начале кодирования
	/*--OUT*/printf("\r\n\tEncode palette");

	char *cur = tmp;
	char *beg, *end;

	beg = strchr(cur, '[');
	while(beg)
	{
		cur = beg;
		end = strchr(cur,']');
		if(!end)
		{
			free(tmp);
			return(ERR_PALETTE_FILE_CORRUPT);
		}
		*end=0;
		int index=atoi(beg+1);
		*end=']';
		if(index<0 || index>255)
		{
			free(tmp);
			return(ERR_PALETTE_FILE_CORRUPT);
		}
		
		beg=end+1;
		cur = beg;
		end = strchr(cur,',');
		if(!end)
		{
			free(tmp);
			return(ERR_PALETTE_FILE_CORRUPT);
		}
		*end=0;
		int R=atoi(beg);
		*end=',';

		beg=end+1;
		cur = beg;
		end = strchr(cur,',');
		if(!end)
		{
			free(tmp);
			return(ERR_PALETTE_FILE_CORRUPT);
		}
		*end=0;
		int G=atoi(beg);
		*end=',';

		beg=end+1;
		cur = beg;
		end = strchr(cur,'\r');
		if(!end)
		{
			free(tmp);
			return(ERR_PALETTE_FILE_CORRUPT);
		}
		*end=0;
		int B=atoi(beg);
		*end='\r';

		beg = strchr(cur, '[');

		mask.SetRVal(index, R);
		mask.SetGVal(index, G);
		mask.SetBVal(index, B);

		int ijk=0;
	}
	
	

	
	free(tmp);
	/*--OUT*/printf("\r\nSaveFile: %s\\CLUT",m_parser->GetDstPath());
	mask.Save(m_parser->GetDstPath(), "CLUT");

	return(0);
}