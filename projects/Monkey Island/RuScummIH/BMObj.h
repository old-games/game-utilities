// BMObj.h: interface for the CBMObj class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_BMOBJ_H__2EAC5ACD_E9B3_47B6_8D02_1363886A458A__INCLUDED_)
#define AFX_BMOBJ_H__2EAC5ACD_E9B3_47B6_8D02_1363886A458A__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include "Obj.h"

class CBMObj : public CObj  
{
public:
	CBMObj();
	virtual ~CBMObj();

	int Decode();

private:

};

#endif // !defined(AFX_BMOBJ_H__2EAC5ACD_E9B3_47B6_8D02_1363886A458A__INCLUDED_)
