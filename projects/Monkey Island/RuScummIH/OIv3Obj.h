// OIv3Obj.h: interface for the COIv3Obj class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_OIv3OBJ_H__2EAC5ACD_E9B3_47B6_8D02_1363886A458A__INCLUDED_)
#define AFX_OIv3OBJ_H__2EAC5ACD_E9B3_47B6_8D02_1363886A458A__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include "Obj.h"

class COIv3Obj : public CObj  
{
public:
	COIv3Obj();
	virtual ~COIv3Obj();

	int Decode();

private:

};

#endif // !defined(AFX_OIv3OBJ_H__2EAC5ACD_E9B3_47B6_8D02_1363886A458A__INCLUDED_)
