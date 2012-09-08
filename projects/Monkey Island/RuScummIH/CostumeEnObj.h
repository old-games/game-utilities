// CostumeEnObj.h: interface for the CCostumeEnObj class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_CostumeEnObj_H__2EAC5ACD_E9B3_47B6_8D02_1363886A458A__INCLUDED_)
#define AFX_CostumeEnObj_H__2EAC5ACD_E9B3_47B6_8D02_1363886A458A__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include "EnObj.h"
#include "Chunk.h"

class CCostumeEnObj : public CEnObj  
{
public:
	CCostumeEnObj();
	virtual ~CCostumeEnObj();

	int Encode();

private:
	bool justCO;
};

#endif // !defined(AFX_CostumeEnObj_H__2EAC5ACD_E9B3_47B6_8D02_1363886A458A__INCLUDED_)
