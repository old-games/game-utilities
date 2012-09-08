// OIObj.cpp: implementation of the CPAObj class.
//
//////////////////////////////////////////////////////////////////////

#include "stdafx.h"
#include "PAObj.h"
#include "ImageCodec.h"
#include "BMP.H"

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

CPAObj::CPAObj()
{
}

CPAObj::~CPAObj()
{
}

int CPAObj::Decode()
{
	CChunk pa;
//	CChunk *obj;
//	LPTSTR tmp;

	/*--OUT*/printf("\tFound object");

	//Выбираем номер объекта
	/*--OUT*///printf("\r\n\tLoad file: %s\\PA", m_parser->GetSrcPath());
	//pa.Load(m_parser->GetSrcPath(), "PA");

	/*--OUT*/printf("\r\n\tCreate palette file");

	char ttmp[1000]="";
	sprintf(&ttmp[0], "%s\\%s", m_parser->GetDstPath(), "PA.pal");
	HANDLE hFile =  CreateFile(&ttmp[0], GENERIC_WRITE, FILE_SHARE_READ, NULL, CREATE_ALWAYS, 0, NULL);
	if(hFile == INVALID_HANDLE_VALUE)
		return(ERR_UNABLE_SAVE_FILE);

	for(int i=0; i< 256; i++)
	{
		DWORD sz;
		sprintf(&ttmp[0], "[%.3d] %.3d,%.3d,%.3d\r\n",i, m_chunk->GetRVal(i), m_chunk->GetGVal(i), m_chunk->GetBVal(i));
		WriteFile(hFile, &ttmp[0], strlen(&ttmp[0]), &sz, NULL);
	}
	CloseHandle(hFile);


	//create mask
	/*--OUT*/printf("\r\n\tCreate mask: %s\\%s", m_parser->GetDstPath(), "PA.msk");
	m_chunk->Save(m_parser->GetDstPath(), "PA.msk");
	m_instructions.AddMaskName("PA.msk");

	m_instructions.SetType("PA");
	m_instructions.AddIMName("PA.pal");
	m_instructions.Save(m_parser->GetDstPath(), "PA.ins");
	return(0);
}