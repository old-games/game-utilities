// IMv3Obj.h: interface for the CIMv3Obj class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_IMv3Obj_H__2EAC5ACD_E9B3_47B6_8D02_1363886A458A__INCLUDED_)
#define AFX_IMv3Obj_H__2EAC5ACD_E9B3_47B6_8D02_1363886A458A__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include "Obj.h"

class CIMv3Obj : public CObj  
{
public:
	CIMv3Obj();
	virtual ~CIMv3Obj();

	int Decode();

private:

};

#endif // !defined(AFX_IMv3Obj_H__2EAC5ACD_E9B3_47B6_8D02_1363886A458A__INCLUDED_)
