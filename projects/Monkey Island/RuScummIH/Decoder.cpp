// Decoder.cpp: implementation of the CDecoder class.
//
//////////////////////////////////////////////////////////////////////

#include "stdafx.h"
#include "Decoder.h"

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

CDecoder::CDecoder()
{
	m_object = NULL;

}

CDecoder::~CDecoder()
{
	delete m_object;
}

int CDecoder::Init(CChunk *chunk, CCMDParser *parser,char* errdescr)
{
	if(strcmp(&chunk->m_header.sign[0],"COST")==0 || strcmp(&chunk->m_header.sign[0],"CO")==0)
	{
		m_object = new CCostumeObj();
	}
	else if(strcmp(&chunk->m_header.sign[0],"RMIM")==0)
	{
		m_object = new CBackgroundObj();
	}
	else if(strcmp(&chunk->m_header.sign[0],"OBIM")==0)
	{
		m_object = new CObjectObj();
	}
	else if(strcmp(&chunk->m_header.sign[0],"CLUT")==0)
	{
		m_object = new CCLUTObj();
	}
	else if(strcmp(&chunk->m_header.sign[0],"IMv3")==0)
	{
		m_object = new CIMv3Obj();
	}
	else if(strcmp(&chunk->m_header.sign[0],"OIv3")==0)
	{
		m_object = new COIv3Obj();
	}
	else if(strcmp(&chunk->m_header.sign[0],"BM")==0)
	{
		m_object = new CBMObj();
	}
	else if(strcmp(&chunk->m_header.sign[0],"OI")==0)
	{
		m_object = new COIObj();
	}
	else if(strcmp(&chunk->m_header.sign[0],"PA")==0)
	{
		m_object = new CPAObj();
	}
	else {
		strcpy(errdescr,&(chunk->m_header.sign[0]));
		return(ERR_UNSUPPORTED_BLOCK);
	}
	

	return(m_object->Init(chunk, parser));
}

int CDecoder::Run()
{
	if(m_object)
		return(m_object->Decode());

	return(ERR_NULL_OBJECT);
}