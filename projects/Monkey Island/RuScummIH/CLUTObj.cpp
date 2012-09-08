// OIObj.cpp: implementation of the CCLUTObj class.
//
//////////////////////////////////////////////////////////////////////

#include "stdafx.h"
#include "CLUTObj.h"
#include "ImageCodec.h"
#include "BMP.H"

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

CCLUTObj::CCLUTObj()
{
}

CCLUTObj::~CCLUTObj()
{
}

int CCLUTObj::Decode()
{
	CChunk CLUT;
	//CChunk *obj;
	//LPTSTR tmp;

	/*--OUT*/printf("\tFound object");

	//Выбираем номер объекта
	/*--OUT*///printf("\r\n\tLoad file: %s\\CLUT", m_parser->GetSrcPath());
	//CLUT.Load(m_parser->GetSrcPath(), "CLUT");

	/*--OUT*/printf("\r\n\tCreate palette file");

	char ttmp[1000]="";
	sprintf(&ttmp[0], "%s\\%s", m_parser->GetDstPath(), "CLUT.pal");
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
	/*--OUT*/printf("\r\n\tCreate mask: %s\\%s", m_parser->GetDstPath(), "CLUT.msk");
	m_chunk->Save(m_parser->GetDstPath(), "CLUT.msk");
	m_instructions.AddMaskName("CLUT.msk");

	m_instructions.SetType("CLUT");
	m_instructions.AddIMName("CLUT.pal");
	m_instructions.Save(m_parser->GetDstPath(), "CLUT.ins");
	return(0);
}