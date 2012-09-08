// PAObj.h: interface for the CPAObj class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_PAOBJ_H__2EAC5ACD_E9B3_47B6_8D02_1363886A458A__INCLUDED_)
#define AFX_PAOBJ_H__2EAC5ACD_E9B3_47B6_8D02_1363886A458A__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include "Obj.h"

class CPAObj : public CObj  
{
public:
	CPAObj();
	virtual ~CPAObj();

	int Decode();

private:

};

#endif // !defined(AFX_PAOBJ_H__2EAC5ACD_E9B3_47B6_8D02_1363886A458A__INCLUDED_)
