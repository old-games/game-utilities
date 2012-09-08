// BackgroundEnObj.h: interface for the CBackgroundEnObj class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_BackgroundEnObj_H__2EAC5ACD_E9B3_47B6_8D02_1363886A458A__INCLUDED_)
#define AFX_BackgroundEnObj_H__2EAC5ACD_E9B3_47B6_8D02_1363886A458A__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include "EnObj.h"
#include "Chunk.h"

class CBackgroundEnObj : public CEnObj  
{
public:
	CBackgroundEnObj();
	virtual ~CBackgroundEnObj();

	int Encode();

private:

};

#endif // !defined(AFX_BackgroundEnObj_H__2EAC5ACD_E9B3_47B6_8D02_1363886A458A__INCLUDED_)
