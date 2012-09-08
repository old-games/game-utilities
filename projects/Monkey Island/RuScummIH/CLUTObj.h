// CLUTObj.h: interface for the CCLUTObj class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_CLUTOBJ_H__2EAC5ACD_E9B3_47B6_8D02_1363886A458A__INCLUDED_)
#define AFX_CLUTOBJ_H__2EAC5ACD_E9B3_47B6_8D02_1363886A458A__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include "Obj.h"

class CCLUTObj : public CObj  
{
public:
	CCLUTObj();
	virtual ~CCLUTObj();

	int Decode();

private:

};

#endif // !defined(AFX_CLUTOBJ_H__2EAC5ACD_E9B3_47B6_8D02_1363886A458A__INCLUDED_)
