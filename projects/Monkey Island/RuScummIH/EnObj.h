// EnObj.h: interface for the CEnObj class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_EnObj_H__75970708_C75D_4B6B_A947_1D559263A376__INCLUDED_)
#define AFX_EnObj_H__75970708_C75D_4B6B_A947_1D559263A376__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include "CMDParser.h"
#include "Instructions.h"

class CEnObj  
{
public:
	CEnObj();
	virtual ~CEnObj();

	virtual int Init(CCMDParser * parser);
	virtual int Encode()=0;

protected:
	CCMDParser *m_parser;
	CInstructions m_instructions;
};

#endif // !defined(AFX_EnObj_H__75970708_C75D_4B6B_A947_1D559263A376__INCLUDED_)
