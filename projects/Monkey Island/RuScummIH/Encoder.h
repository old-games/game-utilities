// Encoder.h: interface for the CEncoder class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_Encoder_H__EA64C4BD_CAD4_4EA1_B2B5_E5FBC6D9E6E6__INCLUDED_)
#define AFX_Encoder_H__EA64C4BD_CAD4_4EA1_B2B5_E5FBC6D9E6E6__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include "EnObj.h"
#include "BackgroundEnObj.h"
#include "ObjectEnObj.h"
#include "CostumeEnObj.h"
#include "PAEnObj.h"
#include "OIEnObj.h"
#include "CLUTEnObj.h"
#include "CMDParser.h"
#include "IMv3EnObj.h"


class CEncoder  
{
public:
	CEncoder();
	virtual ~CEncoder();

	int Init(CCMDParser *parser,char* errdescr);
	int Run();

private:
	CEnObj	*m_object;
};

#endif // !defined(AFX_Encoder_H__EA64C4BD_CAD4_4EA1_B2B5_E5FBC6D9E6E6__INCLUDED_)
