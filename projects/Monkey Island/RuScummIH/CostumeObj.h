// CostumeObj.h: interface for the CCostumeObj class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_CostumeObj_H__2EAC5ACD_E9B3_47B6_8D02_1363886A458A__INCLUDED_)
#define AFX_CostumeObj_H__2EAC5ACD_E9B3_47B6_8D02_1363886A458A__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include "Obj.h"

class CCostumeObj : public CObj  
{
public:
	CCostumeObj();
	virtual ~CCostumeObj();

	int Decode();

private:
	bool justCO;

};

#endif // !defined(AFX_CostumeObj_H__2EAC5ACD_E9B3_47B6_8D02_1363886A458A__INCLUDED_)
