// CLUTEnObj.h: interface for the CCLUTEnObj class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_CLUTEnObj_H__2EAC5ACD_E9B3_47B6_8D02_1363886A458A__INCLUDED_)
#define AFX_CLUTEnObj_H__2EAC5ACD_E9B3_47B6_8D02_1363886A458A__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include "EnObj.h"
#include "Chunk.h"

class CCLUTEnObj : public CEnObj  
{
public:
	CCLUTEnObj();
	virtual ~CCLUTEnObj();

	int Encode();

private:

};

#endif // !defined(AFX_CLUTEnObj_H__2EAC5ACD_E9B3_47B6_8D02_1363886A458A__INCLUDED_)
