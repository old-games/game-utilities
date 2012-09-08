// Obj.h: interface for the CObj class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_OBJ_H__75970708_C75D_4B6B_A947_1D559263A376__INCLUDED_)
#define AFX_OBJ_H__75970708_C75D_4B6B_A947_1D559263A376__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include "Chunk.h"
#include "CMDParser.h"
#include "Instructions.h"

class CObj  
{
public:
	CObj();
	virtual ~CObj();

	virtual int Init(CChunk *chunk, CCMDParser *parser);
	virtual int Decode()=0;

protected:
	CChunk *m_chunk;
	CCMDParser *m_parser;
	CInstructions m_instructions;

};

#endif // !defined(AFX_OBJ_H__75970708_C75D_4B6B_A947_1D559263A376__INCLUDED_)
