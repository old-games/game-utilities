// Encoder.cpp: implementation of the CEncoder class.
//
//////////////////////////////////////////////////////////////////////

#include "stdafx.h"
#include "Encoder.h"

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

CEncoder::CEncoder()
{

}

CEncoder::~CEncoder()
{
}

int CEncoder::Init(CCMDParser *parser,char* errdescr)
{
	int err;
	CInstructions ins;
	err= ins.Load(parser->GetSrcPath(), parser->GetCurrentFilename());
	if(err)return(err);

	if(strcmp(ins.GetType(),"RMIM")==0)
	{
		m_object = new CBackgroundEnObj();
	}
	else if(strcmp(ins.GetType(),"IMv3")==0)
	{
		m_object = new CIMv3EnObj();
	}
	else if(strcmp(ins.GetType(),"OBIM")==0)
	{
		m_object = new CObjectEnObj();
	}
	else if(strcmp(ins.GetType(),"COST")==0 || strcmp(ins.GetType(),"CO")==0)
	{
		m_object = new CCostumeEnObj();
	}
	else if(strcmp(ins.GetType(),"CLUT")==0)
	{
		m_object = new CCLUTEnObj();
	}/*
	else if(strcmp(&chunk->m_header.sign[0],"BM")==0)
	{
		m_object = new CBMObj();
	}*/
	else if(strcmp(ins.GetType(),"OI")==0)
	{
		m_object = new COIEnObj();
	}
	else if(strcmp(ins.GetType(),"PA")==0)
	{
		m_object = new CPAEnObj();
	}
	else{
		strcpy(errdescr,ins.GetType());
		return(ERR_UNSUPPORTED_TYPE);
	}

	return(m_object->Init(parser));
}

int CEncoder::Run()
{
	if(m_object)
		return(m_object->Encode());

	return(ERR_NULL_OBJECT);
}