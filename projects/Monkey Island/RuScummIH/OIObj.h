// OIObj.h: interface for the COIObj class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_OIOBJ_H__2EAC5ACD_E9B3_47B6_8D02_1363886A458A__INCLUDED_)
#define AFX_OIOBJ_H__2EAC5ACD_E9B3_47B6_8D02_1363886A458A__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include "Obj.h"

class COIObj : public CObj  
{
public:
	COIObj();
	virtual ~COIObj();

	int Decode();

private:

};

#endif // !defined(AFX_OIOBJ_H__2EAC5ACD_E9B3_47B6_8D02_1363886A458A__INCLUDED_)
