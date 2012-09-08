// IMv3EnObj.h: interface for the CIMv3EnObj class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_IMv3EnObj_H__2EAC5ACD_E9B3_47B6_8D02_1363886A458A__INCLUDED_)
#define AFX_IMv3EnObj_H__2EAC5ACD_E9B3_47B6_8D02_1363886A458A__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include "EnObj.h"
#include "Chunk.h"

class CIMv3EnObj : public CEnObj  
{
public:
	CIMv3EnObj();
	virtual ~CIMv3EnObj();

	int Encode();

private:

};

#endif // !defined(AFX_IMv3EnObj_H__2EAC5ACD_E9B3_47B6_8D02_1363886A458A__INCLUDED_)
